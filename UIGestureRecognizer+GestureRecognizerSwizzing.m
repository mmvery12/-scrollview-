//
//  UIGestureRecognizer+GestureRecognizerSwizzing.m
//  Demo
//
//  Created by JD on 17/2/20.
//  Copyright © 2017年 IMPTest. All rights reserved.
//

#import "UIGestureRecognizer+GestureRecognizerSwizzing.h"
#import <objc/runtime.h>
@implementation UIGestureRecognizer (GestureRecognizerSwizzing)
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            SEL sel = NSSelectorFromString(@"initWithTarget:action:");
            SEL sel2 = NSSelectorFromString(@"minitWithTarget:action:");
            
            Method method = class_getInstanceMethod([self class], sel);
            Method method2 = class_getInstanceMethod([self class], sel2);
            method_exchangeImplementations(method, method2);
        }
        
        {
            SEL sel = NSSelectorFromString(@"addTarget:addTarget:");
            SEL sel2 = NSSelectorFromString(@"maddTarget:addTarget:");
            
            Method method = class_getInstanceMethod([self class], sel);
            Method method2 = class_getInstanceMethod([self class], sel2);
            method_exchangeImplementations(method, method2);
        }
        
        {
            SEL sel = NSSelectorFromString(@"removeTarget:action:");
            SEL sel2 = NSSelectorFromString(@"mremoveTarget:action:");
            
            Method method = class_getInstanceMethod([self class], sel);
            Method method2 = class_getInstanceMethod([self class], sel2);
            method_exchangeImplementations(method, method2);
        }
    });
}

- (instancetype)minitWithTarget:(nullable id)target action:(nullable SEL)action
{
    objc_setAssociatedObject(self, "mGestureRecognizerTarget", target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, "mGestureRecognizerAction", NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self minitWithTarget:self action:@selector(mGestureRecognizerReceiver:)];
}

- (void)maddTarget:(id)target action:(SEL)action;
{
    objc_setAssociatedObject(self, "mGestureRecognizerTarget", target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, "mGestureRecognizerAction", NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self maddTarget:self action:@selector(mGestureRecognizerReceiver:)];
}

- (void)mremoveTarget:(nullable id)target action:(nullable SEL)action;
{
    [self mremoveTarget:self action:@selector(mGestureRecognizerReceiver:)];
}

static UILabel *show = nil;
-(void)mGestureRecognizerReceiver:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *mview = self.view;
    UIView *mtestView = self.view;
    NSString *viewControllerStr = nil;
    UIViewController *viewController = nil;
    for (; ; ) {
        id responser = mtestView.nextResponder;
        if ([responser isKindOfClass:[UIViewController class]]) {
            viewController = responser;
            viewControllerStr = [[responser class] description];
            break;
        }
        mtestView = responser;
    }
    CGPoint point = [gestureRecognizer locationInView:mview];
    point = [mview convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    
    
    {//show lable
        if (show) {
            [show removeFromSuperview];
        }
        show = nil;
        show = [[UILabel alloc] initWithFrame:CGRectMake(33, 64+33, INTMAX_MAX, INTMAX_MAX)];
        
        
        [viewController.view addSubview:show];
        [viewController.view bringSubviewToFront:show];
        show.text = [NSString stringWithFormat:@"%@ \r\n %@",viewControllerStr,NSStringFromCGPoint(point)];
        show.textColor = [UIColor blackColor];
        show.numberOfLines = 2;
        show.backgroundColor = [UIColor redColor];
        CGRect rect = show.frame;
        rect.origin = CGPointMake(33, 64+33);
        rect.size = [show sizeThatFits:show.frame.size];
        show.frame = rect;
    }
    
    
    id target = objc_getAssociatedObject(self, "mGestureRecognizerTarget");
    NSString *selstr = objc_getAssociatedObject(self, "mGestureRecognizerAction");
    SEL sel = NSSelectorFromString(selstr);
    NSMethodSignature  *signature = [[target class] instanceMethodSignatureForSelector:sel];
    if (signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        NSUInteger argumentCount = signature.numberOfArguments;
        [invocation setArgument:&target atIndex:0];
        [invocation setArgument:&sel atIndex:1];
        for (int i=2; i<argumentCount; i++) {
            const char *type = [signature getArgumentTypeAtIndex:i];
            if ([[NSString stringWithUTF8String:type] isEqualToString:@"@"]) {
                [invocation setArgument:&gestureRecognizer atIndex:i];
            }else
            {
                int i=0;
                [invocation setArgument:&i atIndex:i];
            }
        }
        [invocation invoke];
    }
}
@end
