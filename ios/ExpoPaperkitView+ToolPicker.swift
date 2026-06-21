#if canImport(PaperKit) && canImport(PencilKit) && !os(macOS)
import PaperKit
import PencilKit
import UIKit

// MARK: - PKToolPicker (iOS/iPadOS)

@available(iOS 26.0, *)
extension ExpoPaperkitView {

  func setupToolPicker(for vc: PaperMarkupViewController) {
    guard showPencilKit else { return }
    let picker = createToolPicker()
    state.toolPicker = picker
    picker.addObserver(vc)
    let visible = toolPickerVisibilityProp != "hidden"
    picker.setVisible(visible, forFirstResponder: vc.view)
    vc.pencilKitResponderState.activeToolPicker = picker
    vc.pencilKitResponderState.toolPickerVisibility = visible ? .visible : .hidden
  }

  func updatePencilKit() {
    guard let vc = state.viewController else { return }
    if showPencilKit {
      if state.toolPicker == nil { state.toolPicker = createToolPicker() }
      guard let picker = state.toolPicker else { return }
      picker.addObserver(vc)
      let visible = toolPickerVisibilityProp != "hidden"
      picker.setVisible(visible, forFirstResponder: vc.view)
      vc.pencilKitResponderState.activeToolPicker = picker
      vc.pencilKitResponderState.toolPickerVisibility = visible ? .visible : .hidden
      if visible { vc.view.becomeFirstResponder() }
    } else {
      if let picker = state.toolPicker {
        picker.setVisible(false, forFirstResponder: vc.view)
        picker.removeObserver(vc)
        state.toolPicker = nil
      }
      vc.pencilKitResponderState.activeToolPicker = nil
      vc.pencilKitResponderState.toolPickerVisibility = .hidden
      vc.view.resignFirstResponder()
    }
  }

  func applyToolPickerVisibility() {
    guard let vc = state.viewController, let picker = state.toolPicker, showPencilKit else { return }
    let visible = toolPickerVisibilityProp != "hidden"
    picker.setVisible(visible, forFirstResponder: vc.view)
    if visible {
      vc.pencilKitResponderState.activeToolPicker = picker
      vc.pencilKitResponderState.toolPickerVisibility = .visible
      vc.view.becomeFirstResponder()
    } else {
      vc.pencilKitResponderState.toolPickerVisibility = .hidden
      vc.view.resignFirstResponder()
    }
  }

  func setToolPickerVisibility(_ visibility: String) {
    toolPickerVisibilityProp = visibility
  }

  func restoreToolPickerAfterClear() {
    guard showPencilKit, let vc = state.viewController, let picker = state.toolPicker else { return }
    picker.addObserver(vc)
    picker.setVisible(true, forFirstResponder: vc.view)
    vc.pencilKitResponderState.activeToolPicker = picker
    vc.pencilKitResponderState.toolPickerVisibility = .visible
    vc.view.becomeFirstResponder()
  }

  private func createToolPicker() -> PKToolPicker {
    let picker = PKToolPicker()
    if #available(iOS 18.0, *) {
      picker.accessoryItem = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(handleToolPickerAccessory(_:))
      )
    }
    return picker
  }

  @objc private func handleToolPickerAccessory(_ sender: Any?) {
    if #available(iOS 26.0, *) {
      presentMarkupToolsFromSender(sender)
    }
  }
}

#endif

// MARK: - MarkupToolbar (macOS)

#if canImport(PaperKit) && os(macOS)
import PaperKit
import AppKit

@available(macOS 26.0, *)
extension ExpoPaperkitView {

  func setupToolPicker(for vc: PaperMarkupViewController) {}

  func applyToolPickerVisibility() {}

  func setToolPickerVisibility(_ visibility: String) {
    toolPickerVisibilityProp = visibility
  }

  func restoreToolPickerAfterClear() {}

  func updatePencilKit() {
    if showPencilKit || showToolbar {
      if state.toolbarVC == nil { setupMarkupToolbar() }
    } else {
      removeMarkupToolbar()
    }
  }

  func setupMarkupToolbar() {
    guard let parentVC = findViewController(),
          let paperVC = state.viewController else { return }

    let featureSet = state.featureSet ?? buildFeatureSet()
    let toolbar = MarkupToolbarViewController(supportedFeatureSet: featureSet)
    toolbar.delegate = paperVC
    state.toolbarVC = toolbar

    parentVC.addChild(toolbar)
    addSubview(toolbar.view)
    toolbar.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      toolbar.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      toolbar.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      toolbar.view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  func removeMarkupToolbar() {
    guard let toolbar = state.toolbarVC else { return }
    toolbar.view.removeFromSuperview()
    toolbar.removeFromParent()
    state.toolbarVC = nil
  }
}

#endif
