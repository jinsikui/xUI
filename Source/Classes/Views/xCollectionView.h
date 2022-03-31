

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class xCollectionViewSection;

#pragma mark - 分页/下拉刷新

@class xCollectionViewSection;

@interface xCollectionViewPageResult : NSObject
///如果是下一页：返回数组中的数据会填充到最后一个section的dataList的尾部
///如果是刷新：返回的数组中数据会作为xCollectionView.dataList
@property(nonatomic,strong) NSArray *_Nullable pageDataList;
///如果是下一页：返回数组中的数据会作为section添加至dataSectionList尾部，不要忘记设置cellClass属性
///如果是刷新：返回数组中数据会作为xCollectionView.dataSectionList
@property(nonatomic,strong) NSArray<xCollectionViewSection*> *_Nullable pageSectionList;
@property(nonatomic,assign) BOOL isNoMoreData;
///仅对refreshCallback有效，可用于当第一页就知道没有更多数据时隐藏分页控件（下拉刷新后可以改变）
@property(nonatomic,assign) BOOL shouldHideFooter;
///如果设置为true，下拉刷新或加载下一页时，控件不会自动设置/刷新数据，留给业务自己设置数据并调reloadData
@property(nonatomic,assign) BOOL ignoreRetData;
@end

///会自动调用reloadData
typedef FBLPromise<xCollectionViewPageResult*>*_Nullable(^xCollectionViewRefreshCallback)(void);

///会自动调用reloadData
typedef FBLPromise<xCollectionViewPageResult*>*_Nullable(^xCollectionViewNextPageCallback)(void);

#pragma mark - 拖拽排序
/**
    整个拖拽过程以一个xCollectionViewMoveActionBegin开始，
    跟随多个xCollectionViewMoveActionSwap，
    以xCollectionViewMoveActionEnd结束
 */
typedef enum xCollectionViewMoveAction{
    xCollectionViewMoveActionBegin,
    xCollectionViewMoveActionSwap,
    xCollectionViewMoveActionEnd
} xCollectionViewMoveAction;

@interface xCollectionViewMoveData : NSObject
@property(nonatomic,assign) xCollectionViewMoveAction action;
///触发拖拽的cell的indexPath
@property(nonatomic,strong) NSIndexPath *startIndexPath;
///拖拽结束时的indexPath
@property(nonatomic,strong) NSIndexPath *_Nullable endIndexPath;
///当action==xCollectionViewMovementActionSwap时，swapFrom，swapTo都不为空，否则为空
@property(nonatomic,strong) NSIndexPath *_Nullable swapFrom;
@property(nonatomic,strong) NSIndexPath *_Nullable swapTo;
///按拖拽后新的顺序返回
@property(nonatomic,strong) NSArray *sortedDataList;
@property(nonatomic,strong) NSArray<xCollectionViewSection*> *sortedSectionDataList;
@end

typedef void(^xCollectionViewMoveCallback)(xCollectionViewMoveData*_Nonnull);

#pragma mark - xCollectionView

@interface xCollectionViewSection : NSObject
///默认为UICollectionViewCell
@property(nonatomic,strong) Class cellClass;
@property(nonatomic,strong) id  sectionData;
@property(nonatomic,strong) NSArray<id> *dataList;
@end

@interface xCollectionViewCellContext : NSObject
@property(nonatomic,strong) id data;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) xCollectionViewSection *section;
@end

@interface xCollectionView : UIView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

#pragma mark - 拖拽排序

///一旦设置，即开启长按拖拽排序，移动过程中dataSectionList(dataList)中的顺序也会随时改变
@property(nonatomic,copy) xCollectionViewMoveCallback _Nullable moveCallback;
///拖拽排序中不参与拖拽的项目（必须是dataSectionList(dataList)中的对象）
@property(nonatomic,strong) NSArray *_Nullable moveDisableItems;
///暴露给外界的接口，sectionDataList(dataList)会跟随改变，可用来回退
-(void)moveItemFrom:(NSIndexPath*)from to:(NSIndexPath*)to;

#pragma mark - 下拉刷新

///一旦设置，即开启下拉刷新，返回结果后会自动更新数据并reloadData
@property(nonatomic,copy) xCollectionViewRefreshCallback _Nullable refreshCallback;

///分页刷新组件类型，必须设置为MJRefreshHeader的子类否则设置无效，默认为+defaultRefreshHeaderClass
@property(nonatomic) Class refreshHeaderClass;

///默认为MJRefreshNormalHeader
@property(nonatomic,class) Class defaultRefreshHeaderClass;

//可以通过代码触发refresh
-(FBLPromise<xCollectionViewPageResult*>*)refresh;

#pragma mark - 分页

///一旦设置，即开启分页
@property(nonatomic,copy) xCollectionViewNextPageCallback _Nullable nextPageCallback;

///分页刷新组件类型，必须设置为MJRefreshFooter的子类否则设置无效，默认为+defaultRefreshFooterClass
@property(nonatomic) Class refreshFooterClass;

///默认为MJRefreshAutoNormalFooter
@property(nonatomic,class) Class defaultRefreshFooterClass;

///下拉刷新或加载下一页后通过isNoMoreData属性控制是否有更多数据，不需要显示调用
-(void)setNoMoreData;

///下拉刷新或加载下一页后通过isNoMoreData属性控制是否有更多数据，不需要显示调用
-(void)clearNoMoreData;

