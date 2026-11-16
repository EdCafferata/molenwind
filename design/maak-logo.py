import math, sys
from PIL import Image, ImageDraw
S = 4096                      # 4x supersampling, daarna naar 1024
img = Image.new("RGB", (S, S))
d = ImageDraw.Draw(img)
# Verticale oranje gradiënt (warm, avondzon)
top, bot = (10, 10, 11), (10, 10, 11)   # egaal zwart
for y in range(S):
    t = y / (S - 1)
    d.line([(0, y), (S, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))

W = (255, 149, 0)   # oranje molen (zelfde oranje als de app)
cx, hub_y = S * 0.50, S * 0.36
# Romp: achtkante grondzeiler (trapezium) + kap
romp = [(cx - S*0.12, S*0.86), (cx + S*0.12, S*0.86), (cx + S*0.07, hub_y + S*0.07), (cx - S*0.07, hub_y + S*0.07)]
d.polygon(romp, fill=W)
d.polygon([(cx - S*0.095, hub_y + S*0.08), (cx + S*0.095, hub_y + S*0.08), (cx + S*0.055, hub_y - S*0.04), (cx - S*0.055, hub_y - S*0.04)], fill=W)
d.rectangle([cx - S*0.11, hub_y + S*0.075, cx + S*0.11, hub_y + S*0.095], fill=W)  # stelling/rand onder de kap
# Deur
d.rounded_rectangle([cx - S*0.03, S*0.76, cx + S*0.03, S*0.86], radius=S*0.03, fill=bot)
# Grond
d.rounded_rectangle([S*0.18, S*0.855, S*0.82, S*0.885], radius=S*0.015, fill=W)

def roteer(p, hoek):
    x, y = p[0] - cx, p[1] - hub_y
    c, s = math.cos(hoek), math.sin(hoek)
    return (cx + x*c - y*s, hub_y + x*s + y*c)

# Vier wieken VOOR de romp (zoals bij een echte molen). Per wiek eerst een oranje vlak, dan het witte hekwerk:
# zo komen de wieken netjes los van de toren.
L, B = S*0.37, S*0.085
halo = (10, 10, 11)    # smalle scheiding wieken/toren, zelfde zwart als de achtergrond
e = S*0.007
r = S*0.013
x0, x1, y0, y1 = cx + r, cx + r + B, hub_y - S*0.085, hub_y - L
for k in range(4):
    a = math.radians(25 + 90*k)
    vlak = [(cx - r - e, hub_y), (x1 + e, hub_y), (x1 + e, y1 - e), (cx - r - e, y1 - e)]
    d.polygon([roteer(p, a) for p in vlak], fill=halo)
for k in range(4):
    a = math.radians(25 + 90*k)
    roede = [(cx - r, hub_y), (cx + r, hub_y), (cx + r, y1), (cx - r, y1)]
    d.polygon([roteer(p, a) for p in roede], fill=W)
    w = int(S*0.012)
    for (p, q) in [((x0, y0), (x1, y0)), ((x1, y0), (x1, y1)), ((x0, y1), (x1, y1))]:
        d.line([roteer(p, a), roteer(q, a)], fill=W, width=w)
    for i in range(1, 6):
        y = y0 + (y1 - y0) * i / 6
        d.line([roteer((x0, y), a), roteer((x1, y), a)], fill=W, width=int(S*0.009))
d.ellipse([cx - S*0.046, hub_y - S*0.046, cx + S*0.046, hub_y + S*0.046], fill=halo)
d.ellipse([cx - S*0.038, hub_y - S*0.038, cx + S*0.038, hub_y + S*0.038], fill=W)

# Molen iets verkleinen en centreren (ruimte voor de afgeronde hoeken van iOS)
kader = Image.new("RGB", (S, S), bot)
klein = img.resize((int(S*0.86), int(S*0.86)), Image.LANCZOS)
kader.paste(klein, ((S - klein.width)//2, (S - klein.height)//2 + int(S*0.01)))
icoon = kader.resize((1024, 1024), Image.LANCZOS)
icoon.save(sys.argv[1])
icoon.save(sys.argv[2])
