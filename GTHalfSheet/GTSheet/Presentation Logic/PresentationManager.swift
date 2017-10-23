//
//  HalfSheetPresentationManager.swift
//  Gametime
//
//  Created by Matt Banach on 3/22/16.
//
//

import Foundation

public class HalfSheetPresentationManager: NSObject, UIGestureRecognizerDelegate {

    fileprivate var observerContext = 0

    static let transitionDuration = 0.25

    let kAutomaticDismissBreakpoint: CGFloat = 0.25

    internal var interactive: Bool = false
    private var observer: NSKeyValueObservation?

    fileprivate var observingScrollView: Bool = false

    public private(set) lazy var dismissingPanGesture: VerticalPanGestureRecognizer = { [unowned self] in
        let gesture = VerticalPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(HalfSheetPresentationManager.handleDismissingPan(_:)))
        return gesture
    }()

    public private(set) lazy var contentDismissingPanGesture: UIPanGestureRecognizer = { [unowned self] in
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(HalfSheetPresentationManager.handleDismissingPan(_:)))
        return gesture
    }()

    public private(set) lazy var backgroundViewDismissTrigger: UITapGestureRecognizer = { [unowned self] in
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(HalfSheetPresentationManager.handleDismissingTap))
        return gesture
    }()

    fileprivate let presentationAnimation: PresentationAnimator
    fileprivate let dismissalAnimation: DismissalAnimator

    internal var presentationController: PresentationViewController?

    public override init() {

        presentationAnimation = PresentationAnimator()
        dismissalAnimation = DismissalAnimator()

        super.init()

        contentDismissingPanGesture.require(toFail: dismissingPanGesture)
        contentDismissingPanGesture.require(toFail: backgroundViewDismissTrigger)

        presentationAnimation.managerDelegate = self
        dismissalAnimation.managerDelegate = self
        dismissalAnimation.manager = self
    }

    //
    // MARK: Gesture Recoginzers
    //

    @objc func handleDismissingTap() {
        guard allowSwipeToDismiss else { return }
        interactive = false
        presentationController?.presentedViewController.dismiss(animated: true)
    }

    @objc func handleDismissingPan(_ pan: UIPanGestureRecognizer) {

        guard allowSwipeToDismiss else { return }

        let translation = pan.translation(in: pan.view!)
        let velocity    = pan.velocity(in: pan.view!)
        let sourceView  = pan.view

        interactive = true

        let d: CGFloat = max(translation.y, 0) / (sourceView?.bounds.height ?? 0.0)

        switch pan.state {
        case .began:
            guard velocity.y > 0 else { return }
            HapticHelper.warmUp()
            presentationController?.presentedViewController.dismiss(animated: true, completion:nil)
        case .changed:
            dismissalAnimation.update(d)

            if max(translation.y, 0) > 125.0 {
                interactive = false
                pan.isEnabled = false
                HapticHelper.impact()
                dismissalAnimation.finish()
            }
        default:
            interactive = false
            d > kAutomaticDismissBreakpoint ? dismissalAnimation.finish() : dismissalAnimation.cancel()
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
            return
        }

        var topOffset: CGFloat {
            if #available(iOS 11.0, *) {
                return presentationController?.managedScrollView?.safeAreaInsets.top ?? 0.0
            } else {
                return 0.0
            }
        }

        if let offset = change?[.newKey] as? CGPoint, offset.y + topOffset < 0, observingScrollView {
            let offset = offset.y + topOffset

            presentationController?.wrappingView.transform = CGAffineTransform(
                translationX: 0,
                y: -offset
            )

            presentationController?.managedScrollView?.transform = CGAffineTransform(
                translationX: 0,
                y: offset
            )

            if -offset > 125.0 {
                observingScrollView = false
                interactive = false
                HapticHelper.impact()
                presentationController?.presentedViewController.dismiss(animated: true, completion:nil)
            }
        }
    }

    public func didChangeSheetHeight() {
        presentationController?.updateSheetHeight()
    }

    private var allowSwipeToDismiss: Bool {
        return presentationController?.respondingVC?.swipeToDismiss ?? false
    }

    deinit {
        presentationController?.managedScrollView?.removeObserver(
            self,
            forKeyPath:
            #keyPath(UIScrollView.contentOffset),
            context: &observerContext
        )
    }
}

extension HalfSheetPresentationManager: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAnimation
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissalAnimation
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? dismissalAnimation : nil
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        assert(presented.modalPresentationStyle == .custom, "you must use custom presentation style for half sheets (and any custom transition")

        presentationController = PresentationViewController(config:
            PresentationViewController.Config(
                vcs: (
                    presenting: source,
                    presented: presented
                )
            )
        )

        presentationController?.managerDelegate = self

        return presentationController
    }
}

extension HalfSheetPresentationManager: PresentationViewControllerDelegate {

    internal func didPresent() {

        if let scrollView = presentationController?.managedScrollView {
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new, .old], context: &observerContext)
        } else if let gesture = presentationController?.managerDelegate?.dismissingPanGesture {
            presentationController?.presentedViewController.view.addGestureRecognizer(gesture)
        }

        observingScrollView = true
    }

    internal var auxileryView: UIView? {
        return (presentationController?.presentedViewController as? HalfSheetTopVCProviderProtocol)?.topVC.view
    }
}
