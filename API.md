

# _V

_G is the global env (usualy the native one)
_ENV is the local env (but only in lua >= 5.2)

_V is my custom name for the virtual env.
The way to detect if we are in a safe env or not.

```
local ok, _V = pcall(require, "_V")
```


# requireany()

```
local bit, name = requireany('bit', 'bit32', 'bit.numberlua')
```
