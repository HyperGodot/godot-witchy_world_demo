tool
class_name Skydome extends Node
"""========================================================
°                         TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Math for ToD.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================"""
## Properties.
var __init_properties_ok: bool = false

# General.
var sky_visible: bool = true setget set_sky_visible
func set_sky_visible(value: bool) -> void:
	sky_visible = value 
	if not __init_properties_ok:
		return
	
	assert(__sky_instance != null, "Sky instance not found")
	__sky_instance.visible = value

var dome_radius: float = 10.0 setget set_dome_radius
func set_dome_radius(value: float) -> void:
	dome_radius = value
	if not __init_properties_ok:
		return
	
	assert(__sky_instance != null, "Sky instance not foud")
	__sky_instance.scale = value * Vector3.ONE

	assert(__clouds_cumulus_instance != null, "Clouds instance not found")
	__clouds_cumulus_instance.scale = value * Vector3.ONE

var tonemap_level: float = 0.0 setget set_tonemap_level
func set_tonemap_level(value: float) -> void:
	tonemap_level = value
	__set_color_correction_params(value, exposure)

var exposure: float = 1.3 setget set_exposure
func set_exposure(value: float) -> void:
	exposure = value
	__set_color_correction_params(tonemap_level, value)

var ground_color:= Color(0.3, 0.3, 0.3, 1.0) setget set_ground_color
func set_ground_color(value: Color) -> void:
	ground_color = value
	__resources.sky_material.set_shader_param(SkyConst.GROUND_COLOR_P, value)

var sky_layers: int = 4 setget set_sky_layers
func set_sky_layers(value: int) -> void:
	sky_layers = value
	if not __init_properties_ok:
		return
	
	assert(__sky_instance != null, "sky instance not found")
	__sky_instance.layers = value
	
	assert(__clouds_cumulus_instance != null, "Clouds instance not found")
	__clouds_cumulus_instance.layers = value

var sky_render_priority: int = -128 setget set_sky_render_priority
func set_sky_render_priority(value: int) -> void:
	sky_render_priority = value
	__resources.setup_sky_render_priority(value)
	__resources.setup_clouds_cumulus_priority(value + 1)

var horizon_level: float = 0.0 setget set_horizon_level
func set_horizon_level(value: float) -> void:
	horizon_level = value
	__resources.sky_material.set_shader_param(SkyConst.HORIZON_LEVEL, value)

# Sun Coords.
var sun_azimuth: float = 0.0 setget set_sun_azimuth
func set_sun_azimuth(value: float) -> void:
	sun_azimuth = value
	__set_sun_coords()

var sun_altitude: float = -27.387 setget set_sun_altitude
func set_sun_altitude(value: float) -> void:
	sun_altitude = value
	__set_sun_coords()

var __finish_set_sun_pos: bool = false

var __sun_transform:= Transform()
func get_sun_transform() -> Transform:
	return __sun_transform

func sun_direction() -> Vector3:
	return __sun_transform.origin - SkyConst.DEFAULT_POSITION

signal sun_direction_changed(value)
signal sun_transform_changed(value)

# Moon Coords.
var moon_azimuth: float = 5.0 setget set_moon_azimuth
func set_moon_azimuth(value: float) -> void:
	moon_azimuth = value
	__set_moon_coords()

var moon_altitude: float = -80.0 setget set_moon_altitude
func set_moon_altitude(value: float) -> void:
	moon_altitude = value
	__set_moon_coords()

var __finish_set_moon_pos = false

var __moon_transform:= Transform()
func get_moon_transform() -> Transform:
	return __moon_transform

func moon_direction() -> Vector3:
	return __moon_transform.origin - SkyConst.DEFAULT_POSITION

signal moon_direction_changed(value)
signal moon_transform_changed(value)

## Atmosphere.
var atm_quality: int = 1 setget set_atm_quality
func set_atm_quality(value: int) -> void:
	atm_quality = value
	__resources.setup_sky_resources(value)

var atm_wavelenghts:= Vector3(680.0, 550.0, 440.0) setget set_atm_wavelenghts
func set_atm_wavelenghts(value : Vector3) -> void:
	atm_wavelenghts = value
	__set_beta_ray()

var atm_darkness: float = 0.5 setget set_atm_darkness
func set_atm_darkness(value: float) -> void:
	atm_darkness = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_DARKNESS_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_DARKNESS_P, value)

var atm_sun_instensity: float = 30.0 setget set_atm_sun_intensity
func set_atm_sun_intensity(value: float) -> void:
	atm_sun_instensity = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_SUN_INTENSITY_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_SUN_INTENSITY_P, value)

var atm_day_tint:= Color(0.807843, 0.909804, 1.0) setget set_atm_day_tint
func set_atm_day_tint(value: Color) -> void:
	atm_day_tint = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_DAY_TINT_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_DAY_TINT_P, value)

var atm_horizon_light_tint:= Color(0.980392, 0.635294, 0.462745, 1.0) setget set_atm_horizon_light_tint
func set_atm_horizon_light_tint(value: Color) -> void:
	atm_horizon_light_tint = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_HORIZON_LIGHT_TINT_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_HORIZON_LIGHT_TINT_P, value)

var atm_enable_moon_scatter_mode: bool = false setget set_atm_enable_moon_scatter_mode
func set_atm_enable_moon_scatter_mode(value: bool) -> void:
	atm_enable_moon_scatter_mode = value
	__set_night_intensity()


var atm_night_tint:= Color(0.168627, 0.2, 0.25098, 1.0) setget set_atm_night_tint
func set_atm_night_tint(value: Color) -> void:
	atm_night_tint = value
	__set_night_intensity()

var atm_level_params:= Vector3(1.0, 0.0, 0.0) setget set_atm_level_params
func set_atm_level_params(value: Vector3) -> void:
	atm_level_params = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_LEVEL_PARAMS_P, value)
	set_fog_atm_level_params_offset(fog_atm_level_params_offset)

var atm_thickness: float = 0.7 setget set_atm_thickness
func set_atm_thickness(value: float) -> void:
	atm_thickness = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_THICKNESS_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_THICKNESS_P, value)

var atm_mie: float = 0.07 setget set_atm_mie
func set_atm_mie(value: float) -> void:
	atm_mie = value
	__set_beta_mie()

var atm_turbidity: float = 0.001 setget set_atm_turbidity
func set_atm_turbidity(value: float) -> void:
	atm_turbidity = value
	__set_beta_mie()

