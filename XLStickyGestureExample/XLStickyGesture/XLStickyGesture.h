//
//  XLStickyGesture.h
//  XLStickyGestureExample
//
//  Created by mxl on 2021/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XLStickyGesture : UIPanGestureRecognizer

//the color of sticky area,default is blackColor.
@property (nonatomic, strong) UIColor *stickyAreaColor;

//maximum drag distance,default is 100
@property (nonatomic, assign) CGFloat maxDragDistance;

@end

NS_ASSUME_NONNULL_END
