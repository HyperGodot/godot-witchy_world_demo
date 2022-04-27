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

func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1920, 1080))

func _on_quit_pressed():
	get_tree().quit()

func _on_Resume_pressed():
	# Hide UI (for now)
	ui.hide()

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


func _on_Multiplayer_pressed():
	main.hide()
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
