

#import "xCornerView.h"


@interface xCornerView()

@property(nonatomic) CAShapeLayer *borderLayer;

@end

@implementation xCornerView

-(instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius{
    self = [super init];
    if(self){
        self.corners = corners;
        self.radius = radius;
        self.borderWidth = 0;
        self.borderColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:_corners cornerRadii:CGSizeMake(_radius, _radius)];
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = maskPath.CGPath;
    self.layer.mask = shape;
    if(_borderLayer != nil){
        [_borderLayer removeFromSuperlayer];
    }
    if(_borderWidth > 0 && ![_borderColor isEqual:[UIColor clearColor]]){
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        self.borderLayer = borderLayer;
        borderLayer.path = maskPath.CGPath;
        borderLayer.fillColor = nil;
        borderLayer.strokeColor = _borderColor.CGColor;
        borderLayer.lineWidth = _borderWidth;
        [self.layer addSublayer:borderLayer];
    }
}

@end
