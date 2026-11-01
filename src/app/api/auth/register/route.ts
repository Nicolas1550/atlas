import { NextRequest, NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import { getDb, isDatabaseConfigured } from '@/lib/db';
import { createToken, isSessionConfigured, sessionCookie } from '@/lib/auth';
import { authUnavailable, fail, validEmail } from '@/lib/api';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  if (!isDatabaseConfigured()) return authUnavailable();
  if (!isSessionConfigured()) return fail('Configurá JWT_SECRET en .env.local antes de registrar usuarios.', 503);
  try {
    const body = await request.json();
    const name = typeof body.name === 'string' ? body.name.trim() : '';
    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
    const password = typeof body.password === 'string' ? body.password : '';
    if (name.length < 2 || name.length > 60) return fail('El nombre debe tener entre 2 y 60 caracteres.');
    if (!validEmail(email)) return fail('Ingresá un correo electrónico válido.');
    if (password.length < 8 || password.length > 128) return fail('La contraseña debe tener entre 8 y 128 caracteres.');
    const hash = await bcrypt.hash(password, 12);
    const sql = getDb();
    const rows = await sql`INSERT INTO users (display_name, email, password_hash)
      VALUES (${name}, ${email}, ${hash}) RETURNING id, display_name, email`;
    const user = rows[0];
    const token = await createToken(String(user.id));
    const response = NextResponse.json({ user: { id: user.id, name: user.display_name, email: user.email } }, { status: 201 });
    response.cookies.set(sessionCookie.name, token, sessionCookie.options);
    return response;
  } catch (error: unknown) {
    if (typeof error === 'object' && error && 'code' in error && error.code === '23505') {
      return fail('Ya existe una cuenta con ese correo.', 409);
    }
    return fail('No se pudo crear la cuenta. Verificá la configuración SQL y JWT_SECRET.', 500);
  }
}
