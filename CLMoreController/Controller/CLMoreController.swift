//
//  CLMoreController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import SnapKit
import UIKit

// MARK: - JmoVxia---类-属性

class CLMoreController: CLController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {}

    private lazy var tableViewHepler: CLTableViewHepler = {
        let hepler = CLTableViewHepler()
        return hepler
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.dataSource = tableViewHepler
        view.delegate = tableViewHepler
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
}

// MARK: - JmoVxia---生命周期

extension CLMoreController {
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

private extension CLMoreController {
    func initUI() {
        view.addSubview(tableView)
    }

    func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
        }
    }
}

// MARK: - JmoVxia---数据

private extension CLMoreController {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLMoreController {}

// MARK: - JmoVxia---objc

@objc private extension CLMoreController {}

// MARK: - JmoVxia---私有方法

private extension CLMoreController {}

// MARK: - JmoVxia---公共方法

extension CLMoreController {}
