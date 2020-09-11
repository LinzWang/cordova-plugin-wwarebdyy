#import "wwareBaiduYY.h"
#import <Cordova/CDVPlugin.h>

@implementation wwareBaiduYY
/*
官方demo使用了dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
stack overflow给出了[[NSOperationQueue mainQueue] addOperationWithBlock:^{}];
使用两种方法在采集时仍然无法调用回调
*/
- (void)pluginInitialize {
        self._AK = [self.commandDelegate.settings objectForKey:[@"AK" lowercaseString]];
        self._MCode = [self.commandDelegate.settings objectForKey:[@"MCODE" lowercaseString]];
        self.serviceId = [[self.commandDelegate.settings objectForKey:[@"SERVICEID" lowercaseString]] intValue];
        BTKServiceOption* sop = [[BTKServiceOption alloc] initWithAK:self._AK mcode:self._MCode serviceID:self.serviceId keepAlive:FALSE];
        [[BTKAction sharedInstance] initInfo:sop];
        //NSLog(@"_AK: %@, _Mcode %@", self._AK, self._MCode);
}

- (void)startTrace:(CDVInvokedUrlCommand*)command
{
        startTraceCallbackId = command.callbackId;

        NSMutableDictionary *values = [command.arguments objectAtIndex:0];
        NSString* entityName = [values objectForKey:@"entityName"];

        BTKStartServiceOption* ssop = [[BTKStartServiceOption alloc] initWithEntityName:entityName];
        [[BTKAction sharedInstance] startService:ssop delegate:self];

}

- (void)stopTrace:(CDVInvokedUrlCommand*)command
{
        stopTraceCallbackId = command.callbackId;
        [[BTKAction sharedInstance] stopService:self];

}

- (void)startGather:(CDVInvokedUrlCommand*)command
{
        startGatherCallbackId = command.callbackId;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[BTKAction sharedInstance] startGather:self];
        });

        CDVPluginResult* pluginResult;
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:0];
        //无法回调，调用后即返回
        [result setObject:@(true) forKey:@"success"];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];


}

- (void)stopGather:(CDVInvokedUrlCommand*)command
{
        stopGatherCallbackId = command.callbackId;
        [[BTKAction sharedInstance] stopGather:self];

}

- (void)setInterval:(CDVInvokedUrlCommand*)command
{
        setIntervalCallbackId = command.callbackId;
        NSMutableDictionary *values = [command.arguments objectAtIndex:0];
        NSLog(@"setInterval values: %@", values);
        NSUInteger gatherInterval = [[values objectForKey:@"gatherInterval"] intValue];
        NSUInteger packInterval = [[values objectForKey:@"packInterval"] intValue];

        [[BTKAction sharedInstance] changeGatherAndPackIntervals:gatherInterval packInterval:packInterval delegate:self];
}



- (void)setLocationMode:(CDVInvokedUrlCommand*)command
{
  /*
     desiredAccuracy:
     kCLLocationAccuracyBestForNavigation // 最适合导航
     kCLLocationAccuracyBest; // 最好的
     kCLLocationAccuracyNearestTenMeters; // 10m
     kCLLocationAccuracyHundredMeters; // 100m
     kCLLocationAccuracyKilometer; // 1000m
     kCLLocationAccuracyThreeKilometers; // 3000m
     distanceFilter:
     数字
     kCLDistanceFilterNone
     activityType
     CLActivityTypeAutomotiveNavigation
   */
    //[[BTKAction sharedInstance]setLocationAttributeWithActivityType]
}

-(void)addEntity:(CDVInvokedUrlCommand*)command
{
        addEntityCallbackId = command.callbackId;
        NSMutableDictionary *values = [command.arguments objectAtIndex:0];
        NSString* entityName = [values objectForKey:@"entityName"];
        NSString* entityDesc = [values objectForKey:@"entityDesc"];
        //NSUInteger serviceId = [[values objectForKey:@"serviceId"] intValue];
        BTKAddEntityRequest* request = [[BTKAddEntityRequest alloc] initWithEntityName:entityName entityDesc:entityDesc columnKey:nil serviceID:self.serviceId tag:1];
        [[BTKEntityAction sharedInstance]addEntityWith:request delegate:self];
}

