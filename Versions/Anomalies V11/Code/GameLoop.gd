extends Node2D

var menuopen = false

var tileinfo: Array = []
var grid = []
var rng = RandomNumberGenerator.new()
var tilemap_rect
#var player
var factions = {"Players":[],"Corruptions":[]}
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
	
	"Corruption":[{"Cost":{"Oxygen":8,"Blood_Pressure":1},"Upkeep":{"Blood_Pressure":0},"Output":{"Oxygen":1,"Max_Blood_Pressure":3,"Max_Oxygen":1}},
				{"Cost":{"Oxygen":20},"Upkeep":{"Blood_Pressure":3},"Output":{"Oxygen":2,"Max_Blood_Pressure":10,"Max_Oxygen":2}},
				{"Cost":{"Oxygen":30},"Upkeep":{"Blood_Pressure":8},"Output":{"Oxygen":4,"Max_Blood_Pressure":20,"Max_Oxygen":4}}],
	"Corrupt Core":[{"Cost":{},"Upkeep":{},"Output":{"Max_Blood_Pressure":20,"Max_Oxygen":20,"Oxygen":1}},{},{}]
}
const struct_owners = {
	"Corruption":["Corruption","Corrupt Core"],
	"Player":["Core","House","Farm","Lumber Mill","Wind Turbine","Pump","Storage","Mines"]
}

