import SwiftUI

struct PantryCookScreen: StudioScreen {
    static let info = ScreenInfo("Cook mode", project: Pantry.project, flow: "Cook", order: 300,
                                 notes: "One step at a time, readable from a distance, with a timer.")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            progress
            Slot("Step") {
                Variant("Big text") { bigText }
                Variant("Card + timer") { cardWithTimer }
            }
            Spacer()
            controls
        }
        .padding(20)
        .background(Pantry.cream)
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "xmark").font(.headline)
                Spacer()
                Text("Step 3 of 6").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "list.bullet").font(.headline)
            }
            HStack(spacing: 4) {
                ForEach(0..<6) { index in
                    Capsule().fill(index < 3 ? Pantry.green : Color.black.opacity(0.1)).frame(height: 4)
                }
            }
        }
        .studioComponent("Progress")
    }

    private var bigText: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Glaze the salmon")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Pantry.green)
            Text("Brush the miso glaze over the fillets and roast for 12 minutes, until the top caramelizes.")
                .font(.system(size: 30, weight: .semibold, design: .serif))
            Label("12:00", systemImage: "timer")
                .font(.title3.monospacedDigit().weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white, in: Capsule())
        }
        .padding(.top, 20)
        .studioComponent("Step text")
    }

    private var cardWithTimer: some View {
        VStack(spacing: 18) {
            PantryPhoto(recipe: Pantry.recipes[0], symbolSize: 50)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text("Brush the miso glaze over the fillets and roast for 12 minutes.")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            ZStack {
                Circle().stroke(Color.black.opacity(0.08), lineWidth: 10)
                Circle().trim(from: 0, to: 0.35).stroke(Pantry.green, style: StrokeStyle(lineWidth: 10, lineCap: .round)).rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("7:48").font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                    Text("remaining").font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(width: 150, height: 150)
        }
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .studioComponent("Step card")
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Label("Back", systemImage: "chevron.left")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white, in: Capsule())
            Label("Next step", systemImage: "chevron.right")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Pantry.green, in: Capsule())
        }
        .studioComponent("Step controls")
    }
}
