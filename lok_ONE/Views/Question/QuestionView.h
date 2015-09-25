//
//  QuestionView.h
//  lok_ONE
//
//  Created by 卡神 on 15/9/25.
//  Copyright © 2015年 lok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionModel.h"
#import "PraiseButton.h"

@interface QuestionView : UIView

@property (nonatomic, strong)QuestionModel *model;

- (void)refresh;

@end
