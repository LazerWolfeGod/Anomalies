extends Node2D

var resources = {
	"Wood":{"Amount":0,"Max":0,"Change":0},
	"Water":{"Amount":0,"Max":0,"Change":0},
	"Population":{"Amount":0,"Max":0,"Change":0},
	"Rock":{"Amount":0,"Max":0,"Change":0},
	"Metal":{"Amount":0,"Max":0,"Change":0},
	"Energy":{"Amount":0,"Max":0,"Change":0},
	"Food":{"Amount":0,"Max":0,"Change":0}
}
const Name = "Player" 


func calc_resources(tile_data):
	for r in resources:
		resources[r]["Max"] = 0
		resources[r]["Change"] = 0
	for y in range(tile_data.size()):
		for x in range(tile_data[y].size()):
			if tile_data[y][x]["Player_Owned"]:
				for struc in tile_data[y][x]["Structures"]:
					for i in struc["Upkeep"]:
						resources[i]["Change"]-=struc["Upkeep"][i]
					for i in struc["Output"]:
						if i in resources:
							resources[i]["Change"]+=struc["Output"][i]
						elif i.split("_")[0] == "Max":
							resources[i.split("_")[1]]["Max"]+=struc["Output"][i]
	return resources
	
func pass_time():
	for r in resources:
		resources[r]["Amount"]+=resources[r]["Change"]
		if resources[r]["Amount"]>resources[r]["Max"]:
			resources[r]["Amount"] = resources[r]["Max"]
	

