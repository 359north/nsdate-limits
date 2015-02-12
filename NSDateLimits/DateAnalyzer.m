//
//  DateAnalyzer.m
//  NSDateLimits
//
//  Created by Steve Mykytyn on 1/26/15.
//  Copyright (c) 2015 359 North Inc. All rights reserved.
//

#import "DateAnalyzer.h"

#import "NSDate+LUX.h"

#define RPT1 @"NSDate distant"
#define RPT2 @"NSDateFormatter input"
#define RPT3 @"NSDateFormatter output"
#define RPT4 @"NSTimeZone"
#define RPT5 @"NSDate Precision"
#define RPT6 @"NSCalendar"
#define RPT7 @"Julian to Gregorian"
#define RPT8 @"Parse.com BC"
#define RPT9 @"NSNumberFormatter"
#define RPT10 @"Read The Blog Post"

NSString * const noteTZ = @"<p>Before time zones were established in the late 19th century, formatted dates are displayed using <b>local mean time (LMT)</b>, based on longitude of the primary city associated with a time zone.</p>";

NSString * const noteGregorian = @"<p>The Gregorian calendar did not exist before October 15, 1582.  When extended backwards before that date, the calendar is called <i>proleptic</i>.  Dates in the Julian calendar in effect prior to October 15, 1582 in Western Europe are generally different.  Only a few nations adopted the Gregorian calendar in 1582 - notable exceptions among many being the United Kingdom and its colonies (1752) and Russia (1918).</p>";

@interface DateAnalyzer ()

@property (strong, nonatomic) NSDateFormatter *formatterADBC;

@property (strong, nonatomic) NSDateFormatter *formatterADBCPlusTime;

@property (strong, nonatomic) NSDateFormatter *formatterADBCPlusTimeLocal;

@property (strong, nonatomic) NSDateFormatter *formatterADBCPlusTimePST;

@property (strong, nonatomic) NSDateFormatter *formatterADBCPlusTimeChina;

@property (strong, nonatomic) NSNumberFormatter *formatterDouble;

@property (strong, nonatomic) NSNumberFormatter *formatterDoubleLarge;

@property (strong, nonatomic) NSNumberFormatter *formatterLongLong;

@property (strong, nonatomic) NSDate *lastFormattedInputDate;

@property (strong, nonatomic) NSDate *lastFormattedInputDateBC;

@property (strong, nonatomic) NSDate *lastIntervalDate;

@property (strong, nonatomic) NSDate *lastIntervalDateBC;

@end

@implementation DateAnalyzer

#pragma mark - class methods

+ (instancetype)shared {

	static dispatch_once_t flag;
	static DateAnalyzer *shared = nil;
	dispatch_once(&flag, ^{ shared = [[self alloc] init]; });
	return shared;
}

+ (NSArray *) availableReports {
	
	return @[RPT1,RPT2,RPT3,RPT5,RPT6,RPT7,RPT8,RPT9,RPT4,RPT10];
	
	
}

