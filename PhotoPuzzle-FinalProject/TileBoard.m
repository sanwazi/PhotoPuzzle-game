//
//  TileBoard.m
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 12/2/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import "TileBoard.h"

static const NSInteger TileMinSize = 3;
static const NSInteger TileMaxSize = 5;

@interface TileBoard ()

@property (strong, nonatomic) NSMutableArray *tiles;

@end

@implementation TileBoard

- (instancetype)init
{
    return nil;
}

/**
 *  initialize size
 *
 *  @param size size of board
 *
 *  @return instance
 */
- (instancetype)initWithSize:(NSInteger)size
{
    if (!(self = [super init]) || ![self isSizeValid:size]) return nil;
    
    self.size = size;
    
    return self;
}

/**
 *  validate size
 *
 *  @param size input size
 *
 *  @return whether size is validated or not
 */
- (BOOL)isSizeValid:(NSInteger)size
{
    return (size >= TileMinSize && size <= TileMaxSize);
}

/**
 *  validate index of tile
 *
 *  @param coor index in coordinate
 *
 *  @return whether index is validated or not
 */
- (BOOL)isCoordinateInBound:(CGPoint)coor
{
    return (coor.x > 0 && coor.x <= self.size && coor.y > 0 && coor.y <= self.size);
}

/**
 *  initialize the index number of tile
 *
 *  @param size size of board
 *
 *  @return number array of tiles
 */
- (NSMutableArray *)tileValuesForSize:(NSInteger)size
{
    int value = 1;
    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:size];
    for (int i = 0; i < size; i++)
    {
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:size];
        for (int j = 0; j < size; j++)
            values[j] = (value != pow(size, 2))? @(value++) : @0;
        tiles[i] = values;
    }
    
    return tiles;
}

/**
 *  set size of board
 *
 *  @param size new size
 */

- (void)setSize:(NSInteger)size
{
    if ([self isSizeValid:size]) _tiles = [self tileValuesForSize:size];
}

/**
 *  size getter method
 *
 *  @return size
 */
- (NSInteger)size
{
    return [_tiles count];
}

/**
 *  connect the number of tile to tile
 *
 *  @param coor   index cooridnate
 *  @param number index number of tile
 */
- (void)setTileAtCoordinate:(CGPoint)coor with:(NSNumber *)number
{
    if ([self isCoordinateInBound:coor])
        self.tiles[(int)coor.y-1][(int)coor.x-1] = number;
}

- (NSNumber *)tileAtCoordinate:(CGPoint)coor
{
    if ([self isCoordinateInBound:coor])
        return self.tiles[(int)coor.y-1][(int)coor.x-1];
    
    return nil;
}

/**
 *  validate movement
 *
 *  @param coor index cooridnate in board
 *
 *  @return whether this movemnet is validated or not
 */
- (BOOL)canMoveTile:(CGPoint)coor
{
    return ( [[self tileAtCoordinate:CGPointMake(coor.x, coor.y-1)] isEqualToNumber:@0] || // upper neighbor
            [[self tileAtCoordinate:CGPointMake(coor.x+1, coor.y)] isEqualToNumber:@0] || // right neighbor
            [[self tileAtCoordinate:CGPointMake(coor.x, coor.y+1)] isEqualToNumber:@0] || // lower neighbor
            [[self tileAtCoordinate:CGPointMake(coor.x-1, coor.y)] isEqualToNumber:@0] ); // left neighbor
}

/**
 *  movement method
 *
 *  @param move whether movement should be executed or not
 *  @param coor index coordinate
 *
 *  @return the the place where tile can move to
 */
- (CGPoint)shouldMove:(BOOL)move tileAtCoordinate:(CGPoint)coor
{
    if (![self canMoveTile:coor]) return CGPointZero;
    
    CGPoint lowerNeighbor = CGPointMake(coor.x, coor.y+1);
    CGPoint rightNeighbor = CGPointMake(coor.x+1, coor.y);
    CGPoint upperNeighbor = CGPointMake(coor.x, coor.y-1);
    CGPoint leftNeighbor  = CGPointMake(coor.x-1, coor.y);
    
    CGPoint neighbor;
    if ([[self tileAtCoordinate:lowerNeighbor] isEqualToNumber:@0])
        neighbor = lowerNeighbor;
    else if ([[self tileAtCoordinate:rightNeighbor] isEqualToNumber:@0])
        neighbor = rightNeighbor;
    else if ([[self tileAtCoordinate:upperNeighbor] isEqualToNumber:@0])
        neighbor = upperNeighbor;
    else if ([[self tileAtCoordinate:leftNeighbor] isEqualToNumber:@0])
        neighbor = leftNeighbor;
    
    if (move)
    {
        NSNumber *number = [self tileAtCoordinate:coor];
        [self setTileAtCoordinate:coor with:[self tileAtCoordinate:neighbor]];
        [self setTileAtCoordinate:neighbor with:number];
    }
    
    return neighbor;
}

/**
 *  reoreder tiles
 *
 *  @param times time of reordering tile
 */
- (void)shuffle:(NSInteger)times
{
    for (int t = 0; t < times; t++) {
        NSMutableArray *validMoves = [NSMutableArray array];
        
        for (int j = 1; j <= self.size; j++)
        {
            for (int i = 1; i <= self.size; i++)
            {
                CGPoint p = CGPointMake(i, j);
                if ([self canMoveTile:p])
                    [validMoves addObject:[NSValue valueWithCGPoint:p]];
            }
        }
        
        NSValue *v = validMoves[arc4random_uniform([validMoves count])];
        CGPoint p = [v CGPointValue];
        [self shouldMove:YES tileAtCoordinate:p];
    }
}

/**
 *  validate place of all tiles
 *
 *  @return whether new layour of tiles is validated or not
 */
- (BOOL)isAllTilesCorrect
{
    int i = 1;
    BOOL correct = YES;
    
    for (NSArray *values in self.tiles)
    {
        for (NSNumber *value in values)
        {
            if ([value integerValue] != i)
            {
                correct = NO;
                break;
            }
            else
            {
                i = (i < pow(self.size, 2) - 1)? i+1 : 0;
            }
            
        }
    }
    
    return correct;
}


@end
