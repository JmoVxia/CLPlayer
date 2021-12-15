//
//  CLListCell.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import UIKit

// MARK: - JmoVxia---类-属性

class CLListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .hex("#343434")
        view.font = .systemFont(ofSize: 15)
        return view
    }()

    private lazy var arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "meArrowRight")
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .hex("#F0F0F0")
        return view
    }()
}

// MARK: - JmoVxia---布局

private extension CLListCell {
    private func initUI() {
        isExclusiveTouch = true
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(lineView)
        arrowImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        arrowImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func makeConstraints() {
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(arrowImageView.snp.left).offset(-15)
            make.centerY.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

// MARK: - JmoVxia---CLCellProtocol

extension CLListCell: CLCellProtocol {
    func setItem(_ item: CLCellItemProtocol) {
        guard let item = item as? CLListItem else { return }
        titleLabel.text = item.title
    }
}

// MARK: - JmoVxia---数据

private extension CLListCell {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLListCell {}

// MARK: - JmoVxia---objc

@objc private extension CLListCell {}

// MARK: - JmoVxia---私有方法

private extension CLListCell {}

// MARK: - JmoVxia---公共方法

extension CLListCell {}