- (instancetype) init {
	
	self = [super init];
	
	if (self != nil) {
		
		self.formatterADBC = [[NSDateFormatter alloc] init];
		[self.formatterADBC setDateFormat:@"d MMM y GGG"];
		[self.formatterADBC setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
		

		self.formatterADBCPlusTime = [[NSDateFormatter alloc] init];
		[self.formatterADBCPlusTime setDateFormat:@"d MMM y GGG h:mm:ss a ZZ"];
		[self.formatterADBCPlusTime setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
		
		self.formatterADBCPlusTimeLocal = [[NSDateFormatter alloc] init];
		[self.formatterADBCPlusTimeLocal setDateFormat:@"d MMM y GGG h:mm:ss a ZZ"];
		
		self.formatterADBCPlusTimePST = [[NSDateFormatter alloc] init];
		[self.formatterADBCPlusTimePST setDateFormat:@"d MMM y GGG h:mm:ss a ZZ"];
		[self.formatterADBCPlusTimePST setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
		
		self.formatterADBCPlusTimeChina = [[NSDateFormatter alloc] init];
		[self.formatterADBCPlusTimeChina setDateFormat:@"d MMM y GGG h:mm:ss a ZZ"];
		[self.formatterADBCPlusTimeChina setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
		
		self.formatterLongLong = [[NSNumberFormatter alloc] init];
		[self.formatterLongLong setNumberStyle:NSNumberFormatterNoStyle];
		
		
		
		self.formatterDouble = [[NSNumberFormatter alloc] init];
		[self.formatterDouble setNumberStyle:NSNumberFormatterDecimalStyle];
		
		[self findMaxDatesViaFormatter2];
		[self findMaxDatesViaIntervals];
		
		[self checkMaxDatesViaFormatter];
		
	}
	
	return self;

	
	
}

#pragma mark - report generators

- (NSString *) htmlReportNamed:(NSString *) reportName {
	
	NSString *reportString = [NSString stringWithFormat:@"Could not find requested report: \"%@\"",reportName];
	
	if ([reportName isEqualToString:RPT1])		{ reportString = [self reportDistantDates]; }
	else if ([reportName isEqualToString:RPT2]) { reportString = [self reportDatesFromFormatter]; }
	else if ([reportName isEqualToString:RPT3]) { reportString = [self reportDatesFromIntervals]; }
	else if ([reportName isEqualToString:RPT4]) { reportString = [self reportTimeZones]; }
	else if ([reportName isEqualToString:RPT5]) { reportString = [self reportPrecision]; }
	else if ([reportName isEqualToString:RPT6]) { reportString = [self reportCalendar]; }
	else if ([reportName isEqualToString:RPT7]) { reportString = [self reportJulianGregorian]; }
	else if ([reportName isEqualToString:RPT8]) { reportString = [self reportParseBC]; }
	else if ([reportName isEqualToString:RPT9]) { reportString = [self reportNumberFormatter]; }
	else if ([reportName isEqualToString:RPT10]) { reportString = [self reportBlogPost]; }
	
	NSString *html = [NSString stringWithFormat:@"<html><head>%@%@</head><body>%@<hr/></body></html>",[self meta],[self css],reportString];
	
	return html;
}

- (NSString *) reportDistantDates {
	
	NSMutableArray *reportMA = [NSMutableArray arrayWithCapacity:2];
	
	NSDate *distantPast = [NSDate distantPast];
	NSDate *distantFuture = [NSDate distantFuture];
	
	CFAbsoluteTime absoluteDistantPast = CFDateGetAbsoluteTime((CFDateRef)distantPast);
	CFAbsoluteTime absoluteDistantFuture = CFDateGetAbsoluteTime((CFDateRef)distantFuture);
	
	CFAbsoluteTime absoluteReferenceTime = 0;
	NSDate *absoluteReferenceDate = CFBridgingRelease(CFDateCreate(NULL,absoluteReferenceTime));
	
	NSString *distantPastString = [self.formatterADBCPlusTime stringFromDate:distantPast];
	NSString *distantFutureString = [self.formatterADBCPlusTime stringFromDate:distantFuture];
	NSString *referenceString = [self.formatterADBCPlusTime stringFromDate:absoluteReferenceDate];

	NSString *absoluteDistantPastString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteDistantPast]];
	NSString *absoluteDistantFutureString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteDistantFuture]];
	NSString *absoluteReferenceString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteReferenceTime]];
	
	[reportMA addObject:@[@"[NSDate distantPast]",distantPastString,distantPast.description,absoluteDistantPastString]];
	[reportMA addObject:@[@"[NSDate distantFuture]",distantFutureString,distantFuture.description,absoluteDistantFutureString]];
	[reportMA addObject:@[@"CFDateCreate(NULL,0.0f)",referenceString,absoluteReferenceDate.description,absoluteReferenceString]];

	NSString *formatTableHeader = @"<table width=100%><thead><tr valign=bottom><th>Method</th><th>stringFromDate<sup>1</sup></th><th>description<sup>2</sup></th></th><th>CFAbsoluteTime<sup>3</sup></th></tr></thead>\n";
	NSString *formatTableRow = @"<tr><td>%@</td><td align=right>%@</td><td align=right>%@</td><td align=right>%@</td></tr>\n";

	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<p>This report shows the results of using NSDate methods distantPast and distantFuture.</p>"];
	[html appendString:@"<h2>Time Zone GMT</h2>"];
	
	[html appendString:formatTableHeader];
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:formatTableRow,array[0],array[1],array[2],array[3]];
	}

	[html appendFormat:@"</table>\n"];
	
	// now adapt for local time zone of device
	
	distantPastString = [self.formatterADBCPlusTimeLocal stringFromDate:distantPast];
	distantFutureString = [self.formatterADBCPlusTimeLocal stringFromDate:distantFuture];
	referenceString = [self.formatterADBCPlusTimeLocal stringFromDate:absoluteReferenceDate];
	
	[reportMA removeAllObjects];
	
	[reportMA addObject:@[@"[NSDate distantPast]",distantPastString,distantPast.description,absoluteDistantPastString]];
	[reportMA addObject:@[@"[NSDate distantFuture]",distantFutureString,distantFuture.description,absoluteDistantFutureString]];
	[reportMA addObject:@[@"CFDateCreate(NULL,0.0f)",referenceString,absoluteReferenceDate.description,absoluteReferenceString]];
	
	[html appendFormat:@"<br/><h2>Local Time Zone %@</h2>",[NSTimeZone defaultTimeZone]];
	
	[html appendString:formatTableHeader];
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:formatTableRow,array[0],array[1],array[2],array[3]];
	}
	
	[html appendFormat:@"</table>\n"];
	
	

	[html appendFormat:@"<br/><p><sup>1</sup> results from the NSDateFormatter stringFromDate method with format @\"d MMM y GGG h:mm:ss a ZZ\".  The results differ depending on the time zone set for the NSDateFormatter instance.</p>\n"];

	[html appendFormat:@"<p><sup>2</sup> results from the NSDate description method.</p>"];

	[html appendFormat:@"<p><sup>3</sup> results from the CFDateGetAbsoluteTime function.  Identical to NSDate timeIntervalSinceReferenceDate.</p>\n"];
	
	[html appendString:noteTZ];
	[html appendString:noteGregorian];

	[html appendFormat:@"<p>Created at %@</p>", [NSDate date]];
	

	return html;
}

