//
//  CLAutolayoutController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/14.
//

import SnapKit
import UIKit

class CLAutolayoutController: CLController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var placeholderView: CLPlaceholderView = {
        let view = CLPlaceholderView()
        view.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return view
    }()

    private lazy var player: CLPlayer = {
        let view = CLPlayer()
        view.placeholder = placeholderView
        return view
    }()

    private lazy var changeButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = .systemFont(ofSize: 18)
        view.setTitle("切换视频", for: .normal)
        view.setTitle("切换视频", for: .selected)
        view.setTitle("切换视频", for: .highlighted)
        view.setTitleColor(.orange, for: .normal)
        view.setTitleColor(.orange, for: .selected)
        view.setTitleColor(.orange, for: .highlighted)
        view.addTarget(self, action: #selector(changeAction), for: .touchUpInside)
        return view
    }()

    deinit {
        print("CLAutolayoutController deinit")
    }
}

// MARK: - JmoVxia---生命周期

extension CLAutolayoutController {
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

private extension CLAutolayoutController {
    func initUI() {
        updateTitleLabel { $0.text = "UIView" }
        view.addSubview(player)
        view.addSubview(changeButton)
    }

    func makeConstraints() {
        player.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(view.bounds.width / (16.0 / 9.0))
        }
        changeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-150)
        }
    }
}

// MARK: - JmoVxia---数据

private extension CLAutolayoutController {
    func initData() {
        player.title = NSMutableAttributedString("Apple", attributes: { $0
                .font(.systemFont(ofSize: 16))
                .foregroundColor(.white)
                .alignment(.center)
        })
    }
}

extension CLAutolayoutController {
    override var shouldAutorotate: Bool {
        return false
    }

    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLAutolayoutController {
    func playAction() {
        placeholderView.imageView.image = UIImage(named: "placeholder")
        player.url = URL(string: "https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4")
        player.play()
    }

    func changeAction() {
        placeholderView.imageView.image = UIImage(named: "placeholder1")
        player.title = NSMutableAttributedString("这是一个标题", attributes: { $0
                .font(.systemFont(ofSize: 16))
                .foregroundColor(.white)
                .alignment(.left)
        })
        player.url = URL(string: "http://vjs.zencdn.net/v/oceans.mp4")
        player.play()
    }
}
