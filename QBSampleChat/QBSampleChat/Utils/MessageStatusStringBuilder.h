//
//  MessageStatusStringBuilder.h
//  QBSampleChat
//
//  Created by ravi kant on 9/23/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageStatusStringBuilder : NSObject
/**
 *  Responsible for building string for message status.
 */
- (NSString *)statusFromMessage:(QBChatMessage *)message;


@end
