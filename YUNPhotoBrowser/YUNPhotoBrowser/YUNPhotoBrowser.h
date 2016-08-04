//
//  YUNPhotoBrowser.h
//  YUNPhotoBrowser
//
//  Created by Orange on 8/3/16.
//  Copyright © 2016 colorcun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YUNPhotoBrowserDelegate;

@interface YUNPhotoBrowser : UIView

@property (nonatomic, weak) id<YUNPhotoBrowserDelegate> delegate;

@property (nonatomic, assign) NSInteger currentImageIndex;

@property (nonatomic, weak) UIView *sourceImagesContainerView;

@end

@protocol YUNPhotoBrowserDelegate <NSObject>

@required

- (NSInteger)numberOfItemsInPhotoBrowser:(YUNPhotoBrowser *)browser;

- (UIImage *)photoBrowser:(YUNPhotoBrowser *)browser placeholderImageForItemAtIndex:(NSInteger)index;

@optional
- (NSURL *)photoBrowser:(YUNPhotoBrowser *)browser imageURLForItemAtIndex:(NSInteger)index;

@end