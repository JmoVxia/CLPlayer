//
//  CLplayer.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#ifndef CLplayer_h
#define CLplayer_h


/**如果是OC中的全部写在这里边，如果是C语言或者其他，就写在外边*/
#ifdef __OBJC__


/**使用CLlog，调试模式下才会打印，发布模式不会打印*/
#ifdef DEBUG//调试阶段的log
#define CLlog(...) NSLog(__VA_ARGS__)
#else
#define CLlog(...)
#endif
/**打印方法名称*/
#define CLlogFunc  CLlog(@"%s",__func__);

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import  "Masonry.h"

///**iPhone5为标准，乘以宽的比例*/
//#define CLscaleX(value) ((value)/320.0f * CLscreenWidth)
//
///**iPhone5为标准，乘以高的比例*/
//#define CLscaleY(value) ((value)/568.0f * CLscreenHeight)
/**
 *  UIScreen width.
 */
#define  CLscreenWidth   [UIScreen mainScreen].bounds.size.width

/**
 *  UIScreen height.
 */
#define  CLscreenHeight  [UIScreen mainScreen].bounds.size.height


//间隙
#define Padding        10
//消失时间
#define DisappearTime  10
//顶部底部工具条高度
#define ToolBarHeight     35
//进度条颜色
#define ProgressColor     [UIColor colorWithRed:0.54118 green:0.51373 blue:0.50980 alpha:1.00000]
//缓冲颜色
#define ProgressTintColor [UIColor orangeColor]
//播放完成颜色
#define PlayFinishColor   [UIColor whiteColor]




#endif


#endif /* CLplayer_h */
