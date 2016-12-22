#!/bin/bash

pushd /usr/local/src/zimbra

apt-get update --quiet

echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

printf 'y\nn\nn\nn\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\n' | ./install.sh --skip-upgrade-check -x

if [ $? != 0 ]; then
    exit 1
fi

cat /tmp/install.log*

popd
