//
//  InterventionView.swift
//  龙虾AI导航 — Tab 2: AI 动态广场
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
                    Text("最新情报 (\(store.pendingNews.count))").tag(0)
                    Text("历史回顾 (\(store.readNews.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Loading / Error banner
                if store.isLoadingNews {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(Color(hex: "#00E5CC"))
                        Text("正在从云端同步...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } else if let error = store.newsError {
                    HStack(spacing: 6) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#FFD60A"))
                        Text(error)
                            .font(.caption)
                            .foregroundColor(Color(hex: "#FFD60A").opacity(0.8))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "#FFD60A").opacity(0.08))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if selectedTab == 0 {
                            if store.pendingNews.isEmpty {
                                emptyNewsView
                            } else {
                                ForEach(store.pendingNews) { news in
                                    NewsRow(news: news)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .top).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        ))
                                }
                            }
                        } else {
                            if store.readNews.isEmpty {
                                emptyHistoryView
                            } else {
                                ForEach(store.readNews) { news in
                                    ReadNewsRow(news: news)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    await store.refreshNews()
                }
            }
            .navigationTitle("AI 动态广场")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await store.refreshNews() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#00E5CC"))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
    }

    var emptyNewsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "#00E5CC"))
            Text("暂无新鲜资讯")
                .font(.headline)
                .foregroundColor(.white)
            Text("AI 世界正在平静地演进，下拉刷新试试")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.checkmark.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("暂无阅读记录")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - News Row

struct NewsRow: View {
    @EnvironmentObject var store: AgentStore
    let news: AINews

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: "#00E5CC"))
                    Text(news.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    CategoryBadge(label: news.category)
                }

                // Description
                Text(news.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                // URL link
                if let urlStr = news.url, !urlStr.isEmpty, let url = URL(string: urlStr) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.caption2)
                            Text("查看详情")
                                .font(.caption)
                        }
                        .foregroundColor(Color(hex: "#0A84FF"))
                    }
                }

                // Timestamp + actions
                HStack {
                    Text(news.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(Color(hex: "#BF5AF2").opacity(0.8))
                    Spacer()
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        store.markAsRead(news)
                    } label: {
                        Text("标记已读")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#00E5CC").opacity(0.2))
                            .foregroundColor(Color(hex: "#00E5CC"))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Read News Row

struct ReadNewsRow: View {
    let news: AINews

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(news.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text(news.description)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.6))
                        .lineLimit(1)
                }
                Spacer()
                Text("已读")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Sub-components

struct CategoryBadge: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.1))
            .foregroundColor(.secondary)
            .cornerRadius(4)
    }
}
