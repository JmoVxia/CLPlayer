//
//  TableViewCell.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/18.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewCell;

@protocol VideoDelegate <NSObject>

- (void)PlayVideoWithCell:(TableViewCell *)cell;


@end



@interface TableViewCell : UITableViewCell

/**url*/
@property (nonatomic,copy) NSString *url;

@property (nonatomic,weak) id <VideoDelegate>videoDelegate;


@end
