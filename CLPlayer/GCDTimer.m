//
//  GCDTimer.m
//  GCDTimerDemo
//
//  Created by JmoVxia on 2017/11/22.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer ()

@property (strong, readwrite, nonatomic) dispatch_source_t dispatchSource;
@property (assign, readwrite, nonatomic) BOOL isTimerRuning;

@end

@implementation GCDTimer

- (instancetype)init {
    if (self = [super init]) {
        self.dispatchSource = \
        dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    return self;
}
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}
- (void)event:(dispatch_block_t)block timeInterval:(uint64_t)interval delay:(uint64_t)delay {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, delay), interval, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, 0), secs * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}
- (void)event:(dispatch_block_t)block timeIntervalWithSecs:(float)secs delaySecs:(float)delaySecs {
    NSParameterAssert(block);
    dispatch_source_set_timer(self.dispatchSource, dispatch_time(DISPATCH_TIME_NOW, delaySecs * NSEC_PER_SEC), secs * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.dispatchSource, block);
}
- (void)start {
    if (self.dispatchSource) {
        if (!_isTimerRuning) {
            dispatch_resume(self.dispatchSource);
            _isTimerRuning = YES;
        }
    }
}
-(void)pause{
    if (self.dispatchSource) {
        if (self.isTimerRuning) {
            dispatch_suspend(self.dispatchSource);
            _isTimerRuning = NO;
        }
    }
}
- (void)destroy {
    if (self.dispatchSource) {
        dispatch_source_cancel(self.dispatchSource);
        self.dispatchSource = nil;
        _isTimerRuning = NO;
    }
}

@end
