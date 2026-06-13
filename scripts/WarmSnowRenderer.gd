extends Node
class_name WarmSnowRenderer

const TILE_SIZE := 24
const HALF := TILE_SIZE / 2
var map_offset := Vector2.ZERO

# 预计算颜色
var _gold := Color(0.92, 0.72, 0.28)
var _gold_dim := Color(0.72, 0.52, 0.12)
var _gold_glow := Color(0.92, 0.72, 0.28, 0.25)
var _blood_red := Color(0.75, 0.08, 0.08)
var _elite_purple := Color(0.55, 0.20, 0.55)
var _boss_gold := Color(0.85, 0.65, 0.15)
var _enemy_glow := Color(0.6, 0.3, 0.15, 0.2)
var _heal_green := Color(0.25, 0.85, 0.35)
var _weapon_blue := Color(0.65, 0.75, 0.95)
var _scroll_warm := Color(0.92, 0.82, 0.68)
var _shield_blue := Color(0.3, 0.5, 1.0)
var _dark_tile := Color(0.2, 0.14, 0.1)
var _floor_c := Color(0.55, 0.42, 0.3)
var _floor_line := Color(0.3, 0.22, 0.15)
var _wall_c := Color(0.35, 0.25, 0.18)
var _wall_bright := Color(0.45, 0.3, 0.2)
var _wall_gold := Color(0.72, 0.52, 0.12).darkened(0.5)
var _shadow_line := Color(0.15, 0.08, 0.04)
var _stair_glow := Color(0.8, 0.65, 0.2, 0.6)
var _blood_splatter := Color(0.5, 0.03, 0.03, 0.18)
var _white_trans := Color(1, 1, 1, 0.3)
var _body_dark := Color(0.15, 0.08, 0.08)
var _player_outline := Color(0.9, 0.15, 0.15)
var _player_glow := Color(0.9, 0.15, 0.15, 0.3)
var _player_sword := Color(0.4, 0.25, 0.12)
var _player_hair := Color(0.2, 0.15, 0.12)
var _player_mask := Color(0.85, 0.82, 0.78)
var _skeleton_bone := Color(0.85, 0.8, 0.7)
var _ghost_blue := Color(0.6, 0.7, 0.9)
var _slime_green := Color(0.3, 0.6, 0.3)
var _bat_wing := Color(0.35, 0.2, 0.15)
var _rat_brown := Color(0.5, 0.3, 0.15)
var _crit_yellow := Color(1.0, 0.9, 0.4)
var _rage_core := Color(0.95, 0.1, 0.05)
var _rage_mid := Color(0.95, 0.55, 0.15)
var _rage_outer := Color(0.95, 0.35, 0.1)
var _lightning_core := Color(0.6, 0.7, 1.0)
var _lightning_glow := Color(0.8, 0.85, 1.0)
var _heal_core := Color(0.25, 0.85, 0.35)
var _heal_glow := Color(0.25, 0.95, 0.45)

func _ready():
	map_offset = Vector2(15, 15)

# 绘制墙壁——石纹浮雕+金边铆钉
func draw_wall(canvas: Control, sp: Vector2, ts: int):
	canvas.draw_rect(Rect2(sp, Vector2(ts, ts)), _wall_c)
	# 凹凸暗面（左侧+上方阴影）
	canvas.draw_rect(Rect2(sp, Vector2(ts, 3)), _shadow_line)
	canvas.draw_rect(Rect2(sp, Vector2(3, ts)), _shadow_line)
	# 右下亮边
	canvas.draw_rect(Rect2(sp + Vector2(ts-3, 0), Vector2(3, ts)), _wall_bright)
	canvas.draw_rect(Rect2(sp + Vector2(0, ts-3), Vector2(ts, 3)), _wall_bright)
	# 石纹竖线
	var cx = int(sp.x) % 3
	if cx == 0:
		canvas.draw_line(sp + Vector2(ts/3, 3), sp + Vector2(ts/3, ts-3), Color(0.18, 0.1, 0.05), 1.0)
	# 石纹横线
	var cy = int(sp.y) % 3
	if cy == 0:
		canvas.draw_line(sp + Vector2(3, ts/3), sp + Vector2(ts-3, ts/3), Color(0.18, 0.1, 0.05), 1.0)
	# 金色边框
	canvas.draw_rect(Rect2(sp, Vector2(ts, ts)), _wall_gold, false, 1.0)
	# 四角铆钉
	var hs = ts/4
	var r = 2.0
	canvas.draw_circle(sp + Vector2(hs, hs), r, _gold.darkened(0.5))
	canvas.draw_circle(sp + Vector2(ts-hs, hs), r, _gold.darkened(0.5))
	canvas.draw_circle(sp + Vector2(hs, ts-hs), r, _gold.darkened(0.5))
	canvas.draw_circle(sp + Vector2(ts-hs, ts-hs), r, _gold.darkened(0.5))

