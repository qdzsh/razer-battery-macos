//
//  RazerBatteryMenuBarApp.swift
//  RazerBatteryMenuBar
//
//  Menu bar app entry point.
//

import SwiftUI

@main
struct RazerBatteryMenuBarApp: App {
    @State private var monitor = BatteryMonitor()

    var body: some Scene {
        MenuBarExtra {
            Button("Refresh") {
                Task { await monitor.refresh() }
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            MenuBarLabel(monitor: monitor)
        }
    }
}
