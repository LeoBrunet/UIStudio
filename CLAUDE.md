# UI Studio

A Figma-like Mac Catalyst canvas for designing iOS screens in real SwiftUI.
The user asks for screens in chat; Claude writes the SwiftUI; the user browses and picks variants in the app.
The user never edits in the app — all changes go through code.

## Projects

The app hosts several projects; the top-bar menu (⌃⌘1, ⌃⌘2…) switches between them, and the canvas/sidebar show only the current one's screens. A screen picks its project with `ScreenInfo(…, project: "UI Studio", …)`; without it, it belongs to **Coach** (the default). Put a project's screens in their own folder under `Screens/` (e.g. `Screens/UIStudio/`) and prefix their type names to avoid clashes (`StudioLogo…`).

- **UI Studio** — branding of the tool itself. `Screens/UIStudio/StudioLogoScreen.swift`: macOS icon, Dock, wordmark, small sizes; slots Concept / Couleurs / Grille.
  `Screens/UIStudio/StudioTopBarScreen.swift`: static mockups of the app's top bar (slot « Barre »), each in a full macOS window at 1:1. The chosen « Îlot + mode » is the real toolbar: `FloatingToolbar` + `ModeSwitch` in `Studio/UI/RootView.swift` (old `TopBar` kept there as v1, unused). The chosen logo (Calques · Indigo · grille) is the app icon in `Studio/Assets.xcassets/AppIcon.appiconset` (rendered from `StudioLogoArt`).

## Current project: multisport coach app (French UI)

- The coach is Claude, running **in the Claude app** on the user's Pro plan via our MCP connector ("option B"). Our app has **no in-app chat**: it shows program/sessions/Health data and hands off to Claude with `CoachButton` ("S'ouvre dans l'app Claude").
- Multisport (course, vélo, natation, renfo); sessions recorded by Apple Watch, read via HealthKit. No music.
- Shared models + mock data: `Screens/Coach/CoachMock.swift` (`Sport`, `Mock`, `Fmt`). Training components (`IntensityBar`, `DSRing`, `DSMetricTile`, `CoachButton`, `DSChip`, `Color.dsZone`) in `DesignKit/TrainingComponents.swift`.

## Loop

1. Edit/add files in `Screens/` (and `DesignKit/` if needed).
2. Run `./studio.sh` — incremental build (~2–5 s) + relaunch. Canvas state (selection, zoom, device, chosen variants) is restored.
   - On `BUILD FAILED` the script prints the errors grouped by file; full log in `.build/failed-build.log`. Fix and rerun before replying.
   - `./studio.sh build` builds without relaunching.
   - The app runs from `/Applications/UI Studio.app`: each relaunch copies the fresh build there first (`STUDIO_INSTALL=0 ./studio.sh` runs straight from `.build`).
3. Tell the user what changed and which slots/variants to look at.

## Layout

- `Screens/` — one file per screen, grouped in folders by flow. `Screens/ScreenRegistry.swift` is **generated** by `studio.sh` (every `struct X: StudioScreen` under `Screens/`) — never edit it; a new screen file shows up on the next build.
- `DesignKit/` — tokens (`DS.Spacing`, `DS.Radius`, `Color.ds*`, `Font.ds*`) and components (`.dsPrimary`/`.dsSecondary`/`.dsGhost` button styles, `DSTextField`, `.dsCard()`, `DSAvatar`, `DSTag`, `DSSectionHeader`). Screens use tokens, not raw values. Add a component here once it's used by 2+ screens.
- `Studio/` — the canvas app itself (Kit = slot system/store, UI = chrome). Only touch when changing the tool.
- `Export/` — clean, Xcode-ready files (not compiled into the app).
- Folders are Xcode synchronized groups: new files are picked up automatically, never edit the `.pbxproj` to add files.

## Writing a screen

```swift
struct ProfileScreen: StudioScreen {
    static let info = ScreenInfo("Profile", flow: "Main", order: 650, notes: "optional")
    var body: some View { ... }   // normal SwiftUI; NavigationStack/TabView/toolbar all work
}
```

- Mac UI: `ScreenInfo(…, frame: .mac(width: 1200, height: 760))` draws the screen in a macOS window (no bezel/status bar, regular size class) instead of the iPhone picked in the top bar. Draw the traffic lights and toolbar yourself, at Mac sizes (toolbar 52 pt, controls 24 pt, 13 pt text).
- `order` sets the display position: flows are sorted by their lowest screen order, screens within a flow by order then name. Existing screens use 100, 200 … 1200; pick a value in between to slot a screen in, or omit it to land at the end.
- The phone provides real safe areas, compact size class and light/dark — don't fake a status bar or add top padding for it.
- Target iOS 17+ APIs. Use placeholder content that looks real (names, numbers), SF Symbols for icons.

## Slots & variants (open design questions)

```swift
Slot("Header") {
    Variant("Minimal") { ... }
    Variant("Big title") { ... }
    Variant.hidden            // compare with/without
}
```

