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


@property NSDate *editedBirthday;



@end


@implementation UserInfoViewController


- (IBAction)editClick:(id)sender
{
    [self performEditing];
    
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
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

/*- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.delegate = self;
        // Custom initialization
    }
    return self;
}*/
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.firstName.delegate = self;
    self.lastName.delegate = self;

}





- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void) leaveEditMode
{
    self.editMode = NO;
    self.firstName.enabled = NO;
    self.lastName.enabled = NO;
    self.birthday.enabled = NO;
    self.contacts.editable = NO;
    self.bio.editable = NO;
    self.navigationItem.leftBarButtonItem.title = @"Edit";
    self.changeImageButton.hidden = YES;
    self.setDateButton.hidden = YES;
}

- (void) enterEditMode
{
    self.editMode = YES;
    self.firstName.enabled = YES;
    self.lastName.enabled = YES;
    //self.birthday.enabled = YES;
    //self.birthday.delegate = self;
    self.contacts.editable = YES;
    self.bio.editable = YES;
    self.navigationItem.leftBarButtonItem.title = @"Done";
    self.changeImageButton.hidden = NO;
    self.setDateButton.hidden = NO;
}

- (void)fillInfo
{
    self.firstName.text = self.info.firstName;
    self.lastName.text = self.info.lastName;
    self.birthday.text = [NSDateFormatter localizedStringFromDate:self.info.birthday dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    self.image.image = [UIImage imageWithData:self.info.avatar];
    self.contacts.text = self.info.contacts;
    self.bio.text = self.info.bio;
    
}

- (BOOL)inputInfo: (NSError* __autoreleasing *) error
{
    NSString *header = @"Problem";
    NSString *description = nil;
    int code = 0;
    
    if([self.firstName.text length]==0) {
        description = @"Your name cannot be empty";
        code = 1<<0;
    }
    
    if([self.lastName.text length]==0) {
        description = @"Your last name cannot be empty";
        code = 1<<1;
    }
    
    if([self.birthday.text length]==0 && self.editedBirthday==nil) {
        description = @"Please enter your birthday";
        code = 1<<2;
    }
    
    if([self.contacts.text length]==0) {
        description = @"Please enter some contacts";
        code = 1<<3;
    }
    
    if([self.bio.text length]==0) {
        description = @"Please write something about yourself";
        code = 1<<4;
    }
    
    if (description) {
        [self showMessage:description withTitle:header];
        NSError *returnError = [NSError errorWithDomain:NSInvalidArgumentException code:1 userInfo:@{NSLocalizedDescriptionKey: description}];
        *error = returnError;
        return NO;
    }

    
    self.info.firstName = self.firstName.text;
    self.info.lastName = self.lastName.text;
    if(self.editedBirthday) {
        self.info.birthday = self.editedBirthday;
    }
    self.info.contacts = self.contacts.text;
    self.info.bio = self.bio.text;
    self.info.avatar = UIImagePNGRepresentation(self.image.image);
    return YES;

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