var atm_sun_mie_tint:= Color(1.0, 1.0, 1.0, 1.0) setget set_atm_sun_mie_tint
func set_atm_sun_mie_tint(value: Color) -> void:
	atm_sun_mie_tint = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_SUN_MIE_TINT_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_SUN_MIE_TINT_P, value)
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.ATM_SUN_MIE_TINT_P, value)

var atm_sun_mie_intensity: float = 1.0 setget set_atm_sun_mie_intensity
func set_atm_sun_mie_intensity(value: float) -> void:
	atm_sun_mie_intensity = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_SUN_MIE_INTENSITY_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_SUN_MIE_INTENSITY_P, value)

var atm_sun_mie_anisotropy: float = 0.8 setget set_atm_sun_mie_anisotropy
func set_atm_sun_mie_anisotropy(value: float) -> void:
	atm_sun_mie_anisotropy = value
	var partial = ScatterLib.get_partial_mie_phase(value)
	__resources.sky_material.set_shader_param(SkyConst.ATM_SUN_PARTIAL_MIE_PHASE_P, partial)
	__resources.fog_material.set_shader_param(SkyConst.ATM_SUN_PARTIAL_MIE_PHASE_P, partial)

var atm_moon_mie_tint:= Color(0.137255, 0.184314, 0.292196) setget set_atm_moon_mie_tint
func set_atm_moon_mie_tint(value: Color) -> void:
	atm_moon_mie_tint = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_MOON_MIE_TINT_P, value)
	__resources.fog_material.set_shader_param(SkyConst.ATM_MOON_MIE_TINT_P, value)
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.ATM_MOON_MIE_TINT_P, value)

var atm_moon_mie_intensity: float = 0.7 setget set_atm_moon_mie_intensity
func set_atm_moon_mie_intensity(value: float) -> void:
	atm_moon_mie_intensity = value
	__resources.sky_material.set_shader_param(SkyConst.ATM_MOON_MIE_INTENSITY_P, value * atm_moon_phases_mult())
	__resources.fog_material.set_shader_param(SkyConst.ATM_MOON_MIE_INTENSITY_P, value * atm_moon_phases_mult())

var atm_moon_mie_anisotropy: float = 0.8 setget set_atm_moon_mie_anisotropy
func set_atm_moon_mie_anisotropy(value: float) -> void:
	atm_moon_mie_anisotropy = value
	var partial = ScatterLib.get_partial_mie_phase(value)
	__resources.sky_material.set_shader_param(SkyConst.ATM_MOON_PARTIAL_MIE_PHASE_P, partial)
	__resources.fog_material.set_shader_param(SkyConst.ATM_MOON_PARTIAL_MIE_PHASE_P, partial)

func atm_moon_phases_mult() -> float:
	if not atm_enable_moon_scatter_mode:
		return atm_night_intensity()
	return TOD_Math.saturate(-sun_direction().dot(moon_direction()) + 0.60)

func atm_night_intensity() -> float:
	if not atm_enable_moon_scatter_mode:
		return TOD_Math.saturate(-sun_direction().y + 0.30)
	return TOD_Math.saturate(moon_direction().y) * atm_moon_phases_mult()

func fog_atm_night_intensity() -> float:
	if not atm_enable_moon_scatter_mode:
		return TOD_Math.saturate(-sun_direction().y + 0.70)
	return TOD_Math.saturate(-sun_direction().y) * atm_moon_phases_mult()

## Atmospheric fog.
var fog_visible: bool = true setget set_fog_visible
func set_fog_visible(value: bool) -> void:
	fog_visible = value
	if not __init_properties_ok:
		return
	
	assert(__fog_instance != null, "Fog instance not found")
	__fog_instance.visible = value

var fog_atm_level_params_offset:= Vector3(0.0, 0.0, -1.0) setget set_fog_atm_level_params_offset
func set_fog_atm_level_params_offset(value: Vector3) -> void:
	fog_atm_level_params_offset = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_LEVEL_PARAMS_P, atm_level_params + value)

var fog_density: float = 0.00015 setget set_fog_density
func set_fog_density(value: float) -> void:
	fog_density = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_FOG_DENSITY_P, value)

var fog_start: float = 0.0 setget set_fog_start
func set_fog_start(value: float) -> void:
	fog_start = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_FOG_START, value)

var fog_end: float = 1000 setget set_fog_end
func set_fog_end(value: float) -> void:
	fog_end = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_FOG_END, value)

var fog_rayleigh_depth: float = 0.116 setget set_fog_rayleigh_depth
func set_fog_rayleigh_depth(value: float) -> void:
	fog_rayleigh_depth = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_FOG_RAYLEIGH_DEPTH_P, value)

var fog_mie_depth: float = 0.0001 setget set_fog_mie_depth
func set_fog_mie_depth(value: float) -> void:
	fog_mie_depth = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_FOG_MIE_DEPTH_P, value)

var fog_falloff: float = 3.0 setget set_fog_falloff
func set_fog_falloff(value: float) -> void:
	fog_falloff = value
	__resources.fog_material.set_shader_param(SkyConst.ATM_FOG_FALLOFF, value)

var fog_layers: int = 524288 setget set_fog_layers
func set_fog_layers(value: int) -> void:
	fog_layers = value
	if not __init_properties_ok:
		return
		
	assert(__fog_instance != null, "Fog instance not found")
	__fog_instance.layers = value

var fog_render_priority: int = 123 setget set_fog_render_priority
func set_fog_render_priority(value: int) -> void:
	fog_render_priority = value
	__resources.setup_fog_render_priority(value)

## Near space.
var sun_disk_color:= Color(0.996094, 0.541334, 0.140076) setget set_sun_disk_color
func set_sun_disk_color(value: Color) -> void:
	sun_disk_color = value
	__resources.sky_material.set_shader_param(SkyConst.SUN_DISK_COLOR_P, value)

var sun_disk_intensity: float = 2.0 setget set_sun_disk_intensity
func set_sun_disk_intensity(value: float) -> void:
	sun_disk_intensity = value
	__resources.sky_material.set_shader_param(SkyConst.SUN_DISK_INTENSITY_P, value)

var sun_disk_size: float = 0.015 setget set_sun_disk_size
func set_sun_disk_size(value: float) -> void:
	sun_disk_size = value
	__resources.sky_material.set_shader_param(SkyConst.SUN_DISK_SIZE_P, value)

