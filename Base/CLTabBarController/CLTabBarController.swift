//
//  CLTabBarController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/25.
//

import UIKit

// MARK: - JmoVxia---类-属性

class CLTabBarController: UITabBarController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {}
}

// MARK: - JmoVxia---生命周期

extension CLTabBarController {
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

private extension CLTabBarController {
    func initUI() {
        view.backgroundColor = .white
        UITabBar.appearance().unselectedItemTintColor = .hex("#999999")
        UITabBar.appearance().tintColor = .hex("#24C065")
        addChild(child: CLHomeController(), title: "Home", image: UIImage(named: "homeNormal"), selectedImage: UIImage(named: "homeSelected"))
        addChild(child: CLMoreController(), title: "More", image: UIImage(named: "meNormal"), selectedImage: UIImage(named: "meSelected"))
    }

    func makeConstraints() {}
}

// MARK: - JmoVxia---数据

private extension CLTabBarController {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLTabBarController {
    // 是否支持自动转屏
    override var shouldAutorotate: Bool {
        guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.shouldAutorotate ?? false }
        return navigationController.topViewController?.shouldAutorotate ?? false
    }

    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.supportedInterfaceOrientations ?? .portrait }
        return navigationController.topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    // 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait }
        return navigationController.topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    /// 状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.preferredStatusBarStyle ?? .default }
        return navigationController.topViewController?.preferredStatusBarStyle ?? .default
    }

    /// 是否隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        guard let navigationController = selectedViewController as? UINavigationController else { return selectedViewController?.prefersStatusBarHidden ?? false }
        return navigationController.topViewController?.prefersStatusBarHidden ?? false
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLTabBarController {}

// MARK: - JmoVxia---私有方法

private extension CLTabBarController {
    func addChild(child: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?) {
        child.title = title
        child.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        child.tabBarItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 11)], for: .selected)
        child.tabBarItem.image = image?.withRenderingMode(.alwaysOriginal)
        child.tabBarItem.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        let navController = CLNavigationController(rootViewController: child)
        addChild(navController)
    }
}

// MARK: - JmoVxia---公共方法

extension CLTabBarController {}
