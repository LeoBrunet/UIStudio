import SwiftUI

/// Canvas state. Everything except `slots` is persisted so a rebuild + relaunch
/// lands exactly where you were.
@MainActor @Observable
final class StudioStore {
    var selectedScreenID: String? { didSet { save() } }
    /// Current project: the canvas and sidebar only show its screens.
    var project: String { didSet { save() } }
    /// Last selected screen per project, restored when switching back.
    private var lastScreenByProject: [String: String] = [:]
    var selectedSlotPath: String?
    var hoveredSlotPath: String?
    /// Set to scroll the canvas to a screen (e.g. when picked in the sidebar).
    var scrollTarget: String?
    var zoom: Double { didSet { save() } }
    var deviceID: String { didSet { save() } }
    var appearance: Appearance { didSet { save() } }
    var showInspector: Bool { didSet { save() } }
    var showSidebar: Bool { didSet { save() } }
    /// Variants mode: the canvas shows every variant of the selected screen.
    var compareMode: Bool { didSet { save() } }
    var compareStyle: CompareStyle { didSet { save() } }
    /// Screen id -> (slot path -> variant name)
    var selections: [String: [String: String]] { didSet { save(); writeChoices() } }
    /// Screen id -> slot paths the user validated: only the chosen variant is shown,
    /// the other proposals are hidden (never deleted) until the slot is reopened.
    var validated: [String: Set<String>] { didSet { save(); writeChoices() } }

    /// Slots currently rendered by each screen (reported by the phones, not persisted).
    var slots: [String: [SlotInfo]] = [:]

    // MARK: Feedback (comments pinned on screens)

    /// Comment mode: clicking a phone pins a comment instead of interacting with it.
    var commentMode = false
    var draft: CommentDraft?
    var comments: [FeedbackComment] = FeedbackFiles.load()
    var focusedCommentID: String?
    private var commentsLoadedAt = FeedbackFiles.modificationDate()

    var draftComments: [FeedbackComment] { comments.filter { $0.status == .draft } }

    func openComments(for screenID: String) -> [FeedbackComment] {
        comments.filter { $0.screenID == screenID && $0.status != .resolved }
    }

    /// Pin number shown on the phone and in the inspector (stable per screen).
    func pinNumber(of comment: FeedbackComment) -> Int {
        (comments.filter { $0.screenID == comment.screenID }.firstIndex { $0.id == comment.id } ?? 0) + 1
    }

    var nextPinNumber: Int {
        guard let draft else { return 1 }
        return comments.filter { $0.screenID == draft.screenID }.count + 1
    }

    /// Moves the draft's target up/down the element chain (like selecting a parent layer).
    func selectDraftElement(_ index: Int) {
        guard var draft, draft.chain.indices.contains(index) else { return }
        draft.selectedIndex = index
        self.draft = draft
    }

    func beginComment(_ draft: CommentDraft) {
        selectedScreenID = draft.screenID
        self.draft = draft
    }

    func addComment(text: String) {
        guard let draft, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let id = String(UUID().uuidString.prefix(8)).lowercased()
        var imagePath: String?
        if let snapshot = draft.snapshot {
            let annotated = FeedbackFiles.annotate(snapshot, at: draft.point, element: draft.element?.frame, number: nextPinNumber)
            try? FileManager.default.createDirectory(at: FeedbackFiles.images, withIntermediateDirectories: true)
            let url = FeedbackFiles.images.appendingPathComponent("\(id).png")
            if let data = annotated.pngData(), (try? data.write(to: url)) != nil {
                imagePath = "images/\(id).png"
            }
        }
        comments.append(FeedbackComment(
            id: id,
            createdAt: Date(),
            screenID: draft.screenID,
            screenName: draft.screenName,
            slotPath: draft.slotPath,
            x: Double(draft.point.x.rounded()),
            y: Double(draft.point.y.rounded()),
            selections: draft.selections,
            device: deviceID,
            appearance: appearance.rawValue,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            image: imagePath,
            status: .draft,
            reply: nil,
            elementKind: draft.element?.kind,
            elementName: draft.element?.name,
            elementPath: draft.elementPath,
            elementFrame: draft.element.map { [$0.frame.minX, $0.frame.minY, $0.frame.width, $0.frame.height].map { Double($0.rounded()) } }
        ))
        self.draft = nil
        persistComments()
    }

