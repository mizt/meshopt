cd "$(dirname "$0")"
cd ./

set -eu

PLUGIN="meshopt"
echo ${PLUGIN}

mkdir -p ${PLUGIN}.plugin/Contents/MacOS
clang++ -std=c++20 -Wc++20-extensions -bundle -fobjc-arc -O3 -I ./ -I../libs/meshopt -framework Cocoa ../libs/meshopt/*.cpp ./meshopt.mm -o ./${PLUGIN}.plugin/Contents/MacOS/${PLUGIN}
cp ./Info.plist ./${PLUGIN}.plugin/Contents/

# codesign --force --options runtime --deep --entitlements "../CPU/entitlements.plist" --sign "Developer ID Application" --timestamp --verbose ${PLUGIN}.plugin

echo "** BUILD SUCCEEDED **"
