//
//  UserInfoViewController.m
//  KavaAssignmentApp
//
//  Created by kadaj on 3/30/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

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

@property FBUserSettingsViewController *settings;
@property UserInfo *info;
@property NSDate *editedBirthday;

@property NSManagedObjectContext *managedObjectContext;

@property AppDelegate *appDelegate;

@property BOOL editMode;
@property BOOL facebookDataFetched;

@property (readonly) NSArray *permissions;

@end


@implementation UserInfoViewController


- (IBAction)editClick:(id)sender
{
    if (self.editMode) {
        NSError *inputError;
        if ([self inputInfo:&inputError]) {
            [self saveData];
            [self leaveEditMode];
            [self fillInfo];
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) facebookDataFetched {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"facebookDataFetched"];
}

- (void) setFacebookDataFetched:(BOOL)facebookDataFetched {
    [[NSUserDefaults standardUserDefaults] setBool:facebookDataFetched forKey:@"facebookDataFetched"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    if (!_permissions) _permissions = @[@"basic_info", @"email",@"user_about_me",@"user_birthday"];
    self.appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    
    [self fetchData];
    


}

- (void) saveData
{
    NSError *saveError;
    if(![self.managedObjectContext save:&saveError])
    {
        NSLog(@"Couldn't save data: %@", [saveError localizedDescription]);
    }
    
}

- (void) prepareInternetConnectionForIP:(NSString *) ip withHandler:(void (^)(BOOL)) handler {



    
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) facebookFetch: (void (^) (void)) successHandler onError: (void (^) (NSError *)) errorHandler
{


}

- (void) loginViewController:(id)sender receivedError:(NSError *)error
{

    
}

- (void) loginViewControllerWillLogUserOut:(id)sender
{
    
}

- (void) loginViewControllerDidLogUserOut:(id)sender
{

}

- (void) loginViewControllerDidLogUserIn:(id)sender
{

}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"fbSettings"]) {
        FBUserSettingsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.readPermissions = self.permissions;
        
    }
    
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

- (void) fetchData
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count>1) @throw [NSException exceptionWithName:@"InvalidStorageException" reason:@"Storage is corrupted" userInfo:nil];
    if(fetchedObjects.count>0) {
        self.info = [fetchedObjects objectAtIndex:0];
        [self fillInfo];
        [self leaveEditMode];
    } else {
        self.info = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext];
        [self enterEditMode];
    }
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
