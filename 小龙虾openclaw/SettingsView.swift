//
//  SettingsView.swift
//  龙虾AI导航 — Tab 4: 个人中心
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("apiKey") private var apiKey = ""
    @AppStorage("pushEnabled") private var pushEnabled = true
    @AppStorage("autoRefresh") private var autoRefresh = true
    @AppStorage("displayMode") private var displayMode = 0 // 0: Auto, 1: Dark, 2: Light
    @State private var showingAPIKey = false
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // Connection section
                Section {

                    VStack(alignment: .leading, spacing: 6) {
                        Label("私有访问密钥 (API Key)", systemImage: "key.fill")
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
                        Label("云端同步状态", systemImage: "icloud.and.arrow.up.fill")
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: "#30D158"))
                                .frame(width: 7, height: 7)
                            Text("同步中")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#30D158"))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                } header: {
                    Text("服务配置")
                }

                // General section
                Section {
                    Toggle(isOn: $pushEnabled) {
                        Label("每日动态推送", systemImage: "bell.badge.fill")
                    }
                    .tint(Color(hex: "#00E5CC"))
                    .listRowBackground(Color.white.opacity(0.05))

                    Toggle(isOn: $autoRefresh) {
                        Label("自动刷新导航热度", systemImage: "arrow.clockwise.circle.fill")
                    }
                    .tint(Color(hex: "#BF5AF2"))
                    .listRowBackground(Color.white.opacity(0.05))

                    Picker(selection: $displayMode, label: Label("外观模式", systemImage: "paintbrush.fill")) {
                        Text("跟随系统").tag(0)
                        Text("深色模式").tag(1)
                        Text("浅色模式").tag(2)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                } header: {
                    Text("动态与推送")
                }

                // About section
                Section {
                    HStack {
                        Label("当前版本", systemImage: "info.circle.fill")
                        Spacer()
                        Text("v2.0.0 (Gold)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    HStack {
                        Label("龙虾 AI 旗舰版", systemImage: "crown.fill")
                        Spacer()
                        Text("已激活")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#FFD60A"))
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Link(destination: URL(string: "https://jok9580955.github.io/lobster-monitor-station/")!) {
                        Label("隐私政策", systemImage: "hand.raised.fill")
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    Button(action: { showClearConfirm = true }) {
                        Label("清除本地缓存", systemImage: "trash")
                            .foregroundColor(Color(hex: "#FF4D6D"))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                } header: {
                    Text("关于")
                }

                // Footer branding
                Section {
                    VStack(spacing: 8) {
                        LobsterLogo(size: 48)
                        Text("龙虾 AI 导航")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("探索 AI 生产力的终极入口")
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
            .navigationTitle("个人中心")
            .navigationBarTitleDisplayMode(.large)
            .alert("清除缓存", isPresented: $showClearConfirm) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) {
                    NewsService.shared.clearCache()
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } message: {
                Text("清除所有本地缓存数据？下次打开将重新从云端同步。")
            }
        }
    }
}

