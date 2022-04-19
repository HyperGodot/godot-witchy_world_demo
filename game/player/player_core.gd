extends KinematicBody

var hyperGossip : HyperGossip

# TODO : These probably should not be in player_core, though I am uncertain yet if they belong elsewhere
const EVENT_PLAYER_SNAPSHOT = 'player_snapshot'
const EVENT_PLAYER_WANTSTOJUMP = 'player_wantstojump'
const EVENT_PLAYER_DIRECTION = 'player_direction'
const EVENT_PLAYER_RESPAWNPLAYER = 'player_respawnplayer'
const EVENT_PLAYER_SHOOT_GRAPPLINGHOOK = 'player_shoot_grapplinghook'
const EVENT_PLAYER_RELEASE_GRAPPLINGHOOK = 'player_release_grapplinghook'
const EVENT_PLAYER_TOGGLE_LIGHT = 'player_toggle_light'

export var mouseSensitivity : float = 0.3
export var movementSpeed : float = 14
export var fallAcceleration : float = 27
export var movementAcceleration : float = 4
export var canJumpHeight : float = 10
export var jumpHeight : float = 15
export var turn_velocity : float = 15
export var cameraLerpAmount : float = 40
export var currentSpeed : float = 0

onready var meshNode : Spatial = $Model
onready var meshSkeletonNode : Skeleton = $Model/Armature/Skeleton
onready var meshSkeletalIKNode : SkeletonIK = $Model/Armature/Skeleton/SkeletonIK
onready var meshSkeletonHiddenHand : MeshInstance = $Model/Armature/Skeleton/player001
onready var meshHandBone : int = meshSkeletonNode.find_bone("DEF-hand.R")
onready var meshHandBonePos : Transform = meshSkeletonNode.get_bone_pose(meshHandBone)

onready var clippedCamera : Spatial = $CameraHead/CameraPivot/ClippedCamera
onready var clippedCameraHead : Spatial = $CameraHead
onready var clippedCameraPivot : Spatial = $CameraHead/CameraPivot
# onready var csgMesh : CSGMesh = $Head/CamPivot/ClippedCamera/GrappleCast/CSGMesh

onready var meshCollisionShape : CollisionShape = $CollisionShape

onready var grappleHookCast : RayCast = $CameraHead/CameraPivot/GrappleHookCast

onready var grappleVisualPoint_1 = $GrapplingHook/GrappleVisualPoint_1
# onready var grappleVisualPoint_2 = $GrapplingHook/GrappleVisualPoint_2
onready var grappleVisualPoint = grappleVisualPoint_1

onready var grappleLineHelper : Spatial = $Model/GrappleLineHelper
onready var grappleVisualLine : CSGCylinder = $Model/GrappleLineHelper/GrappleVisualLine_1
# onready var grappleVisualLine : = $Model/GrappleLineHelper/GrappleVisualLine_2

onready var grappleIKTarget : Position3D = $GrapplingHook/IKTarget
onready var grapplingHandOriginalScale : Vector3 = Vector3.ZERO

onready var omniLight : OmniLight = $OmniLight

var grapplingHook_GrapplePosition : Vector3 = Vector3.ZERO
var grapplingHook_IsHooked : bool = false
var playerWantsToShootGrapplingHook : bool = false
var playerWantsToReleaseGrapplingHook : bool = false

# TODO : Make Debug UI dynamic and not hardcoded in the core Hyper scripts.
#onready var hyperdebugui : Control = $HyperGodotDebugUI
#onready var hyperdebugui_gateway_startstop_button : Button = $HyperGodotDebugUI/HypercoreDebugPanel/HypercoreDebugContainer/GatewayStartStopButton
#onready var hyperdebugui_gossipid_list : ItemList = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")

onready var currentMap = get_tree().get_current_scene().get_node("Maps").get_child(0)
var originalOrigin : Vector3 = Vector3.ZERO
var currentSpawnLocation : Vector3 = Vector3.ZERO

var currentDirection : Vector3 = Vector3.ZERO
var moveNetworkUpdateAllowed : bool = true

var playerWantsToRespawn : bool = false
var jumpFloorDirection : Vector3 = Vector3(0,1,0)
var playerCanJump : bool = false
var playerWantsToJump : bool = false

