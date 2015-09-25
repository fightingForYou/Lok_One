//
//  PraiseButton.m
//  OhOne
//
//  Created by hyrMac on 15/8/27.
//  Copyright (c) 2015年 hyrMac. All rights reserved.
//

#import "PraiseButton.h"
#import "UIViewExt.h"

@implementation PraiseButton
//    PraiseButton示例
//    PraiseButton *button = [[PraiseButton alloc] initWithFrame:CGRectMake(40, 250, 90, 20)];
//    [button setTitle:@"1323" forState:UIControlStateNormal];
//    [self.view addSubview:button];



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 正常图片
        [self setImage:[UIImage imageNamed:@"home_like"] forState:UIControlStateNormal];
        
        // 选中图片
        [self setImage:[UIImage imageNamed:@"home_like_hl"] forState:UIControlStateSelected];
        
        
        // 背景图片 根据button大小来拉伸背景图片
        UIImage *bgImg = [UIImage imageNamed:@"home_likeBg"];
        bgImg = [bgImg stretchableImageWithLeftCapWidth:self.frame.size.width/2-5 topCapHeight:self.frame.size.height/2-5];
        [self setBackgroundImage:bgImg forState:UIControlStateNormal];
        
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        // 字体颜色
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    }
    return self;
}



- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
    CGFloat x = self.titleLabel.left;
    CGFloat y = self.titleLabel.top;
    
    self.imageView.frame = CGRectMake(x - 20, y + 2.5, 15, 13) ;
    
}



@end
