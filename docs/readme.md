# H4S Documentation

## Overview

H4S is a client-side visual system for Roblox Studio. It controls public Roblox lighting and post-processing APIs while applying contextual material and performance rules.

## Architecture

The engine builds an artistic signature from the map, measures material deviations, calculates perceptual priority from camera context, and applies gradual corrections. Runtime budgets reduce analysis, light, and particle work when the client is under load.

## Compatibility

The system is intended for Roblox Studio projects that support the public APIs used by the selected version. Install it as a `LocalScript`.

## Commercial model

H4S is distributed under the proprietary commercial SaaS license in the repository root. Usage rights, support, updates, and redistribution permissions depend on the customer's commercial agreement.
