extends Node

# ============== 娓告垙閰嶇疆 ==============

const MAP_WIDTH := 60

const MAP_HEIGHT := 40

const TILE_SIZE := 24

const VISIBLE_RADIUS := 35

const MAX_ROOMS := 10

const ROOM_MIN := 5

const ROOM_MAX := 10

const DODGE_CHANCE := 0.05

const CRIT_CHANCE := 0.05

const CRIT_MULTIPLIER := 1.5

const ENEMY_AGGRO_RANGE := 36

const AUTO_EXPLORE_MAX_STEPS := 15

const MAX_MESSAGES := 50

const DISPLAYED_MESSAGES := 7

const DUNGEON_BOSS_INTERVAL := 5

const PLAYER_BASE_HP := 25

const PLAYER_BASE_ATK := 3

const PLAYER_BASE_DEF := 1

const EXP_BASE := 15

# ============== 鍦板浘鏁版嵁 ==============

enum TileType { WALL, FLOOR, STAIRS }

var map_data := []

var explored := {}

var visible := {}

var rooms := []

var player_pos := Vector2.ZERO

var game_paused := false

var game_over := false

var game_started := false

var inventory_open := false

var pause_label: Label

var pause_panel: Panel

# var mouse_enabled := false  # removed

var key_guide_visible := false

var key_guide_panel: Panel

var key_guide_label: Label

var current_floor := 1

var player_hp := 20

var player_max_hp := 20

var player_atk := 5

var player_def := 2

var player_level := 1

var player_exp := 0

var exp_next := 15

var gold := 0

var moves := 0

var inventory := []

# ============== 姝﹀櫒绯荤粺 ==============

var weapon_inventory := []

var weapon_rarity_colors := {

	"common": Color(0.8, 0.8, 0.8),

	"uncommon": Color(0.3, 0.8, 0.3),

	"rare": Color(0.3, 0.5, 1.0),

	"epic": Color(0.7, 0.3, 1.0),

	"legendary": Color(1.0, 0.7, 0.1),

}

var weapon_rarity_names := {

	"common": "鍑″搧",

	"uncommon": "鑹插搧",

	"rare": "鏋佸搧",

	"epic": "绾㈠搧",

	"legendary": "绁炲櫒",

}

var chests := []

# ============== 鏁屼汉 & 閬撳叿 ==============

var enemies := []

var items := []

# ============== UI 寮曠敤 ==============

var map_drawer: Control

var status_label: Label

var msg_label: Label

var inventory_panel: Panel

var inventory_label: Label

var msg_list := []

var root_container: ColorRect

var _minimap_drawer: Control

var _minimap_bg: ColorRect

var _minimap_size := Vector2.ZERO

# ============== 鍔ㄧ敾 ==============

var flash_timer := 0.0

var _move_timer := 0.0

const MOVE_INTERVAL := 0.15

const MOVE_LERP_SPEED := 10.0

var move_from := Vector2.ZERO

var move_to := Vector2.ZERO

var is_moving := false

var move_progress := 0.0

# ============== 浼樺寲妯″潡 ==============

var _object_pool: ObjectPool

# ============== Sprite 娓叉煋 (浼樺寲) ==============

var _use_sprites := true

var _sprite_factory: SpriteFactory

var _sprite_manager: SpriteEntityManager

const SAVE_PATH := "user://save.dat"

# ============== FOV 预计算优化 ==============

var _fov_offsets: Array = []

var _fov_offsets_initialized := false

# ============== 棰滆壊缂撳瓨 (閬垮厤姣忓抚鍒涘缓 Color 瀵硅薄) ==============

# ============== 鏆栭洩椋庢牸绯荤粺 ==============

var rage_system: RageSystem

var dodge_system: DodgeSystem

var flying_sword: FlyingSword

var relic_system: RelicSystem

var warm_snow_ui: WarmSnowUI

var warm_snow_renderer: WarmSnowRenderer

var school_choice: String = "seven_sword"

var sword_cooldown := 0.0

const SWORD_COOLDOWN_MAX := 0.3

var last_move_dir := Vector2i.ZERO

var effects := []  # [{pos, effect, life}]

var _tile_colors := {

	"wall": Color(0.4, 0.25, 0.15),

	"wall_border": Color(0.5, 0.35, 0.2),

	"floor": Color(0.15, 0.15, 0.15),

	"floor_border": Color(0.25, 0.25, 0.2),

	"stair": Color(0.6, 0.5, 0.2),

	"stair_border": Color(0.8, 0.7, 0.3),

	"dark_wall": Color(0.4, 0.25, 0.15, 0.35),

	"dark_floor": Color(0.15, 0.15, 0.15, 0.35),

	"dark_stair": Color(0.6, 0.5, 0.2, 0.35),

}

# ============== 鏁屼汉绫诲瀷甯搁噺 ==============

const ENEMY_TYPES := [

	{"type": "rat", "name": "大鼠", "hp": 6, "atk": 3, "def": 1, "exp": 3, "gold": 1},

	{"type": "bat", "name": "蝙蝠", "hp": 5, "atk": 4, "def": 0, "exp": 3, "gold": 1},

	{"type": "skeleton", "name": "骷髅兵", "hp": 10, "atk": 5, "def": 2, "exp": 5, "gold": 3},

	{"type": "slime", "name": "史莱姆", "hp": 8, "atk": 2, "def": 1, "exp": 2, "gold": 1},

	{"type": "ghost", "name": "幽灵", "hp": 6, "atk": 5, "def": 0, "exp": 6, "gold": 4},

]

# ============== 閬撳叿妯℃澘甯搁噺 ==============

const ITEM_DEFS := [

	{"name": "血瓶", "type": "potion", "desc": "回复 10 HP", "value": 10, "color": "red"},

	{"name": "大血瓶", "type": "big_potion", "desc": "回复 25 HP", "value": 25, "color": "darkred"},

	{"name": "剑", "type": "weapon", "desc": "ATK+3", "value": 3, "color": "white"},

	{"name": "盾", "type": "shield", "desc": "DEF+2", "value": 2, "color": "blue"},

	{"name": "钱袋", "type": "gold", "desc": "Gold+5~15", "value": 0, "color": "yellow"},

	{"name": "地图", "type": "scroll", "desc": "揭示整层", "value": 0, "color": "cyan"},

]

# ============== 武器定核 ==============

const WEAPON_RARITIES := ["common", "uncommon", "rare", "epic", "legendary"]

func generate_weapon(rarity: String) -> Dictionary:

	var prefix_pool = {

	"common": ["破", "裂缺", "破紊"],

	"uncommon": ["银璃", "精牛", "凤紊"],

	"rare": ["行辙", "林魔", "破鬼"],

	"epic": ["火幕", "火鬼", "眸木"],

	"legendary": ["度火", "天涨", "火木"],

	}

	var suffix_pool = {

	"common": ["破剑", "破刃"],

	"uncommon": ["银紊", "银刃"],

	"rare": ["破翼", "破流"],

	"epic": ["火翼", "火流"],

	"legendary": ["度翼", "度刃"],

	}

	var base_stats = {

		"common": { "atk": 2, "crit": 0.03 },

		"uncommon": { "atk": 4, "crit": 0.06 },

		"rare": { "atk": 7, "crit": 0.10 },

		"epic": { "atk": 11, "crit": 0.15 },

		"legendary": { "atk": 16, "crit": 0.22 },

	}

	var prefixes = prefix_pool.get(rarity, prefix_pool["common"])

	var suffixes = suffix_pool.get(rarity, suffix_pool["common"])

	var prefix = prefixes[randi() % prefixes.size()]

	var suffix = suffixes[randi() % suffixes.size()]

	var stats = base_stats.get(rarity, base_stats["common"])

	var final_atk = stats["atk"] + randi_range(0, 3)

	var final_crit = stats["crit"] + randi_range(0, 3) * 0.01

	var wname = prefix + suffix

	if wname == "": wname = "破武"

	return {

		"name": wname,

		"rarity": rarity,

		"atk": final_atk,

		"crit_chance": final_crit,

	}

