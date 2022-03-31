

#import "xPager.h"
#import "xCollectionView.h"
#import "UICollectionViewCell+xUI.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@interface xPager(){
    NSInteger _curPageIndex;
}
@property(nonatomic) xCollectionView *gridView;
@property(nonatomic) NSMutableArray<NSNumber*> *dataList;
@end

@implementation xPager

-(UIColor*)_colorFromRGBA:(uint)rgbValue alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0
                            blue:((CGFloat)(rgbValue & 0x0000FF))/255.0
                           alpha:alpha];
}

-(instancetype)initWithPageCount:(NSInteger)pageCount selectColor:(UIColor*)selectColor unselectColor:(UIColor*)unselectColor{
    return [self initWithPageCount:pageCount dotWidth:6 dotInterval:8 selectColor:selectColor unselectColor:unselectColor touchEnabled:NO];
}

-(instancetype)initWithPageCount:(NSInteger)pageCount{
    return [self initWithPageCount:pageCount dotWidth:6 dotInterval:8 selectColor:[UIColor whiteColor] unselectColor:[self _colorFromRGBA:0xFFFFFF alpha:0.31] touchEnabled:NO];
}

-(instancetype)initWithPageCount:(NSInteger)pageCount dotWidth:(CGFloat)dotWidth dotInterval:(CGFloat)dotInterval selectColor:(UIColor*)selectColor unselectColor:(UIColor*)unselectColor touchEnabled:(BOOL)touchEnabled{
    self = [super initWithFrame:CGRectMake(0, 0, (dotWidth+dotInterval)*pageCount-dotInterval, dotWidth)];
    if(self){
        _pageCount = pageCount;
        _dotWidth = dotWidth;
        _dotInterval = dotInterval;
        _selectColor = selectColor;
        _unselectColor = unselectColor;
        _touchEnabled = touchEnabled;
        
        _gridView = [[xCollectionView alloc] initWithCollectionViewCell];
        _dataList = [[NSMutableArray alloc] initWithCapacity:pageCount];
        for(int i=0; i<pageCount; i++){
            if(i == _curPageIndex){
                [_dataList addObject:@(1)];
            }
            else{
                [_dataList addObject:@(0)];
            }
        }
        _gridView.dataList = _dataList;
        __weak typeof(self) weak = self;
        _gridView.buildCellCallback = ^(UICollectionViewCell *cell, xCollectionViewCellContext *context) {
            cell.layer.cornerRadius = dotWidth / 2.0;
            int select = [cell.x_data intValue];
            if(select){
                cell.backgroundColor = selectColor;
            }
            else{
                cell.backgroundColor = unselectColor;
            }
        };
        _gridView.selectCellCallback = ^(UICollectionViewCell *cell, xCollectionViewCellContext *context) {
            if(!weak.touchEnabled){
                return;
            }
            NSInteger index = cell.x_indexPath.item;
            for(int i=0; i<weak.pageCount; i++){
                weak.dataList[i] = @(0);
            }
            weak.dataList[index] = @(1);
            [weak.gridView reloadData];
            if(weak.selectCallback){
                weak.selectCallback(index);
            }
        };
        _gridView.itemSize = CGSizeMake(dotWidth, dotWidth);
        _gridView.interitemSpace = dotInterval;
        [self addSubview:_gridView];
        [_gridView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        [_gridView reloadData];
    }
    return self;
}

-(NSInteger)curPageIndex{
    return _curPageIndex;
}

-(void)setCurPageIndex:(NSInteger)curPageIndex{
    if(curPageIndex < 0 || curPageIndex >= _pageCount){
        return;
    }
    _curPageIndex = curPageIndex;
    for(int i=0; i<_pageCount; i++){
        _dataList[i] = @(0);
    }
    _dataList[curPageIndex] = @(1);
    [_gridView reloadData];
}

@end
