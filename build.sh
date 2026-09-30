#!/bin/bash
# Build paket deploy SERASI ke folder dist/
# - Menyalin hanya file yang dipakai website (tanpa docx sumber, scratch, dll.)
# - Mengecilkan & mengonversi ilustrasi PNG (≈2,5 MB) menjadi JPEG (≈150 KB)
# - Mengecilkan foto kuliner & banner
# - Menyalin hanya audio yang dirujuk di script.js
# Jalankan: bash build.sh   (macOS, memakai `sips` bawaan)
set -eu
cd "$(dirname "$0")"

OUT="dist"
MAX_PX=1200      # sisi terpanjang gambar
JPG_QUALITY=82

rm -rf "$OUT"
mkdir -p "$OUT"

echo "▶ Menyalin file inti..."
cp index.html style.css script.js "$OUT/"
cp "Logo Tut Wuri Handayani.jpg" "Logo SD Negeri 1 Pare Mondokan Sragen.jpeg" "Logo Kabupaten Sragen.jpg" "$OUT/"
cp "MISI JURNALIS CILIK.docx" "$OUT/"

echo "▶ Mengoptimalkan banner..."
sips -Z "$MAX_PX" -s format jpeg -s formatOptions "$JPG_QUALITY" serasi_hero_banner.jpg --out "$OUT/serasi_hero_banner.jpg" >/dev/null
sips -Z "$MAX_PX" -s format jpeg -s formatOptions "$JPG_QUALITY" beranda-bg.jpg --out "$OUT/beranda-bg.jpg" >/dev/null

echo "▶ Mengonversi ilustrasi PNG -> JPEG..."
for dir in 1 2 3 4 5 6 7 8 9 Sangiran; do
  mkdir -p "$OUT/$dir"
  for f in "$dir"/*.png; do
    base="$(basename "${f%.png}")"
    sips -Z "$MAX_PX" -s format jpeg -s formatOptions "$JPG_QUALITY" "$f" --out "$OUT/$dir/$base.jpg" >/dev/null
  done
done

echo "▶ Mengoptimalkan foto kuliner..."
for dir in "Makanan Khas Sragen" "Minuman Khas Sragen"; do
  mkdir -p "$OUT/$dir"
  for f in "$dir"/*.jpg; do
    sips -Z "$MAX_PX" -s format jpeg -s formatOptions "$JPG_QUALITY" "$f" --out "$OUT/$f" >/dev/null
  done
done

echo "▶ Menyalin audio yang dipakai..."
mkdir -p "$OUT/Audio"
grep -o 'Audio/[^"]*\.m4a' script.js | sort -u | while read -r a; do
  cp "$a" "$OUT/$a"
done

echo "▶ Menyesuaikan referensi .png -> .jpg di dist..."
# Hanya untuk folder ilustrasi (1-9 dan Sangiran)
python3 - "$OUT" <<'EOF'
import re, sys, os
out = sys.argv[1]
pat = re.compile(r'((?:[1-9]|Sangiran)/[A-Za-z0-9_-]+)\.png')
for name in ("index.html", "script.js"):
    p = os.path.join(out, name)
    s = open(p, encoding="utf-8").read()
    s2, n = pat.subn(r'\1.jpg', s)
    open(p, "w", encoding="utf-8").write(s2)
    print(f"   {name}: {n} referensi diubah")
EOF

# File pendukung hosting statis
# Netlify
cat > "$OUT/_headers" <<'EOF'
/*
  Cache-Control: public, max-age=3600
/Audio/*
  Cache-Control: public, max-age=31536000, immutable
EOF
# Vercel (situs statis murni, tanpa build)
cat > "$OUT/vercel.json" <<'EOF'
{
  "framework": null,
  "buildCommand": null,
  "outputDirectory": ".",
  "cleanUrls": true,
  "headers": [
    { "source": "/Audio/(.*)", "headers": [ { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" } ] },
    { "source": "/(.*)\\.(jpg|jpeg|png)", "headers": [ { "key": "Cache-Control", "value": "public, max-age=604800" } ] }
  ]
}
EOF
# GitHub Pages
touch "$OUT/.nojekyll"

echo "▶ Memverifikasi semua referensi di dist..."
python3 - "$OUT" <<'EOF'
import re, sys, os
out = sys.argv[1]
html = open(os.path.join(out, "index.html"), encoding="utf-8").read()
js = open(os.path.join(out, "script.js"), encoding="utf-8").read()
refs = set(re.findall(r'src="([^"#h][^"]*)"', html))
refs |= set(re.findall(r'href="([^"#h][^"]+\.css[^"]*)"', html))
refs |= set(re.findall(r'"([^"]+\.(?:jpg|jpeg|png|m4a|docx))"', js))
refs.add("MISI JURNALIS CILIK.docx")
refs = {r.split("?")[0].split("#")[0] for r in refs}
missing = [r for r in sorted(refs) if not os.path.isfile(os.path.join(out, r))]
if missing:
    print("   ✗ HILANG:", missing); sys.exit(1)
print(f"   ✓ {len(refs)} referensi valid")
EOF

echo "▶ Selesai. Ukuran paket deploy: $(du -sh "$OUT" | cut -f1)"
