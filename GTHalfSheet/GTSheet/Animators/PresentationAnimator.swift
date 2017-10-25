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
        let initialTransform = CGAffineTransform(translationX: 0, y: containerView.bounds.size.height)

        wrappedPresentedView.frame = transitionContext.finalFrame(for: presentedController)
        wrappedPresentedView.transform = initialTransform

        containerView.addSubview(wrappedPresentedView)

        managerDelegate?.presentationController?.backgroundView.alpha = 0.0
        managerDelegate?.auxileryView?.alpha = managerDelegate?.auxileryTransition?.isFade == true ? 0.0 : 1.0
        managerDelegate?.auxileryView?.transform = managerDelegate?.auxileryTransition?.isSlide == true ? initialTransform : .identity

        weak var weakDelegate = self.managerDelegate

        let duration = transitionDuration(using: transitionContext)
        let timing = UISpringTimingParameters(dampingRatio: 1)
        let animator = UIViewPropertyAnimator(duration: duration * 2, timingParameters: timing)

        func animate() {
            wrappedPresentedView.transform = .identity
            weakDelegate?.presentationController?.presentingViewController.view.layer.transform = CATransform3DMakeAffineTransform(
                CGAffineTransform(scaleX: 0.92, y: 0.92)
            )
            weakDelegate?.presentationController?.backgroundView.alpha = 1.0
            weakDelegate?.auxileryView?.transform = .identity

            UIView.animateKeyframes(withDuration: duration, delay: 0, options:[], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                    weakDelegate?.auxileryView?.alpha = 1.0
                }
            })
        }

        func complete(completed: Bool) {
            transitionContext.completeTransition(completed)
            weakDelegate?.didPresent()
        }

        animator.addAnimations(animate)

        animator.addCompletion { position in
            complete(completed: position == .end)
        }

        animator.startAnimation()
    }
}
