extends Panel

const structures = {
	"House":[{"Cost":{"Wood":4,"Rock":8},"Upkeep":{"Water":1,"Food":1},"Output":{"Max_Population":4}},{},{}],
	"Farm":[{"Cost":{"Wood":6,"Metal":5},"Upkeep":{"Water":3,"Population":1},"Output":{"Food":3}},{},{}],
	"Lumber Mill":[{"Cost":{"Wood":8},"Upkeep":{"Population":1},"Output":{"Wood":1}},{},{}],
	"Wind Turbine":[{"Cost":{"Wood":15},"Upkeep":{"Population":3},"Output":{"Energy":2}},{},{}],
	"Pump":[{"Cost":{"Wood":5,"Rock":4},"Upkeep":{"Population":1,"Energy":1},"Output":{"Water":8}},{},{}],
	"Storage":[{"Cost":{"Wood":10,"Rock":8},"Upkeep":{},"Output":{"Max_Energy":20,"Max_Wood":20,"Max_Water":20,"Max_Rock":20,"Max_Metal":20}},{},{}],
	"Mines":[{"Cost":{"Wood":10},"Upkeep":{"Population":4,"Energy":1},"Output":{"Rock":2}},{},{}]
}

const atlas_dict = {
	"Wind Turbine":Vector2i(0,0),
	"Farm":Vector2i(1,0),
	"Lumber Mill":Vector2i(2,0),
	"Mines":Vector2i(3,0),
	"House":Vector2i(4,0),
	"None":Vector2i(5,0)
}

const image_files = {
	"Wood":"res://Assets/GUI/Wood.png",
	"Rock":"res://Assets/GUI/Stone.png",
	"Metal":"res://Assets/GUI/metal.png"
}

var sprites = []

func refresh_structure_list(available):
	for y in range(5):
		$Structure_List.set_cell(0,Vector2i(0,y),0,atlas_dict["None"])
	for y in range(available.size()):
		$Structure_List.set_cell(0,Vector2i(0,y),0,atlas_dict[available[y]["Name"]])
		var xpos = 0
		for mat in structures[available[y]["Name"]][0]["Cost"]:
			make_sprite(mat,xpos,y,structures[available[y]["Name"]][0]["Cost"][mat])
			xpos+=1
	
	
func make_sprite(image,x,y,val):
	var sprite = Sprite2D.new()
	sprite.texture = load(image_files[image])
	sprite.scale = Vector2(0.5,0.5)
	sprite.position = Vector2(105,40)+$Structure_List.position+Vector2(x*80,y*80)
	add_child(sprite)
	
	var text = Label.new()
	text.text = str(val)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.position = Vector2(115,40)+$Structure_List.position+Vector2(x*80,y*80)
	add_child(text)
	
	
