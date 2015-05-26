
# Lua SecEnv

The minimal API to expose in a safe environment.

# 1. Minimal level

# The functions

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
I checked if a table is locked (with __metatable), setmetatable refuse to change it.

# 2. Basic level

## ipairs()

Direct access seems ok.

## pairs()


## table functions

* Direct access seems ok.
* Metatable should be locked.

## string functions

* Direct access seems ok.
* Metatable should be locked.
* Metatable should be uncatchable.

## utf8 functions

* Direct access seems ok.
* Alternative: lua implementation ?

# 3. Full level

## os functions (partially)

## io functions (partially)

## math functions

* Direct access seems ok.
* Excepted for random stuff ?.


## coroutine functions



# Known escape issue

## string metatable
```lua
getmetable("")["foo"] = "bar"
```


