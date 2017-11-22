//
//  GCDTimer.h
//  GCDTimerDemo
//
//  Created by JmoVxia on 2017/11/22.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject

@property (strong, readonly, nonatomic) dispatch_source_t dispatchSource;
@property (assign, readonly, nonatomic) BOOL isTimerRuning;
#pragma 初始化
- (instancetype)init;
#pragma mark - 用法
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval;
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval delay:(uint64_t)delay;
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs;
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs;
/**开始*/
- (void)start;
/**暂停*/
-(void)pause;
/**销毁*/
- (void)destroy;

@end
