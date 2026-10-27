import SwiftUI

struct InspectorView: View {
    @Environment(StudioStore.self) private var store
    @State private var copied = false

    var body: some View {
        if let screen = store.selectedScreen {
            let slots = store.slots[screen.id] ?? []
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(screen.info.name).font(.title3.bold())
                        Text(screen.info.flow).font(.subheadline).foregroundStyle(.secondary)
                        if !screen.info.notes.isEmpty {
                            Text(screen.info.notes).font(.callout).padding(.top, 4)
                        }
                    }
                }

                Section("Slots") {
                    if slots.isEmpty {
                        Text("No open questions on this screen.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(slots) { slot in
                        SlotRow(screenID: screen.id, slot: slot)
                    }
                }

                let screenComments = store.comments.filter { $0.screenID == screen.id }
                if !screenComments.isEmpty {
                    Section("Retours") {
                        ForEach(screenComments.sorted { ($0.status == .resolved ? 1 : 0, $0.createdAt) < ($1.status == .resolved ? 1 : 0, $1.createdAt) }) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                }

                Section {
                    Button(copied ? "Copied" : "Copy selection for Claude", systemImage: copied ? "checkmark" : "doc.on.doc") {
                        UIPasteboard.general.string = store.summary(for: screen)
                        copied = true
                        Task { try? await Task.sleep(for: .seconds(1.5)); copied = false }
                    }
                    Button("Reset variants", systemImage: "arrow.counterclockwise") {
                        store.resetSelections(for: screen.id)
                    }
                    .disabled(slots.isEmpty)
                    Button("Open source file", systemImage: "chevron.left.forwardslash.chevron.right") {
                        UIApplication.shared.open(URL(fileURLWithPath: screen.info.file))
                    }
                }
            }
            .onChange(of: store.selectedScreenID) {
                store.selectedSlotPath = nil
                store.hoveredSlotPath = nil
            }
        } else {
            ContentUnavailableView("No screen selected", systemImage: "iphone")
        }
    }
}

private struct SlotRow: View {
    let screenID: String
    let slot: SlotInfo
    @Environment(StudioStore.self) private var store

    var body: some View {
        let isFocused = store.selectedSlotPath == slot.path
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: slot.depth > 0 ? "arrow.turn.down.right" : "square.dashed")
                    .foregroundStyle(.secondary)
                Text(slot.name).font(.headline)
                Spacer()
                Text("\((slot.variants.firstIndex(of: slot.selected) ?? 0) + 1)/\(slot.variants.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            FlowLayout(spacing: 6) {
                ForEach(slot.variants, id: \.self) { variant in
                    let isOn = variant == slot.selected
                    Button {
                        store.select(variant, slot: slot.path, in: screenID)
                        store.selectedSlotPath = slot.path
                    } label: {
                        Text(variant)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(isOn ? Color.white : Color.primary)
                            .background(Capsule().fill(isOn ? Color.accentColor : Color(uiColor: .tertiarySystemFill)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.leading, CGFloat(slot.depth) * 14)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { store.selectedSlotPath = isFocused ? nil : slot.path }
        .onHover { store.hoveredSlotPath = $0 ? slot.path : nil }
        .listRowBackground(isFocused ? Color.accentColor.opacity(0.12) : nil)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        return CGSize(width: rows.width, height: rows.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(width: bounds.width, subviews: subviews)
        for (index, point) in rows.origins.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> (origins: [CGPoint], width: CGFloat, height: CGFloat) {
        var origins: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxX = max(maxX, x - spacing)
        }
        return (origins, maxX, y + rowHeight)
    }
}

private struct CommentRow: View {
    let comment: FeedbackComment
    @Environment(StudioStore.self) private var store

    var body: some View {
        let isResolved = comment.status == .resolved
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Text("\(store.pinNumber(of: comment))")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(isResolved ? Color.gray : comment.status == .draft ? .orange : .red))
                VStack(alignment: .leading, spacing: 3) {
                    Text(comment.text)
                        .strikethrough(isResolved)
                        .foregroundStyle(isResolved ? .secondary : .primary)
                    Text([comment.elementPath ?? comment.slotPath, statusLabel].compactMap { $0 }.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 4)
                Menu {
                    if comment.status != .resolved {
                        Button("Marquer comme traité", systemImage: "checkmark") { store.setStatus(.resolved, for: comment.id) }
                    } else {
                        Button("Rouvrir", systemImage: "arrow.uturn.backward") { store.setStatus(.sent, for: comment.id) }
                    }
                    Button("Supprimer", systemImage: "trash", role: .destructive) { store.deleteComment(comment.id) }
                } label: {
                    Image(systemName: "ellipsis.circle").foregroundStyle(.secondary)
                }
                .fixedSize()
            }
            if let reply = comment.reply, !reply.isEmpty {
                Label(reply, systemImage: "sparkles")
                    .font(.callout)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onHover { store.focusedCommentID = $0 ? comment.id : nil }
    }

    private var statusLabel: String {
        switch comment.status {
        case .draft: "Brouillon"
        case .sent: "Envoyé à Claude"
        case .resolved: "Traité"
        }
    }
}
