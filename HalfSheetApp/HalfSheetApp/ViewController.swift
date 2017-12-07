//
//  ViewController.swift
//  HalfSheetApp
//
//  Created by Matt Banach on 9/22/17.
//  Copyright © 2017 Gametime. All rights reserved.
//

import UIKit
import GTSheet

class ViewController: UIViewController, HalfSheetPresentingProtocol {

    @IBOutlet weak var hatPresentationMode: UISegmentedControl?

    var transitionManager: HalfSheetPresentationManager!

    @IBAction func showPlainVC() {
        presentUsingHalfSheet(
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlainVC")
        )
    }

    @IBAction func showVCWithHat() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HatParentVC") as! HatParentVC
        vc.topVCTransitionStyle = hatPresentationMode?.selectedSegmentIndex == 0 ? .slide : .fade
        presentUsingHalfSheet(vc)
    }
    
    @IBAction func showScrollingNC() {
        presentUsingHalfSheet(
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScrollingNC")
        )
    }
}

extension ViewController: HalfSheetCompletionProtocol {
    func didDismiss() {
        print("dismissed!")
    }
}
