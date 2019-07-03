//
//  SystemCollectViewDrag_iOS11.m
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/27.
//

#import "SystemCollectViewDrag_iOS11.h"

@interface SystemCollectViewDrag_iOS11 ()
<UICollectionViewDragDelegate, UICollectionViewDropDelegate>

@property (nonatomic, strong) NSIndexPath* dragIndexPath;
@property (nonatomic, assign) CGRect dragBounds;

@property (nonatomic, assign) BOOL isDeleting;
@property (nonatomic, weak) id<UIDropSession> session;

@end

@implementation SystemCollectViewDrag_iOS11{
    UICollectionView* _cv;
}

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView
{
    if (self = [super init]) {
        _cv = collectionView;
        [self setups];
    }
    
    return self;
}

- (void) setups{
    _cv.dragInteractionEnabled = YES;
    _cv.dragDelegate = self;
    _cv.dropDelegate = self;
    
    _cv.reorderingCadence = UICollectionViewReorderingCadenceFast;
}

#pragma mark - UICollectionViewDragDelegate
- (NSArray <UIDragItem *>*)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath  {
    
    if (nil == self.canDragAtIndexPathCB ||
        false == self.canDragAtIndexPathCB(indexPath) ) {
        return nil;
    }
    
    if (self.dragStartCB) {
        self.dragStartCB();
    }
    
    self.dragIndexPath = indexPath;
    
    NSItemProvider *provider = [NSItemProvider new];
    UIDragItem *dragItem =
    [[UIDragItem alloc] initWithItemProvider:provider];
    
    return @[dragItem];
}


- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell =
    [collectionView cellForItemAtIndexPath:indexPath];
    
    //预览图配置信息
    UIDragPreviewParameters *previewInfo = UIDragPreviewParameters.new;
    previewInfo.backgroundColor = [UIColor clearColor];
    previewInfo.visiblePath =
    [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:4.0f];
    
    self.dragBounds = cell.bounds;
    
    //不应该在这里调用 为了动画效果
    if (_session.progress.isIndeterminate) {
//    if (_cv.hasActiveDrag && _cv.hasActiveDrop) {
        //有拖动和放置则为释放手指后的调用
        [self _endCallWithSession:self.session];
        
        if (self.isDeleting) {
            
            
            previewInfo.visiblePath = [UIBezierPath bezierPathWithRoundedRect:CGRectZero cornerRadius:0];

        }
    }
    
    return previewInfo;
}


#pragma mark - UICollectionViewDropDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView canHandleDropSession:(id<UIDropSession>)session {
    
    self.session = session;
    //只考虑App内部的拖拽
    return nil != session.localDragSession;
}

- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath {
    
    if (self.dragingCB) {
        
        CGRect rect = CGRectZero;
        if (session.localDragSession) {
            CGPoint center =
            [session.localDragSession locationInView:_cv.window];
            
            rect = [self _rectFromCenter:center size:self.dragBounds.size];
        }

        self.dragingCB(rect);
    }

    if (nil == session.localDragSession //只考虑App内部的拖拽
        || nil == destinationIndexPath
        || nil == self.canDragAtIndexPathCB
        || false == self.canDragAtIndexPathCB(destinationIndexPath)) {
        
        return
        [[UICollectionViewDropProposal alloc]
         initWithDropOperation:UIDropOperationCancel
         intent:UICollectionViewDropIntentUnspecified];
    }
    
    return
    [[UICollectionViewDropProposal alloc]
     initWithDropOperation:UIDropOperationMove
     intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
}

- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator {
   
    if (nil != coordinator.destinationIndexPath &&
        1 == coordinator.items.count &&
        coordinator.items.firstObject.sourceIndexPath) {
        
        NSIndexPath *destIndexPath =
        coordinator.destinationIndexPath;

        NSIndexPath *sourceIndexPath =
        coordinator.items.firstObject.sourceIndexPath;
        
        // collectionView更新
        [collectionView performBatchUpdates:^{
            // 更新数据源
            if (nil != self.changeItemIndexPathCB) {
                self.changeItemIndexPathCB(sourceIndexPath, destIndexPath);
            }
            // 更新collectionView
            [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destIndexPath];
            
        } completion:nil];
        
        // 移动Item
        [coordinator dropItem:coordinator.items.firstObject.dragItem toItemAtIndexPath:destIndexPath];
    }
}


- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session{
    
    //这里本应是最佳调用位置，但为了动画优化，改为了前面调用
//    [self _endCallWithSession:session];
    self.isDeleting = false;
    self.dragIndexPath = nil;
}

- (void) _endCallWithSession:(id<UIDropSession>)session
{
    if (self.dragEndCB && nil != session) {
        CGRect rect = CGRectZero;
        
        if (session.localDragSession) {
            CGPoint center =
            [session.localDragSession locationInView:_cv.window];
            
            rect = [self _rectFromCenter:center size:self.dragBounds.size];
        }
        self.dragEndCB(rect);
    }
}

- (CGRect) _rectFromCenter:(CGPoint)center size:(CGSize)size
{
    CGRect rect = CGRectZero;
    
    CGPoint orign = CGPointZero;
    orign.x = center.x - size.width * 0.5f;
    orign.y = center.y - size.height * 0.5f;
    
    rect.size = size;
    rect.origin = orign;
    
    return  rect;
}


@synthesize canDragAtIndexPathCB;
@synthesize dragEndCB;
@synthesize dragingCB;
@synthesize dragStartCB;
@synthesize changeItemIndexPathCB;
@synthesize deleteItemAtIndexPathCB;

- (void)removeDragCell {
    
    self.isDeleting = YES;
    
    NSIndexPath* where = self.dragIndexPath;

    if (where == nil) {
        NSLog(@"删除失败");
        return;
    }
    
    //更新数据源
    if (self.deleteItemAtIndexPathCB) {
        self.deleteItemAtIndexPathCB(where);
    }
    
    //删除Cell
    [_cv deleteItemsAtIndexPaths:@[where]];
}

- (void)restoreDragCell {
}


@end
