import java.io.File
import java.sql.*


class  DBHelper(
    private val dbName: String,
    private val address: String = "localhost",
    private val port: Int = 3306,
    private val user: String = "root",
    private val password: String = "root")
{
    private var connection: Connection? = null
    private var statement: Statement? = null

    init {
        connect()
    }



    private fun connect(){
        //Проверка на закрытое подключение.утверждение
        statement?.run{
            if (!isClosed) close()
        }
        var rep = 0
        //Попытка подключения к бд
        do {
            try {
                connection =
                    DriverManager.getConnection("jdbc:mysql://$address:$port/$dbName?serverTimezone=UTC",
                        user,
                        password
                    )
                statement =
                    DriverManager.getConnection("jdbc:mysql://$address:$port/$dbName?serverTimezone=UTC",
                        user,
                        password
                    ).createStatement()
            } catch (e: SQLSyntaxErrorException) {
                println("Ошибка подключения к бд ${dbName} : \n${e.toString()}")
                println("Попытка создания бд ${dbName}")
                val tstmt =
                    DriverManager.getConnection("jdbc:mysql://$address:$port/?serverTimezone=UTC", user, password)
                        .createStatement()
                tstmt.execute("CREATE SCHEMA `$dbName`")
                tstmt.closeOnCompletion()
                rep++
            }
        } while (statement == null && rep < 2)
    }

    fun dropAllTables(){
        println("Удаление всех таблиц в базе данных...")
        val s = connection?.createStatement()
        s?.execute("DROP TABLE if exists `performance`")
        s?.execute("DROP TABLE if exists `students`")
        s?.execute("DROP TABLE if exists `groups`")
        s?.execute("DROP TABLE if exists `disciplines_plans`")
        s?.execute("DROP TABLE if exists `academic_plans`")
        s?.execute("DROP TABLE if exists `disciplines`")
        s?.execute("DROP TABLE if exists `cathedras`")
        s?.execute("DROP TABLE if exists `specializations`")
        println("Все таблицы удалены.")


    }
    /**Функция для поиска студентов у которых  есть стипендия  */
    fun findStudentWhoHasGrant()
    {
        val sql = "SELECT group_id, last_name,first_name, mid_name,grants  from students,(SELECT student_id ,min(result),COUNT(attempt), \n" +
                "(case \n" +
                "when min(result)=5  then 3100 \n" +
                "when min(result)=4  then 2100\n" +
                "when min(result)=3  then 0\n" +
                "else 0 end) as grants\n" +
                "\n" +
                "FROM (SELECT `student_id`, `score`, `attempt`, `reporting_form`,\n" +
                "(CASE\n" +
                "WHEN `reporting_form` = \"экзамен\" AND `score` > 86 THEN 5\n" +
                "WHEN `reporting_form` = \"экзамен\" AND `score` > 70 THEN 4\n" +
                "WHEN `reporting_form` = \"экзамен\" AND `score` > 55 THEN 3\n" +
                "WHEN `reporting_form` = \"зачет\" AND `score` > 55 THEN 5\n" +
                "ELSE 0\n" +
                "END) AS `result`\n" +
                "FROM performance, disciplines_plans,\n" +
                "(SELECT `students`.`id`, current_semester FROM `students` ,\n" +
                "(SELECT year, groups.id, 2*(YEAR(NOW()) - year) - (CASE WHEN MONTH(NOW()) > 6 THEN 1 ELSE 0 END) AS `current_semester`\n" +
                "FROM `groups`, `academic_plans` WHERE `groups`.`academic_plan_id` = `academic_plans`.`id`) AS `group_cs`\n" +
                "WHERE `students`.`group_id` = `group_cs`.`id`) AS `swcs` WHERE performance.student_id = swcs.id\n" +
                "AND disciplines_plans.id = performance.disciplines_plan_id\n" +
                "AND swcs.current_semester = disciplines_plans.semester_number + 1)\n" +
                "AS `rank` GROUP BY `student_id`) AS `swsh` WHERE `students`.`id` = swsh.student_id ORDER BY group_id, last_name,first_name, mid_name"
        val rs =  statement?.executeQuery(sql)
        var i =0
        while (rs?.next()==true){
            print( "$i "+ rs.getString(1)+"   "+rs.getString(2)+"   "+rs.getString(3) +"   "+rs.getString(4)+"   "+rs.getString(5)+"\n")
            i++
        }
    }
    /**Функция для создания приложение к диплому1
     * @param person id  студента  */
    fun DiplomaSupplement(person:Int ){
        val sql = "SELECT  tb2.name, tb2.semester_number,tb2.hours,tb2.reporting_form ,performance.score from \n" +
                "(SELECT disciplines.name,tb1.semester_number,tb1.hours,tb1.reporting_form,tb1.id,tb1.discipline_id,tb1.plan from \n" +
                " (SELECT disciplines_plans.semester_number,disciplines_plans.hours,disciplines_plans.reporting_form,disciplines_plans.discipline_id,tb0.id,disciplines_plans.id as plan from \n" +
                "  (SELECT students.group_id,`groups`.academic_plan_id,students.id FROM students INNER JOIN `groups` on students.group_id=`groups`.id where students.id=1)\n" +
                "  as tb0 INNER join disciplines_plans ON disciplines_plans.academic_plan_id= tb0.academic_plan_id)\n" +
                " as tb1 inner join disciplines on tb1.discipline_id=disciplines.id)\n" +
                " as tb2 INNER join performance on performance.student_id=tb2.id and performance.disciplines_plan_id = tb2.plan"
        val rs =  statement?.executeQuery(sql)
        var i =0
        while (rs?.next()==true){
            print( "$i "+ rs.getString(1)+"   "+rs.getString(2)+"   "+rs.getString(3) +"   "+rs.getString(4)+"   "+rs.getString(5)+"\n")
            i++
        }
    }
    /**Функция, создающая таблицы в базе данных на основе SQL-дампа
     * @param path путь до SQL-дампа*/
    fun createDataBaseFromDump(path: String){
        println("Создание структуры базы данных из дампа...")
        try {
            var query = ""
            File(path).forEachLine {
                if(!it.startsWith("--") && it.isNotEmpty()){
                    query += it
                    if (it.endsWith(';')) {
                        statement?.addBatch(query)
                        query = ""
                    }
                }
            }
            statement?.executeBatch()
            println("Структура базы данных успешно создана.")
        }catch (e: SQLException){ println(e.message)
        }catch (e: Exception){ println(e.message)}
    }
    /**Функция для заполнения таблицы из CSV - файла
     * @param table название таблицы в базе данных
     * @param path путь до источника данных (CSV - файла)
     * TODO Добавить Exception для ощибок с чтением файла*/
    fun fillTableFromCSV(table: String, path: String){

        println("Заполнение таблицы $table из файла $path")
        val s = connection?.createStatement()
        try {
            var requestTemplate = "INSERT INTO `${table}` "
            val dataBufferedReader = File(path).bufferedReader()
            val columns = dataBufferedReader.readLine()
                .split(',',';')
                .toString()
            requestTemplate += "(${columns.substring(1, columns.length - 1)}) VALUES "

            while (dataBufferedReader.ready()){
                var request = "$requestTemplate("
                val data = dataBufferedReader.readLine().split(',')
                data.forEachIndexed{i, column ->
                    request += "\"$column\""
                    if (i < data.size - 1) request += ','
                }
                request += ')'
                s?.addBatch(request)
            }
            s?.executeBatch()
            s?.clearBatch()

        }catch (e: SQLException){ println(e)}
    }
}