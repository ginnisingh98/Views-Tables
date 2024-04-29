--------------------------------------------------------
--  DDL for Package Body XLA_UTILITY_PROFILER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_UTILITY_PROFILER_PKG" AS
/* $Header: xlacmupr.pkb 120.6 2005/10/22 00:09:38 awan ship $ */
/*======================================================================+
|             Copyright (c) 2000-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_utility_profiler_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Utility profiler_Package                                       |
|                                                                       |
|    Debug/Profiler activities.                                         |
|                                                                       |
| HISTORY                                                               |
|    12-Jan-00 P. Labrevois    Created                                  |
|    08-Feb-01                 Created for XLA                          |
|    20-Oct-05 A.Wan           Bug 4693865 remove g_keep_going          |
+=======================================================================*/


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Activate_profiler                                                     |
|                                                                       |
| Activate the profiler.                                                |
|                                                                       |
+======================================================================*/
PROCEDURE start_profiler

IS

l_cr                           INTEGER;

BEGIN
--
-- To be uncommented when dbms_profiler is installed
--
l_cr := dbms_profiler.start_profiler(xla_utility_pkg.g_unique_location);

NULL;

END start_profiler;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Stop_profiler                                                         |
|                                                                       |
| Unactivate the profiler.                                              |
|                                                                       |
+======================================================================*/
PROCEDURE stop_profiler

IS

l_cr                           INTEGER;

BEGIN
--
-- To be uncommented when dbms_profiler is installed
--
l_cr :=  dbms_profiler.stop_profiler;
l_cr :=  dbms_profiler.flush_data;

END stop_profiler;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_profiler_data                                                    |
|                                                                       |
| Print the information from the profiler                               |
|                                                                       |
+======================================================================*/
PROCEDURE  dump_profiler_data

IS

l_statement_runid              VARCHAR2(4000);
l_statement_unit               VARCHAR2(4000);
l_statement_data               VARCHAR2(4000);
l_rows_runid                   INTEGER;
l_rows_unit                    INTEGER;
l_rows_data                    INTEGER;
l_cr_runid                     INTEGER;
l_cr_unit                      INTEGER;
l_cr_data                      INTEGER;
l_runid                        INTEGER;
l_unit_number                  INTEGER;
l_unit_type                    VARCHAR2(30);
l_unit_name                    VARCHAR2(30);
l_text                         VARCHAR2(2000);
l_total_occur                  INTEGER;
l_total_time                   INTEGER;
l_min_time                     INTEGER;
l_max_time                     INTEGER;
c_chr                          CONSTANT VARCHAR2(9) := xla_environment_pkg.g_chr_newline;
l_table_not_exist              EXCEPTION;

PRAGMA exception_init         (l_table_not_exist    , -0942);

BEGIN
xla_utility_pkg.trace(RPAD('+',76,'-')||'+'                             ,-10);
xla_utility_pkg.trace('Profiler info'                                   ,-10);

