//
//  CollectViewDragProtocal.h
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CollectViewDragProtocal <NSObject>

@property (nonatomic, copy) BOOL (^canDragAtIndexPathCB)(NSIndexPath*);
@property (nonatomic, copy) void (^dragStartCB)(void);
@property (nonatomic, copy) void (^dragingCB)(CGRect imgRect);
@property (nonatomic, copy) void (^dragEndCB)(CGRect imgRect);

@property (nonatomic, copy)
void (^changeItemIndexPathCB)(NSIndexPath* from, NSIndexPath* to);

@property (nonatomic, copy)
void (^deleteItemAtIndexPathCB)(NSIndexPath* indexPath);

//拖动完成后调用
- (void) removeDragCell;
- (void) restoreDragCell;

@end

//获取Drag配置对象
@protocol DragInfoProtocal <NSObject>

-(id<CollectViewDragProtocal>)dragInfo;

@end


NS_ASSUME_NONNULL_END
