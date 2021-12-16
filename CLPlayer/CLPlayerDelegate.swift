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
    func didPlayToEndTime(in player: CLPlayer)
}
