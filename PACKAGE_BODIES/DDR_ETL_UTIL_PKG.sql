--------------------------------------------------------
--  DDL for Package Body DDR_ETL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_ETL_UTIL_PKG" AS
/* $Header: ddruetlb.pls 120.5.12010000.4 2010/03/03 04:08:29 vbhave ship $ */

  g_delimeter_char      VARCHAR2(1) := '	'; /* Tab as delimeter */
  -- g_delimeter_char      VARCHAR2(1) := '~';
  -- g_delimeter_char      VARCHAR2(1) := CHR(9); /* Tab as delimeter */
  g_owner_name          VARCHAR2(30) := 'DDR';
  g_max_col_value_size  INTEGER := 1000;
  g_max_linesize        INTEGER := 32767;

  PROCEDURE Raise_Error (p_error_text IN VARCHAR2)
  IS
      l_error_text        VARCHAR2(240);
  BEGIN
      l_error_text := p_error_text;
      Raise_Application_Error(-20001,l_error_text);
  END Raise_Error;

  PROCEDURE Validate_Parameters (p_table_name IN VARCHAR2,p_file_name IN VARCHAR2)
  IS
      CURSOR cur_tab (p_table_name IN VARCHAR2) IS
      SELECT 1
      FROM   ALL_TABLES
      WHERE  table_name = p_table_name
      AND    owner = g_owner_name;

      l_dummy   INTEGER;
  BEGIN
      IF p_table_name IS NULL
      THEN
          Raise_Error('Table Name must be specified');
      END IF;

      IF p_file_name IS NULL
      THEN
          Raise_Error('File Name must be specified');
      END IF;

      /* Validate Table Name */
      OPEN cur_tab (UPPER(p_table_name));
      FETCH cur_tab INTO l_dummy;
      IF cur_tab%NOTFOUND
      THEN
          Raise_Error('Invalid table name: ' || p_table_name);
      END IF;
      CLOSE cur_tab;
  END Validate_Parameters;

  FUNCTION is_string (p_column_type IN VARCHAR2)
  RETURN BOOLEAN
  IS
  BEGIN
      RETURN (p_column_type IN ('CHAR', 'VARCHAR2'));
  END;

  FUNCTION is_string (p_column_type IN string_tab,p_row_idx IN INTEGER)
  RETURN BOOLEAN
  IS
  BEGIN
      RETURN (p_column_type(p_row_idx) IN ('CHAR', 'VARCHAR2'));
  END;

  FUNCTION is_number (p_column_type IN VARCHAR2)
  RETURN BOOLEAN
  IS
  BEGIN
      RETURN (p_column_type IN ('FLOAT', 'INTEGER', 'NUMBER'));
  END;

  FUNCTION is_number (p_column_type IN string_tab,p_row_idx IN INTEGER)
  RETURN BOOLEAN
  IS
  BEGIN
      RETURN (p_column_type(p_row_idx) IN ('FLOAT', 'INTEGER', 'NUMBER'));
  END;

  FUNCTION is_date (p_column_type IN VARCHAR2)
  RETURN BOOLEAN
  IS
  BEGIN
      RETURN (p_column_type = 'DATE');
  END;

  FUNCTION is_date (p_column_type IN string_tab,p_row_idx IN INTEGER)
  RETURN BOOLEAN
  IS
  BEGIN
      RETURN (p_column_type(p_row_idx) = 'DATE');
  END;

  FUNCTION Get_Directory_Name RETURN VARCHAR2
  IS
      l_dirname     VARCHAR2(100);
  BEGIN
      -- l_dirname := 'E:\Biswajit\BI-Projects\DSM\Praxis-Work\ETL\Scripts\Error\';
      l_dirname := 'DDR_ERROR_DIR';
      RETURN l_dirname;
  END Get_Directory_Name;

  PROCEDURE Get_Column_Details (
      p_table_name      IN VARCHAR2,
      p_column_name     IN OUT NOCOPY string_tab,
      p_column_type     IN OUT NOCOPY string_tab,
      p_column_count    IN OUT NOCOPY NUMBER
  )
  IS
      CURSOR cur_col(c_table_name IN VARCHAR2) IS
      SELECT column_name, data_type, data_length, data_precision, data_scale
      FROM   ALL_TAB_COLUMNS
      WHERE  table_name = c_table_name
      AND    owner = g_owner_name
      ORDER BY column_id;
  BEGIN
      p_column_count := 0;
      FOR rec_col IN cur_col (p_table_name)
      LOOP
         p_column_count := p_column_count + 1;
         p_column_name(p_column_count) := rec_col.column_name;
         p_column_type(p_column_count) := rec_col.data_type;
      END LOOP;
  END Get_Column_Details;

  PROCEDURE Get_File_Column_Details (
      p_line                IN VARCHAR2,
      p_file_column_name    IN OUT NOCOPY string_tab,
      p_file_column_count   IN OUT NOCOPY NUMBER
  )
  IS
      l_token     VARCHAR2(4000);
  BEGIN
      p_file_column_count := LENGTH(p_line) - LENGTH(REPLACE(p_line,g_delimeter_char,'')) + 1;

      FOR idx IN 0 .. (p_file_column_count-1)
      LOOP
          IF (idx=0)
          THEN
              IF INSTR(p_line,g_delimeter_char,1,1) <> 0
              THEN
                  l_token := SUBSTR(p_line,1,INSTR(p_line,g_delimeter_char,1,1)-1);
              ELSE
                  l_token := p_line;
              END IF;
          ELSE
              IF INSTR(p_line,g_delimeter_char,1,idx+1) <> 0
              THEN
                  l_token := SUBSTR(p_line,INSTR(p_line,g_delimeter_char,1,idx)+1,
                                                INSTR(p_line,g_delimeter_char,1,idx+1)-INSTR(p_line,g_delimeter_char,1,idx)-1);
              ELSE
                  l_token  := SUBSTR(p_line,INSTR(p_line,g_delimeter_char,1,idx)+1);
              END IF;
          END IF;

          p_file_column_name(idx+1) := l_token;
      END LOOP;

  END Get_File_Column_Details;

  FUNCTION Column_Exists (p_column_name_array IN string_tab,p_column_name IN VARCHAR2)
  RETURN BOOLEAN
  IS
      l_return_value    BOOLEAN := FALSE;
  BEGIN
      FOR indx IN 1 .. p_column_name_array.COUNT
      LOOP
          IF p_column_name_array(indx) = p_column_name
          THEN
              l_return_value := TRUE;
              EXIT;
          END IF;
      END LOOP;
      RETURN l_return_value;
  END Column_Exists;

  PROCEDURE Export_Error (
        p_table_name          IN VARCHAR2,
        p_load_id             IN NUMBER   DEFAULT NULL,
        p_file_name           IN VARCHAR2 DEFAULT NULL
  )
  AS
      l_where_clause        VARCHAR2(500);
      l_file_name           VARCHAR2(100);
  BEGIN
      l_where_clause := 'WHERE ACTION_FLAG = ''N'' ';
      IF p_load_id IS NOT NULL
      THEN
          l_where_clause := l_where_clause || ' AND LOAD_ID = ' || p_load_id;
      END IF;

      l_file_name := p_file_name;
      IF l_file_name IS NULL
      THEN
          IF p_load_id IS NOT NULL
          THEN
              l_file_name := p_table_name || '_' || TO_CHAR(p_load_id) || '.err';
          ELSE
              l_file_name := p_table_name || '.err';
          END IF;
      END IF;

      Export_Data(p_table_name,l_where_clause,NVL(p_file_name,l_file_name));
  END Export_Error;

  PROCEDURE Export_Data (
        p_table_name          IN VARCHAR2,
        p_where_clause        IN VARCHAR2  DEFAULT NULL,
        p_file_name           IN VARCHAR2  DEFAULT NULL
  )
  AS
      l_dir_name            VARCHAR2(100);
      l_table_name          VARCHAR2(30);
      l_where_clause        VARCHAR2(500);
      l_file                UTL_FILE.FILE_TYPE;
      l_column_name         string_tab;
      l_column_type         string_tab;
      l_column_count        INTEGER;
      l_column_list         VARCHAR2(10000);
      l_SQL_stmt            VARCHAR2(10000);
      cur_err               INTEGER;
      l_string_value        VARCHAR2(1000);
      l_number_value        NUMBER;
      l_date_value          DATE;
      l_return_value        INTEGER;
      l_line                VARCHAR2(10000);
      l_hdr_line            VARCHAR2(10000);
  BEGIN
      l_table_name := UPPER(p_table_name);
      l_where_clause := LTRIM(UPPER(p_where_clause));

      Validate_Parameters(l_table_name,p_file_name);
      Get_Column_Details(l_table_name,l_column_name,l_column_type,l_column_count);

      /* Build the SELECT statement to be executed */
      FOR indx IN 1 .. l_column_count
      LOOP
          IF indx = 1
          THEN
              l_column_list := l_column_name(indx);
              l_hdr_line := l_column_name(indx);
          ELSE
              l_column_list := l_column_list || ', ' || l_column_name(indx);
              l_hdr_line := l_hdr_line || g_delimeter_char || l_column_name(indx);
          END IF;
      END LOOP;

      l_SQL_stmt := 'SELECT ' || l_column_list;
      l_SQL_stmt := l_SQL_stmt || ' FROM ' || l_table_name;
      IF l_where_clause IS NOT NULL
      THEN
          IF (l_where_clause NOT LIKE 'GROUP BY%' AND l_where_clause NOT LIKE 'ORDER BY%')
          THEN
              l_where_clause := ' WHERE ' || LTRIM (l_where_clause, 'WHERE');
          END IF;
      END IF;
      l_SQL_stmt := l_SQL_stmt || l_where_clause;

      l_dir_name := Get_Directory_Name;
      l_file := UTL_FILE.FOPEN(l_dir_name,p_file_name,'W',g_max_linesize);

      /* Retrieve the records */
      cur_err := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(cur_err,l_SQL_stmt,DBMS_SQL.NATIVE);
      FOR col_indx IN 1 .. l_column_count
      LOOP
          IF is_string(l_column_type,col_indx)
          THEN
              DBMS_SQL.DEFINE_COLUMN (cur_err,col_indx,l_string_value,g_max_col_value_size);
          ELSIF is_number(l_column_type,col_indx)
          THEN
              DBMS_SQL.DEFINE_COLUMN (cur_err,col_indx,l_number_value);
          ELSIF is_date (l_column_type,col_indx)
          THEN
              DBMS_SQL.DEFINE_COLUMN (cur_err,col_indx,l_date_value);
          END IF;
      END LOOP;
      l_return_value := DBMS_SQL.EXECUTE(cur_err);

      LOOP
          l_return_value := DBMS_SQL.FETCH_ROWS(cur_err);
          EXIT WHEN l_return_value = 0;

          IF DBMS_SQL.last_row_count = 1
          THEN
              /* Write the column header line in file */
              UTL_FILE.PUT_LINE(l_file,l_hdr_line);
          END IF;

          l_line := NULL;
          FOR col_indx IN 1 .. l_column_count
          LOOP
              IF is_string(l_column_type,col_indx)
              THEN
                  DBMS_SQL.COLUMN_VALUE(cur_err,col_indx,l_string_value);
              ELSIF is_number(l_column_type,col_indx)
              THEN
                  DBMS_SQL.COLUMN_VALUE(cur_err,col_indx,l_number_value);
                  l_string_value := TO_CHAR (l_number_value);
              ELSIF is_date(l_column_type,col_indx)
              THEN
                  DBMS_SQL.COLUMN_VALUE(cur_err,col_indx,l_date_value);
                  l_string_value := TO_CHAR(l_date_value,'YYYY/MM/DD');
              END IF;

              l_line := l_line || g_delimeter_char || l_string_value;
          END LOOP;
          l_line := SUBSTR(l_line,2);

          /* Write the line to the file */
          UTL_FILE.PUT_LINE(l_file,l_line);
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(cur_err);

      UTL_FILE.FCLOSE(l_file);
  EXCEPTION
      WHEN OTHERS
      THEN
          IF UTL_FILE.IS_OPEN(l_file)
          THEN
              UTL_FILE.FCLOSE(l_file);
          END IF;
          IF DBMS_SQL.IS_OPEN(cur_err)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_err);
          END IF;
          Raise_Error(SQLERRM);
  END Export_Data;

  PROCEDURE Import_Error (
        p_table_name          IN VARCHAR2,
        p_file_name           IN VARCHAR2  DEFAULT NULL
  )
  AS
      l_dir_name            VARCHAR2(100);
      l_table_name          VARCHAR2(30);
      l_file_name           VARCHAR2(100);
      l_file                UTL_FILE.FILE_TYPE;
      l_column_name         string_tab;
      l_column_type         string_tab;
      l_column_count        INTEGER;
      l_update_stmt         VARCHAR2(10000);
      l_insert_stmt         VARCHAR2(10000);
      l_update_clause       VARCHAR2(10000);
      l_insert_clause       VARCHAR2(10000);
      l_values_clause       VARCHAR2(10000);
      cur_err_upd           INTEGER;
      cur_err_ins           INTEGER;
      l_string_value        VARCHAR2(4000);
      l_number_value        NUMBER;
      l_date_value          DATE;
      l_return_value        INTEGER;
      l_line                VARCHAR2(10000);
      l_col_type_by_name    string_index_by_char_tab;
      l_file_column_name    string_tab;
      l_file_column_count   INTEGER;
      l_rec_count           INTEGER;
      l_count               INTEGER;
      l_file_column_value   string_tab;
      l_update_count        INTEGER;
      l_action_column_indx  INTEGER;
  BEGIN
      l_table_name := UPPER(p_table_name);
      l_file_name := NVL(p_file_name,l_table_name || '.err');

      Validate_Parameters(l_table_name,l_file_name);
      Get_Column_Details(l_table_name,l_column_name,l_column_type,l_column_count);

      FOR indx IN 1 .. l_column_count
      LOOP
          l_col_type_by_name(l_column_name(indx)) := l_column_type(indx);
      END LOOP;

      l_dir_name := Get_Directory_Name;
      l_file := UTL_FILE.FOPEN(l_dir_name,l_file_name,'R',g_max_linesize);

      /* Read and Process all records from the file */
      cur_err_upd := DBMS_SQL.OPEN_CURSOR;
      cur_err_ins := DBMS_SQL.OPEN_CURSOR;
      l_rec_count := 0;
      LOOP
          BEGIN
              UTL_FILE.GET_LINE(l_file,l_line,g_max_linesize);
              l_rec_count := l_rec_count + 1;

              IF l_rec_count = 1  /* Assuming that the first line is the File Column Header Line */
              THEN
                  /* Build l_file_column_name array based on the read line */
                  Get_File_Column_Details(l_line,l_file_column_name,l_file_column_count);

                  /* Build the Update and Insert Statements and Parse them */
                  l_update_clause := 'UPDATE ' || l_table_name || ' SET ';
                  l_insert_clause := 'INSERT INTO ' || l_table_name ||'(';
                  l_values_clause := 'VALUES (';
                  l_action_column_indx := 0;
                  FOR indx IN 1 .. l_file_column_count
                  LOOP
                      IF l_file_column_name(indx) <> 'REC_ID'
                      THEN
                          l_update_clause := l_update_clause || ' ' || l_file_column_name(indx)
                                                || '=:' || l_file_column_name(indx) || ',';
                      END IF;
                      l_insert_clause := l_insert_clause || l_file_column_name(indx) || ',';
                      l_values_clause := l_values_clause || ':' || l_file_column_name(indx) || ',';

                      IF l_file_column_name(indx) = 'ACTION_FLAG'
                      THEN
                          l_action_column_indx := indx;
                      END IF;
                  END LOOP;
                  l_update_clause := SUBSTR(l_update_clause,1,LENGTH(l_update_clause)-1);
                  l_insert_clause := SUBSTR(l_insert_clause,1,LENGTH(l_insert_clause)-1);
                  l_values_clause := SUBSTR(l_values_clause,1,LENGTH(l_values_clause)-1);
                  l_update_stmt := l_update_clause || ' WHERE REC_ID=:REC_ID';
                  l_insert_stmt := l_insert_clause || ') ' || l_values_clause || ')';

                  DBMS_SQL.PARSE(cur_err_upd,l_update_stmt,DBMS_SQL.NATIVE);
                  DBMS_SQL.PARSE(cur_err_ins,l_insert_stmt,DBMS_SQL.NATIVE);
              ELSE
                  Get_File_Column_Details(l_line,l_file_column_value,l_count);

                  IF l_file_column_value(l_action_column_indx) IN ('Y','D') /* i.e. ACTION_FLAG IN ('Y','D') */
                  THEN
                      /* Update the record into table */
                      FOR indx IN 1 .. l_count
                      LOOP
                          IF is_string(l_col_type_by_name(l_file_column_name(indx)))
                          THEN
                              l_string_value := l_file_column_value(indx);
                              DBMS_SQL.BIND_VARIABLE(cur_err_upd,l_file_column_name(indx),l_string_value);
                          ELSIF is_number(l_col_type_by_name(l_file_column_name(indx)))
                          THEN
                              l_number_value := TO_NUMBER(l_file_column_value(indx));
                              DBMS_SQL.BIND_VARIABLE(cur_err_upd,l_file_column_name(indx),l_number_value);
                          ELSIF is_date(l_col_type_by_name(l_file_column_name(indx)))
                          THEN
                              l_date_value := TO_DATE(l_file_column_value(indx),'YYYY/MM/DD');
                              DBMS_SQL.BIND_VARIABLE(cur_err_upd,l_file_column_name(indx),l_date_value);
                          END IF;
                      END LOOP;
                      l_update_count := DBMS_SQL.EXECUTE(cur_err_upd);

                      /* Insert the record into table if Update fails */
                      IF l_update_count = 0
                      THEN
                          FOR indx IN 1 .. l_count
                          LOOP
                              IF is_string(l_col_type_by_name(l_file_column_name(indx)))
                              THEN
                                  l_string_value := l_file_column_value(indx);
                                  DBMS_SQL.BIND_VARIABLE(cur_err_ins,l_file_column_name(indx),l_string_value);
                              ELSIF is_number(l_col_type_by_name(l_file_column_name(indx)))
                              THEN
                                  l_number_value := TO_NUMBER(l_file_column_value(indx));
                                  DBMS_SQL.BIND_VARIABLE(cur_err_ins,l_file_column_name(indx),l_number_value);
                              ELSIF is_date(l_col_type_by_name(l_file_column_name(indx)))
                              THEN
                                  l_date_value := TO_DATE(l_file_column_value(indx),'YYYY/MM/DD');
                                  DBMS_SQL.BIND_VARIABLE(cur_err_ins,l_file_column_name(indx),l_date_value);
                              END IF;
                          END LOOP;
                          l_update_count := DBMS_SQL.EXECUTE(cur_err_ins);
                      END IF;
                  END IF;

              END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND
              THEN EXIT;
          END;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(cur_err_upd);
      DBMS_SQL.CLOSE_CURSOR(cur_err_ins);
      UTL_FILE.FCLOSE(l_file);

      COMMIT;
  EXCEPTION
      WHEN OTHERS
      THEN
          IF UTL_FILE.IS_OPEN(l_file)
          THEN
              UTL_FILE.FCLOSE(l_file);
          END IF;
          IF DBMS_SQL.IS_OPEN(cur_err_upd)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_err_upd);
          END IF;
          IF DBMS_SQL.IS_OPEN(cur_err_ins)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_err_ins);
          END IF;
          Raise_Error(SQLERRM);
  END Import_Error;

  PROCEDURE Import_Error (
        p_table_name          IN VARCHAR2,
        p_file_name           IN VARCHAR2  DEFAULT NULL,
        p_err_table_name      IN VARCHAR2,
        p_load_id             IN NUMBER    DEFAULT NULL,
        p_tgt_table_type      IN VARCHAR2  DEFAULT 'I'
  )
  AS
      l_err_table_name      VARCHAR2(30);
  BEGIN
      IF p_err_table_name IS NULL
      THEN
          l_err_table_name := 'DDR_E_' || SUBSTR(p_table_name,7);
      ELSE
          l_err_table_name := p_err_table_name;
      END IF;
      Import_Error(l_err_table_name,p_file_name);
      Transfer_Data(l_err_table_name,p_table_name,p_load_id,p_tgt_table_type);
  END Import_Error;

  PROCEDURE Import_Data (
        p_table_name          IN VARCHAR2,
        p_file_name           IN VARCHAR2  DEFAULT NULL
  )
  AS
      l_dir_name            VARCHAR2(100);
      l_table_name          VARCHAR2(30);
      l_file_name           VARCHAR2(100);
      l_file                UTL_FILE.FILE_TYPE;
      l_column_name         string_tab;
      l_column_type         string_tab;
      l_column_count        INTEGER;
      l_insert_stmt         VARCHAR2(10000);
      l_insert_clause       VARCHAR2(10000);
      l_values_clause       VARCHAR2(10000);
      cur_err_ins           INTEGER;
      l_string_value        VARCHAR2(4000);
      l_number_value        NUMBER;
      l_date_value          DATE;
      l_return_value        INTEGER;
      l_line                VARCHAR2(10000);
      l_col_type_by_name    string_index_by_char_tab;
      l_file_column_name    string_tab;
      l_file_column_count   INTEGER;
      l_rec_count           INTEGER;
      l_count               INTEGER;
      l_file_column_value   string_tab;
      l_update_count        INTEGER;
  BEGIN
      l_table_name := UPPER(p_table_name);
      l_file_name := NVL(p_file_name,l_table_name || '.txt');

      Validate_Parameters(l_table_name,l_file_name);
      Get_Column_Details(l_table_name,l_column_name,l_column_type,l_column_count);

      FOR indx IN 1 .. l_column_count
      LOOP
          l_col_type_by_name(l_column_name(indx)) := l_column_type(indx);
      END LOOP;

      l_dir_name := Get_Directory_Name;
      l_file := UTL_FILE.FOPEN(l_dir_name,l_file_name,'R',g_max_linesize);

      /* Read and Process all records from the file */
      cur_err_ins := DBMS_SQL.OPEN_CURSOR;
      l_rec_count := 0;
      LOOP
          BEGIN
              UTL_FILE.GET_LINE(l_file,l_line,g_max_linesize);
              l_rec_count := l_rec_count + 1;

              IF l_rec_count = 1  /* Assuming that the first line is the File Column Header Line */
              THEN
                  /* Build l_file_column_name array based on the read line */
                  Get_File_Column_Details(l_line,l_file_column_name,l_file_column_count);

                  /* Build the Insert Statement and Parse them */
                  l_insert_clause := 'INSERT INTO ' || l_table_name ||'(';
                  l_values_clause := 'VALUES (';
                  FOR indx IN 1 .. l_file_column_count
                  LOOP
                      l_insert_clause := l_insert_clause || l_file_column_name(indx) || ',';
                      l_values_clause := l_values_clause || ':' || l_file_column_name(indx) || ',';
                  END LOOP;
                  l_insert_clause := SUBSTR(l_insert_clause,1,LENGTH(l_insert_clause)-1);
                  l_values_clause := SUBSTR(l_values_clause,1,LENGTH(l_values_clause)-1);
                  l_insert_stmt := l_insert_clause || ') ' || l_values_clause || ')';

                  DBMS_SQL.PARSE(cur_err_ins,l_insert_stmt,DBMS_SQL.NATIVE);
              ELSE
                  Get_File_Column_Details(l_line,l_file_column_value,l_count);

                  /* Insert the record into table */
                  FOR indx IN 1 .. l_count
                  LOOP
                      IF is_string(l_col_type_by_name(l_file_column_name(indx)))
                      THEN
                          l_string_value := l_file_column_value(indx);
                          DBMS_SQL.BIND_VARIABLE(cur_err_ins,l_file_column_name(indx),l_string_value);
                      ELSIF is_number(l_col_type_by_name(l_file_column_name(indx)))
                      THEN
                          l_number_value := TO_NUMBER(l_file_column_value(indx));
                          DBMS_SQL.BIND_VARIABLE(cur_err_ins,l_file_column_name(indx),l_number_value);
                      ELSIF is_date(l_col_type_by_name(l_file_column_name(indx)))
                      THEN
                          l_date_value := TO_DATE(l_file_column_value(indx),'YYYY/MM/DD');
                          DBMS_SQL.BIND_VARIABLE(cur_err_ins,l_file_column_name(indx),l_date_value);
                      END IF;
                  END LOOP;
                  l_update_count := DBMS_SQL.EXECUTE(cur_err_ins);

              END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND
              THEN EXIT;
          END;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(cur_err_ins);
      UTL_FILE.FCLOSE(l_file);

      COMMIT;
  EXCEPTION
      WHEN OTHERS
      THEN
          IF UTL_FILE.IS_OPEN(l_file)
          THEN
              UTL_FILE.FCLOSE(l_file);
          END IF;
          IF DBMS_SQL.IS_OPEN(cur_err_ins)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_err_ins);
          END IF;
          Raise_Error(SQLERRM);
  END Import_Data;

  PROCEDURE Transfer_Data (
        p_src_table_name      IN VARCHAR2,
        p_tgt_table_name      IN VARCHAR2,
        p_load_id             IN NUMBER    DEFAULT NULL,
        p_tgt_table_type      IN VARCHAR2  DEFAULT 'I'
  )
  AS
      l_src_table_name          VARCHAR2(30);
      l_tgt_table_name          VARCHAR2(30);
      l_tgt_table_type          VARCHAR2(30);
      l_src_column_name         string_tab;
      l_src_column_type         string_tab;
      l_src_column_count        INTEGER;
      l_src_column_list         VARCHAR2(10000);
      l_select_stmt             VARCHAR2(10000);
      l_where_clause            VARCHAR2(500);
      l_tgt_column_name         string_tab;
      l_tgt_column_type         string_tab;
      l_tgt_column_count        INTEGER;
      l_tgt_col_type_by_name    string_index_by_char_tab;
      l_update_stmt             VARCHAR2(10000);
      l_insert_stmt             VARCHAR2(10000);
      l_update_clause           VARCHAR2(10000);
      l_insert_clause           VARCHAR2(10000);
      l_values_clause           VARCHAR2(10000);
      l_delete_stmt             VARCHAR2(1000);
      l_rest_where_clause       VARCHAR2(500);
      cur_src                   INTEGER;
      cur_tgt_upd               INTEGER;
      cur_tgt_ins               INTEGER;
      l_string_value            VARCHAR2(1000);
      l_number_value            NUMBER;
      l_date_value              DATE;
      l_return_value            INTEGER;
      l_update_count            INTEGER;
  BEGIN
      l_src_table_name := UPPER(p_src_table_name);
      l_tgt_table_name := UPPER(p_tgt_table_name);
      l_tgt_table_type := NVL(p_tgt_table_type,'I');

      Validate_Parameters(l_src_table_name,'DUMMY');
      Validate_Parameters(l_tgt_table_name,'DUMMY');
      IF p_tgt_table_type NOT IN ('I','S')
      THEN
          Raise_Error('Valid values for Target Table Type is ''I'' and ''S'' only');
      END IF;

      /* Get Target Table Column details */
      Get_Column_Details(l_tgt_table_name,l_tgt_column_name,l_tgt_column_type,l_tgt_column_count);
      FOR indx IN 1 .. l_tgt_column_count
      LOOP
          l_tgt_col_type_by_name(l_tgt_column_name(indx)) := l_tgt_column_type(indx);
      END LOOP;

      /* Get Source Table Column details */
      Get_Column_Details(l_src_table_name,l_src_column_name,l_src_column_type,l_src_column_count);

      /* Build the SELECT statement to be executed */
      FOR indx IN 1 .. l_src_column_count
      LOOP
          IF indx = 1
          THEN
              l_src_column_list := l_src_column_name(indx);
          ELSE
              l_src_column_list := l_src_column_list || ', ' || l_src_column_name(indx);
          END IF;
      END LOOP;

      l_select_stmt := 'SELECT ' || l_src_column_list;
      l_select_stmt := l_select_stmt || ' FROM ' || l_src_table_name;
      l_where_clause := ' WHERE ACTION_FLAG = ''Y'' ';
      l_rest_where_clause := null;
      IF p_load_id IS NOT NULL
      THEN
          l_where_clause := l_where_clause || ' AND LOAD_ID = ' || p_load_id;
          l_rest_where_clause := l_rest_where_clause || ' AND LOAD_ID = ' || p_load_id;
      END IF;
      IF Column_Exists(l_src_column_name,'SRC_IDNT_FLAG')
      THEN
          l_where_clause := l_where_clause || ' AND SRC_IDNT_FLAG = ''' || l_tgt_table_type || '''';
          l_rest_where_clause := l_rest_where_clause || ' AND SRC_IDNT_FLAG = ''' || l_tgt_table_type || '''';
      END IF;
      l_select_stmt := l_select_stmt || l_where_clause;

      cur_tgt_upd := DBMS_SQL.OPEN_CURSOR;
      cur_tgt_ins := DBMS_SQL.OPEN_CURSOR;

      /* Build the Update and Insert Statements and Parse them */
      l_update_clause := 'UPDATE ' || l_tgt_table_name || ' SET ';
      l_insert_clause := 'INSERT INTO ' || l_tgt_table_name ||'(';
      l_values_clause := 'VALUES (';
      FOR indx IN 1 .. l_tgt_column_count
      LOOP
          /* Here check for the corresponding column existance in source table */
          IF Column_Exists(l_src_column_name,l_tgt_column_name(indx))
          THEN
              IF l_tgt_column_name(indx) <> 'REC_ID'
              THEN
                  l_update_clause := l_update_clause || ' ' || l_tgt_column_name(indx)
                                        || '=:' || l_tgt_column_name(indx) || ',';
              END IF;
              l_insert_clause := l_insert_clause || l_tgt_column_name(indx) || ',';
              l_values_clause := l_values_clause || ':' || l_tgt_column_name(indx) || ',';
          END IF;
      END LOOP;
      l_update_clause := SUBSTR(l_update_clause,1,LENGTH(l_update_clause)-1);
      l_insert_clause := SUBSTR(l_insert_clause,1,LENGTH(l_insert_clause)-1);
      l_values_clause := SUBSTR(l_values_clause,1,LENGTH(l_values_clause)-1);
      l_update_stmt := l_update_clause || ' WHERE REC_ID=:REC_ID';
      l_insert_stmt := l_insert_clause || ') ' || l_values_clause || ')';

      DBMS_SQL.PARSE(cur_tgt_upd,l_update_stmt,DBMS_SQL.NATIVE);
      DBMS_SQL.PARSE(cur_tgt_ins,l_insert_stmt,DBMS_SQL.NATIVE);

      /* Retrieve the records from Source table */
      cur_src := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(cur_src,l_select_stmt,DBMS_SQL.NATIVE);
      FOR col_indx IN 1 .. l_src_column_count
      LOOP
          IF is_string(l_src_column_type,col_indx)
          THEN
              DBMS_SQL.DEFINE_COLUMN (cur_src,col_indx,l_string_value,g_max_col_value_size);
          ELSIF is_number(l_src_column_type,col_indx)
          THEN
              DBMS_SQL.DEFINE_COLUMN (cur_src,col_indx,l_number_value);
          ELSIF is_date (l_src_column_type,col_indx)
          THEN
              DBMS_SQL.DEFINE_COLUMN (cur_src,col_indx,l_date_value);
          END IF;
      END LOOP;

      l_return_value := DBMS_SQL.EXECUTE(cur_src);
      LOOP
          l_return_value := DBMS_SQL.FETCH_ROWS(cur_src);
          EXIT WHEN l_return_value = 0;

          FOR col_indx IN 1 .. l_src_column_count
          LOOP
              IF Column_Exists(l_tgt_column_name,l_src_column_name(col_indx))
              THEN
                  IF is_string(l_src_column_type,col_indx)
                  THEN
                      DBMS_SQL.COLUMN_VALUE(cur_src,col_indx,l_string_value);
                      DBMS_SQL.BIND_VARIABLE(cur_tgt_upd,l_src_column_name(col_indx),l_string_value);
                      DBMS_SQL.BIND_VARIABLE(cur_tgt_ins,l_src_column_name(col_indx),l_string_value);
                  ELSIF is_number(l_src_column_type,col_indx)
                  THEN
                      DBMS_SQL.COLUMN_VALUE(cur_src,col_indx,l_number_value);
                      DBMS_SQL.BIND_VARIABLE(cur_tgt_upd,l_src_column_name(col_indx),l_number_value);
                      DBMS_SQL.BIND_VARIABLE(cur_tgt_ins,l_src_column_name(col_indx),l_number_value);
                  ELSIF is_date(l_src_column_type,col_indx)
                  THEN
                      DBMS_SQL.COLUMN_VALUE(cur_src,col_indx,l_date_value);
                      DBMS_SQL.BIND_VARIABLE(cur_tgt_upd,l_src_column_name(col_indx),l_date_value);
                      DBMS_SQL.BIND_VARIABLE(cur_tgt_ins,l_src_column_name(col_indx),l_date_value);
                  END IF;
              END IF;
          END LOOP;

          /* Execute the DML statement against the Target table */
          l_update_count := DBMS_SQL.EXECUTE(cur_tgt_upd);

          /* Insert the record into table if Update fails */
          IF l_update_count = 0
          THEN
              l_update_count := DBMS_SQL.EXECUTE(cur_tgt_ins);
          END IF;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(cur_src);
      DBMS_SQL.CLOSE_CURSOR(cur_tgt_upd);
      DBMS_SQL.CLOSE_CURSOR(cur_tgt_ins);

      /* Delete Records from Target table for records marked with "ACTION_FLAG = 'D'" in Source Error table */
      l_delete_stmt := 'DELETE FROM ' || l_tgt_table_name || ' WHERE REC_ID IN (SELECT REC_ID FROM ' || l_src_table_name;
      l_delete_stmt := l_delete_stmt || ' WHERE ACTION_FLAG = ''D'' ' || l_rest_where_clause || ')';
      EXECUTE IMMEDIATE l_delete_stmt;

      /* Delete Transfered Records (i.e. ACTION_FLAG = 'Y') as well as records marked with "ACTION_FLAG = 'D'"
        from Source Error table */
      l_delete_stmt := 'DELETE FROM ' || l_src_table_name || ' WHERE ACTION_FLAG IN (''Y'',''D'') ' || l_rest_where_clause;
      EXECUTE IMMEDIATE l_delete_stmt;

      COMMIT;
  EXCEPTION
      WHEN OTHERS
      THEN
          IF DBMS_SQL.IS_OPEN(cur_src)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_src);
          END IF;
          IF DBMS_SQL.IS_OPEN(cur_tgt_upd)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_tgt_upd);
          END IF;
          IF DBMS_SQL.IS_OPEN(cur_tgt_ins)
          THEN
              DBMS_SQL.CLOSE_CURSOR(cur_tgt_ins);
          END IF;
          Raise_Error(SQLERRM);
  END Transfer_Data;

  PROCEDURE refresh_mv (
        p_list                 IN VARCHAR2,
        p_method               IN VARCHAR2 DEFAULT NULL,
        p_rollback_seg         IN VARCHAR2 DEFAULT NULL,
        p_push_deferred_rpc    IN BOOLEAN  DEFAULT TRUE,
        p_refresh_after_errors IN BOOLEAN  DEFAULT FALSE,
        p_purge_option         IN BINARY_INTEGER DEFAULT 1,
        p_parallelism          IN BINARY_INTEGER DEFAULT 0,
        p_heap_size            IN BINARY_INTEGER DEFAULT 0,
        p_atomic_refresh       IN BOOLEAN  DEFAULT TRUE,
        p_job_id               IN VARCHAR2 DEFAULT NULL,
        p_refreshed_by         IN VARCHAR2 DEFAULT NULL,
        x_out                  OUT NOCOPY VARCHAR2,
        x_message              OUT NOCOPY VARCHAR2
  ) IS
        v_seq NUMBER;
  BEGIN

    SELECT ddr_u_mv_rfrsh_seq.nextval INTO v_seq FROM DUAL;
    INSERT INTO ddr_u_mv_rfrsh_log(refresh_job_id
                       ,refresh_sequence
                       ,mv_name
                       ,refresh_method
                       ,error_message
                       ,refreshed_by
                       ,start_date
                       ,end_date)
                 VALUES(p_job_id
                       ,v_seq
                       ,p_list
                       ,p_method
                       ,p_refreshed_by
                       ,NULL
                       ,SYSDATE
                       ,NULL);
    COMMIT;

    DBMS_MVIEW.REFRESH(p_list, p_method, p_rollback_seg, p_push_deferred_rpc,
                       p_refresh_after_errors, p_purge_option,
                       p_parallelism, p_heap_size, p_atomic_refresh);

    UPDATE ddr_u_mv_rfrsh_log
    SET    end_date = SYSDATE
    WHERE  refresh_job_id = p_job_id
    AND    refresh_sequence = v_seq
    AND    mv_name = p_list;
    COMMIT;

    x_out := 'S';
    x_message := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_out := 'F';
      x_message := SQLERRM;

      UPDATE ddr_u_mv_rfrsh_log
      SET    end_date = SYSDATE,
             error_message = x_message
      WHERE  refresh_job_id = p_job_id
      AND    refresh_sequence = v_seq
      AND    mv_name = p_list;
      COMMIT;

  END refresh_mv;

  FUNCTION get_mv_refresh_job_id RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(SYSDATE,'YYYYMMDDHH24MMSS');
  END get_mv_refresh_job_id;

  PROCEDURE truncate_mv_log(
        p_mv_log_name          IN VARCHAR2,
        p_job_id               IN VARCHAR2 DEFAULT NULL,
        p_refreshed_by         IN VARCHAR2 DEFAULT NULL,
        x_out                  OUT NOCOPY VARCHAR2,
        x_message              OUT NOCOPY VARCHAR2
  ) IS
        v_seq NUMBER;
  BEGIN

    SELECT ddr_u_mv_rfrsh_seq.nextval INTO v_seq FROM DUAL;
    INSERT INTO ddr_u_mv_rfrsh_log(refresh_job_id
                       ,refresh_sequence
                       ,mv_name
                       ,refresh_method
                       ,error_message
                       ,refreshed_by
                       ,start_date
                       ,end_date)
                 VALUES(p_job_id
                       ,v_seq
                       ,p_mv_log_name
                       ,'TRUNCATE'
                       ,p_refreshed_by
                       ,NULL
                       ,SYSDATE
                       ,NULL);
    COMMIT;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||p_mv_log_name||' DROP STORAGE';

    UPDATE ddr_u_mv_rfrsh_log
    SET    end_date = SYSDATE
    WHERE  refresh_job_id = p_job_id
    AND    refresh_sequence = v_seq
    AND    mv_name = p_mv_log_name;
    COMMIT;

    x_out := 'S';
    x_message := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_out := 'F';
      x_message := SQLERRM;
      UPDATE ddr_u_mv_rfrsh_log
      SET    end_date = SYSDATE,
             error_message = x_message
      WHERE  refresh_job_id = p_job_id
      AND    refresh_sequence = v_seq
      AND    mv_name = p_mv_log_name;
      COMMIT;

  END truncate_mv_log;

END ddr_etl_util_pkg;

/
