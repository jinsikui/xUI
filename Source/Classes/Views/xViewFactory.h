

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xViewFactory : NSObject

+(UIView*)lineWithColor:(UIColor*)color;

+(UILabel*)labelWithText:(NSString* _Nullable)text font:(UIFont*)font color:(UIColor*)color;

+(UILabel*)labelWithText:(NSString* _Nullable)text font:(UIFont*)font color:(UIColor*)color alignment:(NSTextAlignment)alignment;

///高度会自动计算
+(UILabel *)labelWithFrame:(CGRect)frame text:(NSString * )text font:(UIFont *)font textColor:(UIColor *)textColor lineSpace:(CGFloat)lineSpace underline:(BOOL)underline;

+(UIButton*)imageButton:(UIImage*)image;

+(UIButton*)buttonWithTitle:(NSString* _Nullable)title font:(UIFont*)font titleColor:(UIColor*)titleColor bgColor:(UIColor*)bgColor;

+(UIButton*)buttonWithTitle:(NSString* _Nullable)title font:(UIFont*)font titleColor:(UIColor*)titleColor bgColor:(UIColor*)bgColor cornerRadius:(CGFloat)cornerRadius;

+(UIButton*)buttonWithTitle:(NSString* _Nullable)title font:(UIFont*)font titleColor:(UIColor*)titleColor bgColor:(UIColor*)bgColor borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth;

+(UIButton*)buttonWithTitle:(NSString* _Nullable)title font:(UIFont*)font titleColor:(UIColor*)titleColor bgColor:(UIColor*)bgColor cornerRadius:(CGFloat)cornerRadius borderColor:(UIColor*)borderColor borderWidth:(CGFloat)borderWidth;

+(UIButton*)buttonWithTitle:(NSString* _Nullable)title
                       font:(UIFont*)font
                 titleColor:(UIColor*)titleColor
                    bgColor:(UIColor*)bgColor
               cornerRadius:(CGFloat)cornerRadius
                borderColor:(UIColor*)borderColor
                borderWidth:(CGFloat)borderWidth
                      frame:(CGRect)frame;

+(UITextField*)textfiledWith:(NSString* _Nullable)text
                        font:(UIFont*)font
                   textColor:(UIColor*)textColor
               textAlignment:(NSTextAlignment)textAlignment
           verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
                 placeholder:(NSString* _Nullable)placeholder;

@end

NS_ASSUME_NONNULL_END
