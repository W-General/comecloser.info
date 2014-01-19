//
//  TrackViewController.m
//  iBeacons Demo
//
//  Created by M Newill on 27/09/2013.
//  Copyright (c) 2013 Mobient. All rights reserved.
//

#import "TrackViewController.h"
#import "WebQuery.h"

@interface TrackViewController ()

@property WebQuery* wqq;
@property WebQuery* wqq_self;
@property NSMutableArray* common;
@property NSMutableArray* diff;


@end

@implementation TrackViewController
@synthesize wqq, wqq_self;


- (WebQuery*)getUser:(NSNumber*)userId
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://mhacks-ios-backend.herokuapp.com/users/%@", userId];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    WebQuery *user = [[WebQuery alloc] init];
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&responseCode error:&error];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    user.firstname = [JSON objectForKey:@"firstname"];
    user.lastname = [JSON objectForKey:@"lastname"];
    user.user = [JSON objectForKey:@"user"];
    user.keyowords = [JSON objectForKey:@"keywords"];
    
    return user;
}

- (WebQuery*)CallWebQuery:(NSNumber*)user
{
    WebQuery* wq = [self getUser: user];
    return wq;
}

- (WebQuery*)CallWebQuery_Simulated:(NSNumber*)user
{
    WebQuery* wq = [[WebQuery alloc] init];
    wq.user = user;
    wq.firstname = [NSString stringWithFormat:@"Eric"];
    wq.lastname = [NSString stringWithFormat:@"Yu"];
    wq.keyowords = [NSArray arrayWithObjects: @"Programming", @"Test1", @"Test2", nil];
    return wq;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    self.wqq_self = [self CallWebQuery: [[NSNumber alloc] initWithInt:3]];
    [self initBeacon];
    [self transmitBeacon];
    //self.minorLabel.text = [self numberOfSectionsInTableView: tblView];
    //[self.tblView reloadData];
}

- (void)initBeacon {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.TbeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:3
                                                                minor:1
                                                           identifier:@"com.devfright.myRegion"];
}

- (void)transmitBeacon {
    self.beaconPeripheralData = [self.TbeaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [self.peripheralManager stopAdvertising];
    }
}


- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.devfright.myRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconFoundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];

    if(beacon.major!=nil && beacon.proximity == CLProximityImmediate)
    {
        // Simulated WebQuery
        self.wqq = [self CallWebQuery: beacon.major];
        [self.tblView reloadData];
        NSString* tmp = [wqq.firstname stringByAppendingString:[NSString stringWithFormat:@" "]];
        self.beaconFoundLabel.text = [tmp stringByAppendingString:wqq.lastname];
        
        [self tableView: self.wqq_self.keyowords commDiffKeywords:self.wqq.keyowords];
        
        // Use here to update
    }
    else
    {
        self.beaconFoundLabel.text = @"Unknown";
        self.wqq.user = nil;
        self.wqq.firstname = nil;
        self.wqq.lastname = nil;
        self.wqq.keyowords = nil;
        self.common = nil;
        self.diff = nil;
        [self.tblView reloadData];
    }
    //self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
    //self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    //self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    //self.minorLabel.text = self.wqq.firstname;
    //self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    if (beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate) {
        self.distanceLabel.text = @"Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Far";
    }
    //self.rssiLabel.text = [NSString stringWithFormat:@"%i", beacon.rssi];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)tableView:(NSArray *)keywords_self commDiffKeywords:(NSArray *)keywords_other {
    
    //NSArray* testMine = [NSArray arrayWithObjects: @"Programming", @"Test1", @"Test2", nil];
    //NSArray* testOthers = [NSArray arrayWithObjects: @"Programming", @"Test1", nil];
    self.diff = [NSMutableArray new];
    self.common = [NSMutableArray new];
    
    /*
    for ( NSString * kw in testOthers)
        [self.diff addObject:kw];
    for ( NSString * kw in testMine)
        [self.common addObject:kw];*/
    
    
    for(NSString * kw in keywords_other) {
        NSInteger idx = [keywords_self indexOfObject:kw];
        if (idx != NSNotFound){
            [self.common addObject:kw];
        }//add ot common
        else [self.diff addObject:kw];//add to diff;
    }
    
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [self.common count];
    else return [self.diff count];
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}
*/

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return [NSString stringWithFormat:@"Common Interests"];
    else return [NSString stringWithFormat:@"Other Interests"];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0)
        cell.textLabel.text = [self.common objectAtIndex:indexPath.row];
    else cell.textLabel.text = [self.diff objectAtIndex:indexPath.row];
    
    
    
    // Configure the cell.
    
    return cell;
}


@end
