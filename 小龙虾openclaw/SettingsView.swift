//
//  SettingsView.swift
//  龙虾监测站 — Tab 4: 设置
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("agentHost") private var agentHost = "http://localhost:8765"
    @AppStorage("apiKey") private var apiKey = ""
    @AppStorage("pushEnabled") private var pushEnabled = true
    @AppStorage("cpuThreshold") private var cpuThreshold = 0.8
    @AppStorage("tokenThreshold") private var tokenThreshold = 0.75
    @State private var showingAPIKey = false
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            List {
                // Connection section
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Agent 主机地址", systemImage: "network")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("http://", text: $agentHost)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(Color(hex: "#00E5CC"))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    VStack(alignment: .leading, spacing: 6) {
                        Label("API Key", systemImage: "key.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            if showingAPIKey {
                                TextField("sk-...", text: $apiKey)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(Color(hex: "#00E5CC"))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            } else {
                                SecureField("sk-...", text: $apiKey)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(Color(hex: "#00E5CC"))
                            }
                            Button(action: { showingAPIKey.toggle() }) {
                                Image(systemName: showingAPIKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    HStack {
                        Label("连接状态", systemImage: "wifi")
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: "#30D158"))
                                .frame(width: 7, height: 7)
                            Text("已连接")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#30D158"))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                } header: {
                    Text("连接配置")
                }

                // Notifications section
                Section {
                    Toggle(isOn: $pushEnabled) {
                        Label("推送通知", systemImage: "bell.badge.fill")
                    }
                    .tint(Color(hex: "#00E5CC"))
                    .listRowBackground(Color.white.opacity(0.05))

                    if pushEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label("CPU 警戒阈值", systemImage: "cpu.fill")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.0f%%", cpuThreshold * 100))
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundColor(Color(hex: "#00E5CC"))
                            }
                            Slider(value: $cpuThreshold, in: 0.5...0.99, step: 0.05)
                                .tint(Color(hex: "#FF4D6D"))
                        }
                        .listRowBackground(Color.white.opacity(0.05))

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label("Token 警戒阈值", systemImage: "bolt.fill")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.0f%%", tokenThreshold * 100))
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundColor(Color(hex: "#00E5CC"))
                            }
                            Slider(value: $tokenThreshold, in: 0.5...0.99, step: 0.05)
                                .tint(Color(hex: "#FFD60A"))
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                } header: {
                    Text("通知与告警")
                }

                // About section
                Section {
                    HStack {
                        Label("版本", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    HStack {
                        Label("技术栈", systemImage: "swift")
                        Spacer()
                        Text("SwiftUI · Combine")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    HStack {
                        Label("OpenClaw 版本", systemImage: "waveform")
                        Spacer()
                        Text("v2.4.1-beta")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#00E5CC"))
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Button(action: {}) {
                        Label("重置所有设置", systemImage: "arrow.counterclockwise")
                            .foregroundColor(Color(hex: "#FF4D6D"))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                } header: {
                    Text("关于")
                }

                // Footer branding
                Section {
                    VStack(spacing: 8) {
                        Text("🦞")
                            .font(.system(size: 32))
                        Text("龙虾监测站")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("OpenClaw Agent 移动指挥部")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
