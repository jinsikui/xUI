

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class xPopViewQueue;
@class xBasePopView;

//值越小，越重要
typedef enum LivePopViewLevel{
    LivePopViewLevelCritical = 0,
    LivePopViewLevelUserTrigger = 1,
    LivePopViewLevelSystemInfo = 2
}LivePopViewLevel;

typedef void(^LivePopViewAfterShowBlock)(xBasePopView*);
typedef void(^LivePopViewAfterHideBlock)(xBasePopView*);
typedef BOOL(^LivePopViewShouldShowCallback)(xBasePopView*);

@interface xBasePopView : UIView

@property(nonatomic,class,strong) xBasePopView *windowPopView;

@property(nonatomic) LivePopViewLevel       level;
@property(nonatomic) UIColor                *coverColor;
@property(nonatomic) BOOL                   isCloseOnSpaceClick;
@property(nonatomic) BOOL                   useFrameLayout;
@property(nonatomic) LivePopViewAfterShowBlock  afterShowCallback;
@property(nonatomic) LivePopViewAfterHideBlock  afterHideCallback;
/// 这个回调仅当结合弹窗队列（xPopViewQueue）使用时有意义，用于在要显示队列中弹窗前决定是否要显示，如果返回false会直接丢弃这个弹窗
@property(nonatomic) LivePopViewShouldShowCallback shouldShowCallback;
@property(nonatomic,weak) xPopViewQueue  *queue;
-(instancetype)initWithFrame:(CGRect)frame;
-(instancetype)initWithLevel:(LivePopViewLevel)level;
-(instancetype)initWithLevel:(LivePopViewLevel)level coverColor:(UIColor*)coverColor;
-(instancetype)initWithLevel:(LivePopViewLevel)level isCloseOnSpaceClick:(BOOL)isCloseOnSpaceClick;
-(instancetype)initWithLevel:(LivePopViewLevel)level coverColor:(UIColor*)coverColor isCloseOnSpaceClick:(BOOL)isCloseOnSpaceClick;
-(void)showInWindow;
-(void)showInView:(UIView*)view;
/// xPopViewQueue.inqueuePopView(popView)方法内部会调这个方法，用户不需要自己调用这个方法
-(void)showInView:(UIView*)view queue:(xPopViewQueue* _Nullable)queue;
-(void)actionSpaceClick;
-(void)hideAndTryDequeue;
-(void)hide;
+(void)hideFromWindow;
@end

NS_ASSUME_NONNULL_END
