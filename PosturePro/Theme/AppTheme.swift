//
//  AppTheme.swift
//  PosturePro
//
//  Design system centralizzato. Modifica qui per cambiare l'aspetto dell'intera app.
//

import SwiftUI

enum AppTheme {
    
    // MARK: - Spacing (8pt grid)
    enum Spacing {
        static let xxxs: CGFloat = 4
        static let xxs: CGFloat = 8
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    enum Radius {
        static let card: CGFloat = 20
        static let button: CGFloat = 14
        static let plantCard: CGFloat = 28
        static let icon: CGFloat = 12
    }
    
    // MARK: - Layout
    enum Layout {
        static let minTouchTarget: CGFloat = 44
        static let plantSceneWidth: CGFloat = 300
        static let plantSceneHeight: CGFloat = 420
    }
    
    // MARK: - Colors (semantic)
    enum Colors {
        static let background = Color(.systemGroupedBackground)
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let success = Color.green
        static let warning = Color.orange
    }
    
    // MARK: - Typography
    enum Typography {
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.subheadline
        static let captionMuted = Font.caption
    }
}
