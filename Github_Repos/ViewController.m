//
//  ViewController.m
//  Github_Repos
//
//  Created by Trevor MacGregor on 2017-03-27.
//  Copyright © 2017 Trevor MacGregor. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "Repos.h"



@interface ViewController ()<UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic,strong) NSMutableArray<Repos*>* repos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //always set up array for the backing store. The gitHub repos will be brought in and stored here. So set it up first.
    self.repos = [[NSMutableArray alloc] init];
    
    //Now we go grab our data from Github...
    
    //Create a new NSURL object from the github url string.
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/users/trevormac/repos"];
    
    //Create a new NSURLRequest object using the URL object. Use this object to make configurations specific to the URL. For example, specifying if this is a GET or POST request, or how we should cache data.
    NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:url];

    //An NSURLSessionConfiguration object defines the behavior and policies to use when making a request with an NSURLSession object. We can set things like the caching policy on this object, similar to the NSURLRequest object, but we can use the session configuration to create many different requests, where any configurations we make to the NSURLRequest object will only apply to that single request.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //Create an NSURLSession object using our session configuration. Any changes we want to make to our configuration object must be done before this.
    NSURLSession *session =  [NSURLSession sessionWithConfiguration:configuration];
    
    //We create a task that will actually get the data from the server. The session creates and configures the task and the task makes the request. Data tasks send and receive data using NSData objects. Data tasks are intended for short, often interactive requests to a server. Check out the NSURLSession API Referece for more info on this. We could optionally use a delegate to get notified when the request has completed, but we're going to use a completion block instead. This block will get called when the network request is complete, weather it was successful or not.
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //If there was an error, we want to handle it straight away so we can fix it. Here we're checking if there was an error, logging the description, then returning out of the block since there's no point in continuing.
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            return ;
        }
        
        NSError *jsonError = nil;
        //The data task retrieves data from the server as an NSData object because the server could return anything. We happen to know that this server is returning JSON so we need a way to convert this data to JSON. Luckily we can just use the NSJSONSerialization object to do just that. We know that the top level object in the JSON response is a JSON object (not an array or string) so we're setting the json as a dictionary.
        NSArray *repos = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        //If there was an error getting JSON from the NSData, like if the server actually returned XML to us, then we want to handle it here.
        if (jsonError) {
            NSLog(@"error: %@", jsonError.localizedDescription);
            return ;
        }
        //If we get to this point, we have the JSON data back from our request, so let's use it. When we made this request in our browser,  we can see that we have an array of dictionaries that have the key 'name'. In order to access this in Objective-C, we can just loop through each dictionary element of the array and grab the name object and save it to a string.
        for (NSDictionary *repo in repos ) {
            NSString *repoName = repo[@"name"];
            NSLog(@"repo %@", repoName);
            
            //instantiate Repos and assign the array data to the string property from Repos.h
            Repos *newRepo = [[Repos alloc]init];
            newRepo.name = repoName;
            [self.repos addObject:newRepo];
        }
        //We always have to perform UI updates on the main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //and reload the tableview data
            [self.tableView reloadData];
        }];
        
        
        
    }];
    //A task is created in a suspended state, so we need to resume it. We can also You can also suspend, resume and cancel tasks whenever we want. This can be incredibly useful when downloading larger files using a download task.
    [dataTask resume];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repoCell"];
    
    Repos *repo = self.repos[indexPath.row];
    
    cell.cellLabel.text = repo.name;
//
    //UILabel *label = [cell viewWithTag:1];
//
//    //for James Dictionary
//    label.text = [NSString stringWithFormat:@"%@ (written in %@)", repo.name, repo.language];
////    self.label.text = (@"%@ ", repoName);

    
    return cell;
}


@end
