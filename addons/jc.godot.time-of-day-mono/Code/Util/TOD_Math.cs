/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Utility.
°   -----------------------------------------------------
°   Description:
°       Math for ToD.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
using Godot;
using System;
using System.Runtime.CompilerServices;

namespace JC.TimeOfDay
{
    public struct TOD_Math 
    {
        /// <summary></summary>
        public const float kRadToDeg = 57.2957795f;

        /// <summary></summary>
        public const float kDegToRad = 0.0174533f;

        /// <summary> Returns the value clamped between 0 and 1. </summary> 
        /// <param name="value"> Value to clamp </param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float Saturate(float value)
        {
            return value < 0.0f ? 0.0f : value > 1.0f ? 1.0f : value;
        }

        /// <summary> Returns the value clamped between 0 and 1. </summary> 
        /// <param name="value"> Value to clamp </param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Vector3 Saturate(Vector3 value)
        {
            Vector3 ret;
            ret.x = value.x < 0.0f ? 0.0f : value.x > 1.0f ? 1.0f : value.x;
            ret.y = value.y < 0.0f ? 0.0f : value.y > 1.0f ? 1.0f : value.y;
            ret.z = value.z < 0.0f ? 0.0f : value.z > 1.0f ? 1.0f : value.z;

            return ret;
        }

        /// <summary> Returns the value clamped between 0 and 1. </summary> 
        /// <param name="value"> Value to clamp </param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Color Saturate(Color value)
        {
            Color ret;
            ret.r = value.r < 0.0f ? 0.0f : value.r > 1.0f ? 1.0f : value.r;
            ret.g = value.g < 0.0f ? 0.0f : value.g > 1.0f ? 1.0f : value.g;
            ret.b = value.b < 0.0f ? 0.0f : value.b > 1.0f ? 1.0f : value.b;
            ret.a = value.a < 0.0f ? 0.0f : value.a > 1.0f ? 1.0f : value.a;

            return ret;
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float Rev(float value) 
        {
            return value - Mathf.Floor(value / 360.0f) * 360.0f;
        }

        /// <summary> Linear interpolation between two values(Precise method). </summary>
        /// <param "from"> Initial value. </param>
        /// <param "to"> Destination value. </param>
        /// <param "t"> Amount. </param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float Lerp(float from, float to, float t)
        {
            return (1.0f - t) * from + t * to;
        }

        /// <summary> Linear interpolation between two values(Precise method). </summary>
        /// <param "from"> Initial value. </param>
        /// <param "to"> Destination value. </param>
        /// <param "t"> Amount. </param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Vector3 Lerp(Vector3 from, Vector3 to, float t)
        {
            return (1.0f - t) * from + t * to;
        }

        /// <summary> Linear interpolation between two values(Precise method). </summary>
        /// <param "from"> Initial value. </param>
        /// <param "to"> Destination value. </param>
        /// <param "t"> Amount. </param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Color Lerp(Color from, Color to, float t)
        {
            return (1.0f - t) * from + t * to;
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Vector3 ToOrbit(float theta, float pi, float radius = 1.0f)
        {
            Vector3 ret;
            float sinTheta = Mathf.Sin(theta);
            float cosTheta = Mathf.Cos(theta);
            float sinPI = Mathf.Sin(pi);
            float cosPI = Mathf.Cos(pi);

            ret.x = sinTheta * sinPI;
            ret.y = cosTheta;
            ret.z = sinTheta * cosPI;

            return ret * radius;
        }
    }
}