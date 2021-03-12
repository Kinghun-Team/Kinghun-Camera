//
//  JXFunctionListView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/2/6.
//

#import "JXFunctionListView.h"

#define typeTag  100000

@interface JXFunctionListView ()<NSTableViewDelegate,NSTableViewDataSource,NSComboBoxDelegate,NSComboBoxDataSource>

@property(nonatomic,strong)NSTableView *cameraTab;
@property(nonatomic,strong)NSTableColumn *cameraColumn;

@property(nonatomic,assign)NSInteger selectCameraIndex;
@property(nonatomic,strong)dispatch_source_t timer;

@property(nonatomic,strong)NSComboBox *selectbox;
@property(nonatomic,strong)NSComboBox *imageType;

@property(nonatomic,strong)NSArray *imageSizeArray;
@property(nonatomic,strong)NSArray *typeArray;

@end

@implementation JXFunctionListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSArray *)imageSizeArray {
    if (!_imageSizeArray) {
        _imageSizeArray = @[@"1920*1080", @"2560*1440",@"3840*2160", @"4480*2520"];
    }
    return _imageSizeArray;
}

- (NSArray *)typeArray {
    if (!_typeArray) {
        _typeArray = @[@".png",@".jpg",@".tif",@".bmp"];
    }
    return _typeArray;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [self initView];
        
    }
    return self;
}

- (void)initView {
    self.selectCameraIndex = 0;
    NSScrollView *tableContainerView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, self.frame.size.height-120, self.frame.size.width, 120)];
    tableContainerView.hasVerticalScroller = YES;
    
    self.cameraTab = [[NSTableView alloc] initWithFrame: tableContainerView.bounds];
    
    self.cameraTab.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;
    self.cameraTab.delegate = self;
    self.cameraTab.rowHeight = 25;
    self.cameraTab.dataSource = self;
    self.cameraColumn = [[NSTableColumn alloc] initWithIdentifier:@"column"];
    self.cameraColumn.resizingMask = NSTableColumnNoResizing;
    self.cameraColumn.title = @"当前摄像头：";
    
    [self.cameraColumn setWidth:150];
    [self.cameraTab addTableColumn:self.cameraColumn];
    [tableContainerView setDocumentView:self.cameraTab];
    [self addSubview:tableContainerView];
    
    self.selectbox = [[NSComboBox alloc] initWithFrame:NSMakeRect(70, self.frame.size.height- 160, 110, 30)];
    self.selectbox.usesDataSource = YES;
    self.selectbox.dataSource = self;
    self.selectbox.delegate = self;
    self.selectbox.tag = typeTag+1;
    [self.selectbox selectItemAtIndex:0];
    self.selectbox.editable = NO;
    [self addSubview:self.selectbox];
    
    JHLabel* sizeLabel = [[JHLabel alloc] initWithFrame:NSMakeRect(10, self.frame.size.height-160 +8, 60, 20)];
    sizeLabel.wantsLayer = YES;
    sizeLabel.backgroundColor = [NSColor clearColor];
    sizeLabel.font = [NSFont systemFontOfSize:13];
    [self addSubview:sizeLabel];
    sizeLabel.text = @"分辨率：";
    
    JHLabel* imageTypeLabel = [[JHLabel alloc] initWithFrame:NSMakeRect(10, self.frame.size.height-190 +8, 60, 20)];
    imageTypeLabel.wantsLayer = YES;
    imageTypeLabel.backgroundColor = [NSColor clearColor];
    imageTypeLabel.font = [NSFont systemFontOfSize:13];
    [self addSubview:imageTypeLabel];
    imageTypeLabel.text = @"类型：";
    
    self.imageType = [[NSComboBox alloc] initWithFrame:NSMakeRect(70, self.frame.size.height - 190, 110, 30)];
    self.imageType.usesDataSource = YES;
    self.imageType.dataSource = self;
    self.imageType.delegate = self;
    self.imageType.tag = typeTag;
    [self.imageType selectItemAtIndex:0];
    self.imageType.editable = NO;
    [self addSubview:self.imageType];
    
    
    
    [self findCamera];
}

