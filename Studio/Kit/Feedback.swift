import SwiftUI
import UIKit

/// A comment pinned on a screen. Stored in `Feedback/feedback.json` at the project root so
/// Claude can read it (with the annotated screenshot in `Feedback/images/`).
struct FeedbackComment: Codable, Identifiable, Equatable {
    enum Status: String, Codable {
        case draft, sent, resolved
    }

    var id: String
    var createdAt: Date
    var screenID: String
    var screenName: String
    /// Most specific slot under the pin, if any.
    var slotPath: String?
    var x: Double
    var y: Double
    /// Variants that were on screen when the comment was made.
    var selections: [String: String]
    var device: String
    var appearance: String
    var text: String
    /// Path relative to the Feedback folder.
    var image: String?
    var status: Status
    /// Claude's answer, written into the JSON when the comment is handled.
    var reply: String?
    /// The selected element, like a Figma layer: kind ("Bouton", "Texte", "Composant", "Slot"…),
    /// its name/label, its path from the screen, and its frame [x, y, width, height] in phone points.
    var elementKind: String?
    var elementName: String?
    var elementPath: String?
    var elementFrame: [Double]?

    var elementRect: CGRect? {
        guard let f = elementFrame, f.count == 4 else { return nil }
        return CGRect(x: f[0], y: f[1], width: f[2], height: f[3])
    }
}

/// A selectable element on a phone: a slot, a tagged component, or an accessibility
/// leaf (button, text, image…) discovered automatically.
struct ElementInfo: Equatable {
    var kind: String
    var name: String
    var frame: CGRect

    var shortName: String {
        let last = name.split(separator: "/").last.map(String.init) ?? name
        return last.count > 40 ? String(last.prefix(38)) + "…" : last
    }

    var title: String { kind == "Écran" ? name : "\(kind) · \(shortName)" }
}

/// Where the user clicked, before the text is typed.
struct CommentDraft {
    let screenID: String
    let screenName: String
    let point: CGPoint
    let slotPath: String?
    let selections: [String: String]
    let snapshot: UIImage?
    /// From the whole screen down to the deepest element under the click.
    let chain: [ElementInfo]
    /// Which element of the chain the comment is about (defaults to the deepest).
    var selectedIndex: Int

    var element: ElementInfo? { chain.indices.contains(selectedIndex) ? chain[selectedIndex] : nil }
    var elementPath: String { chain.prefix(selectedIndex + 1).map(\.shortName).joined(separator: " › ") }
}

enum FeedbackFiles {
    /// <project>/Feedback — derived from this source file's location (Studio/Kit/Feedback.swift).
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Feedback")
    static let json = root.appendingPathComponent("feedback.json")
    static let images = root.appendingPathComponent("images")
    /// One line appended per "send to Claude" — watched by Claude's session.
    static let sentLog = root.appendingPathComponent("sent.log")

    static func load() -> [FeedbackComment] {
        guard let data = try? Data(contentsOf: json) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([FeedbackComment].self, from: data)) ?? []
    }

    static func save(_ comments: [FeedbackComment]) {
        try? FileManager.default.createDirectory(at: images, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        if let data = try? encoder.encode(comments) {
            try? data.write(to: json, options: .atomic)
        }
    }

    static func modificationDate() -> Date? {
        (try? FileManager.default.attributesOfItem(atPath: json.path))?[.modificationDate] as? Date
    }

    static func appendSentLine(_ line: String) {
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let data = Data((line + "\n").utf8)
        if let handle = try? FileHandle(forWritingTo: sentLog) {
            handle.seekToEndOfFile()
            handle.write(data)
            try? handle.close()
        } else {
            try? data.write(to: sentLog)
        }
    }

    /// Screenshot of the phone with a numbered pin drawn at the comment location.
    static func annotate(_ image: UIImage, at point: CGPoint, element: CGRect?, number: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size, format: {
            let format = UIGraphicsImageRendererFormat()
            format.scale = image.scale
            return format
        }())
        return renderer.image { _ in
            image.draw(at: .zero)
            var point = point
            if let element {
                UIColor.systemRed.setStroke()
                let outline = UIBezierPath(roundedRect: element.insetBy(dx: -2, dy: -2), cornerRadius: 4)
                outline.lineWidth = 3
                outline.stroke()
                point = CGPoint(x: max(element.minX, 16), y: max(element.minY, 16))
            }
            let radius: CGFloat = 16
            let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            UIColor.systemRed.setFill()
            UIBezierPath(ovalIn: rect).fill()
            UIColor.white.setStroke()
            let ring = UIBezierPath(ovalIn: rect.insetBy(dx: 1.5, dy: 1.5))
            ring.lineWidth = 3
            ring.stroke()
            let label = "\(number)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.white,
            ]
            let size = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2), withAttributes: attributes)
        }
    }
}

