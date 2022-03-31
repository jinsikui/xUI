

#import "xAlert.h"
#import "xViewFactory.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#define XALERT_TAG 19860915
#define xalert_str_not_null(x) (x && [x isKindOfClass:[NSString class]] && ((NSString*)x).length > 0)

@implementation xAlert

static xAlertPresentFromControllerProvider _Nullable _presentFromControllerProvider;
+(void)setPresentFromControllerProvider:(xAlertPresentFromControllerProvider)presentFromControllerProvider{
    _presentFromControllerProvider = presentFromControllerProvider;
}

+(xAlertPresentFromControllerProvider)presentFromControllerProvider{
    return _presentFromControllerProvider;
}

+(void)_executeMain:(void(^)(void))task{
    if(NSThread.isMainThread){
        task();
    }
    else{
        dispatch_async(dispatch_get_main_queue(), task);
    }
}

static NSString *__appDisplayName = nil;
+(NSString*)_appDisplayName{
    if(__appDisplayName){
        return __appDisplayName;
    }
    __appDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (xalert_str_not_null(__appDisplayName)) {
      return __appDisplayName;
    }
    __appDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] ?: @"";
    return __appDisplayName;
}

+(void)showSystemAlertWithTitle:(NSString*)title
                        message:(NSString*)message
                    confirmText:(NSString*)confirmText
                     cancelText:(NSString*)cancelText
                       callback:(void(^)(UIAlertAction *action))callback{
    [xAlert _executeMain:^{
        xAlertPresentFromControllerProvider provider = xAlert.presentFromControllerProvider;
        if(!provider){
            return;
        }
        UIViewController *c = provider();
        if(!c){
            return;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if(xalert_str_not_null(confirmText)){
            [alert addAction:[UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:callback]];
        }
        if(xalert_str_not_null(cancelText)){
            [alert addAction:[UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:callback]];
        }
        [c presentViewController:alert animated:true completion:nil];
    }];
}

+(void)showSystemAlertWithMessage:(NSString*)message{
    [self showSystemAlertWithTitle:@"提示" message:message confirmText:@"确定" cancelText:nil callback:nil];
}

+(void)showPushPermissionAlert{
    [self showSystemAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"请在“设置—通知”选项中，允许%@开启推送", [self _appDisplayName]] confirmText:@"确定" cancelText:nil callback:nil];
}

+(void)showAlbumPermissionAlert{
    [self showSystemAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"请在“设置—隐私—相册”选项中，允许%@访问你的相册", [self _appDisplayName]] confirmText:@"确定" cancelText:nil callback:nil];
}

+(void)showCameraPermissionAlert{
    [self showSystemAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"请在“设置—隐私—照相”选项中，允许%@访问你的相机", [self _appDisplayName]] confirmText:@"确定" cancelText:nil callback:nil];
}

+(void)showMicrophonePermissionAlert{
    [self showSystemAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"请在“设置—隐私—麦克风”选项中，允许%@使用麦克风", [self _appDisplayName]] confirmText:@"确定" cancelText:nil callback:nil];
}

+(void)showItunesMediaPermissionAlert{
    [self showSystemAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"请在“设置—隐私—媒体与Apple Music”选项中，允许%@使用", [self
                                                                                                                    _appDisplayName]] confirmText:@"确定" cancelText:nil callback:nil];
}

@end