# 绘制地板——血墨砖格+随机血渍
func draw_floor(canvas: Control, sp: Vector2, ts: int, x: int, y: int):
	canvas.draw_rect(Rect2(sp, Vector2(ts, ts)), _floor_c)
	# 砖缝网格
	canvas.draw_line(sp + Vector2(0, 0), sp + Vector2(ts, 0), _floor_line, 1.0)
	canvas.draw_line(sp + Vector2(0, 0), sp + Vector2(0, ts), _floor_line, 1.0)
	# 砖纹中心暗点
	canvas.draw_circle(sp + Vector2(ts/2, ts/2), 2, Color(0.1, 0.06, 0.04, 0.3))
	# 随机血渍（确定性随机）
	var pr = (x * 7 + y * 13) % 12
	if pr < 4:
		var bd = Color(0.55, 0.05, 0.05, 0.12 + pr * 0.03)
		var bx = (x * 5 + pr * 3) % ts
		var by = (y * 7 + pr * 5) % ts
		canvas.draw_circle(sp + Vector2(bx, by), 2 + pr/2, bd)
		if pr < 2:
			canvas.draw_circle(sp + Vector2((bx+7)%ts, (by+5)%ts), 1.5, Color(0.55, 0.05, 0.05, 0.08))

# 绘制楼梯——金芒星阵
func draw_stairs(canvas: Control, sp: Vector2, ts: int, ft: float):
	canvas.draw_rect(Rect2(sp, Vector2(ts, ts)), _floor_c)
	canvas.draw_rect(Rect2(sp, Vector2(ts, ts)), _gold, false, 2.0)
	# 旋转星标
	var cc = sp + Vector2(ts/2, ts/2)
	var glow_r = 4 + sin(ft * 3) * 1.5
	canvas.draw_circle(cc, glow_r, _gold_glow)
	canvas.draw_line(cc + Vector2(-5, 0), cc + Vector2(5, 0), _stair_glow, 2.0)
	canvas.draw_line(cc + Vector2(0, -5), cc + Vector2(0, 5), _stair_glow, 2.0)
	canvas.draw_line(cc + Vector2(-4, -4), cc + Vector2(4, 4), _stair_glow, 1.0)
	canvas.draw_line(cc + Vector2(-4, 4), cc + Vector2(4, -4), _stair_glow, 1.0)

# 绘制玩家——暖雪剑士+方向剑气
func draw_player(canvas: Control, center: Vector2, r: int, ft: float, sdir: Vector2):
	# 外发光
	var glow_r = r + 2 + int(ft * 3) % 2
	canvas.draw_circle(center, glow_r, _player_glow)
	# 身体（暗红圆底）
	canvas.draw_circle(center, r-1, _body_dark)
	# 血红外圈（闪烁）
	var pc = Color(0.85, 0.1, 0.1) if int(ft * 10) % 2 == 0 else Color(0.65, 0.08, 0.08)
	canvas.draw_circle(center, r-1, pc, false, 2.0)
	# 背剑交叉
	canvas.draw_line(center + Vector2(-3, -5), center + Vector2(3, 5), _player_sword, 1.5)
	canvas.draw_line(center + Vector2(3, -5), center + Vector2(-3, 5), _player_sword, 1.5)
	# 头发（水墨黑）
	canvas.draw_circle(center + Vector2(0, -r+3), 3, _player_hair)
	# 面具/脸部（白）
	canvas.draw_circle(center + Vector2(0, 0), 2, _player_mask)

# 绘制敌人——按类型独特纹理
func draw_enemy_rat(canvas: Control, cc: Vector2, r: int, ec: Color):
	canvas.draw_circle(cc + Vector2(0, 2), 2, ec.lightened(0.2))
	canvas.draw_circle(cc + Vector2(-2, -2), 1.5, ec.lightened(0.5))
	canvas.draw_circle(cc + Vector2(2, -2), 1.5, ec.lightened(0.5))
	canvas.draw_circle(cc + Vector2(-2, -2), 0.8, Color(0.95, 0.1, 0.1))
	canvas.draw_circle(cc + Vector2(2, -2), 0.8, Color(0.95, 0.1, 0.1))

