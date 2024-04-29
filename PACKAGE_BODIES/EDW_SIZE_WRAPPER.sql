--------------------------------------------------------
--  DDL for Package Body EDW_SIZE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SIZE_WRAPPER" AS
/* $Header: EDWAUTSB.pls 115.14 2004/02/13 05:10:48 smulye noship $*/

PROCEDURE function_call(errbuf            OUT NOCOPY VARCHAR2,
                        retcode           OUT NOCOPY VARCHAR2,
                        p_log_name        IN   VARCHAR2,
                        p_from_date       IN   VARCHAR2,
                        p_to_date         IN   VARCHAR2,
                        p_input_num_rows  IN   NUMBER DEFAULT 0,
                        p_custom          IN   NUMBER DEFAULT 0,
                        p_commit_size     IN   NUMBER DEFAULT 10000) IS


api_CLAUSE          VARCHAR2(2400);
l_cursor_id         NUMBER;
l_dummy             NUMBER;
l_avg_row_len       NUMBER;
l_num_rows          NUMBER;
l_row_cnt_proc_name         VARCHAR2(120) := null;
l_row_len_proc_name         VARCHAR2(120) := null;
l_pack_name              VARCHAR2(120) := null;
l_pack_name_tmp              VARCHAR2(10) := null;
l_package_found     NUMBER := 0;
l_count             NUMBER := 0;
l_count1             NUMBER := 1;
l_loop_cnt             NUMBER := 0;

TABLE_NOT_FOUND      EXCEPTION;
PROCEDURE_NOT_FOUND  EXCEPTION;
PACKAGE_NOT_FOUND    EXCEPTION;
PARAMETER_NULL       EXCEPTION;

CURSOR c_get_schema IS
   select table_name, table_owner, table_type
   from  EDW_SIZE_INPUT where
   table_logical_name like p_log_name || '%';

CURSOR c_get_proc_name IS
   select num_rows_proc_name, row_len_proc_name
   from  EDW_SIZE_INPUT where table_owner = g_schema
   and table_name = g_table_name;

CURSOR c_get_all_objects IS
   select num_rows_proc_name, row_len_proc_name, table_name, table_owner,
                   table_type, table_logical_name
   from  EDW_SIZE_INPUT order by table_owner;

/*
 changed from all_objects to user_objects by amitgupt
 for impact analysis changes
*/
CURSOR c_check_pack IS
   select count(*)
   from  user_objects where object_type = 'PACKAGE BODY'
   and object_name = l_pack_name;


BEGIN

