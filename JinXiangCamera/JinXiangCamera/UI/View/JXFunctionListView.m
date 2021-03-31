//
//  JXFunctionListView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/2/6.
//

#import "JXFunctionListView.h"

#define typeTag  100000

@interface JXFunctionListView ()<NSTableViewDelegate,NSTableViewDataSource,NSComboBoxDelegate,NSComboBoxDataSource,NSTextFieldDelegate>

@property(nonatomic,strong)NSTableView *cameraTab;
@property(nonatomic,strong)NSTableColumn *cameraColumn;

@property(nonatomic,assign)NSInteger selectCameraIndex;
@property(nonatomic,strong)dispatch_source_t timer;

@property(nonatomic,strong)NSComboBox *selectbox;
@property(nonatomic,strong)NSComboBox *imageType;

@property(nonatomic,strong)NSArray *imageSizeArray;
@property(nonatomic,strong)NSArray *typeArray;

@property(nonatomic,strong)NSButton *customImage;
@property(nonatomic,strong)NSButton *dateImage;

@property(nonatomic,strong)NSTextField *textField;

@property(nonatomic,strong)NSButton *colourBtn;
@property(nonatomic,strong)NSButton *grayscaleBtn;
@property(nonatomic,strong)NSButton *blackAndWhiteBtn;

@end

@implementation JXFunctionListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
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

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [self initView];
        
        [self findCamera];
    }
    return self;
}