- (NSString *) reportDatesFromFormatter {
	
	NSMutableArray *reportMA = [NSMutableArray arrayWithCapacity:2];
	
	NSDate *newBCDate = [self.lastFormattedInputDateBC dateByAddingTimeInterval:-1]; // one second less
	NSDate *newADDate = [self.lastFormattedInputDate dateByAddingTimeInterval:+1]; // one second more
	
	CFAbsoluteTime absoluteAD = CFDateGetAbsoluteTime((CFDateRef)self.lastFormattedInputDate);
	CFAbsoluteTime absoluteBC = CFDateGetAbsoluteTime((CFDateRef)self.lastFormattedInputDateBC);
	CFAbsoluteTime absoluteAD2 = CFDateGetAbsoluteTime((CFDateRef)newADDate);
	CFAbsoluteTime absoluteBC2 = CFDateGetAbsoluteTime((CFDateRef)newBCDate);
	
	NSString *newBCDateString = [self.formatterADBCPlusTime stringFromDate:newBCDate];
	NSString *newADDateString = [self.formatterADBCPlusTime stringFromDate:newADDate];
	
	newBCDate = [self.formatterADBCPlusTime dateFromString:newBCDateString];
	newADDate = [self.formatterADBCPlusTime dateFromString:newADDateString];

	
	NSString *adString = [self.formatterADBCPlusTime stringFromDate:self.lastFormattedInputDate];
	NSString *bcString = [self.formatterADBCPlusTime stringFromDate:self.lastFormattedInputDateBC];
	
	NSString *absoluteADString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteAD]];
	NSString *absoluteBCString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteBC]];
	NSString *absoluteADString2 = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteAD2]];
	NSString *absoluteBCString2 = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteBC2]];
	
	[reportMA addObject:@[adString,self.lastFormattedInputDate.description,absoluteADString]];
	[reportMA addObject:@[newADDateString,(newADDate)?newADDate:@"(null)",absoluteADString2.description]];
	[reportMA addObject:@[bcString,self.lastFormattedInputDateBC.description,absoluteBCString]];
	[reportMA addObject:@[newBCDateString,(newBCDate)?newBCDate.description:@"(null)",absoluteBCString2.description]];
	
	NSString *formatTableHeader = @"<table width=100%><thead><tr><th>input to NSDateFormatter</th><th>dateFromString</th><th>CFAbsoluteTime</th></tr></thead>\n";
	NSString *formatTableRow = @"<tr><td align=right>%@</td><td align=right>%@</td><td align=right>%@</td></tr>\n";
	NSString *formatTableRow2 = @"<tr><td align=right class=\"even\">%@</td><td align=right class=\"even\">%@</td><td align=right class=\"even\">%@</td></tr>\n";
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<p>The NSDateFormatter instance method dateFromString accepts an NSString and produces an NSDate, but only for a limited range.  This report empirically determines that range.</p>"];

	
	[html appendString:@"<h2>Time Zone GMT</h2>"];
	
	[html appendString:formatTableHeader];
	
	NSInteger i = 0;
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:(i%2==0)?formatTableRow:formatTableRow2,array[0],array[1],array[2]];
		
		i++;
	}
	
	[html appendFormat:@"</table>\n"];
	
	// now adapt for China time zone
	
	adString = [self.formatterADBCPlusTimeChina stringFromDate:self.lastFormattedInputDate];
	bcString = [self.formatterADBCPlusTimeChina stringFromDate:self.lastFormattedInputDateBC];
	
	[reportMA removeAllObjects];
	
	newBCDate = [self.lastFormattedInputDateBC dateByAddingTimeInterval:-1]; // one second less
	newADDate = [self.lastFormattedInputDate dateByAddingTimeInterval:+1]; // one second more
	
	newBCDateString = [self.formatterADBCPlusTimeChina stringFromDate:newBCDate];
	newADDateString = [self.formatterADBCPlusTimeChina stringFromDate:newADDate];

	
	newBCDate = [self.formatterADBCPlusTimeChina dateFromString:newBCDateString];
	newADDate = [self.formatterADBCPlusTimeChina dateFromString:newADDateString];
	
	[reportMA addObject:@[adString,self.lastFormattedInputDate.description,absoluteADString]];
	[reportMA addObject:@[newADDateString,(newADDate)?newADDate:@"(null)",absoluteADString2.description]];
	[reportMA addObject:@[bcString,self.lastFormattedInputDateBC.description,absoluteBCString]];
	[reportMA addObject:@[newBCDateString,(newBCDate)?newBCDate.description:@"(null)",absoluteBCString2.description]];

	
	[html appendFormat:@"<br/><h2>Time Zone %@</h2>",[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
	
	[html appendString:formatTableHeader];
	
	i = 0;
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:(i%2==0)?formatTableRow:formatTableRow2,array[0],array[1],array[2]];
		
		i++;
	}
	
	[html appendFormat:@"</table>\n"];
	
	// now adapt for Los Angeles time zone
	
	adString = [self.formatterADBCPlusTimePST stringFromDate:self.lastFormattedInputDate];
	bcString = [self.formatterADBCPlusTimePST stringFromDate:self.lastFormattedInputDateBC];
	
	[reportMA removeAllObjects];
	
	newBCDate = [self.lastFormattedInputDateBC dateByAddingTimeInterval:-1]; // one second less
	newADDate = [self.lastFormattedInputDate dateByAddingTimeInterval:+1]; // one second more
	
	newBCDateString = [self.formatterADBCPlusTimePST stringFromDate:newBCDate];
	newADDateString = [self.formatterADBCPlusTimePST stringFromDate:newADDate];
	
	
	newBCDate = [self.formatterADBCPlusTimePST dateFromString:newBCDateString];
	newADDate = [self.formatterADBCPlusTimePST dateFromString:newADDateString];
	
	[reportMA addObject:@[adString,self.lastFormattedInputDate.description,absoluteADString]];
	[reportMA addObject:@[newADDateString,(newADDate)?newADDate:@"(null)",absoluteADString2.description]];
	[reportMA addObject:@[bcString,self.lastFormattedInputDateBC.description,absoluteBCString]];
	[reportMA addObject:@[newBCDateString,(newBCDate)?newBCDate.description:@"(null)",absoluteBCString2.description]];
	
	
	[html appendFormat:@"<br/><h2>Time Zone %@</h2>",[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
	
	[html appendString:formatTableHeader];
	
	i = 0;
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:(i%2==0)?formatTableRow:formatTableRow2,array[0],array[1],array[2]];
		
		i++;
	}
	
	[html appendFormat:@"</table>\n"];

	
	[html appendString:noteTZ];
	[html appendString:noteGregorian];

	[html appendFormat:@"<p>Created at %@</p>", [NSDate date]];
	
	return html;
	
}