/*   api_CLAUSE :=  'exec ' || p_table_name||'_SIZE.init_all(''' || p_table_name ||
   ''', '''|| p_schema || ''', ''' || p_from_date ||''', ''' || p_to_date || ''', '''
   || p_output_file || ''')' ;     */

   errbuf  := null;
   retcode := 0;

   g_from_date  := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
   g_to_date    := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
   g_custom     := p_custom;
   g_commit_size    := p_commit_size;

   IF (p_log_name ^= 'ALL') THEN
      g_log_name := p_log_name;
      l_package_found := 1;

      OPEN c_get_schema;
         FETCH c_get_schema INTO g_table_name, g_schema, g_table_type;
         IF c_get_schema%NOTFOUND THEN
            RAISE TABLE_NOT_FOUND;
         END IF;
      CLOSE c_get_schema;

      OPEN c_get_proc_name;
           FETCH c_get_proc_name INTO l_row_cnt_proc_name, l_row_len_proc_name;
      CLOSE c_get_proc_name;

      l_loop_cnt := length(l_row_cnt_proc_name);
      FOR l_count1 in 1.. l_loop_cnt LOOP
          l_pack_name_tmp := substr(l_row_cnt_proc_name, l_count1, 1);
          IF l_pack_name_tmp = '.' THEN
             l_pack_name := substr(l_row_cnt_proc_name, 1, l_count1 - 1);
 -- dbms_output.put_line('l_pack_name =  ' || l_pack_name );
             EXIT;
          END IF;
      END LOOP;

      OPEN c_check_pack;
         FETCH c_check_pack INTO l_package_found;
      CLOSE c_check_pack;
      IF l_package_found = 0 THEN
         g_message := 'Package ' || l_pack_name || ' (for object ' || p_log_name
                      || ') not existing in the database. ';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;
      ELSE
        api_CLAUSE :=  'begin ' || l_row_len_proc_name ||' (:s1, :s2, :s3) ; end; ';

        l_cursor_id := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor_id ,api_CLAUSE, DBMS_SQL.V7);
        dbms_sql.bind_variable(l_cursor_id, ':s1', g_from_date);
        dbms_sql.bind_variable(l_cursor_id, ':s2', g_to_date);
        dbms_sql.bind_variable(l_cursor_id, ':s3', l_avg_row_len);
        l_dummy := dbms_sql.execute(l_cursor_id);
        dbms_sql.variable_value(l_cursor_id, ':s3', l_avg_row_len);
        dbms_sql.close_cursor(l_cursor_id);

        IF p_input_num_rows = 0 THEN
           api_CLAUSE :=  'begin ' || l_row_cnt_proc_name ||' (:s1, :s2, :s3) ; end; ';

           l_cursor_id := dbms_sql.open_cursor;
           dbms_sql.parse(l_cursor_id, api_CLAUSE, DBMS_SQL.V7);
           dbms_sql.bind_variable(l_cursor_id, ':s1', g_from_date);
           dbms_sql.bind_variable(l_cursor_id, ':s2', g_to_date);
           dbms_sql.bind_variable(l_cursor_id, ':s3', l_num_rows);
           l_dummy := dbms_sql.execute(l_cursor_id);
           dbms_sql.variable_value(l_cursor_id, ':s3', l_num_rows);
           dbms_sql.close_cursor(l_cursor_id);
        ELSE
           l_num_rows := p_input_num_rows;
        END IF;

        --  Start calculation and write the results into a file.
        calculate_detail(l_avg_row_len, l_num_rows);
      END IF;

    ELSE
      OPEN c_get_all_objects;
      LOOP
         FETCH c_get_all_objects INTO l_row_cnt_proc_name, l_row_len_proc_name,
               g_table_name, g_schema, g_table_type, g_log_name;
      EXIT WHEN c_get_all_objects%NOTFOUND;

      IF g_log_name = 'ALL' THEN
         null;
      ELSE
         IF l_row_len_proc_name is null or l_row_cnt_proc_name is null THEN
            RAISE PROCEDURE_NOT_FOUND;
         END IF;

         l_package_found := 1;
         l_loop_cnt := length(l_row_cnt_proc_name);
         FOR l_count1 in 1.. l_loop_cnt LOOP
            l_pack_name_tmp := substr(l_row_cnt_proc_name, l_count1, 1);
            IF l_pack_name_tmp = '.' THEN
               l_pack_name := substr(l_row_cnt_proc_name, 1, l_count1 - 1);
               EXIT;
            END IF;
         END LOOP;

         OPEN c_check_pack;
            FETCH c_check_pack INTO l_package_found;
         CLOSE c_check_pack;
         IF l_package_found = 0 THEN
            g_message := 'Package ' || l_pack_name || ' (for object ' || g_log_name
                         || ') not existing in the database. ';
            fnd_file.put_line(FND_FILE.LOG, g_message) ;
            fnd_file.put_line(FND_FILE.LOG, '           ') ;
            -- RAISE PACKAGE_NOT_FOUND;
         ELSE
           api_CLAUSE :=  'begin ' || l_row_len_proc_name ||' (:s1, :s2, :s3) ; end; ';

           l_cursor_id := dbms_sql.open_cursor;
           dbms_sql.parse(l_cursor_id ,api_CLAUSE, DBMS_SQL.V7);
           dbms_sql.bind_variable(l_cursor_id, ':s1', g_from_date);
           dbms_sql.bind_variable(l_cursor_id, ':s2', g_to_date);
           dbms_sql.bind_variable(l_cursor_id, ':s3', l_avg_row_len);
           l_dummy := dbms_sql.execute(l_cursor_id);
           dbms_sql.variable_value(l_cursor_id, ':s3', l_avg_row_len);
           dbms_sql.close_cursor(l_cursor_id);

           IF p_input_num_rows = 0 THEN
              api_CLAUSE :=  'begin ' || l_row_cnt_proc_name ||' (:s1, :s2, :s3) ; end; ';

              l_cursor_id := dbms_sql.open_cursor;
              dbms_sql.parse(l_cursor_id ,api_CLAUSE, DBMS_SQL.V7);
              dbms_sql.bind_variable(l_cursor_id, ':s1', g_from_date);
              dbms_sql.bind_variable(l_cursor_id, ':s2', g_to_date);
              dbms_sql.bind_variable(l_cursor_id, ':s3', l_num_rows);
              l_dummy := dbms_sql.execute(l_cursor_id);

              dbms_sql.variable_value(l_cursor_id, ':s3', l_num_rows);
              dbms_sql.close_cursor(l_cursor_id);
           ELSE
              l_num_rows := p_input_num_rows;
           END IF;

           --  Start calculation and write the results into a file.
           calculate_detail(l_avg_row_len, l_num_rows);
         END IF;
      END IF;

      END LOOP;
      CLOSE c_get_all_objects;

      fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
      fnd_file.put_line(FND_FILE.OUTPUT, 'In Summary ') ;
      fnd_file.put_line(FND_FILE.OUTPUT, '------------------------------------------------') ;
      fnd_file.put_line(FND_FILE.OUTPUT, 'The total space of indeces for all objects is (MB): '
                        || ceil(g_all_index_space/1024/1024)) ;
      fnd_file.put_line(FND_FILE.OUTPUT, 'The total space of tables for all objects is (MB): '
                        || ceil(g_all_table_space/1024/1024)) ;
      fnd_file.new_line(FND_FILE.OUTPUT, 2) ;

   END IF;

   EXCEPTION
      WHEN TABLE_NOT_FOUND THEN
         g_message := 'No table is found from EDW_SIZE_INPUT. ';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;
      WHEN PROCEDURE_NOT_FOUND THEN
         g_message := 'Procedure name ' || l_row_cnt_proc_name
                           || ' not found from table EDW_SIZE_INPUT. ';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;
      WHEN PACKAGE_NOT_FOUND THEN
         g_message := 'Package ' || l_pack_name
                           || ' not existing in the database. ';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;
      WHEN PARAMETER_NULL THEN
         g_message := 'The parameter can not be null. ';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;
      WHEN OTHERS THEN
         IF sqlerrm = 'ORA-06502' or sqlerrm = 'ORA-06550' THEN
            g_message := 'Package ' || l_pack_name || ' has error ' || sqlerrm;
            fnd_file.put_line(FND_FILE.LOG, g_message) ;
            fnd_file.put_line(FND_FILE.LOG, '           ') ;
         ELSE
            errbuf  := sqlerrm;
            retcode := sqlcode;
            fnd_file.put_line(FND_FILE.LOG, errbuf) ;
            fnd_file.put_line(FND_FILE.LOG, '           ') ;
         END IF;

END function_call;   -- procedure function_call.

PROCEDURE calculate_detail (p_avg_row_len NUMBER, p_num_rows NUMBER) IS

l_TBL_s         NUMBER := 0;
l_TBL_l         NUMBER := 0;
l_TBL_t         NUMBER := 0;
l_IND_s         NUMBER := 0;
l_IND_l         NUMBER := 0;
l_IND_t         NUMBER := 0;
l_pct_s         NUMBER := 0;
l_pct_l         NUMBER := 0;
l_pct_t         NUMBER := 0;
l_tbl_size_s    NUMBER := 0;
l_ind_size_s    NUMBER := 0;
l_tbl_size_l    NUMBER := 0;
l_ind_size_l    NUMBER := 0;
l_tbl_size_t    NUMBER := 0;
l_ind_size_t    NUMBER := 0;
l_temp_tbl_size    NUMBER := 0;
l_temp_size        NUMBER := 0;
l_temp_size_source    NUMBER := 0;
l_total_pem_space     NUMBER := 0;
l_total_tmp_space     NUMBER := 0;
l_rb_size      NUMBER := 0;
l_constant1    NUMBER := 0;
l_constant2    NUMBER := 0;
l_constant3    NUMBER := 0;
l_constant4    NUMBER := 0;
l_constant5    NUMBER := 0;
l_constant6    NUMBER := 0;
l_row_len_ss   NUMBER := 0;
l_row_len_m    NUMBER := 0;
l_row_len_l    NUMBER := 0;
l_TMP_TBL      NUMBER := 0;
l_TMP          NUMBER := 0;
l_RB           NUMBER := 0;
l_count        number := 0;
l_num_of_levels        number := 0;
l_from_date            varchar2(11);
l_to_date              varchar2(11);

