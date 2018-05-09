//
//  ZJJPhotoBrowserViewController.h
//  ZJJChosePhonePhotosBrowse
//
//  Created by 张锦江 on 2018/5/9.
//  Copyright © 2018年 xtayqria. All rights reserved.
//

#import <MWPhotoBrowser/MWPhotoBrowser.h>

@protocol ZJJDeleteImageDataSourse <NSObject>

- (void)beginToDeleteAtIndex:(NSInteger)index;

@end

@interface ZJJPhotoBrowserViewController : MWPhotoBrowser

@property (nonatomic, assign) id <ZJJDeleteImageDataSourse> dataSourse;

@end
