

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,xImageTitleControlLayout) {
    xImageTitleControlLayoutTextLeft = 0,
    xImageTitleControlLayoutTextRight,
    xImageTitleControlLayoutTextBottom,
};

NS_ASSUME_NONNULL_BEGIN

@interface xImageTitleControl : UIControl

@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UILabel *label;

-(instancetype)initWithTitle:(NSString*)title
                   titleFont:(UIFont*)titleFont
                  titleColor:(UIColor*)titleColor
                     imgName:(NSString*)imgName
                    imgWidth:(CGFloat)imgWidth
                      layout:(xImageTitleControlLayout)layout;

-(instancetype)initWithTitle:(NSString*)title
                   titleFont:(UIFont*)titleFont
                  titleColor:(UIColor*)titleColor
                         img:(UIImage*)img
                    imgWidth:(CGFloat)imgWidth
                      layout:(xImageTitleControlLayout)layout;

-(instancetype)initWithTitle:(NSString*)title
                   titleFont:(UIFont*)titleFont
                  titleColor:(UIColor*)titleColor
                      imgUrl:(NSString*)imgUrl
                    imgWidth:(CGFloat)imgWidth
                   imgHeight:(CGFloat)imgHeight
                      layout:(xImageTitleControlLayout)layout;
@end

NS_ASSUME_NONNULL_END