CURSOR c_check IS
   select count(*)
   from EDW_SIZE_OUTPUT where
   table_name = g_table_name
   and owner = g_schema;

CURSOR c_get_cons_f IS
   select avg_row_len1, avg_row_len2, avg_row_len3, max_row_len_ss, max_row_len_m
   from  EDW_SIZE_INPUT where table_name = g_table_name
   and table_owner = g_schema;

CURSOR c_get_cons_m IS
   select num_of_levels, avg_row_len1, avg_row_len2, avg_row_len3,
   avg_row_len4, avg_row_len5, avg_row_len6, max_row_len_l
   from  EDW_SIZE_INPUT where table_name = g_table_name
   and table_owner = g_schema;


BEGIN

   l_from_date := to_char(g_from_date, 'DD-MON-YYYY');
   l_to_date   := to_char(g_to_date, 'DD-MON-YYYY');

   OPEN c_check;
       FETCH c_check INTO l_count;
   CLOSE c_check;

   IF g_table_type = 'FACT' THEN
      OPEN c_get_cons_f;
         FETCH c_get_cons_f INTO l_constant1, l_constant2, l_constant3,
         l_row_len_ss, l_row_len_m;
      CLOSE c_get_cons_f;

      l_TBL_s := p_avg_row_len + l_constant1 + g_custom;
      l_IND_s := l_constant2;
      l_TBL_t := p_avg_row_len + g_custom;
      l_IND_t := l_constant3;
      l_pct_s := 1 + 0.07;
      l_pct_l := 1 + 0.32;
      l_pct_t := 1 + 0.32;
      l_TMP_TBL := 2*l_TBL_s + l_TBL_t;
      l_TMP     := 2*l_row_len_m;
      l_RB      := l_TBL_s + l_TBL_t;

      l_tbl_size_s := ceil(p_num_rows*l_pct_s*l_TBL_s);
      l_ind_size_s := ceil(p_num_rows*l_pct_l*l_IND_s);
      l_tbl_size_t := ceil(p_num_rows*l_pct_t*l_TBL_t);
      l_ind_size_t := ceil(p_num_rows*l_pct_l*l_IND_t);

      l_temp_tbl_size    := g_commit_size*l_TMP_TBL;
      l_temp_size        := g_commit_size*l_TMP;
      l_rb_size          := g_commit_size*l_RB;
      l_temp_size_source := ceil(p_num_rows*1.15*l_TBL_s + g_commit_size*2*l_row_len_ss);

      l_total_pem_space := l_tbl_size_s + l_ind_size_s + l_tbl_size_t + l_ind_size_t;
      l_total_tmp_space := l_temp_tbl_size + l_temp_size + l_rb_size;

      IF (g_log_name ^= 'ALL') THEN
         g_all_index_space := g_all_index_space + l_ind_size_s + l_ind_size_t;
         g_all_table_space := g_all_table_space + l_tbl_size_s + l_tbl_size_t;
      END IF;

      IF l_count = 0 THEN
         insert into edw_size_output(
         TABLE_NAME,
         OWNER,
         TABLE_TYPE,
         TABLE_LOGICAL_NAME,
         AVG_ROW_LEN_STAGE,
         AVG_ROW_LEN,
         AVG_ROW_LEN_IND_S,
         AVG_ROW_LEN_IND,
         NUM_ROWS,
         TABLE_SIZE_STAGE,
         INDEX_SIZE_STAGE,
         TABLE_SIZE,
         INDEX_SIZE,
         TEMP_TABLE_SIZE,
         TEMP_SIZE,
         TEMP_SIZE_SOURCE,
         RB_SIZE,
         TOTAL_PEM_SPACE,
         TOTAL_TMP_SPACE,
         PCT_FREE_S,
         PCT_FREE_L,
         PCT_FREE,
         FROM_DATE,
         TO_DATE,
         LAST_UPDATE_DATE	,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE) values
      (  g_table_name,
         g_schema,
         g_table_type,
         g_log_name,
         l_TBL_s,
         l_TBL_t,
         l_IND_s,
         l_IND_t,
         p_num_rows,
         l_tbl_size_s,
         l_ind_size_s,
         l_tbl_size_t,
         l_ind_size_t,
         l_temp_tbl_size,
         l_temp_size,
         l_temp_size_source,
         l_rb_size,
         l_total_pem_space,
         l_total_tmp_space,
         l_pct_s,
         l_pct_l,
         l_pct_t,
         g_from_date,
         g_to_date,
         sysdate, 0, 0, 0, sysdate);
         g_message := 'Object logical name: ' || g_log_name ||
                      ', one record is inserted';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
      ELSE
         update edw_size_output set  TABLE_LOGICAL_NAME = g_log_name,
         OWNER = g_schema,
         AVG_ROW_LEN_STAGE = l_TBL_s,
         AVG_ROW_LEN = l_TBL_t,
         AVG_ROW_LEN_IND_S = l_IND_s,
         AVG_ROW_LEN_IND = l_IND_t,
         NUM_ROWS = p_num_rows,
         TABLE_SIZE_STAGE = l_tbl_size_s,
         INDEX_SIZE_STAGE = l_ind_size_s,
         TABLE_SIZE = l_tbl_size_t,
         INDEX_SIZE = l_ind_size_t,
         TEMP_TABLE_SIZE = l_temp_tbl_size,
         TEMP_SIZE = l_temp_size,
         TEMP_SIZE_SOURCE = l_temp_size_source,
         RB_SIZE = l_rb_size,
         TOTAL_PEM_SPACE = l_total_pem_space,
         TOTAL_TMP_SPACE = l_total_tmp_space,
         PCT_FREE_S = l_pct_s,
         PCT_FREE_L = l_pct_l,
         PCT_FREE = l_pct_t,
         FROM_DATE = g_from_date,
         TO_DATE = g_to_date,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = 0,
         LAST_UPDATE_LOGIN = 0,
         CREATED_BY = 0,
         CREATION_DATE = sysdate
         where table_name = g_table_name
         and owner = g_schema;
         g_message := 'Object logical name: ' || g_log_name ||
                      ', record is updated';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
      END IF;

      print_f(g_schema,
              l_from_date,
              l_to_date,
              l_temp_size_source,
              l_TBL_s,
              l_TBL_t,
              l_IND_s,
              l_IND_t,
              p_num_rows,
              l_tbl_size_s,
              l_ind_size_s,
              l_tbl_size_t,
              l_ind_size_t,
              l_temp_size,
              l_rb_size,
              l_temp_tbl_size,
              l_total_pem_space,
              l_total_tmp_space);


   -- calculate size for dimension.
   ELSIF g_table_type = 'DIMENSION' THEN
      OPEN c_get_cons_m;
         FETCH c_get_cons_m INTO l_num_of_levels, l_constant1, l_constant2,
         l_constant3, l_constant4, l_constant5, l_constant6, l_row_len_l;
      CLOSE c_get_cons_m;

      l_TBL_s := p_avg_row_len + l_constant1 + g_custom;
      l_IND_s := l_constant2;
      l_TBL_l := p_avg_row_len + l_constant3 + g_custom;
      l_IND_l := l_constant4;
      l_TBL_t := p_avg_row_len + l_constant5 + g_custom;
      l_IND_t := l_constant6;
      l_pct_s := 1 + 0.07;
      l_pct_l := 1 + 0.32;
      l_pct_t := 1 + 0.32;
      l_TMP_TBL := ceil(1.5*l_TBL_t);
      l_TMP     := 2*l_row_len_l;
      l_RB      := l_TBL_l + l_TBL_t;

      l_tbl_size_s := ceil(p_num_rows*l_pct_s*l_TBL_s/l_num_of_levels);
      l_ind_size_s := ceil(p_num_rows*l_pct_l*l_IND_s/l_num_of_levels);
      l_tbl_size_l := ceil(p_num_rows*l_pct_t*l_TBL_l/l_num_of_levels);
      l_ind_size_l := ceil(p_num_rows*l_pct_l*l_IND_l/l_num_of_levels);
      l_tbl_size_t := ceil(p_num_rows*l_pct_t*l_TBL_t);
      l_ind_size_t := ceil(p_num_rows*l_pct_l*l_IND_t);

      l_temp_tbl_size := g_commit_size*l_TMP_TBL;
      l_temp_size     := g_commit_size*l_TMP;
      l_rb_size       := g_commit_size*l_RB;

      l_total_pem_space := l_tbl_size_s + l_ind_size_s + l_tbl_size_l +
                           l_ind_size_l + l_tbl_size_t + l_ind_size_t;
      l_total_tmp_space := l_temp_tbl_size + l_temp_size + l_rb_size;

      IF (g_log_name ^= 'ALL') THEN
         g_all_index_space := g_all_index_space + l_ind_size_s + l_ind_size_l + l_ind_size_t;
         g_all_table_space := g_all_table_space + l_tbl_size_s + l_tbl_size_l + l_tbl_size_t;
      END IF;

      IF l_count = 0 THEN
         insert into edw_size_output(
         TABLE_NAME,
         OWNER,
         TABLE_TYPE,
         TABLE_LOGICAL_NAME,
         AVG_ROW_LEN_STAGE,
         AVG_ROW_LEN,
         AVG_ROW_LEN_LEVEL,
         AVG_ROW_LEN_IND_S,
         AVG_ROW_LEN_IND,
         AVG_ROW_LEN_IND_L,
         NUM_ROWS,
         TABLE_SIZE_STAGE,
         INDEX_SIZE_STAGE,
         TABLE_SIZE_LEVEL,
         INDEX_SIZE_LEVEL,
         TABLE_SIZE,
         INDEX_SIZE,
         TEMP_TABLE_SIZE,
         TEMP_SIZE,
         RB_SIZE,
         TOTAL_PEM_SPACE,
         TOTAL_TMP_SPACE,
         PCT_FREE_S,
         PCT_FREE_L,
         PCT_FREE,
         FROM_DATE,
         TO_DATE,
         LAST_UPDATE_DATE	,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE) values
      (  g_table_name,
         g_schema,
         g_table_type,
         g_log_name,
         l_TBL_s,
         l_TBL_t,
         l_TBL_l,
         l_IND_s,
         l_IND_t,
         l_IND_l,
         p_num_rows,
         l_tbl_size_s,
         l_ind_size_s,
         l_tbl_size_l,
         l_ind_size_l,
         l_tbl_size_t,
         l_ind_size_t,
         l_temp_tbl_size,
         l_temp_size,
         l_rb_size,
         l_total_pem_space,
         l_total_tmp_space,
         l_pct_s,
         l_pct_l,
         l_pct_t,
         g_from_date,
         g_to_date,
         sysdate, 0, 0, 0, sysdate);
         g_message := 'Object logical name: ' || g_log_name ||
                      ', one record is inserted';
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
      ELSE
         update edw_size_output set  TABLE_LOGICAL_NAME = g_log_name,
         OWNER = g_schema,
         AVG_ROW_LEN_STAGE = l_TBL_s,
         AVG_ROW_LEN = l_TBL_t,
         AVG_ROW_LEN_LEVEL = l_TBL_l,
         AVG_ROW_LEN_IND_S = l_IND_s,
         AVG_ROW_LEN_IND = l_IND_t,
         AVG_ROW_LEN_IND_L = l_IND_l,
         NUM_ROWS = p_num_rows,
         TABLE_SIZE_STAGE = l_tbl_size_s,
         INDEX_SIZE_STAGE = l_ind_size_s,
         TABLE_SIZE_LEVEL = l_tbl_size_l,
         INDEX_SIZE_LEVEL = l_ind_size_l,
         TABLE_SIZE = l_tbl_size_t,
         INDEX_SIZE = l_ind_size_t,
         TEMP_TABLE_SIZE = l_temp_tbl_size,
         TEMP_SIZE = l_temp_size,
         RB_SIZE = l_rb_size,
         TOTAL_PEM_SPACE = l_total_pem_space,
         TOTAL_TMP_SPACE = l_total_tmp_space,
         PCT_FREE_S = l_pct_s,
         PCT_FREE_L = l_pct_l,
         PCT_FREE = l_pct_t,
         FROM_DATE = g_from_date,
         TO_DATE = g_to_date,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = 0,
         LAST_UPDATE_LOGIN = 0,
         CREATED_BY = 0,
         CREATION_DATE = sysdate
         where table_name = g_table_name
         and owner = g_schema;
         g_message := 'Object logical name: ' || g_log_name ||
                      ', record is updated' ;
         fnd_file.put_line(FND_FILE.LOG, g_message) ;
      END IF;   -- l_count.

      print_m(g_schema,
              l_from_date,
              l_to_date,
              l_TBL_s,
              l_TBL_l,
              l_TBL_t,
              l_IND_s,
              l_IND_l,
              l_IND_t,
              p_num_rows,
              l_tbl_size_s,
              l_ind_size_s,
              l_tbl_size_l,
              l_ind_size_l,
              l_tbl_size_t,
              l_ind_size_t,
              l_temp_size,
              l_rb_size,
              l_temp_tbl_size,
              l_total_pem_space,
              l_total_tmp_space);

   END IF;   -- g_table_type.

