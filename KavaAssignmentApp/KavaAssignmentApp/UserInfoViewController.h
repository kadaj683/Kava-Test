//
//  UserInfoViewController.h
//  KavaAssignmentApp
//
//  Created by kadaj on 3/30/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UITableViewController<UINavigationControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate>
-(BOOL) textFieldShouldReturn:(UITextField *)textField;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
@end
