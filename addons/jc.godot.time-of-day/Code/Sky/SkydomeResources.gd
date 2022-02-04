tool
class_name SkydomeResources extends Resource 
"""========================================================
°                         TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Skydome resources.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================"""

# Mesh.
var _skydome_mesh:= SphereMesh.new()
var _clouds_cumulus_mesh:= SphereMesh.new()
var _full_screen_quad:= QuadMesh.new()

# Materials.
var sky_material:= ShaderMaterial.new()
var fog_material:= ShaderMaterial.new()
var moon_material:= ShaderMaterial.new()
var clouds_cumulus_material:= ShaderMaterial.new()

# Shaders.
const _sky_shader: Shader = preload("res://addons/jc.godot.time-of-day-common/Shaders/Sky.shader")
const _pv_sky_shader: Shader = preload("res://addons/jc.godot.time-of-day-common/Shaders/PerVertexSky.shader")
const _atm_fog_shader: Shader = preload("res://addons/jc.godot.time-of-day-common/Shaders/AtmFog.shader")
const _moon_shader: Shader = preload("res://addons/jc.godot.time-of-day-common/Shaders/SimpleMoon.shader")
const _clouds_cumulus_shader: Shader = preload("res://addons/jc.godot.time-of-day-common/Shaders/CloudsCumulus.shader")

# Scenes.
const _moon_render: PackedScene = preload("res://addons/jc.godot.time-of-day-common/Scenes/Moon/MoonRender.tscn")

# Textures.
const _moon_texture: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MoonMap/MoonMap.png")
const _background_texture: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/Milkyway.jpg")
const _stars_field_texture: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/StarField.jpg")
const _sun_moon_curve_fade: Curve = preload("res://addons/jc.godot.time-of-day-common/Resources/SunMoonLightFade.tres")
const _stars_field_noise: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Textures/noise.jpg")
const _clouds_texture: Texture = preload("res://addons/jc.godot.time-of-day-common/Resources/SNoise.tres")
const _clouds_cumulus_texture: Texture = preload("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Textures/noiseClouds.png")

enum SkydomeMeshQuality{
	Low, High
}

enum SkyShaderQuality{
	PerPixel, PerVertex
}

## Sky

func __change_skydome_mesh_quality(quality: int) -> void:
	if quality == SkydomeMeshQuality.Low:
		_skydome_mesh.radial_segments = 16
		_skydome_mesh.rings = 8
	else:
		_skydome_mesh.radial_segments = 64
		_skydome_mesh.rings = 64
	
func __set_sky_quality(quality: int) -> void:
	if quality == SkyShaderQuality.PerPixel:
		sky_material.shader = _sky_shader
		__change_skydome_mesh_quality(SkydomeMeshQuality.Low)
	else:
		sky_material.shader = _pv_sky_shader
		__change_skydome_mesh_quality(SkydomeMeshQuality.High)

func setup_sky_resources(quality: int) -> void:
	__set_sky_quality(quality)

func setup_sky_render_priority(value: int) -> void:
	sky_material.render_priority = value

func setup_full_sky_resources(quality: int, renderPriority: int) -> void:
	__set_sky_quality(quality)
	setup_sky_render_priority(renderPriority)


## Moon.
func setup_moon_resources():
	moon_material.shader = _moon_shader
	moon_material.setup_local_to_scene()

## Fog.
func setup_fog_resources():
	var size: Vector2
	size.x = 2.0
	size.y = 2.0
	_full_screen_quad.size = size
	fog_material.shader = _atm_fog_shader
	setup_fog_render_priority(127)

func setup_fog_render_priority(value: int):
	fog_material.render_priority = value

## Clouds Cumulus
func setup_clouds_cumulus_resources(renderPriority: int):
	_clouds_cumulus_mesh.radial_segments = 8
	_clouds_cumulus_mesh.rings = 8
	clouds_cumulus_material.shader = _clouds_cumulus_shader
	setup_clouds_cumulus_priority(renderPriority)


func setup_clouds_cumulus_priority(value: int):
	clouds_cumulus_material.render_priority = value