func generate_chest(pos: Vector2i):

	var roll = randf()

	var rarity = "common"

	if roll < 0.05: rarity = "legendary"

	elif roll < 0.15: rarity = "epic"

	elif roll < 0.35: rarity = "rare"

	elif roll < 0.60: rarity = "uncommon"

	var weapon = generate_weapon(rarity)

	chests.append({

		"pos": pos,

		"weapon": weapon,

		"opened": false,

	})

	var item_desc = "鎸夊惈" + weapon_rarity_names.get(rarity, "") + "姝﹀櫒"

	items.append({

		"pos": pos,

		"name": "瀹濆瓙",

		"type": "chest",

		"desc": "",

		"value": 0,

		"color": rarity,

		"collected": false,

	})

func open_chest(chest_idx: int):

	if chest_idx >= chests.size(): return

	var chest = chests[chest_idx]

	if chest.opened: return

	chest.opened = true

	var weapon = chest.weapon

	weapon_inventory.append(weapon)

	var col = weapon_rarity_colors.get(weapon["rarity"], Color(0.8, 0.8, 0.8))

	add_msg("寮€鍒颁簡瀹濆瓙! " + weapon["name"] + " (" + weapon_rarity_names.get(weapon["rarity"], "") + ")", col)

	effects.append({"pos": chest.pos, "effect": "heal", "life": 0.8})

	if weapon["rarity"] == "legendary":

		effects.append({"pos": chest.pos, "effect": "rage", "life": 1.2})

	equip_weapon(weapon_inventory.size() - 1)

func equip_weapon(idx: int):

	if idx >= weapon_inventory.size(): return

	var wp = weapon_inventory[idx]

	player_atk = PLAYER_BASE_ATK + wp["atk"]

	var col = weapon_rarity_colors.get(wp["rarity"], Color(0.8, 0.8, 0.8))

	add_msg("装备" + wp["name"] + " (" + weapon_rarity_names.get(wp["rarity"], "") + ")", col)

	update_ui()

# ============== 颜色映射常量 ==============

const ITEM_COLOR_MAP := {

	"red": Color(1, 0.3, 0.3),

	"darkred": Color(0.6, 0.1, 0.1),

	"blue": Color(0.3, 0.5, 1),

	"yellow": Color(1, 0.9, 0.2),

	"cyan": Color(0.3, 1, 1),

	"white": Color(0.9, 0.9, 0.9),

}

func _setup_input_map():

	var action_names = ["ui_right", "ui_left", "ui_up", "ui_down"]

	for a in action_names:

		if InputMap.has_action(a): InputMap.erase_action(a)

		InputMap.add_action(a)

	var key_map = {

		"ui_right": [KEY_D, KEY_RIGHT],

		"ui_left": [KEY_A, KEY_LEFT],

		"ui_up": [KEY_W, KEY_UP],

		"ui_down": [KEY_S, KEY_DOWN],

	}

	for action in key_map:

		for key in key_map[action]:

			var event = InputEventKey.new()

			event.keycode = key

			InputMap.action_add_event(action, event)

func start_smooth_move(target: Vector2):

	move_from = player_pos

	move_to = target

	move_progress = 0.0

	is_moving = true

func update_ui():

	var txt = "?" + str(current_floor) + "?"

	txt += "  HP:" + str(player_hp) + "/" + str(player_max_hp)

	txt += "  ATK:" + str(player_atk) + "  DEF:" + str(player_def)

	txt += "  Lv." + str(player_level)

	txt += "  EXP:" + str(player_exp) + "/" + str(exp_next)

	txt += "  Gold:" + str(gold) + "  Moves:" + str(moves)

	if game_over: txt += "  DEAD!"

	status_label.text = txt

func add_msg(text: String, _color = null):

	msg_list.append({"text": text})

	if msg_list.size() > MAX_MESSAGES:

		msg_list.pop_front()

	var start_idx = max(0, msg_list.size() - DISPLAYED_MESSAGES)

	var lines_p = []

	for i in range(start_idx, msg_list.size()):

		lines_p.append(msg_list[i].text)

	msg_label.text = "\\n".join(lines_p)

func _ready():

	_setup_input_map()

	print("=== _ready() called ===")

	# 加载字体保证中文显示

	var font_file := load("res://font/Font.tres") as Font

	if font_file:

		var dt := ThemeDB.get_project_theme()

		if dt:

			dt.default_font = font_file

			dt.default_font_size = 16

	var win = get_window()

	win.title = "暖雪·诅咒地牢"

	win.size = Vector2i(1400, 900)

	win.min_size = Vector2i(1400, 900)

	win.max_size = Vector2i(1400, 900)

	win.mode = Window.MODE_WINDOWED

	win.unresizable = true

	_object_pool = ObjectPool.new()

	add_child(_object_pool)

	# =====# ??????? =====

	rage_system = RageSystem.new()

	add_child(rage_system)

	rage_system.connect("rage_changed", Callable(self, "_on_rage_changed"))

	dodge_system = DodgeSystem.new()

	add_child(dodge_system)

	dodge_system.connect("dodge_performed", Callable(self, "_on_dodge_performed"))

	flying_sword = FlyingSword.new()

	add_child(flying_sword)

	relic_system = RelicSystem.new()

	add_child(relic_system)

	warm_snow_renderer = WarmSnowRenderer.new()

	add_child(warm_snow_renderer)

	warm_snow_ui = WarmSnowUI.new()

	add_child(warm_snow_ui)

	school_choice = "seven_sword"

	sword_cooldown = 0.0

	last_move_dir = Vector2i.ZERO

	effects = []

	root_container = ColorRect.new()

	root_container.anchor_right = 1.0

	root_container.anchor_bottom = 1.0

	root_container.color = Color(0.08, 0.04, 0.03)


	add_child(root_container)

	warm_snow_ui.create_hud(root_container)

	var vbox = VBoxContainer.new()

	vbox.anchor_right = 1.0

	vbox.anchor_bottom = 1.0

	vbox.add_theme_constant_override("separation", 0)

	root_container.add_child(vbox)

	var hud = Panel.new()

	hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	hud.custom_minimum_size = Vector2(0, 32)

	var hud_style = StyleBoxFlat.new()

	hud_style.bg_color = Color(0.07, 0.05, 0.03)

	hud_style.set_border_width(2, 2)

	hud_style.border_color = Color(0.55, 0.08, 0.04)

	hud.add_theme_stylebox_override("panel", hud_style)

	vbox.add_child(hud)

	status_label = Label.new()

	status_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

	status_label.add_theme_font_size_override("font_size", 14)

	status_label.position = Vector2(10, 5)

	hud.add_child(status_label)

	var map_container = Panel.new()

	map_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	map_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	map_container.add_theme_constant_override("separation", 0)

	var map_style = StyleBoxFlat.new()

	map_style.bg_color = Color(0.04, 0.02, 0.01)

	map_style.border_color = Color(0.4, 0.06, 0.03)

	map_container.add_theme_stylebox_override("panel", map_style)

	vbox.add_child(map_container)

	map_drawer = Control.new()

	map_drawer.anchor_right = 1.0

	map_drawer.anchor_bottom = 1.0

	map_drawer.connect("draw", Callable(self, "_draw_map"))

	map_container.add_child(map_drawer)

	# minimap

	_minimap_size = Vector2(MAP_WIDTH, MAP_HEIGHT) * 2

	_minimap_bg = ColorRect.new()

	_minimap_bg.color = Color(0, 0, 0, 0.5)

	_minimap_bg.size = _minimap_size + Vector2(4, 4)

	_minimap_bg.anchor_right = 1.0

	_minimap_bg.anchor_top = 0.0

	_minimap_bg.position = Vector2(-_minimap_size.x - 8, 40)

	root_container.add_child(_minimap_bg)

	_minimap_drawer = Control.new()

	_minimap_drawer.size = _minimap_size

	_minimap_drawer.anchor_right = 1.0

	_minimap_drawer.anchor_top = 0.0

	_minimap_drawer.position = Vector2(-_minimap_size.x - 6, 42)

	_minimap_drawer.connect("draw", Callable(self, "_draw_minimap"))

	root_container.add_child(_minimap_drawer)

	## ??????_draw??????????

	# _sprite_factory = SpriteFactory.new()

	# add_child(_sprite_factory)

	# _sprite_manager = SpriteEntityManager.new(_sprite_factory, TILE_SIZE, Vector2(3, 3), map_drawer)

	# add_child(_sprite_manager)

	# _sprite_manager.create_player()

	inventory_panel = Panel.new()

	inventory_panel.anchor_right = 1.0

	inventory_panel.anchor_bottom = 1.0

	inventory_panel.visible = false

	var inv_style = StyleBoxFlat.new()

	inv_style.bg_color = Color(0.04, 0.02, 0.01, 0.92)

	inv_style.border_color = Color(0.45, 0.08, 0.04)

	inventory_panel.add_theme_stylebox_override("panel", inv_style)

	root_container.add_child(inventory_panel)

	inventory_label = Label.new()

	inventory_label.position = Vector2(50, 50)

	inventory_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

	inventory_label.add_theme_font_size_override("font_size", 17)

	inventory_panel.add_child(inventory_label)

	pause_panel = Panel.new()

	pause_panel.anchor_right = 1.0

	pause_panel.anchor_bottom = 1.0

	pause_panel.visible = false

	var pause_style = StyleBoxFlat.new()

	pause_style.bg_color = Color(0.04, 0.02, 0.01, 0.85)

	pause_style.border_color = Color(0.45, 0.08, 0.04)

	pause_panel.add_theme_stylebox_override("panel", pause_style)

	root_container.add_child(pause_panel)

	pause_label = Label.new()

	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	pause_label.anchor_right = 1.0

	pause_label.anchor_bottom = 1.0

	pause_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

	pause_label.add_theme_font_size_override("font_size", 20)

	pause_panel.add_child(pause_label)

	key_guide_panel = Panel.new()

	key_guide_panel.anchor_right = 1.0

	key_guide_panel.anchor_bottom = 1.0

	key_guide_panel.visible = false

	var kg_style = StyleBoxFlat.new()

	kg_style.bg_color = Color(0.04, 0.02, 0.01, 0.88)

	kg_style.border_color = Color(0.45, 0.08, 0.04)

	key_guide_panel.add_theme_stylebox_override("panel", kg_style)

	root_container.add_child(key_guide_panel)

	key_guide_label = Label.new()

	key_guide_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	key_guide_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	key_guide_label.anchor_right = 1.0

	key_guide_label.anchor_bottom = 1.0

	key_guide_label.add_theme_color_override("font_color", Color(0.65, 0.88, 0.65))

	key_guide_label.add_theme_font_size_override("font_size", 16)

	key_guide_panel.add_child(key_guide_label)

	var msg_panel = Panel.new()

	msg_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	msg_panel.custom_minimum_size = Vector2(0, 130)

	var msg_style = StyleBoxFlat.new()

	msg_style.bg_color = Color(0.05, 0.03, 0.02)

	msg_style.set_border_width(1, 2)

	msg_style.border_color = Color(0.45, 0.06, 0.03)

	msg_panel.add_theme_stylebox_override("panel", msg_style)

	vbox.add_child(msg_panel)

	msg_label = Label.new()

	msg_label.position = Vector2(12, 8)

	msg_label.add_theme_color_override("font_color", Color(0.65, 0.88, 0.65))

	msg_label.add_theme_font_size_override("font_size", 13)

	msg_panel.add_child(msg_label)

	## ?????????

	set_process_input(true)

	show_title_screen()

