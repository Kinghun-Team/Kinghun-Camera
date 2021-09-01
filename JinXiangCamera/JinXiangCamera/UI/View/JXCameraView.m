//
//  JXCameraView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/16.
//

#import "JXCameraView.h"


#define tabBarHeight   30

@interface JXCameraView()<cameraManagerDelegate>

@property(nonatomic,strong)NSScrollView *imageScView;

@property(nonatomic,strong)NSArray *pathArray;

@property(nonatomic,strong)NSArray *arrWidth;
@property(nonatomic,strong)NSArray *arrHeight;
@property(nonatomic,strong)NSArray *arrMinScale;


@end

@implementation JXCameraView

- (NSArray *)arrWidth{
    if (!_arrWidth) {
        _arrWidth = @[@"1920", @"2560",@"3840", @"4480"];
        
    }
    return _arrWidth;
}

- (NSArray *)arrHeight{
    if (!_arrHeight) {
        _arrHeight = @[@"1080", @"1440",@"2160", @"2520"];
    }
    return _arrHeight;
}

- (NSArray *)arrMinScale{
    if (!_arrMinScale) {
        _arrMinScale = @[@"0.35", @"0.26",@"0.18", @"0.15"];
    }
    return _arrMinScale;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
//        self.layer.backgroundColor = [NSColor colorWithRed:(0.266) green:(0.266) blue:(0.266) alpha:(1)].CGColor;
//        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
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
        enlargeBtn.wantsLayer = YES;
        enlargeBtn.frame = NSMakeRect(10, 5, 70, 20);
        enlargeBtn.bezelStyle = NSRoundedBezelStyle;
//        enlargeBtn.bezelStyle = NSBezelStyleRounded;
//        enlargeBtn.layer.backgroundColor = [NSColor colorWithRed:(1) green:(0.266) blue:(0.266) alpha:(1)].CGColor;
        enlargeBtn.title = @"放大";
        [enlargeBtn setTitle:[enlargeBtn title] color:[NSColor colorWithRed:(0) green:(0) blue:(0) alpha:(1)] font:12];
        enlargeBtn.target = self;
        enlargeBtn.action = @selector(enlargeClick);
        [self addSubview:enlargeBtn];
        
        NSButton *narrowBtn = [[NSButton alloc] init];
        narrowBtn.frame = NSMakeRect(10 + 80, 0, 70, 30);
        narrowBtn.bezelStyle = NSRoundedBezelStyle;
        narrowBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
        narrowBtn.title = @"缩小";
        [narrowBtn setTitle:[narrowBtn title] color:[NSColor blackColor] font:12];
        narrowBtn.target = self;
        narrowBtn.action = @selector(narrowClick);
        [self addSubview:narrowBtn];
        
        NSButton *suitBtn = [[NSButton alloc] init];
        suitBtn.frame = NSMakeRect(10 + 160, 0, 70, 30);
        suitBtn.bezelStyle = NSRoundedBezelStyle;
        suitBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
        suitBtn.title = @"适合";
        [suitBtn setTitle:[suitBtn title] color:[NSColor blackColor] font:12];
        suitBtn.target = self;
        suitBtn.action = @selector(suitClick);
        [self addSubview:suitBtn];
        
        NSButton *pixelBtn = [[NSButton alloc] init];
        pixelBtn.frame = NSMakeRect(10 + 240, 0, 70, 30);
        pixelBtn.bezelStyle = NSRoundedBezelStyle;
        pixelBtn.layer.backgroundColor = [NSColor whiteColor].CGColor;
        pixelBtn.title = @"1:1";
        [pixelBtn setTitle:[pixelBtn title] color:[NSColor blackColor] font:12];
        pixelBtn.target = self;
        pixelBtn.action = @selector(pixelClick);
        [self addSubview:pixelBtn];
        
        NSButton *LeftRotation = [[NSButton alloc] init];
        LeftRotation.frame = NSMakeRect(10 + 320, 0, 70, 30);
        LeftRotation.bezelStyle = NSRoundedBezelStyle;
        LeftRotation.layer.backgroundColor = [NSColor whiteColor].CGColor;
        LeftRotation.title = @"左旋转";
        [LeftRotation setTitle:[LeftRotation title] color:[NSColor blackColor] font:12];
        LeftRotation.target = self;
        LeftRotation.action = @selector(leftClick);
        [self addSubview:LeftRotation];
        
        NSButton *RightRotation = [[NSButton alloc] init];
        RightRotation.frame = NSMakeRect(10 + 400, 0, 70, 30);
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
    if([CameraManager sharedManager].getPhoto == YES) {
        return;
    }
    image.size = NSMakeSize(image.size.width*[CameraManager sharedManager].imageScale, image.size.height*[CameraManager sharedManager].imageScale);
//    NSLog(@"image.size.width = %f", image.size.width);
//    NSLog(@"image.size.height = %f", image.size.height);
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - tabBarHeight;
    if (image.size.width > width) {
        x = 0.0;
//        x = (image.size.width - width) / 2;
        width = image.size.width;
    } else {
        x = (width - image.size.width) / 2;
    }
    if (image.size.height > height) {
        y = 0.0;
//        y = (image.size.height - height) / 2;
        height = image.size.height;
    } else {
        y = (height - image.size.height) / 2;
    }
    self.cameraView.frame = CGRectMake(x, y, image.size.width, image.size.height);
    [self.imageScView.documentView setFrameSize:NSMakeSize(width, height)];
    self.cameraView.image = image;
}

