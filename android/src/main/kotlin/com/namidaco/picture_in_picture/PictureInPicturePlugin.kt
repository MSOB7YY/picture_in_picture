package com.namidaco.picture_in_picture

import android.app.Activity
import android.app.PictureInPictureParams
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Rational
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*
import kotlin.concurrent.fixedRateTimer


/** PictureInPicturePlugin */
class PictureInPicturePlugin : FlutterPlugin, MethodCallHandler, Activity(), ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null


    val canEnterPip: Boolean
        get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "picture_in_picture")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformSdk" -> result.success(Build.VERSION.SDK_INT)
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "isPiPSupported" -> result.success(canEnterPip)
            "startPipCheckTimer" -> {
                val millis = call.argument<Int?>("durationMS")
                result.success(startPipCheckTimer(millis))
            }

            "enterPip" -> {
                val width = call.argument<Int?>("width")
                val height = call.argument<Int?>("height")
                result.success(enterPip(width, height))

            }

            else -> result.notImplemented()
        }
    }
    
    private var pipTimer: Timer? = null

    private fun startPipCheckTimer(durationMs: Int?): Boolean {
        pipTimer?.cancel()
        if (canEnterPip) {
            var lastInPip = activity?.isInPictureInPictureMode;
            pipTimer = fixedRateTimer("timer", false, 0L, durationMs?.toLong() ?: 100) {
                val pip = activity?.isInPictureInPictureMode
                if (pip != lastInPip) {
                    lastInPip = pip
                    runOnUiThread {
                        channel.invokeMethod("isInPip", mapOf("isInsidePip" to pip))
                    }
                }
            }
            return true;
        } else {
            return false;
        }
    }

    private fun enterPip(width: Int?, height: Int?): Boolean {
        if (canEnterPip) {
            return try {
                val params1 = PictureInPictureParams.Builder()

                if (width != null && height != null) {
                    val ratio = Rational(width, height)
                    val params2 = params1.setAspectRatio(ratio)
                    activity?.enterPictureInPictureMode(params2.build())
                } else {
                    activity?.enterPictureInPictureMode(params1.build())
                }
                true
            } catch (ignore: Exception) {
                false
            }
        } else {
            return false;
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {}
}
