# =====================================
# SpriteEntityManager.gd — Sprite 化的实体管理器
# 管理敌人/道具/玩家的 Sprite2D 节点
# 替代 _draw() 中手动绘制字符串的方式
# =====================================
extends Node

class_name SpriteEntityManager

var _sprite_factory: SpriteFactory
var _player_sprite: Sprite2D
var _enemy_sprites := {}
var _item_sprites := {}
var _tile_size: int = 20
var _draw_offset: Vector2 = Vector2(10, 10)
var _map_drawer: Control

func _init(factory: SpriteFactory, tile_size: int, offset: Vector2, drawer: Control):
	_sprite_factory = factory
	_tile_size = tile_size
	_draw_offset = offset
	_map_drawer = drawer

# 创建玩家 Sprite
func create_player() -> Sprite2D:
	if _player_sprite == null:
		_player_sprite = Sprite2D.new()
		_player_sprite.name = "PlayerSprite"
		_player_sprite.texture = _sprite_factory.load_sprite("player")
		_player_sprite.scale = Vector2(_tile_size / 64.0, _tile_size / 64.0)
		_player_sprite.centered = false
		_map_drawer.add_child(_player_sprite)
	return _player_sprite

# 更新玩家位置
func update_player_pos(pos: Vector2):
	if _player_sprite:
		_player_sprite.position = pos * _tile_size + _draw_offset

# 创建敌人 Sprite
func create_enemy_sprite(enemy_id: int, enemy_type: String, is_elite: bool, is_boss: bool) -> Sprite2D:
	var key = str(enemy_id)
	if _enemy_sprites.has(key):
		return _enemy_sprites[key]
	
	var spr = Sprite2D.new()
	spr.name = "Enemy_" + key
	spr.centered = false
	
	spr.texture = _sprite_factory.load_sprite(enemy_type)
	if is_boss:
		spr.texture = _sprite_factory.load_sprite("boss")
	elif is_elite:
		spr.texture = _sprite_factory.load_sprite("elite")
	spr.scale = Vector2(_tile_size / 64.0, _tile_size / 64.0)
	_map_drawer.add_child(spr)
	_enemy_sprites[key] = spr
	return spr

# 更新敌人位置
func update_enemy_pos(enemy_id: int, pos: Vector2i):
	var key = str(enemy_id)
	if _enemy_sprites.has(key):
		_enemy_sprites[key].position = Vector2(pos) * _tile_size + _draw_offset

# 移除敌人 Sprite
func remove_enemy_sprite(enemy_id: int):
	var key = str(enemy_id)
	if _enemy_sprites.has(key):
		var spr = _enemy_sprites[key]
		_map_drawer.remove_child(spr)
		spr.queue_free()
		_enemy_sprites.erase(key)

# 显示/隐藏敌人 Sprite
func set_enemy_visible(enemy_id: int, visible: bool):
	var key = str(enemy_id)
	if _enemy_sprites.has(key):
		_enemy_sprites[key].visible = visible

# 创建道具 Sprite
func create_item_sprite(item_id: int, item_type: String, color_key: String) -> Sprite2D:
	var key = str(item_id)
	if _item_sprites.has(key):
		return _item_sprites[key]
	
	var spr = Sprite2D.new()
	spr.name = "Item_" + key
	spr.centered = false
	
	var col = Color.WHITE
	match color_key:
		"red": col = Color(1, 0.3, 0.3)
		"darkred": col = Color(0.6, 0.1, 0.1)
		"blue": col = Color(0.3, 0.5, 1)
		"yellow": col = Color(1, 0.9, 0.2)
		"cyan": col = Color(0.3, 1, 1)
		"white": col = Color(0.9, 0.9, 0.9)
	
	var item_sprite_name = item_type
	if item_type == "gold": item_sprite_name = "coin"
	spr.texture = _sprite_factory.load_sprite(item_sprite_name)
	spr.scale = Vector2(_tile_size / 64.0, _tile_size / 64.0)
	_map_drawer.add_child(spr)
	_item_sprites[key] = spr
	return spr

# 更新道具位置
func update_item_pos(item_id: int, pos: Vector2i):
	var key = str(item_id)
	if _item_sprites.has(key):
		_item_sprites[key].position = Vector2(pos) * _tile_size + _draw_offset

# 移除道具 Sprite
func remove_item_sprite(item_id: int):
	var key = str(item_id)
	if _item_sprites.has(key):
		var spr = _item_sprites[key]
		_map_drawer.remove_child(spr)
		spr.queue_free()
		_item_sprites.erase(key)

# 设置 Sprites 可见性（基于 FOV）
func update_visibility(visible_set: Dictionary, enemy_list: Array, item_list: Array):
	# 玩家始终可见
	if _player_sprite:
		_player_sprite.visible = true
	
	# 敌人可见性
	for i in range(enemy_list.size()):
		var key = str(i)
		if _enemy_sprites.has(key):
			var e = enemy_list[i]
			_enemy_sprites[key].visible = visible_set.has(e.pos) if e.alive else false
	
	# 道具可见性
	for i in range(item_list.size()):
		var key = str(i)
		if _item_sprites.has(key):
			var it = item_list[i]
			_item_sprites[key].visible = visible_set.has(it.pos) if not it.collected else false

# 清空所有 Sprite
func clear_all():
	# 清除敌人
	for key in _enemy_sprites.keys():
		var spr = _enemy_sprites[key]
		if spr and spr.get_parent():
			_map_drawer.remove_child(spr)
		spr.queue_free()
	_enemy_sprites.clear()
	
	# 清除道具
	for key in _item_sprites.keys():
		var spr = _item_sprites[key]
		if spr and spr.get_parent():
			_map_drawer.remove_child(spr)
		spr.queue_free()
	_item_sprites.clear()
	
	# 清除玩家
	if _player_sprite:
		if _player_sprite.get_parent():
			_map_drawer.remove_child(_player_sprite)
		_player_sprite.queue_free()
		_player_sprite = null
