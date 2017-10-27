//
//  HalfSheetPresentationProtocol.swift
//  Gametime
//
//  Created by Mike Silvis on 5/18/17.
//
//

import Foundation

public protocol HalfSheetPresentingProtocol: class {
    var transitionManager: HalfSheetPresentationManager! { get set }
}

public extension HalfSheetPresentingProtocol where Self: UIViewController {

    func presentUsingHalfSheet(_ vc: UIViewController, animated: Bool = true) {
        transitionManager = HalfSheetPresentationManager()
        vc.transitioningDelegate = transitionManager
        vc.modalPresentationStyle = .custom
        present(vc, animated: animated)
    }

    @discardableResult func presentUsingHalfSheetInNC(_ vc: UIViewController, animated: Bool = true) -> UINavigationController {
        let nc = UINavigationController(rootViewController: vc)
        transitionManager = HalfSheetPresentationManager()
        nc.transitioningDelegate = transitionManager
        nc.modalPresentationStyle = .custom
        present(nc, animated: animated)
        return nc
    }
}
