#if canImport(PaperKit)
import PaperKit
import Foundation

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView {

  func loadInitialData(_ base64String: String) {
    guard let data = Data(base64Encoded: base64String) else { return }
    do {
      let markup = try PaperMarkup(dataRepresentation: data)
      state.markup = markup
      state.viewController?.markup = markup
    } catch {
      NSLog("[ExpoPaperkit] Failed to load initial data: %@", error.localizedDescription)
    }
  }

  func save() async throws -> String {
    guard let markup = state.viewController?.markup ?? state.markup else {
      throw PaperkitError.noMarkupData
    }
    let data = try await markup.dataRepresentation()
    return data.base64EncodedString()
  }

  func clearMarkup() {
    guard bounds.width > 0, bounds.height > 0 else { return }
    let markup = PaperMarkup(bounds: currentCanvasBounds())
    state.markup = markup
    state.viewController?.markup = markup

#if !os(macOS)
    restoreToolPickerAfterClear()
#endif
  }

  func performUndo() {
    state.viewController?.undoManager?.undo()
  }

  func performRedo() {
    state.viewController?.undoManager?.redo()
  }

  func exportAsImage(format: String, quality: Double) async throws -> String {
    guard let markup = state.viewController?.markup ?? state.markup else {
      throw PaperkitError.noMarkupData
    }

    let renderBounds = markup.bounds
#if !os(macOS)
    let scale = UIScreen.main.scale
#else
    let scale = NSScreen.main?.backingScaleFactor ?? 2.0
#endif
    let pixelWidth = Int(renderBounds.width * scale)
    let pixelHeight = Int(renderBounds.height * scale)
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let ctx = CGContext(
      data: nil,
      width: pixelWidth,
      height: pixelHeight,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    ) else {
      throw PaperkitError.exportFailed("Failed to create bitmap context")
    }

    ctx.scaleBy(x: scale, y: scale)
    ctx.translateBy(x: -renderBounds.origin.x, y: -renderBounds.origin.y)

#if !os(macOS)
    let options = RenderingOptions(traitCollection: UITraitCollection.current)
#else
    let options = RenderingOptions()
#endif
    await markup.draw(in: ctx, frame: renderBounds, options: options)

    guard let cgImage = ctx.makeImage() else {
      throw PaperkitError.exportFailed("Failed to create image from context")
    }

#if !os(macOS)
    let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    let ext = format == "jpg" ? "jpg" : "png"
    let imageData: Data? = format == "jpg"
      ? image.jpegData(compressionQuality: quality)
      : image.pngData()
#else
    let nsImage = NSImage(cgImage: cgImage, size: renderBounds.size)
    let ext = format == "jpg" ? "jpg" : "png"
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    let imageData: Data? = format == "jpg"
      ? bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
      : bitmapRep.representation(using: .png, properties: [:])
#endif

    guard let data = imageData else {
      throw PaperkitError.exportFailed("Failed to generate image data")
    }

    let tempDir = FileManager.default.temporaryDirectory
    let fileName = "paperkit_export_\(UUID().uuidString).\(ext)"
    let fileURL = tempDir.appendingPathComponent(fileName)
    try data.write(to: fileURL)
    return fileURL.absoluteString
  }
}

#else

// MARK: - Stubs (PaperKit unavailable)

extension ExpoPaperkitView {
  func loadInitialData(_ base64String: String) {}
  func save() async throws -> String { throw PaperkitError.unsupportedPlatform }
  func clearMarkup() {}
  func performUndo() {}
  func performRedo() {}
  func presentMarkupTools() {}
  func exportAsImage(format: String, quality: Double) async throws -> String {
    throw PaperkitError.unsupportedPlatform
  }
}

#endif
