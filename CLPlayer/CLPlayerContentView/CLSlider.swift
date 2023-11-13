import UIKit

class CLSlider: UISlider {
    private var lastThumbBounds = CGRect.zero

    var thumbClickableOffset = CGPoint(x: 30.0, y: 40.0)

    var verticalSliderOffset: CGFloat = 0.0

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let newTrackRect = super.trackRect(forBounds: bounds)
        return CGRect(origin: newTrackRect.origin, size: CGSize(width: newTrackRect.width, height: 2))
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var thumbRect = rect
        thumbRect.origin.x = thumbRect.minX - verticalSliderOffset
        thumbRect.size.width = thumbRect.width + verticalSliderOffset * 2.0
        lastThumbBounds = super.thumbRect(forBounds: bounds, trackRect: thumbRect, value: value)
        return lastThumbBounds
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return view }
        guard point.x >= 0, point.x < bounds.width else { return view }
        guard point.y >= -thumbClickableOffset.x * 0.5, point.y < lastThumbBounds.height + thumbClickableOffset.y else { return view }
        return self
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isInside = super.point(inside: point, with: event)
        guard !isInside else { return isInside }
        guard point.x >= lastThumbBounds.minX - thumbClickableOffset.x, point.x <= lastThumbBounds.maxX + thumbClickableOffset.x else { return isInside }
        guard point.y >= -thumbClickableOffset.y, point.y < lastThumbBounds.height + thumbClickableOffset.y else { return isInside }
        return true
    }
}
