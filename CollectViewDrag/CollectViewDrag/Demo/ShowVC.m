//
//  ShowVC.m
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/25.
//

#import "ShowVC.h"
#import "DragCell.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define kSingleItemHeight (SCREEN_WIDTH - 15*4) / kItemCount

#define kItemCount 3


@interface ShowVC () 
@property (nonatomic, strong) NSMutableArray<UIColor*>* imgColors;
@end

@implementation ShowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgColors = NSMutableArray.new;
    [self setupCV];
}

- (void) setupCV
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(kSingleItemHeight,kSingleItemHeight);
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    layout.minimumInteritemSpacing = 15;
    layout.minimumLineSpacing = 15;
    
    _collectionView.collectionViewLayout = layout;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    
    [_collectionView registerClass:DragCell.class
        forCellWithReuseIdentifier:@"DragCell"];
}

- (void)setDrag:(id<CollectViewDragProtocal>)drag
{
    _drag = drag;
    
    __weak typeof(self) self_weak_ = self;
    
    self.drag.dragStartCB = ^{
        self_weak_.tipLabel.text = @"拖动到此删除";
    };
    
    self.drag.dragingCB = ^(CGRect imgRect) {
        self_weak_.tipLabel.text =
        [NSString stringWithFormat:@"拖动中 \n %@", [NSValue valueWithCGRect:imgRect]];
        
        if (imgRect.origin.y > self_weak_.tipLabel.frame.origin.y) {
            [NSString stringWithFormat:@"拖动到此删除"];
        }
    };
    
    self.drag.dragEndCB = ^(CGRect imgRect) {
        
        if (imgRect.origin.y > self_weak_.tipLabel.frame.origin.y) {
            [self_weak_.drag removeDragCell];
        }else{
            [self_weak_.drag restoreDragCell];
        }
        
        self_weak_.tipLabel.text = @"拖动结束";
    };
    
    self.drag.changeItemIndexPathCB = ^(NSIndexPath *from, NSIndexPath *to) {
        
        if (from.row < to.row) {
            for (NSInteger i = from.row; i < to.row; i++) {
                [self_weak_.imgColors exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }else{
            for (NSInteger i = from.row; i > to.row; i--) {
                [self_weak_.imgColors exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    };
    
    self.drag.deleteItemAtIndexPathCB = ^(NSIndexPath * _Nonnull indexPath) {
        [self_weak_.imgColors removeObjectAtIndex:indexPath.row];
    };
    
    self.drag.canDragAtIndexPathCB = ^BOOL(NSIndexPath *indexPath) {
        return indexPath.row < self_weak_.imgColors.count;
    };
}



#pragma mark - DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //长图
    DragCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DragCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.imgColors.count) {
        
        UIColor* color = _imgColors[indexPath.row];
        cell.imageView.image = nil;
        cell.imageView.backgroundColor = color;
        
    }else{
        cell.imageView.image = [UIImage imageNamed:@"pic_add"];
        cell.imageView.backgroundColor = UIColor.clearColor;
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.imgColors.count + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(0, 0);
}

#pragma mark - Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.tipLabel.text = @"点击";
    
    if (indexPath.row == self.imgColors.count) {
        UIColor* color =
        [UIColor colorWithRed:arc4random() * 1.0f / UINT32_MAX
                        green:arc4random() * 1.0f / UINT32_MAX
                         blue:arc4random() * 1.0f / UINT32_MAX
                        alpha:1.0f];
        
        [self.imgColors addObject:color];
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    }
    
}


- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    
    [self.imgColors exchangeObjectAtIndex:indexPath.row
                        withObjectAtIndex:newIndexPath.row];
}


-(id<CollectViewDragProtocal>)dragInfo
{
    return _drag;
}


@end
