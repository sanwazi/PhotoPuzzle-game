//
//  TileBoardView.h
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 12/2/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TileBoardView;

@protocol TileBoardViewDelegate <NSObject>

@optional

- (void)tileBoardViewDidFinished:(TileBoardView *)tileBoardView;
- (void)tileBoardView:(TileBoardView *)tileBoardView tileDidMove:(CGPoint)position;

@end

@interface TileBoardView : UIView

@property (assign, nonatomic) IBOutlet id<TileBoardViewDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image size:(NSInteger)size frame:(CGRect)frame;
- (void)playWithImage:(UIImage *)image size:(NSInteger)size;
- (void)shuffleTimes:(NSInteger)times;

@end
