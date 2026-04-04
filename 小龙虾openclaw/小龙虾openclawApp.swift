//
//  LobsterAINavigationApp.swift
//  龙虾AI导航 — Portal Command Center
//

import SwiftUI

@main
struct LobsterAINavigationApp: App {
    @StateObject private var agentStore = AgentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(agentStore)
                .preferredColorScheme(.dark)
        }
    }
}
