/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Atmospheric Scattering Methods and Constants.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE File.
========================================================*/
using Godot;
using System;

namespace JC.TimeOfDay
{
    public struct ScatterLib 
    {
        /*===============================================
        ° References:
        ° - Preetham and Hoffman Paper:
        ° See: https://developer.amd.com/wordpress/media/2012/10/ATI-LightScattering.pdf
        ===============================================*/

        /// <summary> 
        /// Index of the air refraction </summary>
        public const float n = 1.0003f;

        /// <summary> 
        /// Index of the air refraction ˆ 2 </summary>
        public const float n2 = 1.00060009f;

        /// <summary> 
        /// Molecular Density </summary>
        public const float N = 2.545e25f;

        /// <summary>
        /// Depolatization factor for standard air </summary>
        public const float pn = 0.035f;

        public static Vector3 ComputeWavelenghtsLambda(Vector3 value) => value * 1e-9f;

        public static Vector3 ComputeWavelenghts(Vector3 lambda)
        {
            const float k = 4.0f;
            Vector3 ret = lambda;
            ret.x = Mathf.Pow(lambda.x, k);
            ret.y = Mathf.Pow(lambda.y, k);
            ret.z = Mathf.Pow(lambda.z, k);

            return ret;
        }

        public static Vector3 ComputeBetaRay(Vector3 wavelenghts)
        {
            float kr = (8.0f * Mathf.Pow(Mathf.Pi, 3.0f) * Mathf.Pow(n2 - 1.0f, 2.0f) * (6.0f + 3.0f * pn));
            Vector3 ret = 3.0f * N * wavelenghts * (6.0f - 7.0f * pn);
            ret.x = kr / ret.x;
            ret.y = kr / ret.y;
            ret.z = kr / ret.z;

            return ret;
        }

        public static Vector3 ComputeBetaMie(float mie, float turbidity)
        {
            const float k = 434e-6f; 
            return Vector3.One * mie * turbidity * k;
        }

        public static Vector3 GetPartialMiePhase(float g)
        {
            float g2 = g * g;
            Vector3 ret;
            //ret.x = ((1.0f - g2) / (2.0f + g2));
            ret.x = 1.0f - g2; // Simplified
            ret.y = 1.0f + g2;
            ret.z = 2.0f * g;
            return ret;
        }
    }
}
