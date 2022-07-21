//
//  CLPlaceholderView.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2022/12/9.
//

import UIKit

// MARK: - JmoVxia---枚举

extension CLPlaceholderView {}

// MARK: - JmoVxia---类-属性

class CLPlaceholderView: UIControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "placeholder"))
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var playImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "play"))
        view.isUserInteractionEnabled = false
        return view
    }()
}

// MARK: - JmoVxia---布局

private extension CLPlaceholderView {
    func initSubViews() {
        addSubview(imageView)
        addSubview(playImageView)
    }

    func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---override

extension CLPlaceholderView {}

// MARK: - JmoVxia---objc

@objc private extension CLPlaceholderView {}

// MARK: - JmoVxia---私有方法

private extension CLPlaceholderView {}

// MARK: - JmoVxia---公共方法

extension CLPlaceholderView {}
