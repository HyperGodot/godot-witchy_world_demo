extends Spatial

onready var collisionShape = $Area/CollisionShape


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#PrepareSignalsWithChildCollisionNode()
	
	var aChildren = self.get_children()
	var maskNode = self
	var error
	
	# for i in range(0, aChildren.size() ):
	#	if aChildren[i] is Area:
	#		# Connect the Signal
	#		error = aChildren[i].connect("ready", maskNode, "_on_ready")
	
func PrepareSignalsWithChildCollisionNode():
	var aChildren = self.get_children()
	var maskNode = self
	var error
	
	for i in range(0, aChildren.size() ):
		if aChildren[i] is Area:
			# Connect the Signal
			error = aChildren[i].connect("body_entered", maskNode, "_on_body_entered")
	
func getMaskName() -> String:
	return self.name.substr(4, -1)
	
func DisableCollisionShape():
	#collisionShape.disabled = true
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body : Node):
	if body is KinematicBody:
		body.mask_SetNewMaskName( self.name )
		