- (void)enlargeClick {
    [CameraManager sharedManager].imageScale += 0.025;
    if ([CameraManager sharedManager].imageScale > 2.0) {
//        self.imageScView.documentView.
//        [self.imageScView.documentView scrollPoint:NSMakePoint(x,y)];
        [CameraManager sharedManager].imageScale = 2.0;
    }
    NSLog(@"imageScale = %f", [CameraManager sharedManager].imageScale);
}

- (void)narrowClick {
    CGFloat div;
    div = [self.arrMinScale[[CameraManager sharedManager].imageSize] floatValue];
    
    [CameraManager sharedManager].imageScale -= 0.025;
    if ([CameraManager sharedManager].imageScale < div) {
//        [self.imageScView.documentView scrollPoint:NSMakePoint(x,y)];
        [CameraManager sharedManager].imageScale = div;
    }
//    [CameraManager sharedManager].imageScale = div;
    NSLog(@"imageScale = %f", [CameraManager sharedManager].imageScale);
}

- (void)suitClick {
    CGFloat div;
    if (labs([CameraManager sharedManager].rotate % 2) == 0) {
        //水平方向
        div = [self.arrWidth[[CameraManager sharedManager].imageSize] floatValue];
        [CameraManager sharedManager].imageScale = (self.frame.size.width) * 2 * 0.99 / div;
    } else {
        //垂直方向
        div = [self.arrHeight[[CameraManager sharedManager].imageSize] floatValue];
        [CameraManager sharedManager].imageScale = (self.frame.size.height) * 1.05 / div;
    }

    NSLog(@"self.frame.size.width = %f", self.frame.size.width);
    NSLog(@"self.frame.size.height = %f", self.frame.size.height);
    NSLog(@"div = %f", div);
    NSLog(@"imageScale = %f", [CameraManager sharedManager].imageScale);
}

- (void)pixelClick {
    [CameraManager sharedManager].imageScale = 2;
}

- (void)leftClick {
    if ([CameraManager sharedManager].rotate == 0) {
        [CameraManager sharedManager].rotate = 3;
    } else {
        [CameraManager sharedManager].rotate -= 1;
    }
    [self suitClick];
}

- (void)rightClick {
    if ([CameraManager sharedManager].rotate == 3) {
        [CameraManager sharedManager].rotate = 0;
    } else {
        [CameraManager sharedManager].rotate += 1;
    }
    [self suitClick];
}


- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    [self updateFrame:frame];
}

- (void)updateFrame:(NSRect)frame {
    _imageScView.frame = NSMakeRect(0, tabBarHeight, frame.size.width, frame.size.height - tabBarHeight);
}



@end
