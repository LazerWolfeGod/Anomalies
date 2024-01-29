extends Node2D

var research = {
	"Spread_Cheaply":{"Level":0,"info":{"Costs":[],"Modifers":[0,1,2,3,4,5,6,7,8,9,10]}},
	"Spread_For_Production":{"Level":0,"info":{"Costs":[],"Modifers":[0,1,2,3,4,5,6,7,8,9,10]}},
	"Spread_To_Player":{"Level":0,"info":{"Costs":[],"Modifers":[0,1,2,3,4,5,6,7,8,9,10]}},
	"Block_Random_Spread":{"Level":0,"info":{"Costs":[],"Modifers":[10,9,8,7,6,5,4,3,2,1,0]}},
	"Increase_Output":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
	"Decrease_Spread_Cost":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
	"Cardiac_Strength":{"Level":0,"info":{"Costs":[],"Modifers":[20,30,40,50,60,70,80,90,100,110,120]}},
	"Split_Chance":{"Level":0,"info":{"Costs":[],"Modifers":[0]}},
}

var resources = {
	"Oxygen":{"Amount":0,"Max":0.0,"Change":0.0},
	"Crystal":{"Amount":0.0,"Max":0.0,"Change":0.0},
	"Energy":{"Amount":0.0,"Max":0.0,"Change":0.0},   # Used to increase heart rate
}

const direction_data = [
	[Vector2i(1,0),Vector2i(0,1),Vector2i(-1,1),Vector2i(-1,0),Vector2i(-1,-1),Vector2i(0,-1)],
	[Vector2i(1,0),Vector2i(1,1),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,-1)]]

var tileinfo
var owned_tiles = []
var coretile
var rng = RandomNumberGenerator.new()
var queue_expansion = {"Waiting":false,"Pos":Vector2i(0,0),"Cost":0.0}
const Id = "Corruption"
var owned_structures = []


func _init():
	for r in research:
		research[r]["Modifer"] = research[r]["info"]["Modifers"][0]
		
func set_core(core):
	coretile = core

func refresh(tileinfo):
	refresh_owned_tiles(tileinfo)
	refresh_max_resources(tileinfo)
	refresh_owned_structures(tileinfo)
	refresh_active_structures()

func refresh_owned_tiles(tileinfo):
	owned_tiles = []
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			if tileinfo[y][x]["Structures"].size()>0 and tileinfo[y][x]["Structures"][0]["Owner"] == Id:
				owned_tiles.append(tileinfo[y][x])

func refresh_max_resources(tileinfo):
	for r in resources:
		resources[r]["Max"] = 0
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			for struc in tileinfo[y][x]["Structures"]:
				if struc["Active"] and struc["Owner"] == Id:
					for u in struc["Output"]:
						if u.split("_",1)[0] == "Max":
							if u == "Max_Blood_Pressure":
								tileinfo[y][x]["Blood_Pressure"]["Max"] = struc["Output"][u]
							else:
								resources[u.split("_",1)[1]]["Max"]+=struc["Output"][u]
			
func gametick(tileinfo,delta):
	if not queue_expansion["Waiting"]:
		var dat = grow(tileinfo)
		if dat is Array:
			var tile = dat[0]
			var cost = dat[1]
			queue_expansion["Waiting"] = true
			queue_expansion["Tile"] = tile
			queue_expansion["Cost"] = cost
			print("item cost is ",queue_expansion["Cost"])
	elif resources["Oxygen"]["Amount"]>queue_expansion["Cost"] and pullblood_togrow(queue_expansion["Tile"],2):
		queue_expansion["Waiting"] = false
		resources["Oxygen"]["Amount"]-=queue_expansion["Cost"]
		refresh(tileinfo)
		return queue_expansion["Tile"]["Grid_Pos"]
	return -1

