//
//  SKLoad_Components.swift
//  MicroUXLibrary
//
//  Created by Lai Wei on 2025-04-28.
//

import SwiftUI
import Unicro


/// Configuration for shimmer loading effect
public struct SKLoadShimmerConfiguration {
    public var baseColor: Color
    public var shimmerColor: Color
    public var cornerRadius: CGFloat
    public var duration: Double
    public var delay: Double

    public init(
        baseColor: Color = Color.gray.opacity(0.3),
        shimmerColor: Color = Color.white.opacity(0.7),
        cornerRadius: CGFloat = 4,
        duration: Double = 1.5,
        delay: Double = 0.0
    ) {
        self.baseColor = baseColor
        self.shimmerColor = shimmerColor
        self.cornerRadius = cornerRadius
        self.duration = duration
        self.delay = delay
    }

    public static let standard = SKLoadShimmerConfiguration()
}

public struct SKLoadShimmerModifier: ViewModifier {
    @State private var isAnimating = false
    @Binding var isLoading: Bool
    private let config: SKLoadShimmerConfiguration

    // New initializer with isLoading binding
    public init(isLoading: Binding<Bool>, config: SKLoadShimmerConfiguration = .standard) {
        self._isLoading = isLoading
        self.config = config
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isLoading {  
                        GeometryReader { geometry in
                            ZStack {
                                config.baseColor
                                    .mask(
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: .clear, location: 0),
                                                        .init(color:  config.shimmerColor, location: 0.3),
                                                        .init(color: .clear, location: 0.7)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * 2)
                                            .offset(x: -geometry.size.width + (isAnimating ? geometry.size.width * 3 : 0))
                                    )
                                    .blendMode(.screen)
                            }
                        }
                    }
                }
            )
            .onAppear {
                if isLoading {
                    startAnimation()
                }
            }
            .onChange(of: isLoading) { newValue in
                if newValue {
                    startAnimation()
                }
            }
    }
    
    // Helper function to start animation
    private func startAnimation() {
        isAnimating = false  // Reset animation state
        withAnimation(
            Animation
                .linear(duration: config.duration)
                .repeatForever(autoreverses: false)
                .delay(config.delay)
        ) {
            isAnimating = true
        }
    }
}

public extension View {
    func SKLoadShimmer(isLoading: Binding<Bool>, config: SKLoadShimmerConfiguration = .standard) -> some View {
        modifier(SKLoadShimmerModifier(isLoading: isLoading, config: config))
    }
}

#if DEBUG
// Example usage
struct ShimmerExample: View {
    @State private var isLoading = true
    @State private var items: [String] = []
    
