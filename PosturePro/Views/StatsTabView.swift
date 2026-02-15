//
//  StatsTabView.swift
//  PosturePro
//

import SwiftUI

struct StatsTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    placeholderCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Statistiche",
                        subtitle: "Le tue sessioni e il tempo con postura corretta appariranno qui."
                    )
                }
                .padding(AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Statistiche")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func placeholderCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.success.opacity(0.7))
            Text(title)
                .font(AppTheme.Typography.headline)
            Text(subtitle)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
    }
}

#Preview {
    StatsTabView()
}
