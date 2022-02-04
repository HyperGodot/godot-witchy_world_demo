/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°      Constants for sky.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
using Godot;
using System;

namespace JC.TimeOfDay
{
    public partial struct SkyConst
    {
    
    #region Skydome

        public const String kSkyInstance = "_SkyMeshI";
        public const String kFogInstance = "_FogMeshI";
        public const String kMoonInstance  = "MoonRender";
        public const String kCloudsCInstance = "_CloudsCumulusI";
        
        public const float kMaxExtraCullMargin = 16384.0f;
        public static readonly Vector3 kDefaultPosition = new Vector3(0.0000001f, 0.0000001f, 0.0000001f);
    
    #endregion

    #region Coords

        // Shader Params.
        public static readonly String kSunDirP = "_sun_direction";
        public static readonly String kMoonDirP = "_moon_direction";
        public static readonly String kMoonMatrixP = "_moon_matrix";

    #endregion

    #region General

        public static readonly String kTextureP = "_texture";
        public static readonly String kColorCorrectionP = "_color_correction_params";
        public static readonly String kGroundColorP = "_ground_color";
        public static readonly String kNoiseTex = "_noise_tex";
        public static readonly String kHorizonLevel = "_horizon_level";

    #endregion

    #region Atmosphere

        public static readonly String kAtmDarknessP = "_atm_darkness";
        public static readonly String kAtmBetaRayP = "_atm_beta_ray";
        public static readonly String kAtmSunIntensityP = "_atm_sun_intensity";
        public static readonly String kAtmDayTintP = "_atm_day_tint";
        public static readonly String kAtmHorizonLightTintP = "_atm_horizon_light_tint";

        public static readonly String kAtmNightTintP = "_atm_night_tint";
        public static readonly String kAtmLevelParamsP = "_atm_level_params";
        public static readonly String kAtmThicknessP = "_atm_thickness";
        public static readonly String kAtmBetaMieP = "_atm_beta_mie";

        public static readonly String kAtmSunMieTintP = "_atm_sun_mie_tint";
        public static readonly String kAtmSunMieIntensityP = "_atm_sun_mie_intensity";
        public static readonly String KAtmSunPartialMiePhaseP = "_atm_sun_partial_mie_phase";

        public static readonly String kAtmMoonMieTintP = "_atm_moon_mie_tint";
        public static readonly String kAtmMoonMieIntensityP = "_atm_moon_mie_intensity";
        public static readonly String kAtmMoonPartialMiePhaseP = "_atm_moon_partial_mie_phase";

    #endregion

    #region Fog

        public static readonly String kFogDensityP = "_fog_density";
        public static readonly String kFogRayleighDepthP = "_fog_rayleigh_depth";
        public static readonly String kFogMieDepthP = "_fog_mie_depth";
        public static readonly String kFogFallof = "_fog_falloff";
        public static readonly String kFogStart = "_fog_start";
        public static readonly String kFogEnd = "_fog_end";
    
    #endregion

    #region Near Space

        public static readonly String kSunDiskColorP = "_sun_disk_color";
        public static readonly String kSunDiskIntensityP = "_sun_disk_intensity";
        public static readonly String kSunDiskSizeP = "_sun_disk_size";
        public static readonly String kMoonColorP = "_moon_color";
        public static readonly String kMoonSizeP = "_moon_size";
        public static readonly String kMoonTextureP = "_moon_texture";
    
    #endregion

    #region Deep Space

        public static readonly String kDeepSpaceMatrixP = "_deep_space_matrix";
        public static readonly String kBGColP = "_background_color";
        public static readonly String kBGTextureP = "_background_texture";
        public static readonly String kStarsColorP = "_stars_field_color";
        public static readonly String kStarsTextureP = "_stars_field_texture";
        public static readonly String kStarsScP = "_stars_scintillation";
        public static readonly String kStarsScSpeedP = "_stars_scintillation_speed";

    #endregion

    #region Clouds.

        public static readonly String kCloudsThickness = "_clouds_thickness";
        public static readonly String kCloudsCoverage = "_clouds_coverage";
        public static readonly String kCloudsAbsorption = "_clouds_absorption";
        public static readonly String kCloudsSkyTintFade = "_clouds_sky_tint_fade";
        public static readonly String kCloudsIntensity = "_clouds_intensity";
        public static readonly String kCloudsSize = "_clouds_size";
        public static readonly String kCloudsNoiseFreq = "_clouds_noise_freq";

        public static readonly String kCloudsUV = "_clouds_uv";
        public static readonly String kCloudsOffset = "_clouds_offset";
        public static readonly String kCloudsOffsetSpeed = "_clouds_offset_speed";
        public static readonly String kCloudsTexture = "_clouds_texture";

        public static readonly String kCloudsDayColor = "_clouds_day_color";
        public static readonly String kCloudsHorizonLightColor = "_clouds_horizon_light_color";
        public static readonly String kCloudsNightColor = "_clouds_night_color";
        public static readonly String kCloudsMieIntensity = "_clouds_mie_intensity";
        public static readonly String kCloudsPartialMiePhase = "_clouds_partial_mie_phase";

    #endregion

    }
}
