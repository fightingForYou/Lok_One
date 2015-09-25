//
//  ThingsViewController.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "ThingsViewController.h"
#import "CommonRefreshView.h"
#import "ThingsModel.h"
#import <MJExtension/MJExtension.h>
#import "ThingsView.h"
#import "HTTPTool.h"

@interface ThingsViewController () <CommonRefreshViewDelegate, CommonRefreshViewDataSource>

@property (nonatomic, strong) CommonRefreshView *CommonRefreshView;

@end

@implementation ThingsViewController {
    // 当前一共有多少 item，默认为3个
    NSInteger numberOfItems;
    // 保存当前查看过的数据
    NSMutableDictionary *readItems;
    // 最后展示的 item 的下标
    NSInteger lastConfigureViewForItemIndex;
    // 当前是否正在右拉刷新标记
    BOOL isRefreshing;
}

#pragma mark - View Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_item_thing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_item_thing_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"东西" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    numberOfItems = 2;
    readItems = [[NSMutableDictionary alloc] init];
    lastConfigureViewForItemIndex = 0;
    isRefreshing = NO;
    
    self.CommonRefreshView = [[CommonRefreshView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight - 64 - CGRectGetHeight(self.tabBarController.tabBar.frame))];
    self.CommonRefreshView.delegate = self;
    self.CommonRefreshView.dataSource = self;
    [self.view addSubview:self.CommonRefreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionNightFallingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionDawnComingNotification" object:nil];
    
    [self requestThingContentAtIndex:0];
}

#pragma mark - Lifecycle

- (void)dealloc {
    self.CommonRefreshView.delegate = nil;
    self.CommonRefreshView.dataSource = nil;
    self.CommonRefreshView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotification

- (void)nightModeSwitch:(NSNotification *)notification {
    [self.CommonRefreshView reloadData];
}

#pragma mark - CommonRefreshViewDataSource

- (NSInteger)numberOfItemsInCommonRefreshView:(CommonRefreshView *)CommonRefreshView {
    return numberOfItems;
}

- (UIView *)CommonRefreshView:(CommonRefreshView *)CommonRefreshView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    ThingsView *thingView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(CommonRefreshView.frame), CGRectGetHeight(CommonRefreshView.frame))];
        thingView = [[ThingsView alloc] initWithFrame:view.bounds];
        [view addSubview:thingView];
    } else {
        thingView = (ThingsView *)view.subviews[0];
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    if (index == numberOfItems - 1 || index == readItems.allKeys.count) {// 当前这个 item 是没有展示过的
        [thingView refreshView];
    } else {// 当前这个 item 是展示过了但是没有显示过数据的
        lastConfigureViewForItemIndex = MAX(index, lastConfigureViewForItemIndex);
        thingView.model = readItems[[@(index) stringValue]];
    }
    
    return view;
}

#pragma mark - CommonRefreshViewDelegate

- (void)CommonRefreshViewRefreshing:(CommonRefreshView *)CommonRefreshView {
    [self refreshing];
}

- (void)CommonRefreshView:(CommonRefreshView *)CommonRefreshView didDisplayItemAtIndex:(NSInteger)index {
    if (index == numberOfItems - 1) {// 如果当前显示的是最后一个，则添加一个 item
        numberOfItems++;
        [self.CommonRefreshView insertItemAtIndex:(numberOfItems - 1) animated:YES];
    }
    
    if (index < readItems.allKeys.count && readItems[[@(index) stringValue]]) {
        ThingsView *thingView = (ThingsView *)[CommonRefreshView itemViewAtIndex:index].subviews[0];
        thingView.model = readItems[[@(index) stringValue]];
    } else {
        [self requestThingContentAtIndex:index];
    }
}

#pragma mark - Network Requests

// 右拉刷新
- (void)refreshing {
    if (readItems.allKeys.count > 0) {// 避免第一个还未加载的时候右拉刷新更新数据
        [self showHUDWithText:@""];
        isRefreshing = YES;
        [self requestThingContentAtIndex:0];
    }
}

- (void)requestThingContentAtIndex:(NSInteger)index {
    [HTTPTool requestThingContentByIndex:index success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"rs"] isEqualToString:@"SUCCESS"]) {
            ThingsModel *returnThingEntity = [[ThingsModel alloc] init];
            [returnThingEntity setValuesForKeysWithDictionary:responseObject[@"entTg"]];
            
            if (isRefreshing) {
                [self endRefreshing];
                if ([returnThingEntity.strId isEqualToString:((ThingsModel *)readItems[@"0"]).strId]) {// 没有最新数据
                    [self showHUDWithText:@"已经是最新的了" delay:1];
                } else {// 有新数据
                    // 删掉所有的已读数据，不用考虑第一个已读数据和最新数据之间相差几天，简单粗暴
                    [readItems removeAllObjects];
                    [self hideHud];
                }
                
                [self endRequestThingContent:returnThingEntity atIndex:index];
            } else {
                [self hideHud];
                [self endRequestThingContent:returnThingEntity atIndex:index];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@", error);
    }];
}

#pragma mark - Private

- (void)endRefreshing {
    isRefreshing = NO;
    [self.CommonRefreshView endRefreshing];
}

- (void)endRequestThingContent:(ThingsModel *)thingEntity atIndex:(NSInteger)index {
    [readItems setObject:thingEntity forKey:[@(index) stringValue]];
    [self.CommonRefreshView reloadItemAtIndex:index animated:NO];
}


#pragma mark - showShare
- (void)showShareView {
    //    NSLog(@"%ld",(long)_carousel.currentItemIndex);
    NSInteger index = _CommonRefreshView.currentItemIndex;
    NSString *indexStr = [NSString stringWithFormat:@"%li",index];
    ThingsModel *model = readItems[indexStr];
    
    
    NSString *shareText = [NSString stringWithFormat:@"%@。%@ %@",model.strTt,model.strTc,model.strWu];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:shareText
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.strBu]]]
                                shareToSnsNames:nil
                                       delegate:nil];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
