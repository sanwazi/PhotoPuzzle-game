//
//  TileBoardView.m
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 12/2/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import "TileBoardView.h"
#import "TileBoard.h"
#import "UIImage+Resize.h"

typedef enum {
    DirectionUp = 1,
    DirectionRight,
    DirectionDown,
    DirectionLeft
} Direction;

@interface TileBoardView()

@property (nonatomic) CGFloat tileWidth;
@property (nonatomic) CGFloat tileHeight;
@property (nonatomic, getter = isGestureRecognized) BOOL gestureRecognized;
@property (strong, nonatomic) TileBoard *board;
@property (strong, nonatomic) NSMutableArray *tiles;

@property (strong, nonatomic) UIImageView *draggedTile;
@property (nonatomic) NSInteger draggedDirection;

@end

@implementation TileBoardView

#pragma mark - Initialization Methods

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    return self;
}

/**
 *  initialize data and start play.
 *
 *  @param image image selected to play
 *  @param size  size selected 3x3, 4x4 or 5x5
 *  @param frame board frame
 *
 *  @return instance object
 */
- (instancetype)initWithImage:(UIImage *)image size:(NSInteger)size frame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self playWithImage:image size:size];
    
    return self;
}

/**
 *  private method - start playing
 *
 *  @param image image played
 *  @param size  size of image
 */
- (void)playWithImage:(UIImage *)image size:(NSInteger)size
{
    // make the board model
    self.board = [[TileBoard alloc] initWithSize:size];
    
    // slice the images
    UIImage *resizedImage = [image resizedImageWithSize:self.frame.size];
    self.tileWidth = resizedImage.size.width / size;
    self.tileHeight = resizedImage.size.height / size;
    self.tiles = [self sliceImageToAnArray:resizedImage];
    
    // recognize gestures
    if (!self.isGestureRecognized) [self addGestures];
}

/**
 *  slice image with size selected.
 *
 *  @param image target image
 *
 *  @return images
 */
- (NSMutableArray *)sliceImageToAnArray:(UIImage *)image
{
    NSMutableArray *slices = [NSMutableArray array];
    
    for (int i = 0; i < self.board.size; i++)
    {
        for (int j = 0; j < self.board.size; j++)
        {
            if (i == self.board.size && j == self.board.size) continue;
            
            CGRect f = CGRectMake(self.tileWidth * j, self.tileHeight * i, self.tileWidth, self.tileHeight);
            UIImageView *tileImageView = [self tileImageViewWithImage:image frame:f];
            
            [slices addObject:tileImageView];
        }
    }
    
    return slices;
}

/**
 *  create image tile with spical frame.
 *
 *  @param image image piece
 *  @param frame frame image should placed
 *
 *  @return image piece object
 */
- (UIImageView *)tileImageViewWithImage:(UIImage *)image frame:(CGRect)frame
{
    UIImage *tileImage = [image cropImageFromFrame:frame];
    UIImageView *tileImageView = [[UIImageView alloc] initWithImage:tileImage];
    
    /**
     *  set shadow
     */
    [tileImageView.layer setShadowColor:[UIColor blackColor].CGColor];
    [tileImageView.layer setShadowOpacity:1];
    [tileImageView.layer setShadowRadius:10];
    [tileImageView.layer setShadowOffset:CGSizeMake(10, 10)];
    [tileImageView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:tileImageView.layer.bounds] CGPath]];
    
    return tileImageView;
}

/**
 *  add gestures tap and drag.
 */
