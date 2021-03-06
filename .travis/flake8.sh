#!/bin/sh

set -x

# Run pep8 on all .py files in all subfolders
# We must ignore E402 module level import not at top of file
# because of use case sys.path.append('..'); import <module>

tmpafter=$(mktemp)
find gui src -name \*.py -exec flake8 --ignore=E402,E501 {} + | egrep -v "migrations/|usr/local/share/pysnmp/mibs/" > $tmpafter
num_errors_after=`cat $tmpafter | wc -l`
echo $num_errors_after

git checkout HEAD~

tmpbefore=$(mktemp)
find gui src -name \*.py -exec flake8 --ignore=E402,E501 {} + | egrep -v "migrations/|usr/local/share/pysnmp/mibs/" > $tmpbefore
num_errors_before=`cat $tmpbefore | wc -l`
echo $num_errors_before


if [ $num_errors_after -gt $num_errors_before ]; then
	echo "New Flake8 errors were introduced:"
	diff -u $tmpbefore $tmpafter
	exit 1
fi