func draw_enemy_bat(canvas: Control, cc: Vector2, r: int, ec: Color):
	canvas.draw_line(cc + Vector2(-r+1, -2), cc + Vector2(-r+4, 2), ec.lightened(0.3), 1.5)
	canvas.draw_line(cc + Vector2(r-1, -2), cc + Vector2(r-4, 2), ec.lightened(0.3), 1.5)
	canvas.draw_circle(cc + Vector2(-1, -1), 1, Color(0.95, 0.1, 0.1))
	canvas.draw_circle(cc + Vector2(1, -1), 1, Color(0.95, 0.1, 0.1))

func draw_enemy_skeleton(canvas: Control, cc: Vector2, r: int, ec: Color):
	canvas.draw_line(cc + Vector2(-3, -2), cc + Vector2(-1, 2), _skeleton_bone, 1.5)
	canvas.draw_line(cc + Vector2(-1, -2), cc + Vector2(-3, 2), _skeleton_bone, 1.5)
	canvas.draw_line(cc + Vector2(1, -2), cc + Vector2(3, 2), _skeleton_bone, 1.5)
	canvas.draw_line(cc + Vector2(3, -2), cc + Vector2(1, 2), _skeleton_bone, 1.5)
	canvas.draw_circle(cc, 3, _skeleton_bone * Color(1,1,1,0.3))

func draw_enemy_slime(canvas: Control, cc: Vector2, r: int, ec: Color):
	canvas.draw_arc(cc + Vector2(0, -2), r-2, 0, 3.14, 8, ec.lightened(0.3), 1.5)
	canvas.draw_circle(cc + Vector2(-2, -3), 1, Color(0.2, 0.2, 0.2))
	canvas.draw_circle(cc + Vector2(2, -3), 1, Color(0.2, 0.2, 0.2))

func draw_enemy_ghost(canvas: Control, cc: Vector2, r: int, ec: Color):
	canvas.draw_circle(cc + Vector2(0, -r+2), 3, Color(0.6, 0.7, 0.9, 0.3))
	canvas.draw_circle(cc + Vector2(-1, -3), 1, Color(0.95, 0.1, 0.1, 0.6))
	canvas.draw_circle(cc + Vector2(1, -3), 1, Color(0.95, 0.1, 0.1, 0.6))

# 绘制物品——灵韵光点+旋转光环
func draw_item(canvas: Control, cc: Vector2, item_type: String, ft: float):
	var col = _gold
	var glow_col = _gold_glow
	match item_type:
		"potion", "big_potion":
			col = _heal_green
			glow_col = Color(0.25, 0.85, 0.35, 0.15)
		"weapon":
			col = _weapon_blue
			glow_col = Color(0.65, 0.75, 0.95, 0.15)
		"scroll":
			col = _scroll_warm
			glow_col = Color(0.92, 0.82, 0.68, 0.15)
		"shield":
			col = _shield_blue
			glow_col = Color(0.3, 0.5, 1.0, 0.15)
	canvas.draw_circle(cc, 6, glow_col)
	var pulse = sin(ft * 4) * 1.5
	canvas.draw_circle(cc, 3, col)
	canvas.draw_circle(cc, 3, _white_trans, false, 1.5)
	# 旋转光环
	for s in range(3):
		var a = s * 2.09 + ft * 2.0
		var dp = cc + Vector2(cos(a), sin(a)) * (5 + pulse)
		canvas.draw_circle(dp, 1, Color(col.r, col.g, col.b, 0.3))

# 绘制飞剑——剑芒+流光+拖尾
func draw_flying_sword(canvas: Control, pos: Vector2, sword_type: int, sdir: Vector2, ft: float):
	var base_col = _weapon_blue
	match sword_type:
		1: base_col = Color(0.95, 0.75, 0.35)
		2: base_col = Color(0.55, 0.85, 0.95)
		3: base_col = Color(0.85, 0.65, 0.95)
	
	var p = pos + map_offset
	# 残影轨迹
	for t in range(4):
		var trail_pos = p - sdir * (t * 5 + 3)
		var alpha = 0.35 - t * 0.08
		canvas.draw_circle(trail_pos, 4 - t, Color(base_col.r, base_col.g, base_col.b, max(0, alpha)))
	# 剑体：光点+剑芒
	canvas.draw_circle(p, 4, base_col)
	canvas.draw_circle(p, 7, Color(base_col.r, base_col.g, base_col.b, 0.15))
	canvas.draw_circle(p, 4, Color(1, 1, 1, 0.35), false, 1.5)
	# 剑尖光痕
	canvas.draw_line(p, p + sdir * 7, Color(base_col.r, base_col.g, base_col.b, 0.45), 1.5)
	# 剑柄
	canvas.draw_line(p + sdir * (-2), p + sdir * 2, Color(0.3, 0.15, 0.05), 2.0)