- (void)initView {
    self.selectCameraIndex = 0;
    NSScrollView *tableContainerView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, self.frame.size.height-120, self.frame.size.width, 120)];
    tableContainerView.hasVerticalScroller = YES;
    
    self.cameraTab = [[NSTableView alloc] initWithFrame:tableContainerView.bounds];
    self.cameraTab.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;
    self.cameraTab.delegate = self;
    self.cameraTab.rowHeight = 25;
    self.cameraTab.focusRingType = NSFocusRingTypeNone;
    self.cameraTab.dataSource = self;
    self.cameraColumn = [[NSTableColumn alloc] initWithIdentifier:@"column"];
    self.cameraColumn.resizingMask = NSTableColumnNoResizing;
    self.cameraColumn.title = @"当前摄像头：";
    
    [self.cameraColumn setWidth:150];
    [self.cameraTab addTableColumn:self.cameraColumn];
    [tableContainerView setDocumentView:self.cameraTab];
    self.cameraTab.headerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self addSubview:tableContainerView];
    
    self.selectbox = [[NSComboBox alloc] initWithFrame:NSMakeRect(70, self.frame.size.height - 160, self.frame.size.width - 90, 30)];
    self.selectbox.usesDataSource = YES;
    self.selectbox.textColor = [NSColor blackColor];
    self.selectbox.backgroundColor = [NSColor whiteColor];
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
    
    self.imageType = [[NSComboBox alloc] initWithFrame:NSMakeRect(70, self.frame.size.height - 190, self.frame.size.width - 90, 30)];
    self.imageType.usesDataSource = YES;
    self.imageType.dataSource = self;
    self.imageType.textColor = [NSColor blackColor];
    self.imageType.backgroundColor = [NSColor whiteColor];
    self.imageType.delegate = self;
    self.imageType.tag = typeTag;
    [self.imageType selectItemAtIndex:0];
    self.imageType.editable = NO;
    [self addSubview:self.imageType];
    
    JHLabel *imageNameType = [[JHLabel alloc] initWithFrame:NSMakeRect(10, self.frame.size.height-220, 100, 20)];
    imageNameType.wantsLayer = YES;
    imageNameType.backgroundColor = [NSColor clearColor];
    imageNameType.font = [NSFont systemFontOfSize:13];
    [self addSubview:imageNameType];
    imageNameType.text = @"命名方式：";
    
    self.dateImage = [[NSButton alloc] init];
    [self.dateImage setButtonType:NSButtonTypeRadio];
    self.dateImage.bezelStyle = NSRoundedBezelStyle;
    [self.dateImage setState:NSGestureRecognizerStateBegan];
    self.dateImage.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.dateImage.title = @"时间日期";
    [self.dateImage setTitle:[self.dateImage title] color:[NSColor blackColor] font:12];
    self.dateImage.target = self;
    self.dateImage.action = @selector(dateClick:);
    [self addSubview:self.dateImage];
    self.dateImage.frame = NSMakeRect(20, imageNameType.frame.origin.y-imageNameType.frame.size.height-15, 100, 30);
    
    self.customImage = [[NSButton alloc] init];
    [self.customImage setButtonType:NSButtonTypeRadio];
    self.customImage.bezelStyle = NSRoundedBezelStyle;
    self.customImage.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.customImage.title = @"自定义";
    [self.customImage setTitle:[self.customImage title] color:[NSColor blackColor] font:12];
    self.customImage.target = self;
    self.customImage.action = @selector(customClick:);
    [self addSubview:self.customImage];
    self.customImage.frame = NSMakeRect(20, self.dateImage.frame.origin.y-self.dateImage.frame.size.height, 100, 30);
    
    self.textField = [[NSTextField alloc] initWithFrame:CGRectMake(20, self.customImage.frame.origin.y-self.customImage.frame.size.height-5, 80, 26)];
    self.textField.backgroundColor = [NSColor clearColor];
    self.textField.stringValue = [FileManager sharedManager].imageFirstName;
    [[self.textField cell] setScrollable:YES];
    self.textField.delegate = self;
    self.textField.focusRingType = NSFocusRingTypeNone;
    [self.textField setTextColor:[NSColor blackColor]];
    [self.textField setFont:[NSFont systemFontOfSize:16]];
    [self addSubview:self.textField];
    
    self.imageNameLast = [[JHLabel alloc] initWithFrame:NSMakeRect(self.textField.frame.origin.x+self.textField.frame.size.width+10, self.textField.frame.origin.y+6, 80, 20)];
    self.imageNameLast.wantsLayer = YES;
    self.imageNameLast.backgroundColor = [NSColor clearColor];
    self.imageNameLast.font = [NSFont systemFontOfSize:13];
    [self addSubview:self.imageNameLast];
    self.imageNameLast.text = [NSString stringWithFormat:@"+%@",[FileManager sharedManager].imageLastName];
    
    JHLabel *colorModeLabel = [[JHLabel alloc] initWithFrame:NSMakeRect(10, self.frame.size.height-360, 100, 20)];
    colorModeLabel.wantsLayer = YES;
    colorModeLabel.backgroundColor = [NSColor clearColor];
    colorModeLabel.font = [NSFont systemFontOfSize:13];
    [self addSubview:colorModeLabel];
    colorModeLabel.text = @"色彩模式：";
    
    self.colourBtn = [[NSButton alloc] init];
    [self.colourBtn setButtonType:NSButtonTypeRadio];
    self.colourBtn.bezelStyle = NSRoundedBezelStyle;
    [self.colourBtn setState:NSGestureRecognizerStateBegan];
    self.colourBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.colourBtn.title = @"彩色";
    [self.colourBtn setTitle:[self.colourBtn title] color:[NSColor blackColor] font:12];
    self.colourBtn.target = self;
    self.colourBtn.action = @selector(colorClick:);
    [self addSubview:self.colourBtn];
    self.colourBtn.frame = NSMakeRect(10, colorModeLabel.frame.origin.y-colorModeLabel.frame.size.height-15, 60, 30);
    
    self.grayscaleBtn = [[NSButton alloc] init];
    [self.grayscaleBtn setButtonType:NSButtonTypeRadio];
    self.grayscaleBtn.bezelStyle = NSRoundedBezelStyle;
    self.grayscaleBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.grayscaleBtn.title = @"灰度";
    [self.grayscaleBtn setTitle:[self.grayscaleBtn title] color:[NSColor blackColor] font:12];
    self.grayscaleBtn.target = self;
    self.grayscaleBtn.action = @selector(grayClick:);
    [self addSubview:self.grayscaleBtn];
    self.grayscaleBtn.frame = NSMakeRect(self.colourBtn.frame.origin.x+self.colourBtn.frame.size.width+5, colorModeLabel.frame.origin.y-colorModeLabel.frame.size.height-15, 60, 30);
    
    self.blackAndWhiteBtn = [[NSButton alloc] init];
    [self.blackAndWhiteBtn setButtonType:NSButtonTypeRadio];
    self.blackAndWhiteBtn.bezelStyle = NSRoundedBezelStyle;
    self.blackAndWhiteBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.blackAndWhiteBtn.title = @"黑白";
    [self.blackAndWhiteBtn setTitle:[self.blackAndWhiteBtn title] color:[NSColor blackColor] font:12];
    self.blackAndWhiteBtn.target = self;
    self.blackAndWhiteBtn.action = @selector(blackClick:);
    [self addSubview:self.blackAndWhiteBtn];
    self.blackAndWhiteBtn.frame = NSMakeRect(self.grayscaleBtn.frame.origin.x+self.grayscaleBtn.frame.size.width+5, colorModeLabel.frame.origin.y-colorModeLabel.frame.size.height-15, 60, 30);
}