- (void)addGestures
{
    // add panning recognizer
    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    [dragGesture setMaximumNumberOfTouches:1];
    [dragGesture setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:dragGesture];
    
    // add tapping recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMove:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Public Methods for playing puzzle
/**
 *  reorder tile.
 *
 *  @param times time to reorder
 */
- (void)shuffleTimes:(NSInteger)times
{
    [self.board shuffle:times];
    [self drawTiles];
}

/**
 *  refresh the board.
 */
- (void)drawTiles
{
    for (UIView *view in self.subviews)
        [view removeFromSuperview];
    
    [self traverseTilesWithBlock:^(UIImageView *tileImageView, int i, int j) {
        CGRect frame = CGRectMake(self.tileWidth*(i-1), self.tileHeight*(j-1), self.tileWidth, self.tileHeight);
        tileImageView.frame = frame;
        [self addSubview:tileImageView];
    }];
}

/**
 *  order tiles
 */
- (void)orderingTiles
{
    [self traverseTilesWithBlock:^(UIImageView *tileImageView, int i, int j) {
        [self bringSubviewToFront:tileImageView];
    }];
}

/**
 *  travel tiles and add number into tile layer.
 *
 *  @param block go through all tiles
 */
- (void)traverseTilesWithBlock:(void (^)(UIImageView *tileImageView, int i, int j))block
{
    
    CATextLayer * textLayer;
    for (int j = 1; j <= self.board.size; j++) {
        for (int i = 1; i <= self.board.size; i++) {
            NSNumber *value = [self.board tileAtCoordinate:CGPointMake(i, j)];
            
            if ([value intValue] == 0) continue;
            
            textLayer = [[CATextLayer alloc] init];
            textLayer.string = [NSString stringWithFormat:@"%i", [value intValue]];
            [textLayer setFontSize:22];
            
            textLayer.frame = CGRectMake(2, 2, 30, 30);
            
            
            UIImageView *tileImageView = [self.tiles objectAtIndex:[value intValue]-1];
            NSArray * sublayers = [tileImageView.layer sublayers];
            for(CALayer * cy in sublayers)
                [cy removeFromSuperlayer];
            [tileImageView.layer addSublayer:textLayer];
            
            
            UISwitch * shouldShow = [[self.superview subviews] objectAtIndex:4];
            if( !shouldShow.on )
                textLayer.hidden = YES;
            else
                textLayer.hidden = NO;
            block(tileImageView, i, j);
        }
    }
}

#pragma mark - Movers Methods
/**
 *  move a tile to new frame.
 *
 *  @param position position of which tile need to be moved
 */
- (void)moveTileAtPosition:(CGPoint)position
{
    __block UIImageView *tileView = [self tileViewAtPosition:position];
    if (![self.board canMoveTile:position] || !tileView) return;
    
    CGPoint p = [self.board shouldMove:YES tileAtCoordinate:position];
    CGRect newFrame = CGRectMake(self.tileWidth * (p.x - 1), self.tileHeight * (p.y - 1), self.tileWidth, self.tileHeight);
    [UIView animateWithDuration:0.49 delay:0.0 usingSpringWithDamping:0.49 initialSpringVelocity:.98 options:UIViewAnimationOptionOverrideInheritedCurve
                     animations:^{
                         tileView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         if (self.delegate) [self.delegate tileBoardView:self tileDidMove:position];
                         [self tileWasMoved];
                     }];
    
}

/**
 *  find the which tile in board.
 *
 *  @param position the position in board
 *
 *  @return tile object
 */
- (UIImageView *)tileViewAtPosition:(CGPoint)position
{
    UIImageView *tileView;
    CGRect checkRect = CGRectMake((position.x - 1) * self.tileWidth + 1, (position.y - 1) * self.tileHeight + 1, 1.0, 1.0);
    for (UIImageView *enumTile in self.tiles)
    {
        if  (CGRectIntersectsRect(enumTile.frame, checkRect))
        {
            tileView = enumTile;
            break;
        }
    }
    
    return tileView;
}

/**
 *  private method executed after a tile was moved.
 */
- (void)tileWasMoved
{
    [self orderingTiles];
    
    if ([self.board isAllTilesCorrect])
        if (self.delegate) [self.delegate tileBoardViewDidFinished:self];
}

/**
 *  index a tile in board.
 *
 *  @param point point triggered by player
 *
 *  @return index of tile
 */
- (CGPoint)coordinateFromPoint:(CGPoint)point
{
    return CGPointMake((int)(point.x / self.tileWidth) + 1, (int)(point.y / self.tileHeight) + 1);
}

#pragma mark - Gesture Methods
/**
 *  drag gesture method
 *
 *  @param gestureRecognizer gesture reconizer
 */
- (void)dragging:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan: {
            CGPoint p = [gestureRecognizer locationInView:self];
            [self assignDraggedTileAtPoint:p];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.draggedTile) break;
            
            CGPoint translation = [gestureRecognizer translationInView:self];
            [self movingDraggedTile:translation];
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (!self.draggedTile) break;
            
            [self snapDraggedTile];
            
            break;
        }
        default:
            break;
    }
}

/**
 *  find which tile dragged
 *
 *  @param position position of tile dragged in board
 */
- (void)assignDraggedTileAtPoint:(CGPoint)position
{
    CGPoint coor = [self coordinateFromPoint:position];
    
    if (![self.board canMoveTile:coor]) {
        self.draggedDirection = 0;
        self.draggedTile = nil;
        return;
    }
    
    if ([[self.board tileAtCoordinate:CGPointMake(coor.x, coor.y-1)] isEqualToNumber:@0]) {
        self.draggedDirection = DirectionUp;
    } else if ([[self.board tileAtCoordinate:CGPointMake(coor.x+1, coor.y)] isEqualToNumber:@0]) {
        self.draggedDirection = DirectionRight;
    } else if ([[self.board tileAtCoordinate:CGPointMake(coor.x, coor.y+1)] isEqualToNumber:@0]) {
        self.draggedDirection = DirectionDown;
    } else if ([[self.board tileAtCoordinate:CGPointMake(coor.x-1, coor.y)] isEqualToNumber:@0]) {
        self.draggedDirection = DirectionLeft;
    }
    
    for (UIImageView *tile in self.tiles)
    {
        if (CGRectContainsPoint(tile.frame, position))
        {
            self.draggedTile = tile;
            break;
        }
    }
}

