#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEBS_DIR="$REPO_ROOT/debs"
PACKAGES_FILE="$REPO_ROOT/Packages"
PACKAGES_GZ_FILE="$REPO_ROOT/Packages.gz"
RELEASE_FILE="$REPO_ROOT/Release"

if [ ! -d "$DEBS_DIR" ]; then
  echo "Missing debs directory: $DEBS_DIR" >&2
  exit 1
fi

DEB_FILES=()
while IFS= read -r deb_path; do
  DEB_FILES+=("$deb_path")
done < <(find "$DEBS_DIR" -maxdepth 1 -type f -name "*.deb" | sort)

if [ "${#DEB_FILES[@]}" -eq 0 ]; then
  echo "No .deb files found in: $DEBS_DIR" >&2
  exit 1
fi

TMP_PACKAGES="$(mktemp)"
trap 'rm -f "$TMP_PACKAGES"' EXIT

extract_control() {
  local deb_path="$1"
  local control_member
  control_member="$(ar t "$deb_path" | awk '/^control\.tar\./ {print $0; exit}')"
  if [ -z "$control_member" ]; then
    echo "Missing control archive in $deb_path" >&2
    return 1
  fi

  case "$control_member" in
    control.tar.xz)
      ar p "$deb_path" "$control_member" | tar -xJOf - ./control
      ;;
    control.tar.gz)
      ar p "$deb_path" "$control_member" | tar -xzOf - ./control
      ;;
    control.tar.bz2)
      ar p "$deb_path" "$control_member" | tar -xjOf - ./control
      ;;
    *)
      echo "Unsupported control compression ($control_member) in $deb_path" >&2
      return 1
      ;;
  esac
}

ARCH_TMP="$(mktemp)"
trap 'rm -f "$TMP_PACKAGES" "$ARCH_TMP"' EXIT

for deb in "${DEB_FILES[@]}"; do
  rel_path="${deb#$REPO_ROOT/}"
  control_text="$(extract_control "$deb")"

  arch="$(printf '%s\n' "$control_text" | awk -F': ' '$1=="Architecture"{print $2; exit}')"
  if [ -n "$arch" ]; then
    printf '%s\n' "$arch" >> "$ARCH_TMP"
  fi

  size="$(stat -f%z "$deb")"
  md5sum="$(md5 -q "$deb")"
  sha1sum="$(shasum -a 1 "$deb" | awk '{print $1}')"
  sha256sum="$(shasum -a 256 "$deb" | awk '{print $1}')"

  {
    printf '%s\n' "$control_text"
    printf 'Filename: %s\n' "$rel_path"
    printf 'Size: %s\n' "$size"
    printf 'MD5sum: %s\n' "$md5sum"
    printf 'SHA1: %s\n' "$sha1sum"
    printf 'SHA256: %s\n\n' "$sha256sum"
  } >> "$TMP_PACKAGES"
done

mv "$TMP_PACKAGES" "$PACKAGES_FILE"

gzip -n -9 -c "$PACKAGES_FILE" > "$PACKAGES_GZ_FILE"

ARCH_LIST="$(sort -u "$ARCH_TMP" | tr '\n' ' ' | sed 's/ $//')"
[ -n "$ARCH_LIST" ] || ARCH_LIST="iphoneos-arm64"

ORIGIN="${ORIGIN:-Yz4u}"
LABEL="${LABEL:-Yz4u Tweaks}"
SUITE="${SUITE:-stable}"
CODENAME="${CODENAME:-ios}"
COMPONENTS="${COMPONENTS:-main}"
DESCRIPTION="${DESCRIPTION:-Yz4u JB Comfort Project repository}"
NOW_UTC="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S +0000')"

pkg_size="$(stat -f%z "$PACKAGES_FILE")"
pkg_gz_size="$(stat -f%z "$PACKAGES_GZ_FILE")"
pkg_md5="$(md5 -q "$PACKAGES_FILE")"
pkg_gz_md5="$(md5 -q "$PACKAGES_GZ_FILE")"
pkg_sha1="$(shasum -a 1 "$PACKAGES_FILE" | awk '{print $1}')"
pkg_gz_sha1="$(shasum -a 1 "$PACKAGES_GZ_FILE" | awk '{print $1}')"
pkg_sha256="$(shasum -a 256 "$PACKAGES_FILE" | awk '{print $1}')"
pkg_gz_sha256="$(shasum -a 256 "$PACKAGES_GZ_FILE" | awk '{print $1}')"

cat > "$RELEASE_FILE" <<EOF
Origin: $ORIGIN
Label: $LABEL
Suite: $SUITE
Version: 1.0
Codename: $CODENAME
Date: $NOW_UTC
Architectures: $ARCH_LIST
Components: $COMPONENTS
Description: $DESCRIPTION
MD5Sum:
 $pkg_md5 $pkg_size Packages
 $pkg_gz_md5 $pkg_gz_size Packages.gz
SHA1:
 $pkg_sha1 $pkg_size Packages
 $pkg_gz_sha1 $pkg_gz_size Packages.gz
SHA256:
 $pkg_sha256 $pkg_size Packages
 $pkg_gz_sha256 $pkg_gz_size Packages.gz
EOF

echo "Generated:"
echo "  $PACKAGES_FILE"
echo "  $PACKAGES_GZ_FILE"
echo "  $RELEASE_FILE"
