//
//  小龙虾openclawApp.swift
//  龙虾监测站 — Agent Command Center
//

import SwiftUI

@main
struct 小龙虾openclawApp: App {
    @StateObject private var agentStore = AgentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(agentStore)
                .preferredColorScheme(.dark)
        }
    }
}
