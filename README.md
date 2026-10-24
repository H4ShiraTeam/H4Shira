# H4Shira

Adaptive visual systems for Roblox Studio, distributed as a proprietary commercial SaaS product.

H4Shira provides the H4S Adaptive Rendering Engine: a client-side Roblox system for lighting control, atmosphere, contextual material adjustments, perceptual prioritization, distance budgets, and runtime CPU/GPU-aware quality control.

## Quick start

1. Open the project in Roblox Studio.
2. Copy `Latest/ShadersLocalScript.lua`.
3. Create a `LocalScript` inside `StarterPlayer > StarterPlayerScripts`.
4. Paste the script and run the experience.

Use an earlier version when a smaller implementation is preferred.

## Versions

| Version | Main focus |
| --- | --- |
| `V1` | Future Lighting, atmosphere, water, Bloom and SunRays |
| `V2` | Basic adaptive materials and dynamic lighting updates |
| `V3` | Camera priority, material preservation and adaptive exposure |
| `Latest` | Full H4S Adaptive Rendering Engine with contextual analysis and runtime budgets |

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

## Technical notes

- The scripts are client-side and should be installed as `LocalScript` objects.
- The project uses public Roblox APIs and Future lighting technology.
- Existing materials, colors, and protected objects are preserved as much as possible.
- Custom PBR textures and `SurfaceAppearance` assets are not included.
- Test the selected version on the target PC, mobile, and console devices.
- Roblox and Roblox Studio are trademarks of Roblox Corporation.

## Documentation

- [Installation](docs/installation.md)
- [Architecture](docs/architecture.md)
- [Attributes and tags](examples/attributes.md)
- [Changelog](CHANGELOG.md)
- [Commercial SaaS License](LICENSE)

## License

This is proprietary software. Access, source use, redistribution, resale, and commercial rights are governed by the [H4Shira Proprietary Commercial SaaS License](LICENSE).
