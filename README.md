## Limits on NSDate and friends ##

Instances of NSDate are simple wrappers around a double precision floating point value that represents the number of seconds before or after the reference date -- the first instant of 1 January 2001, GMT.

NSDate has a lot of friends: including NSCalendar, NSDateComponents, NSDateFormatter, NSLocale and NSTimeZone. (The corresponding Core Foundation entities are CFDate, CFCalendar, CFDateFormatter, CFLocale and CFTimeZone)

For most practical purposes, instances of these classes behave nicely.  (roughly a range of 289,000 years around 2001)

Beyond this range of dates, however, some unexpected behaviors appear.

This project builds a universal iOS app that illustrates these behaviors of NSDate and its friends under stress.  Apple may elect to fix some of these behaviors in the future.

In the course of closely examining NSDate and friends, we also took a look at historical handling of pre-1970 time zones by NSTimeZone, NSNumberFormatter, and the handling of NSDate objects within the Parse.com backend-as-a-service.

For a detailed discussion of NSDate and its friends, see our blog post at [359north.com](http://359north.com/blog/2015/02/08/the-limits-of-nsdate-and-friends/)
