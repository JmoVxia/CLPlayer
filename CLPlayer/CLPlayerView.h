//
//  PlayerView.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,VideoFillMode){
    VideoFillModeResize = 0,       ///<拉伸占满整个播放器，不按原比例拉伸
    VideoFillModeResizeAspect,     ///<按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
    VideoFillModeResizeAspectFill, ///<按照原比例拉伸占满整个播放器，但视频内容超出部分会被剪切
};
typedef NS_ENUM(NSUInteger, TopToolBarHiddenType) {
    TopToolBarHiddenNever = 0, ///<小屏和全屏都不隐藏
    TopToolBarHiddenAlways,    ///<小屏和全屏都隐藏
    TopToolBarHiddenSmall,     ///<小屏隐藏，全屏不隐藏
};
typedef NS_ENUM(NSUInteger, FullStatusBarHiddenType) {
    FullStatusBarHiddenNever = 0,     ///<一直不隐藏
    FullStatusBarHiddenAlways,        ///<一直隐藏
    FullStatusBarHiddenFollowToolBar, ///<跟随工具条，工具条隐藏就隐藏，工具条不隐藏就不隐藏
};
typedef void(^BackButtonBlock)(UIButton *button);
typedef void(^EndBolck)(void);


@interface CLPlayerViewConfig : NSObject

/**后台返回是否自动播放，默认Yes,会跟随用户，如果是播放状态进入后台，返回会继续播放*/
@property (nonatomic, assign) BOOL                    backPlay;
/**重复播放,默认No*/
@property (nonatomic, assign) BOOL                    repeatPlay;
/**当前页面是否支持横屏,默认NO*/
@property (nonatomic, assign) BOOL                    isLandscape;
/**自动旋转，默认Yes*/
@property (nonatomic, assign) BOOL                    autoRotate;
/**静音,默认为NO*/
@property (nonatomic, assign) BOOL                    mute;
/**小屏手势控制,默认NO*/
@property (nonatomic, assign) BOOL                    smallGestureControl;
/**全屏手势控制,默认Yes*/
@property (nonatomic, assign) BOOL                    fullGestureControl;;
/**工具条消失时间，默认10s*/
@property (nonatomic, assign) NSInteger               toolBarDisappearTime;
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) VideoFillMode           videoFillMode;
/**顶部工具条隐藏方式，默认不隐藏*/
@property (nonatomic, assign) TopToolBarHiddenType    topToolBarHiddenType;
/**全屏状态栏隐藏方式，默认不隐藏*/
@property (nonatomic, assign) FullStatusBarHiddenType fullStatusBarHiddenType;

/**进度条背景颜色*/
@property (nonatomic, strong) UIColor                 *progressBackgroundColor;
/**缓冲条缓冲进度颜色*/
@property (nonatomic, strong) UIColor                 *progressBufferColor;
/**进度条播放完成颜色*/
@property (nonatomic, strong) UIColor                 *progressPlayFinishColor;
/**转子线条颜色*/
@property (nonatomic, strong) UIColor                 *strokeColor;

/**
 默认配置
 @return 配置
 */
+ (instancetype)defaultConfig;

@end

@interface CLPlayerView : UIView

/**是否是全屏*/
@property (nonatomic, assign, readonly) BOOL          isFullScreen;
/**视频url*/
@property (nonatomic, strong) NSURL                   *url;

/**更新播放器基本配置*/
- (void)updateWithConfig:(void(^)(CLPlayerViewConfig *config))configBlock;

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
