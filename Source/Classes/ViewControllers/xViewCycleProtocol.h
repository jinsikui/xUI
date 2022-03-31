

#import <Foundation/Foundation.h>

@protocol xViewCycleProtocol <NSObject>



@optional

//如果依赖appear相关方法来初始化，但某些情况下appear相关方法可能不会被调用（比如外部controller appear之后才创建本协议的对象），这时应该在initxx方法中完成初始化工作

-(void)viewWillAppear:(BOOL)animated isMovingToParentViewController:(BOOL)isMovingToParentViewController;

-(void)viewDidAppear:(BOOL)animated isMovingToParentViewController:(BOOL)isMovingToParentViewController;

-(void)viewWillDisappear:(BOOL)animated isMovingFromParentViewController:(BOOL)isMovingFromParentViewController;

-(void)viewDidDisappear:(BOOL)animated isMovingFromParentViewController:(BOOL)isMovingFromParentViewController;

//如果依赖于disappear相关事件来释放资源比如解除循环引用，但是某些情况下disappear相关事件可能不会被调用（比如外部不再引用自己），应该通过dealloc来释放资源，但如果由于循环引用导致dealloc不会被调用，可以通过主动调用dispose方法完成释放工作
-(void)dispose;

@end
