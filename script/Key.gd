@tool
class_name KeyboardKey
extends RefCounted

var color = "#cccccc"
var labels = []
var textColor = []
var textSize = []
var default = {
	"textColor": "#000000",
	"textSize": 3
}
var x = 0
var y = 0
var width = 1
var height = 1
var x2 = 0
var y2 = 0
var width2 = 1
var height2 = 1
var rotation_x = 0
var rotation_y = 0
var rotation_angle = 0
var decal = false
var ghost = false
var stepped = false
var nub = false
var profile = ""
var sm = "" 
var sb = ""
var st = ""


func get_rect():
	return Rect2(x, y, width, height)
