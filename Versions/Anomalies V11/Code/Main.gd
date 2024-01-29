extends Node2D

var ingame = false
var game
var base_screen_size
var current_screen_size

func _ready():
	base_screen_size = get_viewport_rect()
	current_screen_size = get_viewport_rect()


func _process(delta):
	if $MainMenu.ingame and not ingame:
		start_game()
		ingame = true
		
	var ss = get_viewport_rect()
	if current_screen_size != ss:
		scale = ss.size/base_screen_size.size
		current_screen_size = ss
		
		
func start_game():
	var game_scene = load("res://Scenes/Fins tiles.tscn")
	game = game_scene.instantiate()
	if $MainMenu.button_pressed == "Random_Map":
		game.load_map("Random")
		
	game.request_ready()
	add_child(game)
	
	
	
		
