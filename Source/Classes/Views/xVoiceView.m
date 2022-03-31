

#import "xVoiceView.h"

@interface xVoiceView()
@property(nonatomic,strong) UIView  *v1;
@property(nonatomic,strong) UIView  *v2;
@property(nonatomic,strong) UIView  *v3;
@property(nonatomic,readonly) NSArray<UIView*> *viewsInBox;
@property(nonatomic,assign) BOOL    isAnimationInit;
@property(nonatomic,assign) BOOL    isAnimationRunning;
@property(nonatomic,assign) CGSize  boxSize;
@property(nonatomic,strong) NSString *animationKey;
@end

@implementation xVoiceView

-(instancetype)initWithBoxSize:(CGSize)boxSize color:(UIColor*)color{
    self = [super init];
    if(self){
        self.boxSize = boxSize;
        self.animationKey = @"voiceAnimation";
        
        UIView *v1 = [UIView new];
        self.v1 = v1;
        v1.frame = CGRectMake(0, _boxSize.height * 3.0/5.0, _boxSize.width/5.0, _boxSize.height * 2.0 / 5.0);
        v1.backgroundColor = color;
        [self addSubview:v1];
        
        UIView *v2 = [UIView new];
        self.v2 = v2;
        v2.frame = CGRectMake(_boxSize.width*2.0/5.0, _boxSize.height * 3.0/5.0, _boxSize.width/5.0, _boxSize.height * 2.0 / 5.0);
        v2.backgroundColor = color;
        [self addSubview:v2];
        
        UIView *v3 = [UIView new];
        self.v3 = v3;
        v3.frame = CGRectMake(_boxSize.width*4.0/5.0, _boxSize.height * 3.0/5.0, _boxSize.width/5.0, _boxSize.height * 2.0 / 5.0);
        v3.backgroundColor = color;
        [self addSubview:v3];
    }
    return self;
}

-(instancetype)initWithBoxSize:(CGSize)boxSize{
    return [self initWithBoxSize:boxSize color:[self _colorFromRGBA:0x63C48F alpha:1]];
}

-(UIColor*)_colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}

-(NSArray<UIView*>*)viewsInBox{
    return @[self.v2,self.v1,self.v3];
}

-(void)reset{
    for(UIView *v in self.viewsInBox){
        [v.layer removeAllAnimations];
    }
    self.isAnimationInit = NO;
    self.isAnimationRunning = NO;
}

-(void)startAnimation{
    if(!_isAnimationInit){
        _isAnimationInit = YES;
        _isAnimationRunning = YES;
        double duration = 0.35;
        double delay = 0.0;
        double delta = duration / 3.0;
        CATransform3D transform = CATransform3DIdentity;
        //先缩放scale，再沿y平移
        float scale = 5.0/2.0;
        float moveY = -_boxSize.height * (0.5 - 0.4/2);
        transform = CATransform3DTranslate(transform, 0, moveY, 0);
        transform = CATransform3DScale(transform, 1, scale, 1);
        for(UIView *v in self.viewsInBox){
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.duration = duration; // 持续时间
            animation.repeatCount = MAXFLOAT; // 重复次数
            animation.beginTime = CACurrentMediaTime() + delay;
            animation.removedOnCompletion = NO;
            animation.autoreverses = YES;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            animation.toValue = [NSValue valueWithCATransform3D:transform];
            [v.layer addAnimation:animation forKey:_animationKey];
            delay += delta;
        }
    }
    else{
        [self resumeAnimation];
    }
}

-(void)pauseAnimation{
    if(!_isAnimationRunning){
        return;
    }
    _isAnimationRunning = NO;
    for(UIView *v in self.viewsInBox){
        CALayer *layer = v.layer;
        [self _pauseAnimation:layer];
    }
}

-(void)_pauseAnimation:(CALayer*)layer{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0;
    layer.timeOffset = pausedTime;
}

-(void)resumeAnimation{
    if(_isAnimationRunning){
        return;
    }
    _isAnimationRunning = YES;
    for(UIView *v in self.viewsInBox){
        CALayer *layer = v.layer;
        [self _resumeAnimation: layer];
    }
}

-(void)_resumeAnimation:(CALayer*)layer{
    CFTimeInterval pausedTime = layer.timeOffset;
    layer.speed = 1;
    layer.timeOffset = 0;
    layer.beginTime = 0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

-(void)dealloc{
    [self reset];
}

@end
