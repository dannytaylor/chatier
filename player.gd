extends CharacterBody3D

@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/CameraSpringArm
@onready var camera = $SpringArmPivot/CameraSpringArm/Camera3D
@onready var sfx = $AudioStreamPlayer
@onready var listener = $AudioListener3D

@onready var armature = $shindigs/Armature
@onready var animtree = $shindigs/AnimationTree
# peepo model drop in
#@onready var armature = $peepo/Armature
#@onready var animtree = $peepo/AnimationTree

const SPEED = 10.0
const JUMP_VELOCITY = 7.5
const LERP_VAL = 0.1
const MIN_DB = -30.0
const DELTA_DB = 15.0
const IDLE_TIMEOUT = 6.0
var idle_time = 0.0

enum {NORMAL,GUN,FPS}
var camera_state = NORMAL

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 2 * ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("gun"):
		camera_state = abs(1-camera_state)
	
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * 0.003)
		spring_arm.rotate_x(-event.relative.y * 0.003)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/8, PI/16)
		listener.rotation.y = spring_arm_pivot.rotation.y + PI/4

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		animtree.set("parameters/air/blend_amount",clamp((JUMP_VELOCITY-velocity.y),0,1))
		animtree.set("parameters/grounded-jump/blend_amount",1)
	else:
		animtree.set("parameters/grounded-jump/blend_amount",0)
		
		animtree.set("parameters/jumpshot/active",false)
		

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		animtree.set("parameters/jumpshot/active",false)
		animtree.set("parameters/jumpshot/active",true)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED,LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED,LERP_VAL)
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(velocity.x,velocity.z), LERP_VAL*2)
		armature.rotation.z = lerp_angle(0, input_dir.x*PI/2, LERP_VAL)
		if not sfx.playing:
			sfx.play()
	
		
	else:
		velocity.x = lerp(velocity.x,0.0,LERP_VAL*2)
		velocity.z = lerp(velocity.z,0.0,LERP_VAL*2)
		
		armature.rotation.z = lerp_angle(armature.rotation.z, 0, LERP_VAL)
		
		if sfx.playing:
			if sfx.volume_db <= MIN_DB/2:
				sfx.stop()
				
	if velocity.length() > 0:
		idle_time = 0 
		animtree.set("parameters/idleshot/active",false)
	else:
		idle_time += delta
		
		
	if not is_on_floor():
		sfx.stop()
	
	
	
	var v_fraction = clamp(velocity.length()/SPEED,0,1)
	sfx.volume_db = MIN_DB+v_fraction*DELTA_DB
	
	if idle_time >= IDLE_TIMEOUT:
		animtree.set("parameters/idleshot/active",true)
		idle_time = -3.0
	animtree.set("parameters/ground/blend_amount",v_fraction)
	animtree.set("parameters/TimeScale/scale",1+v_fraction)

	if camera_state == GUN:
		spring_arm.spring_length = lerp(spring_arm.spring_length,3.0,LERP_VAL)
		spring_arm.position.x = lerp(spring_arm.position.x,0.5,LERP_VAL)
		camera.fov = lerp(camera.fov,60.0,LERP_VAL)
	else:
		spring_arm.spring_length = lerp(spring_arm.spring_length,8.0,LERP_VAL)
		spring_arm.position.x = lerp(spring_arm.position.x,0.0,LERP_VAL)
		camera.fov = lerp(camera.fov,45.0,LERP_VAL)
		
		
	move_and_slide()
