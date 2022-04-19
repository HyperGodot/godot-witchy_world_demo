extends Node

onready var meshNode : Spatial = get_node("../Mesh")
onready var clippedCamera : Spatial = get_node("../Head/CamPivot/ClippedCamera")
onready var clippedCameraHead : Spatial = get_node("../Head")
onready var clippedCameraPivot : Spatial = get_node("../Head/CamPivot")

signal player_restore_origin()
signal player_mousemotion_event(event)
signal player_action_jump()
signal player_action_roll()
signal player_move(inputDirection)
signal player_change_physics_mode()
signal player_shoot()

var previousInputDirection : Vector3 = Vector3.ZERO
var mouseMovementChanged : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	clippedCamera.add_exception(get_parent())

func _process(_delta):
	var inputDirection : Vector3 = Vector3.ZERO
	# Calculate Direction Vector
	if( Input.is_action_pressed("right") ):
		inputDirection.x += 1
	if( Input.is_action_pressed("left") ):
		inputDirection.x -= 1
	if( Input.is_action_pressed("backward") ):
		inputDirection.z += 1
	if( Input.is_action_pressed("forward") ):
		inputDirection.z -= 1
		
	var h_rot = clippedCameraHead.global_transform.basis.get_euler().y
	# Adjust Current Direction based on Mouse Direction
	inputDirection = Vector3(inputDirection.x, 0, inputDirection.z).rotated(Vector3.UP, h_rot).normalized()
	
	if(inputDirection != previousInputDirection):
		emit_signal("player_move", inputDirection)
	previousInputDirection = inputDirection
	
func _physics_process(_delta):
	pass

func _input(event : InputEvent):
	if event is InputEventMouseMotion && Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		emit_signal("player_mousemotion_event", event)
		
	if event.is_action_pressed("jump"):
		emit_signal("player_action_jump")
		
	if event.is_action_pressed("shoot"):
		emit_signal("player_shoot")
	
	if event.is_action_pressed("roll"):
		emit_signal("player_action_roll")
		
	if event.is_action_pressed("restoreOrigin"):
		emit_signal("player_restore_origin")
		
	if event.is_action_pressed("changemode"):
		emit_signal("player_change_physics_mode")
		
	#if Input.is_action_pressed("forward") ||  Input.is_action_pressed("backward") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right"):
	#	movementDirection = Vector3.ZERO
	#	movementDirection = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
	#	0,
	#	Input.get_action_strength("forward") - Input.get_action_strength("backward"))
	#	emit_signal("player_move", movementDirection)
