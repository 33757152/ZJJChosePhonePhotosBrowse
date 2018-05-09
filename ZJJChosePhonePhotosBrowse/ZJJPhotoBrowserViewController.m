//
//  ZJJPhotoBrowserViewController.m
//  ZJJChosePhonePhotosBrowse
//
//  Created by 张锦江 on 2018/5/9.
//  Copyright © 2018年 xtayqria. All rights reserved.
//

#import "ZJJPhotoBrowserViewController.h"

/**
 首次进来如果 _firstTitleNull 为 YES , 则表示只有一张照片，_zeroTimeInt 为 一 的时候应该返回；
 首次进来如果 _firstTitleNull 为 NO , 则表示有多张照片，   _zeroTimeInt    为 二 的时候应该返回
 */

@interface ZJJPhotoBrowserViewController () {
    NSInteger _zeroTimeInt;
    BOOL _firstTitleNull;
}

@end

@implementation ZJJPhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _zeroTimeInt = 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemTrash) target:self action:@selector(deleteClick)];
    if ([self titleIsNull]) {
        _firstTitleNull = YES;
    } else {
        _firstTitleNull = NO;
    }
}

- (void)deleteClick {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"已确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.dataSourse respondsToSelector:@selector(beginToDeleteAtIndex:)]) {
            [self.dataSourse beginToDeleteAtIndex:self.currentIndex];
            [self reloadData];
            if ([self.navigationItem.title isEqualToString:@"(null)"] || !self.navigationItem.title) {
                _zeroTimeInt ++;
                if (_zeroTimeInt == 2 && !_firstTitleNull) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                if (_zeroTimeInt == 1 && _firstTitleNull) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)titleIsNull {
    if ([self.navigationItem.title isEqualToString:@"(null)"] || !self.navigationItem.title) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
