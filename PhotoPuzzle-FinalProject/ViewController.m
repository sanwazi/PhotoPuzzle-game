//
//  ViewController.m
//  PhotoPuzzle-FinalProject
//
//  Created by Stan on 14-11-11.
//  Copyright (c) 2014 UWL-Jingbo Chu. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (strong, nonatomic) UIPopoverController * popover;

@end

@implementation ViewController

/**
 *  data initialize when this view is loading.
 */
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"head"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.layer.masksToBounds = NO;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 6);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationController.navigationBar.bounds].CGPath;
    
    UIToolbar * toolBar = [self.view.subviews lastObject];
    [toolBar setBackgroundImage:[UIImage imageNamed:@"head"]forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    toolBar.layer.masksToBounds = NO;
    toolBar.layer.shadowOffset = CGSizeMake(0, -6);
    toolBar.layer.shadowOpacity = 0.5;
    toolBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:toolBar.bounds].CGPath;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  method executed when this view appear.
 *
 *  @param animated whether animation should be executed or not
 */
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    // Disable edit button if there is no selected image.
    self.imageView.image = self.img.image;
    [self updatePlayButtonEnabled];
    
}

#pragma mark - Action methods

/**
 *  camera button - select a photo.
 *
 *  @param sender send from UIButton
 */
- (IBAction)cameraButtonAction:(UIBarButtonItem *)sender {
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Photo Album", nil];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [actionSheet addButtonWithTitle:@"Camera"];
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        [actionSheet showFromBarButtonItem:self.cameraButton animated:YES];
    }else
        [actionSheet showFromToolbar:self.navigationController.toolbar];
    
}

#pragma mark - private methods
/**
 *  selector method - open camera.
 */
-(void) showCamera{
    
    UIImagePickerController * controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [self.popover presentPopoverFromBarButtonItem:self.cameraButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

/**
 *  selector method - open photo album.
 */
- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [self.popover presentPopoverFromBarButtonItem:self.cameraButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

/**
 *  update play button whether it is enabled or unenabled
 */
- (void)updatePlayButtonEnabled
{
    self.playButton.enabled = !!self.imageView.image;
}

#pragma mark - UIActionSheet Delegate methods

/**
 *  UIActionSheet Delegate methods to implement action.
 *
 *  @param actionSheet action sheet trggered by carmera button
 *  @param buttonIndex index of button clicked
 */

-(void) actionSheet:(UIActionSheet *) actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Photo Album"]) {
        [self openPhotoAlbum];
    } else if ([buttonTitle isEqualToString:@"Camera"]) {
        [self showCamera];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate methods

/**
 *  Open SecondViewController automattically when image selected.
 *
 *  @param picker whether action is from camera of photo album
 *  @param info   photo from picker
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        [self updatePlayButtonEnabled];
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            ;
        }];
    }
    self.img = [[UIImageView alloc] initWithImage:image];
    
}

/**
 *  play action - go to the next board.
 *
 *  @param sender send from UIButton
 */
- (IBAction)playAction:(id)sender {
    
    UIStoryboard *str = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SecondViewController * page2 =[str instantiateViewControllerWithIdentifier:@"second"];
    self.navigationController.viewControllers=@[page2];
    page2.targetImage = self.imageView.image;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

@end
