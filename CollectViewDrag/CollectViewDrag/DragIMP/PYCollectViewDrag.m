//
//  PYCollectViewDrag.m
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/25.
//



#import "PYCollectViewDrag.h"


@interface PYCollectViewDrag () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *dragInView;
//拖拽的cell的截图
@property (nonatomic, strong) UIView *snapshot;

//被拖拽Cell的位置
@property (nonatomic, strong) NSIndexPath *dragFromIndexPath;
//截图拖动到边缘，调整ContentOffset移动视图
@property (nonatomic, strong) CADisplayLink *adjustTimer;
@property (nonatomic, assign) CGFloat adjustSpeed;

@end

@implementation PYCollectViewDrag{
    UICollectionView* _cv;
}

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView
                             dragInView:(nonnull UIView *)dragInView
{
    if (self = [super init]) {
        _cv = collectionView;
        self.dragInView = dragInView;
        [self setups];
    }
    
    return self;
}
- (void) setups{
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self action:@selector(longPressGestureRecognized:)];
    
    longPress.delegate = self;
    [_cv addGestureRecognizer:longPress];
    
    //不添加，当长按取消后会执行「delayTouch」事件,delegate的「cell选择」被执行
    UILongPressGestureRecognizer *cancelDelayTouch =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self action:@selector(cancelDelayTouchGestureRecognized:)];
    
    [cancelDelayTouch requireGestureRecognizerToFail:longPress];
    [_cv addGestureRecognizer:cancelDelayTouch];
}

#pragma mark - GR Delegate
- (BOOL)gestureRecognizerShouldBegin:(UILongPressGestureRecognizer *)longPress{
    
    if (false == [longPress isKindOfClass:UILongPressGestureRecognizer.class]) {
        return YES;
    }
    
    //手势的位置
    CGPoint pressPoint = [longPress locationInView:_cv];
    
    //手势位置对应的indexPath，可能为nil
    NSIndexPath* pressIndexPath = [_cv indexPathForItemAtPoint:pressPoint];
    if (nil == pressIndexPath || nil == self.canDragAtIndexPathCB) {
        return NO;
    }
    
    return self.canDragAtIndexPathCB(pressIndexPath);
}

#pragma mark - event response
- (void)cancelDelayTouchGestureRecognized:(id)sender{
    //不用做任何事
}

- (void)longPressGestureRecognized:(id)sender{
    
    UILongPressGestureRecognizer *longPress = sender;
    UIGestureRecognizerState longPressState = longPress.state;
    
    //手势的位置
    CGPoint pressPoint = [longPress locationInView:_cv];
    
    //手势位置对应的indexPath，可能为nil
    NSIndexPath* pressIndexPath = [_cv indexPathForItemAtPoint:pressPoint];
    
    //状态处理
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{
            //手势开始，对被选中cell截图，隐藏原cell
            
            _dragFromIndexPath = pressIndexPath;
            
            UIView *cell = [_cv cellForItemAtIndexPath:pressIndexPath];
            CGPoint p =  [_cv convertPoint:cell.center toView:_dragInView];
            
            [self _createSnapshot:cell atPoint:p];
            
            cell.hidden = YES;
            
            if (self.dragStartCB) {
                self.dragStartCB();
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:{
            //点击位置移动，判断手指拖动位置是否进入其它Cell范围，\
            若进入则更新数据源并移动Cell
            
            //截图跟随手指移动
            CGPoint p =  [_cv convertPoint:pressPoint toView:_dragInView];
            _snapshot.center = p;
            
            
            if (pressIndexPath &&
                ![pressIndexPath isEqual:_dragFromIndexPath]) {
                //手指拖动进入其它Cell，需要进行调整
                
                if (nil != self.canDragAtIndexPathCB &&
                    self.canDragAtIndexPathCB(pressIndexPath)) {
                    //进入的Cell可以移动
                    [self _moveCell2NewIndexPath:pressIndexPath];
                }
            }
            
            if (self.dragingCB) {
                self.dragingCB(_snapshot.frame);
            }
            
            break;
        }
        default:{
            //长按手势结束或被取消，移除截图，显示cell
            if (self.dragEndCB) {
                self.dragEndCB(_snapshot.frame);
            }else{
                [self restoreDragCell];
            }
            
            
            break;
        }
    }
}

#pragma mark -

/**通过视图创建截图，并制定位置*/
- (void)_createSnapshot:(UIView *)view
                atPoint:(CGPoint)point{
    
    _snapshot = [self _customSnapshotFromView:view];
    _snapshot.center = point;
    
    [_dragInView addSubview:_snapshot];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshot.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self.snapshot.alpha = 0.98;
    }];
    
    [_snapshot addObserver:self
                forKeyPath:@"center"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
}


