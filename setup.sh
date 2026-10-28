#!/usr/bin/env bash
# Usage: ./setup.sh com.yourname      (your unique reverse-domain prefix)
# The final Android app id becomes  <prefix>.vibestream  and CANNOT be changed after publishing.
set -euo pipefail

ORG="${1:-}"
if [[ -z "$ORG" || "$ORG" == "com.example" ]]; then
  echo "Give a unique prefix, e.g.  ./setup.sh com.mohsin"; exit 1
fi

flutter create . --platforms=android,ios,web --org "$ORG" --project-name vibestream
flutter pub get

# Firebase needs minSdk 23
for f in android/app/build.gradle android/app/build.gradle.kts; do
  [[ -f "$f" ]] && sed -i -E 's/minSdk(Version)? *=? *flutter\.minSdkVersion/minSdk = 23/' "$f"
done

# Make sure release builds can use the internet
M=android/app/src/main/AndroidManifest.xml
grep -q 'android.permission.INTERNET' "$M" || \
  sed -i '0,/<application/s//<uses-permission android:name="android.permission.INTERNET"\/>\n    <application/' "$M"

# App name shown on the phone
sed -i -E 's/android:label="[^"]*"/android:label="VibeStream"/' "$M"

echo
echo "Done. Next: dart pub global activate flutterfire_cli && flutterfire configure"
echo "Then: flutter run"
