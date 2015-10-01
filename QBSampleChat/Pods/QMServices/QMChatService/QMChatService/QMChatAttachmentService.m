//
//  QMChatAttachmentService.m
//  QMServices
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatAttachmentService.h"
#import "QMChatService.h"
#import "QBChatMessage+QMCustomParameters.h"
#import "QMChatService+AttachmentService.h"

static NSString* attachmentCacheDir() {
    
    static NSString *attachmentCacheDirString;
    
    if (!attachmentCacheDirString) {
        
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        attachmentCacheDirString = [cacheDir stringByAppendingPathComponent:@"Attachment"];
        
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            if (![[NSFileManager defaultManager] fileExistsAtPath:attachmentCacheDirString]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:attachmentCacheDirString withIntermediateDirectories:NO attributes:nil error:nil];
            }
        });
    }

    return attachmentCacheDirString;
}

static NSString* attachmentPath(QBChatAttachment *attachment) {
    
    return [attachmentCacheDir() stringByAppendingPathComponent:[NSString stringWithFormat:@"attachment-%@", attachment.ID]];
}

@implementation QMChatAttachmentService


- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog withChatService:(QMChatService *)chatService withAttachedImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    
    [chatService.messagesMemoryStorage addMessage:message forDialogID:dialog.ID];
    
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading forMessage:message];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [QBRequest TUploadFile:imageData fileName:@"attachment" contentType:@"image/png" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
       
        QBChatAttachment *attachment = [QBChatAttachment new];
        attachment.type = @"image";
        attachment.ID = [@(blob.ID) stringValue];
        attachment.url = [blob publicUrl];
        
        message.attachments = @[attachment];
        message.text = @"Attachment image";
        
        [self saveImageData:imageData chatAttachment:attachment error:nil];
        
        [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:message];
        
        [chatService sendMessage:message type:QMMessageTypeText toDialog:dialog save:YES saveToStorage:YES completion:completion];
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        
    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"________________%@",response.debugDescription);
        
        [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:message];
        
        if (completion) completion(response.error.error);
    }];
}


- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog withChatService:(QMChatService *)chatService withAttachedVideoData:(NSData *)videodata withAttachedImage:(UIImage *)image completion:(void(^)(NSError *error))completion{

    [chatService.messagesMemoryStorage addMessage:message forDialogID:dialog.ID];
    
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading forMessage:message];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [QBRequest TUploadFile:videodata fileName:@"attachment" contentType:@"video/mp4" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
        
        QBChatAttachment *attachment = [QBChatAttachment new];
        attachment.type = @"video";
        attachment.ID = [@(blob.ID) stringValue];
        attachment.url = [blob publicUrl];
        
        message.attachments = @[attachment];
        message.text = @"Attachment video";
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *imageName = [NSString stringWithFormat:@"playvideo-%@.mp4",attachment.ID];
        NSString *imagePath = [basePath stringByAppendingPathComponent:imageName];
        [videodata writeToFile:imagePath atomically:YES];
        
        
               
        [self saveImageData:imageData chatAttachment:attachment error:nil];
        
        [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded forMessage:message];
        
        [chatService sendMessage:message type:QMMessageTypeText toDialog:dialog save:YES saveToStorage:YES completion:completion];
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        
    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"________________%@",response.debugDescription);
        
        [self changeMessageAttachmentStatus:QMMessageAttachmentStatusNotLoaded forMessage:message];
        
        if (completion) completion(response.error.error);
    }];

}


- (void)getImageForChatAttachment:(QBChatAttachment *)attachment completion:(void (^)(NSError *error, UIImage *image))completion {
    
    NSString *path = attachmentPath(attachment);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(error, image);
            });
        });

        return;
    }
    
    [QBRequest downloadFileWithID:attachment.ID.integerValue successBlock:^(QBResponse *response, NSData *fileData) {
        
        UIImage *image = [UIImage imageWithData:fileData];
        NSError *error;
        
        [self saveImageData:fileData chatAttachment:attachment error:&error];
        
        if (completion) completion(error, image);
        
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        
        if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeLoadingProgress:forChatAttachment:)]) {
            [self.delegate chatAttachmentService:self didChangeLoadingProgress:status.percentOfCompletion forChatAttachment:attachment];
        }
        
    } errorBlock:^(QBResponse *response) {
        
       if (completion) completion(response.error.error, nil);
        
    }];
}

- (void)saveImageData:(NSData *)imageData chatAttachment:(QBChatAttachment *)attachment error:(NSError **)errorPtr {
    
    NSString *path = attachmentPath(attachment);
    
    [imageData writeToFile:path options:NSDataWritingAtomic error:errorPtr];
}

- (void)changeMessageAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message {
    
    message.attachmentStatus = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(chatAttachmentService:didChangeAttachmentStatus:forMessage:)]) {
            [self.delegate chatAttachmentService:self didChangeAttachmentStatus:status forMessage:message];
        }
        
    });
}



@end
