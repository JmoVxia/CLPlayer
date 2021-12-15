//
//  CLHomeController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import SnapKit
import UIKit

// MARK: - JmoVxia---类-属性

class CLHomeController: CLController {
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

extension CLHomeController {
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

private extension CLHomeController {
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

private extension CLHomeController {
    func initData() {
        do {
            let item = CLListItem()
            item.title = "Autolayout创建"
            item.didSelectCellCallback = { [weak self] _ in
                guard let self = self else { return }
                self.pushToAutolayout()
            }
            tableViewHepler.dataSource.append(item)
        }
        do {
            let item = CLListItem()
            item.title = "Frame创建"
            item.didSelectCellCallback = { [weak self] _ in
                guard let self = self else { return }
                self.pushToFrame()
            }
            tableViewHepler.dataSource.append(item)
        }
        do {
            let item = CLListItem()
            item.title = "UITableView"
            item.didSelectCellCallback = { [weak self] _ in
                guard let self = self else { return }
                self.pushToTableView()
            }
            tableViewHepler.dataSource.append(item)
        }
        tableView.reloadData()
    }
}

// MARK: - JmoVxia---override

extension CLHomeController {}

// MARK: - JmoVxia---objc

@objc private extension CLHomeController {}

// MARK: - JmoVxia---私有方法

private extension CLHomeController {
    func pushToAutolayout() {
        navigationController?.pushViewController(CLAutolayoutController(), animated: true)
    }

    func pushToFrame() {
        navigationController?.pushViewController(CLFrameController(), animated: true)
    }

    func pushToTableView() {
        navigationController?.pushViewController(CLTableViewController(), animated: true)
    }
}

// MARK: - JmoVxia---公共方法

extension CLHomeController {}
