//
//  PostsViewModel.swift
//  AnimalWellnessAction
//

import Foundation

@MainActor
final class PostsViewModel: ObservableObject {
    @Published var posts: [WPPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private var canLoadMore = true

    func loadInitial() async {
        guard posts.isEmpty else { return }
        await refresh()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        canLoadMore = true
        do {
            let fetched = try await WordPressAPI.shared.fetchPosts(page: currentPage)
            posts = fetched
        } catch {
            errorMessage = "Couldn't load the latest posts. Pull to refresh to try again."
        }
        isLoading = false
    }

    /// Called when the list scrolls near the bottom to fetch the next page.
    func loadMoreIfNeeded(currentItem: WPPost) async {
        guard canLoadMore, !isLoading else { return }
        guard let last = posts.last, last.id == currentItem.id else { return }

        isLoading = true
        currentPage += 1
        do {
            let nextPage = try await WordPressAPI.shared.fetchPosts(page: currentPage)
            if nextPage.isEmpty {
                canLoadMore = false
            } else {
                posts.append(contentsOf: nextPage)
            }
        } catch {
            // Silently stop paginating on error; the user still has what loaded.
            canLoadMore = false
        }
        isLoading = false
    }

    func search(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            await refresh()
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            posts = try await WordPressAPI.shared.searchPosts(query: query)
        } catch {
            errorMessage = "Search failed. Check your connection and try again."
        }
        isLoading = false
    }
}
