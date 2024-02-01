extends Control


const image_files = {
	"Wood":{"Image":"res://Assets/GUI/Resources/Wood.png","Scale":Vector2(0.5,0.5),"Text_Pos":Vector2(8,0)},
	"Rock":{"Image":"res://Assets/GUI/Resources/Stone.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(15,0)},
	"Metal":{"Image":"res://Assets/GUI/Resources/Metal.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(15,0)},
	"Water":{"Image":"res://Assets/GUI/Resources/Water.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(15,0)},
	"Food":{"Image":"res://Assets/GUI/Resources/Food.png","Scale":Vector2(0.2,0.2),"Text_Pos":Vector2(25,0)},
	"Population":{"Image":"res://Assets/GUI/Resources/Cat.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(15,0)},
	
	"Max_Population":{"Image":"res://Assets/GUI/Resources/Cat.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(15,0)},
	
	"No_Image":{"Image":"res://Assets/GUI/Resources/Cat.png","Scale":Vector2(0.4,0.4),"Text_Pos":Vector2(15,0)},
	

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

func set_info(mats,offset_pos):
	var xpos = 0
	for mat in mats:
		make_sprite(mat,xpos,0,mats[mat],$".",offset_pos)
		xpos+=1
	
	#var sprite = Sprite2D.new()
	#sprite.texture = load(image_files[tile]["Image"])
	#sprite.scale = Vector2(0.2,0.2)
	#sprite.position = Vector2(40,54)
	#add_child(sprite)
	#added_nodes.append(sprite)

func make_sprite(image,x,y,val,node,offset_pos):
	var sprite = Sprite2D.new()
	if not image in image_files: image = "No_Image"
	sprite.texture = load(image_files[image]["Image"])
	sprite.scale = image_files[image]["Scale"]
	sprite.position = offset_pos+Vector2(x*50,y*80)
	node.add_child(sprite)
	added_nodes.append(sprite)
	
	var text = Label.new()
	text.text = str(val) 
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.position = offset_pos+image_files[image]["Text_Pos"]+Vector2(x*50,y*80)
	node.add_child(text)
	added_nodes.append(text)
