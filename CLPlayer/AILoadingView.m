//
//  AILoading.m
//  AIAnimationDemo
//
//  Created by 艾泽鑫 on 2017/8/5.
//  Copyright © 2017年 艾泽鑫. All rights reserved.
//

#import "AILoadingView.h"

@interface AILoadingView ()<CAAnimationDelegate>

@property (nonatomic, strong) CAShapeLayer *loadingLayer;
/** 当前的index*/
@property (nonatomic, assign) NSInteger index;
/**结束*/
@property (nonatomic, assign) BOOL realFinish;
/**strokeStartAnimation*/
@property (nonatomic, strong) CABasicAnimation *strokeStartAnimation;
/**strokeEndAnimation*/
@property (nonatomic, strong) CABasicAnimation *strokeEndAnimation;
/**动画组*/
@property (nonatomic, strong) CAAnimationGroup *strokeAniamtionGroup;

@end
@implementation AILoadingView
//loadingLayer
- (CAShapeLayer *) loadingLayer{
    if (_loadingLayer == nil){
        _loadingLayer             = [CAShapeLayer layer];
        _loadingLayer.lineWidth   = 2.;
        _loadingLayer.fillColor   = [UIColor clearColor].CGColor;
        _loadingLayer.strokeColor = [UIColor whiteColor].CGColor;
        _loadingLayer.lineCap     = kCALineCapRound;
    }
    return _loadingLayer;
}
//strokeStartAnimation
- (CABasicAnimation *) strokeStartAnimation{
    if (_strokeStartAnimation == nil){
        _strokeStartAnimation                = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        _strokeStartAnimation.fromValue      = @0;
        _strokeStartAnimation.toValue        = @1.;
        _strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
    return _strokeStartAnimation;
}
//strokeEndAnimation
- (CABasicAnimation *) strokeEndAnimation{
    if (_strokeEndAnimation == nil){
        _strokeEndAnimation           = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _strokeEndAnimation.fromValue = @.0;
        _strokeEndAnimation.toValue   = @1.;
        _strokeEndAnimation.duration  = self.duration * 0.5;
    }
    return _strokeEndAnimation;
}
//strokeAniamtionGroup
- (CAAnimationGroup *) strokeAniamtionGroup{
    if (_strokeAniamtionGroup == nil){
        _strokeAniamtionGroup                     = [CAAnimationGroup animation];
        _strokeAniamtionGroup.duration            = self.duration;
        _strokeAniamtionGroup.delegate            = self;
        _strokeAniamtionGroup.removedOnCompletion = NO;
        _strokeAniamtionGroup.fillMode            = kCAFillModeForwards;
    }
    return _strokeAniamtionGroup;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _index    = 0;
        _duration = 2.;
        self.strokeAniamtionGroup.animations = @[self.strokeEndAnimation,self.strokeStartAnimation];
        [self.layer addSublayer:self.loadingLayer];
        [self loadingAnimation];
    }
    return self;
}
- (UIBezierPath*)cycleBezierPathIndex:(NSInteger)index{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height *0.5) radius:self.bounds.size.width * 0.5 startAngle:index * (M_PI* 2)/3  endAngle:index * (M_PI* 2)/3 + 2*M_PI * 4/3 clockwise:YES];
    return path;
}

- (void)loadingAnimation{
    [self.loadingLayer addAnimation:self.strokeAniamtionGroup forKey:@"strokeAniamtionGroup"];
}
#pragma mark -CAAnimationDelegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.isHidden) {
        _realFinish = YES;
        return;
    }
    _index++;
    self.loadingLayer.path = [self cycleBezierPathIndex:_index %3].CGPath;
    [self loadingAnimation];
}

#pragma mark -public
- (void)starAnimation{
    if (self.loadingLayer.animationKeys.count > 0) {
        return;
    }
    self.hidden = NO;
    if (_realFinish) {
        [self loadingAnimation];
    }
}
- (void)stopAnimation{
    self.hidden = YES;
    self.index  = 0;
    [self.loadingLayer removeAllAnimations];
}
- (void)setStrokeColor:(UIColor *)strokeColor{
    _strokeColor                   = strokeColor;
    self.loadingLayer.strokeColor  = strokeColor.CGColor;
}
- (void)destroyAnimation{
    [self stopAnimation];
    [self.loadingLayer removeFromSuperlayer];
    self.loadingLayer         = nil;
    self.strokeAniamtionGroup = nil;
}
-(void)dealloc{
#ifdef DEBUG
    NSLog(@"转子动画销毁了");
#endif
}

@end
