//
//  IKGesturePreviewGallery.swift
//  Unicro
//
//  Created by Lai Wei on 2026-02-20.
//

import Foundation
import SwiftUI

#if DEBUG

private enum GestureDemoKind: String, CaseIterable {
    case tap
    case longPress
    case drag
    case pinch
    case rotate
    case combined

    var title: String {
        switch self {
        case .tap: return "Tap"
        case .longPress: return "Long Press"
        case .drag: return "Drag / Pan"
        case .pinch: return "Pinch"
        case .rotate: return "Rotate"
        case .combined: return "Combined"
        }
    }

    var defaultSubtitle: String {
        switch self {
        case .tap: return "Tap card"
        case .longPress: return "Press and hold 0.45s"
        case .drag: return "Drag horizontally"
        case .pinch: return "Pinch to zoom"
        case .rotate: return "Rotate with two fingers"
        case .combined: return "Pinch + rotate on same card"
        }
    }

    var color: Color {
        switch self {
        case .tap: return .blue
        case .longPress: return .mint
        case .drag: return .orange
        case .pinch: return .purple
        case .rotate: return .pink
        case .combined: return .teal
        }
    }
}

private struct GestureDemoRow: Identifiable, Equatable {
    let id: UUID
    let kind: GestureDemoKind
    var subtitle: String

    init(kind: GestureDemoKind) {
        self.id = UUID()
        self.kind = kind
        self.subtitle = kind.defaultSubtitle
    }
}

private struct GestureDemoCard: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}