END calculate_detail;

PROCEDURE show_results (errbuf        OUT NOCOPY VARCHAR2,
                        retcode       OUT NOCOPY VARCHAR2,
                        p_log_name    IN   VARCHAR2) IS


 v_TABLE_LOGICAL_NAME              VARCHAR2(240);
 v_TABLE_NAME                      VARCHAR2(70);
 v_TABLE_OWNER                     VARCHAR2(30);
 v_TABLE_TYPE                      VARCHAR2(30);
 v_AVG_ROW_LEN_STAGE               NUMBER;
 v_AVG_ROW_LEN_LEVEL               NUMBER;
 v_AVG_ROW_LEN                     NUMBER;
 v_AVG_ROW_LEN_IND_S               NUMBER;
 v_AVG_ROW_LEN_IND_L               NUMBER;
 v_AVG_ROW_LEN_IND                 NUMBER;
 v_NUM_ROWS                        NUMBER;
 v_TABLE_SIZE_STAGE                NUMBER;
 v_INDEX_SIZE_STAGE                NUMBER;
 v_TABLE_SIZE_LEVEL                NUMBER;
 v_INDEX_SIZE_LEVEL                NUMBER;
 v_TABLE_SIZE                      NUMBER;
 v_INDEX_SIZE                      NUMBER;
 v_TEMP_SIZE                       NUMBER;
 v_RB_SIZE                         NUMBER;
 v_TEMP_TABLE_SIZE                 NUMBER;
 v_TEMP_SIZE_SOURCE                NUMBER;
 v_TOTAL_PEM_SPACE                 NUMBER;
 v_TOTAL_TMP_SPACE                 NUMBER;
 v_FROM_DATE                       DATE;
 v_TO_DATE                         DATE;
 v_total_idx_space                 NUMBER := 0;
 v_total_tbl_space                 NUMBER := 0;
 l_FROM_DATE                       VARCHAR2(11);
 l_TO_DATE                         VARCHAR2(11);


