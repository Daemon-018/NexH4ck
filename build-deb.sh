#!/bin/bash
# =============================================================================
#  Build the NexH4ck .deb package (Termux). termuxvoid-style layout.
#  Usage: bash build-deb.sh
#  Produces: nexh4ck_<ver>_all.deb
# =============================================================================
set -euo pipefail

VER="0.1.1"
PACKAGE="nexh4ck"
ARCH="all"
MAINTAINER="Hari (Daemon-018) <daemon018@users.noreply.github.com>"

# sources
SRC_NEXH4CK="$(cd "$(dirname "$0")" && pwd)"
TOOL="$SRC_NEXH4CK/nexh4ck"

[ -f "$TOOL" ] || { echo "nexh4ck tool not found"; exit 1; }

# build dir
PKGTREE="$SRC_NEXH4CK/.build/pkg"
rm -rf "$SRC_NEXH4CK/.build"
mkdir -p "$PKGTREE/DEBIAN"
mkdir -p "$PKGTREE/data/data/com.termux/files/usr/bin"

# --- control file ---
cat > "$PKGTREE/DEBIAN/control" <<EOF
Package: $PACKAGE
Version: $VER
Architecture: $ARCH
Maintainer: $MAINTAINER
Installed-Size: 40
Depends: bash, curl
Section: security
Priority: optional
Homepage: https://github.com/Daemon-018/NexH4ck
Description: Authorized Termux security lab terminal (i-Haklab-style menu + termuxvoid/apt lite-install model).
 A curated, ROE-first tool catalog grouped by category (recon, scan, web,
 password, wireless) that lite-installs security tools from termux-main,
 pip and git on demand. Never overrides core shell commands; ships no
 phishing/ransomware payloads. Author: @daemon-018.
EOF

# --- postinst: install mtimes + nothing else needed (binary already placed) ---
cat > "$PKGTREE/DEBIAN/postinst" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# NexH4ck post-install: ensure executable
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
chmod +x "$PREFIX/bin/nexh4ck" 2>/dev/null
echo "  NexH4ck installed — run: nexh4ck help"
exit 0
EOF

cat > "$PKGTREE/DEBIAN/postrm" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# NexH4ck post-remove: nothing persistent to clean (config in ~/.nexh4ck kept)
exit 0
EOF

chmod 0755 "$PKGTREE/DEBIAN/postinst" "$PKGTREE/DEBIAN/postrm"
chmod 0755 "$PKGTREE" "$PKGTREE/DEBIAN"

# --- place the tool ---
install -m 0755 "$TOOL" "$PKGTREE/data/data/com.termux/files/usr/bin/nexh4ck"

# --- build ---
cd "$SRC_NEXH4CK"
# deb requires fixed file order; use dpkg-deb if present else ar fallback
if command -v dpkg-deb >/dev/null 2>&1; then
  dpkg-deb --build --root-owner-group "$PKGTREE" "nexh4ck_${VER}_all.deb"
else
  echo "dpkg-deb not found — using manual ar/tar build"
  # tar the control and data separately (deterministic)
  (cd "$PKGTREE" && tar --owner=0 --group=0 -czf "$SRC_NEXH4CK/.build/control.tar.gz" DEBIAN)
  (cd "$PKGTREE/data" && tar --owner=0 --group=0 -czf "$SRC_NEXH4CK/.build/data.tar.gz" data)
  cd "$SRC_NEXH4CK/.build"
  printf '2.0\n' > debian-binary
  ar -r "$SRC_NEXH4CK/nexh4ck_${VER}_all.deb" debian-binary control.tar.gz data.tar.gz
fi

rm -rf "$SRC_NEXH4CK/.build"
echo ""
echo "  Built: $SRC_NEXH4CK/nexh4ck_${VER}_all.deb"
ls -la "$SRC_NEXH4CK/nexh4ck_${VER}_all.deb"
