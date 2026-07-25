# Website Sync Features

This document describes how the Animal Wellness Action app stays in sync with the website.

## Automatic Sync Features

### 1. **Background Auto-Refresh (News Tab)**
- News articles automatically refresh every 5 minutes while the app is running
- Happens silently in the background without disrupting the user
- Ensures users always see the latest content

### 2. **App Activation Sync**
- When the app becomes active (user returns from background), content refreshes if it's more than 2 minutes old
- Keeps content fresh without excessive API calls

### 3. **Pull-to-Refresh**
- Users can manually refresh by pulling down on the news list
- Immediately fetches the latest articles from the website

### 4. **Last Updated Indicator**
- Shows "Updated X ago" in the navigation bar
- Users can see how recent their content is

### 5. **Live Web Content**
All non-news tabs load content directly from the website:
- **Home Tab**: animalwellnessaction.org (main website)
- **Take Action Tab**: /campaigns page
- **About Tab**: /what-we-do page  
- **Donate Tab**: /donate page

These tabs:
- Always show the current website content
- Include a refresh button to reload the page
- Use cache-busting to prevent stale content
- All forms, buttons, and links work exactly as on the website

## How Content Stays Fresh

### News Articles (Native API)
1. Initial load when opening the app
2. Auto-refresh every 5 minutes
3. Refresh when app becomes active (if stale)
4. Manual pull-to-refresh
5. Infinite scroll pagination for older articles

### Website Pages (Embedded WebView)
1. Fresh load every time you switch to the tab
2. Manual refresh button in navigation bar
3. No caching - always gets latest version
4. All website updates appear immediately

## Benefits

✅ **Always Up-to-Date**: Content syncs automatically without user action
✅ **Real-Time Website Changes**: Web pages show updates immediately
✅ **Offline Graceful**: News articles remain viewable even when offline
✅ **Battery Efficient**: Smart refresh timing prevents excessive API calls
✅ **User Control**: Pull-to-refresh and refresh buttons for manual updates

## Technical Details

- News uses WordPress REST API (`/wp-json/wp/v2/posts`)
- Web pages use WKWebView with cache policy set to `.reloadIgnoringLocalAndRemoteCacheData`
- Background refresh uses `Timer` with 300-second intervals
- App lifecycle monitoring via `@Environment(\.scenePhase)`
