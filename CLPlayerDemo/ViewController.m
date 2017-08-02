//
//  ViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "CLPlayerView.h"
#import "TableViewCell.h"
#import "Model.h"
#import "UIView+CLSetRect.h"
#import  "Masonry.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,VideoDelegate,UIScrollViewDelegate>

/**tableView*/
@property (nonatomic,strong) UITableView *tableView;
/**数据源*/
@property (nonatomic,strong) NSMutableArray *arrayDS;
/**CLplayer*/
@property (nonatomic,weak) CLPlayerView *playerView;
/**记录Cell*/
@property (nonatomic,assign) TableViewCell *cell;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initDate];
    
    [self initUI];
}

- (void)initDate
{
    _arrayDS = [NSMutableArray array];
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Date" ofType:@"json"]];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Model *model = [Model new];
        [model setValuesForKeysWithDictionary:obj];
        [_arrayDS addObject:model];
    }];

}
- (void)initUI
{
    self.navigationItem.title = @"CLPlayer";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CLscreenWidth, CLscreenHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayDS.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Index = @"Cell";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Index];
    if (!cell)
    {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Index];
    }
    cell.videoDelegate = self;
    return cell;
}
//在willDisplayCell里面处理数据能优化tableview的滑动流畅性
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell * myCell = (TableViewCell *)cell;
    myCell.model = _arrayDS[indexPath.row];
    //Cell开始出现的时候修正偏移量，让图片可以全部显示
    [myCell cellOffset];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}
#pragma mark - 点击播放代理
- (void)PlayVideoWithCell:(TableViewCell *)cell;
{
    //记录被点击的Cell
    _cell = cell;
    
    //销毁播放器
    [_playerView destroyPlayer];
    _playerView = nil;
    
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, cell.CLwidth, cell.CLheight)];
   
    _playerView = playerView;
    [cell.contentView addSubview:_playerView];
    
    //根据旋转自动支持全屏，默认支持
//        _playerView.autoFullScreen = NO;
    //重复播放，默认不播放
    //    _playerView.repeatPlay     = YES;
    //设置等比例全屏拉伸，多余部分会被剪切
//    _playerView.fillMode = ResizeAspectFill;
    //设置进度条背景颜色
//    _playerView.progressBackgroundColor = [UIColor purpleColor];
//    //设置进度条缓冲颜色
//    _playerView.progressBufferColor = [UIColor redColor];
//    //设置进度条播放完成颜色
//    _playerView.progressPlayFinishColor = [UIColor greenColor];
    //视频地址
    _playerView.url = [NSURL URLWithString:cell.model.videoUrl];
    //播放
    [_playerView playVideo];

    //返回按钮点击事件回调
    [_playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    
    //播放完成回调
    [_playerView endPlay:^{
        //销毁播放器
        [_playerView destroyPlayer];
        _playerView = nil;
        NSLog(@"播放完成");
    }];
}
#pragma mark - 滑动代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // visibleCells 获取界面上能显示出来了cell
    NSArray<TableViewCell *> *array = [self.tableView visibleCells];
    //enumerateObjectsUsingBlock 类似于for，但是比for更快
    [array enumerateObjectsUsingBlock:^(TableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cellOffset];
    }];
    //计算偏移来销毁播放器
    [_playerView calculateScrollOffset:self.tableView cell:_cell];
}
#pragma mark -- 需要页面支持其他方向，需要重写这三个方法，默认所有页面只支持竖屏
//// 是否支持自动转屏
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//// 支持哪些屏幕方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}
//// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}




@end
