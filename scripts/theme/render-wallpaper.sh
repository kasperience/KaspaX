#!/usr/bin/env bash
set -euo pipefail

# Generate a dark wallpaper with a centered kdapp logo using ImageMagick.
# Adds a subtle teal tint overlay by default for KaspaX vibe.
# Optional daily quote overlay (center-bottom) from a quotes file.
#
# Usage: render-wallpaper.sh [WIDTHxHEIGHT]
# Example: render-wallpaper.sh 1920x1080
#
# Env toggles:
#   KASPAX_TINT=0               # disable tint overlay (default: 1)
#   KASPAX_TINT_COLOR=#00e5b0   # tint color (default teal)
#   KASPAX_TINT_ALPHA=8         # tint strength percent (0-100, default: 8)
#
# Quote overlay (optional):
#   KASPAX_QUOTE=1              # force-enable quote overlay (default: auto if file exists)
#   KASPAX_QUOTES_FILE=/path/quotes.txt  # one quote per line
#   KASPAX_QUOTE_COLOR=#9ad9c8  # text color (default muted teal)
#   KASPAX_QUOTE_SIZE=28        # point size
#   KASPAX_QUOTE_MARGIN=64      # bottom margin in px from screen bottom
#   KASPAX_QUOTE_FONT=DejaVu-Sans   # font family name (optional)

RES="${1:-1920x1080}"
W=${RES%x*}
H=${RES#*x}

if ! [[ "$W" =~ ^[0-9]+$ && "$H" =~ ^[0-9]+$ ]]; then
  echo "Invalid resolution: $RES (expected e.g. 1920x1080)" >&2
  exit 1
fi

# Locate logo (from kaspa-auth assets)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOGO="$ROOT_DIR/applications/kdapps/kaspa-auth/public/assets/kdapp_framework.jpg"
if [ ! -f "$LOGO" ]; then
  echo "Logo not found: $LOGO" >&2
  exit 1
fi

# Output location
OUT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/kaspax/wallpapers"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/kaspax-${W}x${H}.png"

# Pick ImageMagick executable
IM="magick"
if ! command -v "$IM" >/dev/null 2>&1; then
  IM="convert"
fi
if ! command -v "$IM" >/dev/null 2>&1; then
  echo "ImageMagick not found. Install 'imagemagick' (pacman -S imagemagick)." >&2
  exit 1
fi

# Colors (match palette)
BG="#0F1115"
TINT_ENABLE="${KASPAX_TINT:-1}"
TINT_COLOR="${KASPAX_TINT_COLOR:-#00e5b0}"
TINT_ALPHA="${KASPAX_TINT_ALPHA:-8}"

# Optional background image
BG_IMAGE="${KASPAX_BG_IMAGE:-}"
BG_MODE="${KASPAX_BG_MODE:-cover}"   # cover|contain|stretch

# Temp workspace
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t kaspax-wall)"
trap 'rm -rf "$TMP_DIR"' EXIT || true

# Logo shape options
LOGO_SHAPE="${KASPAX_LOGO_SHAPE:-circle}"   # circle|square
LOGO_SCALE="${KASPAX_LOGO_SCALE:-0.18}"     # fraction of screen width (e.g., 0.18)
LOGO_FEATHER="${KASPAX_LOGO_FEATHER:-0}"     # soften edge in px (anti-alias mask)
RING_ENABLE="${KASPAX_LOGO_RING:-1}"        # 1 to draw ring around logo
RING_COLOR="${KASPAX_RING_COLOR:-#00e5b0}"
RING_WIDTH="${KASPAX_RING_WIDTH:-6}"

# Matrix code overlay (optional, behind logo/glass)
MATRIX_ENABLE="${KASPAX_MATRIX:-0}"
MATRIX_COLOR="${KASPAX_MATRIX_COLOR:-#00ff88}"
MATRIX_ALPHA="${KASPAX_MATRIX_ALPHA:-12}"        # overall opacity percent (0-100)
MATRIX_POINT="${KASPAX_MATRIX_POINT:-16}"        # character point size
MATRIX_TILE="${KASPAX_MATRIX_TILE:-320x320}"     # tile size for pattern
MATRIX_DENSITY="${KASPAX_MATRIX_DENSITY:-45}"    # percentage of grid cells to draw
MATRIX_BLUR="${KASPAX_MATRIX_BLUR:-0}"           # slight blur to soften (e.g., 0.5..1)
MATRIX_FONT="${KASPAX_MATRIX_FONT:-}"            # optional font family (e.g., 'DejaVu Sans Mono')
MATRIX_CHARS="${KASPAX_MATRIX_CHARS:-01|/\\*+}"  # character set (ASCII recommended)
MATRIX_JITTER="${KASPAX_MATRIX_JITTER:-2}"        # random px offset to break grid