    var body: some View {
        VStack {
            ForEach(0..<10, id: \.self) { i in
                Text(items.count > i ? items[i] : "Loading...")
                    .foregroundStyle(Color(hex: "9C4AFF"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "E0C7FF"))
                    .cornerRadius(8)
                    .shadow(radius: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .SKLoadShimmer(isLoading: $isLoading)
            }
            
            Button("Reload Data") {
                loadData()
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        // Reset state
        isLoading = true
        items = []
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // In a real app, this would be your API request
            items = (1...10).map { "Item \($0)" }
            isLoading = false
        }
    }
}



/// Example usage in a Gmail style skeleton screen
struct GmailLoadingExample: View {
    @State private var isLoading = true
    @State private var emails: [EmailItem] = []
    
    // Email model
    struct EmailItem: Identifiable {
        let id = UUID()
        let sender: String
        let subject: String
        let preview: String
        let timestamp: String
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // App bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Inbox")
                    .foregroundColor(.white)
                    .font(.headline)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                }

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(90))
                }
            }
            .padding()
            .background(Color.purple)

            // Section label
            HStack {
                Text("Today")
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                Spacer()
                
                // Add refresh button
                Button(action: {
                    fetchEmails()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.purple)
                        .opacity(isLoading ? 0.5 : 1.0)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(
                            isLoading ?
                                Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                                .default,
                            value: isLoading
                        )
                }
                .disabled(isLoading)
                .padding(.trailing)
            }
            .background(Color.gray.opacity(0.15))

            // Email list - Show skeletons when loading, real data when loaded
            ScrollView {
                VStack(spacing: 0) {
                    if isLoading || emails.isEmpty {
                        // Show skeleton loaders while loading
                        ForEach(0..<8, id: \.self) { index in
                            emailSkeletonItem(index: index)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                        }
                    } else {
                        // Show actual emails when loaded
                        ForEach(emails) { email in
                            emailItem(email: email)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchEmails()
        }
    }
    
    // Real email item view
    private func emailItem(email: EmailItem) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar circle with initials
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.7))
                    .frame(width: 40, height: 40)
                
                Text(String(email.sender.prefix(1)))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(email.sender)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(email.timestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(email.subject)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(email.preview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
    }

    // Skeleton item - now with isLoading binding
    private func emailSkeletonItem(index: Int) -> some View {
        let delay = Double(index) * 0.05
        let config = SKLoadShimmerConfiguration(
            baseColor: .gray.opacity(0.3),
            shimmerColor: .white.opacity(0.7),
            cornerRadius: 4,
            duration: 1.2,
            delay: delay
        )

        return HStack(alignment: .top, spacing: 16) {
            // Avatar circle
            Circle()
                .fill(.gray.opacity(0.5))
                .frame(width: 40, height: 40)
                .SKLoadShimmer(isLoading: $isLoading, config: config)

            VStack(alignment: .leading, spacing: 8) {
                // Sender and time
                HStack {
                    Rectangle()
                        .fill(.gray.opacity(0.5))
                        .frame(width: 150, height: 16)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(.gray.opacity(0.5))
                        .frame(width: 40, height: 12)
                }
                .SKLoadShimmer(isLoading: $isLoading, config: config)
                   
                // Subject
                Rectangle()
                    .fill(.gray.opacity(0.5))
                    .frame(height: 14)
                    .SKLoadShimmer(isLoading: $isLoading, config: config)
                
                // Preview
                Rectangle()
                    .fill(.gray.opacity(0.5))
                    .frame(height: 14)
                    .SKLoadShimmer(isLoading: $isLoading, config: config)
            }
        }
    }
    
    // Simulated API call to fetch emails
    private func fetchEmails() {
        // Reset state
        isLoading = true
        emails = []
        
        // Simulate network delay (2 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // In a real app, this would be your email API request
            // For example: EmailService.shared.fetchInbox { result in ... }
            
            // Sample data
            self.emails = [
                EmailItem(
                    sender: "John Appleseed",
                    subject: "Project update - New UI design",
                    preview: "Hi team, I've just finished the new UI design for our app. Please review and provide feedback.",
                    timestamp: "11:32 AM"
                ),
                EmailItem(
                    sender: "App Store",
                    subject: "Your receipt from Apple",
                    preview: "Thank you for your purchase. Your receipt is attached.",
                    timestamp: "10:15 AM"
                ),
                EmailItem(
                    sender: "Sarah Johnson",
                    subject: "Meeting rescheduled",
                    preview: "The team meeting has been rescheduled to tomorrow at 2 PM. Please update your calendar.",
                    timestamp: "9:47 AM"
                ),
                EmailItem(
                    sender: "Medium Daily Digest",
                    subject: "Top stories for you",
                    preview: "Check out today's top stories personalized just for you.",
                    timestamp: "8:30 AM"
                ),
                EmailItem(
                    sender: "GitHub",
                    subject: "Security alert: dependency update required",
                    preview: "We've detected a vulnerability in one of your repository dependencies.",
                    timestamp: "7:55 AM"
                ),
                EmailItem(
                    sender: "LinkedIn",
                    subject: "New job matches for you",
                    preview: "We found 5 new jobs that match your profile. See them now.",
                    timestamp: "7:22 AM"
                ),
                EmailItem(
                    sender: "Alex Cooper",
                    subject: "Weekend plans",
                    preview: "Hey! Are you free this weekend? I was thinking we could grab lunch.",
                    timestamp: "6:45 AM"
                ),
                EmailItem(
                    sender: "Twitter",
                    subject: "Your weekly summary",
                    preview: "See what you missed this week on Twitter.",
                    timestamp: "5:30 AM"
                )
            ]
            
            // Update loading state
            self.isLoading = false
        }
    }
}


/// Preview the gmail-style loading screen
#Preview {
    GmailLoadingExample()
}
#endif

