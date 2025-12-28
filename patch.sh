#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
BASEDIR=$(dirname "$0")
src_dir="HandBrake"
help="Usage: patch.sh [src_dir=\"HandBrake\"] [options]

The src_dir is the directory that contains the HandBrake source code (defaults to \"HandBrake\)
-c --clone -> option that clone the repo to src_dir
-h --help  -> print usage message

If no directory is found, the program exits"

[[ "$#" -gt 2 ]] && { echo "$help"; exit 1; }
for (( i=1; i <= "$#"; i++ )); do
  case ${!i} in
	-h | --help) echo "$help"; exit 1 ;;
	-c | --clone)
		[[ "$i" -lt "$#" ]] && { echo "$help"; exit 1; }
		rm -rf HandBrake; git clone --depth 1 https://github.com/HandBrake/HandBrake.git ;;
	-*) echo "${!i} option doesn't exists!"; echo "$help"; exit 1 ;;
	*) src_dir="$1" ;;
	esac
done
[[ ! -d "$src_dir" ]] && { echo "$src_dir directory doesn't exists!"; echo "$help"; exit 1; }
for filename in ${BASEDIR}/patches/*.patch; do
  patch -t -N -p1 -d "$src_dir" < "$filename"  || exit 1
done
# The flatpak build refers to the latest commit, so we add a commit that includes the patches
cd "$src_dir"
git add .
git -c user.name='deadbeef' -c user.email='deadbeef' commit -m "Patch"
