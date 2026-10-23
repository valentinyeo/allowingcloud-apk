#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
SITE=${SITE:-../allowingcloud}
SDK=${ANDROID_HOME:-$HOME/Android/Sdk}
BT=$SDK/build-tools/35.0.0
JAR=$SDK/platforms/android-35/android.jar
B=build
rm -rf $B && mkdir -p $B/assets/www/vendor $B/classes $B/res

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

$BT/aapt2 compile --dir res -o $B/res.zip
$BT/aapt2 link -o $B/unsigned.apk -I "$JAR" --manifest AndroidManifest.xml -A $B/assets $B/res.zip
javac -Xlint:-options -source 11 -target 11 -classpath "$JAR" -d $B/classes $(find src -name '*.java')
$BT/d8 --min-api 24 --lib "$JAR" --output $B $(find $B/classes -name '*.class')
(cd $B && zip -q unsigned.apk classes.dex)

$BT/zipalign -f 4 $B/unsigned.apk allowing-unsigned.apk
echo "built $(pwd)/allowing-unsigned.apk, sign it with ./sign.sh"
