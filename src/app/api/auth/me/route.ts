import { NextResponse } from 'next/server';
import { getUserId } from '@/lib/auth';
import { getDb, isDatabaseConfigured } from '@/lib/db';

export const runtime = 'nodejs';

export async function GET() {
  if (!isDatabaseConfigured()) return NextResponse.json({ user: null, configured: false });
  const id = await getUserId();
  if (!id) return NextResponse.json({ user: null, configured: true });
  try {
    const sql = getDb();
    const rows = await sql`SELECT id, display_name, email FROM users WHERE id = ${id} LIMIT 1`;
    const user = rows[0];
    return NextResponse.json({ user: user ? { id: user.id, name: user.display_name, email: user.email } : null, configured: true });
  } catch {
    return NextResponse.json({ user: null, configured: true });
  }
}
