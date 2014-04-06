//
//  UserStoredDataViewController.m
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "UserStoredDataViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

@interface UserStoredDataViewController ()

@property (readonly) NSArray *permissions;
@property BOOL facebookDataFetched;

@end

@implementation UserStoredDataViewController

static UserInfo *_info;
static NSArray *_permissions;
//static BOOL _editMode;

- (UserInfo *)info
{
    @synchronized(self) {
        return _info;
    }
}

- (void) setInfo:(UserInfo *) info
{
    @synchronized(self) {
        _info = info;
    }
}

+ (void) init
{
    if(!_permissions) {
        _permissions = @[@"basic_info", @"email", @"user_about_me", @"user_birthday"];
    }
}

- (NSArray *) permissions
{
    return _permissions;
}

- (BOOL) facebookDataFetched {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"facebookDataFetched"];
}

- (void) setFacebookDataFetched:(BOOL)facebookDataFetched {
    [[NSUserDefaults standardUserDefaults] setBool:facebookDataFetched forKey:@"facebookDataFetched"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*- (BOOL) editMode {
    return _editMode;
}

- (void) setEditMode: (BOOL) mode {
    _editMode = mode;
}*/




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
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.editMode) {
        [self fetchData];
        
    }
   
}

- (void)performEditing {
    if (self.editMode) {
        NSError *inputError;
        if ([self.delegate inputInfo:&inputError]) {
            [self saveData];
            [self.delegate leaveEditMode];
            [self.delegate fillInfo];
        }
        
    } else {
        [self.delegate enterEditMode];
    }
    
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
    
    //[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    //[[UIApplication sharedApplication] performSelector:@selector(suspend)];
    self.navigationController.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
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
    
    self.navigationItem.backBarButtonItem.enabled = YES;
    self.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = NO;
    
    UIViewController *controller = sender;
    if(controller.view.tag==777) [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) saveData
{
    NSError *saveError;
    if(![self.managedObjectContext save:&saveError])
    {
        NSLog(@"Couldn't save data: %@", [saveError localizedDescription]);
    }
    
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
        [self.delegate fillInfo];
        [self.delegate leaveEditMode];
    } else {
        self.info = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext];
        [self.delegate enterEditMode];
    }
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
        controller.hidesBottomBarWhenPushed = NO;
        controller.view.tag = 777;
        self.hidesBottomBarWhenPushed = YES;
        
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
//
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
