

#import "MainViewController.h"
#import "xUtil.h"
#import "xUI.h"
#import "Masonry.h"
#import "xBaseController.h"
#import "SDWebImage.h"
#import "TestBannerController.h"


@interface MainViewController ()
@property(nonatomic,strong) UIScrollView   *scroll;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"xUI Test";
    self.view.backgroundColor = UIColor.whiteColor;
    _scroll = [[UIScrollView alloc] init];
    _scroll.alwaysBounceVertical = true;
    [self.view addSubview:_scroll];
    [_scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self addBtn:@"9 patch" y:30 selector:@selector(action9Patch)];
    [self addBtn:@"alphaVideo-top" y:80 selector:@selector(actionAlphaVideoTop)];
    [self addBtn:@"alphaVideo-bottom" y:130 selector:@selector(actionAlphaVideoBottom)];
    [self addBtn:@"xBaseController" y:180 selector:@selector(baseControllerTest)];
    [self addBtn:@"loading" y:230 selector:@selector(loadingTest)];
    [self addBtn:@"toast" y:280 selector:@selector(toastTest)];
    [self addBtn:@"banner" y:330 selector:@selector(actionBanner)];
    [self addBtn:@"xAlert" y:380 selector:@selector(actionxAlert)];
    [self addBtn:@"xCornerView" y:430 selector:@selector(actionxCornerView)];
    [self addBtn:@"xGradientView" y:480 selector:@selector(actionGradientView)];
    //
    _scroll.contentSize = CGSizeMake(0, 580);
}

-(void)addBtn:(NSString*)text y:(CGFloat)y selector:(SEL)selector{
    UIButton *btn = [xViewFactory buttonWithTitle:text font:kFontRegularPF(12) titleColor:kColor(0) bgColor:xColor.clearColor borderColor:kColor(0) borderWidth:0.5];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0.5 * (xDevice.screenWidth - 150), y, 150, 35);
    [self.scroll addSubview:btn];
}

-(void)refreshConstraints{
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

#pragma mark - Actions

-(void)actionGradientView {
    xGradientView *gv = [[xGradientView alloc] init];
    gv.colors = @[
        (__bridge id)[xColor fromRGBA:0x0000FF alpha:0.76].CGColor,
        (__bridge id)[xColor fromRGBA:0x0000FF alpha:0].CGColor,
    ];
    // 从上到下渐变
    gv.startPoint = CGPointMake(0.5, 0);
    gv.endPoint = CGPointMake(0.5, 1);
    
    [self.view addSubview:gv];
    [gv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view).offset(120);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
}

-(void)actionxCornerView {
    xCornerView *cv = [[xCornerView alloc] initWithCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft radius:10];
    cv.backgroundColor = UIColor.systemBlueColor;
    [self.view addSubview:cv];
    [cv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view).offset(120);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
}

-(void)actionxAlert {
    xAlert.presentFromControllerProvider = ^UIViewController * _Nullable{
        return UIApplication.sharedApplication.keyWindow.rootViewController;
    };
    [xAlert showSystemAlertWithTitle:@"提示" message:@"退出直播间会断开与主播的连麦" confirmText:@"再看看" cancelText:@"仍然退出" callback:^(UIAlertAction * _Nonnull action) {
        if([action.title isEqualToString:@"再看看"]){
            // 再看看 ...
        }
        else {
            // 仍然退出 ...
        }
    }];
}

-(void)actionBanner {
    [self.navigationController pushViewController:[TestBannerController new] animated:true];
}

-(void)actionAlphaVideoBottom{
    xAlphaVideoView *view = [xAlphaVideoView new];
    [self.view addSubview:view];
    [view playUrl:[NSBundle.mainBundle URLForResource:@"天秤" withExtension:@"mp4"] infoCallback:^(UIView * _Nonnull view, CGSize videoSize, double duration) {
        //这里不能直接引用self or self.view，会造成循环引用
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kScreenWidth * videoSize.height / videoSize.width);
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    } completion:^(UIView * _Nonnull view, NSError * _Nullable error) {
        NSLog(@"===== video complete: error(%@) =====", error);
        [view removeFromSuperview];
    }];
}

-(void)actionAlphaVideoTop{
    xAlphaVideoView *view = [xAlphaVideoView new];
    [self.view addSubview:view];
    [view playUrl:[NSBundle.mainBundle URLForResource:@"天秤" withExtension:@"mp4"] infoCallback:^(UIView * _Nonnull view, CGSize videoSize, double duration) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(kScreenWidth * videoSize.height / videoSize.width);
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(0);
        }];
    } completion:^(UIView * _Nonnull view, NSError * _Nullable error) {
        NSLog(@"===== video complete: error(%@) =====", error);
        [view removeFromSuperview];
    }];
}

-(void)action9Patch{
    NSData *data = [xFile getDataFromFileOfPath:[xFile bundlePath:@"国王气泡.png"]];
    UIImage *resizableImg = [x9PatchParser resizableImageFromPngData:data scale:3];
    UIImageView *imgv = [[UIImageView alloc] initWithImage:resizableImg];
    [self.view addSubview:imgv];
    [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.top.mas_equalTo(200);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(150);
    }];
}

- (void)baseControllerTest {
    xBaseController * baseController = [xBaseController new];
    baseController.navigationBar.title = @"baseVC";
    baseController.navigationBar.leftText = @"返回";
    baseController.navigationBar.leftTextColor = [UIColor grayColor];
    baseController.navigationBar.leftBtnHandler = ^{
        [self.navigationController popViewControllerAnimated:true];
    };
    baseController.navigationBar.rightText = @"右侧返回";
    baseController.navigationBar.rightTextColor = [UIColor grayColor];
    baseController.navigationBar.rightBtnHandler = ^{
        [self.navigationController popViewControllerAnimated:true];
    };
    [baseController.navigationBar addBottomShadow];
    [self.navigationController pushViewController:baseController animated:true];
}

- (void)loadingTest {
    [xLoading showInWindow:@"加载中..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [xLoading hide];
    });
}

- (void)toastTest {
    [xToast show:@"我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容" duration:2];
}


@end

