//
//  SKLoadShimmer_Components.swift
//  MicroUXLibrary
//
//  Created by Lai Wei on 2025-04-30.
//

import SwiftUI
import Unicro

public struct SKDragLoadConfiguration {
    public var threshold: CGFloat
    public var indicator: AnyView

    public init(
        threshold: CGFloat = 40,
        indicator: AnyView = AnyView(ProgressView())
    ) {
        self.threshold = threshold
        self.indicator = indicator
    }

    public static let standard = SKDragLoadConfiguration()

}

public struct SKDragLoadIndicator: View {
    @Binding var isLoading: Bool
    var loadingView: AnyView

    public var body: some View {
        VStack {
            if isLoading {
                loadingView
            }
        }
      
    }
}

public struct SKDragLoadContainer<Content: View>: View {
    @State private var dragOffset: CGFloat = 0
    @Binding var isLoading: Bool
    
    private let config: SKDragLoadConfiguration
    private let content: Content
    private let onRefresh: () -> Void
    
    var loadingView: AnyView = SKDragLoadConfiguration.standard.indicator
    
  
    public init(
        config: SKDragLoadConfiguration = .standard,
        isLoading: Binding<Bool>,
        onRefresh: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.config = config
        self._isLoading = isLoading
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SKDragLoadIndicator(isLoading: $isLoading, loadingView: loadingView)
                content
                    .padding(.top, 8)
            }
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 && !isLoading {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > config.threshold {
                            isLoading = true
                            dragOffset = config.threshold
                           
                            onRefresh()
                            
                          
                            if !isLoading {
                                withAnimation {
                                    dragOffset = 0
                                }
                            }
                        } else {
                            withAnimation {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .animation(.easeOut, value: dragOffset)
            .onChange(of: isLoading) { newValue in
                if !newValue {
                    withAnimation {
                        dragOffset = 0
                    }
                }
            }
        }
    }
}

struct DragLoadingExample: View {
    @State private var isLoading: Bool = false // State managed by parent
    
    var body: some View {
        SKDragLoadContainer(
            config: SKDragLoadConfiguration(threshold: 20),
            isLoading: $isLoading,
            onRefresh: {
                // Simulate API call or real data fetch
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    // Your real API call would go here
                    self.isLoading = false // Set loading to false when done
                }
            }
        ) {
            ForEach(0..<10) { i in
                Text("Item \(i)")
                    .foregroundStyle(Color(hex: "9C4AFF"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "E0C7FF"))
                    .cornerRadius(8)
                    .shadow(radius: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    DragLoadingExample()
}