struct IKGesturePreviewGallery: View {
    @State private var rows: [GestureDemoRow] = GestureDemoKind.allCases.map(GestureDemoRow.init)
    @State private var tapCounts: [UUID: Int] = [:]
    @State private var activeReorderID: UUID?
    @State private var activeReorderOffset: CGFloat = 0
    @State private var reorderAccumulatedShift: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("IK Gesture Gallery")
                    .font(.title2.bold())
                Text("Drag vertically to reorder rows")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(rows) { row in
                    configuredRow(for: row)
                        .opacity(activeReorderID == row.id ? 0.7 : 1)
                        .offset(y: activeReorderID == row.id ? activeReorderOffset : 0)
                        .zIndex(activeReorderID == row.id ? 1 : 0)
                        .simultaneousGesture(reorderGesture(for: row))
                }
            }
            .padding()
        }
        .animation(.snappy(duration: 0.2), value: rows)
    }

    private func configuredRow(for row: GestureDemoRow) -> some View {
        let card = GestureDemoCard(
            title: row.kind.title,
            subtitle: row.subtitle,
            color: row.kind.color
        )

        switch row.kind {
        case .tap:
            return AnyView(
                card
                    .intent(.browse(.read)) { i in
                        i.tap { s in
                            s.behaviour(.single, haptics: true)
                            s.onTrigger {
                                let next = (tapCounts[row.id] ?? 0) + 1
                                tapCounts[row.id] = next
                                updateSubtitle(row.id, "Single tap count: \(next)")
                            }
                        }
                    }
                    .intent(.selection(.reorder)) { i in
                        i.drag { s in
                            s.behaviour(.horizontal, minimumDistance: 6, rubberBand: 0.2, endState: .reset)
                        }
                    }
            )

        case .longPress:
            return AnyView(
                card
                    .intent(.task(.manage)) { i in
                        i.longPress { s in
                            s.behaviour(minimumDuration: 0.45, maximumDistance: 18, haptics: true)
                            s.onTrigger {
                                let isTriggered = rows.first(where: { $0.id == row.id })?.subtitle == "Triggered"
                                updateSubtitle(row.id, isTriggered ? row.kind.defaultSubtitle : "Triggered")
                            }
                        }
                    }
                    .intent(.selection(.reorder)) { i in
                        i.drag { s in
                            s.behaviour(.horizontal, minimumDistance: 6, rubberBand: 0.2, endState: .reset)
                        }
                    }
            )

        case .drag:
            return AnyView(
                card
                    .intent(.selection(.reorder)) { i in
                        i.drag { s in
                            s.behaviour(.horizontal, minimumDistance: 8, rubberBand: 0.22, endState: .reset)
                            s.onChange { point in
                                updateSubtitle(row.id, String(format: "x: %.0f", point.width))
                            }
                            s.onEnd { _ in
                                updateSubtitle(row.id, row.kind.defaultSubtitle)
                            }
                        }
                    }
            )

        case .pinch:
            return AnyView(
                card
                    .intent(.browse(.discover)) { i in
                        i.pinch { s in
                            s.behaviour(minScale: 0.8, maxScale: 2.2, endState: .keep)
                            s.onChange { scale in
                                updateSubtitle(row.id, String(format: "scale: %.2fx", scale))
                            }
                        }
                    }
                    .intent(.selection(.reorder)) { i in
                        i.drag { s in
                            s.behaviour(.horizontal, minimumDistance: 6, rubberBand: 0.2, endState: .reset)
                        }
                    }
            )

        case .rotate:
            return AnyView(
                card
                    .intent(.browse(.inspect)) { i in
                        i.rotate { s in
                            s.behaviour(endState: .keep)
                            s.onChange { angle in
                                updateSubtitle(row.id, String(format: "angle: %.0f°", angle.degrees))
                            }
                        }
                    }
                    .intent(.selection(.reorder)) { i in
                        i.drag { s in
                            s.behaviour(.horizontal, minimumDistance: 6, rubberBand: 0.2, endState: .reset)
                        }
                    }
            )

        case .combined:
            return AnyView(
                card
                    .intent(.browse(.inspect)) { i in
                        i.rotate { rotate in
                            rotate.behaviour(endState: .keep)
                            rotate.onChange { angle in
                                updateSubtitle(row.id, String(format: "angle: %.0f°", angle.degrees))
                            }
                        }
                    }
                    .intent(.browse(.inspect)) { i in
                        i.pinch { pinch in
                            pinch.behaviour(minScale: 0.8, maxScale: 2.3, endState: .keep)
                            pinch.onChange { scale in
                                updateSubtitle(row.id, String(format: "scale: %.2fx", scale))
                            }
                        }
                    }
                    .intent(.selection(.reorder)) { i in
                        i.drag { s in
                            s.behaviour(.horizontal, minimumDistance: 6, rubberBand: 0.2, endState: .reset)
                        }
                    }
            )
        }
    }

    private func updateSubtitle(_ id: UUID, _ text: String) {
        guard let index = rows.firstIndex(where: { $0.id == id }) else { return }
        rows[index].subtitle = text
    }

    private func reorderGesture(for row: GestureDemoRow) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                let vertical = value.translation.height
                let horizontal = value.translation.width
                guard abs(vertical) > abs(horizontal) else { return }

                if activeReorderID == nil {
                    activeReorderID = row.id
                    reorderAccumulatedShift = 0
                }

                guard activeReorderID == row.id else { return }

                activeReorderOffset = vertical - reorderAccumulatedShift
                moveIfNeeded(for: row.id, effectiveVerticalOffset: activeReorderOffset)
            }
            .onEnded { _ in
                if activeReorderID == row.id {
                    withAnimation(.snappy(duration: 0.18)) {
                        activeReorderOffset = 0
                    }
                    activeReorderID = nil
                    reorderAccumulatedShift = 0
                }
            }
    }

    private func moveIfNeeded(for id: UUID, effectiveVerticalOffset: CGFloat) {
        let step: CGFloat = 72
        guard abs(effectiveVerticalOffset) > step,
              let from = rows.firstIndex(where: { $0.id == id })
        else { return }

        if effectiveVerticalOffset > 0, from < rows.count - 1 {
            withAnimation(.snappy(duration: 0.2)) {
                rows.move(fromOffsets: IndexSet(integer: from), toOffset: from + 2)
            }
            reorderAccumulatedShift += step
        } else if effectiveVerticalOffset < 0, from > 0 {
            withAnimation(.snappy(duration: 0.2)) {
                rows.move(fromOffsets: IndexSet(integer: from), toOffset: from - 1)
            }
            reorderAccumulatedShift -= step
        }
    }
}

#Preview("IK Gestures") {
    IKGesturePreviewGallery()
}

#endif