func get_stats() -> Dictionary:

	return {

		"enemies": enemies.size(),

		"items": items.size(),

		"rooms": rooms.size(),

		"floor": current_floor

	}

func _process(delta):

	flash_timer += delta

	# 骞虫粦鎻掑€肩些鍔?

	if is_moving:

		move_progress += delta * MOVE_LERP_SPEED

		if move_progress >= 1.0:

			move_progress = 1.0

			is_moving = false

			player_pos = move_to

		map_drawer.queue_redraw()

		_minimap_drawer.queue_redraw()

	# 闄嶄綆鍒锋柊棰戠巼: 姣?.1绉掑埛鏂颁竴娆￠棯鐑佹晥鏋?

	if int(flash_timer * 60) != int((flash_timer - delta) * 60):

		if not is_moving:

			map_drawer.queue_redraw()

			_minimap_drawer.queue_redraw()

	if not game_started or game_over:

		return

	handle_continuous_movement(delta)

	# mouse control removed

func handle_continuous_movement(delta):

	if not game_started or game_over or inventory_open or game_paused:

		_move_timer = 0.0

		return

	var dir := Vector2i.ZERO

	var right = Input.is_action_pressed("ui_right")

	var left = Input.is_action_pressed("ui_left")

	var up = Input.is_action_pressed("ui_up")

	var down = Input.is_action_pressed("ui_down")

	if right: dir.x += 1

	if left: dir.x -= 1

	if up: dir.y -= 1

	if down: dir.y += 1

	if dir != Vector2i.ZERO: last_move_dir = dir

	if dir == Vector2i.ZERO:

		_move_timer = 0.0

		return

	_move_timer += delta

	if _move_timer < MOVE_INTERVAL:

		return

	_move_timer = 0.0

	if Input.is_key_pressed(KEY_SHIFT):

		auto_explore(dir)

	else:

		move_player(dir)

func show_title_screen():

	print("=== 浠ユ拻鐨勫湴鐗?涓昏彍鍗?===")

	game_started = false

	map_data.clear()

	msg_list.clear()

	msg_label.text = ""

	status_label.text = ""

# 创建主菜单UI（如果尚未创建）

	if not root_container.has_node("TitleUI"):

		var title_container = Panel.new()

		title_container.name = "TitleUI"

		title_container.anchor_right = 1.0

		title_container.anchor_bottom = 1.0

		var title_style = StyleBoxFlat.new()

		title_style.bg_color = Color(0.08, 0.04, 0.03)


		title_style.set_border_width_all(2)

		title_style.border_color = Color(0.55, 0.08, 0.04)

		title_container.add_theme_stylebox_override("panel", title_style)

		root_container.add_child(title_container)

		var title_vbox = VBoxContainer.new()

		title_vbox.anchor_right = 1.0

		title_vbox.anchor_bottom = 1.0

		title_vbox.add_theme_constant_override("separation", 8)

		title_container.add_child(title_vbox)

		var title_label = Label.new()

		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		title_label.add_theme_color_override("font_color", Color(0.85, 0.15, 0.1))

		title_label.add_theme_font_size_override("font_size", 42)

		title_label.text = "暖雪的诅咒地牢"

		title_label.custom_minimum_size = Vector2(0, 60)

		title_vbox.add_child(title_label)

		var sub_label = Label.new()

		sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		sub_label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.35))

		sub_label.add_theme_font_size_override("font_size", 20)

		sub_label.text = "The Binding Dungeon"

		title_vbox.add_child(sub_label)

		var spacer = Control.new()

		spacer.custom_minimum_size = Vector2(0, 40)

		title_vbox.add_child(spacer)

		var btn_vbox = VBoxContainer.new()

		btn_vbox.alignment = 1

		btn_vbox.add_theme_constant_override("separation", 12)

		title_vbox.add_child(btn_vbox)

		var items = [

			[" [ ENTER ]  开始新游戏", Color(0.65, 0.88, 0.65)],

			[" [ L ]  读取存档", Color(0.5, 0.7, 0.9)],

			[" [ DELETE ]  删除存档", Color(0.8, 0.4, 0.4)],

			[" [ H ]  键位帮助", Color(0.6, 0.6, 0.6)],

		]

		for item in items:

			var btn = Label.new()

			btn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

			btn.add_theme_color_override("font_color", item[1])

			btn.add_theme_font_size_override("font_size", 18)

			btn.text = item[0]

			btn.custom_minimum_size = Vector2(300, 28)

			btn_vbox.add_child(btn)

		var bottom_spacer = Control.new()

		bottom_spacer.custom_minimum_size = Vector2(0, 30)

		title_vbox.add_child(bottom_spacer)

		var tips_label = Label.new()

		tips_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		tips_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3))

		tips_label.add_theme_font_size_override("font_size", 12)

		tips_label.text = "WASD移动  |  J攻击  |  I背包  |  ESC暂停"

		title_vbox.add_child(tips_label)

