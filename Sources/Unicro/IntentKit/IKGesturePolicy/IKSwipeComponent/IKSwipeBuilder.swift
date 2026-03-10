//
//  IKSwipeContainer.swift
//  Unicro
//
//  Created by Lai Wei on 2026-01-23.
//

import SwiftUI

// MARK: - TaskSwipeModifier







struct DemoRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .opacity(0.6)
        }
        .padding()
        .background(.background)
        .cornerRadius(12)
    }
}



struct DemoScreen: View {
    var body: some View {
        VStack(spacing: 16) {

            // 行1，右滑按钮 80pt
            DemoRow(title: "Inbox Item 1")
                .modifier(
                    TaskSwipeModifier(
                        config: TaskSwipeConfig(
                            behavior: SwipeBehavior(commitLevel: .commitOnFull, triggerThreshold: 40),
                            callbacks: SwipeCallbacks(
                                onReveal: { print("Button revealed") },
                                onCommit: { print("Full swipe commit") }
                            )
                        ),
                        rightRevealWidth: 80,
                        leftView: { EmptyView() },
                        rightView: {
                            Button("Delete") { print("Delete tapped") }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    )
                )

            // 行2，右滑按钮更宽 120pt
            DemoRow(title: "Inbox Item 2")
                .modifier(
                    TaskSwipeModifier(
                        config: TaskSwipeConfig(
                            behavior: SwipeBehavior(commitLevel: .commitOnFull, triggerThreshold: 40),
                            callbacks: SwipeCallbacks(
                                onReveal: { print("Button revealed") },
                                onCommit: { print("Full swipe commit") }
                            )
                        ),
                        rightRevealWidth: 120,
                        leftView: { EmptyView() },
                        rightView: {
                            Button("Archive") { print("Archive tapped") }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    )
                )
        }
        .padding()

        .padding()
    }
}


#Preview {
    DemoScreen()
}



