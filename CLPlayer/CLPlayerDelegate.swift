//
//  CLPlayerDelegate.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/15.
//

import UIKit

public protocol CLPlayerDelegate: AnyObject {
    /// 点击顶部工具条返回按钮
    func didClickBackButton(in player: CLPlayer)
    /// 视频播放结束
    func didPlayToEnd(in player: CLPlayer)
    /// 播放器播放进度变化
    func player(_ player: CLPlayer, playProgressChanged value: CGFloat)
    /// 播放器播放失败
    func player(_ player: CLPlayer, playFailed error: Error?)
}

public extension CLPlayerDelegate {
    func didClickBackButton(in player: CLPlayer) {}
    func didPlayToEnd(in player: CLPlayer) {}
    func player(_ player: CLPlayer, playProgressChanged value: CGFloat) {}
    func player(_ player: CLPlayer, playFailed error: Error?) {}
}
