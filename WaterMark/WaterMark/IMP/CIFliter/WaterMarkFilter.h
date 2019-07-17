//
//  WaterMarkFilter.h
//  WaterMark
//
//  Created by RuiYang on 2019/7/10.
//  Copyright © 2019 py. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import "WaterMarkInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterMarkFilter : CIFilter

@property (nonatomic, strong) CIImage* bgImage;
@property (nonatomic, strong) CIImage* textImage;
@property (nonatomic, assign) CGRect textRect;

@end

NS_ASSUME_NONNULL_END
