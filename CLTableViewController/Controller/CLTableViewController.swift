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
        let hepler = CLTableViewHepler(delegate: self)
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

    private var player: CLPlayer?
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
        let array = [
            "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4",
            "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4",
            "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
            "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4",
            "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4",
            "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318214226685784.mp4",
            "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319104618910544.mp4",
            "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319125415785691.mp4",
            "http://vfx.mtime.cn/Video/2019/03/17/mp4/190317150237409904.mp4",
            "http://vfx.mtime.cn/Video/2019/03/14/mp4/190314223540373995.mp4",
            "http://vfx.mtime.cn/Video/2019/03/14/mp4/190314102306987969.mp4",
            "http://vfx.mtime.cn/Video/2019/03/13/mp4/190313094901111138.mp4",
            "http://vfx.mtime.cn/Video/2019/03/12/mp4/190312143927981075.mp4",
            "http://vfx.mtime.cn/Video/2019/03/12/mp4/190312083533415853.mp4",
            "http://vfx.mtime.cn/Video/2019/03/09/mp4/190309153658147087.mp4",
            "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4",
            "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4",
            "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4",
            "http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4",
        ]
        for string in array {
            let item = CLTableViewItem()
            item.title = NSMutableAttributedString("这是一个标题", attributes: { $0
                    .font(.systemFont(ofSize: 16))
                    .foregroundColor(.orange)
                    .alignment(.center)
            })
            item.url = URL(string: string)
            item.didSelectCellCallback = { [weak self] indexPath in
                guard let self = self else { return }
                self.playWithIndexPath(indexPath)
            }
            tableViewHepler.dataSource.append(item)
        }
        tableView.reloadData()
    }
}

// MARK: - JmoVxia---override

extension CLTableViewController {
    override var shouldAutorotate: Bool {
        return false
    }

    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLTableViewController {}

// MARK: - JmoVxia---私有方法

private extension CLTableViewController {
    func playWithIndexPath(_ indexPath: IndexPath) {
        guard let item = tableViewHepler.dataSource[indexPath.row] as? CLTableViewItem else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if player == nil {
            player = CLPlayer()
        }
        cell.contentView.addSubview(player!)
        player?.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height - 10)
        player?.title = item.title
        player?.url = item.url
        player?.play()
    }
}

extension CLTableViewController: UITableViewDelegate {
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let player = player else { return }
        let url = (tableViewHepler.dataSource[indexPath.row] as? CLTableViewItem)?.url?.absoluteString
        guard url == player.url?.absoluteString else { return }

        cell.contentView.addSubview(player)
        player.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height - 10)
        player.play()
    }

    func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let player = player else { return }
        let url = (tableViewHepler.dataSource[indexPath.row] as? CLTableViewItem)?.url?.absoluteString
        guard url == player.url?.absoluteString else { return }

        player.removeFromSuperview()
        player.pause()
    }
}