# 绘制特效——水墨溅射+血雾
func draw_effect(canvas: Control, center: Vector2, effect_type: String, life: float):
	var a = life
	var r = 4 + int((1.0 - a) * 8)
	var ft = life * 10.0
	match effect_type:
		"crit":
			canvas.draw_circle(center, r + 2, Color(1, 0.95, 0.5, a * 0.6))
			canvas.draw_circle(center, r, Color(1, 0.85, 0.2, a * 0.8))
			canvas.draw_circle(center, r - 2, Color(1, 1, 0.8, a * 0.5))
			canvas.draw_line(center + Vector2(-r-2, -r-2), center + Vector2(r+2, r+2), Color(1, 0.9, 0.4, a * 0.4), 2.0)
			canvas.draw_line(center + Vector2(-r-2, r+2), center + Vector2(r+2, -r-2), Color(1, 0.9, 0.4, a * 0.4), 2.0)
			for s in range(8):
				var ang = s * 0.785 + ft * 0.5
				var dpos = center + Vector2(cos(ang), sin(ang)) * (r + 4 + int((1.0 - a) * 6))
				canvas.draw_circle(dpos, 1.5, Color(1, 0.9, 0.3, a * 0.5))
		"hit":
			canvas.draw_arc(center, r + 2, 0, 3.14, 8, Color(1, 1, 1, a * 0.4), 2.0)
			canvas.draw_arc(center, r, 3.14, 6.28, 8, Color(1, 1, 1, a * 0.3), 1.5)
			canvas.draw_circle(center, r, Color(0.9, 0.9, 1.0, a * 0.5))
			canvas.draw_circle(center, r - 1, Color(1, 1, 1, a * 0.3))
		"rage":
			canvas.draw_circle(center, r + 6, Color(0.95, 0.15, 0.05, a * 0.25))
			canvas.draw_circle(center, r + 4, Color(0.95, 0.35, 0.1, a * 0.35))
			canvas.draw_circle(center, r + 2, Color(0.95, 0.55, 0.15, a * 0.3))
			canvas.draw_circle(center, r, Color(0.95, 0.1, 0.05, a * 0.5))
			canvas.draw_circle(center, r - 1, Color(1, 0.3, 0.1, a * 0.4))
			for s in range(6):
				var ang = s * 1.05 + a * 2.0
				var dpos = center + Vector2(cos(ang), sin(ang)) * r * 2.0
				canvas.draw_circle(dpos, 2 + int(a * 3), Color(0.75, 0.08, 0.08, a * 0.6))
				var dpos2 = center + Vector2(cos(ang + 0.5), sin(ang + 0.5)) * r * 1.5
				canvas.draw_circle(dpos2, 1, Color(0.95, 0.45, 0.15, a * 0.4))
		"lightning":
			canvas.draw_circle(center, r + 2, Color(0.8, 0.85, 1.0, a * 0.3))
			canvas.draw_circle(center, r, Color(0.6, 0.7, 1.0, a * 0.5))
			canvas.draw_circle(center, r - 1, Color(0.9, 0.95, 1.0, a * 0.35))
			for s in range(4):
				var ang = s * 1.57 + a * 3.0
				var dpos = center + Vector2(cos(ang), sin(ang)) * r * 2.5
				canvas.draw_line(center, dpos, Color(0.6, 0.7, 1.0, a * 0.4), 2.0)
				canvas.draw_line(dpos, dpos + Vector2(cos(ang+0.8), sin(ang+0.8)) * r * 0.8, Color(0.6, 0.7, 1.0, a * 0.2), 1.0)
		"heal":
			canvas.draw_circle(center, r + 3, Color(0.25, 0.95, 0.45, a * 0.2))
			canvas.draw_circle(center, r, Color(0.25, 0.85, 0.35, a * 0.5))
			canvas.draw_circle(center, r - 1, Color(0.4, 1.0, 0.5, a * 0.3))
			for s in range(5):
				var ang = s * 1.26 + ft * 0.3
				var dpos = center + Vector2(cos(ang), sin(ang)) * (r + 2) + Vector2(0, -(1.0 - a) * 4)
				canvas.draw_circle(dpos, 1.5, Color(0.25, 0.95, 0.45, a * 0.5))
		"blood":
			canvas.draw_circle(center, r, Color(0.55, 0.05, 0.05, a * 0.4))
			for s in range(8):
				var ang = s * 0.785 + a * 2.5
				var dist = r * (1.5 + a * 2.0)
				var dpos = center + Vector2(cos(ang), sin(ang)) * dist
				canvas.draw_circle(dpos, 1.5 + int((1.0 - a) * 3), Color(0.75, 0.08, 0.08, a * 0.35))
				var dpos2 = center + Vector2(cos(ang+0.4), sin(ang+0.4)) * dist * 0.7
				canvas.draw_circle(dpos2, 1, Color(0.55, 0.05, 0.05, a * 0.25))
		"slash":
			var arc_r = r + 6
			for s in range(3):
				var ang_start = -1.0 + s * 0.3 - a * 0.5
				var ang_end = 1.0 + s * 0.3 + a * 0.5
				var alpha = a * (0.5 - s * 0.15)
				canvas.draw_arc(center + Vector2(cos(ft) * 2, sin(ft) * 2) * s, arc_r - s * 2, ang_start, ang_end, 12, Color(0.85, 0.85, 0.95, max(0, alpha)), 2.0 - s * 0.5)
		"trail":
			canvas.draw_circle(center, 2 + int(a * 3), Color(0.65, 0.08, 0.08, a * 0.3))
			canvas.draw_circle(center + Vector2(randf_range(-2, 2), randf_range(-2, 2)), 1, Color(0.92, 0.72, 0.28, a * 0.15))