var moon_color:= Color.white setget set_moon_color
func set_moon_color(value: Color) -> void:
	moon_color = value
	__resources.sky_material.set_shader_param(SkyConst.MOON_COLOR_P, value)

var moon_size: float = 0.07 setget set_moon_size
func set_moon_size(value: float) -> void:
	moon_size = value
	__resources.sky_material.set_shader_param(SkyConst.MOON_SIZE_P, value)

var enable_set_moon_texture = false setget set_enable_set_moon_texture
func set_enable_set_moon_texture(value: bool) -> void:
	enable_set_moon_texture = value
	if not value:
		set_moon_texture(__resources._moon_texture)
	
	property_list_changed_notify()

var moon_texture: Texture = null setget set_moon_texture
func set_moon_texture(value: Texture) -> void:
	moon_texture = value
	__resources.moon_material.set_shader_param(SkyConst.TEXTURE_P, value)

enum MoonResolution{
	R64, R128, R256, R512, R1024,
}

var moon_resolution: int = MoonResolution.R256 setget set_moon_resolution
func set_moon_resolution(value: int) -> void:
	moon_resolution = value
	if not __init_properties_ok:
		return
	
	assert(__moon_instance != null, "Moon instance not found")
	match value:
		MoonResolution.R64: __moon_instance.size = Vector2.ONE * 64
		MoonResolution.R128: __moon_instance.size = Vector2.ONE * 128
		MoonResolution.R256: __moon_instance.size = Vector2.ONE * 256
		MoonResolution.R512: __moon_instance.size = Vector2.ONE * 512
		MoonResolution.R1024: __moon_instance.size = Vector2.ONE * 1024
	
	__moon_rt = __moon_instance.get_texture()
	__resources.sky_material.set_shader_param(SkyConst.MOON_TEXTURE_P, __moon_rt)

## Near space lights.
var sun_light_color:= Color(0.984314, 0.843137, 0.788235) setget set_sun_light_color
func set_sun_light_color(value: Color) -> void:
	sun_light_color = value
	__set_sun_light_color(value, sun_horizon_light_color)

var sun_horizon_light_color:= Color(1.0, 0.384314, 0.243137, 1.0) setget set_sun_horizon_light_color
func set_sun_horizon_light_color(value: Color) -> void:
	sun_horizon_light_color = value
	__set_sun_light_color(sun_light_color, value)

var sun_light_energy: float = 1.0 setget set_sun_light_energy
func set_sun_light_energy(value: float) -> void:
	sun_light_energy = value
	__set_sun_light_energy()

var sun_light_path: NodePath setget set_sun_light_path
func set_sun_light_path(value: NodePath) -> void:
	sun_light_path = value
	if value != null:
		__sun_light_node = get_node_or_null(value) as DirectionalLight
	
	__sun_light_ready = true if __sun_light_node != null else false
	
	__set_sun_coords()

var __sun_light_ready: bool = false
var __sun_light_node: DirectionalLight = null
var __sun_light_altitude_mult: float = 0.0

var moon_light_color:= Color(0.572549, 0.776471, 0.956863, 1.0) setget set_moon_light_color
func set_moon_light_color(value: Color) -> void:
	moon_light_color = value
	if __moon_light_ready:
		__moon_light_node.light_color = value

var moon_light_energy: float = 0.3 setget set_moon_light_energy
func set_moon_light_energy(value: float) -> void:
	moon_light_energy = value
	__set_moon_light_energy()

var moon_light_path: NodePath setget set_moon_light_path
func set_moon_light_path(value: NodePath) -> void:
	moon_light_path = value
	if value != null:
		__moon_light_node = get_node_or_null(value) as DirectionalLight
	
	__moon_light_ready = true if __moon_light_node != null else false
	
	__set_moon_coords()

var __moon_light_ready: bool = false
var __moon_light_node: DirectionalLight
var __moon_light_altitude_mult: float = 0.0

## Deep space.
var deep_space_euler:= Vector3(-0.752, 2.56, 0.0) setget set_deep_space_euler
func set_deep_space_euler(value: Vector3) -> void:
	deep_space_euler = value
	__deep_space_basis = Basis(value)
	deep_space_quat = __deep_space_basis.get_rotation_quat()
	__resources.sky_material.set_shader_param(SkyConst.DEEP_SPACE_MATRIX_P, __deep_space_basis)

var deep_space_quat:= Quat.IDENTITY setget set_deep_space_quat
func set_deep_space_quat(value: Quat) -> void:
	deep_space_quat = value
	__deep_space_basis = Basis(value)
	deep_space_euler = __deep_space_basis.get_euler()
	__resources.sky_material.set_shader_param(SkyConst.DEEP_SPACE_MATRIX_P, __deep_space_basis)

var __deep_space_basis: Basis

var background_color:= Color(0.709804, 0.709804, 0.709804, 0.854902) setget set_background_color
func set_background_color(value: Color) -> void:
	background_color = value
	__resources.sky_material.set_shader_param(SkyConst.BG_COL_P, value)

var set_background_texture: bool = false setget set_set_background_texture
func set_set_background_texture(value: bool) -> void:
	set_background_texture = value
	if not value:
		set_background_texture(__resources._background_texture)
	
	property_list_changed_notify()

var background_texture: Texture = null setget set_background_texture
func set_background_texture(value: Texture) -> void:
	background_texture = value
	__resources.sky_material.set_shader_param(SkyConst.BG_TEXTURE_P, value)

var stars_field_color:= Color.white setget set_stars_field_color
func set_stars_field_color(value: Color) -> void:
	stars_field_color = value
	__resources.sky_material.set_shader_param(SkyConst.STARS_COLOR_P, value)

var set_stars_field_texture: bool = false setget set_set_stars_field_texture
func set_set_stars_field_texture(value: bool) -> void:
	set_stars_field_texture = value
	if not value:
		set_stars_field_texture(__resources._stars_field_texture)
	
	property_list_changed_notify()

var stars_field_texture: Texture = null setget set_stars_field_texture
func set_stars_field_texture(value: Texture) -> void:
	stars_field_texture = value
	__resources.sky_material.set_shader_param(SkyConst.STARS_TEXTURE_P, value)

var stars_scintillation: float = 0.75 setget set_stars_scintillation
func set_stars_scintillation(value: float) -> void:
	stars_scintillation = value
	__resources.sky_material.set_shader_param(SkyConst.STARS_SC_P, value)

