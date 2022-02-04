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

namespace JC.TimeOfDay
{
    [Tool]
    public partial class Skydome : Node
    {

    #region Properties

        private bool _InitPropertiesOk = false;

        #region General.
        
        private bool _SkyVisible = true;
        public bool SkyVisible 
        {
            get => _SkyVisible;
            set 
            {
                _SkyVisible = value;

                if(!_InitPropertiesOk) 
                    return;

                if(_SkyInstance == null)
                    throw new Exception("Sky instance not found");
                
                _SkyInstance.Visible = value;
            }
        } 

        private float _DomeRadius = 10.0f; 
        public float DomeRadius
        {
            get => _DomeRadius;
            set 
            {
                _DomeRadius = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_SkyInstance == null)
                    throw new Exception("Sky instance not found");
                
                _SkyInstance.Scale = value * Vector3.One;

                if(_CloudsCumulusInstance == null)
                    throw new Exception("Clouds instance not found");
                
                _CloudsCumulusInstance.Scale = value * Vector3.One;
            }
        }

        private float _TonemapLevel = 0.0f;
        public float TonemapLevel 
        {
            get => _TonemapLevel;
            set 
            {
                _TonemapLevel = value;
                SetColorCorrectionParams(value, _Exposure);
            }
        }

        private float _Exposure = 1.3f;
        public float Exposure 
        {
            get => _Exposure;
            set 
            {
                _Exposure = value;
                SetColorCorrectionParams(_TonemapLevel, value);
            }
        }