NO_INFORMATION      EXCEPTION;

CURSOR c_get_type IS
   select  table_name, table_type
   from  EDW_SIZE_OUTPUT where table_logical_name = p_log_name;

CURSOR c_get_object_f IS
   select  TABLE_LOGICAL_NAME,
           OWNER,
           FROM_DATE,
           TO_DATE,
           TEMP_SIZE_SOURCE ,
           AVG_ROW_LEN_STAGE,
           AVG_ROW_LEN      ,
           AVG_ROW_LEN_IND_S,
           AVG_ROW_LEN_IND  ,
           NUM_ROWS         ,
           TABLE_SIZE_STAGE ,
           INDEX_SIZE_STAGE ,
           TABLE_SIZE       ,
           INDEX_SIZE       ,
           TEMP_SIZE        ,
           RB_SIZE          ,
           TEMP_TABLE_SIZE  ,
           TOTAL_PEM_SPACE  ,
           TOTAL_TMP_SPACE
   from  EDW_SIZE_OUTPUT where table_logical_name = p_log_name;

CURSOR c_get_object_m IS
   select  TABLE_LOGICAL_NAME,
           OWNER,
           FROM_DATE,
           TO_DATE,
           AVG_ROW_LEN_STAGE,
           AVG_ROW_LEN_LEVEL,
           AVG_ROW_LEN      ,
           AVG_ROW_LEN_IND_S,
           AVG_ROW_LEN_IND_L,
           AVG_ROW_LEN_IND  ,
           NUM_ROWS         ,
           TABLE_SIZE_STAGE ,
           INDEX_SIZE_STAGE ,
           TABLE_SIZE_LEVEL ,
           INDEX_SIZE_LEVEL ,
           TABLE_SIZE       ,
           INDEX_SIZE       ,
           TEMP_SIZE        ,
           RB_SIZE          ,
           TEMP_TABLE_SIZE  ,
           TEMP_SIZE_SOURCE ,
           TOTAL_PEM_SPACE  ,
           TOTAL_TMP_SPACE
   from  EDW_SIZE_OUTPUT where table_logical_name = p_log_name;

