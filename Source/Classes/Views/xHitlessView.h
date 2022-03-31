

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum xHitlessPolicy{
    xHitlessPolicyAllDescendants = 0,
    xHitlessPolicyOnlySelf = 1
} xHitlessPolicy;

@interface xHitlessView : UIView

@property(nonatomic,assign) xHitlessPolicy policy;

-(instancetype)initWithPolicy:(xHitlessPolicy)policy;

@end

NS_ASSUME_NONNULL_END
