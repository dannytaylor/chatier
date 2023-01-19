extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var uv_scale = 64.0
	for mesh in get_children():
		if mesh is MeshInstance3D:
			print(mesh.mesh.get_surface_count())
			for i in range(mesh.mesh.get_surface_count()):
				mesh.mesh.surface_get_material(i).uv1_scale = Vector3(uv_scale ,uv_scale ,uv_scale )
	
	var player = get_tree().get_nodes_in_group("player")[0]
	player.get_node("SpringArmPivot/CameraSpringArm/Camera3D").far = 40


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
