//
//  CLHomeViewController.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "CLHomeViewController.h"
#import "UIView+CLMediaPlayer.h"
#import "UITableView+CLMediaPlayer.h"
#import "CLHomeVideoTableViewCell.h"

@interface CLHomeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CLHomeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tableView.visiableTableViewFrame = self.tableView.frame;
    
    [self.tableView mp_initializtionVisibleCellPlaceCellTypeAfterReload];
    [self.tableView mp_playVisibleCellIfNeed];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"CLHomeVideoTableViewCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"player"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"other"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0 || indexPath.section != 1) {
        return 375;
    }
    else {
        return 50;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 20;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"other";
    
    if (indexPath.row % 2 == 0 || indexPath.section != 1) {
        identifier = @"player";
        CLHomeVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.mdPlayView = cell.mpVideoPlayerView;
        cell.videoUrl   = @"https://dn-youplus-app2.qbox.me/FkFASJjXSrH3LPDyrAHUsbmn3heh";
        [tableView mp_initializtionPlaceCellTypeWithUITableViewCell:cell indexPath:indexPath];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        return cell;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView mp_scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableView mp_scrollViewDidEndDraggingWithDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.tableView mp_scrollViewDidEndDecelerating];
}

@end
