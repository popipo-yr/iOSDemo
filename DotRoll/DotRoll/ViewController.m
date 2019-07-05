//
//  ViewController.m
//  DotRoll
//
//  Created by RuiYang on 2019/7/5.
//  Copyright © 2019 py. All rights reserved.
//

#import "ViewController.h"
#import "ImgIMP.h"

#import "DotShowView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ImgIMP* imp = [[ImgIMP alloc] initWithFrame:CGRectMake(20, 100, 120, 120)];
    [self.view addSubview:imp];


    DotShowView* mask = [[DotShowView alloc] initWithFrame:CGRectMake(20, 300, 120, 120)];
    
    mask.numberOfDots = 8;
    mask.maxRadiusOfDot = 20;
    mask.minRadiusOfDot = 5;
    mask.lengthOfDot2Edge = 2;
    mask.animationDuration = 2;
    
    mask.backgroundColor = UIColor.lightGrayColor;
    
    [self.view addSubview:mask];
}

@end
