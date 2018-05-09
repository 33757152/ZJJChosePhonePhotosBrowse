//
//  ViewController.m
//  ZJJChosePhonePhotosBrowse
//
//  Created by 张锦江 on 2018/5/8.
//  Copyright © 2018年 xtayqria. All rights reserved.
//

/**
 一次获取系统多张图片，并且可删除，可浏览
 */

#define MAX_IMG_COUNT 9

#import "ViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "ZJJPhotoBrowserViewController.h"

@interface ViewController () <CTAssetsPickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate,ZJJDeleteImageDataSourse> {
    NSCondition *_condition;     // 确保 block 块执行完毕再刷表
}

@property (nonatomic, strong) UICollectionView *collect;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collect reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"选择图片";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(uploadImageClick)];
    _condition = [[NSCondition alloc] init];
    [self.view addSubview:self.collect];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView *)collect {
    if (!_collect) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collect = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAV_STATUS_BAR_HEIGHT) collectionViewLayout:layout];
        _collect.delegate = self;
        _collect.dataSource = self;
        _collect.backgroundColor = [UIColor whiteColor];
        [_collect registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collect;
}

#pragma mark - UICollectionView 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.dataArray[indexPath.row]];
    cell.backgroundView = imageView;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 50)/4, (SCREEN_WIDTH - 50)/4);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZJJPhotoBrowserViewController *photoBrowser = [[ZJJPhotoBrowserViewController alloc] initWithPhotos:self.dataArray];
    photoBrowser.delegate = self;
    photoBrowser.dataSourse = self;
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

#pragma mark - 按钮点击事件
- (void)uploadImageClick {
    if (self.dataArray.count == MAX_IMG_COUNT) {
        UIAlertController *alert = [self customAlert];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.delegate = self;
                // 显示选择的索引
            picker.showsSelectionIndex = YES;
                // 设置相册的类型：相机胶卷 +自定义相册
            picker.assetCollectionSubtypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                              @(PHAssetCollectionSubtypeAlbumRegular)];
                // 不需要显示空的相册
            picker.showsEmptyAlbums = NO;
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    if (picker.selectedAssets.count >= MAX_IMG_COUNT) {
        UIAlertController *alert = [self customAlert];
        [picker presentViewController:alert animated:YES completion:nil];
        // 这里不能使用self来modal别的控制器，因为此时self.view不在window上
        return NO;
    }
    return YES;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    // 获取成功后要刷表
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    [self reloadTheCollectView];
    // 关闭图片选择界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 遍历选择的所有图片
    for (NSInteger i = 0; i < assets.count; i++) {
        // 基本配置
        CGFloat scale = [UIScreen mainScreen].scale;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode  = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        PHAsset *asset = assets[i];
        CGSize size = CGSizeMake(asset.pixelWidth / scale, asset.pixelHeight / scale);
        // 获取图片
        __block ViewController *weakself = self;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *_Nullable result,NSDictionary *_Nullable info) {
            // 压缩
            NSData *imageData = UIImageJPEGRepresentation(result, 0.3);
            UIImage *image = [UIImage imageWithData:imageData];
            [tempArray addObject:image];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_condition lock];
                if (tempArray.count == assets.count) {
                    if (weakself.dataArray.count + tempArray.count > MAX_IMG_COUNT) {
                        UIAlertController *alert = [weakself customAlert];
                        [weakself presentViewController:alert animated:YES completion:nil];
                        if (weakself.dataArray.count < MAX_IMG_COUNT) {
                            // 8-2
                            NSInteger index = MAX_IMG_COUNT - weakself.dataArray.count;
                            for (NSInteger j = 0; j<index; j++) {
                                [weakself.dataArray addObject:tempArray[j]];
                            }
                        } else {
                            // 9-1
                        }
                    } else {
                        [weakself.dataArray addObjectsFromArray:tempArray];
                    }
                    [_condition signal];
                }
                [_condition unlock];
            });
        }];
    }
}

- (void)reloadTheCollectView {
    __block ViewController *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_condition lock];
        [_condition wait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.collect reloadData];
        });
        [_condition unlock];
    });
}

- (UIAlertController *)customAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%zd张图片", MAX_IMG_COUNT] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

#pragma mark - MWPhotoBrowser 代理方法
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.dataArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [MWPhoto photoWithImage:self.dataArray[index]];
    return photo;
}

- (void)beginToDeleteAtIndex:(NSInteger)index {
    if (self.dataArray.count > 0) {
        [self.dataArray removeObjectAtIndex:index];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
