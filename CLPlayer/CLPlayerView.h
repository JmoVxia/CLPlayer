//
//  PlayerView.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,VideoFillMode){
    VideoFillModeResize = 0,       //拉伸占满整个播放器，不按原比例拉伸
    VideoFillModeResizeAspect,     //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
    VideoFillModeResizeAspectFill, //按照原比例拉伸占满整个播放器，但视频内容超出部分会被剪切
};
typedef NS_ENUM(NSUInteger, TopToolBarHiddenType) {
    TopToolBarHiddenCustom = 0, //不隐藏
    TopToolBarHiddenAll,        //小屏和全屏都隐藏
    TopToolBarHiddenSmall,      //小屏隐藏，全屏不隐藏
};

typedef void(^BackButtonBlock)(UIButton *button);
typedef void(^EndBolck)(void);

@interface CLPlayerView : UIView

/**重复播放,默认No*/
@property (nonatomic, assign) BOOL                 repeatPlay;
/**当前页面是否支持横屏,默认NO*/
@property (nonatomic, assign) BOOL                 isLandscape;
/**自动旋转，默认Yes*/
@property (nonatomic, assign) BOOL                 autoRotate;
/**全屏是否隐藏状态栏,默认YES*/
@property (nonatomic, assign) BOOL                 fullStatusBarHidden;
/**静音,默认为NO*/
@property (nonatomic, assign) BOOL                 mute;
/**小屏手势控制音量亮度,默认NO*/
@property (nonatomic, assign) BOOL                 smallGestureControl;
/**全屏手势控制音量亮度,默认Yes*/
@property (nonatomic, assign) BOOL                 fullGestureControl;;
/**是否是全屏*/
@property (nonatomic, assign, readonly) BOOL       isFullScreen;
/**工具条消失时间，默认10s*/
@property (nonatomic, assign) NSInteger            toolBarDisappearTime;
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) VideoFillMode        videoFillMode;
/**隐藏顶部工具条，默认不隐藏*/
@property (nonatomic, assign) TopToolBarHiddenType topToolBarHiddenType;
/**视频url*/
@property (nonatomic, strong) NSURL                *url;
/**进度条背景颜色*/
@property (nonatomic, strong) UIColor              *progressBackgroundColor;
/**缓冲条缓冲进度颜色*/
@property (nonatomic, strong) UIColor              *progressBufferColor;
/**进度条播放完成颜色*/
@property (nonatomic, strong) UIColor              *progressPlayFinishColor;
/**转子线条颜色*/
@property (nonatomic, strong) UIColor              *strokeColor;

/**播放*/
- (void)playVideo;
/**暂停*/
- (void)pausePlay;
/**返回按钮回调方法，只有小屏会调用，全屏点击默认回到小屏*/
- (void)backButton:(BackButtonBlock) backButton;
/**播放完成回调*/
- (void)endPlay:(EndBolck) end;
/**销毁播放器*/
- (void)destroyPlayer;




@end
