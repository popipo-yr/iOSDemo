//
//  SystemCollectViewDrag.m
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/26.
//

#import "SystemCollectViewDrag_iOS9.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import "ShowVC.h"

@interface SystemCollectViewDrag_iOS9 ()
@property (nonatomic, weak) Class originDataSourceClass;
@property (nonatomic, weak) id originDataSource;
@property (nonatomic, weak) UICollectionViewCell* dragCell;

@property (nonatomic, strong) NSIndexPath* dragStartIndexPath;
@property (nonatomic, strong) NSIndexPath* dragEndIndexPath;

@property (nonatomic, strong) NSArray<NSString*>* changeSelectors;

@end


@implementation SystemCollectViewDrag_iOS9
{
    UICollectionView* _cv;
}

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView
                             dataSource:(nonnull id<UICollectionViewDataSource, DragInfoProtocal>)dataSource
{
    if (self = [super init]) {
        _cv = collectionView;
        
        self.originDataSource = dataSource;
        self.originDataSourceClass = dataSource.class;
        
        NSString* canSELStr = @"collectionView:canMoveItemAtIndexPath:",
        *movSELStr = @"collectionView:moveItemAtIndexPath:toIndexPath:",
        *willSELStr =  @"collectionView:targetIndexPathForMoveFromItemAtIndexPath:toProposedIndexPath:";
        
        _changeSelectors = @[canSELStr, movSELStr, willSELStr];
        
        [self dataSourceChangeClass:dataSource];
        [self setups];
    }
    
    return self;
}

- (void) dataSourceChangeClass:(id<UICollectionViewDataSource>)obj
{
    if (nil == obj) {
        return;
    }
    
    char * preTag = "__Drag_";
    const char * _Nonnull lastTag = object_getClassName(obj);
    char * tag = (char *) malloc(strlen(preTag) + strlen(lastTag));
    sprintf(tag, "%s%s_%ld", preTag, lastTag, time(0));
    
    Class dragClass = objc_allocateClassPair([obj class], tag, 0);
    
    free(tag);
    
    for (NSString* selStr in self.changeSelectors) {
        SEL selector = NSSelectorFromString(selStr);
        SEL mySel = [SystemCollectViewDrag_iOS9 _getMySel:selector];
        
        Method myMethod = class_getInstanceMethod(self.class, mySel);

        class_addMethod(dragClass, selector , method_getImplementation(myMethod) , method_getTypeEncoding(myMethod));
    }

    object_setClass(obj, dragClass);

    [self resetDataSource];
}

- (void) resetDataSource{
    /*这步操作很关键 UICollectionView内部一个变量记录了能否移动，
     如果在Nib中设置了代理，必须先执nil再设置代理才能重置那个变量，直接设置代理不会重置*/
    id<UICollectionViewDataSource> _Nullable oldDataSource = _cv.dataSource;
    id<UICollectionViewDelegate> _Nullable oldDelegate = _cv.delegate;
    
    _cv.dataSource = nil;
    _cv.delegate = nil;
    
    _cv.dataSource = oldDataSource;
    _cv.delegate = oldDelegate;
}


+ (SEL) _getMySel:(SEL)originSel
{
    NSString* selStr = NSStringFromSelector(originSel);
    NSString* mySelStr  = [@"ex_"  stringByAppendingString:selStr];
    SEL mySel = NSSelectorFromString(mySelStr);
    
    return mySel;
}


#define _CanSuperCallStart \
Class supClass = class_getSuperclass(self.class); \
if (class_respondsToSelector(supClass, _cmd)) { \
    struct objc_super superReceiver = { \
        self, \
        [self superclass] \
    }; \

#define _CanSuperCallEnd }

#define _SuperCallReciver &superReceiver


- (BOOL)ex_collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //优先执行原来的方法 self为_Drag
    _CanSuperCallStart
    
    return ((BOOL(*)(struct objc_super *, SEL, id, id))objc_msgSendSuper)
    (_SuperCallReciver, _cmd, collectionView, indexPath);
    
    _CanSuperCallEnd

    if ([self conformsToProtocol:@protocol(DragInfoProtocal)]) {
        id<CollectViewDragProtocal> drag =
        [((id<DragInfoProtocal>)self) dragInfo];
        
        if (drag.canDragAtIndexPathCB) {
            return drag.canDragAtIndexPathCB(indexPath);
        }
    }

    //默认返回NO
    return NO;
}

