import { NextResponse } from 'next/server';
import { getDb, isDatabaseConfigured } from '@/lib/db';
import { isSessionConfigured } from '@/lib/auth';

export const runtime = 'nodejs';

export async function GET() {
  if (!isDatabaseConfigured()) {
    return NextResponse.json({ app: 'ok', database: 'not-configured', message: 'Modo demostración: mapa y datos USGS disponibles.' });
  }
  try {
    const sql = getDb();
    await sql`SELECT 1`;
    return NextResponse.json({ app: 'ok', database: 'connected', authentication: isSessionConfigured() ? 'configured' : 'missing-jwt-secret' });
  } catch {
    return NextResponse.json({ app: 'ok', database: 'error', message: 'Revisá DATABASE_URL y las tablas SQL.' }, { status: 503 });
  }
}
