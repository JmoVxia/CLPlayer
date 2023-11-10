//
//  CLPlayerContentPanelCell.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/13.
//

import SnapKit
import UIKit

class CLPlayerContentPanelCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 14)
        view.textColor = .white
        view.adjustsFontSizeToFitWidth = true
        return view
    }()

    var title: String? {
        didSet {
            guard title != oldValue else { return }
            titleLabel.text = title
        }
    }

    var isCurrent: Bool = false {
        didSet {
            guard isCurrent != oldValue else { return }
            titleLabel.textColor = isCurrent ? .orange : .white
        }
    }
}

private extension CLPlayerContentPanelCell {
    func initSubViews() {
        contentView.addSubview(titleLabel)
    }

    func makeConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-10)
        }
    }
}
