# Animal Wellness Action — iOS App (starter project)

A native SwiftUI app that syncs live content from **animalwellnessaction.org**
using WordPress's built-in REST API (`/wp-json/wp/v2/`) — no separate backend
needed.

## What it does

- **News tab**: fetches the latest posts/press releases directly from the
  site, with infinite scroll, pull-to-refresh, search, and a detail view that
  renders each article's full HTML content (including images) natively.
- **Take Action / About / Donate tabs**: load the corresponding live pages
  from the site in an embedded web view, so forms, donation processing, and
  any future site changes stay in sync automatically without an app update.

## Setup (you'll need a Mac with Xcode 16+)

1. Open **Xcode** → **File → New → Project**.
2. Choose **iOS → App**, click Next.
3. Product Name: `AnimalWellnessAction`
   Organization Identifier: `org.animalwellnessaction`
   (this produces the Bundle ID `org.animalwellnessaction.app` — the one
   you already registered in the Apple Developer portal)
   Interface: **SwiftUI**, Language: **Swift**
4. Save it anywhere — this creates a new project folder with a default
   `AnimalWellnessActionApp.swift` and `ContentView.swift`.
5. **Delete** the default `ContentView.swift` Xcode generated.
6. Drag the `Models`, `Services`, and `Views` folders from this delivered
   project into your new Xcode project's file navigator (check
   "Copy items if needed" and "Create groups").
7. Replace the default `AnimalWellnessActionApp.swift` Xcode generated with
   the one included here (or just paste its contents in).
8. Build and run (⌘R) on a simulator or your device.

## File overview

```
AnimalWellnessAction/
├── AnimalWellnessActionApp.swift     — app entry point
├── Models/
│   └── WPModels.swift                — Codable structs matching WP JSON
├── Services/
│   ├── WordPressAPI.swift            — networking (posts, pages, media, search)
│   └── PostsViewModel.swift          — pagination/search state for the News tab
└── Views/
    ├── RootTabView.swift             — tab bar shell
    ├── PostListView.swift            — News tab list + search
    ├── PostDetailView.swift          — full article view
    ├── HTMLContentView.swift         — renders WP HTML content natively
    └── WebPageView.swift             — embedded web view for site pages
```

## Things to double check before shipping

- **Confirm the REST API is reachable**: visit
  `https://animalwellnessaction.org/wp-json/wp/v2/posts` in a browser. If it
  returns JSON, you're good. If a security plugin (e.g. Wordfence,
  Cloudflare bot protection) blocks it, you'll need to allowlist the API
  path or the app's user agent.
- **Tab URLs**: I guessed `/campaigns`, `/what-we-do`, and `/donate` as the
  Take Action / About / Donate pages based on the site's known structure —
  confirm these are still the right slugs and swap the URLs in
  `RootTabView.swift` if not.
- **App icon & launch screen**: not included — add a 1024x1024 icon in
  Assets.xcassets before submitting to App Store Connect.
- **Custom domain vs subpages**: if any tab should link to an external form
  provider (e.g. a separate petition or donation platform), just swap that
  tab's `url:` value.

## Optional next steps

- Add push notifications for new posts (would need a small server-side
  piece, e.g. a WordPress plugin that pings a push service on publish).
- Cache posts locally (e.g. with SwiftData) for offline reading.
- Add a "Categories" filter using `/wp-json/wp/v2/categories`.
