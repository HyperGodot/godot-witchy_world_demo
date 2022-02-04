tool extends EditorPlugin
"""========================================================
°                         TimeOfDay.
°                   ======================
°
°   Category: Plugin.
°   -----------------------------------------------------
°   Description:
°       Editor Plugin.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================"""
const __skydome_script: Script = preload("res://addons/jc.godot.time-of-day/Code/Sky/Skydome.gd")
const __skydome_icon: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Gizmos/SkyIcon.png")

const __time_of_day_script: Script = preload("res://addons/jc.godot.time-of-day/Code/TimeOfDay/TimeOfDay.gd")
const __time_of_day_icon: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Gizmos/SkyIcon.png")

func _enter_tree() -> void:
	add_custom_type("Skydome", "Node", __skydome_script, __skydome_icon)
	add_custom_type("TimeOfDay", "Node", __time_of_day_script, __time_of_day_icon)

func _exit_tree() -> void:
	remove_custom_type("Skydome")
	remove_custom_type("TimeOfDay")
