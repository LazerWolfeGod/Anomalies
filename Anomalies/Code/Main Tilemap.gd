extends TileMap

var menuopen = false
const movespeed = 2000
const scalesize = 1.1

var tileinfo: Array = []
var rng = RandomNumberGenerator.new()

const atlas_key = {
	Vector2i(-1,-1):"None",
	Vector2i(0,0):"Forest",
	Vector2i(1,0):"Rock",
	Vector2i(2,0):"City",
	Vector2i(3,0):"Water",
	Vector2i(4,0):"Meadow",
}

const tile_init_data = {
	"Forest":{"Wood":true,"Max_Structures":[1,2]},
	"Rock":{"Metal":true,"Max_Structures":[3,4,5]},
	"City":{"Population":10,"Max_Population":100,"Max_Structures":[3]},
	"Water":{"Water":true,"Max_Structures":[0]},
	"Meadow":{"Food":true,"Max_Structures":[3]},
	"None":{}
}

func gen_tile_dict(pos):
	var atlas_cords = get_cell_atlas_coords(0,pos)
	var tile_type = atlas_key[atlas_cords]
	var tile_dict = {
		"Map_Pos":pos,
		"Tile":"None",
		"Population":0,
		"Max_Population":0,
		"Wood":false,
		"Water":false,
		"Metal":false,
		"Food":false,
		"Corruption":0,
		"Max_Structures":0,
		"Structures": {},
	}
	tile_dict["Tile"] = tile_type
	for a in tile_init_data[tile_type]:
		var val = tile_init_data[tile_type][a]
		if val is Array:
			val = ranchoice(val)
		tile_dict[a] = val
	return tile_dict

func ranchoice(lis):
	var ran = rng.randi_range(0,len(lis)-1)
	return lis[ran]
	
func _ready():
	for y in range(get_used_rect().size.y):
		tileinfo.append([])
		for x in range(get_used_rect().size.x):
			tileinfo[-1].append(gen_tile_dict(Vector2i(x,y)))
			set_cell(1,Vector2i(x,y),0)

func _process(delta):
	move(delta)
	
	
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
		
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if not menuopen:
				var clicked_pos = event.position
				var map_pos = local_to_map(to_local(clicked_pos))
				if get_cell_atlas_coords(0,map_pos) != Vector2i(-1,-1):
					var menu_scene = load("res://Scenes/menu.tscn")
					var menu = menu_scene.instantiate()
					add_sibling(menu)
					menu.ready(tileinfo[map_pos.y][map_pos.x])
					menuopen = true
			
