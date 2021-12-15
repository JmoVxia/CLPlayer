//
//  CLController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import SnapKit
import UIKit

// MARK: - JmoVxia---类-属性

class CLController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 18)
        view.textColor = .black
        return view
    }()

    /// 导航条高度
    var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.bounds.height ?? 0
    }

    deinit {}
}

// MARK: - JmoVxia---生命周期

extension CLController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        makeConstraints()
        initData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

// MARK: - JmoVxia---布局

private extension CLController {
    func initUI() {
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        view.backgroundColor = .white
    }

    func makeConstraints() {}
}

// MARK: - JmoVxia---数据

private extension CLController {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLController {
    // 是否支持自动转屏
    override var shouldAutorotate: Bool {
        return false
    }

    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    /// 状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    /// 是否隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLController {}

// MARK: - JmoVxia---私有方法

private extension CLController {}

// MARK: - JmoVxia---公共方法

extension CLController {
    /// 更新顶部label
    func updateTitleLabel(_ viewCallback: @escaping ((UILabel) -> Void)) {
        DispatchQueue.main.async {
            viewCallback(self.titleLabel)
            self.titleLabel.sizeToFit()
        }
    }
}
