//
//  MaskDraw.h
//  MaskAnimation
//
//  Created by RuiYang on 2019/7/4.
//  Copyright © 2019 py. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DotShowView : UIView

@property (nonatomic, strong) UIColor* dotColor;

@property (nonatomic, assign) int  numberOfDots; //圆点数量
@property (nonatomic, assign) CGFloat lengthOfDot2Edge; //圆点里边框的距离
@property (nonatomic, assign) CGFloat maxRadiusOfDot; //圆点最大半径
@property (nonatomic, assign) CGFloat minRadiusOfDot; //圆点最小半径
@property (nonatomic, assign) CGFloat animationDuration; //动画时长



@end

NS_ASSUME_NONNULL_END
