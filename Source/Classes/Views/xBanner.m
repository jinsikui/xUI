

#import "xBanner.h"
#import "UICollectionViewCell+xUI.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@implementation xBannerCellContext
@end

@interface xBanner()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic) UICollectionView *collectionView;
@property(nonatomic) UICollectionViewFlowLayout *layout;
@property(nonatomic) NSString *reuseId;
@property(nonatomic) NSInteger lastDataIndex;
//当reuseEnabled == NO时，dataList中每一个data对应一个cell，cell存在这里
@property(nonatomic) NSMutableDictionary<NSString*, id> *cellStore;
//Timer
@property(nonatomic) dispatch_source_t source;
@property(nonatomic, assign) BOOL suspended;
@end

@implementation xBanner

-(instancetype)initWithCellClass:(Class)cellClass itemSize:(CGSize)itemSize{
    self = [super init];
    if(self){
        [self setDefaults];
        _cellClass = cellClass;
        _itemSize = itemSize;
    }
    return self;
}

-(void)setScrollEnabled:(BOOL)scrollEnabled{
    _scrollEnabled = scrollEnabled;
    if(_collectionView){
        _collectionView.scrollEnabled = scrollEnabled;
    }
}


-(void)setDefaults{
    _autoScrollIntervalSeconds = 5;
    _itemSize = CGSizeZero;
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _cellClass = UICollectionViewCell.class;
    _lastDataIndex = 0;
    _isCycleScroll = NO;
    _isAutoScroll = NO;
    _scrollEnabled = YES;
    _reuseId = [NSString stringWithFormat:@"%d", arc4random()];
    _reuseEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
}

-(void)reloadData{
    if(_collectionView == nil){
        //
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        _layout.scrollDirection = _scrollDirection;
        _layout.itemSize = _itemSize;
        //
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView setPagingEnabled:YES];
        _collectionView.directionalLockEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        if(_reuseEnabled){
            [_collectionView registerClass:_cellClass forCellWithReuseIdentifier:_reuseId];
        }
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
        _collectionView.scrollEnabled = _scrollEnabled;
    }
    [_collectionView reloadData];
    if(_isCycleScroll && _isAutoScroll && _dataList.count > 1){
        [self startTimer];
    }
}

-(void)disableScroll{
    _collectionView.scrollEnabled = NO;
}

-(void)enableScroll{
    _collectionView.scrollEnabled = YES;
}

-(void)dealloc{
    [self deallocTimer];
}

#pragma mark - UICollectionViewDelegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_dataList != nil){
        if(_dataList.count <= 1){
            return _dataList.count;
        }
        else{
            if(_isCycleScroll){
                return _dataList.count + 2*1;
            }
            else{
                return _dataList.count;
            }
        }
    }
    else{
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger dataIndex = [self getDataIndexByCellIndex:indexPath.item];
    NSIndexPath *dataIndexPath = [NSIndexPath indexPathForItem:dataIndex inSection:0];
    if(_reuseEnabled){
        UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:_reuseId forIndexPath:indexPath];
        cell.x_indexPath = dataIndexPath;
        cell.x_data = _dataList[dataIndex];
        if(_buildCellCallback){
            _buildCellCallback(cell, [self _makeCellContext:dataIndex]);
        }
        return cell;
        
    }
    else{
        NSString *cellId = [NSString stringWithFormat:@"%ld", (long)dataIndex];
        if(_cellStore == nil){
            _cellStore = [[NSMutableDictionary<NSString*, id> alloc] init];
        }
        if(_cellStore[cellId]){
            return _cellStore[cellId];
        }
        [_collectionView registerClass:_cellClass forCellWithReuseIdentifier:cellId];
        UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:dataIndexPath];
        cell.x_indexPath = dataIndexPath;
        cell.x_data = _dataList[dataIndex];
        if(_buildCellCallback){
            _buildCellCallback(cell, [self _makeCellContext:dataIndex]);
        }
        _cellStore[cellId] = cell;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSInteger dataIndex = [self getDataIndexByCellIndex:indexPath.item];
    if(_selectCellCallback){
        _selectCellCallback(cell, [self _makeCellContext:dataIndex]);
    }
}

#pragma mark - UIScrollView delegate

//滑动过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_dataList.count > 0){
        NSInteger cellIndex = [self getCellIndexByScrollPosition];
        NSInteger dataIndex = [self getDataIndexByCellIndex:cellIndex];
        if(dataIndex < 0 || dataIndex >= self.dataList.count){
            return;
        }
        if(_lastDataIndex != dataIndex){
            _lastDataIndex = dataIndex;
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
            if(_indexChangeCallback){
                _indexChangeCallback(cell, [self _makeCellContext:dataIndex]);
            }
        }
    }
}

//开始划动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}

//停止滑动（手势）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(_isCycleScroll && _isAutoScroll && _dataList.count > 1){
        [self startTimer];
    }
    [self adjustCyclePosition];
    [self triggerStopToItemCallback];
}

