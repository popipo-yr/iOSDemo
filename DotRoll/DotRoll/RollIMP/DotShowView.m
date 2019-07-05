//
//  MaskDraw.m
//  MaskAnimation
//
//  Created by RuiYang on 2019/7/4.
//  Copyright © 2019 py. All rights reserved.
//

#import "DotShowView.h"

@implementation DotShowView{
    
    CAShapeLayer* _dotsLayer;
}

- (void)willMoveToSuperview:(UIView*)newSuperview {
    if (nil != newSuperview) {
        [self setupLayer];
    } else {
        [_dotsLayer removeFromSuperlayer];
        _dotsLayer = nil;
    }
}

- (void)setupLayer {
    CALayer *layer = self.animatedLayer;
    [self.layer addSublayer:layer];
    
    CGRect rect = self.bounds;
    layer.position = CGPointMake(CGRectGetMidX(rect),
                                 CGRectGetMidY(rect));
}

- (CAShapeLayer*)animatedLayer {
    if(!_dotsLayer) {
        
        CGRect rect = self.bounds;

        //生成圆点Path
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPoint center = CGPointMake(rect.size.width * 0.5,
                                     rect.size.height * 0.5);
        //初始圆点的中心离视图的中心的距离
        CGFloat radius = rect.size.width * 0.5f
        - self.maxRadiusOfDot - self.lengthOfDot2Edge;
       
        //每个圆点占的角度
        int perAngele = 360 / self.numberOfDots;
        //开始点在1点钟方向
        int startAngele = -90 + perAngele;
        
        //增加一个圆点增加的半径
        float perAddRadiusOfDot = (self.maxRadiusOfDot - self.minRadiusOfDot)
        / (self.numberOfDots - 1);
        
        //中间圆点位置，奇数为整数，偶数带小数位0.5
        float midNum = (self.numberOfDots + 1) / 2.0f;
        //圆点离中点的距离缩小常量
        float c_minus_radius = 3;
        
        //前半圈结束圆点位置 圆点数为8值为3 圆点数为9值为4
        int indexOfPreCircleEnd = (self.numberOfDots + 1) / 2 - 1;
        //圆点间缩短距离常量
        float c_minus_dot = 10.0f;
        
        //从小到大，顺时针，绘制圆点
        for (int i = 0; i < self.numberOfDots; i++) {
            
            //前半圈相邻原点间的距离进行缩小处理
            float lessValue = i < indexOfPreCircleEnd ?
            (indexOfPreCircleEnd - i) * c_minus_dot : 0;
            
            float curAngele = startAngele + i*perAngele + lessValue; //注意方向
            float dotRadius = self.minRadiusOfDot + perAddRadiusOfDot * i;
            
            //缩短最大和最小圆点离圆心的距离，通过中间绝对值计算
            CGFloat needRaduis =
            radius - fabs((i + 1) - midNum) * c_minus_radius;
            
            CGPoint p =
            [self _dotCenterPointWithViewCenter:center
                                          angle:curAngele
                                         radius:needRaduis];
            
            CGRect curRect = CGRectZero;
            curRect.origin.x = p.x - dotRadius * 0.5;
            curRect.origin.y = p.y - dotRadius * 0.5;
            curRect.size.width = dotRadius;
            curRect.size.height = dotRadius;
            
            CGPathAddEllipseInRect(path, nil, curRect);
        }
        
        //设置渐变遮罩
        CALayer *maskLayer = [CALayer layer];
        
        NSURL *url = [NSBundle.mainBundle
                      URLForResource:NSStringFromClass(self.class)
                      withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        NSString *imagePath = [imageBundle pathForResource:@"mask" ofType:@"png"];
        
        maskLayer.contents = (__bridge id)[UIImage imageWithContentsOfFile:imagePath].CGImage;
        maskLayer.frame = rect;

        //创建
        _dotsLayer = [CAShapeLayer layer];
        _dotsLayer.contentsScale = [[UIScreen mainScreen] scale];
        _dotsLayer.frame = CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
        
        _dotsLayer.fillColor = [UIColor whiteColor].CGColor;
        _dotsLayer.path = path;
        _dotsLayer.mask = maskLayer;

        /*旋转动画模拟时钟走动 位置变化为 0 ->  0  ->  1  ->  1  -> 2   -> 2   ->...
                           时间变化为 0 -> 0.1 -> 0.1 -> 0.2 -> 0.2 -> 0.3 ->...
         
         0保持了十分之1的时间后瞬间变为1，1保持了十分之1的时间后瞬间变为2，。。。。
         */
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];

        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        
        NSMutableArray* values = NSMutableArray.new;
        for (int i = 0; i < self.numberOfDots; i++) {
            //缩小减少的角度
             float lessAngule = i < indexOfPreCircleEnd ?
            (indexOfPreCircleEnd - i) * c_minus_dot : 0;
            //1.5f 位置开始在第一个圆点的位置 0.5由于Mask图片刚好隔断了半个圆点
            float curAngele = 0 + (i + 1.5f)*perAngele + lessAngule;
            [values addObject: @(curAngele * (M_PI / 180))];
            [values addObject: @(curAngele * (M_PI / 180))];
        }
        
        //模拟的时间片
        NSMutableArray* keyTimes = NSMutableArray.new;
        for (int i = 0; i < self.numberOfDots; i++) {
            [keyTimes addObject:@(i  / (self.numberOfDots * 1.0))];
            [keyTimes addObject:@((i + 1) / (self.numberOfDots * 1.0))];
        }
        
        animation.keyTimes = keyTimes;
        animation.values = values;
        animation.duration = self.animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_dotsLayer.mask addAnimation:animation forKey:@"rotate"];
    }
    
    return _dotsLayer;
}


- (CGPoint) _dotCenterPointWithViewCenter:(CGPoint) center
                                    angle:(CGFloat) angle
                                   radius:(CGFloat) radius{

    CGFloat x = radius * cosf(angle * M_PI / 180);
    CGFloat y = radius * sinf(angle * M_PI / 180);
    return CGPointMake(center.x + x, center.y + y);
}

@end