- (void)queryHistoryTrack:(CDVInvokedUrlCommand*)command
{
        queryHistoryCallbackId = command.callbackId;
        NSMutableDictionary* values = [command.arguments objectAtIndex:0];
        NSLog(@"queryHISTORY %@",values);
        //NSUInteger serviceId = [[values objectForKey:@"serviceId"] intValue];
        NSUInteger startTime = [[values objectForKey:@"startTime"] intValue];
        NSUInteger endTime = [[values objectForKey:@"endTime"] intValue];
        NSString* entityName = [values objectForKey:@"entityName"];
        BOOL isProcessed = [[values objectForKey:@"isProcessed"] boolValue];
        BOOL denoise = [[values objectForKey:@"denoise"] boolValue];
        BOOL mapMatch = [[values objectForKey:@"mapMatch"] boolValue];
        BOOL vacuate = [[values objectForKey:@"vacuate"] boolValue];
        NSInteger radiusThreshold = [[values objectForKey:@"radiusThreshold"] intValue];
        NSString* transportName = [values objectForKey:@"transportMode"];
        BOOL supplement = [[values objectForKey:@"supplement"] boolValue];
        NSInteger pageIndex = [[values objectForKey:@"pageIndex"] intValue];
        NSInteger pageSize = [[values objectForKey:@"pageSize"] intValue];
        if(pageIndex < 1) {
                pageIndex = 1;
        }
        if(pageSize < 5000) {
                pageSize = 5000;
        }

        BTKTrackProcessOptionTransportMode transportMode;

        if([transportName  isEqual: @"walk"]) {
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
        }else if([transportName  isEqual: @"ride"]) {
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_RIDING;
        }else{
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING;
        }

        BTKTrackProcessOptionSupplementMode supplementMode;

        if(supplement) {
                supplementMode =  BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
        }else{
                supplementMode = BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT;
        }

        BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
        option.denoise = denoise;
        option.mapMatch = mapMatch;
        option.radiusThreshold = radiusThreshold;
        option.transportMode = transportMode;
        option.denoise = denoise;
        option.vacuate = vacuate;
        // 发起查询请求
        BTKQueryHistoryTrackRequest *request = [[BTKQueryHistoryTrackRequest alloc] initWithEntityName:entityName startTime:startTime endTime:endTime isProcessed:isProcessed processOption:option supplementMode:supplementMode outputCoordType:BTK_COORDTYPE_BD09LL sortType:BTK_TRACK_SORT_TYPE_DESC pageIndex:pageIndex pageSize:pageSize serviceID:self.serviceId tag:10];
        [[BTKTrackAction sharedInstance] queryHistoryTrackWith:request delegate:self];

}

- (void)queryDistance:(CDVInvokedUrlCommand*)command
{
        queryDistanceCallbackId = command.callbackId;
        NSMutableDictionary* values = [command.arguments objectAtIndex:0];
        //NSUInteger serviceId = [[values objectForKey:@"serviceId"] intValue];
        NSUInteger startTime = [[values objectForKey:@"startTime"] intValue];
        NSUInteger endTime = [[values objectForKey:@"endTime"] intValue];
        NSString* entityName = [values objectForKey:@"entityName"];
        BOOL denoise = [[values objectForKey:@"denoise"] boolValue];
        BOOL mapMatch = [[values objectForKey:@"mapMatch"] boolValue];
        NSInteger radiusThreshold = [[values objectForKey:@"radiusThreshold"] intValue];
        NSString* transportName = [values objectForKey:@"transportMode"];
        BOOL supplement = [[values objectForKey:@"supplement"] boolValue];
        BOOL isProcessed = [[values objectForKey:@"isProcessed"] boolValue];
        BTKTrackProcessOptionTransportMode transportMode;

        if([transportName  isEqual: @"walk"]) {
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
        }else if([transportName  isEqual: @"ride"]) {
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_RIDING;
        }else{
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING;
        }

        BTKTrackProcessOptionSupplementMode supplementMode;

        if(supplement) {
                supplementMode =  BTK_TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING;
        }else{
                supplementMode = BTK_TRACK_PROCESS_OPTION_NO_SUPPLEMENT;
        }

        BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
        option.denoise = denoise;
        option.mapMatch = mapMatch;
        option.radiusThreshold = radiusThreshold;
        option.transportMode = transportMode;
        // 构造请求对象
        // 发起查询请求
        BTKQueryTrackDistanceRequest *request = [[BTKQueryTrackDistanceRequest alloc] initWithEntityName:entityName startTime:startTime endTime:endTime isProcessed:isProcessed processOption:option supplementMode:supplementMode serviceID:self.serviceId tag:10];
        [[BTKTrackAction sharedInstance] queryTrackDistanceWith:request delegate:self];

}