# 键位指导

	var guide_panel = Panel.new()

	guide_panel.name = "KeyGuideUI"

	guide_panel.anchor_right = 1.0

	guide_panel.anchor_bottom = 1.0

	guide_panel.visible = false

	var gs = StyleBoxFlat.new()

	gs.bg_color = Color(0.04, 0.02, 0.01, 0.88)

	gs.border_color = Color(0.45, 0.08, 0.04)

	guide_panel.add_theme_stylebox_override("panel", gs)

	root_container.add_child(guide_panel)

	var guide_label = Label.new()

	guide_label.name = "KeyGuideLabel"

	guide_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	guide_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	guide_label.anchor_right = 1.0

	guide_label.anchor_bottom = 1.0

	guide_label.text = "=== 键位指导 ==="

	guide_label.add_theme_font_size_override("font_size", 14)

	guide_label.text += "\nW/A/S/D - 移动\nJ - 攻击(2格)\nF - 飞剑\nR - 怒气技能\n空格 - 闪避\nQ - 切换飞剑\nI - 背包\nESC - 暂停\nH - 关闭"

	guide_panel.add_child(guide_label)

		# 显示主菜单

	var title_ui = root_container.get_node("TitleUI")

	title_ui.visible = true

		# 隐藏游戏UI元素

	_minimap_bg.visible = false

	_minimap_drawer.visible = false

	inventory_panel.visible = false

	pause_panel.visible = false

	game_paused = false

	if key_guide_panel:

		key_guide_panel.visible = false

	update_ui()

func start_game():

	print("start_game() called")

	current_floor = 1

	player_hp = PLAYER_BASE_HP

	player_max_hp = PLAYER_BASE_HP

	player_atk = PLAYER_BASE_ATK

	player_def = PLAYER_BASE_DEF

	player_level = 1

	player_exp = 0

	exp_next = EXP_BASE

	gold = 0

	moves = 0

	inventory.clear()

	enemies.clear()

	items.clear()

	game_over = false

	msg_list.clear()

	msg_label.text = ""

	add_msg("==================================")

	add_msg("欢迎来到肉鸽地牢!")

	add_msg("==================================")

	# 初始化游戏

	if root_container.has_node("TitleUI"):

		root_container.get_node("TitleUI").visible = false

	_minimap_bg.visible = true

	_minimap_drawer.visible = true

	generate_dungeon()

func generate_dungeon():

	if _use_sprites and _sprite_manager:

		_sprite_manager.clear_all()

		_sprite_manager.create_player()

	print("Generating floor " + str(current_floor))

	map_data.clear()

	explored.clear()

	visible.clear()

	rooms.clear()

# 初始化地图为墙壁

	for y in range(MAP_HEIGHT):

		var row = []

		row.resize(MAP_WIDTH)

		for x in range(MAP_WIDTH):

			row[x] = TileType.WALL

		map_data.append(row)

	var max_attempts = 50

	for i in range(max_attempts):

		if rooms.size() >= MAX_ROOMS:

			break

		var w = randi_range(ROOM_MIN, ROOM_MAX)

		var h = randi_range(ROOM_MIN, ROOM_MAX)

		var x = randi_range(1, MAP_WIDTH - w - 1)

		var y = randi_range(1, MAP_HEIGHT - h - 1)

		var new_room = Rect2i(x, y, w, h)

		var overlap = false

		for r in rooms:

			if new_room.intersects(r):

				overlap = true

				break

		if not overlap:

			rooms.append(new_room)

	var room_centers = []

	for r in rooms:

		carve_room(r)

		room_centers.append(Vector2i(r.position.x + r.size.x / 2, r.position.y + r.size.y / 2))

	for i in range(1, room_centers.size()):

		var a = room_centers[i - 1]

		var b = room_centers[i]

		carve_tunnel(a, b)

	var last_room = rooms[-1]

	var stairs_pos = Vector2i(last_room.position.x + last_room.size.x / 2, last_room.position.y + last_room.size.y / 2)

	map_data[stairs_pos.y][stairs_pos.x] = TileType.STAIRS

	place_player()

	update_fov()

	place_enemies()

	place_items()

	update_ui()

	map_drawer.queue_redraw()

	_minimap_drawer.queue_redraw()

	add_msg("第" + str(current_floor) + " 层 - 当心怪物!")

	# 预计算 FOV 偏移表

	_init_fov_offsets()

func carve_room(room: Rect2i):

	var x_start = max(0, room.position.x)

	var y_start = max(0, room.position.y)

	var x_end = min(MAP_WIDTH - 1, room.position.x + room.size.x)

	var y_end = min(MAP_HEIGHT - 1, room.position.y + room.size.y)

	for y in range(y_start, y_end):

		var row = map_data[y]

		for x in range(x_start, x_end):

			row[x] = TileType.FLOOR

func carve_tunnel(a: Vector2i, b: Vector2i):

	var x = a.x

	var y = a.y

	while x != b.x:

		if y >= 0 and y < MAP_HEIGHT and x >= 0 and x < MAP_WIDTH:

			map_data[y][x] = TileType.FLOOR

		x += 1 if b.x > x else -1

	while y != b.y:

		if y >= 0 and y < MAP_HEIGHT and x >= 0 and x < MAP_WIDTH:

			map_data[y][x] = TileType.FLOOR

		y += 1 if b.y > y else -1

func place_player():

	var first_room = rooms[0]

	player_pos = Vector2(first_room.position.x + first_room.size.x / 2, first_room.position.y + first_room.size.y / 2)

func place_enemies():

	enemies.clear()

	var is_boss_floor = (current_floor % DUNGEON_BOSS_INTERVAL == 0)

	var last_room_idx = rooms.size() - 1

	for i in range(1, rooms.size()):

		var r = rooms[i]

		var count = randi_range(1, 3)

		for j in range(count):

			var ex = randi_range(r.position.x + 1, r.position.x + r.size.x - 2)

			var ey = randi_range(r.position.y + 1, r.position.y + r.size.y - 2)

			var pos = Vector2i(ex, ey)

			if pos != Vector2i(player_pos) and map_data[ey][ex] == TileType.FLOOR:

				var is_elite = randi_range(1, 100) <= 15

				var is_boss = is_boss_floor and (i == last_room_idx) and (j == 0)

				var type_data = get_enemy_type(is_elite, is_boss)

				var e = {

					pos = pos, type = type_data.type, name = type_data.name,

					hp = type_data.hp, max_hp = type_data.hp,

					atk = type_data.atk, def = type_data.def,

					exp = type_data.exp, gold = type_data.gold,

					alive = true, elite = is_elite, is_boss = is_boss

				}

				enemies.append(e)

func get_enemy_type(is_elite: bool, is_boss: bool) -> Dictionary:

	if is_boss:

		var boss_num = int(current_floor / float(DUNGEON_BOSS_INTERVAL))

		return {

			"type": "boss", "name": "榛戞殫楦＄巼路Lv" + str(boss_num),

			"hp": 50 + boss_num * 20, "atk": 12 + boss_num * 4, "def": 4 + boss_num * 2,

			"exp": 50 + boss_num * 15, "gold": 30 + boss_num * 10

		}

	if is_elite:

		return {

				"type": "elite", "name": "精英怪",

			"hp": 16 + current_floor * 3, "atk": 6 + current_floor, "def": 3 + int(current_floor / 2.0),

			"exp": 10 + current_floor * 2, "gold": 8 + current_floor

		}

	var t = ENEMY_TYPES[randi() % ENEMY_TYPES.size()]

	var scale = 1.0 + (current_floor - 1) * 0.15

	return {

		"type": t.type, "name": t.name,

		"hp": int(t.hp * scale), "atk": int(t.atk * scale), "def": int(t.def * scale),

		"exp": int(t.exp * scale), "gold": int(t.gold * scale)

	}

func place_items():

	items.clear()

	for i in range(1, rooms.size()):

		if randi_range(1, 100) <= 60:

			var r = rooms[i]

			var ix = randi_range(r.position.x + 1, r.position.x + r.size.x - 2)

			var iy = randi_range(r.position.y + 1, r.position.y + r.size.y - 2)

			var pos = Vector2i(ix, iy)

			if pos != Vector2i(player_pos) and map_data[iy][ix] == TileType.FLOOR:

				var item = ITEM_DEFS[randi() % ITEM_DEFS.size()].duplicate()

				item.pos = pos

				item.collected = false

				if item.type == "gold":

					item.value = randi_range(5, 15)

				items.append(item)

