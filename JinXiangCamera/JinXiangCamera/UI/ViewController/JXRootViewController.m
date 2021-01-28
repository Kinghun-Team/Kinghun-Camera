//
//  JXRootViewController.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/3.
//

#import "JXRootViewController.h"
#import "JXImageDataView.h"
#import "JXCameraView.h"

#define imageListWidth  240
#define imageCellHeight 205

@interface JXRootViewController ()<NSSplitViewDelegate,NSTableViewDelegate,NSTableViewDataSource>

@property(nonatomic,strong)NSMutableArray<AVCaptureDevice *> *cameraList;

@property(nonatomic,strong)NSSplitView *splitView;

@property(nonatomic,strong)NSTableView *imageListView;
@property(nonatomic,strong)JXCameraView *caView;

@property(nonatomic,copy)NSMutableArray *dataArray;

@end

@implementation JXRootViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    //检测摄像头
    [self findCamera];
}

- (NSSplitView *)splitView {
    if (!_splitView) {
        _splitView = [[NSSplitView alloc] initWithFrame:self.view.bounds];
        _splitView.wantsLayer = YES;
        _splitView.delegate = self;
        _splitView.vertical = YES;
        _splitView.dividerStyle = NSSplitViewDividerStyleThin;
        _splitView.layer.backgroundColor = NSColor.whiteColor.CGColor;
    }
    return _splitView;
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
    
    NSScrollView *tableContainerView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, imageListWidth, _splitView.frame.size.height)];
    tableContainerView.hasVerticalScroller = YES;
    self.imageListView = [[NSTableView alloc] initWithFrame: tableContainerView.bounds];
    self.imageListView.delegate = self;
    self.imageListView.rowHeight = imageCellHeight;
    self.imageListView.dataSource = self;
    self.imageListView.headerView = [NSTableHeaderView new];
    NSTableColumn * column = [[NSTableColumn alloc] initWithIdentifier:@"column"];
    column.resizingMask = NSTableColumnNoResizing;
//    column.headerCell = [NSTableHeaderCell new];
    [column setWidth:200];
    [self.imageListView addTableColumn:column];
    [self.imageListView reloadData];
    [tableContainerView setDocumentView:self.imageListView];
    if (@available(macOS 10.11, *)) {
        [self.splitView addArrangedSubview:tableContainerView];
    } else {
        
    }
    
    JXCameraView *caView = [[JXCameraView alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width-imageListWidth, _splitView.frame.size.height)];
    WS(weakSelf)
    caView.photoClickBlock = ^{
        [[CameraManager sharedManager] getPhotoImage:^(NSImage * _Nonnull image) {
            [weakSelf.dataArray addObject:image];
            [weakSelf.imageListView reloadData];
        }];
    };
    if (@available(macOS 10.11, *)) {
        [self.splitView addArrangedSubview:caView];
    } else {
        
    }
    [self.view addSubview:self.splitView];
//    [self.splitView setPosition:imageListWidth ofDividerAtIndex:0];
    
    [CameraManager cameraDefaultConfig];
    [CameraManager sharedManager].iamgeSize = ImageSize2560;
    
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



#pragma mark Table DataSource
//数据源方法（返回NSTableView有多少行）
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _dataArray.count;
}

//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    return _dataArray[row];
//}

#pragma mark Table Delegate
//设置是否可以进行编辑
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    return NO;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    //根据ID取视图
    JXImageDataView * view = [tableView makeViewWithIdentifier:@"cellId" owner:self];
    if (!view) {
        view = [[JXImageDataView alloc]initWithFrame:CGRectMake(0, 0, imageListWidth, imageCellHeight)];
        view.identifier = @"cellId";
    }
    view.image = self.dataArray[row];
    return view;
}

//- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
//    TableRow * rowView = [[TableRow alloc]init];
//    return rowView;
//}

//选中的响应
- (void)tableViewSelectionDidChange:(nonnull NSNotification *)notification {
    NSTableView* tableView = notification.object;
    //选中的行数
    //tableView.selectedRow;
    //选中的列数(列数无效，因为只能同时选中行。不能单独选中Cell)
    //tableView.selectedColumn;
    NSLog(@"%ld %ld", (long)tableView.selectedRow , (long)tableView.selectedColumn);
}

- (void)findCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *devList = @[@"UVC Camera VendorID_3141 ProductID_5634"];
    self.cameraList = [NSMutableArray array];
    for (AVCaptureDevice *dev in devices) {
        if ([devList containsObject:dev.modelID]) {
            [self.cameraList addObject:dev];
        }
    }
    NSLog(@"%@",self.cameraList);
}



@end
