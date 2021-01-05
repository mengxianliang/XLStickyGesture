//
//  ViewController.m
//  XLStickyGestureExample
//
//  Created by mxl on 2021/1/5.
//

#define RedColor [UIColor colorWithRed:242/255.0f green:51/255.0f blue:38/255.0f alpha:1]
#define GrayColor [UIColor colorWithRed:193/255.0f green:199/255.0f blue:211/255.0f alpha:1]

#import "ViewController.h"
#import "XLStickyGesture.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat labelHeight = 50.0f;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
    label1.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f - 100);
    label1.backgroundColor = RedColor;
    label1.textColor = [UIColor whiteColor];
    label1.text = @"6";
    label1.font = [UIFont systemFontOfSize:labelHeight*0.8];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.layer.cornerRadius = labelHeight/2.0f;
    label1.userInteractionEnabled = YES;
    label1.layer.masksToBounds = YES;
    [self.view addSubview:label1];
    
    XLStickyGesture *gesture1 = [[XLStickyGesture alloc] init];
    [label1 addGestureRecognizer:gesture1];
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelHeight*2, labelHeight)];
    label2.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f + 100);
    label2.backgroundColor = GrayColor;
    label2.textColor = [UIColor whiteColor];
    label2.text = @"99+";
    label2.font = [UIFont systemFontOfSize:labelHeight*0.8];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.layer.cornerRadius = labelHeight/2.0f;
    label2.layer.masksToBounds = YES;
    label2.userInteractionEnabled = YES;
    [self.view addSubview:label2];
    
    XLStickyGesture *gesture2 = [[XLStickyGesture alloc] init];
    [label2 addGestureRecognizer:gesture2];
}


@end
