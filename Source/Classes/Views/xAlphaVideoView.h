

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "xHitlessView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^xAlphaVideoInfoCallback)(UIView *view, CGSize videoSize, double duration);
typedef void(^xAlphaVideoCompletionCallback)(UIView *view, NSError *_Nullable error);

/// 目前只支持alpha在视频的左边
@interface xAlphaVideoView: xHitlessView
/// url可以是网络url也可以是本地文件url
-(void)playUrl:(NSURL*)url
  infoCallback:(xAlphaVideoInfoCallback _Nullable)infoCallback
    completion:(xAlphaVideoCompletionCallback _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
