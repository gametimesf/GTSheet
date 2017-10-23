//
//  HalfSheetPresentableProtocol.swift
//  Gametime
//
//  Matt Banach on 2/21/17.
//
//

import UIKit

public protocol HalfSheetPresentableProtocol: class {
    weak var managedScrollView: UIScrollView? { get }
    var swipeToDismiss: Bool { get }
    var sheetHeight: CGFloat? { get }
}

public protocol HalfSheetTopVCProviderProtocol: class {
    var topVC: UIViewController { get }
}

public protocol HalfSheetCompletionProtocol: class {
    func didDismiss()
}

public protocol HalfSheetAppearanceProtocol: class {
    var cornerRadius: CGFloat { get }
}

public extension HalfSheetPresentableProtocol where Self: UIViewController {
    func didUpdateSheetHeight() {
        (navigationController?.transitioningDelegate as? HalfSheetPresentationManager ?? transitioningDelegate as? HalfSheetPresentationManager)?.didChangeSheetHeight()
    }
}
