

#import "xImageTitleButton.h"

@implementation xImageTitleButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.spacing = 0;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.spacing = 0;
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (self.customTitleHeight > 0) {
        titleRect.size.height = self.customTitleHeight;
    }
    return CGRectMake(0,
                      CGRectGetHeight(contentRect) - CGRectGetHeight(titleRect),
                      CGRectGetWidth(contentRect),
                      CGRectGetHeight(titleRect));
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    CGRect titleRect = [self titleRectForContentRect:contentRect];
    if (self.customImageSize.width > 0 &&
        self.customImageSize.height > 0) {
        imageRect.size = self.customImageSize;
    }
    CGFloat imageViewY = (CGRectGetHeight(contentRect) - CGRectGetHeight(titleRect) - self.spacing) / 2.f - CGRectGetHeight(imageRect) / 2.f;
    imageViewY = imageViewY > 0 ? imageViewY : 0;
    return CGRectMake(CGRectGetWidth(contentRect) / 2.f - CGRectGetWidth(imageRect) / 2.f,
                      imageViewY,
                      CGRectGetWidth(imageRect),
                      CGRectGetHeight(imageRect));
}

- (CGSize)intrinsicContentSize {
    if (self.imageView.image) {
        CGSize labelSize = [self.titleLabel sizeThatFits:
                            CGSizeMake(CGRectGetWidth([self contentRectForBounds:self.bounds]),
                                       CGFLOAT_MAX)];
        return CGSizeMake(labelSize.width, self.imageView.image.size.height + labelSize.height);
    }
    return [super intrinsicContentSize];
}

@end
