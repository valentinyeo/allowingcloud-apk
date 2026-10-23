# allowing.cloud APK

Offline Android wrapper for https://allowing.cloud. The site's HTML files and the
React, Babel and Tailwind scripts are bundled inside the APK, so it works with no network.

GitHub builds it: the APK workflow fetches the site files from https://allowing.cloud,
runs `./build.sh` and uploads `allowing-unsigned.apk` as the `allowing-unsigned` artifact.
`./build.sh` needs the Android SDK with `platforms;android-35` and `build-tools;35.0.0`,
JDK 11+, and the site files at `../allowingcloud` (or `SITE=<folder>`).

Sign it with `./sign.sh [in.apk] [out.apk]` (default `allowing-unsigned.apk` to `allowing.apk`).
It reads the signing key from the 1Password item "AllowingCloud APK Signing" (vault
Yeo UX Agents) with `yeo-key` and keeps it in a private temp folder only while signing.
Keep that key: an APK signed with a different key can't update an installed one.

After changing the site, bump `versionCode` in `AndroidManifest.xml`, let the workflow
build, sign the artifact, and install the new APK over the old one.
