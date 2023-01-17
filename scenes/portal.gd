extends Node3D

var player
var player_cam
var portals
@export var other_portal: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('player')[0]
	player_cam = player.get_node("SpringArmPivot/CameraSpringArm/Camera3D")
	$SubViewport/Camera3D.fov = player_cam.fov

	$PortalSprite.texture = other_portal.get_node("SubViewport").get_texture()
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Set the portal's camera transform to the player's camera relative to the other portal
	var trans = other_portal.global_transform.inverse() * player_cam.global_transform
	# Rotate by 180 degrees around the up axis because the camera should be facing the opposite way (180 degrees) at the other portal
	trans = trans.rotated(Vector3.UP, PI)
	$CameraTransform.transform = trans

