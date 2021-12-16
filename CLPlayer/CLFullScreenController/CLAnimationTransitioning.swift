//
//  CLAnimationTransitioning.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/27.
//

import SnapKit
import UIKit

extension CLAnimationTransitioning {
    enum CLAnimationType {
        case present
        case dismiss
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

    private weak var player: CLPlayer?

    private weak var parentView: UIView?

    private var centerInWindow: CGPoint = .zero

    private var centerInParent: CGPoint = .zero

    private var originSize: CGSize = .zero

    var animationType: CLAnimationType = .present

    init(playView: CLPlayer) {
        player = playView
        parentView = playView.superview
        centerInParent = parentView?.convert(playView.center, from: parentView) ?? .zero
        centerInWindow = keyWindow?.convert(playView.center, from: parentView) ?? .zero
        originSize = playView.frame.size
    }
}

extension CLAnimationTransitioning: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let playView = player else { return }
        if animationType == .present {
            guard let toView = transitionContext.view(forKey: .to) else { return }
            guard let toController = transitionContext.viewController(forKey: .to) else { return }

            let fromCenter = transitionContext.containerView.convert(playView.center, from: playView.superview)
            let fromSize = transitionContext.containerView.convert(playView.frame, from: nil).size

            transitionContext.containerView.addSubview(toView)
            toView.addSubview(playView)

            toView.transform = toController.isKind(of: CLFullScreenLeftController.self) ? .init(rotationAngle: Double.pi * 0.5) : .init(rotationAngle: -Double.pi * 0.5)

            toView.snp.remakeConstraints { make in
                make.center.equalTo(fromCenter)
                make.size.equalTo(fromSize)
            }
            playView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            transitionContext.containerView.setNeedsLayout()
            transitionContext.containerView.layoutIfNeeded()

            toView.snp.updateConstraints { make in
                make.center.equalTo(transitionContext.containerView.center)
                make.size.equalTo(transitionContext.containerView.bounds.size)
            }
            if #available(iOS 11.0, *) {
                playView.contentView.animationLayout(safeAreaInsets: keyWindow?.safeAreaInsets ?? .zero, to: .fullScreen)
            } else {
                playView.contentView.animationLayout(safeAreaInsets: .zero, to: .fullScreen)
            }
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .layoutSubviews, animations: {
                toView.transform = .identity
                transitionContext.containerView.setNeedsLayout()
                transitionContext.containerView.layoutIfNeeded()
                playView.contentView.setNeedsLayout()
                playView.contentView.layoutIfNeeded()
            }) { _ in
                toView.transform = .identity
                transitionContext.completeTransition(true)
                UIViewController.attemptRotationToDeviceOrientation()
            }
        } else {
            guard let parentView = parentView else { return }
            guard let fromView = transitionContext.view(forKey: .from) else { return }
            guard let toView = transitionContext.view(forKey: .to) else { return }

            toView.frame = transitionContext.containerView.bounds

            let fromCenter = CGPoint(x: toView.frame.width * 0.5, y: toView.frame.height * 0.5)
            let fromSize = transitionContext.containerView.convert(playView.frame, from: nil).size

            transitionContext.containerView.addSubview(toView)
            transitionContext.containerView.addSubview(fromView)

            fromView.snp.remakeConstraints { make in
                make.center.equalTo(fromCenter)
                make.size.equalTo(fromSize)
            }
            playView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            transitionContext.containerView.setNeedsLayout()
            transitionContext.containerView.layoutIfNeeded()

            fromView.snp.updateConstraints { make in
                make.center.equalTo(centerInWindow)
                make.size.equalTo(originSize)
            }

            playView.contentView.animationLayout(safeAreaInsets: .zero, to: .small)

            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .layoutSubviews, animations: {
                fromView.transform = .identity
                transitionContext.containerView.setNeedsLayout()
                transitionContext.containerView.layoutIfNeeded()
                playView.contentView.setNeedsLayout()
                playView.contentView.layoutIfNeeded()
            }) { _ in
                fromView.transform = .identity
                parentView.addSubview(playView)
                playView.snp.remakeConstraints { make in
                    make.center.equalTo(self.centerInParent)
                    make.size.equalTo(self.originSize)
                }
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}
