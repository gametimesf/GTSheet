//
//  PresentationAnimator.swift
//  Gametime
//
//  Created by Matt Banach on 3/24/16.
//
//

import Foundation

class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    weak var managerDelegate: PresentationViewControllerDelegate?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return HalfSheetPresentationManager.transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let presentedController = transitionContext.viewController(forKey: .to),
            let wrappedPresentedView = managerDelegate?.presentationController?.wrappingView
        else {
            return
        }

        let containerView = transitionContext.containerView

        wrappedPresentedView.frame = transitionContext.finalFrame(for: presentedController)
        wrappedPresentedView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.size.height)

        containerView.addSubview(wrappedPresentedView)

        managerDelegate?.presentationController?.backgroundView.alpha = 0.0
        managerDelegate?.auxileryView?.alpha = 0.0

        weak var weakSelf = self

        let duration = transitionDuration(using: transitionContext)
        let timing = UISpringTimingParameters(dampingRatio: 1)
        let animator = UIViewPropertyAnimator(duration: duration * 2, timingParameters: timing)

        func animate() {
            wrappedPresentedView.transform = .identity
            weakSelf?.managerDelegate?.presentationController?.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            weakSelf?.managerDelegate?.presentationController?.backgroundView.alpha = 1.0

            UIView.animateKeyframes(withDuration: duration, delay: 0, options:[], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                    weakSelf?.managerDelegate?.auxileryView?.alpha = 1.0
                }
            })
        }

        func complete(completed: Bool) {
            transitionContext.completeTransition(completed)
            weakSelf?.managerDelegate?.didPresent()
        }

        animator.addAnimations(animate)

        animator.addCompletion { position in
            complete(completed: position == .end)
        }

        animator.startAnimation()
    }
}
