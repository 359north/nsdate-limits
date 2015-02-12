//
//  NSDate+LUX.m
//  NSDateLimits
//
//  Created by Steve Mykytyn on 1/27/15.
//  Copyright (c) 2015 359 North Inc. All rights reserved.
//

#import "NSDate+LUX.h"

#define ALL_COMPONENTS NSCalendarUnitCalendar|NSCalendarUnitDay|NSCalendarUnitEra|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitNanosecond|NSCalendarUnitQuarter|NSCalendarUnitSecond|NSCalendarUnitTimeZone|NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekOfYear|NSCalendarUnitYear|NSCalendarUnitYearForWeekOfYear

@implementation NSDate (LUX)

- (NSString *) luxDescription {
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components:ALL_COMPONENTS fromDate:self];
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	
	NSString *yearString = [nf stringFromNumber:[NSNumber numberWithLong:components.year]];
	
	NSString *formattedDate = [NSString stringWithFormat:@"%@-%ld-%ld",yearString,(long)components.month,(long)components.day];
	
	return formattedDate;
}

@end