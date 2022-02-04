class_name SkyConst
"""========================================================
°                         TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Constants for sky.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================"""

## Skydome
const SKY_INSTANCE:= "_SkyMeshI"
const FOG_INSTANCE:= "_FogMeshI"
const MOON_INSTANCE:= "MoonRender"
const CLOUDS_C_INSTANCE:= "_CloudsCumulusI"

const MAX_EXTRA_CULL_MARGIN: float = 16384.0
const DEFAULT_POSITION:= Vector3(0.0000001, 0.0000001, 0.0000001)

## Coords
const SUN_DIR_P:= "_sun_direction"
const MOON_DIR_P:= "_moon_direction"
const MOON_MATRIX:= "_moon_matrix"

## General
const TEXTURE_P:= "_texture"
const COLOR_CORRECTION_P:= "_color_correction_params"
const GROUND_COLOR_P:= "_ground_color"
const NOISE_TEX:= "_noise_tex"
const HORIZON_LEVEL = "_horizon_level"

## Atmosphere
const ATM_DARKNESS_P:= "_atm_darkness"
const ATM_BETA_RAY_P:= "_atm_beta_ray"
const ATM_SUN_INTENSITY_P:= "_atm_sun_intensity"
const ATM_DAY_TINT_P:= "_atm_day_tint"
const ATM_HORIZON_LIGHT_TINT_P:= "_atm_horizon_light_tint"

const ATM_NIGHT_TINT_P:= "_atm_night_tint"
const ATM_LEVEL_PARAMS_P:= "_atm_level_params"
const ATM_THICKNESS_P:= "_atm_thickness"
const ATM_BETA_MIE_P:= "_atm_beta_mie"

const ATM_SUN_MIE_TINT_P:= "_atm_sun_mie_tint"
const ATM_SUN_MIE_INTENSITY_P:= "_atm_sun_mie_intensity"
const ATM_SUN_PARTIAL_MIE_PHASE_P:= "_atm_sun_partial_mie_phase"

const ATM_MOON_MIE_TINT_P:= "_atm_moon_mie_tint"
const ATM_MOON_MIE_INTENSITY_P:= "_atm_moon_mie_intensity"
const ATM_MOON_PARTIAL_MIE_PHASE_P:= "_atm_moon_partial_mie_phase"

## Fog
const ATM_FOG_DENSITY_P:= "_fog_density"
const ATM_FOG_RAYLEIGH_DEPTH_P:= "_fog_rayleigh_depth"
const ATM_FOG_MIE_DEPTH_P:= "_fog_mie_depth"
const ATM_FOG_FALLOFF:= "_fog_falloff"
const ATM_FOG_START:= "_fog_start"
const ATM_FOG_END:= "_fog_end"

## Near Space.
const SUN_DISK_COLOR_P:= "_sun_disk_color"
const SUN_DISK_INTENSITY_P:= "_sun_disk_intensity"
const SUN_DISK_SIZE_P:= "_sun_disk_size"
const MOON_COLOR_P:= "_moon_color"
const MOON_SIZE_P:= "_moon_size"
const MOON_TEXTURE_P:= "_moon_texture"

## Deep Space.
const DEEP_SPACE_MATRIX_P:= "_deep_space_matrix"
const BG_COL_P:= "_background_color"
const BG_TEXTURE_P:= "_background_texture"
const STARS_COLOR_P:= "_stars_field_color"
const STARS_TEXTURE_P:= "_stars_field_texture"
const STARS_SC_P:= "_stars_scintillation"
const STARS_SC_SPEED_P:= "_stars_scintillation_speed"

## Clouds
const CLOUDS_THICKNESS:= "_clouds_thickness"
const CLOUDS_COVERAGE:= "_clouds_coverage"
const CLOUDS_ABSORPTION:= "_clouds_absorption"
const CLOUDS_SKY_TINT_FADE:= "_clouds_sky_tint_fade"
const CLOUDS_INTENSITY:= "_clouds_intensity"
const CLOUDS_SIZE:= "_clouds_size"
const CLOUDS_NOISE_FREQ:= "_clouds_noise_freq"

const CLOUDS_UV:= "_clouds_uv"
const CLOUDS_OFFSET:= "_clouds_offset"
const CLOUDS_OFFSET_SPEED:= "_clouds_offset_speed"
const CLOUDS_TEXTURE:= "_clouds_texture"

const CLOUDS_DAY_COLOR:= "_clouds_day_color"
const CLOUDS_HORIZON_LIGHT_COLOR:= "_clouds_horizon_light_color"
const CLOUDS_NIGHT_COLOR:= "_clouds_night_color"
const CLOUDS_MIE_INTENSITY:= "_clouds_mie_intensity"
const CLOUDS_PARTIAL_MIE_PHASE:= "_clouds_partial_mie_phase"
