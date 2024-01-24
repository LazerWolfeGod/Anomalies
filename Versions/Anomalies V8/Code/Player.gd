extends Node2D

var resources = {
	"Wood":{"Amount":0,"Max":0,"Change":0},
	"Water":{"Amount":0,"Max":0,"Change":0},
	"Population":{"Amount":2,"Max":0,"Change":0},
	"Rock":{"Amount":0,"Max":0,"Change":0},
	"Metal":{"Amount":0,"Max":0,"Change":0},
	"Energy":{"Amount":0,"Max":0,"Change":0},
	"Food":{"Amount":0,"Max":0,"Change":0}
}
var owned_structures = []
const Name = "Player" 
var rng = RandomNumberGenerator.new()



func calc_resources(tile_data):
	for r in resources:
		resources[r]["Max"] = 0
		resources[r]["Change"] = 0
	for struc in owned_structures:
		if struc["Active"]:
			for i in struc["Upkeep"]:
				resources[i]["Change"]-=struc["Upkeep"][i]
			for i in struc["Output"]:
				if i in resources:
					resources[i]["Change"]+=struc["Output"][i]
				elif i.split("_")[0] == "Max":
					resources[i.split("_")[1]]["Max"]+=struc["Output"][i]
	increase_population()
	return resources
	
func refresh_resources(tileinfo):
	refresh_structures(tileinfo)
	var res = calc_resources(tileinfo)
	$PlayerHud.UpdateGui(res)

func refresh_structures(tileinfo):
	owned_structures = []
	for y in tileinfo:
		for x in y:
			for s in x["Structures"]:
				if s["Owner"] == Name:
					owned_structures.append(s)
	var temp_res = {}
	for r in resources:
		temp_res[r] = resources[r]["Amount"]
	for s in owned_structures:
		s["Active"] = false
	for l in range(2):
		for s in owned_structures:
			var valid = true
			for u in s["Upkeep"]:
				if temp_res[u]<s["Upkeep"][u]: 
					valid = false
			if valid and not s["Active"]:
				for u in s["Upkeep"]:
					temp_res[u]-=s["Upkeep"][u]
				for u in s["Output"]:
					if u.split("_")[0] != "Max":
						temp_res[u]+=s["Output"][u]
			if l == 0: s["Active"] = valid
			elif valid == true: s["Active"] = true

		
		
		
func pass_time(tileinfo):
	for s in owned_structures:
		if s["Active"]:
			for u in s["Upkeep"]:
				if u != "Population":
					resources[u]["Amount"]-=s["Upkeep"][u]
			for u in s["Output"]:
				if u.split("_")[0] != "Max":
					resources[u]["Amount"]+=s["Output"][u]
					if resources[u]["Amount"]>resources[u]["Max"]:
						resources[u]["Amount"] = resources[u]["Max"]
	resources["Population"]["Amount"]+=resources["Population"]["Change"]
	refresh_resources(tileinfo)
	
func increase_population():
	var u = 1 # Rate of change
	var r = float(resources["Population"]["Max"]) # Max population
	var f = (1/(r**0.5)) # Rate of change but more useful
	var x = resources["Population"]["Amount"] # Current Population
	# Graph = y=\frac{re^{fx}}{e^{fx}+u}
	
	var t = (2.718281828**(f*x)) # var to shorten algebra
	var grad = (f*r*u*t)/((t+u)**2) # Gradient of graph 
	#print("Grad: ",grad)#, " r: ",r, " f: ",f," t: ",t," x: ",x)
	var intpart = int(grad)
	var floatpart = fmod(grad,1)
	if rng.randf()<floatpart: intpart+=1
	if resources["Population"]["Amount"]+intpart>resources["Population"]["Max"]:
		intpart = resources["Population"]["Max"]-resources["Population"]["Amount"]
	resources["Population"]["Change"] = intpart
	
	
	
