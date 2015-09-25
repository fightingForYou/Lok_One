//
//  HomeView.m
//  OhOne
//
//  Created by hyrMac on 15/8/31.
//  Copyright (c) 2015年 hyrMac. All rights reserved.
//

#import "HomeView.h"
#import "HomeModel.h"
#import "UIImageView+WebCache.h"
#import "PraiseButton.h"
#import "UIViewExt.h"
#import "Utils.h"
#import "ZoomImageView.h"

#define PaintInfoTextColor [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1] // #555555
#define DayTextColor [UIColor colorWithRed:55 / 255.0 green:194 / 255.0 blue:241 / 255.0 alpha:1] // #37C2F1
#define MonthAndYearTextColor [UIColor colorWithRed:173 / 255.0 green:173 / 255.0 blue:173 / 255.0 alpha:1] // #ADADAD

@implementation HomeView

- (void)setModel:(HomeModel *)model {
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
    
     [DKNightVersionManager addClassToSet:self.class];
    _homeBgScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_homeBgScrollView];
    
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [_homeBgScrollView addSubview:_containerView];
    
    _strHpTitleLabel = [[UILabel alloc] init];
    [_containerView addSubview:_strHpTitleLabel];
    
    _strThumbnailUrlImageView = [[ZoomImageView alloc] init];
    [_containerView addSubview:_strThumbnailUrlImageView];
    
