#/bin/sh

USAGE="Usage: $0 [major|minor|patch] <project-dir> <opam-dir>\n\
Example: $0 minor ../AbSolute ../solvers-opam\n\

'project-dir' must be the root of an OPAM project (do not use '.', we need the name).\n\
'opam-dir' must be the root of an OPAM repository.\n\n\

Assumptions:\n\
  1. The OPAM file is named in lower case with the project directory name (e.g. 'absolute.opam').\n\
  2. The OPAM file contains a 'src' field containing the substring 'AbSolute/zipball/v0.3.0' (this is how we retrieve the current version number).\n"

UPDATE_KIND=$1
PROJECT_DIR=$2
OPAM_DIR=$3

# Sanity checks

if [[ $UPDATE_KIND != "major" && $UPDATE_KIND != "minor" && $UPDATE_KIND != "patch" ]]; then
  printf "Error: Use either major, minor or patch to indicate the kind of update.\n$USAGE"
  exit 1
fi

if [ ! -d $PROJECT_DIR ]; then
  printf "Error: The project directory '$PROJECT_DIR' does not exist.\n$USAGE"
  exit 1
fi

if [ ! -d $OPAM_DIR ]; then
  printf "Error: The OPAM directory '$OPAM_DIR' does not exist.\n$USAGE"
  exit 1
fi

GIT_NAME=$(basename $PROJECT_DIR)
OPAM_NAME=$(echo $GIT_NAME | tr '[:upper:]' '[:lower:]')
OPAM_FILE=$PROJECT_DIR/$OPAM_NAME.opam

if [ ! -f $OPAM_FILE ]; then
  printf "Missing OPAM file '$OPAM_FILE' in the project directory.\n$USAGE"
  exit 1
fi

semver=$(sed -n "s,.*$GIT_NAME/zipball/v\([0-9]\+.[0-9]\+.[0-9]\+\).*,\1,p" $OPAM_FILE)
if [ $semver == "" ]; then
  printf "The semantic version in $OPAM_FILE is not correct, we expect a three-number version such as `1.2.3`.\n\
        $USAGE"
  exit 1
fi
major=$(echo $semver | sed -n "s,\([0-9]\+\).[0-9]\+.[0-9]\+,\1,p")
minor=$(echo $semver | sed -n "s,[0-9]\+.\([0-9]\+\).[0-9]\+,\1,p")
patch=$(echo $semver | sed -n "s,[0-9]\+.[0-9]\+.\([0-9]\+\),\1,p")

if [ "$UPDATE_KIND" == "major" ]; then
  major=$(($major+1))
elif [ "$UPDATE_KIND" == "minor" ]; then
  minor=$(($minor+1))
elif [ "$UPDATE_KIND" == "patch" ]; then
  patch=$(($patch+1))
fi

VERSION=$major.$minor.$patch
VERSION_TAG=v$VERSION

set -x

# Replace the version number of the project in its OPAM file.
sed -i "s,$GIT_NAME/zipball/v[0-9]\+.[0-9]\+.[0-9]\+,$GIT_NAME/zipball/$VERSION_TAG,g" $OPAM_FILE &&

# Create and copy the OPAM file into the OPAM_DIR.
PACKAGE_DIR=packages/$OPAM_NAME/$OPAM_NAME.$VERSION
VERSION_DIR=$OPAM_DIR/$PACKAGE_DIR
mkdir -p $VERSION_DIR &&
cp $OPAM_FILE $VERSION_DIR/opam &&

# Create the version tag in the project, and push the changes on github.
cd $PROJECT_DIR &&
git commit -a -m "[release] Update the version number to $VERSION in the OPAM file." &&
git tag -a $VERSION_TAG -m "[release] Update to version $VERSION." &&
git push origin $VERSION_TAG &&
cd - &&

# Commit and push the new version in OPAM_DIR
cd $OPAM_DIR &&
git add $PACKAGE_DIR/opam &&
git commit -a -m "[package][$GIT_NAME] Upgrade to version $VERSION_TAG of $GIT_NAME." &&
git push &&
cd - &&

printf "Update successful."