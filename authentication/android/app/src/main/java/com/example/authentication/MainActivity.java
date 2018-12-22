package com.example.authentication;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.Intent;
import android.app.IntentService;
import android.content.Context;

public class MainActivity extends FlutterActivity {

  Context context;
  LocationService locService;
  Intent locServiceIntent;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    context = this;
    locService = new LocationService(context);
    locServiceIntent = new Intent(context, locService.getClass());

    // tracker/gps/.. is not a path, simply a way of making method channel names unique and organised
    new MethodChannel(getFlutterView(), "tracker/gps/background_location_updater").setMethodCallHandler(
      new MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall call, Result result) {
              if (call.method.equals("setBackgroundLocationUpdater")) startService(locServiceIntent);
          }
    });
  }
}
