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

  func rebuildToolPicker() {
    guard showPencilKit, let vc = state.viewController else { return }

    if let existing = state.toolPicker {
      existing.setVisible(false, forFirstResponder: vc.view)
      existing.removeObserver(vc)
    }

    let picker = createToolPicker()
    state.toolPicker = picker
    picker.addObserver(vc)
    let visible = toolPickerVisibilityProp != "hidden"
    picker.setVisible(visible, forFirstResponder: vc.view)
    vc.pencilKitResponderState.activeToolPicker = picker
    vc.pencilKitResponderState.toolPickerVisibility = visible ? .visible : .hidden
    if visible { vc.view.becomeFirstResponder() }
  }

  private func createToolPicker() -> PKToolPicker {
    let picker = makeToolPicker()
    if #available(iOS 18.0, *) {
      picker.accessoryItem = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(handleToolPickerAccessory(_:))
      )
    }
    return picker
  }

  private func makeToolPicker() -> PKToolPicker {
    guard !toolItemConfigs.isEmpty else {
      return PKToolPicker()
    }

    let items = toolItemConfigs.compactMap(Self.toolItem(from:))

    return items.isEmpty ? PKToolPicker() : PKToolPicker(toolItems: items)
  }

  private static func toolItem(from config: ToolItemConfig) -> PKToolPickerItem? {
    switch config.type {
    case "eraser":
      let eraserType = self.eraserType(named: config.eraserType) ?? .vector

      guard let width = config.width else {
        return PKToolPickerEraserItem(type: eraserType)
      }

      return PKToolPickerEraserItem(type: eraserType, width: CGFloat(width))

    case "lasso":
      return PKToolPickerLassoItem()

    default:
      guard let inkType = self.inkType(named: config.inkType) else { return nil }

      let item = PKToolPickerInkingItem(
        type: inkType,
        color: config.color,
        width: config.width.map { CGFloat($0) },
        identifier: config.identifier
      )

      item.allowsColorSelection = config.allowsColorSelection ?? true

      return item
    }
  }

  private static func inkType(named name: String?) -> PKInkingTool.InkType? {
    switch name {
    case "pen", nil: return .pen
    case "pencil": return .pencil
    case "marker": return .marker
    case "monoline": return .monoline
    case "fountainPen": return .fountainPen
    case "watercolor": return .watercolor
    case "crayon": return .crayon
    case "reed": return .reed
    default: return nil
    }
  }

  private static func eraserType(named name: String?) -> PKEraserTool.EraserType? {
    switch name {
    case "bitmap": return .bitmap
    case "fixedWidthBitmap": return .fixedWidthBitmap
    case "vector", nil: return .vector
    default: return nil
    }
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
