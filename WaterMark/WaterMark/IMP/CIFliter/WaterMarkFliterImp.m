//
//  WaterMarkFliterImp.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/10.
//  Copyright © 2019 py. All rights reserved.
//

#import "WaterMarkFliterImp.h"
#import "WaterMarkFilter.h"

@implementation WaterMarkFliterImp

+ (UIImage *)py_filterWaterMarkWithInfo:(WaterMarkInfo*)info
{
    //获取需要的参数
    CGRect textRect = [info drawTextRect];
    float fontSize = [info autoFontSize];
    
    CGRect drawRect = textRect;
    drawRect.origin = CGPointZero;
    
    //将文字转为图片
    UIGraphicsBeginImageContextWithOptions(textRect.size, NO, 1.0f);
    
    [info.text drawInRect:drawRect withAttributes:
     @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];

    UIImage * textImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    /*设置滤镜*/
    // 1. 将UIImage转换成CIImage
    CIImage *bgCIImage = [[CIImage alloc] initWithImage:info.image];
    CIImage *textCIImage = [[CIImage alloc] initWithImage:textImage];
    
    // 2. 创建滤镜
    WaterMarkFilter* filter = [[WaterMarkFilter alloc] init];
    // 设置相关参数
    filter.bgImage = bgCIImage;
    filter.textImage = textCIImage;
    filter.textRect = textRect;
    
    // 3. 渲染并输出CIImage
    CIImage *outputImage = [filter outputImage];
    
    // 4. 获取绘制上下文
    CIContext* context = [CIContext contextWithOptions:nil];
    
    // 5. 创建输出CGImage
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    // 6. 释放CGImage
    CGImageRelease(cgImage);
    
    return image;
}

@end
