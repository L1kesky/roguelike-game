extends Node
class_name RageSystem

signal rage_changed(current: int, max_rage: int)
signal rage_skill_ready

var current_rage := 0
var max_rage := 100
var rage_per_hit := 8
var rage_per_kill := 20
var rage_per_damage_taken := 5

func _init():
	reset()

func reset():
	current_rage = 0

func add_rage(amount: int) -> bool:
	current_rage = mini(current_rage + amount, max_rage)
	rage_changed.emit(current_rage, max_rage)
	if current_rage >= max_rage:
		rage_skill_ready.emit()
		return true
	return false

func on_hit():
	return add_rage(rage_per_hit)

func on_kill():
	return add_rage(rage_per_kill)

func on_damage_taken():
	return add_rage(rage_per_damage_taken)

func consume_rage(amount: int) -> bool:
	if current_rage >= amount:
		current_rage -= amount
		rage_changed.emit(current_rage, max_rage)
		return true
	return false

func consume_all() -> int:
	var used = current_rage
	current_rage = 0
	rage_changed.emit(current_rage, max_rage)
	return used

func is_full() -> bool:
	return current_rage >= max_rage