# Milk-glass panel options (for readable content)
GLASS_ENABLE="${KASPAX_GLASS:-0}"
GLASS_WIDTH_FRAC="${KASPAX_GLASS_WIDTH:-0.8}"  # 0.6..0.9 of width
GLASS_HEIGHT="${KASPAX_GLASS_HEIGHT:-180}"     # px
GLASS_MARGIN="${KASPAX_GLASS_MARGIN:-80}"      # bottom margin px
GLASS_RADIUS="${KASPAX_GLASS_RADIUS:-24}"      # corner radius px
GLASS_BLUR="${KASPAX_GLASS_BLUR:-10}"          # Gaussian sigma
GLASS_ALPHA="${KASPAX_GLASS_ALPHA:-35}"        # white overlay percent (0-100)

# Quote overlay defaults
QUOTES_FILE_DEFAULT="$ROOT_DIR/themes/kaspax/quotes.txt"
QUOTES_FILE="${KASPAX_QUOTES_FILE:-$QUOTES_FILE_DEFAULT}"
QUOTE_COLOR="${KASPAX_QUOTE_COLOR:-#9ad9c8}"
QUOTE_SIZE="${KASPAX_QUOTE_SIZE:-28}"
QUOTE_MARGIN="${KASPAX_QUOTE_MARGIN:-64}"
QUOTE_FONT="${KASPAX_QUOTE_FONT:-}"
QUOTE_AUTO=0
if [ -f "$QUOTES_FILE" ]; then QUOTE_AUTO=1; fi
QUOTE_ENABLE="${KASPAX_QUOTE:-$QUOTE_AUTO}"

# Compute logo width as ~20% of screen width
LOGO_W=$(( W / 5 ))

# 1) Build base background: optional image fitted to canvas, then optional teal tint overlay
if [ -n "$BG_IMAGE" ] && [ -f "$BG_IMAGE" ]; then
  case "$BG_MODE" in
    cover)
      "$IM" "$BG_IMAGE" -resize ${W}x${H}^ -gravity center -extent ${W}x${H} "$OUT"
      ;;
    contain)
      "$IM" "$BG_IMAGE" -resize ${W}x${H} -gravity center -background "$BG" -extent ${W}x${H} "$OUT"
      ;;
    stretch)
      "$IM" "$BG_IMAGE" -resize ${W}x${H}! "$OUT"
      ;;
    *)
      "$IM" "$BG_IMAGE" -resize ${W}x${H}^ -gravity center -extent ${W}x${H} "$OUT"
      ;;
  esac
else
  "$IM" -size ${W}x${H} xc:"$BG" "$OUT"
fi

# Optional teal tint overlay on base
if [ "$TINT_ENABLE" != "0" ]; then
  "$IM" "$OUT" -fill "$TINT_COLOR" -colorize ${TINT_ALPHA}% "$OUT"
fi

