

#import "UICollectionViewCell+xUI.h"
#import <objc/runtime.h>

@implementation UICollectionViewCell (xUI)

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
