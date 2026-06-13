# =====================================
# PerformanceMonitor.gd — 运行时性能监控
# 显示 FPS、Draw Call、内存、对象数
# 按 F3 切换显示
# =====================================
extends CanvasLayer

class_name PerformanceMonitor

var _visible_flag := false
var _fps := 0
var _draw_calls := 0
var _frame_time := 0.0
var _object_count := 0
var _pool_total := 0
var _update_timer := 0.0
var _fps_counter := 0
var _fps_timer := 0.0

var _monitor_panel: Panel
var _monitor_label: Label

func _ready():
	_visible_flag = true
	
	_monitor_panel = Panel.new()
	_monitor_panel.visible = _visible_flag
	_monitor_panel.position = Vector2(10, 60)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	_monitor_panel.add_theme_stylebox_override("panel", style)
	add_child(_monitor_panel)
	
	_monitor_label = Label.new()
	_monitor_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	_monitor_label.add_theme_font_size_override("font_size", 12)
	_monitor_label.position = Vector2(8, 6)
	_monitor_panel.add_child(_monitor_label)
	
	_monitor_label.text = "Performance Monitor (F3: toggle)"

func _process(delta):
	if not _visible_flag:
		_monitor_panel.visible = false
		return
	_monitor_panel.visible = true
	
	_fps_counter += 1
	_fps_timer += delta
	_update_timer += delta
	
	# 每秒统计一次 FPS
	if _fps_timer >= 1.0:
		_fps = _fps_counter
		_fps_counter = 0
		_fps_timer -= 1.0
	
	# 每 0.5 秒刷新显示
	if _update_timer < 0.5:
		return
	_update_timer = 0.0
	
	_frame_time = Performance.get_monitor(Performance.TIME_FPS)
	_draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	_object_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	
	_pool_total = 0
	var pool_node = get_node_or_null("/root/Main/ObjectPoolRoot")
	if pool_node:
		_pool_total = pool_node.get_child_count()
	
	var text = ""
	text += "[FPS Monitor — F3: toggle]\n"
	text += "FPS:           " + str(_fps) + "\n"
	text += "Frame Time:    " + str(snapped(_frame_time, 0.01)) + " ms\n"
	text += "Draw Calls:    " + str(_draw_calls) + "\n"
	text += "Node Count:    " + str(_object_count) + "\n"
	text += "Pooled Objs:   " + str(_pool_total) + "\n"
	
	## 自定义扩展：如果有 GameStats 类可以提供更多数据
	var main = get_node_or_null("/root/Main")
	if main and main.has_method("get_stats"):
		var stats = main.get_stats()
		if stats:
			text += "Enemies:       " + str(stats.get("enemies", "?")) + "\n"
			text += "Items:         " + str(stats.get("items", "?")) + "\n"
			text += "Rooms:         " + str(stats.get("rooms", "?")) + "\n"
			text += "Floor:         " + str(stats.get("floor", "?")) + "\n"
	
	_monitor_label.text = text
	
	# 自动调整面板大小
	var line_count = _monitor_label.text.count("\n") + 2
	_monitor_panel.custom_minimum_size = Vector2(260, line_count * 18 + 12)
	_monitor_panel.size = Vector2(260, line_count * 18 + 12)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_F3 and event.pressed:
		_visible_flag = not _visible_flag
		get_viewport().set_input_as_handled()