var stars_scintillation_speed: float = 0.01 setget set_stars_scintillation_speed
func set_stars_scintillation_speed(value: float) -> void:
	stars_scintillation_speed = value
	__resources.sky_material.set_shader_param(SkyConst.STARS_SC_SPEED_P, value)

var clouds_thickness: float = 1.7 setget set_clouds_thickness
func set_clouds_thickness(value: float) -> void:
	clouds_thickness = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_THICKNESS, value)

var clouds_coverage: float = 0.5 setget set_clouds_coverage
func set_clouds_coverage(value: float) -> void:
	clouds_coverage = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_COVERAGE, value)

var clouds_absorption: float = 2.0 setget set_clouds_absorption
func set_clouds_absorption(value: float) -> void:
	clouds_absorption = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_ABSORPTION, value)

var clouds_sky_tint_fade: float = 0.5 setget set_clouds_sky_tint_fade
func set_clouds_sky_tint_fade(value: float) -> void:
	clouds_sky_tint_fade = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_SKY_TINT_FADE, value)

var clouds_intensity: float = 10.0 setget set_clouds_intensity
func set_clouds_intensity(value: float) -> void:
	clouds_intensity = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_INTENSITY, value)

var clouds_size: float = 2.0 setget set_clouds_size
func set_clouds_size(value: float) -> void:
	clouds_size = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_SIZE, value)

var clouds_uv:= Vector2(0.16, 0.11) setget set_clouds_uv
func set_clouds_uv(value: Vector2) -> void:
	clouds_uv = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_UV, value)

var clouds_offset:= Vector2(0.21, 0.175) setget set_clouds_offset
func set_clouds_offset(value: Vector2) -> void:
	clouds_offset = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_OFFSET, value)

var clouds_offset_speed: float = 0.01 setget set_clouds_offset_speed
func set_clouds_offset_speed(value: float) -> void:
	clouds_offset_speed = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_OFFSET_SPEED, value)

var set_clouds_texture: bool = false setget set_set_clouds_texture
func set_set_clouds_texture(value: bool) -> void:
	set_clouds_texture = value
	if not value:
		set_clouds_texture(__resources._clouds_texture)
	
	property_list_changed_notify()

var clouds_texture: Texture = null setget set_clouds_texture
func set_clouds_texture(value: Texture) -> void:
	clouds_texture = value
	__resources.sky_material.set_shader_param(SkyConst.CLOUDS_TEXTURE, value)

var clouds_cumulus_visible: bool = true setget set_clouds_cumulus_visible
func set_clouds_cumulus_visible(value: bool) -> void:
	clouds_cumulus_visible = value
	if not __init_properties_ok:
		return
	
	assert(__clouds_cumulus_instance != null, "Clouds instance not found")
	__clouds_cumulus_instance.visible = value

var clouds_cumulus_day_color:= Color(0.823529, 0.87451, 1.0, 1.0) setget set_clouds_cumulus_day_color
func set_clouds_cumulus_day_color(value: Color) -> void:
	clouds_cumulus_day_color = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_DAY_COLOR, value)

var clouds_cumulus_horizon_light_color:= Color(1.0, 0.333333, 0.152941, 1.0) setget set_clouds_cumulus_horizon_light_color
func set_clouds_cumulus_horizon_light_color(value: Color) -> void:
	clouds_cumulus_horizon_light_color = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_HORIZON_LIGHT_COLOR, value)

var clouds_cumulus_night_color:= Color(0.090196, 0.094118, 0.129412, 1.0) setget set_clouds_cumulus_night_color
func set_clouds_cumulus_night_color(value: Color) -> void:
	clouds_cumulus_night_color = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_NIGHT_COLOR, value)

var clouds_cumulus_thickness: float = 0.0243 setget set_clouds_cumulus_thickness
func set_clouds_cumulus_thickness(value: float) -> void:
	clouds_cumulus_thickness = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_THICKNESS, value)

var clouds_cumulus_coverage: float = 0.55 setget set_clouds_cumulus_coverage
func set_clouds_cumulus_coverage(value: float) -> void:
	clouds_cumulus_coverage = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_COVERAGE, value)

var clouds_cumulus_absorption: float = 2.0 setget set_clouds_cumulus_absorption
func set_clouds_cumulus_absorption(value: float) -> void:
	clouds_cumulus_absorption = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_ABSORPTION, value)

var clouds_cumulus_noise_freq: float = 2.7 setget set_clouds_cumulus_noise_freq
func set_clouds_cumulus_noise_freq(value: float) -> void:
	clouds_cumulus_noise_freq = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_NOISE_FREQ, value)

var clouds_cumulus_intensity: float = 1.0 setget set_clouds_cumulus_intensity
func set_clouds_cumulus_intensity(value: float) -> void:
	clouds_cumulus_intensity = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_INTENSITY, value)

var clouds_cumulus_mie_intensity: float = 1.0 setget set_clouds_cumulus_mie_intensity
func set_clouds_cumulus_mie_intensity(value: float) -> void:
	clouds_cumulus_mie_intensity = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_MIE_INTENSITY, value)

var clouds_cumulus_mie_anisotropy: float = 0.206 setget set_clouds_cumulus_mie_anisotropy
func set_clouds_cumulus_mie_anisotropy(value: float) -> void:
	clouds_cumulus_mie_anisotropy = value
	var partial = ScatterLib.get_partial_mie_phase(value)
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_PARTIAL_MIE_PHASE, partial)


var clouds_cumulus_size: float = 0.5 setget set_clouds_cumulus_size
func set_clouds_cumulus_size(value: float) -> void:
	clouds_cumulus_size = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_SIZE, value)

var clouds_cumulus_offset:= Vector3(0.64, 0.522, 0.128) setget set_clouds_cumulus_offset
func set_clouds_cumulus_offset(value: Vector3) -> void:
	clouds_cumulus_offset = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_OFFSET, value)

var clouds_cumulus_offset_speed: float = 0.005 setget set_clouds_cumulus_offset_speed
func set_clouds_cumulus_offset_speed(value: float) -> void:
	clouds_cumulus_offset_speed = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_OFFSET_SPEED, value)

var set_clouds_cumulus_texture: bool = false setget set_set_clouds_cumulus_texture
func set_set_clouds_cumulus_texture(value: bool) -> void:
	set_clouds_cumulus_texture = value
	if not value:
		set_clouds_cumulus_texture(__resources._clouds_cumulus_texture)
	
	property_list_changed_notify()

