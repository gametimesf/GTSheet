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
