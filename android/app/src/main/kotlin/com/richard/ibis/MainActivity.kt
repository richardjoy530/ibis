package com.richard.ibis

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private  val CHANNEL="com.richard.ibis/ibis"
    override  fun  onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterEngine?.dartExecutor,CHANNEL).setMethodCallHandler{ methodCall,result ->
            if(methodCall.method=="hotspot")
            {
                result.success("welcome to kotlin world")
            }
        }
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
