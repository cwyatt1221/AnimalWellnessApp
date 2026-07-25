//
//  WebPageView.swift
//  AnimalWellnessAction
//
//  Loads a live page from animalwellnessaction.org directly. Used for
//  sections where showing the real site is simpler/more reliable than
//  rebuilding the page natively (e.g. Take Action forms, Donate).
//

import SwiftUI
import WebKit

struct WebPageView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}

struct WebPageScreen: View {
    let title: String
    let url: URL

    var body: some View {
        WebPageView(url: url)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
