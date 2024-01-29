extends Node2D

var tileinfo


func _draw():
	var w = 496
	var h = 571*0.75
	var startpos = Vector2(tileinfo[0][0]["Map_Pos"])*Vector2(w,h)
	var offset = [Vector2(w,h/0.75/2),Vector2(w/2,h/0.75/2)]
	var side = w/2/cos(PI/6)
	var r3 = 3**0.5
	#var cords = [Vector2(-r3/2*side,-side/2),Vector2(-r3/2*side,side/2),Vector2(0,side),
				 #Vector2(r3/2*side,side/2),Vector2(r3/2*side,-side/2),Vector2(0,-side)]
	
	var cords = [Vector2(0.5,0),Vector2(-r3/6,r3/4),Vector2(r3/6,r3/4),
				Vector2(-0.5,0),Vector2(r3/6,-r3/4),Vector2(-r3/6,-r3/4)]
	var mul = 5
	
	for y in range(tileinfo.size()):
		for x in range(tileinfo[y].size()):
			var center = Vector2(x*w,y*h)+offset[fmod(y,2)]+startpos
			var blood = tileinfo[y][x]["Blood_Pressure"]
			draw_circle(center,blood["Amount"]*mul,Color(255,255,255))
			for c in range(cords.size()):
				var lsize = blood["Directions"][c]["Output"]*mul
				if blood["Directions"][c]["Output"]*mul>0 and blood["Directions"][c]["Output"]*mul<1: lsize = 1
				draw_line(center+cords[c]*(w/3),center+cords[c]*(w/2),Color(255,255,255),lsize,true)
