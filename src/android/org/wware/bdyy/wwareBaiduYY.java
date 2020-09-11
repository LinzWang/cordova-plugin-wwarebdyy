package org.wware.bdyy;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import android.content.pm.PackageManager;

import android.os.Bundle;

import android.provider.Settings;

import android.util.Log;

//import com.cordovaPlugin.JsonUtil;
// 处理经纬度坐标：用于封装鹰眼SDK中各接口使用到的经纬度信息
import com.baidu.trace.*;
import com.baidu.trace.api.analysis.OnAnalysisListener;
import com.baidu.trace.api.bos.OnBosListener;
import com.baidu.trace.api.entity.OnEntityListener;
import com.baidu.trace.api.fence.OnFenceListener;
import com.baidu.trace.api.track.DistanceRequest;
import com.baidu.trace.api.track.DistanceResponse;
import com.baidu.trace.api.track.HistoryTrackRequest;
import com.baidu.trace.api.track.HistoryTrackResponse;
import com.baidu.trace.api.track.LatestPointResponse;
import com.baidu.trace.api.track.OnTrackListener;
import com.baidu.trace.api.track.SupplementMode;
import com.baidu.trace.api.track.TrackPoint;
import com.baidu.trace.model.CoordType;
import com.baidu.trace.model.LatLng;

import static com.baidu.trace.model.LocationMode.Battery_Saving;
import static com.baidu.trace.model.LocationMode.Device_Sensors;
import static com.baidu.trace.model.LocationMode.High_Accuracy;

import com.baidu.trace.model.OnTraceListener;
import com.baidu.trace.model.ProcessOption;
import com.baidu.trace.model.PushMessage;
import com.baidu.trace.model.SortType;
import com.baidu.trace.model.StatusCodes;
import com.baidu.trace.model.TransportMode;
import com.baidu.trace.model.BaseRequest;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaPreferences;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

// 处理轨迹回放
import java.util.Map;


public class wwareBaiduYY extends CordovaPlugin {
 protected static String CLIENTID;
 private CallbackContext callbackContext;
 private LBSTraceClient client;
 private Trace mTrace;
 private Context ctx;
 private int pageIndex = 1;
 private OnTraceListener mTraceListener = null;
 private OnTrackListener mTrackListener = null;
 @Override
 public void pluginInitialize() {
  super.pluginInitialize();
  //CLIENTID = webView.getPreferences().getString("CLIENTID", "c").substring(1);
  //BJCASDK.getInstance().setServerUrl(EnvType.INTEGRATE);
  
  ctx = this.cordova.getActivity().getApplicationContext();
  // 轨迹服务客户端对象，封装鹰眼SDK所有对外接口
  client = new LBSTraceClient(ctx);
   
 }

 // invalid
 protected void initTrace(long serviceId, String entityName) {
  boolean isNeedObjectStorage = false;
  mTrace = new Trace(serviceId, entityName, isNeedObjectStorage);
 }

