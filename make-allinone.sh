#!/bin/sh

# see https://github.com/tst2005/luamodules-all-in-one-file/
# wget https://raw.githubusercontent.com/tst2005/luamodules-all-in-one-file/newtry/pack-them-all.lua
ALLINONE=./luamodules-all-in-one-file/pack-them-all.lua 

#--icheckinit
#--icheck
#--autoaliases
"$ALLINONE" \
	--mod compat_env	lib/compat_env.lua \
	--mod restricted	lib/restricted.lua \
	--code			lib/apilayer.lua \
> apilayer.lua

#(
#	cd ./ && "$ALLINONE" --icheckinit $(
#	find -depth -name '*.lua' -printf '%P\n' | while read -r line; do echo "--mod $(echo "$line" | sed 's,\.lua$,,g' | tr / .) $line"; done
#	) --icheck --autoaliases --code main.lua
#)

# How to use it ?
# Just run :
#   ./make-allinone.sh > apilayer.lua
