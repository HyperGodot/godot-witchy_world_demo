/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Editor.
°   -----------------------------------------------------
°   Description:
°       Editor Plugin.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
#if TOOLS
using Godot;
using System;

namespace JC.TimeOfDay
{
    [Tool]
    public class TOD_Editor : EditorPlugin
    {
        Script _SkydomeScript = 
            GD.Load<Script>("res://addons/jc.godot.time-of-day-mono/Code/Sky/Skydome.cs");
        
        Texture _SkydomeTexture = 
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Gizmos/SkyIcon.png");
        
        Script _TimeOfDayScript = 
            GD.Load<Script>("res://addons/jc.godot.time-of-day-mono/Code/TimeOfDay/TimeOfDay.cs");
        
        Texture _TimeOfDayTexture = 
            GD.Load<Texture>("res://addons/jc.godot.time-of-day-common/Assets/MyAssets/Graphics/Gizmos/SkyIcon.png");

        public override void _EnterTree()
        {
            AddCustomType("Skydome", "Node", _SkydomeScript, _SkydomeTexture);
            AddCustomType("TimeOfDay", "Node", _TimeOfDayScript, _TimeOfDayTexture);
        }

        public override void _ExitTree()
        {
            RemoveCustomType("Skydome");
            RemoveCustomType("TimeOfDay");
        }
    }
}
#endif