 protected void initListener(){
    // 初始化轨迹服务监听器
 mTraceListener = new OnTraceListener() {
    // 初始化对象存储服务回调接口
    @Override
    public void onInitBOSCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 绑定服务回调接口
    @Override
    public void onBindServiceCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 开启服务回调
    @Override
    public void onStartTraceCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 停止服务回调
    @Override
    public void onStopTraceCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 开启采集回调
    @Override
    public void onStartGatherCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 停止采集回调
    @Override
    public void onStopGatherCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 推送回调
    @Override
    public void onPushCallback(byte messageNo, PushMessage message) {
     // JSONObject value = new JSONObject();
     // if(status == 0){
     //   value.put("success",true);
     // }else{
     //   value.put("success",false);
     //   value.put("status",status);
     // }
     // value.put("message",message);
     // callbackContext.success(value);
    }
   };
   
 }

 
 public boolean execute(String action, JSONArray args,
  CallbackContext callbackContext) throws JSONException {
  this.callbackContext = callbackContext;

  if (action.equals("startTrace")) {
   JSONObject message = args.getJSONObject(0);
   this.startTrace(message, callbackContext);
   return true;
  }
  if (action.equals("startGather")) {
   JSONObject message = args.getJSONObject(0);
   this.startGather(message, callbackContext);
   return true;
  }
  if (action.equals("stopGather")) {
   JSONObject message = args.getJSONObject(0);
   this.stopGather(message, callbackContext);
   return true;
  }
  if (action.equals("stopTrace")) {
   JSONObject message = args.getJSONObject(0);
   this.stopTrace(message, callbackContext);
   return true;
  }
  if (action.equals("setLocationMode")) {
   JSONObject message = args.getJSONObject(0);
   this.setLocationMode(message, callbackContext);
   return true;
  }
  if (action.equals("queryDistance")) {
   JSONObject message = args.getJSONObject(0);
   this.queryDistance(message, callbackContext);
   return true;
  }
  if (action.equals("queryHistoryTrack")) {
   JSONObject message = args.getJSONObject(0);
   this.queryHistoryTrack(message, callbackContext);
   return true;
  }
  // 设置位置采集周期 (s)和打包周期 (s)
  if (action.equals("setInterval")) {
   JSONObject message = args.getJSONObject(0);
   this.setInterval(message, callbackContext);
   return true;
  }
  return false;
 }

 public void setInterval(JSONObject message, CallbackContext callbackContext) throws JSONException {
  //位置采集周期 (s)
  int gatherInterval = message.getInt("gatherInterval");
  //打包周期 (s)
  int packInterval = message.getInt("packInterval");
  client.setInterval(gatherInterval, packInterval);
  JSONObject value = new JSONObject();
  value.put("success", true);
  callbackContext.success(value);
 }

