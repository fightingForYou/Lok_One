//
//  CommonRefreshView.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/24.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "CommonRefreshView.h"
#import <iCarousel/iCarousel.h>

#define LabelOffsetX 20
#define LeftRefreshLabelTextColor [UIColor colorWithRed:90 / 255.0 green:91 / 255.0 blue:92 / 255.0 alpha:1]

@interface CommonRefreshView () <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UILabel *leftRefreshLabel;

@end

@implementation CommonRefreshView {
    // 视图控件的高度
    CGFloat selfHeight;
    // 当前一共有多少个 item
    NSInteger numberOfItems;
    // 保存当 leftRefreshLabel 的 text 为“右拉刷新...”时的宽，在右拉的时候用到
    CGFloat leftRefreshLabelWidth;
    // 标记是否需要刷新，默认为 NO
    BOOL isNeedRefresh;
    // 保存右拉的 x 距离
    CGFloat draggedX;
    // 标记是否能够 scroll back，用在刷新的时候不改变 leftRefreshLabel 的 frame，默认为 YES
    BOOL canScrollBack;
    // 最后一次显示的 item 的下标
    NSInteger lastItemIndex;
}

#pragma mark - View Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)dealloc {
    self.carousel.delegate = nil;
    self.carousel.dataSource = nil;
    [self.carousel removeFromSuperview];
    self.carousel = nil;
    [self.leftRefreshLabel removeFromSuperview];
    self.leftRefreshLabel = nil;
}

#pragma mark - Private

- (void)setUp {
    
    selfHeight = CGRectGetHeight(self.frame);
    isNeedRefresh = NO;
    canScrollBack = YES;
    draggedX = 0;
    lastItemIndex = -1;
    
    [self setUpViews];
}

#pragma mark 初始化视图控件
- (void)setUpViews {
    self.carousel = [[iCarousel alloc] initWithFrame:self.bounds];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.vertical = NO;
    self.carousel.pagingEnabled = YES;
    self.carousel.bounceDistance = 0.7;
    self.carousel.decelerationRate = 0.6;
    [self addSubview:self.carousel];
    
    self.leftRefreshLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.leftRefreshLabel.font = [UIFont systemFontOfSize:10.0f];
    self.leftRefreshLabel.textColor = LeftRefreshLabelTextColor;
    self.leftRefreshLabel.textAlignment = NSTextAlignmentRight;
    self.leftRefreshLabel.text = LeftDragToRightForRefreshHintText;
    [self.leftRefreshLabel sizeToFit];
    [self.leftRefreshLabel setNeedsDisplay];
    leftRefreshLabelWidth = CGRectGetWidth(self.leftRefreshLabel.frame);
    CGRect labelFrame = CGRectMake(0 - leftRefreshLabelWidth * 1.5 - LabelOffsetX, (CGRectGetMaxY(self.carousel.frame) - CGRectGetHeight(self.leftRefreshLabel.frame)) / 2.0, leftRefreshLabelWidth * 1.5, CGRectGetHeight(self.leftRefreshLabel.frame));
    self.leftRefreshLabel.frame = labelFrame;
    [self.carousel.contentView addSubview:self.leftRefreshLabel];
}

#pragma mark - Public

- (void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    numberOfItems++;
    [self.carousel insertItemAtIndex:(numberOfItems - 1) animated:YES];
    
}

- (void)reloadData {
    [self.carousel reloadData];
}

- (void)reloadItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.carousel reloadItemAtIndex:index animated:animated];
}

- (UIView *)itemViewAtIndex:(NSInteger)index {
    return [self.carousel itemViewAtIndex:index];
}

- (void)endRefreshing {
    
    
        CGRect frame = self.leftRefreshLabel.frame;
        frame.origin.x = 0 - leftRefreshLabelWidth * 1.5 - LabelOffsetX;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.carousel.contentOffset = CGSizeMake(0, 0);
            self.leftRefreshLabel.frame = frame;
        } completion:^(BOOL finished) {
            isNeedRefresh = NO;
            canScrollBack = YES;
        }];
    
}

#pragma mark - Getter

- (NSInteger)currentItemIndex {
    return self.carousel.currentItemIndex;
}

- (UIView *)currentItemView {
    return [self.carousel itemViewAtIndex:self.currentItemIndex];
}

#pragma mark - Setter

- (void)setDelegate:(id<CommonRefreshViewDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate && _dataSource) {
            [self setNeedsLayout];
        }
    }
}

- (void)setDataSource:(id<CommonRefreshViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        
        if (_dataSource) {
            [self.carousel reloadData];
        }
    }
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    numberOfItems = [self.dataSource numberOfItemsInCommonRefreshView:self];
       return numberOfItems;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    return [self.dataSource CommonRefreshView:self viewForItemAtIndex:index reusingView:view];
}

#pragma mark - iCarouselDelegate

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return CGRectGetWidth(self.frame);
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    
    if (carousel.scrollOffset <= 0) {
        
        if (canScrollBack) {
            // scrollOffset的大小为0-1
            draggedX = fabs(carousel.scrollOffset * carousel.itemWidth);
            
            CGRect frame = self.leftRefreshLabel.frame;
            frame.origin.x = draggedX - CGRectGetWidth(self.leftRefreshLabel.frame) - LabelOffsetX;
            self.leftRefreshLabel.frame = frame;
            
            if (draggedX >= leftRefreshLabelWidth * 1.5 + LabelOffsetX) {
                
                self.leftRefreshLabel.text = LeftReleaseToRefreshHintText;
                
                isNeedRefresh = YES;
            } else {
                
                self.leftRefreshLabel.text = LeftDragToRightForRefreshHintText;
                
                isNeedRefresh = NO;
            }
        }
        
    }
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    
    if (!decelerate && isNeedRefresh) {
        // 设置 leftRefreshLabel 的显示文字、X 轴坐标
        self.leftRefreshLabel.text = LeftReleaseIsRefreshingHintText;
        CGRect frame = self.leftRefreshLabel.frame;
        frame.origin.x = leftRefreshLabelWidth - CGRectGetWidth(self.leftRefreshLabel.frame);
        
        [UIView animateWithDuration:0.2 animations:^{
            // 设置 carousel item 的 X 轴偏移
            carousel.contentOffset = CGSizeMake(CGRectGetMaxX(frame) + LabelOffsetX, 0);
            
            self.leftRefreshLabel.frame = frame;
        }];
        
        if ([self.delegate respondsToSelector:@selector(CommonRefreshViewRefreshing:)]) {
            [self.delegate CommonRefreshViewRefreshing:self];
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    
    if (carousel.currentItemIndex == 0 && canScrollBack) {
        self.leftRefreshLabel.text = LeftDragToRightForRefreshHintText;
        isNeedRefresh = NO;
    }
    
    if (lastItemIndex != carousel.currentItemIndex) {
        
        if ([self.delegate respondsToSelector:@selector(CommonRefreshView:didDisplayItemAtIndex:)]) {
            [self.delegate CommonRefreshView:self didDisplayItemAtIndex:carousel.currentItemIndex];
        }
    }
    
    lastItemIndex = carousel.currentItemIndex;
    
 
}



@end
