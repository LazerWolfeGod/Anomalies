extends Control


func _process(delta):
	if Input.is_action_just_pressed("Back"):
		exit()

func exit():
	get_node("../TileMap").menuopen = false
	queue_free()


func _on_button_button_down():
	print('clicked')
	exit()
	
func ready(data):
	var txt = ""
	for d in data:
		txt+=d+": "+str(data[d])+"\n"
	$Buildings_List/Label.text = txt
