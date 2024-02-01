extends Panel

var tick_pressed = false

var data_info = {
	"Cost":{"Pos":Vector2(50,195)},
	"Upkeep":{"Pos":Vector2(50,270)},
	"Output":{"Pos":Vector2(50,360)}
}
var added_nodes = []

func set_info(struc,upgrade,atlas_dict):
	
	tick_pressed = false
	if upgrade:
		$Structure_List.set_cell(0,Vector2i(0,0),0,atlas_dict[struc["Name"]])
		$Title.text = "Upgrade to lvl "+str(struc["Level"])
		$Description.text = struc["Description"]
		for d in data_info:
			var mat_image_scene = load("res://Scenes/material_display.tscn")
			var mat_images = mat_image_scene.instantiate()
			add_child(mat_images)
			mat_images.set_info(struc[d],data_info[d]["Pos"])
		


func _on_cross_button_down():
	hide()


func _on_tick_button_down():
	tick_pressed = true
