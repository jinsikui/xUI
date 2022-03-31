

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class xTableViewSection;

#pragma mark - 分页/下拉刷新

@interface xTableViewPageResult : NSObject
///如果是下一页：返回数组中的数据会填充到最后一个section的dataList的尾部
///如果是刷新：返回的数组中数据会作为xTableView.dataList
@property(nonatomic,strong) NSArray *_Nullable pageDataList;
///如果是下一页：返回数组中的数据会作为section添加至dataSectionList尾部，不要忘记设置cellClass属性
///如果是刷新：返回数组中数据会作为xTableView.dataSectionList
@property(nonatomic,strong) NSArray<xTableViewSection*> *_Nullable pageSectionList;
@property(nonatomic,assign) BOOL isNoMoreData;
///仅对refreshCallback有效，可用于当第一页就知道没有更多数据时隐藏分页控件（下拉刷新后可以改变）
@property(nonatomic,assign) BOOL shouldHideFooter;
@end

///会自动调用reloadData
typedef FBLPromise<xTableViewPageResult*>*_Nullable(^xTableViewRefreshCallback)(void);

///会自动调用reloadData
typedef FBLPromise<xTableViewPageResult*>*_Nullable(^xTableViewNextPageCallback)(void);

#pragma mark - 拖拽排序
/**
    整个拖拽过程以一个xTableViewMoveActionBegin开始，
    跟随多个xTableViewMoveActionSwap，
    以xTableViewMoveActionEnd结束
 */
typedef enum xTableViewMoveAction{
    xTableViewMoveActionBegin,
    xTableViewMoveActionSwap,
    xTableViewMoveActionEnd
} xTableViewMoveAction;

@interface xTableViewMoveData : NSObject
@property(nonatomic,assign) xTableViewMoveAction action;
///触发拖拽的cell的indexPath
@property(nonatomic,strong) NSIndexPath *startIndexPath;
///拖拽结束时的indexPath
@property(nonatomic,strong) NSIndexPath *_Nullable endIndexPath;
///当action==xTableViewMovementActionSwap时，swapFrom，swapTo都不为空，否则为空
@property(nonatomic,strong) NSIndexPath *_Nullable swapFrom;
@property(nonatomic,strong) NSIndexPath *_Nullable swapTo;
///按拖拽后新的顺序返回
@property(nonatomic,strong) NSArray *sortedDataList;
@property(nonatomic,strong) NSArray<xTableViewSection*> *sortedSectionDataList;
@end

typedef void(^xTableViewMoveCallback)(xTableViewMoveData*_Nonnull);

#pragma mark - xTableView

@interface xTableViewSection : NSObject
///默认为UITableViewCell
@property(nonatomic,strong) Class cellClass;
@property(nonatomic,strong) id  sectionData;
@property(nonatomic,strong) NSArray<id> *dataList;
@end

@interface xTableViewCellContext : NSObject
@property(nonatomic,strong) id data;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) xTableViewSection *section;
@end

@interface xTableView : UIView <UITableViewDelegate, UITableViewDataSource>

#pragma mark - 拖拽排序

///一旦设置，即开启长按拖拽排序，移动过程中dataSectionList(dataList)中的顺序也会随时改变
@property(nonatomic,copy) xTableViewMoveCallback _Nullable moveCallback;
///拖拽排序中不参与拖拽的项目（必须是dataSectionList(dataList)中的对象）
@property(nonatomic,strong) NSArray *_Nullable moveDisableItems;
///暴露给外界的接口，sectionDataList(dataList)会跟随改变，可用来回退
-(void)moveRowFrom:(NSIndexPath*)from to:(NSIndexPath*)to;

#pragma mark - 下拉刷新

///一旦设置，即开启下拉刷新，返回结果后会自动更新数据并reloadData
@property(nonatomic,copy) xTableViewRefreshCallback _Nullable refreshCallback;

///分页刷新组件类型，必须设置为MJRefreshHeader的子类否则设置无效，默认为+defaultRefreshHeaderClass
@property(nonatomic) Class refreshHeaderClass;

///默认为MJRefreshNormalHeader
@property(nonatomic,class) Class defaultRefreshHeaderClass;

///可以通过代码触发refresh
-(FBLPromise<xTableViewPageResult*>*)refresh;

#pragma mark - 分页

