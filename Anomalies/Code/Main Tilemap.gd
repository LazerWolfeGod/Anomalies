extends TileMap

var menuopen = false
var movespeed = 200

func _ready():
	var menu = $"../Menu"
	menuopen = menu.visible
	for y in range(get_used_rect().size.y):
		for x in range(get_used_rect().size.x):
			set_cell(1,Vector2i(x,y),0)
	
func _process(delta):
	if Input.is_action_pressed("Move_Camera_Left"):
		position.x+=movespeed*delta
	if Input.is_action_pressed("Move_Camera_Right"):
		position.x-=movespeed*delta
	if Input.is_action_pressed("Move_Camera_Up"):
		position.y+=movespeed*delta
	if Input.is_action_pressed("Move_Camera_Down"):
		position.y-=movespeed*delta
		
	if Input.is_action_just_released("Zoom_In"):
		scale*=1.1
	elif Input.is_action_just_released("Zoom_Out"):
		scale/=1.1
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if not menuopen:
				var clicked_pos = event.position
				var map_pos = local_to_map(to_local(clicked_pos))
				print(map_pos)
				var menu = $"../Menu"
				menu.show()
			
