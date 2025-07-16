//
//  CLFullScreenLeftController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/27.
//

import UIKit

// MARK: - JmoVxia---类-属性

class CLFullScreenLeftController: CLFullScreenController {
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }

    deinit {}
}
