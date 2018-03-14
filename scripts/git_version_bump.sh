#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 {PATCH|MINOR|MAJOR}"
  exit 1
fi

update_type="$1"
root_dir="$(git rev-parse --show-toplevel)"
plist="$root_dir/PowerScout/Info.plist"
latest_tag="$(git describe --tags --abbrev=0)"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

majornum=`echo "$latest_tag" | awk -F "." '{print $1}'`
minornum=`echo "$latest_tag" | awk -F "." '{print $2}'`
patchnum=`echo "$latest_tag" | awk -F "." '{print $3}'`
new_majornum="$majornum"
new_minornum="$minornum"
new_patchnum="$patchnum"

if [[ "$current_branch" != "master" ]]; then
	echo "Current Branch: $current_branch"
	echo "You must be on the master branch to run this script!"
	echo "To switch branches, type \`git checkout master\`"
	exit 3
fi

case "$update_type" in
  MAJOR)
    new_patchnum=0
    new_minornum=0
    new_majornum=$(($majornum + 1))
    ;;
  MINOR)
    new_patchnum=0
    new_minornum=$(($minornum + 1))
    ;;
  PATCH)
    new_patchnum=$(($patchnum + 1))
    ;;
  *)
    echo "Invalid Update Type given! Valie types: PATCH, MINOR, MAJOR"
    exit 2
esac

echo "Tagging: $majornum.$minornum.$patchnum ~> $new_majornum.$new_minornum.$new_patchnum..."

source "$root_dir"/scripts/xcode_version_bump.sh "$plist" "$update_type"
$(git add .)
$(git commit -q --author="Version Bump Bot <>" -m "$update_type Version Bump ~> $new_majornum.$new_minornum.$new_patchnum")
$(git tag "$new_majornum"."$new_minornum"."$new_patchnum")

echo "Tag Done!"

