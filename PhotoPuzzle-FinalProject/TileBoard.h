//
//  TileBoard.h
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 12/2/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TileBoard : NSObject

@property (nonatomic) NSInteger size;

- (instancetype)initWithSize:(NSInteger)size;
- (void)setTileAtCoordinate:(CGPoint)coor with:(NSNumber *)number;
- (NSNumber *)tileAtCoordinate:(CGPoint)coor;

- (BOOL)canMoveTile:(CGPoint)coor;
- (CGPoint)shouldMove:(BOOL)move tileAtCoordinate:(CGPoint)coor;
- (BOOL)isAllTilesCorrect;

- (void)shuffle:(NSInteger)times;

@end
