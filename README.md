# H4Shira

Adaptive visual systems for Roblox Studio.

H4Shira provides a single LocalScript with lighting controls, atmosphere, material adjustments, perceptual prioritization, distance budgets for lights and particles, and runtime CPU/GPU-aware quality control.

## Quick start

1. Open the project in Roblox Studio.
2. Copy `Latest/ShadersLocalScript.lua`.
3. Create a `LocalScript` inside `StarterPlayer > StarterPlayerScripts`.
4. Paste the script and run the experience.

Use an earlier version if you need a smaller or simpler implementation.

## Versions

| Version | Main focus |
| --- | --- |
| `V1` | Future Lighting, atmosphere, water, Bloom and SunRays |
| `V2` | Basic adaptive materials and dynamic lighting updates |
| `V3` | Camera priority, material preservation and adaptive exposure |
| `Latest` | Full H4S Visual Intelligence Engine with contextual analysis and runtime budgets |

## Optional attributes

Set these attributes on `Workspace` or on individual objects when needed:

```text
H4S_ArtStyle = "realistic"
H4S_PreserveAesthetic = 0.85
H4S_KeepMaterial = true
H4S_Preserve = true
H4S_ForceRealism = true
H4S_KeepLight = true
H4S_KeepParticles = true
```

Valid `H4S_ArtStyle` values are `realistic`, `cinematic`, `stylized`, and `balanced`.

## Notes

- The scripts are client-side and should be installed as `LocalScript` objects.
- The project uses public Roblox APIs and the Future lighting technology.
- Existing materials, colors and protected objects are preserved as much as possible.
- Custom PBR textures and `SurfaceAppearance` assets are not included and must be provided by the map creator.
- Test the selected version on the target PC, mobile and console devices.

## Documentation

- [Installation](docs/installation.md)
- [Architecture](docs/architecture.md)
- [Attributes and tags](examples/attributes.md)
- [Changelog](CHANGELOG.md)
