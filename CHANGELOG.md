# Changelog


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
