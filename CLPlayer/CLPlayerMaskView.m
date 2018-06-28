//
//  CLPlayerMaskView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLPlayerMaskView.h"
#import "CLSlider.h"
#import "Masonry.h"
//间隙
#define Padding        10
//顶部底部工具条高度
#define ToolBarHeight     50

@interface CLPlayerMaskView ()


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
    [self addSubview:self.loadingView];
    [self addSubview:self.failButton];
    [self.topToolBar addSubview:self.backButton];
    [self.bottomToolBar addSubview:self.playButton];
    [self.bottomToolBar addSubview:self.fullButton];
    [self.bottomToolBar addSubview:self.currentTimeLabel];
    [self.bottomToolBar addSubview:self.totalTimeLabel];
    [self.bottomToolBar addSubview:self.progress];
    [self.bottomToolBar addSubview:self.slider];
    self.topToolBar.backgroundColor    = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.20000f];
    self.bottomToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.20000f];
}
#pragma mark - 约束
- (void)makeConstraints{
    //顶部工具条
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    //底部工具条
    [self .bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    //转子
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    //返回按钮
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(Padding);
        make.bottom.mas_equalTo(-Padding);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    //播放按钮
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(Padding);
        make.bottom.mas_equalTo(-Padding);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    //全屏按钮
    [self.fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(-Padding);
        make.top.mas_equalTo(Padding);
        make.width.mas_equalTo(self.backButton.mas_height);
    }];
    //当前播放时间
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).mas_offset(Padding);
        make.width.mas_equalTo(45);
        make.centerY.mas_equalTo(self.bottomToolBar);
    }];
    //总时间
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.fullButton.mas_left).mas_offset(-Padding);
        make.width.mas_equalTo(45);
        make.centerY.mas_equalTo(self.bottomToolBar);
    }];
    //缓冲条
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.currentTimeLabel.mas_right).mas_offset(Padding);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left).mas_offset(-Padding);
        make.height.mas_equalTo(2);
        make.centerY.mas_equalTo(self.bottomToolBar);
    }];
    //滑杆
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.progress);
    }];
    //失败按钮
    [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
}
#pragma mark -- 设置颜色
-(void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor{
    _progressBackgroundColor = progressBackgroundColor;
    _progress.trackTintColor = progressBackgroundColor;
}
-(void)setProgressBufferColor:(UIColor *)progressBufferColor{
    _progressBufferColor        = progressBufferColor;
    _progress.progressTintColor = progressBufferColor;
}
-(void)setProgressPlayFinishColor:(UIColor *)progressPlayFinishColor{
    _progressPlayFinishColor      = progressPlayFinishColor;
    _slider.minimumTrackTintColor = _progressPlayFinishColor;
}
#pragma mark - 懒加载
//顶部工具条
- (UIView *) topToolBar{
    if (_topToolBar == nil){
        _topToolBar                        = [[UIView alloc] init];
        _topToolBar.userInteractionEnabled = YES;
    }
    return _topToolBar;
}
//底部工具条
- (UIView *) bottomToolBar{
    if (_bottomToolBar == nil){
        _bottomToolBar                        = [[UIView alloc] init];
        _bottomToolBar.userInteractionEnabled = YES;
    }
    return _bottomToolBar;
}
//转子
- (AILoadingView *) loadingView{
    if (_loadingView == nil){
        _loadingView             = [[AILoadingView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _loadingView.strokeColor = [UIColor whiteColor];
        [_loadingView starAnimation];
    }
    return _loadingView;
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
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
        [_playButton setImage:[self getPictureWithName:@"CLPauseBtn"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
//全屏按钮
- (UIButton *) fullButton{
    if (_fullButton == nil){
        _fullButton = [[UIButton alloc] init];
        [_fullButton setImage:[self getPictureWithName:@"CLMaxBtn"] forState:UIControlStateNormal];
        [_fullButton setImage:[self getPictureWithName:@"CLMinBtn"] forState:UIControlStateSelected];
        [_fullButton addTarget:self action:@selector(fullButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}
//当前播放时间
- (UILabel *) currentTimeLabel{
    if (_currentTimeLabel == nil){
        _currentTimeLabel                           = [[UILabel alloc] init];
        _currentTimeLabel.textColor                 = [UIColor whiteColor];
        _currentTimeLabel.adjustsFontSizeToFitWidth = YES;
        _currentTimeLabel.text                      = @"00:00";
        _currentTimeLabel.textAlignment             = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}
//总时间
- (UILabel *) totalTimeLabel{
    if (_totalTimeLabel == nil){
        _totalTimeLabel                           = [[UILabel alloc] init];
        _totalTimeLabel.textColor                 = [UIColor whiteColor];
        _totalTimeLabel.adjustsFontSizeToFitWidth = YES;
        _totalTimeLabel.text                      = @"00:00";
        _totalTimeLabel.textAlignment             = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}
//缓冲条
- (UIProgressView *) progress{
    if (_progress == nil){
        _progress = [[UIProgressView alloc] init];
    }
    return _progress;
}
//滑动条
- (CLSlider *) slider{
    if (_slider == nil){
        _slider = [[CLSlider alloc] init];
        // slider开始滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        //右边颜色
        _slider.maximumTrackTintColor = [UIColor clearColor];
    }
    return _slider;
}
//加载失败按钮
- (UIButton *) failButton
{
    if (_failButton == nil) {
        _failButton        = [[UIButton alloc] init];
        _failButton.hidden = YES;
        [_failButton setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failButton.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
        [_failButton addTarget:self action:@selector(failButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failButton;
}
#pragma mark - 按钮点击事件
//返回按钮
- (void)backButtonAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_backButtonAction:)]) {
        [_delegate cl_backButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//播放按钮
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_playButtonAction:)]) {
        [_delegate cl_playButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//全屏按钮
- (void)fullButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_fullButtonAction:)]) {
        [_delegate cl_fullButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//失败按钮
- (void)failButtonAction:(UIButton *)button{
    self.failButton.hidden = YES;
    self.loadingView.hidden   = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(cl_failButtonAction:)]) {
        [_delegate cl_failButtonAction:button];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
#pragma mark - 滑杆
//开始滑动
- (void)progressSliderTouchBegan:(CLSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderTouchBegan:)]) {
        [_delegate cl_progressSliderTouchBegan:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动中
- (void)progressSliderValueChanged:(CLSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderValueChanged:)]) {
        [_delegate cl_progressSliderValueChanged:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
//滑动结束
- (void)progressSliderTouchEnded:(CLSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_progressSliderTouchEnded:)]) {
        [_delegate cl_progressSliderTouchEnded:slider];
    }else{
        NSLog(@"没有实现代理或者没有设置代理人");
    }
}
#pragma mark - 布局
-(void)layoutSubviews{
    [super layoutSubviews];
    [self makeConstraints];
}
#pragma mark - 获取资源图片
- (UIImage *)getPictureWithName:(NSString *)name{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


@end
