//
//  JXRootViewController.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/3.
//

#import "JXRootViewController.h"
#import "JXCameraView.h"
#import "JXFunctionListView.h"
#import "JXImageDataItem.h"

#define    FWidth   180

@interface JXRootViewController ()<NSSplitViewDelegate,NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout>

@property(nonatomic,strong)NSMutableArray<AVCaptureDevice *> *cameraList;

@property(nonatomic,strong)NSSplitView *splitView;
@property(nonatomic,strong)NSCollectionView *mainCollection;

@property(nonatomic,copy)NSMutableArray *dataArray;

@end

@implementation JXRootViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
}

- (NSSplitView *)splitView {
    if (!_splitView) {
        _splitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width-FWidth, self.view.frame.size.height)];
        _splitView.wantsLayer = YES;
        _splitView.delegate = self;
        _splitView.vertical = YES;
        _splitView.dividerStyle = NSSplitViewDividerStyleThin;
        _splitView.layer.backgroundColor = NSColor.whiteColor.CGColor;
    }
    return _splitView;
}

-(NSCollectionView *)mainCollection{
    if (!_mainCollection) {
        NSCollectionViewFlowLayout *flowLayout = [[NSCollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0; // 最小横向间距
        flowLayout.minimumInteritemSpacing = 0; // 最小竖向间距
        _mainCollection = [[NSCollectionView alloc] initWithFrame:NSMakeRect(0, 0, imageListWidth, _splitView.frame.size.height)];
        _mainCollection.wantsLayer = YES;
        _mainCollection.collectionViewLayout = flowLayout;
        _mainCollection.layer.backgroundColor = [NSColor redColor].CGColor;
        _mainCollection.selectable = YES;
        _mainCollection.delegate = self;
        _mainCollection.dataSource = self;
    }
    return _mainCollection;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"金翔影像";
    
    [self creatUI];
}

- (void)creatUI {
    NSScrollView *tableContainerView = [[NSScrollView alloc] initWithFrame:self.mainCollection.bounds];
    tableContainerView.hasVerticalScroller = YES;
    NSClipView *clip = [[NSClipView alloc] initWithFrame:self.mainCollection.bounds];
    clip.documentView = self.mainCollection;
    tableContainerView.contentView = clip;
    [self.splitView addArrangedSubview:tableContainerView];
    [_mainCollection registerClass:[JXImageDataItem class] forItemWithIdentifier:@"JXImageDataItem"];
    
    WS(weakSelf)
    JXCameraView *caView = [[JXCameraView alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width-imageListWidth-FWidth, _splitView.frame.size.height)];
    caView.photoClickBlock = ^{
        [[CameraManager sharedManager] getPhotoImage:^(NSImage * _Nonnull image) {
            [weakSelf.dataArray addObject:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.mainCollection reloadData];
            });
        }];
    };
    [self.splitView addArrangedSubview:caView];
    [self.view addSubview:self.splitView];
    
    JXFunctionListView *fListView = [[JXFunctionListView alloc] initWithFrame:NSMakeRect(self.view.frame.size.width-FWidth, 0, FWidth, self.view.frame.size.height)];
    [self.view addSubview:fListView];
    
     [[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
    
}

#pragma mark NSSplitViewDelegate
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return imageListWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return imageListWidth;
}

// 能否折叠子视图
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return YES;
}

- (void)splitViewWillResizeSubviews:(NSNotification *)notification {
    
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    
}

#pragma mark NSCollectionViewDelegate
//个数
-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
//内容
-(NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    JXImageDataItem *item = [collectionView makeItemWithIdentifier:@"JXImageDataItem" forIndexPath:indexPath];
    item.image = self.dataArray[indexPath.item];
    item.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
    return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSIndexPath *indexPath = indexPaths.allObjects.firstObject;
    JXImageDataItem *cell = (JXImageDataItem *)[collectionView itemAtIndexPath:indexPath];
    cell.view.layer.backgroundColor = NSColor.lightGrayColor.CGColor;
}

- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSIndexPath *indexPath = indexPaths.allObjects.firstObject;
    JXImageDataItem *cell = (JXImageDataItem *)[collectionView itemAtIndexPath:indexPath];
    cell.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
}

#pragma mark - 布局协议
//item的size
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(imageListWidth, imageCellHeight);
}


@end
