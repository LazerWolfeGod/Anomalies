extends Control

var tile_accessible = false
var tile_owned = false
var data

const atlas_dict = {
	"Wind Turbine":Vector2i(0,0),
	"Farm":Vector2i(1,0),
	"Lumber Mill":Vector2i(2,0),
	"Mines":Vector2i(3,0),
	"Pump":Vector2i(6,0),
	"Core":Vector2i(4,0),
	"House":Vector2i(4,0),
	"None":Vector2i(5,0)
}
var inverse_atlas_dict = {}
var block_buying = true

const image_files = {
	"Wood":"res://Assets/GUI/Wood.png",
	"Rock":"res://Assets/GUI/Stone.png",
	"Metal":"res://Assets/GUI/metal.png"
}


func _process(delta):
	if Input.is_action_just_pressed("Back"):
		exit()

func get_buying():
	var map_pos = $Buildable/Structure_List/Structure_List.local_to_map($Buildable/Structure_List/Structure_List.to_local(get_viewport().get_mouse_position()))
	var atlas_pos = $Buildable/Structure_List/Structure_List.get_cell_atlas_coords(0,map_pos)
	if atlas_pos != Vector2i(-1,-1):
		if Input.is_action_just_pressed("Click") and not block_buying:
			return [true,inverse_atlas_dict[atlas_pos]]
		if not Input.is_action_pressed("Click"):
			block_buying = false
	return [false,false]

func exit():
	$"../".shutmenu()
	queue_free()


func _on_button_button_down():
	exit()
	
func ready(d):
	data = d
	for a in atlas_dict:
		inverse_atlas_dict[atlas_dict[a]] = a
	tile_accessible = data["Player_Accessible"]
	tile_owned = data["Player_Owned"]
	
	$Buildable/Hex_Display.set_cell(0,Vector2i(0,0),data["Atlas_Id"],data["Atlas_Cords"])

	$not_owned_panel.hide()
	$Buildable.hide()
	if not tile_accessible:
		$not_owned_panel.show()
		$not_owned_panel/Hex_Label.text = data["Tile"]+" Tile"
	else:
		$Buildable.show()
		$Buildable/Hex_Display/Hex_Label.text = data["Tile"]+" Tile"
		
	refresh()

var sprites = []

func refresh():
	refresh_structure_list()
	refresh_current_list()
	
func refresh_structure_list():
	var available = data["Possible_Structures"]
	for y in range(5):
		$Buildable/Structure_List/Structure_List.set_cell(0,Vector2i(0,y),0,atlas_dict["None"])
	for y in range(available.size()):
		$Buildable/Structure_List/Structure_List.set_cell(0,Vector2i(0,y),0,atlas_dict[available[y]["Name"]])
		var xpos = 0
		for mat in available[y]["Cost"]:
			make_sprite(mat,xpos,y,available[y]["Cost"][mat])
			xpos+=1

func refresh_current_list():
	for y in range(data["Max_Structures"]):
		$Buildable/Built_List/Structure_List.set_cell(0,Vector2i(fmod(y,2),int(y/2)),0,atlas_dict["None"])
	for y in range(data["Structures"].size()):
		$Buildable/Built_List/Structure_List.set_cell(0,Vector2i(fmod(y,2),int(y/2)),0,atlas_dict[data["Structures"][y]["Name"]])
		
	
	
func make_sprite(image,x,y,val):
	var sprite = Sprite2D.new()
	sprite.texture = load(image_files[image])
	sprite.scale = Vector2(0.5,0.5)
	sprite.position = Vector2(105,40)+$Buildable/Structure_List/Structure_List.position+Vector2(x*50,y*80)
	$Buildable/Structure_List.add_child(sprite)
	
	var text = Label.new()
	text.text = str(val)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.position = Vector2(115,40)+$Buildable/Structure_List/Structure_List.position+Vector2(x*50,y*80)
	$Buildable/Structure_List.add_child(text)
	
