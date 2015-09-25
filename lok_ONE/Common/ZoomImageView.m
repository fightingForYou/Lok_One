//
//  ZoomImageView.m
//  Lok_m微博
//
//  Created by 卡神 on 15/8/29.
//  Copyright (c) 2015年 lok. All rights reserved.
//

#import "ZoomImageView.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "UIImage+GIF.h"

@implementation ZoomImageView {
    UIScrollView *_scrollView;
    UIImageView *_fullImageView;
    CGRect _bigFrame;
    BOOL isZooming;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomIn)];
        recognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:recognizer];
        self.userInteractionEnabled = YES;
        
    }
    
    return self;
}

#pragma mark - zoom

- (void)zoomIn {
    
    [self.delegate zoomingWillIn];
    
    [self _createSubviews];
    
    CGRect frame = CGRectZero;
#warning 调试
    NSLog(@"self.frame = %@, window frame = %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(frame));
    _fullImageView.center = self.window.center;
    
    if (self.bigImage) {
        
        _fullImageView.image = self.bigImage;
        CGSize size = self.bigImage.size;
        CGFloat sacle = size.width / kWidth;
        
        NSLog(@"%@", NSStringFromCGRect(_fullImageView.frame));
        
        if (size.width > kWidth) {
            size = CGSizeMake(kWidth, size.height / sacle);
        }
        
        [UIView animateWithDuration:0.6 animations:^{
            
            _scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
            _fullImageView.frame = CGRectMake(0, 0, size.width, size.height);
            if (size.height < kHeight) {
                _fullImageView.center = _scrollView.center;
            }
            
        } completion:^(BOOL finished) {
            
            _scrollView.contentSize = size;
            
        }];
        
    } else {
        
        [_fullImageView sd_setImageWithURL:[NSURL URLWithString:self.bigURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            CGSize size = image.size;
            CGFloat sacle = size.width / kWidth;
            
            NSLog(@"%@", NSStringFromCGRect(_fullImageView.frame));
            
            if (size.width > kWidth) {
                size = CGSizeMake(kWidth, size.height / sacle);
            }
            
            [UIView animateWithDuration:0.6 animations:^{
                
                _scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
                _fullImageView.frame = CGRectMake(0, 0, size.width, size.height);
                if (size.height < kHeight) {
                    _fullImageView.center = _scrollView.center;
                }
                
            } completion:^(BOOL finished) {
                
                _scrollView.contentSize = size;
                
            }];
            
        }];
    }
}

- (void)zoomOut {
    [self.delegate zoomingWillOut];
    
    CGRect frame = CGRectZero;
    frame.origin = self.window.center;
    
    [UIView animateWithDuration:0.6 animations:^{
        
        _fullImageView.frame = frame;
         _scrollView.backgroundColor = [UIColor clearColor];
       
        
    } completion:^(BOOL finished) {
        
        [_scrollView removeFromSuperview];
        _scrollView = nil;
        
    }];
    
}

- (void)zoomBig {
    
    if (isZooming) {
        [_scrollView setZoomScale:1 animated:YES];
    } else {
        [_scrollView setZoomScale:2 animated:YES];
    }
    isZooming = !isZooming;
#warning 调试放大效果
    NSLog(@"imagecenter = %@, scrollercenter = %@", NSStringFromCGPoint(_fullImageView.center), NSStringFromCGPoint(_scrollView.center));
    
}

#pragma mark - createSubViews

- (void)_createSubviews {
    
   
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.maximumZoomScale = 3;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.delegate = self;
    
    self.window.backgroundColor = [UIColor clearColor];
    
    [self.window addSubview:_scrollView];
    
    _fullImageView = [[UIImageView alloc] init];
    _fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _fullImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut)];
    recognizer.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomBig)];
    tap.numberOfTapsRequired = 2;
    [recognizer requireGestureRecognizerToFail:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage:)];

    
    [_scrollView addGestureRecognizer:longPress];
    [_scrollView addGestureRecognizer:tap];
    [_scrollView addGestureRecognizer:recognizer];
    [_scrollView addSubview:_fullImageView];
    
    
}
#pragma mark - save image
- (void)saveImage: (UILongPressGestureRecognizer *)press {
    
    if (press.state == UIGestureRecognizerStateBegan) {
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否保存图片" preferredStyle:UIAlertControllerStyleActionSheet];
//        
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
//            hud.labelText = @"正在保存";
//            hud.dimBackground = YES;
//            
//            UIImage *image = _fullImageView.image;
//            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void*)hud);
//            
//        }];
//        
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        
//        [alertController addAction:okAction];
//        [alertController addAction:cancelAction];
//    
//        //UIViewController *ctr = (UIViewController *)self.nextResponder.nextResponder.nextResponder.nextResponder.nextResponder.nextResponder.nextResponder.nextResponder.nextResponder.nextResponder;
//        
//        //[ctr presentViewController:alertController animated:YES completion:nil];
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否保存图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alertView show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        hud.labelText = @"正在保存";
        hud.dimBackground = YES;
        UIImage *image = _fullImageView.image;
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void*)hud);
    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    MBProgressHUD *hud = (__bridge MBProgressHUD *)contextInfo;
    
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = view;
    hud.labelText = @"图片已保存到相册";
    
    [hud hide:YES afterDelay:1];
   
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _fullImageView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
