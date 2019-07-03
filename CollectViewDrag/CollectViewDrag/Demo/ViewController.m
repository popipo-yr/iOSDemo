//
//  ViewController.m
//  CollectViewDrag
//
//  Created by RuiYang on 2019/6/25.
//

#import "ViewController.h"
#import "ShowVC.h"
#import "PYCollectViewDrag.h"
#import "SystemCollectViewDrag_iOS9.h"
#import "SystemCollectViewDrag_iOS11.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)styleOne:(id)sender
{
    
    ShowVC* vc = [ShowVC new];
    vc.title = @"自定义拖动在CollectionView内";
    
    void (^pushFinish)(void)  = ^{
        
        PYCollectViewDrag* drag =
        [[PYCollectViewDrag alloc]
         initWithCollectionView:vc.collectionView
         dragInView:vc.collectionView];
        
        vc.drag = drag;
    };
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:pushFinish];
    [self.navigationController pushViewController:vc animated:YES];
    [CATransaction commit];
}

-(IBAction)styleTwo:(id)sender
{
    ShowVC* vc = [ShowVC new];
    vc.title = @"自定义拖动在Window内";
    
    void (^pushFinish)(void)  = ^{
        
        PYCollectViewDrag* drag =
        [[PYCollectViewDrag alloc]
         initWithCollectionView:vc.collectionView
         dragInView:vc.collectionView.window];
        
        vc.drag = drag;
    };
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:pushFinish];
    [self.navigationController pushViewController:vc animated:YES];
    [CATransaction commit];
}

-(IBAction)styleThree:(id)sender
{
    if (@available(iOS 9, *)) {
        
        ShowVC* vc = [ShowVC new];
        vc.title = @"系统拖动在CollectionView内";
        
        void (^pushFinish)(void)  = ^{
            
            SystemCollectViewDrag_iOS9* drag =
            [[SystemCollectViewDrag_iOS9 alloc]
             initWithCollectionView:vc.collectionView
             dataSource:vc];
            
            vc.drag = drag;
        };
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:pushFinish];
        [self.navigationController pushViewController:vc animated:YES];
        [CATransaction commit];
    }
}


-(IBAction)styleFour:(id)sender
{
    if (@available(iOS 11, *)) {
        ShowVC* vc = [ShowVC new];
        vc.title = @"系统拖动在Window内";
        
        void (^pushFinish)(void)  = ^{
            
            SystemCollectViewDrag_iOS11* drag =
            [[SystemCollectViewDrag_iOS11 alloc]
             initWithCollectionView:vc.collectionView];
            
            vc.drag = drag;
        };
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:pushFinish];
        [self.navigationController pushViewController:vc animated:YES];
        [CATransaction commit];
    }
}

@end
