//
//  AboutViewController.m
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UITextView *bio;

@end

@implementation AboutViewController

- (IBAction)editClick:(id)sender
{
    [self performEditing];
    
}

/*- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) leaveEditMode
{
    self.editMode = NO;
    self.bio.editable = NO;
    self.navigationItem.leftBarButtonItem.title = @"Edit";

}

- (void) enterEditMode
{
    self.editMode = YES;
    self.bio.editable = YES;
    self.navigationItem.leftBarButtonItem.title = @"Done";
}

- (void)fillInfoFromObject:(UserInfo *)info
{
    self.bio.text = info.bio;
    
}

- (BOOL)inputInfoToObject:(UserInfo *)info withError:(NSError *__autoreleasing *)error
{
    NSString *header = @"Problem";
    NSString *description = nil;
    
    
    if([self.bio.text length]==0) {
        description = @"Please write something about yourself";
    }
    
    if (description) {
        [self showMessage:description withTitle:header];
        NSError *returnError = [NSError errorWithDomain:NSInvalidArgumentException code:1 userInfo:@{NSLocalizedDescriptionKey: description}];
        *error = returnError;
        return NO;
    }
    
    
    info.bio = self.bio.text;
    return YES;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
