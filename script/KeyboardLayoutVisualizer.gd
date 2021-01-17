tool
extends Control
const Key = preload("Key.gd")
const KeyboardMetadata = preload("KeyboardMetadata.gd")
const Keyboard = preload("Keyboard.gd")
const KeyboardSerial = preload("KeyboardSerial.gd")

export(String, FILE, "*.json") var src_path = "res://asset/keyboard_layouts/keyboard-default.json" setget set_src_path
export var key_unit_size = 10 setget set_key_unit_size

var keyboard
var label_margin = Vector2.ONE

	
func _draw():
	var rect = Rect2()
	for key in keyboard.keys:
		var key_rect = key.get_rect()
		key_rect.position.x *= key_unit_size
		key_rect.position.y *= key_unit_size
		key_rect.size.x *= key_unit_size
		key_rect.size.y *= key_unit_size
		draw_rect(key_rect, Color(key.color))
		draw_rect(key_rect, Color.black, false)
		for i in key.labels.size():
			var label = key.labels[i]
			var font = get_font("") 
			var label_pos = key_rect.position + Vector2(0, font.height) + label_margin
			# TODO: set font size
			if typeof(label) == TYPE_STRING:
				# TODO: Wrap/clip string in key_rect
				draw_string(font, label_pos, label, Color(key.textColor[i] if key.textColor else key.default.textColor))
			break # TODO: Handle more than 1 label
		rect = rect.merge(key_rect)
	rect_size = rect.size

func load_layout():
	if not src_path:
		print("Not src provided")
		return

	var src_file = File.new()
	var file_error = src_file.open(src_path, File.READ)
	if  file_error:
		print("Error opening file(%s): ERROR %s" % [src_path, file_error])
		return

	var src_text = src_file.get_as_text()
	src_file.close()
	keyboard = KeyboardSerial.parse(src_text)

func set_src_path(p):
	src_path = p
	load_layout()
	update()

func set_key_unit_size(size):
	key_unit_size = size
	update()
