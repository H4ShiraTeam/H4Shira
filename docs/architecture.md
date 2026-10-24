# Technical Architecture

- **Scene intent:** estimates the map style from palette, saturation, materials, lighting, and context names.
- **Map profile:** builds per-material averages to locate visual outliers without replacing the whole palette.
- **Camera priority:** considers distance, object size, and camera centrality.
- **Contextual correction:** combines material profiles, object names, zones, and preservation attributes.
- **Runtime budgets:** measures frame time and Lua execution time to adjust work batches.
- **Native budgets:** limits distant local lights and particle emitters through public Roblox properties.

The system does not access Roblox's private renderer, GPU buffers, or driver-level upscaling APIs.
