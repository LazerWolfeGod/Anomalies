extends Node2D

var menuopen = false

var tileinfo: Array = []
var grid = []
var rng = RandomNumberGenerator.new()
var player
var menu
var tilemap

const map_generator = preload("res://Code/MapGenerator.gd")
var mapgen = map_generator.new()

var structures = {
	"Core":[{"Cost":{},"Upkeep":{},"Output":{"Wood":1,"Water":2,"Food":1,"Max_Wood":15,"Max_Water":10,"Max_Food":5,"Max_Energy":10,"Max_Population":3,"Max_Rock":10}},{},{}],
	"House":[{"Cost":{"Wood":4},"Upkeep":{"Water":1,"Food":1},"Output":{"Max_Population":4}},{},{}],
	"Farm":[{"Cost":{"Wood":6},"Upkeep":{"Water":3,"Population":1},"Output":{"Food":3}},{},{}],
	"Lumber Mill":[{"Cost":{"Wood":8},"Upkeep":{"Population":1},"Output":{"Wood":1}},{},{}],
	"Wind Turbine":[{"Cost":{"Wood":15},"Upkeep":{"Population":1},"Output":{"Energy":2}},{},{}],
	"Pump":[{"Cost":{"Wood":5,"Rock":4},"Upkeep":{"Population":1,"Energy":1},"Output":{"Water":8}},{},{}],
	"Storage":[{"Cost":{"Wood":10,"Rock":8},"Upkeep":{},"Output":{"Max_Energy":20,"Max_Wood":20,"Max_Water":20,"Max_Rock":20,"Max_Metal":20}},{},{}],
	"Mines":[{"Cost":{"Wood":10},"Upkeep":{"Population":2,"Energy":1},"Output":{"Rock":2}},{},{}],
}

var tile_init_data = {
	"Forest":{"Possible_Structures":["House","Farm","Lumber Mill"]},
	"Rock":{"Possible_Structures":["Mines"]},
	"City":{"Possible_Structures":["House"]},
	"Water":{},
	"Meadow":{"Possible_Structures":["House","Farm","Wind Turbine"]},
	"Core":{"Structures":[{"Name":"Core","Level":1,"Owner":"Player","Upkeep":structures["Core"][0]["Upkeep"],"Output":structures["Core"][0]["Output"]}]},
	"Deforest":{"Possible_Structures":["House","Farm","Wind Turbine"]},
	"BigCity":{},
	
	"CorruptTile":{},
	"CorruptRock":{},
	"CorruptCore":{},
	
	"None":{},
	"Overlay":{},
	"Highlight":{}
	
}

func load_map(map):
	if map == "Random":
		grid = mapgen.map_generator(200,150)

func _ready():
	tilemap = $TileMap
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			tilemap.set_tile(grid[y][x],Vector2i(x-grid[y].size()/2,y-grid.size()/2),0)
		
	for s in structures:
		for l in range(structures[s].size()):
			structures[s][l]["Level"] = l+1
			
	
	var player_scene = load("res://Scenes/player.tscn")
	player = player_scene.instantiate()
	add_child(player)
	
	for y in range(tilemap.get_used_rect().size.y):
		tileinfo.append([])
		for x in range(tilemap.get_used_rect().size.x):
			tileinfo[-1].append(gen_tile_dict(Vector2i(x,y)))
			
	refresh()
	
func refresh():
	update_tile_data()
	refresh_possible_structures()
	player.refresh_resources(tileinfo)
	if menuopen: menu.refresh()
	
func gen_tile_dict(pos):
	var tile_type = tilemap.get_tile(pos)
	var tile_dict = {
		"Map_Pos":pos, "Tile":tile_type,"Near_Water":false,
		"Atlas_Cords":tilemap.tile_to_atlas_cords(tile_type),"Atlas_Id":tilemap.tile_to_source_id(tile_type),
		"Owner":"None", "Player_Owned":false, "Player_Accessible":false,
		"Structures":[], "Possible_Structures": []
	}
	for a in tile_init_data[tile_type]:
		var val = tile_init_data[tile_type][a]
		#if a == "Max_Structures":
			#val = ranchoice(val)
		#elif a == "Possible_Structures":
			#var lis = []
			#for s in val:
				#lis.append(structures[s][0].duplicate(true))
				#lis[-1]["Name"] = s
			##if tile_dict["Tile"] != "Water":
				##var around = tilemap.get_surrounding_cells(tile_dict["Map_Pos"])
				##for p in around:
					##if tileinfo[p.y][p.x]["Tile"] == "Water":
						##lis.append(structures["Pump"][0].duplicate(true))
			#val = lis
		tile_dict[a] = val
	return tile_dict

