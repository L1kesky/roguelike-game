# =====================================
# SpriteFactory.gd - 加载外部像素贴图
# 从 assets/sprites/ 加载 PNG 贴图
# =====================================
extends Node

class_name SpriteFactory

const SPRITE_DIR := "res://assets/sprites/"

var _cache := {}

# 从 PNG 文件加载贴图
func load_sprite(name: String) -> Texture2D:
	if _cache.has(name):
		return _cache[name]
	
	var img = Image.new()
	var err = img.load(SPRITE_DIR + name + ".png")
	if err != OK:
		return _make_default_tex()
	var tex = ImageTexture.create_from_image(img)
	_cache[name] = tex
	return tex

func _make_default_tex() -> Texture2D:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)

# 兼容旧接口
func make_text_sprite(text: String, color: Color, size: int = 20) -> Texture2D:
	var name_map = {
		"@": "player", "玩家": "player",
		"B": "boss", "Boss": "boss",
		"E": "elite", "Elite": "elite",
		"r": "rat", "rat": "rat",
		"b": "bat", "bat": "bat",
		"s": "skeleton", "skeleton": "skeleton",
		"o": "slime", "slime": "slime",
		"g": "ghost", "ghost": "ghost",
		"!": "potion", "potion": "potion",
		"+": "big_potion", "big_potion": "big_potion",
		"/": "weapon", "weapon": "weapon",
		"#": "shield", "shield": "shield",
		"$": "coin", "gold": "coin",
		"~": "scroll", "scroll": "scroll",
	}
	var sprite_name = name_map.get(text, "player")
	return load_sprite(sprite_name)