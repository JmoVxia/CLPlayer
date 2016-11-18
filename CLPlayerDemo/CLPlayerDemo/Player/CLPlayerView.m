//
//  PlayerView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "CLPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+CLSetRect.h"
#import "UIImage+CLTintColor.h"
#import "UIImage+CLScaleToSize.h"
#import "CLSlider.h"


typedef enum : NSUInteger {
    Letf = 0,
    Right,
}Direction;


//间隙
#define Padding        10
//消失时间
#define DisappearTime  6
//顶部底部控件高度
#define ViewHeight     40
//按钮大小
#define ButtonSize     30
//滑块大小
#define SliderSize     20
//进度条颜色
#define ProgressColor     [UIColor colorWithRed:1.00000f green:1.00000f blue:1.00000f alpha:0.40000f]
//缓冲颜色
#define ProgressTintColor [UIColor colorWithRed:1.00000f green:1.00000f blue:1.00000f alpha:1.00000f]
//播放完成颜色
#define PlayFinishColor   [UIColor redColor]
//滑块颜色
#define SliderColor       [UIColor redColor]

@interface CLPlayerView ()

/**控件原始Farme*/
@property (nonatomic,assign) CGRect customFarme;
/**父类控件*/
@property (nonatomic,strong) UIView *fatherView;
/**全屏标记*/
@property (nonatomic,assign) BOOL   isFullScreen;
/**横屏标记*/
@property (nonatomic,assign) BOOL   landscape;

/**播放器*/
@property (nonatomic,strong) AVPlayer                *player;
/**playerLayer*/
@property (nonatomic,strong) AVPlayerLayer           *playerLayer;
/**播放器item*/
@property (nonatomic,strong) AVPlayerItem            *playerItem;
/**播放进度条*/
@property (nonatomic,strong) CLSlider                  *slider;
/**播放时间*/
@property (nonatomic,strong) UILabel                 *currentTimeLabel;
/**表面View*/
@property (nonatomic,strong) UIView                  *backView;
/**转子*/
@property (nonatomic,strong) UIActivityIndicatorView *activity;
/**缓冲进度条*/
@property (nonatomic,strong) UIProgressView          *progress;
/**顶部控件*/
@property (nonatomic,strong) UIView                  *topView;
/**底部控件 */
@property (nonatomic,strong) UIView                  *bottomView;
/**播放按钮*/
@property (nonatomic,strong) UIButton                *startButton;
/**轻拍定时器*/
@property (nonatomic,strong) NSTimer                 *timer;

/**返回按钮回调*/
@property (nonatomic,copy) void(^BackBlock) (UIButton *backButton);
/**播放完成回调*/
@property (nonatomic,copy) void(^EndBlock) ();

@end

