

#import "xCoolPager.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface xCoolPager(){
    int         _pageIndex;
    NSString    *_reuseId;
    int         _dotTag;
}
@property(nonatomic,strong) UICollectionView        *collectionView;
@property(nonatomic,strong) UICollectionViewFlowLayout  *layout;
@property(nonatomic,assign,readonly) CGFloat        edgeSpace;

@end

@implementation xCoolPager

-(UIColor*)_colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}

-(CGFloat)edgeSpace{
    return (_visibleDot -1) / 2.0 * (_dotWidth + _dotSpace);
}

-(CGFloat)pagerWidth{
    return _visibleDot * _dotWidth + (_visibleDot - 1) * _dotSpace;
}

-(int)pageIndex{
    return _pageIndex;
}

-(void)setPageIndex:(int)pageIndex{
    [self setPageIndex:pageIndex animated:YES];
}

-(void)setPageIndex:(int)index animated:(BOOL)animated{
    if(index >= _pageCount || index == _pageIndex){
        return;
    }
    _pageIndex = index;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    if(!animated){
        [self layoutIfNeeded];
        [self scaleCells];
    }
}

-(instancetype)initWithPageCount:(int)pageCount{
    self = [super init];
    if(self){
        _pageCount = pageCount;
        _reuseId = [NSString stringWithFormat:@"%u",arc4random()];
        _dotTag = 1000;
        _dotWidth = 7;
        _dotSpace = 14;
        _visibleDot = 5;
        _minScale = 0.6;
        _minAlpha = 0.3;
        _maxAlpha = 0.8;
        self.backgroundColor = [UIColor clearColor];
        //
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = _dotSpace;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(_dotWidth, _dotWidth);
        _layout.sectionInset = UIEdgeInsetsMake(0, self.edgeSpace, 0, self.edgeSpace);
        //
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = true;
        _collectionView.directionalLockEnabled = true;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = false;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_reuseId];
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.mas_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate & DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _pageCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseId forIndexPath:indexPath];
    UIView *dot = [cell viewWithTag:_dotTag];
    if(dot == nil){
        dot = [UIView new];
        dot.tag = _dotTag;
        dot.layer.cornerRadius = _dotWidth/2.0;
        dot.backgroundColor = [self _colorFromRGBA:0xFFFFFF alpha:0.3];
        [cell addSubview:dot];
        [dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_equalTo(0);
        }];
    }
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self scaleCells];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self scaleCells];
}

-(void)scaleCells{
    NSArray *visibleCells = _collectionView.visibleCells;
    for(UICollectionViewCell *cell in visibleCells){
        CGRect rect = [cell convertRect:cell.bounds toView:self];
        CGFloat disToCenter = fabs(rect.origin.x - self.edgeSpace);
        CGFloat maxDisToCenter = self.edgeSpace;
        CGFloat scale = 1 - disToCenter / maxDisToCenter * (1 - _minScale);
        CGFloat alpha = _maxAlpha - disToCenter / maxDisToCenter * (_maxAlpha - _minAlpha);
        CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
        cell.transform = t;
        UIView *dot = [cell viewWithTag:_dotTag];
        dot.backgroundColor = [self _colorFromRGBA:0xFFFFFF alpha:alpha];
    }
}

@end
