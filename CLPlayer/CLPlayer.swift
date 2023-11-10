//
//  CLPlayer.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2023/11/10.
//

import UIKit

// MARK: - JmoVxia---枚举

extension CLPlayer {}

// MARK: - JmoVxia---类-属性

public class CLPlayer: UIStackView {
    public init(frame: CGRect = .zero, config: ((inout CLPlayerConfigure) -> Void)? = nil) {
        super.init(frame: frame)
        config?(&self.config)
        initSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var playerView: CLPlayerView = {
        let view = CLPlayerView(config: config)
        view.backButtonTappedHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.didClickBackButton(in: self)
        }
        view.playToEndHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.didPlayToEnd(in: self)
        }
        view.playProgressChanged = { [weak self] value in
            guard let self else { return }
            self.delegate?.player(self, playProgressChanged: value)
        }
        view.playFailed = { [weak self] error in
            guard let self else { return }
            self.delegate?.player(self, playFailed: error)
        }
        return view
    }()

    private var config = CLPlayerConfigure()

    public var totalDuration: TimeInterval {
        playerView.totalDuration
    }

    public var currentDuration: TimeInterval {
        playerView.currentDuration
    }

    public var playbackProgress: CGFloat {
        playerView.playbackProgress
    }

    public var rate: Float {
        playerView.rate
    }

    public var isFullScreen: Bool {
        playerView.contentView.screenState == .fullScreen
    }

    public var isPlaying: Bool {
        playerView.contentView.playState == .playing
    }

    public var isBuffering: Bool {
        playerView.contentView.playState == .buffering
    }

    public var isFailed: Bool {
        playerView.contentView.playState == .failed
    }

    public var isPaused: Bool {
        playerView.contentView.playState == .pause
    }

    public var isEnded: Bool {
        playerView.contentView.playState == .ended
    }

    public var title: NSMutableAttributedString? {
        didSet {
            guard let title = title else { return }
            playerView.contentView.title = title
        }
    }

    public var url: URL? {
        didSet {
            guard let url = url else { return }
            playerView.url = url
        }
    }

    public weak var placeholder: UIView? {
        didSet {
            playerView.contentView.placeholderView = placeholder
        }
    }

    public weak var delegate: CLPlayerDelegate?
}

// MARK: - JmoVxia---布局

private extension CLPlayer {
    func initSubViews() {
        distribution = .fill
        alignment = .fill
        addArrangedSubview(playerView)
    }

    func makeConstraints() {}
}

// MARK: - JmoVxia---override

extension CLPlayer {}

// MARK: - JmoVxia---objc

@objc private extension CLPlayer {}

// MARK: - JmoVxia---私有方法

private extension CLPlayer {}

// MARK: - JmoVxia---公共方法

extension CLPlayer {
    func play() {
        playerView.play()
    }

    func pause() {
        playerView.pause()
    }

    func stop() {
        playerView.stop()
    }
}