- (void)dateClick:(NSButton *)button {
    [button setState:NSGestureRecognizerStateBegan];
    [[FileManager sharedManager] setImageName:FileDate];
    [self.customImage setState:NSGestureRecognizerStatePossible];
}

- (void)customClick:(NSButton *)button {
    [button setState:NSGestureRecognizerStateBegan];
    [[FileManager sharedManager] setImageName:FileCustom];
    [self.dateImage setState:NSGestureRecognizerStatePossible];
}

- (void)colorClick:(NSButton *)button {
    [button setState:NSGestureRecognizerStateBegan];
    [self.grayscaleBtn setState:NSGestureRecognizerStatePossible];
    [self.blackAndWhiteBtn setState:NSGestureRecognizerStatePossible];
    
    [[CameraManager sharedManager] setCameraRGBType:Colour];
}

- (void)grayClick:(NSButton *)button {
    [button setState:NSGestureRecognizerStateBegan];
    [self.colourBtn setState:NSGestureRecognizerStatePossible];
    [self.blackAndWhiteBtn setState:NSGestureRecognizerStatePossible];
    
    [[CameraManager sharedManager] setCameraRGBType:GrayColor];
}

- (void)blackClick:(NSButton *)button {
    [button setState:NSGestureRecognizerStateBegan];
    [self.colourBtn setState:NSGestureRecognizerStatePossible];
    [self.grayscaleBtn setState:NSGestureRecognizerStatePossible];
    
    [[CameraManager sharedManager] setCameraRGBType:blackAndWhite] ;
}

#pragma mark - NSTextFieldDelegate
-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        return true;
    }
    return false;
}
// 控制文本输入框的内容长度.
-(void)controlTextDidChange:(NSNotification *)obj {
    NSInteger accountMaxLimit = 8;
    if (self.textField.stringValue.length > accountMaxLimit) {
        self.textField.stringValue = [self.textField.stringValue substringToIndex:accountMaxLimit];
    }
    [FileManager sharedManager].imageFirstName = self.textField.stringValue;
    self.imageNameLast.text = [NSString stringWithFormat:@"+%@",[FileManager sharedManager].imageLastName];
}

- (void)findCamera {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
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
                [[FileManager sharedManager] choiceImageType:IMGPNG];
                break;
            case 1:
                [[FileManager sharedManager] choiceImageType:IMGJPG];
                break;
            case 2:
                [[FileManager sharedManager] choiceImageType:IMGTIF];
                break;
            case 3:
                [[FileManager sharedManager] choiceImageType:IMGBMP];
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
