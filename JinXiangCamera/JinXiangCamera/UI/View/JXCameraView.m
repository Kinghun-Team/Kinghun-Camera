//
//  JXCameraView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/16.
//

#import "JXCameraView.h"
//#import "CustomButton.h"

#define tabBarHeight   100

@interface JXCameraView()<cameraManagerDelegate,NSComboBoxDelegate,NSComboBoxDataSource>

@property(nonatomic,strong)NSButton *photoButton;

@property(nonatomic,strong)NSArray *pathArray;

@end

@implementation JXCameraView

- (NSArray *)pathArray {
    if (!_pathArray) {
        _pathArray = @[@"下载", @"桌面"];
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
        self.layer.backgroundColor = [NSColor colorWithWhite:0.95 alpha:1].CGColor;
        
        JHLabel *pathLabel = [[JHLabel alloc] initWithFrame:NSMakeRect(100, self.frame.size.height - 35 , 70, 25)];
        pathLabel.wantsLayer = YES;
        pathLabel.backgroundColor = [NSColor clearColor];
        pathLabel.font = [NSFont systemFontOfSize:13];
        pathLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:pathLabel];
        pathLabel.text = @"保存路径：";
        
        NSComboBox *selectPath = [[NSComboBox alloc] initWithFrame:NSMakeRect(170, self.frame.size.height - 40, 300, 30)];
        selectPath.usesDataSource = YES;
        selectPath.dataSource = self;
        selectPath.delegate = self;
        [selectPath selectItemAtIndex:0];
        selectPath.editable = NO;
        [self addSubview:selectPath];
        
        self.cameraView = [[NSImageView alloc] init];
        self.cameraView.wantsLayer = YES;
//        self.cameraView.layer.backgroundColor = [NSColor colorWithWhite:0.9 alpha:1].CGColor;
        [self addSubview:self.cameraView];
        
        self.photoButton = [[NSButton alloc] init];
        self.photoButton.bezelStyle = NSRoundedBezelStyle;
        self.photoButton.title = @"拍照";
        self.photoButton.target = self;
        self.photoButton.action = @selector(photoClick);
        [self addSubview:self.photoButton];
        
        [CameraManager sharedManager].allCamera = YES;
        [CameraManager sharedManager].delegate = self;
        [[CameraManager sharedManager] start];
    }
    return self;
}

-(void)cameraBufferIamge:(NSImage *)image {
    self.cameraView.image = image;
}

- (void)photoClick {
    if (self.photoClickBlock) {
        self.photoClickBlock();
    }
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self updateFrame:frame];
    
}

- (void)updateFrame:(NSRect)frame {
    _cameraView.frame = NSMakeRect(0, tabBarHeight, frame.size.width, frame.size.height - tabBarHeight - 50);
    _photoButton.frame = NSMakeRect(frame.size.width-50-25, 25, 50, 50);
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
        [CameraManager sharedManager].searchPath = NSDownloadsDirectory;
    } else {
        [CameraManager sharedManager].searchPath = NSDesktopDirectory;
    }
}

@end
