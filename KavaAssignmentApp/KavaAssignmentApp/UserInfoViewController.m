//
//  UserInfoViewController.m
//  KavaAssignmentApp
//
//  Created by kadaj on 3/30/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoViewController+Testing.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "DatePickerViewController.h"

@interface UserInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *birthday;
@property (weak, nonatomic) IBOutlet UITextView *contacts;
@property (weak, nonatomic) IBOutlet UITextView *bio;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
//@property (nonatomic) UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *setDateButton;
@property UserInfo *info;
@property NSDate *editedBirthday;

@property NSManagedObjectContext *managedObjectContext;

@property AppDelegate *appDelegate;

@property BOOL editMode;

@end


@implementation UserInfoViewController


- (IBAction)editClick:(id)sender
{
    if (self.editMode) {
        NSError *inputError;
        if ([self inputInfo:&inputError]) {
            NSError *saveError;
            if(![self.managedObjectContext save:&saveError])
            {
                NSLog(@"Couldn't save data: %@", [saveError localizedDescription]);
            }
            [self leaveEditMode];
        }
        
    } else {
        [self enterEditMode];
    }
    
}

- (IBAction)changeImageClick:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [self.navigationController presentViewController: picker animated: YES completion: nil];
   
    }
    
}

- (IBAction)unwindFromDate:(UIStoryboardSegue *)segue
{
    DatePickerViewController *controller = [segue sourceViewController];
    self.editedBirthday = controller.date;
    self.birthday.text = [NSDateFormatter localizedStringFromDate:self.editedBirthday dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}





- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    self.image.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    
    [self fetchData];
    
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) leaveEditMode
{

}

- (void) enterEditMode
{
 
}

- (void)fillInfo
{

    
}

- (BOOL)inputInfo: (NSError* __autoreleasing *) error
{
 
    return YES;

}

- (void) fetchData
{

}
/*#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
