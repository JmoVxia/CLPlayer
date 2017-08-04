//
//  CLTableViewCell.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/4.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+CLSetRect.h"

#define CellHeight   300
#define ImageViewHeight 600

@interface CLTableViewCell ()

/**button*/
@property (nonatomic,strong) UIButton *button;
/**picture*/
@property (nonatomic,strong) UIImageView *pictureView;

@end

@implementation CLTableViewCell
#pragma mark - 懒加载
/**button*/
- (UIButton *) button{
    if (_button == nil){
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_button setBackgroundImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
/**pictureView*/
- (UIImageView *) pictureView{
    if (_pictureView == nil){
        _pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, - (ImageViewHeight - CellHeight) * 0.5, CLscreenWidth, ImageViewHeight)];    }
    return _pictureView;
}
#pragma mark - 入口
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initUI];
    }
    return self;
}
- (void)initUI{
    //剪裁看不到的
    self.clipsToBounds       = YES;
    self.selectionStyle      = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.pictureView];
    [self.contentView addSubview:self.button];
}
-(void)setModel:(CLModel *)model{
    _model = model;
    __block UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    [[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:_model.pictureUrl] completion:^(BOOL isInCache) {
        if (isInCache) {
            //本地存在图片,替换占位图片
            placeholderImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.pictureUrl];
        }
        //主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [_pictureView sd_setImageWithURL:[NSURL URLWithString:model.pictureUrl] placeholderImage:placeholderImage];
        });
    }];
}
- (void)playAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_tableViewCellPlayVideoWithCell:)]){
        [_delegate cl_tableViewCellPlayVideoWithCell:self];
    }
}
- (UIImage *)getPictureWithName:(NSString *)name{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}
- (CGFloat)cellOffset{
    /*
     - (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;
     将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect
     这里用来获取self在window上的位置
     */
    CGRect toWindow      = [self convertRect:self.bounds toView:self.window];
    //获取父视图的中心
    CGPoint windowCenter = self.superview.center;
    //cell在y轴上的位移
    CGFloat cellOffsetY  = CGRectGetMidY(toWindow) - windowCenter.y;
    //位移比例
    CGFloat offsetDig    = 2 * cellOffsetY / self.superview.frame.size.height ;
    //要补偿的位移,self.superview.frame.origin.y是tableView的Y值，这里加上是为了让图片从最上面开始显示
    CGFloat offset       = - offsetDig * (ImageViewHeight - CellHeight) / 2;
    //让pictureViewY轴方向位移offset
    CGAffineTransform transY = CGAffineTransformMakeTranslation(0,offset);
    _pictureView.transform   = transY;
    return offset;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _button.CLcenterX     = self.CLwidth/2.0;
    _button.CLcenterY     = self.CLheight/2.0;
    _pictureView.CLwidth  = self.CLwidth;
}

@end
