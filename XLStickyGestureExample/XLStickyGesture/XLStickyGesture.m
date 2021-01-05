//
//  XLStickyGesture.m
//  XLStickyGestureExample
//
//  Created by mxl on 2021/1/5.
//

#import "XLStickyGesture.h"

static CGFloat fixPointOriginHeight = 60.0f;
static CGFloat fixPointMaxDragDistance = 300.0f;

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
    self.fixPoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fixPointOriginHeight, fixPointOriginHeight)];
    self.fixPoint.layer.cornerRadius = fixPointOriginHeight/2.0f;
    self.fixPoint.layer.masksToBounds = YES;
    
    //阴影
    self.shadowLayer = [CAShapeLayer layer];
    
    //背景视图
    self.backgroundView = [[UIView alloc] init];
    [self.backgroundView addSubview:self.fixPoint];
    [self.backgroundView.layer addSublayer:self.shadowLayer];
    
    //初始化背景颜色
    self.stickyAreaColor = [UIColor blackColor];
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
    self.fixPoint.center = touchView.center;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.state = UIGestureRecognizerStateChanged;
    
    CGPoint location = [self locationInView:self.backgroundView];
    
    self.view.center = location;
    
    //不动点信息
    CGFloat x1 = self.fixPoint.center.x;
    CGFloat y1 = self.fixPoint.center.y;
    
    
    //拖动点信息
    CGFloat x2 = self.view.center.x;
    CGFloat y2 = self.view.center.y;
    
    
    //计算出两点间距离
    CGFloat d = sqrtf((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    
    if (d >= fixPointMaxDragDistance) {
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
    
    CGFloat progress = d/fixPointMaxDragDistance;
    
    //固定点最小高度
    CGFloat fixPoint1MiniHeight = 20.0f;
    CGFloat plusHeight = 40;
    CGFloat fixPoint1Height = fixPoint1MiniHeight + plusHeight*(1 - progress);
    NSLog(@"fixPoint1Height = %f",fixPoint1Height);
    self.fixPoint.bounds = CGRectMake(0, 0, fixPoint1Height, fixPoint1Height);
    self.fixPoint.center = CGPointMake(x1, y1);
    self.fixPoint.layer.cornerRadius = fixPoint1Height/2.0f;
    
    
    NSLog(@"两球间距：%f",d);
    
    CGFloat r1 = self.fixPoint.bounds.size.width/2.0f;
    CGFloat r2 = self.view.bounds.size.width/2.0f;
    
    //计算出角θ的正弦和余弦值
    CGFloat sinθ = (x2 - x1)/d;
    CGFloat cosθ = (y2 - y1)/d;
    
    //根据sinθ、cosθ、两点坐标，计算出A、B、C、D的坐标
    CGPoint pointA = CGPointMake(x1 - r1*cosθ, y1 + r1*sinθ);
    CGPoint pointB = CGPointMake(x1 + r1*cosθ, y1 - r1*sinθ);
    CGPoint pointC = CGPointMake(x2 - r2*cosθ, y2 + r2*sinθ);
    CGPoint pointD = CGPointMake(x2 + r2*cosθ, y2 - r2*sinθ);
    
    //计算出点A点B计算出点O、P的坐标
    CGPoint pointE = CGPointMake(pointA.x + (d/2)*sinθ, pointA.y + (d/2)*cosθ);
    CGPoint pointF = CGPointMake(pointB.x + (d/2)*sinθ, pointB.y + (d/2)*cosθ);
    
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
    [UIView animateWithDuration:0.2 animations:^{
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
}


@end
