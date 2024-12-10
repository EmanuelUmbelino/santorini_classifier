package com.example.santorini_classifier

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.pytorch.IValue
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import org.pytorch.Module
import org.pytorch.Tensor

class MainActivity: FlutterActivity() {
    private val CHANNEL = "pytorch_classifier"
    private lateinit var module: Module

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadModel" -> {
                    val modelPath = "classifier.pt"
                    try {
                        val filePath = assetFilePath(this, modelPath)
                        module = Module.load(filePath)
                        result.success(filePath)
                    } catch (e: Exception) {
                        result.error("LOAD_ERROR",modelPath, e)
                    }
                }
                "classify" -> {
                    // Retrieve and cast arguments
                    val imageData = call.argument<ArrayList<Double>>("imageData")!!
                    val inputShape = call.argument<List<Long>>("inputShape")!!
            
                    // Convert ArrayList<Double> to FloatArray
                    val floatArray = FloatArray(imageData.size) { i -> imageData[i].toFloat() }

                    // Convert List<Long> to LongArray
                    val longArray = inputShape.map { it.toLong() }.toLongArray()

                    // Create input tensor
                    val inputTensor = Tensor.fromBlob(floatArray, longArray)
            
                    // Run the model
                    val outputTensor = module.forward(IValue.from(inputTensor)).toTensor()
            
                    // Extract the result
                    val outputData = outputTensor.dataAsFloatArray
                    result.success(outputData)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun assetFilePath(context: Context, asset: String): String {
        val file = File(context.filesDir, asset)

        try {
            val inpStream: InputStream = context.assets.open(asset)
            try {
                val outStream = FileOutputStream(file, false)
                val buffer = ByteArray(4 * 1024)
                var read: Int

                while (true) {
                    read = inpStream.read(buffer)
                    if (read == -1) {
                        break
                    }
                    outStream.write(buffer, 0, read)
                }
                outStream.flush()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return ""
    }
}
