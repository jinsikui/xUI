

#import "xGradientView.h"

@interface xGradientView ()
{
    CAGradientLayer   *_gradientLayer;
}

@end

@implementation xGradientView

/**
 *  修改当前view的backupLayer为CAGradientLayer
 *
 *  @return CAGradientLayer类名字
 */
+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gradientLayer = (CAGradientLayer *)self.layer;
        _gradientLayer.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/**
 *  重写setter,getter方法
 */
@synthesize colors = _colors;
- (void)setColors:(NSArray *)colors {
    _colors = colors;
    
    // 设置Colors
    _gradientLayer.colors = colors;
}

- (NSArray *)colors {
    return _colors;
}

@synthesize locations = _locations;
- (void)setLocations:(NSArray *)locations {
    _locations = locations;
    _gradientLayer.locations = _locations;
}

- (NSArray *)locations {
    return _locations;
}

@synthesize startPoint = _startPoint;
- (void)setStartPoint:(CGPoint)startPoint {
    _startPoint = startPoint;
    _gradientLayer.startPoint = startPoint;
}

- (CGPoint)startPoint {
    return _startPoint;
}

@synthesize endPoint = _endPoint;
- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    _gradientLayer.endPoint = endPoint;
}

- (CGPoint)endPoint {
    return _endPoint;
}

@end