CURSOR c_get_objects IS
   select  TABLE_LOGICAL_NAME,
           TABLE_TYPE,
           OWNER,
           FROM_DATE,
           TO_DATE,
           AVG_ROW_LEN_STAGE,
           AVG_ROW_LEN_LEVEL,
           AVG_ROW_LEN      ,
           AVG_ROW_LEN_IND_S,
           AVG_ROW_LEN_IND_L,
           AVG_ROW_LEN_IND  ,
           NUM_ROWS         ,
           TABLE_SIZE_STAGE ,
           INDEX_SIZE_STAGE ,
           TABLE_SIZE_LEVEL ,
           INDEX_SIZE_LEVEL ,
           TABLE_SIZE       ,
           INDEX_SIZE       ,
           TEMP_SIZE        ,
           RB_SIZE          ,
           TEMP_TABLE_SIZE  ,
           TEMP_SIZE_SOURCE ,
           TOTAL_PEM_SPACE  ,
           TOTAL_TMP_SPACE
   from  EDW_SIZE_OUTPUT order by owner;

BEGIN

   g_log_name := p_log_name;
   IF g_log_name ^= 'ALL' THEN
      OPEN c_get_type;
         FETCH c_get_type INTO g_table_name, g_table_type;
      CLOSE c_get_type;

      IF g_table_name is null or g_table_name = 'null' THEN
         RAISE NO_INFORMATION;
      END IF;

      IF g_table_type = 'FACT' then
         OPEN c_get_object_f;
            FETCH c_get_object_f INTO g_log_name,
                                 g_schema,
                                 v_FROM_DATE,
                                 v_TO_DATE,
                                 v_TEMP_SIZE_SOURCE,
                                 v_AVG_ROW_LEN_STAGE,
                                 v_AVG_ROW_LEN,
                                 v_AVG_ROW_LEN_IND_S,
                                 v_AVG_ROW_LEN_IND,
                                 v_NUM_ROWS ,
                                 v_TABLE_SIZE_STAGE,
                                 v_INDEX_SIZE_STAGE ,
                                 v_TABLE_SIZE ,
                                 v_INDEX_SIZE ,
                                 v_TEMP_SIZE  ,
                                 v_RB_SIZE    ,
                                 v_TEMP_TABLE_SIZE,
                                 v_TOTAL_PEM_SPACE,
                                 v_TOTAL_TMP_SPACE;
         CLOSE c_get_object_f;
         l_FROM_DATE := to_char(v_FROM_DATE, 'DD-MON-YYYY');
         l_TO_DATE   := to_char(v_TO_DATE, 'DD-MON-YYYY');

         print_f(g_schema,
                   l_FROM_DATE,
                   l_TO_DATE,
                   v_TEMP_SIZE_SOURCE ,
                   v_AVG_ROW_LEN_STAGE  ,
                   v_AVG_ROW_LEN        ,
                   v_AVG_ROW_LEN_IND_S ,
                   v_AVG_ROW_LEN_IND   ,
                   v_NUM_ROWS          ,
                   v_TABLE_SIZE_STAGE  ,
                   v_INDEX_SIZE_STAGE  ,
                   v_TABLE_SIZE         ,
                   v_INDEX_SIZE        ,
                   v_TEMP_SIZE         ,
                   v_RB_SIZE           ,
                   v_TEMP_TABLE_SIZE   ,
                   v_TOTAL_PEM_SPACE   ,
                   v_TOTAL_TMP_SPACE );
         g_message := 'Information for object ' || g_log_name || 'is printed. ';
         fnd_file.put_line(FND_FILE.LOG, g_message ) ;

      ELSIF g_table_type = 'DIMENSION' then
         OPEN c_get_object_m;
            FETCH c_get_object_m INTO g_log_name,
                                 g_schema,
                                 v_FROM_DATE,
                                 v_TO_DATE,
                                 v_AVG_ROW_LEN_STAGE,
                                 v_AVG_ROW_LEN_LEVEL,
                                 v_AVG_ROW_LEN,
                                 v_AVG_ROW_LEN_IND_S,
                                 v_AVG_ROW_LEN_IND_L,
                                 v_AVG_ROW_LEN_IND,
                                 v_NUM_ROWS ,
                                 v_TABLE_SIZE_STAGE,
                                 v_INDEX_SIZE_STAGE ,
                                 v_TABLE_SIZE_LEVEL,
                                 v_INDEX_SIZE_LEVEL,
                                 v_TABLE_SIZE ,
                                 v_INDEX_SIZE ,
                                 v_TEMP_SIZE  ,
                                 v_RB_SIZE    ,
                                 v_TEMP_TABLE_SIZE,
                                 v_TEMP_SIZE_SOURCE,
                                 v_TOTAL_PEM_SPACE,
                                 v_TOTAL_TMP_SPACE;
         CLOSE c_get_object_m;
         l_FROM_DATE := to_char(v_FROM_DATE, 'DD-MON-YYYY');
         l_TO_DATE   := to_char(v_TO_DATE, 'DD-MON-YYYY');

         print_m(g_schema,
                   l_FROM_DATE,
                   l_TO_DATE,
                   v_AVG_ROW_LEN_STAGE ,
                   v_AVG_ROW_LEN_LEVEL ,
                   v_AVG_ROW_LEN        ,
                   v_AVG_ROW_LEN_IND_S ,
                   v_AVG_ROW_LEN_IND_L ,
                   v_AVG_ROW_LEN_IND   ,
                   v_NUM_ROWS          ,
                   v_TABLE_SIZE_STAGE  ,
                   v_INDEX_SIZE_STAGE  ,
                   v_TABLE_SIZE_LEVEL ,
                   v_INDEX_SIZE_LEVEL  ,
                   v_TABLE_SIZE         ,
                   v_INDEX_SIZE        ,
                   v_TEMP_SIZE         ,
                   v_RB_SIZE           ,
                   v_TEMP_TABLE_SIZE   ,
                   v_TOTAL_PEM_SPACE   ,
                   v_TOTAL_TMP_SPACE   );
         g_message := 'Information for object ' || g_log_name || 'is printed. ';
         fnd_file.put_line(FND_FILE.LOG, g_message ) ;

      END IF;
   ELSE
      OPEN c_get_objects;
         LOOP
            FETCH c_get_objects INTO V_TABLE_LOGICAL_NAME,
                                 g_table_type,
                                 g_schema,
                                 v_FROM_DATE,
                                 v_TO_DATE,
                                 v_AVG_ROW_LEN_STAGE,
                                 v_AVG_ROW_LEN_LEVEL,
                                 v_AVG_ROW_LEN,
                                 v_AVG_ROW_LEN_IND_S,
                                 v_AVG_ROW_LEN_IND_L,
                                 v_AVG_ROW_LEN_IND,
                                 v_NUM_ROWS ,
                                 v_TABLE_SIZE_STAGE,
                                 v_INDEX_SIZE_STAGE ,
                                 v_TABLE_SIZE_LEVEL,
                                 v_INDEX_SIZE_LEVEL,
                                 v_TABLE_SIZE ,
                                 v_INDEX_SIZE ,
                                 v_TEMP_SIZE  ,
                                 v_RB_SIZE    ,
                                 v_TEMP_TABLE_SIZE,
                                 v_TEMP_SIZE_SOURCE,
                                 v_TOTAL_PEM_SPACE,
                                 v_TOTAL_TMP_SPACE;
           EXIT WHEN c_get_objects%NOTFOUND;

           IF V_TABLE_LOGICAL_NAME is null or V_TABLE_LOGICAL_NAME = 'null' THEN
              RAISE NO_INFORMATION;
           END IF;

           l_FROM_DATE := to_char(v_FROM_DATE, 'DD-MON-YYYY');
           l_TO_DATE   := to_char(v_TO_DATE, 'DD-MON-YYYY');

           IF g_table_type = 'FACT' THEN
              fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
              fnd_file.put_line(FND_FILE.OUTPUT, 'Size Estimation Result for Table: '
                 || V_TABLE_LOGICAL_NAME || '(' || g_table_type || ')') ;
              fnd_file.put_line(FND_FILE.OUTPUT, '------------------------------------------------') ;
              print_f(g_schema,
                   l_FROM_DATE,
                   l_TO_DATE,
                   v_TEMP_SIZE_SOURCE ,
                   v_AVG_ROW_LEN_STAGE  ,
                   v_AVG_ROW_LEN        ,
                   v_AVG_ROW_LEN_IND_S ,
                   v_AVG_ROW_LEN_IND   ,
                   v_NUM_ROWS          ,
                   v_TABLE_SIZE_STAGE  ,
                   v_INDEX_SIZE_STAGE  ,
                   v_TABLE_SIZE         ,
                   v_INDEX_SIZE        ,
                   v_TEMP_SIZE         ,
                   v_RB_SIZE           ,
                   v_TEMP_TABLE_SIZE   ,
                   v_TOTAL_PEM_SPACE   ,
                   v_TOTAL_TMP_SPACE );
                   null;
              g_message := 'Information for object ' || g_log_name || 'is printed. ';
              fnd_file.put_line(FND_FILE.LOG, g_message ) ;
              v_total_idx_space := v_total_idx_space + v_INDEX_SIZE_STAGE + v_INDEX_SIZE;
              v_total_tbl_space := v_total_tbl_space + v_TABLE_SIZE_STAGE + v_TABLE_SIZE;
           ELSE
              fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
              fnd_file.put_line(FND_FILE.OUTPUT, 'Size Estimation Result for Table: '
                 || V_TABLE_LOGICAL_NAME || '(' || g_table_type || ')') ;
              fnd_file.put_line(FND_FILE.OUTPUT, '------------------------------------------------') ;
              print_m(g_schema,
                   l_FROM_DATE,
                   l_TO_DATE,
                   v_AVG_ROW_LEN_STAGE ,
                   v_AVG_ROW_LEN_LEVEL ,
                   v_AVG_ROW_LEN        ,
                   v_AVG_ROW_LEN_IND_S ,
                   v_AVG_ROW_LEN_IND_L ,
                   v_AVG_ROW_LEN_IND   ,
                   v_NUM_ROWS          ,
                   v_TABLE_SIZE_STAGE  ,
                   v_INDEX_SIZE_STAGE  ,
                   v_TABLE_SIZE_LEVEL ,
                   v_INDEX_SIZE_LEVEL  ,
                   v_TABLE_SIZE         ,
                   v_INDEX_SIZE        ,
                   v_TEMP_SIZE         ,
                   v_RB_SIZE           ,
                   v_TEMP_TABLE_SIZE   ,
                   v_TOTAL_PEM_SPACE   ,
                   v_TOTAL_TMP_SPACE   );
              g_message := 'Information for object ' || g_log_name || 'is printed. ';
              fnd_file.put_line(FND_FILE.LOG, g_message ) ;
              v_total_idx_space := v_total_idx_space + v_INDEX_SIZE_STAGE +
                                v_INDEX_SIZE_LEVEL + v_INDEX_SIZE;
              v_total_tbl_space := v_total_tbl_space + v_TABLE_SIZE_STAGE +
                                v_TABLE_SIZE_LEVEL + v_TABLE_SIZE;
           END IF;
         END LOOP;
      CLOSE c_get_objects;
      fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
      fnd_file.put_line(FND_FILE.OUTPUT, 'In Summary') ;
      fnd_file.put_line(FND_FILE.OUTPUT, '------------------------------------------------') ;
      fnd_file.put_line(FND_FILE.OUTPUT, 'The total index space of all objects is (MB): '
                        || ceil(v_total_idx_space/1024/1024)) ;
      fnd_file.put_line(FND_FILE.OUTPUT, 'The total table space of all objects is (MB): '
                        || ceil(v_total_tbl_space/1024/1024)) ;
      fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
   END IF;

   EXCEPTION
      WHEN NO_INFORMATION THEN
         g_message := 'No information found for object: ';
         fnd_file.put_line(FND_FILE.LOG, g_message || g_log_name) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;
      WHEN OTHERS THEN
         errbuf  := sqlerrm;
         retcode := sqlcode;
         fnd_file.put_line(FND_FILE.LOG, errbuf) ;
         fnd_file.put_line(FND_FILE.LOG, '           ') ;

