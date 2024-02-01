extends Control

var gui_elements = ["Wood","Water","Population","Metal","Rock","Energy","Food"]
var flipped = false

func _process(_delta):
	if not flipped: $TextureProgressBar.value+=1
	else: $TextureProgressBar.value-=1
	
	if $TextureProgressBar.value>=100: flipped = true
	elif $TextureProgressBar.value<=0: flipped = false

func UpdateGui(resources):
	for r in resources:
		if r in gui_elements:
			get_node("Top_Bar/"+r+"/Amount").text = str(resources[r]["Amount"])+"/"+str(resources[r]["Max"])
			var st = str(resources[r]["Change"])
			get_node("Top_Bar/"+r+"/Change").set("theme_override_colors/font_color",Color(1,0,0,1))
			if resources[r]["Change"]>0:
				st = '+'+st
				get_node("Top_Bar/"+r+"/Change").set("theme_override_colors/font_color",Color(0,1,0,1))
			
			get_node("Top_Bar/"+r+"/Change").text = st
