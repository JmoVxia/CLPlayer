//
//  CLListItem.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import UIKit

class CLListItem: NSObject {
    var title = ""
    var didSelectCellCallback: ((IndexPath) -> Void)?
}

extension CLListItem: CLCellItemProtocol {
    func bindCell() -> UITableViewCell.Type {
        return CLListCell.self
    }

    func cellHeight() -> CGFloat {
        return 50
    }
}
