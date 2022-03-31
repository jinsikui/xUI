

#import "xTableView.h"
#import "UITableViewCell+xUI.h"
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

#define xTableViewErrorDomain @"xTableViewError"


@implementation xTableViewPageResult
@end

@implementation xTableViewMoveData
@end

@implementation xTableViewSection
-(instancetype)init{
    self = [super init];
    if(self){
        self.cellClass = UITableViewCell.class;
    }
    return self;
}
@end

@implementation xTableViewCellContext
@end

@interface xTableView()
//UITableView中触发拖拽的cell，开始拖拽后隐藏，结束拖拽后重新显示在新位置
@property(nonatomic,strong) UITableViewCell *movingStartCell;
//开始拖拽后为了UI显示而新创建的cell，跟随手指移动，仅仅为了UI显示，结束拖拽后隐藏
@property(nonatomic,strong) UITableViewCell *movingCell;
@property(nonatomic,strong) NSIndexPath *startDragingIndexPath;
@property(nonatomic,strong) NSIndexPath *dragingIndexPath;
@property(nonatomic,assign) BOOL isScrollEnableBeforeMove;

@property(nonatomic,strong) NSMutableArray<Class> *cellClasses;

+(FBLPromise*)_rejectedErrorPromise;

@end

@implementation xTableView

