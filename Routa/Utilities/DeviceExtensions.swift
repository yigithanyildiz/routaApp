import SwiftUI
import UIKit

// MARK: - Device Extension for SafeArea Management
extension UIDevice {
    /// Detects if the device has Dynamic Island (iPhone 14 Pro and later)
    static var hasDynamicIsland: Bool {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else { return false }
        return window.safeAreaInsets.top > 50
    }

    /// Detects if the device has a notch (iPhone X - iPhone 13 series)
    static var hasNotch: Bool {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else { return false }
        return window.safeAreaInsets.top > 20 && window.safeAreaInsets.top <= 50
    }

    /// Gets the current safe area insets
    static var safeAreaInsets: UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        return window.safeAreaInsets
    }

    /// Device type identification
    static var deviceType: DeviceType {
        if hasDynamicIsland {
            return .dynamicIsland
        } else if hasNotch {
            return .notch
        } else {
            return .legacy
        }
    }

    enum DeviceType {
        case dynamicIsland  // iPhone 14 Pro and later
        case notch          // iPhone X - iPhone 13 series
        case legacy         // iPhone 8 and earlier, iPad
    }
}

// MARK: - View Extensions for SafeArea Management
extension View {
    /// Adds appropriate padding for Dynamic Island devices
    func dynamicIslandPadding() -> some View {
        self.padding(.top, UIDevice.hasDynamicIsland ? 50 : 44)
    }

    /// Adds appropriate safe area top padding based on device type
    func safeAreaTopPadding() -> some View {
        switch UIDevice.deviceType {
        case .dynamicIsland:
            return self.padding(.top, 50)
        case .notch:
            return self.padding(.top, 44)
        case .legacy:
            return self.padding(.top, 20)
        }
    }

    /// Adds smart top padding that adapts to device type
    func adaptiveTopPadding() -> some View {
        self.padding(.top, UIDevice.safeAreaInsets.top)
    }

    /// Ensures content doesn't get clipped by Dynamic Island or notch
    func avoidDynamicIsland() -> some View {
        self.padding(.top, UIDevice.hasDynamicIsland ? 15 : 0)
    }

    /// Adds proper navigation bar replacement padding
    func navigationBarReplacementPadding() -> some View {
        self.padding(.top, UIDevice.safeAreaInsets.top + 44)
    }
}

// MARK: - Safe Area Constants
struct SafeAreaConstants {
    /// Dynamic Island additional padding
    static let dynamicIslandPadding: CGFloat = 15

    /// Standard navigation bar height
    static let navigationBarHeight: CGFloat = 44

    /// Minimum safe area top for legacy devices
    static let legacySafeAreaTop: CGFloat = 20

    /// Standard notch safe area
    static let notchSafeAreaTop: CGFloat = 44

    /// Dynamic Island safe area
    static let dynamicIslandSafeAreaTop: CGFloat = 50

    /// Get appropriate top safe area for current device
    static var currentTopSafeArea: CGFloat {
        switch UIDevice.deviceType {
        case .dynamicIsland:
            return dynamicIslandSafeAreaTop
        case .notch:
            return notchSafeAreaTop
        case .legacy:
            return legacySafeAreaTop
        }
    }
}