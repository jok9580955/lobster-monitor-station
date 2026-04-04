//
//  DashboardView.swift
//  龙虾AI导航 — Tab 1: 智能导航首页
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AgentStore
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerHero
                    
                    trendingCard
                    
                    HStack(spacing: 10) {
                        CategoryQuickLink(title: "智能体", icon: "brain.head.profile", color: Color(hex: "#FFD60A"))
                        CategoryQuickLink(title: "大模型", icon: "message.and.waveform.fill", color: Color(hex: "#00E5CC"))
                        CategoryQuickLink(title: "基础设施", icon: "cloud.fill", color: Color(hex: "#0A84FF"))
                        CategoryQuickLink(title: "技能市场", icon: "square.grid.2x2.fill", color: Color(hex: "#FF9500"))
                    }
                    
                    featuredToolsSection
                    
                    portalStatsCard
                    
                    recentActivitySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.clear)
            .navigationTitle("龙虾 AI 导航")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(store.isPortalLive ? Color(hex: "#30D158") : .red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseScale)
                            .shadow(color: (store.isPortalLive ? Color(hex: "#30D158") : .red).opacity(0.8), radius: 4)
                        Text(store.isPortalLive ? "已联网" : "离线中")
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

    // MARK: - Components

    var headerHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        LobsterLogo(size: 48, secondaryColor: Color(hex: "#00E5CC"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("欢迎来到龙虾 AI 导航")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("发现最前沿的 AI 生产力")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Simulated Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("搜索 AI 工具或资源...")
                            .foregroundColor(.secondary.opacity(0.6))
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "mic.fill")
                            .foregroundColor(Color(hex: "#00E5CC"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                }
            }
        }
    }

    var trendingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("全网动态", systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(hex: "#00E5CC"))

                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .foregroundColor(Color(hex: "#00E5CC"))
                        .font(.system(size: 14))
                    Text(store.trendingToolName)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .id(store.trendingToolName)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    Spacer()
                }
            }
        }
    }

    var featuredToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("热门推荐")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("查看全部")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#00E5CC"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.allTools.prefix(5)) { tool in
                        ToolCard(tool: tool)
                    }
                }
            }
        }
    }

    var portalStatsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("导航活跃度", systemImage: "chart.bar.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(hex: "#FFD60A"))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(store.activeUsers.formatted())")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        Text("当前在线用户")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f%%", store.networkStatus * 100))
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color(hex: "#30D158"))
                        Text("联网通达度")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [Color(hex: "#FFD60A"), Color(hex: "#00E5CC")], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(store.networkStatus), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    var recentActivitySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("最近访问", systemImage: "clock.arrow.2.circlepath")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                ForEach(store.naviHistory.prefix(3)) { log in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: "#00E5CC").opacity(0.3))
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(log.toolName)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(log.timestamp.formatted(.relative(presentation: .named)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(log.action)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                            .foregroundColor(.secondary)
                    }
                    if log.id != store.naviHistory.prefix(3).last?.id {
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    func startPulse() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.25
            glowOpacity = 1.0
        }
    }
}

// MARK: - Subviews

struct CategoryQuickLink: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
    }
}

struct ToolCard: View {
    let tool: AITool
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundColor(tool.category.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                    Text(tool.category.rawValue)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    ForEach(tool.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 8))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 100, height: 110)
        }
    }
}

// MARK: - Glass Card Component (Shared)

struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(14)
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

// MARK: - Shared Lobster Logo

struct LobsterLogo: View {
    var size: CGFloat = 40
    var secondaryColor: Color = Color(hex: "#BF5AF2")
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF4D6D"), secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color(hex: "#FF4D6D").opacity(0.35), radius: size/5)
            
            Image(systemName: "safari.fill")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundColor(.white)
            
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.35))
                .foregroundColor(.white)
                .offset(x: size * 0.25, y: -size * 0.25)
        }
    }
}
