//
//  ViewController.h
//  GPUImage_demo
//
//  Created by tataball on 2019/3/16.
//  Copyright © 2019 copyCat_yy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface ViewController : UIViewController
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}

@end

