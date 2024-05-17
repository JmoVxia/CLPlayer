//
//  CLAnimationTransitioning.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/27.
//

import SnapKit
import UIKit

extension CLAnimationTransitioning {
    enum AnimationType {
        case present
        case dismiss
    }

    enum AnimationOrientation {
        case left
        case right
        case fullRight
    }
}

class CLAnimationTransitioning: NSObject {
    private let keyWindow: UIWindow? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter { $0.isKeyWindow }.last
        } else {
            return UIApplication.shared.keyWindow
        }
    }()

    private weak var playerView: CLPlayerView?

    private weak var parentStackView: UIStackView?

    private var initialCenter: CGPoint = .zero

    private var finalCenter: CGPoint = .zero

    private var initialBounds: CGRect = .zero

    private var animationOrientation: AnimationOrientation = .left

    var animationType: AnimationType = .present

    init(playerView: CLPlayerView, animationOrientation: AnimationOrientation) {
        self.playerView = playerView
        self.animationOrientation = animationOrientation
        parentStackView = playerView.superview as? UIStackView
        initialBounds = playerView.bounds
        initialCenter = playerView.center
        finalCenter = playerView.convert(initialCenter, to: nil)
    }
}

extension CLAnimationTransitioning: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let playerView = playerView else { return }

        if animationType == .present {
            guard let toView = transitionContext.view(forKey: .to) else { return }
            guard let toController = transitionContext.viewController(forKey: .to) as? CLFullScreenController else { return }

            let startCenter = transitionContext.containerView.convert(initialCenter, from: playerView)
            transitionContext.containerView.addSubview(toView)
            toController.mainStackView.addArrangedSubview(playerView)
            toView.bounds = initialBounds
            toView.center = startCenter
            toView.transform = .init(rotationAngle: toController.isKind(of: CLFullScreenLeftController.self) ? Double.pi * 0.5 : Double.pi * -0.5)

            if #available(iOS 11.0, *) {
                playerView.contentView.animationLayout(safeAreaInsets: keyWindow?.safeAreaInsets ?? .zero, to: .fullScreen)
            } else {
                playerView.contentView.animationLayout(safeAreaInsets: .zero, to: .fullScreen)
            }
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .layoutSubviews, animations: {
                toView.transform = .identity
                toView.bounds = transitionContext.containerView.bounds
                toView.center = transitionContext.containerView.center
                playerView.contentView.setNeedsLayout()
                playerView.contentView.layoutIfNeeded()
            }) { _ in
                toView.transform = .identity
                toView.bounds = transitionContext.containerView.bounds
                toView.center = transitionContext.containerView.center
                transitionContext.completeTransition(true)
                UIViewController.attemptRotationToDeviceOrientation()
            }
        } else {
            guard let parentStackView = parentStackView else { return }
            guard let fromView = transitionContext.view(forKey: .from) else { return }
            guard let toView = transitionContext.view(forKey: .to) else { return }

            transitionContext.containerView.addSubview(toView)
            transitionContext.containerView.addSubview(fromView)
            toView.frame = transitionContext.containerView.bounds

            playerView.contentView.animationLayout(safeAreaInsets: .zero, to: .small)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .layoutSubviews, animations: {
                fromView.transform = .identity
                fromView.center = self.finalCenter
                fromView.bounds = self.initialBounds
                playerView.contentView.setNeedsLayout()
                playerView.contentView.layoutIfNeeded()
            }) { _ in
                fromView.transform = .identity
                fromView.center = self.finalCenter
                fromView.bounds = self.initialBounds
                parentStackView.addArrangedSubview(playerView)
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