--
-- Get the runid
--
l_statement_runid := 'SELECT runid       '
                ||   xla_environment_pkg.g_chr_newline
                ||   'FROM   plsql_profiler_runs   '
                ||   xla_environment_pkg.g_chr_newline
                ||   'WHERE  run_comment   = '''||xla_utility_pkg.g_unique_location||'''';

-- xla_utility_pkg.trace(l_statement_runid                                     ,  50);

l_cr_runid        := dbms_sql.open_cursor;

dbms_sql.parse
   (l_cr_runid
   ,l_statement_runid
   ,dbms_sql.native);

dbms_sql.define_column
   (l_cr_runid
   ,1
   ,l_runid);

l_rows_runid      := dbms_sql.execute_and_fetch(l_cr_runid);

dbms_sql.column_value
   (l_cr_runid
   ,1
   ,l_runid);

dbms_sql.close_cursor(l_cr_runid);


--
-- Prepare to fetch accross all units
--
l_statement_unit  := 'SELECT unit_type '
                ||   xla_environment_pkg.g_chr_newline
                ||   '      ,unit_name '
                ||   xla_environment_pkg.g_chr_newline
                ||   '      ,unit_number '
                ||   xla_environment_pkg.g_chr_newline
                ||   'FROM   plsql_profiler_units  '
                ||   xla_environment_pkg.g_chr_newline
                ||   'WHERE  runid          = '||l_runid||' '
                ||   xla_environment_pkg.g_chr_newline
                ||   '  AND  unit_name NOT IN (''DBMS_PROFILER'' '
                ||   xla_environment_pkg.g_chr_newline
                ||   '                        ,''<anonymous>'') ';

-- xla_utility_pkg.trace(l_statement_unit                                      ,  50);

l_cr_unit         := dbms_sql.open_cursor;

dbms_sql.parse
   (l_cr_unit
   ,l_statement_unit
   ,dbms_sql.native);

dbms_sql.define_column
   (l_cr_unit
   ,1
   ,l_unit_type
   ,255);

dbms_sql.define_column
   (l_cr_unit
   ,2
   ,l_unit_name
   ,255);

dbms_sql.define_column
   (l_cr_unit
   ,3
   ,l_unit_number);

l_rows_unit       := dbms_sql.execute(l_cr_unit);

--
-- Fetch accross all units
--

LOOP
   IF dbms_sql.fetch_rows (l_cr_unit) >0 THEN
      dbms_sql.column_value(l_cr_unit,1,l_unit_type);
      dbms_sql.column_value(l_cr_unit,2,l_unit_name);
      dbms_sql.column_value(l_cr_unit,3,l_unit_number);

      xla_utility_pkg.trace(l_unit_name                                           ,-10);
      xla_utility_pkg.trace(''                                                    ,-10);

      l_statement_data  := 'SELECT s.text '
              || c_chr ||  '      ,d.total_occur '
              || c_chr ||  '      ,d.total_time '
              || c_chr ||  '      ,d.min_time '
              || c_chr ||  '      ,d.max_time '
              || c_chr ||  'FROM   plsql_profiler_data    d '
              || c_chr ||  '      ,user_source            s '
              || c_chr ||  'WHERE  s.type            = ''' || l_unit_type   ||''' '
              || c_chr ||  '  AND  s.name            = ''' || l_unit_name   ||''' '
              || c_chr ||  '  AND  d.runid (+)       =   ' || l_runid
              || c_chr ||  '  AND  d.unit_number (+) =   ' || l_unit_number
              || c_chr ||  '  AND  d.line# (+)       = s.line '
              || c_chr ||  'ORDER BY '
              || c_chr ||  '       s.line';

      l_cr_data         := dbms_sql.open_cursor;

      dbms_sql.parse (l_cr_data
                     ,l_statement_data
                     ,dbms_sql.native);

      dbms_sql.define_column
         (l_cr_data
         ,1
         ,l_text
         ,255);

      dbms_sql.define_column
         (l_cr_data
         ,2
         ,l_total_occur);

      dbms_sql.define_column
         (l_cr_data
         ,3
         ,l_total_time);

      dbms_sql.define_column
         (l_cr_data
         ,4
         ,l_min_time);

      dbms_sql.define_column
         (l_cr_data
         ,5
         ,l_max_time);

      l_rows_data := dbms_sql.execute(l_cr_data);

      LOOP
         IF dbms_sql.fetch_rows (l_cr_data) >0 THEN

            dbms_sql.column_value(l_cr_data, 1,l_text         );
            dbms_sql.column_value(l_cr_data, 2,l_total_occur  );
            dbms_sql.column_value(l_cr_data, 3,l_total_time   );
            dbms_sql.column_value(l_cr_data, 4,l_min_time     );
            dbms_sql.column_value(l_cr_data, 5,l_max_time     );

            xla_utility_pkg.trace       ('! '
                      || SUBSTR(
                                RPAD(
                                     REPLACE(l_text ,xla_environment_pkg.g_chr_newline,''),75,' '),1,75)
                      || ' '
                      ||    TO_CHAR(l_total_occur,'999999')
                      ||    TO_CHAR(l_total_time/1000000000 ,'99999.9999999')
                      ||    TO_CHAR(l_min_time  /1000000000 ,'99999.9999999')
                      ||    TO_CHAR(l_max_time  /1000000000 ,'99999.9999999'),-10);
         ELSE
            EXIT;
         END IF;
      END LOOP;

      dbms_sql.close_cursor(l_cr_data);

   ELSE
      EXIT;
   END IF;

END LOOP;

dbms_sql.close_cursor(l_cr_unit);

EXCEPTION
WHEN l_table_not_exist THEN
      xla_exceptions_pkg.raise_message
        (p_appli_s_name => 'XLA'
        ,p_msg_name     => 'XLA_DEBUG_PROFILER'
        );
END  dump_profiler_data;


END xla_utility_profiler_pkg;

/
