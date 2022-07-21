//
//  CLPlayerContentViewDelegate.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/28.
//

import AVFoundation
import Foundation
import UIKit

protocol CLPlayerContentViewDelegate: AnyObject {
    func didClickFailButton(in contentView: CLPlayerContentView)

    func didClickBackButton(in contentView: CLPlayerContentView)

    func contentView(_ contentView: CLPlayerContentView, didClickPlayButton isPlay: Bool)

    func contentView(_ contentView: CLPlayerContentView, didClickFullButton isFull: Bool)

    func contentView(_ contentView: CLPlayerContentView, didChangeRate rate: Float)

    func contentView(_ contentView: CLPlayerContentView, didChangeVideoGravity videoGravity: AVLayerVideoGravity)

    func contentView(_ contentView: CLPlayerContentView, sliderTouchBegan slider: CLSlider)

    func contentView(_ contentView: CLPlayerContentView, sliderValueChanged slider: CLSlider)

    func contentView(_ contentView: CLPlayerContentView, sliderTouchEnded slider: CLSlider)
}
