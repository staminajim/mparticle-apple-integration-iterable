//
//  MPKitIterable.m
//
//  Copyright 2016 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitIterable.h"

@implementation MPKitIterable

@synthesize kitApi = _kitApi;

+ (NSNumber *)kitCode {
    return @1003;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Iterable" className:@"MPKitIterable"];
    [MParticle registerExtension:kitRegister];
}

#pragma mark - MPKitInstanceProtocol methods

#pragma mark Kit instance and lifecycle
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    
    _configuration = configuration;
    
    [self start];
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (void)start {
    static dispatch_once_t kitPredicate;
    
    dispatch_once(&kitPredicate, ^{
        
        _started = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

#pragma mark Application
- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    NSURL *clickedURL = userActivity.webpageURL;
    
    ITEActionBlock callbackBlock = ^(NSString* destinationURL) {
        NSDictionary *getAndTrackParams = nil;
        NSString *clickedUrlString = clickedURL.absoluteString;
        if (!destinationURL || [clickedUrlString isEqualToString:destinationURL]) {
            getAndTrackParams = [[NSDictionary alloc] initWithObjectsAndKeys: clickedUrlString, IterableClickedURLKey, nil];
        } else {
            getAndTrackParams = [[NSDictionary alloc] initWithObjectsAndKeys: destinationURL, IterableDestinationURLKey, clickedUrlString, IterableClickedURLKey, nil];
        }

        MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
        attributionResult.linkInfo = getAndTrackParams;

        [_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
    };
    [IterableAPI getAndTrackDeeplink:clickedURL callbackBlock:callbackBlock];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[MPKitIterable kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

@end
