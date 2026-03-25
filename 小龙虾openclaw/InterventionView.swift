//
//  InterventionView.swift
//  龙虾监测站 — Tab 2: 远程干预
//

import SwiftUI

struct InterventionView: View {
    @EnvironmentObject var store: AgentStore
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment picker
                Picker("", selection: $selectedTab) {
                    Text("待处理 (\(store.pendingAlerts.count))").tag(0)
                    Text("已处理 (\(store.resolvedAlerts.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if selectedTab == 0 {
                            if store.pendingAlerts.isEmpty {
                                emptyPendingView
                            } else {
                                ForEach(store.pendingAlerts) { alert in
                                    PendingAlertRow(alert: alert)
                                }
                            }
                        } else {
                            if store.resolvedAlerts.isEmpty {
                                emptyResolvedView
                            } else {
                                ForEach(store.resolvedAlerts) { alert in
                                    ResolvedAlertRow(alert: alert)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("远程干预")
            .navigationBarTitleDisplayMode(.large)
        }
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
    }

    var emptyPendingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "#30D158"))
            Text("无待处理告警")
                .font(.headline)
                .foregroundColor(.white)
            Text("Agent 正在自主运行中，所有任务均在权限范围内")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    var emptyResolvedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.checkmark.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("暂无处理记录")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Pending Alert Row

struct PendingAlertRow: View {
    @EnvironmentObject var store: AgentStore
    let alert: AgentAlert
    @State private var showingDetail = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(alert.riskLevel.color)
                    Text(alert.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    RiskBadge(level: alert.riskLevel)
                }

                // Description
                Text(alert.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                // Timestamp
                Text(alert.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(Color(hex: "#00E5CC").opacity(0.7))

                Divider().background(Color.white.opacity(0.08))

                // Action buttons
                HStack(spacing: 10) {
                    ActionButton(
                        title: "授权",
                        icon: "checkmark.circle.fill",
                        color: Color(hex: "#30D158"),
                        action: { store.approve(alert) }
                    )
                    ActionButton(
                        title: "终止",
                        icon: "xmark.circle.fill",
                        color: Color(hex: "#FF4D6D"),
                        action: { store.reject(alert) }
                    )
                    ActionButton(
                        title: "暂停",
                        icon: "pause.circle.fill",
                        color: Color(hex: "#FF9500"),
                        action: { store.pause(alert) }
                    )
                }
            }
        }
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
}

// MARK: - Resolved Alert Row

struct ResolvedAlertRow: View {
    let alert: AgentAlert

    var statusInfo: (icon: String, color: Color, label: String) {
        switch alert.status {
        case .approved: return ("checkmark.circle.fill", Color(hex: "#30D158"), "已授权")
        case .rejected: return ("xmark.circle.fill", Color(hex: "#FF4D6D"), "已终止")
        case .paused:   return ("pause.circle.fill", Color(hex: "#FF9500"), "已暂停")
        default:        return ("questionmark.circle.fill", .secondary, "未知")
        }
    }

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: statusInfo.icon)
                    .font(.title3)
                    .foregroundColor(statusInfo.color)
                VStack(alignment: .leading, spacing: 3) {
                    Text(alert.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(alert.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text(alert.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(statusInfo.label)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusInfo.color.opacity(0.15))
                    .foregroundColor(statusInfo.color)
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Sub-components

struct RiskBadge: View {
    let level: AgentAlert.RiskLevel

    var body: some View {
        Text(level.rawValue)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(level.color.opacity(0.2))
            .foregroundColor(level.color)
            .cornerRadius(6)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { pressed = false }
                action()
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(color.opacity(0.15))
            .cornerRadius(10)
            .scaleEffect(pressed ? 0.92 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
    }
}
