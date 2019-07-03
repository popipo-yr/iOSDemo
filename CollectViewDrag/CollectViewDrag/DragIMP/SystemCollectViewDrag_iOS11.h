//
//  SystemCollectViewDrag_iOS11.h
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/27.
//

#import <UIKit/UIKit.h>
#import "CollectViewDragProtocal.h"

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(, 11_0)
@interface SystemCollectViewDrag_iOS11 : NSObject <CollectViewDragProtocal>

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView;

@end

NS_ASSUME_NONNULL_END
