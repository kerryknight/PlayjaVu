//
//  PVMyProfileViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 3/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVMyProfileViewController.h"

static NSString *const kProfileViewControllerCellReuseId = @"PVProfileCell";

@interface PVMyProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PVMyProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureUI];
}

#pragma mark - Public Methods

#pragma mark - Private Methods
- (void)configureUI
{
    self.tableView.backgroundColor = kMedGray;
    self.view.backgroundColor = kMedGray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileViewControllerCellReuseId];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileViewControllerCellReuseId];
	}

    cell.textLabel.text = [NSString stringWithFormat:@"Cell: %li", (long)indexPath.row];
	cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = kMedGray;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds] ;
    cell.selectedBackgroundView.backgroundColor = kDrkGray;
    
	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
