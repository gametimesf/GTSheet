//
//  PresentationViewController.swift
//  Gametime
//
//  Created by Matt Banach on 3/24/16.
//
//

import Foundation

protocol PresentationViewControllerDelegate: class {

    var auxileryView: UIView? { get }

    var dismissingPanGesture: VerticalPanGestureRecognizer { get }
    var contentDismissingPanGesture: UIPanGestureRecognizer { get }
    var backgroundViewDismissTrigger: UITapGestureRecognizer { get }

    var presentationController: PresentationViewController? { get }
    
    func didPresent()

    func handleDismissingTap()
    func handleDismissingPan(_ pan: UIPanGestureRecognizer)
}

public class PresentationViewController: UIPresentationController {

    public static let kDefaultOffset: CGFloat = 104.0

    weak var managerDelegate: PresentationViewControllerDelegate?

    lazy var backgroundView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.add(gestureRecognizer: self.managerDelegate?.backgroundViewDismissTrigger)
        view.add(gestureRecognizer: self.managerDelegate?.contentDismissingPanGesture)
        view.alpha = 1.0
        return view
    }()

    var wrappingView: UIView = UIView()

    var presentedViewConstraints: [NSLayoutConstraint] = []
    var wrappingViewConstraints: [NSLayoutConstraint] = []

    convenience init(config: Config) {
        self.init(
            presentedViewController: config.vcs.presented,
            presenting: config.vcs.presenting
        )
    }

    public func updateSheetHeight() {

        guard
            let presentedView = presentedView,
            let _ = presentedView.superview
        else {
            return
        }

        wrappingView.superview?.removeConstraints(wrappingViewConstraints)
        wrappingView.removeConstraints(wrappingViewConstraints)

        wrappingViewConstraints = wrappingView.bindToSuperView(edgeInsets:
            UIEdgeInsets(
                top: getRequestedOffset(),
                left: 0,
                bottom: 0,
                right: 0
            )
        )

        let animator = UIViewPropertyAnimator(
            duration: 0.4,
            timingParameters: UISpringTimingParameters(dampingRatio: 1)
        )

        animator.addAnimations { [weak self] in
            self?.containerView?.layoutIfNeeded()
        }

        animator.startAnimation()
    }

    override public func presentationTransitionWillBegin() {

        guard
            let containerView = containerView,
            let presentedView = presentedView
        else {
            return
        }

        (presentedViewController as? UINavigationController)?.delegate = self

        containerView.addSubview(backgroundView)
        containerView.addSubview(wrappingView)
        wrappingView.addSubview(presentedView)

        if let view = managerDelegate?.auxileryView {
            addTopContent(view: view)
        }

        backgroundView.bindToSuperView(edgeInsets: .zero)
        presentedView.bindToSuperView(edgeInsets: .zero)

        wrappingView.superview?.removeConstraints(wrappingViewConstraints)
        wrappingView.removeConstraints(wrappingViewConstraints)

        wrappingViewConstraints = wrappingView.bindToSuperView(edgeInsets:
            UIEdgeInsets(
                top: getRequestedOffset(),
                left: 0,
                bottom: 0,
                right: 0
            )
        )

        if let appearanceProvider = respondingVC as? HalfSheetAppearanceProtocol {
            presentedView.clipsToBounds = true
            presentedView.round(corners: [.topLeft, .topRight], radius: appearanceProvider.cornerRadius)
        }

        presentedView.add(gestureRecognizer: self.managerDelegate?.dismissingPanGesture)

        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
		guard !completed else { return }
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        presentingViewController.view.transform = CGAffineTransform.identity
        managerDelegate?.auxileryView?.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }

    fileprivate func getRequestedOffset() -> CGFloat {

        guard let containerView = containerView else {
            return PresentationViewController.kDefaultOffset
        }

        var topOffset: CGFloat {
            if #available(iOS 11.0, *) {
                return managedScrollView?.safeAreaInsets.top ?? 0.0
            } else {
                return 0.0
            }
        }

        var expectedOffset: CGFloat {

            if let respondingVC = respondingVC {

                var defaultHeight: CGFloat {
                    return containerHeight - PresentationViewController.kDefaultOffset
                }

                return containerHeight - (respondingVC.sheetHeight ?? defaultHeight) - topOffset
            }

            return PresentationViewController.kDefaultOffset
        }

        return max(expectedOffset, UIApplication.shared.statusBarFrame.height)
    }

    var respondingVC: HalfSheetPresentableProtocol? {

        if let pc = presentedViewController as? HalfSheetPresentableProtocol {
            return pc
        }

        if let nc = presentedViewController as? UINavigationController, let pc = nc.viewControllers.last as? HalfSheetPresentableProtocol {
            return pc
        }

        return nil
    }

    override public var shouldPresentInFullscreen: Bool {
        return false
    }

    private var containerHeight: CGFloat {
        return containerView?.bounds.height ?? 0.0
    }

    weak var managedScrollView: UIScrollView? {

        if let sheet = respondingVC {
            return sheet.managedScrollView
        }

        return nil
    }

    // MARK: Content Changes

    func addTopContent(view: UIView) {

        guard let containerView = containerView else {
            return
        }

        containerView.insertSubview(
            view,
            aboveSubview: backgroundView
        )

        view.bindToSuperView(edgeInsets:
            UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: containerView.bounds.height - getRequestedOffset(),
                right: 0
            )
        )
    }
}

private extension UIView {

    func add(gestureRecognizer: UIGestureRecognizer?) {
        guard let gestureRecognizer = gestureRecognizer else { return }
        addGestureRecognizer(gestureRecognizer)
    }

    func round(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

extension PresentationViewController : UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateSheetHeight()
    }
}
