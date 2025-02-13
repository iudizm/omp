#!/bin/bash

#
# buildpkg.sh
#
# Copyright (c) 2014-2021 Simon Fraser University
# Copyright (c) 2003-2021 John Willinsky
# Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
#
# Script to create an OMP package for distribution.
#
# Usage: buildpkg.sh <version> [<tag>]
#
#

GITREP=git://github.com/pkp/omp.git

if [ -z "$1" ]; then
	echo "Usage: $0 <version> [<tag>-<branch>]";
	exit 1;
fi

VERSION=$1
TAG=$2
PREFIX=omp
BUILD=$PREFIX-$VERSION
TMPDIR=`mktemp -d $PREFIX.XXXXXX` || exit 1

EXCLUDE="docs/dev									\
tests											\
cypress											\
tools/buildpkg.sh									\
lib/pkp/cypress										\
tools/test										\
lib/pkp/tools/travis									\
lib/pkp/plugins/*/*/tests								\
docs/dev										\
docs/doxygen										\
lib/pkp/tools/travis									\
lib/pkp/lib/vendor/smarty/smarty/demo							\
plugins/generic/customBlockManager/.git							\
plugins/generic/staticPages/.git							\
plugins/paymethod/paypal/vendor/omnipay/common/tests/					\
plugins/paymethod/paypal/vendor/omnipay/paypal/tests/					\
plugins/paymethod/paypal/vendor/guzzle/guzzle/docs/					\
plugins/paymethod/paypal/vendor/guzzle/guzzle/tests/					\
plugins/paymethod/paypal/vendor/symfony/http-foundation/Tests/				\
plugins/paymethod/paypal/vendor/clue/stream-filter/tests/				\
lib/pkp/plugins/*/*/tests								\
lib/pkp/tests										\
.git											\
.openshift										\
.travis.yml										\
lib/pkp/.git										\
lib/pkp/captainhook.json								\
lib/pkp/lib/vendor/ezyang/htmlpurifier/art						\
lib/pkp/lib/vendor/ezyang/htmlpurifier/benchmarks					\
lib/pkp/lib/vendor/ezyang/htmlpurifier/configdog					\
lib/pkp/lib/vendor/ezyang/htmlpurifier/docs						\
lib/pkp/lib/vendor/ezyang/htmlpurifier/extras						\
lib/pkp/lib/vendor/ezyang/htmlpurifier/maintenance					\
lib/pkp/lib/vendor/ezyang/htmlpurifier/smoketests					\
lib/pkp/lib/vendor/ezyang/htmlpurifier/tests						\
lib/pkp/lib/vendor/leafo/lessphp/tests							\
lib/pkp/lib/vendor/leafo/lessphp/docs							\
lib/pkp/lib/vendor/moxiecode/plupload/examples						\
lib/pkp/lib/vendor/phpmailer/phpmailer/docs						\
lib/pkp/lib/vendor/phpmailer/phpmailer/examples						\
lib/pkp/lib/vendor/phpmailer/phpmailer/test						\
lib/pkp/lib/vendor/robloach								\
lib/pkp/lib/vendor/smarty/smarty/demo							\
lib/pkp/lib/vendor/pimple/pimple/ext/pimple/tests					\
lib/pkp/lib/vendor/adodb/adodb-php/.git							\
lib/pkp/lib/vendor/phpunit								\
lib/pkp/lib/vendor/phpdocumentor/reflection-docblock					\
lib/pkp/lib/vendor/doctrine/instantiator/tests						\
lib/pkp/lib/vendor/sebastian/global-state/tests						\
lib/pkp/lib/vendor/sebastian/comparator/tests						\
lib/pkp/lib/vendor/sebastian/diff/tests							\
lib/pkp/lib/vendor/oyejorge/less.php/test						\
lib/pkp/lib/vendor/dragonmantank/cron-expression/tests/					\
lib/pkp/lib/vendor/cweagans/composer-patches/tests					\
lib/pkp/lib/vendor/moxiecode/plupload/examples/						\
lib/pkp/lib/vendor/swiftmailer/swiftmailer/tests/					\
lib/pkp/js/lib/pnotify/build-tools							\
lib/pkp/lib/vendor/alex198710/pnotify/.git						\
node_modules										\
.editorconfig										\
babel.config.js										\
package-lock.json										\
package.json										\
vue.config.js									\
lib/ui-library"

cd $TMPDIR

echo -n "Cloning $GITREP and checking out tag $TAG ... "
git clone -b $TAG --depth 1 -q -n $GITREP $BUILD || exit 1
cd $BUILD
git checkout -q $TAG || exit 1
echo "Done"

echo -n "Checking out corresponding submodules ... "
git submodule -q update --init --recursive >/dev/null || exit 1
echo "Done"

echo "Installing composer dependencies ... "
echo -n " - lib/pkp ... "
composer.phar --working-dir=lib/pkp install --no-dev

echo -n " - plugins/paymethod/paypal ... "
composer.phar --working-dir=plugins/paymethod/paypal install --no-dev
echo "Done"

echo -n "Installing node dependencies... "
npm install
echo "Done"

echo -n "Running webpack build process... "
npm run build
echo "Done"

echo -n "Preparing package ... "
cp config.TEMPLATE.inc.php config.inc.php
find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm '{}' \;
rm -rf $EXCLUDE
echo "Done"

cd ..

echo -n "Creating archive $BUILD.tar.gz ... "
tar -zhcf ../$BUILD.tar.gz $BUILD
echo "Done"

cd ..

rm -r $TMPDIR
