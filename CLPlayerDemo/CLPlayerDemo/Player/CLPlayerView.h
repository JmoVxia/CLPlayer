//
//  PlayerView.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackButtonBlock)(UIButton *button);
typedef void(^EndBolck)();
typedef void(^BeyondBlock)();

@interface CLPlayerView : UIView

/**视频url*/
@property (nonatomic,strong) NSURL *url;
/**旋转自动全屏，默认Yes*/
@property (nonatomic,assign) BOOL autoFullScreen;
/**重复播放，默认No*/
@property (nonatomic,assign) BOOL repeatPlay;
/**是否支持横屏，默认No*/
@property (nonatomic,assign) BOOL isLandscape;
/**播放*/
- (void)playVideo;
/**暂停*/
- (void)pausePlay;
/**返回按钮回调方法*/
- (void)backButton:(BackButtonBlock) backButton;
/**播放完成回调*/
- (void)endPlay:(EndBolck) end;
/**销毁播放器*/
- (void)destroyPlayer;

/**
 根据播放器所在位置计算是否滑出tableView，根据上下偏移量可以精准的计算你想要销毁播放器的位置
 
 @param tableView tableView
 @param cell 播放器所在cell
 @param topOffset tableview 相对于屏幕顶部的偏移（根据你自己需求设置）
 @param bottomOffset  tableView 相对于屏幕底部的偏移
 @param beyond 超出后的回调
 */
- (void)calculateWith:(UITableView *)tableView cell:(UITableViewCell *)cell topOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset beyond:(BeyondBlock) beyond;





@end
