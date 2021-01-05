//
//  XLStickyGesture.m
//  XLStickyGestureExample
//
//  Created by mxl on 2021/1/5.
//

#import "XLStickyGesture.h"

@interface XLStickyGesture ()

@property (nonatomic, strong) UIView *fixPoint;

@property (nonatomic, strong) CAShapeLayer *shadowLayer;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) CGPoint originCenter;

@property (nonatomic, strong) UIView *superView;

@property (nonatomic, assign) BOOL shouldRemoveTouchView;

@end

@implementation XLStickyGesture


- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        [self initStickyGesture];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initStickyGesture];
    }
    return self;
}

- (void)initStickyGesture {
    //固定点
    self.fixPoint = [[UIView alloc] init];
    self.fixPoint.layer.masksToBounds = YES;
    
    //阴影
    self.shadowLayer = [CAShapeLayer layer];
    
    //背景视图
    self.backgroundView = [[UIView alloc] init];
    [self.backgroundView addSubview:self.fixPoint];
    [self.backgroundView.layer addSublayer:self.shadowLayer];
    
    //设置默认颜色
    self.stickyAreaColor = [UIColor blackColor];
    
    //设置默认最大拖拽距离
    self.maxDragDistance = 100;
}

//拖拽开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
    
    //手势添加到的view
    UIView *touchView = self.view;
    
    //记录原始位置，和父视图
    self.originCenter = touchView.center;
    self.superView = touchView.superview;
    
    //添加到新的背景视图上
    self.backgroundView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    CGRect convertRect = [touchView convertRect:touchView.bounds toView:self.backgroundView];
    [self.backgroundView addSubview:touchView];
    touchView.frame = convertRect;
    
    //设置固定点的位置
    self.fixPoint.bounds = CGRectMake(0, 0, touchView.bounds.size.height, touchView.bounds.size.height);
    self.fixPoint.center = touchView.center;
    self.fixPoint.layer.cornerRadius = self.fixPoint.bounds.size.height/2.0f;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.state = UIGestureRecognizerStateChanged;
    
    //获取手指位置
    CGPoint location = [self locationInView:self.backgroundView];
    //更新view位置
    self.view.center = location;
    
    //不动点信息
    CGFloat x1 = self.fixPoint.center.x;
    CGFloat y1 = self.fixPoint.center.y;
    
    //拖动点信息
    CGFloat x2 = self.view.center.x;
    CGFloat y2 = self.view.center.y;
    
    //计算出两点间距离
    CGFloat d = sqrtf((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    
    //更新显示/隐藏
    if (d >= self.maxDragDistance) {
        self.shadowLayer.hidden = YES;
        [self.shadowLayer removeAllAnimations];
        self.fixPoint.hidden = YES;
        self.shouldRemoveTouchView = YES;
    }else {
        self.shadowLayer.hidden = NO;
        [self.shadowLayer removeAllAnimations];
        self.fixPoint.hidden = NO;
        self.shouldRemoveTouchView = NO;
    }
    
    //计算效果进度 0 - 1
    CGFloat progress = d/self.maxDragDistance;
    
    //固定点最小高度
    CGFloat fixPointMiniHeight = 0.4*self.view.bounds.size.height;
    CGFloat fixPointPlusHeight = self.view.bounds.size.height - fixPointMiniHeight;
    CGFloat fixPointHeight = fixPointMiniHeight + fixPointPlusHeight*(1 - progress);
    self.fixPoint.bounds = CGRectMake(0, 0, fixPointHeight, fixPointHeight);
    self.fixPoint.center = CGPointMake(x1, y1);
    self.fixPoint.layer.cornerRadius = fixPointHeight/2.0f;
    
    CGFloat r1 = fixPointHeight/2.0f;
    
    CGFloat dragPointMiniHeight = 0.9*self.view.bounds.size.height;
    CGFloat dragPointPlusHeight = self.view.bounds.size.height - dragPointMiniHeight;
    CGFloat dragPointHeight = dragPointMiniHeight + dragPointPlusHeight*(1 - progress);
    
    CGFloat r2 = dragPointHeight/2.0f;
    
    //计算出角θ的正弦和余弦值
    CGFloat sinθ = (x2 - x1)/d;
    CGFloat cosθ = (y2 - y1)/d;
    
    //根据sinθ、cosθ、两点坐标，计算出A、B、C、D的坐标
    CGPoint pointA = CGPointMake(x1 - r1*cosθ, y1 + r1*sinθ);
    CGPoint pointB = CGPointMake(x1 + r1*cosθ, y1 - r1*sinθ);
    CGPoint pointC = CGPointMake(x2 - r2*cosθ, y2 + r2*sinθ);
    CGPoint pointD = CGPointMake(x2 + r2*cosθ, y2 - r2*sinθ);
    
    NSLog(@"progress = %f",progress);
    //计算出A1和B1
    CGFloat scale = (1 - progress)*0.8;
    CGPoint pointA1 = CGPointMake(x1 - r1*cosθ*scale, y1 + r1*sinθ*scale);
    CGPoint pointB1 = CGPointMake(x1 + r1*cosθ*scale, y1 - r1*sinθ*scale);
    
    //计算出点A1点B计算出点E、F的坐标
    CGPoint pointE = CGPointMake(pointA1.x + (d/2)*sinθ, pointA1.y + (d/2)*cosθ);
    CGPoint pointF = CGPointMake(pointB1.x + (d/2)*sinθ, pointB1.y + (d/2)*cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointD controlPoint:pointF];
    [path addLineToPoint:pointC];
    [path addQuadCurveToPoint:pointA controlPoint:pointE];
    [path closePath];
    
    self.shadowLayer.path = path.CGPath;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
    
    if (self.shouldRemoveTouchView) {
        [self removeTouchView];
    }else {
        [self resetTouchView];
    }
}
    
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
    
    if (self.shouldRemoveTouchView) {
        [self removeTouchView];
    }else {
        [self resetTouchView];
    }
}

- (void)resetTouchView {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.center = self.fixPoint.center;
        self.shadowLayer.path = [UIBezierPath bezierPath].CGPath;
    } completion:^(BOOL finished) {
        [self.superView addSubview:self.view];
        self.view.center = self.originCenter;
        [self.backgroundView removeFromSuperview];
    }];
}

- (void)removeTouchView {
    [UIView animateWithDuration:0.15 animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
}

#pragma mark - Setter
- (void)setStickyAreaColor:(UIColor *)stickyAreaColor {
    _stickyAreaColor = stickyAreaColor;
    
    self.shadowLayer.fillColor = stickyAreaColor.CGColor;
    self.fixPoint.backgroundColor = stickyAreaColor;
    
//    //测试代码
//    self.shadowLayer.strokeColor = stickyAreaColor.CGColor;
//    self.shadowLayer.fillColor = [UIColor clearColor].CGColor;
//
//    self.fixPoint.backgroundColor = [UIColor clearColor];
//    self.fixPoint.layer.borderWidth = 1.0f;
//    self.fixPoint.layer.borderColor = stickyAreaColor.CGColor;
}


@end
