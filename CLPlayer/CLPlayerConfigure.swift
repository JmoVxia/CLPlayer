//
//  CLPlayerConfigure.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/15.
//

import AVFoundation
import UIKit

public struct CLPlayerConfigure {
    /// 顶部工具条隐藏风格
    public enum CLPlayerTopBarHiddenStyle {
        /// 小屏和全屏都不隐藏
        case never
        /// 小屏和全屏都隐藏
        case always
        /// 小屏隐藏，全屏不隐藏
        case onlySmall
    }

    /// 自动旋转
    public var isAutoRotate = true
    /// 手势控制
    public var isGestureInteractionEnabled = true
    /// 是否显示更多面板
    public var isShowMorePanel = true
    /// 顶部工具条隐藏风格
    public var topBarHiddenStyle: CLPlayerTopBarHiddenStyle = .onlySmall
    /// 工具条自动消失时间
    public var autoFadeOut: TimeInterval = 5
    /// 默认拉伸方式
    public var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    /// 顶部工具条背景颜色
    public var topToobarBackgroundColor: UIColor = .black.withAlphaComponent(0.6)
    /// 底部工具条背景颜色
    public var bottomToolbarBackgroundColor: UIColor = .black.withAlphaComponent(0.6)
    /// 进度条背景颜色
    public var progressBackgroundColor: UIColor = .white.withAlphaComponent(0.35)
    /// 缓冲条缓冲进度颜色
    public var progressBufferColor: UIColor = .white.withAlphaComponent(0.5)
    /// 进度条播放完成颜色
    public var progressFinishedColor: UIColor = .white
    /// 转子背景颜色
    public var loadingBackgroundColor: UIColor = .white
    /// 返回按钮图片
    public var backImage: UIImage?
    /// 更多按钮图片
    public var moreImage: UIImage?
    /// 播放按钮图片
    public var playImage: UIImage?
    /// 暂停按钮图片
    public var pauseImage: UIImage?
    /// 进度滑块图片
    public var sliderImage: UIImage?
    /// 最大化按钮图片
    public var maxImage: UIImage?
    /// 最小化按钮图片
    public var minImage: UIImage?
    /// 封面图片
    public var maskImage: UIImage?
}
