

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xBannerCellContext: NSObject
@property(nonatomic,assign) NSInteger   dataIndex;
@property(nonatomic,strong) id  data;
@end

typedef void (^xBannerCellCallback)(UICollectionViewCell *cell, xBannerCellContext *context);

@interface xBanner : UIView

/// 是否支持循环（仅当dataList.count > 1时才起作用）
@property(nonatomic) BOOL isCycleScroll;
/// 仅当 isCycleScroll==YES 时才有意义，只有能够循环播放才能自动播放
@property(nonatomic) BOOL isAutoScroll;
/// 自动播放时间间隔
@property(nonatomic) int autoScrollIntervalSeconds;
/// 是否允许用户手动滑（不影响自动播放的滑动）
@property(nonatomic) BOOL scrollEnabled;
/// 是否支持cell重用（有些情况下比如cell中是webView，不希望重用，这时dataList中每一个data对应一个cell）
@property(nonatomic) BOOL reuseEnabled;
@property(nonatomic,nullable) NSArray *dataList;
/// 需要告知cell的尺寸，本控件只支持固定尺寸的cell，应当与banner的整体尺寸相同
@property(nonatomic) CGSize itemSize;
/// 水平 or 垂直 banner
@property(nonatomic) UICollectionViewScrollDirection scrollDirection;
@property(nonatomic) Class cellClass;
@property(nonatomic,nullable) xBannerCellCallback buildCellCallback;
@property(nonatomic,nullable) xBannerCellCallback selectCellCallback;
/// 稳定的停住后回调
@property(nonatomic,nullable) xBannerCellCallback stopToItemCallback;
/// 页码改变回调
@property(nonatomic,nullable) xBannerCellCallback indexChangeCallback;

-(void)scrollToDataIndex:(NSInteger)dataIndex animated:(BOOL)animated;

-(instancetype)initWithCellClass:(Class)cellClass itemSize:(CGSize)itemSize;

-(void)reloadData;


@end

NS_ASSUME_NONNULL_END
