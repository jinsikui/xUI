

#import "xBasePopView.h"
#import "xPopViewQueue.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

static  xBasePopView  *windowPopView = nil;

@interface xBasePopView()<UIGestureRecognizerDelegate>
@end

@implementation xBasePopView

+(xBasePopView*)windowPopView{
    return windowPopView;
}

+(void)setWindowPopView:(xBasePopView *)popView{
    windowPopView = popView;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self prepareWithLevel:LivePopViewLevelUserTrigger coverColor:[self _colorFromRGBA:0 alpha:0.3] isCloseOnSpaceClick:YES];
    }
    return self;
}

-(UIColor*)_colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}

-(instancetype)initWithLevel:(LivePopViewLevel)level{
    self = [super init];
    if(self){
        [self prepareWithLevel:level coverColor:[self _colorFromRGBA:0 alpha:0.3] isCloseOnSpaceClick:YES];
    }
    return self;
}

-(instancetype)initWithLevel:(LivePopViewLevel)level coverColor:(UIColor*)coverColor{
    self = [super init];
    if(self){
        [self prepareWithLevel:level coverColor:coverColor isCloseOnSpaceClick:YES];
    }
    return self;
}

-(instancetype)initWithLevel:(LivePopViewLevel)level isCloseOnSpaceClick:(BOOL)isCloseOnSpaceClick{
    self = [super init];
    if(self){
        [self prepareWithLevel:level coverColor:[self _colorFromRGBA:0 alpha:0.3] isCloseOnSpaceClick:isCloseOnSpaceClick];
    }
    return self;
}

-(instancetype)initWithLevel:(LivePopViewLevel)level coverColor:(UIColor*)coverColor isCloseOnSpaceClick:(BOOL)isCloseOnSpaceClick{
    self = [super init];
    if(self){
        [self prepareWithLevel:level coverColor:coverColor isCloseOnSpaceClick:isCloseOnSpaceClick];
    }
    return self;
}

-(void)prepareWithLevel:(LivePopViewLevel)level coverColor:(UIColor*)coverColor isCloseOnSpaceClick:(BOOL)isCloseOnSpaceClick{
    _level = level;
    _coverColor = coverColor;
    _isCloseOnSpaceClick = isCloseOnSpaceClick;
    _useFrameLayout = NO;
    self.backgroundColor = coverColor;
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionSpaceClick)];
    g.delegate = self;
    [self addGestureRecognizer:g];
}

-(void)actionSpaceClick{
    if(_isCloseOnSpaceClick){
        [self hideAndTryDequeue];
    }
}

-(void)showInWindow{
    [self showInView:[UIApplication sharedApplication].delegate.window queue:nil];
    windowPopView = self;
}

-(void)showInView:(UIView*)view{
    [self showInView:view queue:nil];
}

-(void)showInView:(UIView*)view queue:(xPopViewQueue*)queue{
    if(self.superview){
        return;
    }
    if(queue){
        self.queue = queue;
    }
    [view addSubview:self];
    if(_useFrameLayout){
        self.frame = view.bounds;
    }
    else{
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
    }
    LivePopViewAfterShowBlock callback = self.afterShowCallback;
    if(callback){
        callback(self);
    }
    self.queue.curPopView = self;
}

-(void)hideAndTryDequeue{
    if(self.superview){
        [self hide];
        if(self.queue){
            [self.queue tryDequeueAndShowPopView];
        }
    }
}

+(void)hideFromWindow{
    if(windowPopView){
        [windowPopView hide];
    }
}

-(void)hide{
    if(windowPopView == self){
        windowPopView = nil;
    }
    if(self.superview){
        xBasePopView *popView = self;
        [popView removeFromSuperview];
        if(popView.queue){
            popView.queue.curPopView = nil;
        }
        if(popView.afterHideCallback){
            popView.afterHideCallback(popView);
        }
    }
}

#pragma mark - gestureRecognizer

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return touch.view == gestureRecognizer.view;
}

@end