# ============== 瑙嗛噹绯荤粺 (FOV) -	# 鐢熺疆瀹濆瓙

	var chest_count = randi_range(1, 2)

	var shuffled = rooms.duplicate()

	shuffled.shuffle()

	for i in range(min(chest_count, shuffled.size())):

		var r = shuffled[i]

		var cx = r.position.x + randi() % r.size.x

		var cy = r.position.y + randi() % r.size.y

		var cp = Vector2i(cx, cy)

		if get_blocking_enemy_at(cp) == null and cp != Vector2i(player_pos):

			generate_chest(cp)

# ============== 浼樺寲鐗?============== ==============

func _init_fov_offsets() -> void:

	if _fov_offsets_initialized:

		return

	_fov_offsets_initialized = true

	_fov_offsets.clear()

	var r = VISIBLE_RADIUS

	var r_sq = r * r + r  # 鍔犱竴浜涗綑閲?

	for dy in range(-r, r + 1):

		for dx in range(-r, r + 1):

			if dx * dx + dy * dy <= r_sq:

				_fov_offsets.append(Vector2i(dx, dy))

func update_fov():

	visible.clear()

	var px = int(player_pos.x)

	var py = int(player_pos.y)

	for offset in _fov_offsets:

		var tx = px + offset.x

		var ty = py + offset.y

		if tx < 0 or tx >= MAP_WIDTH or ty < 0 or ty >= MAP_HEIGHT:

			continue

		if _fast_los(px, py, tx, ty):

			var key = Vector2i(tx, ty)

			visible[key] = true

			explored[key] = true

# 内联版视线检测(避免函数调用开销 + 常量比较)

func _fast_los(x0: int, y0: int, x1: int, y1: int) -> bool:

	var dx = abs(x1 - x0)

	var dy = abs(y1 - y0)

	var x = x0

	var y = y0

	var n = 1 + dx + dy

	var x_inc = 1 if x1 > x0 else -1

	var y_inc = 1 if y1 > y0 else -1

	var error = dx - dy

	dx *= 2

	dy *= 2

	for i in range(n):

		if x == x1 and y == y1:

			return true

		if x >= 0 and x < MAP_WIDTH and y >= 0 and y < MAP_HEIGHT:

			# 鐩存帴姣旇緝鏁村瀷: 0 = TileType.WALL

			if map_data[y][x] == 0 and not (x == x0 and y == y0):

				return false

		if error > 0:

			x += x_inc

			error -= dy

		else:

			y += y_inc

			error += dx

	return true

func is_walkable(pos: Vector2i) -> bool:

	if pos.x < 0 or pos.x >= MAP_WIDTH or pos.y < 0 or pos.y >= MAP_HEIGHT:

		return false

	return map_data[pos.y][pos.x] != TileType.WALL

func get_tile_at(pos: Vector2i) -> int:

	if pos.x < 0 or pos.x >= MAP_WIDTH or pos.y < 0 or pos.y >= MAP_HEIGHT:

		return TileType.WALL

	return map_data[pos.y][pos.x]

func get_blocking_enemy_at(pos: Vector2i):

	for e in enemies:

		if e.alive and e.pos == pos:

			return e

	return null

func get_item_at(pos: Vector2i):

	for it in items:

		if not it.collected and it.pos == pos:

			return it

	return null

# ============== 绉诲姩 & 鎴樻枟 ==============

func move_player(dir: Vector2i):

	if dir != Vector2i.ZERO: last_move_dir = dir

	if not game_started or game_over or inventory_open:

		return

	var new_pos = Vector2i(player_pos) + dir

	if not is_walkable(new_pos):

		return

	var enemy = get_blocking_enemy_at(new_pos)

	if enemy != null:

		player_attack(enemy)

		return

	if get_tile_at(new_pos) == TileType.STAIRS:

		start_smooth_move(Vector2(new_pos))

		current_floor += 1

		# (楼层无上限)
		add_msg("前往第" + str(current_floor) + "层...")

		generate_dungeon()

		update_ui()

		map_drawer.queue_redraw()

		_minimap_drawer.queue_redraw()

		return

	var item = get_item_at(new_pos)

	if item != null:

		pickup_item(item)

	enemy_turn()

	update_ui()

	map_drawer.queue_redraw()

	_minimap_drawer.queue_redraw()

func _melee_attack_2():

	# 近战攻击，距离2格，带特效

	if not game_started or game_over or game_paused: return

	var dir = last_move_dir if last_move_dir != Vector2i.ZERO else Vector2i(0, -1)

	var hit = false

	var hit_pos = Vector2i(player_pos)

	for dist in range(1, 3):

		var target_pos = Vector2i(player_pos) + dir * dist

		if target_pos.x < 0 or target_pos.x >= MAP_WIDTH or target_pos.y < 0 or target_pos.y >= MAP_HEIGHT:

			break

		var enemy = get_blocking_enemy_at(target_pos)

		if enemy != null:

			player_attack(enemy)

			hit = true

			hit_pos = target_pos

			break

		if map_data[target_pos.y][target_pos.x] == 0:  # 遇到墙壁停止

			break

		hit_pos = target_pos

	# 特效

	if hit:

		effects.append({"pos": hit_pos, "effect": "slash", "life": 0.3})

		effects.append({"pos": hit_pos, "effect": "blood", "life": 0.4})

		# 攻击轨迹特效（从玩家到目标）

		var trail_pos = Vector2i(player_pos)

		while true:

			trail_pos += dir

			if trail_pos == hit_pos: break

		effects.append({"pos": trail_pos, "effect": "hit", "life": 0.15})

	else:

		add_msg("攻击落空", Color(0.6, 0.6, 0.6))

		# 落空特效：面前一道白光

		var miss_pos = Vector2i(player_pos) + dir

		if is_walkable(miss_pos):

		effects.append({"pos": miss_pos, "effect": "hit", "life": 0.2})

func player_attack(enemy):

	if enemy == null or not enemy.alive:

		return

	var damage = max(1, player_atk - enemy.def)

	# 暖雪：圣物加持 & 怒气

	if relic_system:

		var stats = relic_system.get_stats()

		damage += stats.get("atk", 0)

		var extra_dmg = stats.get("extra_dmg", 0.0)

		if extra_dmg > 0: damage += int(damage * extra_dmg)

	if rage_system: rage_system.on_hit()

	if randi_range(1, 100) <= (CRIT_CHANCE * 100):

		damage = int(damage * CRIT_MULTIPLIER)

		add_msg("暴击! " + enemy.name + " 受到" + str(damage) + " 点伤害")

	else:

		add_msg("你攻击" + enemy.name + " 造成" + str(damage) + " 点伤害")

	enemy.hp -= damage

	effects.append({"pos": enemy.pos, "effect": "slash", "life": 0.4})

	effects.append({"pos": enemy.pos, "effect": "blood", "life": 0.5})
		effects.append({"pos": enemy.pos, "effect": "dmg_text", "text": str(damage), "life": 0.8})


	enemy.hurt_timer = 0.3

	if enemy.hp <= 0:

		enemy.alive = false

		player_exp += enemy.exp

		gold += enemy.gold

		add_msg(enemy.name + " 被打败 +" + str(enemy.exp) + "EXP, +" + str(enemy.gold) + "G")

		check_level_up()

		if randi_range(1, 100) <= 30:

			items.append({

			pos = enemy.pos, name = "指尘钱袋", type = "gold",

			desc = "Gold+" + str(enemy.gold / 2), value = int(enemy.gold / 2),

			color = "yellow", collected = false

			})

			add_msg(enemy.name + " 掉落金" + str(enemy.gold / 2) + " G")

func auto_explore(dir: Vector2i):

	if dir != Vector2i.ZERO: last_move_dir = dir

	if not game_started or game_over or inventory_open:

		return

	var steps = 0

	while steps < AUTO_EXPLORE_MAX_STEPS:

		var new_pos = Vector2i(player_pos) + dir

		if not is_walkable(new_pos):

			break

		var enemy = get_blocking_enemy_at(new_pos)

		if enemy != null:

			player_attack(enemy)

			if enemy.alive:

				break

			continue

		if get_tile_at(new_pos) == TileType.STAIRS:

			player_pos = Vector2(new_pos)

			current_floor += 1

			# (楼层无上限)
			add_msg("前往第" + str(current_floor) + "层...")

			generate_dungeon()

			update_ui()

			map_drawer.queue_redraw()

			break

		var item = get_item_at(new_pos)

		if item != null:

			pickup_item(item)

	if steps > 0:

		enemy_turn()

		update_ui()

		map_drawer.queue_redraw()

