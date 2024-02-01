extends Control

var ingame = false
var button_pressed

func _ready():
	$StartMenu.show()
	$LevelsMenu.hide()

func exit_game():
	ingame = false
	show()

func _on_button_button_down():
	$StartMenu.hide()
	$LevelsMenu.show()


func _on_standard_game_button_down():
	button_pressed = "Standard"
	ingame = true
	hide()

func _on_random_map_button_down():
	button_pressed = "Random_Map"
	ingame = true
	hide()
