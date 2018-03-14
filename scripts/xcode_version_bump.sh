#!/bin/bash

if [ $# -ne 2 ]; then
  echo "usage: $0 <plist-file> {PATCH|MINOR|MAJOR}"
  exit 1
fi

plist="$1"
update_type="$2"
current_dir="$(dirname "$plist")"

buildnum=$(/usr/libexec/Plistbuddy -c "Print CFBundleVersion" "$plist")
if [ -z "$buildnum" ]; then
  echo "No build number found! Could not perform version bump"
  exit 2
fi
versionnum=$(/usr/libexec/Plistbuddy -c "Print CFBundleShortVersionString" "$plist")
if [ -z "$versionnum" ]; then
  echo "No version string found! Could not perform version bump"
  exit 3
fi
majornum=`echo "$versionnum" | awk -F "." '{print $1}'`
minornum=`echo "$versionnum" | awk -F "." '{print $2}'`
new_buildnum="$buildnum"
new_majornum="$majornum"
new_minornum="$minornum"

case "$update_type" in
  MAJOR)
    new_buildnum=0
    new_minornum=0
    new_majornum=$(($majornum + 1))
    ;;
  MINOR)
    new_buildnum=0
    new_minornum=$(($minornum + 1))
    ;;
  PATCH)
    new_buildnum=$(($buildnum + 1))
    ;;
  *)
    echo "Invalid Update Type given! Valid types: PATCH, MINOR, MAJOR"
    exit 4
    ;;
esac

echo "Performing Xcode Bump: $majornum.$minornum.$buildnum ~> $new_majornum.$new_minornum.$new_buildnum..."

/usr/libexec/Plistbuddy -c "Set CFBundleVersion $new_buildnum" "$plist"
/usr/libexec/Plistbuddy -c "Set CFBundleShortVersionString $new_majornum.$new_minornum" "$plist"

echo "Version Bump Done!"

