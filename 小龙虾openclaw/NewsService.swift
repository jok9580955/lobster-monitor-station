//
//  NewsService.swift
//  龙虾AI导航 — Cloud News Service
//

import Foundation

// MARK: - API Response Model

struct NewsAPIResponse: Codable {
    let version: Int
    let updated: String
    let news: [NewsItem]
}

struct NewsItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let url: String?
    let timestamp: String

    /// Convert to app's AINews model
    func toAINews() -> AINews {
        let date = ISO8601DateFormatter().date(from: timestamp) ?? Date()
        return AINews(
            remoteId: id,
            title: title,
            description: description,
            category: category,
            timestamp: date,
            url: url
        )
    }
}

// MARK: - News Service

@MainActor
class NewsService {

    static let shared = NewsService()

    private let apiURL = "https://jok9580955.github.io/lobster-monitor-station/api/news.json"
    private let cacheKey = "lobster_cached_news"
    private let cacheTimeKey = "lobster_cache_time"

    /// Fetch latest news from GitHub Pages, with local cache fallback
    func fetchLatestNews() async -> [AINews] {
        // Try network first
        if let news = await fetchFromNetwork() {
            cacheNews(news)
            return news
        }

        // Fallback to cache
        if let cached = loadCachedNews() {
            return cached
        }

        // Final fallback: empty
        return []
    }

    // MARK: - Network

    private func fetchFromNetwork() async -> [AINews]? {
        guard let url = URL(string: apiURL + "?t=\(Int(Date().timeIntervalSince1970))") else {
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)
            return apiResponse.news.map { $0.toAINews() }
        } catch {
            print("[NewsService] Network fetch failed: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Cache

    private func cacheNews(_ news: [AINews]) {
        let items = news.map { n in
            CachedNewsItem(
                remoteId: n.remoteId ?? n.id.uuidString,
                title: n.title,
                description: n.description,
                category: n.category,
                timestamp: n.timestamp.timeIntervalSince1970,
                url: n.url
            )
        }
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: cacheTimeKey)
        }
    }

    private func loadCachedNews() -> [AINews]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let items = try? JSONDecoder().decode([CachedNewsItem].self, from: data) else {
            return nil
        }
        return items.map { item in
            AINews(
                remoteId: item.remoteId,
                title: item.title,
                description: item.description,
                category: item.category,
                timestamp: Date(timeIntervalSince1970: item.timestamp),
                url: item.url
            )
        }
    }

    /// Clear all cached news data
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
    }
}

// MARK: - Cache Model

private struct CachedNewsItem: Codable {
    let remoteId: String
    let title: String
    let description: String
    let category: String
    let timestamp: Double
    let url: String?
}