///一旦设置，即开启分页，返回结果后会自动更新数据并reloadData
@property(nonatomic,copy) xTableViewNextPageCallback _Nullable nextPageCallback;

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
@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic) BOOL isScrollEnabled;

@property(nonatomic) BOOL isScrollsToTop;

@property(nonatomic) BOOL showsVerticalScrollIndicator;

@property(nonatomic) BOOL alwaysBounceVertical;

@property(nonatomic) BOOL bounces;

@property(nonatomic,copy)void (^_Nullable scrollEndCallback)(CGPoint);

@property(nonatomic,copy)void (^_Nullable didScrollCallback)(UIScrollView*);

-(void)scrollToRowAt:(NSIndexPath*)indexPath position:(UITableViewScrollPosition)position animated:(BOOL)animated;

-(void)scrollToTopAnimated:(BOOL)animated;

-(void)scrollToBottomAnimated:(BOOL)animated;

-(void)scrollTo:(CGPoint)offset animated:(BOOL)animated;

///新方法，删除cell，同步删除data
-(void)deleteRowAtIndexPath:(NSIndexPath*)indexPath;

///旧方法，只删除cell，未同步删除data
-(void)deleteAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths;

-(UITableViewCell *_Nullable)cellWithIndexPath:(NSIndexPath *)path;

@property(nonatomic,readonly)NSInteger numberOfSections;

-(NSInteger)numberOfRowsInSection:(NSInteger)section;

-(void)reloadData;

#pragma mark - size & margin

@property(nonatomic) CGFloat rowHeight;

@property(nonatomic) CGFloat sectionHeaderHeight;

@property(nonatomic) CGFloat sectionFooterHeight;

@property(nonatomic,copy)CGFloat(^_Nullable rowHeightCallback)(xTableViewCellContext *context);

@property(nonatomic,copy)CGFloat(^_Nullable sectionHeaderHeightCallback)(xTableViewSection* sectionData, NSInteger sectionIndex);

@property(nonatomic,copy)CGFloat(^_Nullable sectionFooterHeightCallback)(xTableViewSection* sectionData, NSInteger sectionIndex);

#pragma mark - 左滑操作

@property(nonatomic,copy) BOOL(^_Nullable canEditRowCallback)(xTableViewCellContext *context);

@property(nonatomic,copy) NSArray<UITableViewRowAction*>*_Nullable(^_Nullable editActionsForRowCallback)(xTableViewCellContext *context);

#pragma mark - build & select

@property(nonatomic,copy)void (^_Nullable buildCellCallback)(UITableViewCell* cell, xTableViewCellContext *context);

@property(nonatomic,strong) UIView *_Nullable tableHeaderView;

@property(nonatomic,strong) UIView *_Nullable tableFooterView;
/**
 触发时传入的view不会为空，如果某个section不需要设置header就返回nil，否则构造后返回传入的那个view
 */
@property(nonatomic,copy) UIView *_Nullable(^_Nullable buildHeaderCallback)(UITableViewHeaderFooterView* view, NSInteger sectionIndex, xTableViewSection *section);

/**
 触发时传入的view不会为空，如果某个section不需要设置footer就返回nil，否则构造后返回传入的那个view
*/
@property(nonatomic,copy) UIView *_Nullable(^_Nullable buildFooterCallback)(UITableViewHeaderFooterView* view, NSInteger sectionIndex, xTableViewSection *section);

@property(nonatomic,copy)void (^_Nullable selectCellCallback)(UITableViewCell* cell, xTableViewCellContext *context);

/**
 注册一批cellClass，后续每个section可以指定不同的cellClass，但是必须在init方法里面把所有可能的cellClass先行传入，否则dequeue没有注册的cell会crash
 UITableViewCell不需要传入会自动添加
 */
-(instancetype)initWithCellClasses:(NSArray<Class>*_Nullable)cellClasses;

-(instancetype)initWithCellClass:(Class)cellClass;

-(instancetype)initWithTableViewCell;

/**
 如果不设置dataSectionList，设置dataList会自动生成只有一个section的dataSectionList，并将dataList填入section-0中
 如果dataSectionList已经设置，会替换section-0中的数据，总之dataList恒等于dataSectionList中section-0中的数据
 */
@property(nonatomic,strong)NSArray *_Nullable dataList;
@property(nonatomic,strong)NSArray<xTableViewSection*> *_Nullable dataSectionList;

@end

NS_ASSUME_NONNULL_END
