//
//  CLPlayerView.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import AVFoundation
import SnapKit
import UIKit

extension CLPlayerView {
    enum CLWaitReadyToPlayState {
        case nomal
        case pause
        case play
    }
}

class CLPlayerView: UIView {
    init(config: CLPlayerConfigure) {
        super.init(frame: .zero)
        self.config = config
        initSubViews()
        makeConstraints()
        (layer as? AVPlayerLayer)?.videoGravity = self.config.videoGravity
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @discardableResult private func mainSync<T>(execute block: () -> T) -> T {
        guard !Thread.isMainThread else { return block() }
        return DispatchQueue.main.sync { block() }
    }

    private(set) lazy var contentView: CLPlayerContentView = {
        let view = CLPlayerContentView(config: config)
        view.delegate = self
        return view
    }()

    private var keyWindow: UIWindow? {
        mainSync {
            if #available(iOS 13.0, *) {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap(\.windows)
                    .first { $0.isKeyWindow }
            } else {
                UIApplication.shared.keyWindow
            }
        }
    }

    private var seekTime: CLPlayer.CLPlayerSeek?

    private var waitReadyToPlayState: CLWaitReadyToPlayState = .nomal

    private var sliderTimer: CLGCDTimer?

    private var bufferTimer: CLGCDTimer?

    private var config = CLPlayerConfigure()

    private var animationTransitioning: CLAnimationTransitioning?

    private var fullScreenController: CLFullScreenController?

    private var statusObserve: NSKeyValueObservation?

    private var loadedTimeRangesObserve: NSKeyValueObservation?

    private var playbackBufferEmptyObserve: NSKeyValueObservation?

    private var isUserPause: Bool = false

    private var isEnterBackground: Bool = false

    private var player: AVPlayer?

    private var playerItem: AVPlayerItem? {
        didSet {
            guard playerItem != oldValue else { return }
            if let oldPlayerItem = oldValue {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldPlayerItem)
            }
            guard let playerItem = playerItem else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(didPlaybackEnds), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

            statusObserve = playerItem.observe(\.status, options: [.new]) { [weak self] _, _ in
                self?.observeStatusAction()
            }
        }
    }

    private(set) var totalDuration: TimeInterval = .zero {
        didSet {
            guard totalDuration != oldValue else { return }
            contentView.setTotalDuration(totalDuration)
        }
    }

    private(set) var currentDuration: TimeInterval = .zero {
        didSet {
            guard currentDuration != oldValue else { return }
            contentView.setCurrentDuration(min(currentDuration, totalDuration))
        }
    }

    private(set) var playbackProgress: CGFloat = .zero {
        didSet {
            guard playbackProgress != oldValue else { return }
            contentView.setSliderProgress(Float(playbackProgress), animated: false)
            let oldIntValue = Int(oldValue * 100)
            let intValue = Int(playbackProgress * 100)
            if intValue != oldIntValue {
                DispatchQueue.main.async {
                    self.playProgressChanged?(CGFloat(intValue) / 100)
                }
            }
        }
    }

    private(set) var rate: Float = 1.0 {
        didSet {
            guard rate != oldValue else { return }
            play()
        }
    }

    var isFullScreen: Bool {
        return contentView.screenState == .fullScreen
    }

    var isPlaying: Bool {
        return contentView.playState == .playing
    }

    var isBuffering: Bool {
        return contentView.playState == .buffering
    }

    var isFailed: Bool {
        return contentView.playState == .failed
    }

    var isPaused: Bool {
        return contentView.playState == .pause
    }

    var isEnded: Bool {
        return contentView.playState == .ended
    }

    var title: NSMutableAttributedString? {
        didSet {
            guard let title = title else { return }
            contentView.title = title
        }
    }

    var url: URL? {
        didSet {
            guard let url = url else { return }
            stop()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback)
                try session.setActive(true)
            } catch {
                print("set session error:\(error)")
            }
            playerItem = AVPlayerItem(asset: .init(url: url))
            player = AVPlayer(playerItem: playerItem)
            (layer as? AVPlayerLayer)?.player = player
        }
    }

    weak var placeholder: UIView? {
        didSet {
            contentView.placeholderView = placeholder
        }
    }

    var backButtonTappedHandler: (() -> Void)?

    var playToEndHandler: (() -> Void)?

    var playProgressChanged: ((CGFloat) -> Void)?

    var playFailed: ((Error?) -> Void)?
}

// MARK: - JmoVxia---override

extension CLPlayerView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
}

// MARK: - JmoVxia---布局

