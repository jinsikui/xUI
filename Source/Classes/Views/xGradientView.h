

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xGradientView : UIView
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic)         CGPoint  startPoint;
@property (nonatomic)         CGPoint  endPoint;
@end

NS_ASSUME_NONNULL_END
