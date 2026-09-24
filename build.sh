#!/usr/bin/env bash
# Builds allowing.apk: bundles the allowing.cloud site (../allowingcloud) for offline use.
set -euo pipefail
cd "$(dirname "$0")"
SITE=${SITE:-../allowingcloud}
SDK=${ANDROID_HOME:-$HOME/Android/Sdk}
BT=$SDK/build-tools/35.0.0
JAR=$SDK/platforms/android-35/android.jar
KEYSTORE=${KEYSTORE:-$HOME/.android-keys/allowingcloud.jks}
B=build
rm -rf $B && mkdir -p $B/assets/www/vendor $B/classes $B/res

# 1. Site files, with CDN scripts swapped for bundled copies and the service worker removed.
cp "$SITE"/*.html "$SITE"/theme.css "$SITE"/theme.js $B/assets/www/
cp -r "$SITE"/icons $B/assets/www/
cp vendor/*.js $B/assets/www/vendor/
sed -i \
  -e 's|https://unpkg.com/react@18/umd/react.production.min.js|vendor/react.production.min.js|' \
  -e 's|https://unpkg.com/react-dom@18/umd/react-dom.production.min.js|vendor/react-dom.production.min.js|' \
  -e 's|https://unpkg.com/@babel/standalone/babel.min.js|vendor/babel.min.js|' \
  -e 's|https://cdn.tailwindcss.com|vendor/tailwind.js|' \
  -e 's| crossorigin>|>|' \
  -e '/navigator.serviceWorker.register/d' \
  -e '/rel="manifest"/d' \
  $B/assets/www/*.html
if grep -nE 'src="https?://' $B/assets/www/*.html; then echo "external script left, aborting" >&2; exit 1; fi

# 2. Compile resources, Java, dex.
$BT/aapt2 compile --dir res -o $B/res.zip
$BT/aapt2 link -o $B/unsigned.apk -I "$JAR" --manifest AndroidManifest.xml -A $B/assets $B/res.zip
javac -Xlint:-options -source 11 -target 11 -classpath "$JAR" -d $B/classes $(find src -name '*.java')
$BT/d8 --min-api 24 --lib "$JAR" --output $B $(find $B/classes -name '*.class')
(cd $B && zip -q unsigned.apk classes.dex)

# 3. Align and sign with a stable key kept outside the repo (same key = updates keep working).
# The password sits next to the key in $KEYSTORE.pass, never in the repo.
if [ ! -f "$KEYSTORE" ]; then
  mkdir -p "$(dirname "$KEYSTORE")"
  (umask 077; openssl rand -hex 16 > "$KEYSTORE.pass")
  keytool -genkeypair -keystore "$KEYSTORE" -alias allowing -keyalg RSA -keysize 2048 -validity 36500 \
    -storepass:file "$KEYSTORE.pass" -keypass:file "$KEYSTORE.pass" -dname "CN=allowing.cloud" >/dev/null
fi
$BT/zipalign -f 4 $B/unsigned.apk $B/aligned.apk
$BT/apksigner sign --ks "$KEYSTORE" --ks-pass file:"$KEYSTORE.pass" --out allowing.apk $B/aligned.apk
echo "built $(pwd)/allowing.apk ($(du -h allowing.apk | cut -f1))"
