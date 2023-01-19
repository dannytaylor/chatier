extends Node3D

var gamba = false
var won = false

var WINDUP = PI*2.0*160.0
var SPACING = PI*2.0*80.0 # rotations/sec
var SPEED = PI/(300.0)
var LERP_VAL = 0.01
var spins = []

@onready var timeout = $TimeOut
@onready var sfx_pull = $sfx_pull
@onready var sfx_win = $sfx_win

var emission = 0.0
@onready var stars_mat = $stars.get_active_material(0)

@export var peepo: Node3D
var mouth: Node3D

class Spinner:
	var mesh = Mesh.new()
	var windup = 0.0
	var result = 0
	var result_rot = 0.0
	
	func _init(m):
		mesh = m
	
	func new_result():
		result = randi_range(0,9)
		result_rot = -(result-1)*(2.0*PI/10.0) # turn offset

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for s in $spins.get_children():
		var spinner = Spinner.new(s)
		spins.append(spinner)
		
	peepo.state = 1
	peepo.get_node('peepo/AnimationTree').set("parameters/state/blend_amount",1.0)
	mouth = peepo.get_node("peepo/Armature/Skeleton3D/mouth")
	
	timeout.wait_time = randf_range(0.0,2.0)
	timeout.start()
	
	stars_mat = stars_mat.duplicate()
	$stars.set_surface_override_material(0,stars_mat)
	stars_mat.albedo_color = Color(0,0,0,1.0)
	stars_mat.emission_energy_multiplier = emission
	
	
func pull():
	won = false
	gamba = true
	$number.visible = false
	
	emission = 0.0
	
	sfx_pull.play()
	sfx_pull.volume_db = -12
	
	mouth.set_blend_shape_value(3,0.5)
	mouth.set_blend_shape_value(4,0.5)
	
	$AnimationPlayer.play("gamba_pull")
	peepo.get_node('peepo/AnimationTree').set("parameters/gamba_pull_shot/active",true)
	gamba = true
	var windup = 0.0
	for s in spins:
		s.windup = WINDUP + windup
		windup += SPACING
		s.new_result()
		s.mesh.rotation.x = s.windup
		# print(s.windup," ",s.result," ",s.result_rot)

func end_spin():
	gamba = false
	var val = ""
	for s in spins:
		val += str(s.result)
	val = int(val)
	print(val)
	
	$number.text = str(val)
	$number.visible = true
	$number.position.x = 0.5
	
	sfx_pull.stop()
	if val % 3 == 0:
		win()
		timeout.wait_time = 5.0
		print('WINNER?!')
	else:
		timeout.wait_time = randf_range(1.0,3.0)
	timeout.start()

	
func win():
	won = true
	peepo.get_node('peepo/AnimationTree').set("parameters/gamba_win_shot/active",true)
	mouth.set_blend_shape_value(3,0.0)
	mouth.set_blend_shape_value(4,0.0)
	sfx_win.play()

	
func _process(_delta):
	if gamba:
		var finished = false
		for s in spins:
			s.windup = lerp(s.windup,s.result_rot,SPEED)
			s.mesh.rotation.x = s.windup
			if s.mesh.rotation.x > (s.result_rot - PI/64) and s.mesh.rotation.x < (s.result_rot + PI/64):
				finished = true
				
		sfx_pull.volume_db = lerp(sfx_pull.volume_db,-36.0,LERP_VAL/8)
		if finished:
			end_spin()
			
	if won:
		emission += _delta
		stars_mat.emission_energy_multiplier = pingpong(emission,0.3)*15
	else:
		stars_mat.emission_energy_multiplier = lerp(stars_mat.emission_energy_multiplier,emission,LERP_VAL*2)
	if $number.visible:
		$number.position.x -= LERP_VAL/8
		if $number.position.x < -0.2:
			$number.visible = false

	if not gamba and timeout.is_stopped():
		pull()
		
