//
//  WPModels.swift
//  AnimalWellnessAction
//
//  Codable models matching the default WordPress REST API JSON shape
//  (https://animalwellnessaction.org/wp-json/wp/v2/...)
//

import Foundation

/// A rendered text field WordPress returns as { "rendered": "..." }
struct RenderedField: Codable {
    let rendered: String
}

/// A single WordPress post (news, press releases, blog entries, etc.)
struct WPPost: Codable, Identifiable {
    let id: Int
    let date: String
    let link: String
    let title: RenderedField
    let excerpt: RenderedField
    let content: RenderedField
    let featuredMediaId: Int?

    enum CodingKeys: String, CodingKey {
        case id, date, link, title, excerpt, content
        case featuredMediaId = "featured_media"
    }

    var plainTitle: String {
        title.rendered.strippingHTML()
    }

    var plainExcerpt: String {
        excerpt.rendered.strippingHTML()
    }

    var displayDate: String {
        WPPost.isoFormatter.date(from: date).map {
            WPPost.displayFormatter.string(from: $0)
        } ?? date
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
}

/// A WordPress media object, used to resolve featured images.
struct WPMedia: Codable {
    let sourceUrl: String

    enum CodingKeys: String, CodingKey {
        case sourceUrl = "source_url"
    }
}

/// A static WordPress page (e.g. "What We Do", "About Us").
struct WPPage: Codable, Identifiable {
    let id: Int
    let link: String
    let title: RenderedField
    let content: RenderedField

    var plainTitle: String {
        title.rendered.strippingHTML()
    }
}

extension String {
    /// Very small helper to strip HTML tags and decode common entities
    /// from WordPress "rendered" fields for plain-text display (e.g. list rows).
    func strippingHTML() -> String {
        var result = self.replacingOccurrences(
            of: "<[^>]+>", with: "", options: .regularExpression
        )
        let entities: [String: String] = [
            "&amp;": "&", "&#8217;": "’", "&#8216;": "‘",
            "&#8220;": "“", "&#8221;": "”", "&#8211;": "–",
            "&#8212;": "—", "&nbsp;": " ", "&quot;": "\"", "&#039;": "'"
        ]
        for (key, value) in entities {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
