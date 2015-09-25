//
//  ZoomImageView.h
//  Lok_m微博
//
//  Created by 卡神 on 15/8/29.
//  Copyright (c) 2015年 lok. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZoomingDelegate <NSObject>

@optional

- (void)zoomingWillIn;
- (void)zoomingWillOut;

@end


@interface ZoomImageView : UIImageView <UIScrollViewDelegate, UIAlertViewDelegate>

@property (copy, nonatomic) NSString *bigURL;
@property (strong, nonatomic) UIImage *bigImage;

@property (weak, nonatomic) id<ZoomingDelegate>delegate;

@end
