# allowing.cloud APK

Offline Android wrapper for https://allowing.cloud. The site's HTML files and the
React, Babel and Tailwind scripts are bundled inside the APK, so it works with no network.

Build (needs the Android SDK in `~/Android/Sdk` with `platforms;android-35` and
`build-tools;35.0.0`, JDK 11+, and the site repo checked out at `../allowingcloud`):

    ./build.sh   # -> allowing.apk

The signing key lives outside the repo at `~/.android-keys/allowingcloud.jks`.
Keep it: an APK signed with a different key can't update an installed one.

After changing the site, rerun `./build.sh`, bump `versionCode` in
`AndroidManifest.xml`, and install the new APK over the old one.
