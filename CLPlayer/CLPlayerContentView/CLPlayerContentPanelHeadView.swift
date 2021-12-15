//
//  CLPlayerContentPanelHeadView.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/13.
//

import SnapKit
import UIKit

class CLPlayerContentPanelHeadView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
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
        view.textColor = .white.withAlphaComponent(0.6)
        view.adjustsFontSizeToFitWidth = true
        return view
    }()

    var title: String? {
        didSet {
            guard title != oldValue else { return }
            titleLabel.text = title
        }
    }
}

private extension CLPlayerContentPanelHeadView {
    func initUI() {
        addSubview(titleLabel)
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
