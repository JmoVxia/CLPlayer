//
//  NSMutableAttributedString+Extension.swift
//  CKD
//
//  Created by Chen JmoVxia on 2021/3/26.
//  Copyright © 2021 JmoVxia. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    /// 快捷初始化
    convenience init(_ text: String, attributes: ((AttributesItem) -> Void)? = nil) {
        let item = AttributesItem()
        attributes?(item)
        self.init(string: text, attributes: item.attributes)
    }

    /// 添加字符串并为此段添加对应的Attribute
    @discardableResult
    func addText(_ text: String, attributes: ((AttributesItem) -> Void)? = nil) -> NSMutableAttributedString {
        let item = AttributesItem()
        attributes?(item)
        append(NSMutableAttributedString(string: text, attributes: item.attributes))
        return self
    }

    /// 添加Attribute作用于当前整体字符串，如果不包含传入的attribute，则增加当前特征
    @discardableResult
    func addAttributes(_ attributes: (AttributesItem) -> Void) -> NSMutableAttributedString {
        let item = AttributesItem()
        attributes(item)
        enumerateAttributes(in: NSRange(string.startIndex ..< string.endIndex, in: string), options: .reverse) { oldAttribute, range, _ in
            var newAtt = oldAttribute
            for item in item.attributes where !oldAttribute.keys.contains(item.key) {
                newAtt[item.key] = item.value
            }
            addAttributes(newAtt, range: range)
        }
        return self
    }

    /// 添加图片
    @discardableResult
    func addImage(_ image: UIImage?, _ bounds: CGRect) -> NSMutableAttributedString {
        let attch = NSTextAttachment()
        attch.image = image
        attch.bounds = bounds
        append(NSAttributedString(attachment: attch))
        return self
    }
}

extension NSAttributedString {
    class AttributesItem {
        private(set) var attributes = [NSAttributedString.Key: Any]()
        private(set) lazy var paragraphStyle = NSMutableParagraphStyle()
        /// 字体
        @discardableResult
        func font(_ value: UIFont) -> AttributesItem {
            attributes[.font] = value
            return self
        }

        /// 字体颜色
        @discardableResult
        func foregroundColor(_ value: UIColor) -> AttributesItem {
            attributes[.foregroundColor] = value
            return self
        }

        /// 斜体
        @discardableResult
        func oblique(_ value: CGFloat) -> AttributesItem {
            attributes[.obliqueness] = value
            return self
        }

        /// 文本横向拉伸属性，正值横向拉伸文本，负值横向压缩文本
        @discardableResult
        func expansion(_ value: CGFloat) -> AttributesItem {
            attributes[.expansion] = value
            return self
        }

        /// 字间距
        @discardableResult
        func kern(_ value: CGFloat) -> AttributesItem {
            attributes[.kern] = value
            return self
        }

        /// 删除线
        @discardableResult
        func strikeStyle(_ value: NSUnderlineStyle) -> AttributesItem {
            attributes[.strikethroughStyle] = value.rawValue
            return self
        }

        /// 删除线颜色
        @discardableResult
        func strikeColor(_ value: UIColor) -> AttributesItem {
            attributes[.strikethroughColor] = value
            return self
        }

        /// 下划线
        @discardableResult
        func underlineStyle(_ value: NSUnderlineStyle) -> AttributesItem {
            attributes[.underlineStyle] = value.rawValue
            return self
        }

        /// 下划线颜色
        @discardableResult
        func underlineColor(_ value: UIColor) -> AttributesItem {
            attributes[.underlineColor] = value
            return self
        }

        /// 设置基线偏移值，正值上偏，负值下偏
        @discardableResult
        func baselineOffset(_ value: CGFloat) -> AttributesItem {
            attributes[.baselineOffset] = value
            return self
        }

        /// 居中方式
        @discardableResult
        func alignment(_ value: NSTextAlignment) -> AttributesItem {
            paragraphStyle.alignment = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }

        /// 字符截断类型
        @discardableResult
        func lineBreakMode(_ value: NSLineBreakMode) -> AttributesItem {
            paragraphStyle.lineBreakMode = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }

        /// 行间距
        @discardableResult
        func lineSpacing(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.lineSpacing = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }

        /// 最小行高
        @discardableResult
        func minimumLineHeight(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.minimumLineHeight = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }

        /// 最大行高
        @discardableResult
        func maximumLineHeight(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.maximumLineHeight = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }

        /// 段落间距
        @discardableResult
        func paragraphSpacing(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.paragraphSpacing = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
    }
}