var playerWantsNewWorldEnvironment : bool = true
var playerWantsToToggleLight : bool = false

var f_input : float
var h_input : float

var snapVector : float

var kinematicVelocity : Vector3 = Vector3.ZERO

var collisions : Dictionary = {}

var Particles_Land = preload("res://game/player/particles.tscn")

func _ready():
	# Backup Origin
	originalOrigin = self.translation
	
	# Spawn into Map
	currentSpawnLocation = getSpawnLocationForMapName(currentMap.map_name)
	playerWantsToRespawn = true
	
	# Get HyperGossip
	hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	
func snapShotUpdate(_translation : Vector3, _meshDirection : Vector3, _lookingDirection : Vector3):
	self.translation = _translation
	self.meshNode.rotation = _meshDirection
	self.currentDirection = _lookingDirection

func directionUpdate(_direction : Vector3):
	self.currentDirection = _direction
	
func getSpawnLocationForMapName(mapName : String) -> Vector3:
	# Get Map Node
	var mapNode = get_tree().get_current_scene().get_node("Maps").find_node(mapName, true, false)
	if(mapNode == null):
		return get_tree().get_current_scene().get_node("Maps").find_node("map_test", true, false).getSpawnLocation()
	else:
		return mapNode.getSpawnLocation()

func _process(_delta):
	if(currentDirection != Vector3.ZERO):
		meshNode.rotation.y = lerp_angle(meshNode.rotation.y, atan2(-currentDirection.x, -currentDirection.z), turn_velocity * _delta)
	
func grapplingHook_Process():
	grapplingHook_CheckActivation()
	var length : float = grapplingHook_UpdatePlayerVelocityAndReturnHookLength()
	grapplingHook_UpdateVisualLine(length)
	# TODO : BIG Hack to prevent running on remote players
	var _name = self.name
	if(self.name == "PlayerLocal"):
		grapplingHook_UpdateVisualPoint()
	
func grapplingHook_CheckActivation():
	# Activate hook
	if(playerWantsToShootGrapplingHook):
		playerWantsToShootGrapplingHook = false
		playerWantsToReleaseGrapplingHook = false
		grapplingHook_IsHooked = true
		grappleVisualLine.show()
		$Model/Sound_Shoot_GrapplingHook_2.play()
		grappleIKTarget.translation = grapplingHook_GrapplePosition
		grapplingHook_DisappearHand()
		
	elif(playerWantsToReleaseGrapplingHook):
		# Stop grappling
		if(grapplingHook_IsHooked):
			grapplingHook_IsHooked = false
			playerWantsToReleaseGrapplingHook = false
			grappleVisualLine.hide()
			$Model/Sound_Release_GrapplingHook.play()
			grapplingHook_ReappearHand()
	
func grapplingHook_UpdateVisualPoint():
	if grappleHookCast.is_colliding():
		grappleVisualPoint.visible = true
		grappleVisualPoint.translation = grappleHookCast.get_collision_point()
	else:
		grappleVisualPoint.visible = false
		
func grapplingHook_UpdateVisualLine(length : float):
	if(grapplingHook_IsHooked):
		grappleLineHelper.look_at(grapplingHook_GrapplePosition, Vector3.UP)
		grappleVisualLine.height = length
		grappleVisualLine.translation.z = length / -1.80
		
func grapplingHook_UpdatePlayerVelocityAndReturnHookLength() -> float:
	var grapple_speed : float = 0.5
	var rest_length : float = 1
	var max_grapple_speed : float = 2.75
	
	var player2hook := grapplingHook_GrapplePosition - translation # vector from player to hook
	var length := player2hook.length()
	if(grapplingHook_IsHooked):
		# if we more than 4 away from line, don't dampen speed as much
		if(length > 4):
			kinematicVelocity *= .999
		# Otherwise dampen speed more
		else:
			kinematicVelocity *= .9
		
		# Hook's law equation
		var force := grapple_speed * (length - rest_length)
		
		# Clamp force to be less than max_grapple_speed
		if abs(force) > max_grapple_speed:
			force = max_grapple_speed
		
		# Preserve direction, but scale by force
		kinematicVelocity += player2hook.normalized() * force
	
	return length
	
