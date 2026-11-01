import { NextRequest, NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { getDb, isDatabaseConfigured } from '@/lib/db';
import { createToken, isSessionConfigured, sessionCookie } from '@/lib/auth';
import { authUnavailable, fail } from '@/lib/api';
import { isLoginBlocked, recordLoginFailure, clearLoginFailures } from '@/lib/login-guard';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  if (!isDatabaseConfigured()) return authUnavailable();
  if (!isSessionConfigured()) return fail('Configurá JWT_SECRET en .env.local antes de registrar usuarios.', 503);
  try {
    const body = await request.json();
    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    const password = typeof body.password === 'string' ? body.password : '';
    if (!email || !password || email.length > 254 || password.length > 128) return fail('Credenciales inválidas.', 401);
    if (await isLoginBlocked(email)) return fail('Demasiados intentos. Probá nuevamente dentro de 15 minutos.', 429);
    const sql = getDb();
    const rows = await sql`SELECT id, display_name, email, password_hash FROM users WHERE email = ${email} LIMIT 1`;
    const user = rows[0];
    if (!user || !(await bcrypt.compare(password, String(user.password_hash)))) {
      await recordLoginFailure(email);
      return fail('Correo o contraseña incorrectos.', 401);
    }
    await clearLoginFailures(email);
    const token = await createToken(String(user.id));
    const response = NextResponse.json({ user: { id: user.id, name: user.display_name, email: user.email } });
    response.cookies.set(sessionCookie.name, token, sessionCookie.options);
    return response;
  } catch {
    return fail('Error al iniciar sesión. Revisá la conexión con la base de datos.', 500);
  }
}
