//
//  XLStickyGesture.h
//  XLStickyGestureExample
//
//  Created by mxl on 2021/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLStickyGesture : UIPanGestureRecognizer

//The color of sticky area,default is blackColor.
@property (nonatomic, strong) UIColor *stickyAreaColor;

@end

NS_ASSUME_NONNULL_END
