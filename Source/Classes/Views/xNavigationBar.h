

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^xNavBtnHandler)(void);

@interface xNavigationBar : UIView
//一般情况下不需要直接操作这些控件
@property(nonatomic)    UIView      *bar;
@property(nonatomic)    UILabel     *titleLabel;
@property(nonatomic)    UIButton    *leftImgBtn;
@property(nonatomic)    UIButton    *leftTextBtn;
@property(nonatomic)    UIButton    *rightImgBtn;
@property(nonatomic)    UIButton    *rightTextBtn;

//这些属性设置后会自动改变UI
@property(nonatomic,nullable)    NSString    *title;
@property(nonatomic,nullable)    UIColor     *titleColor;
@property(nonatomic,nullable)    NSString    *leftImg;
@property(nonatomic,nullable)    NSString    *leftText;
@property(nonatomic,nullable)    UIColor     *leftTextColor;
@property(nonatomic,nullable)    xNavBtnHandler     leftBtnHandler;
@property(nonatomic,nullable)    NSString    *rightImg;
@property(nonatomic,nullable)    NSString    *rightText;
@property(nonatomic,nullable)    UIColor     *rightTextColor;
@property(nonatomic,nullable)    xNavBtnHandler     rightBtnHandler;
//在bar的下底添加内阴影，需要手动调用
-(void)addBottomShadow;


@end

NS_ASSUME_NONNULL_END
