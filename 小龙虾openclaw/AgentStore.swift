//
//  AgentStore.swift
//  龙虾AI导航 — Global Navigation Portal
//

import SwiftUI
import Combine

// MARK: - Models

struct AINews: Identifiable {
    let id = UUID()
    let remoteId: String?
    let title: String
    let description: String
    let category: String
    let timestamp: Date
    var isRead: Bool = false
    let url: String?

    init(remoteId: String? = nil, title: String, description: String, category: String, timestamp: Date, isRead: Bool = false, url: String? = nil) {
        self.remoteId = remoteId
        self.title = title
        self.description = description
        self.category = category
        self.timestamp = timestamp
        self.isRead = isRead
        self.url = url
    }
}

struct ToolLog: Identifiable {
    let id = UUID()
    let toolName: String
    let timestamp: Date
    let action: String
}

struct AITool: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: ToolCategory
    let url: String
    let tags: [String]
}

enum ToolCategory: String, CaseIterable {
    case language = "大语言模型"
    case image = "AI 图像绘画"
    case video = "AI 视频制作"
    case autonomous = "智能体/Agent"
    case infrastructure = "基础设施/MaaS"
    case code = "编程/开发"
    case skillMarket = "技能市场"

    var icon: String {
        switch self {
        case .language: return "message.fill"
        case .image: return "paintpalette.fill"
        case .video: return "video.fill"
        case .autonomous: return "brain.head.profile"
        case .infrastructure: return "cloud.fill"
        case .code: return "terminal.fill"
        case .skillMarket: return "square.grid.2x2.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .language: return Color(hex: "#00E5CC")
        case .image: return Color(hex: "#BF5AF2")
        case .video: return Color(hex: "#FF4D6D")
        case .autonomous: return Color(hex: "#FFD60A")
        case .infrastructure: return Color(hex: "#0A84FF")
        case .code: return Color(hex: "#30D158")
        case .skillMarket: return Color(hex: "#FF9500")
        }
    }
}

// MARK: - AgentStore

@MainActor
class AgentStore: ObservableObject {

    // Global portal state
    @Published var networkStatus: Double = 0.98
    @Published var activeUsers: Int = 772480
    @Published var hotToolsUsed: Int = 14820
    @Published var toolLimit: Int = 100000
    @Published var isPortalLive: Bool = true
    @Published var trendingToolName: String = "正在分析全网 AI 活跃度..."
    @Published var naviHistory: [ToolLog] = []

    // Feed / News state
    @Published var pendingNews: [AINews] = []
    @Published var readNews: [AINews] = []
    @Published var isLoadingNews: Bool = false
    @Published var newsError: String? = nil

    // Tools state
    @Published var favoriteTools: Set<String> = [] {
        didSet { saveFavorites() }
    }
    let allTools: [AITool] = AITool.catalog

    private var timer: AnyCancellable?
    private var newsIndex = 0

    let newsPhrases: [String] = [
        "OpenClaw 平台活跃 Agent 突破 77 万...",
        "DeepSeek 思考模型推理能力全球领先...",
        "Manus 通用智能体开启全自动任务规划...",
        "OpenClaw AI 升级：推理速度提升 30%...",
        "AI 代理实现可穿戴设备血氧预警...",
        "SiliconFlow 提供 200+ 开源模型接口...",
        "Kimi 智能助手月度访问突破千万...",
        "Claude 4 Opus 代码生成再度进化...",
        "Luma Dream Machine 视频生成质量飞跃...",
        "OpenRouter 全球模型聚合平台更新..."
    ]

    // MARK: - Favorites Persistence

    private let favoritesKey = "lobster_favorite_tools"

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteTools = saved
        } else {
            favoriteTools = ["open_claw", "deep_seek", "manus_ai"]
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteTools) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    // MARK: - Init

    init() {
        loadFavorites()
        seedNaviHistory()
        startSimulation()
        // Load cloud news
        Task {
            await loadNews()
        }
    }

    // MARK: - News

    func loadNews() async {
        isLoadingNews = true
        newsError = nil

        let cloudNews = await NewsService.shared.fetchLatestNews()

        if cloudNews.isEmpty {
            // Fallback to mock data if network fails and no cache
            if pendingNews.isEmpty {
                seedMockNews()
            }
            newsError = "无法连接云端，显示本地数据"
        } else {
            withAnimation(.spring()) {
                pendingNews = cloudNews
                readNews = []
            }
        }

        isLoadingNews = false
    }

    func refreshNews() async {
        await loadNews()
    }

    // MARK: - Simulation

    func startSimulation() {
        timer = Timer.publish(every: 3.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        withAnimation(.easeInOut(duration: 0.8)) {
            networkStatus = Double.random(in: 0.9...0.99)
            activeUsers = activeUsers + Int.random(in: 10...150)
            hotToolsUsed = min(hotToolsUsed + Int.random(in: 5...25), toolLimit)
        }
        newsIndex = (newsIndex + 1) % newsPhrases.count
        withAnimation(.easeIn(duration: 0.4)) {
            trendingToolName = newsPhrases[newsIndex]
        }
    }

    // MARK: - News Actions

    func markAsRead(_ news: AINews) {
        if let idx = pendingNews.firstIndex(where: { $0.id == news.id }) {
            var updated = pendingNews[idx]
            updated.isRead = true
            withAnimation(.spring()) {
                pendingNews.remove(at: idx)
                readNews.insert(updated, at: 0)
            }
        }
    }

    // MARK: - Tools

    func toggleFavorite(_ toolId: String) {
        withAnimation(.spring(response: 0.35)) {
            if favoriteTools.contains(toolId) {
                favoriteTools.remove(toolId)
            } else {
                favoriteTools.insert(toolId)
            }
        }
    }

    // MARK: - Seeds

    private func seedMockNews() {
        pendingNews = [
            AINews(title: "OpenClaw 平台活跃突破 77 万", description: "随着生态迅速扩张，平台公布了最新的安全风险评估与系统升级方案。 ", category: "生态报告", timestamp: Date().addingTimeInterval(-1800)),
            AINews(title: "AI 代理实现血氧异常预警", description: "OpenClaw AI 代理成功集成健康监测功能，能够实时分析并预警血氧异常。", category: "技术突破", timestamp: Date().addingTimeInterval(-3600)),
            AINews(title: "OpenClaw AI Agent 重大升级", description: "新版本推理速度提升 30%，多模态调度能力显著增强。", category: "版本更新", timestamp: Date().addingTimeInterval(-7200)),
            AINews(title: "DeepSeek 当前最火的国产模型", description: "强化 Agent 能力，融入思考推理，引领国产大模型进入 2.0 时代。", category: "模型热点", timestamp: Date().addingTimeInterval(-10800))
        ]
    }

    private func seedNaviHistory() {
        let items = [
            ("OpenClaw", "官方访问"),
            ("DeepSeek", "模型调研"),
            ("Manus AI", "计划执行"),
            ("SiliconFlow", "接口同步"),
            ("ClawHub", "技能拉取"),
        ]
        naviHistory = items.enumerated().map { i, item in
            ToolLog(toolName: item.0, timestamp: Date().addingTimeInterval(Double(-(i+1) * 3600)), action: item.1)
        }
    }
}

