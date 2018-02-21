//
//  HalfSheetPresentationManager.swift
//  Gametime
//
//  Created by Matt Banach on 3/22/16.
//
//

import Foundation

public class HalfSheetPresentationManager: NSObject, UIGestureRecognizerDelegate {

    private var observer: NSKeyValueObservation?
    private var displayLink: CADisplayLink?
    private var lastSnapshot: UIView?

    public private(set) lazy var dismissingPanGesture: VerticalPanGestureRecognizer = { [unowned self] in
        return VerticalPanGestureRecognizer(
            target: self,
            action: #selector(HalfSheetPresentationManager.handleDismissingPan(_:))
        )
    }()

    public private(set) lazy var contentDismissingPanGesture: UIPanGestureRecognizer = { [unowned self] in
        return UIPanGestureRecognizer(
            target: self,
            action: #selector(HalfSheetPresentationManager.handleDismissingPan(_:))
        )
    }()

    public private(set) lazy var backgroundViewDismissTrigger: UITapGestureRecognizer = { [unowned self] in
        return UITapGestureRecognizer(
            target: self,
            action: #selector(HalfSheetPresentationManager.handleDismissingTap)
        )
    }()

    fileprivate lazy var presentationAnimation: PresentationAnimator = { [unowned self] in
        return PresentationAnimator(manager: self)
    }()

    fileprivate lazy var dismissalAnimation: DismissalAnimator = { [unowned self] in
        return DismissalAnimator(manager: self)
    }()

    internal var presentationController: PresentationViewController?

    var hasActiveGesture: Bool {
        return [dismissingPanGesture.state, contentDismissingPanGesture.state].filter { ![.possible, .failed].contains($0) }.isEmpty == false
    }

    public override init() {
        super.init()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.unlinkDisplay()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.linkDisplay()
        }

        linkDisplay()
    }

    //
    // MARK: Gesture Recoginzers
    //

    @objc func handleDismissingTap() {
        guard allowTapToDismiss, !isScrolling else { return }
        dismissPresentedVC()
    }

    @objc func handleDismissingPan(_ pan: UIPanGestureRecognizer) {
        guard allowTapToDismiss, !isScrolling else { return }

        let translation = pan.translation(in: containerView)
        let velocity = pan.velocity(in: containerView)

        let d: CGFloat = max(translation.y, 0) / containerHeight

        switch pan.state {
        case .began:
            guard velocity.y > 0 else { return }
            HapticHelper.warmUp()
            dismissalAnimation.isFromGesture = true
            dismissPresentedVC()
        case .changed:
            dismissalAnimation.update(d)

            if max(translation.y, 0) > TransitionConfiguration.Dismissal.dismissBreakpoint {
                pan.isEnabled = false
                HapticHelper.impact()
                dismissalAnimation.finish()
            }
        default:

            func commitTransition() {
                dismissalAnimation.finish()
            }

            func cancelTransition() {
                dismissalAnimation.isFromGesture = false
                dismissalAnimation.cancel()
            }

            translation.y > TransitionConfiguration.Dismissal.dismissBreakpoint ? commitTransition() : cancelTransition()
        }
    }

    public func updateForScrollPosition(yOffset: CGFloat) {

        let fullOffset = yOffset + topOffset

        guard fullOffset < 0 else {
            return
        }

        let forwardTransform = CGAffineTransform(translationX: 0, y: -fullOffset)
        let backwardsTransform = CGAffineTransform(translationX: 0, y: fullOffset)

        presentationController?.wrappingView.layer.transform = forwardTransform.as3D
        presentationController?.managedScrollView?.layer.transform = backwardsTransform.as3D

        if shouldSlideAuxilery {
            auxileryView?.transform = forwardTransform
        }

        if -fullOffset > TransitionConfiguration.Dismissal.dismissBreakpoint {
            observer = nil
            HapticHelper.impact()
            dismissalAnimation.isFromGesture = false
            dismissPresentedVC()
        }
    }

    internal func dismissComplete() {
        observer = nil

        var respondingHalfSheetCompletionProtocol: HalfSheetCompletionProtocol? {
            if let pc = presentationController?.presentingViewController as? HalfSheetCompletionProtocol {
                return pc
            }

            if let nc = presentationController?.presentingViewController as? UINavigationController, let pc = nc.viewControllers.last as? HalfSheetCompletionProtocol {
                return pc
            }

            return nil
        }

        var respondingPresentationProtocol: HalfSheetPresentingProtocol? {
            if let pc = presentationController?.presentingViewController as? HalfSheetPresentingProtocol {
                return pc
            }

            if let nc = presentationController?.presentingViewController as? UINavigationController, let pc = nc.viewControllers.last as? HalfSheetPresentingProtocol {
                return pc
            }

            return nil
        }

        respondingHalfSheetCompletionProtocol?.didDismiss()
        respondingPresentationProtocol?.transitionManager = nil

        displayLink?.invalidate()
        displayLink = nil
        presentationController = nil
    }
    
    public func didChangeSheetHeight() {
        presentationController?.updateSheetHeight()
    }

    private var allowSwipeToDismiss: Bool {
        return respondingVC?.dismissMethod.allowSwipe ?? false
    }

    private var allowTapToDismiss: Bool {
        return respondingVC?.dismissMethod.allowTap ?? false
    }

    private var topOffset: CGFloat {
        if #available(iOS 11.0, *) {
            return presentationController?.managedScrollView?.safeAreaInsets.top ?? 0.0
        } else {
            return presentationController?.managedScrollView?.contentInset.top ?? 0.0
        }
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
        return hasActiveGesture ? dismissalAnimation : nil
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        presented.modalPresentationStyle = .custom

        presentationController = PresentationViewController(
            presentedViewController: presented,
            presentingViewController: source,
            manager: self
        )

        return presentationController
    }

    internal func didFinishPresentation() {
        observer = presentationController?.managedScrollView?.observe(\UIScrollView.contentOffset, options: [.new]) { [weak self] _, change in
            guard let offset = change.newValue, offset.y < 0 else { return }
            self?.updateForScrollPosition(yOffset: offset.y)
        }
    }
}

extension HalfSheetPresentationManager {

    private func unlinkDisplay() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func linkDisplay() {
        copyPresentingViewToTransitionContext(afterScreenUpdate: true)
        displayLink?.invalidate()
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(HalfSheetPresentationManager.displayDidRefresh(_:)))
        displayLink?.add(to: .main, forMode: .defaultRunLoopMode)
    }

    @objc private func displayDidRefresh(_ displayLink: CADisplayLink) {
        copyPresentingViewToTransitionContext(afterScreenUpdate: false)
    }

    func copyPresentingViewToTransitionContext(afterScreenUpdate: Bool) {
        guard let newSnapshot = presentationController?.presentingViewController.view.snapshotView(afterScreenUpdates: afterScreenUpdate) else { return }
        presentationController?.presentingViewContainer.isHidden = false
        lastSnapshot?.removeFromSuperview()
        newSnapshot.frame = presentationController?.presentingViewContainer.bounds ?? .zero
        presentationController?.presentingViewContainer.addSubview(newSnapshot)
        lastSnapshot = newSnapshot
    }
}

extension HalfSheetPresentationManager: AnimatorConvenience {

    weak var manager: HalfSheetPresentationManager? {
        return self
    }
}
