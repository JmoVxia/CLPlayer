//
//  CLCollectionViewController.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/12/16.
//

import SnapKit
import UIKit

// MARK: - JmoVxia---枚举

extension CLCollectionViewController {}

// MARK: - JmoVxia---类-属性

class CLCollectionViewController: CLController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {}

    private lazy var collectionView: UICollectionView = {
        let width = (view.bounds.width - 30) * 0.5
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: width, height: width * 9.0 / 16.0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(CLCollectionViewCell.self, forCellWithReuseIdentifier: "CLCollectionViewCell")
        return view
    }()

    private var player: CLPlayer?

    let array = [
        "https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4",
        "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4",
        "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4",
        "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4",
        "http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4",
        "https://media.w3.org/2010/05/sintel/trailer.mp4",
        "https://cdn.cnbj1.fds.api.mi-img.com/mi-mall/7194236f31b2e1e3da0fe06cfed4ba2b.mp4",
        "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
        "http://vjs.zencdn.net/v/oceans.mp4",
        "https://media.w3.org/2010/05/sintel/trailer.mp4",
        "http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4",
        "https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_2mb.mp4",
        "https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4",
        "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4",
        "https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4",
        "https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4",
        "http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4",
        "https://media.w3.org/2010/05/sintel/trailer.mp4",
        "https://cdn.cnbj1.fds.api.mi-img.com/mi-mall/7194236f31b2e1e3da0fe06cfed4ba2b.mp4",
        "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
        "http://vjs.zencdn.net/v/oceans.mp4",
        "https://media.w3.org/2010/05/sintel/trailer.mp4",
    ]
}

// MARK: - JmoVxia---生命周期

extension CLCollectionViewController {
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

private extension CLCollectionViewController {
    func initUI() {
        updateTitleLabel { $0.text = "CollectionView" }
        view.addSubview(collectionView)
    }

    func makeConstraints() {
        collectionView.snp.makeConstraints { make in
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

private extension CLCollectionViewController {
    func initData() {}
}

// MARK: - JmoVxia---override

extension CLCollectionViewController {
    override var shouldAutorotate: Bool {
        return false
    }

    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLCollectionViewController {}

// MARK: - JmoVxia---私有方法

private extension CLCollectionViewController {
    func playWithIndexPath(_ indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        if player == nil {
            player = CLPlayer()
        }
        player?.title = NSMutableAttributedString("这是一个标题", attributes: { $0
                .font(.systemFont(ofSize: 16))
                .foregroundColor(.orange)
                .alignment(.center)
        })
        player?.url = URL(string: array[indexPath.row])
        cell.contentView.addSubview(player!)
        player?.frame = cell.contentView.bounds
        player?.play()
    }
}

// MARK: - JmoVxia---公共方法

extension CLCollectionViewController {}

extension CLCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CLCollectionViewCell", for: indexPath)
        return cell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return array.count
    }
}

extension CLCollectionViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playWithIndexPath(indexPath)
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let player = player else { return }
        guard array[indexPath.row] == player.url?.absoluteString else { return }

        cell.contentView.addSubview(player)
        player.frame = cell.contentView.bounds
        player.play()
    }

    func collectionView(_: UICollectionView, didEndDisplaying _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let player = player else { return }
        guard array[indexPath.row] == player.url?.absoluteString else { return }

        player.removeFromSuperview()
        player.pause()
    }
}