// MARK: - AITool Catalog

extension AITool {
    static let catalog: [AITool] = [
        // Autonomous
        AITool(id: "open_claw", name: "OpenClaw", description: "开源、本地优先的自主 AI 助手，支持全自动任务处理。", icon: "sparkles", category: .autonomous, url: "https://openclaw.ai", tags: ["官方", "核心"]),
        AITool(id: "manus_ai", name: "Manus", description: "通用型 AI 智能体，具备从任务规划到执行的全流程自动化能力。", icon: "brain.head.profile", category: .autonomous, url: "https://manus.ai", tags: ["极客", "高智"]),
        AITool(id: "devin_ai", name: "Devin", description: "全球首位 AI 软件工程师，能够独立完成编程任务并学习新技术。", icon: "terminal.fill", category: .autonomous, url: "https://www.cognition-labs.com", tags: ["工程师", "黑科技"]),
        AITool(id: "mule_run", name: "MuleRun", description: "全球首个自进化个人 AI，实时学习用户习惯与偏好。", icon: "bolt.fill", category: .autonomous, url: "https://mule.run", tags: ["自进化", "私人"]),

        // Language
        AITool(id: "deep_seek", name: "DeepSeek", description: "强化 Agent 能力，融入思考推理，国产大模型之光。", icon: "sparkles", category: .language, url: "https://www.deepseek.com", tags: ["热门", "国产"]),
        AITool(id: "kimi_assistant", name: "Kimi (Moonshot)", description: "擅长超长上下文处理与视觉推理，长文本理解行业领先。", icon: "moon.fill", category: .language, url: "https://kimi.moonshot.cn", tags: ["长文本", "无损"]),
        AITool(id: "gpt_openai", name: "GPT (OpenAI)", description: "具备原生计算机使用能力，引领行业标准的旗舰模型。", icon: "sparkles", category: .language, url: "https://chatgpt.com", tags: ["标杆", "全能"]),

        // Infrastructure
        AITool(id: "silicon_flow", name: "硅基流动 (SiliconFlow)", description: "提供 200+ 开源模型的统一 API 接口，性能稳定成本低。", icon: "cloud.fill", category: .infrastructure, url: "https://siliconflow.cn", tags: ["开发者", "MaaS"]),
        AITool(id: "open_router", name: "OpenRouter", description: "全球模型聚合平台，支持一键切换不同模型并按需付费。", icon: "network", category: .infrastructure, url: "https://openrouter.ai", tags: ["全聚合", "API"]),
        AITool(id: "aliyun_bailian", name: "阿里云百炼", description: "企业级大模型服务平台，整合阿里系最强 AI 能力。", icon: "cloud.sun.fill", category: .infrastructure, url: "https://bailian.aliyun.com", tags: ["企业级", "稳定"]),

        // Skill Market
        AITool(id: "claw_hub", name: "ClawHub", description: "OpenClaw 官方技能市场，海量自动化工作流下载。", icon: "square.grid.2x2.fill", category: .skillMarket, url: "https://openclaw.ai/hub", tags: ["官方", "生态"]),
        AITool(id: "skill_hub_tx", name: "SkillHub (腾讯云)", description: "专为中国用户优化的本地化技能平台，响应迅速。", icon: "bolt.horizontal.circle.fill", category: .skillMarket, url: "https://skillhub.tencent.com", tags: ["本地化", "高效"]),

        // Video & Image
        AITool(id: "runway_video", name: "Runway", description: "领先的 AI 视频生成平台，支持生成、修剪与特效增强。", icon: "video.fill", category: .video, url: "https://runwayml.com", tags: ["视频", "创作"]),
        AITool(id: "midjourney_art", name: "Midjourney", description: "顶级 AI 绘画平台，艺术感与画质行业标杆。", icon: "paintpalette.fill", category: .image, url: "https://midjourney.com", tags: ["艺术", "标杆"]),
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }
}
