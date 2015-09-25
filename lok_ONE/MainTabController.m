//
//  MainTabController.m
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//

#import "MainTabController.h"
#import "BaseNavigationController.h"
#import "HomeViewController.h"
#import "ArticleViewController.h"
#import "QuestionViewController.h"
#import "PersonalViewController.h"
#import "ThingsViewController.h"

@interface MainTabController ()

@end

@implementation MainTabController

#pragma mark -创建子控制器

- (void)_createSubControllers {
    
    HomeViewController     *homeVC      = [[HomeViewController alloc] init];
    ArticleViewController  *articleVC   = [[ArticleViewController alloc] init];
    QuestionViewController *questionVC  = [[QuestionViewController alloc] init];
    ThingsViewController   *somethingVC = [[ThingsViewController alloc] init];
    PersonalViewController *personalVC  = [[PersonalViewController alloc] init];

    NSArray *VCArray = @[homeVC,articleVC,questionVC,somethingVC, personalVC];
    
    NSMutableArray *navArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < VCArray.count; i++) {
        
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:VCArray[i]];
        [navArray addObject:nav];
        
    }
    
 
    
    self.viewControllers = navArray;
    /**
     *
     设置tabarbutton
     */
    
    NSArray *titles = @[@"首页",@"文章",@"问题",@"东西",@"个人"];
    NSArray *buttonImageNames = @[@"tabbar_item_home",@"tabbar_item_reading",@"tabbar_item_question",@"tabbar_item_thing",@"tabbar_item_person"];

    
    for (NSInteger i = 0; i < 5; i++) {
        
        UITabBarItem *button = [[UITabBarItem alloc] initWithTitle:titles[i] image:[UIImage imageNamed:buttonImageNames[i]] tag:i];
        
        BaseNavigationController *nav = navArray[i];
        nav.tabBarItem = button;
        
    }
    
}

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _createSubControllers];
    self.tabBar.translucent = NO;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
