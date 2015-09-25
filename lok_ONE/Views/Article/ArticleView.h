//
//  ArticleView.h
//  lok_ONE
//
//  Created by 卡神 on 15/9/25.
//  Copyright © 2015年 lok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleModel.h"

@interface ArticleView : UIView

@property (nonatomic, strong) ArticleModel *model;

- (void)refresh;

@end
