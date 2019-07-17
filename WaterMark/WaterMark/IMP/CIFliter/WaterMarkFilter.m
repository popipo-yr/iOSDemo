//
//  WaterMarkFilter.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/10.
//  Copyright © 2019 py. All rights reserved.
//

#import "WaterMarkFilter.h"

@implementation WaterMarkFilter

static CIKernel  *customKernel = nil;

- (instancetype)init {
    
    self = [super init];
    if (self) {
        if (customKernel == nil)
        {
            NSBundle *bundle = [NSBundle bundleForClass: [self class]];
            NSURL *kernelURL = [bundle URLForResource:@"WaterMark" withExtension:@"cikernel"];
            
            NSError *error;
            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL
                                                            encoding:NSUTF8StringEncoding error:&error];
            if (kernelCode == nil) {
                NSLog(@"Error loading kernel code string in %@\n%@",
                      NSStringFromSelector(_cmd),
                      [error localizedDescription]);
                abort();
            }
            
            NSArray *kernels = [CIKernel kernelsWithString:kernelCode];
            customKernel = [kernels objectAtIndex:0];
        }
    }
    return self;
}


- (CIImage *)outputImage
{
    __weak typeof(self) self_w_ = self;
    
    CIImage *result =
    [customKernel applyWithExtent:_bgImage.extent
                      roiCallback:^CGRect(int index, CGRect destRect) {
                          if (index == 0) {
                              return self_w_.bgImage.extent;
                          }else{
                              return self_w_.textImage.extent;
                          }
                      }
                        arguments:@[_bgImage,
                                    _textImage,
                                    @(_bgImage.extent.size.height),
                                    [CIVector vectorWithCGRect:_textRect]]];
    
    return result;
}
@end
