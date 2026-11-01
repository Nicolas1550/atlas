import { NextRequest, NextResponse } from 'next/server';
import { sendSecurityEvent } from '@/lib/sentinel';
import { sessionCookie } from '@/lib/auth';

export async function POST(request: NextRequest) {
  await sendSecurityEvent(request, 'logout', '', 'Cierre de sesión solicitado');
  const response = NextResponse.json({ ok: true });
  response.cookies.set(sessionCookie.name, '', { ...sessionCookie.options, maxAge: 0 });
  return response;
}
