# Testing Guide

Test each version in a clean place file before using it in a production experience.

## Visual checks

1. Test a daylight scene.
2. Test the same scene at night or during evening lighting.
3. Check water, glass, metal, wood, terrain and neon materials.
4. Check protected objects with `H4S_Preserve`.
5. Check newly spawned parts and lights.
6. Confirm that the original color palette is still recognizable.

## Device checks

Run the experience on the target PC, mobile device and console profile. Compare:

- Frame pacing.
- Input response.
- Lighting consistency.
- Particle and local-light distance behavior.
- Loading time after joining.

## Before release

Record a short before/after capture from the same camera position. Keep the map, time of day, camera field of view and graphics quality unchanged between captures.
