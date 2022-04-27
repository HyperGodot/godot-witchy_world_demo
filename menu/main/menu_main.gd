extends Node

var res_loader: ResourceInteractiveLoader = null
var loading_thread: Thread = null

signal replace_main_scene
#warning-ignore:unused_signal
signal quit # Useless, but needed as there is no clean way to check if a node exposes a signal

onready var ui = $Menu_Main
onready var main = ui.get_node(@"Main")
onready var play_button = main.get_node(@"Resume")
onready var settings_button = main.get_node(@"Settings")
onready var quit_button = main.get_node(@"Quit")

onready var settings_menu = ui.get_node(@"Settings")
onready var settings_actions = settings_menu.get_node(@"Actions")
onready var settings_action_apply = settings_actions.get_node(@"Apply")
onready var settings_action_cancel = settings_actions.get_node(@"Cancel")

onready var multiplayer_menu = ui.get_node(@"Multiplayer")
onready var multiplayer_LabelGWStatus = multiplayer_menu.get_node(@"HyperGatewayStatus").get_node(@"LabelGWStatus")
onready var multiplayer_StartGW = multiplayer_menu.get_node(@"Gateway").get_node(@"Start")
onready var multiplayer_StopGW = multiplayer_menu.get_node(@"Gateway").get_node(@"Stop")
onready var multiplayer_PortInput = multiplayer_menu.get_node(@"HyperGatewayPort").get_node(@"LineEdit")

onready var gi_menu = settings_menu.get_node(@"GI")
onready var gi_high = gi_menu.get_node(@"High")
onready var gi_low = gi_menu.get_node(@"Low")
onready var gi_disabled = gi_menu.get_node(@"Disabled")

onready var aa_menu = settings_menu.get_node(@"AA")
onready var aa_8x = aa_menu.get_node(@"8x")
onready var aa_4x = aa_menu.get_node(@"4x")
onready var aa_2x = aa_menu.get_node(@"2x")
onready var aa_disabled = aa_menu.get_node(@"Disabled")

onready var bloom_menu = settings_menu.get_node(@"Bloom")
onready var bloom_high = bloom_menu.get_node(@"High")
onready var bloom_low = bloom_menu.get_node(@"Low")
onready var bloom_disabled = bloom_menu.get_node(@"Disabled")

var hyperGatewayNode = null
var hyperGatewayURL : String = ""
var hyperGatewayPID : int = 0
var hyperGatewayPort : int = 0

var hyperGWPortInputBackup : String = ""

func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1440, 810))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _getIsMenuShowing() -> bool:
	return ui.visible

func _on_quit_pressed():
	get_tree().quit()
	
func hideUI():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ui.hide()
	
func showUI():
	# resetUI()
	ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func resetUI():
	settings_menu.hide()
	multiplayer_menu.hide()
	main.show()

func _on_Resume_pressed():
	# Hide UI (for now)
	hideUI()

func _on_Quit_pressed():
	get_tree().quit()


func _on_Settings_pressed():
	main.hide()
	settings_menu.show()
	settings_action_cancel.grab_focus()

	if Settings.gi_quality == Settings.GIQuality.HIGH:
		gi_high.pressed = true
	elif Settings.gi_quality == Settings.GIQuality.LOW:
		gi_low.pressed = true
	elif Settings.gi_quality == Settings.GIQuality.DISABLED:
		gi_disabled.pressed = true

	if Settings.aa_quality == Settings.AAQuality.AA_8X:
		aa_8x.pressed = true
	elif Settings.aa_quality == Settings.AAQuality.AA_4X:
		aa_4x.pressed = true
	elif Settings.aa_quality == Settings.AAQuality.AA_2X:
		aa_2x.pressed = true
	elif Settings.aa_quality == Settings.AAQuality.DISABLED:
		aa_disabled.pressed = true

	if Settings.bloom_quality == Settings.BloomQuality.HIGH:
		bloom_high.pressed = true
	elif Settings.bloom_quality == Settings.BloomQuality.LOW:
		bloom_low.pressed = true
	elif Settings.bloom_quality == Settings.BloomQuality.DISABLED:
		bloom_disabled.pressed = true
		
func _UpdateHyperGatewayInfo():
	multiplayer_StartGW.disabled = true
	multiplayer_StopGW.disabled = true
	
	if(hyperGatewayNode != null):
		if(hyperGatewayNode is HyperGateway):
			hyperGatewayPID = hyperGatewayNode.getGatewayPID()
			hyperGatewayPort = hyperGatewayNode.getGatewayPort()
			
			if( hyperGatewayNode.getIsGatewayRunning() ):
				multiplayer_StopGW.disabled = false
				multiplayer_LabelGWStatus.text = "Running (PID " + str(hyperGatewayPID) + ") on Port " + str(hyperGatewayPort)
			else:
				multiplayer_StartGW.disabled = false
				multiplayer_LabelGWStatus.text = "Not Running"

func _on_Multiplayer_pressed():
	main.hide()
	# Check for HyperGateway Node
	if(hyperGatewayNode == null):
		hyperGatewayNode = get_tree().get_current_scene().find_node("HyperGateway")
	_UpdateHyperGatewayInfo()
			
	multiplayer_menu.show()

func _on_Apply_pressed():
	main.show()
	# play_button.grab_focus()
	settings_menu.hide()

	if gi_high.pressed:
		Settings.gi_quality = Settings.GIQuality.HIGH
	elif gi_low.pressed:
		Settings.gi_quality = Settings.GIQuality.LOW
	elif gi_disabled.pressed:
		Settings.gi_quality = Settings.GIQuality.DISABLED

	if aa_8x.pressed:
		Settings.aa_quality = Settings.AAQuality.AA_8X
	elif aa_4x.pressed:
		Settings.aa_quality = Settings.AAQuality.AA_4X
	elif aa_2x.pressed:
		Settings.aa_quality = Settings.AAQuality.AA_2X
	elif aa_disabled.pressed:
		Settings.aa_quality = Settings.AAQuality.DISABLED

	if bloom_high.pressed:
		Settings.bloom_quality = Settings.BloomQuality.HIGH
	elif bloom_low.pressed:
		Settings.bloom_quality = Settings.BloomQuality.LOW
	elif bloom_disabled.pressed:
		Settings.bloom_quality = Settings.BloomQuality.DISABLED

	Settings.save_settings()


func _on_Cancel_pressed():
	main.show()
	# play_button.grab_focus()
	settings_menu.hide()


func _on_Multiplayer_Cancel_pressed():
	main.show()
	# play_button.grab_focus()
	multiplayer_menu.hide()


func _on_Multiplayer_Apply_pressed():
	main.show()
	# play_button.grab_focus()
	multiplayer_menu.hide()


func _on_Start_pressed():
	hyperGatewayNode.start()
	_UpdateHyperGatewayInfo()


func _on_Stop_pressed():
	hyperGatewayNode.stop()
	multiplayer_PortInput
	_UpdateHyperGatewayInfo()


func _on_HyperGWPort_LineEdit_text_changed(new_text : String):
	if(new_text.length() < 1 or new_text.is_valid_integer()):
		hyperGWPortInputBackup = new_text
	else:
		multiplayer_PortInput.text = hyperGWPortInputBackup