        private Color _GroundColor = new Color(0.3f, 0.3f, 0.3f, 1.0f);
        public Color GroundColor 
        {
            get => _GroundColor;
            set 
            {
                _GroundColor = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kGroundColorP, value);
            }
        }

        private uint _SkyLayers = 4;
        public uint SkyLayers 
        {
            get => _SkyLayers;
            set 
            {
                _SkyLayers = value;
                if(!_InitPropertiesOk)
                    return;
                
                if(_SkyInstance == null)
                    throw new Exception("Sky instance not found");
                
                _SkyInstance.Layers = value;

                if(_CloudsCumulusInstance == null)
                    throw new Exception("Clouds instance not found");
                
                _CloudsCumulusInstance.Layers = value;
            }
        }

        private int _SkyRenderPriority = -128;
        public int SkyRenderPriority 
        {
            get => _SkyRenderPriority;
            set 
            {
                _SkyRenderPriority = value;
                _Resources.SetupSkyResources(value);
                _Resources.SetupCloudsCumulusPriority(value + 1);
            }
        }

        private float _HorizonLevel = 0.0f;
        public float HorizonLevel
        {
            get => _HorizonLevel;
            set 
            {
                _HorizonLevel = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kHorizonLevel, value);
            }
        }

        #endregion

        #region Sun Coords. 

        private float _SunAzimuth = 0.0f;
        public float SunAzimuth 
        {
            get => _SunAzimuth;
            set 
            {
                _SunAzimuth = value;
                SetSunCoords();
            }
        }

        private float _SunAltitude = -27.387f;
        public float SunAltitude 
        {
            get => _SunAltitude;
            set 
            {
                _SunAltitude = value;
                SetSunCoords();
            }
        }

        bool _FinishSetSunPos = false;
        private Transform _SunTransform = new Transform();
        public Transform SunTransform => _SunTransform;
        public Vector3 SunDirection => _SunTransform.origin - SkyConst.kDefaultPosition;
 
        [Signal]
        public delegate void SunDirectionChanged(Vector3 value);

        [Signal]
        public delegate void SunTransformChanged(Transform value);

        #endregion

        #region Moon Coords.

        private float _MoonAzimuth = 5.0f;
        public float MoonAzimuth 
        {
            get => _MoonAzimuth;
            set 
            {
                _MoonAzimuth = value;
                SetMoonCoords();
            }
        }

        private float _MoonAltitude = -80.0f;
        public float MoonAltitude 
        {
            get => _MoonAltitude;
            set 
            {
                _MoonAltitude = value;
                SetMoonCoords();
            }
        }

        bool _FinishSetMoonPos = false;
        private Transform _MoonTransform = new Transform();
        public Transform MoonTransform => _MoonTransform;
        public Vector3 MoonDirection => _MoonTransform.origin - SkyConst.kDefaultPosition;

        [Signal]
        public delegate void MoonDirectionChanged(Vector3 value);

        [Signal]
        public delegate void MoonTransformChanged(Transform value);

        #endregion

        #region Atmosphere.
        
        private SkyShaderQuality _AtmQuality = SkyShaderQuality.PerVertex;
        public SkyShaderQuality AtmQuality 
        { 
            get => _AtmQuality;
            set 
            {
                _AtmQuality = value;
                _Resources.SetupSkyResources(value);
            }
        }

        private Vector3 _AtmWavelenghts = new Vector3(680.0f, 550.0f, 440.0f);
        public Vector3 AtmWavelenghts 
        {
            get => _AtmWavelenghts;
            set 
            {
                _AtmWavelenghts = value;
                SetBetaRay();
            }
        }

        private float _AtmDarkness = 0.5f;
        public float AtmDarkness 
        {
            get => _AtmDarkness;
            set 
            {
                _AtmDarkness = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmDarknessP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmDarknessP, value);
            }
        }

        private float _AtmSunIntensity = 30.0f;
        public float AtmSunIntensity 
        {
            get => _AtmSunIntensity;
            set 
            {
                _AtmSunIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmSunIntensityP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmSunIntensityP, value);
            }
        }

        private Color _AtmDayTint = new Color(0.807843f, 0.909804f, 1.0f, 1.0f);
        public Color AtmDayTint 
        {
            get => _AtmDayTint;
            set 
            {
                _AtmDayTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmDayTintP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmDayTintP, value);
            }
        }

        private Color _AtmHorizonLightTint = new Color(0.980392f, 0.635294f, 0.462745f, 1.0f);
        public Color AtmHorizonLightTint 
        {
            get => _AtmHorizonLightTint;
            set 
            {
                _AtmHorizonLightTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmHorizonLightTintP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmHorizonLightTintP, value);
            }
        }

        private bool _AtmEnableMoonScatterMode = false;
        public bool AtmEnableMoonScatterMode 
        {
            get => _AtmEnableMoonScatterMode;
            set 
            {
                _AtmEnableMoonScatterMode = value;
                SetNightIntensity();
            }
        }

        public float AtmNightIntensity
        {
            get 
            {
                if(!AtmEnableMoonScatterMode)
                    return TOD_Math.Saturate(-SunDirection.y + 0.30f);
                
                return TOD_Math.Saturate(MoonDirection.y) * AtmMoonPhasesMult;
            }
        }

        public float FogAtmNightIntensity 
        {
            get 
            {
                if(!AtmEnableMoonScatterMode)
                    return TOD_Math.Saturate(-SunDirection.y + 0.70f);
                                
                return TOD_Math.Saturate(MoonDirection.y) * AtmMoonPhasesMult;
            }
        }

        public float AtmMoonPhasesMult 
        {
            get 
            {
                if(!AtmEnableMoonScatterMode)
                    return AtmNightIntensity;
                
                return TOD_Math.Saturate(-SunDirection.Dot(MoonDirection) + 0.60f);
            }
        }

        private Color _AtmNightTint = new Color(0.168627f, 0.2f, 0.25098f);
        public Color AtmNightTint 
        {
            get => _AtmNightTint;
            set 
            {
                _AtmNightTint = value;
                SetNightIntensity();
            }
        }

        private Vector3 _AtmLevelParams = new Vector3(1.0f, 0.0f, 0.0f);
        public Vector3 AtmLevelParams 
        {
            get => _AtmLevelParams;
            set 
            {
                _AtmLevelParams = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmLevelParamsP, value);
                FogAtmLevelParamsOffset = FogAtmLevelParamsOffset;
            }
        }

        private float _AtmThickness = 0.7f;
        public float AtmThickness 
        {
            get => _AtmThickness;
            set 
            {
                _AtmThickness = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmThicknessP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmThicknessP, value);
            }
        }

        private float _AtmMie = 0.07f;
        public float AtmMie 
        {
            get => _AtmMie;
            set 
            {
                _AtmMie = value;
                SetBetaMie();
            }
        }

        private float _AtmTurbidity = 0.001f;
        public float AtmTurbidity 
        {
            get => _AtmTurbidity;
            set 
            {
                _AtmTurbidity = value;
                SetBetaMie();
            }
        }

        private Color _AtmSunMieTint = new Color(1.0f, 1.0f, 1.0f, 1.0f);
        public Color AtmSunMieTint 
        {
            get => _AtmSunMieTint;
            set 
            {
                _AtmSunMieTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmSunMieTintP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmSunMieTintP, value);
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kAtmSunMieTintP, value);
            }
        }

        private float _AtmSunMieIntensity = 1.0f;
        public float AtmSunMieIntensity 
        {
            get => _AtmSunMieIntensity;
            set 
            {
                _AtmSunMieIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmSunMieIntensityP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmSunMieIntensityP, value);
            }
        }

        private float _AtmSunMieAnisotropy = 0.8f;
        public float AtmSunMieAnisotropy 
        {
            get => _AtmSunMieAnisotropy;
            set 
            {
                _AtmSunMieAnisotropy = value;
                var partial = ScatterLib.GetPartialMiePhase(value);
                _Resources.SkyMaterial.SetShaderParam(SkyConst.KAtmSunPartialMiePhaseP, partial);
                _Resources.FogMaterial.SetShaderParam(SkyConst.KAtmSunPartialMiePhaseP, partial);
            }
        }

        private Color _AtmMoonMieTint = new Color(0.137255f, 0.184314f, 0.290196f);
        public Color AtmMoonMieTint 
        {
            get => _AtmMoonMieTint;
            set 
            {
                _AtmMoonMieTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmMoonMieTintP, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmMoonMieTintP, value);
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kAtmMoonMieTintP, value);
            }
        }

        private float _AtmMoonMieIntensity = 0.7f;
        public float AtmMoonMieIntensity 
        {
            get => _AtmMoonMieIntensity;
            set 
            {
                _AtmMoonMieIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmMoonMieIntensityP, value * AtmMoonPhasesMult);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmMoonMieIntensityP, value * AtmMoonPhasesMult);
            }
        }

        private float _AtmMoonMieAnisotropy = 0.8f;
        public float AtmMoonMieAnisotropy 
        {
            get => _AtmMoonMieAnisotropy;
            set 
            {
                _AtmMoonMieAnisotropy = value;
                var partial = ScatterLib.GetPartialMiePhase(value);
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmMoonPartialMiePhaseP, partial);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmMoonPartialMiePhaseP, partial);
            }
        }

        #endregion

        #region Atmospheric Fog
        
        private bool _FogVisible = true;
        public bool FogVisible 
        {
            get => _FogVisible;
            set 
            {
                _FogVisible = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_FogInstance == null)
                    throw new Exception("Fog instance not found");
                
                _FogInstance.Visible = value;
            }
        }

        private Vector3 _FogAtmLevelParamsOffset = new Vector3(0.0f, 0.0f, -1.0f); // z = -1.0 for down tintend.
        public Vector3 FogAtmLevelParamsOffset
        {
            get => _FogAtmLevelParamsOffset;
            set
            {
                _FogAtmLevelParamsOffset = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmLevelParamsP, _AtmLevelParams + value);
            }
        }

        private float _FogDensity = 0.00015f;
        public float FogDensity
        {
            get => _FogDensity;
            set 
            {
                _FogDensity = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogDensityP, value);
            }
        }

        private float _FogStart = 0.0f;
        public float FogStart 
        {
            get => _FogStart;
            set 
            {
                _FogStart = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogStart, value);
            }
        }

        private float _FogEnd = 1000.0f;
        public float FogEnd 
        {
            get => _FogEnd;
            set 
            {
                _FogEnd = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogEnd, value);
            }
        }

        private float _FogRayleighDepth = 0.116f;
        public float FogRayleighDepth
        {
            get => _FogRayleighDepth;
            set 
            {
                _FogRayleighDepth = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogRayleighDepthP, value);
            }
        }

        private float _FogMieDepth = 0.0001f;
        public float FogMieDepth 
        {
            get => _FogMieDepth;
            set 
            {
                _FogMieDepth = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogMieDepthP, value);
            }
        }

        private float _FogFalloff = 3.0f;
        public float FogFalloff
        {
            get => _FogFalloff;
            set 
            {
                _FogFalloff = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogFallof, value);
            }
        }

        private uint _FogLayers = 524288;
        public uint FogLayers 
        {
            get => _FogLayers;
            set 
            {
                _FogLayers = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_FogInstance == null)
                    throw new Exception("Fog instance not found");
                
                _FogInstance.Layers = value;
            }
        }

        private int _FogRenderPriority = 123;
        public int FogRenderPriority 
        {
            get => _FogRenderPriority;
            set 
            {
                _FogRenderPriority = value;
                _Resources.SetupFogResources(value);
            }
        }

        #endregion

        #region NearSpace

        private Color _SunDiskColor = new Color(0.996094f, 0.541334f, 0.140076f, 1.0f);
        public Color SunDiskColor 
        {
            get => _SunDiskColor;
            set 
            {
                _SunDiskColor = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kSunDiskColorP, value);
            }
        }

        private float _SunDiskIntensity = 2.0f;
        public float SunDiskIntensity 
        {
            get => _SunDiskIntensity;
            set 
            {
                _SunDiskIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kSunDiskIntensityP, value);
            }
        }

        private float _SunDiskSize = 0.015f;
        public float SunDiskSize 
        {
            get => _SunDiskSize;
            set 
            {
                _SunDiskSize = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kSunDiskSizeP, value);
            }
        }

        private Color _MoonColor = Colors.White;
        public Color MoonColor 
        {
            get => _MoonColor;
            set 
            {
                _MoonColor = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonColorP, value);
            }
        }

        private float _MoonSize = 0.07f;
        public float MoonSize 
        {
            get => _MoonSize;
            set 
            {
                _MoonSize = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonSizeP, value);
            }
        }

        private bool _EnableSetMoonTexture = false;
        public bool EnableSetMoonTexture 
        {
            get => _EnableSetMoonTexture;
            set 
            {
                _EnableSetMoonTexture = value;
                
                if(!value)
                    MoonTexture = _Resources.MoonTexture;
                
                PropertyListChangedNotify();
            }
        }

        private Texture _MoonTexture = null;
        public Texture MoonTexture 
        {
            get => _MoonTexture;
            set 
            {
                _MoonTexture = value;
                _Resources.MoonMaterial.SetShaderParam(SkyConst.kTextureP, value);
            }
        }

        private JC.TimeOfDay.Resolution _MoonResolution = Resolution.R256;
        public JC.TimeOfDay.Resolution MoonResolution 
        {
            get => _MoonResolution;
            set 
            {
                _MoonResolution = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_MoonInstance == null)
                    throw new Exception("Moon instance not found");
                
                switch(value)
                {
                    case Resolution.R64:   _MoonInstance.Size = Vector2.One * 64;   break; 
                    case Resolution.R128:  _MoonInstance.Size = Vector2.One * 128;  break; 
                    case Resolution.R256:  _MoonInstance.Size = Vector2.One * 256;  break; 
                    case Resolution.R512:  _MoonInstance.Size = Vector2.One * 512;  break; 
                    case Resolution.R1024: _MoonInstance.Size = Vector2.One * 1024; break;
                }

                _MoonRT = _MoonInstance.GetTexture();
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonTextureP, _MoonRT);
            }
        }

        #endregion

        #region Near Space Lights

        private Color _SunLightColor = new Color(0.984314f, 0.843137f, 0.788235f);
        public Color SunLightColor 
        {
            get => _SunLightColor;
            set 
            {
                _SunLightColor = value;
                SetSunLightColor(value, _SunHorizonLightColor);
            }
        }

        private Color _SunHorizonLightColor = new Color(1.0f, 0.384314f, 0.243137f);
        public Color SunHorizonLightColor 
        {
            get => _SunHorizonLightColor;
            set 
            {
                _SunHorizonLightColor = value;
                 SetSunLightColor(_SunLightColor, value);
            }
        }

        private float _SunLightEnergy = 1.0f;
        public float SunLightEnergy
        {
            get => _SunLightEnergy;
            set 
            {
                _SunLightEnergy = value;
                SetSunLightEnergy();
            }
        }

        private NodePath _SunLightPath = null;
        public NodePath SunLightPath 
        {
            get => _SunLightPath;
            set 
            {
                _SunLightPath = value;
                if(value != null)
                    _SunLightNode = GetNodeOrNull<DirectionalLight>(value);

                _SunLightReady = _SunLightNode != null ? true: false;

                SetSunCoords();
            }
        }

        private bool _SunLightReady = false;
        private DirectionalLight _SunLightNode = null;
        private float _SunLightAltitudeMult = 0.0f;


        private Color _MoonLightColor = new Color(0.572549f, 0.776471f, 0.956863f);
        public Color MoonLightColor 
        {
            get => _MoonLightColor;
            set 
            {
                _MoonLightColor = value;

                if(_MoonLightReady)
                    _MoonLightNode.LightColor = value;
            }
        }

        private float _MoonLightEnergy = 0.3f;
        public float MoonLightEnergy 
        {
            get => _MoonLightEnergy;
            set 
            {
                _MoonLightEnergy = value;
                SetMoonLightEnergy();
            }
        }

        private NodePath _MoonLightPath = null;
        public NodePath MoonLightPath
        {
            get => _MoonLightPath;
            set 
            {
                _MoonLightPath = value;

                if(value != null)
                    _MoonLightNode = GetNodeOrNull<DirectionalLight>(value);
                
                _MoonLightReady = _MoonLightNode != null ? true: false;
                
                SetMoonCoords();
            }
        }

        private DirectionalLight _MoonLightNode = null;
        private bool _MoonLightReady = false;
        private float _MoonLightAltitudeMult = 0.0f;


        #endregion

        #region Deep Space 

        private Vector3 _DeepSpaceEuler = new Vector3(-0.752f, -2.56f, 0.0f);
        public Vector3 DeepSpaceEuler 
        {
            get => _DeepSpaceEuler;
            set 
            {
                _DeepSpaceEuler = value;
                _DeepSpaceBasis = new Basis(value);
                _DeepSpaceQuat = _DeepSpaceBasis.RotationQuat();
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kDeepSpaceMatrixP, _DeepSpaceBasis);
            }
        }

        private Quat _DeepSpaceQuat = Quat.Identity;
        public Quat DeepSpaceQuat 
        {
            get => _DeepSpaceQuat;
            set 
            {
                _DeepSpaceQuat = value;
                _DeepSpaceBasis = new Basis(value);
                _DeepSpaceEuler = _DeepSpaceBasis.GetEuler();
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kDeepSpaceMatrixP, _DeepSpaceBasis);
            }
        }
 
        private Basis _DeepSpaceBasis;

        private Color _BackgroundColor = new Color(0.709804f, 0.709804f, 0.709804f, 0.854902f);
        public Color BackgroundColor 
        {
            get => _BackgroundColor;
            set 
            {
                _BackgroundColor = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kBGColP, value);
            }
        }

        private bool _SetBackgroundTexture = false;
        public bool SetBackgroundTexture 
        {
            get => _SetBackgroundTexture;
            set 
            {
                _SetBackgroundTexture = value;

                if(!value)
                    BackgroundTexture = _Resources.BackgroundTexture;
                
                PropertyListChangedNotify();
            }
        }

        private Texture _BackgroundTexture = null;
        public Texture BackgroundTexture 
        {
            get => _BackgroundTexture;
            set 
            {
                _BackgroundTexture = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kBGTextureP, value);
            }
        }
        
        private Color _StarsFieldColor = Colors.White;
        public Color StarsFieldColor 
        {
            get => _StarsFieldColor;
            set 
            {
                _StarsFieldColor = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kStarsColorP, value);
            }
        }

        private bool _SetStarsFieldTexture = false;
        public bool SetStarsFieldTexture 
        {
            get => _SetStarsFieldTexture;
            set 
            {
                _SetStarsFieldTexture = value;

                if(!value)
                    StarsFieldTexture = _Resources.StarsFieldTexture;
                
                PropertyListChangedNotify();
            }
        }

        private Texture _StarsFieldTexture = null;
        public Texture StarsFieldTexture 
        {
            get => _StarsFieldTexture;
            set 
            {
                _StarsFieldTexture = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kStarsTextureP, value);
            }
        }

        private float _StarsScintillation = 0.75f;
        public float StarsScintillation 
        {
            get => _StarsScintillation;
            set 
            {
                _StarsScintillation = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kStarsScP, value);
            }
        }

        private float _StarsScintillationSpeed = 0.01f;
        public float StarsScintillationSpeed
        {
            get => _StarsScintillationSpeed;
            set 
            {
                _StarsScintillationSpeed = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kStarsScSpeedP, value);
            }
        }

        #endregion

        #region 2D Clouds

        private float _CloudsThickness = 1.7f;
        public float CloudsThickness 
        {
            get => _CloudsThickness;
            set 
            {
                _CloudsThickness = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsThickness, value);

            }
        }

        private float _CloudsCoverage = 0.5f;
        public float CloudsCoverage 
        {
            get => _CloudsCoverage;
            set 
            {
                _CloudsCoverage = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsCoverage, value);
            }
        }

        private float _CloudsAbsorption = 2.0f;
        public float CloudsAbsorption 
        {
            get => _CloudsAbsorption;
            set 
            {
                _CloudsAbsorption = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsAbsorption, value);
            }
        }

        private float _CloudsSkyTintFade = 0.5f;
        public float CloudsSkyTintFade 
        {
            get => _CloudsSkyTintFade;
            set 
            {
                _CloudsSkyTintFade = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsSkyTintFade, value);
            }
        }

        private float _CloudsIntensity = 10.0f;
        public float CloudsIntensity 
        {
            get => _CloudsIntensity;
            set 
            {
                _CloudsIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsIntensity, value);
            }
        }

        private float _CloudsSize = 2.0f;
        public float CloudsSize 
        {
            get => _CloudsSize;
            set 
            {
                _CloudsSize = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsSize, value);
            }
        }

        private Vector2 _CloudsUV = new Vector2(0.16f, 0.11f);
        public Vector2 CloudsUV 
        {
            get => _CloudsUV;
            set 
            {
                _CloudsUV = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsUV, value);
            }
        }

        private Vector2 _CloudsOffset = new Vector2(0.21f, 0.175f);
        public Vector2 CloudsOffset 
        {
            get => _CloudsOffset;
            set 
            {
                _CloudsOffset = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsOffset, value);
            }
        }

        private float _CloudsOffsetSpeed = 0.01f;
        public float CloudsOffsetSpeed 
        {
            get => _CloudsOffsetSpeed;
            set 
            {
                _CloudsOffsetSpeed = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsOffsetSpeed, value);
            }
        }

        private bool _SetCloudsTexture = false;
        public bool SetCloudsTexture
        {
            get => _SetCloudsTexture;
            set 
            {
                _SetCloudsTexture = value;

                if(!value)
                    CloudsTexture = _Resources.CloudsTexture;
                
                PropertyListChangedNotify();
            }

        }

        private Texture _CloudsTexture = null;
        public Texture CloudsTexture 
        {
            get => _CloudsTexture;
            set 
            {
                _CloudsTexture = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kCloudsTexture, value);
            }
        }

        #endregion

        #region Clouds Cumulus 

        private bool _CloudsCumulusVisible = true;
        public bool CloudsCumulusVisible 
        {
            get => _CloudsCumulusVisible;
            set 
            {
                _CloudsCumulusVisible = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_CloudsCumulusInstance == null)
                    throw new Exception("Clouds instance not found");
                
                _CloudsCumulusInstance.Visible = value;
            }
        }

        private Color _CloudsCumulusDayColor = new Color(0.823529f, 0.87451f, 1.0f, 1.0f);
        public Color CloudsCumulusDayColor 
        {
            get => _CloudsCumulusDayColor;
            set 
            {
                _CloudsCumulusDayColor = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsDayColor, value);
            }
        }

        private Color _CloudsCumulusHorizonLightColor = new Color(1.0f, 0.333333f, 0.152941f, 1.0f);
        public Color CloudsCumulusHorizonLightColor 
        {
            get => _CloudsCumulusHorizonLightColor;
            set 
            {
                _CloudsCumulusHorizonLightColor = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsHorizonLightColor, value);
            }
        }

        private Color _CloudsCumulusNightColor = new Color(0.090196f, 0.094118f, 0.129412f, 1.0f);
        public Color CloudsCumulusNightColor
        {
            get => _CloudsCumulusNightColor;
            set 
            {
                _CloudsCumulusNightColor = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsNightColor, value);
            }
        }

        private float _CloudsCumulusThickness = 0.0243f;
        public float CloudsCumulusThickness 
        {
            get => _CloudsCumulusThickness;
            set 
            {
                _CloudsCumulusThickness = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsThickness, value);
            }
        }

        private float _CloudsCumulusCoverage = 0.55f;
        public float CloudsCumulusCoverage 
        {
            get => _CloudsCumulusCoverage;
            set 
            {
                _CloudsCumulusCoverage = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsCoverage, value);
            }
        }

        private float _CloudsCumulusAbsorption = 2.0f;
        public float CloudsCumulusAbsorption 
        {
            get => _CloudsCumulusAbsorption;
            set 
            {
                _CloudsCumulusAbsorption = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsAbsorption, value);
            }
        }

        private float _CloudsCumulusNoiseFreq = 2.7f;
        public float CloudsCumulusNoiseFreq 
        {
            get => _CloudsCumulusNoiseFreq;
            set 
            {
                _CloudsCumulusNoiseFreq = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsNoiseFreq, value);
            }
        }

        private float _CloudsCumulusIntensity = 1.0f;
        public float CloudsCumulusIntensity 
        {
            get => _CloudsCumulusIntensity;
            set 
            {
                _CloudsCumulusIntensity = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsIntensity, value);
            }
        }

        private float _CloudsCumulusMieIntensity = 1.0f;
        public float CloudsCumulusMieIntensity
        {
            get => _CloudsCumulusMieIntensity;
            set 
            {
                _CloudsCumulusMieIntensity = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsMieIntensity, value);
            }
        }

        private float _CloudsCumulusMieAnisotropy = 0.206f;
        public float CloudsCumulusMieAnisotropy
        {
            get => _CloudsCumulusMieAnisotropy;
            set 
            {
                _CloudsCumulusMieAnisotropy = value;

                var partial = ScatterLib.GetPartialMiePhase(value);
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsPartialMiePhase, partial);
            }
        }

        private float _CloudsCumulusSize = 0.5f;
        public float CloudsCumulusSize 
        {
            get => _CloudsCumulusSize;
            set 
            {
                _CloudsCumulusSize = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsSize, value);
            }
        }

        private Vector3 _CloudsCumulusOffset = new Vector3(0.64f, 0.522f, 0.128f);
        public Vector3 CloudsCumulusOffset 
        {
            get => _CloudsCumulusOffset;
            set 
            {
                _CloudsCumulusOffset = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsOffset, value);
            }
        }

        private float _CloudsCumulusOffsetSpeed = 0.005f;
        public float CloudsCumulusOffsetSpeed 
        {
            get => _CloudsCumulusOffsetSpeed;
            set 
            {
                _CloudsCumulusOffsetSpeed = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsOffsetSpeed, value);
            }
        }

        private bool _SetCloudsCumulusTexture = false;
        public bool SetCloudsCumulusTexture
        {
            get => _SetCloudsCumulusTexture;
            set 
            {
                _SetCloudsCumulusTexture = value;

                if(!value)
                    CloudsCumulusTexture = _Resources.CloudsCumulusTexture;
                
                PropertyListChangedNotify();
            }

        }

        private Texture _CloudsCumulusTexture = null;
        public Texture CloudsCumulusTexture 
        {
            get => _CloudsCumulusTexture;
            set 
            {
                _CloudsCumulusTexture = value;
                _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kCloudsTexture, value);
            }
        }


        #endregion

        #region Environment

        private bool _EnableEnviro = false;

        private Godot.Environment _Enviro = null;
        public Godot.Environment Enviro 
        {
            get => _Enviro;
            set 
            {
                _Enviro = value;
                _EnableEnviro = Enviro == null ? false : true;

                if(_EnableEnviro && _InitPropertiesOk)
                    UpdateEnviro();
            }
        }

        #endregion

    #endregion

    #region Resources And Instances

        private SkyDomeResources _Resources = new SkyDomeResources();
    
        // Instances.
        private MeshInstance _SkyInstance = null;
        private MeshInstance _FogInstance = null;

        private Viewport _MoonInstance = null;
        private ViewportTexture _MoonRT = null;
        private Spatial _MoonInstanceTransform = null;
        private MeshInstance _MoonInstanceMesh = null;

        private MeshInstance _CloudsCumulusInstance = null;

        private bool CheckInstances
        {
            get 
            {
                _SkyInstance  = GetNodeOrNull<MeshInstance>(SkyConst.kSkyInstance);
                _MoonInstance = GetNodeOrNull<Viewport>(SkyConst.kMoonInstance);
                _FogInstance  = GetNodeOrNull<MeshInstance>(SkyConst.kFogInstance);
                _CloudsCumulusInstance = GetNodeOrNull<MeshInstance>(SkyConst.kCloudsCInstance);

                if(_SkyInstance == null)  return false;
                if(_MoonInstance == null) return false;
                if(_FogInstance == null)  return false;
                if(_CloudsCumulusInstance == null) return false;

                return true;
            }
        }
    
    #endregion

    #region Build in

        public Skydome() 
        {
            _Resources.SetupSkyResources(_AtmQuality, _SkyRenderPriority);
            _Resources.SetupMoonResources();
            _Resources.SetupFogResources();
            _Resources.SetupCloudsCumulusResources(_SkyRenderPriority+1);

            ForceSetupInstances();
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kNoiseTex, _Resources.StarsFieldNoise);
        }

        public override void _EnterTree()
        {

            BuildDome();
            InitProperties();
        }

        public override void _Ready()
        {
            SetSunCoords();
            SetMoonCoords();
        }

    #endregion

    #region Setup

        private void InitProperties()
        {
            _InitPropertiesOk = true;

            // Globals.
            SkyVisible = SkyVisible;
            DomeRadius = DomeRadius;
            TonemapLevel = TonemapLevel;
            Exposure = Exposure;
            GroundColor = GroundColor;
            SkyLayers = SkyLayers;
            SkyRenderPriority = SkyRenderPriority;

            SunAzimuth = SunAzimuth;
            SunAltitude = SunAltitude;

            MoonAzimuth = MoonAzimuth;
            MoonAltitude = MoonAltitude;
            
            // Atmosphere.
            AtmQuality = AtmQuality;
            AtmWavelenghts = AtmWavelenghts;
            AtmDarkness = AtmDarkness;
            AtmSunIntensity = AtmSunIntensity;
            AtmDayTint = AtmDayTint;
            AtmHorizonLightTint = AtmHorizonLightTint;
            AtmEnableMoonScatterMode = AtmEnableMoonScatterMode;
            AtmNightTint = AtmNightTint;
            AtmLevelParams = AtmLevelParams;
            AtmThickness = AtmThickness;
            AtmMie = AtmMie;
            AtmTurbidity = AtmTurbidity;
            AtmSunMieTint = AtmSunMieTint;
            AtmSunMieIntensity = AtmSunMieIntensity;
            AtmSunMieAnisotropy = AtmSunMieAnisotropy;
            AtmMoonMieTint = AtmMoonMieTint;
            AtmMoonMieIntensity = AtmMoonMieIntensity;
            AtmMoonMieAnisotropy = AtmMoonMieAnisotropy;

            FogVisible = FogVisible;
            FogAtmLevelParamsOffset = FogAtmLevelParamsOffset;
            FogDensity = FogDensity;
            FogRayleighDepth = FogRayleighDepth;
            FogMieDepth = FogMieDepth;
            FogFalloff = FogFalloff;
            FogStart = FogStart;
            FogEnd = FogEnd;
            FogLayers = FogLayers;
            FogRenderPriority = FogRenderPriority;

            SunDiskColor = SunDiskColor;
            SunDiskIntensity = SunDiskIntensity;
            SunDiskSize = SunDiskSize;

            MoonColor = MoonColor;
            MoonSize = MoonSize;
            EnableSetMoonTexture = EnableSetMoonTexture;

            if(EnableSetMoonTexture)
                MoonTexture = MoonTexture;
            
            MoonResolution = MoonResolution;

            SunLightPath = SunLightPath;
            SunLightColor = SunLightColor;
            SunHorizonLightColor = SunHorizonLightColor;
            SunLightEnergy = SunLightEnergy;

            MoonLightPath = MoonLightPath;
            MoonLightColor = MoonLightColor;
            MoonLightEnergy = MoonLightEnergy;

            DeepSpaceEuler = DeepSpaceEuler;
            DeepSpaceQuat = DeepSpaceQuat;
            BackgroundColor = BackgroundColor;
            SetBackgroundTexture = SetBackgroundTexture;
            if(SetBackgroundTexture)
                BackgroundTexture = BackgroundTexture;
            
            StarsFieldColor = StarsFieldColor;
            SetStarsFieldTexture = SetStarsFieldTexture;

            if(SetStarsFieldTexture)
                StarsFieldTexture = StarsFieldTexture;

            StarsScintillation = StarsScintillation;
            StarsScintillationSpeed = StarsScintillationSpeed;


            CloudsThickness = CloudsThickness;
            CloudsCoverage = CloudsCoverage;
            CloudsAbsorption = CloudsAbsorption;
            CloudsSkyTintFade = CloudsSkyTintFade;
            CloudsIntensity = CloudsIntensity;
            CloudsSize = CloudsSize;
            CloudsUV = CloudsUV;
            CloudsOffset = CloudsOffset;
            CloudsOffsetSpeed = CloudsOffsetSpeed;
            SetCloudsTexture = SetCloudsTexture;

            if(SetCloudsTexture)
                CloudsTexture = CloudsTexture;
            

            CloudsCumulusVisible = CloudsCumulusVisible;
            CloudsCumulusDayColor = CloudsCumulusDayColor;
            CloudsCumulusHorizonLightColor = CloudsCumulusHorizonLightColor;
            CloudsCumulusNightColor = CloudsCumulusNightColor;

            CloudsCumulusThickness = CloudsCumulusThickness;
            CloudsCumulusCoverage = CloudsCumulusCoverage;
            CloudsCumulusAbsorption = CloudsCumulusAbsorption;
            CloudsCumulusIntensity = CloudsCumulusIntensity;
            CloudsCumulusMieIntensity = CloudsCumulusMieIntensity;
            CloudsCumulusMieAnisotropy = CloudsCumulusMieAnisotropy;
            CloudsCumulusNoiseFreq = CloudsCumulusNoiseFreq;
            CloudsCumulusSize = CloudsCumulusSize;
            CloudsCumulusOffset = CloudsCumulusOffset;
            CloudsCumulusOffsetSpeed = CloudsCumulusOffsetSpeed;
            SetCloudsCumulusTexture = SetCloudsCumulusTexture;

            if(SetCloudsCumulusTexture)
                CloudsCumulusTexture = CloudsCumulusTexture;
            
            Enviro = Enviro;
        }

        private void BuildDome()
        {
            // Sky.
            _SkyInstance = this.GetOrCreate<MeshInstance>(this, SkyConst.kSkyInstance, false);

            // Moon.
            _MoonInstance = GetNodeOrNull<Viewport>(SkyConst.kMoonInstance);
            if(_MoonInstance == null)
            {
       
                _MoonInstance = _Resources.MoonRender.Instance() as Viewport;
                this.AddChild(_MoonInstance);
                //_MoonInstance.Owner = this.GetTree().EditedSceneRoot;
            }

            // Fog.
            _FogInstance = this.GetOrCreate<MeshInstance>(this, SkyConst.kFogInstance, false);

            // Clouds.
            _CloudsCumulusInstance = this.GetOrCreate<MeshInstance>(this, SkyConst.kCloudsCInstance, false);
            
            SetupInstances();
        }

        // Prevents save scene errors.
        private void ForceSetupInstances()
        {       
            if(CheckInstances)
            {
                _InitPropertiesOk = true;
                SetupInstances();
            }
        }

        private void SetupInstances()
        {
            if(_SkyInstance == null)
                throw new Exception("Sky instance not found");

            SetupMeshInstance(_SkyInstance, _Resources.SkydomeMesh, _Resources.SkyMaterial, SkyConst.kDefaultPosition);

            if(_MoonInstance == null)
                throw new Exception("Moon instance not found");
            
            _MoonInstanceTransform = _MoonInstance.GetNodeOrNull<Spatial>("MoonTransform");
            _MoonInstanceMesh = _MoonInstanceTransform.GetNodeOrNull<MeshInstance>("Camera/Mesh");
            _MoonInstanceMesh.MaterialOverride = _Resources.MoonMaterial;
            
            if(_FogInstance == null)
                throw new Exception("Fog instance not found");
            
            SetupMeshInstance(_FogInstance, _Resources.FullScreenQuad, _Resources.FogMaterial, Vector3.Zero);

            if(_CloudsCumulusInstance == null)
                throw new Exception("Clouds instance not found");
            
            SetupMeshInstance(_CloudsCumulusInstance, _Resources.CloudsCumulusMesh, _Resources.CloudsCumulusMaterial, SkyConst.kDefaultPosition);
        }

        private void SetupMeshInstance(MeshInstance target, Mesh mesh, Material mat,  Vector3 origin)
        {
            var tmpTransform = target.Transform;
            tmpTransform.origin = origin;
            target.Transform = tmpTransform;
            target.Mesh = mesh;
            target.ExtraCullMargin = SkyConst.kMaxExtraCullMargin;
            target.CastShadow = GeometryInstance.ShadowCastingSetting.Off;
            target.MaterialOverride = mat;
        }

    #endregion

    #region General

        private void SetColorCorrectionParams(float tonemap, float exposure)
        {
            Vector2 p;
            p.x = tonemap;
            p.y = exposure;
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kColorCorrectionP, p);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kColorCorrectionP, p);
        }

    #endregion

    #region Coords

        private void SetSunCoords()
        {
            if(!_InitPropertiesOk)
                return;

            if(_SkyInstance == null)
                throw new Exception("Sky instance not found");
            
            float azimuth = SunAzimuth * TOD_Math.kDegToRad;
            float altitude = SunAltitude * TOD_Math.kDegToRad;

            _FinishSetSunPos = false;
            if(!_FinishSetSunPos)
            {
                _SunTransform.origin = TOD_Math.ToOrbit(altitude, azimuth);
                _FinishSetSunPos = true;
            }

            if(_FinishSetSunPos)
            {
                _SunTransform = _SunTransform.LookingAt(SkyConst.kDefaultPosition, Vector3.Left);
            }

            SetDayState(altitude);
            EmitSignal(nameof(SunTransformChanged), _SunTransform);
            EmitSignal(nameof(SunDirectionChanged), SunDirection);

            // Set Sun Direction.
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);
            _Resources.MoonMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);
            _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);

            if(_SunLightReady)
            {
                //if(_SunLightNode.LightEnergy > 0.0 && (Mathf.Abs(_SunAltitude) < 90.0f))
                if(_SunLightNode.LightEnergy > 0.0)
                    _SunLightNode.Transform = _SunTransform;
            }

            _SunLightAltitudeMult = TOD_Math.Saturate(SunDirection.y);

            SetNightIntensity();
            SetSunLightColor(_SunLightColor, _SunHorizonLightColor);
            SetSunLightEnergy();
            SetMoonLightEnergy();
            UpdateEnviro();
        }

        private void SetMoonCoords()
        {
            if(!_InitPropertiesOk)
                return;

            if(_SkyInstance == null)
                throw new Exception("Sky instance not found");

            float azimuth = _MoonAzimuth * TOD_Math.kDegToRad;
            float altitude = _MoonAltitude * TOD_Math.kDegToRad;

            _FinishSetMoonPos = false;
            if(!_FinishSetMoonPos)
            {
                _MoonTransform.origin = TOD_Math.ToOrbit(altitude, azimuth);
                _FinishSetMoonPos = true;
            }

            if(_FinishSetMoonPos)
            {
                _MoonTransform = _MoonTransform.LookingAt(SkyConst.kDefaultPosition, Vector3.Left);
            }

            EmitSignal(nameof(MoonDirectionChanged), MoonDirection);
            EmitSignal(nameof(MoonTransformChanged), _MoonTransform);

            _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonDirP, MoonDirection);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kMoonDirP, MoonDirection);
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonMatrixP, _MoonTransform.basis.Inverse());
            _Resources.MoonMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);
            _Resources.CloudsCumulusMaterial.SetShaderParam(SkyConst.kMoonDirP, MoonDirection);

            if(_MoonInstanceTransform == null)
                throw new Exception("Moon instance transform not found");
            
            _MoonInstanceTransform.Transform = _MoonTransform;

            if(_MoonLightReady)
            {
                //if(_MoonLightNode.LightEnergy > 0.0f && (Mathf.Abs(_MoonAltitude) < 90.0f))  
                if(_MoonLightNode.LightEnergy > 0.0f)
                    _MoonLightNode.Transform = _MoonTransform;
            }

            _MoonLightAltitudeMult = TOD_Math.Saturate(MoonDirection.y);

            SetNightIntensity();
            MoonLightColor = MoonLightColor;
            SetMoonLightEnergy();
            UpdateEnviro();
        }

    #endregion

    #region Atmosphere

        private void SetBetaRay()
        {
            var wll = ScatterLib.ComputeWavelenghtsLambda(_AtmWavelenghts);
            var wls = ScatterLib.ComputeWavelenghts(wll);
            var betaRay = ScatterLib.ComputeBetaRay(wls);
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmBetaRayP, betaRay);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmBetaRayP, betaRay);
        }

        private void SetBetaMie()
        {
            var bM = ScatterLib.ComputeBetaMie(_AtmMie, _AtmTurbidity);
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmBetaMieP, bM);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmBetaMieP, bM);
        }
 
        private void SetNightIntensity()
        {
            Color tint = _AtmNightTint * AtmNightIntensity;
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmNightTintP, tint);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmNightTintP, _AtmNightTint * FogAtmNightIntensity);

            AtmMoonMieIntensity = AtmMoonMieIntensity;
        }

    #endregion

    #region Lighting

        [Signal]
        public delegate void IsDay(bool value);
        
        private void SetDayState(float v, float threshold = 1.80f)
        {
            if(Mathf.Abs(v) > threshold)
                EmitSignal(nameof(IsDay), false);
            else 
                EmitSignal(nameof(IsDay), true);
            
            EvaluateLightEnable();
        }

        /*private void EvaluateLightEnable()
        {
            if(!_SunLightReady)
                return;

            _SunLightNode.Visible = _SunLightNode.LightEnergy > 0.0f ? true : false;;
            
            if(_MoonLightReady)
                _MoonLightNode.Visible = !_SunLightNode.Visible;
        }*/

        bool _LightEnable;
        private void EvaluateLightEnable()
        {

            if(_SunLightReady)
            {
                _LightEnable = _SunLightNode.LightEnergy > 0.0 ? true : false;
                _SunLightNode.Visible = _LightEnable;
            }

            if(_MoonLightReady) 
            {
                _MoonLightNode.Visible = !_LightEnable;
            }
        }

        private void SetSunLightColor(Color col, Color horizonCol)
        {
            if(_SunLightReady)
                _SunLightNode.LightColor = TOD_Math.Lerp(horizonCol, col, _SunLightAltitudeMult);
        }

        private void SetSunLightEnergy()
        {
            if(_SunLightReady)
                _SunLightNode.LightEnergy = TOD_Math.Lerp(0.0f, _SunLightEnergy, _SunLightAltitudeMult);
        }

        private void SetMoonLightEnergy()
        {
            if(!_MoonLightReady) 
                return;

            var l = TOD_Math.Lerp(0.0f, _MoonLightEnergy, _MoonLightAltitudeMult);
            l *= AtmMoonPhasesMult;

            var fade = (1.0f - SunDirection.y) * 0.5f;
            _MoonLightNode.LightEnergy = l * _Resources.SunMoonCurveFade.InterpolateBaked(fade);
        }

        private void UpdateEnviro()
        {
            if(!_EnableEnviro)
                return;
            
            var a = TOD_Math.Saturate(1.0f - SunDirection.y);
            var b = TOD_Math.Saturate(-SunDirection.y + 0.60f);
            
            Color colA = TOD_Math.Lerp(AtmDayTint * 0.5f, AtmHorizonLightTint, a);
            Color colB = TOD_Math.Lerp(colA, AtmNightTint * AtmNightIntensity, b);

            Enviro.AmbientLightColor = colB;
        }

    #endregion

    }
}
