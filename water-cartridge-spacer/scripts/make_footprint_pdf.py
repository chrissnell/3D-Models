#!/usr/bin/env python3
"""Generate print-ready 1:1 footprint PDFs from the OpenSCAD SVG export.

The spacer footprint is ~250.5 mm across, larger than the short side of a
US Letter / A4 sheet, so it cannot print on one page at true scale. This
produces two PDFs:

  * <base>-actual-size.pdf : one custom-size page at 1:1 (for Tabloid/A3,
    a plotter, or Acrobat's own "Poster" tiling).
  * <base>-letter-tiled.pdf : the same outline pre-tiled across US Letter
    pages at 1:1, with crop marks, overlap, and a calibration square.

Every PDF carries a 100 mm calibration square — measure it after printing;
if it isn't exactly 100 mm the print was scaled and must be redone at 100%.
"""
import sys
from svglib.svglib import svg2rlg
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.graphics import renderPDF

PT_PER_MM = 72.0 / 25.4

def calibration(c, x, y, size_mm=100):
    """Draw a labelled square of known size for post-print scale checking."""
    s = size_mm * PT_PER_MM
    c.setLineWidth(0.75)
    c.rect(x, y, s, s)
    c.setFont("Helvetica", 9)
    c.drawString(x + 4, y + 4, f"Calibration: this square is {size_mm} mm x {size_mm} mm")
    c.drawString(x + 4, y + s - 12, "Measure after printing to confirm 100% scale")

def make_actual_size(drawing, out, base_name):
    b = drawing.getBounds()
    gw, gh = b[2] - b[0], b[3] - b[1]
    margin = 20
    cal = 100 * PT_PER_MM
    gap = 30
    pw = max(gw, cal) + 2 * margin
    ph = gh + gap + cal + 20 + 2 * margin
    c = canvas.Canvas(out, pagesize=(pw, ph))
    renderPDF.draw(drawing, c, margin - b[0], ph - margin - gh - b[1])
    calibration(c, margin, margin, 100)
    c.setFont("Helvetica", 9)
    c.drawString(margin, ph - 12, f"{base_name} footprint - 1:1 actual size "
                 f"({gw/PT_PER_MM:.1f} x {gh/PT_PER_MM:.1f} mm)")
    c.showPage()
    c.save()

def crop_marks(c, x0, y0, x1, y1, m=12):
    c.setLineWidth(0.5)
    for (cx, cy, dx, dy) in [(x0, y0, 1, 1), (x1, y0, -1, 1),
                             (x0, y1, 1, -1), (x1, y1, -1, -1)]:
        c.line(cx, cy, cx + dx * m, cy)
        c.line(cx, cy, cx, cy + dy * m)

def make_letter_tiled(drawing, out, base_name):
    b = drawing.getBounds()
    bx0, by0 = b[0], b[1]
    gw, gh = b[2] - b[0], b[3] - b[1]
    pageW, pageH = letter
    margin = 27                      # 0.375 in printer border
    overlap = 36                     # 0.5 in overlap between tiles
    printW, printH = pageW - 2 * margin, pageH - 2 * margin
    stepX, stepY = printW - overlap, printH - overlap
    import math
    # A single page covers printW/printH; each extra tile adds one step.
    cols = max(1, math.ceil((gw - printW) / stepX) + 1)
    rows = max(1, math.ceil((gh - printH) / stepY) + 1)
    c = canvas.Canvas(out, pagesize=letter)

    # Cover / calibration page.
    c.setFont("Helvetica-Bold", 14)
    c.drawString(margin, pageH - margin - 14, f"{base_name} - 1:1 footprint, tiled")
    c.setFont("Helvetica", 10)
    lines = [
        f"Full size: {gw/PT_PER_MM:.1f} x {gh/PT_PER_MM:.1f} mm - too large for one Letter/A4 sheet.",
        f"Printed across {rows} x {cols} = {rows*cols} tiles.",
        "",
        "PRINT SETTINGS (critical):",
        "  - Scale: 100% / Actual size (NOT 'Fit to page').",
        "  - Then measure the square below: it must be exactly 100 mm.",
        "",
        "ASSEMBLY:",
        "  - Trim each sheet to the crop marks.",
        "  - Tiles overlap 0.5 in; align the outline across the seam and tape.",
    ]
    ty = pageH - margin - 40
    for ln in lines:
        c.drawString(margin, ty, ln)
        ty -= 15
    calibration(c, margin, margin, 100)
    c.showPage()

    # Tiles, bottom-up so page order reads row 1..N.
    for row in range(rows):
        for col in range(cols):
            c.saveState()
            p = c.beginPath()
            p.rect(margin, margin, printW, printH)
            c.clipPath(p, stroke=0)
            X = margin - bx0 - col * stepX
            Y = margin - by0 - row * stepY
            renderPDF.draw(drawing, c, X, Y)
            c.restoreState()
            crop_marks(c, margin, margin, margin + printW, margin + printH)
            c.setFont("Helvetica", 9)
            c.drawString(margin, margin - 14,
                         f"{base_name}  tile row {row+1}/{rows}  col {col+1}/{cols}"
                         "  -  print at 100%, trim to marks, align overlap")
            c.showPage()
    c.save()
    return rows, cols

def main():
    svg, base = sys.argv[1], sys.argv[2]
    d = svg2rlg(svg)
    make_actual_size(d, f"{base}-actual-size.pdf", base.split('/')[-1])
    r, cnt = make_letter_tiled(d, f"{base}-letter-tiled.pdf", base.split('/')[-1])
    print(f"actual-size + {r}x{cnt} tiled Letter PDF written")

if __name__ == "__main__":
    main()
