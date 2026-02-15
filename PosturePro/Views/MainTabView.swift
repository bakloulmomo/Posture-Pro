//
//  MainTabView.swift
//  PosturePro
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView()
                .tabItem {
                    Label("Casa", systemImage: "leaf.fill")
                }
                .tag(0)
            
            StatsTabView()
                .tabItem {
                    Label("Statistiche", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            InfoTabView()
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
                }
                .tag(2)
        }
        .tint(AppTheme.Colors.success)
    }
}

#Preview {
    MainTabView()
}
