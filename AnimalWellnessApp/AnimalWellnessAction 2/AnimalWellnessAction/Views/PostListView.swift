//
//  PostListView.swift
//  AnimalWellnessAction
//

import SwiftUI

struct PostListView: View {
    @StateObject private var viewModel = PostsViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.posts.isEmpty && viewModel.isLoading {
                    ProgressView("Loading latest news…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.posts.isEmpty {
                    ContentUnavailableView(
                        "Couldn't Load News",
                        systemImage: "wifi.slash",
                        description: Text(error)
                    )
                } else {
                    List {
                        ForEach(viewModel.posts) { post in
                            NavigationLink(value: post) {
                                PostRow(post: post)
                            }
                            .task {
                                await viewModel.loadMoreIfNeeded(currentItem: post)
                            }
                        }
                        if viewModel.isLoading && !viewModel.posts.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { await viewModel.refresh() }
                }
            }
            .navigationTitle("News & Action")
            .searchable(text: $searchText, prompt: "Search articles")
            .onSubmit(of: .search) {
                Task { await viewModel.search(query: searchText) }
            }
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    Task { await viewModel.refresh() }
                }
            }
            .navigationDestination(for: WPPost.self) { post in
                PostDetailView(post: post)
            }
            .task {
                await viewModel.loadInitial()
            }
        }
    }
}

private struct PostRow: View {
    let post: WPPost

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(post.plainTitle)
                .font(.headline)
                .lineLimit(3)
            Text(post.plainExcerpt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(post.displayDate)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// Allows WPPost to be used directly as a NavigationLink value.
extension WPPost: Hashable {
    static func == (lhs: WPPost, rhs: WPPost) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

#Preview {
    PostListView()
}
