//
//  QuestionView.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/25.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "QuestionView.h"
#import "PraiseButton.h"
#import "BaseFunction.h"
#import "UIViewExt.h"



@interface QuestionView() <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) PraiseButton *strPnButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;// item 加载中转转的菊花

@end

@implementation QuestionView

- (void)setModel:(QuestionModel *)model {
    _model = model;
    [self initSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUpViews];
    }
    
    return self;
}

- (void)setUpViews {
    [DKNightVersionManager addClassToSet:self.class];
    self.backgroundColor = [UIColor whiteColor];
    
    // 设置夜间模式背景色
    self.nightBackgroundColor = NightBGViewColor;
    self.webView.backgroundColor = WebViewBGColor;
    self.webView.nightBackgroundColor = NightBGViewColor;
    self.webView.scrollView.backgroundColor = WebViewBGColor;
    self.webView.scrollView.nightBackgroundColor = NightBGViewColor;
    self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
    self.webView.scrollView.showsVerticalScrollIndicator = YES;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scalesPageToFit = NO;
    self.webView.tag = 1;
    self.webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    self.webView.multipleTouchEnabled = NO;
    self.webView.scrollView.scrollsToTop = YES;
    
    // webView 顶部添加一个 UIView，高度为34，UIView 里面再添加一个 UILabel，x 为15，y 为12，高度为16，左右距离为15，水平垂直居中，系统默认字体，颜色#555555，大小为13。
    UIView *webViewTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 34)];
    webViewTopView.tag = 10;
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(webViewTopView.frame) - 30, 16)];
    self.dateLabel.tag = 20;
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textColor = DateTextColor;
    [webViewTopView addSubview:self.dateLabel];
    self.dateLabel.center = webViewTopView.center;
    [self.webView.scrollView addSubview:webViewTopView];
    
    [self addSubview:self.webView];
    
    // 初始化加载中的菊花控件
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.hidesWhenStopped = YES;
    [self addSubview:self.indicatorView];
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

- (void)initSubviews {
  
    
    // 如果当前的问题内容没有获取过来，就暂时直接加载该问题对应的官方手机版网页
    if ([_model.strQuestionId isEqualToString:@""]) {
        //		self.dateLabel.text = @"What the fuck！日了狗了，获取不到数据了。";
        self.dateLabel.superview.hidden = YES;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.wufazhuce.com/question/%@", _model.strQuestionMarketTime]]]];
    } else {
        self.dateLabel.superview.hidden = NO;
        self.dateLabel.text = [BaseFunction enMarketTimeWithOriginalMarketTime:_model.strQuestionMarketTime];
        
        NSString *webViewBGColor = Is_Night_Mode ? NightWebViewBGColorName : @"#ffffff";
        NSString *webViewContentTextColor = Is_Night_Mode ? NightWebViewTextColorName : DawnWebViewTextColorName;
        NSString *separateLineColor = Is_Night_Mode ? @"#333333" : @"#d4d4d4";
        
        NSMutableString *HTMLString = [[NSMutableString alloc] init];
        // Questin Title
        [HTMLString appendString:[NSString stringWithFormat:@"<body style=\"margin: 0px; background-color: %@;\"><div style=\"margin-bottom: 0px; margin-top: 0px; background-color: %@;\"><div style=\"margin-bottom: 100px; margin-top: 34px;\"><table style=\"width: 100%%;\"><tbody style=\"display: table-row-group; vertical-align: middle; border-color: inherit;\"><tr style=\"display: table-row; vertical-align: inherit;\"><td style=\"width: 84px;\" align=\"center\"><img style=\"width: 42px; height: 42px; vertical-align: middle;\" alt=\"问题\" src=\"http://s2-cdn.wufazhuce.com/m.wufazhuce/images/question.png\" /></td>", webViewBGColor, webViewBGColor]];
        [HTMLString appendString:[NSString stringWithFormat:@"<td><p style=\"margin-top: 0; margin-left: 0; color: %@; font-size: 16px; font-weight: bold;\">%@</p></td></tr></tbody></table>", webViewContentTextColor, _model.strQuestionTitle]];
        // Question Content
        [HTMLString appendString:[NSString stringWithFormat:@"<div style=\"line-height: 26px; margin-top: 14px;\"><p style=\"margin-left: 20px; margin-right: 20px; margin-bottom: 0; color: %@; text-shadow: none; font-size: 15px;\">%@</p></div>", webViewContentTextColor, _model.strQuestionContent]];
        // Separate Line
        [HTMLString appendString:[NSString stringWithFormat:@"<div style=\"margin-top: 15px; margin-bottom: 15px; width: 95%%; height: 1px; background-color: %@; margin-left: auto; margin-right: auto;\"></div>", separateLineColor]];
        // Answer Title
        [HTMLString appendString:[NSString stringWithFormat:@"<table style=\"width: 100%%;\"><tbody style=\"display: table-row-group; vertical-align: middle; border-color: inherit;\"><tr style=\"display: table-row; vertical-align: inherit; border-color: inherit;\"><td style=\"width: 84px;\" align=\"center\"><img style=\"width: 42px; height: 42px; vertical-align: middle;\" alt=\"回答\" src=\"http://s2-cdn.wufazhuce.com/m.wufazhuce/images/answer.png\" /></td><td align=\"left\"><p style=\"margin-top: 0; margin-left: 0; color: %@; font-size: 16px; font-weight: bold; margin-right: 20px; margin-bottom: 0; text-shadow: none;\">%@</p></td></tr></tbody></table>", webViewContentTextColor, _model.strAnswerTitle]];
        // Answer Content
        [HTMLString appendString:[NSString stringWithFormat:@"<div style=\"line-height: 26px; margin-top: 14px;\"><p></p><p style=\"margin-left: 20px; margin-right: 20px; margin-bottom: 0; color: %@; text-shadow: none; font-size: 15px;\">%@</p><p></p></div>", webViewContentTextColor, _model.strAnswerContent]];
        // Question Editor
        [HTMLString appendString:[NSString stringWithFormat:@"<p style=\"color: #333333; font-style: oblique; margin-left: 20px; margin-right: 20px; margin-bottom: 0; text-shadow: none; font-size: 15px;\">%@</p></div></div></body>", _model.sEditor]];
        
        [self.webView loadHTMLString:HTMLString baseURL:nil];
    }
    
    self.webView.delegate = self;
    [self.webView.scrollView scrollsToTop];
}

- (void)refresh {
    self.dateLabel.text = @"";
    
    self.webView.hidden = YES;
    
    [self startRefreshing];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
    self.webView.hidden = NO;
    
    _strPnButton = [[PraiseButton alloc] initWithFrame:CGRectMake(kWidth-80, _webView.scrollView.contentSize.height - 50, 90, 30)];
    _strPnButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _strPnButton.titleLabel.textColor = [UIColor darkGrayColor];
    [_strPnButton setTitle:[NSString stringWithFormat:@" %@",_model.strPraiseNumber] forState:UIControlStateNormal];
    [webView.scrollView addSubview:_strPnButton];
}


@end
