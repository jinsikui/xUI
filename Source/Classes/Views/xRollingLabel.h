

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xRollingLabel : UIView

-(instancetype)initWithFont:(UIFont*)font textColor:(UIColor*)textColor size:(CGSize)size;
///可多次设置不同值
@property(nonatomic) NSString *text;
@end

NS_ASSUME_NONNULL_END
