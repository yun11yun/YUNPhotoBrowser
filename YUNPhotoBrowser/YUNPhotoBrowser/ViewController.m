//
//  ViewController.m
//  YUNPhotoBrowser
//
//  Created by Orange on 8/3/16.
//  Copyright © 2016 colorcun. All rights reserved.
//

#import "ViewController.h"

#import "YUNPhotoBrowser.h"

@interface ViewController ()<YUNPhotoBrowserDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) YUNPhotoBrowser *photoBrowser;

@property (nonatomic, strong) NSArray *imageNames;

@property (nonatomic, strong) NSArray *testImages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i < self.testImages.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.testImages[i]]];
        imageView.frame = CGRectMake(i * CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), 300);
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTaped:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.testImages.count, 0);
}

- (void)imageViewTaped:(UITapGestureRecognizer *)recognizer
{
    _photoBrowser = [[YUNPhotoBrowser alloc] init];
    _photoBrowser.frame = self.view.bounds;
    _photoBrowser.center = self.view.center;
    _photoBrowser.sourceImagesContainerView = _scrollView;
    _photoBrowser.currentImageIndex = recognizer.view.tag;
    _photoBrowser.delegate = self;
    [self.view addSubview:_photoBrowser];
}

#pragma mark - YUNPhotoBrowserDelegate

- (NSInteger)numberOfItemsInPhotoBrowser:(YUNPhotoBrowser *)browser {
    return self.testImages.count;
}

- (UIImage *)photoBrowser:(YUNPhotoBrowser *)browser placeholderImageForItemAtIndex:(NSInteger)index {
    return [UIImage imageNamed:self.testImages[index]];
}

- (NSArray *)testImages
{
    if (!_testImages) {
        _testImages = @[@"another1.jpg",@"another2.jpg",@"another3.jpg"];
    }
    return _testImages;
}

@end
