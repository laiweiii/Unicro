//
//  FKExapndFull_Layout.swift
//  MicroUXLibrary
//
//  Created by Lai Wei on 2025-04-07.
//
import SwiftUI
import Unicro

public struct ExpandLayoutConfiguration {
    // Appearance
    var backgroundColor: Color
    var collapsedWidth: CGFloat
    var collapsedHeight: CGFloat
    var expandedWidth: CGFloat
    var expandedHeight: CGFloat
    var cornerRadiusCollapsed: CGFloat
    var cornerRadiusExpanded: CGFloat
    var needShadow: Bool
    
    // Behavior
    var animation: Animation
    
    // Standard configuration
    public static let standard = ExpandLayoutConfiguration(
        backgroundColor: .blue,
        collapsedWidth: 100,
        collapsedHeight: 100,
        expandedWidth: UIScreen.main.bounds.width - 40,
        expandedHeight: UIScreen.main.bounds.height - 40,
        cornerRadiusCollapsed: 50,
        cornerRadiusExpanded: 20,
        needShadow: true,
        animation: .spring(response: 0.4, dampingFraction: 0.8)
    )
    
    // Partial configuration initializer
    public init(
        backgroundColor: Color? = nil,
        collapsedWidth: CGFloat? = nil,
        collapsedHeight: CGFloat? = nil,
        expandedWidth: CGFloat? = nil,
        expandedHeight: CGFloat? = nil,
        cornerRadiusCollapsed: CGFloat? = nil,
        cornerRadiusExpanded: CGFloat? = nil,
        needShadow: Bool? = nil,
        animation: Animation? = nil
    ) {
        // Start with standard config
        let standard = ExpandLayoutConfiguration.standard
        
        // Only override the specified properties
        self.backgroundColor = backgroundColor ?? standard.backgroundColor
        self.collapsedWidth = collapsedWidth ?? standard.collapsedWidth
        self.collapsedHeight = collapsedHeight ?? standard.collapsedHeight
        self.expandedWidth = expandedWidth ?? standard.expandedWidth
        self.expandedHeight = expandedHeight ?? standard.expandedHeight
        self.cornerRadiusCollapsed = cornerRadiusCollapsed ?? standard.cornerRadiusCollapsed
        self.cornerRadiusExpanded = cornerRadiusExpanded ?? standard.cornerRadiusExpanded
        self.needShadow = needShadow ?? standard.needShadow
        self.animation = animation ?? standard.animation
    }
    
    // Full initializer (used internally and for the standard preset)
    private init(
        backgroundColor: Color,
        collapsedWidth: CGFloat,
        collapsedHeight: CGFloat,
        expandedWidth: CGFloat,
        expandedHeight: CGFloat,
        cornerRadiusCollapsed: CGFloat,
        cornerRadiusExpanded: CGFloat,
        needShadow: Bool,
        animation: Animation
    ) {
        self.backgroundColor = backgroundColor
        self.collapsedWidth = collapsedWidth
        self.collapsedHeight = collapsedHeight
        self.expandedWidth = expandedWidth
        self.expandedHeight = expandedHeight
        self.cornerRadiusCollapsed = cornerRadiusCollapsed
        self.cornerRadiusExpanded = cornerRadiusExpanded
        self.needShadow = needShadow
        self.animation = animation
    }
}

public struct FKExpandLayout<ButtonContent: View, CloseContent: View, ExpandedContent: View>: View {
    @Binding var isExpanded: Bool

    var config: ExpandLayoutConfiguration

    let buttonContent: () -> ButtonContent
    let closeContent: () -> CloseContent
    let expandedContent: () -> ExpandedContent

    public init(
        isExpanded: Binding<Bool>,
        config: ExpandLayoutConfiguration = .standard,
        @ViewBuilder buttonContent: @escaping () -> ButtonContent,
        @ViewBuilder closeContent: @escaping () -> CloseContent,
        @ViewBuilder expandedContent: @escaping () -> ExpandedContent
    ) {
        self._isExpanded = isExpanded
        self.config = config
        self.buttonContent = buttonContent
        self.closeContent = closeContent
        self.expandedContent = expandedContent
    }

    public var body: some View {
        ZStack {
            // Background
            config.backgroundColor

            if isExpanded {
                FKExpandedContent<ExpandedContent, CloseContent>(
                    isExpanded: isExpanded,
                    onClose: toggleExpansion,
                    content: expandedContent,
                    closeContent: closeContent
                )
            } else {
                FKExpandButton {
                    buttonContent()
                }
            }
        }
        .frame(
            width: isExpanded ? config.expandedWidth : config.collapsedWidth,
            height: isExpanded ? config.expandedHeight : config.collapsedHeight
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: isExpanded ? config.cornerRadiusExpanded : config.cornerRadiusCollapsed
            )
        )
        .shadow(
            color: config.needShadow ? .black.opacity(0.3) : .clear,
            radius: 10, x: 0, y: 5
        )
        .onTapGesture {
            if !isExpanded {
                toggleExpansion()
            }
        }
        .animation(config.animation, value: isExpanded)
    }

    private func toggleExpansion() {
        withAnimation(config.animation) {
            isExpanded.toggle()
        }
    }
}

// Example usage
struct FKExpandLayoutExample: View {
    @State private var isExpanded = false

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()

                FKExpandLayout(
                    isExpanded: $isExpanded,
                    config: ExpandLayoutConfiguration(
                        backgroundColor: .blue,
                        collapsedWidth: 60,
                        collapsedHeight: 60,
                        expandedWidth: 350,
                        expandedHeight: geo.size.height - 20,
                        cornerRadiusCollapsed: 50,
                        cornerRadiusExpanded: 20,
                        needShadow: true,
                        animation: .spring(response: 0.4, dampingFraction: 0.8)
                    ),
                    buttonContent: {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundStyle(.white)
                    },
                    closeContent: {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .padding(.trailing)
                            .padding(.top)
                    },
                    expandedContent: {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(0..<10) { i in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 100)
                                }
                            }
                            .padding()
                        }
                    }
                )

            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}



#Preview {
    FKExpandLayoutExample()
}
