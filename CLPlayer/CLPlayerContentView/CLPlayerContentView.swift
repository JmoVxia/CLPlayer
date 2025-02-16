//
//  CLPlayerContentView.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//
import AVFoundation
import MediaPlayer
import SnapKit
import UIKit

// MARK: - JmoVxia---枚举

extension CLPlayerContentView {
    enum CLPlayerScreenState {
        case small
        case animating
        case fullScreen
    }

    enum CLPlayerPlayState {
        case unknow
        case waiting
        case readyToPlay
        case playing
        case buffering
        case failed
        case pause
        case ended
        var canFastForward: Bool {
            switch self {
            case .unknow, .waiting, .failed:
                return false
            case .readyToPlay, .playing, .pause, .buffering, .ended:
                return true
            }
        }
    }

    enum CLPanDirection {
        case unknow
        case horizontal
        case leftVertical
        case rightVertical
    }
}

class CLPlayerContentView: UIView {
    init(config: CLPlayerConfigure) {
        self.config = config
        super.init(frame: .zero)
        initSubViews()
        makeConstraints()
        updateConfig()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var placeholderStackView: UIStackView = {
        let view = UIStackView()
        view.isHidden = true
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        view.insetsLayoutMarginsFromSafeArea = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .zero
        view.spacing = 0
        return view
    }()

    private lazy var topToolView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        return view
    }()

