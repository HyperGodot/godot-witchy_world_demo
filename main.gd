extends Node

#onready var map_witch_island = preload("res://game/maps/map_witch_island/map_witch_island.scn")
#onready var map_cyber_environment = preload("res://assets/maps/map_cyber/map_cyber_environment.scn")
#onready var map_cyber1_environment = preload("res://assets/maps/map_cyber1/map_cyber1_environment.scn")

func _ready():
	pass


func _process(delta):
	pass

func getSpawnLocation(bodyNode, mapNode) -> Vector3:
	# Get Number of Maps
	var childCount : int = self.get_child(0).get_child_count()
	
	# Get Random Spawn Location from Map
	var playerSpawnNodes = mapNode.find_node("PlayerSpawnNodes", true, false)
	# Get Number of Spawn Nodes
	childCount = playerSpawnNodes.get_child_count()
	# Get Random Spawn Node
	var spawnNode : Spatial = playerSpawnNodes.get_child( randi() % childCount )
	# Get Global Space
	var globalCoord = spawnNode.global_transform.origin
	
	# Return!
	return spawnNode.global_transform.origin
	
func PurgeAllWorldEnvironmentNodes():
	var worldEnvironment = find_node("WorldEnvironment", true, false)
	while(worldEnvironment != null):
		worldEnvironment.free()
		worldEnvironment = find_node("WorldEnvironment", true, false)
