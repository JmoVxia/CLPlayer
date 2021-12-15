//
//  CLPlayer.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import AVFoundation
import SnapKit
import UIKit

public class CLPlayer: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        print("CLPlayer deinit")
    }

    private(set) lazy var contentView: CLPlayerContentView = {
        let view = CLPlayerContentView()
        view.delegate = self
        return view
    }()

    private let keyWindow: UIWindow? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter { $0.isKeyWindow }.last
        } else {
            return UIApplication.shared.keyWindow
        }
    }()

    private lazy var sliderTimer: CLGCDTimer = {
        let timer = CLGCDTimer(interval: 0.1) { [weak self] _ in
            self?.sliderTimerAction()
        }
        return timer
    }()

    private var animationTransitioning: CLAnimationTransitioning?

    private var fullScreenController: CLFullScreenController?

    private var statusObserve: NSKeyValueObservation?

    private var loadedTimeRangesObserve: NSKeyValueObservation?

    private var playbackBufferEmptyObserve: NSKeyValueObservation?

    private var isUserPause: Bool = false

    private var player: AVPlayer?

    private var playerLayer: AVPlayerLayer?

    private var playerItem: AVPlayerItem? {
        didSet {
            guard playerItem != oldValue else { return }
            if let oldPlayerItem = oldValue {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldPlayerItem)
            }
            guard let playerItem = playerItem else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidToEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

            statusObserve = playerItem.observe(\.status, options: [.new]) { [weak self] _, _ in
                self?.observeStatusAction()
            }
            loadedTimeRangesObserve = playerItem.observe(\.loadedTimeRanges, options: [.new]) { [weak self] _, _ in
                self?.observeLoadedTimeRangesAction()
            }
            playbackBufferEmptyObserve = playerItem.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] _, _ in
                self?.observePlaybackBufferEmptyAction()
            }
        }
    }

    private var totalDuration: TimeInterval = .zero {
        didSet {
            guard totalDuration != oldValue else { return }
            contentView.setTotalDuration(totalDuration)
        }
    }

    private var currentDuration: TimeInterval = .zero {
        didSet {
            guard currentDuration != oldValue else { return }
            contentView.setCurrentDuration(currentDuration)
        }
    }

    private var rate: Float = 1.0 {
        didSet {
            guard rate != oldValue else { return }
            play()
        }
    }

    private var videoGravity: AVLayerVideoGravity = .resizeAspectFill {
        didSet {
            guard videoGravity != oldValue else { return }
            playerLayer?.videoGravity = videoGravity
        }
    }

    public var url: URL? {
        didSet {
            guard let url = url else { return }
            resetPlayer()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback)
                try session.setActive(true)
            } catch {
                print("set session error:\(error)")
            }
            playerItem = AVPlayerItem(asset: .init(url: url))
            player = AVPlayer(playerItem: playerItem)
            playerLayer = layer as? AVPlayerLayer
            playerLayer?.videoGravity = videoGravity
            playerLayer?.player = player

            play()
        }
    }
}

// MARK: - JmoVxia---override

public extension CLPlayer {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
}

// MARK: - JmoVxia---布局

