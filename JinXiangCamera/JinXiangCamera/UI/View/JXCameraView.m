//
//  JXCameraView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/16.
//

#import "JXCameraView.h"


#define tabBarHeight   100

@interface JXCameraView()<cameraManagerDelegate>

@property(nonatomic,strong)NSScrollView *imageScView;

@property(nonatomic,strong)NSArray *pathArray;

@end

@implementation JXCameraView



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor colorWithWhite:0.95 alpha:1].CGColor;
        
        self.cameraView = [[NSImageView alloc] init];
        self.cameraView.wantsLayer = YES;
        self.cameraView.imageScaling = NSImageScaleNone;
        
        self.imageScView = [[NSScrollView alloc] init];
        self.imageScView.documentView = self.cameraView;
        self.imageScView.hasVerticalScroller = YES;
        self.imageScView.hasHorizontalScroller = YES;
        self.imageScView.horizontalScrollElasticity = NSScrollElasticityNone;
        self.imageScView.verticalScrollElasticity = NSScrollElasticityNone;
        [self addSubview:self.imageScView];
        
        NSButton *enlargeBtn = [[NSButton alloc] init];
        enlargeBtn.frame = NSMakeRect(100, 25, 50, 50);
        enlargeBtn.bezelStyle = NSRoundedBezelStyle;
        enlargeBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
        enlargeBtn.title = @"放大";
        [enlargeBtn setTitle:[enlargeBtn title] color:[NSColor blackColor] font:12];
        enlargeBtn.target = self;
        enlargeBtn.action = @selector(enlargeClick);
        [self addSubview:enlargeBtn];
        
        NSButton *narrowBtn = [[NSButton alloc] init];
        narrowBtn.frame = NSMakeRect(40, 25, 50, 50);
        narrowBtn.bezelStyle = NSRoundedBezelStyle;
        narrowBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
        narrowBtn.title = @"缩小";
        [narrowBtn setTitle:[narrowBtn title] color:[NSColor blackColor] font:12];
        narrowBtn.target = self;
        narrowBtn.action = @selector(narrowClick);
        [self addSubview:narrowBtn];
        
        NSButton *LeftRotation = [[NSButton alloc] init];
        LeftRotation.frame = NSMakeRect(160, 25, 70, 50);
        LeftRotation.bezelStyle = NSRoundedBezelStyle;
        LeftRotation.layer.backgroundColor = [NSColor whiteColor].CGColor;
        LeftRotation.title = @"左旋转";
        [LeftRotation setTitle:[LeftRotation title] color:[NSColor blackColor] font:12];
        LeftRotation.target = self;
        LeftRotation.action = @selector(leftClick);
        [self addSubview:LeftRotation];
        
        NSButton *RightRotation = [[NSButton alloc] init];
        RightRotation.frame = NSMakeRect(240, 25, 70, 50);
        RightRotation.bezelStyle = NSRoundedBezelStyle;
        RightRotation.layer.backgroundColor = [NSColor whiteColor].CGColor;
        RightRotation.title = @"右旋转";
        [RightRotation setTitle:[RightRotation title] color:[NSColor blackColor] font:12];
        RightRotation.target = self;
        RightRotation.action = @selector(rightClick);
        [self addSubview:RightRotation];
        
        [CameraManager sharedManager].allCamera = YES;
        [CameraManager sharedManager].delegate = self;
        [[CameraManager sharedManager] start];
    }
    return self;
}

- (void)cameraBufferIamge:(NSImage *)image {
    image.size = NSMakeSize(image.size.width*[CameraManager sharedManager].imageScale, image.size.height*[CameraManager sharedManager].imageScale);
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - tabBarHeight;
    if (image.size.width > width) {
        x = 0.0;
        width = image.size.width;
    } else {
        x = (width - image.size.width) / 2;
    }
    if (image.size.height > height) {
        y = 0.0;
        height = image.size.height;
    } else {
        y = (height - image.size.height) / 2;
    }
    self.cameraView.frame = CGRectMake(x, y, image.size.width, image.size.height);
    [self.imageScView.documentView setFrameSize:NSMakeSize(width, height)];
    self.cameraView.image = image;
}

- (void)enlargeClick {
    if ([CameraManager sharedManager].imageScale < 2.0) {
//        self.imageScView.documentView.
//        [self.imageScView.documentView scrollPoint:NSMakePoint(x,y)];
        [CameraManager sharedManager].imageScale += 0.1;
    }
}

- (void)narrowClick {
    if ([CameraManager sharedManager].imageScale > 0.5) {
//        [self.imageScView.documentView scrollPoint:NSMakePoint(x,y)];
        [CameraManager sharedManager].imageScale -= 0.1;
    }
}

- (void)leftClick {
    if ([CameraManager sharedManager].rotate == 0) {
        [CameraManager sharedManager].rotate = 3;
    } else {
        [CameraManager sharedManager].rotate -= 1;
    }
}

- (void)rightClick {
    if ([CameraManager sharedManager].rotate == 3) {
        [CameraManager sharedManager].rotate = 0;
    } else {
        [CameraManager sharedManager].rotate += 1;
    }
}


- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self updateFrame:frame];
}

- (void)updateFrame:(NSRect)frame {
    _imageScView.frame = NSMakeRect(0, tabBarHeight, frame.size.width, frame.size.height - tabBarHeight);
}



@end
