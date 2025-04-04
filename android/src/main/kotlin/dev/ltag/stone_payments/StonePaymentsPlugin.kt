package dev.ltag.stone_payments

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import android.content.Intent
import android.util.Log
import dev.ltag.stone_payments.usecases.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import stone.database.transaction.TransactionObject
import io.flutter.plugin.common.MethodChannel.Result as Res
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** StonePaymentsPlugin */
class StonePaymentsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, Activity() {
    private lateinit var channel: MethodChannel
    var context: Context = this;
    var activity: Activity? = null
    var transactionObject = TransactionObject()
    var paymentUsecase: PaymentUsecase? = null
    var printerUsecase: PrinterUsecase? = null
    var deeplinkUsecase: DeeplinkUsecase? = null

    companion object {
        var flutterBinaryMessenger: BinaryMessenger? = null
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        flutterBinaryMessenger = flutterPluginBinding.binaryMessenger;
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "stone_payments")
        channel.setMethodCallHandler(this)
        // Inicialize as propriedades aqui
        paymentUsecase = PaymentUsecase(this)
        printerUsecase = PrinterUsecase(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        // Inicializar os casos de uso com o contexto ou atividade
        deeplinkUsecase = DeeplinkUsecase(activity)

        binding.addOnNewIntentListener(::handleNewIntent)

        /*binding.addActivityResultListener { requestCode, resultCode, data ->
            if (requestCode == DeeplinkUsecase.REQUEST_CODE_PAYMENT) {
                deeplinkUsecase?.handleActivityResult(resultCode, data)
                true
            } else {
                false
            }
        }*/
    }

    override fun onDetachedFromActivity() {
        activity = null
        deeplinkUsecase = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Res) {
        val activateUsecase: ActivateUsecase? = ActivateUsecase(context)
        when (call.method) {
            "activateStone" -> {
                try {
                    activateUsecase!!.doActivate(
                        call.argument("appName")!!,
                        call.argument("stoneCode")!!,
                        call.argument("qrCodeProviderId"),
                        call.argument("qrCodeAuthorization")
                    ) { resp ->
                        when (resp) {
                            is Result.Success<Boolean> -> result.success(
                                "Ativado"
                            )
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot Activate", e.toString())
                }
            }
            "payment" -> {
                try {
                    paymentUsecase!!.doPayment(
                        call.argument("value")!!,
                        call.argument("typeTransaction")!!,
                        call.argument("installment")!!,
                        call.argument("printReceipt"),
                    ) { resp ->
                        when (resp) {
                            is Result.Success<Boolean> -> result.success(
                                resp.data
                            )
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot Activate", e.toString())
                }
            }
            "transaction" -> {
                try {
                    paymentUsecase!!.doTransaction(
                        call.argument("value")!!,
                        call.argument("typeTransaction")!!,
                        call.argument("installment")!!,
                        call.argument("printReceipt"),
                    ) { resp ->
                        when (resp) {
                            is Result.Success<String> -> result.success(
                                resp.data
                            )
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot Activate", e.toString())
                }
            }
            "print" -> {
                try {
                    printerUsecase!!.print(
                        call.argument("items")!!,
                    ) { resp ->
                        when (resp) {
                            is Result.Success<Boolean> -> result.success(
                                "Impresso"
                            )
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot Activate", e.toString())
                }
            }
            "printReceipt" -> {
                try {
                    printerUsecase!!.printReceipt(
                        call.argument("type")!!,
                    ) { resp ->
                        when (resp) {
                            is Result.Success<Boolean> -> result.success(
                                "Via Impressa"
                            )
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot Activate", e.toString())
                }
            }
            "abortPayment" -> {
                try {
                    paymentUsecase!!.doAbort() { resp ->
                        when (resp) {
                            is Result.Success<String> -> result.success(
                                resp.data
                            )
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot Activate", e.toString())
                }
            }
            "cancelPayment" -> {
                try {
                    paymentUsecase!!.doCancelWithITK(
                       call.argument("initiatorTransactionKey")!!,
                       call.argument("printReceipt"),
                   ) { resp ->
                        when (resp) {
                            is Result.Success<*> -> result.success(resp.data.toString())
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot cancel", e.toString())
                }
            }
            // "cancelPaymentWithATK" -> {
            //     try {
            //         paymentUsecase!!.doCancelWithITK(
            //            call.argument("acquirerTransactionKey")!!,
            //            call.argument("printReceipt"),
            //        ) { resp ->
            //             when (resp) {
            //                 is Result.Success<*> -> result.success(resp.data.toString())
            //                 else -> result.error("Error", resp.toString(), resp.toString())
            //             }
            //         }
            //     } catch (e: Exception) {
            //         result.error("UNAVAILABLE", "Cannot cancel", e.toString())
            //     }
            // }
            "cancelPaymentWithAuthorizationCode" -> {
                try {
                    paymentUsecase!!.doCancelWithAuthorizationCode(
                       call.argument("authorizationCode")!!,
                       call.argument("printReceipt"),
                   ) { resp ->
                        when (resp) {
                            is Result.Success<*> -> result.success(resp.data.toString())
                            else -> result.error("Error", resp.toString(), resp.toString())
                        }
                    }
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Cannot cancel", e.toString())
                }
            }
            "transactionDeeplink" -> deeplinkUsecase?.doTransaction(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun handleNewIntent(intent: Intent): Boolean {
        Log.i("StonePlugin", "onNewIntent received:")

//        intent.data?.let {
//            deeplinkUsecase?.handleDeeplinkResponse(intent)
//            return true
//        }
        return false
    }
}
