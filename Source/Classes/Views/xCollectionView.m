

#import "xCollectionView.h"
#import <objc/runtime.h>
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<MJRefresh/MJRefresh.h>)
#import <MJRefresh/MJRefresh.h>
#else
#import "MJRefresh.h"
#endif

#define xCollectionViewErrorDomain @"xCollectionViewError"

@implementation UICollectionViewCell (xCollectionView)

- (NSIndexPath*)x_indexPath{
    NSIndexPath *indexPath = objc_getAssociatedObject(self, _cmd);
    return indexPath;
}

- (void)setX_indexPath:(NSIndexPath *)x_indexPath{
    objc_setAssociatedObject(self, @selector(x_indexPath), x_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)x_data{
    id data = objc_getAssociatedObject(self, _cmd);
    return data;
}

- (void)setX_data:(id)x_data{
    objc_setAssociatedObject(self, @selector(x_data), x_data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout
@end

@implementation LeftAlignedCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    CGFloat leftMargin = self.sectionInset.left; //initalized to silence compiler, and actaully safer, but not planning to use.
    CGFloat maxY = -1.0f;
    //this loop assumes attributes are in IndexPath order
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if (attribute.frame.origin.y >= maxY) {
            leftMargin = self.sectionInset.left;
        }
        attribute.frame = CGRectMake(leftMargin, attribute.frame.origin.y, attribute.frame.size.width, attribute.frame.size.height);

        leftMargin += attribute.frame.size.width + self.minimumInteritemSpacing;
        maxY = MAX(CGRectGetMaxY(attribute.frame), maxY);
    }
    return attributes;
}

@end

@implementation xCollectionViewPageResult
@end

@implementation xCollectionViewMoveData
@end

@implementation xCollectionViewSection
-(instancetype)init{
    self = [super init];
    if(self){
        self.cellClass = UICollectionViewCell.class;
    }
    return self;
}
@end

@implementation xCollectionViewCellContext
@end

@interface xCollectionView()
//UICollectionView中触发拖拽的cell，开始拖拽后隐藏，结束拖拽后重新显示在新位置
@property(nonatomic,strong) UICollectionViewCell *movingStartCell;
//开始拖拽后为了UI显示而新创建的cell，跟随手指移动，仅仅为了UI显示，结束拖拽后隐藏
@property(nonatomic,strong) UICollectionViewCell *movingCell;
@property(nonatomic,strong) NSIndexPath *startDragingIndexPath;
@property(nonatomic,strong) NSIndexPath *dragingIndexPath;
@property(nonatomic,assign) BOOL isScrollEnableBeforeMove;

@property(nonatomic,strong) NSMutableArray<Class> *cellClasses;
@property(nonatomic,strong) UICollectionViewFlowLayout *layout;
@property(nonatomic,assign) BOOL isLeftAlign;

+(RACSignal*)_rejectedErrorSignal;

@end

@implementation xCollectionView

+(RACSignal*)_rejectedErrorSignal{
    return [RACSignal error:[NSError errorWithDomain:xCollectionViewErrorDomain code:-1 userInfo:nil]];
}

#pragma mark - 下拉刷新

static Class _defaultRefreshHeaderClass = nil;
+(void)setDefaultRefreshHeaderClass:(Class)defaultRefreshHeaderClass{
    if([defaultRefreshHeaderClass isSubclassOfClass:MJRefreshHeader.class]){
        _defaultRefreshHeaderClass = defaultRefreshHeaderClass;
    }
}

+(Class)defaultRefreshHeaderClass{
    if(_defaultRefreshHeaderClass == nil){
        _defaultRefreshHeaderClass = MJRefreshNormalHeader.class;
    }
    return _defaultRefreshHeaderClass;
}

-(void)setRefreshHeaderClass:(Class)refreshHeaderClass{
    if([refreshHeaderClass isSubclassOfClass:MJRefreshHeader.class]){
        _refreshHeaderClass = refreshHeaderClass;
    }
}

-(void)setRefreshCallback:(xCollectionViewRefreshCallback)refreshCallback{
    _refreshCallback = refreshCallback;
    if(refreshCallback){
        self.isScrollEnabled = true;
        __weak typeof(self) weak = self;
        _collectionView.mj_header = [_refreshHeaderClass headerWithRefreshingBlock:^{
            [weak refresh];
        }];
    }
    else{
        _collectionView.mj_header = nil;
    }
}

-(RACDisposable*)refresh{
    xCollectionViewRefreshCallback refreshCallback = self.refreshCallback;
    if(!refreshCallback){
        return [[xCollectionView _rejectedErrorSignal] subscribeNext:^(id  _Nullable x) {
            // do nothing, just let the stream execute
        }];
    }
    RACSignal<xCollectionViewPageResult*> *signal = refreshCallback();
    if(signal){
        __weak typeof(self) weak = self;
        signal = [signal deliverOn:RACScheduler.mainThreadScheduler];
        signal = [signal doNext:^(xCollectionViewPageResult * _Nullable result) {
            __strong xCollectionView *s = weak;
            if(!result.ignoreRetData){
                if(result.pageSectionList){
                    s.dataSectionList = result.pageSectionList;
                }
                else if(result.pageDataList){
                    if(s.pageSize > 0){
                        if(result.pageDataList.count < s.pageSize){
                            result.isNoMoreData = true;
                            result.shouldHideFooter = true;
                        }
                    }
                    NSMutableArray *sectionList = [NSMutableArray new];
                    xCollectionViewSection *section = [xCollectionViewSection new];
                    section.cellClass = (s.cellClasses.count == 1)?s.cellClasses[0]:UICollectionViewCell.class;
                    section.dataList = result.pageDataList;
                    [sectionList addObject:section];
                    s.dataSectionList = sectionList;
                }
                else{
                    s.dataSectionList = nil;
                }
                [s reloadData];
            }
            if (result.isNoMoreData) {
                [s.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            else{
                [s.collectionView.mj_footer resetNoMoreData];
            }
            s.collectionView.mj_footer.hidden = result.shouldHideFooter;
            [s.collectionView.mj_header endRefreshing];
        }];
        signal = [signal doError:^(NSError * _Nonnull error) {
            [weak.collectionView.mj_header endRefreshing];
        }];
        return [signal subscribeNext:^(xCollectionViewPageResult * _Nullable x) {
            // do nothing, just let the stream execute
        }];
    }
    else{
        return [[xCollectionView _rejectedErrorSignal] subscribeNext:^(id  _Nullable x) {
            // do nothing, just let the stream execute
        }];
    }
}


#pragma mark - 分页

static Class _defaultRefreshFooterClass = nil;
+(void)setDefaultRefreshFooterClass:(Class)defaultRefreshFooterClass{
    if([defaultRefreshFooterClass isSubclassOfClass:MJRefreshFooter.class]){
        _defaultRefreshFooterClass = defaultRefreshFooterClass;
    }
}

+(Class)defaultRefreshFooterClass{
    if(_defaultRefreshFooterClass == nil){
        _defaultRefreshFooterClass = MJRefreshAutoNormalFooter.class;
    }
    return _defaultRefreshFooterClass;
}

-(void)setRefreshFooterClass:(Class)refreshFooterClass{
    if([refreshFooterClass isSubclassOfClass:MJRefreshFooter.class]){
        _refreshFooterClass = refreshFooterClass;
    }
}

-(void)setNextPageCallback:(xCollectionViewNextPageCallback)nextPageCallback{
    _nextPageCallback = nextPageCallback;
    if(nextPageCallback){
        self.isScrollEnabled = true;
        __weak typeof(self) weak = self;
        _collectionView.mj_footer = [_refreshFooterClass footerWithRefreshingBlock:^{
            RACSignal<xCollectionViewPageResult*> *signal = nextPageCallback();
            if(signal){
                signal = [signal deliverOn:RACScheduler.mainThreadScheduler];
                signal = [signal doNext:^(xCollectionViewPageResult * _Nullable result) {
                    __strong xCollectionView *s = weak;
                    if(!result.ignoreRetData){
                        if(result.pageDataList){
                            if(s.pageSize > 0){
                                if(result.pageDataList.count < s.pageSize){
                                    result.isNoMoreData = true;
                                }
                            }
                            NSMutableArray *sectionList = s.dataSectionList != nil?[NSMutableArray arrayWithArray:s.dataSectionList]:[NSMutableArray new];
                            if(sectionList.count == 0){
                                xCollectionViewSection *section = [xCollectionViewSection new];
                                section.cellClass = (s.cellClasses.count == 1)?s.cellClasses[0]:UICollectionViewCell.class;
                                section.dataList = result.pageDataList;
                                [sectionList addObject:section];
                            }
                            else{
                                xCollectionViewSection *section = sectionList[sectionList.count - 1];
                                if(section.dataList){
                                    section.dataList = [section.dataList arrayByAddingObjectsFromArray:result.pageDataList];
                                }
                                else{
                                    section.dataList = result.pageDataList;
                                }
                            }
                            s.dataSectionList = sectionList;
                        }
                        else if(result.pageSectionList){
                            NSMutableArray *sectionList = s.dataSectionList != nil?[NSMutableArray arrayWithArray:s.dataSectionList]:[NSMutableArray new];
                            [sectionList addObjectsFromArray:result.pageSectionList];
                            s.dataSectionList = sectionList;
                        }
                        [s reloadData];
                    }
                    if(result.isNoMoreData){
                        [s.collectionView.mj_footer endRefreshingWithNoMoreData];
                    }
                    else{
                        [s.collectionView.mj_footer endRefreshing];
                    }
                }];
                signal = [signal doError:^(NSError * _Nonnull error) {
                    [weak.collectionView.mj_footer endRefreshing];
                }];
                [signal subscribeNext:^(xCollectionViewPageResult * _Nullable x) {
                    // do nothing, just let the stream execute
                }];
            }
            else{
                [weak.collectionView.mj_footer endRefreshing];
            }
        }];
    }
    else{
        self.collectionView.mj_footer = nil;
    }
}

-(void)setNoMoreData{
    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
}

-(void)clearNoMoreData{
    [self.collectionView.mj_footer resetNoMoreData];
}

#pragma mark - 拖拽排序

-(void)setMoveCallback:(xCollectionViewMoveCallback)moveCallback{
    _moveCallback = moveCallback;
    if(moveCallback){
        UILongPressGestureRecognizer *g = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
        g.minimumPressDuration = 0.3f;
        [self.collectionView addGestureRecognizer:g];
    }
}

-(void)actionLongPress:(UILongPressGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self.collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}

//拖拽开始 找到被拖拽的item
-(void)dragBegin:(CGPoint)point{
    NSIndexPath *startIndexPath = [self getDragingIndexPathWithPoint:point];
    if(!startIndexPath){
        return;
    }
    if([self.moveDisableItems containsObject:[self _getDataFromIndexPath:startIndexPath]]){
        return;
    }
    self.isScrollEnableBeforeMove = self.isScrollEnabled;
    self.isScrollEnabled = false;
    self.startDragingIndexPath = startIndexPath;
    self.dragingIndexPath = startIndexPath;
    
    //原始cell隐藏
    UICollectionViewCell *startCell = [self.collectionView cellForItemAtIndexPath:startIndexPath];
    startCell.hidden = true;
    self.movingStartCell = startCell;
    
    //构建movingCell
    UICollectionViewCell *movingCell = [self _buildCellFromIndexPath:startIndexPath];
    movingCell.frame = startCell.frame;
    [self.movingCell removeFromSuperview];
    self.movingCell = movingCell;
    [self.collectionView addSubview:movingCell];
    [UIView animateWithDuration:0.1 animations:^{
        [movingCell setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
        movingCell.center = point;
    }];
    
    //回调
    xCollectionViewMoveCallback callback = self.moveCallback;
    if(callback){
        xCollectionViewMoveData *retData = [xCollectionViewMoveData new];
        retData.action = xCollectionViewMoveActionBegin;
        retData.startIndexPath = startIndexPath;
        retData.sortedDataList = self.dataList;
        retData.sortedSectionDataList = self.dataSectionList;
        callback(retData);
    }
}

//正在被拖拽、、、
-(void)dragChanged:(CGPoint)point{
    if(!self.dragingIndexPath){
        return;
    }
    self.movingCell.center = point;
    NSIndexPath *targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到targetIndexPath则不交换位置
    if (self.dragingIndexPath && targetIndexPath) {
        if([self.moveDisableItems containsObject:[self _getDataFromIndexPath:targetIndexPath]]){
            return;
        }
        //更新数据源
        [self sortDataFrom:self.dragingIndexPath to:targetIndexPath];
        //更新item位置
        [self.collectionView moveItemAtIndexPath:self.dragingIndexPath toIndexPath:targetIndexPath];
        //回调
        xCollectionViewMoveCallback callback = self.moveCallback;
        if(callback){
            xCollectionViewMoveData *retData = [xCollectionViewMoveData new];
            retData.action = xCollectionViewMoveActionSwap;
            retData.startIndexPath = self.startDragingIndexPath;
            retData.swapFrom = [NSIndexPath indexPathForItem:self.dragingIndexPath.item inSection:self.dragingIndexPath.section];
            retData.swapTo = [NSIndexPath indexPathForItem:targetIndexPath.item inSection:targetIndexPath.section];
            retData.sortedDataList = self.dataList;
            retData.sortedSectionDataList = self.dataSectionList;
            callback(retData);
        }
        self.dragingIndexPath = targetIndexPath;
    }
}

//拖拽结束
-(void)dragEnd{
    if(!self.dragingIndexPath){
        return;
    }
    NSIndexPath *startIndex = self.startDragingIndexPath;
    NSIndexPath *endIndex = self.dragingIndexPath;
    self.startDragingIndexPath = nil;
    self.dragingIndexPath = nil;
    CGRect endFrame = [self.collectionView cellForItemAtIndexPath:endIndex].frame;
    [UIView animateWithDuration:0.1 animations:^{
        [self.movingCell setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        self.movingCell.frame = endFrame;
    }completion:^(BOOL finished) {
        [self.movingCell removeFromSuperview];
        UICollectionViewCell *startMovingCell = [self.collectionView cellForItemAtIndexPath:endIndex];
        startMovingCell.hidden = false;
        //回调
        xCollectionViewMoveCallback callback = self.moveCallback;
        if(callback){
            xCollectionViewMoveData *retData = [xCollectionViewMoveData new];
            retData.action = xCollectionViewMoveActionEnd;
            retData.startIndexPath = startIndex;
            retData.endIndexPath = endIndex;
            retData.sortedDataList = self.dataList;
            retData.sortedSectionDataList = self.dataSectionList;
            callback(retData);
        }
        self.isScrollEnabled = self.isScrollEnableBeforeMove;
    }];
}

//获取被拖动IndexPath的方法
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point{
    NSIndexPath* dragIndexPath = nil;
    //只有一个不排序
    NSInteger count = 0;
    for(xCollectionViewSection *item in self.dataSectionList){
        count += item.dataList.count;
    }
    if (count == 0) {
        return nil;
    }
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        if (CGRectContainsPoint([self.collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            dragIndexPath = indexPath;
            break;
        }
    }
    return dragIndexPath;
}

//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:self.dragingIndexPath]) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([self.collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            targetIndexPath = indexPath;
        }
    }
    return targetIndexPath;
}

-(void)sortDataFrom:(NSIndexPath*)from to:(NSIndexPath*)to{
    xCollectionViewSection *fromSection = [self _getSectionFromIndexPath:from];
    NSMutableArray *fromArr =  [NSMutableArray arrayWithArray:fromSection.dataList];
    id obj = fromArr[from.item];
    xCollectionViewSection *toSection = [self _getSectionFromIndexPath:to];
    NSMutableArray *toArr = fromSection == toSection ? fromArr : [NSMutableArray arrayWithArray:toSection.dataList];
    [fromArr removeObject:obj];
    [toArr insertObject:obj atIndex:to.item];
    fromSection.dataList = fromArr;
    if(fromSection != toSection){
        toSection.dataList = toArr;
    }
}

//暴露给外界的接口，dataList会跟随改变，可用来回退
-(void)moveItemFrom:(NSIndexPath*)from to:(NSIndexPath*)to{
    if(from.item < self.dataList.count && to.item < self.dataList.count){
        [self.collectionView moveItemAtIndexPath:from toIndexPath:to];
        [self sortDataFrom:from to:to];
    }
}

#pragma mark - Utils

-(id)_getDataFromIndexPath:(NSIndexPath*)indexPath{
    if(!self.dataSectionList || self.dataSectionList.count <= indexPath.section){
        return nil;
    }
    xCollectionViewSection *section = self.dataSectionList[indexPath.section];
    if(!section.dataList || section.dataList.count <= indexPath.item){
        return nil;
    }
    return section.dataList[indexPath.item];
}

-(xCollectionViewSection*)_getSectionFromIndexPath:(NSIndexPath*)indexPath{
    if(!self.dataSectionList || self.dataSectionList.count <= indexPath.section){
        return nil;
    }
    return self.dataSectionList[indexPath.section];
}

-(UICollectionViewScrollDirection)scrollDirection{
    return _layout.scrollDirection;
}

-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
    _layout.scrollDirection = scrollDirection;
}

-(void)setIsScrollEnabled:(BOOL)isScrollEnabled{
    _collectionView.scrollEnabled = isScrollEnabled;
    if(_layout.scrollDirection == UICollectionViewScrollDirectionVertical){
        _collectionView.alwaysBounceVertical = isScrollEnabled;
    }
}

-(BOOL)isScrollEnabled{
    return _collectionView.scrollEnabled;
}

-(void)setIsScrollsToTop:(BOOL)isScrollsToTop {
    _collectionView.scrollsToTop = isScrollsToTop;
}
-(BOOL)isScrollsToTop {
    return _collectionView.scrollsToTop;
}

-(BOOL)showsVerticalScrollIndicator{
    return _collectionView.showsVerticalScrollIndicator;
}

-(void)setShowsVerticalScrollIndicator:(BOOL)value{
    _collectionView.showsVerticalScrollIndicator = value;
}

- (void)setAlwaysBounceVertical:(BOOL)bounce{
    _collectionView.alwaysBounceVertical = bounce;
}

-(BOOL)alwaysBounceVertical{
    return _collectionView.alwaysBounceVertical;
}

- (void)setAlwaysBounceHorizontal:(BOOL)bounce{
    _collectionView.alwaysBounceHorizontal = bounce;
}

-(BOOL)alwaysBounceHorizontal{
    return _collectionView.alwaysBounceHorizontal;
}

- (void)setBounces:(BOOL)bounces{
    _collectionView.bounces = bounces;
}

-(BOOL)bounces{
    return _collectionView.bounces;
}

-(void)scrollToItemAt:(NSIndexPath*)indexPath position:(UICollectionViewScrollPosition)position animated:(BOOL)animated{
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:animated];
}

-(void)scrollToTopAnimated:(BOOL)animated{
    if([self numberOfItemsInSection:0] > 0){
        [self scrollToItemAt:[NSIndexPath indexPathForRow:0 inSection:0] position:UICollectionViewScrollPositionTop animated:animated];
    }
    else{
        [self scrollTo:CGPointMake(0, 0) animated:animated];
    }
}

-(void)scrollToBottomAnimated:(BOOL)animated{
    NSInteger rowCount = [self numberOfItemsInSection:self.dataSectionList.count - 1];
    [self scrollToItemAt:[NSIndexPath indexPathForRow:(rowCount > 0 ?rowCount - 1:0) inSection:self.dataSectionList.count - 1] position:UICollectionViewScrollPositionBottom animated:animated];
}

-(void)scrollTo:(CGPoint)offset animated:(BOOL)animated{
    [_collectionView setContentOffset:offset animated:animated];
}

-(void)setClipsToBounds:(BOOL)clipsToBounds{
    super.clipsToBounds = clipsToBounds;
    _collectionView.clipsToBounds = clipsToBounds;
}

//新方法，删除cell，同步删除data
-(void)deleteItemAtIndexPath:(NSIndexPath*)indexPath{
    xCollectionViewSection *section = self.dataSectionList[indexPath.section];
    NSMutableArray *arr =  [NSMutableArray arrayWithArray:section.dataList];
    [arr removeObjectAtIndex:indexPath.item];
    section.dataList = arr;
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

//旧方法，只删除cell，未同步删除data
-(void)deleteAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths{
    [_collectionView deleteItemsAtIndexPaths:indexPaths];
}

-(UICollectionViewCell *)cellWithIndexPath:(NSIndexPath *)path{
    return [_collectionView cellForItemAtIndexPath:path];
}

-(NSInteger)numberOfSections{
    return _collectionView.numberOfSections;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return self.dataSectionList[section].dataList.count;
}

-(CGSize)contentSize {
    return self.layout.collectionViewContentSize;
}

-(void)reloadData{
    [_collectionView reloadData];
}

#pragma mark - scrollView delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.didScrollCallback){
        self.didScrollCallback(scrollView);
    }
}

