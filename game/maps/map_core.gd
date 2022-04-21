extends Spatial

onready var playerSpawnNodes : Node = find_node("PlayerSpawnNodes")

export(String) var map_name : String = ""
export(NodePath) var map_asset_node : NodePath

var scatterAreas : Array
var scatterAreasFound = false

func _ready():
	randomize()
	addGrapplingHookCollisionMaskToMap()

func _process(_delta):
	pass
	
func toggleScatterAreaVisibility():
	if(!scatterAreasFound):
		getListOfScatterNodes(self, 0)
		scatterAreasFound = true
		
	var numAreas : int = scatterAreas.size()
	
	for cnt in range(0, numAreas):
		# scatterAreas[cnt].visible = !scatterAreas[cnt].visible
		if(scatterAreas[cnt] == null):
			scatterAreas[cnt].free()
		
func getListOfScatterNodes(_Node, indentLevel : int):
	var _strIndents : String = ""
	for _i in range(indentLevel):
		_strIndents += "\t"
		
	if( str(_Node.name).begins_with("Scatter") and (str(_Node.name).length() == 7 or (str(_Node.name).length() == 8) ) ):
		# scatterAreas.append(_Node)
		_Node.free()
		
	var childCount = _Node.get_child_count()
	for i in range(childCount):
		getListOfScatterNodes(_Node.get_child(i), indentLevel + 1)
	
func getSpawnLocation() -> Vector3:
	var childCount : int = playerSpawnNodes.get_child_count()
	var spawnNode : Spatial = playerSpawnNodes.get_child( randi() % childCount )
	return spawnNode.global_transform.origin
	
func getInstanceOfMapWorldEnvironmentScene():
	var path = "res://assets/maps/" + map_name + "/" + map_name + "_environment.scn"
	var worldEnvironment = load(path)
	return worldEnvironment
	
func updateMapWorldEnvironmentScene():
	# First check to see if we need to delete any existing World Environments
	get_tree().get_current_scene().PurgeAllWorldEnvironmentNodes()
		
	# Spawn in new World Environment
	var worldEnvironment = getInstanceOfMapWorldEnvironmentScene()
	if(worldEnvironment != null):
		add_child(worldEnvironment.instance())

func addGrapplingHookCollisionMaskToMap():
	checkAndSetChildrenGrapplingHookMask(self, 0)
				
func checkAndSetChildrenGrapplingHookMask(var _Node, indentLevel : int):
	var _strIndents : String = ""
	for _i in range(indentLevel):
		_strIndents += "\t"
		
	if(_Node is StaticBody):
		_Node.collision_layer += 2
		
	var childCount = _Node.get_child_count()
	for i in range(childCount):
		checkAndSetChildrenGrapplingHookMask(_Node.get_child(i), indentLevel + 1)


func _on_Area_body_entered(body, map_name):
	if(body is KinematicBody):
		var mapNode = get_tree().get_current_scene().find_node(map_name, true, false)
		body.currentMap = mapNode
		body.playerWantsNewWorldEnvironment = true
		
