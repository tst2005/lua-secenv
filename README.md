
# Lua SecEnv

The minimal API to expose in a safe environment.
The challenge was to define (and implement) every dependencies inside the new isolated environement.


# 1. Minimal level

A mininal set of functions `assert`, `error`, `require`, `getmetatable`, `setmetatable` and `load` seems mandatory to make a separated environment execution.
Some others functions like `pcall`, `xpcall` should be added to the minimal set.

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

## require()

This require function is rebuilt inside the new environment.
Some implementation should allow to exchange require request from isolated env to uplevel env.

# 2. Basic level

Some others usefull common functions are grouped in the 2nd set.

Some usefull function like `pairs`, `ipairs` and `next` should be rewritten in lua.

## ipairs()

Direct access seems ok.

## pairs()

## next()


# Standard Modules


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

# Extention

## import

See lua-import-experiment

## require

The new implementation of require and package management should provide new features
Summary of new possible feature :
 * automatically setup the _NAME _PATH _PPATH in the module object
 * use the lua5.3 API with package.searchers
 * import/export stuff ?
 * improved parser/lexer to allow some funny stuff

