

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 可以任意指定view的四个角中哪些需要圆角
 在autolayout的情况下，无法根据view的frame来设置layer.mask的尺寸，这个类通过覆盖draw(rect:)实现
 必须在view尺寸改变后调用setNeedsDisplay()方法来触发draw(rect:)
 **/
@interface xCornerView : UIView

@property(nonatomic) UIRectCorner corners;
@property(nonatomic) CGFloat radius;
///default is 0
@property(nonatomic) CGFloat borderWidth;
///default is clear color
@property(nonatomic) UIColor *borderColor;

-(instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
