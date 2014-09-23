//
//  DLImageListViewController.m
//  InstagramAPI
//
//  Created by Admin on 22/09/14.
//  Copyright (c) 2014 Admin. All rights reserved.
//

#import "DLImageListViewController.h"
#import "DlImageListTableViewCell.h"

#import "UIImageView+AFNetworking.h"
#import "InstagramKit.h"
#import "InstagramMedia.h"
#import "InstagramUser.h"

@interface DLImageListViewController ()
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) UIView *viewBackground;
@property (nonatomic, strong ) InstagramPaginationInfo *paginationInfo;
@property (nonatomic, weak) IBOutlet UITextField *txtKeyword;
@property (nonatomic, weak) IBOutlet UITableView *tblImageList;

@end

@implementation DLImageListViewController

#pragma Mark Lazy Instantiation

-(NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

-(UIView *)viewBackground{
    if (!_viewBackground) {
        _viewBackground = [[UIView alloc] initWithFrame:self.view.frame];
        [_viewBackground setBackgroundColor:[UIColor blackColor]];
        [_viewBackground setAlpha:0.9f];
        _viewBackground.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [_viewBackground setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minimizeview:)];
        [_viewBackground addGestureRecognizer:tap];
    }
    return _viewBackground;
}


#pragma View initialization

-(void)setUP{
    
    self.paginationInfo = nil;
    [self instagramAPICall:@"Selfie"];
    
}
-(void)awakeFromNib{
    [self setUP];
}

#pragma Mark UITableViewDataSource Delegate


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"cellIdentifier";
    DlImageListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.dataSourceArray.count >0) {
        InstagramMedia *iObject = self.dataSourceArray[indexPath.row];
        [cell.imgLarge setImageWithURL:iObject.standardResolutionImageURL];
        [cell.imgMedium setImageWithURL:iObject.lowResolutionImageURL];
        [cell.imgThumbnail setImageWithURL:iObject.thumbnailURL];
    }
    return cell;
    
}


#pragma Mark UITableViewDelegate Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self popoverPresentationwWithImageAtIndex:indexPath];
    return;
}

#pragma Mark Instagram API Call

- (void)instagramAPICall:(NSString *)tag
{
    [[InstagramEngine sharedEngine] getMediaWithTagName:tag count:100 maxId:self.paginationInfo.nextMaxId withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.paginationInfo = paginationInfo;
        [self.dataSourceArray addObjectsFromArray:media];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblImageList reloadData];
        });
        
        
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"no image found for the given keyword" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}


#pragma Mark ReloadTableView

-(void)reloadTableWithArray:(NSArray *)array{
    [self.tblImageList insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self instagramAPICall:@"Selfie"];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self instagramAPICall:@"Selfie"];
    });
}
#pragma Mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *keyword = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (keyword.length == 0) {
        keyword = @"Selfie";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.dataSourceArray removeAllObjects];
        [self instagramAPICall:keyword];
    });
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma  Mark popover
-(void)popoverPresentationwWithImageAtIndex:(NSIndexPath *)indexPath{
    
    InstagramMedia *iObject = self.dataSourceArray[indexPath.row];
    
    UIImageView *imgLocal = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/4, self.view.bounds.size.height/4, self.view.bounds.size.width/2, self.view.bounds.size.height/4)];
    [imgLocal setImageWithURL:iObject.thumbnailURL];
    [self.viewBackground addSubview:imgLocal];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view addSubview:self.viewBackground];
        self.viewBackground.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }completion:nil];
    
}
-(void)minimizeview:(UITapGestureRecognizer*)recognizer{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.viewBackground.transform = CGAffineTransformMakeScale(0.05f,0.05);
        
    }completion:^(BOOL finished) {
        [self.viewBackground removeFromSuperview];
        self.viewBackground = nil;
    }];
  
    
}


@end
