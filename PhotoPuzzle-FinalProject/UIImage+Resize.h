//
//  UIImage+Resize.h
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 12/2/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)resizedImageWithSize:(CGSize)size;
- (UIImage *)cropImageFromFrame:(CGRect)frame;

@end
