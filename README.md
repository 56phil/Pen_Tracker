# PenTracker

A native macOS app for tracking a fountain pen collection: pens, inks, paper, and the swatches and inking history that tie them together.

Built with SwiftUI and SwiftData for macOS 14.0 and later.

## Features

- **Dashboard**: collection counts, total ink volume on hand, total tracked value, and a grid of currently inked pens with their ink and fill date.
- **Pens**: brand, model, color, nib/tip, filling mechanism, status, rating, purchase details, photo, and notes. The current ink is shown right on the list row.
- **Inks**: brand, line, color name, color swatch, package type (bottle/sample/cartridge), volume, quantity, and rating.
- **Paper**: brand, line, weight (gsm), color or finish, format, quantity, and rating.
- **Swatches**: ink on paper, date tested, rating, photo, and notes in a gallery grid.
- **Inking history**: record when a pen is filled with an ink and when it is emptied. An inking with no emptied date is the pen's current ink.
- **Four-level ratings**: Outstanding, Satisfactory, Barely Satisfactory, Unsatisfactory. Optional on every item.
- **Collection statuses**: Wishlist, In Rotation, Stored, Retired. Filter any list by status.
- **Keyboard-first navigation**: every GUI action is reachable from the keyboard (see below).

## Requirements

- macOS 14.0 or later
- Xcode 15 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- Swift 5

## Build from source

The Xcode project is generated from `project.yml`, which is the source of truth. Run XcodeGen after cloning, and again after adding or removing files:

```bash
xcodegen generate
open PenTracker.xcodeproj
```

Or build from the command line:

```bash
xcodegen generate
xcodebuild -project PenTracker.xcodeproj -scheme PenTracker -configuration Debug build
```

The app is ad-hoc signed (see `project.yml`: `CODE_SIGN_IDENTITY: "-"`) and runs locally without an Apple Developer account. Gatekeeper will not accept the binary; that is expected for a personal, locally built app.

## Build the DMG

```bash
./scripts/build-dmg.sh
```

Produces `dist/PenTracker.dmg` with a drag-to-Applications shortcut. Verify the image with:

```bash
hdiutil verify dist/PenTracker.dmg
```

## Install

Open the DMG and drag PenTracker into Applications, or from the command line:

```bash
hdiutil attach dist/PenTracker.dmg -nobrowse -mountpoint /tmp/pentracker_dmg
ditto /tmp/pentracker_dmg/PenTracker.app /Applications/PenTracker.app
hdiutil detach /tmp/pentracker_dmg
```

## Keyboard shortcuts

File-menu commands that dispatch to the most recently visible screen; they no-op safely when nothing matches.

| Shortcut | Action |
| --- | --- |
| ⌘E | Edit… the focused item |
| ⌘I | Ink This Pen… |
| ⌘⇧W | Swatch on Paper… |
| ⌘S | Save |
| Esc | Cancel |
| ⌘⇧⌫ | Delete… |
| ⌘[ | Back |

Additional navigation:

- Tab in the search field selects the first filtered row; arrow keys move the selection, Enter opens it, and clicking a row opens it directly.
- Tab walks detail fields (requires Full Keyboard Access: System Settings > Keyboard > Keyboard navigation).
- Arrow keys cycle the arrow-key pickers in forms.

## Data model

SwiftData models live in `Sources/PenTracker/Models/`:

- **Pen**, **Ink**, **Paper**, **Swatch**, **Inking**, each with optional rating, purchase info, photo, and notes where applicable.
- **Inking** links a Pen and an Ink with `filledDate` and `emptiedDate`.
- **Swatch** links an Ink and a Paper with `dateTested`.

## Data and storage

Collection data lives in a SwiftData store outside the app bundle:

```
~/Library/Application Support/PenTracker/PenTracker.store
```

The store is shared by development and installed builds, so your collection persists across rebuilds. Back this file up to protect your collection.

## Project layout

```
project.yml                  XcodeGen project spec (source of truth)
Sources/PenTracker/
  App/                       App entry, sidebar, navigation
  Features/                  Dashboard, Pens, Inks, Papers, Swatches, Inkings
  Models/                    SwiftData models and enums
  Persistence/               Model container and store URL
  Shared/                    Reusable components (keyboard layer, pickers, views)
scripts/
  build-dmg.sh               Release build and DMG packaging
  icon/                      App icon sources
```

## License

No license is declared; all rights reserved.