    private lazy var bottomToolView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        return view
    }()

    private lazy var bottomContentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var bottomSafeView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var loadingView: CLRotateAnimationView = {
        let view = CLRotateAnimationView(frame: .init(x: 0, y: 0, width: 40, height: 40))
        view.startAnimation()
        return view
    }()

    private lazy var backButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        return view
    }()

    private lazy var moreButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var playButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(playButtonAction(_:)), for: .touchUpInside)
        return view
    }()

    private lazy var fullButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(fullButtonAction(_:)), for: .touchUpInside)
        return view
    }()

    private lazy var currentDurationLabel: UILabel = {
        let view = UILabel()
        view.text = "00:00"
        view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    private lazy var totalDurationLabel: UILabel = {
        let view = UILabel()
        view.text = "00:00"
        view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 1
        view.trackTintColor = .white.withAlphaComponent(0.35)
        view.progressTintColor = .white.withAlphaComponent(0.5)
        return view
    }()

    private lazy var sliderView: CLSlider = {
        let view = CLSlider()
        view.isUserInteractionEnabled = false
        view.maximumValue = 1
        view.minimumValue = 0
        view.minimumTrackTintColor = .white
        view.addTarget(self, action: #selector(progressSliderTouchBegan(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
        view.addTarget(self, action: #selector(progressSliderTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        return view
    }()

    private lazy var failButton: UIButton = {
        let view = UIButton()
        view.isHidden = true
        view.titleLabel?.font = .systemFont(ofSize: 14)
        view.setTitle("加载失败,点击重试", for: .normal)
        view.setTitle("加载失败,点击重试", for: .selected)
        view.setTitle("加载失败,点击重试", for: .highlighted)
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.white, for: .selected)
        view.setTitleColor(.white, for: .highlighted)
        view.addTarget(self, action: #selector(failButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var morePanelCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        layout.sectionInset = .zero
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(CLPlayerContentPanelHeadView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CLPlayerContentPanelHeadView")
        view.register(CLPlayerContentPanelCell.classForCoder(), forCellWithReuseIdentifier: "CLPlayerContentPanelCell")
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.alwaysBounceVertical = true
        view.isExclusiveTouch = true
        return view
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        gesture.delegate = self
        return gesture
    }()

    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panDirection(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.delaysTouchesBegan = true
        gesture.delaysTouchesEnded = true
        gesture.cancelsTouchesInView = true
        gesture.delegate = self
        return gesture
    }()

    private lazy var volumeSlider: UISlider? = {
        let view = MPVolumeView()
        return view.subviews.first(where: { $0 is UISlider }) as? UISlider
    }()

    private var config: CLPlayerConfigure!

    private var isShowMorePanel: Bool = false {
        didSet {
            guard isShowMorePanel != oldValue else { return }
            if isShowMorePanel {
                hiddenToolView()
                morePanelCollectionView.snp.updateConstraints { make in
                    make.right.equalTo(0)
                }
            } else {
                if screenState == .fullScreen {
                    showToolView()
                }
                morePanelCollectionView.snp.updateConstraints { make in
                    make.right.equalTo(morePanelWidth)
                }
            }
            UIView.animate(withDuration: 0.25) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    private var isHiddenToolView: Bool = true

    private var panDirection: CLPanDirection = .unknow

    private var autoFadeOutTimer: CLGCDTimer?

    private var rates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]

    private var videoGravity: [(name: String, mode: AVLayerVideoGravity)] = [("适应", .resizeAspect), ("拉伸", .resizeAspectFill), ("填充", .resize)]

    private let morePanelWidth: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.382

    weak var delegate: CLPlayerContentViewDelegate?

    weak var placeholderView: UIView? {
        didSet {
            guard placeholderView != oldValue else { return }
            placeholderStackView.isHidden = placeholderView == nil
            if let newView = placeholderView {
                placeholderStackView.addArrangedSubview(newView)
            }
            guard let oldView = oldValue else { return }
            placeholderStackView.removeArrangedSubview(oldView)
        }
    }

    var title: NSMutableAttributedString? {
        didSet {
            guard let title = title else { return }
            titleLabel.attributedText = title
        }
    }

    var currentRate: Float = 1.0 {
        didSet {
            guard currentRate != oldValue else { return }
            morePanelCollectionView.reloadData()
            delegate?.contentView(self, didChangeRate: currentRate)
        }
    }

    var currentVideoGravity: AVLayerVideoGravity = .resizeAspectFill {
        didSet {
            guard currentVideoGravity != oldValue else { return }
            morePanelCollectionView.reloadData()
            delegate?.contentView(self, didChangeVideoGravity: currentVideoGravity)
        }
    }

    var screenState: CLPlayerScreenState = .small {
        didSet {
            guard screenState != oldValue else { return }
            switch screenState {
            case .small:
                topToolView.isHidden = config.topBarHiddenStyle != .never
                hiddenMorePanel()
            case .animating:
                break
            case .fullScreen:
                topToolView.isHidden = config.topBarHiddenStyle == .always
            }
        }
    }

    var playState: CLPlayerPlayState = .unknow {
        didSet {
            guard playState != oldValue else { return }
            switch playState {
            case .unknow:
                sliderView.isUserInteractionEnabled = false
                failButton.isHidden = true
                playButton.isSelected = false
                placeholderStackView.isHidden = placeholderView == nil
                loadingView.startAnimation()
            case .waiting:
                sliderView.isUserInteractionEnabled = false
                failButton.isHidden = true
                placeholderStackView.isHidden = true
                loadingView.startAnimation()
            case .readyToPlay:
                sliderView.isUserInteractionEnabled = true
            case .playing:
                sliderView.isUserInteractionEnabled = true
                failButton.isHidden = true
                playButton.isSelected = true
                placeholderStackView.isHidden = true
                loadingView.stopAnimation()
            case .buffering:
                sliderView.isUserInteractionEnabled = true
                failButton.isHidden = true
                placeholderStackView.isHidden = true
                loadingView.startAnimation()
            case .failed:
                sliderView.isUserInteractionEnabled = false
                failButton.isHidden = false
                loadingView.stopAnimation()
            case .pause:
                sliderView.isUserInteractionEnabled = true
                playButton.isSelected = false
            case .ended:
                sliderView.isUserInteractionEnabled = true
                failButton.isHidden = true
                playButton.isSelected = false
                placeholderStackView.isHidden = placeholderView == nil
                loadingView.stopAnimation()
            }
        }
    }
}

// MARK: - JmoVxia---布局

private extension CLPlayerContentView {
    func initSubViews() {
        clipsToBounds = true
        autoresizesSubviews = true
        isUserInteractionEnabled = true

        addSubview(topToolView)
        addSubview(bottomToolView)
        addSubview(loadingView)
        topToolView.addSubview(backButton)
        topToolView.addSubview(titleLabel)
        topToolView.addSubview(moreButton)
        bottomToolView.addSubview(bottomContentView)
        bottomToolView.addSubview(bottomSafeView)
        bottomContentView.addSubview(playButton)
        bottomContentView.addSubview(fullButton)
        bottomContentView.addSubview(currentDurationLabel)
        bottomContentView.addSubview(totalDurationLabel)
        bottomContentView.addSubview(progressView)
        bottomContentView.addSubview(sliderView)
        addSubview(failButton)
        addSubview(morePanelCollectionView)
        addSubview(placeholderStackView)

        addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)

        guard !config.isHiddenToolbarWhenStart else { return }
        autoFadeOutTooView()
    }

    func makeConstraints() {
        topToolView.snp.makeConstraints { make in
            make.top.equalTo(config.isHiddenToolbarWhenStart ? -50 : 00)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        bottomToolView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            if config.isHiddenToolbarWhenStart {
                make.top.equalTo(self.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        bottomSafeView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
        bottomContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalTo(bottomSafeView.snp.top)
        }
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(40)
        }
        backButton.snp.makeConstraints { make in
            make.left.equalTo(-40)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(15)
            make.right.equalTo(moreButton.snp.left).offset(-15)
            make.centerY.height.equalToSuperview()
        }
        moreButton.snp.makeConstraints { make in
            make.right.equalTo(40)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
        }
        playButton.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
        }
        fullButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
        }
        currentDurationLabel.snp.makeConstraints { make in
            make.left.equalTo(playButton.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        totalDurationLabel.snp.makeConstraints { make in
            make.right.equalTo(fullButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        progressView.snp.makeConstraints { make in
            make.left.equalTo(currentDurationLabel.snp.right).offset(15 + config.thumbImageOffset)
            make.centerY.equalToSuperview()
            make.height.equalTo(2)
            make.right.equalTo(totalDurationLabel.snp.left).offset(-15 - config.thumbImageOffset)
        }
        sliderView.snp.makeConstraints { make in
            make.left.equalTo(progressView).offset(-1)
            make.right.equalTo(progressView).offset(1)
            make.height.equalTo(30)
            make.centerY.equalTo(progressView)
        }
        failButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        morePanelCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(morePanelWidth)
            make.width.equalTo(morePanelWidth)
        }
        placeholderStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateConfig() {
        currentVideoGravity = config.videoGravity
        topToolView.isHidden = screenState == .small ? config.topBarHiddenStyle != .never : config.topBarHiddenStyle == .always
        moreButton.isHidden = config.isHiddenMorePanel
        topToolView.backgroundColor = config.color.topToobar
        bottomToolView.backgroundColor = config.color.bottomToolbar
        progressView.trackTintColor = config.color.progress
        progressView.progressTintColor = config.color.progressBuffer
        sliderView.minimumTrackTintColor = config.color.progressFinished
        loadingView.updateWithConfigure { $0.backgroundColor = self.config.color.loading }
        isHiddenToolView = config.isHiddenToolbarWhenStart

        backButton.setImage(config.image.back, for: .normal)
        moreButton.setImage(config.image.more, for: .normal)
        playButton.setImage(config.image.play, for: .normal)
        playButton.setImage(config.image.pause, for: .selected)
        fullButton.setImage(config.image.max, for: .normal)
        fullButton.setImage(config.image.min, for: .selected)
        sliderView.setThumbImage(config.image.thumb, for: .normal)
        sliderView.verticalSliderOffset = config.thumbImageOffset
        sliderView.thumbClickableOffset = config.thumbClickableOffset
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLPlayerContentView {
    func tapAction() {
        if isShowMorePanel {
            isShowMorePanel = false
        } else {
            isHiddenToolView ? showToolView() : hiddenToolView()
        }
    }

    func panDirection(_ pan: UIPanGestureRecognizer) {
        let locationPoint = pan.location(in: self)
        let veloctyPoint = pan.velocity(in: self)
        switch pan.state {
        case .began:
            if abs(veloctyPoint.x) > abs(veloctyPoint.y) {
                panDirection = .horizontal
            } else {
                panDirection = locationPoint.x < bounds.width * 0.5 ? .leftVertical : .rightVertical
            }
        case .changed:
            switch panDirection {
            case .horizontal:
                break
            case .leftVertical:
                UIScreen.main.brightness -= veloctyPoint.y / 10000
            case .rightVertical:
                volumeSlider?.value -= Float(veloctyPoint.y / 10000)
            default:
                break
            }
        case .ended, .cancelled:
            panDirection = .unknow
        default:
            break
        }
    }

    func backButtonAction() {
        delegate?.didClickBackButton(in: self)
    }

    func moreButtonAction() {
        showMorePanel()
    }

    func playButtonAction(_ button: UIButton) {
        delegate?.contentView(self, didClickPlayButton: button.isSelected)
    }

    func fullButtonAction(_ button: UIButton) {
        delegate?.contentView(self, didClickFullButton: button.isSelected)
    }

    func failButtonAction() {
        delegate?.didClickFailButton(in: self)
    }

    func progressSliderTouchBegan(_ slider: CLSlider) {
        cancelAutoFadeOutTooView()
        delegate?.contentView(self, sliderTouchBegan: slider)
    }

    func progressSliderValueChanged(_ slider: CLSlider) {
        delegate?.contentView(self, sliderValueChanged: slider)
    }

    func progressSliderTouchEnded(_ slider: CLSlider) {
        autoFadeOutTooView()
        delegate?.contentView(self, sliderTouchEnded: slider)
    }
}

// MARK: - JmoVxia---私有方法

private extension CLPlayerContentView {
    func showMorePanel() {
        isShowMorePanel = true
    }

    func hiddenMorePanel() {
        isShowMorePanel = false
    }

    func showToolView() {
        isHiddenToolView = false
        topToolView.snp.updateConstraints { make in
            make.top.equalTo(0)
        }
        bottomToolView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            self.autoFadeOutTooView()
        }
    }

    func hiddenToolView() {
        isHiddenToolView = true
        topToolView.snp.updateConstraints { make in
            make.top.equalTo(-50)
        }
        bottomToolView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
        }
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            self.cancelAutoFadeOutTooView()
        }
    }

    func autoFadeOutTooView() {
        guard config.autoFadeOut > .zero, config.autoFadeOut != .greatestFiniteMagnitude else { return }
        autoFadeOutTimer = CLGCDTimer(interval: 0.25 + config.autoFadeOut, initialDelay: 0.25 + config.autoFadeOut)
        autoFadeOutTimer?.run { [weak self] _ in
            self?.hiddenToolView()
        }
    }

    func cancelAutoFadeOutTooView() {
        autoFadeOutTimer = nil
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let time = Int(ceil(duration))
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return hours == 0 ? String(format: "%02ld:%02ld", minutes, seconds) : String(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
    }
}

// MARK: - JmoVxia---公共方法

extension CLPlayerContentView {
    func animationLayout(safeAreaInsets: UIEdgeInsets, to screenState: CLPlayerScreenState) {
        bottomSafeView.snp.updateConstraints { make in
            make.height.equalTo(safeAreaInsets.bottom)
        }
        backButton.snp.updateConstraints { make in
            make.left.equalTo(screenState == .small ? -40 : safeAreaInsets.left + 10)
        }
        titleLabel.snp.updateConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(screenState == .small ? 15 : 10)
            make.right.equalTo(moreButton.snp.left).offset(screenState == .small ? -15 : -10)
        }
        moreButton.snp.updateConstraints { make in
            make.right.equalTo(screenState == .small ? 40 : -safeAreaInsets.left - 10)
        }
        playButton.snp.updateConstraints { make in
            make.left.equalTo(safeAreaInsets.left + 10)
        }
        fullButton.snp.updateConstraints { make in
            make.right.equalTo(-safeAreaInsets.right - 10)
        }

        fullButton.isSelected = screenState == .fullScreen

        topToolView.isHidden = screenState == .small ? config.topBarHiddenStyle != .never : config.topBarHiddenStyle == .always
    }

    func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(min(max(0, progress), 1), animated: animated)
    }

    func setSliderProgress(_ progress: Float, animated: Bool) {
        sliderView.setValue(min(max(0, progress), 1), animated: animated)
    }

    func setTotalDuration(_ totalDuration: TimeInterval) {
        totalDurationLabel.text = formatDuration(totalDuration)
    }

    func setCurrentDuration(_ currentDuration: TimeInterval) {
        currentDurationLabel.text = formatDuration(currentDuration)
    }
}

extension CLPlayerContentView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexPath.section == 0 ? (currentRate = rates[indexPath.row]) : (currentVideoGravity = videoGravity[indexPath.row].mode)
    }
}

extension CLPlayerContentView: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor(morePanelWidth / (indexPath.section == 0 ? 5 : 3)), height: 40)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: morePanelWidth, height: 40)
    }
}

