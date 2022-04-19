extends Node

var hyperGateway : HyperGateway
var hyperGossip : HyperGossip
var hyperDebugUI : Control
var localSnapshotTimer : Timer

const knownPlayers = {}

# TODO : Move these out of here and share with Gossip / game-level constants
const EVENT_PLAYER_SNAPSHOT = 'player_snapshot'
const EVENT_PLAYER_WANTSTOJUMP = 'player_wantstojump'
const EVENT_PLAYER_DIRECTION = 'player_direction'
const EVENT_PLAYER_RESPAWNPLAYER = 'player_respawnplayer'
const EVENT_PLAYER_MAPCHANGE = 'player_mapchange'
const EVENT_PLAYER_SHOOT_GRAPPLINGHOOK = 'player_shoot_grapplinghook'
const EVENT_PLAYER_RELEASE_GRAPPLINGHOOK = 'player_release_grapplinghook'
const EVENT_PLAYER_TOGGLE_LIGHT = 'player_toggle_light'

var PlayerCoreLocal = preload("res://game/player/player_core_local.tscn")
var PlayerCoreRemote = preload("res://game/player/player_core_remote.tscn")
var PlayerCoreLocalDebugUI = preload("res://game/player/player_core_local_debugui.tscn")

func _ready():
	hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	hyperDebugUI = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperDebugUI")
	localSnapshotTimer = get_tree().get_current_scene().get_node("HyperGodot").get_node("LocalSnapshotTimer")

func _process(_delta):
	pass

func _perform_setup():
	hyperGossip.start_listening()
	
func _on_HyperGateway_started_gateway(_pid : int):
	if !hyperGateway:
		hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	if !hyperGossip:
		hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	#if !debugui:
	#	debugui = get_tree().get_current_scene().get_node("HyperGodotDebugUI")
	if(hyperDebugUI):
		hyperDebugUI.updateGatewayStatus()
	_perform_setup()

func _on_HyperGateway_stopped_gateway():
	if(hyperDebugUI):
		hyperDebugUI.updateGatewayStatus()


func _on_HyperDebugUI_gossip_update_rate_changed(seconds: float):
	localSnapshotTimer.wait_time = seconds
	localSnapshotTimer.start(seconds)


func _on_LocalSnapshotTimer_timeout():
	var snapShotData : Dictionary
	if hyperGateway.getIsGatewayRunning():
		snapShotData = getPlayerLocalSnapshotData()
		
		hyperGossip.broadcast_event(EVENT_PLAYER_SNAPSHOT, snapShotData)
		
func _on_HyperGossip_listening(_extension_name):
	var snapShotData : Dictionary = getPlayerLocalSnapshotData()
	hyperGossip.broadcast_event(EVENT_PLAYER_SNAPSHOT, snapShotData)

# TODO : Get these out of here and into player_core or player_core_remote
func _on_HyperGossip_event(type, data, from):
	if type == EVENT_PLAYER_SNAPSHOT:
		updatePlayerWithSnapshot(data, from)
	elif type == EVENT_PLAYER_WANTSTOJUMP:
		updatePlayer_wantstojump(data, from)
	elif type == EVENT_PLAYER_DIRECTION:
		updatePlayer_direction(data, from)
	elif type == EVENT_PLAYER_RESPAWNPLAYER:
		updatePlayer_respawnPlayer(data, from)
	elif type == EVENT_PLAYER_MAPCHANGE:
		updatePlayer_mapchange(data, from)
	elif type == EVENT_PLAYER_SHOOT_GRAPPLINGHOOK:
		updatePlayer_shootGrapplingHook(data, from)
	elif type == EVENT_PLAYER_RELEASE_GRAPPLINGHOOK:
		updatePlayer_releaseGrapplingHook(data, from)
	elif type == EVENT_PLAYER_TOGGLE_LIGHT:
		updatePlayer_toggleLight(data, from)
	
func get_player_object(id):
	if knownPlayers.has(id):
		return knownPlayers[id]

	var remotePlayer = PlayerCoreRemote.instance()
	knownPlayers[id] = remotePlayer
	
	hyperDebugUI.addGossipIDToList(id)

	get_tree().get_current_scene().get_node("Players").add_child(remotePlayer)

	return remotePlayer
	
func updatePlayer_shootGrapplingHook(data, id):
	var remotePlayer = get_player_object(id)
	
	var translation : Vector3 = Vector3(data.translation.x, data.translation.y, data.translation.z)
	var direction : Vector3 = Vector3(data.direction.x, data.direction.y, data.direction.z)
	var velocity : Vector3 = Vector3(data.velocity.x, data.velocity.y, data.velocity.z)
	var grapple_position : Vector3 = Vector3(data.grapple_position.x, data.grapple_position.y, data.grapple_position.z)
	
	remotePlayer.playerCoreNetworkDataUpdate_Types(translation, direction, velocity)
	remotePlayer.grapplingHook_GrapplePosition = grapple_position
	remotePlayer.playerWantsToShootGrapplingHook = true
	
func updatePlayer_releaseGrapplingHook(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.playerCoreNetworkDataUpdate(data)
	remotePlayer.playerWantsToReleaseGrapplingHook = true
	
func updatePlayerWithSnapshot(data, id):
	var remotePlayer = get_player_object(id)

	var translation : Vector3 = Vector3(data.translation.x, data.translation.y, data.translation.z)
	var meshDirection : Vector3 = Vector3(data.meshDirection.x, data.meshDirection.y, data.meshDirection.z)
	var lookingDirection : Vector3 = Vector3(data.lookingDirection.x, data.lookingDirection.y, data.lookingDirection.z)
	
	remotePlayer.snapShotUpdate(
		translation,
		meshDirection,
		lookingDirection
	)
	
func updatePlayer_wantstojump(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.playerCoreNetworkDataUpdate(data)
	remotePlayer.playerWantsToJump = true
	
func updatePlayer_toggleLight(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.playerCoreNetworkDataUpdate(data)
	remotePlayer.playerWantsToToggleLight = true
	
func updatePlayer_mapchange(data, _id):
	var newMapName = data.map.name
	# TODO : Do this elsewhere
	var playerDebugUI = get_tree().get_current_scene().get_node("Players").get_node("PlayerLocal").get_node("PlayerDebugUI")
	playerDebugUI.tryMapChange(newMapName, false)
	
func updatePlayer_respawnPlayer(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.currentSpawnLocation = Vector3(data.spawnLocation.x, data.spawnLocation.y, data.spawnLocation.z)
	remotePlayer.respawnPlayer()
	
func updatePlayer_direction(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.playerCoreNetworkDataUpdate(data)

func getPlayerLocalSnapshotData() -> Dictionary:
	var snapshotPlayer : KinematicBody = get_tree().get_current_scene().get_node("Players").get_node("PlayerLocal")
	var translation : Vector3 = snapshotPlayer.translation
	var meshDirection : Vector3 = Vector3(0, snapshotPlayer.meshNode.rotation.y, 0)
	var lookingDirection : Vector3 = snapshotPlayer.currentDirection
	
	var data : Dictionary = {
		#"profile": profile,
		"translation": {
			"x": translation.x,
			"y": translation.y,
			"z": translation.z
		},
		"meshDirection": {
			"x": meshDirection.x,
			"y": meshDirection.y,
			"z": meshDirection.z
		},
		"lookingDirection": {
			"x": lookingDirection.x,
			"y": lookingDirection.y,
			"z": lookingDirection.z
		}
	}

	return data
