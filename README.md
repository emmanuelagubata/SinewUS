# SinewUS iOS App

A real-time force monitoring app for isometric strength testing. Connects to a custom ESP32 microcontroller with a strain gauge amplifier over Bluetooth Low Energy (BLE) and displays live ADC readings.

## What We're Building

SinewUS is a handheld device that measures how much force a muscle group can produce during an isometric (non-moving) contraction. The hardware is a strain gauge wired through an amplifier into an ESP32 microcontroller. This iOS app connects to the ESP32 over Bluetooth and graphs the readings in real time.

## Problems We Ran Into (April 19-20, 2026)

### 1. ESP32 was sending data before we were ready

When the phone connected to the ESP32, it immediately started blasting ADC readings — even before the user tapped "Start Session." This meant the graph was running, the numbers were jumping, and we had no control over when data collection actually began.

**What we did:** Added a second BLE channel (a "control characteristic"). Now the ESP32 sits quietly after connection and waits. When the user taps Start Session, the app sends a "START" command over this channel, and only then does the ESP32 begin streaming. Tapping Stop Session sends "STOP" and the ESP32 goes silent again.

### 2. The graph looked like it was dipping when we added weight

When applying force to the strain gauge, the graph would briefly dip down before going up — which made no sense physically. Turns out the Y-axis was auto-scaling every time a new data point came in. When a high value arrived, the range expanded and all previous points got visually pushed down, creating a fake dip.

**What we did:** Locked the Y-axis to a fixed range (0–260 for 8-bit ADC). No more jumping around. What you see on the graph is what actually happened.

### 3. ADC values were too sensitive (12-bit was overkill)

With 12-bit resolution (0–4095 steps), the readings were bouncing around from electrical noise. Small fluctuations in the amplifier output caused the number to jump by 20–50 counts even with no load. For our testing phase, we don't need that precision.

**What we did:** Dropped to 8-bit resolution (0–255 steps). Each step now represents a bigger voltage change, so noise doesn't cause visible jumps. We can always go back to 12-bit once we have proper filtering and calibration.

### 4. Graph took forever to show any movement

After starting a session, you had to wait about 10 seconds (200 data points) before the graph visually showed anything. The line just sat flat. This was because the graph was stretching all data points across the full screen width — with only a few points, each one took up a huge chunk of space, and the line looked flat.

**What we did:** Rewrote the graph to work like an oscilloscope. It now has a fixed 20-second time window that scrolls — new data appears on the right edge immediately when force is applied. No more waiting.

### 5. Couldn't tell when things happened on the graph

The graph had no time reference. You couldn't tell if a spike happened at 5 seconds or 15 seconds.

**What we did:** Added a time axis along the bottom with 10-second interval labels (0s, 10s, 20s, 1:00, etc.). Also added drag-to-inspect — slide your finger across the graph to see a crosshair that shows the exact ADC value and timestamp at any point.

### 6. ESP32 didn't always show up when scanning

Sometimes tapping "Scan for Devices" wouldn't find the ESP32 at all, even though it was powered on and right next to the phone. This was an iOS BLE caching issue — once iOS saw the device, it wouldn't report it again on the next scan.

**What we did:** Changed the scan to allow duplicate reports and added a stop/restart cycle to clear iOS's cache. Also bumped the scan timeout from 10 to 15 seconds.

### 7. Graph was too small to analyze

The in-page graph card was useful for a quick glance, but too small to zoom in and check if the signal was linear or where it was saturating.

**What we did:** Added a fullscreen graph popup — tap the expand icon (or tap the graph itself) to get a full-screen view. Pinch to zoom up to 10x, drag to pan when zoomed, double-tap to reset. The live ADC readout stays visible in the header so you always know the current value.

## What's Next

We're currently in the **testing phase** — verifying that the hardware chain works end to end (strain gauge -> amplifier -> ESP32 ADC -> BLE -> app).

1. **Verify signal response** — Apply and remove load, confirm ADC values go up and down as expected (0–255 range)
2. **Calibrate** — Apply known weights (5 lb, 10 lb, 20 lb, etc.) and record the ADC value at each. Build a calibration equation: `Force = m * ADC + b`
3. **Add force units** — Once calibrated, convert raw ADC to real force (Newtons or lbs) in the app
4. **Add deadzone filtering** — After calibration, add a threshold so the app ignores noise at rest and only shows real force
5. **Data export** — Save session data so we can analyze calibration curves outside the app

## Tech Stack

- **iOS App:** Swift / SwiftUI
- **Microcontroller:** ESP32 (Arduino framework)
- **Communication:** Bluetooth Low Energy (BLE)
- **Sensor:** Strain gauge with custom amplifier circuit on GPIO 4

## BLE Protocol

| Characteristic | UUID | Direction | Purpose |
|---|---|---|---|
| Data | `abcdef01-1234-...` | ESP32 -> App (notify) | Streams ADC values as UTF-8 strings |
| Control | `abcdef02-1234-...` | App -> ESP32 (write) | Accepts "START" / "STOP" commands |

Service UUID: `12345678-1234-5678-1234-56789abcdef0`
