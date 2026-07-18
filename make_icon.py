#!/usr/bin/env python3
"""Bold single-emblem app icon: gold sun + origami-crane silhouette on a night-teal gradient.
No detailed scene, no text — matches Q's icon style preference (bold, not detailed)."""

from PIL import Image, ImageDraw
import math

SIZE = 1024
img = Image.new("RGB", (SIZE, SIZE), "#0a0e18")
draw = ImageDraw.Draw(img)

# Vertical gradient: deep indigo night -> pine/teal green (echoes the card-table + Aug "moon" bright)
top = (14, 18, 36)
bottom = (10, 46, 34)
for y in range(SIZE):
    t = y / SIZE
    r = int(top[0] + (bottom[0] - top[0]) * t)
    g = int(top[1] + (bottom[1] - top[1]) * t)
    b = int(top[2] + (bottom[2] - top[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

# Gold sun disc, upper-right of center (echoes the Jan "Crane & Sun" bright card)
sun_cx, sun_cy, sun_r = SIZE * 0.62, SIZE * 0.36, SIZE * 0.30
draw.ellipse([sun_cx - sun_r, sun_cy - sun_r, sun_cx + sun_r, sun_cy + sun_r], fill=(255, 205, 90))
# subtle inner ring for depth
inner_r = sun_r * 0.86
draw.ellipse([sun_cx - inner_r, sun_cy - inner_r, sun_cx + inner_r, sun_cy + inner_r], fill=(255, 216, 120))


def scale_pts(pts, ox, oy, s):
    return [(ox + x * s, oy + y * s) for x, y in pts]


# Origami crane silhouette built from flat polygon facets (unit space, crane facing left, standing).
s = SIZE * 0.62
ox, oy = SIZE * 0.30, SIZE * 0.40

body = [
    (0.10, 0.55), (0.55, 0.30), (0.98, 0.42), (0.80, 0.55),
    (0.55, 0.68), (0.30, 0.78), (0.15, 0.70),
]
neck_head = [
    (0.10, 0.55), (-0.18, 0.18), (-0.30, -0.05), (-0.22, -0.02),
    (-0.08, 0.20), (0.02, 0.40), (0.15, 0.60),
]
beak = [(-0.30, -0.05), (-0.42, -0.10), (-0.28, 0.02)]
tail = [(0.80, 0.55), (1.05, 0.62), (0.95, 0.70), (0.72, 0.66)]
wing = [(0.30, 0.35), (0.62, 0.10), (0.90, 0.20), (0.66, 0.30), (0.50, 0.50), (0.32, 0.50)]
leg1 = [(0.30, 0.78), (0.24, 1.02), (0.32, 1.03), (0.38, 0.80)]
leg2 = [(0.45, 0.75), (0.44, 1.04), (0.52, 1.04), (0.53, 0.78)]

cream = (250, 246, 235)
shadow = (222, 214, 196)

for shape, color in [
    (leg1, shadow), (leg2, shadow),
    (tail, cream), (body, cream), (neck_head, cream), (beak, cream),
    (wing, shadow),
]:
    draw.polygon(scale_pts(shape, ox, oy, s), fill=color)

img.save("/Users/user/HanafudaKoiKoi/HanafudaKoiKoi/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
print("wrote AppIcon.png", img.size)
