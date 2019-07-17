//
//  WaterMarkOpenGL.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/12.
//  Copyright © 2019 py. All rights reserved.
//

#import "WaterMarkOpenGL.h"
#import "WMOpenGL.h"

@implementation WaterMarkOpenGL

+ (UIImage *)py_openGLWaterMarkWithInfo:(WaterMarkInfo*)info
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
    
    WMOpenGL* imp = [WMOpenGL new];
    imp.bgImage = info.image;
    imp.textImage = textImage;
    imp.textRect = textRect;

    UIImage* endImg = [imp resultImage];
    
    return endImg;
}

@end
