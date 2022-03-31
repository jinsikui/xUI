

#import "xHitlessView.h"

@implementation xHitlessView

-(instancetype)initWithPolicy:(xHitlessPolicy)policy{
    self = [super init];
    if(self){
        self.policy = policy;
    }
    return self;
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(self.policy == xHitlessPolicyOnlySelf && hitView == self){
        return nil;
    }
    else if(self.policy == xHitlessPolicyAllDescendants && [hitView isDescendantOfView:self]){
        return nil;
    }
    return hitView;
}

@end
