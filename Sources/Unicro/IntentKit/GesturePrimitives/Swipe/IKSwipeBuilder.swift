//
//  IKSwipeContainer.swift
//  Unicro
//
//  Created by Lai Wei on 2026-01-23.
//

import SwiftUI

// MARK: - IKSwipeBuilder

public enum SwipeEdge { case leading, trailing }

public struct SwipeSpec {
    var behavior: SwipeBehavior = .init()
    var leftWidth: CGFloat = 0
    var rightWidth: CGFloat = 0
    var leftView: AnyView = AnyView(EmptyView())
    var rightView: AnyView = AnyView(EmptyView())
    var onReveal: (() -> Void)?
    var onCommit: (() -> Void)?

    public mutating func behaviour(_ level: SwipeBehavior.CommitLevel,
                                   threshold: CGFloat = 90,
                                   rubberBand: CGFloat = 0.25,
                                   haptics: Bool = true) {
        behavior = .init(commitLevel: level,
                         triggerThreshold: threshold,
                         rubberBand: rubberBand,
                         hapticsOnTrigger: haptics)
    }

    public mutating func reveal(edge: SwipeEdge, width: CGFloat, @ViewBuilder _ view: () -> some View) {
        switch edge {
        case .leading:
            leftWidth = width
            leftView = AnyView(view())
        case .trailing:
            rightWidth = width
            rightView = AnyView(view())
        }
    }

    public mutating func onReveal(_ f: @escaping () -> Void) { onReveal = f }
    public mutating func onCommit(_ f: @escaping () -> Void) { onCommit = f }
}

public extension InteractionBinder {
    public func swipe(build: (inout SwipeSpec) -> Void) -> some View {
        var spec = SwipeSpec()
        build(&spec)

        let config = TaskSwipeConfig(
            behavior: spec.behavior,
            callbacks: SwipeCallbacks(onReveal: spec.onReveal, onCommit: spec.onCommit)
        )

        // ✅ 用 intent gate capability：只有 task 才启用 task swipe
        let enabled = intent.allowsTaskSwipe

        return base.modifier(
            TaskSwipeModifier(
                enabled: enabled,
                config: config,
                leftRevealWidth: spec.leftWidth,
                rightRevealWidth: spec.rightWidth,
                leftView: spec.leftView,
                rightView: spec.rightView
            )
        )
    }
}

#if DEBUG

// MARK: - Gmail-like Row (UI only)
struct GmailRow: View {
    let sender: String
    let subject: String
    let preview: String
    let time: String
    var isUnread: Bool = true
    var isStarred: Bool = false
    var avatarColor: Color = .blue

    private var initial: String {
        sender.trimmingCharacters(in: .whitespacesAndNewlines).first.map { String($0).uppercased() } ?? "?"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Avatar
            ZStack {
                Circle().fill(avatarColor.opacity(0.9))
                Text(initial)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 40, height: 40)
            .padding(.top, 2)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(sender)
                        .font(.system(size: 16, weight: isUnread ? .semibold : .regular))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(time)
                        .font(.system(size: 12, weight: isUnread ? .semibold : .regular))
                        .foregroundStyle(.secondary)
                }

                Text(subject)
                    .font(.system(size: 14, weight: isUnread ? .semibold : .regular))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(preview)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Star
            Button(action: {}) {
                Image(systemName: isStarred ? "star.fill" : "star")
                    .font(.system(size: 16))
                    .foregroundStyle(isStarred ? Color.yellow : Color.secondary)
                    .padding(.top, 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.background)
        .overlay(alignment: .bottom) {
            Divider()
                .padding(.leading, 16 + 40 + 12) // align with text block (skip avatar)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Demo Screen
struct DemoScreen: View {
    var body: some View {
        VStack(spacing: 0) {

            // Optional: simple "search" bar look (UI only)
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                Text("Search in mail")
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            ScrollView {
                LazyVStack(spacing: 0) {
                    GmailRow(
                        sender: "Air Canada",
                        subject: "Your itinerary is ready",
                        preview: "Thanks for booking. Your flight details are attached…",
                        time: "7:48 PM",
                        isUnread: true,
                        isStarred: false,
                        avatarColor: .blue
                    )
                    .intent(.rerouteTrip()) { i in
                        i.swipe{ s in
                            s.behaviour(.commitOnFull, threshold: 100, rubberBand: 0.2)
                            s.reveal(edge: .trailing, width: 160) {
                                HStack(spacing: 12) {
                                    CircleIconButton(system: "archivebox.fill", bg: .green) {}
                                    CircleIconButton(system: "trash.fill", bg: .red) {}
                                }
                                .padding(.trailing, 16)
                            }
                            s.onCommit { print("Full swipe commit") }
                        }
                    }

                    GmailRow(
                        sender: "Notion",
                        subject: "Weekly digest",
                        preview: "You have 3 updates in your workspace…",
                        time: "6:12 PM",
                        isUnread: false,
                        isStarred: true,
                        avatarColor: .purple
                    )
                    .intent(.rerouteTrip()) { i in
                        i.swipe{ s in
                            s.behaviour(.commitOnFull, threshold: 100, rubberBand: 0.2)
                            s.reveal(edge: .trailing, width: 160) {
                                HStack(spacing: 12) {
                                    CircleIconButton(system: "archivebox.fill", bg: .green) {}
                                    CircleIconButton(system: "trash.fill", bg: .red) {}
                                }
                                .padding(.trailing, 16)
                            }
                            s.onCommit { print("Full swipe commit") }
                        }
                    }
                }
            }
        }
        .background(.background)
    }
}

// MARK: - Small UI helper (Gmail-like swipe buttons)
private struct CircleIconButton: View {
    let system: String
    let bg: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(bg)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 2)
    }
}



#Preview {
    DemoScreen()
}

#endif