func draw_slash_arc(canvas: Control, center: Vector2, dir: Vector2, ft: float):
	var perp = Vector2(-dir.y, dir.x)
	var arc_len = 1.2
	var arc_r = 10.0
	for i in range(3):
		var alpha = 0.4 - i * 0.12
		var offset = dir * i * 2.0
		canvas.draw_arc(center + offset + perp * i, arc_r - i * 2, -arc_len + ft * 0.2, arc_len + ft * 0.2, 10, Color(0.85, 0.85, 0.95, max(0, alpha)), 2.5 - i * 0.5)

func draw_attack_trail(canvas: Control, start_pos: Vector2, end_pos: Vector2, life: float):
	var a = life
	canvas.draw_line(start_pos, end_pos, Color(0.85, 0.85, 0.95, a * 0.3), 2.0 + int(a * 2))
	var mid = (start_pos + end_pos) / 2
	canvas.draw_circle(mid, 2 + int(a * 2), Color(0.9, 0.9, 1.0, a * 0.4))

func draw_particle_burst(canvas: Control, center: Vector2, color: Color, count: int, life: float):
	var a = life
	for s in range(count):
		var ang = s * (6.28 / count) + (1.0 - a) * 3.0
		var dist = 3 + int((1.0 - a) * 6)
		var dpos = center + Vector2(cos(ang), sin(ang)) * dist
		var pc = Color(color.r, color.g, color.b, a * 0.6)
		canvas.draw_circle(dpos, 1.5, pc)


func draw_chest(canvas: Control, cc: Vector2, ft: float):
	var pulse = sin(ft * 3) * 0.3 + 0.7
	var gold = Color(0.92, 0.72, 0.28)
	canvas.draw_rect(Rect2(cc - Vector2(5, 5), Vector2(10, 10)), Color(0.15, 0.1, 0.05))
	canvas.draw_rect(Rect2(cc - Vector2(5, 5), Vector2(10, 10)), Color(gold.r, gold.g, gold.b, pulse), false, 2.0)
	canvas.draw_circle(cc, 3, Color(gold.r, gold.g, gold.b, pulse * 0.4))
	canvas.draw_circle(cc, 2, Color(1, 1, 0.8, pulse * 0.3))
	for s in range(4):
		var ang = s * 1.57 + ft * 2.0
		var dp = cc + Vector2(cos(ang), sin(ang)) * 7
		canvas.draw_circle(dp, 1, Color(0.92, 0.72, 0.28, pulse * 0.3))
