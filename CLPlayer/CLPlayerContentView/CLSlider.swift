//
//  CLSlider.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/28.
//

import SnapKit
import UIKit

class CLSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var lastBounds: CGRect = .zero

    private let sliderBoundX: CGFloat = 30

    private let sliderBoundY: CGFloat = 40
}

// MARK: - JmoVxia---布局

private extension CLSlider {
    func initUI() {
        let thumbImage = CLImageHelper.imageWithName("CLSlider")
        setThumbImage(thumbImage, for: .normal)
        setThumbImage(thumbImage, for: .highlighted)
    }
}

// MARK: - JmoVxia---override

extension CLSlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        super.trackRect(forBounds: bounds)
        return .init(origin: bounds.origin, size: CGSize(width: bounds.width, height: 2))
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var rect = rect
        rect.origin.x = rect.minX - 6
        rect.size.width = rect.width + 12
        lastBounds = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        return lastBounds
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return view }
        guard point.x >= 0, point.x < bounds.width else { return view }
        guard point.y >= -15, point.y < lastBounds.height + sliderBoundY else { return view }
        return self
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = super.point(inside: point, with: event)
        guard !result else { return result }
        guard point.x >= lastBounds.minX - sliderBoundX, point.x <= lastBounds.maxX + sliderBoundX else { return result }
        guard point.y >= -sliderBoundY, point.y < lastBounds.height + sliderBoundY else { return result }
        return true
    }
}