- (NSString *) reportDatesFromIntervals {
	
	NSMutableArray *reportMA = [NSMutableArray arrayWithCapacity:2];
	
	NSDate *newBCDate = [self.lastIntervalDateBC dateByAddingTimeInterval:-1]; // one second less
	NSDate *newADDate = [self.lastIntervalDate dateByAddingTimeInterval:+1]; // one second more
	
	CFAbsoluteTime absoluteAD = CFDateGetAbsoluteTime((CFDateRef)self.lastIntervalDate);
	CFAbsoluteTime absoluteBC = CFDateGetAbsoluteTime((CFDateRef)self.lastIntervalDateBC);
	CFAbsoluteTime absoluteAD2 = CFDateGetAbsoluteTime((CFDateRef)newADDate);
	CFAbsoluteTime absoluteBC2 = CFDateGetAbsoluteTime((CFDateRef)newBCDate);
	
	NSString *newBCDateString = [self.formatterADBCPlusTime stringFromDate:newBCDate];
	NSString *newADDateString = [self.formatterADBCPlusTime stringFromDate:newADDate];
	
//	newBCDate = [self.formatterADBCPlusTime dateFromString:newBCDateString];
//	newADDate = [self.formatterADBCPlusTime dateFromString:newADDateString];
	
	
	NSString *adString = [self.formatterADBCPlusTime stringFromDate:self.lastIntervalDate];
	NSString *bcString = [self.formatterADBCPlusTime stringFromDate:self.lastIntervalDateBC];
	
	NSString *absoluteADString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteAD]];
	NSString *absoluteBCString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteBC]];
	NSString *absoluteADString2 = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteAD2]];
	NSString *absoluteBCString2 = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:absoluteBC2]];
	
	[reportMA addObject:@[adString,self.lastIntervalDate.description,absoluteADString]];
	[reportMA addObject:@[newADDateString,(newADDate.description.length>0)?newADDate:@"(description failed)",absoluteADString2]];
	[reportMA addObject:@[bcString,self.lastIntervalDateBC.description,absoluteBCString]];
	[reportMA addObject:@[newBCDateString,(newBCDate.description.length>0)?newBCDate.description:@"(description failed)",absoluteBCString2]];
	
	NSString *formatTableHeader = @"<table width=100%><thead><tr valign=bottom><th>CFAbsoluteTime</th><th>stringFromDate<sup>1</sup></th><th>description<sup>2</sup></th></tr></thead>\n";
	NSString *formatTableRow = @"<tr><td align=right>%@</td><td align=right>%@</td><td align=right>%@</td></tr>\n";
	NSString *formatTableRow2 = @"<tr><td align=right class=\"even\">%@</td><td align=right class=\"even\">%@</td><td align=right class=\"even\">%@</td></tr>\n";
	
	
	
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<p>NSDateFormatter can output an NSString for a considerably wider range of dates than it can input.  This report empirically determines that range.</p>"];
	
	
	[html appendString:@"<h2>Time Zone GMT</h2>"];
	
	[html appendString:formatTableHeader];
	
	NSInteger i = 0;
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:(i%2==0)?formatTableRow:formatTableRow2,array[2],array[0],array[1]];
		
		i++;
	}
	
	[html appendFormat:@"</table>\n"];
	
	// now adapt for China time zone
	
	adString = [self.formatterADBCPlusTimeChina stringFromDate:self.lastIntervalDate];
	bcString = [self.formatterADBCPlusTimeChina stringFromDate:self.lastIntervalDateBC];
	
	[reportMA removeAllObjects];
	
	newBCDate = [self.lastIntervalDateBC dateByAddingTimeInterval:-1]; // one second less
	newADDate = [self.lastIntervalDate dateByAddingTimeInterval:+1]; // one second more
	
	newBCDateString = [self.formatterADBCPlusTimeChina stringFromDate:newBCDate];
	newADDateString = [self.formatterADBCPlusTimeChina stringFromDate:newADDate];
	
	
	newBCDate = [self.formatterADBCPlusTimeChina dateFromString:newBCDateString];
	newADDate = [self.formatterADBCPlusTimeChina dateFromString:newADDateString];
	
	[reportMA addObject:@[adString,self.lastIntervalDateBC.description,absoluteADString]];
	[reportMA addObject:@[newADDateString,(newADDate)?newADDate:@"(null)",absoluteADString2.description]];
	[reportMA addObject:@[bcString,self.lastIntervalDateBC.description,absoluteBCString]];
	[reportMA addObject:@[newBCDateString,(newBCDate)?newBCDate.description:@"(null)",absoluteBCString2.description]];
	
	
	[html appendFormat:@"<br/><h2>Time Zone %@</h2>",[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
	
	[html appendString:formatTableHeader];
	
	i = 0;
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:(i%2==0)?formatTableRow:formatTableRow2,array[2],array[0],array[1]];
		
		i++;
	}
	
	[html appendFormat:@"</table>\n"];
	
	// now adapt for Los Angeles time zone
	
	adString = [self.formatterADBCPlusTimePST stringFromDate:self.lastIntervalDate];
	bcString = [self.formatterADBCPlusTimePST stringFromDate:self.lastIntervalDateBC];
	
	[reportMA removeAllObjects];
	
	newBCDate = [self.lastIntervalDateBC dateByAddingTimeInterval:-1]; // one second less
	newADDate = [self.lastIntervalDate dateByAddingTimeInterval:+1]; // one second more
	
	newBCDateString = [self.formatterADBCPlusTimePST stringFromDate:newBCDate];
	newADDateString = [self.formatterADBCPlusTimePST stringFromDate:newADDate];
	
	
	newBCDate = [self.formatterADBCPlusTimePST dateFromString:newBCDateString];
	newADDate = [self.formatterADBCPlusTimePST dateFromString:newADDateString];
	
	[reportMA addObject:@[adString,self.lastIntervalDate.description,absoluteADString]];
	[reportMA addObject:@[newADDateString,(newADDate)?newADDate:@"(null)",absoluteADString2.description]];
	[reportMA addObject:@[bcString,self.lastIntervalDateBC.description,absoluteBCString]];
	[reportMA addObject:@[newBCDateString,(newBCDate)?newBCDate.description:@"(null)",absoluteBCString2.description]];
	
	
	[html appendFormat:@"<br/><h2>Time Zone %@</h2>",[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
	
	[html appendString:formatTableHeader];
	
	i = 0;
	
	for(NSArray *array in reportMA) { // generate report lines
		
		[html appendFormat:(i%2==0)?formatTableRow:formatTableRow2,array[2],array[0],array[1]];
		
		i++;
	}
	
	[html appendFormat:@"</table>\n"];
	
	[html appendFormat:@"<br/><p><sup>1</sup> results from the NSDateFormatter stringFromDate method with format @\"d MMM y GGG h:mm:ss a ZZ\".  The results differ depending on the time zone set for the NSDateFormatter instance.</p>\n"];

	[html appendFormat:@"<p><sup>2</sup> results from the NSDate description method.</p>"];
	
	[html appendString:noteTZ];
	[html appendString:noteGregorian];
	
	[html appendFormat:@"<p>Created at %@</p>", [NSDate date]];
	
	return html;
	
}

- (NSString *) reportTimeZones {
	
	
	NSArray *timeA = @[
					   @[@"Sydney",@"Australia/Sydney"],
					   @[@"Tokyo",@"Asia/Tokyo"],
					   @[@"Shanghai",@"Asia/Shanghai"],
					   @[@"Paris",@"Europe/Paris"],
					   @[@"London",@"Europe/London"],
					   @[@"GMT",@"GMT"],
					   @[@"New York",@"America/New_York"],
					   @[@"Toronto",@"America/Toronto"],
					   @[@"Chicago",@"America/Chicago"],
					   @[@"Denver",@"America/Denver"],
					   @[@"Phoenix",@"America/Phoenix"],
					   @[@"Los Angeles",@"America/Los_Angeles"],
					   @[@"Juneau",@"America/Juneau"],
					   @[@"Honolulu",@"Pacific/Honolulu"]
					   ];
	
	
	NSArray *dateFormatStringA = @[
					   @"January 4, %ld 12:00:00 PM",
					   @"July 4, %ld 12:00:00 PM",
					   @"December 4, %ld 12:00:00 PM"
					   ];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"h:mm:ss a z"];

	NSDateFormatter *dfYear = [[NSDateFormatter alloc] init];
	[dfYear setDateFormat:@"MMMM d,y h:mm:ss a"];
	[dfYear setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<h2>NSTimeZone Report</h2>"];

	[html appendString:@"<p>This report shows the changes over time for a selection of time zones.  The maintainers of the tz database note that information pre-1970 is not always precise.  The report for each time zone starts in 1846, prior to the introduction of Railway time in the United Kingdom.</>"];

	[html appendString:@"<p>Because we only examine three specific dates, January 4, July 4, and December 4, the dates on which time zone behavior appears to change are not exact.</>"];
	
	
	NSMutableString *formatTableHeader = [NSMutableString stringWithString:@"<table width=100%><thead><tr><th>Year</th><th>January 4</th><th>July 4</th><th>December 4</th></tr>"];
	
	NSString *dateString, *timeJanuary, *timeJuly, *timeDecember, *lastTimeJanuary, *lastTimeJuly, *lastTimeDecember;
	
	NSDate *dateJanuary, *dateJuly, *dateDecember;
	
	for (NSArray *timeZoneA in timeA) {
		
		lastTimeJanuary = @"";
		lastTimeJuly = @"";
		lastTimeDecember = @"";
		
		[df setTimeZone:[NSTimeZone timeZoneWithName:timeZoneA[1]]];
		
		[html appendFormat:@"<h3>%@ (%@)</h3>",timeZoneA[0],timeZoneA[1]];

		[html appendString:formatTableHeader];
		
		int i=0;

		for (long year=1846;year<2015;year++) {
			
			dateString = [NSString stringWithFormat:dateFormatStringA[0],year];
			dateJanuary = [dfYear dateFromString:dateString];
			timeJanuary = [df stringFromDate:dateJanuary];

			dateString = [NSString stringWithFormat:dateFormatStringA[1],year];
			dateJuly = [dfYear dateFromString:dateString];
			timeJuly = [df stringFromDate:dateJuly];

			dateString = [NSString stringWithFormat:dateFormatStringA[2],year];
			dateDecember = [dfYear dateFromString:dateString];
			timeDecember = [df stringFromDate:dateDecember];

			if ( ![timeJanuary isEqualToString:lastTimeJanuary] || ![timeJuly isEqualToString:lastTimeJuly] || ![timeDecember isEqualToString:lastTimeDecember] ) {
				
				lastTimeJanuary = timeJanuary;
				lastTimeJuly = timeJuly;
				lastTimeDecember = timeDecember;
				
				if (i%2==0) [html appendString:[NSString stringWithFormat:@"<tr><td align=right>%ld</td><td align=right>%@</td><td align=right>%@</td><td align=right>%@</td></tr>",year, timeJanuary, timeJuly, timeDecember]];
				else [html appendString:[NSString stringWithFormat:@"<tr><td class=\"even\" align=right>%ld</td><td align=right>%@</td><td align=right>%@</td><td align=right>%@</td></tr>",year, timeJanuary, timeJuly, timeDecember]];
			
			}
			
		}

		[html appendFormat:@"</table>\n"];

	}
	
	[html appendString:noteTZ];

	[html appendFormat:@"<br/><p>Created at %@</p>\n", [NSDate date]];

	return html;
	
}

- (NSString *) reportPrecision {
	
	NSTimeInterval absoluteInterval = CFAbsoluteTimeGetCurrent();
	NSDate *absoluteReferenceDate = CFBridgingRelease(CFDateCreate(NULL, absoluteInterval));
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MMMM d, y h:mm:ss a Z"];
	[df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	NSDate *distantDate, *reboundDate;
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<h2>NSDate Precision</h2>"];
	
	[html appendFormat:@"<p>Starting from the current date and time (%@), we add seconds in powers of 2, then subtract the same number of seconds, examining how much error is introduced by these two operations.  The results will vary depending upon the starting point.</p>",[df stringFromDate:absoluteReferenceDate]];

//	[html appendString:formatTableHeader];

	BOOL flagReport = YES;
	
	double exponent = 0.0f;
	
	[html appendString:@"<p>In theory, NSDate can represent dates with integral number of seconds up to around 2<sup>53</sup> = 9,007,199,254,740,992 = approximately 285,426,782 years based on the double precision representation of time.  If we round the time to the nearest second before processing, that would be true.</p>"];
	
	NSMutableString *formatTableHeader2 = [NSMutableString stringWithString:@"<table width=100%><thead><tr><th>+ Seconds</th><th>Result</th><th>Reverse</th><th>Error</th></tr>"];

	[html appendString:formatTableHeader2];
	
	flagReport = YES;
	
	long long newInterval = absoluteInterval;
	
	absoluteInterval = newInterval;
	
	absoluteReferenceDate = CFBridgingRelease(CFDateCreate(NULL, absoluteInterval));
	
	exponent = 40.0f;
	
	for (int i=40; i<57; i++) {
		
		NSTimeInterval interval = pow(2.0f, exponent);
		
		distantDate = [absoluteReferenceDate dateByAddingTimeInterval:interval];
		
		reboundDate = [distantDate dateByAddingTimeInterval:-interval];
		
		NSString *distantDateString = [distantDate description];
		
		if (distantDateString.length==0) {
			
			long long years = 2001 + ([distantDate timeIntervalSinceReferenceDate]/(365.2425*24*3600));
			
			NSString *yearString = [self.formatterDouble stringFromNumber:[NSNumber numberWithLongLong:years]];
			
			distantDateString = [NSString stringWithFormat:@"approx %@ AD",yearString];
			
		}
		
		
		NSTimeInterval reboundInterval = CFDateGetAbsoluteTime((CFDateRef)reboundDate);
		
		double error = fabs(reboundInterval-absoluteInterval);
		
		if (flagReport) {
			
			NSString *yearString = [self.formatterDouble stringFromNumber:[NSNumber numberWithDouble:interval]];
			
			if (i%2==0) [html appendFormat:@"<tr><td align=right>%@  = 2<sup>%d</sup></td><td align=right>%@</td><td align=right>%@</td><td align=right>%0.5lf</td></tr>",yearString,i,distantDateString, reboundDate,reboundInterval-absoluteInterval];
			else [html appendFormat:@"<tr><td class=\"even\" align=right>%@ = 2<sup>%d</sup></td><td class=\"even\" align=right>%@</td><td class=\"even\" align=right>%@</td><td class=\"even\" align=right>%0.5lf</td></tr>",yearString,i,distantDateString, reboundDate,reboundInterval-absoluteInterval];
			
		}
		
		if (error>1.0f) flagReport = NO;
		
		exponent += 1.0f;
		
	}
	
	
	[html appendFormat:@"</table>\n"];

	
	[html appendString:@"<p><b>Note</b> NSNumberFormatter starts to give incorrect results at 2<sup>50</sup> in the table above for stringFromNumber.</p>"];

	[html appendString:@"<p>Wikipedia discussion of double precision <a href=\"https://en.wikipedia.org/wiki/Double-precision_floating-point_format\">here</a>.</p>"];

	

	
	[html appendFormat:@"<br/><p>Created at %@</p>\n", [NSDate date]];
	
	return html;
	
}

#define ALL_COMPONENTS NSCalendarUnitCalendar|NSCalendarUnitDay|NSCalendarUnitEra|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitNanosecond|NSCalendarUnitQuarter|NSCalendarUnitSecond|NSCalendarUnitTimeZone|NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekOfYear|NSCalendarUnitYear|NSCalendarUnitYearForWeekOfYear

- (NSString *) reportCalendar {
	
	NSTimeInterval absoluteInterval = [self.lastIntervalDate timeIntervalSinceReferenceDate];
	NSDate *absoluteReferenceDate = CFBridgingRelease(CFDateCreate(NULL, absoluteInterval));
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MMMM d, y h:mm:ss a Z"];
	[df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *components = [calendar components:ALL_COMPONENTS fromDate:absoluteReferenceDate];
	
	
	NSDateComponents *newComponents;
	
	
	NSMutableString *formatTableHeader = [NSMutableString stringWithString:@"<table width=100%><thead><tr><th>Year</th><th>Result</th><th>Reverse</th><th>Error</th></tr>"];
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<h2>NSCalendar and NSDateComponents</h2>"];
	
	[html appendString:@"<p>Starting from 5,828,955 AD (slightly below the limit observed for NSDateFormatter output) we construct a date from NSDateComponents, then extract the year back from the resulting date.  We stop in the first year where the extracted year does not match the original year."];
	
	[html appendString:formatTableHeader];
	
	BOOL flagReport = YES;
	
	double exponent = 1.0f;
	
	long newYear = components.year;

	long reboundYear = components.year;

	for (int i=1; i<25; i++) {
		
		newYear = 5828955 + i;
		
		newComponents = [[NSDateComponents alloc]init];
		
		[newComponents setYear:newYear];

		[newComponents setMonth:components.month];
		[newComponents setDay:components.day];
		[newComponents setHour:components.hour];
		[newComponents setMinute:components.minute];
		[newComponents setSecond:components.second];
		[newComponents setEra:components.era];
		[newComponents setTimeZone:components.timeZone];
		
		NSDate *newDate = [calendar dateFromComponents:newComponents];
		
		reboundYear = [calendar components:NSCalendarUnitYear fromDate:newDate].year;
		
		if (flagReport) {
			
			if (i%2==0) [html appendFormat:@"<tr><td align=right>%ld</td><td align=right>%@</td><td align=right>%ld</td><td align=right>%ld</td></tr>",newYear,[newDate luxDescription], reboundYear, newYear-reboundYear];
			else [html appendFormat:@"<tr><td align=right class=\"even\">%ld</td><td align=right class=\"even\">%@</td><td align=right class=\"even\">%ld</td><td align=right class=\"even\">%ld</td></tr>",newYear,[newDate luxDescription], reboundYear, newYear-reboundYear];
			
			if (newYear!=reboundYear) flagReport = NO;
			
		}
		
		exponent += 1.0f;
		
	}
	
	
	[html appendFormat:@"</table>\n"];
	
	[html appendFormat:@"<p>calendar = %@</p>",calendar.calendarIdentifier];
	[html appendFormat:@"<p>NSDateComponents = %@</p>",components];
	
	
	[html appendFormat:@"<br/><p>Created at %@</p>\n", [NSDate date]];
	
	return html;
	
}

#define SOME_COMPONENTS NSCalendarUnitCalendar|NSCalendarUnitDay|NSCalendarUnitEra|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitSecond|NSCalendarUnitTimeZone|NSCalendarUnitWeekday||NSCalendarUnitYear


- (NSString *) reportJulianGregorian {
	
	NSMutableString *html = [[NSMutableString alloc] initWithString:@"<h2>The Julian to Gregorian Transition</h2>"];
	
	[html appendString:@"<p>The <a href=\"https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/DatesAndTimes/Articles/dtHist.html#//apple_ref/doc/uid/TP40010240-SW4\">Date and Time Programming Guide</a> for iOS is outdated(on February 11, 2015).</p>"];
	
	[html appendString:@"<p>The guide states:</p>"];
	 
	[html appendString:@"<p style=\"margin-left:20;margin-right:20;\">NSCalendar models the transition from the Julian to Gregorian calendar in October 1582. During this transition, 10 days were skipped. This means that October 15, 1582 follows October 4, 1582. All of the provided methods for calendrical calculations take this into account, but you may need to account for it when you are creating dates from components. Dates created in the gap are pushed forward by 10 days. For example October 8, 1582 is stored as October 18, 1582.</p>"];
	
	[html appendString:@"<p>The true behavior seems to be a <i>proleptic</i> Gregorian calendar, in which the Gregorian calendar is simply extended backwards in time.  This is a more logical way to operate, leaving the somewhat tricky management of Julian calendar dates to the programmer.</p>"];

	[html appendString:@"<p>We demonstrate the behavior of the calendar prior to October 15, 1582 below.  We use the dateFromComponents for the Gregorian calendar to get the desired date.</p>"];
	
	NSString *dateFormat = @"MMMM d, y GGG HH:mm:ss";
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormat];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"];
	
	dateFormatter.locale = locale;
	
	dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // use GMT
	
	
	NSUInteger year = 1582;  // 140,000 AD
	
	NSString *dateStringFormat = @"October 15, %ld AD 12:00:00";
	
	NSString *dateString = [NSString stringWithFormat:dateStringFormat,(long)year];
	
	NSDate *absoluteReferenceDate = [dateFormatter dateFromString:dateString];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MMMM d, y h:mm:ss a Z"];
	[df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
	
	NSDateComponents *components = [calendar components:ALL_COMPONENTS fromDate:absoluteReferenceDate];
	
	NSDateComponents *newComponents;
	
	NSMutableString *formatTableHeader = [NSMutableString stringWithString:@"<table width=100%><thead><tr><th>Day</th><th>dateFromComponents</th><th>CFDateGetAbsoluteTime</th><th>Difference</th></tr>"];
	
	[html appendString:formatTableHeader];
	
	BOOL flagReport = YES;
		
	long newDay = components.day;
	
	CFAbsoluteTime timeLast = -1;
	
	for (long i=15; i>0; i--) {
		
		newDay = i;
		
		newComponents = [[NSDateComponents alloc]init];
		
		[newComponents setCalendar:components.calendar];
		[newComponents setYear:components.year];
		
		[newComponents setMonth:components.month];
		[newComponents setDay:newDay];
		[newComponents setHour:components.hour];
		[newComponents setMinute:components.minute];
		[newComponents setSecond:components.second];
		[newComponents setEra:components.era];
		[newComponents setTimeZone:components.timeZone];
		
		NSDate *newDate = [calendar dateFromComponents:newComponents];
		
		CFAbsoluteTime time = CFDateGetAbsoluteTime((CFDateRef)newDate);
		
		NSString *newDateString = [self.formatterADBC stringFromDate:newDate];

		if (flagReport) {
			
			if (i%2==0) [html appendFormat:@"<tr><td align=right>%ld</td><td align=right>%@</td><td align=right>%.0lf</td><td align=right>%.0lf</td></tr>",i,newDateString, time,timeLast - time];
			else [html appendFormat:@"<tr><td align=right class=\"even\">%ld</td><td align=right class=\"even\">%@</td><td align=right class=\"even\">%.0lf</td><td align=right class=\"even\">%.0lf</td></tr>",i,newDateString, time,timeLast - time];
			
			
		}
		
		timeLast = time;
		
	}
	
	
	[html appendFormat:@"</table>\n"];
	
	[html appendFormat:@"<p>calendar = %@</p>",calendar.calendarIdentifier];
	[html appendFormat:@"<p>NSDateComponents = %@</p>",components];
	
	
	[html appendFormat:@"<br/><p>Created at %@</p>\n", [NSDate date]];
	
	return html;
	
}

- (NSString *) reportParseBC {
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<h2>Parse.com and NSDate</h3>"];

	[html appendString:@"<p>Parse.com is our very favorite back-end service for iOS.  It's well designed, efficient, and inexpensive.  You can easily create objects with columns of type \"Date\" which provide transparent support for NSDate objects.  But there's a catch: Parse won't store BC dates correctly, and while it will store dates before 100 AD correctly, it won't display them correctly in the Core data browser.</p>"];

	[html appendString:@"<p>We've filed a <a href=\"https://developers.facebook.com/bugs/1006270306055313/\">bug report</a> with Parse, so they will probably fix this eventually.</p>"];

	[html appendString:@"<p><b>Work-around</b> - instead of persisting an NSDate object, use the timeIntervalSinceReferenceDate instance method to obtain a double and save that as a number in Parse.  Upon retrieving that number, convert it back to an NSDate by using the dateWithTimeIntervalSinceReferenceDate class method.</p>"];


	return html;
	
}

- (NSString *) reportNumberFormatter {
	
	NSString *formatTableHeader = [NSMutableString stringWithString:@"<table width=100%><thead><tr><th>Power of 2</th><th>C format %lf</th><th>NSNumberFormatter</th><th>Error</th></tr>"];
	
	NSMutableString *html = [NSMutableString stringWithString:@""];
	
	[html appendString:@"<h2>NSNumberFormatter Precision</h2>"];
	
	[html appendString:@"<p><b>Note</b> NSNumberFormatter starts to give incorrect results at 2<sup>50</sup> in the table below for stringFromNumber when powers of 2 are represented as doubles.  NSNumberFormatter works correctly when the powers of 2 are represented as long long.</p>"];
	

	
	BOOL flagReport = YES;
	
	double exponent;
	
	[html appendString:formatTableHeader];
	
	flagReport = YES;
	
	double powerOf2 = 0.0f;

	long long powerOf2Long = 0LL;

	NSNumber *numberLong, *numberDouble;
	
	for (int i=40; i<57; i++) {
		
		powerOf2 = pow(2.0f, i*1.0f);
		
		powerOf2Long = powerOf2;
		
		numberLong = [NSNumber numberWithLongLong:powerOf2Long];

		numberDouble = [NSNumber numberWithDouble:powerOf2];
		
		NSString *p2inC = [NSString stringWithFormat:@"%.0lf",powerOf2];
		
		NSString *p2inNSF = [self.formatterDouble stringFromNumber:numberDouble];
		
		double reboundInterval = [[self.formatterDouble numberFromString:p2inNSF] longLongValue];
		
		double  error = fabs(reboundInterval-powerOf2);
		
		if (flagReport) {
			
			//			double years = pow(2.0f, exponent)*yearInSeconds;

			
			if (i%2==0) [html appendFormat:@"<tr><td align=right>2<sup>%d</sup></td><td align=right>%@</td><td align=right>%@</td><td align=right>%0.5lf</td></tr>",i,p2inC, p2inNSF,error];
			else [html appendFormat:@"<tr><td class=\"even\" align=right>2<sup>%d</sup></td><td class=\"even\" align=right>%@</td><td class=\"even\" align=right>%@</td><td class=\"even\" align=right>%0.5lf</td></tr>",i,p2inC, p2inNSF,error];
			
		}
		
		if (error>1.0f) flagReport = NO;
		
		exponent += 1.0f;
		
	}
	
	
	[html appendFormat:@"</table>\n"];
	
	
	[html appendFormat:@"<br/><p>Created at %@</p>\n", [NSDate date]];
	
	return html;
}

- (NSString *) reportBlogPost {
	
	NSMutableString *html = [[NSMutableString alloc] initWithString:@"<p>Read the blog post at <a href=\"http://359north.com/blog/2015/02/08/the-limits-of-nsdate-and-friends/\">359north.com</a> to get even more discussion of all these limits.</p>"];
	
	[html appendString:@"<p>More on calendars <a href=\"http://www.tondering.dk/claus/calendar.html\"> here</a>.</p>"];
	
	[html appendString:@"<p>Info on the tz database <a href=\"http://www.iana.org/time-zones\"> here</a>.</p>"];

	[html appendString:@"<p>Interesting note on tz database <a href=\"https://www.eff.org/press/releases/eff-wins-protection-time-zone-database\"> here</a>.</p>"];

	[html appendString:@"<p>Info on British time <a href=\"http://www.polyomino.org.uk/british-time/\"> here</a>.</p>"];
	
	[html appendString:@"<p>iOS Date and Time Programming Guide <a href=\"https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DatesAndTimes/DatesAndTimes.html\"> here</a>.</p>"];
	
	return html;
	

}

#pragma mark - date checkers

- (void) checkMaxDatesViaFormatter {
	
	
	
}

#pragma mark - date generators

- (void) findMaxDatesViaFormatter2 {
	
	// http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
	
	//  we take advantage of stringFromDate working longer than dateFromString.
	
	NSString *dateFormat = @"MMMM d, y GGG hh:mm:ss a Z";
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormat];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"];
	
	dateFormatter.locale = locale;
	
	dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // use GMT
	
	CFAbsoluteTime absoluteReferenceTime = 0;
	NSDate *absoluteReferenceDate = CFBridgingRelease(CFDateCreate(NULL,absoluteReferenceTime));
	
	NSTimeInterval timeIncrement = powf(2.0f, 41.0f);  // make sure it's divisable by two all the way
	
	NSString *dateString = [dateFormatter stringFromDate:absoluteReferenceDate];
	
	NSString *lastdateString = [dateString copy];
	
	NSDate *date = [absoluteReferenceDate copy];
	
	NSDate *newDate;
	
	CFAbsoluteTime timeCounter = 0;

	CFAbsoluteTime newTimeCounter = 0;
	
	NSUInteger steps = 0;
	
	
	while (timeIncrement >= 1) {
		
		steps++;
		
		newTimeCounter = timeCounter + timeIncrement;
		
		newDate = CFBridgingRelease(CFDateCreate(NULL,newTimeCounter));
		
		dateString = [dateFormatter stringFromDate:newDate];

		newDate = [dateFormatter dateFromString:dateString];
		
		dateString = [dateFormatter stringFromDate:newDate];
		
		if (dateString.length > 0) {
			
			timeCounter	= newTimeCounter;
			
			date = [newDate copy];
			
			lastdateString = [dateString copy];
			
			
		}
		else {
			
			timeIncrement *= 0.5f;

		}
		
		
		
	}
	
	self.lastFormattedInputDate = date;

	
	timeIncrement = powf(2.0f, 41.0f);  // make sure it's divisable by two all the way
	
	timeCounter = 0;
	
	newTimeCounter = 0;
	
	steps = 0;
	
	while (timeIncrement >= 1) {
		
		steps++;
		
		newTimeCounter = timeCounter - timeIncrement;
		
		newDate = CFBridgingRelease(CFDateCreate(NULL,newTimeCounter));
		
		dateString = [dateFormatter stringFromDate:newDate];
		
		newDate = [dateFormatter dateFromString:dateString];
		
		dateString = [dateFormatter stringFromDate:newDate];
		
		if (dateString.length > 0) {
			
			timeCounter	= newTimeCounter;
			
			date = [newDate copy];
			
			lastdateString = [dateString copy];
			
			
		}
		else {
			
			timeIncrement *= 0.5f;
			
		}
		
		
		
	}
	
	self.lastFormattedInputDateBC = date;


}

- (void) findMaxDatesViaIntervals {
	
	// http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
	
	// Newton's method
	
	NSString *dateFormat = @"MMMM d, y GGG HH:mm:ss";
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormat];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"];
	
	dateFormatter.locale = locale;
	
	dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0]; // use GMT
	
	
	NSUInteger year = 140000;  // 140,000 AD
	
	NSString *dateStringFormat = @"December 31, %ld AD 23:59:59";
	
	NSString *dateString = [NSString stringWithFormat:dateStringFormat,(long)year];

	NSDate *date = [dateFormatter dateFromString:dateString];
	
	NSDate *newDate;
	
	NSTimeInterval timeInterval = powf(2.0f, 47.0f);
	
	while (timeInterval>=1) {
		
		newDate = [date dateByAddingTimeInterval:timeInterval];
		
		dateString = [dateFormatter	stringFromDate:newDate];
		
		if (dateString.length>0) {
			
			date = newDate;
			
			
		}
		else {
			timeInterval /= 2.0f;
		}
		
		
	}
	
	self.lastIntervalDate = [date copy];
	
	
	year = 139000;  // 140,000 BC
	
	dateStringFormat = @"December 31, %ld BC 23:59:59";
	
	dateString = [NSString stringWithFormat:dateStringFormat,(long)year];
	
	date = [dateFormatter dateFromString:dateString];
	
	timeInterval = powf(2.0f, 47.0f);
	
	while (timeInterval>=1) {
		
		newDate = [date dateByAddingTimeInterval:-timeInterval];
		
		dateString = [dateFormatter	stringFromDate:newDate];
		
		if (dateString.length>0) {
			
			date = newDate;
			
		}
		else {
			timeInterval /= 2.0f;
		}
		
		
	}
	
	self.lastIntervalDateBC = [date copy];
	
}



#pragma mark - html helpers for reports

- (NSString *) meta {
	
	return @"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\
	<meta http-equiv=\"Content-Language\" content=\"en-US\" />\
	<meta charset=\"utf-8\" />";
}

- (NSString *) css {
	
	return @"<style type=\"text/css\">\
	body { margin:0; padding:0; font-family:\"Helvetica Neue\"; font-size:10pt; color:black; background-color:white;}\
	h1 {color:#09F; font-size: 150%;margin:0;}\
	h2 {color:#09F;font-size: 125%;}\
	h3 {color:#09F;font-size: 105%;}\
	table {border: 1px solid #555;margin: 10px 0; padding:0px; border-collapse: collapse;}\
	td {font-size:10pt; padding:0px;}\
	td, td.even {border: 1px solid #999; padding:2px;}\
	td.even {background-color:#eee;}\
	hr {color:blue;}\
	p {margin-left:0px;margin-top:0px;font-size:10pt; }\
	thead th { font-size:10pt; border:1px solid #999; font-weight:normal; color:black; background-color:#aaddff; padding: 1px 4px 2px 1px;}\
	</style>";
 
	
}

@end