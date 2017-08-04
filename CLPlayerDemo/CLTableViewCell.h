//
//  CLTableViewCell.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/4.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLModel.h"
@class CLTableViewCell;

@protocol CLTableViewCellDelegate <NSObject>

- (void)cl_tableViewCellPlayVideoWithCell:(CLTableViewCell *)cell;

@end

@interface CLTableViewCell : UITableViewCell

/**model*/
@property (nonatomic, copy) CLModel *model;

@property (nonatomic, weak) id <CLTableViewCellDelegate> delegate;

- (CGFloat)cellOffset;

@end
