# CaelestiaPlugin-AudioBoost

A small Caelestia Shell plugin that turns the existing audio UI into a real
booster instead of adding a second, disconnected mixer.

## Behaviour

- Configurable native volume ceiling from 100% to 200%.
- Caelestia output sliders and per-app sliders can use the full ceiling.
- Per-app boost presets are remembered by PipeWire application name.
- A new stream gets its remembered boost automatically when it appears.
- 100% remains normal gain; values above 100% are amplification and can clip.

The tiny core-shell patch only makes the existing sliders respect
GlobalConfig.services.maxVolume. The actual policy and persistence live in this
plugin.