func pickup_item(item):

	if item == null or item.collected:

		return

	item.collected = true

	match item.type:

		"potion", "big_potion":

			var heal = item.value

			player_hp = min(player_max_hp, player_hp + heal)

			add_msg("你使用了 " + item.name + " 回复 " + str(heal) + " HP")

		"weapon":

			player_atk += item.value

			add_msg("装备了" + item.name + " ATK+" + str(item.value))

		"shield":

			player_def += item.value

			add_msg("装备了" + item.name + " DEF+" + str(item.value))

		"gold":

			gold += item.value

			add_msg("捡到 " + str(item.value) + " G")

		"scroll":

			for y in range(MAP_HEIGHT):

				for x in range(MAP_WIDTH):

					explored[Vector2i(x, y)] = true

					if map_data[y][x] != TileType.WALL:

						visible[Vector2i(x, y)] = true

			add_msg("地图全开")

		"chest":

			var ci = -1

			for j in range(chests.size()):

				if chests[j].pos == item.pos:

					ci = j

					break

			if ci >= 0:

				open_chest(ci)

			else:

				add_msg("宝箱已空")

		_:

			inventory.append(item)

			add_msg("捡到 " + item.name)

# ============== 敌人 AI (距离裁剪 + 降帧) ==============

var _enemy_frame_counter := 0

func enemy_turn():

	var player_tile = Vector2i(player_pos)

	_enemy_frame_counter += 1

	var aggro_sq = ENEMY_AGGRO_RANGE * ENEMY_AGGRO_RANGE

	for e in enemies:

		if not e.alive:

			continue

		var dx = e.pos.x - player_tile.x

		var dy = e.pos.y - player_tile.y

		var dist_sq = dx * dx + dy * dy

		if dist_sq > aggro_sq:

			continue

# 降帧: 距离越远更新频率越低

		var update_every := 1

		if dist_sq > 400:

			update_every = 10

		elif dist_sq > 100:

			update_every = 5

		elif dist_sq > 25:

			update_every = 2

		if _enemy_frame_counter % update_every != 0:

			continue

		if dist_sq <= 2:

			enemy_attack_player(e)

			continue

		var moves_attempted: Array

		if abs(dx) > abs(dy):

			moves_attempted = [Vector2i(sign(dx), 0), Vector2i(0, sign(dy)), Vector2i(sign(dx), sign(dy))]

		else:

			moves_attempted = [Vector2i(0, sign(dy)), Vector2i(sign(dx), 0), Vector2i(sign(dx), sign(dy))]

		for move in moves_attempted:

			var new_pos = e.pos + move

			if new_pos == player_tile:

				enemy_attack_player(e)

				break

			if is_walkable(new_pos) and get_blocking_enemy_at(new_pos) == null and new_pos != Vector2i(player_pos):

				e.pos = new_pos

				break

func enemy_attack_player(e):

	if randi_range(1, 100) <= DODGE_CHANCE * 100:

		add_msg(e.name + " 鏀诲嚮, 浣犻棯閬夸簡!")

		return

	var damage = max(1, e.atk - player_def)

	player_hp -= damage

	effects.append({"pos": Vector2i(int(player_pos.x), int(player_pos.y)), "effect": "blood", "life": 0.4})
		effects.append({"pos": Vector2i(int(player_pos.x), int(player_pos.y)), "effect": "dmg_text", "text": str(damage), "life": 0.8})


	e.hurt_timer = 0.2

	if rage_system: rage_system.on_damage_taken()

	add_msg(e.name + " 鏀诲嚮 浣? 鍙楀埌 " + str(damage) + " 鐐逛激瀹?")

	if player_hp <= 0:

		player_hp = 0

		game_over = true

		add_msg("你死了! [ENTER] 重新开始")

		update_ui()

func check_level_up():

	while player_exp >= exp_next:

		player_exp -= exp_next

		player_level += 1

		exp_next = int(EXP_BASE * pow(1.4, player_level - 1))

		player_max_hp += 5

		player_hp = player_max_hp

		player_atk += 2

		player_def += 1

		add_msg("升级! 当前等级: " + str(player_level))

		add_msg("HP: " + str(player_max_hp) + ", ATK: " + str(player_atk) + ", DEF: " + str(player_def))

# ============== Mouse Move ==============

# mouse move function removed

func _input(event):

	if event is InputEventKey and event.pressed and not event.echo:

		var k = event.keycode

		# (通关画面按键已移除)

		# 标题画面按键

		if not game_started and not game_over:

			if k == KEY_ENTER:

				start_game()

			elif k == KEY_L:

				load_game()

			elif k == KEY_DELETE:

				delete_save()

			elif k == KEY_H:

				key_guide_visible = not key_guide_visible

				if key_guide_panel:

					key_guide_panel.visible = key_guide_visible

				if root_container.has_node('KeyGuideUI'):

					root_container.get_node('KeyGuideUI').visible = key_guide_visible

				if key_guide_visible:

					add_msg("按 H 关闭键位指导")

		# 游戏中按键

		if game_started and not game_over and not game_paused:

			if k == KEY_F:

				_fire_sword_in_facing_direction()

			elif k == KEY_J:

				_melee_attack_2()

			elif k == KEY_R:

				_use_rage_skill()

			elif k == KEY_SPACE:

				if dodge_system and dodge_system.can_dodge():

					var d = last_move_dir if last_move_dir != Vector2i.ZERO else Vector2i(0, -1)

					if dodge_system.perform_dodge(d):

						start_smooth_move(player_pos + Vector2(d))

						add_msg("闪避", Color(0.65, 0.75, 0.95))

			elif k == KEY_Q:

				_cycle_sword_type()

			elif k == KEY_I:

				inventory_open = not inventory_open

				_inventory_display()

				if inventory_panel: inventory_panel.visible = inventory_open

			elif k == KEY_1:

				if weapon_inventory.size() >= 1: equip_weapon(0)

			elif k == KEY_2:

				if weapon_inventory.size() >= 2: equip_weapon(1)

			elif k == KEY_3:

				if weapon_inventory.size() >= 3: equip_weapon(2)

			elif k == KEY_H:

				key_guide_visible = not key_guide_visible

				if key_guide_panel:

					key_guide_panel.visible = key_guide_visible

				if key_guide_label:

					key_guide_label.text = "键位指南\nW/A/S/D - 移动\nJ - 攻击(2格)\nF - 飞剑\nR - 怒气技能\n空格 - 闪避\nQ - 切换飞剑\nI - 背包\nESC - 暂停\nH - 关闭键位指导"

func _inventory_display():

	if inventory_panel:

		if inventory_open:

			var txt = "背包 (I 关闭)\n"

			txt += "--- 道具 ---\n"

			if inventory.size() == 0:

				txt += "空的\n"

			else:

				for inv in inventory:

					txt += inv.name + " - " + inv.desc + "\n"

			txt += "\n--- 武器 ---\n"

			if weapon_inventory.size() == 0:

				txt += "未持武器\n"

			else:

				for i in range(weapon_inventory.size()):

					var w = weapon_inventory[i]

					var rname = weapon_rarity_names.get(w["rarity"], "")

					txt += "  " + w["name"] + " (" + rname + ") ATK+" + str(w["atk"]) + "\n"

				txt += "\n[1-" + str(weapon_inventory.size()) + "] 装备"

			inventory_label.text = txt

		else:

			inventory_label.text = ""

		update_ui()

func _draw_minimap():

	if not game_started or map_data.is_empty():

		return

	var d = _minimap_drawer

	var s := 1.0

	for y in range(MAP_HEIGHT):

		for x in range(MAP_WIDTH):

			if not explored.has(Vector2i(x, y)):

				continue

			var tile = map_data[y][x]

			var col: Color

			if tile == 0:

				col = Color(0.25, 0.16, 0.09)

			elif tile == 2:

				col = Color(0.72, 0.52, 0.12)

			else:

				col = Color(0.14, 0.09, 0.06)

			if visible.has(Vector2i(x, y)):

				col = col.lightened(0.4)

			d.draw_rect(Rect2(x * s, y * s, s, s), col)

	for e in enemies:

		if e.alive and explored.has(e.pos):

			var mc = Color(0.9, 0.15, 0.15) if e.is_boss else (Color(0.55, 0.20, 0.55) if e.elite else Color(0.9, 0.4, 0))

			d.draw_rect(Rect2(e.pos.x * s, e.pos.y * s, s, s), mc)

	for it in items:

		if not it.collected and explored.has(it.pos):

			d.draw_rect(Rect2(it.pos.x * s, it.pos.y * s, s, s), Color(1, 0.9, 0.2))

	if not game_over:

		var mp = move_to if is_moving else player_pos; d.draw_rect(Rect2(mp.x * s - 1, mp.y * s - 1, s + 2, s + 2), Color(0.75, 0.08, 0.08))

