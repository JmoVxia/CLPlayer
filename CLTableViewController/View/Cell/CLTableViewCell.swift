//
//  CLTableViewCell.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/14.
//

import UIKit

// MARK: - JmoVxia---类-属性

class CLTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

private extension CLTableViewCell {
    func initUI() {
        selectionStyle = .none
        backgroundColor = UIColor.orange.withAlphaComponent(0.5)
        contentView.addSubview(iconImageView)
        iconImageView.addSubview(playImageView)
    }

    func makeConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-10)
        }
        playImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---CKDCellProtocol

extension CLTableViewCell: CLCellProtocol {
    func setItem(_ item: CLCellItemProtocol) {
        guard let _ = item as? CLTableViewItem else { return }
    }
}

// MARK: - JmoVxia---数据

private extension CLTableViewCell {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLTableViewCell {}

// MARK: - JmoVxia---objc

@objc private extension CLTableViewCell {}

// MARK: - JmoVxia---私有方法

private extension CLTableViewCell {}

// MARK: - JmoVxia---公共方法

extension CLTableViewCell {}
