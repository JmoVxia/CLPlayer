//
//  CLTableViewItem.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/14.
//

import UIKit

class CLTableViewItem: NSObject {
    var didSelectCellCallback: ((IndexPath) -> Void)?
}

extension CLTableViewItem: CLCellItemProtocol {
    func bindCell() -> UITableViewCell.Type {
        return CLTableViewCell.self
    }

    func cellHeight() -> CGFloat {
        return 300
    }
}
