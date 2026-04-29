# 사용 패턴 (Usage Patterns)

## 파트(Part) 풀링을 통한 GC 최적화

```luau
local ObjectPool = require(Packages.ObjectPool)

local pool = ObjectPool.new({
    factory = function() 
        local p = Instance.new("Part")
        p.Anchored = true
        return p
    end,
    reset = function(part) 
        part.Parent = nil -- 부모 관계 해제
    end
})

-- 객체 획득 및 사용
local part = pool:Get()
part.Position = Vector3.new(0, 10, 0)
part.Parent = workspace

task.wait(2)

-- 사용 완료 후 반환
pool:Return(part)
```
