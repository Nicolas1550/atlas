"""Genera la vista previa Open Graph de ATLAS a partir de su textura terrestre."""
from pathlib import Path
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
root=Path(__file__).resolve().parents[1]
W,H=1200,630
Y,X=np.mgrid[:H,:W]
base=np.zeros((H,W,3),dtype=np.uint8)
base[:,:,0]=np.clip(4+10*(X/W),0,255)
base[:,:,1]=np.clip(14+17*(X/W),0,255)
base[:,:,2]=np.clip(25+22*(X/W),0,255)
img=Image.fromarray(base,'RGB').convert('RGBA')
d=ImageDraw.Draw(img,'RGBA')
for i in range(0,W,52): d.line((i,0,i,H),fill=(64,157,169,5))
for i in range(0,H,52): d.line((0,i,W,i),fill=(64,157,169,5))
# Globo ortográfico usando la textura original.
tex=np.array(Image.open(root/'public/earth-night.jpg').convert('RGB'))
cx,cy,r=885,325,267
yy,xx=np.mgrid[-r:r,-r:r]
x=xx/r;y=-yy/r
rho2=x*x+y*y
inside=rho2<=1
z=np.sqrt(np.maximum(0,1-rho2))
# Vista centrada en el Pacífico occidental / Asia
lon0=math.radians(115)
lat0=math.radians(10)
lat=np.arcsin(np.clip(y*math.cos(lat0)+z*math.sin(lat0),-1,1))
lon=lon0+np.arctan2(x, z*math.cos(lat0)-y*math.sin(lat0))
u=((lon+math.pi)%(2*math.pi))/(2*math.pi)
v=(math.pi/2-lat)/math.pi
pix=tex[np.clip((v*(tex.shape[0]-1)).astype(int),0,tex.shape[0]-1),np.clip((u*(tex.shape[1]-1)).astype(int),0,tex.shape[1]-1)]
shade=np.clip(0.35+0.65*z+0.14*x,0,1)
rgba=np.zeros((2*r,2*r,4),dtype=np.uint8)
rgba[:,:,:3]=np.clip(pix*shade[:,:,None]*1.25,0,255).astype(np.uint8)
rgba[:,:,3]=np.where(inside,255,0).astype(np.uint8)
globe=Image.fromarray(rgba,'RGBA')
# Halo exterior.
halo=Image.new('RGBA',(2*r+100,2*r+100))
hd=ImageDraw.Draw(halo,'RGBA')
hd.ellipse((50,50,2*r+50,2*r+50),fill=(19,166,190,100))
halo=halo.filter(ImageFilter.GaussianBlur(32))
img.alpha_composite(halo,(cx-r-50,cy-r-50))
img.alpha_composite(globe,(cx-r,cy-r))
d=ImageDraw.Draw(img,'RGBA')
d.ellipse((cx-r,cy-r,cx+r,cy+r),outline=(77,213,218,150),width=2)
for rr in [r+36,r+78]: d.ellipse((cx-rr,cy-rr,cx+rr,cy+rr),outline=(44,135,158,55),width=2)
# Copy
font_dir=Path('/usr/share/fonts/truetype/lato')
regular=ImageFont.truetype(str(font_dir/'Lato-Regular.ttf'),21)
small=ImageFont.truetype(str(font_dir/'Lato-Bold.ttf'),17)
logo=ImageFont.truetype(str(font_dir/'Lato-Heavy.ttf'),54)
headline=ImageFont.truetype(str(font_dir/'Lato-Heavy.ttf'),67)
d.text((75,64),'ATLAS.',font=logo,fill=(215,249,248,255))
d.line((77,144,145,144),fill=(111,232,218,255),width=3)
d.text((75,176),'EARTH INTELLIGENCE',font=small,fill=(122,221,216,255),spacing=6)
d.text((70,245),'El planeta',font=headline,fill=(237,249,252,255))
d.text((70,321),'está vivo.',font=headline,fill=(115,232,221,255))
d.text((76,424),'Exploración sísmica 3D',font=regular,fill=(161,190,201,255))
d.text((76,456),'Datos USGS  ·  Next.js  ·  PostgreSQL',font=regular,fill=(161,190,201,255))
d.rounded_rectangle((76,533,272,577),radius=8,fill=(17,66,73,255),outline=(75,187,182,150),width=1)
d.text((95,544),'FULL STACK  /  V1.0',font=small,fill=(142,239,225,255))
img.convert('RGB').save(root/'public/og-atlas.jpg',quality=89,optimize=True)
print('Created',root/'public/og-atlas.jpg')
