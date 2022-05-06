extends Spatial

export var portal_destination : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func tryGameChange(gameChangeName : String, sendGossip : bool, playerNode):
	OS.execute(OS.get_executable_path(), ["--main-pack", portal_destination], false)
	get_tree().quit()

func _on_CollisionShape_gameplay_entered():
	pass # Replace with function body.

func _on_Hitbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if(body is KinematicBody):
		tryGameChange(portal_destination, true, body)
