

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xLoading : UIView

+(void)showInView:(UIView*)view text:(NSString* __nullable)text;

+(void)showInWindow:(NSString* __nullable)text;

+(void)showInWindow;

+(void)hide;

@end

NS_ASSUME_NONNULL_END
