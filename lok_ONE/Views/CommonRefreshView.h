//
//  CommonRefreshView.h
//  lok_ONE
//
//  Created by 卡神 on 15/9/24.
//  Copyright © 2015年 lok. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol CommonRefreshViewDelegate;
@protocol CommonRefreshViewDataSource;
@interface CommonRefreshView : UIView

@property (nonatomic, assign) id <CommonRefreshViewDelegate> delegate;
@property (nonatomic, assign) id <CommonRefreshViewDataSource> dataSource;
@property (nonatomic, readonly) NSInteger currentItemIndex;
@property (nonatomic, strong, readonly) UIView *currentItemView;

/**
 *  插入一个新的 item
 *
 *  @param index     新的 item 的下标
 *  @param animated 是否需要动画
 */
- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  重新加载数据
 */
- (void)reloadData;

/**
 *  重新加载指定下标的 item
 *
 *  @param index  要重新加载的 item 的下标
 */
- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 *  获取指定下标的 item
 *
 *  @param index  要获取的 item 的下标
 *
 *  @return 指定下标的 item
 */
- (UIView *)itemViewAtIndex:(NSInteger)index;

/**
 *  结束刷新
 */
- (void)endRefreshing;

@end

@protocol CommonRefreshViewDataSource <NSObject>

@required
/**
 *  一共有多少个 item
 *
 *  @param CommonRefreshView CommonRefreshView
 *
 *  @return item 的个数
 */
- (NSInteger)numberOfItemsInCommonRefreshView:(CommonRefreshView *)CommonRefreshView;

/**
 *  当前要显示的 item 的 view
 *
 *  @param CommonRefreshView CommonRefreshView
 *  @param index                  当前要显示的 item 的下标
 *  @param view                   重用的 view
 *
 *  @return item 的 view
 */
- (UIView *)CommonRefreshView:(CommonRefreshView *)CommonRefreshView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@end

@protocol CommonRefreshViewDelegate <NSObject>

@optional

/**
 *  右拉刷新时回调的方法
 *
 *  @param CommonRefreshView CommonRefreshView
 */
- (void)CommonRefreshViewRefreshing:(CommonRefreshView *)CommonRefreshView;

/**
 *  当当前显示的是最后一个 item 时回调，用于添加新的 item
 *
 *  @param CommonRefreshView CommonRefreshView
 */
- (void)CommonRefreshViewDidScrollToLastItem:(CommonRefreshView *)CommonRefreshView;

/**
 *  item 在屏幕上显示完毕
 *
 *  @param CommonRefreshView CommonRefreshView
 *  @param index                  当前 item 的下标
 */
- (void)CommonRefreshView:(CommonRefreshView *)CommonRefreshView didDisplayItemAtIndex:(NSInteger)index;

@end