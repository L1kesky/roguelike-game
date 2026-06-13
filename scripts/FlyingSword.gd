extends Node
class_name FlyingSword

enum SwordType { NORMAL, TRACKING, PIERCE, SPIRIT }

const SWORD_DATA := {
	SwordType.NORMAL: { "damage": 5, "speed": 300, "rage_cost": 10, "pierce": 0, "tracking": false, "color_key": "FLYING_SWORD" },
	SwordType.TRACKING: { "damage": 4, "speed": 250, "rage_cost": 15, "pierce": 0, "tracking": true, "color_key": "TRACKING_SWORD" },
	SwordType.PIERCE: { "damage": 3, "speed": 200, "rage_cost": 18, "pierce": 2, "tracking": false, "color_key": "FLYING_SWORD" },
	SwordType.SPIRIT: { "damage": 8, "speed": 350, "rage_cost": 25, "pierce": 0, "tracking": true, "color_key": "TRACKING_SWORD" },
}

var swords := []
var current_type := SwordType.NORMAL
var unlocked_types := [SwordType.NORMAL]
var rage_cost := 10
var base_damage := 5