var clouds_cumulus_texture: Texture = null setget set_clouds_cumulus_texture
func set_clouds_cumulus_texture(value: Texture) -> void:
	clouds_cumulus_texture = value
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.CLOUDS_TEXTURE, value)


## Enviro.
var __enable_enviro: bool = false
var enviro: Environment = null setget set_enviro
func set_enviro(value: Environment) -> void:
	enviro = value
	__enable_enviro = true if enviro != null else false
	
	if __enable_enviro && __init_properties_ok:
		__update_enviro()

## Resources and instances.
# Resources.
var __resources:= SkydomeResources.new()

# Instances.
var __sky_instance: MeshInstance = null
var __fog_instance: MeshInstance = null
var __moon_instance: Viewport = null
var __moon_rt: ViewportTexture = null
var __moon_instance_transform: Spatial = null
var __moon_instance_mesh: MeshInstance = null
var __clouds_cumulus_instance: MeshInstance = null

func __check_instances() -> bool:
	__sky_instance = get_node_or_null(SkyConst.SKY_INSTANCE)
	__moon_instance = get_node_or_null(SkyConst.MOON_INSTANCE)
	__fog_instance = get_node_or_null(SkyConst.FOG_INSTANCE)
	__clouds_cumulus_instance = get_node_or_null(SkyConst.CLOUDS_C_INSTANCE)
	
	if __sky_instance == null: return false
	if __moon_instance == null: return false
	if __fog_instance == null: return false
	if __clouds_cumulus_instance == null: return false
	
	return true

## Build in
func _init() -> void:
	__resources.setup_full_sky_resources(atm_quality, sky_render_priority)
	__resources.setup_moon_resources()
	__resources.setup_fog_resources()
	__resources.setup_clouds_cumulus_resources(sky_render_priority + 1)
	
	__force_setup_instances()
	__resources.sky_material.set_shader_param(SkyConst.NOISE_TEX, __resources._stars_field_noise)

func _enter_tree() -> void:
	__build_dome()
	__init_properties()

func _ready() -> void:
	__set_sun_coords()
	__set_moon_coords()

## Setup
func __init_properties() -> void:
	__init_properties_ok = true
	
	# Globals
	set_sky_visible(sky_visible)
	set_dome_radius(dome_radius)
	set_tonemap_level(tonemap_level)
	set_exposure(exposure)
	set_ground_color(ground_color)
	set_sky_layers(sky_layers)
	set_fog_render_priority(fog_render_priority)
	
	# Coords.
	set_sun_azimuth(sun_azimuth)
	set_sun_altitude(sun_altitude)
	set_moon_azimuth(moon_azimuth)
	set_moon_altitude(moon_altitude)
	
	# Atmosphere
	set_atm_quality(atm_quality)
	set_atm_wavelenghts(atm_wavelenghts)
	set_atm_darkness(atm_darkness)
	set_atm_sun_intensity(atm_sun_instensity)
	set_atm_day_tint(atm_day_tint)
	set_atm_horizon_light_tint(atm_horizon_light_tint)
	set_atm_enable_moon_scatter_mode(atm_enable_moon_scatter_mode)
	set_atm_night_tint(atm_night_tint)
	set_atm_level_params(atm_level_params)
	set_atm_thickness(atm_thickness)
	set_atm_mie(atm_mie)
	set_atm_turbidity(atm_turbidity)
	set_atm_sun_mie_tint(atm_sun_mie_tint)
	set_atm_sun_mie_intensity(atm_sun_mie_intensity)
	set_atm_sun_mie_anisotropy(atm_sun_mie_anisotropy)
	set_atm_moon_mie_tint(atm_moon_mie_tint)
	set_atm_moon_mie_intensity(atm_moon_mie_intensity)
	set_atm_moon_mie_anisotropy(atm_moon_mie_anisotropy)
	
	set_fog_visible(fog_visible)
	set_fog_atm_level_params_offset(fog_atm_level_params_offset)
	set_fog_density(fog_density)
	set_fog_rayleigh_depth(fog_rayleigh_depth)
	set_fog_mie_depth(fog_mie_depth)
	set_fog_falloff(fog_falloff)
	set_fog_start(fog_start)
	set_fog_end(fog_end)
	set_fog_layers(fog_layers)
	set_fog_render_priority(fog_render_priority)
	
	# Near space.
	set_sun_disk_color(sun_disk_color)
	set_sun_disk_intensity(sun_disk_intensity)
	set_sun_disk_size(sun_disk_size)
	
	set_moon_color(moon_color)
	set_moon_size(moon_size)
	set_enable_set_moon_texture(enable_set_moon_texture)
	
	if enable_set_moon_texture:
		set_moon_texture(moon_texture)
	
	set_moon_resolution(moon_resolution)

	# Near space lighting.
	set_sun_light_path(sun_light_path)
	set_sun_light_color(sun_light_color)
	set_sun_horizon_light_color(sun_horizon_light_color)
	set_sun_light_energy(sun_light_energy)
	
	set_moon_light_path(moon_light_path)
	set_moon_light_color(moon_light_color)
	set_moon_light_energy(moon_light_energy)
	
	# Deep Space.
	set_deep_space_euler(deep_space_euler)
	set_deep_space_quat(deep_space_quat)
	set_background_color(background_color)
	set_set_background_texture(set_background_texture)
	if set_background_texture:
		set_background_texture(background_texture)
	
	set_stars_field_color(stars_field_color)
	set_set_stars_field_texture(set_stars_field_texture)
	if set_stars_field_texture:
		set_stars_field_texture(stars_field_texture)
	
	set_stars_scintillation(stars_scintillation)
	set_stars_scintillation_speed(stars_scintillation_speed)
	
	# Clouds
	set_clouds_thickness(clouds_thickness)
	set_clouds_coverage(clouds_coverage)
	set_clouds_absorption(clouds_absorption)
	set_clouds_sky_tint_fade(clouds_sky_tint_fade)
	set_clouds_intensity(clouds_intensity)
	set_clouds_size(clouds_size)
	set_clouds_uv(clouds_uv)
	set_clouds_offset(clouds_offset)
	set_clouds_offset_speed(clouds_offset_speed)
	
	set_set_clouds_texture(set_clouds_texture)
	
	if set_clouds_texture:
		set_clouds_texture(clouds_texture)
	
	# Clouds cumulus.
	set_clouds_cumulus_visible(clouds_cumulus_visible)
	set_clouds_cumulus_day_color(clouds_cumulus_day_color)
	set_clouds_cumulus_horizon_light_color(clouds_cumulus_horizon_light_color)
	set_clouds_cumulus_night_color(clouds_cumulus_night_color)
	
	set_clouds_cumulus_thickness(clouds_cumulus_thickness)
	set_clouds_cumulus_coverage(clouds_cumulus_coverage)
	set_clouds_cumulus_absorption(clouds_cumulus_absorption)
	set_clouds_cumulus_intensity(clouds_cumulus_intensity)
	set_clouds_cumulus_mie_intensity(clouds_cumulus_mie_intensity)
	set_clouds_cumulus_mie_anisotropy(clouds_cumulus_mie_anisotropy)
	set_clouds_cumulus_noise_freq(clouds_cumulus_noise_freq)
	set_clouds_cumulus_size(clouds_cumulus_size)
	set_clouds_cumulus_offset(clouds_cumulus_offset)
	set_clouds_cumulus_offset_speed(clouds_cumulus_offset_speed)
	set_set_clouds_cumulus_texture(set_clouds_cumulus_texture)
	
	if set_clouds_cumulus_texture:
		set_clouds_cumulus_texture(clouds_cumulus_texture)
	
	# Enviro.
	set_enviro(enviro)

