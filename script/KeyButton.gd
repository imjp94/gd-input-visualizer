extends Button

var unit_sizes = {
		"px" : {
			"unit" : 54,
			"strokeWidth": 1,
			"" : { "profile": "" , "keySpacing": 0, "bevelMargin": 6, "bevelOffsetTop": 3, "bevelOffsetBottom": 3, "padding": 3, "roundOuter": 5, "roundInner": 3 },
			"DCS" : { "profile": "DCS", "keySpacing": 0, "bevelMargin": 6, "bevelOffsetTop": 3, "bevelOffsetBottom": 3, "padding": 3, "roundOuter": 5, "roundInner": 3 },
			"DSA" : { "profile": "DSA", "keySpacing": 0, "bevelMargin": 6, "bevelOffsetTop": 0, "bevelOffsetBottom": 0, "padding": 3, "roundOuter": 5, "roundInner": 8 },
			"SA" :  { "profile": "SA", "keySpacing": 0, "bevelMargin": 6, "bevelOffsetTop": 2, "bevelOffsetBottom": 2, "padding": 3, "roundOuter": 5, "roundInner": 5 },
			"CHICKLET" :  { "profile": "CHICKLET", "keySpacing": 3, "bevelMargin": 1, "bevelOffsetTop": 0, "bevelOffsetBottom": 2, "padding": 4, "roundOuter": 4, "roundInner": 4 },
			"FLAT" : { "profile": "FLAT" , "keySpacing": 1, "bevelMargin": 1, "bevelOffsetTop": 0, "bevelOffsetBottom": 0, "padding": 4, "roundOuter": 5, "roundInner": 3 },
		},
		"mm" : {
			"unit": 19.05,
			"strokeWidth": 0.20,
			"" : {  "profile": "" , "keySpacing": 0.4445, "bevelMargin": 3.1115, "padding": 0, "roundOuter": 1.0, "roundInner": 2.0 },
			"DCS" : {  "profile": "DCS", "keySpacing": 0.4445, "bevelMargin": 3.1115, "padding": 0, "roundOuter": 1.0, "roundInner": 2.0 },
			"DSA" : {  "profile": "DSA", "keySpacing": 0.4445, "bevelMargin": 3.1115, "padding": 0, "roundOuter": 1.0, "roundInner": 2.0 },
			"SA" : {  "profile": "SA", "keySpacing": 0.4445, "bevelMargin": 3.1115, "padding": 0, "roundOuter": 1.0, "roundInner": 2.0 },
			"CHICKLET" : {  "profile": "CHICKLET", "keySpacing": 0.4445, "bevelMargin": 3.1115, "padding": 0, "roundOuter": 1.0, "roundInner": 2.0 },
			"FLAT" : {  "profile": "FLAT" , "keySpacing": 0.4445, "bevelMargin": 3.1115, "padding": 0, "roundOuter": 1.0, "roundInner": 2.0 },
		}
	}

func _init():
	for unit in ["px","mm"]:
		for profile in ["","DCS","DSA","SA","CHICKLET","FLAT"]:
			unit_sizes[unit][profile].unit = unit_sizes[unit].unit
			unit_sizes[unit][profile].strokeWidth = unit_sizes[unit].strokeWidth
		unit_sizes[unit].OEM = unit_sizes[unit].DCS

func get_profile(key):
	var regex = RegEx.new()
	regex.compile("\b(SA|DSA|DCS|OEM|CHICKLET|FLAT)\b")
	var result = regex.search_all(key.profile)
	return result.get_string(0) if not result.is_empty() else ""

