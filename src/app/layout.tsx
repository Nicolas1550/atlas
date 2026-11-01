import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'ATLAS V4 — Earth Intelligence | Global Seismic Intelligence',
  description: 'Explorá eventos sísmicos USGS sobre un globo 3D. Time Machine, historial sísmico, alertas programadas, investigaciones con eventos, informes compartibles y PostgreSQL.',
  applicationName: 'ATLAS Earth Intelligence',
  openGraph: {
    title: 'ATLAS V4 — Earth Intelligence',
    description: 'Globo 3D, archivo histórico Neon, alertas, investigaciones e informes compartibles.',
    type: 'website',
    images: [{ url: '/og-atlas.jpg', width: 1200, height: 630, alt: 'ATLAS Earth Intelligence — planeta 3D y datos sísmicos' }],
  },
  twitter: { card: 'summary_large_image', images: ['/og-atlas.jpg'] },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="es"><body>{children}</body></html>;
}
