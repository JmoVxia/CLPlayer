//
//  CLCollectionViewCell.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/16.
//

import UIKit

class CLCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "placeholder")
        return view
    }()

    private lazy var playImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "play")
        return view
    }()
}

// MARK: - JmoVxia---布局

private extension CLCollectionViewCell {
    func initUI() {
        contentView.addSubview(iconImageView)
        iconImageView.addSubview(playImageView)
    }

    func makeConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
