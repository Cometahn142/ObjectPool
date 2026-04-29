--!strict

export type PoolOptions<T> = {
	factory: () -> T,
	reset: (T) -> (),
	destroy: ((T) -> ())?,
	maxSize: number?,
}

export type ObjectPool<T> = {
	Get: (self: ObjectPool<T>) -> T,
	Return: (self: ObjectPool<T>, object: T) -> (),
	Prewarm: (self: ObjectPool<T>, amount: number) -> (),
	Clear: (self: ObjectPool<T>) -> (),
	Destroy: (self: ObjectPool<T>) -> (),
	GetActiveCount: (self: ObjectPool<T>) -> number,
	GetInactiveCount: (self: ObjectPool<T>) -> number,
}

type PrivateObjectPool<T> = ObjectPool<T> & {
	_factory: () -> T,
	_reset: (T) -> (),
	_destroy: ((T) -> ())?,
	_maxSize: number,
	_pool: { T },
	_active: { [T]: boolean },
	_destroyed: boolean,
}

local ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new<T>(options: PoolOptions<T>): ObjectPool<T>
	assert(type(options.factory) == "function", "options.factory must be a function")
	assert(type(options.reset) == "function", "options.reset must be a function")

	if options.destroy ~= nil then
		assert(type(options.destroy) == "function", "options.destroy must be a function")
	end

	if options.maxSize ~= nil then
		assert(type(options.maxSize) == "number" and options.maxSize > 0, "options.maxSize must be a positive number")
	end

	local self = setmetatable({}, ObjectPool) :: any

	self._factory = options.factory
	self._reset = options.reset
	self._destroy = options.destroy
	self._maxSize = options.maxSize or math.huge
	self._pool = {}
	self._active = {}
	self._destroyed = false

	return (self :: any) :: ObjectPool<T>
end

function ObjectPool:Get<T>(): T
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	assert(not poolSelf._destroyed, "Attempted to use a destroyed ObjectPool")

	local object: T
	if #poolSelf._pool > 0 then
		object = table.remove(poolSelf._pool) :: T
	else
		object = poolSelf._factory()
	end

	poolSelf._active[object] = true
	return object
end

function ObjectPool:Return<T>(object: T)
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	assert(not poolSelf._destroyed, "Attempted to use a destroyed ObjectPool")

	if not poolSelf._active[object] then
		return
	end

	poolSelf._active[object] = nil
	poolSelf._reset(object)

	if #poolSelf._pool < poolSelf._maxSize then
		table.insert(poolSelf._pool, object)
	else
		if poolSelf._destroy then
			poolSelf._destroy(object)
		end
	end
end

function ObjectPool:Prewarm<T>(amount: number)
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	assert(not poolSelf._destroyed, "Attempted to use a destroyed ObjectPool")
	assert(amount > 0, "Prewarm amount must be greater than 0")

	local currentSize = #poolSelf._pool
	local needed = math.min(amount, poolSelf._maxSize - currentSize)

	for _ = 1, needed do
		local object = poolSelf._factory()
		table.insert(poolSelf._pool, object)
	end
end

function ObjectPool:Clear<T>()
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	assert(not poolSelf._destroyed, "Attempted to use a destroyed ObjectPool")

	if poolSelf._destroy then
		for _, object in poolSelf._pool do
			poolSelf._destroy(object)
		end
	end

	table.clear(poolSelf._pool)
end

function ObjectPool:Destroy<T>()
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	if poolSelf._destroyed then
		return
	end

	poolSelf:Clear()
	poolSelf._destroyed = true

	table.clear(poolSelf._active)
end

function ObjectPool:GetActiveCount<T>(): number
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	local count = 0
	for _ in poolSelf._active do
		count += 1
	end
	return count
end

function ObjectPool:GetInactiveCount<T>(): number
	local poolSelf = (self :: any) :: PrivateObjectPool<T>
	return #poolSelf._pool
end

return ObjectPool
