//
//  UIColor+CLExtension.swift
//  CKD
//
//  Created by JmoVxia on 2020/2/25.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

import UIKit

extension UIColor {
    // 16进制颜色
    class func hex(_ string: String, alpha: CGFloat = 1.0) -> UIColor {
        var hexString = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        } else if hexString.hasPrefix("0X") {
            hexString.removeFirst(2)
        }

        // 确保是6位
        guard hexString.count == 6 else {
            return UIColor.clear
        }

        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = nil

        var color: UInt64 = 0
        if scanner.scanHexInt64(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            return UIColor.clear
        }
    }

    /// 颜色16进制字符串
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        if a == 1.0 {
            return String(format: "%0.2X%0.2X%0.2X", UInt(r * 255), UInt(g * 255), UInt(b * 255))
        } else {
            return String(format: "%0.2X%0.2X%0.2X%0.2X", UInt(r * 255), UInt(g * 255), UInt(b * 255), UInt(a * 255))
        }
    }

    /// 主题色
    @objc class var themeColor: UIColor {
        return hex("2DD178")
    }

    /// 随机色
    class var randomColor: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 0.35)
    }

    // 获取反色(补色)
    var invertColor: UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: 1)
    }
}