func pullblood_togrow(tile,blood_needed):
	var around = []
	for d in direction_data[fmod(tile["Grid_Pos"].y,2)]:
		around.append(tile["Grid_Pos"]+d)
	var available_blood = 0
	for a in range(around.size()):
		if around[a].x>-1 and around[a].x<tileinfo[tile["Grid_Pos"].y].size() and around[a].y>-1 and around[a].y<tileinfo.size():
			var adjacent = tileinfo[around[a].y][around[a].x]
			available_blood+=adjacent["Blood_Pressure"]["Amount"]
	#print(tile["Map_Pos"]," available blood ",available_blood, " around: ",around)
	if available_blood>blood_needed:
		var mul = blood_needed/available_blood
		for a in range(around.size()):
			if around[a].x>-1 and around[a].x<tileinfo[tile["Grid_Pos"].y].size() and around[a].y>-1 and around[a].y<tileinfo.size():
				tileinfo[around[a].y][around[a].x]["Blood_Pressure"]["Amount"]-=tileinfo[around[a].y][around[a].x]["Blood_Pressure"]["Amount"]*mul
				return true
	else:
		return false
			
func bloodflow(tileinfo):
	var around
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			tileinfo[y][x]["Blood_Pressure"]["Change"] = 0
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			var tile = tileinfo[y][x]
			if tile["Structures"].size()>0 and tile["Structures"][0]["Owner"] == Id:
				var core = false
				if tile["Blood_Pressure"]["Amount"] == 20:
					core = true
				#print(tile["Blood_Pressure"]["Amount"]," ",y," ",x," ",tile["Structures"][0]["Active"])
				var totalveinsize = 0
				for v in tile["Blood_Pressure"]["Directions"]:
					totalveinsize+=v["Throughput"]
				around = []
				for d in direction_data[fmod(y,2)]:
					around.append(Vector2i(x,y)+d)
				for a in range(around.size()):
					tile["Blood_Pressure"]["Directions"][a]["Active"] = false
					if around[a].x>-1 and around[a].x<tileinfo[y].size() and around[a].y>-1 and around[a].y<tileinfo.size():
						var adjacent = tileinfo[around[a].y][around[a].x]
						if adjacent["Owner"] == Id:
							tile["Blood_Pressure"]["Directions"][a]["Active"] = true
							
							var moveable_blood = tile["Blood_Pressure"]["Amount"]*tile["Blood_Pressure"]["Directions"][a]["Throughput"]/totalveinsize
							var vein_throughput = tile["Blood_Pressure"]["Directions"][a]["Throughput"]
							
							tile["Blood_Pressure"]["Directions"][a]["Oversupply"] = moveable_blood-vein_throughput
							var blood_to_move
							if vein_throughput>moveable_blood:
								blood_to_move = moveable_blood
							else:
								blood_to_move = vein_throughput
							tile["Blood_Pressure"]["Directions"][a]["Output"] = blood_to_move
							adjacent["Blood_Pressure"]["Directions"][fmod(a+3,6)]["Intake"] = blood_to_move
	
	
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			var tile = tileinfo[y][x]
			if tile["Structures"].size()>0 and tile["Structures"][0]["Owner"] == Id:
				var given_blood = 0
				for i in tile["Blood_Pressure"]["Directions"]:
					given_blood+=i["Intake"]
				
				#if tile["Blood_Pressure"]["Amount"]+given_blood>tile["Blood_Pressure"]["Max"]:
				var overflow = tile["Blood_Pressure"]["Amount"]+given_blood-tile["Blood_Pressure"]["Max"]
				
				if tile["Blood_Pressure"]["Amount"]>0:
					print(tile["Grid_Pos"],tile["Blood_Pressure"])
				
				if given_blood != 0:
					around = []
					for d in direction_data[fmod(y,2)]:
						around.append(Vector2i(x,y)+d)
					for a in range(around.size()):
						if around[a].x>-1 and around[a].x<tileinfo[y].size() and around[a].y>-1 and around[a].y<tileinfo.size():
							var adjacent = tileinfo[around[a].y][around[a].x]
							if adjacent["Owner"] == Id:
								adjacent["Blood_Pressure"]["Directions"][fmod(a+3,6)]["Overflow"] = overflow*(tile["Blood_Pressure"]["Directions"][a]["Intake"]/given_blood)
							
				if overflow>0:
					tile["Blood_Pressure"]["Amount"] = tile["Blood_Pressure"]["Max"]
				else:
					tile["Blood_Pressure"]["Amount"] += given_blood
			
			
	
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
	return (map_cords-coretile["Map_Pos"]).length()

	
