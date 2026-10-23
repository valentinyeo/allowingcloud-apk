#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
IN=${1:-allowing-unsigned.apk}
OUT=${2:-allowing.apk}
ITEM="AllowingCloud APK Signing"
SDK=${ANDROID_HOME:-$HOME/Android/Sdk}
KS=$(mktemp -d)
trap 'rm -rf "$KS"' EXIT
chmod 700 "$KS"
yeo-key "$ITEM" KEYSTORE_BASE64 | base64 -d > "$KS/key.jks"
KS_PASS="$(yeo-key "$ITEM" KEYSTORE_PASSWORD)" "$SDK/build-tools/35.0.0/apksigner" sign \
  --ks "$KS/key.jks" --ks-pass env:KS_PASS --ks-key-alias allowing --out "$OUT" "$IN"
echo "signed $(pwd)/$OUT"
