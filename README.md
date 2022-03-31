# <a name="top"></a>xUI

* [概述](#概述)
* [安装](#安装)
* [使用](#使用)
* [xCollectionView](#xcollectionview)
   * [简单列表](#simplelist)
   * [多section列表](#sectionlist)
   * [向左靠齐布局](#alignleft)
   * [下拉刷新](#refresh)
   * [分页](#paging)
   * [拖拽排序](#drag)
* [xTableView](#xtableview)
   * [概述](#overview)
   * [左滑操作](#leftswipe)
* [xBanner](#xbanner)
   * [简单例子](#bannerexample)
   * [用作tab切换](#bannercomplicated)
   * [接口概览](#bannerinterface)
* [xPager](#xpager)
   * [用法举例](#xpagerexample)  
* [xWebView](#xwebview)
   * [基本用法](#xwebviewbasic)
   * [与JS交互](#xwebviewjs)
   * [定制ui](#xwebviewui)
* [xToast](#xtoast)
   * [用法举例](#xtoastexample)
* [xLoading](#xloading)
   * [用法举例](#xloadingexample)  
* [xAlert](#xalert)
   * [用法举例](#xalertexample) 
* [xCornerView](#xcornerview)
   * [用法举例](#xcornerexample) 
* [xGradientView](#xgradientview)
   * [用法举例](#xgradientexample) 
* [xBasePopView](#xbasepopview)
   * [单独使用](#xpopviewexample) 
   * [结合弹窗队列使用](#xpopviewqueue) 
* [xViewFactory](#xviewfactory)
   * [用法举例](#xviewfactoryexample) 

## 概述

业务无关的通用iOS UI组件库，支持ObjC & Swift

## 安装

通过pod引用，在podfile增加下面一行，通过tag指定版本
```
pod 'xUI',     :git => "https://github.com/jinsikui/xUI.git", :tag => 'v2.0.0-0'
```
 objc代码中引入：
```
#import <xUI/xUI.h>
```
 swift代码中引入：
```
在项目的plist文件中配置置 'Objective-C Bridging Header = xxx.h'，在xxx.h中添加一行：
#import <xUI/xUI.h>
```

## 使用

### xCollectionView 
[回顶](#top) 

```
封装了UICollectionView，使用丰富的属性和callback简化代码，支持下拉刷新，分页，拖拽排序等功能
```

#### <a name="simplelist"></a> - 简单列表

![Alt text](/Readme/pay-rank-list.jpeg)

```objc
// 创建组件
xCollectionView *cv = [[xCollectionView alloc] initWithCollectionViewCell]; // initWithCellClass:CHPositionCell.class

// 水平滚动（布局）
cv.scrollDirection = UICollectionViewScrollDirectionHorizontal; // 默认vertical
cv.clipsToBounds = false;

// 不允许用户滑动
cv.isScrollEnabled = false;

// 固定item size, 非固定size参考itemSizeCallback
cv.itemSize = CGSizeMake(28, 28);

// 水平滚动：列间距，垂直滚动：行间距
cv.lineSpace = 4;

// 创建cell callback
cv.buildCellCallback = ^(UICollectionViewCell *cell, xCollectionViewCellContext *context) {
   // cell.x_data is the element in cv.dataList
   LivePayRankItem *item = cell.x_data;
   //
   UIImageView *avatarView = [cell viewWithTag:PAYRANK_CELL_AVATAR_TAG];
   UIImageView *crownView = [cell viewWithTag:PAYRANK_CELL_CROWN_TAG];
   if (avatarView == nil) {
         avatarView = //...
         crownView = //...
         avatarView.tag = PAYRANK_CELL_AVATAR_TAG;
         crownView.tag = PAYRANK_CELL_CROWN_TAG;
         [cell addSubview:avatarView];
         [cell addSubview:crownView];
         // layout them ...
   }
   // refresh cell UI
   [avatarView lv_showAvatar:item.avatar width:27 placeholderImage:[LiveUser defaultAvatar]];
   crownView.image = [UIImage imageNamed:[NSString stringWithFormat:@"live-crown-%ld",(long)item.rank]];
};

// 设置数据
NSArray<LivePayRankItem*> *dataList = ...
cv.dataList = dataList;

// 每次dataList改变, 调reloadData()
[cv reloadData];
```

#### <a name="sectionlist"></a> - 多section列表

![Alt text](/Readme/section-list.jpeg)

```objc
// 创建组件
// 需要把所有section的cellClass放进一个数组传进去
xCollectionView *cv = [[xCollectionView alloc] initWithCellClasses:@[CHPositionCell.class]];
// 整体上下滚动
cv.scrollDirection = UICollectionViewScrollDirectionVertical;
__weak typeof(self) weakSelf = self;

// 构建cell UI
cv.buildCellCallback = ^(UICollectionViewCell * _Nonnull cell, xCollectionViewCellContext * _Nonnull context) {
   
   // 任意类型用户自定义section相关数据
   NSDictionary *dic = context.section.sectionData;
   CHPositionType type = [dic[@"type"] unsignedIntegerValue];
   
   // context.data: 每个cell对应的数据（ == cell.x_data）
   [((CHPositionCell *)cell) updateWithType:type model:context.data];
};

// 构建每个section的header UI
cv.buildHeaderCallback = ^UICollectionReusableView * _Nullable(UICollectionReusableView * _Nonnull view, NSInteger sectionIndex, xCollectionViewSection * _Nonnull section) {
   
   NSDictionary *dic = section.sectionData;
   CHPositionType type = [dic[@"type"] unsignedIntegerValue];
   
   if (type == CHPositionTypeHostin) {
         // 第一个section没有header
         return nil;
   } else {
         // 第二个section
         UILabel *headerLabel = [view viewWithTag:kCHMicPositionHeaderTag];
         if (!headerLabel) {
            headerLabel = [xViewFactory labelWithText:@"围观用户" font:[xFont semiboldPFWithSize:13] color:[xColor fromRGB:0x6F798E] alignment:NSTextAlignmentLeft];
            headerLabel.tag = kCHMicPositionHeaderTag;
            [view addSubview:headerLabel];
            [headerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
               make.leading.mas_equalTo(view).offset(25);
               make.bottom.mas_equalTo(view);
            }];
         }
         return view;
   }
};
cv.itemSizeCallback = ^CGSize(xCollectionViewCellContext * _Nonnull context) {
   // cell size
   // ...
};
cv.headerSizeCallback = ^CGSize(xCollectionViewSection * _Nonnull sectionData, NSInteger sectionIndex) {
   // 每个section的header size
   // ...
};
cv.sectionInsetCallback = ^UIEdgeInsets(xCollectionViewSection * _Nonnull sectionData, NSInteger sectionIndex) {
   // 每个section内容的整体外边距
   // ...
};
cv.lineSpaceCallback = ^CGFloat(xCollectionViewSection * _Nonnull sectionData, NSInteger sectionIndex) {
   // cv.scrollDirection == .vertical时，上下两行cell之间的间距
   // ...
};
cv.interitemSpaceCallback = ^CGFloat(xCollectionViewSection * _Nonnull sectionData, NSInteger sectionIndex) {
   // cv.scrollDirection == .vertical时，左右两个cell之间的间距
   // ...
};

// 构造数据
NSMutableArray<xCollectionViewSection*> *array = [NSMutableArray array];

// 第一个section
xCollectionViewSection *hostinSection = [[xCollectionViewSection alloc] init];

// section中的列表数据
hostinSection.dataList = self.hostinUserList;

// 用户自定义的section数据
hostinSection.sectionData = @{@"type" : @(CHPositionTypeHostin)};

// 每个section可以设置不同的cellClass，xCollectionView.initWithCellClasses(:) 要把所有的cellClass放进数组传进去
hostinSection.cellClass = CHPositionCell.class;

[array addObject:hostinSection];


// 第二个section
xCollectionViewSection *audienceSection = [[xCollectionViewSection alloc] init];

// section中的列表数据
audienceSection.dataList = self.audienceList;

// 用户自定义的section数据
audienceSection.sectionData = @{@"type" : @(CHPositionTypeAudience)};

// 每个section可以设置不同的cellClass
audienceSection.cellClass = CHPositionCell.class;

[array addObject:audienceSection];

// 设置数据
cv.dataSectionList = array;
[cv reloadData]; // 显示多section列表
```

#### <a name="alignleft"></a> - 向左靠齐布局

UICollectionView的瀑布流布局，默认情况下，先计算每一行能放下多少个元素，然后把这些元素平均分布到这一行，如下图所示：

![Alt text](/Readme/search-history-wrong.jpeg)

而对于像搜索记录等需求，我们希望这些元素向左靠齐布局。xCollectionView 提供了支持：
```swift
// init中传入isLeftAlign = true 即可
self.historyView = xCollectionView.init(cellClasses: [TSSearchHistoryCell.self], isLeftAlign: true)
```
![Alt text](/Readme/search-history-right.jpeg)

#### <a name="refresh"></a> - 下拉刷新

![Alt text](/Readme/refresh.gif)

`xCollectionView`内部基于`MJRefresh`提供了下拉刷新功能，用法举例：

```objc
// 创建组件
- (void)createView {
   xCollectionView *cv = [[xCollectionView alloc] initWithCellClass:LiveQuitPopViewCell.class];
   self.cv = cv;
   // ......
   // 一旦设置，即开启下拉刷新，返回结果后会自动更新数据并reloadData
   cv.refreshCallback = ^FBLPromise<xCollectionViewPageResult *> * _Nullable{
      return [weakSelf refreshData];
   };
   // 下面这句：在设置了refreshCallback后再隐藏header，这样只能通过调代码refresh()来刷新，不能通过下拉刷新
   // cv.collectionView.mj_header.hidden = YES;

   // 调用refreshCallback，用返回的数据设置dataList然后reloadData()
   [self.cv refresh];
}

// 刷新获取数据的方法，返回FBLPromise
- (FBLPromise<xCollectionViewPageResult *> *)refreshData {
    __weak typeof(self) weakSelf = self;
    int pageSize = 10;
    return [LiveAPI.shared getRoomsWithstatus:LiveRoomStatusLiving page:1 pageSize:pageSize].then(^id (NSDictionary *ret) {
         weakSelf.page = 1; //记录当前是第几页
         // 构造返回数据
         xCollectionViewPageResult *result = [[xCollectionViewPageResult alloc] init];
         NSArray<NSDictionary*> *dataList = ret[@"items"];
         // 是否没有更多数据了
         result.isNoMoreData = dataList.count < pageSize;
         // 数据列表
         result.pageDataList = [dataList x_map:^(NSDictionary *dic) {
            return [[LiveRoomCellModel alloc] initWithDic:dic];
         }];
         return result;
    });
}

```

主要接口如下：

```objc

@interface xCollectionView : UIView

#pragma mark - 下拉刷新

/// 一旦设置，即开启下拉刷新，返回结果后会自动更新数据并reloadData
@property(nonatomic,copy) xCollectionViewRefreshCallback _Nullable refreshCallback;

/// 分页刷新组件类型，必须设置为MJRefreshHeader的子类否则设置无效，默认为+defaultRefreshHeaderClass
@property(nonatomic) Class refreshHeaderClass;

/// 默认为MJRefreshNormalHeader
@property(nonatomic,class) Class defaultRefreshHeaderClass;

// 可以通过代码触发refresh
-(FBLPromise<xCollectionViewPageResult*>*)refresh;

// ......
@end

```
其中最核心的`xCollectionViewRefreshCallback`定义如下

```objc

/// 同时用于下拉刷新和分页返回数据
@interface xCollectionViewPageResult : NSObject

/// 如果是下一页：返回数组中的数据会填充到最后一个section的dataList的尾部
/// 如果是刷新：返回的数组中数据会作为xCollectionView.dataList
@property(nonatomic,strong) NSArray *_Nullable pageDataList;

/// 如果是下一页：返回数组中的数据会作为section添加至dataSectionList尾部，不要忘记设置cellClass属性
/// 如果是刷新：返回数组中数据会作为xCollectionView.dataSectionList
@property(nonatomic,strong) NSArray<xCollectionViewSection*> *_Nullable pageSectionList;

/// footer是否变为'没有更多数据'状态
@property(nonatomic,assign) BOOL isNoMoreData;

/// 仅对refreshCallback有效，可用于当第一页就知道没有更多数据时隐藏分页控件（下拉刷新后可以改变）
@property(nonatomic,assign) BOOL shouldHideFooter;

/// 如果设置为true，下拉刷新或加载下一页时，控件不会自动设置/刷新数据，留给业务自己设置数据并调reloadData
@property(nonatomic,assign) BOOL ignoreRetData;

@end

/// 默认会自动调用reloadData
typedef FBLPromise<xCollectionViewPageResult*>*_Nullable(^xCollectionViewRefreshCallback)(void);

```

#### <a name="paging"></a> - 分页

![Alt text](/Readme/next-page.gif)

`xCollectionView`内部基于`MJRefresh`提供了分页功能，用法举例：

```objc
// 创建组件
- (void)createView {
   xCollectionView *cv = [[xCollectionView alloc] initWithCellClass:LiveQuitPopViewCell.class];
   self.cv = cv;
   // ......
   // 一旦设置，即开启分页
   cv.nextPageCallback = ^FBLPromise<xCollectionViewPageResult *> * _Nullable{
      return [weakSelf loadNextPage];
   };
}

// 获取下一页数据
- (FBLPromise<xCollectionViewPageResult *> *)loadNextPage {
    __weak typeof(self) weakSelf = self;
    int pageSize = 10;
    return [LiveAPI.shared getRoomsWithStatus:LiveRoomStatusLiving page:self.page+1 pageSize:pageSize].then(^id (NSDictionary *ret) {
         weakSelf.page += 1; //记录当前是第几页

         // 构造返回数据
         xCollectionViewPageResult *result = [[xCollectionViewPageResult alloc] init];
         NSArray<NSDictionary*> *dataList = ret[@"items"];
         // 是否没有更多数据了
         result.isNoMoreData = dataList.count < pageSize;
         // 一页的数据列表
         result.pageDataList = [dataList x_map:^(NSDictionary *dic) {
            return [[LiveRoomCellModel alloc] initWithDic:dic];
         }];
         return result;
    });
}

```

主要接口如下：

```objc

@interface xCollectionView : UIView

#pragma mark - 分页

/// 一旦设置，即开启分页
@property(nonatomic,copy) xCollectionViewNextPageCallback _Nullable nextPageCallback;

/// 分页刷新组件类型，必须设置为MJRefreshFooter的子类否则设置无效，默认为+defaultRefreshFooterClass
@property(nonatomic) Class refreshFooterClass;

/// 默认为MJRefreshAutoNormalFooter
@property(nonatomic,class) Class defaultRefreshFooterClass;

// ......

@end

```
其中最核心的`xCollectionViewRefreshCallback`定义如下

```objc

/// 同时用于下拉刷新和分页返回数据
@interface xCollectionViewPageResult : NSObject

/// 如果是下一页：返回数组中的数据会填充到最后一个section的dataList的尾部
/// 如果是刷新：返回的数组中数据会作为xCollectionView.dataList
@property(nonatomic,strong) NSArray *_Nullable pageDataList;

/// 如果是下一页：返回数组中的数据会作为section添加至dataSectionList尾部，不要忘记设置cellClass属性
/// 如果是刷新：返回数组中数据会作为xCollectionView.dataSectionList
@property(nonatomic,strong) NSArray<xCollectionViewSection*> *_Nullable pageSectionList;

/// footer是否变为'没有更多数据'状态
@property(nonatomic,assign) BOOL isNoMoreData;

/// 仅对refreshCallback有效，可用于当第一页就知道没有更多数据时隐藏分页控件（下拉刷新后可以改变）
@property(nonatomic,assign) BOOL shouldHideFooter;

/// 如果设置为true，下拉刷新或加载下一页时，控件不会自动设置/刷新数据，留给业务自己设置数据并调reloadData
@property(nonatomic,assign) BOOL ignoreRetData;

@end

/// 默认会自动调用reloadData
typedef FBLPromise<xCollectionViewPageResult*>*_Nullable(^xCollectionViewNextPageCallback)(void);

```

#### <a name="drag"></a> - 拖拽排序

![Alt text](/Readme/drag.gif)

用法举例（swift）:

```swift
func createView() {
   // 创建组件
   cv = xCollectionView.init(cellClass: TSPhotoCell.self)
   // ......
   // 一旦设置，即开启长按拖拽排序，移动过程中dataSectionList(dataList)中的顺序也会随时改变
   cv.moveCallback = { [weak self] moveData in
      self?.movePhoto(moveData)
   }
   // 最后一个cell是添加按钮，不参与拖拽排序
   cv.moveDisableItems = [self.btnModel]

   // 加载数据
   TSAPI.shared().getPhotosWithUserId(TSAuth.shared().userId!).__onQueue(DispatchQueue.main, then: {ret in
      var dataList: [TSUserPhotoModel] = []
      let arr = JSON.init(ret)["items"].array
      for item in arr {
         dataList.append(TSUserPhotoModel.init(json: item))
      }
      if arr.count < 9 {
         // 如果形象照小于9个，显示添加按钮
         dataList.append(self.btnModel)
      }
      // 设置数据
      self.cv.dataList = dataList
      self.cv.reloadData()
      return nil
   })
}

func movePhoto(_ data: xCollectionViewMoveData) {
   if data.action == xCollectionViewMoveActionEnd {
      let end = data.endIndexPath!
      let start = data.startIndexPath!
      // 没有移动
      if end.item == start.item {
         return
      }
      let model = data.sortedDataList[end.item] as! TSUserPhotoModel
      // 通知服务端排序改变
      TSAPI.shared().sortPhoto(model.id, position: end.item).__onQueue(DispatchQueue.main, then: { ret in
         // 调接口成功
         xToast.show("已保存", duration: 1)
         return nil
      }).__onQueue(DispatchQueue.main, catch: { error in
         // 调接口失败，回退
         self.cv.moveItem(from: end, to: start)
         xToast.show("接口失败", duration: 1)
      })
   }
}

```
主要接口如下：

```objc

@interface xCollectionView : UIView
// ......
#pragma mark - 拖拽排序

/// 一旦设置，即开启长按拖拽排序，移动过程中dataSectionList(dataList)中的顺序也会随时改变
@property(nonatomic,copy) xCollectionViewMoveCallback _Nullable moveCallback;

/// 拖拽排序中不参与拖拽的项目（必须是dataSectionList(dataList)中的对象）
@property(nonatomic,strong) NSArray *_Nullable moveDisableItems;

/// 暴露给外界的接口，sectionDataList(dataList)会跟随改变，可用来回退
-(void)moveItemFrom:(NSIndexPath*)from to:(NSIndexPath*)to;

// ......

@end

```
其中核心的`moveCallback`定义如下

```objc
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

/// 触发拖拽的cell的indexPath
@property(nonatomic,strong) NSIndexPath *startIndexPath;

/// 拖拽结束时的indexPath
@property(nonatomic,strong) NSIndexPath *_Nullable endIndexPath;

/// 当action==xCollectionViewMovementActionSwap时，swapFrom，swapTo都不为空，否则为空
@property(nonatomic,strong) NSIndexPath *_Nullable swapFrom;
@property(nonatomic,strong) NSIndexPath *_Nullable swapTo;

/// 按拖拽后新的顺序返回
@property(nonatomic,strong) NSArray *sortedDataList;
@property(nonatomic,strong) NSArray<xCollectionViewSection*> *sortedSectionDataList;

@end

typedef void(^xCollectionViewMoveCallback)(xCollectionViewMoveData*_Nonnull);

```


### xTableView
[回顶](#top)

#### <a name="overview"></a> - 概述

```
内部封装了UITableView，使用丰富的属性和callback简化代码，支持下拉刷新，分页，左划操作等功能
xTableView的使用方法和xCollectionView类似，主要的不同在于xTableView不支持水平列表，但支持每行的左划操作，比如左划删除行
```

#### <a name="leftswipe"></a> - 左划操作

![Alt text](/Readme/leftswipe.gif)

```objc

@interface xTableView : UIView

#pragma mark - 左滑操作

@property(nonatomic,copy) BOOL(^_Nullable canEditRowCallback)(xTableViewCellContext *context);

@property(nonatomic,copy) NSArray<UITableViewRowAction*>*_Nullable(^_Nullable editActionsForRowCallback)(xTableViewCellContext *context);

// ......

@end

```
用法举例（swift）:

```swift

func createUI() {
   tv = xTableView.init(cellClass: TSRoomRowCell.self)
   // ......
   tv.canEditRowCallback = {_ in
      return true
   }
   tv.editActionsForRowCallback = {_ in
      let del = UITableViewRowAction.init(style: .destructive, title: "取消收藏") { [weak self] (_, indexPath) in
            self?.delete(indexPath)
      }
      del.backgroundColor = TSColors.mainColor
      return [del]
   }
   // ......
}

func delete(_ indexPath: IndexPath) {
   let data = self.dataList[indexPath.item]
   TSAPI.shared().deleteData(data.roomId).__onQueue(DispatchQueue.main, then: {_ in
      // UI删除
      self.tv.deleteRow(at: indexPath)
      return nil
   }
}

```

### xBanner
[回顶](#top)

![Alt text](/Readme/banner1.gif)
![Alt text](/Readme/banner2.gif)
```
功能丰富的banner，支持水平和垂直布局，支持循环播放，自动播放，页码回调等功能
```

#### <a name="bannerexample"></a> - 简单例子
![Alt text](/Readme/banner2.gif)
```objc
// 创建控件
xBanner *banner = [[xBanner alloc] initWithCellClass:UICollectionViewCell.class itemSize:CGSizeMake(250, 350)];
[self.view addSubview:banner];
// banner布局 ......

// 开启自动播放
banner.isAutoScroll = true;

// 开启循环播放
banner.isCycleScroll = true;

// 自动播放每页停留时间
banner.autoScrollIntervalSeconds = 1.5f;

// 构建cell
banner.buildCellCallback = ^(UICollectionViewCell * _Nonnull cell, xBannerCellContext * _Nonnull context) {
   UIImageView *imgv = [cell.contentView viewWithTag:1024];
   if(!imgv){
      // 添加一个UIImageView
      imgv = [UIImageView new];
      imgv.clipsToBounds = true;
      imgv.contentMode = UIViewContentModeScaleAspectFill;
      imgv.tag = 1024;

      // 布局
      [cell.contentView addSubview:imgv];
      [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
      }];
   }
   [imgv sd_setImageWithURL:[NSURL URLWithString:(NSString*)cell.x_data]];
};
__weak typeof(self) weak = self;

// 页码回调
banner.indexChangeCallback = ^(UICollectionViewCell * _Nonnull cell, xBannerCellContext * _Nonnull context) {
   weak.pageLabel.text = [NSString stringWithFormat:@"%ld/3", context.dataIndex + 1];
};

// 设置数据
banner.dataList = @[@"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty.jpeg",
                  @"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty4.jpeg",
                  @"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty3.jpeg"];

// 显示数据
[banner reloadData];

// 页码label
_pageLabel = [UILabel new];
[self.view addSubview:_pageLabel];
// label布局 ......
```

#### <a name="bannercomplicated"></a> - 用作tab切换
```
xBanner常用于tab切换的控件，每个tab对应一个banner的cell，cell中是复杂的内容或者列表
此时应该禁止banner重用外层的cell：banner.reuseEnabled = false; 可以在页码回调中更新tab header UI
```

#### <a name="bannerinterface"></a> - 接口概览
```objc
@interface xBanner : UIView

/// 是否支持循环（仅当dataList.count > 1时才起作用）
@property(nonatomic) BOOL isCycleScroll;

/// 是否支持自动播放，仅当 isCycleScroll==YES 时才有意义
@property(nonatomic) BOOL isAutoScroll;

/// 自动播放时间间隔
@property(nonatomic) int autoScrollIntervalSeconds;

/// 是否允许用户手动滑（不影响自动播放的滑动）
@property(nonatomic) BOOL scrollEnabled;

/// 是否支持cell重用（有些情况下比如cell中是xCollectionView，不希望重用外面banner的cell）
@property(nonatomic) BOOL reuseEnabled;

/// 数据源
@property(nonatomic,nullable) NSArray *dataList;

/// 需要告知cell的尺寸，本控件只支持固定尺寸的cell，应当与banner的整体尺寸相同
@property(nonatomic) CGSize itemSize;

/// 水平 or 垂直 banner
@property(nonatomic) UICollectionViewScrollDirection scrollDirection;

/// banner的cell类型，需要是UICollectionViewCell或子类
@property(nonatomic) Class cellClass;

/// 构建cell回调
@property(nonatomic,nullable) xBannerCellCallback buildCellCallback;

/// 点击cell回调
@property(nonatomic,nullable) xBannerCellCallback selectCellCallback;

/// 稳定的停住后回调
@property(nonatomic,nullable) xBannerCellCallback stopToItemCallback;

/// 页码改变回调
@property(nonatomic,nullable) xBannerCellCallback indexChangeCallback;

/// 初始化
-(instancetype)initWithCellClass:(Class)cellClass itemSize:(CGSize)itemSize;

/// 通过代码触发banner滚动
-(void)scrollToDataIndex:(NSInteger)dataIndex animated:(BOOL)animated;

/// 显示banner数据
-(void)reloadData;

@end
```

### xPager
[回顶](#top)
```
可定制尺寸和颜色的圆形页码UI
```
#### <a name="xpagerexample"></a> - 用法举例
![Alt text](/Readme/pager.gif)
```objc

// 页码回调
banner.indexChangeCallback = ^(UICollectionViewCell * _Nonnull cell, xBannerCellContext * _Nonnull context) {
   // 设置当前页
   weak.pager.curPageIndex = context.dataIndex;
};

// 显示页码
xPager *pager = [[xPager alloc] initWithPageCount:4
                                 dotWidth:8
                              dotInterval:8
                              selectColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
                           unselectColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]
                              touchEnabled:true];

// 点选页码圆点后事件
pager.selectCallback = ^(NSInteger page) {
   [weak.banner scrollToDataIndex:page animated:true];
};

// 布局
[self.view addSubview:pager];
[pager mas_makeConstraints:^(MASConstraintMaker *make) {
   make.centerX.mas_equalTo(self.view);
   make.top.mas_equalTo(banner.mas_bottom).offset(20);
   make.size.mas_equalTo(CGSizeMake(8*4 + 8*3, 8));
}];
```

### xWebView
[回顶](#top)
```
封装WKWebView，支持下拉刷新，方便的注册jsbridge，callJS方法等
支持附加UI的定制，可作为基类使用
```
#### <a name="xwebviewbasic"></a> - 基本用法
```objc
webView = xWebView()
webView.beforeNavHandler = { url -> Bool in
   // 用来与router集成 ...
   return true/false
}
// ......
webView.loadUrl(url)
```
#### <a name="xwebviewjs"></a> - 与JS交互
```objc

@interface TSWebView : xWebView
// ......
@end

@implementation TSWebView

-(void)registJsBridges{
   // 调父类方法注册jsbridge
   __weak typeof(self) weakSelf = self;
   [self registNativeCallbackName:@"getDeviceInfo" handler:^id _Nullable(id _Nullable params) {
      return @{
         @"deviceId":xDevice.deviceId
      };
   }];
   [self registNativeCallbackName:@"getAuthInfo" handler:^id _Nullable(id _Nullable params) {
      return @{
         @"id":TSAuth.shared.userId ?: @"",
         @"accessToken":TSAuth.shared.accessToken ?: @"",
         @"name":TSAuth.shared.user.name ?: @"",
         @"avatar":TSAuth.shared.user.avatar ?: @""
      };
   }];
   // ......  
} 
// ......
@end
```

```swift

// 异步延迟返回jsbridge结果
self.webView.registNativeCallbackName("getUserInfo") { params in
   TSAPI.shared().getUserInfo().__onQueue(DispatchQueue.main, then: {ret in
         self.webView.callNativeHandlerJSCallback("getUserInfo", retValue: ret)
   })
   return nil
}

override func viewDidAppear(_ animated: Bool) {
   super.viewDidAppear(animated)
   // 直接call js方法
   self.webView.callJS("window.onVisible", params: nil, resultHandler: nil)
}
```

#### <a name="xwebviewui"></a> - 定制UI
```swift
@interface TSWebView : xWebView  <xWebViewAdditionViewsDelegate>
// ......
@end

@implementation TSWebView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
         // 定制下拉刷新样式
         self.refreshHeaderClass = TSRrefreshHeader.class;
         // 与router集成
         self.beforeNavHandler = ^BOOL(NSString * _Nonnull url) {
            // ......
         };
         // 其它UI样式
         self.additionViewsDelegate = self;
    }
    return self;
}

#pragma mark - xWebViewAdditionViewsDelegate

-(void)showLoading:(xWebView *)webView{
    // (首次加载)显示全屏loading ...
}

-(void)hideLoading:(xWebView *)webView{
    // (首次加载)隐藏全凭loading ...
}

-(void)showFailView:(xWebView *)webView error:(NSError * _Nullable)error{
    // (首次加载)显示全屏错误页 ...
}

-(void)hideFailView:(xWebView *)webView{
    // (首次加载)隐藏全屏错误页 ...
}

-(void)showFailToast:(NSError *_Nullable)error{
    // (非首次)加载失败toast ...
}

@end                     
```

### xToast
[回顶](#top)

![Alt text](/Readme/xToast.gif)
#### <a name="xtoastexample"></a> - 用法举例
```objc
[xToast show:@"我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容,我是特别长的内容" duration:2];
```

### xLoading
[回顶](#top)

![Alt text](/Readme/xLoading.gif)
#### <a name="xloadingexample"></a> - 用法举例
```objc
[xLoading showInWindow:@"加载中..."];
```

### xAlert
[回顶](#top)
```
简单封装了系统的提示弹窗
```
#### <a name="xalertexample"></a> - 用法举例
![Alt text](/Readme/xAlert.jpeg)
```objc
// example 1
[xAlert showSystemAlertWithMessage:@"您的实名认证已通过"];

// example 2
[xAlert showSystemAlertWithTitle:@"提示" message:@"退出直播间会断开与主播的连麦" confirmText:@"再看看" cancelText:@"仍然退出" callback:^(UIAlertAction * _Nonnull action) {
   if([action.title isEqualToString:@"再看看"]){
      // 再看看 ...
   }
   else {
      // 仍然退出 ...
   }
}];
```

### xCornerView
[回顶](#top)
```
可以分别指定view的四个角哪些是圆角的控件
```
#### <a name="xcornerexample"></a> - 用法举例
![Alt text](/Readme/xCornerView.jpeg)
```objc
xCornerView *cv = [[xCornerView alloc] initWithCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft radius:10];
cv.backgroundColor = UIColor.systemBlueColor;
[self.view addSubview:cv];
[cv mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.size.mas_equalTo(CGSizeMake(50, 25));
}];
```

### xGradientView
[回顶](#top)
```
简化颜色渐变的view的创建
```
#### <a name="xgradientexample"></a> - 用法举例
![Alt text](/Readme/xGradientView.jpeg)
```objc
// objc code
xGradientView *gv = [[xGradientView alloc] init];
gv.colors = @[
    (__bridge id)[xColor fromRGBA:0x0000FF alpha:0.76].CGColor,
    (__bridge id)[xColor fromRGBA:0x0000FF alpha:0].CGColor,
];
// 从上到下渐变
gv.startPoint = CGPointMake(0.5, 0);
gv.endPoint = CGPointMake(0.5, 1);

[self.view addSubview:gv];
[gv mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view).offset(120);
    make.size.mas_equalTo(CGSizeMake(50, 25));
}];

// swift code
let cv = xGradientView.init()
cv.colors = [xColor.fromRGBA(0x0000FF, alpha:0.76).cgColor, xColor.fromRGBA(0x0000FF, alpha:0).cgColor]
// 从左到右渐变
cv.startPoint = CGPoint(x: 0, y: 0.5)
cv.endPoint = CGPoint(x: 1, y: 0.5)
// ......
```

### xBasePopView
[回顶](#top)
```
通用的弹窗基类，可以覆盖在window或者任意view上，可配置背景颜色，是否点击空白处关闭，显示前后的回调等
还可以结合xPopViewQueue实现多个弹窗排队显示
```
#### <a name="xpopviewexample"></a> - 单独使用
```objc
@interface ExamplePopView : xBasePopView
@end

@implementation ExamplePopView

- (instancetype)init{
    // level：如果结合xPopViewQueue使用，level决定同一个队列中弹窗的优先级
    self = [super initWithLevel:LivePopViewLevelSystemInfo coverColor:[xColor fromRGBA:0x000000 alpha:.9f] isCloseOnSpaceClick:false];
    if (self) {
        // ......
    }
    return self;
}

// ......
@end

// 显示弹窗
ExamplePopView *popView = [[ExamplePopView alloc] init];
popView.afterShowCallback = ^(xBasePopView *pop){
   // ... 显示后的回调
};
popView.afterHideCallback = ^(xBasePopView *pop){
   // ... 移除后的回调
};
[popView showInView:self.view];
// [popView showInWindow];

// 移除弹窗
[popView hide];
```
#### <a name="xpopviewqueue"></a> - 结合弹窗队列使用
```objc
// 结合弹窗队列使用
self.popVieQueue = [[xPopViewQueue alloc] initWithView:self.view];
// ......
ExamplePopView *popView = [[ExamplePopView alloc] init];
popView.shouldShowCallback = ^BOOL(xBasePopView *pop){
   // ...这个回调仅当结合弹窗队列使用时有意义，用于在要显示队列中弹窗前决定是否要显示，如果返回false会直接丢弃这个弹窗
};
[self.popViewQueue inqueuePopView:popView]; //入队列显示弹窗
// ......
[popView hideAndTryDequeue]; //隐藏当前弹窗并显示队列中下一个弹窗（如果有）
// ......
xBasePopView *curPopView = self.popVieQueue.curPopView; //可以获取队列中当前显示的弹窗

```

### xViewFactory
[回顶](#top)
```
提供几个快捷方法简化UILabel，UIButton，UITextField等常用系统控件的创建
```
#### <a name="xviewfactoryexample"></a> - 用法举例
```objc
// 创建UIlabel
let label = xViewFactory.label(withText: "", font: xFont.mediumPF(withSize: 15), color: TSColors.txtBigTitleColor)

// 创建UIButton
let btn1 = xViewFactory.imageButton(UIImage(named: "personal_barBack")!)
let brn2 = xViewFactory.button(withTitle: name, font: xFont.mediumPF(withSize: 14), titleColor: TSColors.txtRegular2Color, bgColor: xColor.clear)

// 创建UITextField
let txt = xViewFactory.textfiled(with: "", font: xFont.regularPF(withSize: 15), textColor: TSColors.txtSmallTitleColor, textAlignment: .right, verticalAlignment: .center, placeholder: "请输入正确证件号码")

// ......

```