func add_corrupt_data(tile):
	tile["Blood_Pressure"] = {"Amount":0,"Max":0,"Change":0,"Directions":[
		{"Throughput":6,"Overflow":0,"Oversupply":0,"Intake":0,"Output":0,"Active":false},
		{"Throughput":6,"Overflow":0,"Oversupply":0,"Intake":0,"Output":0,"Active":false},
		{"Throughput":6,"Overflow":0,"Oversupply":0,"Intake":0,"Output":0,"Active":false},
		{"Throughput":6,"Overflow":0,"Oversupply":0,"Intake":0,"Output":0,"Active":false},
		{"Throughput":6,"Overflow":0,"Oversupply":0,"Intake":0,"Output":0,"Active":false},
		{"Throughput":6,"Overflow":0,"Oversupply":0,"Intake":0,"Output":0,"Active":false}]}
	tile["Corruption_Cost"] = rng.randf()*1.5+0.5
	tile["Corruption_Output"] = rng.randf()+0.5
	tile["Surrounding_Biomass"] = 0
	

func pass_time():
	coretile["Blood_Pressure"]["Amount"]+=research["Cardiac_Strength"]["Modifer"]
	if coretile["Blood_Pressure"]["Amount"]>coretile["Blood_Pressure"]["Max"]:
		coretile["Blood_Pressure"]["Amount"] = coretile["Blood_Pressure"]["Max"]
	print("core at: ",coretile["Grid_Pos"]," ",resources["Oxygen"])
	
	bloodflow(tileinfo)
	refresh_active_structures()
	for s in owned_structures:
		if s["Active"]:
			for u in s["Upkeep"]:
				if u == "Blood_Pressure":
					tileinfo[s["Grid_Pos"].y][s["Grid_Pos"].x]["Blood_Pressure"]["Amount"]-=s["Upkeep"][u]
				else:
					resources[u]["Amount"]-=s["Upkeep"][u]
			for u in s["Output"]:
				if u.split("_")[0] != "Max":
					resources[u]["Amount"]+=s["Output"][u]
					if resources[u]["Amount"]>resources[u]["Max"]:
						resources[u]["Amount"] = resources[u]["Max"]
						
	refresh_active_structures()
	
func refresh_active_structures():
	var temp_res = {}
	for r in resources:
		temp_res[r] = resources[r]["Amount"]
	for s in owned_structures:
		s["Active"] = false
	for l in range(2):
		for s in owned_structures:
			var valid = true
			for u in s["Upkeep"]:
				if u == "Blood_Pressure":
					if tileinfo[s["Grid_Pos"].y][s["Grid_Pos"].x]["Blood_Pressure"]["Amount"]<s["Upkeep"][u]: valid = false
				else:
					if temp_res[u]<s["Upkeep"][u]: valid = false
			if valid and not s["Active"]:
				for u in s["Upkeep"]:
					if u != "Blood_Pressure":
						temp_res[u]-=s["Upkeep"][u]
				for u in s["Output"]:
					if u.split("_")[0] != "Max":
						temp_res[u]+=s["Output"][u]
			if l == 0: s["Active"] = valid
			elif valid == true: s["Active"] = true

func refresh_owned_structures(tileinfo):
	owned_structures = []
	for y in tileinfo:
		for x in y:
			for s in x["Structures"]:
				if s["Owner"] == Id:
					owned_structures.append(s)
