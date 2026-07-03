package shortcode.fintraqr.com

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.URLEncoder

class MainActivity : FlutterActivity() {
    private val channelName = "shortcode.fintraqr.com/phone"
    private val pickContactRequestCode = 1530
    private var pendingContactResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "dial" -> handleDial(call, result)
                    "pickContactPhone" -> handlePickContact(result)
                    "shareText" -> handleShareText(call, result)
                    "openUrl" -> handleOpenUrl(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleDial(call: MethodCall, result: MethodChannel.Result) {
        val code = call.argument<String>("code")
        if (code.isNullOrBlank()) {
            result.error("INVALID_CODE", "Enter a shortcode before dialing.", null)
            return
        }

        val encoded = URLEncoder.encode(code, "UTF-8")
        val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$encoded"))
        if (intent.resolveActivity(packageManager) == null) {
            result.error("NO_DIALER", "No phone dialer is available on this device.", null)
            return
        }

        startActivity(intent)
        result.success(null)
    }

    private fun handlePickContact(result: MethodChannel.Result) {
        if (pendingContactResult != null) {
            result.error("PICK_IN_PROGRESS", "Contact picker is already open.", null)
            return
        }

        val intent = Intent(
            Intent.ACTION_PICK,
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
        )

        if (intent.resolveActivity(packageManager) == null) {
            result.error("NO_CONTACTS", "No contact picker is available on this device.", null)
            return
        }

        pendingContactResult = result
        startActivityForResult(intent, pickContactRequestCode)
    }

    private fun handleShareText(call: MethodCall, result: MethodChannel.Result) {
        val text = call.argument<String>("text")
        if (text.isNullOrBlank()) {
            result.error("INVALID_SHARE_TEXT", "Nothing to share yet.", null)
            return
        }

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }

        startActivity(Intent.createChooser(intent, "Share Shortcode"))
        result.success(null)
    }

    private fun handleOpenUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("INVALID_URL", "No link was provided.", null)
            return
        }

        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        result.success(null)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != pickContactRequestCode) return

        val result = pendingContactResult ?: return
        pendingContactResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        result.success(readPhoneNumber(data.data!!))
    }

    private fun readPhoneNumber(uri: Uri): String? {
        val projection = arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER)
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)
        cursor.use {
            if (it == null || !it.moveToFirst()) return null
            val index = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
            if (index < 0) return null
            return it.getString(index)
        }
    }
}
