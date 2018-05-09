//
//  ZJJPhotoBrowserViewController.m
//  ZJJChosePhonePhotosBrowse
//
//  Created by 张锦江 on 2018/5/9.
//  Copyright © 2018年 xtayqria. All rights reserved.
//

#import "ZJJPhotoBrowserViewController.h"

@interface ZJJPhotoBrowserViewController () {
    NSInteger _zeroTimeInt;  // 第二次为零就是应该返回的时候了
}

@end

@implementation ZJJPhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _zeroTimeInt = 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemTrash) target:self action:@selector(deleteClick)];
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
                if (_zeroTimeInt == 2) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
