//
//  ViewController.m
//  sdWebimage_demo
//
//  Created by Ye Ye on 2019/3/10.
//  Copyright © 2019 copyCat_yy. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor yellowColor];
    imageView.frame = CGRectMake(20, 50, 200, 160);
    [self.view addSubview:imageView];
    
    NSURL *url = [NSURL URLWithString:@"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png"];
    [imageView sd_setImageWithURL:url];
    
//    [imageView sd_setImageWithURL:<#(nullable NSURL *)#> placeholderImage:<#(nullable UIImage *)#> options:<#(SDWebImageOptions)#> completed:<#^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL)completedBlock#>]
    
}

- (void)xxx {
    // HTTP NTLM auth example
    // Add your NTLM image url to the array below and replace the credentials
    [SDWebImageManager sharedManager].imageDownloader.username = @"httpwatch";
    [SDWebImageManager sharedManager].imageDownloader.password = @"httpwatch01";
    
//    self.objects = [NSMutableArray arrayWithObjects:
//                    @"http://www.httpwatch.com/httpgallery/authentication/authenticatedimage/default.aspx?0.35786508303135633",     // requires HTTP auth, used to demo the NTLM auth
//                    @"http://assets.sbnation.com/assets/2512203/dogflops.gif",
//                    @"https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif",
//                    @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
//                    @"http://www.ioncannon.net/wp-content/uploads/2011/06/test9.webp",
//                    @"http://littlesvr.ca/apng/images/SteamEngine.webp",
//                    @"http://littlesvr.ca/apng/images/world-cup-2014-42.webp",
//                    @"https://isparta.github.io/compare-webp/image/gif_webp/webp/2.webp",
//                    @"https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
//                    @"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
//                    @"http://via.placeholder.com/200x200.jpg",
//                    nil];
//
//    for (int i=0; i<100; i++) {
//        [self.objects addObject:[NSString stringWithFormat:@"https://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage%03d.jpg", i]];
//    }
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
}


- (void)flushCache
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDiskOnCompletion:nil];
}


@end