extension CLPlayerContentView: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? rates.count : videoGravity.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CLPlayerContentPanelHeadView", for: indexPath)
            (headView as? CLPlayerContentPanelHeadView)?.title = indexPath.section == 0 ? "播放速度" : "填充模式"
            return headView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CLPlayerContentPanelCell", for: indexPath)
        if let cell = cell as? CLPlayerContentPanelCell {
            cell.isCurrent = indexPath.section == 0 ? (rates[indexPath.row] == currentRate) : (videoGravity[indexPath.row].mode == currentVideoGravity)
            cell.title = indexPath.section == 0 ? "\(rates[indexPath.row])" : "\(videoGravity[indexPath.row].name)"
        }
        return cell
    }
}

extension CLPlayerContentView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !placeholderStackView.isHidden {
            return false
        } else if morePanelCollectionView.bounds.contains(touch.location(in: morePanelCollectionView)) {
            return false
        } else if topToolView.bounds.contains(touch.location(in: topToolView)) {
            return false
        } else if bottomToolView.bounds.contains(touch.location(in: bottomToolView)) {
            return false
        } else if gestureRecognizer == panGesture {
            guard screenState != .animating else { return false }
            if config.gestureInteraction == .none { return false }
            if config.gestureInteraction == .small, screenState == .fullScreen { return false }
            if config.gestureInteraction == .fullScreen, screenState == .small { return false }
        }
        return true
    }
}
