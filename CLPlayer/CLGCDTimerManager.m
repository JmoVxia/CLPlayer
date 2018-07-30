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
@property (nonatomic, strong) NSMutableArray   *actionBlockArray;
/**是否重复*/
@property (nonatomic, assign) BOOL             repeat;
/**执行时间*/
@property (nonatomic, assign) NSTimeInterval   timeInterval;
/**延迟时间*/
@property (nonatomic, assign) float            delaySecs;
/**是否正在运行*/
@property (nonatomic, assign) BOOL             isRuning;
/*定时器*/
@property (nonatomic,strong) dispatch_source_t timer_t;
/*响应次数*/
@property (nonatomic, assign) NSInteger actionTimes;

@end

@implementation CLGCDTimer

- (instancetype)initDispatchTimerWithName:(NSString *)timerName
                             timeInterval:(double)interval
                                delaySecs:(float)delaySecs
                                    queue:(dispatch_queue_t)queue
                                  repeats:(BOOL)repeats
                                   action:(dispatch_block_t)action{
    if (self = [super init]) {
        NSLog(@"创建定时器");
        self.timeInterval = interval;
        self.delaySecs    = delaySecs;
        self.repeat       = repeats;
        self.action       = action;
        self.timerName    = timerName;
        self.isRuning     = NO;
        self.serialQueue           = dispatch_queue_create([[NSString stringWithFormat:@"CLGCDTimer.%p", self] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        self.timer_t               = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.serialQueue);
        dispatch_set_target_queue(self.serialQueue, queue);
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:action, nil];
        self.actionBlockArray = array;
    }
    return self;
}

