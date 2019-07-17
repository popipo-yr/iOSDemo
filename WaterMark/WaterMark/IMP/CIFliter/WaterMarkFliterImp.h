//
//  WaterMarkFliterImp.h
//  WaterMark
//
//  Created by RuiYang on 2019/7/10.
//  Copyright © 2019 py. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterMarkInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterMarkFliterImp : NSObject

+ (UIImage *)py_filterWaterMarkWithInfo:(WaterMarkInfo*)info;


@end

NS_ASSUME_NONNULL_END
