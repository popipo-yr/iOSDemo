//
//  DragPhotoCollectionViewCell.m
//  DragPhotoDemo
//
//  Created by 关旭 on 2018/12/17.
//  Copyright © 2018 关旭. All rights reserved.
//

#import "DragCell.h"

@implementation DragCell

#pragma mark -
#pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initCellView];
    }
    return self;
}


#pragma mark -
#pragma mark - private methods
- (void)_initCellView{
    [self.contentView addSubview:self.imageView];
    
    self.imageView.frame = self.bounds;
    self.contentView.backgroundColor = [UIColor whiteColor];
}


#pragma mark -
#pragma mark - getters and setters
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}


@end