- (void)queryLocation:(CDVInvokedUrlCommand*)command
{
        queryLocationCallbackId = command.callbackId;
        NSMutableDictionary *values = [command.arguments objectAtIndex:0];
        //NSUInteger serviceId = [[values objectForKey:@"serviceId"] longLongValue];
        NSString* entityName = [values objectForKey:@"entityName"];
        //是否去噪
        BOOL denoise = [[values objectForKey:@"denoise"] boolValue];
        //是否绑路
        BOOL mapMatch = [[values objectForKey:@"mapMatch"] boolValue];
        //去除噪点精度 0 不去噪，20去除gps之外，100过滤大于100
        NSInteger radiusThreshold = [[values objectForKey:@"radiusThreshold"] intValue];
        NSString* transportName = [values objectForKey:@"transportMode"];
        BTKTrackProcessOptionTransportMode transportMode;
        if([transportName  isEqual: @"walk"]) {
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING;
        }else if([transportName  isEqual: @"ride"]) {
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_RIDING;
        }else{
                transportMode = BTK_TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING;
        }


        BTKQueryTrackProcessOption *option = [[BTKQueryTrackProcessOption alloc] init];
        option.denoise = denoise;
        option.mapMatch = mapMatch;
        option.radiusThreshold = radiusThreshold;
        option.transportMode = transportMode;
        // 构造请求对象
        // 发起查询请求
        BTKQueryTrackLatestPointRequest *request = [[BTKQueryTrackLatestPointRequest alloc] initWithEntityName:entityName processOption: option outputCootdType:BTK_COORDTYPE_BD09LL serviceID:self.serviceId tag:10];
        [[BTKTrackAction sharedInstance] queryTrackLatestPointWith:request delegate:self];

}

#pragma mark - Trace服务相关的回调方法

- (void)onChangeGatherAndPackIntervals:(BTKChangeIntervalErrorCode)error
{
        CDVPluginResult* pluginResult;
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:0];
        BOOL isSuccess = FALSE;
        NSString *message = nil;
        switch (error) {
        case BTK_CHANGE_INTERVAL_NO_ERROR:
                isSuccess = TRUE;
                message = @"采集和打包间隔设置成功";
                break;
        case BTK_CHANGE_INTERVAL_PARAM_ERROR:
                message = @"采集和打包间隔参数错误";
                break;
        default:
                message=@"设置采集和打包间隔未知错误";
                break;
        }
        if(isSuccess) {
                [result setObject:@(true) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:setIntervalCallbackId];
        }else{
                [result setObject:@(false) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:setIntervalCallbackId];
        }
}
- (void)onStartService:(BTKServiceErrorCode)error
{
        NSLog(@"start service ");
        CDVPluginResult* pluginResult;
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:0];
        BOOL isSuccess = FALSE;
        NSString *message = nil;
        switch (error) {
        case BTK_START_SERVICE_SUCCESS:
                isSuccess = TRUE;
                message = @"成功登录到服务端";
                break;
        case BTK_START_SERVICE_SUCCESS_BUT_OFFLINE:
                isSuccess = TRUE;
                message = @"当前网络不畅，未登录到服务端。网络恢复后SDK会自动重试";
                break;
        case BTK_START_SERVICE_PARAM_ERROR:
                message = @"参数错误,点击右上角设置按钮设置参数";
                break;
        case BTK_START_SERVICE_INTERNAL_ERROR:
                message = @"SDK服务内部出现错误";
                break;
        case BTK_START_SERVICE_NETWORK_ERROR:
                message = @"网络异常";
                break;
        case BTK_START_SERVICE_AUTH_ERROR:
                message = @"鉴权失败，请检查AK和MCODE等配置信息";
                break;
        case BTK_START_SERVICE_IN_PROGRESS:
                message = @"正在开启服务，请稍后再试";
                break;
        case BTK_START_SERVICE_SUCCESS_BUT_NO_AUTH_TO_KEEP_ALIVE:
              message = @"服务开启成功，但是由于没有定位权限，所以无法保活";
              break;
        case BTK_SERVICE_ALREADY_STARTED_ERROR:
                message = @"已经成功开启服务，请勿重复开启";
                break;
        default:
                message = @"轨迹服务开启结果未知";
                break;
        }
        if(isSuccess) {
                [result setObject:@(true) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:startTraceCallbackId];
        }else{
                [result setObject:@(false) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:startTraceCallbackId];
        }
}
- (void)onStopService:(BTKServiceErrorCode)error
{
        NSLog(@"stop service");
        CDVPluginResult* pluginResult;
        BOOL isSuccess = FALSE;
        NSString *message = nil;
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:0];
        switch (error) {
        case BTK_STOP_SERVICE_NO_ERROR:
                isSuccess = TRUE;
                message = @"SDK已停止工作";
                break;
        case BTK_STOP_SERVICE_NOT_YET_STARTED_ERROR:
                message = @"还没有开启服务，无法停止服务";
                break;
        case BTK_STOP_SERVICE_IN_PROGRESS:
                message = @"正在停止服务，请稍后再试";
                break;
        default:
                message = @"轨迹服务停止结果未知";
                break;
        }
        if(isSuccess) {

                [result setObject:@(true) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:stopTraceCallbackId];
        }else{
                [result setObject:@(false) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:stopTraceCallbackId];
        }
}

