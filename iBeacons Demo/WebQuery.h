//
//  WebQuery.h
//  iBeacons Demo
//
//  Created by Yi-Chin Wu on 1/18/14.
//  Copyright (c) 2014 Mobient. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebQuery : NSObject

@property NSNumber *user;
@property NSString *firstname;
@property NSString *lastname;
@property NSArray *keyowords;
-(void)WebQuery:(NSNumber*)user;
@end
