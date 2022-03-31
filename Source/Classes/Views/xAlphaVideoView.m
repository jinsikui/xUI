

#import "xAlphaVideoView.h"

static NSString *xAlphaVideoErrorDomain = @"xAlphaVideoErrorDomain";

@interface xAlphaFrameFilter: CIFilter
@property(nonatomic, strong) CIImage *inputImage;
@property(nonatomic, strong) CIImage *maskImage;
@end

@implementation xAlphaFrameFilter

+(CIColorKernel*)kernel{
    static CIColorKernel *_kernel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kernel = [CIColorKernel kernelWithString:@"kernel vec4 alphaFrame(__sample s, __sample m) { return vec4(s.rgb, m.r); }"];
    });
    return _kernel;
}

-(CIImage*)outputImage{
    CIColorKernel *kernel = [xAlphaFrameFilter kernel];
    if(!self.inputImage || !self.maskImage){
        return nil;
    }
    return [kernel applyWithExtent:self.inputImage.extent arguments:@[self.inputImage, self.maskImage]];
}

@end

@interface xAlphaVideoView()
@property(nonatomic,strong) NSURL *videoURL;
@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong, readonly) AVPlayer *player;
@property(nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, assign) CMTime pauseTime;
@property(nonatomic, copy) xAlphaVideoInfoCallback infoCallback;
@property(nonatomic, copy) xAlphaVideoCompletionCallback completionCallback;
@end

//引用路径：playerLayer -> player -> playerItem -> asset
@implementation xAlphaVideoView

-(void)dealloc{
    self.playerItem = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

//override the UIView's layerClass property
+(Class)layerClass{
    return AVPlayerLayer.class;
}

-(AVPlayerLayer*)playerLayer{
    return (AVPlayerLayer*)self.layer;
}

-(AVPlayer*)player{
    return self.playerLayer.player;
}

-(void)playUrl:(NSURL*)url
  infoCallback:(xAlphaVideoInfoCallback _Nullable)infoCallback
    completion:(xAlphaVideoCompletionCallback)completion{
    self.videoURL = url;
    self.infoCallback = infoCallback;
    self.completionCallback = completion;
    self.playerLayer.pixelBufferAttributes = @{
        (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)
    };
    self.playerLayer.player = [AVPlayer new];
    self.asset = [AVURLAsset assetWithURL:_videoURL];
    __weak xAlphaVideoView *weak = self;
    [self.asset loadValuesAsynchronouslyForKeys:@[@"duration",@"tracks"] completionHandler:^{
        __strong xAlphaVideoView *s = weak;
        if(s){
            [s.class _executeMain:^{
                [s setupPlayerItemAndPlay];
            }];
        }
    }];
}

-(void)setupPlayerItemAndPlay{
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    NSArray<AVAssetTrack *> *tracks = [self.playerItem.asset tracksWithMediaType:AVMediaTypeVideo];
    if(tracks.count <= 0){
        [self callbackWithErrorMsg:@"未找到视频"];
        return;
    }
    
    CGSize videoSize = CGSizeMake(tracks[0].naturalSize.width * 0.5, tracks[0].naturalSize.height);
    if(videoSize.width <= 0 || videoSize.height <= 0){
        [self callbackWithErrorMsg:@"未找到视频"];
        return;
    }
    double duration = CMTimeGetSeconds(tracks[0].timeRange.duration);
    xAlphaVideoInfoCallback callback = self.infoCallback;
    if(callback){
        callback(self, videoSize, duration);
    }
    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoCompositionWithAsset:self.playerItem.asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        CGRect sourceRect = CGRectMake(videoSize.width, 0, videoSize.width, videoSize.height);
        CGRect alphaRect = CGRectMake(0, 0, videoSize.width, videoSize.height);
        
        xAlphaFrameFilter *filter = [xAlphaFrameFilter new];
        filter.maskImage = [request.sourceImage imageByCroppingToRect:alphaRect];
        filter.inputImage = [[request.sourceImage imageByCroppingToRect:sourceRect] imageByApplyingTransform:CGAffineTransformMakeTranslation(-videoSize.width, 0)];
        return [request finishWithImage:filter.outputImage context:nil];
    }];
    
    composition.renderSize = videoSize;
    self.playerItem.videoComposition = composition;
    self.playerItem.seekingWaitsForVideoCompositionRendering = true;
    [self.player seekToTime:kCMTimeZero];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self play];
}

-(void)play{
    [self.player play];
}

- (void)appWillResignActive:(NSNotification*)notification{
    [self.player pause];
    self.pauseTime = self.player.currentTime;
}

- (void)appBecomeActive:(NSNotification*)notification{
    @try{
        [self.player seekToTime:self.pauseTime];
    }
    @catch(NSException *ex){}
    [self.player play];
}

-(void)playToEnd{
    xAlphaVideoCompletionCallback callback = self.completionCallback;
    if(callback){
        callback(self, nil);
    }
}

-(void)callbackWithErrorMsg:(NSString*)msg{
    xAlphaVideoCompletionCallback callback = self.completionCallback;
    if(callback){
        NSError *error = [NSError errorWithDomain:xAlphaVideoErrorDomain code:-1 userInfo:@{
            NSLocalizedDescriptionKey: msg
        }];
        callback(self, error);
    }
}

+(void)_executeMain:(void(^)(void))task{
    if(NSThread.isMainThread){
        task();
    }
    else{
        dispatch_async(dispatch_get_main_queue(), task);
    }
}

@end
