//
//  UserInfoViewController.h
//  KavaAssignmentApp
//
//  Created by kadaj on 3/30/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UserStoredDataViewController.h"

@interface UserInfoViewController : UserStoredDataViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UserStoredDataViewControllerDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)leaveEditMode;
- (BOOL)inputInfo: (NSError* __autoreleasing *) error;
- (void)enterEditMode;
- (void)fillInfo;


@end
