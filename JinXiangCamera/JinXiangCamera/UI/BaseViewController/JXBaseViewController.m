//
//  JXBaseViewController.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/3.
//

#import "JXBaseViewController.h"

@interface JXBaseViewController ()

@end

@implementation JXBaseViewController

//macOS 调用View初始化
- (void)loadView {
//    CGRect windowRect = [NSApplication sharedApplication].mainWindow.frame; [NSScreen mainScreen].frame
    self.view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, mainScreendWidth, mainScreendHeight)];
    self.view.wantsLayer = YES;//显示View之前调用
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

@end
