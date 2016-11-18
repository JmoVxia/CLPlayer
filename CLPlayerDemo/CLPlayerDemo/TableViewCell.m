//
//  TableViewCell.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/18.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "TableViewCell.h"
#import "CLPlayerView.h"
#import "UIView+CLSetRect.h"

@interface TableViewCell ()

/**button*/
@property (nonatomic,weak) UIButton *button;

@end



@implementation TableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    _button = button;
}

-(void)setUrl:(NSString *)url
{
    _url = url;
}

- (void)playAction:(UIButton *)button
{
    if (_videoDelegate && [_videoDelegate respondsToSelector:@selector(PlayVideoWithCell:)])
    {
        [_videoDelegate PlayVideoWithCell:self];
    }
   
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _button.centerX = self.width/2.0;
    _button.centerY = self.height/2.0;
}


@end