func grapplingHook_DisappearHand():
	meshSkeletonHiddenHand.visible = false
	#var bone = meshSkeletonNode.find_bone("DEF-hand.R")
	#var bonePos = meshSkeletonNode.get_bone_pose(bone)
	#bonePos = bonePos.scaled( Vector3(0.1, 0.1, 0.1) )
	#meshSkeletonNode.set_bone_custom_pose(bone, bonePos)
	
func grapplingHook_ReappearHand():
	meshSkeletonHiddenHand.visible = true
	#var bone = meshSkeletonNode.find_bone("DEF-hand.R")
	#var bonePos = meshSkeletonNode.get_bone_pose(bone)
	#bonePos = bonePos.( Vector3(1, 1, 1) )
	#meshSkeletonNode.set_bone_custom_pose(bone, bonePos)

var jumpingUp : bool
func _physics_process(_delta):
	# Respawn Player here first
	if(playerWantsToRespawn):
		playerWantsToRespawn = false
		respawnPlayer()
		return
	
	# Check for New World Environment
	if(playerWantsNewWorldEnvironment):
		playerWantsNewWorldEnvironment = false
		currentMap.updateMapWorldEnvironmentScene()
		
	# Check for Toggle Light
	if(playerWantsToToggleLight):
		playerWantsToToggleLight = false
		omniLight.visible = !omniLight.visible
		$Model/Sound_ToggleLight_1.play()
	
	# Moving the character
	var y_cache : float = kinematicVelocity.y
	kinematicVelocity = kinematicVelocity.linear_interpolate(currentDirection * movementSpeed, movementAcceleration * _delta)
	kinematicVelocity.y = y_cache
	
	# Vertical velocity
	if(!grapplingHook_IsHooked):
		# Apply Gravity
		kinematicVelocity.y -= fallAcceleration * _delta
		# Check for a Jump
		if(playerWantsToJump):
			playerWantsToJump = false
			if( playerCanJump() ):
				kinematicVelocity.y = jumpHeight
				jumpingUp = true
				$Model/Sound_Jump.play()
	# kinematicVelocity = move_and_slide(kinematicVelocity, Vector3.UP)
	var bPrevOnFloor = is_on_floor()
	y_cache = kinematicVelocity.y
	kinematicVelocity = move_and_slide(kinematicVelocity, Vector3.UP, false, 4, 10.0, true)
	
	if( !bPrevOnFloor and is_on_floor() and y_cache < -17.0):
		var particles = Particles_Land.instance()
		$Model.add_child(particles)
		$Model/Sound_Land.play()
	
	# Calculate Potential Jumping Animation
	if( !is_on_floor() ):
		if(kinematicVelocity.y > 0.1):
			$AnimationTree.set("parameters/air_transition/current", 0)
			$AnimationTree.set("parameters/air_blend/blend_amount", -1)
		elif(kinematicVelocity.y < -0.1):
			$AnimationTree.set("parameters/air_transition/current", 0)
			$AnimationTree.set("parameters/air_blend/blend_amount", 0)
	else:
		$AnimationTree.set("parameters/air_transition/current", 1)
	
	# Calculate Running Animation
	currentSpeed = ( (abs(kinematicVelocity.x) + abs(kinematicVelocity.z) - 7) / 7)
	$AnimationTree.set("parameters/iwr_blend/blend_amount", currentSpeed)
	
	# Update Grappling Hook
	grapplingHook_Process()
	
	# Check for Hand IK from Grappling Hook
	if(grapplingHook_IsHooked):
		meshSkeletalIKNode.start()
	else:
		meshSkeletalIKNode.stop()
		
	
	#	self.linear_velocity.y += jumpHeight
	#	playerWantsToJump = false
		
	#var y_cache = linear_velocity.y
	#linear_velocity = linear_velocity.linear_interpolate(currentDirection * movementSpeed, movementAcceleration * _delta)
	#linear_velocity.y = y_cache
	#linear_velocity = Vector3(currentDirection.x, 0, currentDirection.z).normalized() * movementSpeed * _delta
	#linear_velocity.y = y_cache
	
	#linear_velocity.x += currentDirection.x * movementSpeed * _delta
	#linear_velocity.x = clamp(linear_velocity.x, -3, 3)
	#linear_velocity.z += currentDirection.z * movementSpeed * _delta
	#linear_velocity.z = clamp(linear_velocity.z, -3, 3)
	
	# Handle Jumping / Gravity
	#if is_on_floor():
	#if true:
	#	snapVector = -get_floor_normal()
	#	gravity_vec = Vector3.ZERO
	#else:
	#	snap = Vector3.DOWN
	#	accel = ACCEL_AIR
	#	gravity_vec += Vector3.DOWN * gravity * delta
		
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	snap = Vector3.ZERO
	#	gravity_vec = Vector3.UP * jump
	
	# Actually Movement
	#velocityAmount = velocityAmount.linear_interpolate(currentDirection * movementSpeed, accelerationDefault * delta)
	# finalMovement = velocityAmount + finalgravityVelociy
	
