//
//  battery.c
//  RazerBatteryMenuBar
//
//  Reads battery level and charging state from a connected Razer mouse
//  via librazermacos.
//

#include <stdlib.h>
#include "battery.h"
#include "razerdevice.h"
#include "razermouse_driver.h"

/// Whether the product id is a Razer mouse that reports a battery level — a
/// wireless mouse, its charging dock, or its USB receiver. Only devices that
/// the bundled librazermacos has a working battery read path for are listed;
/// wired-only mice (e.g. Naga Trinity, Basilisk V3) are intentionally omitted.
static int has_battery(UInt16 productId) {
    switch (productId) {
        // Lancehead Wireless
        case USB_DEVICE_ID_RAZER_LANCEHEAD_WIRELESS:
        case USB_DEVICE_ID_RAZER_LANCEHEAD_WIRELESS_RECEIVER:
        case USB_DEVICE_ID_RAZER_LANCEHEAD_WIRELESS_WIRED:
        // Mamba Wireless
        case USB_DEVICE_ID_RAZER_MAMBA_WIRELESS_RECEIVER:
        case USB_DEVICE_ID_RAZER_MAMBA_WIRELESS_WIRED:
        // Naga Pro
        case USB_DEVICE_ID_RAZER_NAGA_PRO_WIRELESS:
        case USB_DEVICE_ID_RAZER_NAGA_PRO_WIRED:
        // Viper Ultimate
        case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRELESS:
        case USB_DEVICE_ID_RAZER_VIPER_ULTIMATE_WIRED:
        // Viper V3 Pro
        case USB_DEVICE_ID_RAZER_VIPER_V3_PRO_WIRELESS:
        case USB_DEVICE_ID_RAZER_VIPER_V3_PRO_WIRED:
        // DeathAdder V2 Pro
        case USB_DEVICE_ID_RAZER_DEATHADDER_V2_PRO_WIRELESS:
        case USB_DEVICE_ID_RAZER_DEATHADDER_V2_PRO_WIRED:
        // Basilisk Ultimate
        case USB_DEVICE_ID_RAZER_BASILISK_ULTIMATE_RECEIVER:
        // Orochi V2
        case USB_DEVICE_ID_RAZER_OROCHI_V2_RECEIVER:
        case USB_DEVICE_ID_RAZER_OROCHI_V2_BLUETOOTH:
        // Atheris
        case USB_DEVICE_ID_RAZER_ATHERIS_RECEIVER:
            return 1;
        default:
            return 0;
    }
}

int get_battery_level(void) {
    RazerDevices devices = getAllRazerDevices();
    int level = -1;

    for (int i = 0; i < devices.size; i++) {
        RazerDevice device = devices.devices[i];
        if (!has_battery(device.productId)) {
            continue;
        }

        // The driver writes the raw battery level (0-255) as a decimal string.
        char buffer[16] = {0};
        if (razer_attr_read_get_battery(device.usbDevice, buffer) > 0) {
            level = (atoi(buffer) * 100) / 255;
            break;
        }
    }

    closeAllRazerDevices(devices);
    return level;
}

int is_charging(void) {
    RazerDevices devices = getAllRazerDevices();
    int charging = -1;

    for (int i = 0; i < devices.size; i++) {
        RazerDevice device = devices.devices[i];
        if (!has_battery(device.productId)) {
            continue;
        }

        char buffer[16] = {0};
        if (razer_attr_read_is_charging(device.usbDevice, buffer) > 0) {
            charging = atoi(buffer);
            break;
        }
    }

    closeAllRazerDevices(devices);
    return charging;
}
