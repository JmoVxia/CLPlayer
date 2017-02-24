//
//  CLPlayerMaskView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/2/24.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLPlayerMaskView.h"
#import "CLplayer.h"
@interface CLPlayerMaskView ()
/**顶部工具条*/
@property (nonatomic,strong) UIView *topToolBar;
/**底部工具条*/
@property (nonatomic,strong) UIView *bottomToolBar;
/**转子*/
@property (nonatomic,strong) UIActivityIndicatorView *activity;
/**顶部工具条返回按钮*/
@property (nonatomic,strong) UIButton *backButton;
/**底部工具条播放按钮*/
@property (nonatomic,strong) UIButton *playButton;
/**底部工具条全屏按钮*/
@property (nonatomic,strong) UIButton *fullButton;
@end

@implementation CLPlayerMaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}
- (void)initViews{
    [self addSubview:self.topToolBar];
    [self addSubview:self.bottomToolBar];
    [self addSubview:self.activity];
    [self.topToolBar addSubview:self.backButton];
    [self.bottomToolBar addSubview:self.playButton];
    [self.bottomToolBar addSubview:self.fullButton];
    [self makeConstraints];
    
    
    self.topToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    self.bottomToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    
}
#pragma mark - 约束
- (void)makeConstraints{
    //顶部工具条
    [self.topToolBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(40);
    }];
    //底部工具条
    [self .bottomToolBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(40);
    }];
    //转子
    [self.activity makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    //返回按钮
    [self.backButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(10);
        make.bottom.equalTo(-10);
        make.width.equalTo(self.backButton.height);
    }];
    //播放按钮
    [self.playButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(10);
        make.bottom.equalTo(-10);
        make.width.equalTo(self.backButton.height);
    }];
    //全屏按钮
    [self.fullButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(-10);
        make.top.equalTo(10);
        make.width.equalTo(self.backButton.height);
    }];
}



#pragma mark - 懒加载
//顶部工具条
- (UIView *) topToolBar{
    if (_topToolBar == nil){
        _topToolBar = [[UIView alloc]init];
    }
    return _topToolBar;
}
//底部工具条
- (UIView *) bottomToolBar{
    if (_bottomToolBar == nil){
        _bottomToolBar = [[UIView alloc]init];
    }
    return _bottomToolBar;
}
//转子
- (UIActivityIndicatorView *) activity{
    if (_activity == nil){
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}
//返回按钮
- (UIButton *) backButton{
    if (_backButton == nil){
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[self getPictureWithName:@"CLBackBtn"] forState:UIControlStateNormal];
        [_backButton setImage:[self getPictureWithName:@"CLBackBtn"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
//播放按钮
- (UIButton *) playButton{
    if (_playButton == nil){
        _playButton = [[UIButton alloc]init];
        [_playButton setImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
        [_playButton setImage:[self getPictureWithName:@"CLPauseBtn"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
- (UIButton *) fullButton{
    if (_fullButton == nil){
        _fullButton = [[UIButton alloc]init];
        [_fullButton setImage:[self getPictureWithName:@"CLMaxBtn"] forState:UIControlStateNormal];
        [_fullButton setImage:[self getPictureWithName:@"CLMinBtn"] forState:UIControlStateSelected];
        [_fullButton addTarget:self action:@selector(fullButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}
#pragma mark - 按钮点击事件
//返回按钮
- (void)backButtonAction:(UIButton *)button{
    
}
//播放按钮
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
}
//全屏按钮
- (void)fullButtonAction:(UIButton *)button{
    button.selected = !button.selected;

}






#pragma mark - 获取资源图片
- (UIImage *)getPictureWithName:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}


@end