/**
 *  get new place of tile dragged.
 *
 *  @param translationPoint new point of tile dragged
 */

- (void)movingDraggedTile:(CGPoint)translationPoint
{
    CGFloat x = 0.0, y = 0.0;
    CGPoint translation = translationPoint;
    
    switch (self.draggedDirection) {
        case DirectionUp :
            if (translation.y > 0) y = 0.0;
            else if (translation.y < - self.tileHeight) y = -self.tileHeight;
            else y = translation.y;
            break;
        case DirectionRight:
            if (translation.x < 0) x = 0.0;
            else if (translation.x > self.tileWidth) x = self.tileWidth;
            else x = translation.x;
            break;
        case DirectionDown :
            if (translation.y < 0) y = 0.0;
            else if (translation.y > self.tileHeight) y = self.tileHeight;
            else y = translation.y;
            break;
        case DirectionLeft:
            if (translation.x > 0) x = 0.0;
            else if (translation.x < -self.tileWidth) x = -self.tileWidth;
            else x = translation.x;
            break;
        default:
            return;
    }
    [self.draggedTile setTransform:CGAffineTransformMakeTranslation(x, y)];
}

/**
 *  movement of the tile.
 *
 *  @param tile      which tile will move
 *  @param direction the direction of movement
 *  @param tilePoint the original place of tile
 */
- (void)moveTile:(UIImageView *)tile withDirection:(int)direction fromTilePoint:(CGPoint)tilePoint {
    int deltaX = 0;
    int deltaY = 0;
    
    switch (direction) {
        case DirectionUp :
            deltaY = -1; break;
        case DirectionRight :
            deltaX = 1; break;
        case DirectionDown :
            deltaY = 1; break;
        case DirectionLeft :
            deltaX = -1; break;
        default: break;
    }
    CGRect newFrame = CGRectMake((tilePoint.x + deltaX - 1) * self.tileWidth, (tilePoint.y + deltaY - 1) * self.tileHeight, tile.frame.size.width, tile.frame.size.height);
    
    /**
     *  animation of movement.
     */
    [UIView animateWithDuration:.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         tile.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         [tile setTransform:CGAffineTransformIdentity];
                         tile.frame = newFrame;
                         
                         if (direction != 0) {
                             [self.board shouldMove:YES tileAtCoordinate:tilePoint];
                             if (self.delegate) [self.delegate tileBoardView:self tileDidMove:tilePoint];
                             [self tileWasMoved];
                         }
                     }];
}

/**
 *  private method executed after dragging tile
 */
- (void)snapDraggedTile
{
    
    CGPoint movingTilePoint = CGPointMake(floorf(self.draggedTile.center.x / self.tileWidth) + 1, floorf(self.draggedTile.center.y / self.tileHeight) + 1);
    
    if (self.draggedTile.transform.ty < 0) {
        if (self.draggedTile.transform.ty < - (self.tileHeight/2)) {
            [self moveTile:self.draggedTile withDirection:DirectionUp fromTilePoint:movingTilePoint];
        } else {
            [self moveTile:self.draggedTile withDirection:0 fromTilePoint:movingTilePoint];
        }
    } else if (self.draggedTile.transform.tx > 0) {
        if (self.draggedTile.transform.tx > (self.tileWidth/2)) {
            [self moveTile:self.draggedTile withDirection:DirectionRight fromTilePoint:movingTilePoint];
        } else {
            [self moveTile:self.draggedTile withDirection:0 fromTilePoint:movingTilePoint];
        }
    } else if (self.draggedTile.transform.ty > 0) {
        if (self.draggedTile.transform.ty > (self.tileHeight/2)) {
            [self moveTile:self.draggedTile withDirection:DirectionDown fromTilePoint:movingTilePoint];
        } else {
            [self moveTile:self.draggedTile withDirection:0 fromTilePoint:movingTilePoint];
        }
    } else if (self.draggedTile.transform.tx < 0) {
        if (self.draggedTile.transform.tx < - (self.tileWidth/2)) {
            [self moveTile:self.draggedTile withDirection:DirectionLeft fromTilePoint:movingTilePoint];
        } else {
            [self moveTile:self.draggedTile withDirection:0 fromTilePoint:movingTilePoint];
        }
    }
}

/**
 *  private method executed after selecting a tile which will move.
 *
 *  @param tapRecognizer tap gesture recognizer
 */
- (void)tapMove:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapPoint = [tapRecognizer locationInView:self];
    [self moveTileAtPosition:[self coordinateFromPoint:tapPoint]];
}


@end
