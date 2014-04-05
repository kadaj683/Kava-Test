//
//  UserInfoViewController.h
//  KavaAssignmentApp
//
//  Created by kadaj on 3/30/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface UserInfoViewController : UITableViewController<UINavigationControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,FBUserSettingsDelegate,NSURLSessionDataDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)loginViewController:(id)sender receivedError:(NSError *)error;
- (void)loginViewControllerWillLogUserOut:(id)sender;
- (void)loginViewControllerDidLogUserOut:(id)sender;
- (void)loginViewControllerDidLogUserIn:(id)sender;

@end
