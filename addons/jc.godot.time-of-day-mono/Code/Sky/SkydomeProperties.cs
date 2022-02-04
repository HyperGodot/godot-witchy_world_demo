/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Skydome Base.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
using Godot;
using System;
using GodotArray = Godot.Collections.Array;
using PropElement = Godot.Collections.Dictionary<object, object>;

namespace JC.TimeOfDay
{

    public partial class Skydome : Node
    {

        public override GodotArray _GetPropertyList()
        {
            GodotArray ret = new GodotArray();

            PropElement pTitle = new PropElement 
            { 
                {"name", "Skydome"}, 
                {"type", Variant.Type.Nil}, 
                {"usage", PropertyUsageFlags.Category} 
            };
            ret.Add(pTitle);

        #region Global

            PropElement pGlobalGroup = new PropElement 
            { 
                {"name", "Global"}, 
                {"type", Variant.Type.Nil}, 
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pGlobalGroup);
                        
            PropElement pSkyVisible = new PropElement
            { 
                {"name", "SkyVisible"}, 
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSkyVisible);
                        
            PropElement pDomeRadius = new PropElement 
            {
                {"name", "DomeRadius"}, 
                {"type", Variant.Type.Real},
            };
            ret.Add(pDomeRadius);

            PropElement pTonemapLevel = new PropElement
            {
                {"name", "TonemapLevel"}, 
                {"type", Variant.Type.Real}, 
                {"hint", PropertyHint.Range}, 
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pTonemapLevel);

            PropElement pExposure = new PropElement
            {
                {"name", "Exposure"}, 
                {"type", Variant.Type.Real}
            };
            ret.Add(pExposure);

            PropElement pGroundColor = new PropElement
            {
                {"name", "GroundColor"}, 
                {"type", Variant.Type.Color}
            };
            ret.Add(pGroundColor);

            PropElement pSkyLayers = new PropElement 
            {
                {"name", "SkyLayers"},
                {"type", Variant.Type.Int}, 
                {"hint", PropertyHint.Layers3dRender}
            };
            ret.Add(pSkyLayers);

            PropElement pSkyRenderPriority = new PropElement
            {
                {"name", "SkyRenderPriority"}, 
                {"type", Variant.Type.Int}, 
                {"hint", PropertyHint.Range},
                {"hint_string", "-128, 128"}
            };
            ret.Add(pSkyRenderPriority);

            PropElement pHorizonLevel = new PropElement
            {
                {"name", "HorizonLevel"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pHorizonLevel);

        #endregion

        #region Sun

            PropElement pSunGroup = new PropElement 
            { 
                {"name", "Sun"}, 
                {"type", Variant.Type.Nil}, 
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pSunGroup);

            PropElement pSunAltitude = new PropElement 
            {
                {"name", "SunAltitude"}, 
                {"type", Variant.Type.Real}, 
                {"hint", PropertyHint.Range},
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pSunAltitude);

            PropElement pSunAzimuth = new PropElement 
            { 
                {"name", "SunAzimuth"}, 
                {"type", Variant.Type.Real}, 
                {"hint", PropertyHint.Range}, 
                {"hint_string", "-180.0, 180.0"}

            };
            ret.Add(pSunAzimuth);

            PropElement pSunDiskColor = new PropElement 
            {
                {"name", "SunDiskColor"}, 
                {"type", Variant.Type.Color}
            };
            ret.Add(pSunDiskColor);

            PropElement pSunDiskIntensity = new PropElement 
            {
                {"name", "SunDiskIntensity"}, 
                {"type", Variant.Type.Real}, 
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 2.0"}
            };
            ret.Add(pSunDiskIntensity);

            PropElement pSunDiskSize = new PropElement 
            {
                {"name", "SunDiskSize"}, 
                {"type", Variant.Type.Real}, 
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 0.5"}
            };
            ret.Add(pSunDiskSize);

            PropElement pSunLightPath = new PropElement 
            {
                {"name", "SunLightPath"},
                {"type", Variant.Type.NodePath} 
            };
            ret.Add(pSunLightPath);

            PropElement pSunLightColor = new PropElement 
            {
                {"name", "SunLightColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pSunLightColor);

            PropElement pSunHorizonLightColor = new PropElement 
            {
                {"name", "SunHorizonLightColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pSunHorizonLightColor);

            PropElement pSunLightEnergy = new PropElement 
            {
                {"name", "SunLightEnergy"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pSunLightEnergy);

        #endregion

        #region Moon

            PropElement pMoonGroup = new PropElement 
            { 
                {"name", "Moon"}, 
                {"type", Variant.Type.Nil}, 
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pMoonGroup);

            PropElement pMoonAltitude = new PropElement 
            {
                {"name", "MoonAltitude"}, 
                {"type", Variant.Type.Real}, 
                {"hint", PropertyHint.Range}, 
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pMoonAltitude);

            PropElement pMoonAzimuth = new PropElement 
            {
                {"name", "MoonAzimuth"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pMoonAzimuth);

            PropElement pMoonColor = new PropElement 
            {
                {"name", "MoonColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pMoonColor);

            PropElement pMoonSize = new PropElement 
            {
                {"name", "MoonSize"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pMoonSize);

            PropElement pEnableSetMoonTex = new PropElement 
            {
                {"name", "EnableSetMoonTexture"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pEnableSetMoonTex);

            if(_EnableSetMoonTexture)
            {
                PropElement pMoonTexture = new PropElement 
                {
                    {"name", "MoonTexture"},
                    {"type", Variant.Type.Object},
                    {"hint", PropertyHint.File},
                    {"hint_string", "Texture"}
                };
                ret.Add(pMoonTexture);
            }

            PropElement pMoonResolution = new PropElement 
            {
                {"name", "MoonResolution"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Enum},
                {"hint_string", "64, 128, 256, 512, 1024"}
            };
            ret.Add(pMoonResolution);

            PropElement pMoonLightPath = new PropElement 
            {
                {"name", "MoonLightPath"},
                {"type", Variant.Type.NodePath}
            };
            ret.Add(pMoonLightPath);

            PropElement pMoonLightColor = new PropElement 
            {
                {"name", "MoonLightColor"},
                {"type", Variant.Type.Color }
            };
            ret.Add(pMoonLightColor);

            PropElement pMoonLightEnergy = new PropElement
            {
                {"name", "MoonLightEnergy"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pMoonLightEnergy);


        #endregion

        #region DeepSpace 

            PropElement pDeepSpaceGroup = new PropElement 
            { 
                {"name", "DeepSpace"}, 
                {"type", Variant.Type.Nil}, 
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pDeepSpaceGroup);

            PropElement pDeepSpaceEuler = new PropElement
            {
                {"name", "DeepSpaceEuler"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pDeepSpaceEuler);

            PropElement pBackgroundColor = new PropElement
            {
                {"name", "BackgroundColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pBackgroundColor);

            PropElement pSetBackgroundTexture = new PropElement
            {
                {"name", "SetBackgroundTexture"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSetBackgroundTexture);

            if(_SetBackgroundTexture)
            {
                PropElement pBackgroundTexture = new PropElement
                {
                    {"name", "BackgroundTexture"},
                    {"type", Variant.Type.Object},
                    {"hint", PropertyHint.File},
                    {"hint_string", "Texture"}
                };
                ret.Add(pBackgroundTexture);
            }

            PropElement pStarsFieldColor = new PropElement
            {
                {"name", "StarsFieldColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pStarsFieldColor);

            PropElement pSetStarsFieldTexture = new PropElement
            {
                {"name", "SetStarsFieldTexture"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSetStarsFieldTexture);

            if(_SetStarsFieldTexture)
            {
                PropElement pStarsFieldTexture = new PropElement
                {
                    {"name", "StarsFieldTexture"},
                    {"type", Variant.Type.Object},
                    {"hint", PropertyHint.File},
                    {"hint_string", "Texture"}
                };
                ret.Add(pStarsFieldTexture);
            }

            PropElement pStarsFieldScintillation = new PropElement
            {
                {"name", "StarsScintillation"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pStarsFieldScintillation);

            PropElement pStarsFieldScintillationSpeed = new PropElement 
            {
                {"name", "StarsScintillationSpeed"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pStarsFieldScintillationSpeed);

        #endregion

        #region Atmosphere 

            PropElement pAtmosphereGroup = new PropElement 
            { 
                {"name", "Atmosphere"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group},
                {"hint_string", "Atm"}
            };
            ret.Add(pAtmosphereGroup);

            PropElement pAtmQuality = new PropElement 
            {
                {"name", "AtmQuality"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Enum},
                {"hint_string", "PerPixel, PerVertex"}
            };
            ret.Add(pAtmQuality);

            PropElement pAtmWavelenghts = new PropElement 
            {
                {"name", "AtmWavelenghts"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pAtmWavelenghts);

            PropElement pAtmDarkness = new PropElement 
            {
                {"name", "AtmDarkness"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pAtmDarkness);

            PropElement pAtmSunIntensity = new PropElement 
            {
                {"name", "AtmSunIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmSunIntensity);

            PropElement pAtmDayTint = new PropElement
            {
                {"name", "AtmDayTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmDayTint);

            PropElement pAtmHorizonLightTint = new PropElement
            {
                {"name", "AtmHorizonLightTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmHorizonLightTint);

            PropElement pAtmEnableMoonScatterMode = new PropElement 
            {
                {"name", "AtmEnableMoonScatterMode"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pAtmEnableMoonScatterMode);

            PropElement pAtmNightTint = new PropElement
            {
                {"name", "AtmNightTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmNightTint);

            PropElement pAtmLevelParams = new PropElement 
            {
                {"name", "AtmLevelParams"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pAtmLevelParams);

            PropElement pAtmThickness = new PropElement 
            {
                {"name", "AtmThickness"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 100.0"}
            };
            ret.Add(pAtmThickness);
            PropElement pAtmMie = new PropElement
            {
                {"name", "AtmMie"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmMie);

            PropElement pAtmTurbidity = new PropElement 
            {
                {"name", "AtmTurbidity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmTurbidity);

            PropElement pAtmSunMieTint = new PropElement
            {
                {"name", "AtmSunMieTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmSunMieTint);

            PropElement pAtmSunMieIntensity = new PropElement 
            {
                {"name", "AtmSunMieIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmSunMieIntensity);

            PropElement pAtmSunMieAnisotropy = new PropElement 
            {
                {"name", "AtmSunMieAnisotropy"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 0.9999999"}
            };
            ret.Add(pAtmSunMieAnisotropy);

            PropElement pAtmMoonMieTint = new PropElement 
            {
                {"name", "AtmMoonMieTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmMoonMieTint);

            PropElement pAtmMoonMieIntensity = new PropElement 
            {
                {"name", "AtmMoonMieIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmMoonMieIntensity);

            PropElement pAtmMoonMieAnisotropy = new PropElement 
            {
                {"name", "AtmMoonMieAnisotropy"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 0.9999999"}
            };
            ret.Add(pAtmMoonMieAnisotropy);

            PropElement pFogGroup = new PropElement 
            { 
                {"name", "Fog"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group},
                {"hint_string", "Fog"}
            };
            ret.Add(pFogGroup);

            PropElement pFogVisible = new PropElement 
            {
                {"name", "FogVisible"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pFogVisible);

            PropElement pFogAtmLevelParamOffset = new PropElement
            {
                {"name", "FogAtmLevelParamsOffset"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pFogAtmLevelParamOffset);

            PropElement pFogDensity = new PropElement 
            {
                {"name", "FogDensity"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.ExpEasing},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pFogDensity);

            PropElement pFogRayleighDepth = new PropElement 
            {
                {"name", "FogRayleighDepth"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.ExpEasing},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pFogRayleighDepth);

            PropElement pFogMieDepth = new PropElement 
            {
                {"name", "FogMieDepth"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.ExpEasing},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pFogMieDepth);

            PropElement pFogFalloff = new PropElement
            {
                {"name", "FogFalloff"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 10.0"}
            };
            ret.Add(pFogFalloff);

            PropElement pFogStart = new PropElement
            {
                {"name", "FogStart"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 5000.0"}
            };
            ret.Add(pFogStart);

            PropElement pFogEnd = new PropElement
            {
                {"name", "FogEnd"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 5000.0"}
            };
            ret.Add(pFogEnd);

            PropElement pFogLayers = new PropElement 
            {
                {"name", "FogLayers"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Layers3dRender}
            };
            ret.Add(pFogLayers);

            PropElement pFogRenderPriority = new PropElement 
            {
                {"name", "FogRenderPriority"},
                {"type", Variant.Type.Int}
            };
            ret.Add(pFogRenderPriority);

        #endregion

        #region 2D Clouds 

            PropElement p2DCloudsGroup = new PropElement 
            { 
                {"name", "2DClouds"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(p2DCloudsGroup);

            PropElement pCloudsThickness = new PropElement 
            {
                {"name", "CloudsThickness"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsThickness);

            PropElement pCloudsCoverage = new PropElement
            {
                {"name", "CloudsCoverage"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0f, 1.0"}
            };
            ret.Add(pCloudsCoverage);

            PropElement pCloudsAbsorption = new PropElement
            {
                {"name", "CloudsAbsorption"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsAbsorption);

            PropElement pCloudsSkyTintFade = new PropElement
            {
                {"name", "CloudsSkyTintFade"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pCloudsSkyTintFade);

            PropElement pCloudsIntensity = new PropElement 
            {
                {"name", "CloudsIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsIntensity);

            PropElement pCloudsSize = new PropElement
            {
                {"name", "CloudsSize"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsSize);

            PropElement pCloudsUV = new PropElement 
            {
                {"name", "CloudsUV"},
                {"type", Variant.Type.Vector2}
            };
            ret.Add(pCloudsUV);

            PropElement pCloudsOffset = new PropElement 
            {
                {"name", "CloudsOffset"},
                {"type", Variant.Type.Vector2}
            };
            ret.Add(pCloudsOffset);

            PropElement pCloudsOffsetSpeed = new PropElement
            {
                {"name", "CloudsOffsetSpeed"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsOffsetSpeed);

            PropElement pSetCloudsTexture = new PropElement 
            {
                {"name", "SetCloudsTexture"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSetCloudsTexture);

            if(_SetCloudsTexture)
            {
                PropElement pCloudsTexture = new PropElement
                {
                    {"name", "CloudsTexture"},
                    {"type", Variant.Type.Object},
                    {"hint", PropertyHint.File},
                    {"hint_sting", "Texture"}
                };
                ret.Add(pCloudsTexture);

            }

        #endregion
        
        #region Clouds Cumulus
        
            PropElement pCloudsCumulusGroup = new PropElement 
            { 
                {"name", "CloudsCumulus"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pCloudsCumulusGroup);

            PropElement pCloudsCumulusVisible = new PropElement
            {
                {"name", "CloudsCumulusVisible"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pCloudsCumulusVisible);

            PropElement pCloudsCumulusDayColor = new PropElement 
            {
                {"name", "CloudsCumulusDayColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pCloudsCumulusDayColor);

            PropElement pCloudsCumulusHorizonLightColor = new PropElement 
            {
                {"name", "CloudsCumulusHorizonLightColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pCloudsCumulusHorizonLightColor);

            PropElement pCloudsCumulusNightColor = new PropElement 
            {
                {"name", "CloudsCumulusNightColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pCloudsCumulusNightColor);

            PropElement pCloudsCumulusThickness = new PropElement 
            {
                {"name", "CloudsCumulusThickness"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsCumulusThickness);

            PropElement pCloudsCumulusCoverage = new PropElement
            {
                {"name", "CloudsCumulusCoverage"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0f, 1.0"}
            };
            ret.Add(pCloudsCumulusCoverage);

            PropElement pCloudsCumulusAbsorption = new PropElement
            {
                {"name", "CloudsCumulusAbsorption"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsCumulusAbsorption);

            PropElement pCloudsCumulusNoiseFreq = new PropElement
            {
                {"name", "CloudsCumulusNoiseFreq"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 3.0"}
            };
            ret.Add(pCloudsCumulusNoiseFreq);

            PropElement pCloudsCumulusIntensity = new PropElement 
            {
                {"name", "CloudsCumulusIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsCumulusIntensity);

            PropElement pCloudsCumulusMieIntensity = new PropElement
            {
                {"name", "CloudsCumulusMieIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsCumulusMieIntensity);

            PropElement pCloudsCumulusMieAnisotropy = new PropElement
            {
                {"name", "CloudsCumulusMieAnisotropy"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 0.999999"}
            };
            ret.Add(pCloudsCumulusMieAnisotropy);

            PropElement pCloudsCumulusSize = new PropElement
            {
                {"name", "CloudsCumulusSize"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsCumulusSize);


            PropElement pCloudsCumulusOffset = new PropElement 
            {
                {"name", "CloudsCumulusOffset"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pCloudsCumulusOffset);

            PropElement pCloudsCumulusOffsetSpeed = new PropElement
            {
                {"name", "CloudsCumulusOffsetSpeed"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCloudsCumulusOffsetSpeed);

            PropElement pSetCloudsCumulusTexture = new PropElement 
            {
                {"name", "SetCloudsCumulusTexture"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSetCloudsCumulusTexture);

            if(_SetCloudsCumulusTexture)
            {
                PropElement pCloudsCumulusTexture = new PropElement
                {
                    {"name", "CloudsCumulusTexture"},
                    {"type", Variant.Type.Object},
                    {"hint", PropertyHint.File},
                    {"hint_sting", "Texture"}
                };
                ret.Add(pCloudsCumulusTexture);

            }

        #endregion

        #region Lighting

            PropElement pLightingGroup = new PropElement 
            { 
                {"name", "Lighting"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pLightingGroup);

            PropElement pEnviro = new PropElement
            {
                {"name", "Enviro"},
                {"type", Variant.Type.Object},
                {"hint", PropertyHint.ResourceType},
                {"hint_string", "Resource"}
            };
            ret.Add(pEnviro);

        #endregion

            return ret;
        }
    }
}
