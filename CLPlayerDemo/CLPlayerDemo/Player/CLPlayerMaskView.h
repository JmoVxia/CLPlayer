//
//  CLPlayerMaskView.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLSlider;
@protocol CLPlayerMaskViewDelegate <NSObject>

/**
 返回按钮代理
 */
- (void)cl_backButtonAction:(UIButton *)button;

/**
 播放按钮代理
 */
- (void)cl_playButtonAction:(UIButton *)button;

/**
 全屏按钮代理
 */
- (void)cl_fullButtonAction:(UIButton *)button;

/**
 开始滑动
 */
- (void)cl_progressSliderTouchBegan:(CLSlider *)sender;

/**
 滑动中
 */
- (void)cl_progressSliderValueChanged:(CLSlider *)sender;

/**
 滑动结束
 */
- (void)cl_progressSliderTouchEnded:(CLSlider *)sender;

@end


@interface CLPlayerMaskView : UIButton
/**代理*/
@property (nonatomic,weak) id<CLPlayerMaskViewDelegate> delegate;

@end
