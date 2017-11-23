//
//  CLGCDTimerManager.m
//  GCDTimer
//
//  Created by JmoVxia on 2017/11/23.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLGCDTimerManager.h"

@interface CLGCDTimer ()
/**响应*/
@property (nonatomic, copy) dispatch_block_t action;
/**线程*/
@property (nonatomic, strong) dispatch_queue_t serialQueue;
/**是否重复*/
@property (nonatomic, assign) BOOL repeat;
/**执行时间*/
@property (nonatomic, assign) NSTimeInterval timeInterval;
/**定时器名字*/
@property (nonatomic, strong) NSString *timerName;
/**类型*/
@property (nonatomic, assign) CLGCDTimerType type;
/**响应数组*/
@property (nonatomic, strong) NSArray *actionBlockArray;
/**延迟时间*/
@property (nonatomic, assign) float delaySecs;

@end

@implementation CLGCDTimer

- (instancetype)initDispatchTimerWithName:(NSString *)timerName
                             timeInterval:(double)interval
                                delaySecs:(float)delaySecs
                                    queue:(dispatch_queue_t)queue
                                  repeats:(BOOL)repeats
                                   action:(dispatch_block_t)action
                               actionType:(CLGCDTimerType)type {
    if (self = [super init]) {
        self.timeInterval = interval;
        self.delaySecs = delaySecs;
        self.repeat = repeats;
        self.action = action;
        self.timerName = timerName;
        self.type = type;
        NSString *privateQueueName = [NSString stringWithFormat:@"CLGCDTimer.%p", self];
        self.serialQueue = dispatch_queue_create([privateQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.serialQueue, queue);
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:action, nil];
        self.actionBlockArray = array;
    }
    return self;
}
- (void)addActionBlock:(dispatch_block_t)action actionType:(CLGCDTimerType)type {
    NSMutableArray *array = [self.actionBlockArray mutableCopy];
    self.type = type;
    switch (type) {
        case CLAbandonPreviousAction: {
            [array removeAllObjects];
            [array addObject:action];
            self.actionBlockArray = array;
            break;
        }
        case CLMergePreviousAction: {
            [array addObject:action];
            self.actionBlockArray = array;
            break;
        }
    }
}

@end

@interface CLGCDTimerManager ()
/**CLGCDTimer字典*/
@property (nonatomic, strong) NSMutableDictionary *timerObjectCache;
/**定时器字典*/
@property (nonatomic, strong) NSMutableDictionary *timerContainer;
/**是否正在运行*/
@property (nonatomic, assign) BOOL isRuning;
@end

@implementation CLGCDTimerManager

#pragma mark - 初始化
+ (instancetype)sharedManager {
    static CLGCDTimerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CLGCDTimerManager alloc] init];
    });
    return manager;
}
- (instancetype)init {
    if (self = [super init]) {
        self.timerContainer = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 添加定时器
- (void)adddDispatchTimerWithName:(NSString *)timerName
                     timeInterval:(NSTimeInterval)interval
                        delaySecs:(float)delaySecs
                            queue:(dispatch_queue_t)queue
                          repeats:(BOOL)repeats
                       actionType:(CLGCDTimerType)type
                           action:(dispatch_block_t)action {
    self.isRuning = NO;
    NSParameterAssert(timerName);
    if (nil == queue) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    CLGCDTimer *timer = self.timerObjectCache[timerName];
    if (!timer) {
        timer = [[CLGCDTimer alloc] initDispatchTimerWithName:timerName
                                                 timeInterval:interval
                                                    delaySecs:delaySecs
                                                        queue:queue
                                                      repeats:repeats
                                                       action:action
                                                   actionType:type];
        self.timerObjectCache[timerName] = timer;
    } else {
        [timer addActionBlock:action actionType:type];
        if (type == CLMergePreviousAction) {
            timer.timeInterval = interval;
            timer.serialQueue = queue;
            timer.repeat = repeats;
            timer.delaySecs = delaySecs;
        }
    }
    dispatch_source_t timer_t = self.timerContainer[timerName];
    if (!timer_t) {
        timer_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timer.serialQueue);
        dispatch_resume(timer_t);
        [self.timerContainer setObject:timer_t forKey:timerName];
    }
}
#pragma mark - 创建定时器
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(NSTimeInterval)interval
                             delaySecs:(float)delaySecs
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                            actionType:(CLGCDTimerType)type
                                action:(dispatch_block_t)action {
    [self adddDispatchTimerWithName:timerName
                       timeInterval:interval
                          delaySecs:delaySecs
                              queue:queue
                            repeats:repeats
                         actionType:type
                             action:action];
    [self startTimer:timerName];
}
#pragma mark - 开始定时器
- (void)startTimer:(NSString *)timerName {
    if (!self.isRuning) {
        NSParameterAssert(timerName);
        dispatch_source_t timer_t = self.timerContainer[timerName];
        NSAssert(timer_t, @"timerName is not vaild");
        CLGCDTimer *timer = self.timerObjectCache[timerName];
        dispatch_source_set_timer(timer_t, dispatch_time(DISPATCH_TIME_NOW, timer.delaySecs * NSEC_PER_SEC),timer.timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        switch (timer.type) {
            case CLAbandonPreviousAction: {
                dispatch_source_set_event_handler(timer_t, ^{
                    timer.action();
                    if (!timer.repeat) {
                        [weakSelf cancelTimerWithName:timerName];
                    }
                });
                break;
            }
            case CLMergePreviousAction: {
                dispatch_source_set_event_handler(timer_t, ^{
                    [timer.actionBlockArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                        dispatch_block_t action = obj;
                        action();
                        if (!timer.repeat) {
                            [weakSelf cancelTimerWithName:timerName];
                        }
                    }];
                });
                break;
            }
        }
        self.isRuning = YES;
    }
}
#pragma mark - 执行一次定时器响应
- (void)responseOnceTimer:(NSString *)timerName {
    self.isRuning = YES;
    CLGCDTimer *timer = self.timerObjectCache[timerName];
    [timer.actionBlockArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        dispatch_block_t action = obj;
        action();
    }];
    self.isRuning = NO;
}
#pragma mark - 取消定时器
- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer = self.timerContainer[timerName];
    if (!timer) {
        return;
    }
    [self.timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
    [self.timerObjectCache removeObjectForKey:timerName];
}
#pragma mark - 暂停定时器
- (void)suspendTimer:(NSString *)timerName {
    if (self.isRuning) {
        dispatch_source_t timer = self.timerContainer[timerName];
        if (!timer) {
            return;
        }
        dispatch_suspend(timer);
        self.isRuning = NO;
    }
}
#pragma mark - 恢复定时器
- (void)resumeTimer:(NSString *)timerName {
    if (!self.isRuning) {
        dispatch_source_t timer = self.timerContainer[timerName];
        if (!timer) {
            return;
        }
        dispatch_resume(timer);
        self.isRuning = YES;
    }
}
#pragma mark - 懒加载
- (NSMutableDictionary *)timerContainer {
    if (!_timerContainer) {
        _timerContainer = [[NSMutableDictionary alloc] init];
    }
    return _timerContainer;
}
- (NSMutableDictionary *)timerObjectCache {
    if (!_timerObjectCache) {
        _timerObjectCache = [[NSMutableDictionary alloc] init];
    }
    return _timerObjectCache;
}
@end



