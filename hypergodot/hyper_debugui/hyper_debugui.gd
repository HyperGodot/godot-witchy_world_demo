extends Control

signal gossip_update_rate_changed(seconds)

onready var lGossipUpdateRate : Label = $HypercoreDebugPanel/HypercoreDebugContainer/GossipUpdateRate
onready var gatewayStartStopButton : Button = $HypercoreDebugPanel/HypercoreDebugContainer/GatewayStartStopButton
onready var gatewayStatus : Label = $HypercoreDebugPanel/HypercoreDebugContainer/GatewayStatus_Value
onready var gossipURL : Label = $HypercoreDebugPanel/HypercoreDebugContainer/GossipURL_Value
onready var gossipIDList : ItemList = $HypercoreDebugPanel/HypercoreDebugContainer/GossipIDList_Value

var hyperGateway : HyperGateway
var hyperGossip : HyperGossip


func _ready():
	hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")

func _process(_delta):
	pass
	
func updateGatewayStatus() -> void:
	if(hyperGateway.getIsGatewayRunning() ):
		gatewayStatus.text = "Listening on Port " + String( hyperGateway.getGatewayPort() ) + " (PID " + String( hyperGateway.getGatewayPID() ) + ")"
		gossipURL.text = hyperGossip.url
		gatewayStartStopButton.text = "Stop Gateway"
	else:
		gatewayStatus.text = "Not Running"
		gossipURL.text = "N/A"
		gatewayStartStopButton.text = "Start Gateway"


func _on_GatewayStartStopButton_button_up() -> void:
	gatewayStartStopButton.release_focus()
	if(!hyperGateway):
		# TODO : Make this find a potential HyperGateway node based on classtype, and not assuming scene root node name is Spatial.
		hyperGateway = get_node("../HyperGateway")
	if(hyperGateway):
		if( hyperGateway.getIsGatewayRunning() ):
			hyperGateway.stop()
		else:
			hyperGateway.start()

func _on_GossipUpdateRate_Value_value_changed(value : float) -> void:
	lGossipUpdateRate.text = "Snapshot in " + String(value) + " Seconds: "
	emit_signal("gossip_update_rate_changed", value)


func addGossipIDToList(gossipID) -> void :
	gossipIDList.add_item(gossipID, null, false)
