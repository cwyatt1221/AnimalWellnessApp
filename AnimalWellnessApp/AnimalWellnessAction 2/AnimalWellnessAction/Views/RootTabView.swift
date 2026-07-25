//
//  RootTabView.swift
//  AnimalWellnessAction
//
//  Root tab bar. News is fully native (fetched via WP REST API).
//  Take Action / Donate load the live site so forms and payment
//  processing always match what's on animalwellnessaction.org.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            PostListView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }

            NavigationStack {
                WebPageScreen(
                    title: "Take Action",
                    url: URL(string: "https://animalwellnessaction.org/campaigns")!
                )
            }
            .tabItem {
                Label("Take Action", systemImage: "megaphone")
            }

            NavigationStack {
                WebPageScreen(
                    title: "About",
                    url: URL(string: "https://animalwellnessaction.org/what-we-do")!
                )
            }
            .tabItem {
                Label("About", systemImage: "pawprint")
            }

            NavigationStack {
                WebPageScreen(
                    title: "Donate",
                    url: URL(string: "https://animalwellnessaction.org/donate")!
                )
            }
            .tabItem {
                Label("Donate", systemImage: "heart")
            }
        }
    }
}

#Preview {
    RootTabView()
}
