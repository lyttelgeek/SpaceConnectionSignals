# Changelog


## 1.0.2 - Factorio 2.1 Compatibility

### Changes
- Updated for Factorio 2.1 (`info.json` `factorio_version` set to `2.1`)
- No prototype or logic changes; the data-stage API used by this mod was verified unchanged against the official 2.1 changelog

---

## 1.0.1 - Icon Tweaks

### Changes
- Removed vanilla arrow layer "planet-route.png" from icons
- Properly implemented full modded planet icon support
- Slightly reduced icon scaling to fit display panels better

---

## 1.0.0 - Initial Stable Release

### Added
- Initial stable release
- Generates virtual signals for all space routes between planets and space locations
- Composite layered route icons using Space Age visuals
- Galaxy-order sorting of signals
- Startup setting: generate only direct starmap connections
- Startup setting: generate one signal per pair (galaxy order priority)
- Compatibility with modded planets and space-locations

### Technical
-   Bulk `data:extend()` implementation for efficient prototype
    registration
-   Direct `space-connection` adjacency detection
-   Proper `LocalisedString` usage for signal names
