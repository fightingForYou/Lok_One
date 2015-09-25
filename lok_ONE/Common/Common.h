//
//  Common.h
//  lok_ONE
//
//  Created by 卡神 on 15/9/17.
//  Copyright © 2015年 lok. All rights reserved.
//

#ifndef Common_h
#define Common_h


#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height


#define LeftDragToRightForRefreshHintText @"右拉刷新..."
#define LeftReleaseToRefreshHintText @"松开刷新数据..."
#define LeftReleaseIsRefreshingHintText @"正在载入..."

#define APP_THEME_NIGHT_MODE @"Night_Mode_Is_On"

#define NightNavigationBarColor [UIColor colorWithRed:32 / 255.0 green:32 / 255.0 blue:32 / 255.0 alpha:1] // #202020
#define DawnNavigationBarColor [UIColor colorWithRed:236 / 255.0 green:236 / 255.0 blue:236 / 255.0 alpha:1] // #ECECEC

#define WebViewBGColor [UIColor whiteColor] // [UIColor colorWithRed:249 / 255.0 green:249 / 255.0 blue:249 / 255.0 alpha:1]
#define VOLTextColor [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1] // #555555
#define DateTextColor [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1] // #555555
#define PraiseBtnTextColor [UIColor colorWithRed:80 / 255.0 green:80 / 255.0 blue:80 / 255.0 alpha:1] // #505050

#define TitleTextColor [UIColor colorWithRed:91 / 255.0 green:91 / 255.0 blue:91 / 255.0 alpha:1] // #5B5B5B

#define LoadingCircleColor [UIColor colorWithRed:132 / 255.0 green:132 / 255.0 blue:132 / 255.0 alpha:1] // #848484

#define NightBGViewColor [UIColor colorWithRed:38 / 255.0 green:38 / 255.0 blue:38 / 255.0 alpha:1] // #262626
#define NightTextColor [UIColor colorWithRed:135 / 255.0 green:135 / 255.0 blue:135 / 255.0 alpha:1] // #878787
#define NightWebViewBGColorName @"#262626"
#define DawnWebViewBGColorName @"#f0f0f0"
#define NightWebViewTextColorName @"#888888"
#define DawnWebViewTextColorName @"#333333"
#define DawnTextColor [UIColor colorWithRed:90 / 255.0 green:91 / 255.0 blue:92 / 255.0 alpha:1] // #5A5B5C
#define NightHomeTextColor [UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1] // #555555
#define DawnDateViewBGColor [UIColor colorWithRed:249 / 255.0 green:249 / 255.0 blue:249 / 255.0 alpha:1] // #F9F9F9

#define TableViewCellSeparatorDawnColor [UIColor colorWithRed:200 / 255.0 green:199 / 255.0 blue:204 / 255.0 alpha:1]; // #C8C7CC
#define TableViewCellDawnBGColor [UIColor colorWithRed:254 / 255.0 green:254 / 255.0 blue:254 / 255.0 alpha:1]; // #FEFEFE


#define Is_Night_Mode [DKNightVersionManager currentThemeVersion] == DKThemeVersionNight

#endif /* Common_h */
