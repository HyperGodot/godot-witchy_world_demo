/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: DateTime.
°   -----------------------------------------------------
°   Description:
°       DateTime Utility.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
using Godot;
using System;

namespace JC.TimeOfDay
{
    public struct DateTimeUtil 
    {

        public const uint kTotalHours = 24;

        public static bool ComputeLeapYear(int year)
        {
            return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
        }

        public static float ToTotalHours(int hours)
        {
            return (float)hours;
        }

        public static float ToTotalHours(int hours, int minutes) 
        {
            return (float)hours + (float)minutes / 60.0f;
        }

        public static float ToTotalHours(int hours, int minutes, int seconds)
        {
            return (float)hours + (float)minutes / 60.0f + (float)seconds / 3600.0f;
        }

        public static float ToTotalHours(int hours, int minutes, int seconds, int milliseconds)
        {
            return (float)hours + (float)minutes / 60.0f + (float)seconds / 3600.0f + 
                (float)milliseconds / 3600000.0f;
        }
    }
}