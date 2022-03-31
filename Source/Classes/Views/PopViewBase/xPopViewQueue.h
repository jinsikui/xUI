

#import <Foundation/Foundation.h>
#import "xBasePopView.h"

NS_ASSUME_NONNULL_BEGIN

@interface xPopViewQueue : NSObject

@property(nonatomic,weak) UIView     *view;
@property(nonatomic) NSMutableArray<xBasePopView*>   *popViews;
@property(nonatomic) xBasePopView                    *_Nullable curPopView;

-(instancetype)initWithView:(UIView*)view;

-(void)inqueuePopView:(xBasePopView*)popView;

-(void)tryDequeueAndShowPopView;

@end

NS_ASSUME_NONNULL_END
