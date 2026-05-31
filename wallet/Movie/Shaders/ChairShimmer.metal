#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Pseudo-random hash for sparkle glints
static float hash(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

// Diagonal shimmer sweep with iridescent color shift and micro-sparkle glints.
// phase: -0.3 → 1.3 sweeps the band fully across the view.
[[stitchable]] half4 chairShimmer(float2 position, half4 color, float2 size, float phase) {
    // Skip fully transparent pixels (outside the chair shape)
    if (color.a < 0.01) return color;

    float2 uv = position / size;

    // Diagonal axis — slightly angled for elegance
    float diagonal = uv.x * 0.62 + uv.y * 0.38;
    float dist = diagonal - phase;

    // --- Main band: soft gaussian falloff ---
    float mainBand = exp(-dist * dist * 18.0);

    // --- Trailing edge glow ---
    float trailDist = dist + 0.06;
    float trail = exp(-trailDist * trailDist * 5.0) * 0.28;

    // --- Micro-sparkle glints at the leading edge ---
    float sparkleNoise = hash(floor(uv * 28.0));          // discrete cells
    float sparkleWindow = exp(-dist * dist * 120.0);      // tight around the band center
    float sparkle = sparkleNoise * sparkleWindow * step(0.72, sparkleNoise) * 0.9;

    // --- Iridescent color: warm gold center → cool ice-blue edges ---
    float t = clamp(dist / 0.14 + 0.5, 0.0, 1.0);
    half3 warmGold = half3(1.0,  0.88, 0.58);
    half3 iceBlue  = half3(0.72, 0.92, 1.0);
    half3 shimmerHue = mix(warmGold, iceBlue, half(t));

    // Screen blend: adds light on top, never darkens
    float total = mainBand * 0.68 + trail + sparkle;
    half3 result = color.rgb + shimmerHue * half(total) * color.a;

    return half4(result, color.a);
}