func refresh_possible_structures():
	for y in range(len(tileinfo)):
		for x in range(len(tileinfo[y])):
			var lis = []
			if "Possible_Structures" in tile_init_data[tileinfo[y][x]["Tile"]]:
				for s in tile_init_data[tileinfo[y][x]["Tile"]]["Possible_Structures"]:
					lis.append(structures[s][0].duplicate(true))
					lis[-1]["Name"] = s
			if tileinfo[y][x]["Near_Water"]:
				lis.append(structures["Pump"][0].duplicate(true))
				lis[-1]["Name"] = "Pump"
			tileinfo[y][x]["Possible_Structures"] = lis
			
	
func update_tile_data():
	for y in range(len(tileinfo)):
		for x in range(len(tileinfo[y])):
			var around = tilemap.get_surrounding_cells(Vector2i(x,y))
			tilemap.set_tile("None",Vector2(x,y),2)
			if len(tileinfo[y][x]["Structures"]) > 0:
				if tileinfo[y][x]["Structures"][0]["Owner"] == "Player":
					tileinfo[y][x]["Player_Owned"] = true
					tileinfo[y][x]["Player_Accessible"] = true
			if tileinfo[y][x]["Player_Owned"]:
				tilemap.set_tile("Overlay",Vector2(x,y),2)
				for p in around:
					tileinfo[p.y][p.x]["Player_Accessible"] = true
			if tileinfo[y][x]["Tile"] == "Water":
				for p in around:
					tileinfo[p.y][p.x]["Near_Water"] = true
					
					

func ranchoice(lis):
	var ran = rng.randi_range(0,len(lis)-1)
	return lis[ran]
	

func _process(delta):
	tilemap.move(delta)
	if not menuopen:
		tilemap.highlight_cursor()
	else:
		get_buying()

func get_buying():
	var check = menu.get_buying()
	if check[0]:
		var can_buy = true
		var tile = tileinfo[menu.data["Map_Pos"].y][menu.data["Map_Pos"].x]
		if tile["Structures"].size()>0: can_buy = false
		if check[1] == "None": can_buy = false
		if can_buy:
			for mat in structures[check[1]][0]["Cost"]:
				if structures[check[1]][0]["Cost"][mat]>player.resources[mat]["Amount"]:
					can_buy = false
			if can_buy:
				add_structure(menu.data["Map_Pos"],check[1])
				for mat in structures[check[1]][0]["Cost"]:
					player.resources[mat]["Amount"] -= structures[check[1]][0]["Cost"][mat]
				
				refresh()
		
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if not menuopen:
				var map_pos = tilemap.get_mouse_tile()
				if tilemap.get_tile(map_pos,0) != "None":
					update_tile_data()
					
					var menu_scene = load("res://Scenes/Hex_Menu.tscn")
					menu = menu_scene.instantiate()
					add_child(menu)
					move_child(menu,1)
					
					menu.ready(tileinfo[map_pos.y][map_pos.x])
					menuopen = true
					tilemap.set_layer_modulate(1,Color(1,1,1,0.9))

func add_structure(pos,structure):
	tileinfo[pos.y][pos.x]["Structures"].append({
		"Name":structure,"Level":1,"Owner":"Player","Active":true,
		"Upkeep":structures[structure][0]["Upkeep"],
		"Output":structures[structure][0]["Output"]})
	tilemap.refresh_tile_texture(tileinfo[pos.y][pos.x])

func shutmenu():
	menuopen = false
	tilemap.set_layer_modulate(1,Color(1,1,1,0.5))
			


func _on_day_cycle_timeout():
	player.pass_time(tileinfo)
