//
//  SecondViewController.h
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 11/20/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TileBoardView;
@class SecondViewController;

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet TileBoardView *board;
@property (strong, nonatomic) UIImage * targetImage;


@end

