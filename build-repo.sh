#!/bin/bash
# =============================================================================
#  Build the NexH4ck APT repository — STANDARD dists layout (termuxvoid-style).
#  Usage: bash build-repo.sh
#
#  Layout served on GitHub Pages at https://daemon-018.github.io/nexh4ck-repo/
#    debs/<pkg>_<ver>_all.deb
#    dists/nexh4ck/Release, InRelease, Release.gpg
#    dists/nexh4ck/main/binary-all/Packages, Packages.gz
#    nexh4ck-repo.gpg   (public signing key users add)
#
#  Apt source users add:
#    deb [arch=all] https://daemon-018.github.io/nexh4ck-repo nexh4ck main
# =============================================================================
set -euo pipefail

BASE="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$BASE/nexh4ck-repo"
KEY="A4EE30A42DF09410"
SUITE="nexh4ck"
COMPONENT="main"
BINARY="binary-all"

rm -rf "$REPO_DIR/debs" "$REPO_DIR/dists"
mkdir -p "$REPO_DIR/debs"
mkdir -p "$REPO_DIR/dists/$SUITE/$COMPONENT/$BINARY"

# copy the .deb
for d in nexh4ck_*.deb; do [ -f "$d" ] && cp "$d" "$REPO_DIR/debs/"; done
find "$REPO_DIR/debs" -name '*.deb' -exec chmod 644 {} +

# ---------------- Packages index ------------------------------------------
{
  for deb in "$REPO_DIR"/debs/*.deb; do
    echo "Package: nexh4ck"
    echo "Version: $(dpkg-deb -f "$deb" Version)"
    echo "Architecture: $(dpkg-deb -f "$deb" Architecture)"
    echo "Maintainer: $(dpkg-deb -f "$deb" Maintainer)"
    echo "Installed-Size: $(dpkg-deb -f "$deb" Installed-Size)"
    echo "Depends: $(dpkg-deb -f "$deb" Depends)"
    echo "Section: $(dpkg-deb -f "$deb" Section)"
    echo "Priority: $(dpkg-deb -f "$deb" Priority)"
    echo "Homepage: $(dpkg-deb -f "$deb" Homepage)"
    echo "Description: $(dpkg-deb -f "$deb" Description | head -1)"
    echo "Filename: debs/$(basename "$deb")"
    echo "Size: $(stat -c%s "$deb")"
    echo "MD5sum: $(md5sum "$deb" | cut -d' ' -f1)"
    echo "SHA1: $(sha1sum "$deb" | cut -d' ' -f1)"
    echo "SHA256: $(sha256sum "$deb" | cut -d' ' -f1)"
    echo ""
  done
} > "$REPO_DIR/dists/$SUITE/$COMPONENT/$BINARY/Packages"
gzip -9c "$REPO_DIR/dists/$SUITE/$COMPONENT/$BINARY/Packages" \
  > "$REPO_DIR/dists/$SUITE/$COMPONENT/$BINARY/Packages.gz"
echo "Packages index built: $(grep -c '^Package:' "$REPO_DIR/dists/$SUITE/$COMPONENT/$BINARY/Packages") pkg"

# ---------------- Release + signing ----------------------------------------
P="$COMPONENT/$BINARY/Packages"
PG="$COMPONENT/$BINARY/Packages.gz"
{
  echo "Origin: NexH4ck APT Repository"
  echo "Label: NexH4ck"
  echo "Suite: $SUITE"
  echo "Codename: $SUITE"
  echo "Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")"
  echo "Architectures: all"
  echo "Components: $COMPONENT"
  echo "Description: Authorized Termux security lab terminal (Daemon-018)"
  echo "MD5Sum:"
  printf ' %s %s %s\n' "$(md5sum "$REPO_DIR/dists/$SUITE/$P" | cut -d' ' -f1)" "$(stat -c%s "$REPO_DIR/dists/$SUITE/$P")" "$P"
  printf ' %s %s %s\n' "$(md5sum "$REPO_DIR/dists/$SUITE/$PG" | cut -d' ' -f1)" "$(stat -c%s "$REPO_DIR/dists/$SUITE/$PG")" "$PG"
  echo "SHA1:"
  printf ' %s %s %s\n' "$(sha1sum "$REPO_DIR/dists/$SUITE/$P" | cut -d' ' -f1)" "$(stat -c%s "$REPO_DIR/dists/$SUITE/$P")" "$P"
  printf ' %s %s %s\n' "$(sha1sum "$REPO_DIR/dists/$SUITE/$PG" | cut -d' ' -f1)" "$(stat -c%s "$REPO_DIR/dists/$SUITE/$PG")" "$PG"
  echo "SHA256:"
  printf ' %s %s %s\n' "$(sha256sum "$REPO_DIR/dists/$SUITE/$P" | cut -d' ' -f1)" "$(stat -c%s "$REPO_DIR/dists/$SUITE/$P")" "$P"
  printf ' %s %s %s\n' "$(sha256sum "$REPO_DIR/dists/$SUITE/$PG" | cut -d' ' -f1)" "$(stat -c%s "$REPO_DIR/dists/$SUITE/$PG")" "$PG"
} > "$REPO_DIR/dists/$SUITE/Release"

cd "$REPO_DIR/dists/$SUITE"
gpg --batch --yes --armor --detach-sign --default-key "$KEY" -o Release.gpg Release
gpg --batch --yes --clearsign --default-key "$KEY" -o InRelease Release
cd "$BASE"

# export public key
gpg --batch --export "$KEY" > "$REPO_DIR/nexh4ck-repo.gpg"

echo ""
echo "Signed Release + InRelease. Repo ready at $REPO_DIR"
echo "  Public key: nexh4ck-repo.gpg"
echo "  Apt source: deb [arch=all] https://daemon-018.github.io/nexh4ck-repo nexh4ck main"
