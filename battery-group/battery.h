//
//  battery.h
//  RazerBatteryMenuBar
//
//  C bridge exposing Razer mouse battery readings to Swift.
//

#ifndef BATTERY_H
#define BATTERY_H

/// Battery level (0-100) of the first connected wireless Razer mouse,
/// or -1 if none is available.
int get_battery_level(void);

/// 1 if the mouse is charging, 0 if not, or -1 if unavailable.
int is_charging(void);

#endif /* BATTERY_H */