func respawnPlayer():
	kinematicVelocity = Vector3.ZERO
	grapplingHook_IsHooked = false
	playerWantsToShootGrapplingHook = false
	playerWantsToReleaseGrapplingHook = true
	$Model/Sound_Teleport_1.play()
	global_transform.origin = currentSpawnLocation

func playerCanJump() -> bool:
	if( self.is_on_floor() ):
		return true
	else:
		return false

func canJump(state : PhysicsDirectBodyState):
	# Raycast from state to ground based on canJumpHeight and straight down (use self to exclude raycast from intersecting itself)
	var hitDictionary : Dictionary = state.get_space_state().intersect_ray(global_transform.origin, canJumpHeight * jumpFloorDirection, [self])
	# If the dictionary is empty, nothing was hit, so we can't jump
	if hitDictionary.size() == 0:
		return false
	else:
		var collider : StaticBody = hitDictionary.collider

		var parent = collider.get_parent()
		if(parent is MeshInstance):
			if(true):
				var material : SpatialMaterial = SpatialMaterial.new()
				material.albedo_color = Color(0, 188, 0)
				parent.material_override = material
			else:
				parent.material_override = null
		return true

func _on_Input_player_mousemotion_event(event):
	clippedCameraHead.rotate_y(deg2rad(-event.relative.x * mouseSensitivity))
	clippedCameraPivot.rotate_x(deg2rad(-event.relative.y * mouseSensitivity))
	clippedCameraPivot.rotation.x = clamp(clippedCameraPivot.rotation.x, deg2rad(-89), deg2rad(89))


func _on_Input_player_move(direction : Vector3):
	currentDirection = direction
	
	if(moveNetworkUpdateAllowed):
		hyperGossip.broadcast_event(EVENT_PLAYER_DIRECTION, getPlayerLocalCoreNetworkData() )
		moveNetworkUpdateAllowed = false
	#var h_rot = clippedCameraHead.global_transform.basis.get_euler().y
	# Adjust Current Direction based on Mouse Direction
	#currentDirection = Vector3(direction.x, 0, direction.z).rotated(Vector3.UP, h_rot).normalized()


func _on_Input_player_restore_origin() -> void:
	playerWantsToRespawn = true
	var spawnLocation : Vector3 = getSpawnLocationForMapName(currentMap.map_name)
	currentSpawnLocation = spawnLocation
	
	var data : Dictionary = {
	#"profile": profile,
	"spawnLocation": {
		"x": spawnLocation.x,
		"y": spawnLocation.y,
		"z": spawnLocation.z
		}
	}
	
	hyperGossip.broadcast_event(EVENT_PLAYER_RESPAWNPLAYER, data)

func _on_Input_player_change_physics_mode() -> void:
	self.mode += 1
	if(self.mode > RigidBody.MODE_KINEMATIC):
		self.mode = RigidBody.MODE_RIGID


func _on_Input_player_jump():
	playerWantsToJump = true
	hyperGossip.broadcast_event(EVENT_PLAYER_WANTSTOJUMP, getPlayerLocalCoreNetworkData() )
	
func _on_Input_player_shoot_grapplinghook():
	if( Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE ):
		if( grappleHookCast.is_colliding() ):
			playerWantsToShootGrapplingHook = true
			grapplingHook_GrapplePosition = grappleHookCast.get_collision_point()
			hyperGossip.broadcast_event(EVENT_PLAYER_SHOOT_GRAPPLINGHOOK, getPlayerLocalShootGrapplingHookData() )
			
