//
//  CLPlayerMaskView.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLSlider.h"
#import "AILoadingView.h"
@protocol CLPlayerMaskViewDelegate <NSObject>
/**返回按钮代理*/
- (void)cl_backButtonAction:(UIButton *)button;
/**播放按钮代理*/
- (void)cl_playButtonAction:(UIButton *)button;
/**全屏按钮代理*/
- (void)cl_fullButtonAction:(UIButton *)button;
/**开始滑动*/
- (void)cl_progressSliderTouchBegan:(CLSlider *)slider;
/**滑动中*/
- (void)cl_progressSliderValueChanged:(CLSlider *)slider;
/**滑动结束*/
- (void)cl_progressSliderTouchEnded:(CLSlider *)slider;
/**失败按钮代理*/
- (void)cl_failButtonAction:(UIButton *)button;
@end

@interface CLPlayerMaskView : UIButton
/**顶部工具条*/
@property (nonatomic,strong) UIView *topToolBar;
/**底部工具条*/
@property (nonatomic,strong) UIView *bottomToolBar;
/**转子*/
@property (nonatomic,strong) AILoadingView *activity;
/**顶部工具条返回按钮*/
@property (nonatomic,strong) UIButton *backButton;
/**底部工具条播放按钮*/
@property (nonatomic,strong) UIButton *playButton;
/**底部工具条全屏按钮*/
@property (nonatomic,strong) UIButton *fullButton;
/**底部工具条当前播放时间*/
@property (nonatomic,strong) UILabel *currentTimeLabel;
/**底部工具条视频总时间*/
@property (nonatomic,strong) UILabel *totalTimeLabel;
/**缓冲进度条*/
@property (nonatomic,strong) UIProgressView *progress;
/**播放进度条*/
@property (nonatomic,strong) CLSlider *slider;
/**加载失败按钮*/
@property (nonatomic,strong) UIButton *failButton;
/**代理人*/
@property (nonatomic,weak) id<CLPlayerMaskViewDelegate> delegate;
/**进度条背景颜色*/
@property (nonatomic,strong) UIColor *progressBackgroundColor;
/**缓冲条缓冲进度颜色*/
@property (nonatomic,strong) UIColor *progressBufferColor;
/**进度条播放完成颜色*/
@property (nonatomic,strong) UIColor *progressPlayFinishColor;

@end
