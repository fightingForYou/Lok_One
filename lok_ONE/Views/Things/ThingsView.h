//
//  ThingsView.h
//  lok_ONE
//
//  Created by 卡神 on 15/9/24.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "ZoomImageView.h"
#import "ThingsModel.h"

@interface ThingsView : UIView

@property (nonatomic, strong) ThingsModel *model;
///**
// strLastUpdateDate "2015-08-13 19:30:16"
// strPn             "0"
// strBu             "http:\/\/pic.yupoo.com\/hanapp\/ESg3Qt2H\/Lsvpw.jpg"
// strTm             "2015-08-14"
// strWu             "https:\/\/item.taobao.com\/item.htm?id=520977866501&from=hanhanbook",
// strId             "587"
// strTt             "All I need is U 在一起 情侣对戒"
// strTc             "金风玉露一相逢，便胜却人间无数。\r\n这个七夕，我想和你【在一起】"
// */


@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView        *containerView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel    *detailTextView;
@property (nonatomic, strong) UILabel       *dateLabel;
@property (nonatomic, strong) ZoomImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)refreshView;
@end
