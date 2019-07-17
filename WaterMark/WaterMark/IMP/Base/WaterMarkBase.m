//
//  WaterMarkBase.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/8.
//  Copyright © 2019 py. All rights reserved.
//

#import "WaterMarkBase.h"

@implementation WaterMarkBase

// 给图片添加文字水印：
+ (UIImage *)py_BaseWaterMarkWithInfo:(WaterMarkInfo*)info{

    CGSize imgSize = info.image.size;
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    //2.绘制图片
    [info.image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    //添加水印文字
    CGRect textRect = [info drawTextRect];
    float fontSize = [info autoFontSize];
    [info.text drawInRect:textRect withAttributes:
  @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
//    [info.text drawAtPoint:info.point withAttributes:info.textDrawInfo];
    //3.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}



@end
