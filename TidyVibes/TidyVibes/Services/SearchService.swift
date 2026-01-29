import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let item: Item
    let score: Double
}

class SearchService {
    static let shared = SearchService()

    // Common synonyms for household items
    private let synonyms: [String: [String]] = [
        "scissors": ["shears", "cutting tool"],
        "charger": ["cable", "cord", "usb"],
        "pen": ["pencil", "marker", "writing"],
        "tape": ["adhesive", "sticky"],
        "batteries": ["battery", "cells"],
        "keys": ["key", "keychain"],
        "headphones": ["earbuds", "earphones", "airpods"]
    ]

    func search(query: String, in items: [Item]) -> [SearchResult] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)

        var results: [SearchResult] = []

        for item in items {
            let score = calculateMatchScore(query: normalizedQuery, itemName: item.name.lowercased())
            if score > 0 {
                results.append(SearchResult(item: item, score: score))
            }
        }

        return results.sorted { $0.score > $1.score }
    }

    private func calculateMatchScore(query: String, itemName: String) -> Double {
        // Exact match
        if itemName == query { return 1.0 }

        // Contains match
        if itemName.contains(query) { return 0.9 }

        // Synonym match
        for (key, synonymList) in synonyms {
            if (key == query || synonymList.contains(query)) &&
               (key == itemName || synonymList.contains(where: { itemName.contains($0) })) {
                return 0.8
            }
        }

        // Levenshtein distance for typos
        let distance = levenshteinDistance(query, itemName)
        let maxLength = max(query.count, itemName.count)
        let similarity = 1.0 - (Double(distance) / Double(maxLength))

        if similarity > 0.7 {
            return similarity * 0.7
        }

        return 0
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)
        var dist = [[Int]](repeating: [Int](repeating: 0, count: s2.count + 1), count: s1.count + 1)

        for i in 0...s1.count { dist[i][0] = i }
        for j in 0...s2.count { dist[0][j] = j }

        for i in 1...s1.count {
            for j in 1...s2.count {
                if s1[i-1] == s2[j-1] {
                    dist[i][j] = dist[i-1][j-1]
                } else {
                    dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + 1)
                }
            }
        }

        return dist[s1.count][s2.count]
    }
}