func get_render_params(key, sizes):
	var parms = {}

	parms.jShaped = (key.width != key.width2) || (key.height != key.height2) || key.x2 || key.y2

	# Overall dimensions of the unit square(s) that the cap occupies
	parms.capwidth   = sizes.unit * key.width;
	parms.capheight  = sizes.unit * key.height;
	parms.capx       = sizes.unit * key.x;
	parms.capy       = sizes.unit * key.y;
	if parms.jShaped:
		parms.capwidth2  = sizes.unit * key.width2;
		parms.capheight2 = sizes.unit * key.height2;
		parms.capx2      = sizes.unit * (key.x + key.x2);
		parms.capy2      = sizes.unit * (key.y + key.y2);


	# Dimensions of the outer part of the cap
	parms.outercapwidth   = parms.capwidth   - sizes.keySpacing*2;
	parms.outercapheight  = parms.capheight  - sizes.keySpacing*2;
	parms.outercapx       = parms.capx       + sizes.keySpacing;
	parms.outercapy       = parms.capy       + sizes.keySpacing;
	if parms.jShaped:
		parms.outercapy2      = parms.capy2      + sizes.keySpacing;
		parms.outercapx2      = parms.capx2      + sizes.keySpacing;
		parms.outercapwidth2  = parms.capwidth2  - sizes.keySpacing*2;
		parms.outercapheight2 = parms.capheight2 - sizes.keySpacing*2;

	# Dimensions of the top of the cap
	parms.innercapwidth   = parms.outercapwidth   - sizes.bevelMargin*2;
	parms.innercapheight  = parms.outercapheight  - sizes.bevelMargin*2 - (sizes.bevelOffsetBottom-sizes.bevelOffsetTop);
	parms.innercapx       = parms.outercapx       + sizes.bevelMargin;
	parms.innercapy       = parms.outercapy       + sizes.bevelMargin - sizes.bevelOffsetTop;
	if parms.jShaped:
		parms.innercapwidth2  = parms.outercapwidth2  - sizes.bevelMargin*2;
		parms.innercapheight2 = parms.outercapheight2 - sizes.bevelMargin*2;
		parms.innercapx2      = parms.outercapx2      + sizes.bevelMargin;
		parms.innercapy2      = parms.outercapy2      + sizes.bevelMargin - sizes.bevelOffsetTop;

	# Dimensions of the text part of the cap
	parms.textcapwidth   = parms.innercapwidth   - sizes.padding*2;
	parms.textcapheight  = parms.innercapheight  - sizes.padding*2;
	parms.textcapx       = parms.innercapx       + sizes.padding;
	parms.textcapy       = parms.innercapy       + sizes.padding;

	parms.darkColor = key.color;
	parms.lightColor = str("#", Color(key.color).lightened(0.8).to_html(false))

	# Rotation matrix about the origin
	parms.origin_x = sizes.unit * key.rotation_x;
	parms.origin_y = sizes.unit * key.rotation_y;
	# TODO
	# var mat = Math.transMatrix(parms.origin_x, parms.origin_y).mult(Math.rotMatrix(key.rotation_angle)).mult(Math.transMatrix(-parms.origin_x, -parms.origin_y));

	# Construct the *eight* corner points, transform them, and determine the transformed bbox.
	parms.rect = { "x":parms.capx, "y":parms.capy, "w":parms.capwidth, "h":parms.capheight, "x2":parms.capx+parms.capwidth, "y2":parms.capy+parms.capheight };
	parms.rect2 = { "x":parms.capx2, "y":parms.capy2, "w":parms.capwidth2, "h":parms.capheight2, "x2":parms.capx2+parms.capwidth2, "y2":parms.capy2+parms.capheight2 } if parms.jShaped else parms.rect;
	parms.bbox = { "x":9999999, "y":9999999, "x2":-9999999, "y2":-9999999 };
	var corners = [
		{"x":parms.rect.x, "y":parms.rect.y},
		{"x":parms.rect.x, "y":parms.rect.y2},
		{"x":parms.rect.x2, "y":parms.rect.y},
		{"x":parms.rect.x2, "y":parms.rect.y2}
	];
	if parms.jShaped: 
		corners.push_back({"x":parms.rect2.x, "y":parms.rect2.y})
		corners.push_back({"x":parms.rect2.x, "y":parms.rect2.y2})
		corners.push_back({"x":parms.rect2.x2, "y":parms.rect2.y})
		corners.push_back({"x":parms.rect2.x2, "y":parms.rect2.y2})
	for i in range(corners.size()):
		# corners[i] = mat.transformPt(corners[i]);
		parms.bbox.x = min(parms.bbox.x, corners[i].x);
		parms.bbox.y = min(parms.bbox.y, corners[i].y);
		parms.bbox.x2 = max(parms.bbox.x2, corners[i].x);
		parms.bbox.y2 = max(parms.bbox.y2, corners[i].y);
	parms.bbox.w = parms.bbox.x2 - parms.bbox.x;
	parms.bbox.h = parms.bbox.y2 - parms.bbox.y;

	return parms;

func render(key):
	var sizes = unit_sizes.px[get_profile(key)] # always in pixels
	var parms = get_render_params(key, sizes);

	# Update the rects & bounding-box of the key (for click-selection purposes)
	key.rect = parms.rect;
	key.rect2 = parms.rect2;
	key.bbox = parms.bbox;

	# Keep an inverse transformation matrix so that we can transform mouse coordinates into key-space.
	# TODO
	# key.mat = Math.transMatrix(parms.origin_x, parms.origin_y).mult(Math.rotMatrix(-key.rotation_angle)).mult(Math.transMatrix(-parms.origin_x, -parms.origin_y));

	# Determine the location of the rotation crosshairs for the key
	key.crosshairs = "none";
	if key.rotation_x || key.rotation_y || key.rotation_angle:
		key.crosshairs_x = parms.origin_x;
		key.crosshairs_y = parms.origin_y;
		key.crosshairs = "block";

	# Generate the HTML
	# return keycap_html(key, sizes, parms, $sanitize, lightenColor);
