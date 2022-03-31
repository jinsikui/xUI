

#import "x9PatchParser.h"

@implementation x9PatchParser

+(UIImage*)resizableImageFromPngData:(NSData*)data scale:(CGFloat)scale{
    UIImage *originImg = [UIImage imageWithData:data scale:scale];
    CGSize originSize = originImg.size;
    NSInteger x1 = -1, x2 = -1, y1 = -1, y2 = -1;
    [x9PatchParser _parse9PatchInfo:data x:&x1 x2:&x2 y1:&y1 y2:&y2];
    CGFloat left = 0, right = 0, top = 0, bottom = 0;
    if(x1 > 0 && x2 > 0){
        left = (x1 - 1)/scale;
        right = originSize.width - x2/scale;
    }
    if(y1 > 0 && y2 > 0){
        top = (y1 - 1)/scale;
        bottom = originSize.height - y2/scale;
    }
    return [originImg resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
}

/// 解析出9Patch图片的拉伸信息
/// @param data png图片数据
/// @param x1 水平拉伸起始位置(px)，不存在不设置
/// @param x2 水平拉伸终止位置(px)，不存在不设置
/// @param y1 纵向拉伸起始位置(px)，不存在不设置
/// @param y2 纵向拉伸终止位置(px)，不存在不设置
/// @return png图片格式是否合法（即使不存在拉伸信息，只要png图片格式合法也会返回true）
+(BOOL)_parse9PatchInfo:(NSData*)data x:(NSInteger *)x1 x2:(NSInteger *)x2 y1:(NSInteger *)y1 y2:(NSInteger *)y2{
    uint8_t *bytes = (uint8_t *)data.bytes;
    NSUInteger len = data.length;
    uint32_t i = 0;
    // check PNG signature
    // A PNG always starts with an 8-byte signature: 137 80 78 71 13 10 26 10 (decimal values).
    if ([self readUInt32From:bytes offset:&i] != 0x89504e47 || [self readUInt32From:bytes offset:&i] != 0x0D0A1A0A) {
        return false;
    }
    while (true) {
        int length = [self readUInt32From:bytes offset:&i];
        int type = [self readUInt32From:bytes offset:&i];
        // check for nine patch chunk type (npTc)
        if (type != 0x6E705463) {
            i += (length + 4/*crc*/);
            if(i + 8 >= len){
                return true;
            }
            continue;
        }
        else{
            break;
        }
    }
    //parse 9patch informaton
    i += 1; //skip wasDeserialized byte
    int8_t xNum = bytes[i++];
    int8_t yNum = bytes[i++];
    i += 1; //skip numColors byte
    i += 28; //skip xDivsOffset, yDivsOffset, paddingLeft/Right/Top/Bottom, colorsOffset
    if(xNum >= 2){
        uint32_t v1 = [self readUInt32From:bytes offset:&i];
        uint32_t v2 = [self readUInt32From:bytes offset:&i];
        *x1 = v1;
        *x2 = v2;
        if(xNum > 2){
            i += 4 * (xNum - 2);
        }
    }
    if(yNum >= 2){
        uint32_t v1 = [self readUInt32From:bytes offset:&i];
        uint32_t v2 = [self readUInt32From:bytes offset:&i];
        *y1 = v1;
        *y2 = v2;
    }
    return true;
}

//读取4字节整数，同时改变offset
+(uint32_t)readUInt32From:(uint8_t *)bytes offset:(uint32_t*)offsetP{
    uint32_t u;
    uint32_t offset = *offsetP;
    u = bytes[offset];
    u = (u  << 8) + bytes[offset + 1];
    u = (u  << 8) + bytes[offset + 2];
    u = (u  << 8) + bytes[offset + 3];
    (*offsetP) = offset + 4;
    return u;
}

@end
