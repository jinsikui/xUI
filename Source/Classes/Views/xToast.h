

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xToast : UIView

+(void)show:(NSString* __nullable)text duration:(NSTimeInterval)duration distanceToBottom:(CGFloat)distanceToBottom;

+(void)show:(NSString* __nullable)text duration:(NSTimeInterval)duration;;

+(void)show:(NSString* __nullable)text;

+(void)hide;

@end

NS_ASSUME_NONNULL_END
