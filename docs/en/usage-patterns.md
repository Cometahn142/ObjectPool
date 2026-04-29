# Usage Patterns

## Part Pooling

```luau
local ObjectPool = require(Packages.ObjectPool)

local pool = ObjectPool.new({
    factory = function() return Instance.new("Part") end,
    reset = function(part) part.Parent = nil end
})

local part = pool:Get()
part.Parent = workspace
task.wait(1)
pool:Return(part)
```
