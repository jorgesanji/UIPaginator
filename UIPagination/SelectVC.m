//
//  SelectVC.m
//  UIPagination
//
//  Copyright (c) 2014 Jorge Sanmartin. All rights reserved.
//

#import "SelectVC.h"
#import "Common.h"
#import "ItemSelectedVC.h"

@interface SelectVC ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSMutableArray *data;

@end

@implementation SelectVC

@synthesize data = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        // Custom initialization
        self.data = [NSMutableArray arrayWithCapacity:0];
        
        //TODO:fill data for UITableView
        NSDictionary *dic = @{@"title" :@"UIPaginator with UIView"};
        [_data addObject:dic];
        dic = @{@"title" :@"UIPaginator with ViewController"};
        [_data addObject:dic];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Sample aplication";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
    return KHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ChooseCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setFont:OpenSansSemiBold];
    }
    
    //get title from NSDictionary
    NSDictionary *dic = [_data objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    
    //Set title cell view
    [cell.textLabel setText:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Launch controller with pagination type (UIView or UIViewController)
    ItemSelectedVC *itemSel = [[ItemSelectedVC alloc] init];
    itemSel.type = (indexPath.row == 0)?viewSelection:viewControllerSelection;
    [self.navigationController pushViewController:itemSel animated:YES];

}

@end