- (void)findCamera {
    //1.创建GCD中的定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    //2.设置时间等
    /*
     第一个参数:定时器对象
     第二个参数:DISPATCH_TIME_NOW 表示从现在开始计时
     第三个参数:间隔时间 GCD里面的时间最小单位为 纳秒
     第四个参数:精准度(表示允许的误差,0表示绝对精准)
     */
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *devices = [CameraManager cameraDevice];
            if (devices.count == 0) {
                self.cameraColumn.title = @"当前摄像头：";
                self.selectCameraIndex = 0;
                [[CameraManager sharedManager] stop];
            } else {
                if (self.selectCameraIndex > devices.count-1) {
                    self.selectCameraIndex = 0;
                    [[CameraManager sharedManager] setNewAVCapture:devices[self.selectCameraIndex]];
                }
                AVCaptureDevice *dev = devices[self.selectCameraIndex];
                self.cameraColumn.title = [NSString stringWithFormat:@"当前摄像头：%@",dev.localizedName];
                [[CameraManager sharedManager] start];
            }
            [self.cameraTab reloadData];
        });
    });
    //4.开始执行
    dispatch_resume(timer);
    self.timer = timer;
}

#pragma mark Table DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSArray *devices = [CameraManager cameraDevice];
    return devices.count;
}

#pragma mark Table Delegate
//设置是否可以进行编辑
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    return NO;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *devices = [CameraManager cameraDevice];
    AVCaptureDevice *dev = devices[row];
    return dev.localizedName;
}

//选中的响应
- (void)tableViewSelectionDidChange:(nonnull NSNotification *)notification {
    NSTableView* tableView = notification.object;
    //选中的行数
//    NSLog(@"%ld %ld", (long)tableView.selectedRow , (long)tableView.selectedColumn);
    if (tableView.selectedRow >= 0) {
        if (tableView.selectedRow != self.selectCameraIndex) {
            self.selectCameraIndex = tableView.selectedRow;
            [tableView reloadData];
            //切换摄像头
            NSArray *devices = [CameraManager cameraDevice];
            [[CameraManager sharedManager] setNewAVCapture:devices[self.selectCameraIndex]];
        }
    }
}

#pragma mark - NSComboBoxDataSource
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    if (aComboBox.tag == typeTag) {
        return self.typeArray.count;
    } else {
        return self.imageSizeArray.count;
    }
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (aComboBox.tag == typeTag) {
        return self.typeArray[index];
    } else {
        return self.imageSizeArray[index];
    }
}
  
#pragma mark - NSComboBoxDelegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSComboBox *comboBox = notification.object;
    NSInteger selectedIndex = comboBox.indexOfSelectedItem;
    if (comboBox.tag == typeTag) {
        switch (selectedIndex) {
            case 0:
                [CameraManager sharedManager].imageType = IMGPNG;
                break;
            case 1:
                [CameraManager sharedManager].imageType = IMGJPG;
                break;
            case 2:
                [CameraManager sharedManager].imageType = IMGTIF;
                break;
            case 3:
                [CameraManager sharedManager].imageType = IMGBMP;
                break;
            default:
                break;
        }
    } else {
        switch (selectedIndex) {
            case 0:
                [CameraManager sharedManager].imageSize = imageSize1920;
                break;
            case 1:
                [CameraManager sharedManager].imageSize = imageSize2560;
                break;
            case 2:
                [CameraManager sharedManager].imageSize = imageSize3840;
                break;
            case 3:
                [CameraManager sharedManager].imageSize = imageSize4480;
                break;
//            case 4:
//                [CameraManager sharedManager].imageSize = imageSize3860;
//                break;
            default:
                break;
        }
    }
}



@end
