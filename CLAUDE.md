# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

PenTracker is a personal, local-only macOS SwiftUI app (SwiftData-backed) for tracking a fountain pen, ink, paper, and swatch collection. Bundle id `com.local.pentracker`, macOS 14+ deployment target, built with XcodeGen from `project.yml`. `INFOPLIST_KEY_NSHumanReadableCopyright` is literally "Personal use, local only".

Do not assume App Store or production constraints. There is no CloudKit sync, no multi-user support, and no external API. `README.md` covers features, the data model, keyboard shortcuts, and packaging.

## Build and verify

`project.yml` is the source of truth; `PenTracker.xcodeproj` is generated from it and checked into git.

**After adding or removing any file under `Sources/`, run `xcodegen generate` before building.** A new Swift file does not appear in the `.xcodeproj` on its own. Skipping this produces misleading `no exact matches` and `cannot find type` errors that look like real code bugs but are not.

```bash
xcodegen generate
xcodebuild -project PenTracker.xcodeproj -scheme PenTracker -configuration Debug build
```

`xcodegen` lives at `/opt/homebrew/bin/xcodegen`.

**SourceKit diagnostics are not a reliable verification signal here.** The single-file diagnostics reported on Edit and Write are noisy, and they emit false "cannot find type in scope" errors for cross-file symbols even when the code compiles. Confirm with a real `xcodebuild` run.

For UI-facing changes, exercise the actual app before calling the work done. The built app runs from the terminal, which lets you capture stdout and stderr:

```bash
<DerivedData>/Build/Products/Debug/PenTracker.app/Contents/MacOS/PenTracker > /tmp/log 2>&1 &
```

Interaction notes that save time: rapid batched clicks into Form text fields do not reliably transfer focus (click once, wait for a visible cursor or highlight, then type; Tab between fields is reliable once focus is established). Maximizing the window enters true macOS fullscreen and hides the menu bar, so hover the very top edge to reveal it. List row deletion via the Delete key or the right-click context menu did not work in this environment; the Edit menu's Delete command with the row selected did.

## macOS navigation gotcha

On macOS, a `NavigationSplitView` detail column does **not** implicitly provide a `NavigationStack` the way iPadOS does. A `navigationDestination(for:)` inside that column registers `NavigationLink(value:)` taps (the List row highlights) but never pushes, because there is no stack to push onto.

Any detail or content column hosting `navigationDestination(for:)` needs its own explicit `NavigationStack` wrapper. `Sources/PenTracker/App/ContentView.swift` line 14 is the working example. This bit the project once already (commit `c543bd3`), fixed by wrapping the `detail:` closure's `switch selection { ... }` content.

## Data safety

The collection store lives at `~/Library/Application Support/PenTracker/PenTracker.store` (SQLite, unsandboxed). It is shared by development and installed builds, so it holds the user's real personal collection. Read-only inspection with `sqlite3` is fine. Never write to it directly, and never point a scratch or test build at it. Clean up test data through the app's own UI.

`ModelContainer+PenTracker.swift` pins that path deliberately: without an explicit URL, SwiftData falls back to a generic `default.store` shared by any unsandboxed app on the machine, which another app can silently overwrite.

## Working style

Work a punch list one item at a time, in order, rather than batching. The user says "next" or "proceed" between items.

Each fix gets its own commit with a descriptive message. Do not squash.

After finishing one item: build it, verify it (a real build, plus exercising the UI for UI changes), commit it, then briefly state what is next and wait rather than continuing unprompted. When a defect is discovered rather than assigned, report it and ask before fixing it.

## History

The 2026-08-21 review session found and fixed 8 issues plus a pre-existing navigation bug, all with individual commits:

| Commit | Fix |
|---|---|
| `b934ab5` | Cascade-delete on Ink/Pen destroyed shared Inking history (`.nullify`) |
| `64da98c` | Rejected nonsensical negative-duration inkings |
| `89173bf` | Locale-sensitive price parsing (`Shared/Decimal+PriceText.swift`) |
| `208ba83` | `Color+Hex` accepted only 6-char hex |
| `426b3a2` | `ImagePickerButton` swallowed photo read errors silently |
| `e281f01` | `Inking.notes` was write-only and never displayed |
| `9a2d21a` | `Swatch` had no edit capability, unlike Pen/Ink/Paper |
| `dd01b93` | Deduplicated triplicated List/Edit/Detail views (`CollectionListView<Model>`, `PurchasableItem`, `PhotoSection`, `Date.abbreviated`) |
| `c543bd3` | Row-tap navigation never pushed the detail view |
