import ExpoModulesCore

#if canImport(PaperKit)
import PaperKit
#endif

#if canImport(PencilKit) && !os(macOS)
import PencilKit
#endif

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

// MARK: - PaperKit State Container

#if canImport(PaperKit)

@available(iOS 26.0, macOS 26.0, *)
class PaperKitState {
  var markup: PaperMarkup?
  var viewController: PaperMarkupViewController?
  var featureSet: FeatureSet?

#if !os(macOS)
  var toolPicker: PKToolPicker?
#else
  var toolbarVC: MarkupToolbarViewController?
#endif
}

#endif

// MARK: - ExpoPaperkitView

class ExpoPaperkitView: ExpoView {

  // MARK: - Props

  var showToolbar: Bool = true

  var readOnly: Bool = false {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { updateReadOnly() }
    }
  }

  var showPencilKit: Bool = true {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { updatePencilKit() }
    }
  }

  var allowFingerDrawing: Bool = false {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { updateFingerDrawing() }
    }
  }

  var directTouchAutomaticallyDraws: Bool = false {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { updateDirectTouchAutomaticallyDraws() }
    }
  }

  var featureSetConfig = FeatureSetConfig()
  var enableShapes: Bool = true
  var enableTextBoxes: Bool = true
  var enableArrows: Bool = true
  var enableSignatures: Bool = true
  var enableHDR: Bool = false

  var canvasWidth: Double = 0
  var canvasHeight: Double = 0
  var minZoomScale: Double = 0.25
  var maxZoomScale: Double = 4.0

  var toolPickerVisibilityProp: String = "visible" {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { applyToolPickerVisibility() }
    }
  }

  var isRulerActive: Bool = false {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { updateRuler() }
    }
  }

  var paperBackgroundColor: UIColor? {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { applyPaperBackgroundColor() }
    }
  }

  var backgroundImageUri: String? {
    didSet {
      guard isSetUp else { return }
      if #available(iOS 26.0, macOS 26.0, *) { updateBackgroundImage() }
    }
  }

  // MARK: - Events

  let onMarkupChanged = EventDispatcher()
  let onSelectionChanged = EventDispatcher()
  let onDrawingBegan = EventDispatcher()
  let onContentVisibleFrameChanged = EventDispatcher()

  // MARK: - Internal State

  var isSetUp = false
  var _state: AnyObject?

  // MARK: - Init

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
  }

  // MARK: - Lifecycle

#if !os(macOS)
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil { setupIfNeeded() }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    setupIfNeeded()
  }
#else
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    if window != nil { setupIfNeeded() }
  }

  override func layout() {
    super.layout()
    setupIfNeeded()
  }
#endif

  // MARK: - Setup

  private func setupIfNeeded() {
    guard !isSetUp, bounds.width > 0, bounds.height > 0 else { return }
    guard findViewController() != nil else { return }
    isSetUp = true

    if #available(iOS 26.0, macOS 26.0, *) {
#if canImport(PaperKit)
      setupPaperKit()
#endif
    }
  }

  // MARK: - View Controller Lookup

  func findViewController() -> UIViewController? {
#if !os(macOS)
    var responder = next
    while let r = responder {
      if let vc = r as? UIViewController { return vc }
      responder = r.next
    }
    return nil
#else
    guard let window = self.window else { return nil }
    return window.contentViewController
#endif
  }

  // MARK: - Canvas Bounds Helper

  func currentCanvasBounds() -> CGRect {
    if canvasWidth > 0 && canvasHeight > 0 {
      return CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight)
    }
    return bounds
  }
}

// MARK: - PaperKit State Accessor

#if canImport(PaperKit)

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView {

  var state: PaperKitState {
    if let s = _state as? PaperKitState { return s }
    let s = PaperKitState()
    _state = s
    return s
  }

  func setupPaperKit() {
    let config = featureSetConfig
    enableShapes = config.shapes
    enableTextBoxes = config.textBoxes
    enableArrows = config.arrows
    enableSignatures = config.signatures
    enableHDR = config.hdr

    let markup = PaperMarkup(bounds: currentCanvasBounds())
    state.markup = markup

    let featureSet = buildFeatureSet()
    state.featureSet = featureSet

    let vc = PaperMarkupViewController(
      markup: markup,
      supportedFeatureSet: featureSet
    )
    state.viewController = vc
    vc.isEditable = !readOnly
    vc.delegate = self
    vc.zoomRange = minZoomScale...maxZoomScale

    guard let parentVC = findViewController() else { return }

    parentVC.addChild(vc)
    addSubview(vc.view)
    vc.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      vc.view.topAnchor.constraint(equalTo: topAnchor),
      vc.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      vc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      vc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

#if !os(macOS)
    vc.didMove(toParent: parentVC)
    vc.directTouchMode = allowFingerDrawing ? .drawing : .selection
    vc.directTouchAutomaticallyDraws = directTouchAutomaticallyDraws
    setupToolPicker(for: vc)
#else
    if showToolbar { setupMarkupToolbar() }
#endif

    if let uri = backgroundImageUri, !uri.isEmpty {
      updateBackgroundImage()
    }

    applyPaperBackgroundColor()
    vc.view.becomeFirstResponder()
  }

  func buildFeatureSet() -> FeatureSet {
    var fs: FeatureSet = .latest
    fs.insert(.stickers)
    if !enableShapes {
      fs.remove(.shapeStrokes)
      fs.remove(.shapeFills)
    }
    if !enableTextBoxes {
      fs.remove(.text)
    }
    return fs
  }
}

#endif
