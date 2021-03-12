//
//  AppDelegate.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/3.
//

#import "AppDelegate.h"
#import "JXRootViewController.h"

@interface AppDelegate ()

@property(nonatomic,strong)NSWindowController *mainWindowController;
@property(nonatomic,strong)NSWindow *mainWindow;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSViewController *mainVC = [[JXRootViewController alloc] init];
    
    self.mainWindow =  [NSWindow windowWithContentViewController:mainVC];
    self.mainWindow.delegate = self;
//    NSWindow *mainWindow = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 1000, 600) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable|NSWindowStyleMaskClosable|NSWindowStyleMaskUtilityWindow backing:NSBackingStoreBuffered defer:NO];
//    mainWindow.contentViewController = mainVC;
    
    [self.mainWindow setContentSize:NSMakeSize(mainScreendWidth, mainScreendHeight)];
    self.mainWindow.minSize = NSMakeSize(mainScreendWidth, mainScreendHeight);//NSMakeSize(800, 600)
    self.mainWindow.maxSize = NSMakeSize(mainScreendWidth, mainScreendHeight);//固定窗口
    
    self.mainWindowController = [[NSWindowController alloc] initWithWindow:self.mainWindow];
    mainVC.view.window.windowController = self.mainWindowController;
    [self.mainWindowController.window makeKeyAndOrderFront:self];
    [self.mainWindowController.window center];
    [self.mainWindowController showWindow:nil];
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApplication hasVisibleWindows:(BOOL)flag {
    if(!flag){
        [NSApp activateIgnoringOtherApps:NO];
        [self.mainWindow makeKeyAndOrderFront:self];//主窗口显示自己方法一
        //[_mainWindow orderFront:nil];           //主窗口显示自己方法二
        return YES;
    }
    return NO;
}

- (BOOL)windowShouldClose:(id)sender {
    [self.mainWindow orderOut:nil];//窗口消失
    return NO;
}

- (NSSize)windowWillResize:(NSWindow*)sender toSize:(NSSize)frameSize {
    return frameSize;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)newFrame {
    return newFrame;
}

- (BOOL)windowShouldZoom:(NSWindow*)window toFrame:(NSRect)newFrame {
    if(newFrame.size.height>350) {
        return YES;
    }
    return NO;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