- (instancetype)initDispatchTimerWithTimeInterval:(double)interval
                                delaySecs:(float)delaySecs
                                    queue:(dispatch_queue_t)queue
                                  repeats:(BOOL)repeats
                                   action:(dispatch_block_t)action{
    if (self = [super init]) {
        NSLog(@"创建定时器");
        self.timeInterval = interval;
        self.delaySecs    = delaySecs;
        self.repeat       = repeats;
        self.action       = action;
        self.timerName    = nil;
        self.isRuning     = NO;
        self.serialQueue           = dispatch_queue_create([[NSString stringWithFormat:@"CLGCDTimer.%p", self] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        self.timer_t               = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.serialQueue);
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
- (void)replaceOldAction:(dispatch_block_t)action {
    self.action = action;
}
/**开始定时器*/
- (void)startTimer {
    NSLog(@"开始定时器");
    //拿到当前线程线程
    dispatch_async(self.serialQueue, ^{
        dispatch_source_set_timer(self.timer_t, dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(self.delaySecs * NSEC_PER_SEC)),(NSInteger)(self.timeInterval * NSEC_PER_SEC), 0 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(self.timer_t, ^{
            if (self.action) {
                self.action();
                self.actionTimes ++;
            }
            if (!self.repeat) {
                [weakSelf cancelTimer];
            }
        });
        [self resumeTimer];
    });
}
/**执行一次定时器响应*/
- (void)responseOnceTimer {
    self.isRuning    = YES;
    [self.actionBlockArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger __unused idx, BOOL *_Nonnull __unused stop) {
        dispatch_block_t action = obj;
        if (action) {
            action();
            self.actionTimes ++;
        }
    }];
    self.isRuning = NO;
}
/**取消定时器*/
- (void)cancelTimer {
    //拿到当前线程线程
    dispatch_async(self.serialQueue, ^{
        NSLog(@"取消定时器");
        if (!self.isRuning) {
            [self resumeTimer];
        }
        dispatch_source_cancel(self.timer_t);
    });
}
/**暂停定时器*/
- (void)suspendTimer {
    //拿到当前线程线程
    dispatch_async(self.serialQueue, ^{
        if (self.isRuning) {
            dispatch_suspend(self.timer_t);
            self.isRuning = NO;
        }
    });
}
/**恢复定时器*/
- (void)resumeTimer {
    //拿到当前线程线程
    dispatch_async(self.serialQueue, ^{
        if (!self.isRuning) {
            dispatch_resume(self.timer_t);
            self.isRuning = YES;
        }
    });
}
@end

@interface CLGCDTimerManager ()

/**CLGCDTimer字典*/
@property (nonatomic, strong) NSMutableDictionary *timerObjectCache;
/**信号*/
@property (nonatomic, strong) dispatch_semaphore_t semaphore;


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
        self.timerObjectCache = [NSMutableDictionary dictionary];
        self.semaphore = dispatch_semaphore_create(1);
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
    
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    if (!GCDTimer) {
        GCDTimer = [[CLGCDTimer alloc] initDispatchTimerWithName:string
                                                    timeInterval:interval
                                                       delaySecs:delaySecs
                                                           queue:queue
                                                         repeats:repeats
                                                          action:action];
        [self setTimer:GCDTimer name:string];
        NSLog(@"创建定时器成功");
    } else {
        NSLog(@"创建定时器失败");
        [GCDTimer addActionBlock:action];
        GCDTimer.timeInterval = interval;
        GCDTimer.delaySecs    = delaySecs;
        GCDTimer.serialQueue  = queue;
        GCDTimer.repeat       = repeats;
    }
}
#pragma mark - 创建定时器
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(NSTimeInterval)interval
                             delaySecs:(float)delaySecs
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    if (GCDTimer) {
        return;
    }
    [self adddDispatchTimerWithName:string
                       timeInterval:interval
                          delaySecs:delaySecs
                              queue:queue
                            repeats:repeats
                             action:action];
}
#pragma mark - 开始定时器
- (void)startTimer:(NSString *)timerName {
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    if (!GCDTimer.isRuning && GCDTimer) {
        //拿到当前线程线程
        dispatch_async(GCDTimer.serialQueue, ^{
            NSParameterAssert(string);
            dispatch_source_t timer_t = GCDTimer.timer_t;
            dispatch_source_set_timer(timer_t, dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(GCDTimer.delaySecs * NSEC_PER_SEC)),(NSInteger)(GCDTimer.timeInterval * NSEC_PER_SEC), 0 * NSEC_PER_SEC);
            __weak typeof(self) weakSelf = self;
            dispatch_source_set_event_handler(timer_t, ^{
                if (GCDTimer.action) {
                    GCDTimer.action();
                    GCDTimer.actionTimes ++;
                }
                if (!GCDTimer.repeat) {
                    [weakSelf cancelTimerWithName:string];
                }
            });
            [self resumeTimer:string];
        });
    }
}
#pragma mark - 执行一次定时器响应
- (void)responseOnceTimer:(NSString *)timerName {
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    GCDTimer.isRuning    = YES;
    [GCDTimer.actionBlockArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger __unused idx, BOOL *_Nonnull __unused stop) {
        dispatch_block_t action = obj;
        if (action) {
            action();
            GCDTimer.actionTimes ++;
        }
    }];
    GCDTimer.isRuning = NO;
}
#pragma mark - 取消定时器
- (void)cancelTimerWithName:(NSString *)timerName {
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    if (!GCDTimer.isRuning && GCDTimer) {
        [self resumeTimer:string];
    }
    if (GCDTimer) {
        //拿到当前线程线程
        dispatch_async(GCDTimer.serialQueue, ^{
            dispatch_source_cancel(GCDTimer.timer_t);
            [self.timerObjectCache removeObjectForKey:string];
        });
    }
}
#pragma mark - 暂停定时器
- (void)suspendTimer:(NSString *)timerName {
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    if (GCDTimer.isRuning && GCDTimer) {
        //拿到当前线程线程
        dispatch_async(GCDTimer.serialQueue, ^{
            dispatch_suspend(GCDTimer.timer_t);
            GCDTimer.isRuning = NO;
        });
    }
}
#pragma mark - 恢复定时器
- (void)resumeTimer:(NSString *)timerName {
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self timer:string];
    if (!GCDTimer.isRuning && GCDTimer) {
        //拿到当前线程线程
        dispatch_async(GCDTimer.serialQueue, ^{
            dispatch_resume(GCDTimer.timer_t);
            GCDTimer.isRuning = YES;
        });
    }
}
//MARK:JmoVxia---获取定时器
- (CLGCDTimer *)timer:(NSString *)timerName {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    __strong NSString *string = timerName;
    CLGCDTimer *GCDTimer = [self.timerObjectCache objectForKey:string];
    dispatch_semaphore_signal(self.semaphore);
    return GCDTimer;
}
//MARK:JmoVxia---储存定时器
- (void)setTimer:(CLGCDTimer *)timer name:(NSString *)name {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.timerObjectCache setObject:timer forKey:name];
    dispatch_semaphore_signal(self.semaphore);
}



@end



