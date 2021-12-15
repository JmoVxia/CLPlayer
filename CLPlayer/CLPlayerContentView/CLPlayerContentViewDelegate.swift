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

    func didClickPlayButton(isPlay: Bool, in contentView: CLPlayerContentView)

    func didClickFullButton(isFull: Bool, in contentView: CLPlayerContentView)

    func didChangeRate(_ rate: Float, in contentView: CLPlayerContentView)

    func didChangeVideoGravity(_ videoGravity: AVLayerVideoGravity, in contentView: CLPlayerContentView)

    func sliderTouchBegan(_ slider: CLSlider, in contentView: CLPlayerContentView)

    func sliderValueChanged(_ slider: CLSlider, in contentView: CLPlayerContentView)

    func sliderTouchEnded(_ slider: CLSlider, in contentView: CLPlayerContentView)
}
