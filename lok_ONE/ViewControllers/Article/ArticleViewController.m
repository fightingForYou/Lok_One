//
//  ArticleViewController.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//



#import "ArticleViewController.h"
#import "CommonRefreshView.h"
#import "ArticleModel.h"
#import <MJExtension/MJExtension.h>
#import "HTTPTool.h"
#import "BaseFunction.h"
#import "ArticleView.h"

@interface ArticleViewController () <CommonRefreshViewDelegate, CommonRefreshViewDataSource>

@property (nonatomic, strong) CommonRefreshView *CommonRefreshView;

@end

@implementation ArticleViewController {
    // 当前一共有多少篇文章，默认为3篇
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
        UIImage *deselectedImage = [[UIImage imageNamed:@"tabbar_item_reading"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedImage = [[UIImage imageNamed:@"tabbar_item_reading_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        // 底部导航item
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"文章" image:nil tag:0];
        tabBarItem.image = deselectedImage;
        tabBarItem.selectedImage = selectedImage;
        self.tabBarItem = tabBarItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = WebViewBGColor;
    
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
    
    [self requestReadingContentAtIndex:0];
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
    ArticleView *articleView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(CommonRefreshView.frame), CGRectGetHeight(CommonRefreshView.frame))];
        articleView = [[ArticleView alloc] initWithFrame:view.bounds];
        [view addSubview:articleView];
    } else {
        articleView = (ArticleView *)view.subviews[0];
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    if (index == numberOfItems - 1 || index == readItems.allKeys.count) {// 当前这个 item 是没有展示过的
        [articleView refresh];
    } else {// 当前这个 item 是展示过了但是没有显示过数据的
        articleView.model =  readItems[[@(index) stringValue]];
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
        ArticleView *articleView = (ArticleView *)[CommonRefreshView itemViewAtIndex:index].subviews[0];
        articleView.model =  readItems[[@(index) stringValue]];
    } else {
        [self requestReadingContentAtIndex:index];
    }
}

#pragma mark - Network Requests

// 右拉刷新
- (void)refreshing {
    if (readItems.allKeys.count > 0) {// 避免第一个还未加载的时候右拉刷新更新数据
        [self showHUDWithText:@""];
        isRefreshing = YES;
        [self requestReadingContentAtIndex:0];
    }
}

- (void)requestReadingContentAtIndex:(NSInteger)index {
    NSString *date = [BaseFunction stringDateBeforeTodaySeveralDays:index];
    [HTTPTool requestReadingContentByDate:date lastUpdateDate:lastUpdateDate success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"result"] isEqualToString:@"SUCCESS"]) {
            ArticleModel *returnReadingEntity = [[ArticleModel alloc] init];
            [returnReadingEntity setValuesForKeysWithDictionary:
            responseObject[@"contentEntity"]];
            if (isRefreshing) {
                [self endRefreshing];
                if ([returnReadingEntity.strContentId isEqualToString:((ArticleModel *)readItems[@"0"]).strContentId]) {// 没有最新数据
                    [self showHUDWithText:@"已经是最新的了" delay:1];
                } else {// 有新数据
                    // 删掉所有的已读数据，不用考虑第一个已读数据和最新数据之间相差几天，简单粗暴
                    [readItems removeAllObjects];
                    [self hideHud];
                }
                
                [self endRequestReadingContent:returnReadingEntity atIndex:index];
            } else {
                [self hideHud];
                [self endRequestReadingContent:returnReadingEntity atIndex:index];
            }
        }
    } failBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"reading error = %@", error);
    }];
}

#pragma mark - Private

- (void)endRefreshing {
    isRefreshing = NO;
    [self.CommonRefreshView endRefreshing];
}

- (void)endRequestReadingContent:(ArticleModel *)readingEntity atIndex:(NSInteger)index {
    [readItems setObject:readingEntity forKey:[@(index) stringValue]];
    [self.CommonRefreshView reloadItemAtIndex:index animated:NO];
}
#pragma mark - showShare
- (void)showShareView {
    NSLog(@"%ld",(long)_CommonRefreshView.currentItemIndex);
    NSInteger index = _CommonRefreshView.currentItemIndex;
    NSString *indexStr = [NSString stringWithFormat:@"%li",index];
    ArticleModel *model = readItems[indexStr];
    
    NSString *shareText = [NSString stringWithFormat:@"One 文章分享：%@ 作者/%@。%@",model.strContTitle,model.strContAuthor,[NSString stringWithFormat:@"%@%@",@"http://m.wufazhuce.com/article/",model.strContMarketTime]];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:shareText
                                     shareImage:nil
                                shareToSnsNames:nil
                                       delegate:nil];
    
}


@end
