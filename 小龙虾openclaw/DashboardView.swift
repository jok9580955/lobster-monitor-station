//
//  DashboardView.swift
//  龙虾监测站 — Tab 1: 实时状态看板
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AgentStore
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6
    @State private var showingCoTHistory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    cotCard
                    HStack(spacing: 12) {
                        GaugeCard(title: "CPU", value: store.cpuUsage, accentColor: Color(hex: "#00E5CC"), icon: "cpu.fill")
                        GaugeCard(title: "GPU", value: store.gpuUsage, accentColor: Color(hex: "#BF5AF2"), icon: "memorychip.fill")
                    }
                    tokenCard
                    activityStreamCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.clear)
            .navigationTitle("龙虾监测站")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(store.isAgentRunning ? Color(hex: "#30D158") : .red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseScale)
                            .shadow(color: (store.isAgentRunning ? Color(hex: "#30D158") : .red).opacity(0.8), radius: 4)
                        Text(store.isAgentRunning ? "运行中" : "已停止")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            startPulse()
        }
    }

    // MARK: - Cards

    var headerCard: some View {
        GlassCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#00E5CC").opacity(0.15))
                        .frame(width: 56, height: 56)
                    Circle()
                        .fill(Color(hex: "#00E5CC").opacity(glowOpacity * 0.3))
                        .frame(width: 56, height: 56)
                        .scaleEffect(pulseScale)
                    Text("🦞")
                        .font(.system(size: 28))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("OpenClaw Agent")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(store.isAgentRunning ? "● LIVE" : "● 已离线")
                        .font(.caption.weight(.bold))
                        .foregroundColor(store.isAgentRunning ? Color(hex: "#30D158") : .red)
                    Text("已运行 4h 32m · 本地Mac")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(spacing: 8) {
                    Button(action: { withAnimation { store.isAgentRunning.toggle() } }) {
                        Image(systemName: store.isAgentRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(store.isAgentRunning ? Color(hex: "#FF4D6D") : Color(hex: "#30D158"))
                    }
                }
            }
        }
    }

    var cotCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("思维链 (CoT)", systemImage: "brain.head.profile")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(hex: "#00E5CC"))

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "#00E5CC"))
                        .frame(width: 3, height: 36)
                    Text(store.currentTaskText)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .id(store.currentTaskText) // trigger transition
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    Spacer()
                }

                // Mini step pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(store.cotPhrases.prefix(5), id: \.self) { phrase in
                            Text(String(phrase.prefix(12)) + "…")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(8)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }

    var tokenCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("API Token 消耗", systemImage: "bolt.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(hex: "#FFD60A"))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(store.tokenUsed.formatted())")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        Text("已用 / \(store.tokenLimit.formatted()) 总量")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.0f%%", Double(store.tokenUsed) / Double(store.tokenLimit) * 100))
                        .font(.title3.weight(.bold))
                        .foregroundColor(tokenColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [Color(hex: "#FFD60A"), tokenColor], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(store.tokenUsed) / CGFloat(store.tokenLimit), height: 8)
                            .animation(.easeInOut(duration: 0.8), value: store.tokenUsed)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    var activityStreamCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("任务历史", systemImage: "list.bullet.clipboard.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                ForEach(store.taskHistory) { log in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: "#00E5CC").opacity(0.5))
                            .frame(width: 6, height: 6)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(log.step)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(log.timestamp.formatted(.relative(presentation: .named)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(log.duration)
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                    }
                    if log.id != store.taskHistory.last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    var tokenColor: Color {
        let ratio = Double(store.tokenUsed) / Double(store.tokenLimit)
        if ratio > 0.8 { return Color(hex: "#FF4D6D") }
        if ratio > 0.5 { return Color(hex: "#FF9500") }
        return Color(hex: "#30D158")
    }

    func startPulse() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.25
            glowOpacity = 1.0
        }
    }
}

// MARK: - Gauge Card

struct GaugeCard: View {
    let title: String
    let value: Double
    let accentColor: Color
    let icon: String

    var body: some View {
        GlassCard {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(value))
                        .stroke(
                            AngularGradient(colors: [accentColor.opacity(0.5), accentColor], center: .center),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.8), value: value)
                    VStack(spacing: 2) {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(accentColor)
                        Text(String(format: "%.0f%%", value * 100))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 70, height: 70)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Glass Card Component

struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
    }
}
