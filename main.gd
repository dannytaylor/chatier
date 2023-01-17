extends Node

@onready var player = $player

# peepo pathfinding
func _physics_process(_delta):
	get_tree().call_group("peepos","update_target_location",player.global_transform.origin)

