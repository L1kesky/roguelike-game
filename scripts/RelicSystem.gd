extends Node
class_name RelicSystem

class Relic:
	var name: String
	var slot: int
	var school: String
	var rarity: String
	var effects: Dictionary
	var description: String
	func _init(n: String, s: int, sc: String, r: String, eff: Dictionary, desc: String):
		name = n; slot = s; school = sc; rarity = r; effects = eff; description = desc

var equipped: Array = [null, null, null, null]
var school: String = "seven_sword"

class SetBonus:
	var school_name: String
	var count: int
	var description: String
	var effects: Dictionary
	func _init(sc: String, c: int, desc: String, eff: Dictionary):
		school_name = sc; count = c; description = desc; effects = eff

func get_stats() -> Dictionary:
	var total := { "atk": 0, "def": 0, "crit_chance": 0.0, "crit_dmg": 0.0, "lifesteal": 0.0, "dodge": 0.0 }
	for relic in equipped:
		if relic == null: continue
		for key in relic.effects:
			if total.has(key): total[key] += relic.effects[key]
	var sc = 0
	for relic in equipped:
		if relic != null and relic.school == school: sc += 1
	for bonus in _get_bonuses(school):
		if sc >= bonus.count:
			for key in bonus.effects:
				if total.has(key): total[key] += bonus.effects[key]
	return total

func _get_bonuses(s: String) -> Array:
	var all = {
		"seven_sword": [
			SetBonus.new("seven_sword", 2, "双件：攻击+5，暴击率+10%", { "atk": 5, "crit_chance": 0.1 }),
			SetBonus.new("seven_sword", 4, "四件：每次攻击额外造成50%伤害", { "extra_dmg": 0.5 })
		],
		"boundless": [
			SetBonus.new("boundless", 2, "双件：飞剑伤害+5，穿透+1", { "sword_dmg": 5, "pierce_count": 1 }),
			SetBonus.new("boundless", 4, "四件：飞剑变为追踪飞剑", { "auto_tracking": true })
		],
		"thunder_god": [
			SetBonus.new("thunder_god", 2, "双件：攻击附带闪电链", { "lightning_chain": true }),
			SetBonus.new("thunder_god", 4, "四件：击杀触发全屏雷暴", { "storm_on_kill": true })
		]
	}
	return all.get(s, [])