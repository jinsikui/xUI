

#import "xToast.h"
#import "xViewFactory.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface xToastHandle : NSObject
@property(nonatomic,assign) BOOL isCanceled;
@end

@implementation xToastHandle
@end


@interface xToast()

@property(nonatomic,strong) UIView         *centerBgView;
@property(nonatomic,strong) UILabel        *textLabel;
@property(nonatomic,strong) xToastHandle   *handle;
@end

@implementation xToast

+(instancetype)shared {
    static xToast *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xToast alloc] init];
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

+(void)showInView:(UIView*)view text:(NSString*)text duration:(NSTimeInterval)duration distanceToBottom:(CGFloat)distanceToBottom{
    [self _executeMain:^{
        [[xToast shared] showInView:view text:text duration:duration distanceToBottom:distanceToBottom];
    }];
}

+(void)show:(NSString*)text duration:(NSTimeInterval)duration distanceToBottom:(CGFloat)distanceToBottom{
    [self _executeMain:^{
        [[xToast shared] showInView:UIApplication.sharedApplication.keyWindow text:text duration:duration distanceToBottom:distanceToBottom];
    }];
}

+(void)show:(NSString* __nullable)text duration:(NSTimeInterval)duration{
    [self _executeMain:^{
        [[xToast shared] showInView:UIApplication.sharedApplication.keyWindow text:text duration:duration distanceToBottom:0];
    }];
}

+(void)show:(NSString* __nullable)text{
    [self _executeMain:^{
        [[xToast shared] showInView:UIApplication.sharedApplication.keyWindow text:text duration:3 distanceToBottom:0];
    }];
}

+(void)hide{
    [self _executeMain:^{
        [[xToast shared] hide];
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
        
        _textLabel = [xViewFactory labelWithText:nil font:[self _semiboldPFWithSize:13] color:[self _colorFromRGBA:0xFFFFFF alpha:1] alignment:NSTextAlignmentCenter];
        _textLabel.numberOfLines = 0;
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

-(BOOL)_isPad{
    static dispatch_once_t one;
    static BOOL pad;
    dispatch_once(&one, ^{
        pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return pad;
}

-(BOOL)_isPortraitOrientation{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

static CGFloat _screenWidth = 0;
-(CGFloat)_screenWidth{
    if([self _isPad]){
        CGFloat screenWidth;
        if ([self _isPortraitOrientation]) {
            screenWidth = [UIScreen mainScreen].bounds.size.width;
        }else{
            screenWidth = [UIScreen mainScreen].bounds.size.height;
        }
        return screenWidth - 90 - 30.0 * 2;
    }
    else{
        if(_screenWidth <= 0){
            _screenWidth = [UIScreen mainScreen].bounds.size.width;
        }
        return _screenWidth;
    }
}

-(void)showInView:(UIView*)view
             text:(NSString* __nullable)text
         duration:(NSTimeInterval)duration
 distanceToBottom:(CGFloat)distanceToBottom
{
    [self hide];

    CGSize textSize = [self _sizeWithString:text Font:[self _semiboldPFWithSize:13] maxWidth:[self _screenWidth] - 100];

    CGFloat width = textSize.width + 20;
    CGFloat height = textSize.height + 20;
    if(distanceToBottom <= 0){
        [_centerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
            make.center.equalTo(self);
        }];
    }
    else{
        [_centerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
            make.centerX.equalTo(self);
            make.bottom.mas_equalTo(-distanceToBottom);
        }];
    }
    
    _textLabel.text = text;
    [_textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.centerBgView);
        make.width.mas_equalTo(textSize.width + 1);
        make.height.mas_equalTo(textSize.height + 1);
    }];
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    xToastHandle *handle = [xToastHandle new];
    self.handle = handle;
    __weak typeof(self) weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(handle.isCanceled){
            return;
        }
        [weak hide];
    });
}

-(void)hide{
    xToastHandle *handle = self.handle;
    if(handle){
        handle.isCanceled = true;
    }
    [self removeFromSuperview];
}

@end

