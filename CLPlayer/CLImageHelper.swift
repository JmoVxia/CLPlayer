//
//  CLImageHelper.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/27.
//

import UIKit

public class CLImageHelper: NSObject {
    public static func imageWithName(_ name: String) -> UIImage? {
        let filePath = Bundle(for: classForCoder()).resourcePath! + "/CLPlayer.bundle"
        let bundle = Bundle(path: filePath)
        let scale = max(min(Int(UIScreen.main.scale), 2), 3)
        return .init(named: "\(name)@\(scale)x", in: bundle, compatibleWith: nil)
    }
}
