/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Skydome Resources..
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
    public class SkyDomeResources : Resource
    {
        // Meshes.
        public SphereMesh SkydomeMesh{ get; private set; } = new SphereMesh();
        public SphereMesh CloudsCumulusMesh{ get; private set; } = new SphereMesh{ RadialSegments = 8, Rings = 4 };
        public QuadMesh FullScreenQuad{ get; private set; } = new QuadMesh();

        // Materials.
        public ShaderMaterial SkyMaterial{ get; set; } = new ShaderMaterial();
        public ShaderMaterial FogMaterial{ get; set; } = new ShaderMaterial();
        public ShaderMaterial MoonMaterial{ get; set; } = new ShaderMaterial();
        public ShaderMaterial CloudsCumulusMaterial{ get; set; } = new ShaderMaterial();

        // Shaders.
        Shader _SkyShader    = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/Sky.shader");
        Shader _PVSkyShader  = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/PerVertexSky.shader");
        Shader _AtmFogShader = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/AtmFog.shader");
        Shader _MoonShader   = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/SimpleMoon.shader");
        Shader _CloudsCumulusShader = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/CloudsCumulus.shader");
        // Scenes. 
        public PackedScene MoonRender{ get; private set; } = 
            GD.Load<PackedScene>("res://addons/jc.godot.time-of-day-common/Scenes/Moon/MoonRender.tscn");

        // Textures.
        public Texture MoonTexture{ get; private set; } = 
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MoonMap/MoonMap.png");
        
        public Texture BackgroundTexture{ get; private set; } =
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/Milkyway.jpg");

        public Texture StarsFieldTexture{ get; private set; } =
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/ThirdParty/Graphics/Textures/MilkyWay/StarField.jpg");

        public Curve SunMoonCurveFade{ get; private set; } =
            GD.Load<Curve>("res://addons/jc.godot.time-of-day-common/Resources/SunMoonLightFade.tres");
        
        public Texture StarsFieldNoise{ get; private set; } =
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Textures/noise.jpg");
        
        public Texture CloudsTexture{ get; private set; } = 
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Resources/SNoise.tres");
        
        public Texture CloudsCumulusTexture{ get; private set; } =
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Textures/noiseClouds.png");

    #region Sky

        void ChangeSkydomeMeshQuality(SkydomeMeshQuality quality)
        {
       
            if(quality == 0)
            {
                SkydomeMesh.RadialSegments = 16;
                SkydomeMesh.Rings = 8;
            }
            else 
            {
                SkydomeMesh.RadialSegments = 64;
                SkydomeMesh.Rings = 64;
            }
        }

        void SetSkyQuality(SkyShaderQuality quality)
        {

            if(quality == 0)
            {
                SkyMaterial.Shader = _SkyShader;
                ChangeSkydomeMeshQuality(SkydomeMeshQuality.Low);
            }
            else
            { 
                SkyMaterial.Shader = _PVSkyShader;
                ChangeSkydomeMeshQuality(SkydomeMeshQuality.High);
            }
        }

        public void SetupSkyResources(SkyShaderQuality quality)
        {
            SetSkyQuality(quality);
        }

        public void SetupSkyResources(int renderPriority)
        {
            SkyMaterial.RenderPriority = renderPriority;
        }

        public void SetupSkyResources(SkyShaderQuality quality, int renderPriority)
        {
            SetSkyQuality(quality);
            SetupSkyResources(renderPriority);
        }

    #endregion

    #region Moon

        public void SetupMoonResources()
        {
            MoonMaterial.Shader = _MoonShader;
            MoonMaterial.SetupLocalToScene();
        }
    
    #endregion

    #region Fog

        public void SetupFogResources()
        {
            Vector2 size;
            size.x = 2.0f;
            size.y = 2.0f;
            FullScreenQuad.Size = size;
            FogMaterial.Shader = _AtmFogShader;
            SetupFogResources(127); // default.
        }

        public void SetupFogResources(int renderPriority)
        {
            FogMaterial.RenderPriority = renderPriority;
        }

    #endregion

    #region CloudsCumulus

        public void SetupCloudsCumulusResources(int renderPriority)
        {
            CloudsCumulusMaterial.Shader = _CloudsCumulusShader;
            SetupCloudsCumulusPriority(renderPriority);
        }

        public void SetupCloudsCumulusPriority(int renderPriority)
        {
            CloudsCumulusMaterial.RenderPriority = renderPriority;
        }

    #endregion

    }
}