# 1.5) Optional: Matrix code overlay (tiled pattern) before logo
if [ "$MATRIX_ENABLE" = "1" ]; then
  # Parse tile size
  MTW=${MATRIX_TILE%x*}
  MTH=${MATRIX_TILE#*x}
  if ! [[ "$MTW" =~ ^[0-9]+$ && "$MTH" =~ ^[0-9]+$ ]]; then
    MTW=320; MTH=320
  fi

  DRAW_MVG="$TMP_DIR/matrix_draw.mvg"
  TILE_IMG="$TMP_DIR/matrix_tile.png"

  # Estimate grid spacing from point size
  DX=$(awk -v p="$MATRIX_POINT" 'BEGIN{printf "%d", (p*0.6)}')
  if [ "$DX" -lt 8 ]; then DX=8; fi
  DY="$MATRIX_POINT"
  if [ "$DY" -lt 10 ]; then DY=10; fi

  {
    echo "push graphic-context"
    echo "fill $MATRIX_COLOR"
    echo "stroke none"
    echo "font-size $MATRIX_POINT"
    if [ -n "$MATRIX_FONT" ]; then
      FONTSPEC=$(printf "%s" "$MATRIX_FONT" | sed "s/'/\\\\'/g")
      echo "font-family '$FONTSPEC'"
    fi
    # Draw random 0/1 on a grid
    X=0
    echo "# grid $MTW x $MTH, step ${DX}x${DY}"
    while [ "$X" -lt "$MTW" ]; do
      Y=0
      while [ "$Y" -lt "$MTH" ]; do
        R=$(( RANDOM % 100 ))
        if [ "$R" -lt "$MATRIX_DENSITY" ]; then
          # pick a char from MATRIX_CHARS
          CHLEN=${#MATRIX_CHARS}
          if [ "$CHLEN" -eq 0 ]; then CH="0"; else
            CI=$(( RANDOM % CHLEN ))
            CH=${MATRIX_CHARS:$CI:1}
          fi
          # escape backslash for MVG single-quoted content
          case "$CH" in \\) ESC_CH="\\\\" ;; *) ESC_CH="$CH" ;; esac
          # jitter to break perfect grid
          JX=$(( RANDOM % (2*MATRIX_JITTER+1) - MATRIX_JITTER ))
          JY=$(( RANDOM % (2*MATRIX_JITTER+1) - MATRIX_JITTER ))
          PX=$(( X + JX ))
          PY=$(( Y + JY + DY ))
          echo "text $PX,$PY '$ESC_CH'"
        fi
        Y=$(( Y + DY ))
      done
      X=$(( X + DX ))
    done
    echo "pop graphic-context"
  } > "$DRAW_MVG"

  "$IM" -size ${MTW}x${MTH} xc:none -draw "@$DRAW_MVG" "$TILE_IMG"

  MATRIX_TILED="$TMP_DIR/matrix_tiled.png"
  "$IM" -size ${W}x${H} tile:"$TILE_IMG" "$MATRIX_TILED"
  if [ "$MATRIX_BLUR" != "0" ]; then
    "$IM" "$MATRIX_TILED" -blur 0x"$MATRIX_BLUR" "$MATRIX_TILED"
  fi
  # Apply global opacity and composite onto OUT
  MATRIX_ALPHA_IMG="$TMP_DIR/matrix_alpha.png"
  "$IM" "$MATRIX_TILED" -alpha on -channel A -evaluate set ${MATRIX_ALPHA}% +channel "$MATRIX_ALPHA_IMG"
  "$IM" "$OUT" "$MATRIX_ALPHA_IMG" -compose over -composite "$OUT"
fi

# 2) Save a copy of the pre-logo background for glass blur source
BASE_BG="$TMP_DIR/base_bg.png"
cp -f "$OUT" "$BASE_BG"

# 3) Optional: milk-glass panel (blurred background + white translucent overlay)
if [ "$GLASS_ENABLE" = "1" ]; then
  # Panel geometry
  PW=$(awk -v W="$W" -v F="$GLASS_WIDTH_FRAC" 'BEGIN{ if(F+0==0){F=0.8}; printf "%d", W*F }')
  PH="$GLASS_HEIGHT"
  OX=$(( (W - PW) / 2 ))
  OY=$(( H - GLASS_MARGIN - PH ))

  # Make a blurred copy of the pre-logo background so the logo stays crisp
  BLUR_IMG="$TMP_DIR/blur.png"
  "$IM" "$BASE_BG" -filter Gaussian -blur 0x"$GLASS_BLUR" "$BLUR_IMG"

  # Crop the blurred area where the panel will be placed
  BLUR_CROP="$TMP_DIR/blur_crop.png"
  "$IM" "$BLUR_IMG" -crop ${PW}x${PH}+${OX}+${OY} +repage "$BLUR_CROP"

  # Rounded mask for the panel
  MASK_PANEL="$TMP_DIR/glass_mask.png"
  X1=$(( PW - 1 )); Y1=$(( PH - 1 ))
  "$IM" -size ${PW}x${PH} xc:none -fill white -draw "roundrectangle 0,0 ${X1},${Y1} ${GLASS_RADIUS},${GLASS_RADIUS}" "$MASK_PANEL"

  # Apply mask to blurred crop
  PANEL_READY="$TMP_DIR/panel_ready.png"
  "$IM" "$BLUR_CROP" "$MASK_PANEL" -alpha off -compose CopyOpacity -composite "$PANEL_READY"

  # Composite blurred rounded panel onto output
  "$IM" "$OUT" "$PANEL_READY" -gravity northwest -geometry +${OX}+${OY} -compose over -composite "$OUT"

  # White translucent overlay to mimic milk glass
  PANEL_WHITE="$TMP_DIR/panel_white.png"
  "$IM" -size ${PW}x${PH} xc:none -fill white -draw "roundrectangle 0,0 ${X1},${Y1} ${GLASS_RADIUS},${GLASS_RADIUS}" \
    -alpha on -channel A -evaluate set ${GLASS_ALPHA}% +channel "$PANEL_WHITE"
  "$IM" "$OUT" "$PANEL_WHITE" -gravity northwest -geometry +${OX}+${OY} -compose over -composite "$OUT"
