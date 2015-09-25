//
//  ThingsView.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/24.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "ThingsView.h"
#import "UIViewExt.h"
#import <DKNightVersion.h>

@implementation ThingsView

- (void)setModel:(ThingsModel *)model {
    _model = model;
    [self initSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self _createSubs];
    }
    return self;
}


- (void)_createSubs {
    
   
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [_scrollView addSubview:_containerView];
    
    _nameLabel = [[UILabel alloc] init];
    [_containerView addSubview:_nameLabel];
    
    _detailTextView = [[UILabel alloc] init];
    [_containerView addSubview:_detailTextView];
    
    _dateLabel = [[UILabel alloc] init];
    [_containerView addSubview:_dateLabel];
    
    _imageView = [[ZoomImageView alloc] init];
    [_containerView addSubview:_imageView];
    
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    [self addSubview:_indicatorView];
    
}

- (void)initSubviews {
    
    _scrollView.backgroundColor = [UIColor whiteColor];
    self.nightBackgroundColor = NightBGViewColor;
    _scrollView.nightBackgroundColor = NightBGViewColor;
    _containerView.nightBackgroundColor = NightBGViewColor;
   
    // 背景滑动视图
    _scrollView.scrollEnabled = YES;
    
    NSArray *dateArray = [_model.strTm componentsSeparatedByString:@"-"];
    //    NSLog(@"dateArray : %@",dateArray);
    NSDictionary *dataChange = @{@"01":@"January",  @"02":@"February",
                                 @"03":@"March",    @"04":@"April",
                                 @"05":@"May",      @"06":@"June",
                                 @"07":@"July",     @"08":@"August",
                                 @"09":@"September",@"10":@"October",
                                 @"11":@"November", @"12":@"December"};
    //    NSLog(@"%@",dataChange[dateArray[1]]);
    _dateLabel.frame = CGRectMake(8, 15, kWidth-8, 30);
    _dateLabel.font = [UIFont boldSystemFontOfSize:16];
    _dateLabel.textColor = [UIColor darkGrayColor];
    _dateLabel.nightTextColor = DateTextColor;
    _dateLabel.text = [NSString stringWithFormat:@"%@ %@, %@",dataChange[dateArray[1]],dateArray[2],dateArray[0]];
    
    
    _imageView.frame = CGRectMake(8, 50, kWidth-16, kWidth-16);
    _imageView.bigURL = _model.strBu;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_model.strBu]];
    
    _nameLabel.frame = CGRectMake(12, _imageView.bottom+20, kWidth-12, 40);
    _nameLabel.font = [UIFont boldSystemFontOfSize:22];
    _nameLabel.textColor = [UIColor darkGrayColor];
    _nameLabel.text = _model.strTt;
    
    
    CGFloat maxLabelWidth = kWidth-12;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:18]};
    CGSize contentSize = [_model.strTc boundingRectWithSize:CGSizeMake(maxLabelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat height =  contentSize.height+5;
    
    _detailTextView.frame = CGRectMake(12, _nameLabel.bottom+30, maxLabelWidth-12, height);
    _detailTextView.font = [UIFont boldSystemFontOfSize:18];
    _detailTextView.textColor = [UIColor darkGrayColor];
    _detailTextView.numberOfLines = 0;
    _detailTextView.text = _model.strTc;
    _detailTextView.nightTextColor = NightTextColor;
    
    _containerView.frame = CGRectMake(0, 0, kWidth, height+554-40);
    _scrollView.contentSize = CGSizeMake(kWidth,height+554-40);
    
     _containerView.hidden = NO;
    [_indicatorView stopAnimating];
    
}

- (void)startRefreshing {
    self.indicatorView.center = self.center;
    
    if (Is_Night_Mode) {
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    
    [self.indicatorView startAnimating];
}


- (void)refreshView {
    
    self.containerView.hidden = YES;
    
    [self startRefreshing];
}

@end
