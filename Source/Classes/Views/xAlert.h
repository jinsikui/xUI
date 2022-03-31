

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum xAlertAction{
    xAlertActionCancel = 0,
    xAlertActionConfirm = 1
} xAlertAction;

typedef void(^xAlertHandler)(xAlertAction);
typedef UIViewController *_Nullable (^xAlertPresentFromControllerProvider)(void);

@interface xAlert : UIView

@property(nonatomic,class,copy,nullable) xAlertPresentFromControllerProvider presentFromControllerProvider;


+(void)showSystemAlertWithTitle:(NSString* _Nullable)title
                        message:(NSString* _Nullable)message
                    confirmText:(NSString* _Nullable)confirmText
                     cancelText:(NSString* _Nullable)cancelText
                       callback:(void(^_Nullable)(UIAlertAction *action))callback;


+(void)showSystemAlertWithMessage:(NSString*)message;

+(void)showPushPermissionAlert;

+(void)showAlbumPermissionAlert;

+(void)showCameraPermissionAlert;

+(void)showMicrophonePermissionAlert;

+(void)showItunesMediaPermissionAlert;


@end

NS_ASSUME_NONNULL_END
