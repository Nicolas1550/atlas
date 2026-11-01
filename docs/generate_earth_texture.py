"""Genera textura terrestre local sin depender de imágenes de terceros.
Requiere Basemap, numpy y Pillow solo para regenerarla (el proyecto ya trae JPG).
"""
import math
import random
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from mpl_toolkits.basemap import Basemap

random.seed(13)
W, H = 2048, 1024
rng = np.random.default_rng(43)
y, x = np.mgrid[:H, :W]
noise = rng.normal(0, 1.6, (H, W))
lat = (0.5 - y / H) * math.pi
r = (3 + 5 * np.cos(lat)**2 + 1.4*np.sin(x/27) + noise).clip(0, 255)
g = (18 + 7 * np.cos(lat)**2 + 2.5*np.sin(x/53) + noise).clip(0, 255)
b = (33 + 9 * np.cos(lat)**2 + 3.5*np.sin(x/73) + noise).clip(0, 255)
img = Image.fromarray(np.stack([r,g,b], axis=-1).astype('uint8'), 'RGB')
mask = Image.new('L', (W,H), 0)
dm = ImageDraw.Draw(mask)
map_obj = Basemap(projection='cyl', llcrnrlon=-180, urcrnrlon=180, llcrnrlat=-90, urcrnrlat=90, resolution='l')
for p in map_obj.landpolygons:
    coords = p.get_coords()
    if len(coords) < 3: continue
    points = [((lon+180)/360*W, (90-lat)/180*H) for lon,lat in coords]
    dm.polygon(points, fill=255)
land_arr = np.asarray(mask) > 0
base = np.asarray(img).copy()
land_noise = rng.normal(0, 3, (H,W))
base[land_arr, 0] = np.clip(14 + land_noise[land_arr],0,255)
base[land_arr, 1] = np.clip(49 + land_noise[land_arr],0,255)
base[land_arr, 2] = np.clip(62 + land_noise[land_arr],0,255)
img = Image.fromarray(base, 'RGB')
draw = ImageDraw.Draw(img, 'RGBA')
for p in map_obj.landpolygons:
    coords = p.get_coords()
    if len(coords) < 3: continue
    points = [((lon+180)/360*W, (90-lat)/180*H) for lon,lat in coords]
    draw.line(points+[points[0]], fill=(60,190,198,65), width=2)
for lon in range(-180, 181, 30):
    px = int((lon+180)/360*W)
    draw.line((px,0,px,H), fill=(56,134,164,19), width=1)
for latitude in range(-90,91,30):
    py = int((90-latitude)/180*H)
    draw.line((0,py,W,py), fill=(56,134,164,19), width=1)
# Synthetic ambient urban lights, only on land. Not live measurements.
glow = Image.new('RGBA', (W,H), (0,0,0,0))
gd = ImageDraw.Draw(glow, 'RGBA')
for _ in range(14500):
    px = random.randrange(W); py = random.randrange(H)
    if not land_arr[py,px]: continue
    if random.random() < 0.66: continue
    radius = random.choice([1,1,1,2])
    gd.ellipse((px-radius,py-radius,px+radius,py+radius), fill=(100,222,219,random.randint(32,125)))
blur = glow.filter(ImageFilter.GaussianBlur(4))
img = Image.alpha_composite(img.convert('RGBA'), blur)
img = Image.alpha_composite(img, glow).convert('RGB')
output = Path(__file__).resolve().parents[1] / 'public' / 'earth-night.jpg'
img.save(output, quality=88, optimize=True)
print('Created', output, output.stat().st_size)