+(FBLPromise*)_rejectedErrorPromise{
    FBLPromise *promise = FBLPromise.pendingPromise;
    NSError * eror = [NSError errorWithDomain:xTableViewErrorDomain code:-1 userInfo:nil];
    [promise reject:eror];
    return promise;
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

-(void)setRefreshCallback:(xTableViewRefreshCallback)refreshCallback{
    _refreshCallback = refreshCallback;
    if(refreshCallback){
        self.isScrollEnabled = true;
        __weak typeof(self) weak = self;
        _tableView.mj_header = [_refreshHeaderClass headerWithRefreshingBlock:^{
            [weak refresh];
        }];
    }
    else{
        _tableView.mj_header = nil;
    }
}

-(FBLPromise<xTableViewPageResult*>*)refresh{
    xTableViewRefreshCallback refreshCallback = self.refreshCallback;
    if(!refreshCallback){
        return [xTableView _rejectedErrorPromise];
    }
    FBLPromise<xTableViewPageResult*> *promise = refreshCallback();
    if(promise){
        __weak typeof(self) weak = self;
        promise.then(^id(xTableViewPageResult *result){
            __strong xTableView *s = weak;
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
                xTableViewSection *section = [xTableViewSection new];
                section.cellClass = (s.cellClasses.count == 1)?s.cellClasses[0]:UITableViewCell.class;
                section.dataList = result.pageDataList;
                [sectionList addObject:section];
                s.dataSectionList = sectionList;
            }
            else{
                s.dataSectionList = nil;
            }
            [s reloadData];
            if (result.isNoMoreData) {
                [s.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            else{
                [s.tableView.mj_footer resetNoMoreData];
            }
            s.tableView.mj_footer.hidden = result.shouldHideFooter;
            return result;
        }).always(^{
            [weak.tableView.mj_header endRefreshing];
        });
        return promise;
    }
    else{
        return [xTableView _rejectedErrorPromise];
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

-(void)setNextPageCallback:(xTableViewNextPageCallback)nextPageCallback{
    _nextPageCallback = nextPageCallback;
    if(nextPageCallback){
        self.isScrollEnabled = true;
        __weak typeof(self) weak = self;
        _tableView.mj_footer = [_refreshFooterClass footerWithRefreshingBlock:^{
            FBLPromise<xTableViewPageResult*> *promise = nextPageCallback();
            if(promise){
                promise.then(^id(xTableViewPageResult *result){
                    __strong xTableView *s = weak;
                    if(result.pageDataList){
                        if(s.pageSize > 0){
                            if(result.pageDataList.count < s.pageSize){
                                result.isNoMoreData = true;
                            }
                        }
                        NSMutableArray *sectionList = s.dataSectionList != nil?[NSMutableArray arrayWithArray:s.dataSectionList]:[NSMutableArray new];
                        if(sectionList.count == 0){
                            xTableViewSection *section = [xTableViewSection new];
                            section.cellClass = (s.cellClasses.count == 1)?s.cellClasses[0]:UITableViewCell.class;
                            section.dataList = result.pageDataList;
                            [sectionList addObject:section];
                        }
                        else{
                            xTableViewSection *section = sectionList[sectionList.count - 1];
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
                    if(result.isNoMoreData){
                        [s.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                    else{
                        [s.tableView.mj_footer endRefreshing];
                    }
                    return nil;
                }).catch(^(NSError *error){
                    [weak.tableView.mj_footer endRefreshing];
                });
            }
            else{
                [weak.tableView.mj_footer endRefreshing];
            }
        }];
    }
    else{
        self.tableView.mj_footer = nil;
    }
}

-(void)setNoMoreData{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

-(void)clearNoMoreData{
    [self.tableView.mj_footer resetNoMoreData];
}

#pragma mark - 拖拽排序

-(void)setMoveCallback:(xTableViewMoveCallback)moveCallback{
    _moveCallback = moveCallback;
    if(moveCallback){
        UILongPressGestureRecognizer *g = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
        g.minimumPressDuration = 0.3f;
        [self.tableView addGestureRecognizer:g];
    }
}

-(void)actionLongPress:(UILongPressGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:self.tableView];
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
    UITableViewCell *startCell = [self.tableView cellForRowAtIndexPath:startIndexPath];
    startCell.hidden = true;
    self.movingStartCell = startCell;
    
    //构建movingCell
    UITableViewCell *movingCell = [self _buildCellFromIndexPath:startIndexPath];
    movingCell.frame = startCell.frame;
    [self.movingCell removeFromSuperview];
    self.movingCell = movingCell;
    [self.tableView addSubview:movingCell];
    [UIView animateWithDuration:0.1 animations:^{
        [movingCell setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
        movingCell.center = point;
    }];
    
    //回调
    xTableViewMoveCallback callback = self.moveCallback;
    if(callback){
        xTableViewMoveData *retData = [xTableViewMoveData new];
        retData.action = xTableViewMoveActionBegin;
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
        [self.tableView moveRowAtIndexPath:self.dragingIndexPath toIndexPath:targetIndexPath];
        //回调
        xTableViewMoveCallback callback = self.moveCallback;
        if(callback){
            xTableViewMoveData *retData = [xTableViewMoveData new];
            retData.action = xTableViewMoveActionSwap;
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
    CGRect endFrame = [self.tableView cellForRowAtIndexPath:endIndex].frame;
    [UIView animateWithDuration:0.1 animations:^{
        [self.movingCell setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        self.movingCell.frame = endFrame;
    }completion:^(BOOL finished) {
        [self.movingCell removeFromSuperview];
        UITableViewCell *startMovingCell = [self.tableView cellForRowAtIndexPath:endIndex];
        startMovingCell.hidden = false;
        //回调
        xTableViewMoveCallback callback = self.moveCallback;
        if(callback){
            xTableViewMoveData *retData = [xTableViewMoveData new];
            retData.action = xTableViewMoveActionEnd;
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
    for(xTableViewSection *item in self.dataSectionList){
        count += item.dataList.count;
    }
    if (count == 0) {
        return nil;
    }
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        if (CGRectContainsPoint([self.tableView cellForRowAtIndexPath:indexPath].frame, point)) {
            dragIndexPath = indexPath;
            break;
        }
    }
    return dragIndexPath;
}

//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        //如果是自己不需要排序
        if ([indexPath isEqual:self.dragingIndexPath]) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([self.tableView cellForRowAtIndexPath:indexPath].frame, point)) {
            targetIndexPath = indexPath;
        }
    }
    return targetIndexPath;
}

-(void)sortDataFrom:(NSIndexPath*)from to:(NSIndexPath*)to{
    xTableViewSection *fromSection = [self _getSectionFromIndexPath:from];
    NSMutableArray *fromArr =  [NSMutableArray arrayWithArray:fromSection.dataList];
    id obj = fromArr[from.item];
    xTableViewSection *toSection = [self _getSectionFromIndexPath:to];
    NSMutableArray *toArr = fromSection == toSection ? fromArr : [NSMutableArray arrayWithArray:toSection.dataList];
    [fromArr removeObject:obj];
    [toArr insertObject:obj atIndex:to.item];
    fromSection.dataList = fromArr;
    if(fromSection != toSection){
        toSection.dataList = toArr;
    }
}

//暴露给外界的接口，dataList会跟随改变，可用来回退
-(void)moveRowFrom:(NSIndexPath*)from to:(NSIndexPath*)to{
    if(from.item < self.dataList.count && to.item < self.dataList.count){
        [self.tableView moveRowAtIndexPath:from toIndexPath:to];
        [self sortDataFrom:from to:to];
    }
}

#pragma mark - Utils

-(id)_getDataFromIndexPath:(NSIndexPath*)indexPath{
    if(!self.dataSectionList || self.dataSectionList.count <= indexPath.section){
        return nil;
    }
    xTableViewSection *section = self.dataSectionList[indexPath.section];
    if(!section.dataList || section.dataList.count <= indexPath.item){
        return nil;
    }
    return section.dataList[indexPath.item];
}

-(xTableViewSection*)_getSectionFromIndexPath:(NSIndexPath*)indexPath{
    if(!self.dataSectionList || self.dataSectionList.count <= indexPath.section){
        return nil;
    }
    return self.dataSectionList[indexPath.section];
}

-(void)setIsScrollEnabled:(BOOL)isScrollEnabled{
    _tableView.scrollEnabled = isScrollEnabled;
}

-(BOOL)isScrollEnabled{
    return _tableView.scrollEnabled;
}

-(void)setIsScrollsToTop:(BOOL)isScrollsToTop {
    _tableView.scrollsToTop = isScrollsToTop;
}
-(BOOL)isScrollsToTop {
    return _tableView.scrollsToTop;
}

-(BOOL)showsVerticalScrollIndicator{
    return _tableView.showsVerticalScrollIndicator;
}

-(void)setShowsVerticalScrollIndicator:(BOOL)value{
    _tableView.showsVerticalScrollIndicator = value;
}

- (void)setAlwaysBounceVertical:(BOOL)bounce{
    _tableView.alwaysBounceVertical = bounce;
}

-(BOOL)alwaysBounceVertical{
    return _tableView.alwaysBounceVertical;
}

- (void)setBounces:(BOOL)bounces{
    _tableView.bounces = bounces;
}

-(BOOL)bounces{
    return _tableView.bounces;
}

-(void)scrollToRowAt:(NSIndexPath*)indexPath position:(UITableViewScrollPosition)position animated:(BOOL)animated{
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
}

-(void)scrollToTopAnimated:(BOOL)animated{
    if([self numberOfRowsInSection:0] > 0){
        [self scrollToRowAt:[NSIndexPath indexPathForRow:0 inSection:0] position:UITableViewScrollPositionTop animated:animated];
    }
    else{
        [self scrollTo:CGPointMake(0, 0) animated:animated];
    }
}

-(void)scrollToBottomAnimated:(BOOL)animated{
    NSInteger rowCount = [self numberOfRowsInSection:self.dataSectionList.count - 1];
    [self scrollToRowAt:[NSIndexPath indexPathForRow:(rowCount > 0 ?rowCount - 1:0) inSection:self.dataSectionList.count - 1] position:UITableViewScrollPositionBottom animated:animated];
}

-(void)scrollTo:(CGPoint)offset animated:(BOOL)animated{
    [_tableView setContentOffset:offset animated:animated];
}

-(void)setClipsToBounds:(BOOL)clipsToBounds{
    super.clipsToBounds = clipsToBounds;
    _tableView.clipsToBounds = clipsToBounds;
}

//新方法，删除cell，同步删除data
-(void)deleteRowAtIndexPath:(NSIndexPath*)indexPath{
    xTableViewSection *section = self.dataSectionList[indexPath.section];
    NSMutableArray *arr =  [NSMutableArray arrayWithArray:section.dataList];
    [arr removeObjectAtIndex:indexPath.item];
    section.dataList = arr;
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:false];
}

//旧方法，只删除cell，未同步删除data
-(void)deleteAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths{
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:false];
}

-(UITableViewCell *)cellWithIndexPath:(NSIndexPath *)path{
    return [_tableView cellForRowAtIndexPath:path];
}

-(NSInteger)numberOfSections{
    return _tableView.numberOfSections;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return self.dataSectionList[section].dataList.count;
}

-(void)reloadData{
    [_tableView reloadData];
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

-(void)setRowHeight:(CGFloat)rowHeight {
    _tableView.rowHeight = rowHeight;
}

-(CGFloat)rowHeight{
    return _tableView.rowHeight;
}

-(void)setSectionHeaderHeight:(CGFloat)sectionHeaderHeight{
    _tableView.sectionHeaderHeight = sectionHeaderHeight;
}

-(CGFloat)sectionHeaderHeight{
    return _tableView.sectionHeaderHeight;
}

-(void)setSectionFooterHeight:(CGFloat)sectionFooterHeight{
    _tableView.sectionFooterHeight = sectionFooterHeight;
}

-(CGFloat)sectionFooterHeight{
    return _tableView.sectionFooterHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.rowHeightCallback){
        id data = [self _getDataFromIndexPath:indexPath];
        xTableViewSection *section = [self _getSectionFromIndexPath:indexPath];
        xTableViewCellContext *context = [xTableViewCellContext new];
        context.data = data;
        context.indexPath = indexPath;
        context.section = section;
        return self.rowHeightCallback(context);
    }
    return _tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.sectionHeaderHeightCallback){
        return self.sectionHeaderHeightCallback(self.dataSectionList[section], section);
    }
    else if(_tableView.sectionHeaderHeight >= 0){
        return _tableView.sectionHeaderHeight;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(self.sectionFooterHeightCallback){
        return self.sectionFooterHeightCallback(self.dataSectionList[section], section);
    }
    else if(_tableView.sectionFooterHeight >= 0){
        return _tableView.sectionFooterHeight;
    }
    return 0;
}

#pragma mark - 左滑操作

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.canEditRowCallback){
        return self.canEditRowCallback([self buildContextForIndexPath:indexPath]);
    }
    return false;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editActionsForRowCallback){
        return self.editActionsForRowCallback([self buildContextForIndexPath:indexPath]);
    }
    return nil;
}

-(xTableViewCellContext*)buildContextForIndexPath:(NSIndexPath*)indexPath{
    id data = [self _getDataFromIndexPath:indexPath];
    xTableViewSection *section = [self _getSectionFromIndexPath:indexPath];
    xTableViewCellContext *context = [xTableViewCellContext new];
    context.data = data;
    context.indexPath = indexPath;
    context.section = section;
    return context;
}

#pragma mark - build & select

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSectionList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = self.dataSectionList[indexPath.section].cellClass;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass(class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    id data = [self _getDataFromIndexPath:indexPath];
    cell.x_data = data;
    cell.x_indexPath = indexPath;
    xTableViewSection *section = [self _getSectionFromIndexPath:indexPath];
    xTableViewCellContext *context = [xTableViewCellContext new];
    context.data = data;
    context.indexPath = indexPath;
    context.section = section;
    if (self.buildCellCallback) {
        self.buildCellCallback(cell, context);
    }
    return cell;
}

//目前拖拽排序创建movingCell使用
-(UITableViewCell*)_buildCellFromIndexPath:(NSIndexPath*)indexPath{
    Class class = self.dataSectionList[indexPath.section].cellClass;
    UITableViewCell *cell = [[class alloc] init];
    id data = [self _getDataFromIndexPath:indexPath];
    cell.x_data = data;
    cell.x_indexPath = indexPath;
    xTableViewSection *section = [self _getSectionFromIndexPath:indexPath];
    xTableViewCellContext *context = [xTableViewCellContext new];
    context.data = data;
    context.indexPath = indexPath;
    context.section = section;
    if (self.buildCellCallback) {
        self.buildCellCallback(cell, context);
    }
    return cell;
}

-(UIView *)tableHeaderView{
    return _tableView.tableHeaderView;
}

-(void)setTableHeaderView:(UIView *)tableHeaderView{
    _tableView.tableHeaderView = tableHeaderView;
}

-(UIView *)tableFooterView{
    return _tableView.tableFooterView;
}

-(void)setTableFooterView:(UIView *)tableFooterView{
    _tableView.tableFooterView = tableFooterView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(!self.buildHeaderCallback){
        return nil;
    }
    UITableViewHeaderFooterView *view = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    return self.buildHeaderCallback(view, section, self.dataSectionList[section]);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(!self.buildFooterCallback){
        return nil;
    }
    UITableViewHeaderFooterView *view = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    return self.buildFooterCallback(view, section, self.dataSectionList[section]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(self.selectCellCallback){
        id data = [self _getDataFromIndexPath:indexPath];
        xTableViewSection *section = [self _getSectionFromIndexPath:indexPath];
        xTableViewCellContext *context = [xTableViewCellContext new];
        context.data = data;
        context.indexPath = indexPath;
        context.section = section;
        self.selectCellCallback(cell, context);
    }
}

-(instancetype)initWithCellClasses:(NSArray<Class>*_Nullable)cellClasses{
    self = [super init];
    if(self){
        self.cellClasses = [NSMutableArray new];
        for(Class class in cellClasses){
            if(class != UITableViewCell.class){
                [self.cellClasses addObject:class];
            }
        }
        [self prepare];
    }
    return self;
}

-(instancetype)initWithCellClass:(Class)cellClass{
    self = [super init];
    if(self){
        self.cellClasses = [NSMutableArray new];
        if(cellClass != UITableViewCell.class){
            [self.cellClasses addObject:cellClass];
        }
        [self prepare];
    }
    return self;
}

-(instancetype)initWithTableViewCell{
    self = [super init];
    if(self){
        self.cellClasses = [NSMutableArray new];
        [self prepare];
    }
    return self;
}

-(void)prepare{
    self.refreshHeaderClass = [xTableView defaultRefreshHeaderClass];
    self.refreshFooterClass = [xTableView defaultRefreshFooterClass];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = true;
    _tableView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    //UITableViewCell总是注册
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    //用户添加的CellClass
    for(Class class in self.cellClasses){
        [_tableView registerClass:class forCellReuseIdentifier:NSStringFromClass(class)];
    }
    [_tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:@"header"];
    [_tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:@"footer"];
}

-(void)setDataList:(NSArray *)dataList{
    NSMutableArray *sectionList = self.dataSectionList != nil?[NSMutableArray arrayWithArray:self.dataSectionList]:[NSMutableArray new];
    if(sectionList.count == 0){
        xTableViewSection *section = [xTableViewSection new];
        section.cellClass = (self.cellClasses.count == 1)?self.cellClasses[0]:UITableViewCell.class;
        section.dataList = dataList;
        [sectionList addObject:section];
    }
    else{
        xTableViewSection *section = sectionList[0];
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
