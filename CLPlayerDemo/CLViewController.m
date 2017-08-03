//
//  CLViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLViewController.h"
#import "CLViewController1.h"
#import "CLViewController2.h"
#import "CLViewController3.h"
#import "CLViewController4.h"
#import "CLViewController5.h"
#import "UIView+CLSetRect.h"
@interface CLViewController ()<UITableViewDelegate,UITableViewDataSource>

/**tableView*/
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation CLViewController

/**tableView*/
- (UITableView *) tableView{
    if (_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CLscreenWidth, CLscreenHeight - 64 - 49) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"CLPlayer";
    [self.view addSubview:self.tableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UILabel *label = [[UILabel alloc] init];
    label.text = @"播放器默认全部页面只支持竖屏";
    label.textColor = [UIColor redColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:24];
    label.CLheight = 90;
    self.tableView.tableHeaderView = label;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //复用Cell
    static NSString *Identifier=@"UITableViewCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}
//在willDisplayCell里面处理数据能优化tableview的滑动流畅性
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        cell.textLabel.text = @"某个页面需要支持多个方向";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"push不支持多方向";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"push支持多方向";
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"present不支持多方向";
    }else if (indexPath.row == 4){
        cell.textLabel.text = @"present支持多方向";
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[CLViewController1 new] animated:YES];
    }else if (indexPath.row == 1){
        [self.navigationController pushViewController:[CLViewController2 new] animated:YES];
    }else if (indexPath.row == 2){
        [self.navigationController pushViewController:[CLViewController4 new] animated:YES];
    }else if (indexPath.row == 3){
        [self presentViewController:[CLViewController3 new] animated:YES completion:nil];
    }else if (indexPath.row == 4){
        [self presentViewController:[CLViewController5 new] animated:YES completion:nil];
    }
}






@end
