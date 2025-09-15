import SwiftUI

// MARK: - Tab Item Model
struct RoutaTabItem: Identifiable {
    let id = UUID()
    let icon: String
    let selectedIcon: String
    let title: String
    let tag: Int
    
    init(icon: String, selectedIcon: String? = nil, title: String, tag: Int) {
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
        self.title = title
        self.tag = tag
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    let items: [RoutaTabItem]
    @Binding var selectedTab: Int
    let onTabSelected: (Int) -> Void
    
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private let tabBarHeight: CGFloat = 70
    
    init(
        items: [RoutaTabItem],
        selectedTab: Binding<Int>,
        onTabSelected: @escaping (Int) -> Void = { _ in }
    ) {
        self.items = items
        self._selectedTab = selectedTab
        self.onTabSelected = onTabSelected
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TabItemView(
                    item: item,
                    isSelected: selectedTab == item.tag,
                    onTap: {
                        selectTab(item.tag)
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: tabBarHeight)
        .background(.ultraThinMaterial)
        .animation(RoutaAnimations.smoothSpring, value: selectedTab)
    }
    
    private func selectTab(_ tag: Int) {
        if selectedTab != tag {
            hapticFeedback.impactOccurred()
            selectedTab = tag
            onTabSelected(tag)
        }
    }
    
}

// MARK: - Tab Item View
struct TabItemView: View {
    let item: RoutaTabItem
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Icon without background circle
                Image(systemName: isSelected ? item.selectedIcon : item.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .routaPrimary : .routaTextSecondary)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // Title
                Text(item.title)
                    .font(.routaCaption1(.medium))
                    .foregroundColor(isSelected ? .routaPrimary : .routaTextSecondary)
                    .scaleEffect(isSelected ? 1.0 : 0.9)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(RoutaAnimations.quickSpring, value: isPressed)
        .animation(RoutaAnimations.smoothSpring, value: isSelected)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Floating Tab Bar with Center Action
struct FloatingTabBarWithCenter: View {
    let items: [RoutaTabItem]
    @Binding var selectedTab: Int
    let centerAction: () -> Void
    let centerIcon: String
    let onTabSelected: (Int) -> Void
    
    @State private var centerPressed = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    init(
        items: [RoutaTabItem],
        selectedTab: Binding<Int>,
        centerIcon: String = "plus",
        centerAction: @escaping () -> Void,
        onTabSelected: @escaping (Int) -> Void = { _ in }
    ) {
        self.items = items
        self._selectedTab = selectedTab
        self.centerAction = centerAction
        self.centerIcon = centerIcon
        self.onTabSelected = onTabSelected
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side tabs
            ForEach(Array(items.prefix(2).enumerated()), id: \.element.id) { index, item in
                TabItemView(
                    item: item,
                    isSelected: selectedTab == item.tag,
                    onTap: {
                        selectedTab = item.tag
                        onTabSelected(item.tag)
                    }
                )
                .frame(maxWidth: .infinity)
            }
            
            // Center action button
            Button(action: {
                hapticFeedback.impactOccurred()
                centerAction()
            }) {
                Image(systemName: centerIcon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(RoutaGradients.accentGradient)
                            .shadow(
                                color: .routaAccent.opacity(0.4),
                                radius: centerPressed ? 8 : 16,
                                x: 0,
                                y: centerPressed ? 4 : 8
                            )
                    )
                    .scaleEffect(centerPressed ? 0.9 : 1.0)
                    .offset(y: -10)
            }
            .buttonStyle(PlainButtonStyle())
            .animation(RoutaAnimations.quickSpring, value: centerPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                centerPressed = pressing
            }, perform: {})
            
            // Right side tabs
            ForEach(Array(items.suffix(2).enumerated()), id: \.element.id) { index, item in
                TabItemView(
                    item: item,
                    isSelected: selectedTab == item.tag,
                    onTap: {
                        selectedTab = item.tag
                        onTabSelected(item.tag)
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Minimal Floating Tab Bar
struct MinimalFloatingTabBar: View {
    let items: [RoutaTabItem]
    @Binding var selectedTab: Int
    let onTabSelected: (Int) -> Void
    
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    init(
        items: [RoutaTabItem],
        selectedTab: Binding<Int>,
        onTabSelected: @escaping (Int) -> Void = { _ in }
    ) {
        self.items = items
        self._selectedTab = selectedTab
        self.onTabSelected = onTabSelected
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(items, id: \.id) { item in
                Button(action: {
                    if selectedTab != item.tag {
                        hapticFeedback.impactOccurred()
                        selectedTab = item.tag
                        onTabSelected(item.tag)
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: selectedTab == item.tag ? item.selectedIcon : item.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(selectedTab == item.tag ? .routaPrimary : .routaTextSecondary)
                        
                        if selectedTab == item.tag {
                            Circle()
                                .fill(Color.routaPrimary)
                                .frame(width: 6, height: 6)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .fill(.clear)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(.ultraThinMaterial)
        .animation(RoutaAnimations.smoothSpring, value: selectedTab)
    }
}

// MARK: - Tab Bar Styles
enum FloatingTabBarStyle {
    case standard
    case withCenter
    case minimal
}

// MARK: - Main Floating Tab Bar Component
struct RoutaFloatingTabBar: View {
    let items: [RoutaTabItem]
    @Binding var selectedTab: Int
    let style: FloatingTabBarStyle
    let centerAction: (() -> Void)?
    let centerIcon: String
    let onTabSelected: (Int) -> Void
    
    init(
        items: [RoutaTabItem],
        selectedTab: Binding<Int>,
        style: FloatingTabBarStyle = .standard,
        centerIcon: String = "plus",
        centerAction: (() -> Void)? = nil,
        onTabSelected: @escaping (Int) -> Void = { _ in }
    ) {
        self.items = items
        self._selectedTab = selectedTab
        self.style = style
        self.centerAction = centerAction
        self.centerIcon = centerIcon
        self.onTabSelected = onTabSelected
    }
    
    var body: some View {
        Group {
            switch style {
            case .standard:
                FloatingTabBar(
                    items: items,
                    selectedTab: $selectedTab,
                    onTabSelected: onTabSelected
                )
                
            case .withCenter:
                FloatingTabBarWithCenter(
                    items: items,
                    selectedTab: $selectedTab,
                    centerIcon: centerIcon,
                    centerAction: centerAction ?? {},
                    onTabSelected: onTabSelected
                )
                
            case .minimal:
                MinimalFloatingTabBar(
                    items: items,
                    selectedTab: $selectedTab,
                    onTabSelected: onTabSelected
                )
            }
        }
    }
}