    func sendDrafts() {
        let ids = draftComments.map(\.id)
        guard !ids.isEmpty else { return }
        for index in comments.indices where comments[index].status == .draft {
            comments[index].status = .sent
        }
        persistComments()
        FeedbackFiles.appendSentLine("\(ISO8601DateFormatter().string(from: Date())) SENT \(ids.count) comment(s): \(ids.joined(separator: ","))")
    }

    func setStatus(_ status: FeedbackComment.Status, for id: String) {
        guard let index = comments.firstIndex(where: { $0.id == id }) else { return }
        comments[index].status = status
        persistComments()
    }

    func deleteComment(_ id: String) {
        if let comment = comments.first(where: { $0.id == id }), let image = comment.image {
            try? FileManager.default.removeItem(at: FeedbackFiles.root.appendingPathComponent(image))
        }
        comments.removeAll { $0.id == id }
        persistComments()
    }

    /// Picks up replies/status changes Claude writes into feedback.json.
    func reloadCommentsIfChanged() {
        let date = FeedbackFiles.modificationDate()
        guard date != commentsLoadedAt else { return }
        commentsLoadedAt = date
        comments = FeedbackFiles.load()
    }

    private func persistComments() {
        FeedbackFiles.save(comments)
        commentsLoadedAt = FeedbackFiles.modificationDate()
    }

    /// Registry order is file order (generated); display order comes from `ScreenInfo.order`.
    let allScreens: [ScreenEntry] = {
        let all = ScreenRegistry.all
        var flowOrder: [String: Int] = [:]
        for screen in all { flowOrder[screen.info.flow] = min(flowOrder[screen.info.flow] ?? .max, screen.info.order) }
        return all.sorted {
            let (a, b) = ($0.info, $1.info)
            if a.flow != b.flow {
                let (fa, fb) = (flowOrder[a.flow]!, flowOrder[b.flow]!)
                return fa != fb ? fa < fb : a.flow < b.flow
            }
            return a.order != b.order ? a.order < b.order : a.name < b.name
        }
    }()
    var screens: [ScreenEntry] { allScreens.filter { $0.info.project == project } }

    /// Default project first, then the others by name.
    var projects: [String] {
        let names = Set(allScreens.map(\.info.project))
        return names.sorted { a, b in
            a == ScreenInfo.defaultProject || (b != ScreenInfo.defaultProject && a < b)
        }
    }

    func switchProject(to name: String) {
        guard name != project else { return }
        if let selectedScreenID { lastScreenByProject[project] = selectedScreenID }
        compareMode = false
        project = name
        let remembered = lastScreenByProject[name]
        selectedScreenID = screens.contains { $0.id == remembered } ? remembered : screens.first?.id
        scrollTarget = selectedScreenID
    }

    let builtAt: Date? = {
        guard let url = Bundle.main.executableURL else { return nil }
        return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date
    }()

    var device: Device { Device.named(deviceID) }

    /// The frame a screen is drawn in: the picked iPhone, unless the screen asks for a Mac window.
    func device(for screen: ScreenEntry) -> Device {
        switch screen.info.frame {
        case .iPhone: device
        case let .mac(width, height): .macWindow(width: width, height: height)
        }
    }
    var selectedScreen: ScreenEntry? { allScreens.first { $0.id == selectedScreenID } }

    var flows: [(name: String, screens: [ScreenEntry])] {
        var order: [String] = []
        var grouped: [String: [ScreenEntry]] = [:]
        for screen in screens {
            if grouped[screen.info.flow] == nil { order.append(screen.info.flow) }
            grouped[screen.info.flow, default: []].append(screen)
        }
        return order.map { ($0, grouped[$0]!) }
    }

    func select(_ variant: String, slot path: String, in screenID: String) {
        selections[screenID, default: [:]][path] = variant
    }

    func isValidated(_ path: String, in screenID: String) -> Bool {
        validated[screenID]?.contains(path) ?? false
    }

