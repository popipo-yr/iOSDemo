//
//  SystemCollectViewDrag.h
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/26.
//

#import <UIKit/UIKit.h>
#import "CollectViewDragProtocal.h"


NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(, 9_0)
@interface SystemCollectViewDrag_iOS9 : NSObject <CollectViewDragProtocal>

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView
                             dataSource:(id<UICollectionViewDataSource, DragInfoProtocal>) dataSource;

@end


NS_ASSUME_NONNULL_END
