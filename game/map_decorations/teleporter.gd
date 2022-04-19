extends Spatial

export var teleportation_destination : String = ""

onready var mapsNode : Node = get_tree().get_current_scene().get_node("Maps")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_Teleporter_gameplay_entered():
	pass


func tryMapChange(mapChangeName : String, sendGossip : bool, playerNode):
	var mapCurrentName = playerNode.currentMap.map_name
	var mapNode = null
	if(mapCurrentName != teleportation_destination):
		if(mapChangeName == "map_test"):
			mapNode = mapsNode.find_node("map_test", true, false)
		elif(mapChangeName == "map_cyber"):
			mapNode = mapsNode.find_node("map_cyber", true, false)
		elif(mapChangeName == "map_cyber1"):
			mapNode = mapsNode.find_node("map_cyber1", true, false)
		# Find a Respawn Point
		playerNode.currentSpawnLocation = playerNode.getSpawnLocationForMapName(mapChangeName)
		playerNode.currentMap = mapNode
		playerNode.playerWantsToRespawn = true
		playerNode.playerWantsNewWorldEnvironment = true
		
		if(sendGossip):
			var data : Dictionary = {
			"map": {
				"name": mapChangeName
				}
			}
			#hyperGossip.broadcast_event(EVENT_PLAYER_MAPCHANGE, data)


func _on_CollisionShape_gameplay_entered():
	pass # Replace with function body.


func _on_Hitbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if(body is KinematicBody):
		tryMapChange(teleportation_destination, true, body)
