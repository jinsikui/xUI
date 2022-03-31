

#import "xLoading.h"
#import "xViewFactory.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface xLoading()

@property(nonatomic) UIView     *centerBgView;
@property(nonatomic) UILabel    *textLabel;
@property(nonatomic) UIActivityIndicatorView    *spinnerView;

@end

@implementation xLoading

+(instancetype)shared {
    static xLoading *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xLoading alloc] init];
    });
    return instance;
}

+(void)_executeMain:(void(^)(void))task{
    if(NSThread.isMainThread){
        task();
    }
    else{
        dispatch_async(dispatch_get_main_queue(), task);
    }
}

+(void)showInView:(UIView*)view text:(NSString* __nullable)text{
    [self _executeMain:^{
        [[xLoading shared] showInView:view text:text];
    }];
}

+(void)showInWindow:(NSString* __nullable)text{
    [self _executeMain:^{
        [[xLoading shared] showInView:UIApplication.sharedApplication.keyWindow text:text];
    }];
}

+(void)showInWindow{
    [self _executeMain:^{
        [[xLoading shared] showInView:UIApplication.sharedApplication.keyWindow text:nil];
    }];
}

+(void)hide{
    [self _executeMain:^{
        [[xLoading shared] hide];
    }];
}

-(instancetype)init{
    self = [super init];
    if(self){
        self.userInteractionEnabled = NO;
        
        _centerBgView = [UIView new];
        _centerBgView.layer.cornerRadius = 5;
        _centerBgView.backgroundColor = [self _colorFromRGBA:0 alpha:0.7];
        [self addSubview:_centerBgView];
        
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_centerBgView addSubview:_spinnerView];
        [_spinnerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.centerBgView);
        }];
        
        _textLabel = [xViewFactory labelWithText:nil font:[self _semiboldPFWithSize:13] color:[self _colorFromRGBA:0xFFFFFF alpha:1] alignment:NSTextAlignmentCenter];
        _textLabel.numberOfLines = 1;
        [_centerBgView addSubview:_textLabel];
    }
    return self;
}

-(UIColor*)_colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}

-(UIFont*)_semiboldPFWithSize:(CGFloat)size{
    if (@available(iOS 9.0, *)) {
        return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
    }
    else{
        return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    }
}

-(CGSize)_sizeWithString:(NSString*)string Font:(UIFont*)font maxWidth:(CGFloat)maxWidth{
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: font}];
    CGSize size = [attr boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return CGSizeMake(size.width + 1, size.height);
}

-(void)showInView:(UIView*)view
             text:(NSString* __nullable)text{
    [self hide];
    if(text == nil || ![text isKindOfClass:[NSString class]] || ((NSString*)text).length == 0){
        CGFloat minWidth = 90;
        [_centerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(minWidth);
            make.center.equalTo(self);
        }];
        [_spinnerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.centerBgView);
        }];
        _textLabel.hidden = YES;
    }
    else{
        CGFloat minWidth = 100;
        CGFloat width = minWidth;
        CGFloat height = minWidth;
        CGFloat textWidth = [self _sizeWithString:text Font:[self _semiboldPFWithSize:13] maxWidth:CGFLOAT_MAX].width;
        if(textWidth + 30 > width){
            width = textWidth + 30;
        }
        [_centerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
            make.center.equalTo(self);
        }];
        [_spinnerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerBgView);
            make.top.mas_equalTo(16);
        }];
        _textLabel.text = text;
        [_textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerBgView);
            make.top.equalTo(self.spinnerView.mas_bottom).offset(12);
        }];
        _textLabel.hidden = NO;
        
    }
    [_spinnerView startAnimating];
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
}

-(void)hide{
    [_spinnerView stopAnimating];
    [self removeFromSuperview];
}

@end