- (void)ex_collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    //优先执行原来的
    _CanSuperCallStart
    
    ((void(*)(void*, SEL, id, id, id))objc_msgSendSuper)
    (_SuperCallReciver, _cmd, collectionView, sourceIndexPath, destinationIndexPath);
    
    _CanSuperCallEnd
    else{
        if ([self conformsToProtocol:@protocol(DragInfoProtocal)]) {
            id<CollectViewDragProtocal> drag =
            [((id<DragInfoProtocal>)self) dragInfo];
            
            if (drag.changeItemIndexPathCB) {
                drag.changeItemIndexPathCB(sourceIndexPath, destinationIndexPath);
            }
        }
    }
    
    if ([self conformsToProtocol:@protocol(DragInfoProtocal)]) {
        SystemCollectViewDrag_iOS9* drag =
        [((id<DragInfoProtocal>)self) dragInfo];
        if (false == [drag isKindOfClass:SystemCollectViewDrag_iOS9.class]) {
            return;
        }
        
        //移动了位置，修改拖拽开始的IndexPath
        drag.dragStartIndexPath = destinationIndexPath;
    }

}


- (NSIndexPath *)ex_collectionView:(UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath{
    
    //优先执行原来的
    _CanSuperCallStart
    
    return ((id(*)(void*, SEL, id, id, id))objc_msgSendSuper)
    (_SuperCallReciver, _cmd, collectionView, originalIndexPath, proposedIndexPath);
    
    _CanSuperCallEnd

    if ([self conformsToProtocol:@protocol(DragInfoProtocal)]) {
        id<CollectViewDragProtocal> drag =
        [((id<DragInfoProtocal>)self) dragInfo];
        
        if (drag.canDragAtIndexPathCB) {
            if (false == drag.canDragAtIndexPathCB(proposedIndexPath)) {
                return originalIndexPath;
            }
            
            if (false == drag.canDragAtIndexPathCB(originalIndexPath)) {
                return originalIndexPath;
            }
        }
    }
    
    return proposedIndexPath;
}


- (void) setups{
    
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reorderCollectionView:)];
    
    [_cv addGestureRecognizer:longPressGesture];
}


// 长按手势响应方法。
- (void)reorderCollectionView:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint touchPoint = [longPressGesture locationInView:_cv];
    NSIndexPath* where = [_cv indexPathForItemAtPoint:touchPoint];
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:{
            // 手势开始。
            if (where) {
                [_cv beginInteractiveMovementForItemAtIndexPath:where];
                
                self.dragStartIndexPath = where;
                self.dragCell = [_cv cellForItemAtIndexPath:where];
                
                if (self.dragStartCB) {
                    self.dragStartCB();
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            // 手势变化。
            [_cv updateInteractiveMovementTargetPosition:touchPoint];
            
            if (self.dragingCB) {
                self.dragingCB(self.dragCell.frame);
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            // 手势结束。
            [_cv endInteractiveMovement];
            
            self.dragEndIndexPath = where;
            
            if (self.dragEndCB) {
                self.dragEndCB(self.dragCell.frame);
            }
            
            self.dragCell = nil;
            
            break;
        }
            
        default:{
            [_cv cancelInteractiveMovement];
            
            self.dragEndIndexPath = where;
            
            if (self.dragEndCB) {
                self.dragEndCB(self.dragCell.frame);
            }

            self.dragCell = nil;
            
            break;
        }
    }
}

- (void) dealloc
{
    [self restoreClass];
}

- (void) restoreClass{
    
    if (nil == _originDataSource) {
        return;
    }
    
    Class addedClass = [_originDataSource class];
    
    object_setClass(_originDataSource, _originDataSourceClass);
    
    objc_disposeClassPair(addedClass);
    
    [self resetDataSource];
}



@synthesize canDragAtIndexPathCB;
@synthesize dragEndCB;
@synthesize dragingCB;
@synthesize dragStartCB;
@synthesize changeItemIndexPathCB;
@synthesize deleteItemAtIndexPathCB;

- (void)removeDragCell {
    //拖动移动到其他位置，通过手势Point获去值，
    //拖动到空白，获取值会为空，需要考虑这两种情况
    NSIndexPath* where = self.dragEndIndexPath;
    if (where == nil) {
        where = self.dragStartIndexPath;
    }

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