func __build_dome() -> void:
	# Sky.
	__sky_instance = get_node_or_null(SkyConst.SKY_INSTANCE)
	if __sky_instance == null:
		__sky_instance = MeshInstance.new()
		__sky_instance.name = SkyConst.SKY_INSTANCE
		self.add_child(__sky_instance)
		#__sky_instance.owner = self.get_tree().edited_scene_root
	
	## Moon.
	__moon_instance = get_node_or_null(SkyConst.MOON_INSTANCE) as Viewport
	if __moon_instance == null:
		__moon_instance = __resources._moon_render.instance() as Viewport
		self.add_child(__moon_instance)
		#__moon_instance.owner = self.get_tree().edited_scene_root
	
	## Fog.
	__fog_instance = get_node_or_null(SkyConst.FOG_INSTANCE)
	if __fog_instance == null:
		__fog_instance = MeshInstance.new()
		__fog_instance.name = SkyConst.FOG_INSTANCE
		self.add_child(__fog_instance)
		#__fog_instance.owner = self.get_tree().edited_scene_root
	
	## Clouds cumulus.
	__clouds_cumulus_instance = get_node_or_null(SkyConst.CLOUDS_C_INSTANCE)
	if __clouds_cumulus_instance == null:
		__clouds_cumulus_instance = MeshInstance.new()
		__clouds_cumulus_instance.name = SkyConst.CLOUDS_C_INSTANCE
		self.add_child(__clouds_cumulus_instance)
		#__clouds_cumulus_instance.owner = self.get_tree().edited_scene_root
	
	__setup_instances()


# Prevents save scene errors.
func __force_setup_instances() -> void:
	if __check_instances():
		__init_properties_ok = true
		__setup_instances()

func __setup_instances() -> void:
	assert(__sky_instance != null, "Sky instance not found")
	__setup_mesh_instance(__sky_instance, __resources._skydome_mesh, __resources.sky_material, SkyConst.DEFAULT_POSITION)
	
	assert(__moon_instance != null, "Moon instance not found")
	__moon_instance_transform = __moon_instance.get_node_or_null("MoonTransform") as Spatial
	__moon_instance_mesh = __moon_instance_transform.get_node_or_null("Camera/Mesh") as MeshInstance
	__moon_instance_mesh.material_override = __resources.moon_material
	
	assert(__fog_instance != null, "Fog instance not found")
	__setup_mesh_instance(__fog_instance, __resources._full_screen_quad, __resources.fog_material, Vector3.ZERO)
	
	assert(__clouds_cumulus_instance != null, "Clouds cumulus instance not found")
	__setup_mesh_instance(__clouds_cumulus_instance, __resources._clouds_cumulus_mesh, __resources.clouds_cumulus_material, SkyConst.DEFAULT_POSITION)

func __setup_mesh_instance(target: MeshInstance, mesh: Mesh, mat: Material, origin: Vector3) -> void:
	target.transform.origin = origin
	target.mesh = mesh
	target.extra_cull_margin = SkyConst.MAX_EXTRA_CULL_MARGIN
	target.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	target.material_override = mat
	

## General
func __set_color_correction_params(tonemap: float, exposure: float) -> void:
	var p: Vector2
	p.x = tonemap
	p.y = exposure
	__resources.sky_material.set_shader_param(SkyConst.COLOR_CORRECTION_P, p)
	__resources.fog_material.set_shader_param(SkyConst.COLOR_CORRECTION_P, p)


## Coords.
func __set_sun_coords() -> void:
	if not __init_properties_ok:
		return
	
	assert(__sky_instance != null, "Sky instance not found")
	var azimuth: float = sun_azimuth * TOD_Math.DEG_TO_RAD
	var altitude: float = sun_altitude * TOD_Math.DEG_TO_RAD
	
	__finish_set_sun_pos = false
	if not __finish_set_sun_pos:
		__sun_transform.origin = TOD_Math.to_orbit(altitude, azimuth)
		__finish_set_sun_pos = true
	
	if __finish_set_sun_pos:
		__sun_transform = __sun_transform.looking_at(SkyConst.DEFAULT_POSITION, Vector3.LEFT)
	
	__set_day_state(altitude)
	emit_signal("sun_transform_changed", __sun_transform)
	emit_signal("sun_transform_changed", sun_direction())
	
	__resources.sky_material.set_shader_param(SkyConst.SUN_DIR_P, sun_direction())
	__resources.fog_material.set_shader_param(SkyConst.SUN_DIR_P, sun_direction())
	__resources.moon_material.set_shader_param(SkyConst.SUN_DIR_P, sun_direction())
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.SUN_DIR_P, sun_direction())
	
	if __sun_light_ready:
		#if __sun_light_node.light_energy > 0.0 && (abs(sun_altitude) < 90.0
		if __sun_light_node.light_energy > 0.0:
			__sun_light_node.transform = __sun_transform
	
	__sun_light_altitude_mult = TOD_Math.saturate(sun_direction().y)
	
	__set_night_intensity()
	__set_sun_light_color(sun_light_color, sun_horizon_light_color)
	__set_sun_light_energy()
	__set_moon_light_energy()
	__update_enviro()


