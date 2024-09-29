# Digital clock

We needed a new clock. I happen to have made some digital clocks in the past, so it's time for a new version.
For old time sake, I will re-implement an old design I made as a teenager, and a new design I would make now.

## Requirements

Time
* The clock shall display the current time (hours and minutes), at all times.
* The clock shall apply day light saving (de-)activation/ automatically. 

Apperance
* The clock shall be powered internally, hence without the need for a permanent cable.
* The clock shall have a wooden houding with an industrial look.
* To match the industrial look, the digits will amber coloured.

## Specification

Time
* MCU with internal RTC
* Synchronise periodically with DCF77

Display
* 7 segment display
  * E-ink would be nice but not in the desired apperence
  * Nixie tubes would be great, but battery time will become an issue.

Power management
* Low-power
* Battery or battery-pack (integrated charger?)

Personal
* Firmware written in C++

## Design



# Build

```bash
cmake -B build -S .
cmake --build build/    
```