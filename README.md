# LC ELS

A simple, standalone Emergency Lighting System for FiveM.

LC ELS is designed to provide emergency lights, sirens and horn functionality without requiring a framework or vehicle-specific configuration.

## Documentation

Read it on [lc-development.com/docs](https://lc-development.com/docs/#/lc_els).

## Features

- Standalone
- No framework required
- Works with emergency-class vehicles
- No vehicle-specific configuration
- Emergency lights
- Multiple siren modes
- Network-synchronized sirens
- Network-synchronized horn
- Siren audio comes from the vehicle
- Lights remain on when leaving the vehicle
- Siren and horn stop when leaving the vehicle
- Simple configuration
- Works with custom emergency vehicles

## Controls

| Key | Function |
|-----|----------|
| `Q` | Toggle emergency lights |
| `ALT` | Toggle siren |
| `R` | Change siren / Momentary Wail |
| `E` | Horn |

### Siren controls

When the siren is **OFF**:

- Hold `R` to use the Wail siren.
- Release `R` to stop the siren.

When the siren is **ON**:

- Press `R` to cycle through the available sirens.

Default order:

```text
WAIL
YELP
PRIORITY
