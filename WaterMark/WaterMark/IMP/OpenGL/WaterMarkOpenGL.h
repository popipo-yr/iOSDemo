//
//  WaterMarkOpenGL.h
//  WaterMark
//
//  Created by RuiYang on 2019/7/12.
//  Copyright © 2019 py. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterMarkInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterMarkOpenGL : NSObject

+ (UIImage *)py_openGLWaterMarkWithInfo:(WaterMarkInfo*)info;


@end

NS_ASSUME_NONNULL_END
