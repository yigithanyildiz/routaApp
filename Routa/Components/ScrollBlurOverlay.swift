import SwiftUI

// MARK: - Scroll Blur Overlay Component
struct ScrollBlurOverlay: View {
    let position: Position
    let enableBlur: Bool

    enum Position {
        case top
    }

    init(position: Position = .top, enableBlur: Bool = true) {
        self.position = position
        self.enableBlur = enableBlur
    }

    private var overlayHeight: CGFloat {
        switch position {
        case .top:
            return UIDevice.hasDynamicIsland ? 120 : 80
      
        }
    }

    private var gradientColors: [Color] {
        let baseColor = Color.routaBackground
        switch position {
        case .top:
            return [baseColor, baseColor.opacity(0.8), baseColor.opacity(0.4), Color.clear]
        
        }
    }

    private var gradientStartPoint: UnitPoint {
        position == .top ? .top : .bottom
    }

    private var gradientEndPoint: UnitPoint {
        position == .top ? .bottom : .top
    }

    var body: some View {
        VStack(spacing: 0) {
            if position == .top {
                blurContent
                Spacer()
            } else {
                Spacer()
                blurContent
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private var blurContent: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: gradientStartPoint,
                endPoint: gradientEndPoint
            )

            // Blur material overlay
            if enableBlur {
                blurMaterial
            }
        }
        .frame(height: overlayHeight)
    }

    private var blurMaterial: some View {
        Group {
            if position == .top {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: overlayHeight * 0.6)
                        .ignoresSafeArea()

                   
                }
            } else {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.thinMaterial)
                        .opacity(0.7)
                        .frame(height: overlayHeight * 0.4)

                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: overlayHeight * 0.6)
                }
            }
        }
        .compositingGroup()
        .opacity(enableBlur ? 1.0 : 0.0)
    }
}

// MARK: - Tab Bar Blur Overlay
struct TabBarBlurOverlay: View {
    let enableBlur: Bool

    init(enableBlur: Bool = true) {
        self.enableBlur = enableBlur
    }

    private var overlayHeight: CGFloat {
        return LayoutConstants.tabBarHeight + UIDevice.safeAreaInsets.bottom
    }

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.routaBackground.opacity(0.4),
                        Color.routaBackground.opacity(0.8),
                        Color.routaBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Blur material
                if enableBlur {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(.thinMaterial)
                            .opacity(0.7)
                            .frame(height: overlayHeight * 0.3)

                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(height: overlayHeight * 0.7)
                    }
                    .compositingGroup()
                }
            }
            .frame(height: overlayHeight)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Dynamic Island Safe Area ViewModifier
struct DynamicIslandSafeArea: ViewModifier {
    let enableTopBlur: Bool
    let enableBottomBlur: Bool

    init(enableTopBlur: Bool = true, enableBottomBlur: Bool = true) {
        self.enableTopBlur = enableTopBlur
        self.enableBottomBlur = enableBottomBlur
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            // Top blur overlay
            if enableTopBlur {
                ScrollBlurOverlay(position: .top)
            }

            // Bottom blur overlay (for tab bar)
    
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Adds Dynamic Island safe blur overlay
    func dynamicIslandBlur(
        enableTopBlur: Bool = true,
        enableBottomBlur: Bool = true
    ) -> some View {
        self.modifier(
            DynamicIslandSafeArea(
                enableTopBlur: enableTopBlur,
                enableBottomBlur: enableBottomBlur
            )
        )
    }

    /// Adds only top blur overlay
    func topScrollBlur(enableBlur: Bool = true) -> some View {
        ZStack {
            self
            ScrollBlurOverlay(position: .top, enableBlur: enableBlur)
        }
    }

    /// Adds only bottom blur overlay
  

    /// Adds both top and bottom blur overlays
    func fullScrollBlur(
        enableTopBlur: Bool = true,
        enableBottomBlur: Bool = true
    ) -> some View {
        ZStack {
            self

            if enableTopBlur {
                ScrollBlurOverlay(position: .top)
            }

            if enableBottomBlur {
                TabBarBlurOverlay()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ForEach(0..<20) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.3))
                    .frame(height: 100)
                    .overlay(
                        Text("Item \(index)")
                            .font(.headline)
                    )
            }
        }
        .padding()
    }
    .dynamicIslandBlur()
}
