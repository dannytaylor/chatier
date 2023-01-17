extends Node3D

@onready var doormesh = $portapotty/door

var LERP_VAL = 0.025
var door_status = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	doormesh.rotation.y =  lerp(doormesh.rotation.y,-PI*2/3*door_status,LERP_VAL)


func _on_door_zone_body_entered(body):
	if 'player' in body.get_groups():
		door_status = 1

func _on_door_zone_body_exited(body):
	if 'player' in body.get_groups():
		door_status = 0
