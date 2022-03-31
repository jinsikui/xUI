

#import "xBaseController.h"
#import "View+MASAdditions.h"
#import "xUIUtil.h"

@implementation xBaseController

-(xNavigationBar*)navigationBar{
    if(!_navigationBar){
        _navigationBar = [xNavigationBar new];
    }
    return _navigationBar;
}

-(void)setTitle:(NSString *)title{
    self.navigationBar.title = title;
}

-(NSString*)title{
    return self.navigationBar.title;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [xUIUtil colorFromRGBA:0xFFFFFF alpha:1];

    [self.view addSubview:self.navigationBar];
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(xUIUtil.statusBarHeight + xUIUtil.navBarHeight);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏系统导航栏
    self.navigationController.navigationBar.hidden = true;
    //默认状态栏文字颜色黑色
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //默认隐藏tabBar
    self.navigationController.tabBarController.tabBar.hidden = true;
}

@end