var tile_init_data = {
	"Forest":{"Possible_Structures":["House","Farm","Lumber Mill"]},
	"Rock":{"Possible_Structures":["Mines"]},
	"City":{"Possible_Structures":["House"]},
	"Water":{},
	"Meadow":{"Possible_Structures":["House","Farm","Wind Turbine"]},
	"Core":{},
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
		grid = mapgen.map_generator(40,30)

func _ready():
	tilemap = $TileMap
	tilemap.tileinfo = tileinfo
	$TileMap/Blood.tileinfo = tileinfo
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			tilemap.set_tile(grid[y][x],Vector2i(x-grid[y].size()/2,y-grid.size()/2),0)
		
	for s in structures:
		for l in range(structures[s].size()):
			structures[s][l]["Level"] = l+1
			structures[s][l]["Name"] = s
			structures[s][l]["Active"] = true
			for entity in struct_owners:
				if s in struct_owners[entity]:
					structures[s][l]["Owner"] = entity
			
	
	var player_scene = load("res://Scenes/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	factions["Players"].append(player)
	
	var corruption_scene = load("res://Scenes/Corruption.tscn")
	var corruption = corruption_scene.instantiate()
	add_child(corruption)
	corruption.tileinfo = tileinfo
	factions["Corruptions"].append(corruption)
	
	tilemap_rect = tilemap.get_used_rect()
	for y in range(tilemap_rect.size.y):
		tileinfo.append([])
		for x in range(tilemap_rect.size.x):
			tileinfo[-1].append(gen_tile_dict(Vector2i(x+tilemap_rect.position.x,y+tilemap_rect.position.y)))
			tileinfo[-1][-1]["Grid_Pos"] = Vector2i(x,y)
			for s in tileinfo[-1][-1]["Structures"]:
				s["Grid_Pos"] = Vector2i(x,y)
			corruption.add_corrupt_data(tileinfo[-1][-1])
			
			if tileinfo[-1][-1]["Structures"].size()>0 and tileinfo[-1][-1]["Structures"][0]["Owner"] == corruption.Id:
				corruption.set_core(tileinfo[-1][-1])
			
			
	refresh()
	
func refresh():
	update_tile_data()
	refresh_possible_structures()
	for f in factions:
		for p in factions[f]:
			p.refresh(tileinfo)
	if menuopen: menu.refresh()
	
func gen_tile_dict(pos):
	var tile_type = tilemap.get_tile(pos)
	var tile_type_detailed = tilemap.get_tile(pos,0,true)
	var base_structures = []
	var split = tile_type_detailed.split("_")
	if split.size()>1:
		base_structures.append(structures[split[1]][int(split[2])-1].duplicate())
	var tile_dict = {
		"Map_Pos":pos, "Tile":tile_type,"Near_Water":false,
		"Atlas_Cords":tilemap.tile_to_atlas_cords(tile_type),"Atlas_Id":tilemap.tile_to_source_id(tile_type),"Texture_Name":tile_type_detailed,
		"Owner":"None", "AccessibleTo":{"Player":false,"Corruption":false},
		"Structures":base_structures, "Possible_Structures": []
	}
	for a in tile_init_data[tile_type]:
		var val = tile_init_data[tile_type][a]
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
			tileinfo[y][x]["Owner"] = "None"
			for entity in tileinfo[y][x]["AccessibleTo"]:
				tileinfo[y][x]["AccessibleTo"][entity] = false
	for y in range(len(tileinfo)):
		for x in range(len(tileinfo[y])):
			var around = tilemap.get_around(tileinfo[y][x]) 
			tilemap.set_tile("None",tileinfo[y][x]["Map_Pos"],2)
			if len(tileinfo[y][x]["Structures"]) > 0:
				tileinfo[y][x]["Owner"] = tileinfo[y][x]["Structures"][0]["Owner"]
			if tileinfo[y][x]["Owner"] == factions["Players"][0].Id:
				tilemap.set_tile("Overlay",tileinfo[y][x]["Map_Pos"],2)
			tileinfo[y][x]["Surrounding_Biomass"] = 0
			for p in around:
				if p.y>-1 and p.y<tileinfo.size() and p.x>-1 and p.x<tileinfo[p.y].size():
					tileinfo[p.y][p.x]["AccessibleTo"][tileinfo[y][x]["Owner"]] = true
					if tileinfo[y][x]["Tile"] == "Water":
						tileinfo[p.y][p.x]["Near_Water"] = true
					if len(tileinfo[p.y][p.x]["Structures"]) > 0 and tileinfo[p.y][p.x]["Structures"][0]["Owner"] == factions["Corruptions"][0].Id:
						tileinfo[y][x]["Surrounding_Biomass"]+=tileinfo[p.y][p.x]["Structures"][0]["Level"]
				
					
					

func ranchoice(lis):
	var ran = rng.randi_range(0,len(lis)-1)
	return lis[ran]
	

func _process(delta):
	tilemap.move(delta)
	
	for c in factions["Corruptions"]:
		var growto = c.gametick(tileinfo,delta)
		if growto is Vector2i:
			add_structure(growto,structures["Corruption"][0])
		
	if not menuopen:
		tilemap.highlight_cursor()
	else:
		get_buying(factions["Players"][0])

func get_buying(player):
	var check = menu.get_buying()
	if check[0]:
		var can_buy = true
		var tile = tileinfo[menu.data["Grid_Pos"].y][menu.data["Grid_Pos"].x]
		if tile["Structures"].size()>0: can_buy = false
		if check[1] == "None": can_buy = false
		if can_buy:
			for mat in structures[check[1]][0]["Cost"]:
				if structures[check[1]][0]["Cost"][mat]>player.resources[mat]["Amount"]:
					can_buy = false
			if can_buy:
				add_structure(menu.data["Grid_Pos"],structures[check[1]][0])
				for mat in structures[check[1]][0]["Cost"]:
					player.resources[mat]["Amount"] -= structures[check[1]][0]["Cost"][mat]
				refresh()
				menu.bought()
		
	
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
					var infopos = Vector2i(map_pos.x-tilemap_rect.position.x,map_pos.y-tilemap_rect.position.y)
					if map_pos == tileinfo[infopos.y][infopos.x]["Map_Pos"]:
						menu.ready(tileinfo[infopos.y][infopos.x])
					else:
						printerr("THING BROKE")
					menuopen = true
					tilemap.set_layer_modulate(1,Color(1,1,1,0.9))

func add_structure(pos,structure):
	tileinfo[pos.y][pos.x]["Structures"].append(structure.duplicate())
	tileinfo[pos.y][pos.x]["Structures"][-1]["Grid_Pos"] = pos
	if "Max_Blood_Pressure" in structure["Output"]:
		tileinfo[pos.y][pos.x]["Blood_Pressure"]["Max"] = structure["Output"]["Max_Blood_Pressure"]
		#{"Name":structure,"Level":1,"Owner":"Player","Active":true,
		#"Upkeep":structures[structure][0]["Upkeep"],
		#"Output":structures[structure][0]["Output"]})
	tilemap.refresh_tile_texture(tileinfo[pos.y][pos.x])
	refresh()

func shutmenu():
	menuopen = false
	tilemap.set_layer_modulate(1,Color(1,1,1,0.5))
			

func _on_day_cycle_timeout():
	for p in factions["Players"]:
		p.pass_time(tileinfo)

func _on_heart_beat_timeout():
	for p in factions["Corruptions"]:
		p.pass_time()
	$TileMap/Blood.queue_redraw()
