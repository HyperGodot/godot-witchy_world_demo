/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Sky public enums.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/

using Godot;
using System;

namespace JC.TimeOfDay
{

    public enum SkydomeMeshQuality 
    {
        Low = 0,
        High
    }

    public enum SkyShaderQuality 
    {
        PerPixel = 0,
        PerVertex
    }

    public enum Resolution 
    {
        R64,
        R128,
        R256,
        R512,
        R1024
    }
}
