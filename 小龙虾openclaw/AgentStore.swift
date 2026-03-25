//
//  AgentStore.swift
//  龙虾监测站 — Global Data Model
//

import SwiftUI
import Combine

// MARK: - Models

struct AgentAlert: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let riskLevel: RiskLevel
    let timestamp: Date
    var status: AlertStatus = .pending

    enum RiskLevel: String {
        case low = "低风险"
        case medium = "中风险"
        case high = "高风险"

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return Color.orange
            case .high: return Color(hex: "#FF4D6D")
            }
        }
    }

    enum AlertStatus {
        case pending, approved, rejected, paused
    }
}

struct TaskLog: Identifiable {
    let id = UUID()
    let step: String
    let timestamp: Date
    let duration: String
}

struct SkillPlugin: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: SkillCategory
    let permissions: [String]
}

enum SkillCategory: String, CaseIterable {
    case factory = "工厂/制造"
    case medical = "医药健康"
    case culture = "文化传统"
    case ecommerce = "电商"
    case finance = "财务"
    case general = "通用"

    var icon: String {
        switch self {
        case .factory: return "gearshape.2.fill"
        case .medical: return "cross.case.fill"
        case .culture: return "book.closed.fill"
        case .ecommerce: return "cart.fill"
        case .finance: return "chart.pie.fill"
        case .general: return "sparkles"
        }
    }

    var accentColor: Color {
        switch self {
        case .factory: return Color(hex: "#FF9500")
        case .medical: return Color(hex: "#30D158")
        case .culture: return Color(hex: "#BF5AF2")
        case .ecommerce: return Color(hex: "#00E5CC")
        case .finance: return Color(hex: "#FFD60A")
        case .general: return Color(hex: "#0A84FF")
        }
    }
}

// MARK: - AgentStore

@MainActor
class AgentStore: ObservableObject {

    // Dashboard state
    @Published var cpuUsage: Double = 0.32
    @Published var gpuUsage: Double = 0.18
    @Published var tokenUsed: Int = 4820
    @Published var tokenLimit: Int = 16000
    @Published var isAgentRunning: Bool = true
    @Published var currentTaskText: String = "正在初始化龙虾Agent..."
    @Published var taskHistory: [TaskLog] = []

    // Intervention state
    @Published var pendingAlerts: [AgentAlert] = []
    @Published var resolvedAlerts: [AgentAlert] = []

    // Skills state
    @Published var installedSkills: Set<String> = ["smt_order", "web_summary", "price_compare"]
    let allSkills: [SkillPlugin] = SkillPlugin.catalog

    private var timer: AnyCancellable?
    private var cotIndex = 0

    let cotPhrases: [String] = [
        "正在比价机票 DAL→PVG...",
        "正在分析 SMT 贴片订单数据...",
        "正在抓取竞品价格信息...",
        "正在生成供应链优化报告...",
        "正在核对药品库存与有效期...",
        "正在查询《菜根谭》相关典故...",
        "正在识别并分类上传发票...",
        "正在追踪物流信息 SF-9087654...",
        "正在汇总客户评价情感分析...",
        "正在规划明日工作日程...",
        "正在执行网页内容摘要提取...",
        "等待用户授权支付操作..."
    ]

    init() {
        seedMockAlerts()
        seedTaskHistory()
        startSimulation()
    }

    // MARK: - Simulation

