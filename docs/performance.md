# Performance

The system runs client-side. Roblox still decides how rendering work is divided internally between the CPU and GPU. The script controls its own workload and the public effect properties available to it.

## Recommended starting points

- Start with `Latest` on desktop.
- Use `V3` when the map is large or heavily scripted.
- Reduce `MaxTrackedParts` for very large places.
- Reduce `LightDistance` and `ParticleDistance` on mobile.
- Keep high-rate emitters protected only when they are important to the scene.
- Avoid scanning the same decorative folder from multiple local systems.

## Profiling

Use Roblox Studio's MicroProfiler and Performance Stats while testing. Compare the place with the system disabled and enabled. Look for frame-time spikes after joining, during camera movement and when many lights or particle emitters enter view.
