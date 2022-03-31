

#import "xWebView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<MJRefresh/MJRefresh.h>)
#import <MJRefresh/MJRefresh.h>
#else
#import "MJRefresh.h"
#endif
#import "xScrollView.h"

#define xwebview_str_not_null(x) (x && [x isKindOfClass:[NSString class]] && ((NSString*)x).length > 0)


@interface xWebViewHandlerContext : NSObject
@property(nonatomic,copy)   NSString                *handlerName;
@property(nonatomic,copy)   xWebViewNativeHandler   nativeHandler;
@property(nonatomic,copy,nullable)  NSString        *jsCallbackName;
@end

@interface xWebViewJSReceiver : NSObject<WKScriptMessageHandler>
@property(nonatomic,weak)   xWebView    *webView;
-(instancetype)initWithWebView:(xWebView*)webView;
@end

@interface xWebView() <UIScrollViewDelegate>
{
    Class _refreshHeaderClass;
}
@property(nonatomic,strong) NSMutableDictionary<NSString*, xWebViewHandlerContext*> *handlerDic;
@property(nonatomic,strong) xWebViewJSReceiver  *jsReceiver;
@property(nonatomic,strong) WKUserContentController *userContentController;
@property(nonatomic,assign) BOOL isFirstLoading;
-(void)handleJSCall:(WKScriptMessage*)message;
@end


@implementation xWebView

-(Class)refreshHeaderClass{
    return _refreshHeaderClass;
}

-(void)setRefreshHeaderClass:(Class)refreshHeaderClass{
    if([refreshHeaderClass isSubclassOfClass:MJRefreshHeader.class]){
        _refreshHeaderClass = refreshHeaderClass;
    }
}

-(BOOL)alwaysBounceVertical{
    return self.webView.scrollView.alwaysBounceVertical;
}

-(void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical{
    self.webView.scrollView.alwaysBounceVertical = alwaysBounceVertical;
}

-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    NSLog(@"===== xWebView dealloc =====");
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _refreshHeaderClass = MJRefreshNormalHeader.class;
    }
    return self;
}

-(NSString*)currentUrl{
    return self.webView.URL.absoluteString;
}

-(instancetype)build{
    //
    xScrollView *scrollView = [xScrollView new];
    if (@available(iOS 11, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    scrollView.delegate = self;
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    _scrollView = scrollView;
    //
    self.userContentController = [WKUserContentController new];
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.userContentController = self.userContentController;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    if (@available(iOS 11, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    webView.scrollView.delegate = self;
    webView.customUserAgent = self.userAgent;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context: nil];
    webView.frame = self.bounds;
    webView.opaque = false;
    [scrollView addSubview:webView];
    _webView = webView;
    [self setCouldRefresh:self.couldRefresh];
    self.handlerDic = [NSMutableDictionary<NSString*, xWebViewHandlerContext*> new];
    self.jsReceiver = [[xWebViewJSReceiver alloc] initWithWebView:self];
    return self;
}

-(void)setFrame:(CGRect)frame{
    super.frame = frame;
    self.webView.frame = self.bounds;
}

#pragma mark - Addition Views

-(void)showLoading{
    if(self.additionViewsDelegate && [self.additionViewsDelegate respondsToSelector:@selector(showLoading:)]){
        [self.additionViewsDelegate showLoading:self];
    }
}

-(void)hideLoading{
    if(self.additionViewsDelegate && [self.additionViewsDelegate respondsToSelector:@selector(hideLoading:)]){
        [self.additionViewsDelegate hideLoading:self];
    }
}

-(void)showFailView:(NSError*)error{
    if(self.additionViewsDelegate && [self.additionViewsDelegate respondsToSelector:@selector(showFailView:error:)]){
        [self.additionViewsDelegate showFailView:self error:error];
    }
}

-(void)hideFailView{
    if(self.additionViewsDelegate && [self.additionViewsDelegate respondsToSelector:@selector(hideFailView:)]){
        [self.additionViewsDelegate hideFailView:self];
    }
}

-(void)showFailToast:(NSError* _Nullable)error{
    if(self.additionViewsDelegate && [self.additionViewsDelegate respondsToSelector:@selector(showFailToast:)]){
        [self.additionViewsDelegate showFailToast:error];
    }
}

-(void)hideAdditionViews{
    [self hideLoading];
    [self hideFailView];
}

#pragma mark - Operations

-(id)_jsonStrToObject:(NSString*)str{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self _jsonDataToObject:data];
}

-(id)_jsonDataToObject:(NSData*)data{
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers
                                             error:&error];
}

-(NSData*)_objectToJsonData:(id)object{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0
                                                         error:&error];
    return jsonData;
}

-(NSString*)_objectToJsonStr:(id)object{
    NSData *jsonData = [self _objectToJsonData:object];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void)loadUrl:(NSString *)url{
    self.url = url;
    self.isFirstLoading = true;
    [self _loadUrl:url];
}

- (void)_loadUrl:(NSString *)url {
    if(xwebview_str_not_null(url)){
        [self hideAdditionViews];
        if(self.isFirstLoading){
            [self showLoading];
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
    }
}

-(void)refresh{
    NSString *url = self.webView.URL.absoluteString;
    if(!url){
        url = self.url;
    }
    if (url) {
        //清除缓存后再加载
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        __weak typeof(self) weakSelf = self;
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            [weakSelf _loadUrl:url];
        }];
    }
}

