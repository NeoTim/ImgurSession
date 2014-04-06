//
//  IMGAlbumRequest.m
//  ImgurSession
//
//  Created by Geoff MacDonald on 2014-03-15.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGAlbumRequest.h"
#import "IMGAlbum.h"
#import "IMGImage.h"
#import "IMGSession.h"

@implementation IMGAlbumRequest

#pragma mark - Path Component for requests

+(NSString*)pathComponent{
    return @"album";
}

#pragma mark - Load

+ (void)albumWithID:(NSString *)albumID success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID];
    
    [[IMGSession sharedInstance] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError *JSONError = nil;
        IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && album) {
            if(success)
                success(album);
        }
        else {
            
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

#pragma mark - Create

+ (void)createAlbumWithTitle:(NSString *)title imageIDs:(NSArray *)imageIDs success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    
    [self createAlbumWithTitle:title description:nil imageIDs:imageIDs privacy:IMGAlbumPublic layout:IMGDefaultLayout cover:nil success:success failure:failure];
}

+ (void)createAlbumWithTitle:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(NSString *)coverID success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * params = [self updateAlbumParameters:title description:description imageIDs:imageIDs privacy:privacy layout:layout cover:coverID];
    
    [[IMGSession sharedInstance] POST:[self path] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *JSONError = nil;
        IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && album) {
            if(success)
                success(album);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
}

#pragma mark - Update

+ (void)updateAlbumWithID:(NSString*)albumID imageIDs:(NSArray *)imageIDs success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    
    [self updateAlbumWithID:albumID title:nil description:nil imageIDs:imageIDs privacy:0 layout:0 cover:nil success:success failure:failure];
}

+ (void)updateAlbumWithID:(NSString*)albumID title:(NSString *)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(NSString *)coverID success:(void (^)(IMGAlbum *))success failure:(void (^)(NSError *))failure{
    
    //path is different from create album just with the ID
    NSString * path = [self pathWithId:albumID];
    
    NSDictionary * params = [self updateAlbumParameters:title description:description imageIDs:imageIDs privacy:privacy layout:layout cover:coverID];
    
    [[IMGSession sharedInstance] POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *JSONError = nil;
        IMGAlbum *album = [[IMGAlbum alloc] initWithJSONObject:responseObject error:&JSONError];
        
        if(!JSONError && album) {
            if(success)
                success(album);
        }
        else {
            if(failure)
                failure(JSONError);
        }
        
    } failure:failure];
    
}

+(NSDictionary*)updateAlbumParameters:(NSString*)title description:(NSString *)description imageIDs:(NSArray *)imageIDs privacy:(IMGAlbumPrivacy)privacy layout:(IMGAlbumLayout)layout cover:(NSString *)coverID{
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    if(title)
        [parameters setObject:title forKey:@"title"];
    if(description)
        [parameters setObject:description forKey:@"description"];
    if(coverID)
        [parameters setObject:coverID forKey:@"cover"];
    
    if(imageIDs){
        
        NSString *idsParameter = @"";
        for (IMGImage *imageID in imageIDs) {
            if([imageID isKindOfClass:[NSString class]])
                idsParameter = [NSString stringWithFormat:@"%@%@,", idsParameter, imageID];
            else
                @throw [NSException exceptionWithName:@"ImgurObjectTypeException"
                                               reason:@"Objects contained in this array should be of type NSString"
                                             userInfo:[NSDictionary dictionaryWithObject:imageIDs forKey:@"images"]];
        }
        
        // Removing the last comma, which is useless
        [parameters setObject:[idsParameter substringToIndex:[idsParameter length] - 1] forKey:@"ids"];
    }
    
    if(privacy){
        NSString *parameterValue = [IMGAlbum strForPrivacy:privacy];
        
        if(parameterValue)
            [parameters setObject:parameterValue forKey:@"privacy"];
    }
    if (layout){
        NSString *parameterValue = [IMGAlbum strForLayout:layout];
        
        if(parameterValue)
            [parameters setObject:parameterValue forKey:@"layout"];
    }
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

#pragma mark - Delete

+ (void)deleteAlbumWithID:(NSString *)albumID success:(void (^)())success failure:(void (^)(NSError *))failure{
    NSString *path = [self pathWithId:albumID];
    
    [[IMGSession sharedInstance] DELETE:path parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}

#pragma mark - Favourite

+(void)favouriteAlbumWithID:(NSString*)albumID  success:(void (^)())success failure:(void (^)(NSError *error))failure{
    NSString *path = [self pathWithId:albumID withOption:@"favorite"];
    
    [[IMGSession sharedInstance] POST:path parameters:Nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if(success)
            success();
    } failure:failure];
}


@end
