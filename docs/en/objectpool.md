# ObjectPool API

## `ObjectPool.new(options)`
Creates a pool.
- `options.factory`: Function returning a new object.
- `options.reset`: Function resetting the object.

## `Pool:Get()`
Gets an object from the pool.

## `Pool:Return(object)`
Returns an object to the pool.
