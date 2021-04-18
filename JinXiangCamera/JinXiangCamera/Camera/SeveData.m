//
//  SeveData.m
//  JinXiangCamera
//
//  Created by Apple on 2021/4/18.
//

#import "SeveData.h"

@implementation SeveData

static SeveData *seveData;
+ (SeveData *)initData {
    if (!seveData)
    {
        seveData = [[SeveData alloc] init];
    }
    return seveData;
}

- (void)setSelectSize:(NSInteger)selectSize {
    [[NSUserDefaults standardUserDefaults] setInteger:selectSize forKey:JXSelectSize];
}

- (NSInteger)selectSize {
    return [[NSUserDefaults standardUserDefaults] integerForKey:JXSelectSize];
}

- (void)setSelectImageType:(NSInteger)selectImageType {
    [[NSUserDefaults standardUserDefaults] setInteger:selectImageType forKey:JXSelectImageType];
}

- (NSInteger)selectImageType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:JXSelectImageType];
}

- (void)setFileSelectIndex:(NSInteger)fileSelectIndex {
    [[NSUserDefaults standardUserDefaults] setInteger:fileSelectIndex forKey:JXFileSelectIndex];
}

- (NSInteger)fileSelectIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:JXFileSelectIndex];
}

- (void)setFileArray:(NSMutableArray *)fileArray {
    [[NSUserDefaults standardUserDefaults] setObject:fileArray forKey:JXFileArray];
}

- (NSMutableArray *)fileArray {
    return [[NSUserDefaults standardUserDefaults] objectForKey:JXFileArray];
}

@end
