import SwiftUI

enum AppColors {
    static let background = Color("Background")  // #FDF6E9 (cream)
    static let surface = Color("Surface")        // #FFFFFF
    static let accent = Color("Accent")          // #2DD4BF (teal)
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}
