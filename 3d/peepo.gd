extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var animtree = $peepo/AnimationTree
@onready var animplayer = $peepo/AnimationPlayer
@onready var mouth = $peepo/Armature/Skeleton3D/mouth
@onready var sfx = $walkingsound
@onready var msg_label = $message_text
@onready var model = $peepo
@onready var timer = $Timer

var SPEED = 5.0
var SAFE_DIST = 4.5
var ACCEL = 0.25
var LERP_VAL = 0.1
var PHONEMES = 5 # manual update
var TALKING_FRAME = 0.09

var talking_time = 0
var talking = 0
var talking_msg = ""
var msg_length = 0
var size_delta = 0.005
var speed_scale = 0.8
var wait_time = 0.8

func _ready():
	randomize()
	var adj = randf_range(-0.4,0.2)
	speed_scale = speed_scale + adj/2
	SPEED += adj*2
	sfx.pitch_scale += adj/2
	timer.wait_time = wait_time
 
func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_location()
	
	var new_velocity = (next_location - current_location).normalized()*SPEED
	
	if nav_agent.distance_to_target() < SAFE_DIST:
		new_velocity = velocity.move_toward(Vector3(0,0,0),ACCEL)
		var direction = (next_location - current_location).normalized()
		rotation.y = lerp_angle(rotation.y, atan2(direction.x,direction.z), LERP_VAL)
		if sfx.playing:
			sfx.stop()
	else:
		new_velocity = velocity.move_toward(new_velocity,ACCEL)
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x,velocity.z), LERP_VAL)
		if not sfx.playing or velocity.length() < 0.5:
			sfx.play()
	nav_agent.set_velocity(new_velocity)
	
	animtree.set("parameters/TimeScale/scale",1+speed_scale*new_velocity.length()/SPEED)
	animtree.set("parameters/BlendSpace1D/blend_position",new_velocity.length()/SPEED)
	
	if talking == 1 and timer.is_stopped():
		var new_talking_time = wrapf(talking_time+delta, 0, TALKING_FRAME)
		
		model.scale = model.scale+Vector3(1,1,1)*size_delta
		
		if talking_time > new_talking_time:
			model.scale = Vector3(1,1,1)
			change_phoneme(1)
			size_delta = -size_delta
		talking_time = new_talking_time
		
		msg_length += TALKING_FRAME*2.5
		msg_label.text = talking_msg.substr(0,int(msg_length))
		
		
		
func text_to_speech(new_talking,msg):
	
	talking = new_talking
	
	if talking == 1:
		msg_label.text= ""
		talking_msg = msg
		msg_label.visible = true
	else: # on end talking
		model.scale = Vector3(1,1,1)
		size_delta = abs(size_delta)
		timer.start()
		msg_label.text = talking_msg
		
#animate face shape keys
func change_phoneme(change):
	var rand_value = randi_range(0,PHONEMES)
	for ph in range(PHONEMES):
		if ph == rand_value and change == 1:
			mouth.set_blend_shape_value(ph,1)
		else:
			mouth.set_blend_shape_value(ph,0)

func update_target_location(target_location):
	nav_agent.set_target_location(target_location)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity,ACCEL)
	move_and_slide()


func _on_timer_timeout():
	msg_label.visible = false
	msg_length = 0
	timer.stop()
	timer.wait_time = wait_time
