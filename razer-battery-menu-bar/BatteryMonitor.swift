//
//  BatteryMonitor.swift
//  RazerBatteryMenuBar
//
//  Polls the connected Razer mouse for its battery level and charging state.
//

import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class BatteryMonitor {
    /// Current battery percentage (0–100). Zero when no mouse is connected.
    private(set) var batteryLevel = 0
    /// Whether the mouse is currently charging.
    private(set) var isCharging = false

    private let pollInterval = Duration.seconds(120)
    private let lowBatteryThreshold = 20

    private var pollingTask: Task<Void, Never>?
    private var didNotifyLowBattery = false

    init() {
        Task { await requestNotificationAuthorization() }
        start()
    }

    /// Starts (or restarts) the periodic polling loop.
    func start() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                await self.refresh()
                try? await Task.sleep(for: self.pollInterval)
            }
        }
    }

    /// Reads the battery once, on demand. Backs the menu's Update action.
    func refresh() async {
        // The driver calls below block on USB I/O, so run them off the main actor.
        let (level, charging) = await Task.detached(priority: .utility) {
            (get_battery_level(), is_charging())
        }.value

        if level >= 0 {
            batteryLevel = Int(level)
            if level < lowBatteryThreshold, !didNotifyLowBattery {
                didNotifyLowBattery = true
                await postLowBatteryNotification()
            } else if level >= lowBatteryThreshold {
                didNotifyLowBattery = false
            }
        }

        if charging >= 0 {
            isCharging = charging != 0
            if isCharging { didNotifyLowBattery = false }
        }
    }

    private func requestNotificationAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    private func postLowBatteryNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Battery low"
        content.body = "Your mouse battery is below \(lowBatteryThreshold)%."
        content.sound = .defaultCritical
        content.interruptionLevel = .critical

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
