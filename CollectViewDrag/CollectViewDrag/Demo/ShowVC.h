//
//  ShowVC.h
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/25.
//

#import <UIKit/UIKit.h>
#import "CollectViewDragProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, DragInfoProtocal>

@property (nonatomic, strong) id <CollectViewDragProtocal> drag; //

@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) IBOutlet UILabel* tipLabel;

@end

NS_ASSUME_NONNULL_END
