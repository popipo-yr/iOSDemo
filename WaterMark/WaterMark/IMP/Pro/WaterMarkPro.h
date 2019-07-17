//
//  WaterMarkPro.h
//  WaterMark
//
//  Created by RuiYang on 2019/7/9.
//  Copyright © 2019 py. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterMarkInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterMarkPro : NSObject

+ (UIImage *)py_ProWaterMarkWithInfo:(WaterMarkInfo*)info;

@end

NS_ASSUME_NONNULL_END
