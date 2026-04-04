//
//  ContentView.swift
//  龙虾AI导航 — Main Tab Container
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AgentStore
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Global deep dark background
            LinearGradient(
                colors: [Color(hex: "#0A0F1E"), Color(hex: "#080C18"), Color(hex: "#0D1526")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("推荐导航", systemImage: "safari.fill")
                    }
                    .tag(0)

                InterventionView()
                    .tabItem {
                        Label("动态广场", systemImage: "square.grid.2x2.fill")
                    }
                    .tag(1)
                    .badge(store.pendingNews.count > 0 ? store.pendingNews.count : 0)

                SkillsStoreView()
                    .tabItem {
                        Label("全部资源", systemImage: "list.bullet.indent")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("个人中心", systemImage: "person.crop.circle.fill")
                    }
                    .tag(3)
            }
            .tint(Color(hex: "#00E5CC"))
        }
    }
}
