package com.namidaco.picture_in_picture

import android.app.Activity
import android.app.PictureInPictureParams
import android.graphics.Rect
import android.os.Build
import android.util.Rational
import androidx.annotation.RequiresApi
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

            "setAspectRatio" -> {
                if (canEnterPip) {
                    val width = call.argument<Int?>("width")
                    val height = call.argument<Int?>("height")
                    if (width != null && height != null) {
                        val params = PictureInPictureParams.Builder()
                        val ratio = Rational(width, height)
                        params.setAspectRatio(ratio);
                        activity?.setPictureInPictureParams(params.build());
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                } else {
                    result.success(false)
                }
            }

            "enterPip" -> {
                val width = call.argument<Int?>("width")
                val height = call.argument<Int?>("height")
                val left = call.argument<Int?>("left")
                val top = call.argument<Int?>("top")
                val right = call.argument<Int?>("right")
                val bottom = call.argument<Int?>("bottom")
                result.success(enterPip(width, height, left, top, right, bottom))
            }

            else -> result.notImplemented()
        }
    }

    private var pipTimer: Timer? = null

    private fun startPipCheckTimer(durationMs: Int?): Boolean {
        pipTimer?.cancel()
        if (canEnterPip) {
            var lastInPip = activity?.isInPictureInPictureMode
            pipTimer =
                fixedRateTimer("timer", false, 0L, durationMs?.toLong() ?: 20) {
                    val pip = activity?.isInPictureInPictureMode
                    if (pip != lastInPip) {
                        lastInPip = pip
                        runOnUiThread {
                            channel.invokeMethod("isInPip", mapOf("isInsidePip" to pip))
                        }
                    }
                }
            return true
        } else {
            return false
        }
    }

    private fun enterPip(
        width: Int?,
        height: Int?,
        left: Int?,
        top: Int?,
        right: Int?,
        bottom: Int?
    ): Boolean {
        if (canEnterPip) {
            return try {
                val params1 = PictureInPictureParams.Builder()

                if (width != null && height != null) {
                    val ratio = Rational(width, height)
                    val params2 = params1.setAspectRatio(ratio)
                    buildPipWithRect(params2, left, top, right, bottom)
                } else {
                    buildPipWithRect(params1, left, top, right, bottom)
                }
                true
            } catch (ignore: Exception) {
                false
            }
        } else {
            return false
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildPipWithRect(
        builder: PictureInPictureParams.Builder,
        left: Int?,
        top: Int?,
        right: Int?,
        bottom: Int?
    ) {
        var rect: Rect? = null
        if (left != null && top != null && right != null && bottom != null) {
            rect = Rect(left, top, right, bottom);
            activity?.enterPictureInPictureMode(builder.setSourceRectHint(rect).build());

        } else {
            activity?.enterPictureInPictureMode(builder.build());
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