func _draw_map():

	if not game_started:

		## ?????????????

		var dr = map_drawer

		var ts = TILE_SIZE

		var w = dr.size.x

		var h = dr.size.y

		## ??????

		dr.draw_rect(Rect2(0, 0, w, h), Color(0.04, 0.02, 0.02))

		## ???????

		var ft = flash_timer

		for i in range(8):

			var px = (i * 137 + int(ft * 10) % 20) % int(w)

			var py = (i * 89 + int(ft * 5) % 30) % int(h)

			dr.draw_circle(Vector2(px, py), 2 + (i % 3), Color(0.45, 0.04, 0.04, 0.08 + i * 0.02))

		## ???????

		var pulse = sin(ft * 3) * 0.3 + 0.7


		
		
		return


	if map_data.is_empty(): return

	var bg_w = map_drawer.size.x

	var bg_h = map_drawer.size.y

	map_drawer.draw_rect(Rect2(0, 0, bg_w, bg_h), Color(0.04, 0.02, 0.02))

	var dr = map_drawer; var of = Vector2(15, 15); var ts = TILE_SIZE

	var px = int(player_pos.x); var py = int(player_pos.y)

	var min_y = max(0, py - VISIBLE_RADIUS); var max_y = min(MAP_HEIGHT, py + VISIBLE_RADIUS + 1)

	var min_x = max(0, px - VISIBLE_RADIUS); var max_x = min(MAP_WIDTH, px + VISIBLE_RADIUS + 1)

	var ft = flash_timer

	var gold := Color(0.92, 0.72, 0.28)

	var blood_red := Color(0.75, 0.08, 0.08)

	for y in range(min_y, max_y):

		for x in range(min_x, max_x):

			var tp = Vector2i(x, y)

			if not explored.has(tp): continue

			var sp = Vector2(x * ts, y * ts) + of

			var iv = visible.has(tp)

			var t = map_data[y][x]

			if not iv:

				dr.draw_rect(Rect2(sp, Vector2(ts, ts)), Color(0.06, 0.04, 0.03))

				continue

			match t:

				0: warm_snow_renderer.draw_wall(dr, sp, ts)

				1: warm_snow_renderer.draw_floor(dr, sp, ts, x, y)

				2: warm_snow_renderer.draw_stairs(dr, sp, ts, ft)

	for it in items:

		if it.collected or not visible.has(it.pos): continue

		var cc = Vector2(it.pos.x * ts, it.pos.y * ts) + of + Vector2(ts/2, ts/2)

		var float_y = sin(ft * 2 + it.pos.x + it.pos.y) * 1.5

		if it.type == "chest":

			warm_snow_renderer.draw_chest(dr, cc + Vector2(0, float_y), ft)

		else:

			warm_snow_renderer.draw_item(dr, cc + Vector2(0, float_y), it.type, ft)

	for e in enemies:

		if not e.alive or not visible.has(e.pos): continue

		var cc = Vector2(e.pos.x * ts, e.pos.y * ts) + of + Vector2(ts/2, ts/2)

		var r = ts/2 - 1

		var ec = Color(0.4, 0.2, 0.12)

		var glow = Color(0.6, 0.3, 0.15, 0.2)

		if e.is_boss:

			ec = Color(0.85, 0.65, 0.15); r = ts/2

			glow = Color(0.85, 0.65, 0.15, 0.3)

		elif e.elite:

			ec = Color(0.55, 0.20, 0.55)

			glow = Color(0.55, 0.20, 0.55, 0.25)

		dr.draw_circle(cc, r + 3, glow)

		dr.draw_circle(cc, r, Color(0.08, 0.04, 0.02))

		dr.draw_circle(cc, r - 1, ec, false, 2.0)

		if e.has("hurt_timer") and e.hurt_timer > 0:

			if int(e.hurt_timer * 20) % 2 == 0:

				dr.draw_circle(cc, r, Color(1, 1, 1, 0.3))

			e.hurt_timer -= 0.016

		var breathe = sin(ft * 3 + e.pos.x + e.pos.y) * 1.0

		var ec2 = cc + Vector2(0, breathe)

		match e.type:

			"rat": warm_snow_renderer.draw_enemy_rat(dr, ec2, r, ec)

			"bat": warm_snow_renderer.draw_enemy_bat(dr, ec2, r, ec)

			"skeleton": warm_snow_renderer.draw_enemy_skeleton(dr, ec2, r, ec)

			"slime": warm_snow_renderer.draw_enemy_slime(dr, ec2, r, ec)

			"ghost": warm_snow_renderer.draw_enemy_ghost(dr, ec2, r, ec)

		if e.is_boss:

			dr.draw_arc(cc, r + 3, 0, 6.28, 16, gold, 1.5)

		if e.hp < e.max_hp:

			var bar_y = e.pos.y * ts + of.y + ts - 3

			var bar_x = e.pos.x * ts + of.x

			dr.draw_rect(Rect2(bar_x, bar_y, ts, 2), Color(0.3, 0.02, 0.02))

			dr.draw_rect(Rect2(bar_x, bar_y, ts * float(e.hp)/e.max_hp, 2), blood_red)

	# game_won screen removed
	if not game_over and game_started:

		_draw_flying_swords()

		_draw_warm_snow_effects()

# ============== 暖雪系统功能 ==============

func _on_rage_changed(current: int, max_rage: int):

	if warm_snow_ui: warm_snow_ui.update_rage(current, max_rage)

	if current >= max_rage and game_started:

		add_msg("怒气已满！按 R 释放怒技！", Color(0.95, 0.55, 0.15))

func _on_dodge_performed(): pass

func _update_flying_swords(delta):

	if not game_started or game_over or game_paused or not flying_sword: return

	var to_remove := []

	for i in range(flying_sword.swords.size()):

		var s = flying_sword.swords[i]

		s.life -= delta; s.pos += s.dir * 200.0 * delta

		var tile_pos = Vector2i(int(s.pos.x) / TILE_SIZE, int(s.pos.y) / TILE_SIZE)

		for e in enemies:

			if e.hp > 0 and e.pos == tile_pos:

				var dmg = s.damage

				if relic_system: dmg += relic_system.get_stats().get("sword_dmg", 0)

				e.hp -= dmg

			effects.append({"pos": e.pos, "effect": "hit", "life": 0.3})

				if e.hp <= 0 and rage_system: rage_system.on_kill()

				to_remove.append(i); break

		if s.life <= 0: to_remove.append(i)

	for i in to_remove:

		if i < flying_sword.swords.size(): flying_sword.swords.remove_at(i)

func _fire_sword_in_facing_direction():

	if not game_started or game_over or game_paused: return

	if sword_cooldown > 0: return

	if not rage_system or not flying_sword: return

	if flying_sword.rage_cost > rage_system.current_rage:

		add_msg("怒气不足!", Color(0.8, 0.3, 0.3)); return

	var dir = last_move_dir if last_move_dir != Vector2i.ZERO else Vector2i(1, 0)

	var start_pos = player_pos + Vector2(dir)

	rage_system.consume_rage(flying_sword.rage_cost)

	sword_cooldown = SWORD_COOLDOWN_MAX

	var dmg = flying_sword.base_damage

	if relic_system: dmg += relic_system.get_stats().get("sword_dmg", 0)

	add_msg("飞剑!", Color(0.65, 0.75, 0.95))

func _cycle_sword_type():

	if not flying_sword: return

	var idx = flying_sword.unlocked_types.find(flying_sword.current_type)

	idx = (idx + 1) % flying_sword.unlocked_types.size()

	flying_sword.current_type = flying_sword.unlocked_types[idx]

	var names = ["普通", "追踪", "穿刺", "灵气"]

	add_msg("切换飞剑: " + names[flying_sword.current_type], Color(0.92, 0.82, 0.68))

