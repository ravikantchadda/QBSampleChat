//
//  QMMessagesMemoryStorage.m
//  QMServices
//
//  Created by Andrey on 28.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMMessagesMemoryStorage.h"

@interface QMMessagesMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *datasources;

@end

@implementation QMMessagesMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.datasources = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Setters

- (void)addMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    
    [datasource addObject:message];
    [self sortMessagesForDialogID:dialogID];
}

- (void)addMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    
    for (QBChatMessage* message in messages) {
        NSUInteger index = [datasource indexOfObject:message];
        if (index != NSNotFound) {
            [datasource replaceObjectAtIndex:index withObject:message];
        } else {
            [datasource addObject:message];
        }
    }
    
    [self sortMessagesForDialogID:dialogID];
}

- (void)updateMessage:(QBChatMessage *)message
{
    NSAssert(message.dialogID, @"Message must have a dialog ID.");
    NSMutableOrderedSet* messages = [self dataSourceWithDialogID:message.dialogID];
    NSUInteger indexToReplace = [messages indexOfObjectPassingTest:^BOOL(QBChatMessage* obj, NSUInteger idx, BOOL *stop) {
        return [obj.ID isEqualToString:message.ID];
    }];
    
    if (indexToReplace != NSNotFound) {
        [messages removeObjectAtIndex:indexToReplace];
    }
    
    [messages addObject:message];
    
    [self sortMessagesForDialogID:message.dialogID];
}

- (QBChatMessage *)lastMessageFromDialogID:(NSString *)dialogID
{
    NSArray* messages = [self messagesWithDialogID:dialogID];
    return [messages lastObject];
}

#pragma mark - replace

- (void)replaceMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    [datasource removeAllObjects];
    [datasource addObjectsFromArray:messages];
}

#pragma mark - Getters

- (NSMutableOrderedSet *)dataSourceWithDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *messages = self.datasources[dialogID];
    
    if (!messages) {
        messages = [NSMutableOrderedSet orderedSet];
        self.datasources[dialogID] = messages;
    }
    
    return messages;
}

- (NSArray *)messagesWithDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *messages = self.datasources[dialogID];
    
    return [messages array];
}

- (void)deleteMessagesWithDialogID:(NSString *)dialogID {
	
	[self.datasources removeObjectForKey:dialogID];
}

- (BOOL)isEmptyForDialogID:(NSString *)dialogID {
    
    NSArray *messages = self.datasources[dialogID];
    
    return !messages || [messages count] == 0;
}

- (QBChatMessage *)oldestMessageForDialogID:(NSString *)dialogID {
    
    NSArray *messages = [self messagesWithDialogID:dialogID];
    
    return [messages firstObject];
}

- (void)sortMessagesForDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    
    [datasource sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES]]];
}

- (QBChatMessage *)messageWithID:(NSString *)messageID fromDialogID:(NSString *)dialogID;
{
    NSParameterAssert(messageID != nil);
    NSParameterAssert(dialogID != nil);
    
    NSArray* messages = [self messagesWithDialogID:dialogID];
    
    for (QBChatMessage* message in messages) {
        if ([message.ID isEqualToString:messageID]) {
            return message;
        }
    }
    
    return nil;
}

#pragma mark - QMMemeoryStorageProtocol

- (void)free {
    
    [self.datasources removeAllObjects];
}

@end
