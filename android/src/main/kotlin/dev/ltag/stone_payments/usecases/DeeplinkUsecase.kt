package dev.ltag.stone_payments.usecases

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DeeplinkUsecase(private val activity: Activity?, private val channel: MethodChannel) {

    companion object {
        private const val TAG = "DeeplinkUsecase"
    }

    fun doTransaction(call: MethodCall, result: MethodChannel.Result) {
        val amount = call.argument<Double>("amount")
        val transactionType = call.argument<String?>("transactionType")
        val installmentCount = call.argument<String?>("installmentCount")
        val installmentType = call.argument<String?>("installmentType")
        val orderId = call.argument<String>("orderId")
        val returnSchema = call.argument<String>("returnSchema") ?: "stone_example"

        if (amount == null || amount <= 0) {
            result.error("INVALID_ARGUMENTS", "Invalid amount provided", null)
            return
        }

        val amountFormatted = String.format("%09d", (amount * 100).toLong())

        if (transactionType.isNullOrEmpty() || orderId.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "Required arguments are missing", null)
            return
        }

        val uriBuilder = Uri.Builder()
                .authority("pay")
                .scheme("payment-app")
                .appendQueryParameter("return_scheme", returnSchema)
                .appendQueryParameter("amount", amountFormatted)
                .appendQueryParameter("editable_amount", "0")

        if(transactionType != null)
            uriBuilder.appendQueryParameter("transaction_type", transactionType)

        if(installmentType != null)
            uriBuilder.appendQueryParameter("installment_type", installmentType)

        if(orderId != null)
            uriBuilder.appendQueryParameter("order_id", orderId)

        if(installmentCount != null)
            uriBuilder.appendQueryParameter("installment_count", installmentCount)

        val intent = Intent(Intent.ACTION_VIEW, uriBuilder.build()).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        try {
            activity?.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Erro ao iniciar deeplink", e)
        }
    }

    fun doCancel(call: MethodCall, result: MethodChannel.Result) {
        val amount = call.argument<Double>("amount")
        val atk = call.argument<String>("atk")
        val returnSchema = call.argument<String>("returnSchema") ?: "stone_example"

        if (amount == null || amount <= 0) {
            result.error("INVALID_ARGUMENTS", "Invalid amount provided", null)
            return
        }

        val amountFormatted = String.format("%09d", (amount * 100).toLong())

        if (atk.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "Required arguments are missing", null)
            return
        }

        val uriBuilder = Uri.Builder()
            .authority("cancel")
            .scheme("cancel-app")
            .appendQueryParameter("return_scheme", returnSchema)
            .appendQueryParameter("amount", amountFormatted)
            .appendQueryParameter("atk", atk)
            .appendQueryParameter("editable_amount", "0")

        val intent = Intent(Intent.ACTION_VIEW, uriBuilder.build()).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        try {
            activity?.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Erro ao iniciar deeplink", e)
        }
    }

    fun handleDeeplinkResponse(intent: Intent?) {
        intent?.data?.let { uri ->
            val response = mutableMapOf<String, String>()
            uri.queryParameterNames.forEach { key ->
                response[key] = uri.getQueryParameter(key) ?: ""
            }

            Log.d(TAG, "Deeplink response received: $response")

            // Envia para o Flutter via invokeMethod (como broadcast)
            channel.invokeMethod("onDeeplinkResponse", response)
        } ?: run {
            Log.e(TAG, "No data found in deeplink response")
        }
    }
}
