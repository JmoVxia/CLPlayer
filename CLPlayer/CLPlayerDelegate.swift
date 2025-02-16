//
//  CLPlayerDelegate.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/15.
//

import UIKit

public protocol CLPlayerDelegate: AnyObject {
    /// 点击顶部工具条返回按钮
    func playerDidClickBackButton(_ player: CLPlayer)
    /// 视频播放结束
    func playerDidFinishPlaying(_ player: CLPlayer)
    /// 播放器播放进度变化
    func player(_ player: CLPlayer, didUpdateProgress progress: CGFloat)
    /// 播放器播放失败
    func player(_ player: CLPlayer, didFailWithError error: Error?)
}

public extension CLPlayerDelegate {
    func playerDidClickBackButton(_ player: CLPlayer) {}
    func playerDidFinishPlaying(_ player: CLPlayer) {}
    func player(_ player: CLPlayer, didUpdateProgress progress: CGFloat) {}
    func player(_ player: CLPlayer, didFailWithError error: Error?) {}
}
