//
//  PlainVC.swift
//  HalfSheetApp
//
//  Created by Matt Banach on 9/22/17.
//  Copyright © 2017 Gametime. All rights reserved.
//

import UIKit
import GTSheet

class PlainVC: UIViewController, HalfSheetPresentableProtocol {

    var sheetHeight: CGFloat? = 250.0

    var managedScrollView: UIScrollView? {
        return nil
    }

    var swipeToDismiss: Bool {
        return true
    }

    @IBAction func becomeLarger() {
        sheetHeight = (sheetHeight ?? 0.0) + 30.0
        (transitioningDelegate as? HalfSheetPresentationManager)?.sheetHeightDidChange()
    }

    @IBAction func becomeSmaller() {
        sheetHeight = (sheetHeight ?? 0.0) - 30.0
        (transitioningDelegate as? HalfSheetPresentationManager)?.sheetHeightDidChange()
    }

    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

extension PlainVC: HalfSheetAppearanceProtocol {
    var cornerRadius: CGFloat {
        return 8.0
    }
}

class HatParentVC: UIViewController, HalfSheetTopVCProviderProtocol {

    lazy var topVC: UIViewController = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HatVC")
    }()

    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}

class HatVC: UIViewController { }
class ScrollingVC: UITableViewController { }
class ScrollingNC: UINavigationController { }

extension ScrollingNC: HalfSheetPresentableProtocol {

    var managedScrollView: UIScrollView? {
        return (viewControllers.last as? HalfSheetPresentableProtocol)?.managedScrollView
    }

    var swipeToDismiss: Bool {
        return true
    }

    var sheetHeight: CGFloat? {
        return nil
    }
}

extension ScrollingVC: HalfSheetAppearanceProtocol {
    var cornerRadius: CGFloat {
        return 8.0
    }
}

extension ScrollingVC: HalfSheetPresentableProtocol {

    var managedScrollView: UIScrollView? {
        return tableView
    }

    var swipeToDismiss: Bool {
        return true
    }

    var sheetHeight: CGFloat? {
        return 500.0
    }
}

extension HatParentVC: HalfSheetPresentableProtocol {

    var managedScrollView: UIScrollView? {
        return nil
    }

    var swipeToDismiss: Bool {
        return true
    }

    var sheetHeight: CGFloat? {
        return 250.0
    }
}