- (void)onStopGather:(BTKGatherErrorCode)error
{
        NSLog(@"stop gather");
        BOOL isSuccess = FALSE;
        NSString *message = nil;
        CDVPluginResult* pluginResult;
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:0];
        switch (error) {
        case BTK_STOP_GATHER_NO_ERROR:
                isSuccess = TRUE;
                message = @"SDK停止采集本设备的轨迹信息";
                break;
        case BTK_STOP_GATHER_NOT_YET_STARTED_ERROR:
                message = @"还没有开始采集，无法停止";
                break;
        default:
                message = @"停止采集轨迹的结果未知";
                break;
        }
        if(isSuccess) {
                [result setObject:@(true) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:stopGatherCallbackId];
        }else{
                [result setObject:@(false) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:stopGatherCallbackId];
        }
}
- (void)onstartGather:(BTKGatherErrorCode)error
{
        NSLog(@"start gather");
        BOOL isSuccess = FALSE;
        NSString *message = nil;
        CDVPluginResult* pluginResult;
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:0];
        switch (error) {
        case BTK_START_GATHER_SUCCESS:
                isSuccess = TRUE;
                message = @"开始采集成功";
                break;
        case BTK_GATHER_ALREADY_STARTED_ERROR:
                message = @"已经在采集轨迹，请勿重复开始";
                break;
        case BTK_START_GATHER_BEFORE_START_SERVICE_ERROR:
                message = @"开始采集必须在开始服务之后调用";
                break;
        case BTK_START_GATHER_LOCATION_SERVICE_OFF_ERROR:
                message = @"没有开启系统定位服务";
                break;
        case BTK_START_GATHER_LOCATION_ALWAYS_USAGE_AUTH_ERROR:
                message = @"没有开启后台定位权限";
                break;
        case BTK_START_GATHER_INTERNAL_ERROR:
                message = @"SDK服务内部出现错误";
                break;
        default:
                message = @"开始采集轨迹的结果未知";
                break;
        }
        if(isSuccess) {
                [result setObject:@(true) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:startGatherCallbackId];
        }else{
                [result setObject:@(false) forKey:@"success"];
                [result setObject:message forKey:@"message"];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:startGatherCallbackId];
        }
}
-(void) onQueryHistoryTrack:(NSData*)response
{


        NSString *resultString  =[[ NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"get onAddEntity:%@",resultString);
        NSInteger rstatus = [[result objectForKey:@"status"] intValue];
        BOOL isSuccess = (rstatus == 0);
        CDVPluginResult* pluginResult;
        if(isSuccess) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:queryHistoryCallbackId];
        }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:queryHistoryCallbackId];
        }

}
- (void)onQueryTrackDistance:(NSData*)response
{

        NSString *resultString  =[[ NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"get onAddEntity:%@",resultString);
        NSInteger rstatus = [[result objectForKey:@"status"] intValue];
        BOOL isSuccess = (rstatus == 0);
        CDVPluginResult* pluginResult;
        if(isSuccess) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:queryDistanceCallbackId];
        }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:queryDistanceCallbackId];
        }
}
- (void)onQueryTrackLatestPoint:(NSData*)response
{

        NSString *resultString  =[[ NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"get onAddEntity:%@",resultString);
        NSInteger rstatus = [[result objectForKey:@"status"] intValue];
        BOOL isSuccess = (rstatus == 0);
        CDVPluginResult* pluginResult;
        if(isSuccess) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:queryLocationCallbackId];
        }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:queryLocationCallbackId];
        }
}
-(void)onAddEntity:(NSData *)response
{
        NSString *resultString  =[[ NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"get onAddEntity:%@",resultString);
        NSInteger rstatus = [[result objectForKey:@"status"] intValue];
        //NSLog(@"status%@",[status isKindOfClass:[NSString class]]);
        BOOL isSuccess = (rstatus == 0);
        CDVPluginResult* pluginResult;
        if(isSuccess) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:addEntityCallbackId];
        }else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:addEntityCallbackId];
        }

}
@end
