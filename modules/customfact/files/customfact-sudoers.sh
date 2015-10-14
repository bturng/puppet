#!/bin/sh

if [ -f /etc/sudoers ];then
echo "sudoers="`cat /etc/sudoers /etc/sudoers.d/* 2>/dev/null | grep -v "^#" | grep -vi Defaults | sed -e '/^$/d' -e 's/=/%3D/g' | tr \$'\n' ';'`
else
echo "sudoers=nothere"
fi
