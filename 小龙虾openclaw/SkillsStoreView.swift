//
//  SkillsStoreView.swift
//  龙虾AI导航 — Tab 3: 全部 AI 资源
//

import SwiftUI

struct SkillsStoreView: View {
    @EnvironmentObject var store: AgentStore
    @State private var selectedCategory: ToolCategory? = nil
    @State private var selectedTool: AITool? = nil
    @State private var searchText = ""

    var filteredTools: [AITool] {
        store.allTools.filter { tool in
            let categoryMatch = selectedCategory == nil || tool.category == selectedCategory
            let searchMatch = searchText.isEmpty || tool.name.localizedCaseInsensitiveContains(searchText) || tool.description.localizedCaseInsensitiveContains(searchText)
            return categoryMatch && searchMatch
        }
    }

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("搜索工具或分类...", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(label: "全部", icon: "square.grid.2x2.fill", color: Color(hex: "#00E5CC"), isSelected: selectedCategory == nil) {
                            withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                        }
                        ForEach(ToolCategory.allCases, id: \.self) { cat in
                            CategoryChip(label: cat.rawValue, icon: cat.icon, color: cat.accentColor, isSelected: selectedCategory == cat) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = (selectedCategory == cat) ? nil : cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)

                // Stats bar
                HStack {
                    Text("\(filteredTools.count) 个资源项")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(store.favoriteTools.count) 已收藏")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(hex: "#00E5CC"))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredTools) { tool in
                            ToolGridCard(tool: tool)
                                .onTapGesture { selectedTool = tool }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .animation(.spring(response: 0.4), value: filteredTools.count)
                }
            }
            .navigationTitle("全部 AI 资源")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedTool) { tool in
            ToolDetailSheet(tool: tool)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color.opacity(0.25) : Color.white.opacity(0.07))
            .foregroundColor(isSelected ? color : .secondary)
            .cornerRadius(20)
            .overlay(
                Capsule()
                    .stroke(isSelected ? color.opacity(0.6) : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Tool Grid Card

struct ToolGridCard: View {
    @EnvironmentObject var store: AgentStore
    let tool: AITool
    var isFavorited: Bool { store.favoriteTools.contains(tool.id) }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(tool.category.accentColor.opacity(0.18))
                            .frame(width: 38, height: 38)
                        Image(systemName: tool.icon)
                            .font(.system(size: 18))
                            .foregroundColor(tool.category.accentColor)
                    }
                    Spacer()
                    Button {
                        store.toggleFavorite(tool.id)
                    } label: {
                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isFavorited ? .red : .secondary)
                    }
                }

                Text(tool.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(tool.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(tool.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(tool.category.accentColor.opacity(0.12))
                        .foregroundColor(tool.category.accentColor)
                        .cornerRadius(5)
                    Spacer()
                    if isFavorited {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}

// MARK: - Tool Detail Sheet

struct ToolDetailSheet: View {
    @EnvironmentObject var store: AgentStore
    let tool: AITool
    @Environment(\.dismiss) var dismiss
    var isFavorited: Bool { store.favoriteTools.contains(tool.id) }

    var body: some View {
        ZStack {
            Color(hex: "#0A0F1E").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon + name
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(tool.category.accentColor.opacity(0.18))
                                .frame(width: 64, height: 64)
                            Image(systemName: tool.icon)
                                .font(.system(size: 30))
                                .foregroundColor(tool.category.accentColor)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tool.name)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            Text(tool.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(tool.category.accentColor)
                        }
                    }

                    Text(tool.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)

                    // Tags
                    FlowLayout(spacing: 8) {
                        ForEach(tool.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.08))
                                .foregroundColor(.secondary)
                                .cornerRadius(8)
                        }
                    }

                    // URL section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("官方地址")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "link")
                                .font(.caption)
                                .foregroundColor(tool.category.accentColor)
                            Text(tool.url)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }

                    // Action button
                    Button(action: {
                        // Open URL simulation or favorite
                        store.toggleFavorite(tool.id)
                    }) {
                        HStack {
                            Image(systemName: isFavorited ? "heart.slash.fill" : "heart.fill")
                            Text(isFavorited ? "从收藏中移除" : "添加到我的收藏")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(isFavorited ? Color.red.opacity(0.2) : tool.category.accentColor.opacity(0.25))
                        .foregroundColor(isFavorited ? .red : tool.category.accentColor)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isFavorited ? Color.red.opacity(0.5) : tool.category.accentColor.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding(24)
            }
        }
    }
}

// Simple FlowLayout for Tags
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    
    init(spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            content()
        }
    }
}
