//
//  HomeViewController.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//


#import "HomeViewController.h"
#import "CommonRefreshView.h"
#import "HomeModel.h"
#import <MJExtension/MJExtension.h>
#import "HomeView.h"
#import "HTTPTool.h"


@interface HomeViewController () <CommonRefreshViewDelegate, CommonRefreshViewDataSource>

@property (nonatomic, strong) CommonRefreshView *CommonRefreshView;

@end

@implementation HomeViewController {
    // 当前一共有多少篇文章，默认为3篇
    NSInteger numberOfItems;
    // 保存当前查看过的数据
    NSMutableDictionary *readItems;
    // 最后展示的 item 的下标
    NSInteger lastConfigureViewForItemIndex;
    // 当前是否正在右拉刷新标记
    BOOL isRefreshing;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self setUpNavigationBarShowRightBarButtonItem:YES];
    
    
    numberOfItems = 2;
    readItems = [[NSMutableDictionary alloc] init];
    lastConfigureViewForItemIndex = 0;
    isRefreshing = NO;
    
    self.CommonRefreshView = [[CommonRefreshView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight - 64 - CGRectGetHeight(self.tabBarController.tabBar.frame))];
    self.CommonRefreshView.delegate = self;
    self.CommonRefreshView.dataSource = self;
    [self.view addSubview:self.CommonRefreshView];
    
    [self requestHomeContentAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionNightFallingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionDawnComingNotification" object:nil];
    
    //	UIDevice *device = [UIDevice currentDevice];
    //	NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    //	NSString *deviceID = [BaseFunction md5Digest:currentDeviceId];
    //	// @"761784e559875c76cc95222cc8c8135a17bb61e1079fb654100ce81f4ef8e6ef"
    //	NSString *myid = @"761784e559875c76cc95222cc8c8135a17bb61e1079fb654100ce81f4ef8e6ef";
    //	NSLog(@"myid.length = %ld", myid.length);
    //	NSLog(@"deviceID = %@, deviceID.length = %ld", deviceID, deviceID.length);
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
    HomeView *homeView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(CommonRefreshView.frame), CGRectGetHeight(CommonRefreshView.frame))];
        homeView = [[HomeView alloc] initWithFrame:view.bounds];
        [view addSubview:homeView];
    } else {
        homeView = (HomeView *)view.subviews[0];
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    if (index == numberOfItems - 1 || index == readItems.allKeys.count) {// 当前这个 item 是没有展示过的
        [homeView refreshView];
    } else {// 当前这个 item 是展示过了但是没有显示过数据的
        lastConfigureViewForItemIndex = MAX(index, lastConfigureViewForItemIndex);
        //[homeView configureViewWithHomeEntity:readItems[[@(index) stringValue]] animated:YES];
        homeView.model = readItems[[@(index) stringValue]];
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
        HomeView *homeView = (HomeView *)[CommonRefreshView itemViewAtIndex:index].subviews[0];
        //[homeView configureViewWithHomeEntity:readItems[[@(index) stringValue]] animated:(lastConfigureViewForItemIndex == 0 || lastConfigureViewForItemIndex < index)];
        homeView.model = readItems[[@(index) stringValue]] ;
    } else {
        [self requestHomeContentAtIndex:index];
    }
}

#pragma mark - Network Requests

// 右拉刷新
- (void)refreshing {
    if (readItems.allKeys.count > 0) {// 避免第一个还未加载的时候右拉刷新更新数据
        [self showHUDWithText:@""];
        isRefreshing = YES;
        [self requestHomeContentAtIndex:0];
    }
}

- (void)requestHomeContentAtIndex:(NSInteger)index {
    [HTTPTool requestHomeContentByIndex:index success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"result"] isEqualToString:@"SUCCESS"]) {
            HomeModel *returnHomeEntity = [[HomeModel alloc] init];
            [returnHomeEntity setValuesForKeysWithDictionary:responseObject[@"hpEntity"]];
            
            if (isRefreshing) {
                [self endRefreshing];
                if ([returnHomeEntity.strHpId isEqualToString:((HomeModel *)readItems[@"0"]).strHpId]) {// 没有最新数据
                    [self showHUDWithText:@"已经是最新的了" delay:1];
                } else {// 有新数据
                    // 删掉所有的已读数据，不用考虑第一个已读数据和最新数据之间相差几天，简单粗暴
                    [readItems removeAllObjects];
                    [self hideHud];
                }
                
                [self endRequestHomeContent:returnHomeEntity atIndex:index];
            } else {
                [self hideHud];
                [self endRequestHomeContent:returnHomeEntity atIndex:index];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"home error = %@", error);
    }];
}

#pragma mark - Private

- (void)endRefreshing {
    isRefreshing = NO;
    [self.CommonRefreshView endRefreshing];
}

- (void)endRequestHomeContent:(HomeModel *)HomeModel atIndex:(NSInteger)index {
    [readItems setObject:HomeModel forKey:[@(index) stringValue]];
    [self.CommonRefreshView reloadItemAtIndex:index animated:NO];
}

#pragma mark - shareView


- (void)showShareView {
    NSLog(@"%ld",(long)_CommonRefreshView.currentItemIndex);
    NSInteger index = _CommonRefreshView.currentItemIndex;
    NSString *indexStr = [NSString stringWithFormat:@"%li",index];
    HomeModel *model = readItems[indexStr];
    
    NSString *shareText = [NSString stringWithFormat:@"%@。%@",model.strContent,[NSString stringWithFormat:@"%@%@",@"http://m.wufazhuce.com/one/",model.strMarketTime]];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:shareText
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.strOriginalImgUrl]]]
                                shareToSnsNames:nil
                                       delegate:nil];
    
}



@end