func _on_Input_player_release_grapplinghook():
	if( Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE ):
		if(grapplingHook_IsHooked):
			playerWantsToReleaseGrapplingHook = true
			hyperGossip.broadcast_event(EVENT_PLAYER_RELEASE_GRAPPLINGHOOK, getPlayerLocalCoreNetworkData() )
			
func _on_Input_player_toggle_light():
	playerWantsToToggleLight = true
	hyperGossip.broadcast_event(EVENT_PLAYER_TOGGLE_LIGHT, getPlayerLocalCoreNetworkData() )
	
	
func _checkPlayerCanJump(newBody : PhysicsBody, addedBody : bool) -> void:
	# Check if this is a new body added
	if(addedBody):
		# If we are adding a collision, check if we already can jump
		if(playerCanJump):
			return
			
	var hit = newBody.get_space_state().intersect_ray(Vector3(), canJumpHeight * -jumpFloorDirection, [self])
	
	# Check if any surfaces intersected
	if hit.size() == 0:
		playerCanJump = false
	else:
		playerCanJump = true

func _on_Player_body_entered(body : Node) -> void:
	if(!collisions.has(body.get_instance_id()) ):
		collisions[body.get_instance_id()] = body.name
		$CollisionUI.onNewollision(body, collisions)
		

func _on_Player_body_exited(body : Node) -> void:
	if(collisions.has(body.get_instance_id()) ):
		collisions.erase(body.get_instance_id())
		$CollisionUI.onRemovedCollision(body, collisions)

func _on_MoveNetworkTimer_timeout():
	moveNetworkUpdateAllowed = true
	
func getPlayerLocalCoreNetworkData() -> Dictionary:
	# TODO : Fix finding the local player, and get it out of player_core into player_core_local
	var localPlayer : KinematicBody = get_tree().get_current_scene().get_node("Players").get_node("PlayerLocal")
	var translation : Vector3 = localPlayer.translation
	var direction : Vector3 = localPlayer.currentDirection

	var data : Dictionary = {
	#"profile": profile,
	"translation": {
		"x": translation.x,
		"y": translation.y,
		"z": translation.z
		},
	"direction": {
		"x": direction.x,
		"y": direction.y,
		"z": direction.z
		},
	"velocity": {
		"x": kinematicVelocity.x,
		"y": kinematicVelocity.y,
		"z": kinematicVelocity.z
		}
	}

	return data
	
func getPlayerLocalShootGrapplingHookData() -> Dictionary:
	# TODO : Fix finding the local player, and get it out of player_core into player_core_local
	var localPlayer : KinematicBody = get_tree().get_current_scene().get_node("Players").get_node("PlayerLocal")
	var translation : Vector3 = localPlayer.translation
	var direction : Vector3 = localPlayer.currentDirection

	var data : Dictionary = {
	#"profile": profile,
	"translation": {
		"x": translation.x,
		"y": translation.y,
		"z": translation.z
		},
	"direction": {
		"x": direction.x,
		"y": direction.y,
		"z": direction.z
		},
	"velocity": {
		"x": kinematicVelocity.x,
		"y": kinematicVelocity.y,
		"z": kinematicVelocity.z
		},
	"grapple_position": {
		"x": grapplingHook_GrapplePosition.x,
		"y": grapplingHook_GrapplePosition.y,
		"z": grapplingHook_GrapplePosition.z
		}
	}

	return data

func playerCoreNetworkDataUpdate(data : Dictionary):
	self.translation = Vector3(data.translation.x, data.translation.y, data.translation.z)
	self.currentDirection = Vector3(data.direction.x, data.direction.y, data.direction.z)
	self.kinematicVelocity = Vector3(data.velocity.x, data.velocity.y, data.velocity.z)

func playerCoreNetworkDataUpdate_Types(_translation : Vector3, _currentDirection : Vector3, _kinematicVelocity : Vector3):
	self.translation = _translation
	self.currentDirection = _currentDirection
	self.kinematicVelocity = _kinematicVelocity
