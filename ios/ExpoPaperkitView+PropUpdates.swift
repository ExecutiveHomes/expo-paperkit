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

  func updateIndirectPointerTouchMode() {
    let mode: PaperMarkupViewController.TouchMode = indirectPointerTouchMode == "selection" ? .selection : .drawing
    state.viewController?.indirectPointerTouchMode = mode
  }

  func updateRuler() {
#if !os(macOS)
    state.viewController?.isRulerActive = isRulerActive
#endif
  }

  func applyPaperBackgroundColor() {
#if !os(macOS)
    let color = paperBackgroundColor ?? UIColor.systemBackground
    guard backgroundColor != color else { return }
    backgroundColor = color
    state.viewController?.view.backgroundColor = color
#else
    let color = paperBackgroundColor ?? NSColor.windowBackgroundColor
    guard layer?.backgroundColor != color.cgColor else { return }
    wantsLayer = true
    layer?.backgroundColor = color.cgColor
    if let paperView = state.viewController?.view {
      paperView.wantsLayer = true
      paperView.layer?.backgroundColor = color.cgColor
    }
#endif
  }
}

#endif
