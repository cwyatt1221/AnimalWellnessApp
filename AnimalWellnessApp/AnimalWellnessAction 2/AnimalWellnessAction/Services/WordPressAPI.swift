//
//  WordPressAPI.swift
//  AnimalWellnessAction
//
//  Thin client for the site's WordPress REST API.
//  Docs: https://developer.wordpress.org/rest-api/reference/
//

import Foundation

enum WordPressAPIError: Error {
    case badURL
    case badResponse
}

final class WordPressAPI {
    static let shared = WordPressAPI()

    /// Change this if the site ever moves. No trailing slash.
    private let baseURL = "https://animalwellnessaction.org/wp-json/wp/v2"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    /// Fetch the latest posts (press releases / news), newest first.
    /// - Parameters:
    ///   - page: 1-based page number for pagination.
    ///   - perPage: how many posts per page (WordPress default max is 100).
    func fetchPosts(page: Int = 1, perPage: Int = 20) async throws -> [WPPost] {
        guard var components = URLComponents(string: "\(baseURL)/posts") else {
            throw WordPressAPIError.badURL
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "orderby", value: "date"),
            URLQueryItem(name: "order", value: "desc")
        ]
        guard let url = components.url else { throw WordPressAPIError.badURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        try Self.validate(response)
        return try decoder.decode([WPPost].self, from: data)
    }

    /// Fetch a single static page by its numeric WordPress ID.
    func fetchPage(id: Int) async throws -> WPPage {
        guard let url = URL(string: "\(baseURL)/pages/\(id)") else {
            throw WordPressAPIError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        try Self.validate(response)
        return try decoder.decode(WPPage.self, from: data)
    }

    /// Fetch the URL for a post's featured image, if it has one.
    func fetchFeaturedImageURL(mediaId: Int) async throws -> URL? {
        guard let url = URL(string: "\(baseURL)/media/\(mediaId)") else {
            throw WordPressAPIError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        try Self.validate(response)
        let media = try decoder.decode(WPMedia.self, from: data)
        return URL(string: media.sourceUrl)
    }

    /// Search posts by keyword (uses WordPress's built-in ?search= param).
    func searchPosts(query: String) async throws -> [WPPost] {
        guard var components = URLComponents(string: "\(baseURL)/posts") else {
            throw WordPressAPIError.badURL
        }
        components.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "per_page", value: "30")
        ]
        guard let url = components.url else { throw WordPressAPIError.badURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        try Self.validate(response)
        return try decoder.decode([WPPost].self, from: data)
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw WordPressAPIError.badResponse
        }
    }
}
