//
//  PresentationViewController.swift
//  Gametime
//
//  Created by Matt Banach on 3/24/16.
//
//

import Foundation

public class PresentationViewController: UIPresentationController, AnimatorConvenience {

    weak var manager: HalfSheetPresentationManager?

    lazy var backgroundView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()

    lazy var backgroundLayer: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()

    lazy var presentingViewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    var wrappingView: UIView = UIView()

    var presentedViewConstraints: [NSLayoutConstraint] = []
    var wrappingViewConstraints: [NSLayoutConstraint] = []
    var topViewConstraints: [NSLayoutConstraint] = []

    public init(presentedViewController: UIViewController, presentingViewController: UIViewController?, manager: HalfSheetPresentationManager) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.manager = manager
    }

    public func updateSheetHeight() {

        guard
            let presentedView = presentedView,
            let _ = presentedView.superview
        else {
            return
        }

        manager?.auxileryView?.superview?.removeConstraints(topViewConstraints)
        manager?.auxileryView?.removeConstraints(topViewConstraints)

        wrappingView.superview?.removeConstraints(wrappingViewConstraints)
        wrappingView.removeConstraints(wrappingViewConstraints)

        wrappingViewConstraints = wrappingView.bindToSuperView(edgeInsets:
            UIEdgeInsets(withTop: topContainerOffset)
        )

        topViewConstraints = manager?.auxileryView?.bindToSuperView(edgeInsets:
            UIEdgeInsets(withBottom: containerHeight - topContainerOffset)
        ) ?? []

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

        containerView.addSubview(backgroundLayer)
        containerView.addSubview(presentingViewContainer)
        containerView.addSubview(backgroundView)
        containerView.addSubview(wrappingView)
        wrappingView.addSubview(presentedView)

        if let view = auxileryView {
            addTopContent(view: view)
        }

        backgroundLayer.bindToSuperView(edgeInsets: .zero)
        presentingViewContainer.bindToSuperView(edgeInsets: .zero)
        manager?.copyPresentingViewToTransitionContext(afterScreenUpdate: true)
        backgroundView.bindToSuperView(edgeInsets: .zero)
        presentedView.bindToSuperView(edgeInsets: .zero)

        wrappingView.superview?.removeConstraints(wrappingViewConstraints)
        wrappingView.removeConstraints(wrappingViewConstraints)

        wrappingViewConstraints = wrappingView.bindToSuperView(edgeInsets:
            UIEdgeInsets(withTop: topContainerOffset)
        )

        if let appearanceProvider = respondingVC as? HalfSheetAppearanceProtocol {
            presentedView.clipsToBounds = true
            presentedView.round(corners: [.topLeft, .topRight], radius: appearanceProvider.cornerRadius)
        }

        presentedView.add(gestureRecognizer: manager?.dismissingPanGesture)
        backgroundView.add(gestureRecognizer: manager?.backgroundViewDismissTrigger)
        backgroundView.add(gestureRecognizer: manager?.contentDismissingPanGesture)

        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        presentingViewController.view.layer.transform = .identity
        manager?.auxileryView?.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }

    fileprivate var topContainerOffset: CGFloat {

        var expectedOffset: CGFloat {

            guard let sheetHeight = respondingVC?.sheetHeight else {
                return 0.0
            }

            if #available(iOS 11.0, *) {
                return containerHeight - sheetHeight - bottomSafeAreaInset
            } else {
                return containerHeight - sheetHeight
            }
        }

        return max(expectedOffset, UIApplication.shared.statusBarFrame.height)
    }

    override public var shouldPresentInFullscreen: Bool {
        return false
    }

    var bottomSafeAreaInset: CGFloat {
        if #available(iOS 11.0, *) {
            // todo: figure out a way to receive safe area updates in a Presentation VC
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        } else {
            return 0.0
        }
    }

    weak var managedScrollView: UIScrollView? {
        return respondingVC?.managedScrollView
    }

    // MARK: Content Changes

    func addTopContent(view: UIView) {

        containerView?.insertSubview(view, aboveSubview: backgroundView)

        topViewConstraints = view.bindToSuperView(edgeInsets:
            UIEdgeInsets(withBottom: containerHeight - topContainerOffset)
        )
    }
}

extension PresentationViewController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateSheetHeight()
    }
}
