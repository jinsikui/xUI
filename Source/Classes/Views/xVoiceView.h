

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xVoiceView : UIView

-(instancetype)initWithBoxSize:(CGSize)boxSize;

-(instancetype)initWithBoxSize:(CGSize)boxSize color:(UIColor*)color;

-(void)startAnimation;

-(void)pauseAnimation;

-(void)resumeAnimation;

-(void)reset;

@end

NS_ASSUME_NONNULL_END
