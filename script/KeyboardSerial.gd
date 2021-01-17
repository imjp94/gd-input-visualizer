tool
extends Reference
const Key = preload("Key.gd")
const KeyboardMetadata = preload("KeyboardMetadata.gd")
const Keyboard = preload("Keyboard.gd")

# Map from serialized label position to normalized position,
# depending on the alignment flags.
const label_map = [
  #0  1  2  3  4  5  6  7  8  9 10 11   # align flags
  [ 0, 6, 2, 8, 9,11, 3, 5, 1, 4, 7,10], # 0 = no centering
  [ 1, 7,-1,-1, 9,11, 4,-1,-1,-1,-1,10], # 1 = center x
  [ 3,-1, 5,-1, 9,11,-1,-1, 4,-1,-1,10], # 2 = center y
  [ 4,-1,-1,-1, 9,11,-1,-1,-1,-1,-1,10], # 3 = center x & y
  [ 0, 6, 2, 8,10,-1, 3, 5, 1, 4, 7,-1], # 4 = center front (default)
  [ 1, 7,-1,-1,10,-1, 4,-1,-1,-1,-1,-1], # 5 = center front & x
  [ 3,-1, 5,-1,10,-1,-1,-1, 4,-1,-1,-1], # 6 = center front & y
  [ 4,-1,-1,-1,10,-1,-1,-1,-1,-1,-1,-1], # 7 = center front & x & y
]


static func copy(o):
	if not o:
		return o
	if not(o is Object):
		if o is Dictionary:
			return o.duplicate(true)
		elif o is Array:
			return o.duplicate(true)
		return o
	elif o is Resource:
		return o.duplicate(true)
	elif o is Key:
		var new_key = Key.new()
		for prop in o.get_property_list():
			# if prop.name == "x":
			# 	printt(prop.name, copy(o.get(prop.name)))
			new_key.set(prop.name, copy(o.get(prop.name)))
		return new_key
	push_error(str("Unexpected object ", o.get_class()))
	assert(false)


static func reorder_labels_in(labels, align):
	var ret = []
	ret.resize(label_map.size())
	for i in range(labels.size()):
		if labels[i]:
			ret[label_map[align][i]] = labels[i]
	return ret

static func deserialize(rows):
	if not (rows is Array):
		print("Expected array of objects")
		return

	var current = Key.new()
	var kbd = Keyboard.new()
	var align = 4

	for r in range(rows.size()):
		if rows[r] is Array:
			for k in range(rows[r].size()):
				var item = rows[r][k]
				if item is String:
					var new_key = copy(current)

					# Calculate generated values
					new_key.width2 = current.width if new_key.width2 == 0 else current.width2
					new_key.height2 = current.height if new_key.height2 == 0 else current.height2
					new_key.labels = reorder_labels_in(item.split("\n"), align)
					new_key.textSize = reorder_labels_in(new_key.textSize, align)

					# Clean up data
					for i in range(12):
						if i < new_key.labels.size():
							if not new_key.labels[i]:
								if i < new_key.textSize.size():
									new_key.textSize.remove(i)
								if i < new_key.textColor.size():
									new_key.textColor.remove(i)
						if i < new_key.textSize.size():
							if new_key.textSize[i] == new_key.default.textSize:
								new_key.textSize.remove(i)
						if i < new_key.textColor.size():
							if new_key.textColor[i] == new_key.default.textColor:
								new_key.textColor.remove(i)

					# Add key
					kbd.keys.push_back(new_key)

					current.x += current.width
					current.width = 1
					current.height = 1
					current.x2 = 0
					current.y2 = 0
					current.width2 = 0
					current.height2 = 0
					current.nub = false
					current.stepped = false
					current.decal = false
				else:
					if k != 0 and (item.get("r") != null || item.get("rx") != null || item.get("ry") != null):
						print("rotation can only be specified on the first key in a row: ", item)
					if item.get("r") != null:
						current.rotation_angle = item.r
					if item.get("rx") != null:
						current.rotation_x = item.rx
					if item.get("ry") != null:
						current.rotation_y = item.ry
					if item.get("a") != null:
						align = item.a
					if item.get("f"):
						current.default.textSize = item.f
						current.textSize = []
					if item.get("f2"):
						for i in range(12):
							current.textSize[i] = item.f2
					if item.get("fa"):
						current.textSize = item.fa
					if item.get("p"):
						current.profile = item.p
					if item.get("c"):
						current.color = item.c
					if item.get("t"):
						var split = item.t.split("\n")
						if not split[0].empty():
							current.default.textColor = split[0]
						current.textColor = reorder_labels_in(split, align)
					if item.get("x"): 
						current.x += item.x
					if item.get("y"): 
						current.y += item.y
					if item.get("w"): 
						current.width = item.w
						current.width2 = item.w
					if item.get("h"): 
						current.height = item.h
						current.height2 = item.h
					if item.get("x2"): 
						current.x2 = item.x2
					if item.get("y2"): 
						current.y2 = item.y2
					if item.get("w2"): 
						current.width2 = item.w2
					if item.get("h2"): 
						current.height2 = item.h2
					if item.get("n"): 
						current.nub = item.n
					if item.get("l"): 
						current.stepped = item.l
					if item.get("d"): 
						current.decal = item.d
					if item.get("g") != null: 
						current.ghost = item.g
					if item.get("sm"): 
						current.sm = item.sm
					if item.get("sb"): 
						current.sb = item.sb
					if item.get("st"): 
						current.st = item.st
				
			# End of the row
			current.y += 1
			current.x = current.rotation_x
		elif rows[r] is Object:
			if r != 0:
				print("keyboard metadata must the be first element", rows[r])
			
			for prop in kbd.meta:
				if rows[r][prop]:
					kbd.meta[prop] = rows[r][prop]
		else:
			print("unexpected", rows[r])
	return kbd

static func parse(json):
	var src_json = JSON.parse(json)
	if src_json.error != OK:
		print("Error parsing json at %d: %s" % [src_json.error_line, src_json.error_string])
		return null
	return deserialize(src_json.result)
