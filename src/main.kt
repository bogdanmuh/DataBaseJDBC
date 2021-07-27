fun main() {
    //val db = DBController("test")
    val dbHelper = DBHelper("mukhutdinov 05-804")
    dbHelper.apply {

        dropAllTables()
        createDataBaseFromDump("src/main/kotlin/students.sql")
        fillTableFromCSV("cathedras", "data/cathedras.csv")
        fillTableFromCSV("disciplines", "data/disciplines.csv")
        fillTableFromCSV("specializations", "data/specializations.csv")
        fillTableFromCSV("academic_plans", "data/academic_plans.csv")
        fillTableFromCSV("groups", "data/groups.csv")
        fillTableFromCSV("disciplines_plans", "data/disciplines_plans.csv")
        fillTableFromCSV("students", "data/students.csv")
        fillTableFromCSV("performance", "data/performance.csv")
        findStudentWhoHasGrant()
    }
    println("выведите человека для которого нужно  вывести приложеник к диплому")
    var  person  = readLine()
    val l =  person?.toInt() ?: -1
    if (l!=-1) { dbHelper.DiplomaSupplement(l) }
    else {println("видите корректное число")}
}