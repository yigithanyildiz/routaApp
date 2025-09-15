import SwiftUI

// MARK: - Routa Design System Showcase
struct DesignSystemShowcase: View {
    @State private var selectedTab = 0
    @State private var isToggleOn = false
    @State private var selectedButtonGroup = 0
    @State private var showModal = false
    
    private let tabItems = [
        RoutaTabItem(icon: "house", selectedIcon: "house.fill", title: "Home", tag: 0),
        RoutaTabItem(icon: "map", selectedIcon: "map.fill", title: "Routes", tag: 1),
        RoutaTabItem(icon: "heart", selectedIcon: "heart.fill", title: "Favorites", tag: 2),
        RoutaTabItem(icon: "person", selectedIcon: "person.fill", title: "Profile", tag: 3)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    colorsSection
                    typographySection
                    cardsSection
                    buttonsSection
                    animationsSection
                    shadowsSection
                    hapticSection
                }
                .padding()
                .padding(.bottom, 100)
            }
            .background(Color.routaBackground)
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.large)
            .overlay(alignment: .bottom) {
                RoutaFloatingTabBar(
                    items: tabItems,
                    selectedTab: $selectedTab,
                    style: .standard
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Routa Design System")
                .routaHeroTitle()
                .multilineTextAlignment(.center)
            
            Text("A comprehensive modern design system featuring custom colors, typography, glassmorphic cards, spring animations, and haptic feedback.")
                .routaBody()
                .multilineTextAlignment(.center)
                .opacity(0.8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(RoutaGradients.heroGradient)
        )
        .foregroundColor(.white)
        .routaShadow(.high, style: .colored(.routaPrimary))
    }
    
    // MARK: - Colors Section
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Palette")
                .routaTitle2()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ColorSwatch(color: .routaPrimary, name: "Primary")
                ColorSwatch(color: .routaSecondary, name: "Secondary")
                ColorSwatch(color: .routaAccent, name: "Accent")
                ColorSwatch(color: .routaSuccess, name: "Success")
                ColorSwatch(color: .routaWarning, name: "Warning")
                ColorSwatch(color: .routaError, name: "Error")
            }
            
            VStack(spacing: 8) {
                Text("Gradients")
                    .routaHeadline()
                
                HStack(spacing: 12) {
                    GradientSwatch(gradient: RoutaGradients.primaryGradient, name: "Primary")
                    GradientSwatch(gradient: RoutaGradients.secondaryGradient, name: "Secondary")
                    GradientSwatch(gradient: RoutaGradients.accentGradient, name: "Accent")
                }
            }
        }
    }
    
    // MARK: - Typography Section
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .routaTitle2()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Hero Title")
                    .routaHeroTitle()
                Text("Display Title")
                    .routaDisplayTitle()
                Text("Title 1")
                    .routaTitle1()
                Text("Title 2")
                    .routaTitle2()
                Text("Headline")
                    .routaHeadline()
                Text("Body Text")
                    .routaBody()
                Text("Caption")
                    .routaCaption1()
            }
        }
    }
    
    // MARK: - Cards Section
    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Components")
                .routaTitle2()
            
            VStack(spacing: 16) {
                RoutaCard(style: .standard, elevation: .medium) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Standard Card")
                            .routaHeadline()
                        Text("This is a standard card with medium elevation and subtle shadow.")
                            .routaBody()
                    }
                }
                
                RoutaCard(style: .glassmorphic, elevation: .high) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Glassmorphic Card")
                            .routaHeadline()
                        Text("This card features a glassmorphic design with blur effects.")
                            .routaBody()
                    }
                }
                
                RoutaCard(style: .neumorphic, elevation: .medium) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Neumorphic Card")
                            .routaHeadline()
                        Text("This card has a neumorphic design with soft shadows.")
                            .routaBody()
                    }
                }
                
                RoutaCard(style: .gradient, elevation: .high) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gradient Card")
                            .routaHeadline()
                            .foregroundColor(.white)
                        Text("This card features a beautiful gradient background.")
                            .routaBody()
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
    }
    
    // MARK: - Buttons Section
    private var buttonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Button Components")
                .routaTitle2()
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    RoutaButton("Primary", variant: .primary) {
                        // Button action
                    }
                    RoutaButton("Secondary", variant: .secondary) {
                        // Button action
                    }
                    RoutaButton("Outline", variant: .outline) {
                        // Button action
                    }
                }
                
                HStack(spacing: 12) {
                    RoutaButton("Success", variant: .success) {
                        // Button action
                    }
                    RoutaButton("Warning", variant: .warning) {
                        // Button action
                    }
                    RoutaButton("Error", variant: .destructive) {
                        // Button action
                    }
                }
                
                RoutaGradientButton("Gradient Button", icon: "star.fill") {
                    // Button action
                }
                
                HStack(spacing: 16) {
                    RoutaIconButton(icon: "heart.fill", variant: .primary) {
                        // Icon button action
                    }
                    RoutaIconButton(icon: "bookmark.fill", variant: .secondary) {
                        // Icon button action
                    }
                    RoutaIconButton(icon: "share", variant: .outline) {
                        // Icon button action
                    }
                }
                
                RoutaToggleButton(
                    isOn: $isToggleOn,
                    onIcon: "checkmark.circle.fill",
                    offIcon: "circle"
                )
                
                RoutaButtonGroup(
                    buttons: [
                        .init("Option 1"),
                        .init("Option 2"),
                        .init("Option 3")
                    ],
                    selectedIndex: $selectedButtonGroup
                )
            }
        }
    }
    
    // MARK: - Animations Section
    private var animationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Animations")
                .routaTitle2()
            
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(RoutaGradients.primaryGradient)
                    .frame(width: 60, height: 60)
                    .routaPulse()
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(RoutaGradients.secondaryGradient)
                    .frame(width: 60, height: 60)
                    .routaFloat()
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(RoutaGradients.accentGradient)
                    .frame(width: 60, height: 60)
                    .routaGlow()
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.routaPrimary)
                    .frame(width: 60, height: 60)
                    .routaRotatingGradient()
            }
            
            RoutaLoadingView()
                .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Shadows Section
    private var shadowsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shadow System")
                .routaTitle2()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ShadowDemo(elevation: .low, title: "Low")
                ShadowDemo(elevation: .medium, title: "Medium")
                ShadowDemo(elevation: .high, title: "High")
                ShadowDemo(elevation: .floating, title: "Floating")
            }
            
            InteractiveShadowCard {
                VStack {
                    Text("Interactive Card")
                        .routaHeadline()
                    Text("Hover and tap to see shadow changes")
                        .routaCaption1()
                }
            }
        }
    }
    
    // MARK: - Haptic Section
    private var hapticSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Haptic Feedback")
                .routaTitle2()
            
            RoutaHapticSettings()
        }
    }
}

// MARK: - Supporting Views
struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(height: 60)
                .routaShadow(.low)
            
            Text(name)
                .routaCaption1()
        }
    }
}

struct GradientSwatch: View {
    let gradient: LinearGradient
    let name: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(gradient)
                .frame(height: 40)
                .routaShadow(.low)
            
            Text(name)
                .routaCaption1()
        }
    }
}

struct ShadowDemo: View {
    let elevation: RoutaElevation
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .routaHeadline()
            Text("Sample")
                .routaBody()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.routaCard)
        )
        .routaShadow(elevation)
    }
}

// MARK: - Preview
#Preview {
    DesignSystemShowcase()
        .environment(\.haptics, RoutaHapticsManager.shared)
}