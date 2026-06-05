//
//  MenuBarLabel.swift
//  RazerBatteryMenuBar
//
//  Status bar label: mouse glyph, vertical battery gauge and charge percentage.
//

import SwiftUI

/// Flattens the mouse glyph, battery gauge and percentage into a single
/// template image so it renders correctly inside `MenuBarExtra`.
struct MenuBarLabel: View {
    let monitor: BatteryMonitor

    var body: some View {
        // Reading the observable property here (inside a View body) ensures the
        // status item re-renders whenever the battery level changes.
        Image(nsImage: Self.rendered(level: monitor.batteryLevel))
    }

    @MainActor
    private static func rendered(level: Int) -> NSImage {
        let tint = Color.white
        let renderer = ImageRenderer(content:
            HStack(spacing: 3) {
                MouseGlyph(tint: tint)
                BatteryGauge(level: level, outline: tint.opacity(0.5))
                Text("\(level)%")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(tint)
            }
        )
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
        return renderer.nsImage ?? NSImage(size: NSSize(width: 1, height: 1))
    }
}

/// Mouse outline icon, tinted to match the rest of the label.
private struct MouseGlyph: View {
    let tint: Color

    var body: some View {
        Group {
            if let icon = NSImage(named: "MouseIcon") {
                Image(nsImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(height: 17)
        .foregroundStyle(tint)
    }
}

/// Vertical battery gauge whose fill height and colour track the charge level.
struct BatteryGauge: View {
    let level: Int
    var outline: Color

    private var fillColor: Color {
        switch level {
        case ..<20: return .red
        case ..<50: return .yellow
        default:    return .green
        }
    }

    var body: some View {
        let size = CGSize(width: 9, height: 16)
        let lineWidth: CGFloat = 0.8
        let inset: CGFloat = 2
        let innerWidth = size.width - inset * 2
        let trackHeight = size.height - inset * 2
        let clamped = CGFloat(min(max(level, 0), 100))
        let fillHeight = max(innerWidth, trackHeight * clamped / 100)

        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                .strokeBorder(outline, lineWidth: lineWidth)
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(fillColor)
                .frame(width: innerWidth, height: fillHeight)
                .padding(.bottom, inset)
        }
        .frame(width: size.width, height: size.height)
    }
}
