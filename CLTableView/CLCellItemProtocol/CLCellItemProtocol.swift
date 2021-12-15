//
//  CLCellItemProtocol.swift
//  CKD
//
//  Created by JmoVxia on 2020/3/26.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

import UIKit

protocol CLCellItemProtocol {
    /// 加载cell
    var cellForRowCallback: ((IndexPath) -> Void)? { get set }
    /// 将要显示cell
    var willDisplayCallback: ((IndexPath) -> Void)? { get set }
    /// 点击cell回调
    var didSelectCellCallback: ((IndexPath) -> Void)? { get set }
    /// 绑定cell
    func bindCell() -> UITableViewCell.Type
    /// 创建cell
    func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    /// 高度
    func cellHeight() -> CGFloat
}

extension CLCellItemProtocol {
    var cellForRowCallback: ((IndexPath) -> Void)? {
        get {
            return nil
        }
        set {}
    }

    var willDisplayCallback: ((IndexPath) -> Void)? {
        get {
            return nil
        }
        set {}
    }

    var didSelectCellCallback: ((IndexPath) -> Void)? {
        get {
            return nil
        }
        set {}
    }

    func dequeueReusableCell(tableView: UITableView, indexPath _: IndexPath) -> UITableViewCell {
        let cellClass = bindCell()
        let identifier = String(describing: cellClass)
        var tableViewCell: UITableViewCell!
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            tableViewCell = cell
        } else {
            tableViewCell = cellClass.init(style: .default, reuseIdentifier: identifier)
        }
        (tableViewCell as? CLCellProtocol)?.setItem(self)
        return tableViewCell
    }

    /// 高度
    func cellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }
}