- A slot can wrap anything (whole screen, a section, one button) and can be nested inside a variant — nested slots only show in the inspector when their parent variant is active.
- Slot names are unique among siblings; selections are stored by slot path + variant **name**, so renaming a variant resets that choice.
- Add slots when the user asks for options.
- **Never delete anything the user can see** (variants, sections, screens) when they ask for a change. Keep the previous version as a variant (suffix " (v1)" when renaming helps), put the newly requested/chosen version **first** so it becomes the default, and use `Variant.hidden` first when the user says a section isn't needed. "Lock in" = make the chosen variant first/default, not remove the others.
- Top bar "Variants" mode (⌘⇧V) shows the selected screen's current version plus every variant per slot ("Per slot") or every top-level combination ("All combinations", capped at 24). Clicking a phone picks it.
- **Validating** (user, in the app): the ✓ button on a slot in the inspector validates its current variant — the slot collapses to that choice, its other proposals disappear from Variants mode, and « Rouvrir » / « Tout rouvrir » brings them back. Nothing is removed from the code. Picks and validated slots are mirrored to `Feedback/choices.json` (`{screenID: {selections, validated}}`; a slot missing from `selections` is on its first variant) — read it when the user says they made their choices. Don't add new variants to a validated slot unless asked; when the user asks for changes to it, put the new version first and tell them to reopen the slot to compare.
- **States are not variants.** When the options are different states of the same screen (steps of a flow, empty/filled, loading/error, planned/done…), use `States("Étape") { ScreenState("1 · …") { … } }` instead of `Slot`/`Variant`. Same nesting and selection storage, but they sit in the inspector's « États » section (outlined chips, no ✓), are left out of design comparisons, and Variants mode has an « États » view showing them side by side (shown automatically when the screen has no open design question). Never validate or "lock in" a state; design `Slot`s can live inside a `ScreenState`.
- Inspector "Copy selection for Claude" produces e.g. `- Form: Card` / `- Form/Card style: Elevated`.

## Export ("lock in" / "export")

Produce a clean file in `Export/`: the chosen variants inlined, no `Slot`/`Variant`/`StudioScreen`/`ScreenInfo`, a plain `struct XView: View` plus `#Preview`. It may depend on `DesignKit/` — tell the user to copy that folder too (once). The `Screens/` file keeps all its slots and variants.

## Gotchas

- The app chrome deliberately avoids NavigationSplitView/NavigationStack: a UIKit nav container around the phones would swallow the screens' navigation bars.
- Each phone is its own `UIHostingController` (`PhoneHost`); environment from the canvas does not flow in — pass values through `PhoneView`'s `root`.
- Sheets/full-screen covers presented from a screen currently present over the whole window, not inside the phone.
- Dynamic Type cannot be previewed: Mac Catalyst ignores it (`.body`, `relativeTo:`, `@ScaledMetric` all stay fixed). Check text sizes in the iOS Simulator instead.
- Chrome is responsive: below ~1150 iOS pt the inspector floats, below ~910 the sidebar floats (toggle buttons in the top bar); the top bar falls back to icon-only controls via `ViewThatFits`.

## Feedback (comments pinned in the app)

- In the app, "Commenter" (⇧⌘C) → hover outlines the element under the pointer (Figma-like) → click selects it (the composer shows the layer path; clicking a parent widens the selection) → type → comments pile up as drafts → "Envoyer à Claude" sends them.
- Selectable elements = accessibility leaves found automatically (buttons, texts, icons…) + `Slot`s + views tagged with `.studioComponent("Nom")`. **Tag every meaningful container you write** (cards, rows, sections, custom components) so the user can select it; DesignKit components tag themselves.
- Stored in `Feedback/feedback.json` (+ annotated screenshot `Feedback/images/<id>.png` with a numbered red pin). Each comment has `screenName`, `elementKind`/`elementName`/`elementPath`/`elementFrame` (the selected layer), `slotPath` (most specific slot under the pin), `x`/`y` (phone points), `selections` (variants on screen), `text`, `status` (`draft` | `sent` | `resolved`), `reply`.
- "Envoyer à Claude" appends a line to `Feedback/sent.log` (`… SENT n comment(s): id1,id2`). Watch it with Monitor: `tail -n 0 -F Feedback/sent.log` (re-arm on expiry), or only your screen's comments with `./feedback-watch.sh "<screen name>"` (see Parallel sessions).
- Handling: read every `sent` comment and **look at its image**, apply the change (following the never-delete rule above), rebuild, then set `status: "resolved"` and a short French `reply` in the JSON (keep the formatting: sorted keys, ISO dates). The app reloads the JSON within 2 s and shows the reply in the inspector.

## Parallel sessions

Several Claude sessions may work in this folder at the same time, each on different screens. It is not a git repo, so there is no isolation besides these rules:

- **One owner per screen.** Only edit the files of the screen(s) you were given (`Screens/<Flow>/<X>Screen.swift`, plus new files you create for them). Leave other screens alone even if they look broken.
- **Never edit `Screens/ScreenRegistry.swift`** — it is regenerated before every build.
- **New shared components** go in a new file named after your screen, e.g. `DesignKit/TodayComponents.swift` — tell the user you created it. It is compiled into the Coach iOS app too, so keep it DesignKit-only (no `Studio/` or `Screens/` types).
- **Existing DesignKit files and the shared mock data (`Screens/Coach/CoachMock*.swift`)**: one session at a time. Prefer adding new types/extensions in your own file; if you must change an existing one, keep the change small and additive (don't rename or change signatures others use) and mention it to the user.
- **Building**: just run `./studio.sh`. Builds queue behind a lock (`Waiting for another build…` is normal) and the app relaunches once at the end of a burst (`Relaunch left to the next queued build` is normal). The build compiles everyone's files: if `BUILD FAILED` lists only files you don't own, another session is mid-edit — wait a few seconds and rerun rather than touching their files; tell the user if it persists.
- **Your feedback only**: run Monitor on `./feedback-watch.sh "<your screen name>"` (case-insensitive substring of `screenName`). It prints `<id> <screenName>: <text>` for each matching sent comment; handle those ids only. When writing `status`/`reply` into `Feedback/feedback.json`, re-read the file right before writing and change only your comments' fields, since other sessions write to it too.
