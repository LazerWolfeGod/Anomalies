extends Sprite2D

var vel = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel.y+=2
	if position.y>800:
		vel*=-0.9
	position.y+=vel.y
	position.x+=5
	rotation_degrees+=10