    func startSimulation() {
        timer = Timer.publish(every: 2.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        withAnimation(.easeInOut(duration: 0.8)) {
            cpuUsage = Double.random(in: 0.18...0.88)
            gpuUsage = Double.random(in: 0.05...0.72)
            tokenUsed = min(tokenUsed + Int.random(in: 50...350), tokenLimit)
        }
        cotIndex = (cotIndex + 1) % cotPhrases.count
        withAnimation(.easeIn(duration: 0.4)) {
            currentTaskText = cotPhrases[cotIndex]
        }
    }

    // MARK: - Intervention Actions

    func approve(_ alert: AgentAlert) {
        resolve(alert, status: .approved)
    }

    func reject(_ alert: AgentAlert) {
        resolve(alert, status: .rejected)
    }

    func pause(_ alert: AgentAlert) {
        resolve(alert, status: .paused)
    }

    private func resolve(_ alert: AgentAlert, status: AgentAlert.AlertStatus) {
        if let idx = pendingAlerts.firstIndex(where: { $0.id == alert.id }) {
            var resolved = pendingAlerts[idx]
            resolved.status = status
            withAnimation(.spring()) {
                pendingAlerts.remove(at: idx)
                resolvedAlerts.insert(resolved, at: 0)
            }
        }
    }

    // MARK: - Skills

    func toggleSkill(_ skillId: String) {
        withAnimation(.spring(response: 0.35)) {
            if installedSkills.contains(skillId) {
                installedSkills.remove(skillId)
            } else {
                installedSkills.insert(skillId)
            }
        }
    }

    // MARK: - Seeds

    private func seedMockAlerts() {
        pendingAlerts = [
            AgentAlert(
                title: "支付授权请求",
                description: "Agent 请求通过支付宝向「某供应商」付款 ¥12,800，用于采购SMT元器件。",
                riskLevel: .high,
                timestamp: Date().addingTimeInterval(-180)
            ),
            AgentAlert(
                title: "高频API调用告警",
                description: "过去5分钟内API调用次数达到 480次，超过阈值(300次/5min)。是否继续？",
                riskLevel: .medium,
                timestamp: Date().addingTimeInterval(-95)
            ),
            AgentAlert(
                title: "文件批量删除确认",
                description: "Agent 即将删除 /reports/2025_Q4/ 目录下共 234 个旧报告文件。",
                riskLevel: .high,
                timestamp: Date().addingTimeInterval(-40)
            ),
            AgentAlert(
                title: "外部邮件发送申请",
                description: "准备向客户列表发送营销邮件，共 1,240 名收件人。",
                riskLevel: .low,
                timestamp: Date().addingTimeInterval(-10)
            )
        ]
    }

    private func seedTaskHistory() {
        let items = [
            ("提取竞品价格数据", "2m 14s"),
            ("生成周度销售报表", "45s"),
            ("翻译产品说明书（EN→ZH）", "1m 03s"),
            ("更新库存预警规则", "22s"),
            ("抓取行业新闻摘要", "58s"),
        ]
        taskHistory = items.enumerated().map { i, item in
            TaskLog(step: item.0, timestamp: Date().addingTimeInterval(Double(-(i+1) * 600)), duration: item.1)
        }
    }
}

// MARK: - SkillPlugin Catalog

extension SkillPlugin {
    static let catalog: [SkillPlugin] = [
        // Factory
        SkillPlugin(id: "smt_order", name: "SMT订单管理", description: "自动追踪、解析SMT贴片工厂的订单状态与交货进度。", icon: "cpu.fill", category: .factory, permissions: ["文件读取", "网络请求"]),
        SkillPlugin(id: "inventory_alert", name: "库存预警", description: "实时监控原材料库存水位，低于阈值时自动告警并发起采购申请。", icon: "exclamationmark.triangle.fill", category: .factory, permissions: ["数据库读写", "推送通知"]),
        SkillPlugin(id: "supply_chain", name: "供应链优化", description: "分析供应商交货周期与成本，给出最优采购策略建议。", icon: "arrow.triangle.branch", category: .factory, permissions: ["网络请求", "数据分析"]),

        // Medical
        SkillPlugin(id: "drug_query", name: "药品查询", description: "查询药品说明书、适应症、禁忌及库存有效期信息。", icon: "pills.fill", category: .medical, permissions: ["网络请求"]),
        SkillPlugin(id: "patient_followup", name: "患者随访助手", description: "自动发送随访提醒，汇总患者反馈并生成报告。", icon: "person.crop.circle.badge.checkmark", category: .medical, permissions: ["推送通知", "联系人"]),

        // Culture
        SkillPlugin(id: "caigentan", name: "菜根谭语录", description: "每日推送《菜根谭》原文、注解与现代启示，传承传统智慧。", icon: "text.book.closed.fill", category: .culture, permissions: ["推送通知"]),
        SkillPlugin(id: "solar_terms", name: "传统节气", description: "基于二十四节气提供养生建议、农事提醒及文化典故。", icon: "sun.max.fill", category: .culture, permissions: ["位置(模糊)"]),
        SkillPlugin(id: "hanzi_origin", name: "汉字溯源", description: "分析汉字字形演变与文化含义，辅助内容创作与教育。", icon: "textformat.characters", category: .culture, permissions: ["网络请求"]),

        // Ecommerce
        SkillPlugin(id: "price_compare", name: "比价助手", description: "跨平台实时比较商品价格，追踪价格历史趋势。", icon: "tag.fill", category: .ecommerce, permissions: ["网络请求"]),
        SkillPlugin(id: "review_analysis", name: "评价分析", description: "对商品评论进行情感分析，提炼用户核心关切点。", icon: "star.bubble.fill", category: .ecommerce, permissions: ["网络请求", "数据分析"]),
        SkillPlugin(id: "logistics", name: "物流追踪", description: "聚合多家快递公司接口，统一追踪所有在途包裹。", icon: "shippingbox.fill", category: .ecommerce, permissions: ["网络请求"]),

        // Finance
        SkillPlugin(id: "bookkeeping", name: "记账助手", description: "自动归类账单，生成月度收支报表，支持多账户管理。", icon: "dollarsign.circle.fill", category: .finance, permissions: ["文件读取"]),
        SkillPlugin(id: "invoice_scan", name: "发票识别", description: "OCR识别纸质/电子发票，自动录入报销系统。", icon: "doc.text.viewfinder", category: .finance, permissions: ["相机", "文件读写"]),

        // General
        SkillPlugin(id: "web_summary", name: "网页摘要", description: "一键提取任意网页的核心内容，生成结构化摘要。", icon: "globe.badge.chevron.backward", category: .general, permissions: ["网络请求"]),
        SkillPlugin(id: "file_translate", name: "文件翻译", description: "批量翻译文档，支持PDF/Word/Excel，保留原始排版。", icon: "doc.badge.gearshape.fill", category: .general, permissions: ["文件读写"]),
        SkillPlugin(id: "schedule", name: "日程规划", description: "根据任务优先级和截止日期，自动编排最优工作日程。", icon: "calendar.badge.clock", category: .general, permissions: ["日历", "提醒事项"]),
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
