//
//  PostDetailView.swift
//  AnimalWellnessAction
//

import SwiftUI

struct PostDetailView: View {
    let post: WPPost

    @State private var contentHeight: CGFloat = 200
    @State private var featuredImageURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let featuredImageURL {
                    AsyncImage(url: featuredImageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.15)
                    }
                    .frame(height: 220)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(post.plainTitle)
                        .font(.title2.bold())
                    Text(post.displayDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                HTMLContentView(html: post.content.rendered, dynamicHeight: $contentHeight)
                    .frame(height: contentHeight)
                    .padding(.horizontal)

                ShareLink(item: URL(string: post.link) ?? URL(string: "https://animalwellnessaction.org")!) {
                    Label("Share this article", systemImage: "square.and.arrow.up")
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let mediaId = post.featuredMediaId, mediaId != 0 {
                featuredImageURL = try? await WordPressAPI.shared.fetchFeaturedImageURL(mediaId: mediaId)
            }
        }
    }
}
