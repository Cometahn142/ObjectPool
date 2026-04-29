# ObjectPool API 레퍼런스

## `ObjectPool.new(options)`
새로운 객체 풀을 생성합니다.
- `options.factory`: 새로운 객체를 생성하여 반환하는 함수.
- `options.reset`: 객체가 풀로 반환될 때 상태를 초기화하는 함수.

## `Pool:Get()`
풀에서 객체를 가져옵니다. (비어있으면 `factory` 호출)

## `Pool:Return(object)`
객체를 재사용을 위해 풀에 반환합니다.