- (UIView *)_customSnapshotFromView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView drawViewHierarchyInRect:inputView.bounds
                    afterScreenUpdates:YES];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
//    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-3.0, 0.0);
    snapshot.layer.shadowRadius = 3.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

/**
 *  手指移动到新的Cell范围，先更新数据源，移动Cell，更新IndexPath
 */
- (void)_moveCell2NewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源
    if (self.changeItemIndexPathCB) {
        self.changeItemIndexPathCB(_dragFromIndexPath, indexPath);
    }
    
    //交换移动cell位置
    [_cv moveItemAtIndexPath:_dragFromIndexPath toIndexPath:indexPath] ;
    
    //更新cell的原始indexPath为当前indexPath
    _dragFromIndexPath = indexPath;
}

#pragma mark - Observe
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object != self.snapshot) {
        return;
    }
    
    //移动到显示边界
    CGRect frame =
    [_dragInView convertRect:_snapshot.frame toView:_cv.superview];
    
    CGFloat minY = CGRectGetMinY(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    
    
    if (minY <= _cv.frame.origin.y  && _cv.contentOffset.y > 0) {
        
        //这种方式会抖动，由于动画的不连贯性
        //        CGFloat pixelSpeed = 10;
        //        CGPoint p = CGPointMake(0, MAX(_cv.contentOffset.y - pixelSpeed, 0));
        //        [_cv setContentOffset:p];
        
        self.adjustSpeed = - 10;
        [self _startAdjustTimer];
        return;
    }
    
    if (maxY > CGRectGetMaxY(_cv.frame) &&
        _cv.contentOffset.y + _cv.bounds.size.height < _cv.contentSize.height ) {
        
        self.adjustSpeed = 10;
        [self _startAdjustTimer];
        return;
    }
    
    [self _stopAdjustScrollTimer];
}


/**
 *  创建定时器并运行
 */
- (void)_startAdjustTimer{
    if (!_adjustTimer) {
        _adjustTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(_adjustProcess)];
        [_adjustTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
/**
 *  停止定时器并销毁
 */
- (void)_stopAdjustScrollTimer{
    if (_adjustTimer) {
        [_adjustTimer invalidate];
        _adjustTimer = nil;
    }
}

/**
 *  调整处理
 */
- (void)_adjustProcess{
    
    CGFloat y = _cv.contentOffset.y + self.adjustSpeed;
    y = MAX(0, y);
    y = MIN(y, _cv.contentSize.height - _cv.bounds.size.height);
    
    [_cv setContentOffset:CGPointMake(0, y)];
}


#pragma mark -
#pragma mark - getters and setters

- (void) removeDragCell{
    
    UICollectionViewCell *cell = [_cv cellForItemAtIndexPath:_dragFromIndexPath] ;
    cell.hidden = NO;
    cell.alpha = 0;
    
    //更新数据源
    if (self.deleteItemAtIndexPathCB) {
        self.deleteItemAtIndexPathCB(_dragFromIndexPath);
    }
    
    //删除Cell
    [_cv deleteItemsAtIndexPaths:@[_dragFromIndexPath]];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshot.alpha = 0;
        self.snapshot.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
        self.dragFromIndexPath = nil;
    }];
}

- (void) restoreDragCell{
    
    UICollectionViewCell *cell = [_cv cellForItemAtIndexPath:_dragFromIndexPath] ;
    cell.hidden = NO;
    cell.alpha = 0;
    
    //回位
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshot.center = cell.center;
        self.snapshot.alpha = 0;
        self.snapshot.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
        self.dragFromIndexPath = nil;
    }];
    
}

-(void)dealloc{
    
}


@synthesize canDragAtIndexPathCB;
@synthesize dragEndCB;
@synthesize dragingCB;
@synthesize dragStartCB;
@synthesize changeItemIndexPathCB;
@synthesize deleteItemAtIndexPathCB;

@end
