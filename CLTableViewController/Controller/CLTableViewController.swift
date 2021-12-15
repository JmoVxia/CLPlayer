//
//  CLTableViewController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import SnapKit
import UIKit

// MARK: - JmoVxia---枚举

extension CLTableViewController {}

// MARK: - JmoVxia---类-属性

class CLTableViewController: CLController {
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

    private lazy var player: CLPlayer = {
        let view = CLPlayer()
        return view
    }()
}

// MARK: - JmoVxia---生命周期

extension CLTableViewController {
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

private extension CLTableViewController {
    func initUI() {
        updateTitleLabel { $0.text = "TableView" }
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

private extension CLTableViewController {
    func initData() {
        for _ in 0 ..< 30 {
            let item = CLTableViewItem()
            item.didSelectCellCallback = { [weak self] value in
                guard let self = self else { return }
                guard let cell = self.tableView.cellForRow(at: value) else { return }
                self.playWithCell(cell)
            }
            tableViewHepler.dataSource.append(item)
        }
        tableView.reloadData()
    }
}

// MARK: - JmoVxia---override

extension CLTableViewController {}

// MARK: - JmoVxia---objc

@objc private extension CLTableViewController {}

// MARK: - JmoVxia---私有方法

private extension CLTableViewController {
    func playWithCell(_ cell: UITableViewCell) {
        player.url = URL(string: "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4")
        cell.contentView.addSubview(player)
        player.snp.remakeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: cell.bounds.width, height: cell.bounds.height - 10))
        }
    }
}

// MARK: - JmoVxia---公共方法

extension CLTableViewController {}
