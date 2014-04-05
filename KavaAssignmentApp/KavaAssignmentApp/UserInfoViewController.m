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
    
    if (!self.facebookDataFetched) {
        self.settings = [[FBUserSettingsViewController alloc] init];
        self.settings.delegate = self;
        self.settings.readPermissions = self.permissions;
        self.settings.doneButton = nil;
        self.settings.cancelButton = nil;
        [self presentViewController:self.settings animated:NO completion:nil];
    }
    
    [self prepareInternetConnectionForIP:@"8.8.8.8" withHandler:^(BOOL result){
        if (!result) {
            [self showMessage:@"The application require an active internet connection" withTitle:@"Problem"];
        }
    }];

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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        BOOL returnValue = NO;
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
        inet_pton(AF_INET,[ip cStringUsingEncoding:NSUTF8StringEncoding], &address.sin_addr);
        //address.sin_port = htons(80);

        //SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "facebook.com");
        SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*) &address);

        if (reachabilityRef != NULL) {
            SCNetworkReachabilityFlags flags = 0;
            if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags)){
                NSLog(@"connection flags: %d", flags);
                BOOL isReachable = (flags & kSCNetworkFlagsReachable);
                BOOL connectionRequired = (flags & kSCNetworkFlagsConnectionRequired);
                returnValue = isReachable && !connectionRequired;
                if(!returnValue) {
                    NSLog(@"bad connection");
                } else {
                    NSLog(@"good connection");
                }
                
                dispatch_async(main, ^{
                    if (handler) {
                        handler(returnValue);
                    }
                });
            }
            CFRelease(reachabilityRef);
        }
    });


    
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) facebookFetch: (void (^) (void)) successHandler onError: (void (^) (NSError *)) errorHandler
{
    __block int remained = 2;
    __block int succeeded = 0;
    __block NSError *returnError;
    void (^success)(BOOL) = ^(BOOL isSucceeded){
        remained--;
        if (isSucceeded) succeeded++;
        if (!remained) {
            if (succeeded==2) {
                if (successHandler) successHandler();
            } else {
                if (errorHandler) errorHandler(returnError);
            }
        }
    };
    
    

    [FBRequestConnection startWithGraphPath:@"/me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            NSLog(@"class: %@",NSStringFromClass([result class]));
            id<FBGraphUser> me = result;
            self.info.firstName = [me first_name];
            self.info.lastName = [me last_name];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [formatter dateFromString:[me birthday]];
            self.info.birthday = date;

            self.info.contacts = [me objectForKey:@"email"];
            self.info.bio = [me objectForKey:@"bio"];
            success(YES);
            
            
        } else {
            if(!returnError) returnError = error;
            success(NO);
            //if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {

            //}
        }
    }];
    
    [FBRequestConnection startWithGraphPath:@"/me/picture?redirect=0&height=128&width=128" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"picture: %@", result);
            NSLog(@"class: %@",NSStringFromClass([result class]));
            
            NSURL *url = [NSURL URLWithString:[result valueForKeyPath:@"data.url"]];
            
            //dispatch_queue_t callerQueue = dispatch_get_current_queue();
            //dispatch_queue_t downloadQueue = dispatch_queue_create("com.myapp.processsmagequeue", NULL);
            //dispatch_async(downloadQueue, ^{
            //NSData *imageData = [NSData dataWithContentsOfURL:url];
            
            NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
            
            NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(error == nil)
                {
                    self.info.avatar = data;
                    success(YES);
                } else {
                    success(NO);
                }
            }];
            
            [dataTask resume];
            
            //self.info.avatar = imageData;
            //    dispatch_async(callerQueue, ^{
            //        processImage(imageData);
            //    });
            //});
            //dispatch_release(downloadQueue);
            
            
            
        } else {
            //if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            if (!returnError) returnError = error;
            success(NO);
            
        }
    }];
    

}

- (void) loginViewController:(id)sender receivedError:(NSError *)error
{

    
    NSString *alertText;
    NSString *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
        // Error requires people using you app to make an action outside your app to recover
        alertTitle = @"Something went wrong";
        alertText = [FBErrorUtility userMessageForError:error];
        [self showMessage:alertText withTitle:alertTitle];
        
    } else {
        // You need to find more information to handle the error within your app
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            //The user refused to log in into your app, either ignore or...
            alertTitle = @"Login cancelled";
            alertText = @"You need to login to access the app";
            [self showMessage:alertText withTitle:alertTitle];
                
        } else {
            // All other errors that can happen need retries
            // Show the user a generic error message
            alertTitle = @"Something went wrong";
            alertText = @"Please retry";
            [self showMessage:alertText withTitle:alertTitle];
        }
    }
    
}

- (void) loginViewControllerWillLogUserOut:(id)sender
{
    [self showMessage:@"You should stay logged in to continue to use this application" withTitle:@"Warning"];
}

- (void) loginViewControllerDidLogUserOut:(id)sender
{
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

- (void) loginViewControllerDidLogUserIn:(id)sender
{
    if (!self.facebookDataFetched) {
    
        void (^errorHandler) (NSError *) = ^(NSError *error) {
            [self fetchData];
            NSString *alertTitle = @"Something went wrong";
            NSString *alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        };
        
        void (^successHandler) (void) = ^{
            self.facebookDataFetched = YES;
            [self saveData];
            [self.settings dismissViewControllerAnimated:YES completion:nil];
            [self fetchData];
        };
        
        [self facebookFetch:successHandler onError:errorHandler];

    }
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