/** 滚动结束后调用（代码导致） */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.scrollEndCallback) {
        self.scrollEndCallback(scrollView.contentOffset);
    }
}
/** 滚动结束（手势导致） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark - size & margin

-(void)setItemSize:(CGSize)itemSize {
    _layout.itemSize = itemSize;
}

-(CGSize)itemSize{
    return _layout.itemSize;
}

-(void)setLineSpace:(CGFloat)lineSpace {
    _layout.minimumLineSpacing = lineSpace;
}

-(CGFloat)lineSpace{
    return _layout.minimumLineSpacing;
}

-(void)setInteritemSpace:(CGFloat)interitemSpace{
    _layout.minimumInteritemSpacing = interitemSpace;
}

-(CGFloat)interitemSpace{
    return _layout.minimumInteritemSpacing;
}

-(void)setHeaderSize:(CGSize)headerSize{
    _layout.headerReferenceSize = headerSize;
}

-(CGSize)headerSize{
    return _layout.headerReferenceSize;
}

-(void)setFooterSize:(CGSize)footerSize{
    _layout.footerReferenceSize = footerSize;
}

-(CGSize)footerSize{
    return _layout.footerReferenceSize;
}

-(void)setContentInset:(UIEdgeInsets)contentInset{
    _collectionView.contentInset = contentInset;
}

-(UIEdgeInsets)contentInset{
    return _collectionView.contentInset;
}

-(void)setSectionInset:(UIEdgeInsets)sectionInset{
    _layout.sectionInset = sectionInset;
}

-(UIEdgeInsets)sectionInset{
    return _layout.sectionInset;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.itemSizeCallback){
        id data = [self _getDataFromIndexPath:indexPath];
        xCollectionViewSection *section = [self _getSectionFromIndexPath:indexPath];
        xCollectionViewCellContext *context = [xCollectionViewCellContext new];
        context.data = data;
        context.indexPath = indexPath;
        context.section = section;
        return self.itemSizeCallback(context);
    }
    return _layout.itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(self.sectionInsetCallback){
        return self.sectionInsetCallback(self.dataSectionList[section], section);
    }
    return _layout.sectionInset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if(self.lineSpaceCallback){
        return self.lineSpaceCallback(self.dataSectionList[section], section);
    }
    return _layout.minimumLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if(self.interitemSpaceCallback){
        return self.interitemSpaceCallback(self.dataSectionList[section], section);
    }
    return _layout.minimumInteritemSpacing;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(self.headerSizeCallback){
        return self.headerSizeCallback(self.dataSectionList[section], section);
    }
    return _layout.headerReferenceSize;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if(self.footerSizeCallback){
        return self.footerSizeCallback(self.dataSectionList[section], section);
    }
    return _layout.footerReferenceSize;
}

#pragma mark - build & select

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSectionList.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class class = self.dataSectionList[indexPath.section].cellClass;
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(class) forIndexPath:indexPath];
    id data = [self _getDataFromIndexPath:indexPath];
    cell.x_data = data;
    cell.x_indexPath = indexPath;
    xCollectionViewSection *section = [self _getSectionFromIndexPath:indexPath];
    xCollectionViewCellContext *context = [xCollectionViewCellContext new];
    context.data = data;
    context.indexPath = indexPath;
    context.section = section;
    if (self.buildCellCallback) {
        self.buildCellCallback(cell, context);
    }
    return cell;
}

//目前拖拽排序创建movingCell使用
-(UICollectionViewCell*)_buildCellFromIndexPath:(NSIndexPath*)indexPath{
    Class class = self.dataSectionList[indexPath.section].cellClass;
    UICollectionViewCell *cell = [[class alloc] init];
    id data = [self _getDataFromIndexPath:indexPath];
    cell.x_data = data;
    cell.x_indexPath = indexPath;
    xCollectionViewSection *section = [self _getSectionFromIndexPath:indexPath];
    xCollectionViewCellContext *context = [xCollectionViewCellContext new];
    context.data = data;
    context.indexPath = indexPath;
    context.section = section;
    if (self.buildCellCallback) {
        self.buildCellCallback(cell, context);
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        if(!self.buildHeaderCallback){
            return nil;
        }
        UICollectionReusableView *view = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        return self.buildHeaderCallback(view, indexPath.section, self.dataSectionList[indexPath.section]);
    }
    else if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        if(!self.buildFooterCallback){
            return nil;
        }
        UICollectionReusableView *view = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        return self.buildFooterCallback(view, indexPath.section, self.dataSectionList[indexPath.section]);
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if(self.selectCellCallback){
        id data = [self _getDataFromIndexPath:indexPath];
        xCollectionViewSection *section = [self _getSectionFromIndexPath:indexPath];
        xCollectionViewCellContext *context = [xCollectionViewCellContext new];
        context.data = data;
        context.indexPath = indexPath;
        context.section = section;
        self.selectCellCallback(cell, context);
    }
}



-(instancetype)initWithCellClass:(Class)cellClass{
    return [self initWithCellClasses:@[cellClass] isLeftAlign:false];
}

-(instancetype)initWithCollectionViewCell{
    return [self initWithCellClasses:@[] isLeftAlign:false];
}

-(instancetype)initWithCellClasses:(NSArray<Class>*_Nullable)cellClasses{
    return [self initWithCellClasses:cellClasses isLeftAlign:false];
}

-(instancetype)initWithCellClasses:(NSArray<Class>*_Nullable)cellClasses
                       isLeftAlign:(BOOL)isLeftAlign{
    self = [super init];
    if(self){
        self.cellClasses = [NSMutableArray new];
        for(Class class in cellClasses){
            if(class != UICollectionViewCell.class){
                [self.cellClasses addObject:class];
            }
        }
        self.isLeftAlign = isLeftAlign;
        [self prepare];
    }
    return self;
}

-(void)prepare{
    self.refreshHeaderClass = [xCollectionView defaultRefreshHeaderClass];
    self.refreshFooterClass = [xCollectionView defaultRefreshFooterClass];
    Class layoutClass = self.isLeftAlign?LeftAlignedCollectionViewFlowLayout.class:UICollectionViewFlowLayout.class;
    _layout = [[layoutClass alloc] init];
    _layout.minimumInteritemSpacing = 0;
    _layout.minimumLineSpacing = 0;
    _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.scrollEnabled = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    //UICollectionViewCell总是注册
    [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)];
    //用户添加的CellClass
    for(Class class in self.cellClasses){
        [_collectionView registerClass:class forCellWithReuseIdentifier:NSStringFromClass(class)];
    }
    [_collectionView registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [_collectionView registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    
    __weak typeof(self) weak = self;
    [[[_collectionView rac_valuesAndChangesForKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld observer:self] deliverOnMainThread] subscribeNext:^(RACTuple *tuple) {
        CGSize newSize = [tuple.first CGSizeValue] ;
        NSDictionary *change = tuple.second;
        CGSize oldSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
        if (oldSize.height != newSize.height) {
            if (weak.isAutoHeight) {
                [weak invalidateIntrinsicContentSize];
            }
        }
    }];
}

- (CGSize)intrinsicContentSize {
    if (self.isAutoHeight) {
        return CGSizeMake(UIViewNoIntrinsicMetric, _collectionView.contentSize.height);
    }
    else {
        return [super intrinsicContentSize];
    }
}

-(void)setDataList:(NSArray *)dataList{
    NSMutableArray *sectionList = self.dataSectionList != nil?[NSMutableArray arrayWithArray:self.dataSectionList]:[NSMutableArray new];
    if(sectionList.count == 0){
        xCollectionViewSection *section = [xCollectionViewSection new];
        section.cellClass = (self.cellClasses.count == 1)?self.cellClasses[0]:UICollectionViewCell.class;
        section.dataList = dataList;
        [sectionList addObject:section];
    }
    else{
        xCollectionViewSection *section = sectionList[0];
        section.dataList = dataList;
    }
    self.dataSectionList = sectionList;
}

-(NSArray*)dataList{
    if(self.dataSectionList.count == 0){
        return nil;
    }
    return self.dataSectionList[0].dataList;
}

@end