//停止滑动（代码）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(_isCycleScroll && _isAutoScroll && _dataList.count > 1){
        [self startTimer];
    }
    [self adjustCyclePosition];
    [self triggerStopToItemCallback];
}

#pragma mark - Timer

-(void)startTimer{
    if(self.source == nil){
        self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        if (self.source != nil) {
            __weak typeof(self) weak = self;
            dispatch_source_set_timer(self.source,dispatch_walltime(NULL, self.autoScrollIntervalSeconds*NSEC_PER_SEC),self.autoScrollIntervalSeconds*NSEC_PER_SEC,0);
            dispatch_source_set_event_handler(self.source, ^{
                [weak scrollToNext];
            });
        }
        self.suspended = YES;
    }
    if(self.suspended && self.source){
        dispatch_resume(self.source);
        self.suspended = NO;
    }
}

-(void)stopTimer{
    if (self.suspended) return;
    if(self.source){
        dispatch_suspend(self.source);
    }
    self.suspended = YES;
}

-(void)scrollToNext{
    if(_dataList.count > 1){
        NSInteger cellIndex = [self getCellIndexByScrollPosition];
        NSInteger target = cellIndex + 1;
        //容错
        NSInteger numOfCells = [self collectionView:self.collectionView numberOfItemsInSection:0];
        if(target >= numOfCells){
            target = numOfCells - 1;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:target inSection:0] atScrollPosition:(_scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionLeft:UICollectionViewScrollPositionTop) animated:YES];
    }
}

-(void)deallocTimer{
    if(self.source){
        dispatch_source_set_event_handler(self.source, ^{});
        dispatch_source_cancel(self.source);
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        if(self.suspended && self.source){
            dispatch_resume(self.source);
            self.suspended = NO;
        }
    }
}

#pragma mark - Methods

-(xBannerCellContext*)_makeCellContext:(NSInteger)dataIndex{
    xBannerCellContext *context = [xBannerCellContext new];
    id data = self.dataList[dataIndex];
    context.dataIndex = dataIndex;
    context.data = data;
    return context;
}

-(void)adjustCyclePosition{
    if(_isCycleScroll && _dataList.count > 1){
        NSInteger cellIndex = [self getCellIndexByScrollPosition];
        if(cellIndex == 0){
            [self scrollToDataIndex:_dataList.count - 1 animated:NO];
        }
        if(cellIndex == _dataList.count + 1){
            [self scrollToDataIndex:0 animated:NO];
        }
    }
}

-(NSInteger)getCellIndexByScrollPosition{
    if(_collectionView){
        if(_scrollDirection == UICollectionViewScrollDirectionHorizontal){
            NSInteger cellIndex = (NSInteger)ceil((_collectionView.contentOffset.x + _itemSize.width * 0.5)/_itemSize.width -1);
            return cellIndex;
        }
        else{
            NSInteger cellIndex = (NSInteger)ceil((_collectionView.contentOffset.y + _itemSize.height * 0.5)/_itemSize.height -1);
            return cellIndex;
        }
    }
    return -1;
}

-(NSInteger)getDataIndexByCellIndex:(NSInteger)cellIndex{
    if(_dataList.count > 0){
        if(_dataList.count <= 1){
            return cellIndex;
        }
        if(!_isCycleScroll){
            return cellIndex;
        }
        if(cellIndex == 0){
            return _dataList.count - 1;
        }
        else if(cellIndex >= 1 && cellIndex <= _dataList.count){
            return cellIndex - 1;
        }
        else{
            return 0;
        }
    }
    else{
        return -1;
    }
}

-(NSInteger)getCurrentDataIndex{
    return [self getDataIndexByCellIndex:[self getCellIndexByScrollPosition]];
}

-(void)scrollToDataIndex:(NSInteger)dataIndex animated:(BOOL)animated{
    if(_dataList){
        if(!_isCycleScroll || _dataList.count <= 1){
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:dataIndex inSection:0] atScrollPosition:(_scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionLeft:UICollectionViewScrollPositionTop) animated:animated];
        }
        else{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:dataIndex + 1 inSection:0] atScrollPosition:(_scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionLeft:UICollectionViewScrollPositionTop) animated:animated];
        }
    }
}

/// 初始化时将控件定位到正确位置
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if(_isCycleScroll && _dataList.count > 1){
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:(_scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionLeft:UICollectionViewScrollPositionTop) animated:NO];
    }
}


-(void)triggerStopToItemCallback{
    if(_stopToItemCallback){
        NSInteger cellIndex = [self getCellIndexByScrollPosition];
        NSInteger dataIndex = [self getDataIndexByCellIndex:cellIndex];
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
        _stopToItemCallback(cell, [self _makeCellContext:dataIndex]);
    }
}

@end