/// Lets the SwiftUI side reach the phone's hosting view to take a snapshot.
final class PhoneCapture {
    weak var view: UIView?

    /// Scrolls the screen's main scroll view so `rect` (in phone points) is centered in view.
    func scrollIntoView(_ rect: CGRect) {
        guard let view else { return }
        var scrollViews: [UIScrollView] = []
        func collect(_ v: UIView) {
            if let scroll = v as? UIScrollView,
               scroll.contentSize.height + scroll.adjustedContentInset.top + scroll.adjustedContentInset.bottom > scroll.bounds.height + 1,
               scroll.bounds.width >= view.bounds.width * 0.8 {
                scrollViews.append(scroll)
            }
            v.subviews.forEach(collect)
        }
        collect(view)
        // The vertical scroll view that contains the target (biggest first).
        guard let scroll = scrollViews
            .max(by: { $0.contentSize.height < $1.contentSize.height }) else { return }
        let target = scroll.convert(rect, from: view)
        let inset = scroll.adjustedContentInset
        let visible = scroll.bounds.height - inset.top - inset.bottom
        let minY = -inset.top
        let maxY = max(minY, scroll.contentSize.height - scroll.bounds.height + inset.bottom)
        let y = min(max(target.midY - inset.top - visible / 2, minY), maxY)
        scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: y), animated: false)
    }
    private var cachedLeaves: [ElementInfo] = []
    private var cachedAt = Date.distantPast

    /// Buttons, texts, images… read from the accessibility tree SwiftUI builds for the screen.
    func leaves() -> [ElementInfo] {
        if Date().timeIntervalSince(cachedAt) < 0.5 { return cachedLeaves }
        guard let view, let window = view.window else { return [] }
        var result: [ElementInfo] = []
        func walk(_ object: NSObject, depth: Int) {
            guard depth < 40 else { return }
            if object !== view, object.isAccessibilityElement {
                let inWindow = window.convert(object.accessibilityFrame, from: window.screen.coordinateSpace)
                let frame = view.convert(inWindow, from: window)
                if frame.width > 0, frame.height > 0 {
                    result.append(ElementInfo(kind: Self.kind(for: object.accessibilityTraits), name: object.accessibilityLabel ?? "", frame: frame))
                }
            }
            if let children = object.accessibilityElements as? [NSObject], !children.isEmpty {
                children.forEach { walk($0, depth: depth + 1) }
            } else if case let count = object.accessibilityElementCount(), count != NSNotFound, count > 0 {
                for index in 0..<count {
                    if let child = object.accessibilityElement(at: index) as? NSObject { walk(child, depth: depth + 1) }
                }
            } else if let uiView = object as? UIView, !object.isAccessibilityElement {
                // NavigationStack / TabView content lives in nested UIKit views.
                for subview in uiView.subviews where !subview.isHidden && subview.alpha > 0.01 {
                    walk(subview, depth: depth + 1)
                }
            }
        }
        walk(view, depth: 0)
        cachedLeaves = result
        cachedAt = Date()
        return result
    }

    private static func kind(for traits: UIAccessibilityTraits) -> String {
        if traits.contains(.button) { return "Bouton" }
        if traits.contains(.link) { return "Lien" }
        if traits.contains(.adjustable) { return "Contrôle" }
        if traits.contains(.image) { return "Icône" }
        if traits.contains(.header) { return "Titre" }
        if traits.contains(.staticText) { return "Texte" }
        return "Élément"
    }

    func snapshot() -> UIImage? {
        guard let view, view.bounds.width > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
        return UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
