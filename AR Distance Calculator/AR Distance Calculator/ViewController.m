


#import "ViewController.h"
#import "DiscoverBeaconViewController.h"
#import "SimulationBeaconViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"iBeacon";
    [self.view addSubview:self.tableView];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = (id)self;
        _tableView.dataSource = (id)self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Discover Beacon";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Edit Beacon name";
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        DiscoverBeaconViewController *vc = [[DiscoverBeaconViewController alloc] init];
        vc.title = cell.textLabel.text;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
      SimulationBeaconViewController *vc = [[SimulationBeaconViewController alloc] init];
        vc.title = cell.textLabel.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end

