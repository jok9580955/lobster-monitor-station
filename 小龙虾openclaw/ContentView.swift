//
//  ContentView.swift
//  龙虾监测站 — Main Tab Container
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
                        Label("状态看板", systemImage: "waveform.path.ecg")
                    }
                    .tag(0)

                InterventionView()
                    .tabItem {
                        Label("远程干预", systemImage: "bell.badge.fill")
                    }
                    .tag(1)
                    .badge(store.pendingAlerts.count > 0 ? store.pendingAlerts.count : 0)

                SkillsStoreView()
                    .tabItem {
                        Label("技能商店", systemImage: "square.grid.2x2.fill")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(Color(hex: "#00E5CC"))
        }
    }
}
