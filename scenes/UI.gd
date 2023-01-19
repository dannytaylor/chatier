extends Control

@onready var circle = $circle

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	circle.scale = lerp(circle.scale, Vector2(0.0,0.0),0.02)
	if circle.scale.length() < 0.01:
		circle.visible = false
		process_mode = false