//    作品名称
    _opusLabel = [[UILabel alloc] init];
    [_containerView addSubview:_opusLabel];
    
    _authorLabel = [[UILabel alloc] init];
    [_containerView addSubview:_authorLabel];
    
    _dayLabel = [[UILabel alloc] init];
    [_containerView addSubview:_dayLabel];
    
    _timeLabel = [[UILabel alloc] init];
    [_containerView addSubview:_timeLabel];
    
    
    _contentLabelBg = [[UIImageView alloc] init];
    [_containerView addSubview:_contentLabelBg];
    
    
    _strContentLabel = [[UITextView alloc] init];
    [_containerView addSubview:_strContentLabel];
    
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    self.indicatorView.hidesWhenStopped = YES;
    [self addSubview:_indicatorView];
    
    
    _strPnButton = [[PraiseButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    [_containerView addSubview:_strPnButton];
    
    
}
/**
 strHpTitle	        String		期刊号
 strThumbnailUrl	String		中间配图的缩略图
 strOriginalImgUrl	String		原图，点击放大时的图片
 strAuthor	        String		作品名称和作者（显示时还要解析，根据“&”）
 strMarketTime	    String		发表日期（即今天)
 strContent         String		鸡汤正文
 wImgUrl            String		首页整体效果图，好像没啥卵用
 strPn              String		当前点赞数
 */

- (void)initSubviews {
    [super layoutSubviews];
    
    _containerView.hidden = NO;
    self.nightBackgroundColor = NightBGViewColor;
    // 背景滑动视图
    _homeBgScrollView.scrollEnabled = YES;
    _homeBgScrollView.backgroundColor = [UIColor whiteColor];
    _containerView.nightBackgroundColor = NightBGViewColor;
    _homeBgScrollView.nightBackgroundColor = NightBGViewColor;
    
    //    期刊号
    _strHpTitleLabel.text = _model.strHpTitle;
    _strHpTitleLabel.backgroundColor = [UIColor clearColor];
    _strHpTitleLabel.frame = CGRectMake(8, 8, kWidth-8, 21);
    _strHpTitleLabel.font = [UIFont systemFontOfSize:13];
    _strHpTitleLabel.nightTextColor = [UIColor grayColor];
    
    //    中间配图的缩略图
    NSString *strThumbnailUrlStr = _model.strThumbnailUrl;
    NSString *strOriginalImgUrl = _model.strOriginalImgUrl;
    _strThumbnailUrlImageView.frame = CGRectMake(8, 37, kWidth-16, 235);
    _strThumbnailUrlImageView.bigURL = strOriginalImgUrl;
    [_strThumbnailUrlImageView sd_setImageWithURL:[NSURL URLWithString:strThumbnailUrlStr]];
    _strThumbnailUrlImageView.contentMode = UIViewContentModeScaleToFill;
    
    
    //    作品名称和作品
    NSArray *workArray = [_model.strAuthor componentsSeparatedByString:@"&"];
    
    _opusLabel.text = workArray[0];
    _opusLabel.font = [UIFont systemFontOfSize:12];
    _opusLabel.textAlignment = NSTextAlignmentRight;
    _opusLabel.textColor = [UIColor darkGrayColor];
    _opusLabel.backgroundColor = [UIColor clearColor];
    _opusLabel.frame = CGRectMake(0, 280, kWidth-8, 21);
    _opusLabel.nightTextColor = PaintInfoTextColor;
    
    _authorLabel.text = workArray[1];
    _authorLabel.font = [UIFont systemFontOfSize:12];
    _authorLabel.textColor = [UIColor darkGrayColor];
    _authorLabel.textAlignment = NSTextAlignmentRight;
    _authorLabel.backgroundColor = [UIColor clearColor];
    _authorLabel.frame = CGRectMake(0, self.opusLabel.bottom, kWidth-8, 21);
    
    //    鸡汤
    CGFloat maxLabelWidth = kWidth-78-15;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGSize contentSize = [_model.strContent boundingRectWithSize:CGSizeMake(maxLabelWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    CGFloat height =  contentSize.height + 30;
    

    //    2015-08-28           55 195 242
    //    NSLog(@"%@",_model.strMarketTime);
    NSString *newDateStr = [Utils oneString:_model.strMarketTime];
    //    NSLog(@"%@",newDateStr);
    
    NSArray *dateArray = [newDateStr componentsSeparatedByString:@"-"];
    
    _dayLabel.text = [dateArray lastObject];
    
    CGFloat y = self.authorLabel.bottom + 25;
    
    _dayLabel.nightTextColor = DayTextColor;
    _dayLabel.frame = CGRectMake(24, y, 46, 35);
    _dayLabel.font = [UIFont boldSystemFontOfSize:35];
    _dayLabel.textColor = [UIColor colorWithRed:55/255.0 green:195/255.0 blue:242/255.0 alpha:0.9];
    _dayLabel.backgroundColor = [UIColor clearColor];
    
    _timeLabel.nightTextColor = DayTextColor;
    _timeLabel.text = [NSString stringWithFormat:@"%@,%@",dateArray[1],dateArray[0]];
    _timeLabel.frame = CGRectMake(24, self.dayLabel.bottom, 46, 21);
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.backgroundColor = [UIColor clearColor];
    
    
    //background
    _contentLabelBg.frame = CGRectMake(78, self.dayLabel.top, maxLabelWidth - 10, 0);
    _contentLabelBg.height = height;
    //_strContentLabel.text = _model.strContent;
    _strContentLabel.textColor = [UIColor whiteColor];
    //_strContentLabel.font = [UIFont systemFontOfSize:13];
    _strContentLabel.scrollEnabled = NO;
    _strContentLabel.editable = NO;
    _strContentLabel.backgroundColor = [UIColor clearColor];
    _strContentLabel.frame = _contentLabelBg.frame;
    _strContentLabel.width = _strContentLabel.width-15;
    _strContentLabel.center = _contentLabelBg.center;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attribute;
    
    if (Is_Night_Mode) {
        attribute = @{NSParagraphStyleAttributeName : paragraphStyle,
                      NSForegroundColorAttributeName : NightHomeTextColor,
                      NSFontAttributeName : [UIFont systemFontOfSize:13]};
    } else {
        attribute = @{NSParagraphStyleAttributeName : paragraphStyle,
                      NSForegroundColorAttributeName : [UIColor whiteColor],
                      NSFontAttributeName : [UIFont systemFontOfSize:13]};
    }
    _strContentLabel.attributedText = [[NSAttributedString alloc] initWithString:_model.strContent attributes:attribute];
    [self.strContentLabel sizeToFit];
    
    UIImage *contentImg = [[UIImage imageNamed:@"contBack"] stretchableImageWithLeftCapWidth:5 topCapHeight:15];
    UIImage *nightContentImg = [[UIImage imageNamed:@"contBack_nt"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    if (Is_Night_Mode) {
        [_contentLabelBg setImage:nightContentImg];
    } else {
        [_contentLabelBg setImage:contentImg];
    }
 
    
    
    //    点赞按钮
    _strPnButton.frame = CGRectMake(kWidth-80, 0, 90, 30);
    _strPnButton.top = _contentLabelBg.bottom + 30;
    [_strPnButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [_strPnButton setTitle:_model.strPn forState:UIControlStateNormal];
    
    
    //    容器视图
    _containerView.frame = CGRectMake(0, 0, kWidth, height+554-69);
    
    
    _homeBgScrollView.contentSize = CGSizeMake(kWidth, height+554-69);
    
    
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

- (void)select:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    
}


@end