@implementation CLPlayerView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _customFarme         = frame;
        _isFullScreen        = NO;
        _autoFullScreen      = YES;
        _repeatPlay          = NO;
        _isLandscape         = NO;
        _landscape           = NO;
        self.backgroundColor = [UIColor blackColor];
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
        //APP运行状态通知，将要被挂起
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}
#pragma mark - 是否自动支持全屏
- (void)setAutoFullScreen:(BOOL)autoFullScreen
{
    _autoFullScreen = autoFullScreen;
}
#pragma mark - 是否支持横屏
-(void)setIsLandscape:(BOOL)isLandscape
{
    _isLandscape = isLandscape;
    _landscape   = isLandscape;
}
#pragma mark - 重复播放
- (void)setRepeatPlay:(BOOL)repeatPlay
{
    _repeatPlay = repeatPlay;
}
#pragma mark - 传入播放地址
- (void)setUrl:(NSURL *)url
{
    self.frame                = _customFarme;
    _url                      = url;
    
    _playerItem               = [AVPlayerItem playerItemWithURL:url];
    _player                   = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer              = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame        = CGRectMake(0, 0, _customFarme.size.width, _customFarme.size.height);
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:_playerLayer];
    
    //创建原始屏幕UI
    [self originalscreen];
    
    //转子
    _activity        = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.center = _backView.center;
    [_activity startAnimating];
    [self addSubview:_activity];
    
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_player.currentItem];
}
#pragma mark - 创建播放器UI
- (void)creatUI
{
    //最上面的View
    _backView                 = [[UIView alloc]init];
    _backView.frame           = CGRectMake(0, _playerLayer.frame.origin.y, _playerLayer.frame.size.width, _playerLayer.frame.size.height);
    _backView.backgroundColor = [UIColor clearColor];
    [self addSubview:_backView];
    
    //顶部View条
    _topView                 = [[UIView alloc]init];
    _topView.frame           = CGRectMake(0, 0, _backView.width, ViewHeight);
    _topView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_backView addSubview:_topView];
    
    //底部View条
    _bottomView                 = [[UIView alloc] init];
    _bottomView.frame           = CGRectMake(0, _backView.height - ViewHeight, _backView.width, ViewHeight);
    _bottomView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_backView addSubview:_bottomView];
    
    // 监听loadedTimeRanges属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //创建播放按钮
    [self createButton];
    //创建进度条
    [self createProgress];
    //创建播放条
    [self createSlider];
    //创建时间Label
    [self createCurrentTimeLabel];
    //创建返回按钮
    [self createBackButton];
    //创建全屏按钮
    [self createMaxButton];
    //创建点击手势
    [self createGesture];
    
    //计时器，循环执行
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(timeStack)
                                   userInfo:nil
                                    repeats:YES];
    //定时器，工具条消失
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
    
}
#pragma mark - 隐藏或者显示状态栏方法
- (void)setStatusBarHidden:(BOOL)hidden
{
    //取出当前控制器的导航条
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    //设置是否隐藏
    statusBar.hidden  = hidden;
}
#pragma mark - 创建UIProgressView
- (void)createProgress
{
    CGFloat width;
    if (_isLandscape == YES)
    {
        width = self.frame.size.width;
    }
    else
    {
        if (_isFullScreen == NO)
        {
            width = self.frame.size.width;
        }
        else
        {
            width = self.frame.size.height;
        }
    }
    _progress                = [[UIProgressView alloc]init];
    _progress.frame          = CGRectMake(_startButton.right + Padding, 0, width - 80 - Padding - _startButton.right - Padding - Padding, Padding);
    _progress.centerY        = _bottomView.height/2.0;
    //进度条颜色
    _progress.trackTintColor = ProgressColor;
    
    // 计算缓冲进度
    NSTimeInterval timeInterval = [self availableDuration];
    CMTime duration             = _playerItem.duration;
    CGFloat totalDuration       = CMTimeGetSeconds(duration);
    [_progress setProgress:timeInterval / totalDuration animated:NO];
    
    CGFloat time  = round(timeInterval);
    CGFloat total = round(totalDuration);
    
    //确保都是number
    if (isnan(time) == 0 && isnan(total) == 0)
    {
        if (time == total)
        {
            //缓冲进度颜色
            _progress.progressTintColor = ProgressTintColor;
        }
        else
        {
            //缓冲进度颜色
            _progress.progressTintColor = [UIColor clearColor];
        }
    }
    else
    {
        //缓冲进度颜色
        _progress.progressTintColor = [UIColor clearColor];
    }
    [_bottomView addSubview:_progress];
}
#pragma mark - 缓存条监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = _playerItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [_progress setProgress:timeInterval / totalDuration animated:NO];
        
        //设置缓存进度颜色
        _progress.progressTintColor = ProgressTintColor;
    }
}
//计算缓冲进度
- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 创建UISlider
- (void)createSlider
{
    _slider         = [[CLSlider alloc]init];
    _slider.frame   = CGRectMake(_progress.x, 0, _progress.width, ViewHeight);
    _slider.centerY = _bottomView.height/2.0;
    [_bottomView addSubview:_slider];
    
    UIImage *image     = [self getPictureWithName:@"CLRound"];
    //改变滑块大小
    UIImage *tempImage = [image OriginImage:image scaleToSize:CGSizeMake( SliderSize, SliderSize)];
    //改变滑块颜色
    UIImage *newImage  = [tempImage imageWithTintColor:SliderColor];
    [_slider setThumbImage:newImage forState:UIControlStateNormal];
    
    //开始拖拽
    [_slider addTarget:self
                action:@selector(processSliderStartDragAction:)
      forControlEvents:UIControlEventTouchDown];
    //拖拽中
    [_slider addTarget:self
                action:@selector(sliderValueChangedAction:)
      forControlEvents:UIControlEventValueChanged];
    //结束拖拽
    [_slider addTarget:self
                action:@selector(processSliderEndDragAction:)
      forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    //左边颜色
    _slider.minimumTrackTintColor = PlayFinishColor;
    //右边颜色
    _slider.maximumTrackTintColor = [UIColor clearColor];
}
#pragma mark - 拖动进度条
//开始
- (void)processSliderStartDragAction:(UISlider *)slider
{
    //暂停
    [self pausePlay];
    [_timer invalidate];
}
//结束
- (void)processSliderEndDragAction:(UISlider *)slider
{
    //继续播放
    [self playVideo];
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
}
//拖拽中
- (void)sliderValueChangedAction:(UISlider *)slider
{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime];
}
#pragma mark - 创建播放时间
- (void)createCurrentTimeLabel
{
    _currentTimeLabel           = [[UILabel alloc]init];
    _currentTimeLabel.frame     = CGRectMake(0, 0, 80, Padding);
    _currentTimeLabel.centerY   = _progress.centerY;
    _currentTimeLabel.right     = _backView.right - Padding;
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font      = [UIFont systemFontOfSize:12];
    _currentTimeLabel.text      = @"00:00/00:00";
    [_bottomView addSubview:_currentTimeLabel];
}
#pragma mark - 计时器事件
- (void)timeStack
{
    if (_playerItem.duration.timescale != 0)
    {
        //总共时长
        _slider.maximumValue = 1;
        //当前进度
        _slider.value        = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        //当前时长进度progress
        NSInteger proMin     = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec     = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        //duration 总时长
        NSInteger durMin     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", (long)proMin, proSec, durMin, durSec];
    }
    //开始播放停止转子
    if (_player.status == AVPlayerStatusReadyToPlay)
    {
        [_activity stopAnimating];
    }
    else
    {
        [_activity startAnimating];
    }
    
}
#pragma mark - 播放按钮
- (void)createButton
{
    _startButton         = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame   = CGRectMake(Padding, 0, ButtonSize, ButtonSize);
    _startButton.centerY = _bottomView.height/2.0;
    [_bottomView addSubview:_startButton];
   
    //根据播放状态来设置播放按钮
    if (_player.rate == 1.0)
    {
        _startButton.selected = YES;
        [_startButton setBackgroundImage:[[self getPictureWithName:@"CLPauseBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    else
    {
        _startButton.selected = NO;
        [_startButton setBackgroundImage:[[self getPictureWithName:@"CLPlayBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    
    [_startButton addTarget:self
                     action:@selector(startAction:)
           forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 播放暂停按钮方法
- (void)startAction:(UIButton *)button
{
    if (button.selected == YES)
    {
        [self pausePlay];
    }
    else
    {
        [self playVideo];
    }
}
#pragma mark - 返回按钮方法
- (void)createBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame     = CGRectMake(0 , 0, ButtonSize, ButtonSize);
    button.centerY   = _topView.centerY;
    [button setBackgroundImage:[[self getPictureWithName:@"CLBackBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_topView addSubview:button];
    
    [button addTarget:self
               action:@selector(backButtonAction:)
     forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 全屏按钮
- (void)createMaxButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame     = CGRectMake(0, 0, ButtonSize, ButtonSize);
    button.right     = _topView.right - Padding;
    button.centerY   = _topView.centerY;
    [_topView addSubview:button];

    if (_isFullScreen == YES)
    {
        [button setBackgroundImage:[[self getPictureWithName:@"CLMinBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    else
    {
        [button setBackgroundImage:[[self getPictureWithName:@"CLMaxBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    
    [button addTarget:self
               action:@selector(maxAction:)
     forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 全屏按钮响应事件
- (void)maxAction:(UIButton *)button
{
    _isLandscape = NO;
    if (_isFullScreen == NO)
    {
        [self fullScreenWithDirection:Letf];
    }
    else
    {
        [self originalscreen];
    }
    _isLandscape = _landscape;
}
#pragma mark - 创建手势
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}
#pragma mark - 轻拍方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    //取消定时消失
    [_timer invalidate];
    if (_backView.alpha == 1)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 0;
        }];
    }
    else if (_backView.alpha == 0)
    {
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                                  target:self
                                                selector:@selector(disappear)
                                                userInfo:nil
                                                 repeats:NO];
        
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 1;
        }];
    }
}
#pragma mark - 定时消失
- (void)disappear
{
    [UIView animateWithDuration:0.5 animations:^{
        _backView.alpha = 0;
    }];
}
#pragma mark - 播放完成
- (void)moviePlayDidEnd:(id)sender
{
    if (_repeatPlay == NO)
    {
        [self pausePlay];
    }
    else
    {
        [self resetPlay];
    }
    
    self.EndBlock();
}
- (void)endPlay:(EndBolck) end
{
    self.EndBlock = end;
}
#pragma mark - 返回按钮
- (void)backButtonAction:(UIButton *)button
{
    self.BackBlock(button);
}
- (void)backButton:(BackButtonBlock) backButton;
{
    self.BackBlock = backButton;
}
#pragma mark - 暂停播放
- (void)pausePlay
{
    _startButton.selected = NO;
    [_player pause];
    [_startButton setBackgroundImage:[[self getPictureWithName:@"CLPlayBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
}
#pragma mark - 播放
- (void)playVideo
{
    _startButton.selected = YES;
    [_player play];
    [_startButton setBackgroundImage:[[self getPictureWithName:@"CLPauseBtn"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
}
#pragma mark - 重新开始播放
- (void)resetPlay
{
    [_player seekToTime:CMTimeMake(0, 1)];
    [self playVideo];
}
#pragma mark - 销毁播放器
- (void)destroyPlayer
{
    
}
#pragma mark - 屏幕旋转通知
- (void)orientChange:(NSNotification *)notification
{
    if (_autoFullScreen == NO)
    {
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        [self fullScreenWithDirection:Letf];
    }
    else if (orientation == UIDeviceOrientationLandscapeRight)
    {
        [self fullScreenWithDirection:Right];
    }
    else if (orientation == UIDeviceOrientationPortrait)
    {
        [self originalscreen];
    }
}
#pragma mark - 全屏
- (void)fullScreenWithDirection:(Direction)direction
{
    //记录播放器父类
    _fatherView = self.superview;
    
    _isFullScreen = YES;

    //取消定时消失
    [_timer invalidate];
    [self setStatusBarHidden:YES];
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (_isLandscape == YES)
    {
        self.frame         = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }
    else
    {        
        if (direction == Letf)
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }];
        }
        else
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }];
        }
        self.frame         = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _playerLayer.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
    }
    
    
    //删除原有控件
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //创建全屏UI
    [self creatUI];
}
#pragma mark - 原始大小
- (void)originalscreen
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    _isFullScreen = NO;
    
    //取消定时消失
    [_timer invalidate];
    [self setStatusBarHidden:NO];

    [UIView animateWithDuration:0.25 animations:^{
        //还原大小
        self.transform = CGAffineTransformMakeRotation(0);
    }];
    
    self.frame = _customFarme;
    _playerLayer.frame = CGRectMake(0, 0, _customFarme.size.width, _customFarme.size.height);
    //还原到原有父类上
    [_fatherView addSubview:self];
    
    //删除
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //创建小屏UI
    [self creatUI];
}
#pragma mark - APP活动通知
- (void)appwillResignActive:(NSNotification *)note
{
    //将要挂起，停止播放
    [self pausePlay];
}
#pragma mark - 获取资源图片
- (UIImage *)getPictureWithName:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}
#pragma mark - dealloc
- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}





@end
