//
//  WMOpenGL.h
//  WaterMark
//
//  Created by RuiYang on 2019/7/12.
//  Copyright © 2019 py. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMOpenGL : NSObject

@property (nonatomic, strong) UIImage* bgImage;
@property (nonatomic, strong) UIImage* textImage;
@property (nonatomic, assign) CGRect textRect;

- (UIImage*) resultImage;

@end

NS_ASSUME_NONNULL_END