END show_results;   -- procedure show_results.

PROCEDURE print_f (v_TABLE_OWNER                     VARCHAR2,
                   v_FROM_DATE                       VARCHAR2,
                   v_TO_DATE                         VARCHAR2,
                   v_TEMP_SIZE_SOURCE                NUMBER,
                   v_AVG_ROW_LEN_STAGE               NUMBER,
                   v_AVG_ROW_LEN                     NUMBER,
                   v_AVG_ROW_LEN_IND_S               NUMBER,
                   v_AVG_ROW_LEN_IND                 NUMBER,
                   v_NUM_ROWS                        NUMBER,
                   v_TABLE_SIZE_STAGE                NUMBER,
                   v_INDEX_SIZE_STAGE                NUMBER,
                   v_TABLE_SIZE                      NUMBER,
                   v_INDEX_SIZE                      NUMBER,
                   v_TEMP_SIZE                       NUMBER,
                   v_RB_SIZE                         NUMBER,
                   v_TEMP_TABLE_SIZE                 NUMBER,
                   v_TOTAL_PEM_SPACE                 NUMBER,
                   v_TOTAL_TMP_SPACE                 NUMBER) AS

BEGIN

        fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
        IF g_log_name = 'ALL' THEN
           null;
        ELSE
           fnd_file.put_line(FND_FILE.OUTPUT, 'Size Estimation Result for Table: '
               || g_log_name || '(' || g_table_type || ')') ;
           fnd_file.put_line(FND_FILE.OUTPUT, '------------------------------------------------') ;
        END IF;

           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Schema:   ' || v_TABLE_OWNER) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'From Date:   ' || v_FROM_DATE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'To Date:   ' || v_TO_DATE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Temporary Space on Source Side (bytes):  '
                        || v_TEMP_SIZE_SOURCE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Number of Rows:   ' || v_NUM_ROWS) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of Interface Table (bytes):  '
                        || v_AVG_ROW_LEN_STAGE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of the Fact (bytes):  '
                        || v_AVG_ROW_LEN) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of Index for Interface Table (bytes):  '
                     || v_AVG_ROW_LEN_IND_S) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of Index for the Fact (bytes):  '
                        || v_AVG_ROW_LEN_IND) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Interface Table (bytes):  ' || v_TABLE_SIZE_STAGE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Index for Interface Table (bytes):   '
                        || v_INDEX_SIZE_STAGE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of the Fact (bytes):  ' || v_TABLE_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Index of the Fact (bytes):   ' || v_INDEX_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Temporary Space (bytes):  ' || v_TEMP_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Rollback Segments (bytes):  ' || v_RB_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Temporary Table Space (bytes):  '
                        || v_TEMP_TABLE_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Total Size of Permanent Space (bytes):  '
                        || v_TOTAL_PEM_SPACE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Total Size of Temporary Space (bytes):  '
                        || v_TOTAL_TMP_SPACE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
