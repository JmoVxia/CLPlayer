//
//  CLGCDTimerManager.h
//  GCDTimer
//
//  Created by JmoVxia on 2017/11/23.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLGCDTimer : NSObject

@end

@interface CLGCDTimerManager : NSObject

+ (instancetype)sharedManager;

/**
 创建定时器，需要调用开始开启，如果存在定时器，不会重新创建
 @param timerName 定时器名称
 @param interval 间隔时间
 @param delaySecs 第一次延迟时间
 @param queue 线程
 @param repeats 是否重复
 @param action 响应
 */
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(NSTimeInterval)interval
                             delaySecs:(float)delaySecs
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action;
/**开始定时器*/
- (void)startTimer:(NSString *)timerName;
/**执行一次定时器响应*/
- (void)responseOnceTimer:(NSString *)timerName;
/**取消定时器*/
- (void)cancelTimerWithName:(NSString *)timerName;
/**暂停定时器*/
- (void)suspendTimer:(NSString *)timerName;
/**恢复定时器*/
- (void)resumeTimer:(NSString *)timerName;



@end



