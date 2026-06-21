#if canImport(PaperKit)
import PaperKit

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView {

  func updateBackgroundImage() {
    guard let vc = state.viewController else { return }
    guard let uri = backgroundImageUri, !uri.isEmpty else {
      backgroundImageLoadId = nil
      vc.contentView = nil
      return
    }
    let loadId = UUID()
    backgroundImageLoadId = loadId
    let mode = backgroundImageContentMode
    loadImage(from: uri) { [weak self, weak vc] image in
      guard let self = self, self.backgroundImageLoadId == loadId else { return }
      guard let image = image, let vc = vc else { return }
#if !os(macOS)
      let imageView = UIImageView(image: image)
      switch mode {
      case "contain":
        imageView.contentMode = .scaleAspectFit
      case "stretch":
        imageView.contentMode = .scaleToFill
      default:
        imageView.contentMode = .scaleAspectFill
      }
      imageView.clipsToBounds = true
#else
      let imageView = NSImageView(image: image)
      switch mode {
      case "contain":
        imageView.imageScaling = .scaleProportionallyUpOrDown
      case "stretch":
        imageView.imageScaling = .scaleAxesIndependently
      default:
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.wantsLayer = true
        imageView.layer?.contentsGravity = .resizeAspectFill
        imageView.layer?.contents = image
      }
#endif
      vc.contentView = imageView
    }
  }

#if !os(macOS)
  private func loadImage(from uri: String, completion: @escaping (UIImage?) -> Void) {
    if uri.hasPrefix("http://") || uri.hasPrefix("https://") {
      guard let url = URL(string: uri) else { return completion(nil) }
      URLSession.shared.dataTask(with: url) { data, _, _ in
        let image = data.flatMap { UIImage(data: $0) }
        DispatchQueue.main.async { completion(image) }
      }.resume()
    } else {
      var path = uri
      if path.hasPrefix("file://") { path = String(path.dropFirst(7)) }
      completion(UIImage(contentsOfFile: path))
    }
  }
#else
  private func loadImage(from uri: String, completion: @escaping (NSImage?) -> Void) {
    if uri.hasPrefix("http://") || uri.hasPrefix("https://") {
      guard let url = URL(string: uri) else { return completion(nil) }
      URLSession.shared.dataTask(with: url) { data, _, _ in
        let image = data.flatMap { NSImage(data: $0) }
        DispatchQueue.main.async { completion(image) }
      }.resume()
    } else {
      var path = uri
      if path.hasPrefix("file://") { path = String(path.dropFirst(7)) }
      completion(NSImage(contentsOfFile: path))
    }
  }
#endif
}

#endif
