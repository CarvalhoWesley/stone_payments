package dev.ltag.stone_payments.usecases

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import br.com.stone.posandroid.hal.api.mifare.MifareKeyType
import br.com.stone.posandroid.providers.PosMifareProvider
import dev.ltag.stone_payments.Result
import stone.application.interfaces.StoneCallbackInterface
import java.util.concurrent.Executors

class MifareUsecase(
    private val context: Context,
) {
    private var mifareProvider: PosMifareProvider? = null
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun detectCard(callback: (Result<Map<String, Any?>>) -> Unit, attempt: Int = 1) {
        try {
            mifareProvider?.cancelDetection()
            val provider = PosMifareProvider(context)
            mifareProvider = provider

            provider.connectionCallback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    runOperation(callback) {
                        // Em alguns terminais (ex.: Positivo L400) a detecção já ativa o cartão
                        // e activateCard falha sem acessar o leitor, então a falha não é fatal.
                        try {
                            provider.activateCard()
                        } catch (e: PosMifareProvider.MifareException) {
                            Log.w("ERRORMIFARE", "activateCard ignorado: ${e.errorEnum.name}")
                        }
                        mapOf(
                            "uuid" to provider.cardUUID,
                            "properties" to provider.mifareProperties.mapValues { toChannelValue(it.value) },
                        )
                    }
                }

                override fun onError() {
                    // Detecção cancelada pelo app: outro provider já assumiu ou foi limpo
                    val cancelled = mifareProvider !== provider
                    mifareProvider = null
                    val errors = provider.listOfErrors?.joinToString() ?: "Erro na detecção do cartão"

                    // O leitor do Positivo L400 às vezes falha (INTERNAL_ERROR) enquanto o cartão
                    // ainda está se aproximando; com o cartão parado a detecção seguinte funciona.
                    if (!cancelled && errors.contains("INTERNAL_ERROR") && attempt < MAX_DETECT_ATTEMPTS) {
                        Log.w("ERRORMIFARE", "detectCards: $errors, tentando de novo (${attempt + 1}/$MAX_DETECT_ATTEMPTS)")
                        mainHandler.postDelayed({ detectCard(callback, attempt + 1) }, RETRY_DELAY_MS)
                        return
                    }

                    Log.d("ERRORMIFARE", "detectCards: $errors")
                    callback(Result.Error(Exception("detectCards: $errors")))
                }
            }

            provider.execute()
        } catch (e: Exception) {
            Log.d("ERROR", e.toString())
            callback(Result.Error(e))
        }
    }

    fun authenticateSector(keyType: Int, key: ByteArray, sector: Int, callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            requireProvider().authenticateSector(
                if (keyType == 1) MifareKeyType.TypeB else MifareKeyType.TypeA,
                key,
                sector.toByte(),
            )
            true
        }
    }

    fun readBlock(sector: Int, block: Int, callback: (Result<ByteArray>) -> Unit) {
        runOperation(callback) {
            val data = ByteArray(16)
            requireProvider().readBlock(sector.toByte(), block.toByte(), data)
            data
        }
    }

    fun writeBlock(sector: Int, block: Int, data: ByteArray, callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            requireProvider().writeBlock(sector.toByte(), block.toByte(), data)
            true
        }
    }

    fun backupBlock(sector: Int, srcBlock: Int, dstBlock: Int, callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            requireProvider().backupBlock(sector.toByte(), srcBlock.toByte(), dstBlock.toByte())
            true
        }
    }

    fun restoreBlock(sector: Int, srcBlock: Int, dstBlock: Int, callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            requireProvider().restoreBlock(sector.toByte(), srcBlock.toByte(), dstBlock.toByte())
            true
        }
    }

    fun incrementValue(sector: Int, block: Int, value: Int, callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            requireProvider().incrementValue(sector.toByte(), block.toByte(), value.toByte())
            true
        }
    }

    fun decrementValue(sector: Int, block: Int, value: Int, callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            requireProvider().decrementValue(sector.toByte(), block.toByte(), value.toByte())
            true
        }
    }

    fun powerOff(callback: (Result<Boolean>) -> Unit) {
        runOperation(callback) {
            mifareProvider?.powerOff()
            mifareProvider = null
            true
        }
    }

    fun cancelDetection(callback: (Result<Boolean>) -> Unit) {
        try {
            val provider = mifareProvider
            mifareProvider = null
            provider?.cancelDetection()
            callback(Result.Success(true))
        } catch (e: Exception) {
            callback(Result.Error(e))
        }
    }

    private fun requireProvider(): PosMifareProvider =
        mifareProvider ?: throw IllegalStateException("Nenhum cartão Mifare detectado")

    // As operações do cartão são bloqueantes, por isso rodam fora da main thread.
    private fun <T> runOperation(callback: (Result<T>) -> Unit, operation: () -> T) {
        executor.execute {
            val result: Result<T> = try {
                Result.Success(operation())
            } catch (e: PosMifareProvider.MifareException) {
                Log.d("ERRORMIFARE", e.errorEnum.name)
                Result.Error(Exception(e.errorEnum.name))
            } catch (e: Exception) {
                Log.d("ERROR", e.toString())
                Result.Error(e)
            }
            mainHandler.post { callback(result) }
        }
    }

    private fun toChannelValue(value: Any?): Any? = when (value) {
        null, is String, is Boolean, is Int, is Long, is Double, is ByteArray -> value
        is Byte -> value.toInt()
        is Short -> value.toInt()
        is Float -> value.toDouble()
        else -> value.toString()
    }

    companion object {
        private const val MAX_DETECT_ATTEMPTS = 3
        private const val RETRY_DELAY_MS = 300L
    }
}
