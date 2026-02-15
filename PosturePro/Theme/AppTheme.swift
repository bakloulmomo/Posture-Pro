//
//  AppTheme.swift
//  PosturePro
//

import SwiftUI

enum AppTheme {
    
    enum Spacing {
        static let xxxs: CGFloat = 4
        static let xxs: CGFloat = 8
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 40
    }
    
    enum Radius {
        static let card: CGFloat = 20
        static let button: CGFloat = 14
        static let plantCard: CGFloat = 28
    }
    
    enum Layout {
        static let minTouchTarget: CGFloat = 48
        static let plantSceneWidth: CGFloat = 280
        static let plantSceneHeight: CGFloat = 360
        static let bottomBarHeight: CGFloat = 88
    }
    
    enum Colors {
        static let background = Color(.systemGroupedBackground)
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let success = Color.green
        static let warning = Color.orange
    }
    
    enum Typography {
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.subheadline
        static let captionMuted = Font.caption
    }
}
