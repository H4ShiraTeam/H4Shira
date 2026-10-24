# Configuration

The `Latest` version is configured through `CONFIG` near the top of `ShadersLocalScript.lua`.

## Main options

| Option | Purpose |
| --- | --- |
| `EnableMapScan` | Reads the map and adjusts material work. |
| `EnableMaterialAdaptation` | Applies gradual material and color adjustments. |
| `EnableDynamicExposure` | Adjusts exposure from time of day and view obstruction. |
| `EnableAdaptiveAtmosphere` | Updates haze and atmosphere through the day cycle. |
| `EnableDepthOfField` | Enables depth of field when the view and quality budget allow it. |
| `EnableLightBudget` | Limits distant local lights. |
| `EnableParticleBudget` | Limits distant particle emitters. |
| `LightDistance` | Maximum distance used by the local-light budget. |
| `ParticleDistance` | Maximum distance used by the particle budget. |
| `CPUFrameBudget` | Target time reserved for the script's own work. |

## Object controls

Use attributes or tags when an object must remain unchanged:

- `H4S_KeepMaterial`
- `H4S_Preserve`
- `H4S_KeepLight`
- `H4S_KeepParticles`

Use `H4S_ForceMaterial` only on objects that need stronger correction.
