#!/bin/bash

. ./osc_project_sep.sh

UPDATE=
NODE_VERSIONS=

while getopts uh name
do
	case $name in
		u)
			UPDATE="yes"
			;;
		*)
			printf "Usage: %s [-u] [[NODE_VERSION] ...]\n" $0
			echo ""
			printf "   $s -u nodejs10 nodejs12\n" $0
			exit 2
			;;
	esac
done

for i in ${@:$OPTIND}; do
	if ! [ ${i:0:6} = "nodejs" ] || ! [ ${i:6} -ge 4 ]; then
		echo "Invalid NodeJS version: $i";
		exit 3;
	fi

	NODE_VERSIONS="$NODE_VERSIONS $i"
done

if [ "x$NODE_VERSIONS" = "x" ]; then
	NODE_VERSIONS=$(ls -d nodejs? nodejs??)
fi

for i in $NODE_VERSIONS; do
	ver=${i:6}
	if [ $ver -lt 18 ]; then
		echo "Skipping old versions $ver.x"
		continue
	fi
	echo "Checking version for Node $ver.x"

	URL="https://nodejs.org/dist/latest-v$ver.x/"
	upstream_ver=
	while [ "x$upstream_ver" = "x" ]; do
		upstream_ver=$(curl -Ss $URL | grep 'node-v[.0-9]\+'tar.xz | sed -e 's/^.*node-v\([0-9]\+\.[0-9]\+\.[0-9]\+\).tar.xz.*$/\1/') || exit 1
	done

	local_ver=$(grep {{node_version}} nodejs$ver.sed | sed -e 's,s/{{node_version}}/,,' | sed -e 's,/g,,')

	if [ "x$local_ver" != "x$upstream_ver" ]; then
		echo -e "New version $upstream_ver\t\t(local: $local_ver)"

		if [ ! -z "$UPDATE" ]; then
			echo "   updating hash values";
			wget -q -O nodejs$ver/SHASUMS256.txt     $URL/SHASUMS256.txt
			wget -q -O nodejs$ver/SHASUMS256.txt.sig $URL/SHASUMS256.txt.sig
			sed -i -e "s,^s/{{node_version}}.*/g$,s/{{node_version}}/$upstream_ver/g," nodejs$ver.sed

			# DL upstream package too, if directory exists
			if [ -d devel${PS}languages${PS}nodejs/nodejs$ver ]; then
				pushd devel${PS}languages${PS}nodejs/nodejs$ver > /dev/null
				wget -q --show-progress $URL/node-v$upstream_ver.tar.xz
				osc rm node-v$local_ver.tar.xz
				osc add node-v$upstream_ver.tar.xz
				[ -d node-v$local_ver ] && rm -r node-v$local_ver
				popd > /dev/null
			fi

			# Update bundled versions
			./bundling.sh $ver
		fi
	fi
done
