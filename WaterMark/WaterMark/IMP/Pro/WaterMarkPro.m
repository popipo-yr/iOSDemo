//
//  WaterMarkPro.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/9.
//  Copyright © 2019 py. All rights reserved.
//

#import "WaterMarkPro.h"
#import <CoreText/CoreText.h>

@implementation WaterMarkPro

+ (UIImage *)py_ProWaterMarkWithInfo:(WaterMarkInfo*)info
{
    //计算数据
    CGSize imgSize = info.image.size;
    CGRect imgRect = CGRectZero;
    imgRect.size = imgSize;
    
    CGRect textRect = [info drawTextRect];
    
    //获取需要处理的点
    NSArray* points = [self pointsNeedProcess:info];
    if (points == nil || points.count == 0) {
        return nil;
    }
    
    //获取原始图片的数据 进行点处理
    CGContextRef ctx = [self createARGBBitmapContextWithSize:info.image.size];
    
    CGContextDrawImage(ctx, imgRect, info.image.CGImage);
    
    void* data = CGBitmapContextGetData (ctx);
    if (data == NULL) {
        [self destroyBitmapContext:ctx];
        return nil;
    }
    
    //处理数据
    [self processImgData:data
                  points:points
                imgWidth:info.image.size.width
                   shift:textRect.origin];
    
    //从修改后的Data创建数据
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    UIImage * img = [[UIImage alloc] initWithCGImage:imgRef];

    [self destroyBitmapContext:ctx];
    
    return img;
}

+ (void)processImgData:(unsigned char*)imgData
                points:(NSArray*)points
              imgWidth:(CGFloat)width
                 shift:(CGPoint)shiftPoint //偏移的点，文字开始的点
{
    if (imgData == nil || points.count == 0) {
        return;
    }
    
    for (NSValue* value in points) {
        CGPoint point = value.CGPointValue;
        
        int w = point.x + shiftPoint.x;
        int h = point.y + shiftPoint.y;
        
        int offset = 4 * (w + h * width);
//        int alpha =  imgData[offset];
        int red = imgData[offset+1];
        int green = imgData[offset+2];
        int blue = imgData[offset+3];
        
        //图片处理，忽略通明通道
//        int y_yuv = (red*0.299 + green*0.578 + blue*0.114);
//        * (alpha / 255.0f);
//        BOOL isLight = y_yuv >= 100;
        
        int max = MAX( MAX(red, green), blue);
        float b_hsb = max / 255.0f;
        BOOL isLight = b_hsb > 0.5f;
        
        //颜色反转
        if(isLight){ //浅色变黑
            imgData[offset] = 255;
            imgData[offset+1] = 0;
            imgData[offset+2] = 0;
            imgData[offset+3] = 0;
            
        }else{  //深色变白
            imgData[offset] = 255;
            imgData[offset+1] = 255;
            imgData[offset+2] = 255;
            imgData[offset+3] = 255;
        }
    }
}

//返回处理的点 没有偏移量
+ (NSArray*) pointsNeedProcess:(WaterMarkInfo*)info
{
    //计算数据
    CGRect textRect = [info drawTextRect];
    float fontSize = [info autoFontSize];
    
    //高度不够会导致CTFrameDraw后无效果，CTLineDraw无影响
    //CTFramesetterSuggestFrameSizeWithConstraints，会向上取整，这里同样处理
    textRect.size.height = ceilf(textRect.size.height);
    
    CGRect needRect = textRect;
    needRect.origin = CGPointZero;
    
    
    //创建上下文
    CGContextRef ctx = [self createARGBBitmapContextWithSize:textRect.size];
    if (ctx == NULL) {
        return nil;
    }
    
    void* data = CGBitmapContextGetData (ctx);
    if (data == NULL) {
        CGContextRelease(ctx);
        return nil;
    }
    
    /*
    //位置反转
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, needRect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
     */
    
    NSAttributedString* attrStr =
    [[NSAttributedString alloc]
     initWithString:info.text
     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                  NSForegroundColorAttributeName : UIColor.redColor,
                  }];
    
    
    CTFramesetterRef frameSetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    
    //创建可变path
    CGPathRef path = CGPathCreateWithRect(needRect, NULL);
    
    //获取frame
    CTFrameRef frame =
    CTFramesetterCreateFrame(frameSetter,
                             CFRangeMake(0, attrStr.length), path, NULL);
    
    //Context尺寸不够会导致无任何效果
    CTFrameDraw(frame, ctx);
    
    /*
     //单行可以如下处理
     CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrStr);
     CTLineDraw(line, ctx);
     CFRelease(line);
     */

    //获取需要处理的位置
    NSArray* points = [self pointsNeedCalcAboutData:data size:needRect.size];
    
    CFRelease(frame);
    CFRelease(frameSetter);
    [self destroyBitmapContext:ctx];

    return points;
}

+ (NSArray *) pointsNeedCalcAboutData:(unsigned char*) data size:(CGSize)size {
    
    NSMutableArray* retPoints = NSMutableArray.new;
    
    for (size_t h = 0; h < size.height; h++) {
        for (size_t w = 0; w < size.width; w++) {
            
            int offset = 4 * (w + h * size.width);
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            
            if (red != 0 || green != 0 || blue != 0) {
                CGPoint point = CGPointMake(w, h);
                [retPoints addObject:[NSValue valueWithCGPoint:point]];
            }
        }
    }
    
    return retPoints;
}


+ (void) destroyBitmapContext:(CGContextRef) ctx
{
    if (ctx == NULL) {
        return;
    }
    
    void* data = CGBitmapContextGetData (ctx);
    if (data != NULL) {
        free(data);
    }

    CGContextRelease(ctx);
}

//注意传入的size的宽，高必须是整数，不是整数可能出现创建Context失败的情况
+ (CGContextRef) createARGBBitmapContextWithSize:(CGSize)size{
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
 
    bitmapBytesPerRow   = (size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * size.height);
    
    //创建ColorSpace
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL){
        
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    //分配内存，成功后通过「destroyBitmapContext」释放
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL){
        
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    //创建 context
    context = CGBitmapContextCreate (bitmapData,
                                     size.width,
                                     size.height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL){
        
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    //释放ColorSpace
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end

