//
//  QuestionViewController.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "QuestionViewController.h"
#import "CommonRefreshView.h"
#import "QuestionModel.h"
#import <MJExtension/MJExtension.h>
#import "QuestionView.h"
#import "HTTPTool.h"
#import "BaseFunction.h"

@interface QuestionViewController () <CommonRefreshViewDelegate, CommonRefreshViewDataSource>

@property (nonatomic, strong) CommonRefreshView *CommonRefreshView;

@end

@implementation QuestionViewController {
    // 当前一共有多少 item，默认为3个
    NSInteger numberOfItems;
    // 保存当前查看过的数据
    NSMutableDictionary *readItems;
    // 最后更新的日期
    NSString *lastUpdateDate;
    // 当前是否正在右拉刷新标记
    BOOL isRefreshing;
}

#pragma mark - View Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_item_question"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_item_question_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"问题" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //  [self setUpNavigationBarShowRightBarButtonItem:YES];
    
    numberOfItems = 2;
    readItems = [[NSMutableDictionary alloc] init];
    lastUpdateDate = [BaseFunction stringDateBeforeTodaySeveralDays:0];
    isRefreshing = NO;
    
    self.CommonRefreshView = [[CommonRefreshView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight - 64 - CGRectGetHeight(self.tabBarController.tabBar.frame))];
    self.CommonRefreshView.delegate = self;
    self.CommonRefreshView.dataSource = self;
    [self.view addSubview:self.CommonRefreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionNightFallingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeSwitch:) name:@"DKNightVersionDawnComingNotification" object:nil];
    
    [self requestQuestionContentAtIndex:0];
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
    QuestionView *questionView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(CommonRefreshView.frame), CGRectGetHeight(CommonRefreshView.frame))];
        questionView = [[QuestionView alloc] initWithFrame:view.bounds];
        
        [view addSubview:questionView];
    } else {
        questionView = (QuestionView *)view.subviews[0];
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    if (index == numberOfItems - 1 || index == readItems.allKeys.count) {// 当前这个 item 是没有展示过的
        [questionView refresh];
    } else {// 当前这个 item 是展示过了但是没有显示过数据的
        questionView.model = readItems[[@(index) stringValue]];
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
        QuestionView *questionView = (QuestionView *)[CommonRefreshView itemViewAtIndex:index].subviews[0];
        questionView.model = readItems[[@(index) stringValue]];
    } else {
        [self requestQuestionContentAtIndex:index];
    }
}

#pragma mark - Network Requests

// 右拉刷新
- (void)refreshing {
    if (readItems.allKeys.count > 0) {// 避免第一个还未加载的时候右拉刷新更新数据
        [self showHUDWithText:@""];
        isRefreshing = YES;
        [self requestQuestionContentAtIndex:0];
    }
}

- (void)requestQuestionContentAtIndex:(NSInteger)index {
    NSString *date = [BaseFunction stringDateBeforeTodaySeveralDays:index];
    [HTTPTool requestQuestionContentByDate:date lastUpdateDate:lastUpdateDate success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"result"] isEqualToString:@"SUCCESS"]) {
            QuestionModel *returnQuestionEntity = [[QuestionModel alloc] init];
            [returnQuestionEntity setValuesForKeysWithDictionary:responseObject[@"questionAdEntity"]];
            if ([returnQuestionEntity.strQuestionId isEqualToString:@""]) {
                returnQuestionEntity.strQuestionMarketTime = date;
            }
            
            if (isRefreshing) {
                [self endRefreshing];
                if ([returnQuestionEntity.strQuestionId isEqualToString:((QuestionModel *)readItems[@"0"]).strQuestionId]) {// 没有最新数据
                    [self showHUDWithText:@"已经是最新的了" delay:1];
                } else {// 有新数据
                    // 删掉所有的已读数据，不用考虑第一个已读数据和最新数据之间相差几天，简单粗暴
                    [readItems removeAllObjects];
                    [self hideHud];
                }
                
                [self endRequestQuestionContent:returnQuestionEntity atIndex:index];
            } else {
                [self hideHud];
                [self endRequestQuestionContent:returnQuestionEntity atIndex:index];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"question error = %@", error);
    }];
}

#pragma mark - Private

- (void)endRefreshing {
    isRefreshing = NO;
    [self.CommonRefreshView endRefreshing];
}

- (void)endRequestQuestionContent:(QuestionModel *)questionEntity atIndex:(NSInteger)index {
    [readItems setObject:questionEntity forKey:[@(index) stringValue]];
    [self.CommonRefreshView reloadItemAtIndex:index animated:NO];
}

#pragma mark -showShare

- (void)showShareView {

    NSInteger index = _CommonRefreshView.currentItemIndex;
    NSString *indexStr = [NSString stringWithFormat:@"%li",index];
    QuestionModel *model = readItems[indexStr];
    
    
    NSString *shareText = [NSString stringWithFormat:@"%@ %@",model.strQuestionTitle,[NSString stringWithFormat:@"%@%@",@"http://m.wufazhuce.com/question/",model.strQuestionMarketTime]];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:shareText
                                     shareImage:[UIImage imageNamed:@"huwenjie.jpg"]
                                shareToSnsNames:nil
                                       delegate:nil];
    
}
@end
