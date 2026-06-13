extends Node
class_name WarmSnowUI

var hp_bar: ColorRect
var hp_bg: ColorRect
var hp_label: Label
var rage_bar: ColorRect
var rage_bg: ColorRect
var rage_label: Label
var msg_label: Label

func create_hud(parent: Control):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.05, 0.03, 0.92)
	style.set_border_width_all(1)
	style.border_color = Color(0.72, 0.52, 0.12)

	# HP
	var hp_container = Panel.new()
	hp_container.size = Vector2(380, 58)
	hp_container.position = Vector2(20, 20)
	hp_container.add_theme_stylebox_override("panel", style)
	parent.add_child(hp_container)

	hp_bg = ColorRect.new()
	hp_bg.size = Vector2(330, 20)
	hp_bg.position = Vector2(25, 8)
	hp_bg.color = Color(0.45, 0.04, 0.04)
	hp_container.add_child(hp_bg)

	hp_bar = ColorRect.new()
	hp_bar.size = Vector2(330, 20)
	hp_bar.position = Vector2(25, 8)
	hp_bar.color = Color(0.75, 0.08, 0.08)
	hp_container.add_child(hp_bar)

	var hp_gold = ColorRect.new()
	hp_gold.size = Vector2(330, 2)
	hp_gold.position = Vector2(25, 7)
	hp_gold.color = Color(0.72, 0.52, 0.12)
	hp_container.add_child(hp_gold)

	hp_label = Label.new()
	hp_label.position = Vector2(25, 6)
	hp_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.85))
	hp_label.text = "HP"
	hp_container.add_child(hp_label)

	# ??
	var rage_container = Panel.new()
	rage_container.size = Vector2(380, 58)
	rage_container.position = Vector2(20, 86)
	rage_container.add_theme_stylebox_override("panel", style)
	parent.add_child(rage_container)

	rage_bg = ColorRect.new()
	rage_bg.size = Vector2(330, 20)
	rage_bg.position = Vector2(25, 8)
	rage_bg.color = Color(0.35, 0.12, 0.03)
	rage_container.add_child(rage_bg)

	rage_bar = ColorRect.new()
	rage_bar.size = Vector2(330, 20)
	rage_bar.position = Vector2(25, 8)
	rage_bar.color = Color(0.85, 0.35, 0.08)
	rage_container.add_child(rage_bar)

	var rage_gold = ColorRect.new()
	rage_gold.size = Vector2(330, 2)
	rage_gold.position = Vector2(25, 7)
	rage_gold.color = Color(0.72, 0.52, 0.12)
	rage_container.add_child(rage_gold)

	rage_label = Label.new()
	rage_label.position = Vector2(25, 6)
	rage_label.add_theme_color_override("font_color", Color(0.95, 0.55, 0.15))
	rage_label.text = "? 0/100"
	rage_container.add_child(rage_label)

	# ??
	msg_label = Label.new()
	msg_label.position = Vector2(20, 820)
	msg_label.size = Vector2(400, 70)
	msg_label.add_theme_color_override("font_color", Color(0.92, 0.82, 0.68))
	msg_label.add_theme_font_size_override("font_size", 11)
	parent.add_child(msg_label)

func update_hp(current: int, max_hp: int):
	if hp_bar:
		hp_bar.size.x = 330 * current / max_hp
	if hp_label:
		hp_label.text = "HP " + str(current) + "/" + str(max_hp)

func update_rage(current: int, max_rage: int):
	if rage_bar:
		rage_bar.size.x = 330 * current / max_rage
	if rage_label:
		rage_label.text = "? " + str(current) + "/" + str(max_rage)

func update_msg(text: String):
	if msg_label:
		msg_label.text = text
