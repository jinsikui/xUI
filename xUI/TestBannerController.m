

#import "TestBannerController.h"
#import "xBanner.h"
#import "Masonry.h"
#import "SDWebImage.h"
#import "xUI.h"

@interface TestBannerController ()
@property(nonatomic,strong) xPager  *pager;
@property(nonatomic,strong) xBanner *banner;
@end

@implementation TestBannerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"xBanner Test";
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 创建控件
    xBanner *banner = [[xBanner alloc] initWithCellClass:UICollectionViewCell.class itemSize:CGSizeMake(200, 300)];
    _banner = banner;
    [self.view addSubview:banner];
    [banner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(300);
        make.top.mas_equalTo(100);
        make.centerX.mas_equalTo(self.view);
    }];
    banner.isAutoScroll = true;
    banner.isCycleScroll = true;
    banner.autoScrollIntervalSeconds = 1.5f;
    // 构建cell
    banner.buildCellCallback = ^(UICollectionViewCell * _Nonnull cell, xBannerCellContext * _Nonnull context) {
        UIImageView *imgv = [cell.contentView viewWithTag:100];
        if(!imgv){
            imgv = [UIImageView new];
            imgv.clipsToBounds = true;
            imgv.contentMode = UIViewContentModeScaleAspectFill;
            imgv.tag = 100;
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
        weak.pager.curPageIndex = context.dataIndex;
    };
    banner.dataList = @[@"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty.jpeg",
                        @"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty4.jpeg",
                        @"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty3.jpeg",
                        @"https://tuboshu-static.oss-cn-beijing.aliyuncs.com/tuboshu-ios/stuffs/test-beauty5.jpeg"];
    [banner reloadData];
    
    //显示页码
    _pager = [[xPager alloc] initWithPageCount:4
                                      dotWidth:8
                                   dotInterval:8
                                   selectColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
                                 unselectColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]
                                  touchEnabled:true];
    _pager.selectCallback = ^(NSInteger page) {
        [weak.banner scrollToDataIndex:page animated:true];
    };
    [self.view addSubview:_pager];
    [_pager mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(banner.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(8*4 + 8*3, 8));
    }];
}

@end
