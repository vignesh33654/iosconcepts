#include <metal_stdlib>
using namespace metal;

// ---------------------------------------------------------------------------
// holographicShade — colorEffect shader
//
// Parameters
//   time        elapsed seconds (drives animation)
//   angle       gradient flow direction in radians (0 = horizontal →,
//               π/2 = vertical ↓, π*0.6 = diagonal matching the screenshot)
//   speed       animation velocity (0 = frozen, 0.2 = slow drift, 1 = fast)
//   wavelength  pixels per full colour cycle (400 = tight, 900 = wide sweep)
//   layerCount  1 / 2 / 3  — more layers add shimmer depth
//   colorA      darkest / base colour
//   colorB      mid colour
//   colorC      brightest / highlight colour
// ---------------------------------------------------------------------------

[[ stitchable ]] half4 holographicShade(
    float2 position,
    half4  color,           // original pixel colour (ignored; we replace it)
    float  time,
    float  angle,
    float  speed,
    float  wavelength,
    float  layerCount,
    half4  colorA,
    half4  colorB,
    half4  colorC
) {
    // Project the pixel onto the gradient axis.
    float2 dir = float2(cos(angle), sin(angle));
    float  t   = dot(position, dir) / wavelength + time * speed;

    // Layer 1 — dominant gradient wave.
    float f1 = sin(t * M_PI_F) * 0.5 + 0.5;

    // Layer 2 — shimmer at 1.5× frequency (active when layerCount ≥ 2).
    float f2 = layerCount > 1.5
        ? sin(t * M_PI_F * 1.5 - 0.9) * 0.5 + 0.5
        : f1;

    // Layer 3 — slow undulation at 0.5× frequency (active when layerCount ≥ 3).
    float f3 = layerCount > 2.5
        ? sin(t * M_PI_F * 0.5 + 0.3) * 0.5 + 0.5
        : f1;

    // Weighted sum of layers.
    float blend = f1 * 0.60 + f2 * 0.28 + f3 * 0.12;

    // Smooth S-curve so transitions feel analogue rather than sinusoidal.
    blend = blend * blend * (3.0 - 2.0 * blend);

    // Blend A → B linearly, then push towards C on the bright end.
    half4 result = mix(colorA, colorB, half(blend));
    result       = mix(result, colorC, half(pow(blend, 2.0) * 0.70));

    return saturate(result);
}
