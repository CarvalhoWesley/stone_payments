package dev.ltag.stone_payments.usecases

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DeeplinkUsecase(private val activity: Activity?) {

    companion object {
        public const val REQUEST_CODE_PAYMENT = 1001
    }

    /*private var lastResult: MethodChannel.Result? = null*/

    private var pendingResult: MethodChannel.Result? = null

    fun doTransaction(call: MethodCall, result: MethodChannel.Result) {
        val amount = call.argument<Double>("amount")
        val transactionType = call.argument<String>("transactionType")
        val installmentCount = call.argument<Int>("installmentCount")
        val orderId = call.argument<String>("orderId")
        val creditType = call.argument<String>("creditType")

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
                .scheme("payment-app")
                .authority("pay")
                .appendQueryParameter("return_scheme", "stonedeeplink")
                .appendQueryParameter("amount", amountFormatted)
                .appendQueryParameter("editable_amount", "0")
                .appendQueryParameter("transaction_type", transactionType)
                .appendQueryParameter("installment_type", "none")
                .appendQueryParameter("order_id", orderId)

        if (installmentCount != null && installmentCount > 0) {
            uriBuilder.appendQueryParameter("installment_count", installmentCount.toString())
        }

        val deeplinkUri = uriBuilder.build()

        val intent = Intent(Intent.ACTION_VIEW, deeplinkUri).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        pendingResult = result

        try {
            activity?.startActivity(intent)
        } catch (e: Exception) {
            result.error("DEEPLINK_ERROR", "Failed to open deeplink: ${e.localizedMessage}", null)
            pendingResult = null
        }

//        val deeplinkUri = uriBuilder.build()
//
//        val intent = Intent(Intent.ACTION_VIEW, deeplinkUri).apply {
//            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
//        }
//        pendingResult = result
//
//        try {
//            activity?.startActivityForResult(intent, REQUEST_CODE_PAYMENT)
//        } catch (e: Exception) {
//            result.error("DEEPLINK_ERROR", "Failed to open deeplink: ${e.localizedMessage}", null)
//        }
    }

    fun handleDeeplinkResponse(intent: Intent?) {
        intent?.data?.let { uri ->
            val queryParams = mutableMapOf<String, String>()
            uri.queryParameterNames.forEach { key ->
                queryParams[key] = uri.getQueryParameter(key) ?: ""
            }
            pendingResult?.success(queryParams)
            pendingResult = null
        } ?: run {
            pendingResult?.error("DEEPLINK_RESPONSE_ERROR", "No data received", null)
            pendingResult = null
        }
    }


//    fun handleActivityResult(resultCode: Int, data: Intent?) {
//        if (resultCode == Activity.RESULT_OK && data != null) {
//            val gson = Gson()
//            // Converter para JSON e retornar o resultado
//            val transactionJson = gson.toJson(data)
//            pendingResult?.success(transactionJson)
//        } else {
//            pendingResult?.error("CANCELLED", "Payment was cancelled or failed", null)
//        }
//        pendingResult = null
//    }
}
