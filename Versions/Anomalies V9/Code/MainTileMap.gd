extends TileMap

#const atlas_key = {
	#Vector2i(-1,-1):"None",
	#Vector2i(0,0):"Forest",
	#Vector2i(1,0):"Rock",
	#Vector2i(2,0):"City",
	#Vector2i(3,0):"Water",
	#Vector2i(4,0):"Meadow",
	#Vector2i(3,1):"Core",
	#Vector2i(5,0):"Corruption",
#}
const movespeed = 2000
const scalesize = 1.1
var tile_high_light = Vector2i.ZERO

const tile_key = {
	"None":{"Base":[Vector2i(-1,-1),-1],"Structures":{}},
	"Highlight":{"Base":[Vector2i(0,0),0],"Structures":{}},
	
	"BigCity":{"Base":[Vector2i(0,0),1],"Structures":{}},
	
	"Forest":{"Base":[Vector2i(0,0),2],"Structures":{"Lumber Mill":[[Vector2i(0,2),2],[Vector2i(1,2),2],[Vector2i(2,2),2]],"Farm":[[Vector2i(0,3),2],[Vector2i(1,3),2],[Vector2i(2,3),2]],"Corruption":[[Vector2i(5,0),2]]}},
	"Rock":{"Base":[Vector2i(1,0),2],"Structures":{"Mines":[[Vector2i(0,1),2],[Vector2i(1,1),2],[Vector2i(2,1),2]],"Corruption":[[Vector2i(1,0),1]]}},
	"City":{"Base":[Vector2i(2,0),2],"Structures":{"Corruption":[[Vector2i(5,0),2]]}},
	"Water":{"Base":[Vector2i(3,0),2],"Structures":{}},
	"Meadow":{"Base":[Vector2i(4,0),2],"Structures":{"Farm":[[Vector2i(3,2),2],[Vector2i(4,2),2],[Vector2i(5,2),2]],"Corruption":[[Vector2i(5,0),2]]}},
	"Core":{"Base":[Vector2i(3,1),2],"Structures":{"Core":[[Vector2i(3,1),2],[Vector2i(3,0),1]],"Corruption":[[Vector2i(2,0),1]]}},
	"Deforest":{"Base":[Vector2i(5,1),2],"Structures":{}},
	"Overlay":{"Base":[Vector2i(4,1),2],"Structures":{}},
}

func set_tile(tile,pos,layer):
	var dat = tile_key["Overlay"]["Base"]
	if tile in tile_key:
		dat = tile_key[tile]["Base"]
	else:
		var st = tile.split("_")
		if st[0] in tile_key:
			if st[1] in tile_key[st[0]]["Structures"]:
				dat = tile_key[st[0]]["Structures"][st[1]][int(st[2])]
			else: print(st," is invalid set tile, no structure found called: ",st[1])
		else: print(st," is invalid set tile, no tile found called: ",st[0])
	set_cell(layer,pos,dat[1],dat[0])
	
func get_tile(pos,layer=0,detailed=false):
	var atlas = get_cell_atlas_coords(layer,pos)
	var id = get_cell_source_id(layer,pos)
	var tilename = "None"
	for t in tile_key:
		if tile_key[t]["Base"] == [atlas,id]:
			tilename = t
			if not detailed: return tilename
		for struc in tile_key[t]["Structures"]:
			if [atlas,id] in tile_key[t]["Structures"][struc]:
				tilename = t
				if detailed:
					tilename+="_"+struc+"_"+str(tile_key[t]["Structures"][struc].find([atlas,id])+1)
				else: return tilename
	return tilename

func tile_to_source_id(tile):
	return tile_key[tile]["Base"][1]
func tile_to_atlas_cords(tile):
	return tile_key[tile]["Base"][0]

func get_around(tiledata):
	var offset = tiledata["Grid_Pos"]-tiledata["Map_Pos"]
	var around = get_surrounding_cells(tiledata["Map_Pos"])
	for p in range(around.size()):
		around[p]+=offset
	return around

func refresh_tile_texture(tiledata):
	refresh_tile_atlas_data(tiledata)
	set_tile(tiledata["Texture_Name"],tiledata["Map_Pos"],0)
	
func refresh_tile_atlas_data(tiledata):
	var texturename = tiledata["Tile"]
	var dat = tile_key[tiledata["Tile"]]["Base"]
	if len(tiledata["Structures"]) > 0:
		if tiledata["Structures"][0]["Name"] in tile_key[tiledata["Tile"]]["Structures"]:
			texturename+="_"+tiledata["Structures"][0]["Name"]+"_"+str(tiledata["Structures"][0]["Level"]-1)
			dat = tile_key[tiledata["Tile"]]["Structures"][tiledata["Structures"][0]["Name"]][tiledata["Structures"][0]["Level"]-1]
	tiledata["Atlas_Cords"] = dat[0]
	tiledata["Source_Id"] = dat[1]
	tiledata["Texture_Name"] = texturename
	
			
func highlight_cursor():
	var map_pos = get_mouse_tile()
	if get_cell_atlas_coords(0,map_pos) != Vector2i(-1,-1):
		if map_pos != tile_high_light:
			set_cell(1,tile_high_light,2,Vector2i(-1,-1))
			tile_high_light = map_pos
			set_cell(1,tile_high_light,0,Vector2i(0,0))

func get_mouse_tile():
	var clickedpos = get_global_mouse_position()
	return local_to_map(to_local(clickedpos))
	
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
	
	var parentscale = $"../..".scale
	if Input.is_action_just_released("Zoom_In"):
		position-=get_viewport_rect().size*(scalesize-1)*((get_viewport().get_mouse_position()-position*parentscale)/get_viewport_rect().size)/parentscale
		scale*=scalesize
	elif Input.is_action_just_released("Zoom_Out"):
		position+=get_viewport_rect().size*(1-1/scalesize)*((get_viewport().get_mouse_position()-position*parentscale)/get_viewport_rect().size)/parentscale
		scale/=scalesize
