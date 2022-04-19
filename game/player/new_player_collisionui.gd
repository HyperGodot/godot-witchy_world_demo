extends Control

onready var itemList : ItemList = $Panel/MarginContainer/ItemList


func _ready():
	itemList.add_item("Active Collisions", null, false)
	itemList.add_item("", null, false)


func _process(_delta):
	pass

		
func populateItemList(collisions : Dictionary) -> void:
	itemList.clear()
	itemList.add_item("Active Collisions", null, false)
	itemList.add_item("", null, false)
	for i in collisions:
		itemList.add_item(collisions[i], null, false)
		itemList.add_item( String(i), null, false)
		
func zebraNode(child : Node, zebra : bool) -> void:
	var parent = child.get_parent()
	if(parent is MeshInstance):
		if(zebra):
			var material : SpatialMaterial = SpatialMaterial.new()
			material.albedo_color = Color(188, 0, 0)
			parent.material_override = material
		else:
			parent.material_override = null


func onNewCollision(body : Node, collisions : Dictionary):
	collisions[body.get_instance_id()] = body.name
	populateItemList(collisions)
	zebraNode(body, true)
		


func onRemovedCollision(body : Node, collisions : Dictionary):
	collisions.erase(body.get_instance_id())
	populateItemList(collisions)
	zebraNode(body, false)
