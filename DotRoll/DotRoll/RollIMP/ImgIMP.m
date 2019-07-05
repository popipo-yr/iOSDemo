//
//  ImgIMP.m
//  MaskAnimation
//
//  Created by RuiYang on 2019/7/3.
//  Copyright © 2019 py. All rights reserved.
//

#import "ImgIMP.h"

@implementation ImgIMP{
    
    float _angele;
    NSTimer* _timeer;
    
    UIImageView* _rollImgV;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setups];
    }
    
    return self;
}

- (void) setups{
    
    UIImage* rollImg = [UIImage imageNamed:@"bottom_roll"];
    _rollImgV = [[UIImageView alloc] initWithImage:rollImg];
    
    [self addSubview:_rollImgV];
    
    UIImage* upImg = [UIImage imageNamed:@"mask"];
    UIImageView* upImgV = [[UIImageView alloc] initWithImage:upImg];
    [self addSubview:upImgV];
   
    _rollImgV.translatesAutoresizingMaskIntoConstraints = false;
    upImgV.translatesAutoresizingMaskIntoConstraints = false;

    NSString* h_vfl = @"H:|[view]|";
    NSString* v_vfl = @"V:|[view]|";
    
    NSDictionary *views = @{@"view" : _rollImgV};
    
    NSArray *h_constraints = [NSLayoutConstraint constraintsWithVisualFormat:h_vfl options:0 metrics:nil views:views];
    NSArray *v_constraints = [NSLayoutConstraint constraintsWithVisualFormat:v_vfl options:0 metrics:nil views:views];
    
    [self addConstraints:h_constraints];
    [self addConstraints:v_constraints];
    
    views = @{@"view" : upImgV};
    
    h_constraints = [NSLayoutConstraint constraintsWithVisualFormat:h_vfl options:0 metrics:nil views:views];
    v_constraints = [NSLayoutConstraint constraintsWithVisualFormat:v_vfl options:0 metrics:nil views:views];
    
    [self addConstraints:h_constraints];
    [self addConstraints:v_constraints];
}

#define _C_AddAngele 45.0f
#define _C_StartAngele (_C_AddAngele * 0.5f)

#define _C_FirstAdjustAngele  28 //设计图上22.5度没有对准

- (void) update
{
    _angele += _C_AddAngele;

    //设计图没有对准, 进行手动较正
    if (_angele - 360 == _C_StartAngele) {
        _angele = _C_FirstAdjustAngele + 360;
    }

    _rollImgV.transform = CGAffineTransformMakeRotation(_angele / 180.0f * M_PI);
    
    if (_angele >=  _C_FirstAdjustAngele + 360) {
        _angele = _C_StartAngele;
    }
}


-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview == nil) {
        [_timeer invalidate];
    }else{
        _rollImgV.transform =
        CGAffineTransformMakeRotation(_C_FirstAdjustAngele / 180.0f * M_PI);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _angele = _C_StartAngele;
    
    [_timeer invalidate];
    _timeer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
                                             selector:@selector(update)
                                             userInfo:nil repeats:YES];
}


@end
