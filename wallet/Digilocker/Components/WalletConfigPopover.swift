//
//  WalletConfigPopover.swift
//  iosconcepts
//
//  Created by Codex on 20/05/26.
//

import SwiftUI
import UIKit

struct WalletConfigPopover: View {
    private typealias Config = WalletConfig

    let onClose: () -> Void

    @State private var values: [String: String] = Config.settingsDefaultValues
    @State private var expandedSections: Set<String> = ["Wallet"]

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                LazyVStack(spacing: Config.settingsSectionSpacing) {
                    ForEach(groupedSections) { section in
                        DisclosureGroup(
                            isExpanded: sectionBinding(section.title)
                        ) {
                            LazyVStack(spacing: Config.settingsRowSpacing) {
                                ForEach(section.items) { item in
                                    WalletConfigRow(
                                        item: item,
                                        value: binding(for: item)
                                    )
                                }
                            }
                            .padding(.top, Config.settingsRowSpacing)
                        } label: {
                            Text(section.title)
                                .font(.system(size: Config.settingsSectionHeaderFontSize, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        .padding(Config.settingsRowPadding)
                        .background(Config.settingsRowBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Config.settingsRowCornerRadius, style: .continuous))
                    }
                }
                .padding(Config.settingsContentPadding)
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Config.settingsCornerRadius, style: .continuous))
        .shadow(
            color: Config.settingsShadowColor,
            radius: Config.settingsShadowRadius,
            x: Config.settingsShadowX,
            y: Config.settingsShadowY
        )
        .padding(Config.settingsOuterPadding)
    }

    private var header: some View {
        HStack(spacing: Config.settingsHeaderSpacing) {
            Text(Config.settingsPanelTitle)
                .font(.system(size: Config.settingsTitleFontSize, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(Config.settingsTitleMinimumScale)

            Spacer()

            Button {
                values = Config.settingsDefaultValues
            } label: {
                Image(systemName: Config.settingsResetAllIconName)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(Config.settingsResetAllAccessibilityLabel)

            Button(action: onClose) {
                Image(systemName: Config.settingsCloseIconName)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(Config.settingsCloseAccessibilityLabel)
        }
        .padding(.horizontal, Config.settingsContentPadding)
        .padding(.vertical, Config.settingsHeaderVerticalPadding)
    }

    private var groupedSections: [WalletConfigSection] {
        let groupedItems = Dictionary(grouping: Config.settingsItems, by: sectionTitle)
        return sectionOrder.compactMap { title in
            guard let items = groupedItems[title], !items.isEmpty else { return nil }
            return WalletConfigSection(title: title, items: items)
        }
    }

    private var sectionOrder: [String] {
        [
            "Wallet",
            "Header",
            "Assets",
            "Pocket",
            "Cards",
            "Stroke",
            "Expanded Glow",
            "Shader",
            "Motion",
            "Timing",
            "Visibility"
        ]
    }

    private func sectionTitle(for item: WalletConfigItem) -> String {
        switch item.name {
        case let name where name.contains("ImageName"):
            return "Assets"
        case let name where name.hasPrefix("header") || name.hasPrefix("title") || name.hasPrefix("subtitle"):
            return "Header"
        case let name where name.hasPrefix("pocket"):
            return "Pocket"
        case let name where name.contains("Stroke"):
            return "Stroke"
        case let name where name.contains("ExpandedBackground"):
            return "Expanded Glow"
        case let name where name.contains("Shader"):
            return "Shader"
        case let name where name.contains("gyro") || name.contains("Gyroscope"):
            return "Motion"
        case let name where name.contains("Duration") || name.contains("Delay") || name.contains("Spring") || name.contains("spring"):
            return "Timing"
        case let name where name.contains("Opacity") || name.contains("Visible") || name.contains("hidden") || name.contains("visible"):
            return "Visibility"
        case let name where name.contains("Card") || name.contains("card") || name.contains("flip") || name.contains("Flip") || name.contains("swipe") || name.contains("selected"):
            return "Cards"
        default:
            return "Wallet"
        }
    }

    private func binding(for item: WalletConfigItem) -> Binding<String> {
        Binding(
            get: { values[item.id, default: item.defaultValue] },
            set: { values[item.id] = $0 }
        )
    }

    private func sectionBinding(_ title: String) -> Binding<Bool> {
        Binding(
            get: { expandedSections.contains(title) },
            set: { isExpanded in
                if isExpanded {
                    expandedSections.insert(title)
                } else {
                    expandedSections.remove(title)
                }
            }
        )
    }
}

private struct WalletConfigSection: Identifiable {
    let title: String
    let items: [WalletConfigItem]

    var id: String { title }
}

private struct WalletConfigRow: View {
    private typealias Config = WalletConfig

    let item: WalletConfigItem
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Config.settingsRowInnerSpacing) {
            Text(item.name)
                .font(.system(size: Config.settingsKeyFontSize, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(Config.settingsKeyMinimumScale)

            HStack(spacing: Config.settingsValueSpacing) {
                TextField(item.defaultValue, text: $value, axis: .vertical)
                    .font(.system(size: Config.settingsValueFontSize, design: .monospaced))
                    .lineLimit(Config.settingsValueLineLimit, reservesSpace: true)
                    .textFieldStyle(.plain)
                    .padding(Config.settingsValuePadding)
                    .background(Config.settingsValueBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Config.settingsValueCornerRadius, style: .continuous))

                Button {
                    UIPasteboard.general.string = value
                } label: {
                    Image(systemName: Config.settingsCopyIconName)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(Config.settingsCopyAccessibilityLabel)

                Button {
                    value = item.defaultValue
                } label: {
                    Image(systemName: Config.settingsResetIconName)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(Config.settingsResetAccessibilityLabel)
            }

            if let sliderRange, let sliderValue {
                Slider(
                    value: Binding(
                        get: { sliderValue },
                        set: { value = formattedValue($0) }
                    ),
                    in: sliderRange
                )
            }
        }
        .padding(Config.settingsRowPadding)
        .background(Config.settingsValueBackground)
        .clipShape(RoundedRectangle(cornerRadius: Config.settingsRowCornerRadius, style: .continuous))
    }

    private var sliderValue: Double? {
        numericValue(from: value)
    }

    private var sliderRange: ClosedRange<Double>? {
        guard let defaultValue = numericValue(from: item.defaultValue), abs(defaultValue) < 10_000 else {
            return nil
        }

        let span = max(abs(defaultValue), 1)
        if defaultValue < 0 {
            return (defaultValue - span)...(defaultValue + span)
        }

        return 0...(defaultValue + span)
    }

    private func numericValue(from text: String) -> Double? {
        Double(text.replacingOccurrences(of: "_", with: ""))
    }

    private func formattedValue(_ newValue: Double) -> String {
        let defaultValue = item.defaultValue

        if defaultValue.contains(".") {
            return String(format: "%.2f", newValue)
        }

        return String(Int(newValue.rounded()))
    }
}

#Preview {
    WalletConfigPopover {}
        .frame(width: 390, height: 420)
}
