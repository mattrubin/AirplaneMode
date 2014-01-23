//
//  APMRootViewController.m
//  Airplane Mode
//
//  Created by Matt Rubin on 1/22/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "APMRootViewController.h"
#import "APMSessionManager.h"


@interface APMRootViewController ()

@property (nonatomic, strong) UITextView *textView;

@end


@implementation APMRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(log:) name:@"APMSessionManagerNotification" object:nil];
    [[APMSessionManager sharedManager] start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)log:(NSNotification *)notification
{
    NSString *message = notification.userInfo[@"log"];
    if (message)
        self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@", message];
}

@end
