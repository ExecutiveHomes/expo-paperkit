#if canImport(PaperKit)
import PaperKit

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView {

  func updateReadOnly() {
    state.viewController?.isEditable = !readOnly
  }

  func updateFingerDrawing() {
#if !os(macOS)
    state.viewController?.directTouchMode = allowFingerDrawing ? .drawing : .selection
#endif
  }

  func updateDirectTouchAutomaticallyDraws() {
#if !os(macOS)
    state.viewController?.directTouchAutomaticallyDraws = directTouchAutomaticallyDraws
#endif
  }

  func updateRuler() {
    state.viewController?.isRulerActive = isRulerActive
  }

  func applyPaperBackgroundColor() {
    let color = paperBackgroundColor ?? .systemBackground
    self.backgroundColor = color
    state.viewController?.view.backgroundColor = color
  }
}

#endif
