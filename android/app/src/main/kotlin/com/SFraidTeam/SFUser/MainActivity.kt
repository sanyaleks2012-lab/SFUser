package com.SFraidTeam.SFUser

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.IBinder
import androidx.annotation.Keep
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import rikka.shizuku.Shizuku.UserServiceArgs


class MainActivity : FlutterActivity() {
    @Keep
    private val shizukuChannel = "com.SFraidTeam.SFUser/shizuku"
    @Keep
    private var binderService: IBinderService? = null

    @Keep
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shizukuChannel).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "pingBinder" -> {
                    result.success(Shizuku.pingBinder())
                }

                "checkPermission" -> {
                    result.success(Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED)
                }

                "requestPermission" -> {
                    val requestCode: Int = call.argument("requestCode")!!
                    requestPermission(requestCode, result)
                }

                "runCommand" -> {
                    val command = call.argument<String>("command")
                        ?: throw IllegalArgumentException("Invalid command argument")
                    if (binderService == null) {
                        result.error("BINDER_SERVICE_NOT_AVAILABLE", "Binder service is not available", "binderService is null")
                    } else {
                        result.success(binderService?.runCommand(command))
                    }
                }

                "isBinderServiceAvailable" -> {
                    result.success(binderService != null)
                }

                "startBinderService" -> {
                    try {
                        startBinderService()
                        result.success("")
                    } catch (e: Exception) {
                        result.error("START_BINDER_SERVICE_ERROR", e.toString(), "exception in startBindService")
                    }
                }

                "hasStorageAccess" -> {
                    result.success(hasStorageAccess())
                }

                "requestStorageAccess" -> {
                    requestStorageAccess()
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @Keep
    private fun hasStorageAccess(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return Environment.isExternalStorageManager()
        }
        return checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) ==
                PackageManager.PERMISSION_GRANTED &&
                checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                PackageManager.PERMISSION_GRANTED
    }

    @Keep
    private fun requestStorageAccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // "All files access" can only be granted in system settings
            startActivity(
                Intent(
                    Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                    Uri.parse("package:$packageName")
                )
            )
        } else {
            requestPermissions(
                arrayOf(
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                ),
                1001
            )
        }
    }

    @Keep
    private fun requestPermission(code: Int, result: MethodChannel.Result) {
        if (Shizuku.isPreV11()) {
            result.success(false)
            return
        }

        if (Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED) {
            result.success(true)
            return
        }

        if (Shizuku.shouldShowRequestPermissionRationale()) {
            result.success(false)
            return
        }

        Shizuku.addRequestPermissionResultListener(object :
            Shizuku.OnRequestPermissionResultListener {
            override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
                if (requestCode == code) {
                    Shizuku.removeRequestPermissionResultListener(this)
                    val isGranted = grantResult == PackageManager.PERMISSION_GRANTED
                    result.success(isGranted)
                }
            }
        })

        Shizuku.requestPermission(code)
    }

    @Keep
    private fun startBinderService() {
        Log.i("BinderService", "Trying to start the service...")
        Shizuku.bindUserService(
            UserServiceArgs(
                ComponentName(context, BinderService::class.java)
            )
                .processNameSuffix("shell")
                .debuggable(false)
                .daemon(false),
            object : ServiceConnection {
                override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                    this@MainActivity.binderService = IBinderService.Stub.asInterface(service)
                    Log.i("BinderService", "service connected")
                }

                override fun onServiceDisconnected(name: ComponentName?) {}
            }
        )
    }
}