END print_f;

PROCEDURE print_m (v_TABLE_OWNER                     VARCHAR2,
                   v_FROM_DATE                       VARCHAR2,
                   v_TO_DATE                         VARCHAR2,
                   v_AVG_ROW_LEN_STAGE               NUMBER,
                   v_AVG_ROW_LEN_LEVEL               NUMBER,
                   v_AVG_ROW_LEN                     NUMBER,
                   v_AVG_ROW_LEN_IND_S               NUMBER,
                   v_AVG_ROW_LEN_IND_L               NUMBER,
                   v_AVG_ROW_LEN_IND                 NUMBER,
                   v_NUM_ROWS                        NUMBER,
                   v_TABLE_SIZE_STAGE                NUMBER,
                   v_INDEX_SIZE_STAGE                NUMBER,
                   v_TABLE_SIZE_LEVEL                NUMBER,
                   v_INDEX_SIZE_LEVEL                NUMBER,
                   v_TABLE_SIZE                      NUMBER,
                   v_INDEX_SIZE                      NUMBER,
                   v_TEMP_SIZE                       NUMBER,
                   v_RB_SIZE                         NUMBER,
                   v_TEMP_TABLE_SIZE                 NUMBER,
                   v_TOTAL_PEM_SPACE                 NUMBER,
                   v_TOTAL_TMP_SPACE                 NUMBER) IS

BEGIN

        fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
        IF g_log_name = 'ALL' THEN
           null;
        ELSE
           fnd_file.put_line(FND_FILE.OUTPUT, 'Size Estimation Result for Table: '
               || g_log_name || '(' || g_table_type || ')') ;
           fnd_file.put_line(FND_FILE.OUTPUT, '------------------------------------------------') ;
        END IF;

           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Schema:   ' || v_TABLE_OWNER) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'From Date:   ' || v_FROM_DATE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'To Date:   ' || v_TO_DATE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Number of Rows:   ' || v_NUM_ROWS) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of All Interface Tables (bytes):  '
                        || v_AVG_ROW_LEN_STAGE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of All Level Tables (bytes):  '
                        || v_AVG_ROW_LEN_LEVEL) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of the Dimension (bytes):  '
                        || v_AVG_ROW_LEN) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of Index of All Interface Tables (bytes):  '
                     || v_AVG_ROW_LEN_IND_S) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of Index of All Level Tables (bytes):  '
                        || v_AVG_ROW_LEN_IND_L) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Avg Row Length of Index of the Dimension (bytes):  '
                        || v_AVG_ROW_LEN_IND) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Interface Table (bytes):  '
                        || v_TABLE_SIZE_STAGE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Index of Interface Table (bytes):   '
                        || v_INDEX_SIZE_STAGE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Level Table (bytes):  '
                        || v_TABLE_SIZE_LEVEL) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Index of Level Table (bytes):  '
                        || v_INDEX_SIZE_LEVEL) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of the Dimension (bytes):  ' || v_TABLE_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Index of the Dimension (bytes):   ' || v_INDEX_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Temporary Space (bytes):  ' || v_TEMP_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Rollback Segments (bytes):  ' || v_RB_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Size of Temporary Table Space (bytes):  '
                        || v_TEMP_TABLE_SIZE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Total Size of Permanent Space (bytes):  '
                        || v_TOTAL_PEM_SPACE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;
           fnd_file.put(FND_FILE.OUTPUT, 'Total Size of Temporary Space (bytes):  '
                        || v_TOTAL_TMP_SPACE) ;
           fnd_file.new_line(FND_FILE.OUTPUT, 2) ;

END print_m;   -- procedure print_m.


END EDW_SIZE_WRAPPER;   -- package body SIZE_WRAPPER.

/
