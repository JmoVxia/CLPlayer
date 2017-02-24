//
//  CLPlayerMaskView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLPlayerMaskView.h"
#import "CLplayer.h"
#import "CLSlider.h"
@interface CLPlayerMaskView ()<UIGestureRecognizerDelegate>


@end

@implementation CLPlayerMaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}
- (void)initViews{
    [self addSubview:self.topToolBar];
    [self addSubview:self.bottomToolBar];
    [self addSubview:self.activity];
    [self.topToolBar addSubview:self.backButton];
    [self.bottomToolBar addSubview:self.playButton];
    [self.bottomToolBar addSubview:self.fullButton];
    [self.bottomToolBar addSubview:self.currentTimeLabel];
    [self.bottomToolBar addSubview:self.totalTimeLabel];
    [self.bottomToolBar addSubview:self.progress];
    [self.bottomToolBar addSubview:self.slider];
    [self makeConstraints];
    
    
    self.topToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    self.bottomToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    
}
#pragma mark - 约束
- (void)makeConstraints{
    //顶部工具条
    [self.topToolBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(40);
    }];
    //底部工具条
    [self .bottomToolBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(40);
    }];
    //转子
    [self.activity makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    //返回按钮
    [self.backButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(10);
        make.bottom.equalTo(-10);
        make.width.equalTo(self.backButton.height);
    }];
    //播放按钮
    [self.playButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(10);
        make.bottom.equalTo(-10);
        make.width.equalTo(self.backButton.height);
    }];
    //全屏按钮
    [self.fullButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(-10);
        make.top.equalTo(10);
        make.width.equalTo(self.backButton.height);
    }];
    //当前播放时间
    [self.currentTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.right).offset(10);
        make.width.equalTo(35);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //总时间
    [self.totalTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullButton.left).offset(-10);
        make.width.equalTo(35);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //缓冲条
    [self.progress makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.right).offset(10);
        make.right.equalTo(self.totalTimeLabel.left).offset(-10);
        make.height.equalTo(2);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //滑杆
    [self.slider makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.progress);
    }];
}



#pragma mark - 懒加载
//顶部工具条
- (UIView *) topToolBar{
    if (_topToolBar == nil){
        _topToolBar = [[UIView alloc]init];
    }
    return _topToolBar;
}
//底部工具条
- (UIView *) bottomToolBar{
    if (_bottomToolBar == nil){
        _bottomToolBar = [[UIView alloc]init];
    }
    return _bottomToolBar;
}
//转子
- (UIActivityIndicatorView *) activity{
    if (_activity == nil){
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activity startAnimating];
    }
    return _activity;
}
//返回按钮
- (UIButton *) backButton{
    if (_backButton == nil){
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[self getPictureWithName:@"CLBackBtn"] forState:UIControlStateNormal];
        [_backButton setImage:[self getPictureWithName:@"CLBackBtn"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
//播放按钮
- (UIButton *) playButton{
    if (_playButton == nil){
        _playButton = [[UIButton alloc]init];
        [_playButton setImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
        [_playButton setImage:[self getPictureWithName:@"CLPauseBtn"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
//全屏按钮
- (UIButton *) fullButton{
    if (_fullButton == nil){
        _fullButton = [[UIButton alloc]init];
        [_fullButton setImage:[self getPictureWithName:@"CLMaxBtn"] forState:UIControlStateNormal];
        [_fullButton setImage:[self getPictureWithName:@"CLMinBtn"] forState:UIControlStateSelected];
        [_fullButton addTarget:self action:@selector(fullButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}
//当前播放时间
- (UILabel *) currentTimeLabel{
    if (_currentTimeLabel == nil){
        _currentTimeLabel = [[UILabel alloc]init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font      = [UIFont systemFontOfSize:12];
        _currentTimeLabel.text      = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}
//总时间
- (UILabel *) totalTimeLabel{
    if (_totalTimeLabel == nil){
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font      = [UIFont systemFontOfSize:12];
        _totalTimeLabel.text      = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}
//缓冲条
- (UIProgressView *) progress{
    if (_progress == nil){
        _progress = [[UIProgressView alloc]init];
        _progress.trackTintColor = [UIColor whiteColor];
        _progress.progressTintColor = [UIColor orangeColor];
    }
    return _progress;
}
//滑动条
- (CLSlider *) slider{
    if (_slider == nil){
        _slider = [[CLSlider alloc]init];
        // slider开始滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
        [_slider addGestureRecognizer:panRecognizer];
        
        //左边颜色
        _slider.minimumTrackTintColor = PlayFinishColor;
        //右边颜色
        _slider.maximumTrackTintColor = [UIColor clearColor];
    }
    return _slider;
}
#pragma mark - 按钮点击事件
//返回按钮
- (void)backButtonAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_backButtonAction:)]) {
        [_delegate cl_backButtonAction:button];
    }else{
        CLlog(@"没有实现代理或者没有设置代理人");
    }
}
//播放按钮
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_playButtonAction:)]) {
        [_delegate cl_playButtonAction:button];
    }else{
        CLlog(@"没有实现代理或者没有设置代理人");
    }
}
//全屏按钮
- (void)fullButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_fullButtonAction:)]) {
        [_delegate cl_fullButtonAction:button];
    }else{
        CLlog(@"没有实现代理或者没有设置代理人");
    }
}

#pragma mark - 滑杆
//开始滑动
- (void)progressSliderTouchBegan:(CLSlider *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderTouchBegan:)]) {
        [_delegate cl_progressSliderTouchBegan:sender];
    }else{
        CLlog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动中
- (void)progressSliderValueChanged:(CLSlider *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderValueChanged:)]) {
        [_delegate cl_progressSliderValueChanged:sender];
    }else{
        CLlog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动结束
- (void)progressSliderTouchEnded:(CLSlider *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderTouchEnded:)]) {
        [_delegate cl_progressSliderTouchEnded:sender];
    }else{
        CLlog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动slider其他地方不响应其他手势
- (void)panRecognizer:(UIPanGestureRecognizer *)sender{
    
}
#pragma mark - 获取资源图片
- (UIImage *)getPictureWithName:(NSString *)name{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}


@end
