

#import "xPopViewQueue.h"

@implementation xPopViewQueue

-(instancetype)initWithView:(UIView*)view{
    self = [super init];
    if(self){
        _view = view;
        _popViews = [NSMutableArray array];
    }
    return self;
}

-(void)inqueuePopView:(xBasePopView*)popView{
    @synchronized(self){
        [_popViews addObject:popView];
    }
    [self tryDequeueAndShowPopView];
}

-(void)tryDequeueAndShowPopView{
    BOOL shouldTryAgain = NO;
    @synchronized(self){
        if(_popViews.count == 0){
            return;
        }
        xBasePopView *next = nil;
        xBasePopView *cur = self.curPopView;
        for(xBasePopView *popView in self.popViews){
            if(cur){
                //相同级别会覆盖
                if(cur.level < LivePopViewLevelSystemInfo && popView.level > cur.level){
                    continue;
                }
                //相同级别会排队
                if(cur.level == LivePopViewLevelSystemInfo && popView.level >= cur.level){
                    continue;
                }
            }
            if(!next){
                next = popView;
            }
            else{
                if(popView.level < next.level){
                    next = popView;
                }
            }
        }
        if(!next){
            return;
        }
        [self.popViews removeObject:next];
        LivePopViewShouldShowCallback callback = next.shouldShowCallback;
        if(!callback || callback(next)){
            if(cur){
                [cur hide];
            }
            [next showInView:self.view queue:self];
        }
        else{
            shouldTryAgain = YES;
        }
    }
    if(shouldTryAgain){
        [self tryDequeueAndShowPopView];
    }
}

@end
