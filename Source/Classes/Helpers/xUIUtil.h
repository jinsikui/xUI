

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xUIUtil : NSObject

+ (CGFloat)navBarHeight;

+ (BOOL)isiPhoneXSeries;

+ (CGFloat)statusBarHeight;

+ (UIColor*)colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha;


+ (CGSize)x_sizeWithFont:(UIFont*)font maxWidth:(CGFloat)maxWidth contentStr:(NSString *)string;


@end

NS_ASSUME_NONNULL_END
