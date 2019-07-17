//
//  ViewController.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/8.
//  Copyright © 2019 py. All rights reserved.
//

#import "ViewController.h"
#import "WaterMarkBase.h"
#import "WaterMarkPro.h"
#import "WaterMarkFliterImp.h"
#import "WaterMarkOpenGL.h"
#import "ResultVC.h"


@interface ViewController (){
    UIImage* _firstImg;
    UIImage* _secImg;
    NSString* _title;
}

@end

@implementation ViewController

-(IBAction)baseClick:(id)sender{
    
    WaterMarkInfo* info = [WaterMarkInfo new];
    info.text = [@(time(0)) stringValue];
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.point = CGPointMake(0, 0);
    info.h_Rate = 0.1f;
    
    info.image = _firstImgV.image;
    _firstImg = [WaterMarkBase py_BaseWaterMarkWithInfo:info];
    
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.image = _secondImgV.image;
    _secImg = [WaterMarkBase py_BaseWaterMarkWithInfo:info];
    
    _title = @"BASE";
    [self performSegueWithIdentifier:@"ResultVC" sender:self];
}

-(IBAction)proClick:(id)sender{
    
    WaterMarkInfo* info = [WaterMarkInfo new];
    info.text = [@(time(0)) stringValue];
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.point = CGPointMake(0, 0);
    info.h_Rate = 0.1f;
    
    info.image = _firstImgV.image;
    _firstImg = [WaterMarkPro py_ProWaterMarkWithInfo:info];
    
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.image = _secondImgV.image;
    _secImg = [WaterMarkPro py_ProWaterMarkWithInfo:info];
    
    _title = @"PRO";
    [self performSegueWithIdentifier:@"ResultVC" sender:self];
}

-(IBAction)CIFilterClick:(id)sender{
    
    WaterMarkInfo* info = [WaterMarkInfo new];
    info.text = [@(time(0)) stringValue];
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.point = CGPointMake(0, 0);
    info.h_Rate = 0.1f;
    
    info.image = _firstImgV.image;
    _firstImg = [WaterMarkFliterImp py_filterWaterMarkWithInfo:info];
    
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.image = _secondImgV.image;
    _secImg = [WaterMarkFliterImp py_filterWaterMarkWithInfo:info];
    
    _title = @"CIFilter";
    [self performSegueWithIdentifier:@"ResultVC" sender:self];
}

-(IBAction)openGLClick:(id)sender{
    
    WaterMarkInfo* info = [WaterMarkInfo new];
    info.text = [@(time(0)) stringValue];
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.point = CGPointMake(0, 0);
    info.h_Rate = 0.1f;
    
    info.image = _firstImgV.image;
    _firstImg = [WaterMarkOpenGL py_openGLWaterMarkWithInfo:info];
    
    info.text = @"0123456789ABCDEFGHIGKLMN";
    info.image = _secondImgV.image;
    _secImg = [WaterMarkOpenGL py_openGLWaterMarkWithInfo:info];
    
    _title = @"OpenGL";
    [self performSegueWithIdentifier:@"ResultVC" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"ResultVC"]) {
        
        ResultVC* vc = segue.destinationViewController;
        vc.firstImg = _firstImg;
        vc.secondImg = _secImg;
        vc.title = _title;
    }
    
}


@end









