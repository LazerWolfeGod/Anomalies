extends Control

const image_files = {
	"Wood":{"Image":"res://Assets/GUI/Resources/Wood.png","Scale":Vector2(0.5,0.5),"Text_Pos":Vector2(108,60)},
	"Rock":{"Image":"res://Assets/GUI/Resources/Stone.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(115,60)},
	"Metal":{"Image":"res://Assets/GUI/Resources/Metal.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(115,60)},

	"House":{"Image":"res://Assets/GUI/Structure Icons/house.png"},
	"Farm":{"Image":"res://Assets/GUI/Structure Icons/farm.png"},
	"Lumber Mill":{"Image":"res://Assets/GUI/Structure Icons/axe.png"},
	"Wind Turbine":{"Image":"res://Assets/GUI/Structure Icons/Windmill.png"},
	"Pump":{"Image":"res://Assets/GUI/Structure Icons/bigger_pump.png"},
	"Storage":{"Image":"res://Assets/GUI/Structure Icons/crate_icon.png"},
	"Mines":{"Image":"res://Assets/GUI/Structure Icons/mine.png"}
}

var button_pressed = false
var added_nodes = []
var tile

func set_info(mats,Name):
	tile = Name
	#var xpos = 0
	#for mat in mats:
		#make_sprite(mat,xpos,0,mats[mat],$".")
		#xpos+=1
	
	var mat_image_scene = load("res://Scenes/material_display.tscn")
	var mat_images = mat_image_scene.instantiate()
	add_child(mat_images)
	mat_images.set_info(mats,Vector2(100,60))
	
	
	$Name.text = Name
	
	var sprite = Sprite2D.new()
	sprite.texture = load(image_files[tile]["Image"])
	sprite.scale = Vector2(0.2,0.2)
	sprite.position = Vector2(40,54)
	add_child(sprite)
	added_nodes.append(sprite)

#func make_sprite(image,x,y,val,node):
	#var sprite = Sprite2D.new()
	#sprite.texture = load(image_files[image]["Image"])
	#sprite.scale = image_files[image]["Scale"]
	#sprite.position = Vector2(100,60)+Vector2(x*50,y*80)
	#node.add_child(sprite)
	#added_nodes.append(sprite)
	#
	#var text = Label.new()
	#text.text = str(val) 
	#text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#text.position = image_files[image]["Text_Pos"]+Vector2(x*50,y*80)
	#node.add_child(text)
	#added_nodes.append(text)


func _on_structure_outline_button_down():
	button_pressed = true


func _on_structure_outline_button_up():
	button_pressed = false
