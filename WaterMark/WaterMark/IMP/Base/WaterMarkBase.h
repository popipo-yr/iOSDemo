//
//  WaterMarkBase.h
//  WaterMark
//
//  Created by RuiYang on 2019/7/8.
//  Copyright © 2019 py. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterMarkInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterMarkBase : NSObject

+ (UIImage *)py_BaseWaterMarkWithInfo:(WaterMarkInfo*)info;

@end

NS_ASSUME_NONNULL_END
