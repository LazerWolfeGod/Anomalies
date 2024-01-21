extends TileMap

var menuopen = false
const movespeed = 2000
const scalesize = 1.1

var tileinfo: Array = []
var tile_high_light = Vector2i.ZERO
var rng = RandomNumberGenerator.new()
var player
var menu


const atlas_key = {
	Vector2i(-1,-1):"None",
	Vector2i(0,0):"Forest",
	Vector2i(1,0):"Rock",
	Vector2i(2,0):"City",
	Vector2i(3,0):"Water",
	Vector2i(4,0):"Meadow",
	Vector2i(3,1):"Core",
}

const tile_init_data = {
	"Forest":{"Wood":true,"Max_Structures":[1,2],"Possible_Structures":["House","Farm","Lumber Mill"]},
	"Rock":{"Metal":true,"Max_Structures":[3,4,5],"Possible_Structures":["Mines"]},
	"City":{"Population":10,"Max_Population":100,"Max_Structures":[3],"Possible_Structures":["House"]},
	"Water":{"Water":true,"Max_Structures":[0]},
	"Meadow":{"Food":true,"Max_Structures":[3],"Possible_Structures":["House","Farm","Wind Turbine"]},
	"Core":{"Structures":[{"Name":"Core","Level":1,"Owner":"Player","Upkeep":{},"Output":{"Wood":1,"Water":2,"Food":1,"Max_Wood":15,"Max_Water":10,"Max_Food":5,"Max_Energy":10,"Max_Population":3}}]},
	"None":{}
}

func gen_tile_dict(pos):
	var atlas_cords = get_cell_atlas_coords(0,pos)
	var tile_type = atlas_key[atlas_cords]
	var tile_dict = {
		"Map_Pos":pos,
		"Tile":"None",
		"Atlas_Cords":atlas_cords,
		"Population":0,
		"Max_Population":0,
		"Owner":"None",
		"Player_Owned":false,
		"Player_Accessible":false,
		"Wood":false,
		"Water":false,
		"Metal":false,
		"Food":false,
		"Corruption":0,
		"Max_Structures":0,
		"Structures":[],
		"Possible_Structures": []
	}
	tile_dict["Tile"] = tile_type
	for a in tile_init_data[tile_type]:
		var val = tile_init_data[tile_type][a]
		if a == "Max_Structures":
			val = ranchoice(val)
		tile_dict[a] = val
	return tile_dict

func update_tile_data():
	for y in range(len(tileinfo)):
		for x in range(len(tileinfo[y])):
			var around = get_surrounding_cells(Vector2i(x,y))
			set_cell(2,Vector2(x,y),2,Vector2i(-1,-1))
			if len(tileinfo[y][x]["Structures"]) > 0:
				if tileinfo[y][x]["Structures"][0]["Owner"] == "Player":
					tileinfo[y][x]["Player_Owned"] = true
					tileinfo[y][x]["Player_Accessible"] = true
			if tileinfo[y][x]["Player_Owned"]:
				set_cell(2,Vector2(x,y),2,Vector2i(4,1))
				for p in around:
					tileinfo[p.y][p.x]["Player_Accessible"] = true
	var resources = player.calc_resources(tileinfo)
	$"../Game_Gui".UpdateGui(resources)

func ranchoice(lis):
	var ran = rng.randi_range(0,len(lis)-1)
	return lis[ran]
	
func _ready():
	for y in range(get_used_rect().size.y):
		tileinfo.append([])
		for x in range(get_used_rect().size.x):
			tileinfo[-1].append(gen_tile_dict(Vector2i(x,y)))

	var player_scene = load("res://Scenes/player.tscn")
	player = player_scene.instantiate()
	add_sibling(player)
	update_tile_data()

func _process(delta):
	move(delta)
	highlight()
	if menuopen:
		var check = menu.get_buying()
		if check[0]:
			var can_buy = true
			var tile = tileinfo[menu.data["Map_Pos"].y][menu.data["Map_Pos"].x]
			if tile["Structures"].size() == tile["Max_Structures"]:
				can_buy = false
			for mat in menu.structures[check[1]][0]["Cost"]:
				if menu.structures[check[1]][0]["Cost"][mat]>player.resources[mat]["Amount"]:
					can_buy = false
			if can_buy:
				add_structure(menu.data["Map_Pos"],check[1])
				for mat in menu.structures[check[1]][0]["Cost"]:
					player.resources[mat]["Amount"] -= menu.structures[check[1]][0]["Cost"][mat]
				
				update_tile_data()
				player.calc_resources(tileinfo)
				$"../Game_Gui".UpdateGui(player.resources)
				menu.refresh_current_list()
	
	
	
func move(delta):
	var tempmovespeed = movespeed
	if Input.is_action_pressed("Sprint"): tempmovespeed*=3
	
	if Input.is_action_pressed("Move_Camera_Left"):
		position.x+=tempmovespeed*delta*scale.x
	if Input.is_action_pressed("Move_Camera_Right"):
		position.x-=tempmovespeed*delta*scale.x
	if Input.is_action_pressed("Move_Camera_Up"):
		position.y+=tempmovespeed*delta*scale.y
	if Input.is_action_pressed("Move_Camera_Down"):
		position.y-=tempmovespeed*delta*scale.y
	
	if Input.is_action_just_released("Zoom_In"):
		position-=get_viewport_rect().size*(scalesize-1)*((get_viewport().get_mouse_position()-position)/get_viewport_rect().size)
		scale*=1.1
	elif Input.is_action_just_released("Zoom_Out"):
		position+=get_viewport_rect().size*(1-1/scalesize)*((get_viewport().get_mouse_position()-position)/get_viewport_rect().size)
		scale/=1.1
		
func highlight():
	if not menuopen:
		var clicked_pos = get_global_mouse_position()
		var map_pos = local_to_map(to_local(clicked_pos))
		if get_cell_atlas_coords(0,map_pos) != Vector2i(-1,-1):
			if map_pos != tile_high_light:
				set_cell(1,tile_high_light,2,Vector2i(-1,-1))
				tile_high_light = map_pos
				set_cell(1,tile_high_light,0,Vector2i(0,0))
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if not menuopen:
				var clicked_pos = event.position
				var map_pos = local_to_map(to_local(clicked_pos))
				if get_cell_atlas_coords(0,map_pos) != Vector2i(-1,-1):
					update_tile_data()
					var data = get_cell_tile_data(0,map_pos)
					var menu_scene = load("res://Scenes/Hex_Menu.tscn")
					menu = menu_scene.instantiate()
					add_sibling(menu)
					get_used_rect()
					
					menu.ready(tileinfo[map_pos.y][map_pos.x])
					menuopen = true
					set_layer_modulate(1,Color(1,1,1,0.9))

func add_structure(pos,structure):
	tileinfo[pos.y][pos.x]["Structures"].append({
		"Name":structure,"Level":1,"Owner":"Player",
		"Upkeep":menu.structures[structure][0]["Upkeep"],
		"Output":menu.structures[structure][0]["Output"]})

func shutmenu():
	menuopen = false
	set_layer_modulate(1,Color(1,1,1,0.5))
			


func _on_timer_timeout():
	player.pass_time()
	$"../Game_Gui".UpdateGui(player.resources)
