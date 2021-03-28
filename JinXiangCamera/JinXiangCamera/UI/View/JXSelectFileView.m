//
//  JXSelectFileView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/3/23.
//

#import "JXSelectFileView.h"

@interface JXSelectFileView()<cameraManagerDelegate,NSComboBoxDelegate,NSComboBoxDataSource>

@property(nonatomic,strong)NSComboBox *selectPath;
@property(nonatomic,strong)NSMutableArray *pathArray;

@end

@implementation JXSelectFileView

- (NSMutableArray *)pathArray {
    if (!_pathArray) {
        _pathArray = [NSMutableArray arrayWithArray:@[@"下载", @"桌面"]];
    }
    return _pathArray;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
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
    
    JHLabel *pathLabel = [[JHLabel alloc] initWithFrame:NSMakeRect((self.frame.size.width - 370 - 100)/2, self.frame.size.height - 35 , 70, 25)];
    pathLabel.wantsLayer = YES;
    pathLabel.backgroundColor = [NSColor clearColor];
    pathLabel.font = [NSFont systemFontOfSize:13];
    pathLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:pathLabel];
    pathLabel.text = @"保存路径：";

    self.selectPath = [[NSComboBox alloc] initWithFrame:NSMakeRect(pathLabel.frame.origin.x+pathLabel.frame.size.width, self.frame.size.height - 40, 300, 30)];
    self.selectPath.usesDataSource = YES;
    self.selectPath.dataSource = self;
    self.selectPath.delegate = self;
    self.selectPath.textColor = [NSColor blackColor];
    self.selectPath.backgroundColor = [NSColor whiteColor];
    [self.selectPath selectItemAtIndex:0];
    self.selectPath.editable = NO;
    [self addSubview:self.selectPath];
    
    NSButton *selectFileBtn = [[NSButton alloc] init];
    selectFileBtn.frame = NSMakeRect(self.selectPath.frame.origin.x+self.selectPath.frame.size.width, self.frame.size.height - 40, 80, 30);
    selectFileBtn.bezelStyle = NSRoundedBezelStyle;
    selectFileBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
    selectFileBtn.title = @"选择文件";
    [selectFileBtn setTitle:[selectFileBtn title] color:[NSColor blackColor] font:12];
    selectFileBtn.target = self;
    selectFileBtn.action = @selector(selectFilePath);
    [self addSubview:selectFileBtn];
    
    NSView *lineView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 0.5)];
    lineView.wantsLayer = YES;
    lineView.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self addSubview:lineView];
}

#pragma mark - NSComboBoxDataSource
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return  self.pathArray.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    return  self.pathArray[index];
}
  
#pragma mark - NSComboBoxDelegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSComboBox *comboBox = notification.object;
    NSInteger selectedIndex = comboBox.indexOfSelectedItem;
    if (selectedIndex == 0) {
        [CameraManager sharedManager].isSystemFileSave = YES;
        [CameraManager sharedManager].searchPath = NSDownloadsDirectory;
    } else if (selectedIndex == 1) {
        [CameraManager sharedManager].isSystemFileSave = YES;
        [CameraManager sharedManager].searchPath = NSDesktopDirectory;
    } else {
        [CameraManager sharedManager].isSystemFileSave = NO;
        [CameraManager sharedManager].userFilePath = self.pathArray[selectedIndex];
    }
}

- (void)selectFilePath {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];//是否可以选择文件夹
    [openPanel setCanChooseFiles:NO];//是否可以选择文件
    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    //[openPanel runModal]此时线程会停在这里等待选择
    //NO表示用户取消 YES表示用户做出选择
    if(okButtonPressed) {
        NSString *path = [[openPanel URL] path];
        if (![self.pathArray containsObject:path]) {
            [self.pathArray addObject:path];
            [self.selectPath reloadData];
            self.selectPath.stringValue = path;
            [CameraManager sharedManager].isSystemFileSave = NO;
            [CameraManager sharedManager].userFilePath = path;
        }
    }
}

@end
