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
@property (nonatomic, copy) dispatch_block_t   action;
/**线程*/
@property (nonatomic, strong) dispatch_queue_t serialQueue;
/**定时器名字*/
@property (nonatomic, strong) NSString         *timerName;
/**响应数组*/
@property (nonatomic, strong) NSArray          *actionBlockArray;
/**是否重复*/
@property (nonatomic, assign) BOOL             repeat;
/**执行时间*/
@property (nonatomic, assign) NSTimeInterval   timeInterval;
/**延迟时间*/
@property (nonatomic, assign) float            delaySecs;
/**是否正在运行*/
@property (nonatomic, assign) BOOL             isRuning;
@end

@implementation CLGCDTimer

- (instancetype)initDispatchTimerWithName:(NSString *)timerName
                             timeInterval:(double)interval
                                delaySecs:(float)delaySecs
                                    queue:(dispatch_queue_t)queue
                                  repeats:(BOOL)repeats
                                   action:(dispatch_block_t)action{
    if (self = [super init]) {
        self.timeInterval = interval;
        self.delaySecs    = delaySecs;
        self.repeat       = repeats;
        self.action       = action;
        self.timerName    = timerName;
        self.isRuning     = NO;
        
        NSString *privateQueueName = [NSString stringWithFormat:@"CLGCDTimer.%p", self];
        self.serialQueue           = dispatch_queue_create([privateQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.serialQueue, queue);
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:action, nil];
        self.actionBlockArray = array;
    }
    return self;
}
- (void)addActionBlock:(dispatch_block_t)action{
    NSMutableArray *array = [self.actionBlockArray mutableCopy];
    [array removeAllObjects];
    [array addObject:action];
}

@end

@interface CLGCDTimerManager ()

/**CLGCDTimer字典*/
@property (nonatomic, strong) NSMutableDictionary *timerObjectCache;
/**定时器字典*/
@property (nonatomic, strong) NSMutableDictionary *timerContainer;

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
                           action:(dispatch_block_t)action {
    NSParameterAssert(timerName);
    if (nil == queue) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer) {
        GCDTimer = [[CLGCDTimer alloc] initDispatchTimerWithName:timerName
                                                 timeInterval:interval
                                                    delaySecs:delaySecs
                                                        queue:queue
                                                      repeats:repeats
                                                       action:action];
        self.timerObjectCache[timerName] = GCDTimer;
    } else {
        [GCDTimer addActionBlock:action];
        GCDTimer.timeInterval = interval;
        GCDTimer.delaySecs    = delaySecs;
        GCDTimer.serialQueue  = queue;
        GCDTimer.repeat       = repeats;
    }
    dispatch_source_t timer_t = self.timerContainer[timerName];
    if (!timer_t) {
        timer_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, GCDTimer.serialQueue);
        [self.timerContainer setObject:timer_t forKey:timerName];
    }
}
#pragma mark - 创建定时器
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(NSTimeInterval)interval
                             delaySecs:(float)delaySecs
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (GCDTimer) {
        return;
    }
    [self adddDispatchTimerWithName:timerName
                       timeInterval:interval
                          delaySecs:delaySecs
                              queue:queue
                            repeats:repeats
                             action:action];
}
#pragma mark - 开始定时器
- (void)startTimer:(NSString *)timerName {
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer.isRuning && GCDTimer) {
        NSParameterAssert(timerName);
        dispatch_source_t timer_t = self.timerContainer[timerName];
        NSAssert(timer_t, @"timerName is not vaild");
        dispatch_source_set_timer(timer_t, dispatch_time(DISPATCH_TIME_NOW, GCDTimer.delaySecs * NSEC_PER_SEC),GCDTimer.timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(timer_t, ^{
            GCDTimer.action();
            if (!GCDTimer.repeat) {
                [weakSelf cancelTimerWithName:timerName];
            }
        });
        [self resumeTimer:timerName];
    }
}
#pragma mark - 执行一次定时器响应
- (void)responseOnceTimer:(NSString *)timerName {
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    GCDTimer.isRuning    = YES;
    [GCDTimer.actionBlockArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        dispatch_block_t action = obj;
        action();
    }];
    GCDTimer.isRuning = NO;
}
#pragma mark - 取消定时器
- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer_t = self.timerContainer[timerName];
    if (!timer_t) {
        return;
    }
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer.isRuning) {
        [self resumeTimer:timerName];
    }
    dispatch_source_cancel(timer_t);
    [self.timerContainer removeObjectForKey:timerName];
    [self.timerObjectCache removeObjectForKey:timerName];
}
#pragma mark - 暂停定时器
- (void)suspendTimer:(NSString *)timerName {
    dispatch_source_t timer_t = self.timerContainer[timerName];
    if (!timer_t) {
        return;
    }
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (GCDTimer.isRuning) {
        dispatch_suspend(timer_t);
        GCDTimer.isRuning = NO;
    }
}
#pragma mark - 恢复定时器
- (void)resumeTimer:(NSString *)timerName {
    dispatch_source_t timer_t = self.timerContainer[timerName];
    if (!timer_t) {
        return;
    }
    CLGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer.isRuning) {
        dispatch_resume(timer_t);
        GCDTimer.isRuning = YES;
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



