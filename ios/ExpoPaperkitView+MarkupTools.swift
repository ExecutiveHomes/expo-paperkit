#if canImport(PaperKit)
import PaperKit

#if !os(macOS)
import UIKit
#endif

// MARK: - Markup Insertion Tools

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView {

  func presentMarkupTools() {
#if os(macOS)
    if state.toolbarVC == nil { setupMarkupToolbar() }
#else
    presentMarkupToolsFromSender(nil)
#endif
  }

#if !os(macOS)
  func presentMarkupToolsFromSender(_ sender: Any?) {
    guard let paperVC = state.viewController else { return }

    if paperVC.presentedViewController != nil {
      paperVC.dismiss(animated: true) { [weak self] in
        self?.presentPopover(from: paperVC, barButton: sender as? UIBarButtonItem)
      }
    } else {
      presentPopover(from: paperVC, barButton: sender as? UIBarButtonItem)
    }
  }

  private func presentPopover(from paperVC: PaperMarkupViewController, barButton: UIBarButtonItem?) {
    let featureSet = state.featureSet ?? buildFeatureSet()
    let editVC = MarkupEditViewController(supportedFeatureSet: featureSet)

    if let delegate = paperVC as? any MarkupEditViewController.Delegate {
      editVC.delegate = delegate
    }

    editVC.modalPresentationStyle = .popover
    editVC.preferredContentSize = CGSize(width: 300, height: 220)

    if let popover = editVC.popoverPresentationController {
      popover.delegate = self
      if let button = barButton {
        popover.barButtonItem = button
      } else {
        popover.sourceView = self
        popover.sourceRect = CGRect(x: bounds.midX, y: bounds.maxY - 80, width: 1, height: 1)
      }
      popover.permittedArrowDirections = .down
    }

    paperVC.present(editVC, animated: true)
  }
#endif
}

// MARK: - Popover Delegate (iOS)

#if !os(macOS)
extension ExpoPaperkitView: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    .none
  }
}
#endif

#endif
