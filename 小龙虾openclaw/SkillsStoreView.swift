//
//  SkillsStoreView.swift
//  龙虾监测站 — Tab 3: 技能商店
//

import SwiftUI

struct SkillsStoreView: View {
    @EnvironmentObject var store: AgentStore
    @State private var selectedCategory: SkillCategory? = nil
    @State private var selectedSkill: SkillPlugin? = nil
    @State private var searchText = ""

    var filteredSkills: [SkillPlugin] {
        store.allSkills.filter { skill in
            let categoryMatch = selectedCategory == nil || skill.category == selectedCategory
            let searchMatch = searchText.isEmpty || skill.name.localizedCaseInsensitiveContains(searchText) || skill.description.localizedCaseInsensitiveContains(searchText)
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
                    TextField("搜索技能...", text: $searchText)
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
                        ForEach(SkillCategory.allCases, id: \.self) { cat in
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
                    Text("\(filteredSkills.count) 个技能")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(store.installedSkills.count) 已安装")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(hex: "#00E5CC"))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredSkills) { skill in
                            SkillCard(skill: skill)
                                .onTapGesture { selectedSkill = skill }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .animation(.spring(response: 0.4), value: filteredSkills.count)
                }
            }
            .navigationTitle("技能商店")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedSkill) { skill in
            SkillDetailSheet(skill: skill)
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

// MARK: - Skill Card

struct SkillCard: View {
    @EnvironmentObject var store: AgentStore
    let skill: SkillPlugin
    var isInstalled: Bool { store.installedSkills.contains(skill.id) }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(skill.category.accentColor.opacity(0.18))
                            .frame(width: 38, height: 38)
                        Image(systemName: skill.icon)
                            .font(.system(size: 18))
                            .foregroundColor(skill.category.accentColor)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { isInstalled },
                        set: { _ in store.toggleSkill(skill.id) }
                    ))
                    .labelsHidden()
                    .tint(skill.category.accentColor)
                    .scaleEffect(0.8)
                }

                Text(skill.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(skill.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(skill.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(skill.category.accentColor.opacity(0.12))
                        .foregroundColor(skill.category.accentColor)
                        .cornerRadius(5)
                    Spacer()
                    if isInstalled {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(skill.category.accentColor)
                    }
                }
            }
        }
    }
}

// MARK: - Skill Detail Sheet

struct SkillDetailSheet: View {
    @EnvironmentObject var store: AgentStore
    let skill: SkillPlugin
    @Environment(\.dismiss) var dismiss
    var isInstalled: Bool { store.installedSkills.contains(skill.id) }

    var body: some View {
        ZStack {
            Color(hex: "#0A0F1E").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon + name
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(skill.category.accentColor.opacity(0.18))
                                .frame(width: 64, height: 64)
                            Image(systemName: skill.icon)
                                .font(.system(size: 30))
                                .foregroundColor(skill.category.accentColor)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(skill.name)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                            Text(skill.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(skill.category.accentColor)
                        }
                    }

                    Text(skill.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)

                    // Permissions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("所需权限")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        ForEach(skill.permissions, id: \.self) { perm in
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#FF9500"))
                                Text(perm)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)

                    // Install button
                    Button(action: {
                        store.toggleSkill(skill.id)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: isInstalled ? "trash.fill" : "plus.circle.fill")
                            Text(isInstalled ? "卸载此技能" : "安装此技能")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(isInstalled ? Color(hex: "#FF4D6D").opacity(0.2) : skill.category.accentColor.opacity(0.25))
                        .foregroundColor(isInstalled ? Color(hex: "#FF4D6D") : skill.category.accentColor)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isInstalled ? Color(hex: "#FF4D6D").opacity(0.5) : skill.category.accentColor.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding(24)
            }
        }
    }
}