    /// Validates the slot's current variant (recorded explicitly so it survives reordering in code).
    func validate(_ slot: SlotInfo, in screenID: String) {
        selections[screenID, default: [:]][slot.path] = slot.selected
        validated[screenID, default: []].insert(slot.path)
    }

    func reopen(_ path: String, in screenID: String) {
        validated[screenID]?.remove(path)
        if validated[screenID]?.isEmpty == true { validated[screenID] = nil }
    }

    func reopenAll(in screenID: String) {
        validated[screenID] = nil
    }

    func resetSelections(for screenID: String) {
        selections[screenID] = nil
    }

    /// Human-readable summary of the chosen variants, meant to be pasted to Claude.
    func summary(for screen: ScreenEntry) -> String {
        let slots = slots[screen.id] ?? []
        guard !slots.isEmpty else { return "\(screen.info.name): no slots" }
        let lines = slots.map { "- \($0.path): \($0.selected)" + ($0.isState ? " (état)" : isValidated($0.path, in: screen.id) ? " (validé)" : "") }
        return "\(screen.info.name) (\(screen.info.flow))\n" + lines.joined(separator: "\n")
    }

    // MARK: Persistence

    private struct Saved: Codable {
        var selectedScreenID: String?
        var project: String?
        var lastScreenByProject: [String: String]?
        var zoom: Double
        var deviceID: String
        var appearance: String
        var showInspector: Bool
        var showSidebar: Bool?
        var compareMode: Bool?
        var compareStyle: String?
        var selections: [String: [String: String]]
        var validated: [String: [String]]?
    }

    private static let key = "studio.state"
    private var loading = true

    init() {
        let saved = UserDefaults.standard.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(Saved.self, from: $0) }
        let savedID = saved?.selectedScreenID
        let savedProject = saved?.project ?? ScreenInfo.defaultProject
        let current = allScreens.contains { $0.info.project == savedProject } ? savedProject : ScreenInfo.defaultProject
        project = current
        lastScreenByProject = saved?.lastScreenByProject ?? [:]
        let inProject = allScreens.filter { $0.info.project == current }
        selectedScreenID = inProject.contains { $0.id == savedID } ? savedID : inProject.first?.id
        zoom = saved?.zoom ?? 0.6
        deviceID = saved?.deviceID ?? Device.all[0].id
        appearance = saved.flatMap { Appearance(rawValue: $0.appearance) } ?? .light
        showInspector = saved?.showInspector ?? true
        showSidebar = saved?.showSidebar ?? true
        compareMode = saved?.compareMode ?? false
        compareStyle = saved?.compareStyle.flatMap(CompareStyle.init(rawValue:)) ?? .perSlot
        selections = saved?.selections ?? [:]
        validated = (saved?.validated ?? [:]).mapValues(Set.init)
        loading = false
    }

    private func save() {
        guard !loading else { return }
        let state = Saved(
            selectedScreenID: selectedScreenID, project: project, lastScreenByProject: lastScreenByProject, zoom: zoom, deviceID: deviceID,
            appearance: appearance.rawValue,
            showInspector: showInspector, showSidebar: showSidebar, compareMode: compareMode, compareStyle: compareStyle.rawValue,
            selections: selections,
            validated: validated.mapValues { $0.sorted() }
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    /// Mirrors the picked variants and validated slots to `Feedback/choices.json` so Claude can read them.
    private func writeChoices() {
        guard !loading else { return }
        var out: [String: [String: Any]] = [:]
        for id in Set(selections.keys).union(validated.keys) {
            out[id] = ["selections": selections[id] ?? [:], "validated": (validated[id] ?? []).sorted()]
        }
        if let data = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]) {
            try? data.write(to: FeedbackFiles.root.appendingPathComponent("choices.json"), options: .atomic)
        }
    }
}

enum CompareStyle: String, CaseIterable, Identifiable {
    case perSlot = "Per slot"
    case combinations = "All combinations"
    /// Every state of the screen side by side (`States`), not a design comparison.
    case states = "États"
    var id: String { rawValue }
}
