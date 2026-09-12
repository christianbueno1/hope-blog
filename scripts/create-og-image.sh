#!/usr/bin/env bash
#
# create-og-image.sh
#
# Genera una imagen Open Graph (.webp, 1200x630) a partir de una imagen
# fuente (jpg, png, etc.), detectando automáticamente para qué post del
# blog es (comparando src/content/posts/ contra public/og/).
#
# Uso:
#   ./create-og-image.sh <ruta-imagen> [slug]
#
# Ejemplos:
#   ./create-og-image.sh ~/Downloads/ng-filter-signals.jpg
#   ./create-og-image.sh ~/Downloads/ng-filter-signals.jpg how-to-build-a-generic-reactive-filter-in-angular-22-using-signals
#
# Requisitos (Fedora):
#   sudo dnf install ImageMagick
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuración — ajusta PROJECT_ROOT si corres el script desde otro lado
# ---------------------------------------------------------------------------
PROJECT_ROOT="${PROJECT_ROOT:-$HOME/projects/hope-blog}"
POSTS_DIR="$PROJECT_ROOT/src/content/posts"
OG_DIR="$PROJECT_ROOT/public/og"
OG_WIDTH=1200
OG_HEIGHT=630
OG_QUALITY=82

usage() {
	cat <<EOF
Uso: $(basename "$0") <ruta-imagen> [slug]

  <ruta-imagen>   Imagen fuente (jpg, jpeg, png, etc.)
  [slug]          Nombre del post (carpeta en src/content/posts/).
                  Si se omite, el script detecta automáticamente
                  cuál post no tiene imagen OG y la usa. Si hay
                  varios candidatos, te deja elegir.

Ejemplos:
  $(basename "$0") ~/Downloads/ng-filter-signals.jpg
  $(basename "$0") ~/Downloads/ng-filter-signals.jpg how-to-build-a-generic-reactive-filter-in-angular-22-using-signals
EOF
	exit 1
}

[[ $# -lt 1 ]] && usage

IMAGE_PATH="$1"
SLUG_ARG="${2:-}"

# ---------------------------------------------------------------------------
# Validaciones
# ---------------------------------------------------------------------------
if [[ ! -f "$IMAGE_PATH" ]]; then
	echo "❌ No existe el archivo: $IMAGE_PATH" >&2
	exit 1
fi

if [[ ! -d "$POSTS_DIR" ]]; then
	echo "❌ No existe el directorio de posts: $POSTS_DIR" >&2
	echo "   (ajusta PROJECT_ROOT si tu proyecto está en otra ruta)" >&2
	exit 1
fi

# Preferir 'magick' (ImageMagick 7), caer a 'convert' (IM6) si no existe
if command -v magick >/dev/null 2>&1; then
	CONVERT_BIN="magick"
elif command -v convert >/dev/null 2>&1; then
	CONVERT_BIN="convert"
else
	echo "❌ ImageMagick no está instalado." >&2
	echo "   Instálalo con: sudo dnf install ImageMagick" >&2
	exit 1
fi

# Verificar soporte de WebP en ImageMagick
if ! "$CONVERT_BIN" -list format 2>/dev/null | grep -qi '^\s*WEBP'; then
	echo "❌ Tu instalación de ImageMagick no tiene soporte para WebP." >&2
	echo "   Prueba: sudo dnf reinstall ImageMagick libwebp" >&2
	exit 1
fi

mkdir -p "$OG_DIR"

# ---------------------------------------------------------------------------
# Detectar slugs de posts y cuáles no tienen imagen OG
# ---------------------------------------------------------------------------
mapfile -t ALL_SLUGS < <(find "$POSTS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [[ ${#ALL_SLUGS[@]} -eq 0 ]]; then
	echo "❌ No se encontraron posts en $POSTS_DIR" >&2
	exit 1
fi

MISSING_SLUGS=()
for slug in "${ALL_SLUGS[@]}"; do
	if [[ ! -f "$OG_DIR/$slug.webp" ]]; then
		MISSING_SLUGS+=("$slug")
	fi
done

# ---------------------------------------------------------------------------
# Resolver a qué slug corresponde la imagen
# ---------------------------------------------------------------------------
TARGET_SLUG=""

if [[ -n "$SLUG_ARG" ]]; then
	TARGET_SLUG="$SLUG_ARG"
	if [[ ! -d "$POSTS_DIR/$TARGET_SLUG" ]]; then
		echo "⚠️  Advertencia: '$TARGET_SLUG' no existe como carpeta en $POSTS_DIR (¿typo?)" >&2
	fi
elif [[ ${#MISSING_SLUGS[@]} -eq 0 ]]; then
	echo "✅ Todos los posts ya tienen imagen OG en $OG_DIR"
	exit 0
elif [[ ${#MISSING_SLUGS[@]} -eq 1 ]]; then
	TARGET_SLUG="${MISSING_SLUGS[0]}"
	echo "🔎 Post sin imagen OG detectado automáticamente:"
	echo "   $TARGET_SLUG"
else
	echo "🔎 Hay ${#MISSING_SLUGS[@]} posts sin imagen OG. Elige uno:"
	select slug in "${MISSING_SLUGS[@]}"; do
		if [[ -n "${slug:-}" ]]; then
			TARGET_SLUG="$slug"
			break
		fi
		echo "Opción inválida, intenta de nuevo."
	done
fi

OUTPUT_PATH="$OG_DIR/$TARGET_SLUG.webp"

if [[ -f "$OUTPUT_PATH" && -z "$SLUG_ARG" ]]; then
	read -rp "⚠️  $OUTPUT_PATH ya existe. ¿Sobrescribir? [y/N] " confirm
	[[ "$confirm" =~ ^[yY]$ ]] || { echo "Cancelado."; exit 0; }
fi

# ---------------------------------------------------------------------------
# Conversión: resize "cover" (llena 1200x630 recortando el sobrante) + webp
# ---------------------------------------------------------------------------
echo "🖼️  Generando: $OUTPUT_PATH"
echo "    Fuente:   $IMAGE_PATH"

"$CONVERT_BIN" "$IMAGE_PATH" \
	-resize "${OG_WIDTH}x${OG_HEIGHT}^" \
	-gravity center \
	-extent "${OG_WIDTH}x${OG_HEIGHT}" \
	-quality "$OG_QUALITY" \
	"$OUTPUT_PATH"

SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
echo "✅ Listo: $OUTPUT_PATH ($SIZE)"
