//
//  HTMLContentView.swift
//  AnimalWellnessAction
//
//  Renders a WordPress "rendered" HTML string natively (no full page load,
//  just the article content — including images) using WKWebView, with a
//  height that grows to fit the content instead of scrolling internally.
//

import SwiftUI
import WebKit

struct HTMLContentView: UIViewRepresentable {
    let html: String
    @Binding var dynamicHeight: CGFloat

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let styledHTML = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: -apple-system, sans-serif;
            font-size: 17px;
            line-height: 1.5;
            color: #1c1c1e;
            margin: 0;
            padding: 0;
          }
          img { max-width: 100%; height: auto; border-radius: 8px; }
          a { color: #0a7d3e; }
        </style>
        </head>
        <body>\(html)</body>
        </html>
        """
        webView.loadHTMLString(styledHTML, baseURL: URL(string: "https://animalwellnessaction.org"))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: HTMLContentView
        init(_ parent: HTMLContentView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { height, _ in
                if let height = height as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.dynamicHeight = height
                    }
                }
            }
        }

        // Open outbound links (e.g. "Donate", "Take Action" links) in Safari
        // instead of hijacking the in-app content view.
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