 public void setLocationMode(JSONObject message, CallbackContext callbackContext) throws JSONException {
  String locationMode = message.getString("locationMode");
  //locationMode wifi network gps

  if (locationMode.equals("network")) {
   client.setLocationMode(Battery_Saving);

  } else if (locationMode.equals("gps")) {
   client.setLocationMode(Device_Sensors);

  } else {
   client.setLocationMode(High_Accuracy);
  }
  try {

   JSONObject value = new JSONObject();
   value.put("success", true);
   callbackContext.success(value);
  } catch (JSONException e) {

  }
 }
 //开启轨迹服务 在开启轨迹服务前，需要初始化Trace以及LBSTraceClient，并在xml文件中配置API_KEY(AK)。
 public void startTrace(JSONObject message, CallbackContext callbackContext) {
  try {
   long serviceid = message.getLong("serviceid");
   String entityName = message.getString("userid");
   // 是否需要对象存储服务，注意：若需要对象存储服务，一定要导入bos-android-sdk-1.0.2.jar。
   boolean isNeedObjectStorage = false;
   mTrace = new Trace(serviceid, entityName, isNeedObjectStorage);
     // 初始化轨迹服务监听器
 mTraceListener = new OnTraceListener() {
    // 初始化对象存储服务回调接口
    @Override
    public void onInitBOSCallback(int status, String message) {
     super.onInitBOSCallback(int status, String message);
    }
    // 绑定服务回调接口
    @Override
    public void onBindServiceCallback(int status, String message) {
     super.onBindServiceCallback(int status, String message);
    }
    // 开启服务回调
    @Override
    public void onStartTraceCallback(int status, String message) {
      JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 停止服务回调
    @Override
    public void onStopTraceCallback(int status, String message) {
     super.onStopTraceCallback(int status, String message);
    }
    // 开启采集回调
    @Override
    public void onStartGatherCallback(int status, String message) {
     super.onStartGatherCallback(int status, String message);
    }
    // 停止采集回调
    @Override
    public void onStopGatherCallback(int status, String message) {
     super.onStopGatherCallback(int status, String message);
    }
    // 推送回调
    @Override
    public void onPushCallback(byte messageNo, PushMessage message) {
     super.onPushCallback(byte messageNo, PushMessage message);
    }
   };
   client.startTrace(mTrace, mTraceListener);
  } catch (JSONException e) {

  }
 }
 // 停止轨迹服务
 public void stopTrace(JSONObject message, CallbackContext callbackContext) {
   mTraceListener = new OnTraceListener() {
    // 初始化对象存储服务回调接口
    @Override
    public void onInitBOSCallback(int status, String message) {
     super.onInitBOSCallback(int status, String message);
    }
    // 绑定服务回调接口
    @Override
    public void onBindServiceCallback(int status, String message) {
     super.onBindServiceCallback(int status, String message);
    }
    // 开启服务回调
    @Override
    public void onStartTraceCallback(int status, String message) {
      super.onStartTraceCallback(int status, String message);
    }
    // 停止服务回调
    @Override
    public void onStopTraceCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 开启采集回调
    @Override
    public void onStartGatherCallback(int status, String message) {
     super.onStartGatherCallback(int status, String message);
    }
    // 停止采集回调
    @Override
    public void onStopGatherCallback(int status, String message) {
     super.onStopGatherCallback(int status, String message);
    }
    // 推送回调
    @Override
    public void onPushCallback(byte messageNo, PushMessage message) {
     super.onPushCallback(byte messageNo, PushMessage message);
    }
   };
  client.stopTrace(mTrace, mTraceListener);
 }
 // 开启轨迹采集
 public void startGather(JSONObject message, CallbackContext callbackContext) {
   mTraceListener = new OnTraceListener() {
    // 初始化对象存储服务回调接口
    @Override
    public void onInitBOSCallback(int status, String message) {
     super.onInitBOSCallback(int status, String message);
    }
    // 绑定服务回调接口
    @Override
    public void onBindServiceCallback(int status, String message) {
     super.onBindServiceCallback(int status, String message);
    }
    // 开启服务回调
    @Override
    public void onStartTraceCallback(int status, String message) {
      super.onStartTraceCallback(int status, String message);
    }
    // 停止服务回调
    @Override
    public void onStopTraceCallback(int status, String message) {
     super.onStopTraceCallback(int status, String message);
    }
    // 开启采集回调
    @Override
    public void onStartGatherCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 停止采集回调
    @Override
    public void onStopGatherCallback(int status, String message) {
     super.onStopGatherCallback(int status, String message);
    }
    // 推送回调
    @Override
    public void onPushCallback(byte messageNo, PushMessage message) {
     super.onPushCallback(byte messageNo, PushMessage message);
    }
   };
  client.startGather(mTraceListener);
 }
 // 停止轨迹采集
 public void stopGather(JSONObject message, CallbackContext callbackContext) {
   mTraceListener = new OnTraceListener() {
    // 初始化对象存储服务回调接口
    @Override
    public void onInitBOSCallback(int status, String message) {
     super.onInitBOSCallback(int status, String message);
    }
    // 绑定服务回调接口
    @Override
    public void onBindServiceCallback(int status, String message) {
     super.onBindServiceCallback(int status, String message);
    }
    // 开启服务回调
    @Override
    public void onStartTraceCallback(int status, String message) {
      super.onStartTraceCallback(int status, String message);
    }
    // 停止服务回调
    @Override
    public void onStopTraceCallback(int status, String message) {
     super.onStopTraceCallback(int status, String message);
    }
    // 开启采集回调
    @Override
    public void onStartGatherCallback(int status, String message) {
     super.onStartGatherCallback(int status, String message);
    }
    // 停止采集回调
    @Override
    public void onStopGatherCallback(int status, String message) {
     JSONObject value = new JSONObject();
     try {
      if (status == 0) {
       value.put("success", true);
      } else {
       value.put("success", false);
       value.put("status", status);
      }
      value.put("message", message);
      callbackContext.success(value);
     } catch (JSONException e) {

     }
    }
    // 推送回调
    @Override
    public void onPushCallback(byte messageNo, PushMessage message) {
     super.onPushCallback(byte messageNo, PushMessage message);
    }
   };
  client.stopGather(mTraceListener);
 }
 // 查询里程
 public void queryDistance(JSONObject message, CallbackContext callbackContext) {
  try {
   // 请求标识 用时间戳生成请求标识
   int tag = (int)(System.currentTimeMillis() % 1000000000);
   // 轨迹服务ID
   long serviceId = message.getLong("serviceid");
   // 设备标识
   String entityName = message.getString("userid");
   // 创建里程查询请求实例
   DistanceRequest distanceRequest = new DistanceRequest(tag, serviceId, entityName);
   // 开始时间(单位：秒)  由调用者封装到message对象中的startTime
   long startTime = message.getLong("startTime");
   // 结束时间(单位：秒)  由调用者封装到message对象中的endTime
   long endTime = message.getLong("endTime");
   // 设置开始时间
   distanceRequest.setStartTime(startTime);
   // 设置结束时间
   distanceRequest.setEndTime(endTime);
   // 设置需要纠偏
   distanceRequest.setProcessed(true);
   // 创建纠偏选项实例
   ProcessOption processOption = new ProcessOption();
   // 设置需要去噪
   processOption.setNeedDenoise(true);
   // 设置需要绑路
   processOption.setNeedMapMatch(true);
   // 设置交通方式为步行
   processOption.setTransportMode(TransportMode.walking);
   // 设置纠偏选项
   distanceRequest.setProcessOption(processOption);
   // 设置里程填充方式为步行
   distanceRequest.setSupplementMode(SupplementMode.walking);
   mTrackListener = new OnTrackListener() {
  //  @Override
  // 查询里程回调接口(配速 接口调用者自行计算 distance/(endTime-startTime);速度：m/s)
  /*public void onDistanceCallback(DistanceResponse response) {
   try {
    JSONObject value = new JSONObject();
    double distance = response.getDistance(); //里程，单位：米
    value.put("distance", distance);
    value.put("success", true);
    callbackContext.success(value);
   } catch (JSONException e) {

   }
  }*/
  @Override
  public void onDistanceCallback(DistanceResponse response) {
       try {
        JSONObject value = new JSONObject();
        double distance = response.getDistance(); //里程，单位：米
        value.put("distance", distance);
        value.put("success", true);
        callbackContext.success(value);
       } catch (JSONException e) {

       }
  }

  @Override
  public void onLatestPointCallback(LatestPointResponse response) {
      super.onLatestPointCallback(response);
  }
  // 查询历史轨迹回调接口
  @Override
  public void onHistoryTrackCallback(HistoryTrackResponse response) {
    super.onHistoryTrackCallback(response);
  }
 };

   // 查询里程
   client.queryDistance(distanceRequest, mTrackListener);
  } catch (JSONException e) {

  }
 }
 //查询历史轨迹
 public void queryHistoryTrack(JSONObject message, CallbackContext callbackContext) {
  HistoryTrackRequest historyTrackRequest = new HistoryTrackRequest();
  ProcessOption processOption = new ProcessOption(); //纠偏选项
  processOption.setRadiusThreshold(50); //精度过滤
  processOption.setTransportMode(TransportMode.walking); //交通方式，默认为驾车
  processOption.setNeedDenoise(true); //去噪处理，默认为false，不处理
  processOption.setNeedVacuate(true); //设置抽稀，仅在查询历史轨迹时有效，默认需要false
  processOption.setNeedMapMatch(true); //绑路处理，将点移到路径上，默认不需要false
  historyTrackRequest.setProcessOption(processOption);

  /**
  * 设置里程补偿方式，当轨迹中断5分钟以上，会被认为是一段中断轨迹，默认不补充
  * 比如某些原因造成两点之间的距离过大，相距100米，那么在这两点之间的轨迹如何补偿
    SupplementMode.driving：补偿轨迹为两点之间最短驾车路线
    SupplementMode.riding：补偿轨迹为两点之间最短骑车路线
    SupplementMode.walking：补偿轨迹为两点之间最短步行路线
    SupplementMode.straight：补偿轨迹为两点之间直线
  */
  historyTrackRequest.setSupplementMode(SupplementMode.walking);
  historyTrackRequest.setSortType(SortType.asc); //设置返回结果的排序规则，默认升序排序；升序：集合中index=0代表起始点；降序：结合中index=0代表终点。
  historyTrackRequest.setCoordTypeOutput(CoordType.bd09ll); //设置返回结果的坐标类型，默认为百度经纬度

  /**
  *设置是否返回纠偏后轨迹，默认不纠偏
   true：打开轨迹纠偏，返回纠偏后轨迹;
   false：关闭轨迹纠偏，返回原始轨迹。
   打开纠偏时，请求时间段内轨迹点数量不能超过2万，否则将返回错误。
  */
  historyTrackRequest.setProcessed(true);
  // tode 优化异常处理
  try {
   //请求历史轨迹
   // 请求标识 用时间戳生成请求标识
   int tag = (int)(System.currentTimeMillis() % 1000000000);
   // 轨迹服务ID
   long serviceId = message.getLong("serviceid");
   // 设备标识
   String entityName = message.getString("userid");
   ((BaseRequest) historyTrackRequest).setTag(tag); //设置请求标识，用于唯一标记本次请求，在响应结果中会返回该标识
   historyTrackRequest.setServiceId(serviceId); //设置轨迹服务id，Trace中的id
   historyTrackRequest.setEntityName(entityName); //Trace中的entityName

   /**
    * 设置startTime和endTime，会请求这段时间内的轨迹数据;
    * 这里查询采集开始到采集结束之间的轨迹数据
    */
   // 开始时间(单位：秒)  由调用者封装到message对象中的startTime
   long startTime = message.getLong("startTime");
   // 结束时间(单位：秒)  由调用者封装到message对象中的endTime
   long endTime = message.getLong("endTime");
   historyTrackRequest.setStartTime(startTime);
   historyTrackRequest.setEndTime(endTime);

   // 获得分页
   int pageIndex = message.getInt("pageindex");
   int pageSize = message.getInt("pagesize");
   // 设置分页
   historyTrackRequest.setPageIndex(pageIndex);
   historyTrackRequest.setPageSize(pageSize);
  } catch (JSONException e) {

  }
  // 初始化轨迹服务监听器
  mTrackListener = new OnTrackListener() {
  //  @Override
  // 查询里程回调接口(配速 接口调用者自行计算 distance/(endTime-startTime);速度：m/s)
  /*public void onDistanceCallback(DistanceResponse response) {
   try {
    JSONObject value = new JSONObject();
    double distance = response.getDistance(); //里程，单位：米
    value.put("distance", distance);
    value.put("success", true);
    callbackContext.success(value);
   } catch (JSONException e) {

   }
  }*/
  @Override
  public void onDistanceCallback(DistanceResponse response) {
      super.onDistanceCallback(response);
  }

  @Override
  public void onLatestPointCallback(LatestPointResponse response) {
      super.onLatestPointCallback(response);
  }
  // 查询历史轨迹回调接口
  @Override
  public void onHistoryTrackCallback(HistoryTrackResponse response) {
   JSONObject value = new JSONObject();
   JSONArray pointArray = new JSONArray();
   try {
    List < LatLng > trackPoints = new ArrayList < > ();
    int total = response.getTotal();
    if (StatusCodes.SUCCESS != response.getStatus()) {
     value.put("success", false);
     value.put("status", response.getStatus());
     value.put("message", response.getMessage());
    } else if (0 == total) {
     value.put("success", true);
    } else {
     List < TrackPoint > points = response.getTrackPoints();
     if (null != points) {
      for (TrackPoint trackPoint: points) {
       JSONObject tmp = new JSONObject();
       //封装坐标 坐标纬度 坐标精度
       tmp.put("latitude", trackPoint.getLocation().getLatitude());
       tmp.put("longitude", trackPoint.getLocation().getLongitude());
       pointArray.add(tmp);
       value.put("success", true);
      }
     } else {

     }
    }
    // //递归获得所有数据
    // if (total > Constants.PAGE_SIZE * pageIndex) {
    //     historyTrackRequest.setPageIndex(++pageIndex);
    //     queryHistoryTrack();
    // } else {
    //     //返回
    // }
   } catch (Exception e) {

   }
  }
 };
  client.queryHistoryTrack(historyTrackRequest, mTrackListener); //发起请求，设置回调监听
 }
}
