#import <Cordova/CDVPlugin.h>
#import <BaiduTraceSDK/BaiduTraceSDK.h>
#import <BaiduTraceSDK/BTKAction.h>
#import <BaiduTraceSDK/BTKTrackAction.h>
#import <BaiduTraceSDK/BTKServiceOption.h>

@interface wwareBaiduYY : CDVPlugin< BTKTraceDelegate, BTKTrackDelegate, BTKEntityDelegate> {
        @protected
        BTKServiceOption * sop;
        NSMutableDictionary* _customAttr;
        NSString* startTraceCallbackId;
        CDVPluginResult* startTraceResult;
        NSString* stopTraceCallbackId;
        CDVPluginResult* stopTraceResult;
        NSString* queryLocationCallbackId;
        NSString* startGatherCallbackId;
        NSString* stopGatherCallbackId;
        NSString* queryHistoryCallbackId;
        NSString* queryDistanceCallbackId;
        NSString* setIntervalCallbackId;
        NSString* addEntityCallbackId;
}

@property (nonatomic,strong) NSString* _AK;

@property (nonatomic,strong) NSString* _MCode;

@property (nonatomic) NSUInteger serviceId;

- (void)startTrace:(CDVInvokedUrlCommand*)command;
- (void)stopTrace:(CDVInvokedUrlCommand*)command;
- (void)setInterval:(CDVInvokedUrlCommand*)command;
- (void)setLocationMode:(CDVInvokedUrlCommand*)command;
- (void)startGather:(CDVInvokedUrlCommand*)command;
- (void)stopGather:(CDVInvokedUrlCommand*)command;
- (void)queryDistance:(CDVInvokedUrlCommand*)command;
- (void)queryHistoryTrack:(CDVInvokedUrlCommand*)command;
- (void)queryLocation:(CDVInvokedUrlCommand*)command;
- (void)addEntity:(CDVInvokedUrlCommand*)command;
@end
