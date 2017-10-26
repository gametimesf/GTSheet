//
//  DismissalAnimator.swift
//  Gametime
//
//  Created by Matt Banach on 3/24/16.
//
//

import Foundation

public class DismissalAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    weak var manager: HalfSheetPresentationManager?
    weak var managerDelegate: PresentationViewControllerDelegate?

    var animator: UIViewPropertyAnimator?

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let interactive = (manager?.interactive ?? false)
        return HalfSheetPresentationManager.transitionDuration * (interactive ? 2.5 : 1)
    }

    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {

        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let duration = transitionDuration(using: transitionContext)
        let timing = UISpringTimingParameters(dampingRatio: 1.3)
        weak var weakSelf = self

        func animate() {

            let finalTransform = CGAffineTransform(
                translationX: 0,
                y: managerDelegate?.auxileryTransition?.isSlide == true ? (weakSelf?.managerDelegate?.presentationController?.containerView?.bounds.height)! : presentedControllerView.bounds.height
            )

            presentedControllerView.transform = finalTransform

            weakSelf?.managerDelegate?.presentationController?.presentingViewController.view.transform = .identity
            weakSelf?.managerDelegate?.presentationController?.backgroundView.alpha = 0.0
            weakSelf?.managerDelegate?.auxileryView?.alpha = managerDelegate?.auxileryTransition?.isFade == true ? 0.0 : 1.0
            weakSelf?.managerDelegate?.auxileryView?.transform = finalTransform
        }

        func complete(completed: Bool) {

            let finished = completed && !transitionContext.transitionWasCancelled

            transitionContext.completeTransition(finished)

            if finished {
                weakSelf?.manager?.dismissComplete()
            }
        }

        animator = UIViewPropertyAnimator(duration: duration * 2.5, timingParameters: timing)
        animator?.addAnimations(animate)
        animator?.addCompletion { complete(completed: $0 == .end) }
        animator?.startAnimation()

        return animator!
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let presentingVC = transitionContext.viewController(forKey: .from)
        else {
            return
        }

        weak var weakSelf = self

        func animate() {
            let finalTransform = CGAffineTransform(
                translationX: 0,
                y: managerDelegate?.auxileryTransition?.isSlide == true ? (weakSelf?.managerDelegate?.presentationController?.containerView?.bounds.height)! : presentedControllerView.bounds.height
            )
            presentedControllerView.transform = finalTransform
            weakSelf?.managerDelegate?.presentationController?.presentingViewController.view.transform = CGAffineTransform.identity
            weakSelf?.managerDelegate?.presentationController?.backgroundView.alpha = 0.0
            weakSelf?.managerDelegate?.auxileryView?.alpha =  managerDelegate?.auxileryTransition?.isFade == true ? 0.0 : 1.0
            weakSelf?.managerDelegate?.auxileryView?.transform =  managerDelegate?.auxileryTransition?.isSlide == true ? finalTransform : .identity
        }

        func complete(completed: Bool) {

            let finished = completed && !transitionContext.transitionWasCancelled

            transitionContext.completeTransition(finished)

            if finished {
                weakSelf?.manager?.dismissComplete()
            }
        }

        let duration = transitionDuration(using: transitionContext)
        let timing = UISpringTimingParameters(dampingRatio: 1.3)

        animator = UIViewPropertyAnimator(
            duration: duration * 2.5,
            timingParameters: timing
        )

        animator?.addAnimations(animate)
        animator?.addCompletion { complete(completed: $0 == .end) }
        animator?.startAnimation()
    }

    override public func cancel() {
        super.cancel()

        animator?.pauseAnimation()

        let duration: CGFloat = 0.3
        let timing = UISpringTimingParameters(dampingRatio: 0.7)

        animator?.continueAnimation(
            withTimingParameters: timing,
            durationFactor: duration
        )
    }

    override public func finish() {
        super.finish()

        animator?.pauseAnimation()

        let duration: CGFloat = 0.3
        let timing = UISpringTimingParameters(dampingRatio: 1.2)

        animator?.continueAnimation(
            withTimingParameters: timing,
            durationFactor: duration
        )
    }

    override public func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)

        animator?.fractionComplete = percentComplete
    }
}
