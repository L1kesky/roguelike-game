# =====================================
# ObjectPool.gd — 通用对象池系统
# 用于复用子弹、掉落物、敌人等对象
# 显著减少 Instantiate/Free 产生的 GC 卡顿
# =====================================
extends Node

class_name ObjectPool

# 池数据结构：{ "prefab_name": [obj1, obj2, ...] }
var _pools := {}
# 根节点，所有池化对象挂在这个节点下
var _pool_root: Node

func _init():
	_pool_root = Node.new()
	_pool_root.name = "ObjectPoolRoot"
	Engine.get_main_loop().current_scene.add_child(_pool_root)

# ---------- 注册一个对象池 ----------
# pool_name: 池子名称（如 "bullet", "enemy_rat"）
# prefab:   PackedScene 或 null（如果用代码实例化）
# prefill:  预创建数量
func register(pool_name: String, _prefill: int = 0) -> void:
	if _pools.has(pool_name):
		return
	_pools[pool_name] = []

# 获取一个对象
func get_obj(pool_name: String, prefab: PackedScene = null) -> Node:
	if not _pools.has(pool_name):
		register(pool_name)
	
	var pool: Array = _pools[pool_name]
	# 先从池里找 inactive 的对象
	for obj in pool:
		if not obj.is_inside_tree() or not obj.visible:
			obj.visible = true
			obj.process_mode = PROCESS_MODE_INHERIT
			return obj
	
	# 池空则创建新的
	if prefab:
		var new_obj = prefab.instantiate()
		pool.append(new_obj)
		_pool_root.add_child(new_obj)
		return new_obj
	return null

# 归还对象到池
func return_obj(obj: Node) -> void:
	obj.visible = false
	obj.process_mode = PROCESS_MODE_DISABLED
	# 重置位置到池根节点下/远处
	if obj.get_parent():
		obj.get_parent().remove_child(obj)
	_pool_root.add_child(obj)

# 清空指定池
func clear_pool(pool_name: String) -> void:
	if _pools.has(pool_name):
		for obj in _pools[pool_name]:
			obj.queue_free()
		_pools[pool_name].clear()

# 清空所有池
func clear_all() -> void:
	for pool_key in _pools.keys():
		clear_pool(pool_key)

# 获取池大小
func pool_size(pool_name: String) -> int:
	return _pools.get(pool_name, []).size()

# 获取池中活跃对象数
func active_count(pool_name: String) -> int:
	if not _pools.has(pool_name):
		return 0
	var count := 0
	for obj in _pools[pool_name]:
		if obj.is_inside_tree() and obj.visible:
			count += 1
	return count

# 获取总对象数（含 inactive）
func total_count() -> int:
	var count := 0
	for pool_key in _pools.keys():
		count += _pools[name].size()
	return count
