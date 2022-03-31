

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class xWebView, xScrollView;

typedef id _Nullable(^xWebViewNativeHandler)(id _Nullable);
typedef void(^xWebViewCallJSResultHandler)(id _Nullable);
typedef void(^xWebViewTitleCallback)(NSString* _Nullable);
typedef void(^xWebViewRefreshCallback)(xWebView *_Nonnull);
typedef BOOL(^xWebViewBeforeNavigationHandler)(NSString*);

@protocol xWebViewAdditionViewsDelegate <NSObject>

@optional
-(void)showLoading:(xWebView*)webView;

-(void)hideLoading:(xWebView*)webView;

-(void)showFailView:(xWebView*)webView error:(NSError* _Nullable)error;

-(void)hideFailView:(xWebView*)webView;

-(void)showFailToast:(NSError* _Nullable)error;

@end


/// 本类必须使用frame布局，需要在build之前设置好frame，因为内部的组件会使用本类的view.bounds
@interface xWebView : UIView<WKNavigationDelegate, WKUIDelegate>
@property(nonatomic)    BOOL        couldRefresh;
/// 下拉刷新组件类型，必须设置为MJRefreshHeader的子类否则设置无效，默认为MJRefreshNormalHeader
@property(nonatomic)    Class       refreshHeaderClass;
@property(nonatomic,weak) id<xWebViewAdditionViewsDelegate> _Nullable additionViewsDelegate;
@property(nonatomic)    BOOL        alwaysBounceVertical;
@property(nonatomic)    NSString    *userAgent;
@property(nonatomic)   NSString     *_Nullable url;
@property(nonatomic,readonly)  NSString    *_Nullable currentUrl;
/// 本类可以用于加载html字符串
@property(nonatomic)   NSString    *_Nullable html;
/// 当检测到webView.title改变后触发
@property(nonatomic,copy) xWebViewTitleCallback    _Nullable titleCallback;
/// 一旦设置，将代替默认的下拉刷新逻辑，可以在回调中调refresh执行默认逻辑
@property(nonatomic,copy) xWebViewRefreshCallback  _Nullable refreshCallback;
/// h5跳转前调用，返回false会阻止h5跳转，可用来和router集成
@property(nonatomic,copy) xWebViewBeforeNavigationHandler  _Nullable beforeNavHandler;

@property(nonatomic,readonly)    WKWebView   *webView;
@property(nonatomic,readonly)    xScrollView *scrollView; //包裹webView

-(instancetype)build;
-(void)loadUrl:(NSString*)url;
-(void)refresh;
-(void)loadHtmlString:(NSString*)html;
-(void)endRefreshing;
-(void)registNativeCallbackName:(NSString*)name handler:(xWebViewNativeHandler)handler;
-(void)callJS:(NSString*)funcName params:(id _Nullable)params resultHandler:(xWebViewCallJSResultHandler _Nullable)resultHandler;
/// 调用之前JS传来的callback回调
-(void)callNativeHandlerJSCallback:(NSString*)handlerName retValue:(id _Nullable)retValue;
@end

NS_ASSUME_NONNULL_END
