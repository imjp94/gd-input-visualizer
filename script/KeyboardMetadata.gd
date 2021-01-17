tool
extends Reference

var author = ""
var backcolor = "#eeeeee"
var background = null
var name = ""
var notes = ""
var radii = ""
var switchBrand = ""
var switchMount = ""
var switchType = ""


func get_class():
	return "KeyboardMetadata"

func is_class(type):
	return type == get_class() or .is_class(type)