private extension CLPlayer {
    func initUI() {
        backgroundColor = .black
        addSubview(contentView)
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func makeConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---objc

@objc private extension CLPlayer {
    func playerDidToEnd() {
        contentView.playState = .end
        sliderTimer.suspend()
    }

    func deviceOrientationDidChange() {
        switch UIDevice.current.orientation {
        case .portrait:
            dismiss()
        case .landscapeLeft:
            presentController(CLFullScreenRightController())
        case .landscapeRight:
            presentController(CLFullScreenLeftController())
        default:
            break
        }
    }

    func appDidEnterBackground() {
        pause()
    }

    func appDidEnterPlayground() {
        play()
    }
}

// MARK: - JmoVxia---observe

private extension CLPlayer {
    func observeStatusAction() {
        if player?.currentItem?.status == .readyToPlay {
            guard let playerItem = playerItem else { return }
            contentView.playState = .readyToPlay
            totalDuration = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
            sliderTimer.start()
        } else if player?.currentItem?.status == .failed {
            contentView.playState = .failed
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

private extension CLPlayer {
    func availableDuration() -> TimeInterval? {
        guard let timeRange = player?.currentItem?.loadedTimeRanges.first?.timeRangeValue else { return nil }
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        return .init(startSeconds + durationSeconds)
    }

    func bufferingSomeSecond() {
        contentView.playState = .buffering
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.play()
        }
    }

    func sliderTimerAction() {
        guard let playerItem = playerItem else { return }
        guard playerItem.duration.timescale != .zero else { return }

        currentDuration = CMTimeGetSeconds(playerItem.currentTime())

        let value = currentDuration / totalDuration
        contentView.setSliderProgress(Float(value), animated: false)
    }

    func resetPlayer() {
        statusObserve?.invalidate()
        loadedTimeRangesObserve?.invalidate()
        playbackBufferEmptyObserve?.invalidate()

        statusObserve = nil
        loadedTimeRangesObserve = nil
        playbackBufferEmptyObserve = nil

        playerItem = nil
        player = nil
        playerLayer = nil

        contentView.playState = .unknow
        contentView.setProgress(0, animated: false)
        contentView.setSliderProgress(0, animated: false)
        contentView.setTotalDuration(0)
        contentView.setCurrentDuration(0)
        sliderTimer.resume()
    }
}

// MARK: - JmoVxia---Screen

private extension CLPlayer {
    func dismiss() {
        guard contentView.screenState == .fullScreen else { return }
        guard let controller = fullScreenController else { return }
        contentView.screenState = .animating
        controller.dismiss(animated: true, completion: {
            self.contentView.screenState = .small
        })
        fullScreenController = nil
    }

    func presentController(_ controller: CLFullScreenController) {
        guard contentView.screenState == .small else { return }
        guard let rootViewController = keyWindow?.rootViewController else { return }
        contentView.screenState = .animating
        fullScreenController = controller
        fullScreenController?.transitioningDelegate = self
        fullScreenController?.modalPresentationStyle = .fullScreen
        rootViewController.present(fullScreenController!, animated: true, completion: {
            self.contentView.screenState = .fullScreen
        })
    }
}

// MARK: - JmoVxia---公共方法

public extension CLPlayer {
    func pause() {
        contentView.playState = .pause
        player?.pause()
        sliderTimer.suspend()
    }

    func play() {
        guard let playerItem = playerItem else { return }
        guard !isUserPause else { return }
        if contentView.playState == .end {
            player?.seek(to: CMTimeMake(value: 0, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        }
        guard playerItem.isPlaybackLikelyToKeepUp else {
            bufferingSomeSecond()
            return
        }
        contentView.playState = .playing
        player?.play()
        player?.rate = rate
        sliderTimer.resume()
    }
}

// MARK: - JmoVxia---UIViewControllerTransitioningDelegate

extension CLPlayer: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationTransitioning = CLAnimationTransitioning(playView: self)
        animationTransitioning?.animationType = .present
        return animationTransitioning
    }

    public func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationTransitioning?.animationType = .dismiss
        return animationTransitioning
    }
}

// MARK: - JmoVxia---CLPlayerContentViewDelegate

extension CLPlayer: CLPlayerContentViewDelegate {
    func sliderTouchBegan(_: CLSlider, in _: CLPlayerContentView) {
        pause()
    }

    func sliderValueChanged(_ slider: CLSlider, in _: CLPlayerContentView) {
        currentDuration = totalDuration * TimeInterval(slider.value)
        let dragedCMTime = CMTimeMake(value: Int64(ceil(currentDuration)), timescale: 1)
        player?.seek(to: dragedCMTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func sliderTouchEnded(_ slider: CLSlider, in _: CLPlayerContentView) {
        guard let playerItem = playerItem else { return }
        if slider.value == 1 {
            playerDidToEnd()
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
        dismiss()
    }

    func didClickPlayButton(isPlay: Bool, in _: CLPlayerContentView) {
        isUserPause = isPlay
        isPlay ? pause() : play()
    }

    func didClickFullButton(isFull: Bool, in _: CLPlayerContentView) {
        isFull ? dismiss() : presentController(CLFullScreenRightController())
    }

    func didChangeRate(_ rate: Float, in _: CLPlayerContentView) {
        self.rate = rate
    }

    func didChangeVideoGravity(_ videoGravity: AVLayerVideoGravity, in _: CLPlayerContentView) {
        self.videoGravity = videoGravity
    }
}
