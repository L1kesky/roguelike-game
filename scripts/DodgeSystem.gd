extends Node
class_name DodgeSystem

signal dodge_performed

var dodge_cooldown := 3
var dodge_duration := 0.25
var dodge_speed := 400
var current_cooldown := 0
var is_dodging := false
var dodge_timer := 0.0
var dodge_dir := Vector2.ZERO

func can_dodge() -> bool:
	return current_cooldown <= 0 and not is_dodging

func perform_dodge(dir: Vector2i) -> bool:
	if not can_dodge():
		return false
	is_dodging = true
	dodge_timer = dodge_duration
	dodge_dir = Vector2(dir.x, dir.y)
	current_cooldown = dodge_cooldown
	dodge_performed.emit()
	return true

func update(delta: float) -> bool:
	if current_cooldown > 0:
		current_cooldown -= delta
		if current_cooldown < 0:
			current_cooldown = 0
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
			return false
		return true
	return false

func reset():
	current_cooldown = 0
	is_dodging = false
	dodge_timer = 0.0