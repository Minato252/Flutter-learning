class SqlTable {
  static final String sql_createTable_course = """
    CREATE TABLE course (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    courseId INTEGER NOT NULL UNIQUE, 
    title TEXT NOT NULL, 
    clPublic INTEGER,
    orders INTEGER);
    """;
  static final String sql_createTable_user = """
    CREATE TABLE user (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    uid INTEGER NOT NULL UNIQUE, 
    phone TEXT NOT NULL UNIQUE, 
    nickName TEXT,
    portrait TEXT);
    """;

  static final String sql_createTable_message = """
    CREATE TABLE message (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    userId INTEGER NOT NULL, 
    targetId INTEGER NOT NULL, 
    keyWords TEXT NOT NULL, 
    title TEXT NOT NULL,
    htmlCode TEXT NOT NULL);
    """;
}
