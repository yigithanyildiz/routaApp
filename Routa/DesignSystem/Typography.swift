import SwiftUI

// MARK: - Routa Typography System
extension Font {
    
    // MARK: - Custom Font Weights
    enum RoutaWeight {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
        
        var value: Font.Weight {
            switch self {
            case .ultraLight: return .ultraLight
            case .thin: return .thin
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            case .heavy: return .heavy
            case .black: return .black
            }
        }
    }
    
    // MARK: - Heading Styles
    static func routaTitle1(_ weight: RoutaWeight = .bold) -> Font {
        return .system(size: 32, weight: weight.value, design: .rounded)
    }
    
    static func routaTitle2(_ weight: RoutaWeight = .bold) -> Font {
        return .system(size: 28, weight: weight.value, design: .rounded)
    }
    
    static func routaTitle3(_ weight: RoutaWeight = .semibold) -> Font {
        return .system(size: 24, weight: weight.value, design: .rounded)
    }
    
    static func routaHeadline(_ weight: RoutaWeight = .semibold) -> Font {
        return .system(size: 20, weight: weight.value, design: .rounded)
    }
    
    static func routaSubheadline(_ weight: RoutaWeight = .medium) -> Font {
        return .system(size: 18, weight: weight.value, design: .rounded)
    }
    
    // MARK: - Body Styles
    static func routaBody(_ weight: RoutaWeight = .regular) -> Font {
        return .system(size: 16, weight: weight.value, design: .default)
    }
    
    static func routaBodyEmphasized(_ weight: RoutaWeight = .medium) -> Font {
        return .system(size: 16, weight: weight.value, design: .default)
    }
    
    static func routaCallout(_ weight: RoutaWeight = .regular) -> Font {
        return .system(size: 15, weight: weight.value, design: .default)
    }
    
    // MARK: - Small Text Styles
    static func routaFootnote(_ weight: RoutaWeight = .regular) -> Font {
        return .system(size: 13, weight: weight.value, design: .default)
    }
    
    static func routaCaption1(_ weight: RoutaWeight = .regular) -> Font {
        return .system(size: 12, weight: weight.value, design: .default)
    }
    
    static func routaCaption2(_ weight: RoutaWeight = .regular) -> Font {
        return .system(size: 11, weight: weight.value, design: .default)
    }
    
    // MARK: - Special Styles
    static func routaDisplay(_ weight: RoutaWeight = .heavy) -> Font {
        return .system(size: 40, weight: weight.value, design: .rounded)
    }
    
    static func routaHero(_ weight: RoutaWeight = .black) -> Font {
        return .system(size: 48, weight: weight.value, design: .rounded)
    }
    
    // MARK: - Monospaced Styles
    static func routaCodeBlock(_ weight: RoutaWeight = .regular) -> Font {
        return .system(size: 14, weight: weight.value, design: .monospaced)
    }
    
    static func routaCodeInline(_ weight: RoutaWeight = .medium) -> Font {
        return .system(size: 13, weight: weight.value, design: .monospaced)
    }
}

// MARK: - Text Styles with Modifiers
struct RoutaTextStyle: Equatable {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    let tracking: CGFloat
    
    static let displayTitle = RoutaTextStyle(
        font: .routaDisplay(.heavy),
        color: .routaText,
        lineSpacing: 8,
        tracking: -0.5
    )
    
    static let heroTitle = RoutaTextStyle(
        font: .routaHero(.black),
        color: .routaText,
        lineSpacing: 10,
        tracking: -1.0
    )
    
    static let title1 = RoutaTextStyle(
        font: .routaTitle1(.bold),
        color: .routaText,
        lineSpacing: 6,
        tracking: -0.3
    )
    
    static let title2 = RoutaTextStyle(
        font: .routaTitle2(.bold),
        color: .routaText,
        lineSpacing: 4,
        tracking: -0.2
    )
    
    static let title3 = RoutaTextStyle(
        font: .routaTitle3(.semibold),
        color: .routaText,
        lineSpacing: 2,
        tracking: 0
    )
    
    static let headline = RoutaTextStyle(
        font: .routaHeadline(.semibold),
        color: .routaText,
        lineSpacing: 2,
        tracking: 0.1
    )
    
    static let subheadline = RoutaTextStyle(
        font: .routaSubheadline(.medium),
        color: .routaText,
        lineSpacing: 2,
        tracking: 0.1
    )
    
    static let body = RoutaTextStyle(
        font: .routaBody(.regular),
        color: .routaText,
        lineSpacing: 4,
        tracking: 0.2
    )
    
    static let bodyEmphasized = RoutaTextStyle(
        font: .routaBodyEmphasized(.medium),
        color: .routaText,
        lineSpacing: 4,
        tracking: 0.2
    )
    
    static let callout = RoutaTextStyle(
        font: .routaCallout(.regular),
        color: .routaTextSecondary,
        lineSpacing: 2,
        tracking: 0.2
    )
    
    static let footnote = RoutaTextStyle(
        font: .routaFootnote(.regular),
        color: .routaTextSecondary,
        lineSpacing: 1,
        tracking: 0.3
    )
    
    static let caption1 = RoutaTextStyle(
        font: .routaCaption1(.regular),
        color: .routaTextSecondary,
        lineSpacing: 1,
        tracking: 0.3
    )
    
    static let caption2 = RoutaTextStyle(
        font: .routaCaption2(.regular),
        color: .routaTextSecondary,
        lineSpacing: 1,
        tracking: 0.4
    )
}

// MARK: - Text View Modifier
struct RoutaTextModifier: ViewModifier {
    let style: RoutaTextStyle
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
            .tracking(style.tracking)
    }
}

// MARK: - Text Extensions
extension Text {
    func routaStyle(_ style: RoutaTextStyle) -> some View {
        self.modifier(RoutaTextModifier(style: style))
    }
    
    // Convenience methods
    func routaDisplayTitle() -> some View {
        self.routaStyle(.displayTitle)
    }
    
    func routaHeroTitle() -> some View {
        self.routaStyle(.heroTitle)
    }
    
    func routaTitle1() -> some View {
        self.routaStyle(.title1)
    }
    
    func routaTitle2() -> some View {
        self.routaStyle(.title2)
    }
    
    func routaTitle3() -> some View {
        self.routaStyle(.title3)
    }
    
    func routaHeadline() -> some View {
        self.routaStyle(.headline)
    }
    
    func routaSubheadline() -> some View {
        self.routaStyle(.subheadline)
    }
    
    func routaBody() -> some View {
        self.routaStyle(.body)
    }
    
    func routaBodyEmphasized() -> some View {
        self.routaStyle(.bodyEmphasized)
    }
    
    func routaCallout() -> some View {
        self.routaStyle(.callout)
    }
    
    func routaFootnote() -> some View {
        self.routaStyle(.footnote)
    }
    
    func routaCaption1() -> some View {
        self.routaStyle(.caption1)
    }
    
    func routaCaption2() -> some View {
        self.routaStyle(.caption2)
    }
}

// MARK: - Dynamic Typography
struct RoutaDynamicType {
    static func scaledFont(baseSize: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .rounded) -> Font {
        let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.body)
        let scaledSize = metrics.scaledValue(for: baseSize)
        return Font.system(size: scaledSize, weight: weight, design: design)
    }
}

// MARK: - Font Weight Extension
extension Font {
    var weight: Font.Weight? {
        // This is a simplified approach - in a real implementation,
        // you might want to store the weight alongside the font
        return .regular
    }
}