func __set_moon_coords() -> void:
	if not __init_properties_ok:
		return
	
	assert(__sky_instance != null, "Sky instance not found")
	var azimuth: float = moon_azimuth * TOD_Math.DEG_TO_RAD
	var altitude: float = moon_altitude * TOD_Math.DEG_TO_RAD
	
	__finish_set_moon_pos = false
	if not __finish_set_moon_pos:
		__moon_transform.origin = TOD_Math.to_orbit(altitude, azimuth)
		__finish_set_moon_pos = true
	
	if __finish_set_moon_pos:
		__moon_transform = __moon_transform.looking_at(SkyConst.DEFAULT_POSITION, Vector3.LEFT)
	
	emit_signal("moon_transform_changed", __moon_transform)
	emit_signal("moon_direction_changed", moon_direction())
	
	__resources.sky_material.set_shader_param(SkyConst.MOON_DIR_P, moon_direction())
	__resources.fog_material.set_shader_param(SkyConst.MOON_DIR_P, moon_direction())
	__resources.moon_material.set_shader_param(SkyConst.MOON_DIR_P, moon_direction())
	__resources.clouds_cumulus_material.set_shader_param(SkyConst.MOON_DIR_P, moon_direction())
	__resources.sky_material.set_shader_param(SkyConst.MOON_MATRIX, __moon_transform.basis.inverse())
	
	assert(__moon_instance_transform != null, "Moon instance transform not found")
	__moon_instance_transform.transform = __moon_transform
	
	if __moon_light_ready:
		#if __moon_light_node.light_energy > 0.0 && (abs(moon_altitude) < 90.0):
		if __moon_light_node.light_energy > 0.0:
			__moon_light_node.transform = __moon_transform
	
	__moon_light_altitude_mult = TOD_Math.saturate(moon_direction().y)
	
	__set_night_intensity()
	set_moon_light_color(moon_light_color)
	__set_moon_light_energy()
	__update_enviro()

## Atmosphere.
func __set_beta_ray() -> void:
	var wll = ScatterLib.compute_wavelenghts_lambda(atm_wavelenghts)
	var wls = ScatterLib.compute_wavlenghts(wll)
	var betaRay = ScatterLib.compute_beta_ray(wls)
	__resources.sky_material.set_shader_param(SkyConst.ATM_BETA_RAY_P, betaRay)
	__resources.fog_material.set_shader_param(SkyConst.ATM_BETA_RAY_P, betaRay)

func __set_beta_mie() -> void:
	var bm = ScatterLib.compute_beta_mie(atm_mie, atm_turbidity)
	__resources.sky_material.set_shader_param(SkyConst.ATM_BETA_MIE_P, bm)
	__resources.fog_material.set_shader_param(SkyConst.ATM_BETA_MIE_P, bm)

func __set_night_intensity() -> void:
	var tint: Color = atm_night_tint * atm_night_intensity()
	__resources.sky_material.set_shader_param(SkyConst.ATM_NIGHT_TINT_P, tint)
	__resources.fog_material.set_shader_param(SkyConst.ATM_NIGHT_TINT_P, atm_night_tint * fog_atm_night_intensity())
	
	set_atm_moon_mie_intensity(atm_moon_mie_intensity)

## Lighting
signal is_day(value)
func __set_day_state(v: float, threshold: float = 1.80) -> void:
	if abs(v) > threshold:
		emit_signal("is_day", false)
	else:
		emit_signal("is_day", true)
	
	__evaluate_light_enable()

var __light_enable: bool
func __evaluate_light_enable() -> void:
	if __sun_light_ready:
		__light_enable = true if __sun_light_node.light_energy > 0.0 else false
		__sun_light_node.visible = __light_enable
	if __moon_light_ready:
		__moon_light_node.visible = !__light_enable

func __set_sun_light_color(col: Color, horizonCol: Color) -> void:
	if __sun_light_ready:
		__sun_light_node.light_color = TOD_Math.plerp_color(horizonCol, col, __sun_light_altitude_mult)

func __set_sun_light_energy() -> void:
	if __sun_light_ready:
		__sun_light_node.light_energy = TOD_Math.lerp_f(0.0, sun_light_energy, __sun_light_altitude_mult)

func __set_moon_light_energy() -> void:
	if not __moon_light_ready:
		return
	
	var l: float = TOD_Math.lerp_f(0.0, moon_light_energy, __moon_light_altitude_mult)
	l*= atm_moon_phases_mult()
	
	var fade = (1.0 - sun_direction().y) * 0.5
	__moon_light_node.light_energy = l * __resources._sun_moon_curve_fade.interpolate_baked(fade)

func __update_enviro() -> void:
	if not __enable_enviro:
		return
	
	var a = TOD_Math.saturate(1.0 - sun_direction().y)
	var b = TOD_Math.saturate(-sun_direction().y + 0.60)
	
	var colA = TOD_Math.plerp_color(atm_day_tint * 0.5, atm_horizon_light_tint, a)
	var colB = TOD_Math.plerp_color(colA, atm_night_tint * atm_night_intensity(), b)
	
	enviro.ambient_light_color = colB


