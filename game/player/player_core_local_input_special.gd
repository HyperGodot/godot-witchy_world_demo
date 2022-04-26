extends Node

var bDebugPaused : bool = false
var mouseModeBackup

func _ready():
	bDebugPaused = false
	get_tree().paused = false
	mouseModeBackup = Input.get_mouse_mode()
	
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("toggleMouse"):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			mouseModeBackup = Input.get_mouse_mode()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(mouseModeBackup)
	if Input.is_action_just_pressed("toggle_slowmo"):
		if Engine.get_time_scale() < 1.0:
			Engine.set_time_scale(1.0)
		else:
			Engine.set_time_scale(0.1)
	if Input.is_action_just_pressed("toggleScatters"):
		var mapNode = get_tree().get_current_scene().get_node("Maps").find_node("*", true, false)
		mapNode.toggleScatterAreaVisibility()
	if Input.is_action_just_pressed("superDEBUG"):
		# OS.create_process("Tumble.exe", [])
		OS.execute("Tumble.exe", ["--main-pack", "Tumble.pck"], false)
		get_tree().quit()
		#var success = ProjectSettings.load_resource_pack("res://Tumble.pck")
	
		#if success:
			# Now one can use the assets as if they had them in the project from the start.
			# var imported_scene = load("res://main.tscn")
			
			
func _process(_delta):
	pass
