

#import "xNavigationBar.h"
#import "View+MASAdditions.h"
#import "xUIUtil.h"

#define xui_str_not_null(x) (x && [x isKindOfClass:[NSString class]] && ((NSString*)x).length > 0)


@interface xNavigationBar()

@end

@implementation xNavigationBar

#pragma mark - Lazy UIs

-(UIView*)bar{
    if(!_bar){
        _bar = [UIView new];
        [self addSubview:_bar];
        [_bar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(xUIUtil.statusBarHeight);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return _bar;
}

-(UILabel*)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bar addSubview:_titleLabel];
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.bar);
        }];
    }
    return _titleLabel;
}

-(UIButton*)leftImgBtn{
    if(!_leftImgBtn){
        _leftImgBtn = [[UIButton alloc] init];
        [_leftImgBtn addTarget:self action:@selector(actionLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bar addSubview:_leftImgBtn];
        [_leftImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
        _leftImgBtn.hidden = true;
    }
    return _leftImgBtn;
}

-(UIButton*)leftTextBtn{
    if(!_leftTextBtn){
        _leftTextBtn = [[UIButton alloc] init];
        _leftTextBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        _leftTextBtn.backgroundColor = UIColor.clearColor;
        [_leftTextBtn addTarget:self action:@selector(actionLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bar addSubview:_leftTextBtn];
        [_leftTextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
        _leftTextBtn.hidden = true;
    }
    return _leftTextBtn;
}

-(UIButton*)rightImgBtn{
    if(!_rightImgBtn){
        _rightImgBtn = [[UIButton alloc] init];
        [_rightImgBtn addTarget:self action:@selector(actionRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bar addSubview:_rightImgBtn];
        [_rightImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
        _rightImgBtn.hidden = true;
    }
    return _rightImgBtn;
}

-(UIButton*)rightTextBtn{
    if(!_rightTextBtn){
        _rightTextBtn = [[UIButton alloc] init];
        _rightTextBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _rightTextBtn.backgroundColor = UIColor.clearColor;
        [_rightTextBtn addTarget:self action:@selector(actionRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bar addSubview:_rightTextBtn];
        [_rightTextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
        _rightTextBtn.hidden = true;
    }
    return _rightTextBtn;
}

#pragma mark - Features

-(void)addBottomShadow{
    UIView *view = [UIView new];
    view.backgroundColor =  [xUIUtil colorFromRGBA:0 alpha:0.15];

    [self.bar addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

-(void)setTitle:(NSString*)title{
    _title = title;
    self.titleLabel.text = title;
}

-(void)setTitleColor:(UIColor*)titleColor{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

-(void)setLeftImg:(NSString*)leftImg{
    _leftImg = leftImg;
    if(xui_str_not_null(leftImg)){

        self.leftText = nil;
        self.leftImgBtn.hidden = false;
        UIImage *image = [UIImage imageNamed:leftImg];
        [self.leftImgBtn setImage:image forState:UIControlStateNormal];
        [self.leftImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(image.size.width + 30);
        }];
    }
    else{
        self.leftImgBtn.hidden = true;
    }
}

-(void)setLeftText:(NSString*)leftText{
    _leftText = leftText;
    if(xui_str_not_null(leftText)){

        self.leftImg = nil;
        self.leftTextBtn.hidden = false;
        [self.leftTextBtn setTitle:leftText forState:UIControlStateNormal];
        [self.leftTextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([xUIUtil x_sizeWithFont:self.leftTextBtn.titleLabel.font maxWidth:CGFLOAT_MAX contentStr:leftText].width);
        }];
    }
    else{
        self.leftTextBtn.hidden = true;
    }
}

-(void)setLeftTextColor:(UIColor*)leftTextColor{
    _leftTextColor = leftTextColor;
    [self.leftTextBtn setTitleColor:leftTextColor forState:UIControlStateNormal];
}

-(void)setRightImg:(NSString*)rightImg{
    _rightImg = rightImg;
    if(xui_str_not_null(rightImg)){

        self.rightText = nil;
        self.rightImgBtn.hidden = false;
        UIImage *image = [UIImage imageNamed:rightImg];
        [self.rightImgBtn setImage:image forState:UIControlStateNormal];
        [self.rightImgBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(image.size.width + 30);
        }];
    }
    else{
        self.rightImgBtn.hidden = true;
    }
}

-(void)setRightText:(NSString*)rightText{
    _rightText = rightText;
    if(xui_str_not_null(rightText)){

        self.rightImg = nil;
        self.rightTextBtn.hidden = false;
        [self.rightTextBtn setTitle:rightText forState:UIControlStateNormal];
        [self.rightTextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([xUIUtil x_sizeWithFont:self.rightTextBtn.titleLabel.font maxWidth:CGFLOAT_MAX contentStr:rightText].width);
        }];
    }
    else{
        self.rightTextBtn.hidden = true;
    }
}

-(void)setRightTextColor:(UIColor*)rightTextColor{
    _rightTextColor = rightTextColor;
    [self.rightTextBtn setTitleColor:rightTextColor forState:UIControlStateNormal];
}

#pragma mark - Constructor

-(instancetype)init{
    self = [super init];
    if(self){
        //默认值
        self.titleColor = [xUIUtil colorFromRGBA:0x222832 alpha:1];
        self.leftImg = @"back-btn";
    }
    return self;
}

-(void)actionRightBtnClick{
    xNavBtnHandler handler = self.rightBtnHandler;
    if(handler){
        handler();
    }
}

-(void)actionLeftBtnClick{
    xNavBtnHandler handler = self.leftBtnHandler;
    if(handler){
        handler();
    }
}

@end
