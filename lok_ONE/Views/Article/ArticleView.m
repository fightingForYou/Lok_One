//
//  ArticleView.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/25.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "ArticleView.h"
#import "BaseFunction.h"
#import "CountStrHeight.h"
#import "UIViewExt.h"
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@interface ArticleView() <UIWebViewDelegate, UIScrollViewDelegate>


@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic) UILabel *authorNameLabel;
@property (nonatomic) UILabel *detailAuthorLabel;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;// item 加载中转转的菊花

@end

@implementation ArticleView

- (void)setModel:(ArticleModel *)model {
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
    self.backgroundColor = [UIColor whiteColor];// Is_Night_Mode ? NightBGViewColor : [UIColor whiteColor];
    // 设置夜间模式背景色
    self.nightBackgroundColor = NightBGViewColor;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
    self.webView.scrollView.showsVerticalScrollIndicator = YES;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scalesPageToFit = NO;
    self.webView.tag = 1;
    self.webView.backgroundColor = WebViewBGColor;
    self.webView.nightBackgroundColor = NightBGViewColor;
    self.webView.scrollView.backgroundColor = WebViewBGColor;
    self.webView.scrollView.nightBackgroundColor = NightBGViewColor;
    self.webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    self.webView.multipleTouchEnabled = NO;
    self.webView.scrollView.scrollsToTop = YES;
    
    // webView 顶部添加一个 UIView，高度为34，UIView 里面再添加一个 UILabel，x 为15，y 为12，高度为16，左右距离为15，水平垂直居中，系统默认字体，颜色#555555，大小为13。
    UIView *webViewTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 34)];
    webViewTopView.tag = 10;
    webViewTopView.backgroundColor = [UIColor whiteColor];
    webViewTopView.nightBackgroundColor = NightBGViewColor;
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(webViewTopView.frame) - 30, 16)];
    self.dateLabel.tag = 20;
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textColor = DateTextColor;
    self.dateLabel.nightTextColor = DateTextColor;
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
    
    self.dateLabel.text = [BaseFunction enMarketTimeWithOriginalMarketTime:_model.strContMarketTime];
    
    NSString *webViewBGColor = Is_Night_Mode ? NightWebViewBGColorName : @"#ffffff";
    NSString *webViewContentTextColor = Is_Night_Mode ? NightWebViewTextColorName : DawnWebViewTextColorName;
    NSString *webViewTitleTextColor = Is_Night_Mode ? NightWebViewTextColorName : @"#5A5A5A";
    NSString *webViewAuthorTitleTextColor = Is_Night_Mode ? @"#575757" : @"#888888";
    
    NSMutableString *HTMLContent = [[NSMutableString alloc] init];
    [HTMLContent appendString:[NSString stringWithFormat:@"<body style=\"margin: 0px; background-color: %@;\"><div style=\"margin-bottom: 10px; background-color: %@;\">", webViewBGColor, webViewBGColor]];
    [HTMLContent appendString:[NSString stringWithFormat:@"<!-- 文章标题 --><p style=\"color: %@; font-size: 21px; font-weight: bold; margin-top: 34px; margin-left: 15px;\">%@</p>", webViewTitleTextColor, _model.strContTitle]];
    [HTMLContent appendString:[NSString stringWithFormat:@"<!-- 文章作者 --><p style=\"color: %@; font-size: 14px; font-weight: bold; margin-left: 15px; margin-top: -15px;\">%@</p><p></p>", webViewAuthorTitleTextColor, _model.strContAuthor]];
    [HTMLContent appendString:[NSString stringWithFormat:@"<!-- 文章内容 --><div style=\"line-height: 26px; margin-top: 15px; margin-left: 15px; margin-right: 15px; color: %@; font-size: 16px;\">%@</div>", webViewContentTextColor, _model.strContent]];
    [HTMLContent appendString:[NSString stringWithFormat:@"<!-- 文章责任编辑 --><p style=\"color: %@; font-size: 15px; font-style: oblique; margin-left: 15px;\">%@</p></div></body>", webViewContentTextColor, _model.strContAuthorIntroduce]];
    
    [self.webView loadHTMLString:HTMLContent baseURL:nil];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
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
    
    
    if (webView.scrollView.subviews.count < 4) {
        self.authorNameLabel = [[UILabel alloc] init];
        self.authorNameLabel.text = [_model.strContAuthor stringByAppendingString:_model.sWbN];
        self.authorNameLabel.frame = CGRectMake(10, _webView.scrollView.contentSize.height + 30, kWidth, 30);
        self.authorNameLabel.font = [UIFont systemFontOfSize:20];
        self.authorNameLabel.textColor = [UIColor darkGrayColor];
        
        self.detailAuthorLabel = [[UILabel alloc] init];
        self.detailAuthorLabel.text = self.model.sAuth;
        CGFloat detailAuthorHeight = [CountStrHeight countHeightForStr:self.model.sAuth FontType:[UIFont systemFontOfSize:20] RowWidth:kWidth-20];
        self.detailAuthorLabel.frame = CGRectMake(10, _authorNameLabel.bottom + 10, kWidth-20, detailAuthorHeight+10);
        self.detailAuthorLabel.font = [UIFont systemFontOfSize:16];
        self.detailAuthorLabel.textColor = [UIColor darkGrayColor];
        _detailAuthorLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _detailAuthorLabel.numberOfLines = 0;
        [_detailAuthorLabel sizeToFit];
        _detailAuthorLabel.backgroundColor = [UIColor clearColor];
        
        
        webView.scrollView.contentSize = CGSizeMake(webView.scrollView.contentSize.width, webView.scrollView.contentSize.height + 100);
        [webView.scrollView addSubview: _authorNameLabel];
        [webView.scrollView addSubview: _detailAuthorLabel];
    }
   
 
    
}


@end
