//
//  ViewController.m
//  LGNetworking
//
//  Created by 李堪阶 on 16/7/29.
//  Copyright © 2016年 DM. All rights reserved.
//

#import "ViewController.h"
#import "LGNetworking.h"
@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}
/**
 *  POST请求
 */
- (IBAction)clickPOSTRequestBtn {
    
    NSDictionary *dict = @{@"name": @"zhangsan", @"age": @18};
    
    [[LGNetworking sharedTools]request:POST urlString:@"http://httpbin.org/post" parameters:dict progress:^(NSProgress *progress) {
       
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            self.progressView.progress = progress.fractionCompleted;
        });
        
    } finished:^(id responseObject, NSError *error) {
        
        if (error) {
            
            NSLog(@"请求失败%@",error);
        }else{
            NSLog(@"请求成功%@",responseObject);
        }
        
    }];
    
}

/**
 *  GET请求
 */
- (IBAction)clickGETRequestBtn {
    
    [[LGNetworking sharedTools]request:GET urlString:@"http://www.weather.com.cn/data/sk/101010100.html" parameters:nil progress:^(NSProgress *progress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.progressView.progress = progress.fractionCompleted;
        });
        
    } finished:^(id responseObject, NSError *error) {
        
        if (error) {
            
            NSLog(@"请求失败%@",error);
        }else{
            NSLog(@"请求成功%@",responseObject);
        }
        
    }];
}

/**
 *  下载图片
 */
- (IBAction)clickDownloadBtn {
    
    [[LGNetworking sharedTools]downloadTaskURLString:@"http://192.168.1.111/upload/abc/pi.jpg" progress:^(NSProgress *progress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.progressView.progress = progress.fractionCompleted;
        });
    } finished:^(id responseObject, NSError *error) {
        
        if (error) {
            
            NSLog(@"下载失败%@",error);
        }else{
            NSLog(@"下载成功%@",responseObject);
            
            //从路径拿到图片
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:responseObject]];
    
            //保存到系统相册
            UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }];
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(!error){
        NSLog(@"save success");
    }else{
        NSLog(@"save failed");
    }
}

/**
 *  上传图片
 */
- (IBAction)clickUploadImageBtn {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.allowsEditing = YES;
    
    picker.delegate = self;
    
    //对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"相册");
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"相机");
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [[LGNetworking sharedTools]uploadTaskURLString:@"http://192.168.1.111/upload/upload.php" withImage:image withImageName:@"pi" withParameters:nil progress:^(NSProgress *progress) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                self.progressView.progress = progress.fractionCompleted;
            });
            
        } finished:^(id responseObject, NSError *error) {
            if (error) {
                
                NSLog(@"上传失败%@",error);
            }else{
                NSLog(@"上传成功%@",responseObject);
            }
        }];
    }
    
}


/**
 *  上传文件
 */
- (IBAction)clickUploadFileBtn {
    
    [[LGNetworking sharedTools]uploadTaskURLString:@"http://192.168.1.111/upload/upload.php" withFilePath:@"/Users/likanjie/Desktop/1.txt" withFileName:@"5.txt" withParameters:nil progress:^(NSProgress *progress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.progressView.progress = progress.fractionCompleted;
        });
        
    } finished:^(id responseObject, NSError *error) {
        
        if (error) {
            
            NSLog(@"上传失败%@",error);
        }else{
            NSLog(@"上传成功%@",responseObject);
        }
    }];
}


@end
