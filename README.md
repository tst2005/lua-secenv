
# Lua SecEnv

The minimal API to expose in a safe environment.

## load( <string>luacode, _, _, <table>env )

To run some `luacode` inside a specific `env`.
But with a mandatory `env` table (do not use the native _G in `env` ommited ).

## assert(....)

Direct access seems ok

## error(...., level)

Seems mandatory to provide, but probably unsafe if level is not controled...

## require() and package system

Done. Made in Lua from scratch.

## getmetatable()

Direct access seems ok, except for the string metatable.

## setmetatable()

Direct access seems ok.

## ipairs()

Direct access seems ok.

# Known escape issue

## string metatable
```lua
getmetable("")["foo"] = "bar"
```