func _get_property_list() -> Array:
	var ret:= Array() 
	ret.push_back({name = "Skydome", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY})
	
	# Global.
	ret.push_back({name = "Global", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_visible", type = TYPE_BOOL})
	ret.push_back({name = "dome_radius", type = TYPE_REAL})
	ret.push_back({name = "tonemap_level", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "exposure", type = TYPE_REAL})
	ret.push_back({name = "ground_color", type = TYPE_COLOR})
	ret.push_back({name = "sky_layers", type = TYPE_INT, hint = PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "sky_render_priority", type = TYPE_INT, hint = PROPERTY_HINT_RANGE, hint_string = "-128, 127"})
	ret.push_back({name = "horizon_level", type = TYPE_REAL})
	
	# Sun.
	ret.push_back({name = "Sun", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sun_altitude", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "sun_azimuth", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "sun_disk_color", type = TYPE_COLOR})
	ret.push_back({name = "sun_disk_intensity", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 2.0"}) # Clamped 2.0 for prevent reflection probe artifacts.
	ret.push_back({name = "sun_disk_size", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.5"})
	ret.push_back({name = "sun_light_path", type = TYPE_NODE_PATH})
	ret.push_back({name = "sun_light_color", type = TYPE_COLOR})
	ret.push_back({name = "sun_horizon_light_color", type = TYPE_COLOR})
	ret.push_back({name = "sun_light_energy", type = TYPE_REAL})
	
	# Moon.
	ret.push_back({name = "Moon", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "moon_altitude", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "moon_azimuth", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "moon_color", type = TYPE_COLOR})
	ret.push_back({name = "moon_size", type = TYPE_REAL})
	ret.push_back({name = "enable_set_moon_texture", type = TYPE_BOOL})
	
	if enable_set_moon_texture:
		ret.push_back({name = "moon_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture"})
	
	ret.push_back({name = "moon_resolution", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "64, 128, 256, 512, 1024"})
	ret.push_back({name = "moon_light_path", type = TYPE_NODE_PATH})
	
	ret.push_back({name = "moon_light_color", type = TYPE_COLOR})
	ret.push_back({name = "moon_light_energy", type = TYPE_REAL})
	
	# Deep space
	ret.push_back({name = "DeepSpace", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "deep_space_euler", type = TYPE_VECTOR3})
	ret.push_back({name = "background_color", type = TYPE_COLOR})
	ret.push_back({name = "set_background_texture", type = TYPE_BOOL})
	
	if set_background_texture:
		ret.push_back({name = "background_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_GLOBAL_FILE, hint_string = "Texture"})
	
	ret.push_back({name = "stars_field_color", type = TYPE_COLOR})
	ret.push_back({name = "set_stars_field_texture", type = TYPE_BOOL})
	
	if set_stars_field_texture:
		ret.push_back({name = "stats_field_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture"})
	
	ret.push_back({name = "stars_scintillation", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "stars_scintillation_speed", type = TYPE_REAL})
	
	# Atmosphere.
	ret.push_back({name = "Atmosphere", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP, hint_string = "atm_"})
	ret.push_back({name = "atm_quality", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "PerPixel,PerVertex"})
	ret.push_back({name = "atm_wavelenghts", type = TYPE_VECTOR3})
	ret.push_back({name = "atm_darkness", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "atm_sun_instensity", type = TYPE_REAL})
	ret.push_back({name = "atm_day_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_horizon_light_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_enable_moon_scatter_mode", type = TYPE_BOOL})
	ret.push_back({name = "atm_night_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_level_params", type = TYPE_VECTOR3})
	ret.push_back({name = "atm_thickness", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 100.0"})
	ret.push_back({name = "atm_mie", type = TYPE_REAL})
	ret.push_back({name = "atm_turbidity", type = TYPE_REAL})
	ret.push_back({name = "atm_sun_mie_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_sun_mie_intensity", type = TYPE_REAL})
	ret.push_back({name = "atm_sun_mie_anisotropy", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.9999999"})
	
	ret.push_back({name = "atm_moon_mie_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_moon_mie_intensity", type = TYPE_REAL})
	ret.push_back({name = "atm_moon_mie_anisotropy", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.9999999"})
	
	# Fog.
	ret.push_back({name = "Fog", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP, hint_string = "fog_"})
	ret.push_back({name = "fog_visible", type = TYPE_BOOL})
	ret.push_back({name = "fog_atm_level_params_offset", type = TYPE_VECTOR3})
	ret.push_back({name = "fog_density", type = TYPE_REAL, hint = PROPERTY_HINT_EXP_EASING, hint_string = "0.0, 1.0"})
	ret.push_back({name = "fog_rayleigh_depth", type = TYPE_REAL, hint = PROPERTY_HINT_EXP_EASING, hint_string = "0.0, 1.0"})
	ret.push_back({name = "fog_mie_depth", type = TYPE_REAL, hint = PROPERTY_HINT_EXP_EASING, hint_string = "0.0, 1.0"})
	ret.push_back({name = "fog_falloff", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 10.0"})
	ret.push_back({name = "fog_start", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 5000.0"})
	ret.push_back({name = "fog_end", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 5000.0"})
	ret.push_back({name = "fog_layers", type = TYPE_INT, hint = PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "fog_render_priority", type = TYPE_INT})
	
	# 2D Clouds.
	ret.push_back({name = "2D Clouds", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "clouds_thickness", type = TYPE_REAL})
	ret.push_back({name = "clouds_coverage", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "clouds_absorption", type = TYPE_REAL})
	ret.push_back({name = "clouds_sky_tint_fade", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "clouds_intensity", type = TYPE_REAL})
	ret.push_back({name = "clouds_size", type = TYPE_REAL})
	ret.push_back({name = "clouds_uv", type = TYPE_VECTOR2})
	ret.push_back({name = "clouds_offset", type = TYPE_VECTOR2})
	ret.push_back({name = "clouds_offset_speed", type = TYPE_REAL})
	ret.push_back({name = "set_clouds_texture", type = TYPE_BOOL})
	
	if set_clouds_texture:
		ret.push_back({name = "clouds_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture"})
	
	# Clouds cumulus.
	ret.push_back({name = "Clouds Cumulus", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "clouds_cumulus_visible", type = TYPE_BOOL})
	ret.push_back({name = "clouds_cumulus_day_color", type = TYPE_COLOR})
	ret.push_back({name = "clouds_cumulus_horizon_light_color", type = TYPE_COLOR})
	ret.push_back({name = "clouds_cumulus_night_color", type = TYPE_COLOR})
	ret.push_back({name = "clouds_cumulus_thickness", type = TYPE_REAL})
	ret.push_back({name = "clouds_cumulus_coverage", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "clouds_cumulus_absorption", type = TYPE_REAL})
	ret.push_back({name = "clouds_cumulus_noise_freq", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 3.0"})
	ret.push_back({name = "clouds_cumulus_intensity", type = TYPE_REAL})
	ret.push_back({name = "clouds_cumulus_mie_intensity", type = TYPE_REAL})
	ret.push_back({name = "clouds_cumulus_mie_anisotropy", type = TYPE_REAL, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.999999"})
	ret.push_back({name = "clouds_cumulus_size", type = TYPE_REAL})
	ret.push_back({name = "clouds_cumulus_offset", type = TYPE_VECTOR3})
	ret.push_back({name = "clouds_cumulus_offset_speed", type = TYPE_REAL})
	ret.push_back({name = "set_clouds_cumulus_texture", type = TYPE_BOOL})
	
	if set_clouds_cumulus_texture:
		ret.push_back({name = "clouds_cumulus_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture"})
	
	# Lighting
	ret.push_back({name = "Lighting", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "enviro", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Resource"})
	
	return ret
