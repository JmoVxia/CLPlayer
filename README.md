# 使用AVPlayer自定义播放器

![](http://upload-images.jianshu.io/upload_images/1979970-1a6b224753f96181.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#前言
    在项目中，遇到了视频播放的需求，直接使用系统封装的播放器太过于简单，不能很好的满足项目要求，于是花时间研究了一下，使用AVPlayer来自定义播放器。
    本视频播放器主要自定义了带缓冲显示的进度条，可以拖动调节视频播放进度的播放条，具有当前播放时间和总时间的Label，全屏播放功能，定时消失的工具条。支持旋转屏幕自动全屏，可以添加到UItableView上。
#主要功能
##1.带缓冲显示的进度条
    在自定义的时候，主要是需要计算当前进度和监听缓冲的进度，细节方面需要注意进度颜色，进度为0的时候要设置为透明色，缓冲完成的时候需要设置颜色，不然全屏切换就会导致缓冲完成的进度条颜色消失。

+ 自定义进度条的代码

```
#pragma mark - 创建UIProgressView
- (void)createProgress
{
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(_startButton.right + Padding, 0, self.frame.size.width - 80 - Padding - _startButton.right - Padding - Padding, Padding)];
    self.progress.centerY = _bottomView.height/2.0;
    
    //进度条颜色
    self.progress.trackTintColor = ProgressColor;
    // 计算缓冲进度
    NSTimeInterval timeInterval = [self availableDuration];
    CMTime duration = self.playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    [self.progress setProgress:timeInterval / totalDuration animated:NO];
    
    CGFloat time = round(timeInterval);
    CGFloat total = round(totalDuration);
   
    //确保都是number
    if (isnan(time) == 0 && isnan(total) == 0)
    {
        if (time == total)
        {
            //缓冲进度颜色
            self.progress.progressTintColor = ProgressTintColor;
        }
        else
        {
            //缓冲进度颜色
            self.progress.progressTintColor = [UIColor clearColor];
        }
    }
    else
    {
        //缓冲进度颜色
        self.progress.progressTintColor = [UIColor clearColor];
    }
    [_bottomView addSubview:_progress];
}
```

+ 缓冲进度计算和监听代码

```
#pragma mark - 缓冲监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:NO];
        //设置缓存进度颜色
        self.progress.progressTintColor = ProgressTintColor;
    }
}
//计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
```
##2.可以拖动调节视频播放进度的播放条
    这里主要需要注意的是创建的播放条需要比进度条稍微长一点，这样才可以看到滑块从开始到最后走完整个进度条。播放条最好单独新建一个继承自UISlider的控件，因为进度条和播放条的大小很可能不能完美的重合在一起，这样看起来就会有2条线条，很不美观，内部代码将其默认长度和起点重新布局。
+ 播放条控件内部代码
    这里重写`- (CGRect)trackRectForBounds:(CGRect)bounds`方法，才能改变播放条的大小。

```
// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    [super trackRectForBounds:bounds];
    return CGRectMake(-2, (self.frame.size.height - 2.6)/2.0, CGRectGetWidth(bounds) + 4, 2.6);
}
```

+ 创建播放条代码

```
#pragma mark - 创建UISlider
- (void)createSlider
{
    self.slider = [[Slider alloc]init];
    _slider.frame = CGRectMake(_progress.x, 0, _progress.width, ViewHeight);
    _slider.centerY = _bottomView.height/2.0;
    [_bottomView addSubview:_slider];
    //自定义滑块大小
    UIImage *image = [UIImage imageNamed:@"iconfont-yuan"];
    //改变滑块大小
    UIImage *tempImage = [image OriginImage:image scaleToSize:CGSizeMake( SliderSize, SliderSize)];
    //改变滑块颜色
    UIImage *newImage = [tempImage imageWithTintColor:SliderColor];
    [_slider setThumbImage:newImage forState:UIControlStateNormal];
    //添加监听
    [_slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    //左边颜色
    _slider.minimumTrackTintColor = PlayFinishColor;
    //右边颜色
    _slider.maximumTrackTintColor = [UIColor clearColor];
}
```

+ 拖动播放条代码

```
#pragma mark - 拖动进度条
- (void)progressSlider:(UISlider *)slider
{
    //拖动改变视频播放进度
    if (_player.status == AVPlayerStatusReadyToPlay)
    {
        //暂停
        [self pausePlay];
        
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
       
        [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
            //继续播放
            [self playVideo];
        }];
        
    }
}
```

##3.具有当前播放时间和总时间的Label

    创建时间显示Label的时候，我们需要创建一个定时器，每秒执行一下代码，来实现动态改变Label上的时间显示。

+ Label创建代码

```
#pragma mark - 创建播放时间
- (void)createCurrentTimeLabel
{
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, Padding)];
    self.currentTimeLabel.centerY = _progress.centerY;
    self.currentTimeLabel.right = self.backView.right - Padding;
    [_bottomView addSubview:_currentTimeLabel];
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [UIFont systemFontOfSize:12];
    _currentTimeLabel.text = @"00:00/00:00";
}
```

+ Label上面定时器的定时事件

```
- (void)timeStack
{
    if (_playerItem.duration.timescale != 0)
    {
        _slider.maximumValue = 1;//总共时长
        _slider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        //duration 总时长
        NSInteger durMin = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", proMin, proSec, durMin, durSec];
        
    }
    //开始播放停止转子
    if (_player.status == AVPlayerStatusReadyToPlay)
    {
        [_activity stopAnimating];
    } else {
        [_activity startAnimating];
    }
}
```

##4.全屏播放功能
    上面都是一些基本功能，最重要的还是全屏功能的实现。全屏功能这里多说一下，由于我将播放器封装到一个`UIVIew`里边，导致在做全屏的时候出现了一些问题。因为播放器被封装起来了，全屏的时候，播放器的大小就很可能超出父类控件的大小范围，造成了超出部分点击事件无法获取，最开始打算重写父类`-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event`方法，但是想到这样做就没有达到封装的目的，于是改变了一下思路，在全屏的时候，将播放器的父类Size变成全屏大小，并且添加到当前显示的`Window`上，这样播放器就不会超出父类的范围大小。


+ 全屏代码
    全屏的适配采用的是遍历删除原有控件，重新布局创建全屏控件的方法实现。

```
#pragma mark - 横屏代码
- (void)maxAction:(UIButton *)button
{
    //取消定时消失
    [_timer invalidate];
    
    if (ScreenWidth < ScreenHeight)
    {
        //记录父类的父类和父类的位置大小
        _topSuperView = self.superview.superview;
        _customSuperViewFarme = self.superview.frame;
        //横屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        //改变父类大小
        self.superview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        //将父类添加到window上面
        UIView *superView = self.superview;
        [self.window addSubview:superView];
        //删除原有控件
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        //创建全屏控件
        [self creatUI];
    }
    else
    {
       
        //旋转屏幕
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
        //还原父类控件范围大小
        self.superview.frame = _customSuperViewFarme;
        //将父类添加到原有控件上
        UIView *superView = self.superview;
        [_topSuperView addSubview:superView];
        //删除
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        //创建小屏UI
        [self creatUI];
    }
}
```

+ 创建播放器UI的代码

```
#pragma mark - 创建播放器UI
- (void)creatUI
{
    if (ScreenWidth < ScreenHeight)
    {
        self.frame = _customFarme;
        _playerLayer.frame = CGRectMake(0, 0, _customFarme.size.width, _customFarme.size.height);
    }
    else
    {
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }

    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:_playerLayer];

    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    //最上面的View
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, _playerLayer.frame.origin.y, _playerLayer.frame.size.width, _playerLayer.frame.size.height)];
    _backView.backgroundColor = [UIColor clearColor];
    [self addSubview:_backView];
    
    //顶部View条
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, ViewHeight)];
    _topView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_backView addSubview:_topView];
    //底部View条
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _backView.height - ViewHeight, self.frame.size.width, ViewHeight)];
    _bottomView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_backView addSubview:_bottomView];
    // 监听loadedTimeRanges属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
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
    
    //转子
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.center = _backView.center;
    [self addSubview:_activity];
    [_activity startAnimating];
    
    //计时器，循环执行
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeStack) userInfo:nil repeats:YES];
    //工具条定时消失
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime target:self selector:@selector(disappear) userInfo:nil repeats:NO];
}

```
##5.定时消失的工具条
    如果工具条是显示状态，不点击视频，默认一段时间后，自动隐藏工具条，点击视频，直接隐藏工具条；如果工具条是隐藏状态，点击视频，就让工具条显示。功能说起来很简单，最开始的时候，我使用GCD延迟代码实现，但是当点击让工具条显示，然后再次点击让工具条消失，多点几下你会发现你的定时消失时间不对。这里我们需要注意的是，当你再次点击的时候需要取消上一次的延迟执行代码，才能够让下一次点击的时候，延迟代码正确执行。这里采用定时器来实现，因为定时器可以取消延迟执行的代码。

+ 点击视频的代码

```
#pragma mark - 轻拍方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (_backView.alpha == 1)
    {
        //取消定时消失
        [_timer invalidate];
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 0;
        }];
    } else if (_backView.alpha == 0)
    {
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime target:self selector:@selector(disappear) userInfo:nil repeats:NO];
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 1;
        }];
    }
}

```

#接口与用法
    播放器做了一下简单的封装，留了几个常用的接口，方便使用。
+ 接口

```
/**视频url*/
@property (nonatomic,strong) NSURL *url;

/**返回按钮回调方法*/
- (void)backButton:(BackButtonBlock) backButton;

/**播放完成回调*/
- (void)endPlay:(EndBolck) end;

/**播放*/
- (void)playVideo;

/**暂停*/
- (void)pausePlay;
```

+ 使用方法

    先将Demo中播放器文件夹拖拽到工程中（资源文件不要忘记了），导入AVPlayer支持框架`MediaPlayer.framework`，如果不喜欢拖拽，可以直接使用cocoapods导入，`pod 'CLPlayer', '~> 1.0.0'`
+ 具体使用代码

```
PlayerView *playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
[self.view addSubview:playerView];
    //视频地址
playerView.url = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0215/56c1809735217_wpd.mp4"];
    //播放
[playerView playVideo];
    //返回按钮点击事件回调
[playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
[playerView endPlay:^{
        NSLog(@"播放完成");
    }];
```

#说明
    `UIImage+TintColor`是用来渲染图片颜色的分类，由于缺少图片资源，所以采用其他颜色图片渲染成自己需要的颜色；`UIImage+ScaleToSize`这个分类是用来改变图片尺寸大小的，因为播放条中的滑块不能直接改变大小，所以通过改变图片尺寸大小来控制滑块大小；`UIView+SetRect`是用于适配的分类。

#总结

    在自定义播放器的时候，需要注意的细节太多，这里就不一一细说了，具体看Demo，Demo中有很详细的注释。由于时间比较紧张，代码并没有进一步封装，大家将就着看吧。




#简书地址
http://www.jianshu.com/p/b9659492d064
