package net.developerpass.freetds

import android.util.Log
import android.os.Handler
import android.os.Looper
import com.google.gson.GsonBuilder
import com.google.gson.JsonPrimitive
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import com.google.gson.reflect.TypeToken
import com.sybase.jdbc4.jdbc.SybConnection
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Type
import java.sql.Date
import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.Timestamp
import java.sql.Types
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.Executors


class FlutterFreeTdsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
	private lateinit var channel: MethodChannel
	private val mainHandler = Handler(Looper.getMainLooper())
	private val exec = Executors.newSingleThreadExecutor()
	private val gson = GsonBuilder().let { gson ->
		val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT)
		val timestampFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.ROOT)

		val dateSerializer = JsonSerializer { src: Date, _: Type?, _: JsonSerializationContext? ->
			JsonPrimitive(dateFormat.format(src))
		}
		val timestampSerializer = JsonSerializer { src: Timestamp, _: Type?, _: JsonSerializationContext? ->
			JsonPrimitive(timestampFormat.format(src))
		}

		gson.registerTypeAdapter(Date::class.java, dateSerializer)
			.registerTypeAdapter(Timestamp::class.java, timestampSerializer)
			.create()
	}

	data class QueryParam(
		val name: String?,
		val value: Any?,
	)

	@Volatile
	private var connection: SybConnection? = null

	override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
		channel = MethodChannel(binding.binaryMessenger, "freetds")
		channel.setMethodCallHandler(this)
	}

	override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
		channel.setMethodCallHandler(null)
		exec.shutdown()
		closeQuietly()
	}

	override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
		when (call.method) {
			"connect" -> {
				val timeout: Int = call.argument<Int>("timeout") ?: return result.error("ARG", "Missing timeout", null)
				val host: String = call.argument<String>("host") ?: return result.error("ARG", "Missing host", null)
				val user: String? = call.argument<String>("user")
				val password: String? = call.argument<String>("password")
				val database: String? = call.argument<String>("database")
				runBg({
					// Load the driver explicitly; some DriverManager builds need it.
					Class.forName("com.sybase.jdbc4.jdbc.SybDriver")
					val url: String = "jdbc:sybase:Tds:" + host + "?${database?.let { "ServiceName=$it" } ?: ""}"
					DriverManager.setLoginTimeout(timeout);
					connection = DriverManager.getConnection(url, user, password) as SybConnection
					null
				}, result)
			}

			"isConnected" -> {
				val timeout: Int = call.argument<Int>("timeout") ?: return result.error("ARG", "Missing timeout", null)
				runBg({
					connection != null && connection!!.isValid(timeout)
				}, result)
			}

			"query" -> {
				val sql: String = call.argument<String>("sql") ?: return result.error("ARG", "Missing sql", null)
				val paramsJson: String? = call.argument<String>("params")
				val paramsType = object : TypeToken<List<QueryParam>>() {}.type
				val params: List<QueryParam>? = paramsJson?.let { gson.fromJson(it, paramsType) }
				runBg({
					val conn = connection ?: throw IllegalStateException("Not connected")
					NamedParamStatement(conn, sql).use { ps ->
						if (params != null) {
							bindParams(ps, params)
						}
						ps.execute()

						val (cols, rowsJson) = extractResultSet(ps.resultSet)

						mapOf(
							"affectedRows" to ps.updateCount,
							"columns" to cols,
							"data" to rowsJson
						)
					}
				}, result)
			}

			"disconnect" -> {
				runBg({
					closeQuietly()
					null
				}, result)
			}

			else -> result.notImplemented()
		}
	}

	private fun bindParams(ps: NamedParamStatement, params: List<QueryParam>) {
		val parameterNames = ps.getParameterNames()
		params.forEachIndexed { i, param ->
			val indexes = param.name?.let { name -> parameterNames.indexesOf(name) } ?: listOf(i)
			if (indexes.isEmpty()) {
				throw IllegalArgumentException(
					StringBuilder()
						.append("Parameter not found")
						.apply {
							if (param.name != null) {
								append(", name: ${param.name}")
							}
						}
						.append(", index: $i")
						.toString()
				)
			}

			indexes.forEach { index ->
				val index = index + 1
				if (param.value == null) {
					ps.setNull(index)
				} else {
					ps.setObject(index, param.value)
				}
			}
		}
	}

	private fun extractResultSet(resultSet: ResultSet?): Pair<List<String>, String> {
		if (resultSet == null) {
			return Pair(listOf(), "[]")
		}

		val cols: List<String>
		val rows: List<Map<String, Any?>>

		resultSet.use { rs ->
			cols = rs.metaData.let { md -> (1..md.columnCount).map { idx -> md.getColumnLabel(idx) ?: md.getColumnName(idx) } }
			rows = mapResultSet(rs, cols)
		}

		return Pair(cols, gson.toJson(rows))
	}

	private fun mapResultSet(rs: ResultSet, cols: List<String>): List<Map<String, Any?>> {
		val rows = mutableListOf<Map<String, Any?>>()
		val columnTypes = rs.metaData.let { md -> (1..md.columnCount).map { idx -> md.getColumnType(idx) } }
		while (rs.next()) {
			val row = LinkedHashMap<String, Any?>(cols.size)
			cols.forEachIndexed { index, col ->
				row[col] = mapResult(rs, col, columnTypes[index])
			}
			rows.add(row)
		}
		return rows
	}

	private fun mapResult(rs: ResultSet, col: String, columnType: Int): Any? {
		return if (columnType == Types.DATE) {
			if (rs.getDate(col) != null) rs.getDate(col).toString() else null
		} else if (columnType == Types.TIMESTAMP) {
			if (rs.getTimestamp(col) != null) rs.getTimestamp(col).toString() else null
		} else if (columnType == Types.TIME) {
			if (rs.getTime(col) != null) rs.getTime(col).toString() else null
		} else {
			rs.getObject(col)
		}
	}

	private fun closeQuietly() {
		try {
			connection?.close()
		} catch (_: Throwable) {
		}
		connection = null
	}

	private fun <T> runBg(block: () -> T, result: MethodChannel.Result) {
		exec.execute {
			try {
				val out = block()
				mainHandler.post { result.success(out) }
			} catch (t: Throwable) {
				Log.e("FlutterFreeTdsPlugin", "Failed to execute: ${t.message}", t)
				mainHandler.post {
					result.error("ERR", t.message ?: t.toString(), null)
				}
			}
		}
	}

	fun <T> List<T>.indexesOf(element: T): List<Int> =
		withIndex()
			.filter { it.value == element }
			.map { it.index }
}
