

#import "xUIUtil.h"

@implementation xUIUtil

+ (CGFloat)statusBarHeight{
    if (self.isiPhoneXSeries) {
        return 44;
    } else {
        return 20;
    }
}

+ (BOOL)isiPhoneXSeries {
    // 宽高都会变化，以后可能变的更大，但最小的都有以下的值
    return ([UIScreen mainScreen].bounds.size.width >= 375 && [UIScreen mainScreen].bounds.size.width <= 414 && [UIScreen mainScreen].bounds.size.height >= 812);
}

+ (CGFloat)navBarHeight{
    return 44;
}

+ (CGSize)x_sizeWithFont:(UIFont*)font maxWidth:(CGFloat)maxWidth contentStr:(NSString *)string {
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: font}];
    CGSize size = [attr boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return CGSizeMake(size.width + 1, size.height);;
}

+ (UIColor*)colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{

    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}



@end
