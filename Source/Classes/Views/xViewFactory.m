

#import "xViewFactory.h"
#import <UIKit/UIKit.h>

@implementation xViewFactory

+(UIView*)lineWithColor:(UIColor*)color{
    UIView *line = [UIView new];
    line.backgroundColor = color;
    return line;
}

+(UILabel*)labelWithText:(NSString*)text font:(UIFont*)font color:(UIColor*)color{
    return [self labelWithText:text font:font color:color alignment:NSTextAlignmentCenter];
}

+(UILabel*)labelWithText:(NSString*)text font:(UIFont*)font color:(UIColor*)color alignment:(NSTextAlignment)alignment{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = alignment;
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return label;
}

//高度会自动计算
+(UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineSpace:(CGFloat)lineSpace underline:(BOOL)underline {
    //
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:text];
    //行间距
    NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
    [pstyle setLineSpacing:lineSpace];
    [a addAttribute:NSParagraphStyleAttributeName value:pstyle range:NSMakeRange(0, text.length)];
    //字体
    [a addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    //文字颜色
    [a addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, text.length)];
    // 下划线
    if (underline) {
        [a addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, text.length)];
    }
    //求高度
    CGSize constrainedSize = CGSizeMake(frame.size.width, 9999);
    CGRect requiredRect = [a boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    //
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, requiredRect.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.attributedText = a;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return label;
}

+(UIButton*)imageButton:(UIImage*)image{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    return button;
}

+(UIButton*)buttonWithTitle:(NSString*)title
                       font:(UIFont*)font
                 titleColor:(UIColor*)titleColor
                    bgColor:(UIColor*)bgColor{
    return [self buttonWithTitle:title font:font titleColor:titleColor bgColor:bgColor cornerRadius:0 borderColor:UIColor.clearColor borderWidth:0 frame:CGRectZero];
}

+(UIButton*)buttonWithTitle:(NSString*)title
                       font:(UIFont*)font
                 titleColor:(UIColor*)titleColor
                    bgColor:(UIColor*)bgColor
               cornerRadius:(CGFloat)cornerRadius{
    
    return [self buttonWithTitle:title font:font titleColor:titleColor bgColor:bgColor cornerRadius:cornerRadius borderColor:UIColor.clearColor borderWidth:0 frame:CGRectZero];
}

+(UIButton*)buttonWithTitle:(NSString*)title
                       font:(UIFont*)font
                 titleColor:(UIColor*)titleColor
                    bgColor:(UIColor*)bgColor
                borderColor:(UIColor*)borderColor
                borderWidth:(CGFloat)borderWidth{
    
    return [self buttonWithTitle:title font:font titleColor:titleColor bgColor:bgColor cornerRadius:0 borderColor:borderColor borderWidth:borderWidth frame:CGRectZero];
}

+(UIButton*)buttonWithTitle:(NSString*)title
                       font:(UIFont*)font
                 titleColor:(UIColor*)titleColor
                    bgColor:(UIColor*)bgColor
               cornerRadius:(CGFloat)cornerRadius
                borderColor:(UIColor*)borderColor
                borderWidth:(CGFloat)borderWidth {
    
    return [self buttonWithTitle:title font:font titleColor:titleColor bgColor:bgColor cornerRadius:cornerRadius borderColor:borderColor borderWidth:borderWidth frame:CGRectZero];
}

+(UIButton*)buttonWithTitle:(NSString*)title
                       font:(UIFont*)font
                 titleColor:(UIColor*)titleColor
                    bgColor:(UIColor*)bgColor
               cornerRadius:(CGFloat)cornerRadius
                borderColor:(UIColor*)borderColor
                borderWidth:(CGFloat)borderWidth
                      frame:(CGRect)frame{
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState: UIControlStateNormal];
    button.titleLabel.font = font;
    button.backgroundColor = bgColor;
    if(cornerRadius > 0){
        button.layer.cornerRadius = cornerRadius;
    }
    if(![borderColor isEqual:UIColor.clearColor]){
        button.layer.borderWidth = borderWidth;
        button.layer.borderColor = borderColor.CGColor;
    }
    button.frame = frame;
    return button;
    
}

+(UITextField*)textfiledWith:(NSString*)text
                        font:(UIFont*)font
                   textColor:(UIColor*)textColor
               textAlignment:(NSTextAlignment)textAlignment
           verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment
                 placeholder:(NSString*)placeholder{
    
    UITextField * textfield = [[UITextField alloc]init];
    textfield.textAlignment = textAlignment;
    textfield.font = font;
    textfield.textColor = textColor;
    textfield.textAlignment = textAlignment;
    textfield.contentVerticalAlignment = verticalAlignment;
    textfield.placeholder = placeholder;
    return textfield;
}


@end
