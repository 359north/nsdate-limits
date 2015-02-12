//
//  DetailViewController.m
//  NSDateLimits
//
//  Created by Steve Mykytyn on 1/24/15.
//  Copyright (c) 2015 359 North Inc. All rights reserved.
//

#import "DetailViewController.h"

#import "DateAnalyzer.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) DateAnalyzer *dateAnalyzer;

@end

@implementation DetailViewController

- (void)viewDidLoad {
	
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.dateAnalyzer = [DateAnalyzer shared];

	[self configureView];
}



#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
	if (_detailItem != newDetailItem) {
	    _detailItem = newDetailItem;
	        
	    // Update the view.
	    [self configureView];
	}
}

- (void)configureView {
	// Update the user interface for the detail item.
	if (self.detailItem) {
		
		self.detailDescriptionLabel.text = [self.detailItem description];
		
		[self.webView loadHTMLString:[self.dateAnalyzer htmlReportNamed:self.detailItem] baseURL:nil];
		
		self.navigationItem.title = self.detailItem;
		
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if (navigationType==UIWebViewNavigationTypeLinkClicked) {
		
		[[UIApplication sharedApplication] openURL:request.URL];
				
		return NO;
	}
	
	return YES;
}

@end
