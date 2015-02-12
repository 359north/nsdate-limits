//
//  DateAnalyzer.h
//  NSDateLimits
//
//  Created by Steve Mykytyn on 1/26/15.
//  Copyright (c) 2015 359 North Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateAnalyzer : NSObject

+ (instancetype)shared;

+ (NSArray *) availableReports;

- (NSString *) htmlReportNamed:(NSString *) reportName;

@end