fi

# 4) Prepare logo (square resize), then optional circular mask and ring; composite AFTER glass
# Compute logo size from scale (fallback to 20% if parsing fails)
LOGO_SIZE=$(awk -v W="$W" -v S="$LOGO_SCALE" 'BEGIN{ if(S+0==0){S=0.20}; printf "%d", W*S }')
LOGO_RES="$TMP_DIR/logo_resized.png"
"$IM" "$LOGO" -resize ${LOGO_SIZE}x${LOGO_SIZE}^ -gravity center -extent ${LOGO_SIZE}x${LOGO_SIZE} "$LOGO_RES"

LOGO_FINAL="$LOGO_RES"
if [ "$LOGO_SHAPE" = "circle" ]; then
  MASK="$TMP_DIR/logo_mask.png"
  R=$(( LOGO_SIZE / 2 ))
  "$IM" -size ${LOGO_SIZE}x${LOGO_SIZE} xc:none -fill white -draw "circle ${R},${R} ${R},0" "$MASK"
  if [ "$LOGO_FEATHER" != "0" ]; then
    "$IM" "$MASK" -filter Gaussian -blur 0x"$LOGO_FEATHER" "$MASK"
  fi
  LOGO_FINAL="$TMP_DIR/logo_circle.png"
  "$IM" "$LOGO_RES" "$MASK" -compose CopyOpacity -composite "$LOGO_FINAL"
fi

# Composite logo to center (after glass so it's not blurred)
"$IM" "$OUT" "$LOGO_FINAL" -gravity center -composite "$OUT"

# Optional ring overlay
if [ "$LOGO_SHAPE" = "circle" ] && [ "$RING_ENABLE" = "1" ]; then
  R=$(( LOGO_SIZE / 2 ))
  RING_IMG="$TMP_DIR/logo_ring.png"
  # draw ring slightly inset so it fully fits within the logo circle
  HALF_STROKE=$(( RING_WIDTH / 2 ))
  INNER=$(( R - HALF_STROKE - 1 ))
  if [ "$INNER" -lt 1 ]; then INNER=1; fi
  INNERX=$(( R + INNER ))
  "$IM" -size ${LOGO_SIZE}x${LOGO_SIZE} xc:none -stroke "$RING_COLOR" -strokewidth "$RING_WIDTH" -fill none \
    -draw "circle ${R},${R} ${INNERX},${R}" "$RING_IMG"
  "$IM" "$OUT" "$RING_IMG" -gravity center -composite "$OUT"
fi

# Optional: overlay a random quote centered at bottom
if [ "$QUOTE_ENABLE" = "1" ] && [ -f "$QUOTES_FILE" ]; then
  QUOTE_LINE="$(grep -vE '^\s*(#|$)' "$QUOTES_FILE" | shuf -n1 | sed 's/\r$//' || true)"
  if [ -n "$QUOTE_LINE" ]; then
    CAP_W=$(( W * 8 / 10 ))
    QUOTE_IMG="$TMP_DIR/quote.png"
    if [ -n "$QUOTE_FONT" ]; then
      "$IM" -background none -fill "$QUOTE_COLOR" -gravity center -size ${CAP_W}x \
        -font "$QUOTE_FONT" -pointsize "$QUOTE_SIZE" caption:"$QUOTE_LINE" "$QUOTE_IMG"
    else
      "$IM" -background none -fill "$QUOTE_COLOR" -gravity center -size ${CAP_W}x \
        -pointsize "$QUOTE_SIZE" caption:"$QUOTE_LINE" "$QUOTE_IMG"
    fi
    # Composite quote onto the final image with bottom margin
    "$IM" "$OUT" "$QUOTE_IMG" -gravity south -geometry +0+${QUOTE_MARGIN} -composite "$OUT"
  fi
fi

echo "Wallpaper written: $OUT"
