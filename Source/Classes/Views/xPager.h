

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^xPageSelectCallback)(NSInteger);

@interface xPager : UIView

@property(nonatomic) NSInteger pageCount;
@property(nonatomic) NSInteger curPageIndex;
@property(nonatomic) CGFloat dotWidth;
@property(nonatomic) CGFloat dotInterval;
@property(nonatomic) UIColor *selectColor;
@property(nonatomic) UIColor *unselectColor;
///是否允许点击选中
@property(nonatomic) BOOL touchEnabled;
///当touchEnabled==YES时，选中后回调
@property(nonatomic,nullable) xPageSelectCallback selectCallback;


-(instancetype)initWithPageCount:(NSInteger)pageCount selectColor:(UIColor*)selectColor unselectColor:(UIColor*)unselectColor;

-(instancetype)initWithPageCount:(NSInteger)pageCount dotWidth:(CGFloat)dotWidth dotInterval:(CGFloat)dotInterval selectColor:(UIColor*)selectColor unselectColor:(UIColor*)unselectColor touchEnabled:(BOOL)touchEnabled;

@end

NS_ASSUME_NONNULL_END
