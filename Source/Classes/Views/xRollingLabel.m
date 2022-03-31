

#import "xRollingLabel.h"
#import "xViewFactory.h"

@interface xRollingLabel(){
    NSString * _text;
}
@property(nonatomic) UIFont *font;
@property(nonatomic) UIColor *textColor;
@property(nonatomic) CGSize size;
@property(nonatomic) CGSize textSize;
@property(nonatomic) CGFloat interSpace;
@property(nonatomic) CGFloat shadowWidth;
@property(nonatomic) CGFloat rollingSpeed; //每秒多少个pt
@property(nonatomic) double duration; //一趟动画的时间
@property(nonatomic) BOOL shouldRolling;
@property(nonatomic) BOOL isStarted;
@property(nonatomic) CAGradientLayer *mask;
@property(nonatomic) UILabel *label1;
@property(nonatomic) UILabel *label2;
@end

@implementation xRollingLabel

-(instancetype)initWithFont:(UIFont*)font textColor:(UIColor*)textColor size:(CGSize)size{
    self = [super initWithFrame:CGRectMake(0,0,size.width,size.height)];
    if(self){
        _size = size;
        _font = font;
        _textColor = textColor;
        _interSpace = 10;
        _rollingSpeed = 8;
        _shadowWidth = 10;
        self.clipsToBounds = YES;
        
        CAGradientLayer *mask = [CAGradientLayer new];
        mask.frame = CGRectMake(0, 0, _size.width, _size.height);
        //实际上，colors只有alpha的部分起作用
        mask.colors = @[(id)UIColor.clearColor.CGColor, (id)UIColor.whiteColor.CGColor, (id)UIColor.whiteColor.CGColor, (id)UIColor.clearColor.CGColor];
        mask.locations = @[@(0), @(_shadowWidth/_size.width), @((_size.width - _shadowWidth)/_size.width), @(1)];
        mask.startPoint = CGPointMake(0, 0.5);
        mask.endPoint = CGPointMake(1, 0.5);
        _mask = mask;
        self.layer.mask = mask;
        
        _label1 = [xViewFactory labelWithText:nil font:_font color:_textColor];
        _label1.frame = CGRectMake(0, 0, 0, size.height);
        [self addSubview:_label1];
        
        _label2 = [xViewFactory labelWithText:nil font:font color:textColor];
        _label2.frame = CGRectMake(0, 0, 0, size.height);
        _label2.hidden = YES;
        [self addSubview:_label2];
    }
    return self;
}

-(UIFont*)_semiboldPFWithSize:(CGFloat)size{
    if (@available(iOS 9.0, *)) {
        return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
    }
    else{
        return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    }
}

-(CGSize)_sizeWithString:(NSString*)string Font:(UIFont*)font maxWidth:(CGFloat)maxWidth{
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: font}];
    CGSize size = [attr boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return CGSizeMake(size.width + 1, size.height);
}

-(NSString*)text{
    return _text;
}

-(void)setText:(NSString *)text{
    [self stop];
    _text = text;
    _textSize = [self _sizeWithString:text Font:[self _semiboldPFWithSize:13] maxWidth:CGFLOAT_MAX];
    if(_textSize.width <= _size.width){
        _shouldRolling = NO;
        _label1.text = text;
        _label1.frame = CGRectMake(0, 0, _textSize.width, _size.height);
        _label2.hidden = YES;
        self.layer.mask = nil;
    }
    else{
        _shouldRolling = YES;
        _label1.text = text;
        _label1.frame = CGRectMake(0, 0, _textSize.width, _size.height);
        _label2.text = text;
        _label2.frame = CGRectMake(_textSize.width + _interSpace, 0, _textSize.width, _size.height);
        _label2.hidden = NO;
        self.layer.mask = _mask;
        _duration = (_textSize.width + _interSpace) / _rollingSpeed;
        [self start];
    }
}

-(void)start{
    if(!_shouldRolling){
        return;
    }
    if(_isStarted){
        return;
    }
    _isStarted = YES;
    __weak typeof(self) weak = self;
    [UIView animateWithDuration:_duration delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear) animations:^{
        weak.label1.frame = CGRectMake(-(weak.textSize.width + weak.interSpace), 0, weak.textSize.width, weak.size.height);
        weak.label2.frame = CGRectMake(0, 0, weak.textSize.width, weak.size.height);
    } completion:nil];
}

-(void)stop{
    if(!_shouldRolling){
        return;
    }
    if(!_isStarted){
        return;
    }
    [_label1.layer removeAllAnimations];
    [_label2.layer removeAllAnimations];
    _isStarted = NO;
}

-(void)dealloc{
    [self stop];
}

@end
