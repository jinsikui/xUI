

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface x9PatchParser : NSObject


/// 解析Android处理完成的9-patch png图片
/// 使用其中的可拉伸位置信息生成可伸缩的UIImage
/// @param data png图片数据
/// @param scale 图片是3x or 2x or 1x
/// @return 返回可拉伸的UIImage，对于没有拉伸信息的png会返回原图片
+(UIImage*)resizableImageFromPngData:(NSData*)data scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
