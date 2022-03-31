

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xCoolPager : UIView<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic,assign)     int             pageCount;
@property(nonatomic,assign)     CGFloat         dotWidth;
@property(nonatomic,assign)     CGFloat         dotSpace;
@property(nonatomic,assign)     int             visibleDot;
@property(nonatomic,assign)     CGFloat         minScale;//maxScale = 1
@property(nonatomic,assign)     CGFloat         minAlpha;
@property(nonatomic,assign)     CGFloat         maxAlpha;
@property(nonatomic,assign)     int             pageIndex;
@property(nonatomic,assign,readonly) CGFloat    pagerWidth;
-(instancetype)initWithPageCount:(int)pageCount;
-(void)setPageIndex:(int)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
