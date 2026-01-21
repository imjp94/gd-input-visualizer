@tool
class_name KeyboardLayoutVisualizer extends Control

@export var src_path = "res://asset/keyboard_layouts/keyboard-default.json": set = set_src_path
@export var key_unit_size = 10: set = set_key_unit_size

var keyboard
var label_margin = Vector2.ONE

	
func _draw():
	var rect = Rect2()
	
	if keyboard == null: return
	
	for key in keyboard.keys:
		var key_rect = key.get_rect()
		key_rect.position.x *= key_unit_size
		key_rect.position.y *= key_unit_size
		key_rect.size.x *= key_unit_size
		key_rect.size.y *= key_unit_size
		draw_rect(key_rect, Color(key.color))
		draw_rect(key_rect, Color.BLACK, false)
		for i in key.labels.size():
			var label = key.labels[i]
			var font = get_theme_font("") 
			var label_pos = key_rect.position + Vector2(0, font.get_height()) + label_margin
			# TODO: set font size
			if typeof(label) == TYPE_STRING:
				# TODO: Wrap/clip string in key_rect
				print(key.textColor)
				#draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 16, (key.textColor[i] if key.textColor else key.default.textColor))
				draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 16)
			break # TODO: Handle more than 1 label
		rect = rect.merge(key_rect)
	size = rect.size

func load_layout():
	if not src_path:
		print("Not src provided")
		return

	var src_file := FileAccess.open(src_path, FileAccess.READ)
	var file_error := FileAccess.get_open_error()
	if file_error != OK:
		print("Error opening file(%s): ERROR %s" % [src_path, file_error])
		return

	var src_text = src_file.get_as_text()
	src_file.close()
	keyboard = KeyboardSerial.parse(src_text)

func set_src_path(p):
	src_path = p
	load_layout()
	#update()
	queue_redraw()

func set_key_unit_size(size):
	key_unit_size = size
	#update()
	queue_redraw()
