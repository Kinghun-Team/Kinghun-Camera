//
//  JXCameraView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/16.
//

#import "JXCameraView.h"
//#import "CustomButton.h"

#define tabBarHeight   100

@interface JXCameraView()<cameraManagerDelegate>

@property(nonatomic,strong)NSButton *photoButton;

@end

@implementation JXCameraView

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
        
        [CameraManager sharedManager].delegate = self;
        [[CameraManager sharedManager] start];
        
//        self.photoButton.shadowOffset = CGSizeMake(1, 2);
//        [self.photoButton setTitle:@"拍照" color:[NSColor whiteColor] font:18];
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
    _cameraView.frame = NSMakeRect(0, tabBarHeight, frame.size.width, frame.size.height - tabBarHeight);
    _photoButton.frame = NSMakeRect(frame.size.width-50-25, 25, 50, 50);
}

@end
