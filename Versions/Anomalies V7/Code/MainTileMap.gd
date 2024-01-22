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
	"None":[Vector2i(-1,-1),-1],
	"Highlight":[Vector2i(0,0),0],
	
	"Big_City":[Vector2i(0,0),1],
	"Corrupt_Rock":[Vector2i(1,0),1],
	"Corrupt_Core":[Vector2i(2,0),1],
	"Core_lvl2":[Vector2i(3,0),1],
	
	"Forest":[Vector2i(0,0),2],
	"Rock":[Vector2i(1,0),2],
	"City":[Vector2i(2,0),2],
	"Water":[Vector2i(3,0),2],
	"Meadow":[Vector2i(4,0),2],
	"Corrupt_Tile":[Vector2i(5,0),2],
	"Core":[Vector2i(3,1),2],
	"Deforest":[Vector2i(5,1),2],
	"Overlay":[Vector2i(4,1),2],
}

func set_tile(tile,pos,layer):
	var d = tile_key[tile]
	set_cell(layer,pos,d[1],d[0])
	
func get_tile(pos,layer=0):
	var atlas = get_cell_atlas_coords(layer,pos)
	var id = get_cell_source_id(layer,pos)
	for t in tile_key:
		if tile_key[t] == [atlas,id]:
			return t
	return "None"
func tile_to_source_id(tile):
	return tile_key[tile][1]
func tile_to_atlas_cords(tile):
	return tile_key[tile][0]
	
			
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
	
	if Input.is_action_just_released("Zoom_In"):
		position-=get_viewport_rect().size*(scalesize-1)*((get_viewport().get_mouse_position()-position)/get_viewport_rect().size)
		scale*=1.1
	elif Input.is_action_just_released("Zoom_Out"):
		position+=get_viewport_rect().size*(1-1/scalesize)*((get_viewport().get_mouse_position()-position)/get_viewport_rect().size)
		scale/=1.1
