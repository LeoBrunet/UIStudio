import SwiftUI

struct SidebarView: View {
    @Environment(StudioStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(store.project)
                .font(.headline)
                .padding(.horizontal, 16)
                .frame(height: 48)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(store.flows, id: \.name) { flow in
                        Text(flow.name.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.top, 14)
                            .padding(.bottom, 4)
                        ForEach(flow.screens) { screen in
                            row(screen)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            Spacer(minLength: 0)
            if let builtAt = store.builtAt {
                Text("Built \(builtAt.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(16)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }

    private func row(_ screen: ScreenEntry) -> some View {
        let isSelected = store.selectedScreenID == screen.id
        // Proposals left to look at: variants of open design slots (states and validated slots don't count).
        let slotCount = (store.slots[screen.id] ?? [])
            .filter { !$0.isState && !store.isValidated($0.path, in: screen.id) }
            .reduce(0) { $0 + $1.variants.count }
        return Button {
            store.selectedScreenID = screen.id
            store.scrollTarget = screen.id
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "iphone")
                    .foregroundStyle(isSelected ? .white : .secondary)
                Text(screen.info.name)
                Spacer()
                if slotCount > 0 {
                    Text("\(slotCount)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : .clear, in: RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
