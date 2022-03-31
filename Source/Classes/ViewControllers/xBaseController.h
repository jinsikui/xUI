

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "xNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface xBaseController : UIViewController
//可以在任何时候通过.navigationBar的属性改变导航栏的UI
@property(nonatomic,strong)    xNavigationBar     *navigationBar;

@end

NS_ASSUME_NONNULL_END
