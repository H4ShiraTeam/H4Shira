# Troubleshooting

## Nothing changes

Confirm that the file is a `LocalScript` inside `StarterPlayer > StarterPlayerScripts` and that the experience is running in Play mode.

## A part must keep its original look

Set the `H4S_KeepMaterial` or `H4S_Preserve` attribute to `true`, or add the matching tag.

## A light turns off at distance

Set `H4S_KeepLight` to `true` on the light or increase `LightDistance` in `CONFIG`.

## Particles are reduced

Set `H4S_KeepParticles` to `true` on the emitter or increase `ParticleDistance`.

## The map looks too strong

Increase `H4S_PreserveAesthetic` on `Workspace`, use the `balanced` style, or lower the correction values in `CONFIG`.

## Performance is unstable

Use `V3`, lower `MaxTrackedParts`, reduce scan frequency, and test with MicroProfiler before changing multiple settings at once.
