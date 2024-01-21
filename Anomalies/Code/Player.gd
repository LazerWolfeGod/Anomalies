extends Node2D

var resource = {
	"Wood":{"num":0,"max":-1},
	"Water":{"num":0,"max":-1},
	"Population":{"num":0,"max":-1},
	"Rock":{"num":0,"max":-1},
	"Metal":{"num":0,"max":-1}
}

var owned_hexes = {}


func readyfunc(pos):
	owned_hexes[pos] = {"Tile":"Core","Structures":[]}
	var core_pos = pos

	
func pass_time():
	pass

