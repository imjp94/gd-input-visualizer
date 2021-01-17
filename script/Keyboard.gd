tool
extends Reference
const Key = preload("Key.gd")
const KeyboardMetadata = preload("KeyboardMetadata.gd")

var meta = KeyboardMetadata.new()
var keys = []

func get_class():
	return "Keyboard"

func is_class(type):
	return type == get_class() or .is_class(type)