//
//  CLBackView.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import SnapKit
import UIKit

// MARK: - JmoVxia---类-属性

class CLBackView: UIControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        makeConstraints()
        initData()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var title: String = "    " {
        didSet {
            textLabel.text = title
            textLabel.sizeToFit()
            super.setNeedsLayout()
            super.layoutIfNeeded()
        }
    }

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .systemFont(ofSize: 16)
        return view
    }()

    private lazy var backimageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "back")?.tintImage(.black)
        return view
    }()
}

// MARK: - JmoVxia---布局

private extension CLBackView {
    func initUI() {
        addSubview(backimageView)
        addSubview(textLabel)
    }

    func makeConstraints() {
        backimageView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.bottom.equalTo(-5).priority(.low)
            make.top.equalTo(5).priority(.low)
        }
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(backimageView.snp.right).offset(7)
            make.centerY.equalTo(0)
            make.right.equalTo(0).priority(.high)
        }
    }
}

// MARK: - JmoVxia---数据

private extension CLBackView {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLBackView {}

// MARK: - JmoVxia---objc

@objc private extension CLBackView {}

// MARK: - JmoVxia---私有方法

private extension CLBackView {}

// MARK: - JmoVxia---公共方法

extension CLBackView {}
