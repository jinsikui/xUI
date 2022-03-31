

#import "xImageTitleControl.h"
#import "xViewFactory.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface xImageTitleControl()
@property(nonatomic)    UIImageView     *imgv;
@end

@implementation xImageTitleControl

-(instancetype)initWithTitle:(NSString*)title
                   titleFont:(UIFont*)titleFont
                  titleColor:(UIColor*)titleColor
                      imgUrl:(NSString*)imgUrl
                    imgWidth:(CGFloat)imgWidth
                   imgHeight:(CGFloat)imgHeight
                      layout:(xImageTitleControlLayout)layout{
    self = [super init];
    if(self){
        [self commonInitWithTitle:title titleFont:titleFont titleColor:titleColor img:nil imgUrl:imgUrl imgWidth:imgWidth imgHeight:imgHeight layout:layout];
    }
    return self;
}

-(instancetype)initWithTitle:(NSString*)title
                   titleFont:(UIFont*)titleFont
                  titleColor:(UIColor*)titleColor
                     imgName:(NSString*)imgName
                    imgWidth:(CGFloat)imgWidth
                      layout:(xImageTitleControlLayout)layout{
    self = [super init];
    if(self){
        [self commonInitWithTitle:title titleFont:titleFont titleColor:titleColor img:[UIImage imageNamed:imgName] imgUrl:nil imgWidth:imgWidth imgHeight:0 layout:layout];
    }
    return self;
}

-(instancetype)initWithTitle:(NSString*)title
                   titleFont:(UIFont*)titleFont
                  titleColor:(UIColor*)titleColor
                         img:(UIImage*)img
                    imgWidth:(CGFloat)imgWidth
                      layout:(xImageTitleControlLayout)layout{
    self = [super init];
    if(self){
        [self commonInitWithTitle:title titleFont:titleFont titleColor:titleColor img:img imgUrl:nil imgWidth:imgWidth imgHeight:0 layout:layout];
    }
    return self;
}

-(void)commonInitWithTitle:(NSString*)title
                         titleFont:(UIFont*)titleFont
                        titleColor:(UIColor*)titleColor
                                img:(UIImage*)img
                            imgUrl:(NSString*)imgUrl
                          imgWidth:(CGFloat)imgWidth
                         imgHeight:(CGFloat)imgHeight
                            layout:(xImageTitleControlLayout)layout{
    
    UIImageView *imgv = nil;
    CGFloat height = 0;
    if(img != nil && ![img isKindOfClass:[NSNull class]]){
        imgv = [[UIImageView alloc] initWithImage:img];
        imgv.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imgv];
        height = imgWidth * img.size.height / img.size.width;
    }
    else{
        imgv = [[UIImageView alloc] init];
        [imgv sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
        imgv.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imgv];
        height = imgHeight;
    }
    self.imageView = imgv;
    
    UILabel *titleLabel = [xViewFactory labelWithText:title font:titleFont color:titleColor];
    [self addSubview:titleLabel];
    self.label = titleLabel;
    if(layout == xImageTitleControlLayoutTextBottom){
        
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(imgWidth);
            make.height.mas_equalTo(height);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.centerX.equalTo(self);
        }];
    }
    else if(layout == xImageTitleControlLayoutTextLeft){
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(imgWidth);
            make.height.mas_equalTo(height);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.equalTo(self);
        }];
    }
    else if(layout == xImageTitleControlLayoutTextRight){
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(imgWidth);
            make.height.mas_equalTo(height);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.centerY.equalTo(self);
        }];
    }
}

@end
