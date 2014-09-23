//
//  DlImageListTableViewCell.h
//  InstagramAPI
//
//  Created by Admin on 22/09/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DlImageListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgLarge;
@property (weak, nonatomic) IBOutlet UIImageView *imgMedium;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumbnail;

@end
