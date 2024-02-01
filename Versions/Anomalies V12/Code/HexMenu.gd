extends Control

var tile_accessible = false
var tile_owned = false
var data
var upgrade_button_clicked = false

const atlas_dict = {
	"Corrupt Core":Vector2i(4,0),
	"Core":Vector2i(4,0),
	"Corruption":Vector2i(5,0),
	
	"Wind Turbine":Vector2i(0,0),
	"Farm":Vector2i(1,0),
	"Lumber Mill":Vector2i(2,0),
	"Mines":Vector2i(3,0),
	"House":Vector2i(4,0),
	"None":Vector2i(5,0),
	
	"Storage":Vector2i(0,1),
	"Pump":Vector2i(1,1),
	"Metallurgy":Vector2i(2,1),
	"Rock Crusher":Vector2i(3,1),
	"Military":Vector2i(4,1)
}
var inverse_atlas_dict = {}
var block_buying = true
var structures
var added_nodes = []

const image_files = {
	"Wood":"res://Assets/GUI/Resources/Wood.png",
	"Rock":"res://Assets/GUI/Resources/Stone.png",
	"Metal":"res://Assets/GUI/Resources/Metal.png"
}
var data_info = {
	"Upkeep":{"Pos":Vector2(50,340)},
	"Output":{"Pos":Vector2(50,420)}
}

const Id = "Player"


func _process(delta):
	if Input.is_action_just_pressed("Back"):
		exit()
	if $Buildable/Upgrade_Menu.tick_pressed:
		upgrade_button_clicked = true

func get_buying():
	if tile_accessible:
		if not tile_owned:
			for b in added_nodes:
				if b.button_pressed:
					b.button_pressed = false
					return [true,b.tile]
			#var map_pos = $Buildable/Structure_List/Structure_List.local_to_map($Buildable/Structure_List/Structure_List.to_local(get_viewport().get_mouse_position()))
			#var atlas_pos = $Buildable/Structure_List/Structure_List.get_cell_atlas_coords(0,map_pos)
			#if atlas_pos != Vector2i(-1,-1):
				#if Input.is_action_just_pressed("Click") and not block_buying:
					#return [true,inverse_atlas_dict[atlas_pos]]
				#if not Input.is_action_pressed("Click"):
					#block_buying = false
		elif tile_owned:
			if upgrade_button_clicked and data["Structure"]["Level"]<structures[data["Structure"]["Name"]].size():
				var st = data["Structure"]["Name"]+"_"+str(data["Structure"]["Level"]+1)
				upgrade_button_clicked = false
				return [true,st]
			upgrade_button_clicked = false
	return [false,false]

func bought():
	for n in added_nodes:
		n.queue_free()
	added_nodes = []
	ready(data,structures)

func exit():
	$"../".shutmenu()
	queue_free()


func _on_button_button_down():
	exit()
	
func ready(d,strucs):
	structures = strucs
	data = d
	for a in atlas_dict:
		inverse_atlas_dict[atlas_dict[a]] = a
	tile_accessible = data["AccessibleTo"][Id]
	tile_owned = data["Owner"] == Id
	
	$Buildable/Owned/Hex_Display.set_cell(0,Vector2i(0,0),data["Atlas_Id"],data["Atlas_Cords"])

	$not_owned_panel.hide()
	$Buildable.hide()
	if not tile_accessible and not tile_owned:
		$not_owned_panel.show()
		$not_owned_panel/Hex_Label.text = data["Tile"]+" Tile"
	else:
		$Buildable.show()
		$Buildable/Structure_List.hide()
		$Buildable/Owned.hide()
		$Buildable/Upgrade_Menu.hide()
		if tile_owned:
			$Buildable/Owned.show()
			$Buildable/Owned/Hex_Label.text = "Level "+str(data["Structure"]["Level"])+" "+data["Structure"]["Name"]   # data["Tile"]+" Tile"
			#$"Buildable/Owned/Structure Name".text = "Level "+str(data["Structure"]["Level"])+" "+data["Structure"]["Name"]
		else:
			$Buildable/Structure_List.show()
		
		refresh()

var sprites = []

func refresh():
	if tile_owned: refresh_current_list()
	elif tile_accessible: refresh_structure_list()
	
func refresh_structure_list():
	var available = data["Possible_Structures"]
	for i in added_nodes:
		i.queue_free()
	added_nodes = []
	#for y in range(5):
		#$Buildable/Structure_List/Structure_List.set_cell(0,Vector2i(0,y),0,atlas_dict["None"])
	for y in range(available.size()):
		var segment_scene = load("res://Scenes/hex_menu_struc_display.tscn")
		var segment = segment_scene.instantiate()
		$Buildable/Structure_List/Seperator.add_child(segment)
		added_nodes.append(segment)
		segment.set_info(structures[available[y]][0]["Cost"],available[y])
	$Buildable/Structure_List/Seperator.size.y = 100*added_nodes.size()
		
		#$Buildable/Structure_List/Structure_List.set_cell(0,Vector2i(0,y),0,atlas_dict[available[y]])
		#var xpos = 0
		#for mat in structures[available[y]][0]["Cost"]:
			#make_sprite(mat,xpos,y,structures[available[y]][0]["Cost"][mat],"Buildable/Structure_List/")
			#xpos+=1

func refresh_current_list():
	$Buildable/Owned/Structure_List.set_cell(0,Vector2i(fmod(0,2),int(0/2)),0,atlas_dict["None"])
	if not(data["Structure"] is String):
		$Buildable/Owned/Structure_List.set_cell(0,Vector2i(fmod(0,2),int(0/2)),0,atlas_dict[data["Structure"]["Name"]])
	$Buildable/Owned/Description.text = data["Structure"]["Description"]
	
	for d in data_info:
		var mat_image_scene = load("res://Scenes/material_display.tscn")
		var mat_images = mat_image_scene.instantiate()
		$Buildable/Owned.add_child(mat_images)
		mat_images.set_info(data["Structure"][d],data_info[d]["Pos"])
		
		#var xpos = 0
		#var cost = {}
		#if data["Structure"]["Level"]<len(structures[data["Structure"]["Name"]]): cost = structures[data["Structure"]["Name"]][data["Structure"]["Level"]]["Cost"]
		#for mat in cost:
			#make_sprite(mat,xpos,0,cost[mat],"Buildable/Owned/")
			#xpos+=1
	
	
#func make_sprite(image,x,y,val,path):
	#var sprite = Sprite2D.new()
	#sprite.texture = load(image_files[image])
	#sprite.scale = Vector2(0.5,0.5)
	#sprite.position = Vector2(105,40)+get_node(path+"Structure_List").position+Vector2(x*50,y*80)
	#get_node(path).add_child(sprite)
	#added_nodes.append(sprite)
	#
	#var text = Label.new()
	#text.text = str(val) 
	#text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#text.position = Vector2(115,40)+get_node(path+"Structure_List").position+Vector2(x*50,y*80)
	#get_node(path).add_child(text)
	#added_nodes.append(text)
	
func _on_upgrade_button_down():
	$Buildable/Upgrade_Menu.show()
	var upgrade = structures[data["Structure"]["Name"]][data["Structure"]["Level"]]
	$Buildable/Upgrade_Menu.set_info(upgrade,true,atlas_dict)
	#upgrade_button_clicked = true


func _on_downgrade_button_down():
	pass
