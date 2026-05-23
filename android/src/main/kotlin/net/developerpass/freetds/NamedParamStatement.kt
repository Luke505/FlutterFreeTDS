package net.developerpass.freetds

import com.sybase.jdbc4.jdbc.SybConnection
import com.sybase.jdbc4.jdbc.SybPreparedStatement
import org.jdbi.v3.core.statement.ColonPrefixSqlParser
import org.jdbi.v3.core.statement.ParsedSql
import org.jdbi.v3.core.statement.SqlParser
import java.io.Closeable
import java.sql.ResultSet
import java.sql.SQLException
import java.util.regex.Matcher
import java.util.regex.Pattern

class NamedParamStatement(conn: SybConnection, sql: String) : Closeable {
	val parsed: ParsedSql
	val preparedStatement: SybPreparedStatement
	private val fields: MutableMap<String, MutableList<Int>> = HashMap()

	val resultSet: ResultSet?
		get() = preparedStatement.resultSet

	val updateCount: Int
		get() = preparedStatement.updateCount

	init {
		var sql = sql
		val findParametersRegex = "(?<!')(:\\w*)(?!')"
		val findParametersPattern: Pattern = Pattern.compile(findParametersRegex)
		val matcher: Matcher = findParametersPattern.matcher(sql)
		var index = 0
		while (matcher.find()) {
			fields.getOrPut(matcher.group().substring(1)) { mutableListOf() }.apply {
				add(index++)
			}
		}

		val parser: SqlParser = ColonPrefixSqlParser()
		parsed = parser.parse(sql, null)
		this.preparedStatement = conn.prepareStatement(parsed.sql) as SybPreparedStatement
	}

	@Throws(SQLException::class)
	override fun close() =
		preparedStatement.close()

	@Throws(SQLException::class)
	fun execute(): Boolean =
		preparedStatement.execute()

	@Throws(SQLException::class)
	fun setNull(index: Int) =
		preparedStatement.setNull(index, -1)

	@Throws(SQLException::class)
	fun setObject(index: Int, value: Any) =
		preparedStatement.setObject(index, value)

	fun getParameterNames(): List<String?> =
		parsed.parameters.parameterNames
}
