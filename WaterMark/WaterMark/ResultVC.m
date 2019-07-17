//
//  ResultVC.m
//  WaterMark
//
//  Created by RuiYang on 2019/7/8.
//  Copyright © 2019 py. All rights reserved.
//

#import "ResultVC.h"

@interface ResultVC ()

@property (nonatomic, strong) IBOutlet UIImageView* firstImgV;
@property (nonatomic, strong) IBOutlet UIImageView* secondImgV;

@end

@implementation ResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstImgV.image = _firstImg;
    _secondImgV.image = _secondImg;
}



@end