private extension CLPlayerView {
    func initSubViews() {
        backgroundColor = .black
        addSubview(contentView)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayground), name: UIApplication.didBecomeActiveNotification, object: nil)
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func makeConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLPlayerView {
    func didPlaybackEnds() {
        currentDuration = totalDuration
        playbackProgress = 1.0
        contentView.playState = .ended
        sliderTimer?.pause()
        DispatchQueue.main.async {
            self.playToEndHandler?()
        }
    }

    func deviceOrientationDidChange() {
        guard config.rotateStyle != .none else { return }
        if config.rotateStyle == .small, isFullScreen { return }
        if config.rotateStyle == .fullScreen, !isFullScreen { return }
        DispatchQueue.main.async {
            switch UIDevice.current.orientation {
            case .portrait:
                self.dismiss()
            case .landscapeLeft:
                self.presentWithOrientation(.left)
            case .landscapeRight:
                self.presentWithOrientation(.right)
            default:
                break
            }
        }
    }

    func appDidEnterBackground() {
        isEnterBackground = true
        pause()
    }

    func appDidEnterPlayground() {
        isEnterBackground = false
        guard contentView.playState != .ended else { return }
        play()
    }
}

// MARK: - JmoVxia---observe

private extension CLPlayerView {
    func observeStatusAction() {
        guard let playerItem = playerItem else { return }
        if playerItem.status == .readyToPlay {
            contentView.playState = .readyToPlay
            totalDuration = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)

            sliderTimer = CLGCDTimer(interval: 0.1)
            sliderTimer?.run { [weak self] _ in
                self?.sliderTimerAction()
            }

            loadedTimeRangesObserve = playerItem.observe(\.loadedTimeRanges, options: [.new]) { [weak self] _, _ in
                self?.observeLoadedTimeRangesAction()
            }

            playbackBufferEmptyObserve = playerItem.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] _, _ in
                self?.observePlaybackBufferEmptyAction()
            }
            if let seekTime {
                player?.seek(to: seekTime.time, toleranceBefore: seekTime.toleranceBefore, toleranceAfter: seekTime.toleranceAfter)
                self.seekTime = nil
            }

            switch waitReadyToPlayState {
            case .nomal:
                break
            case .pause:
                pause()
            case .play:
                play()
            }
        } else if playerItem.status == .failed {
            contentView.playState = .failed
            DispatchQueue.main.async {
                self.playFailed?(playerItem.error)
            }
        }
    }

    func observeLoadedTimeRangesAction() {
        guard let timeInterval = availableDuration() else { return }
        guard let duration = playerItem?.duration else { return }
        let totalDuration = TimeInterval(CMTimeGetSeconds(duration))
        contentView.setProgress(Float(timeInterval / totalDuration), animated: false)
    }

    func observePlaybackBufferEmptyAction() {
        guard playerItem?.isPlaybackBufferEmpty ?? false else { return }
        bufferingSomeSecond()
    }
}

private extension CLPlayerView {
    func availableDuration() -> TimeInterval? {
        guard let timeRange = playerItem?.loadedTimeRanges.first?.timeRangeValue else { return nil }
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        return .init(startSeconds + durationSeconds)
    }

    func bufferingSomeSecond() {
        guard playerItem?.status == .readyToPlay else { return }
        guard contentView.playState != .failed else { return }

        player?.pause()
        sliderTimer?.pause()

        contentView.playState = .buffering
        bufferTimer = CLGCDTimer(interval: 3.0, initialDelay: 3.0)
        bufferTimer?.run { [weak self] _ in
            guard let playerItem = self?.playerItem else { return }
            self?.bufferTimer = nil
            if playerItem.isPlaybackLikelyToKeepUp {
                self?.play()
            } else {
                self?.bufferingSomeSecond()
            }
        }
    }

    func sliderTimerAction() {
        guard let playerItem = playerItem else { return }
        guard playerItem.duration.timescale != .zero else { return }

        currentDuration = CMTimeGetSeconds(playerItem.currentTime())
        playbackProgress = currentDuration / totalDuration
    }
}

// MARK: - JmoVxia---Screen

private extension CLPlayerView {
    func findTop(from rootViewController: UIViewController?) -> UIViewController? {
        guard let root = rootViewController else { return nil }
        if let nav = root as? UINavigationController { return findTop(from: nav.visibleViewController) }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController { return findTop(from: selected) }
        if let presented = root.presentedViewController, !(presented is UIAlertController) { return findTop(from: presented) }
        return root
    }

    func dismiss() {
        guard Thread.isMainThread else { return DispatchQueue.main.async { self.dismiss() } }
        guard contentView.screenState == .fullScreen else { return }
        guard let controller = fullScreenController else { return }
        contentView.screenState = .animating
        controller.dismiss(animated: true, completion: {
            self.contentView.screenState = .small
            self.fullScreenController = nil
        })
    }

