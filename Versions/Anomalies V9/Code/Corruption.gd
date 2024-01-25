extends Node2D

var research = {
	"Spread_Cheaply":{"Level":0,"info":{"Costs":[],"Modifers":[0,1,2,3,4,5,6,7,8,9,10]}},
	"Spread_For_Production":{"Level":0,"info":{"Costs":[],"Modifers":[0,1,2,3,4,5,6,7,8,9,10]}},
	"Spread_To_Player":{"Level":0,"info":{"Costs":[],"Modifers":[0,1,2,3,4,5,6,7,8,9,10]}},
	"Block_Random_Spread":{"Level":0,"info":{"Costs":[],"Modifers":[10,9,8,7,6,5,4,3,2,1,0]}},
	"Increase_Output":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
	"Decrease_Spread_Cost":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
	"Cardiac_Strength":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
	"Split_Chance":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
}

var resources = {
	"Oxygen":{"Amount":0.0,"Max":0.0,"Change":0.0},
	"Crystal":{"Amount":0.0,"Max":0.0,"Change":0.0},
}

const direction_data = [
	[Vector2i(1,0),Vector2i(0,1),Vector2i(-1,1),Vector2i(-1,0),Vector2i(-1,-1),Vector2i(0,-1)],
	[Vector2i(1,0),Vector2i(1,1),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,-1)]]

var owned_tiles = []
var map_cords_core
var rng = RandomNumberGenerator.new()
var queue_expansion = {"Waiting":false,"Pos":Vector2i(0,0),"Cost":0.0}
const Id = "Corruption"


func _init():
	for r in research:
		research[r]["Modifer"] = research[r]["info"]["Modifers"][-1]#research[r]["Level"]]
func set_core(pos):
	map_cords_core = pos

func refresh(tileinfo):
	refresh_owned_tiles(tileinfo)

func refresh_owned_tiles(tileinfo):
	owned_tiles = []
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			if tileinfo[y][x]["Structures"].size()>0 and tileinfo[y][x]["Structures"][0]["Owner"] == Id:
				owned_tiles.append(tileinfo[y][x])


func gametick(tileinfo):
	resources["Oxygen"]["Amount"]+=10
	if not queue_expansion["Waiting"]:
		var dat = grow(tileinfo)
		if dat is Array:
			var tile = dat[0]
			var cost = dat[1]
			if resources["Oxygen"]["Amount"]>cost:
				resources["Oxygen"]["Amount"]-=cost
				refresh(tileinfo)
				return tile["Grid_Pos"]
			else:
				queue_expansion["Waiting"] = true
				queue_expansion["Pos"] = tile["Grid_Pos"]
				queue_expansion["Cost"] = cost
	elif resources["Oxygen"]["Amount"]>queue_expansion["Cost"]:
		queue_expansion["Waiting"] = false
		resources["Oxygen"]["Amount"]-=queue_expansion["Cost"]
		refresh(tileinfo)
		return queue_expansion["Pos"]
	return -1
	
	
	
	
func grow(tileinfo):
	var possible_tiles = []
	var dat = {"Cost":0,"Output":0,"Attack":0}
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			if tileinfo[y][x]["Owner"] == "None" and tileinfo[y][x]["AccessibleTo"][Id] and tileinfo[y][x]["Tile"] != "Water":
				dat["Cost"] = (get_core_distance(tileinfo[y][x]["Map_Pos"]))/tileinfo[y][x]["Surrounding_Biomass"]*tileinfo[y][x]["Corruption_Cost"]
				
				dat["Output"] = (1*1)*tileinfo[y][x]["Corruption_Output"]
				
				dat["Attack"] = 1
				
				dat["Random"] = rng.randf()*3
				
				var value = dat["Cost"]*research["Spread_Cheaply"]["Modifer"]+dat["Output"]*research["Spread_For_Production"]["Modifer"]+dat["Attack"]*research["Spread_To_Player"]["Modifer"]+dat["Random"]*research["Block_Random_Spread"]["Modifer"]
				
				possible_tiles.append([tileinfo[y][x],value,dat.duplicate()])
	possible_tiles.sort_custom(sort_list)
	if possible_tiles.size() == 0:
		return -1
	return [possible_tiles[0][0],possible_tiles[0][2]["Cost"]]


func sort_list(a,b):
	return a[1]<b[1]

func get_core_distance(map_cords):
	return (map_cords-map_cords_core).length()

	
func add_corrupt_data(tile):
	tile["Blood_Pressure"] = 0
	tile["Vein_Throughput"] = [0,0,0,0,0,0]
	tile["Corruption_Cost"] = rng.randf()*1.5+0.5
	tile["Corruption_Output"] = rng.randf()+0.5
	tile["Surrounding_Biomass"] = 0
	
func pass_time(tileinfo):
	pass


