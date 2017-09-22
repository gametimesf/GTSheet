//
//  DismissalAnimator.swift
//  Gametime
//
//  Created by Matt Banach on 3/24/16.
//
//

import Foundation

public class DismissalAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    var manager: HalfSheetPresentationManager?

    var context: UIViewControllerContextTransitioning?

	public var dismissingPanGesture: UIGestureRecognizer?

    weak var managerDelegate: PresentationViewControllerDelegate?

    private var _animator: AnyObject?

    var animator: UIViewPropertyAnimator?

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let interactive = (manager?.interactive ?? false)
        return HalfSheetPresentationManager.transitionDuration * (interactive ? 2.5 : 1)
    }

    override public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        context = transitionContext
    }

    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {

        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let duration = transitionDuration(using: transitionContext)
        let timing = UISpringTimingParameters(dampingRatio: 1.3)
        weak var weakSelf = self

        func animate() {

            presentedControllerView.transform = CGAffineTransform(
                translationX: 0,
                y: presentedControllerView.bounds.size.height
            )

            weakSelf?.managerDelegate?.presentationController?.presentingViewController.view.transform = .identity
            weakSelf?.managerDelegate?.presentationController?.backgroundView.alpha = 0.0
            weakSelf?.managerDelegate?.auxileryView?.alpha = 0.0
        }

        func complete(completed: Bool) {

            let finished = completed && !transitionContext.transitionWasCancelled

            transitionContext.completeTransition(finished)

            if finished {
                (weakSelf?.managerDelegate?.presentationController?.presentingViewController as? HalfSheetCompletionProtocol)?.didDismiss()
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
            presentedControllerView.transform = CGAffineTransform(translationX: 0, y: presentedControllerView.bounds.size.height)
            weakSelf?.managerDelegate?.presentationController?.presentingViewController.view.transform = CGAffineTransform.identity
            weakSelf?.managerDelegate?.presentationController?.backgroundView.alpha = 0.0
            weakSelf?.managerDelegate?.auxileryView?.alpha = 0.0
        }

        func complete(completed: Bool) {

            let finished = completed && !transitionContext.transitionWasCancelled

            transitionContext.completeTransition(finished)

            if finished {
                (weakSelf?.managerDelegate?.presentationController?.presentingViewController as? HalfSheetCompletionProtocol)?.didDismiss()
                weakSelf?.manager = nil
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