    func presentWithOrientation(_ orientation: CLAnimationTransitioning.AnimationOrientation) {
        guard Thread.isMainThread else { return DispatchQueue.main.async { self.presentWithOrientation(orientation) } }
        guard superview != nil else { return }
        guard fullScreenController == nil else { return }
        guard contentView.screenState == .small else { return }
        guard let topController = findTop(from: keyWindow?.rootViewController) else { return }
        contentView.screenState = .animating

        animationTransitioning = CLAnimationTransitioning(playerView: self, animationOrientation: orientation)

        fullScreenController = orientation == .right ? CLFullScreenLeftController() : CLFullScreenRightController()
        fullScreenController?.transitioningDelegate = self
        fullScreenController?.modalPresentationStyle = .fullScreen
        topController.present(fullScreenController!, animated: true, completion: {
            self.contentView.screenState = .fullScreen
        })
    }
}

// MARK: - JmoVxia---公共方法

extension CLPlayerView {
    func play() {
        guard !isEnterBackground else { return }
        guard !isUserPause else { return }
        guard let playerItem = playerItem else { return }
        guard playerItem.status == .readyToPlay else {
            contentView.playState = .waiting
            waitReadyToPlayState = .play
            return
        }
        guard playerItem.isPlaybackLikelyToKeepUp else {
            bufferingSomeSecond()
            return
        }
        if contentView.playState == .ended {
            player?.seek(to: CMTimeMake(value: 0, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        }
        contentView.playState = .playing
        player?.play()
        player?.rate = rate
        sliderTimer?.resume()
        waitReadyToPlayState = .nomal
        bufferTimer = nil
    }

    func pause() {
        guard playerItem?.status == .readyToPlay else {
            waitReadyToPlayState = .pause
            return
        }
        contentView.playState = .pause
        player?.pause()
        sliderTimer?.pause()
        bufferTimer = nil
        waitReadyToPlayState = .nomal
    }

    func stop() {
        statusObserve?.invalidate()
        loadedTimeRangesObserve?.invalidate()
        playbackBufferEmptyObserve?.invalidate()

        statusObserve = nil
        loadedTimeRangesObserve = nil
        playbackBufferEmptyObserve = nil

        playerItem = nil
        player = nil

        isUserPause = false

        waitReadyToPlayState = .nomal

        contentView.playState = .unknow
        contentView.setProgress(0, animated: false)
        playbackProgress = 0
        totalDuration = 0
        currentDuration = 0
        sliderTimer = nil
        seekTime = nil
    }

    func seek(to time: CLPlayer.CLPlayerSeek) {
        if contentView.playState.canFastForward {
            player?.seek(to: time.time, toleranceBefore: time.toleranceBefore, toleranceAfter: time.toleranceAfter)
        } else {
            seekTime = time
        }
    }
}

// MARK: - JmoVxia---UIViewControllerTransitioningDelegate

extension CLPlayerView: UIViewControllerTransitioningDelegate {
    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationTransitioning?.animationType = .present
        return animationTransitioning
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationTransitioning?.animationType = .dismiss
        return animationTransitioning
    }
}

// MARK: - JmoVxia---CLPlayerContentViewDelegate

extension CLPlayerView: CLPlayerContentViewDelegate {
    func contentView(_ contentView: CLPlayerContentView, didClickPlayButton isPlay: Bool) {
        isUserPause = isPlay
        isPlay ? pause() : play()
    }

    func contentView(_ contentView: CLPlayerContentView, didClickFullButton isFull: Bool) {
        isFull ? dismiss() : presentWithOrientation(.fullRight)
    }

    func contentView(_ contentView: CLPlayerContentView, didChangeRate rate: Float) {
        self.rate = rate
    }

    func contentView(_ contentView: CLPlayerContentView, didChangeVideoGravity videoGravity: AVLayerVideoGravity) {
        (layer as? AVPlayerLayer)?.videoGravity = videoGravity
    }

    func contentView(_ contentView: CLPlayerContentView, sliderTouchBegan slider: CLSlider) {
        pause()
    }

    func contentView(_ contentView: CLPlayerContentView, sliderValueChanged slider: CLSlider) {
        currentDuration = totalDuration * TimeInterval(slider.value)
        let dragedCMTime = CMTimeMake(value: Int64(ceil(currentDuration)), timescale: 1)
        player?.seek(to: dragedCMTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func contentView(_ contentView: CLPlayerContentView, sliderTouchEnded slider: CLSlider) {
        guard let playerItem = playerItem else { return }
        if slider.value == 1 {
            didPlaybackEnds()
        } else if playerItem.isPlaybackLikelyToKeepUp {
            play()
        } else {
            bufferingSomeSecond()
        }
    }

    func didClickFailButton(in _: CLPlayerContentView) {
        guard let url = url else { return }
        self.url = url
    }

    func didClickBackButton(in contentView: CLPlayerContentView) {
        guard contentView.screenState == .fullScreen else { return }
        DispatchQueue.main.async {
            self.dismiss()
            self.backButtonTappedHandler?()
        }
    }
}
