

#import "xScrollView.h"

@interface xScrollView () <UIGestureRecognizerDelegate>

@end

@implementation xScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
