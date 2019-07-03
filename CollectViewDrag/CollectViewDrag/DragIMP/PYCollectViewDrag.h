//
//  PYCollectViewDrag.h
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/25.
//

#import <UIKit/UIKit.h>
#import "CollectViewDragProtocal.h"


NS_ASSUME_NONNULL_BEGIN

@interface PYCollectViewDrag : NSObject <CollectViewDragProtocal>

- (instancetype) initWithCollectionView:(UICollectionView*) collectionView
                             dragInView:(UIView*)dragInView;

@end

NS_ASSUME_NONNULL_END
