//
//  DismissalAnimator.swift
//  Gametime
//
//  Created by Matt Banach on 3/24/16.
//
//

import Foundation

public class DismissalAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, AnimatorConvenience {

    weak var manager: HalfSheetPresentationManager?

    var isFromGesture: Bool = false
    var animator: UIViewPropertyAnimator?

    public init(manager: HalfSheetPresentationManager) {
        super.init()
        self.manager = manager
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isFromGesture ? TransitionConfiguration.Dismissal.durationAfterGesture : TransitionConfiguration.Dismissal.duration
    }

    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transition(using: transitionContext)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transition(using: transitionContext)
    }

    @discardableResult private func transition(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {

        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!

        weak var weakManager = manager

        let finalTransform = CGAffineTransform(translationX: 0, y: shouldSlideAuxilery ? containerHeight : presentedContentHeight )

        func animate() {
            presentedControllerView.layer.transform = finalTransform.as3D
            weakManager?.presentationController?.presentingViewContainer.layer.transform = .identity
            weakManager?.presentationController?.backgroundView.alpha = 0.0
            weakManager?.auxileryView?.alpha =  self.shouldFadeAuxilery ? 0.0 : 1.0
            weakManager?.auxileryView?.layer.transform =  self.shouldSlideAuxilery ? finalTransform.as3D : .identity
        }

        func complete(completed: Bool) {

            let finished = completed && !transitionContext.transitionWasCancelled

            if finished {
                weakManager?.dismissComplete()
            }

            transitionContext.completeTransition(finished)
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

        return animator!
    }

    override public func cancel() {
        super.cancel()

        animator?.pauseAnimation()

        let duration: CGFloat = CGFloat(TransitionConfiguration.Dismissal.duration)
        let timing = UISpringTimingParameters(dampingRatio: 0.7)

        animator?.continueAnimation(
            withTimingParameters: timing,
            durationFactor: duration
        )
    }

    override public func finish() {
        super.finish()

        animator?.pauseAnimation()

        let duration: CGFloat = CGFloat(TransitionConfiguration.Dismissal.duration)
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