#pragma mark - Utils

///一旦设置 >0 的值，控件会自动处理footer的NoMoreData以及隐藏逻辑：
///如果refreshCallback返回的pageDataList != nil && pageDataList.count < pageSize，自动设置noMoreData=true，shouldHideFooter=true
///如果nextPageCallback返回的pageDataList != nil && pageDataList.count < pageSize，自动设置noMoreData=true
@property(nonatomic,assign) NSInteger pageSize;

///一般不需要直接使用，埋点时需要获取
@property(nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic) UICollectionViewScrollDirection scrollDirection;

@property(nonatomic) BOOL isScrollEnabled;

@property(nonatomic) BOOL isScrollsToTop;

@property(nonatomic) BOOL showsVerticalScrollIndicator;

@property(nonatomic) BOOL alwaysBounceVertical;

@property(nonatomic) BOOL alwaysBounceHorizontal;

@property(nonatomic) BOOL bounces;

@property(nonatomic,copy)void (^_Nullable scrollEndCallback)(CGPoint);

@property(nonatomic,copy)void (^_Nullable didScrollCallback)(UIScrollView*);

-(void)scrollToItemAt:(NSIndexPath*)indexPath position:(UICollectionViewScrollPosition)position animated:(BOOL)animated;

-(void)scrollToTopAnimated:(BOOL)animated;

-(void)scrollToBottomAnimated:(BOOL)animated;

-(void)scrollTo:(CGPoint)offset animated:(BOOL)animated;

///新方法，删除cell，同步删除data
-(void)deleteItemAtIndexPath:(NSIndexPath*)indexPath;

///旧方法，只删除cell，未同步删除data
-(void)deleteAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;

-(UICollectionViewCell *_Nullable)cellWithIndexPath:(NSIndexPath *)path;

@property(nonatomic,readonly)NSInteger numberOfSections;

-(NSInteger)numberOfItemsInSection:(NSInteger)section;

-(void)reloadData;

#pragma mark - size & margin

@property(nonatomic) CGSize itemSize;

@property(nonatomic) CGFloat lineSpace;

@property(nonatomic) CGFloat interitemSpace;

@property(nonatomic) CGSize headerSize;

@property(nonatomic) CGSize footerSize;

///整个GridView的contentInset
@property(nonatomic) UIEdgeInsets contentInset;

@property(nonatomic) UIEdgeInsets sectionInset;

@property(nonatomic,copy)CGSize(^_Nullable itemSizeCallback)(xCollectionViewCellContext *context);

@property(nonatomic,copy)CGFloat(^_Nullable lineSpaceCallback)(xCollectionViewSection* sectionData, NSInteger sectionIndex);

@property(nonatomic,copy)CGFloat(^_Nullable interitemSpaceCallback)(xCollectionViewSection* sectionData, NSInteger sectionIndex);

@property(nonatomic,copy)CGSize(^_Nullable headerSizeCallback)(xCollectionViewSection* sectionData, NSInteger sectionIndex);

@property(nonatomic,copy)CGSize(^_Nullable footerSizeCallback)(xCollectionViewSection* sectionData, NSInteger sectionIndex);

@property(nonatomic,copy)UIEdgeInsets(^_Nullable sectionInsetCallback)(xCollectionViewSection* sectionData, NSInteger sectionIndex);

#pragma mark - build & select

@property(nonatomic,copy)void (^_Nullable buildCellCallback)(UICollectionViewCell* cell, xCollectionViewCellContext *context);

/**
 触发时传入的view不会为空，如果某个section不需要设置header就返回nil，否则构造后返回传入的那个view
 */
@property(nonatomic,copy) UICollectionReusableView *_Nullable(^_Nullable buildHeaderCallback)(UICollectionReusableView* view, NSInteger sectionIndex, xCollectionViewSection *section);

/**
 触发时传入的view不会为空，如果某个section不需要设置footer就返回nil，否则构造后返回传入的那个view
*/
@property(nonatomic,copy) UICollectionReusableView *_Nullable(^_Nullable buildFooterCallback)(UICollectionReusableView* view, NSInteger sectionIndex, xCollectionViewSection *section);

@property(nonatomic,copy)void (^_Nullable selectCellCallback)(UICollectionViewCell* cell, xCollectionViewCellContext *context);

/**
 注册一批cellClass，后续每个section可以指定不同的cellClass，但是必须在init方法里面把所有可能的cellClass先行传入，否则dequeue没有注册的cell会crash
 UICollectionViewCell不需要传入会自动添加
 */
-(instancetype)initWithCellClasses:(NSArray<Class>*_Nullable)cellClasses
                       isLeftAlign:(BOOL)isLeftAlign;

-(instancetype)initWithCellClasses:(NSArray<Class>*_Nullable)cellClasses;

-(instancetype)initWithCellClass:(Class)cellClass;

-(instancetype)initWithCollectionViewCell;

/**
 如果不设置dataSectionList，设置dataList会自动生成只有一个section的dataSectionList，并将dataList填入section-0中
 如果dataSectionList已经设置，会替换section-0中的数据，总之dataList恒等于dataSectionList中section-0中的数据
 */
@property(nonatomic,strong)NSArray *_Nullable dataList;
@property(nonatomic,strong)NSArray<xCollectionViewSection*> *_Nullable dataSectionList;

@end

NS_ASSUME_NONNULL_END