func _use_rage_skill():

	if not game_started or game_over or game_paused: return

	if not rage_system or not rage_system.is_full():

		add_msg("怒气未满!", Color(0.8, 0.3, 0.3)); return

	rage_system.consume_all()

	var aoe_dmg = player_atk * 3

	if relic_system: aoe_dmg += relic_system.get_stats().get("aoe_dmg", 0)

	var hit_count = 0

	for e in enemies:

		if e.hp > 0:

			e.hp -= aoe_dmg

		effects.append({"pos": e.pos, "effect": "rage", "life": 0.8})

			hit_count += 1

	add_msg("怒技路血戮！伤害了" + str(hit_count) + " 个敌人!", Color(0.95, 0.55, 0.15))

func _trigger_lightning(source_enemy):

	if not source_enemy or source_enemy.hp <= 0: return

	var chain_targets = []

	for e in enemies:

		if e != source_enemy and e.hp > 0:

			var d = (e.pos - source_enemy.pos).length()

			if d <= 5: chain_targets.append(e)

	if chain_targets.size() > 0:

		var target = chain_targets[randi() % chain_targets.size()]

		target.hp -= player_atk

		effects.append({"pos": target.pos, "effect": "lightning", "life": 0.5})

		add_msg("闪电链!", Color(0.6, 0.7, 1.0))

func _draw_warm_snow_effects():
	# 绘制伤害数字


	if not map_drawer or effects.size() == 0: return

	var to_remove := []

	for i in range(effects.size()):

		var ef = effects[i]
			if ef.has("effect") and ef.effect == "dmg_text":

				var center = Vector2(ef.pos) * TILE_SIZE + Vector2(TILE_SIZE/2, TILE_SIZE/2) + Vector2(15, 15)

				var alpha = ef.life / 0.8

				var offset_y = -10 * (1.0 - alpha)

				var text_pos = center + Vector2(0, offset_y)

				# 伤害数字 - 用彩色圆点代替（无字体时不绘制文字避免报错）

				map_drawer.draw_circle(text_pos, 2, Color(1, 0.85, 0.3, alpha))

				continue


				continue


		ef.life -= 0.016

		if ef.life <= 0: to_remove.append(i); continue

		var center = Vector2(ef.pos) * TILE_SIZE + Vector2(TILE_SIZE/2, TILE_SIZE/2) + Vector2(15, 15)

		warm_snow_renderer.draw_effect(map_drawer, center, ef.effect, ef.life)

	for i in to_remove: effects.remove_at(i)

func _draw_flying_swords():

	if not map_drawer or not flying_sword: return

	for s in flying_sword.swords:

		var ft = flash_timer

		var sdir = s.dir.normalized()

		warm_snow_renderer.draw_flying_sword(map_drawer, s.pos, s.type, sdir, ft)

func _on_enemy_killed(idx: int):

	if idx < enemies.size():

		var e = enemies[idx]

		add_msg(e.name + " 被击杀了!", Color(1.0, 0.85, 0.3))

		if rage_system: rage_system.on_kill()

func save_game():

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:

		add_msg("Save failed!")

		return

	file.store_32(current_floor)

	file.store_32(player_hp)

	file.store_32(player_max_hp)

	file.store_32(player_atk)

	file.store_32(player_def)

	file.store_32(player_level)

	file.store_32(player_exp)

	file.store_32(exp_next)

	file.store_32(gold)

	file.store_32(moves)

	file.store_32(enemies.size())

	for e in enemies:

		file.store_32(e.pos.x)

		file.store_32(e.pos.y)

		file.store_32(e.hp)

		file.store_32(e.max_hp)

		file.store_32(e.atk)

		file.store_32(e.def)

		file.store_32(e.exp)

		file.store_32(e.gold)

		file.store_8(1 if e.alive else 0)

		file.store_8(1 if e.elite else 0)

		file.store_8(1 if e.is_boss else 0)

		file.store_pascal_string(e.type)

		file.store_pascal_string(e.name)

	file.store_32(items.size())

	for it in items:

		file.store_32(it.pos.x)

		file.store_32(it.pos.y)

		file.store_pascal_string(it.name)

		file.store_pascal_string(it.type)

		file.store_pascal_string(it.desc)

		file.store_32(it.value)

		file.store_pascal_string(it.color)

		file.store_8(1 if it.collected else 0)

	file.store_32(inventory.size())

	for inv in inventory:

		file.store_pascal_string(inv.name)

		file.store_pascal_string(inv.type)

		file.store_pascal_string(inv.desc)

		file.store_32(inv.value)

	file.store_32(MAP_WIDTH)

	file.store_32(MAP_HEIGHT)

	for y in range(MAP_HEIGHT):

		var row = map_data[y]

		for x in range(MAP_WIDTH):

			file.store_32(row[x])

	file.store_32(explored.size())

	for key in explored:

		file.store_32(key.x)

		file.store_32(key.y)

	file.store_32(visible.size())

	for key in visible:

		file.store_32(key.x)

		file.store_32(key.y)

	file.store_32(rooms.size())

	for r in rooms:

		file.store_32(r.position.x)

		file.store_32(r.position.y)

		file.store_32(r.size.x)

		file.store_32(r.size.y)

	file.store_32(int(player_pos.x))

	file.store_32(int(player_pos.y))

	add_msg("Game saved!")

func load_game():

	if not FileAccess.file_exists(SAVE_PATH):

		add_msg("No save file found!")

		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:

		add_msg("Load failed!")

		return false

	enemies.clear()

	items.clear()

	inventory.clear()

	map_data.clear()

	explored.clear()

	visible.clear()

	rooms.clear()

	current_floor = file.get_32()

	player_hp = file.get_32()

	player_max_hp = file.get_32()

	player_atk = file.get_32()

	player_def = file.get_32()

	player_level = file.get_32()

	player_exp = file.get_32()

	exp_next = file.get_32()

	gold = file.get_32()

	moves = file.get_32()

	var enemy_count = file.get_32()

	for i in range(enemy_count):

		var e = {

			pos = Vector2i(file.get_32(), file.get_32()),

			hp = file.get_32(), max_hp = file.get_32(),

			atk = file.get_32(), def = file.get_32(),

			exp = file.get_32(), gold = file.get_32(),

			alive = file.get_8() == 1, elite = file.get_8() == 1,

			is_boss = file.get_8() == 1,

			type = file.get_pascal_string(), name = file.get_pascal_string()

		}

		enemies.append(e)

	var item_count = file.get_32()

	for i in range(item_count):

		var it = {

			pos = Vector2i(file.get_32(), file.get_32()),

			name = file.get_pascal_string(), type = file.get_pascal_string(),

			desc = file.get_pascal_string(), value = file.get_32(),

			color = file.get_pascal_string(), collected = file.get_8() == 1

		}

		items.append(it)

	var inv_count = file.get_32()

	for i in range(inv_count):

		inventory.append({

			name = file.get_pascal_string(), type = file.get_pascal_string(),

			desc = file.get_pascal_string(), value = file.get_32()

		})

	var _map_w = file.get_32()

	var _map_h = file.get_32()

	for y in range(MAP_HEIGHT):

		var row = []

		for x in range(MAP_WIDTH):

			row.append(file.get_32())

		map_data.append(row)

	var explored_count = file.get_32()

	for i in range(explored_count):

		explored[Vector2i(file.get_32(), file.get_32())] = true

	var visible_count = file.get_32()

	for i in range(visible_count):

		visible[Vector2i(file.get_32(), file.get_32())] = true

	var room_count = file.get_32()

	for i in range(room_count):

		rooms.append(Rect2i(file.get_32(), file.get_32(), file.get_32(), file.get_32()))

	player_pos = Vector2(file.get_32(), file.get_32())

	file.close()

	game_started = true

	game_over = false

	add_msg("进入第" + str(current_floor) + "层！")

	update_ui()

	map_drawer.queue_redraw()

	_minimap_drawer.queue_redraw()

	_init_fov_offsets()

	return true

func delete_save():

	if FileAccess.file_exists(SAVE_PATH):

		DirAccess.remove_absolute(SAVE_PATH)

	add_msg("Save deleted!")
