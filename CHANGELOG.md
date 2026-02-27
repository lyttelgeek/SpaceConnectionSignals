# Changelog

All notable changes to this project will be documented in this file.

This project follows semantic versioning (MAJOR.MINOR.PATCH).

------------------------------------------------------------------------

## [1.0.0] - Initial Stable Release

### Added

-   Initial stable release
-   Generates virtual signals for all space routes between planets and
    space locations
-   Composite layered route icons using Space Age visuals
-   Galaxy-order sorting of signals
-   Startup setting: generate only direct starmap connections
-   Startup setting: generate one signal per pair (galaxy order
    priority)
-   Compatibility with modded planets and space-locations

### Technical

-   Bulk `data:extend()` implementation for efficient prototype
    registration
-   Direct `space-connection` adjacency detection
-   Proper `LocalisedString` usage for signal names
