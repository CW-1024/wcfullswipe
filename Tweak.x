#import <UIKit/UIKit.h>

@interface MMUIViewController : UIViewController
@property (nonatomic, readonly) UINavigationController *navigationController;
@end

%hook MMUIViewController

- (void)viewDidLoad {
    %orig;
    
    if (![self isKindOfClass:NSClassFromString(@"BaseMsgContentViewController")]) {
        return;
    }

    UIGestureRecognizer *edgeGesture = self.navigationController.interactivePopGestureRecognizer;

    NSArray *targets = [edgeGesture valueForKey:@"_targets"];
    id targetObj = [targets.firstObject valueForKey:@"target"];
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");

    UIPanGestureRecognizer *fullScreenPan = [[UIPanGestureRecognizer alloc] initWithTarget:targetObj action:action];
    fullScreenPan.delegate = (id<UIGestureRecognizerDelegate>)self.navigationController.interactivePopGestureRecognizer.delegate;
    
    fullScreenPan.maximumNumberOfTouches = 1;
    [fullScreenPan requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    fullScreenPan.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:fullScreenPan];

    edgeGesture.enabled = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];
        return fabs(translation.x) > fabs(translation.y) && translation.x > 0;
    }
    return YES;
}

%end