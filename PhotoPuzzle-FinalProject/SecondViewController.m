//
//  SecondViewController.m
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 11/20/14.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import "SecondViewController.h"
#import "TileBoard.h"
#import "TileBoardView.h"
#import "ViewController.h"

@interface SecondViewController ()<TileBoardViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeSegmentedControl;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIView *shouldShowNumber;

@property (weak, nonatomic) UIImageView *imageView;
@property (nonatomic, assign, readonly) UIImage *boardImage;
@property (nonatomic, readonly) NSInteger boardSize;
@property (nonatomic) NSInteger steps;

@property (assign) BOOL shouldShowImage;
@property (nonatomic,assign) CGFloat rotation;

@end

@implementation SecondViewController

@synthesize targetImage;
@synthesize rotation;

/**
 *  data initialize when view is load.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imageButton setBackgroundImage:self.targetImage forState:UIControlStateNormal];
    [self restart:nil];
    
    /**
     back button - to return.
     
     :param: backAction - back to previou view.
     */
    UIBarButtonItem * backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self.navigationController.viewControllers[0] action:@selector(backAction:)];
    backButton.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem=backButton;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"head"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.layer.masksToBounds = NO;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 6);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationController.navigationBar.bounds].CGPath;
    self.navigationController.title=@"PlayBoard";
    
}

/**
 *  selector method - back to previou view.
 *
 *  @param sender sender from UIButton
 */
-(void)backAction:(id)sender{
    
    UIStoryboard *str = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *first = [str instantiateViewControllerWithIdentifier:@"first"];
    first.img = [[UIImageView alloc] initWithImage:self.targetImage];
    NSMutableArray* navArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    
    [navArray replaceObjectAtIndex:[navArray count]-1 withObject:first];
    [self.navigationController setViewControllers:navArray animated:YES ];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  private method executed when back action is triggered.
 *
 *  @return image played
 */
- (UIImage *)boardImage
{
    return self.targetImage;
}

/**
 *  private mehod
 *
 *  @return size of board- 3x3, 4x4 or 5x5
 */
- (NSInteger)boardSize
{
    return self.sizeSegmentedControl.selectedSegmentIndex + 3;
}

/**
 *  selector method to set steps.
 *
 *  @param steps number of movement
 */
- (void)setSteps:(NSInteger)steps
{
    _steps = steps;
    
    self.stepsLabel.text = [NSString stringWithFormat:@"Steps: %ld", (long)self.steps];
    [self.stepsLabel setShadowColor:[UIColor lightGrayColor]];
    [self.stepsLabel setShadowOffset:CGSizeMake(1.0,1.0)];
    self.stepsLabel.font = [UIFont fontWithName:@"Menlo" size:21.0];
}

#pragma mark - Actions
/**
 *  retart action to prepare play again.
 *
 *  @param sender sender from UIButton
 */
- (IBAction)restart:(UIButton *)sender
{
    [self.board playWithImage:self.boardImage size:self.boardSize];
    [self.board shuffleTimes:100];
    self.steps = 0;
    self.shouldShowImage = NO;
    
    /**
     *  animation of restart button.
     */
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        sender.imageView.transform = CGAffineTransformMakeRotation(rotation);
        
    }completion:nil];
    
    if(rotation < 26 )
        rotation +=  M_PI;
    else
        rotation =  M_PI;
    
    UIImageView *originalImage = [[UIImageView alloc] initWithImage:self.boardImage];
    originalImage.frame = self.board.frame;
    originalImage.alpha = 0.0;
    
    [originalImage.layer setShadowColor:[UIColor blackColor].CGColor];
    [originalImage.layer setShadowOpacity:1];
    [originalImage.layer setShadowRadius:10];
    [originalImage.layer setShadowOffset:CGSizeMake(10, 10)];
    [originalImage.layer setShadowPath:[[UIBezierPath bezierPathWithRect:originalImage.layer.bounds] CGPath]];
    self.imageView = originalImage;
    [self.view addSubview:originalImage];
    
    //[self hideImage];
}

/**
 *  private method - give player hint with original image.
 */
- (void)showImage
{

    if (!self.imageView) return;

    /**
     *  animation of show image action.
     */
    [UIView animateWithDuration:1.7 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.board.alpha = 0.0;
                         self.imageView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         ;
                     }];
}

- (void)hideImage
{
    if (!self.imageView) return;
    
    [UIView animateWithDuration:1.7 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.imageView.alpha = 0.0;
        self.board.alpha = 1.0;
    } completion:^(BOOL finished) {
        ;
    }];
}

/**
 *  image button action - show or hide image
 *
 *  @param sender sender from
 */
- (IBAction)buttonTouchDown:(id)sender
{
    if(!self.shouldShowImage)
        [self showImage];
    else
        [self hideImage];
    self.shouldShowImage = !self.shouldShowImage;
}

/**
 *  segment action to set size of board.
 *
 *  @param sender sender from UISegmentController
 */
- (IBAction)sizeChanged:(UISegmentedControl *)sender
{
    [self restart:nil];
    self.rotation += M_PI;
}

/**
 *  switch action whether the number of tile should be showed or not.
 *
 *  @param sender sender from UISwitch
 */
- (IBAction)shouldShowNumber:(UISwitch *)sender {
    
    if(!sender.on)
        for (UIView *view in [self.board subviews]){
            CALayer* textLayer = [[view.layer sublayers] lastObject];
            textLayer.hidden = YES;
        }
    else
        for (UIView *view in [self.board subviews]){
            CALayer* textLayer = [[view.layer sublayers] lastObject];
            textLayer.hidden = NO;
        }
    
}

#pragma mark - Tile Board Delegate Method
/**
 *  movement information from player and increase steps.
 *
 *  @param tileBoardView board view
 *  @param position      the index of tile moved by player
 */
- (void)tileBoardView:(TileBoardView *)tileBoardView tileDidMove:(CGPoint)position
{
    NSLog(@"tile move : %@", [NSValue valueWithCGPoint:position]);
    self.steps++;
}

/**
 *  alert dialog when player win.
 *
 *  @param tileBoardView board view
 */
- (void)tileBoardViewDidFinished:(TileBoardView *)tileBoardView
{
    NSLog(@"tile is completed");
    [self showImage];
    
    NSString *message = [NSString stringWithFormat:@"You've completed a %ld x %ld puzzle with %ld steps. Press restart button to play again.", self.boardSize, self.boardSize, self.steps];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats!" message:message delegate:nil cancelButtonTitle:@"Got it" otherButtonTitles:nil];
    [alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
@end
