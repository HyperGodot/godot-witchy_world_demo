extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Find the Collision Mesh and Remove it!
	var collision : CollisionShape = find_node("shape0")
	if(collision != null):
		collision.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