-(void)loadHtmlString:(NSString *)html{
    self.html = html;
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)setCouldRefresh:(BOOL)couldRefresh {
    _couldRefresh = couldRefresh;
    if (couldRefresh) {
        if (!self.scrollView.mj_header) {
            __weak typeof(self) weak = self;
            self.scrollView.mj_header = [self.refreshHeaderClass headerWithRefreshingBlock:^{
                __strong xWebView *s = weak;
                if(s){
                    xWebViewRefreshCallback callback = s.refreshCallback;
                    if(callback){
                        callback(s);
                    }
                    else{
                        [s refresh];
                    }
                }
            }];
        }
    } else {
        [self.scrollView.mj_header endRefreshing];
        self.scrollView.mj_header = nil;
    }
}

-(void)endRefreshing{
    [self.scrollView.mj_header endRefreshing];
}

-(void)registNativeCallbackName:(NSString *)name handler:(xWebViewNativeHandler)handler{
    [self.userContentController addScriptMessageHandler:self.jsReceiver name:name];
    xWebViewHandlerContext *context = [xWebViewHandlerContext new];
    context.handlerName = name;
    context.nativeHandler = handler;
    context.jsCallbackName = nil;
    self.handlerDic[name] = context;
}

-(void)handleJSCall:(WKScriptMessage*)message {
    NSString *handlerName = message.name;
    id body = message.body;
    xWebViewHandlerContext *handlerContext = self.handlerDic[handlerName];
    if(handlerContext == nil){
        return;
    }
    //now handlerContext won't be nil
    if([body isKindOfClass:NSString.class]){
        body = [self _jsonStrToObject:body];
    }
    if([body isKindOfClass:NSDictionary.class]){
        NSDictionary *bodyDic = (NSDictionary*)body;
        NSString *callbackName = [bodyDic[@"callback"] stringValue];
        if(xwebview_str_not_null(callbackName)){
            handlerContext.jsCallbackName = callbackName;
        }
    }
    xWebViewNativeHandler nativeHandler = handlerContext.nativeHandler;
    id retValue = nil;
    if([body isKindOfClass:NSNull.class]){
        retValue = nativeHandler(nil);
    }
    else{
        retValue = nativeHandler(body);
    }
    if(retValue != nil && handlerContext.jsCallbackName != nil){
        [self callJS:handlerContext.jsCallbackName params: retValue resultHandler: nil];
    }
}

// 调用JS函数
-(void)callJS:(NSString*)funcName params:(id _Nullable)params resultHandler:(xWebViewCallJSResultHandler _Nullable)resultHandler{
    NSMutableString *paramStr = [NSMutableString new];
    if(params != nil){
        if([params isKindOfClass:NSString.class]){
            [paramStr appendFormat:@"\"%@\"", (NSString*)params];
        }
        else{
            [paramStr appendString:[self _objectToJsonStr:params]];
        }
    }
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)", funcName, paramStr] completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        if(resultHandler != nil){
            resultHandler(jsRet);
        }
    }];
}

// 调用之前JS传来的callback回调
-(void)callNativeHandlerJSCallback:(NSString*)handlerName retValue:(id _Nullable)retValue{
    xWebViewHandlerContext *handlerContext = self.handlerDic[handlerName];
    if(handlerContext == nil){
        return;
    }
    NSString *jsCallbackName = handlerContext.jsCallbackName;
    if(xwebview_str_not_null(jsCallbackName)){
        [self callJS:jsCallbackName params:retValue resultHandler:nil];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"estimatedProgress"]){
        if(self.webView.estimatedProgress > 0.5){
            //提前结束loading和refreshing
            [self hideLoading];
            [self endRefreshing];
        }
    }
    else if([keyPath isEqualToString:@"title"]){
        NSString *title = self.webView.title;
        if(xwebview_str_not_null(title)){
            xWebViewTitleCallback callback = self.titleCallback;
            if(callback){
                callback(title);
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"===== didScroll:%@, parentOffset:%f, childOffset:%f", (scrollView == self.scrollView ? @"parent":@"child"), self.scrollView.contentOffset.y, self.webView.scrollView.contentOffset.y);
    if(self.scrollView.contentOffset.y > 0){
        self.scrollView.contentOffset = CGPointZero;
    }
    if(self.webView.scrollView.contentOffset.y < 0){
        self.webView.scrollView.contentOffset = CGPointZero;
    }
    if(self.scrollView.contentOffset.y < 0 && self.webView.scrollView.contentOffset.y > 0){
        self.scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - WKWebView Delegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    BOOL allow = true;
    if(xwebview_str_not_null(url)){
        xWebViewBeforeNavigationHandler navHandler = self.beforeNavHandler;
        if(navHandler){
            allow = navHandler(url);
        }
    }
    WKNavigationActionPolicy policy = allow ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel;
    decisionHandler(policy);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self hideAdditionViews];
    [self endRefreshing];
    if(self.isFirstLoading){
        [self showFailView:error];
    }
    else{
        [self showFailToast:error];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [self hideAdditionViews];
    [self endRefreshing];
    self.isFirstLoading = false;
}

@end

@implementation xWebViewHandlerContext
@end

@implementation xWebViewJSReceiver

-(instancetype)initWithWebView:(xWebView*)webView{
    self = [super init];
    if(self){
        self.webView = webView;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    [self.webView handleJSCall:message];
}

@end


