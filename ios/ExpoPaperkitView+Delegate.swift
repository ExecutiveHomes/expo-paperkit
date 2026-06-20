#if canImport(PaperKit)
import PaperKit

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView: @preconcurrency PaperMarkupViewController.Delegate {

  func paperMarkupViewControllerDidChangeMarkup(_ controller: PaperMarkupViewController) {
    markupChangedWorkItem?.cancel()
    let workItem = DispatchWorkItem { [weak self] in
      self?.onMarkupChanged()
    }
    markupChangedWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: workItem)
  }

  func paperMarkupViewControllerDidChangeSelection(_ controller: PaperMarkupViewController) {
    let selectedBounds = controller.selectedMarkup.contentsRenderFrame
    onSelectionChanged([
      "hasSelection": !selectedBounds.isEmpty,
    ])
  }

  func paperMarkupViewControllerDidBeginDrawing(_ controller: PaperMarkupViewController) {
    onDrawingBegan()
  }

  func paperMarkupViewControllerDidChangeContentVisibleFrame(_ controller: PaperMarkupViewController) {
    let frame = controller.contentVisibleFrame
    onContentVisibleFrameChanged([
      "x": frame.origin.x,
      "y": frame.origin.y,
      "width": frame.size.width,
      "height": frame.size.height,
    ])
  }
}

#endif
