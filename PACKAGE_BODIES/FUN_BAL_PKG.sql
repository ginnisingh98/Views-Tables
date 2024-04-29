--------------------------------------------------------
--  DDL for Package Body FUN_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_BAL_PKG" AS
/* $Header: funbalpkgb.pls 120.31.12010000.31 2010/05/18 11:41:06 abhaktha ship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FUN_BAL_PKG';
G_FILE_NAME CONSTANT VARCHAR2(30) := 'FUNBALPKGB.PLS';
G_PRODUCT_CODE VARCHAR2(3);
G_DEBUG VARCHAR2(1);
G_FUN_SCHEMA VARCHAR2(30);
G_DEBUG_LEVEL NUMBER;

--Bug # 7141663 Created the table type to cache the ouput of get_ccid procedure
TYPE ccid_cache_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(4000);
g_ccid_cache_tab  ccid_cache_tab;


-- This function is not currently used
PROCEDURE debug
( p_message IN VARCHAR2
) IS
BEGIN
IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
    FND_MESSAGE.SET_NAME('FUN', p_message);
    FND_MSG_PUB.Add;
END IF;
END debug;

PROCEDURE truncate_tables
IS
cur_hdl int;
rows_processed int;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.truncate_tables', 'begin');
  END IF;

  DELETE FROM fun_bal_results_gt;
  DELETE FROM fun_bal_errors_gt;
  DELETE FROM fun_bal_le_bsv_map_gt;
  DELETE FROM fun_bal_inter_int_gt;
  DELETE FROM fun_bal_intra_int_gt;
/*  Using delete rather than truncate as shown in the code below.  The reason is that truncate (or any DDL operations)
     perform an implicit commit => need to use autonomous transaction to perform such operation.  However, we would
     like to make sure the calling program does not see the rows that gets deleted, therefore truncate is not used.
     In addition, the truncate operation might not be able to delete the rows that the calling program has not commited yet,
     which could result in that we think the rows got deleted but they still exist.
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_RESULTS_GT', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_ERRORS_GT', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_LE_BSV_MAP_GT', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTER_INT_GT', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTRA_INT_GT', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_RESULTS_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_ERRORS_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_LINES_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_HEADERS_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTER_BSV_MAP_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTRA_BSV_MAP_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTER_INT_T', dbms_sql.native);
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTRA_INT_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  */
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.truncate_tables', 'end');
  END IF;

  RETURN;
END truncate_tables;


PROCEDURE update_inter_seg_val IS
stmt_str varchar2(1000);
cur_hdl int;
rows_processed int;
l_bal_seg_column_name VARCHAR2(25);
CURSOR bal_seg_val_cur IS
SELECT DISTINCT bal_seg_column_name
FROM fun_bal_headers_gt headers
WHERE headers.status = 'OK';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.update_inter_seg_val.begin', 'begin');
  END IF;

OPEN bal_seg_val_cur;
LOOP
  FETCH bal_seg_val_cur INTO l_bal_seg_column_name;
  EXIT WHEN bal_seg_val_cur%NOTFOUND;
  cur_hdl := dbms_sql.open_cursor;
  stmt_str := 'UPDATE fun_bal_inter_int_gt inter_int ' ||
                   ' SET rec_bsv = ' ||
                   ' (SELECT ' || l_bal_seg_column_name ||
                   ' FROM gl_code_combinations ' ||
                   ' WHERE code_combination_id = inter_int.rec_acct ' ||
                   ' AND inter_int.bal_seg_column_name = ''' || l_bal_seg_column_name || ''') ' ||
                   ' WHERE inter_int.rec_acct IS NOT NULL AND inter_int.rec_acct <> -1';
  dbms_sql.parse(cur_hdl, stmt_str, dbms_sql.native);
  rows_processed := dbms_sql.execute(cur_hdl);
  dbms_sql.close_cursor(cur_hdl); -- close cursor

  cur_hdl := dbms_sql.open_cursor;
  stmt_str := 'UPDATE fun_bal_inter_int_gt inter_int ' ||
                   ' SET pay_bsv = ' ||
                   ' (SELECT ' || l_bal_seg_column_name ||
                   ' FROM gl_code_combinations ' ||
                   ' WHERE code_combination_id = inter_int.pay_acct ' ||
                   ' AND inter_int.bal_seg_column_name = ''' || l_bal_seg_column_name || ''') ' ||
                   ' WHERE inter_int.pay_acct IS NOT NULL AND inter_int.pay_acct <> -1';
   dbms_sql.parse(cur_hdl, stmt_str, dbms_sql.native);
  rows_processed := dbms_sql.execute(cur_hdl);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
END LOOP;
CLOSE bal_seg_val_cur;
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.update_inter_seg_val.end', 'end');
  END IF;

  RETURN;
END update_inter_seg_val;

FUNCTION get_segment_index (p_chart_of_accounts_id IN NUMBER,
                            p_segment_type         VARCHAR2)
         RETURN NUMBER
IS
CURSOR c_segments (p_chart_of_accounts_id NUMBER) IS
  SELECT s.segment_num, sav.segment_attribute_type
  FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav
  WHERE s.application_id = 101
  AND s.id_flex_code = 'GL#'
  AND s.id_flex_num = p_chart_of_accounts_id
  AND s.enabled_flag = 'Y'
  AND s.application_column_name = sav.application_column_name
  AND sav.application_id = 101
  AND sav.id_flex_code = 'GL#'
  AND sav.id_flex_num = p_chart_of_accounts_id
  AND sav.attribute_value = 'Y'
  ORDER BY s.segment_num ASC;

  l_ic_seg_num  NUMBER;
  l_bal_seg_num NUMBER;
  l_index       NUMBER;
  l_prev_seg_num  NUMBER;

BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.get_segment_index', 'start');
     END IF;

    l_index := 0;
    l_prev_seg_num := 0;

    FOR r_segments IN c_segments (p_chart_of_accounts_id)
    LOOP
        IF l_prev_seg_num <> r_segments.segment_num
        THEN
            l_index := l_index + 1;
        END IF;

        IF r_segments.segment_attribute_type = p_segment_type
        AND p_segment_type = 'GL_BALANCING'
        THEN
            l_bal_seg_num := l_index;
            RETURN l_bal_seg_num;
        END IF;

        IF r_segments.segment_attribute_type = p_segment_type
        AND p_segment_type = 'GL_INTERCOMPANY'
        THEN
            l_ic_seg_num := l_index;
            RETURN l_ic_seg_num;
        END IF;

        l_prev_seg_num := r_segments.segment_num;
    END LOOP;

    RETURN NULL;

    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.get_segment_index', 'end');
     END IF;

END get_segment_index;

FUNCTION get_ccid
( ccid IN NUMBER,
  chart_of_accounts_id IN NUMBER,
  bal_seg_val IN VARCHAR2,
  intercompany_seg_val IN VARCHAR2,
  bal_seg_column_number IN NUMBER,
  intercompany_column_number IN NUMBER,
  gl_date IN DATE) RETURN NUMBER IS
  l_segment_array FND_FLEX_EXT.SEGMENTARRAY;
  l_flag BOOLEAN;
  l_no_of_segments NUMBER;
  l_ccid NUMBER;
  l_rule VARCHAR2(1000);
  l_where_clause VARCHAR2(30);
  l_get_column      VARCHAR2(30);
  l_delimiter VARCHAR2(1);
  l_cat_segs VARCHAR2(2000);
  l_error_message VARCHAR2(2000);

  -- Bug # 7141663 Key for the cache table created
  l_ccid_key VARCHAR2(2000);

BEGIN

  -- Bug # 7141663 Key for the cache table created
  -- Bug # 7321887 Replaced TO_DATE() with TO_CHAR()
  l_ccid_key := ccid                 || '~' || chart_of_accounts_id       || '~' ||
                bal_seg_val          || '~' || intercompany_seg_val       || '~' ||
                bal_seg_column_number|| '~' || intercompany_column_number || '~' ||
                TO_CHAR(gl_date,'DD-MM-YYYY');

  -- Bug # 7141663 If the key does not exists in the cache table,
  -- then get the ccid as done previously, else fetch the same from
  -- the cache table.
  IF ( g_ccid_cache_tab.EXISTS( l_ccid_key ) = FALSE ) THEN
	  l_rule := '\nSUMMARY_FLAG\nI\n' ||
		       'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
		       'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
		       '\nI\n' ||
		       'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY';
	  l_delimiter := fnd_flex_ext.get_delimiter('SQLGL', 'GL#', chart_of_accounts_id);
	  l_flag := fnd_flex_ext.get_segments('SQLGL', 'GL#', chart_of_accounts_id, ccid,
							       l_no_of_segments, l_segment_array);
	  IF l_flag = FALSE THEN
	    IF (FND_LOG.LEVEL_ERROR >= g_debug_level) THEN
	      l_error_message := FND_FLEX_KEYVAL.ERROR_MESSAGE;
	      IF l_error_message IS NOT NULL THEN
		FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'fun.plsql.fun_bal_pkg.do_inter_bal.get_segment', l_error_message);
	      END IF;
	    END IF;
	    FND_MESSAGE.SET_NAME('FUN', 'FUN_BAL_GET_CCID_ERROR');
	    FND_MESSAGE.SET_TOKEN('GL_ERROR', FND_FLEX_KEYVAL.ERROR_MESSAGE);
	    FND_MSG_PUB.Add;
	    RETURN -ccid;
	  END IF;
	  l_segment_array(bal_seg_column_number) := bal_seg_val;
	  IF intercompany_column_number IS NOT NULL
	  AND bal_seg_column_number <> intercompany_column_number
	  THEN
	    l_segment_array(intercompany_column_number) :=  intercompany_seg_val;
	  END IF;
	  l_cat_segs := fnd_flex_ext.concatenate_segments(l_no_of_segments, l_segment_array, l_delimiter);
	  l_flag := fnd_flex_keyval.validate_segs('CREATE_COMBINATION','SQLGL',
			      'GL#', chart_of_accounts_id, l_cat_segs,
			      'V', gl_date, 'ALL', NULL, l_rule, l_where_clause,
			      l_get_column, FALSE, FALSE,
			      NULL, NULL, NULL, NULL, NULL, NULL);
	  IF l_flag = FALSE THEN
	    IF (FND_LOG.LEVEL_ERROR >= g_debug_level) THEN
	      l_error_message := FND_FLEX_KEYVAL.ERROR_MESSAGE;
	      IF l_error_message IS NOT NULL THEN
		FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'fun.plsql.fun_bal_pkg.do_inter_bal.validate_segs', l_error_message);
	      END IF;
	    END IF;
	    FND_MESSAGE.SET_NAME('FUN', 'FUN_BAL_GET_CCID_ERROR');
	    FND_MESSAGE.SET_TOKEN('GL_ERROR', FND_FLEX_KEYVAL.ERROR_MESSAGE);
	    FND_MSG_PUB.Add;
	    RETURN -ccid;
	  END IF;

  -- Bug # 7141663 Add the result to the cache table
  g_ccid_cache_tab(l_ccid_key) := fnd_flex_keyval.combination_id;
  END IF;

  -- Bug # 7141663 fetch the ccid from the cache table and return the same
  return g_ccid_cache_tab(l_ccid_key);
END get_ccid;

FUNCTION get_ccid_concat_disp
( ccid IN NUMBER,
  chart_of_accounts_id IN NUMBER,
  bal_seg_val IN VARCHAR2,
  intercompany_seg_val IN VARCHAR2,
  bal_seg_column_number IN NUMBER,
  intercompany_column_number IN NUMBER) RETURN VARCHAR2 IS
  l_segment_array FND_FLEX_EXT.SEGMENTARRAY;
  l_flag BOOLEAN;
  l_no_of_segments NUMBER;
  l_delimiter VARCHAR2(1);
  l_cat_segs VARCHAR2(2000);
  l_ccid NUMBER;
BEGIN
  IF ccid = 0 OR ccid IS NULL THEN
    RETURN NULL;
  ELSIF ccid < 0 THEN
     l_ccid := -ccid;
  ELSE
     l_ccid := ccid;
  END IF;
  l_delimiter := fnd_flex_ext.get_delimiter('SQLGL', 'GL#', chart_of_accounts_id);
  l_flag := fnd_flex_ext.get_segments('SQLGL', 'GL#', chart_of_accounts_id, l_ccid,
                                                       l_no_of_segments, l_segment_array);
  IF ccid < 0 THEN
    l_segment_array(bal_seg_column_number) := bal_seg_val;
    IF intercompany_column_number IS NOT NULL THEN
      l_segment_array(intercompany_column_number) :=  intercompany_seg_val;
    END IF;
  END IF;
  l_cat_segs := fnd_flex_ext.concatenate_segments(l_no_of_segments, l_segment_array, l_delimiter);
  RETURN l_cat_segs;
END get_ccid_concat_disp;

PROCEDURE ins_headers_t(headers_tab IN headers_tab_type, headers_count IN NUMBER) IS
cur_hdl int;
BEGIN

  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_HEADERS_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF headers_count > 0 THEN
    FORALL i IN headers_tab.first..headers_tab.last
      INSERT INTO fun_bal_headers_t
        VALUES headers_tab(i);
  END IF;
END ins_headers_t;


PROCEDURE ins_lines_t(lines_tab IN lines_tab_type, lines_count IN NUMBER) IS
cur_hdl int;
BEGIN
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_LINES_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF lines_count > 0 THEN
    FORALL i IN lines_tab.first..lines_tab.last
      INSERT INTO fun_bal_lines_t
        VALUES lines_tab(i);
  END IF;
END ins_lines_t;

PROCEDURE ins_results_t(results_tab IN results_tab_type, results_count IN NUMBER) IS
cur_hdl int;
BEGIN
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_RESULTS_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF results_count > 0 THEN
    FORALL i IN results_tab.first..results_tab.last
      INSERT INTO fun_bal_results_t
         VALUES results_tab(i);
  END IF;
END ins_results_t;

PROCEDURE ins_errors_t(errors_tab IN errors_tab_type, errors_count IN NUMBER) IS
cur_hdl int;
BEGIN
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_ERRORS_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF errors_count > 0 THEN
    FORALL i IN errors_tab.first..errors_tab.last
      INSERT INTO fun_bal_errors_t
        VALUES errors_tab(i);
   END IF;
END ins_errors_t;

PROCEDURE ins_inter_le_bsv_map_t(le_bsv_map_tab IN inter_le_bsv_map_tab_type, inter_le_bsv_map_count IN NUMBER) IS
cur_hdl int;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'ins_inter_le_bsv_map_t.begin');
  END IF;
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTER_BSV_MAP_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF inter_le_bsv_map_count > 0 THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'ins_inter_le_bsv_map_t.insert_begin');
    END IF;

    FORALL i IN le_bsv_map_tab.first..le_bsv_map_tab.last
      INSERT INTO fun_bal_inter_bsv_map_t
        VALUES le_bsv_map_tab(i);

    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'ins_inter_le_bsv_map_t.insert_end');
    END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'ins_inter_le_bsv_map_t.end');
    END IF;
  END IF;
END ins_inter_le_bsv_map_t;

PROCEDURE ins_inter_int_t(inter_int_tab IN inter_int_tab_type, inter_int_count IN NUMBER) IS
cur_hdl int;
BEGIN
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTER_INT_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor

  IF inter_int_count > 0 THEN
    FORALL i IN inter_int_tab.first..inter_int_tab.last
      INSERT INTO fun_bal_inter_int_t
        VALUES inter_int_tab(i);

  END IF;
END ins_inter_int_t;

PROCEDURE ins_intra_le_bsv_map_t(le_bsv_map_tab IN intra_le_bsv_map_tab_type, intra_le_bsv_map_count IN NUMBER) IS
cur_hdl int;
BEGIN
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTRA_BSV_MAP_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF intra_le_bsv_map_count > 0 THEN
    FORALL i IN le_bsv_map_tab.first..le_bsv_map_tab.last
    INSERT INTO fun_bal_intra_bsv_map_t
      VALUES le_bsv_map_tab(i);
  END IF;
END ins_intra_le_bsv_map_t;


PROCEDURE ins_intra_int_t(intra_int_tab IN intra_int_tab_type, intra_int_count IN NUMBER) IS
cur_hdl int;
BEGIN
  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, 'TRUNCATE TABLE ' || g_fun_schema || '.FUN_BAL_INTRA_INT_T', dbms_sql.native);
  dbms_sql.close_cursor(cur_hdl); -- close cursor
  IF intra_int_count > 0 THEN
    FORALL i IN intra_int_tab.first..intra_int_tab.last
    INSERT INTO fun_bal_intra_int_t
      VALUES intra_int_tab(i);
  END IF;
END ins_intra_int_t;


PROCEDURE ins_t_tables_in_error_auto(headers_tab IN headers_tab_type,
                                                     lines_tab IN lines_tab_type,
                                                     headers_count IN NUMBER,
                                                     lines_count IN NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  ins_headers_t(headers_tab, headers_count);
  ins_lines_t(lines_tab, lines_count);
  COMMIT;
END ins_t_tables_in_error_auto;


PROCEDURE ins_t_tables_final_auto(headers_tab IN headers_tab_type,
                                                     lines_tab IN lines_tab_type,
                                                     results_tab IN results_tab_type,
                                                     errors_tab IN errors_tab_type,
                                                     headers_count IN NUMBER,
                                                     lines_count IN NUMBER,
                                                     results_count IN NUMBER,
                                                     errors_count IN NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  ins_headers_t(headers_tab, headers_count);
  ins_lines_t(lines_tab, lines_count);
  ins_results_t(results_tab, results_count);
  ins_errors_t(errors_tab, errors_count);
/*
   INSERT INTO fun_bal_headers_t
        SELECT * FROM fun_bal_headers_gt;
   INSERT INTO fun_bal_lines_t
        SELECT * FROM fun_bal_lines_gt;
   INSERT INTO fun_bal_results_t
        SELECT * FROM fun_bal_results_gt;
   INSERT INTO fun_bal_errors_t
        SELECT * FROM fun_bal_errors_gt;
*/
    COMMIT;
END ins_t_tables_final_auto;

PROCEDURE ins_t_tables_inter_1_auto(le_bsv_map_tab IN inter_le_bsv_map_tab_type, le_bsv_map_count IN NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'auton_begin');
    END IF;
    ins_inter_le_bsv_map_t(le_bsv_map_tab, le_bsv_map_count);
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'auton_end');
    END IF;

    COMMIT;
END ins_t_tables_inter_1_auto;

PROCEDURE ins_t_tables_inter_2_auto(inter_int_tab IN inter_int_tab_type, inter_int_count IN NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ins_inter_int_t(inter_int_tab, inter_int_count);
    COMMIT;
END ins_t_tables_inter_2_auto;

PROCEDURE ins_t_tables_intra_1_auto(le_bsv_map_tab IN intra_le_bsv_map_tab_type, le_bsv_map_count IN NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   ins_intra_le_bsv_map_t(le_bsv_map_tab, le_bsv_map_count);
    COMMIT;
END ins_t_tables_intra_1_auto;

PROCEDURE ins_t_tables_intra_2_auto(intra_int_tab IN intra_int_tab_type, intra_int_count IN NUMBER) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
--    INSERT INTO fun_bal_intra_int_t
--       SELECT * FROM fun_bal_intra_int_gt;
    ins_intra_int_t(intra_int_tab, intra_int_count);
    COMMIT;
END ins_t_tables_intra_2_auto;

FUNCTION do_init RETURN VARCHAR2 IS
  l_return_val VARCHAR2(1) ;
  l_boolean BOOLEAN;
  l_status VARCHAR2(1);
  l_industry VARCHAR2(1);
BEGIN

l_return_val := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_init.begin', 'begin');
  END IF;
  -- Retrieve the actual FUN schema name from the current installation
  l_boolean := FND_INSTALLATION.GET_APP_INFO('FUN', l_status, l_industry, g_fun_schema);
  IF g_debug = FND_API.G_TRUE THEN
    -- Delete data stored in temporary tables
    truncate_tables;
  END IF;


  -- Note:  bal_seg_column_number is different from SUBSTR(bal_seg_column_name, 8),
  -- since bal_seg_column_name refers to the naming in GL_CODE_COMBINATIONS,
  -- but bal_seg_column_number refers to the position relative to the COA.
  -- These 2 values are used in different context (name when dealing with GL_CODE_COMB table
  -- and number when dealing with AOL routines.  Do not be confused.
  -- Problem here:  Later on when we deal with performance and decided to check whether the
  -- code combination already exists in gl_code_combinations table, we would also need to
  -- retrieve the correct segment_name for intercompany segment.
  -- update balancing segment column, chart of accounts
  --ASLAI_INIT_01
  UPDATE fun_bal_headers_gt headers
  SET (bal_seg_column_name, chart_of_accounts_id) =
  (SELECT bal_seg_column_name, chart_of_accounts_id
   FROM gl_ledgers ledgers
   WHERE headers.ledger_id = ledgers.ledger_id);

  UPDATE fun_bal_headers_gt headers
  SET bal_seg_column_number =  get_segment_index ( headers.chart_of_accounts_id,
                                                  'GL_BALANCING'),
      intercompany_column_number =  get_segment_index ( headers.chart_of_accounts_id,
                                                  'GL_INTERCOMPANY');

  --FND_STATS.GATHER_TABLE_STATS(g_fun_schema, 'FUN_BAL_HEADERS_GT');
  --FND_STATS.GATHER_TABLE_STATS(g_fun_schema, 'FUN_BAL_LINES_GT');

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_init.end', 'end');
  END IF;


  RETURN l_return_val;
END do_init;


PROCEDURE do_save_in_error IS
  l_headers_tab headers_tab_type;
  l_lines_tab lines_tab_type;
  l_headers_count NUMBER;
  l_lines_count NUMBER;
  CURSOR l_headers_cursor IS
    SELECT * FROM fun_bal_headers_gt;
  CURSOR l_lines_cursor IS
    SELECT * FROM fun_bal_lines_gt;
BEGIN
         OPEN l_headers_cursor;
         FETCH l_headers_cursor BULK COLLECT INTO l_headers_tab;
         l_headers_count := l_headers_cursor%ROWCOUNT;
         CLOSE l_headers_cursor;
         OPEN l_lines_cursor;
         FETCH l_lines_cursor BULK COLLECT INTO l_lines_tab;
         l_lines_count := l_lines_cursor%ROWCOUNT;
         CLOSE l_lines_cursor;

         ins_t_tables_in_error_auto(l_headers_tab, l_lines_tab,
                                           l_headers_count, l_lines_count);
END do_save_in_error;


FUNCTION do_finalize RETURN VARCHAR2 IS
  l_return_val VARCHAR2(1) ;
  --l_error_count NUMBER(15) := 0;
  l_headers_tab headers_tab_type;
  l_lines_tab lines_tab_type;
  l_results_tab results_tab_type;
  l_errors_tab errors_tab_type;
  l_headers_count NUMBER;
  l_lines_count NUMBER;
  l_results_count NUMBER;
  l_errors_count NUMBER;
  CURSOR l_headers_cursor IS
    SELECT * FROM fun_bal_headers_gt;
  CURSOR l_lines_cursor IS
    SELECT * FROM fun_bal_lines_gt;
  CURSOR l_results_cursor IS
    SELECT * FROM fun_bal_results_gt;
  CURSOR l_errors_cursor IS
    SELECT * FROM fun_bal_errors_gt;
BEGIN
l_return_val := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_finalize.begin', 'begin');
  END IF;

  -- Insert lines generated for Intercompany balancing from FUN_BAL_LINES_GT to FUN_BAL_RESULTS_GT
          INSERT INTO fun_bal_results_gt results(group_id, bal_seg_val, entered_amt_dr,
            entered_amt_cr, entered_currency_code, exchange_date, exchange_rate, exchange_rate_type,
        accounted_amt_dr, accounted_amt_cr, ccid, balancing_type)
        SELECT lines.group_id, lines.bal_seg_val, lines.entered_amt_dr,
        lines.entered_amt_cr, lines.entered_currency_code, lines.exchange_date, lines.exchange_rate,
        lines.exchange_rate_type, lines.accounted_amt_dr, lines.accounted_amt_cr,
        lines.ccid, 'E'
        FROM fun_bal_lines_gt lines
        WHERE lines.generated = 'Y';

        -- Bug 3167894
        UPDATE fun_bal_results_gt results
        SET entered_amt_dr = DECODE(entered_amt_dr, NULL, DECODE(accounted_amt_dr, NULL, entered_amt_dr, 0), entered_amt_dr),
               entered_amt_cr = DECODE(entered_amt_cr, NULL, DECODE(accounted_amt_cr, NULL, entered_amt_cr, 0), entered_amt_cr),
               accounted_amt_dr = DECODE(accounted_amt_dr, NULL, DECODE(entered_amt_dr, NULL, accounted_amt_dr, 0), accounted_amt_dr),
               accounted_amt_cr = DECODE(accounted_amt_cr, NULL, DECODE(entered_amt_cr, NULL, accounted_amt_cr, 0), accounted_amt_cr);

       IF g_debug = FND_API.G_TRUE THEN
         OPEN l_headers_cursor;
         FETCH l_headers_cursor BULK COLLECT INTO l_headers_tab;
         l_headers_count := l_headers_cursor%ROWCOUNT;
         CLOSE l_headers_cursor;
         OPEN l_lines_cursor;
         FETCH l_lines_cursor BULK COLLECT INTO l_lines_tab;
         l_lines_count := l_lines_cursor%ROWCOUNT;
         CLOSE l_lines_cursor;
         OPEN l_results_cursor;
         FETCH l_results_cursor BULK COLLECT INTO l_results_tab;
         l_results_count := l_results_cursor%ROWCOUNT;
         CLOSE l_results_cursor;
         OPEN l_errors_cursor;
         FETCH l_errors_cursor BULK COLLECT INTO l_errors_tab;
         l_errors_count := l_errors_cursor%ROWCOUNT;
         CLOSE l_errors_cursor;

         ins_t_tables_final_auto(l_headers_tab, l_lines_tab, l_results_tab, l_errors_tab,
                                           l_headers_count, l_lines_count, l_results_count, l_errors_count);
       ELSE
         SELECT COUNT(*) INTO l_errors_count
         FROM fun_bal_errors_gt;
       END IF;

       IF l_errors_count > 0 THEN
          l_return_val := FND_API.G_RET_STS_ERROR;
       END IF;

       IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_finalize.end', 'end');
       END IF;
       RETURN l_return_val;
END do_finalize;


FUNCTION do_inter_bal RETURN VARCHAR2 IS
  l_le_bsv_map_tab inter_le_bsv_map_tab_type;
  l_inter_int_tab inter_int_tab_type;
  CURSOR l_le_bsv_map_cursor IS
    SELECT * FROM fun_bal_le_bsv_map_gt;
  CURSOR l_inter_int_cursor IS
    SELECT * FROM fun_bal_inter_int_gt;
  l_le_bsv_map_count NUMBER;
  l_inter_int_count NUMBER;

BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.begin', 'begin');
    END IF;

/*  Replaced by sql below from performance review
    INSERT INTO fun_bal_le_bsv_map_gt(group_id, ledger_id, bal_seg_val, gl_date)
          SELECT DISTINCT hdrs.group_id, hdrs.ledger_id, lines.bal_seg_val, hdrs.gl_date
          FROM fun_bal_headers_gt hdrs, fun_bal_lines_gt lines, gl_ledgers ledger,
                gl_ledger_configurations config
          WHERE hdrs.group_id = lines.group_id
            AND hdrs.ledger_id = ledger.ledger_id
            AND ledger.configuration_id = config.configuration_id
        AND ledger.bal_seg_value_option_code = 'I';
      -- Only possible scenario to perform Intercompany is when bal_seg_value_option_code is 'I' and acct_env_code is 'SHARED'

          -- Update legal entity column in FUN_BAL_LE_BSV_MAP_GT

      -- Legal entity can only be either null or has a specific value
          UPDATE fun_bal_le_bsv_map_gt bsv_le_map
          SET le_id =
            NVL((SELECT vals.legal_entity_id
             FROM gl_ledger_le_bsv_specific_v vals
             WHERE bsv_le_map.bal_seg_val = vals.segment_value
                AND (TRUNC(bsv_le_map.gl_date) BETWEEN TRUNC(NVL(vals.start_date, bsv_le_map.gl_date)) AND
                                                                  TRUNC(NVL(vals.end_date, bsv_le_map.gl_date)))
                AND bsv_le_map.ledger_id = vals.ledger_id
        ), -99);

*/

    -- Bug 3310453
    INSERT INTO fun_bal_errors_gt(error_code, group_id, bal_seg_val)
      SELECT 'FUN_BSV_INVALID', main.group_id, main.bal_seg_val
      FROM (SELECT DISTINCT hdrs.group_id, lines.bal_seg_val, hdrs.gl_date, hdrs.ledger_id
                 FROM fun_bal_headers_gt hdrs, fun_bal_lines_gt lines, gl_ledgers ledger
                 WHERE hdrs.group_id = lines.group_id
                 AND hdrs.ledger_id = ledger.ledger_id(+)
                 AND ledger.bal_seg_value_option_code = 'I') main
      WHERE main.bal_seg_val NOT IN (SELECT vals.segment_value
                                                        FROM gl_ledger_le_bsv_specific_v vals
                                                        WHERE main.ledger_id = vals.ledger_id
                                                             AND TRUNC(main.gl_date) BETWEEN
                                                                        TRUNC(NVL(vals.start_date, main.gl_date)) AND
                                                                        TRUNC(NVL(vals.end_date, main.gl_date)));
    -- Bug 3310453
     UPDATE fun_bal_headers_gt headers
     SET status = 'ERROR',
            error_code = 'FUN_BSV_INVALID'
     WHERE EXISTS (SELECT 'Invalid BSV Error'
                               FROM FUN_BAL_ERRORS_GT errors
                               WHERE headers.group_id =  errors.group_id
                                    AND error_code IN ('FUN_BSV_INVALID'))
     AND headers.status = 'OK';

    -- Select the distinct combination of GROUP_ID, LEDGER_ID and BAL_SEG_VAL into
    -- FUN_BAL_LE_BSV_MAP_GT.  We are only inserting the journals with ledgers in shared
    -- mode configuration, as intercompany balancing should only be performed in shared mode.
    -- Doing so should decrease the amount of processing time required at a later stage.

     -- Only possible scenario to perform Intercompany is when bal_seg_value_option_code is 'I' and acct_env_code is 'SHARED'
         -- Update legal entity column in FUN_BAL_LE_BSV_MAP_GT
     -- Legal entity can only be either null or has a specific value

	--ER: 8588074
	--Bug: 9183927

    INSERT INTO fun_bal_le_bsv_map_gt(group_id, ledger_id, bal_seg_val, gl_date, le_id, je_source_name, je_category_name)
          SELECT main.group_id, main.ledger_id, main.bal_seg_val, main.gl_date, NVL(vals.legal_entity_id, -99),
	         main.je_source_name, main.je_category_name
      FROM (SELECT DISTINCT hdrs.group_id, hdrs.ledger_id, lines.bal_seg_val, hdrs.gl_date, hdrs.je_source_name, hdrs.je_category_name
                FROM fun_bal_headers_gt hdrs, fun_bal_lines_gt lines, gl_ledgers ledger,
                gl_ledger_configurations config
            WHERE hdrs.status = 'OK'  -- Bug 3310453
              AND hdrs.group_id = lines.group_id
              AND hdrs.ledger_id = ledger.ledger_id(+)
              AND ledger.configuration_id = config.configuration_id
              AND ledger.configuration_id <> -2  -- Bug 3271446
              AND ledger.bal_seg_value_option_code = 'I') main,
            gl_ledger_le_bsv_specific_v vals
          WHERE main.bal_seg_val = vals.segment_value(+)
        AND (TRUNC(main.gl_date) BETWEEN TRUNC(NVL(vals.start_date, main.gl_date)) AND
                                                                  TRUNC(NVL(vals.end_date, main.gl_date)))
            AND main.ledger_id = vals.ledger_id(+);


    UPDATE fun_bal_headers_gt headers
    SET (le_id, le_count) =
    (SELECT MIN(le_bsv_map.le_id), SUM(COUNT(DISTINCT  le_bsv_map.le_id))
    FROM fun_bal_le_bsv_map_gt le_bsv_map
    WHERE headers.group_id = le_bsv_map.group_id
        AND le_bsv_map.le_id <> -99
        GROUP BY le_bsv_map.group_id, le_bsv_map.le_id, le_bsv_map.bal_seg_val);

   UPDATE fun_bal_headers_gt headers
   SET status = DECODE(le_id, NULL, status, 'ERROR'),
         error_code = DECODE(le_id, NULL, error_code, 'FUN_INTER_BSV_NOT_ASSIGNED'),
         unmapped_bsv_le_id = -99
   WHERE EXISTS (SELECT 'Unmapped BSV exists'
                             FROM fun_bal_le_bsv_map_gt le_bsv_map
                             WHERE le_bsv_map.group_id = headers.group_id
                             AND le_bsv_map.le_id = -99);


   --      Error out if error out bsv is provided and either one of the following conditions are true:
   -- I)  more than one le count
   -- II) one le count and non-mapped count
   -- III) the clearing BSV entered does not belong to the LE or to the ledger
   --       or one le count and non-mapped count
   -- IV) le_count IS NULL and unmapped_bsv_le_id IS NULL if not shared configuration
   --      and BSV validation set to specific
        UPDATE fun_bal_headers_gt headers
        SET status = 'ERROR',
              error_code = 'FUN_INTRA_OVERRIDE_BSV_ERROR'
        WHERE headers.status = 'OK'
            AND headers.clearing_bsv IS NOT NULL
            AND NOT (headers.le_count IS NULL AND headers.unmapped_bsv_le_id IS NULL) -- Bug 3278912
            AND (headers.le_count > 1
                    OR
                    (headers.le_count = 1 AND headers.unmapped_bsv_le_id = -99)
                     OR
                   (headers.le_id IS NOT NULL
                     AND NOT EXISTS (SELECT 'BSV belongs to the LE'
                                FROM gl_ledger_le_bsv_specific_v vals
                                WHERE vals.segment_value = headers.clearing_bsv
                                AND vals.ledger_id = headers.ledger_id
                                AND vals.legal_entity_id = headers.le_id))
                      OR
                    (headers.le_id IS NULL
                      AND EXISTS (SELECT 'BSV belongs to Ledger'
                                FROM gl_ledger_le_bsv_specific_v vals
                                WHERE vals.segment_value = headers.clearing_bsv
                                AND vals.ledger_id = headers.ledger_id
                                AND vals.legal_entity_id IS NOT NULL))); -- Bug 3278912

    -- Bug 3310453
    UPDATE fun_bal_headers_gt hdrs
    SET status = 'ERROR',
           error_code = 'FUN_INTRA_OVERRIDE_BSV_ERROR'
    WHERE hdrs.status = 'OK'
         AND hdrs.clearing_bsv IS NOT NULL
         AND NOT (hdrs.ledger_id IN (SELECT ledgers.ledger_id
                                      FROM gl_ledgers ledgers
                                      WHERE ledgers.bal_seg_value_option_code = 'A')
                         OR
                         hdrs.clearing_bsv IN (SELECT vals.segment_value
                                                         FROM gl_ledger_le_bsv_specific_v vals
                                                         WHERE hdrs.ledger_id = vals.ledger_id
                                                             AND TRUNC(hdrs.gl_date) BETWEEN
                                                                TRUNC(NVL(vals.start_date, hdrs.gl_date))
                                                                AND
                                                                TRUNC(NVL(vals.end_date, hdrs.gl_date))));

     INSERT INTO fun_bal_errors_gt(error_code, group_id, clearing_bsv)
     SELECT 'FUN_INTRA_OVERRIDE_BSV_ERROR', hdrs.group_id, hdrs.clearing_bsv
     FROM fun_bal_headers_gt hdrs
     WHERE hdrs.error_code = 'FUN_INTRA_OVERRIDE_BSV_ERROR';

     INSERT INTO fun_bal_errors_gt(error_code, group_id, bal_seg_val)
     SELECT 'FUN_INTER_BSV_NOT_ASSIGNED', hdrs.group_id, le_bsv_map.bal_seg_val
     FROM fun_bal_headers_gt hdrs, fun_bal_le_bsv_map_gt le_bsv_map
     WHERE hdrs.group_id = le_bsv_map.group_id
       AND hdrs.error_code = 'FUN_INTER_BSV_NOT_ASSIGNED'
       AND le_bsv_map.le_id = -99;

     --FND_STATS.GATHER_TABLE_STATS(g_fun_schema, 'FUN_BAL_LE_BSV_MAP_GT');

     IF g_debug = FND_API.G_TRUE THEN
         OPEN l_le_bsv_map_cursor;
         FETCH l_le_bsv_map_cursor BULK COLLECT INTO l_le_bsv_map_tab;
         l_le_bsv_map_count := l_le_bsv_map_cursor%ROWCOUNT;
         CLOSE l_le_bsv_map_cursor;
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'begin');
    END IF;
        ins_t_tables_inter_1_auto(l_le_bsv_map_tab, l_le_bsv_map_count);
    IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.ins_t_tables_inter_1_auto', 'end');
    END IF;

     END IF;


     DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map
     WHERE group_id = (SELECT group_id
                                   FROM fun_bal_headers_gt headers
                                   WHERE headers.status = 'ERROR'
                                   AND le_bsv_map.group_id = headers.group_id);

     DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map_del
     WHERE EXISTS (SELECT 'LE already balanced'
                              FROM fun_bal_lines_gt lines, fun_bal_le_bsv_map_gt le_bsv_map
                              WHERE le_bsv_map_del.group_id = le_bsv_map.group_id
                                  AND le_bsv_map_del.le_id = le_bsv_map.le_id
                                  AND le_bsv_map.group_id = lines.group_id
                                  AND le_bsv_map.bal_seg_val = lines.bal_seg_val
                             GROUP BY le_bsv_map.group_id, le_bsv_map.le_id
                             HAVING (SUM(NVL(lines.accounted_amt_dr, 0)) =
                                               SUM(NVL(lines.accounted_amt_cr, 0)))
                                               AND
                                           SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0))=
                                           SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0)));


      -- Determine driving_dr_le_id, intercompany mode
          UPDATE fun_bal_headers_gt hdrs
          SET (driving_dr_le_id, intercompany_mode) =
            (SELECT MIN(le_bsv_map.le_id),
                SUM(COUNT(DISTINCT(le_bsv_map.le_id)))
             FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines
             WHERE hdrs.group_id = le_bsv_map.group_id
                AND le_bsv_map.group_id = lines.group_id
                AND le_bsv_map.bal_seg_val = lines.bal_seg_val
             GROUP BY le_bsv_map.group_id, le_bsv_map.le_id
             HAVING (SUM(NVL(lines.accounted_amt_dr, 0)) >
               SUM(NVL(lines.accounted_amt_cr, 0)))
               OR
           ((SUM(NVL(lines.accounted_amt_dr, 0)) =
               SUM(NVL(lines.accounted_amt_cr, 0))) AND
           SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0)) >
           SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0))))
          WHERE status = 'OK';


      -- Deleting the records that do not require intercompany balancing.
      -- Deleting these records first should make the code perform better,
      -- as there won't be any more join to these lines.
      DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map
      WHERE EXISTS
      (SELECT 'Intercompany balancing is not required'
      FROM fun_bal_headers_gt hdrs
      WHERE le_bsv_map.group_id = hdrs.group_id
      AND hdrs.status = 'OK'
      AND hdrs.intercompany_mode IS NULL);

          -- Determine driving_cr_le_id, intercompany_mode
          UPDATE fun_bal_headers_gt hdrs
          SET (driving_cr_le_id, intercompany_mode) =
            (SELECT MIN(le_bsv_map.le_id),
                DECODE(SUM(COUNT(DISTINCT(le_bsv_map.le_id))), 1,
                      DECODE(hdrs.intercompany_mode, 1, 1, 3),
                      DECODE(hdrs.intercompany_mode, 1, 2, 4))
             FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines
             WHERE hdrs.group_id = le_bsv_map.group_id
                AND le_bsv_map.group_id = lines.group_id
                AND le_bsv_map.bal_seg_val = lines.bal_seg_val
             GROUP BY le_bsv_map.group_id, le_bsv_map.le_id
             HAVING (SUM(NVL(lines.accounted_amt_cr, 0)) >
               SUM(NVL(lines.accounted_amt_dr, 0)))
               OR
           ((SUM(NVL(lines.accounted_amt_dr, 0)) =
               SUM(NVL(lines.accounted_amt_cr, 0))) AND
           SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0)) >
           SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0))))
       WHERE status = 'OK';

      DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map
      WHERE EXISTS (SELECT 'No Driving DR LE or Driving CR LE'
                               FROM fun_bal_headers_gt headers
                               WHERE headers.group_id = le_bsv_map.group_id
                               AND headers.status = 'OK'
                               AND (headers.driving_dr_le_id IS NULL
                                       OR
                                       headers.driving_cr_le_id IS NULL));

      -- Insert into FUN_BAL_INTER_INT2_GT with all lines that require Intercompany balancing
   -- Changed the query for bug 9433610
INSERT INTO FUN_BAL_INTER_INT2_GT
            (GROUP_ID,
             LEDGER_ID,
             GL_DATE,
             STATUS,
             DRIVING_DR_LE_ID,
             DRIVING_CR_LE_ID,
             INTERCOMPANY_MODE,
             LE_ID,
             ENTERED_CURRENCY_CODE,
             EXCHANGE_DATE,
             EXCHANGE_RATE,
             EXCHANGE_RATE_TYPE,
             ACCOUNTED_AMT_CR,
             ACCOUNTED_AMT_DR,
             ENTERED_AMT_CR,
             ENTERED_AMT_DR,
             BAL_SEG_COLUMN_NAME,
             LINE_LE_BSV,
             TYPE)
SELECT GROUP_ID,
       LEDGER_ID,
       GL_DATE,
       STATUS,
       DRIVING_DR_LE_ID,
       DRIVING_CR_LE_ID,
       INTERCOMPANY_MODE,
       LE_ID,
       ENTERED_CURRENCY_CODE,
       SYSDATE,
       DECODE(EXCHANGE_RATE, NULL, NULL,
                             DECODE (TYPE, 'D', ACCOUNTED_AMT_DR / ENTERED_AMT_DR,
                                           ACCOUNTED_AMT_CR / ENTERED_AMT_CR)) EXCHANGE_RATE,
       'User',
       ACCOUNTED_AMT_CR,
       ACCOUNTED_AMT_DR,
       ENTERED_AMT_CR,
       ENTERED_AMT_DR,
       BAL_SEG_COLUMN_NAME,
       BAL_SEG_VAL,
       TYPE
FROM   (SELECT HDRS.GROUP_ID GROUP_ID,
               HDRS.LEDGER_ID LEDGER_ID,
               HDRS.GL_DATE GL_DATE,
               HDRS.STATUS STATUS,
               HDRS.DRIVING_DR_LE_ID DRIVING_DR_LE_ID,
               HDRS.DRIVING_CR_LE_ID DRIVING_CR_LE_ID,
               HDRS.INTERCOMPANY_MODE INTERCOMPANY_MODE,
               LE_BSV_MAP.LE_ID LE_ID,
               LINES.ENTERED_CURRENCY_CODE ENTERED_CURRENCY_CODE,
               LINES.EXCHANGE_DATE EXCHANGE_DATE,
               MAX(LINES.EXCHANGE_RATE) EXCHANGE_RATE,
               LINES.EXCHANGE_RATE_TYPE EXCHANGE_RATE_TYPE,
               DECODE(SIGN(SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))),
			1, ABS(SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))),
                        NULL) ACCOUNTED_AMT_CR,
               DECODE(SIGN(SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))),
			-1, ABS(SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))),
                        NULL) ACCOUNTED_AMT_DR,
               DECODE(SIGN(SUM(NVL(LINES.ENTERED_AMT_CR, 0)) - SUM(NVL(LINES.ENTERED_AMT_DR, 0))),
			1, ABS(SUM(NVL(LINES.ENTERED_AMT_CR, 0)) - SUM(NVL(LINES.ENTERED_AMT_DR, 0))),
                         NULL) ENTERED_AMT_CR,
               DECODE(SIGN(SUM(NVL(LINES.ENTERED_AMT_CR, 0)) - SUM(NVL(LINES.ENTERED_AMT_DR, 0))),
			-1, ABS(SUM(NVL(LINES.ENTERED_AMT_CR, 0)) - SUM(NVL(LINES.ENTERED_AMT_DR, 0))),
                        NULL) ENTERED_AMT_DR,
               HDRS.BAL_SEG_COLUMN_NAME  BAL_SEG_COLUMN_NAME,
               LINES.BAL_SEG_VAL BAL_SEG_VAL,
               DECODE(SIGN(SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))),
			1, 'C',
		       -1, 'D',
		        0, DECODE(SIGN((( SUM(NVL(LINES.ENTERED_AMT_CR, 0)) - SUM(NVL(LINES.ENTERED_AMT_DR, 0)) )) -
			( SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) )), 1, 'C', 'D')) TYPE
        FROM   FUN_BAL_LE_BSV_MAP_GT LE_BSV_MAP,
               FUN_BAL_LINES_GT LINES,
               FUN_BAL_HEADERS_GT HDRS
        WHERE  HDRS.GROUP_ID = LINES.GROUP_ID
               AND LINES.GROUP_ID = LE_BSV_MAP.GROUP_ID
               AND LINES.BAL_SEG_VAL = LE_BSV_MAP.BAL_SEG_VAL
               AND HDRS.INTERCOMPANY_MODE IN ( 1, 2, 3, 4 )
               AND HDRS.STATUS = 'OK'
        GROUP  BY HDRS.GROUP_ID,
                  HDRS.LEDGER_ID,
                  HDRS.GL_DATE,
                  HDRS.STATUS,
                  HDRS.DRIVING_DR_LE_ID,
                  HDRS.DRIVING_CR_LE_ID,
                  HDRS.INTERCOMPANY_MODE,
                  LE_BSV_MAP.LE_ID,
                  LINES.ENTERED_CURRENCY_CODE,
                  -- LINES.EXCHANGE_DATE,
                  -- lines.exchange_rate,
                  -- LINES.EXCHANGE_RATE_TYPE,
                  HDRS.BAL_SEG_COLUMN_NAME,
                  HDRS.INTERCOMPANY_COLUMN_NUMBER,
                  LINES.BAL_SEG_VAL
        HAVING SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) <> SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))
                OR ( SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0)) = SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0))
                     AND SUM(DECODE(LINES.EXCHANGE_RATE, NULL, NVL(LINES.ENTERED_AMT_CR, 0),
                                                         0)) <> SUM(DECODE(LINES.EXCHANGE_RATE, NULL, NVL(LINES.ENTERED_AMT_DR, 0),
                                                                                                0)) ));


      -- Balancing API changes, Feb 22 2005, Start
      -- We now need to find the the payables and receivables account using
      -- the Legal Entity and BSV value. Initially we found the account using
      -- only the LE id.
      -- Find out the balancing segment values for the dr le id
      -- This will set the value correctly where  mode is 1 : 1 or 1 : M

       UPDATE fun_bal_inter_int2_gt upd
      SET    driving_dr_le_bsv =
                (SELECT DECODE((COUNT(DISTINCT le_bsv_map.bal_seg_val)),
                                1, MIN(le_bsv_map.bal_seg_val),
                                'Many')
                 FROM fun_bal_le_bsv_map_gt le_bsv_map
                 WHERE upd.group_id         = le_bsv_map.group_id
                 AND   upd.driving_dr_le_id = le_bsv_map.le_id
                 GROUP BY le_bsv_map.group_id, le_bsv_map.le_id);

      -- Find out the balancing segment values for the cr le id
      -- This will set the value correctly where  mode is 1 : 1 or M : 1
      UPDATE fun_bal_inter_int2_gt upd
      SET    driving_cr_le_bsv =
                (SELECT DECODE((COUNT(DISTINCT le_bsv_map.bal_seg_val)),
                                1, MIN(le_bsv_map.bal_seg_val),
                                'Many')
                 FROM fun_bal_le_bsv_map_gt le_bsv_map
                 WHERE upd.group_id         = le_bsv_map.group_id
                 AND   upd.driving_cr_le_id = le_bsv_map.le_id
                 GROUP BY le_bsv_map.group_id, le_bsv_map.le_id);

--updating the driving_dr_le_bsv ,driving_cr_le_bsv for the Many to many case #9392684
Update fun_bal_inter_int2_gt
SET (driving_dr_le_bsv, driving_cr_le_bsv)=(Select 'Many','Many' from Dual)
where group_id IN (Select upd1.group_id from (select count(DISTINCT inter_int2.line_le_bsv) count1, group_id from fun_bal_inter_int2_gt inter_int2
where type='D'
GROUP by group_id) upd1,
(select count(DISTINCT inter_int2.line_le_bsv) count1, group_id from fun_bal_inter_int2_gt inter_int2
WHERE type='C'
GROUP by group_id) upd2
WHERE upd1.group_id=upd2.group_id
AND upd1.count1 > 1
AND upd2.count1 > 1) ;

--change in Driving Debit and driving credit leid

UPDATE fun_bal_inter_int2_gt upd1
      SET    driving_dr_le_id =  DECODE(TYPE, 'D', LE_ID, DECODE((select count(*) from fun_bal_inter_int2_gt UPD2
                 WHERE type = 'D' AND upd2.group_id=upd1.group_id), 1, (SELECT MIN(LE_ID) FROM fun_bal_inter_int2_gt upd3 WHERE TYPE = 'D' AND upd3.group_id= upd1.group_id), -1))
WHERE intercompany_mode IN (1,2,3)
AND ( driving_dr_le_bsv   <>'Many'
      OR driving_cr_le_bsv   <>'Many');
UPDATE fun_bal_inter_int2_gt upd1
      SET    driving_cr_le_id =  DECODE(TYPE, 'C', LE_ID, DECODE((select count(*) from fun_bal_inter_int2_gt UPD2
                 WHERE type = 'C' AND upd2.group_id=upd1.group_id), 1, (SELECT MIN(LE_ID) FROM fun_bal_inter_int2_gt upd3 WHERE TYPE = 'C' AND upd3.group_id= upd1.group_id), -1))
WHERE intercompany_mode IN (1,2,3)
AND ( driving_dr_le_bsv   <>'Many'
      OR driving_cr_le_bsv   <>'Many');

-- marking the lines to be deletd which need intracompany balancing #9392684
UPDATE fun_bal_inter_int2_gt inter_int1 SET status='DEL'
WHERE (inter_int1.type, inter_int1.le_id,inter_int1.group_id) IN
  (SELECT DECODE(SIGN(NVL(cr_sum, 0) - NVL(dr_sum, 0)), 1, 'D', -1, 'C', 'X'),
    le_id,
    group_id
  FROM
    (SELECT SUM(entered_amt_cr) cr_sum,
      SUM(entered_amt_dr) dr_sum,
      le_id,
      group_id
    FROM fun_bal_inter_int2_gt inter_int2
    WHERE (inter_int2.le_id,inter_int2.group_id) IN
      (SELECT le_id,
        group_id
      FROM fun_bal_inter_int2_gt
      WHERE intercompany_mode IN (1,2,3)
      AND ((driving_cr_le_bsv  ='Many'
      AND driving_dr_le_bsv   <>'Many')
      OR (driving_dr_le_bsv    ='Many'
      AND driving_cr_le_bsv   <>'Many'))
      HAVING COUNT(*)          > 1
      GROUP BY group_id,
        le_id
      )
    GROUP BY le_id,
      group_id
    )
  ) ;

 --updating the entered dr and cr values of the lines that do not need to be deleted.#9392684
UPDATE fun_bal_inter_int2_gt inter_int1
SET
  (
    inter_int1.entered_amt_cr
  )
  =
  (SELECT NVL(inter_int1.entered_amt_cr,0) - NVL(SUM(NVL(inter_int2.entered_amt_dr,0)),0)
  FROM fun_bal_inter_int2_gt inter_int2
  WHERE inter_int2.type='D'
  AND inter_int2.le_id= inter_int1.le_id
  AND inter_int2.group_id = inter_int1.group_id
  group by inter_int2.group_id)
WHERE inter_int1.type='C'
AND 'D'=(Select DISTINCT type from fun_bal_inter_int2_gt inter_int3
WHERE inter_int3.group_id= inter_int1.group_id
AND inter_int3.le_id= inter_int1.le_id
AND inter_int3.status='DEL');

--9692257
UPDATE fun_bal_inter_int2_gt inter_int1
SET
  (
    inter_int1.accounted_amt_cr
  )
  =
  (SELECT NVL(inter_int1.accounted_amt_cr,0) - NVL(SUM(NVL(inter_int2.accounted_amt_dr,0)),0)
  FROM fun_bal_inter_int2_gt inter_int2
  WHERE inter_int2.type='D'
  AND inter_int2.le_id= inter_int1.le_id
  AND inter_int2.group_id = inter_int1.group_id
  )
WHERE inter_int1.type='C'
AND 'D'=(Select DISTINCT type from fun_bal_inter_int2_gt inter_int3
WHERE inter_int3.group_id= inter_int1.group_id
AND inter_int3.le_id= inter_int1.le_id
AND inter_int3.status='DEL');


-- End 9692257

UPDATE fun_bal_inter_int2_gt inter_int1
SET
  (
    inter_int1.entered_amt_dr
  )
  =
  (SELECT NVL(inter_int1.entered_amt_dr,0) - NVL(SUM(NVL(inter_int2.entered_amt_cr,0)),0)
  FROM fun_bal_inter_int2_gt inter_int2
  WHERE inter_int2.type='C'
  AND inter_int2.le_id= inter_int1.le_id
  AND inter_int2.group_id = inter_int1.group_id)
WHERE inter_int1.type='D'
AND 'C'=(Select distinct type from fun_bal_inter_int2_gt inter_int3
WHERE inter_int3.group_id= inter_int1.group_id
AND inter_int3.le_id= inter_int1.le_id
AND inter_int3.status='DEL');

-- 9692257
UPDATE fun_bal_inter_int2_gt inter_int1
SET
  (
    inter_int1.accounted_amt_dr
  )
  =
  (SELECT NVL(inter_int1.accounted_amt_dr,0) - NVL(SUM(NVL(inter_int2.accounted_amt_cr,0)),0)
  FROM fun_bal_inter_int2_gt inter_int2
  WHERE inter_int2.type='C'
  AND inter_int2.le_id= inter_int1.le_id
  AND inter_int2.group_id = inter_int1.group_id)
WHERE inter_int1.type='D'
AND 'C'=(Select distinct type from fun_bal_inter_int2_gt inter_int3
WHERE inter_int3.group_id= inter_int1.group_id
AND inter_int3.le_id= inter_int1.le_id
AND inter_int3.status='DEL');

--End 9692257


--Deleting those BSVs from the fun_bal_le_bsv_map_gt which do not need intercompany balancing #9392684
DELETE from fun_bal_le_bsv_map_gt le_bsv_map
WHERE bal_seg_val IN (Select line_le_bsv from fun_bal_inter_int2_gt
WHERE group_id= le_bsv_map.group_id
AND le_id= le_bsv_map.le_id
AND status='DEL'
OR (NVL(entered_amt_cr,0)=0 AND NVL(entered_amt_dr,0)=0)
)
OR bal_seg_val NOT IN (Select line_le_bsv from fun_bal_inter_int2_gt
WHERE group_id= le_bsv_map.group_id
AND le_id= le_bsv_map.le_id
) ;
--Deleting those lines which do not need intercompany balancing #9392684
DELETE from fun_bal_inter_int2_gt
where status='DEL'
OR (NVL(entered_amt_cr,0)=0 AND NVL(entered_amt_dr,0)=0);
 /*
--updating the driving_dr_le_id, driving_dr_le_bsv and pay_bsv for the 1:M and M:1 case #9392684
      UPDATE fun_bal_inter_int2_gt upd
          SET (driving_dr_le_id, driving_dr_le_bsv,pay_bsv) =
            (SELECT DISTINCT le_bsv_map.le_id,le_bsv_map.bal_seg_val,le_bsv_map.bal_seg_val
             FROM fun_bal_le_bsv_map_gt le_bsv_map
             WHERE le_bsv_map.group_id= upd.group_id
             AND upd.line_le_bsv= le_bsv_map.bal_seg_val
             )
       WHERE intercompany_mode IN (1,2,3)
         AND upd.driving_dr_le_bsv='Many'
         AND upd.driving_cr_le_bsv <>'Many'
         AND upd.driving_cr_le_bsv<>upd.line_le_bsv
         AND status = 'OK'
         AND upd.type='D';
--updating the driving_cr_le_id, driving_cr_le_bsv and rec_bsv for the 1:M and M:1 case #9392684
      UPDATE fun_bal_inter_int2_gt upd
          SET (driving_cr_le_id, driving_cr_le_bsv,rec_bsv) =
            (SELECT DISTINCT le_bsv_map.le_id,le_bsv_map.bal_seg_val,le_bsv_map.bal_seg_val
             FROM fun_bal_le_bsv_map_gt le_bsv_map
             WHERE le_bsv_map.group_id= upd.group_id
               AND upd.line_le_bsv= le_bsv_map.bal_seg_val
             )
       WHERE intercompany_mode IN (1,2,3)
         AND upd.driving_cr_le_bsv='Many'
         AND upd.driving_dr_le_bsv <>'Many'
         AND upd.driving_dr_le_bsv<>upd.line_le_bsv
         AND status = 'OK'
         AND upd.type='C';
 */

--change in bsv level mode:
UPDATE fun_bal_inter_int2_gt upd1
      SET driving_dr_le_bsv= DECODE(upd1.driving_dr_le_id,-1,'Many',
                                                         le_id, line_le_bsv,
                                                         (select bal_seg_val
                                                          from fun_bal_le_bsv_map_gt
                                                          where group_id=upd1.group_id
                                                          and le_id= upd1.driving_dr_le_id)),
         driving_cr_le_bsv= DECODE(upd1.driving_cr_le_id,-1,'Many',
                                                          le_id, line_le_bsv,
                                                          (select bal_seg_val
                                                           from fun_bal_le_bsv_map_gt
                                                           where group_id=upd1.group_id
                                                           and le_id= upd1.driving_cr_le_id))
      Where intercompany_mode in (1,2,3)
AND ( driving_dr_le_bsv   <>'Many'
      OR driving_cr_le_bsv   <>'Many');


-- updating the pay_bsv and rec_bsv for one-many and many-one cases
UPDATE fun_bal_inter_int2_gt SET REC_BSV = driving_cr_le_bsv,PAY_BSV = driving_dr_le_bsv
    WHERE intercompany_mode IN (1,2,3)
    AND driving_dr_le_bsv    <>'Many'
      OR driving_cr_le_bsv   <>'Many';



--inserting the lines of 1:1 into fun_bal_inter_int_gt #9392684
 INSERT into fun_bal_inter_int_gt
 (Select * from fun_bal_inter_int2_gt
 where driving_cr_le_bsv<>'Many'
 and driving_dr_le_bsv<>'Many') ;
 --inserting the lines of M:M into fun_bal_gt by summarizing at LE level #9392684
 INSERT
INTO fun_bal_inter_int_gt
  (
    group_id,
    ledger_id,
    gl_date,
    status,
    driving_dr_le_id,
    driving_cr_le_id,
    intercompany_mode,
    le_id,
    entered_currency_code,
    exchange_date,
    exchange_rate,
    exchange_rate_type,
    accounted_amt_cr,
    accounted_amt_dr,
    entered_amt_cr,
    entered_amt_dr,
    bal_seg_column_name,
    type,
    driving_dr_le_bsv,
    driving_cr_le_bsv
  )
SELECT upd1.group_id,
  upd1.ledger_id,
  upd1.gl_date,
  upd1.status,
  upd1.driving_dr_le_id,
  upd1.driving_cr_le_id,
  upd1.intercompany_mode,
  upd1.le_id,
  upd1.entered_currency_code,
  upd1.exchange_date,
  upd1.exchange_rate,
  upd1.exchange_rate_type,
  DECODE(SIGN(SUM(NVL(upd1.accounted_amt_cr, 0)) - SUM(NVL(upd1.accounted_amt_dr, 0))), 1, ABS(SUM(NVL(upd1.accounted_amt_cr, 0)) - SUM(NVL(upd1.accounted_amt_dr, 0))), NULL) accounted_amt_cr,
  DECODE(SIGN(SUM(NVL(upd1.accounted_amt_cr, 0)) - SUM(NVL(upd1.accounted_amt_dr, 0))), -1, ABS(SUM(NVL(upd1.accounted_amt_cr, 0)) - SUM(NVL(upd1.accounted_amt_dr, 0))), NULL) accounted_amt_dr,
  DECODE(SIGN(SUM(NVL(upd1.entered_amt_cr, 0))   - SUM(NVL(upd1.entered_amt_dr, 0))), 1, ABS(SUM(NVL(upd1.entered_amt_cr, 0)) - SUM(NVL(upd1.entered_amt_dr, 0))), NULL) entered_amt_cr,
  DECODE(SIGN(SUM(NVL(upd1.entered_amt_cr, 0))   - SUM(NVL(upd1.entered_amt_dr, 0))), -1, ABS(SUM(NVL(upd1.entered_amt_cr, 0)) - SUM(NVL(upd1.entered_amt_dr, 0))), NULL) entered_amt_dr,
  upd1.bal_seg_column_name,
  DECODE(SIGN(SUM(NVL(upd1.accounted_amt_cr, 0))-SUM(NVL(upd1.accounted_amt_dr,0))), 1, 'C', -1, 'D', 0,
  DECODE(SIGN(((SUM(NVL(upd1.entered_amt_cr,0)) - SUM(NVL(upd1.entered_amt_dr,0)))) - (SUM(NVL(upd1.accounted_amt_dr,0)) - SUM(NVL(upd1.accounted_amt_cr,0)))), 1, 'C', 'D')) type,
  'Many',
  'Many'
FROM fun_bal_inter_int2_gt upd1
WHERE upd1.driving_dr_le_bsv='Many'
AND   upd1.driving_cr_le_bsv='Many'
AND upd1.intercompany_mode IN (1,2,3,4)
GROUP BY upd1.group_id,
  upd1.ledger_id,
  upd1.gl_date,
  upd1.status,
  upd1.driving_dr_le_id,
  upd1.driving_cr_le_id,
  upd1.intercompany_mode,
  upd1.le_id,
  upd1.entered_currency_code,
  upd1.exchange_date,
  upd1.exchange_rate,
  upd1.exchange_rate_type,
  upd1.bal_seg_column_name
HAVING SUM(NVL(upd1.accounted_amt_cr, 0))                                  <> SUM(NVL(upd1.accounted_amt_dr,0))
OR (SUM(NVL(upd1.accounted_amt_cr, 0))                                      = SUM(NVL(upd1.accounted_amt_dr,0))
AND SUM(DECODE(upd1.exchange_rate, NULL, NVL(upd1.entered_amt_cr, 0), 0)) <> SUM(DECODE(upd1.exchange_rate, NULL, NVL(upd1.entered_amt_dr, 0), 0)));

--inserting lines into fun_bal_inter_int_gt for the 1:M and M:1 case by redistributing amounts #9392684
INSERT into fun_bal_inter_int_gt (GROUP_ID,
                                 LEDGER_ID,
                                 GL_DATE,
                                 STATUS,
                                 DRIVING_DR_LE_ID,
                                 DRIVING_CR_LE_ID,
                                 INTERCOMPANY_MODE,
                                 LE_ID,
                                 ENTERED_CURRENCY_CODE,
                                 ACCOUNTED_AMT_CR,
                                 ACCOUNTED_AMT_DR,
                                 ENTERED_AMT_CR,
                                 ENTERED_AMT_DR,
                                 REC_ACCT,
                                 PAY_ACCT,
                                 BAL_SEG_COLUMN_NAME,
                                 REC_BSV,
                                 PAY_BSV,
                                 EXCHANGE_DATE,
                                 EXCHANGE_RATE,
                                 EXCHANGE_RATE_TYPE,
                                 TYPE,
                                 DRIVING_DR_LE_BSV,
                                 DRIVING_CR_LE_BSV,
                                 LINE_LE_BSV)

                                  Select      upd1.GROUP_ID,
                                 upd1.LEDGER_ID,
                                 upd1.GL_DATE,
                                 upd1.STATUS,
                                 upd1.DRIVING_DR_LE_ID,
                                 upd1.DRIVING_CR_LE_ID,
                                 upd1.INTERCOMPANY_MODE,
                                 upd2.LE_ID,
                                 upd1.ENTERED_CURRENCY_CODE,
                                 upd1.ACCOUNTED_AMT_DR,
                                 upd1.ACCOUNTED_AMT_CR,
                                 upd1.ENTERED_AMT_DR,
                                 upd1.ENTERED_AMT_CR,
                                 upd1.REC_ACCT,
                                 upd1.PAY_ACCT,
                                 upd1.BAL_SEG_COLUMN_NAME,
                                 upd1.REC_BSV,
                                 upd1.PAY_BSV,
                                 upd1.EXCHANGE_DATE,
                                 upd1.EXCHANGE_RATE,
                                 upd1.EXCHANGE_RATE_TYPE,
                                 DECODE(upd1.TYPE,'C','D','C'),
                                 upd1.DRIVING_DR_LE_BSV,
                                 upd1.DRIVING_CR_LE_BSV,
                                 upd2.LINE_LE_BSV
                                 from fun_bal_inter_int2_gt upd1,
                                      fun_bal_inter_int2_gt upd2
                                 where upd2.group_id=upd1.group_id
                                 AND upd1.intercompany_mode in (1,2,3)
                                 AND upd2.intercompany_mode in (1,2,3)
                                 AND ((upd2.driving_dr_le_bsv='Many' and upd2.driving_cr_le_bsv<>'Many' and upd1.driving_dr_le_bsv<>upd2.driving_dr_le_bsv)
                                       or (upd2.driving_cr_le_bsv='Many' and upd2.driving_dr_le_bsv<>'Many'  and upd1.driving_cr_le_bsv<>upd2.driving_cr_le_bsv)
                                 );


      -- Update receivables account for specific LE and BSV values
      --  For  1:1 -
	  --        if driving le is Cr  And type = Cr
      --             driving cr le id = from le; driving dr le id = to le;
 	  --        if driving le is Dr  And type = Cr,
 	  --             driving Dr le id = from le; driving cr le id = to le;
 	  --        Else leave receivables account as null (basically when type = Dr ?)
      --  For 1: Many -
   	  --        if type = Cr,
  	  --	         line le id = from le; Driving dr le id = to le
   	  --        if type = Dr,
  	  --	         driving Dr le id  = from le;  line le id = to le
      --  For Many : 1 -
   	  --        if type = Cr,
  	  --	         line le id = from le;  driving Cr le id  = to le
   	  --        if type = Dr,
  	  --	         driving Cr le id  = from le;  line le id = to le
      --  For Many : Many -
      --        Dont get receives account.

      -- Rules of precedence is to find matching records using
      -- 1)  From LE, From BSV => To LE, To BSV
      -- 2)  From LE, From BSV => To LE
      -- 3)  From LE           => To LE, To BSV
      -- 4)  From LE           => To LE
      -- 4)  From LE           => To All Others

      -- For 1:1, search from rule 1 and progress through to rule 5 if not found
      UPDATE fun_bal_inter_int_gt inter_int
      SET rec_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                          DECODE(inter_int.type, 'C', driving_dr_le_id, NULL),
                          DECODE(inter_int.type, 'C', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'C', driving_cr_le_id, le_id),
                   NULL) = accts.to_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                             DECODE(inter_int.type, 'C', driving_cr_le_bsv ,NULL),
                             DECODE(inter_int.type, 'C', driving_dr_le_bsv,NULL)),
                   2, DECODE(inter_int.type, 'C', line_le_bsv, driving_dr_le_bsv),
                   3, DECODE(inter_int.type, 'C', line_le_bsv,driving_cr_le_bsv),
                   NULL) = accts.trans_bsv --  From BSV

     AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id,  driving_cr_le_id,
                             DECODE(inter_int.type, 'C', driving_dr_le_bsv,NULL),
                             DECODE(inter_int.type, 'C', driving_cr_le_bsv,NULL)),
                   2, DECODE(inter_int.type, 'C', driving_dr_le_bsv,line_le_bsv),
                   3, DECODE(inter_int.type, 'C', driving_cr_le_bsv,line_le_bsv),
                   NULL) = accts.tp_bsv  -- To BSV
      AND accts.type = 'R'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND driving_dr_le_bsv <> 'Many'
      AND driving_cr_le_bsv <> 'Many';

      -- For 1:M, search for rule 2
      UPDATE fun_bal_inter_int_gt inter_int
      SET rec_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                          DECODE(inter_int.type, 'C', driving_dr_le_id, NULL),
                          DECODE(inter_int.type, 'C', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'C', driving_cr_le_id, le_id),
                   NULL) = accts.to_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                             DECODE(inter_int.type, 'C', driving_cr_le_bsv,NULL),
                             DECODE(inter_int.type, 'C', driving_dr_le_bsv,NULL)),
                   2, DECODE(inter_int.type, 'C', line_le_bsv,driving_dr_le_bsv),
                   3, DECODE(inter_int.type, 'C', line_le_bsv,driving_cr_le_bsv),
                   NULL) = accts.trans_bsv --  From BSV

      AND 'OTHER1234567890123456789012345' = accts.tp_bsv  -- To BSV
      AND accts.type = 'R'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND   inter_int.rec_acct IS NULL;

      -- For M:1, search from rule 3 and progress through to rule 5 if not found
      UPDATE fun_bal_inter_int_gt inter_int
      SET rec_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                          DECODE(inter_int.type, 'C', driving_dr_le_id, NULL),
                          DECODE(inter_int.type, 'C', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'C', driving_cr_le_id, le_id),
                   NULL) = accts.to_le_id
     AND 'OTHER1234567890123456789012345' = accts.trans_bsv --  From BSV
     AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id,  driving_cr_le_id,
                             DECODE(inter_int.type, 'C', driving_dr_le_bsv,NULL),
                             DECODE(inter_int.type, 'C', driving_cr_le_bsv,NULL)),
                   2, DECODE(inter_int.type, 'C', driving_dr_le_bsv,line_le_bsv),
                   3, DECODE(inter_int.type, 'C', driving_cr_le_bsv,line_le_bsv),
                   NULL) = accts.tp_bsv  -- To BSV

      AND accts.type = 'R'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND   inter_int.rec_acct IS NULL;

      -- The above will take care of rules 1 to 3.
      -- The account has not been found, the following will deal with rule 4
      -- ie it looks at specific LE without checking for the BSV
      UPDATE fun_bal_inter_int_gt inter_int
      SET rec_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                          DECODE(inter_int.type, 'C', driving_dr_le_id, NULL),
                          DECODE(inter_int.type, 'C', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'C', driving_cr_le_id, le_id),
                   NULL) = accts.to_le_id
      AND 'OTHER1234567890123456789012345' = accts.trans_bsv --  From BSV
      AND 'OTHER1234567890123456789012345' = accts.tp_bsv --  To BSV
      AND accts.type = 'R'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND   inter_int.rec_acct IS NULL;
      -- End, Balancing API Changes, Feb 2005

      -- Update receivables account for other LE if no account specified for specific LE
      -- This will handle rule 5
      --Bug: 9183927
	Update Fun_bal_inter_int_gt Inter_int
	Set Rec_acct = (Select Ccid
        From  fun_inter_accounts Accts
        Where Inter_int.Ledger_id = Accts.Ledger_id
        And  Inter_int.Rec_acct Is Null
        And Decode(Inter_int.Intercompany_mode, 1,
            Decode(Le_id, Driving_cr_le_id,
            Decode(Inter_int.Type, 'C', Driving_cr_le_id, Null),
            Decode(Inter_int.Type, 'C', Driving_dr_le_id, Null)), 2,
            Decode (Inter_int.Type, 'C', Le_id, Driving_dr_le_id), 3,
            Decode(Inter_int.Type, 'C', Le_id, Driving_cr_le_id), 4,
            Decode(Inter_int.Type, 'C', Le_id, Null), Null) =Accts.From_le_id
        And Accts.To_le_id = -99
        AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_cr_le_id,
                             DECODE(inter_int.type, 'C', driving_cr_le_bsv,NULL),
                             DECODE(inter_int.type, 'C', driving_dr_le_bsv,NULL)),
                   2, DECODE(inter_int.type, 'C', line_le_bsv,driving_dr_le_bsv),
                   3, DECODE(inter_int.type, 'C', line_le_bsv,driving_cr_le_bsv),
                   NULL) = accts.trans_bsv --  From BSV
        AND 'OTHER1234567890123456789012345' = accts.tp_bsv
        And Accts.Type = 'R'
        And  Accts.Default_flag = 'Y'
        And (Trunc(Inter_int.Gl_date) Between Trunc(Nvl(Accts.Start_date, Inter_int.Gl_date))
        And  Trunc(Nvl(Accts.End_date, Inter_int.Gl_date))))
        Where Inter_int.Rec_acct Is Null ;


	Update Fun_bal_inter_int_gt Inter_int
	Set Rec_acct = (Select Ccid
        From  fun_inter_accounts Accts
        Where Inter_int.Ledger_id = Accts.Ledger_id
        And  Inter_int.Rec_acct Is Null
        And Decode(Inter_int.Intercompany_mode, 1,
            Decode(Le_id, Driving_cr_le_id,
            Decode(Inter_int.Type, 'C', Driving_cr_le_id, Null),
            Decode(Inter_int.Type, 'C', Driving_dr_le_id, Null)), 2,
            Decode (Inter_int.Type, 'C', Le_id, Driving_dr_le_id), 3,
            Decode(Inter_int.Type, 'C', Le_id, Driving_cr_le_id), 4,
            Decode(Inter_int.Type, 'C', Le_id, Null), Null) =Accts.From_le_id
        And Accts.To_le_id = -99
        AND 'OTHER1234567890123456789012345' = accts.trans_bsv --  From BSV
        AND 'OTHER1234567890123456789012345' = accts.tp_bsv
        And Accts.Type = 'R'
        And  Accts.Default_flag = 'Y'
        And (Trunc(Inter_int.Gl_date) Between Trunc(Nvl(Accts.Start_date, Inter_int.Gl_date))
        And  Trunc(Nvl(Accts.End_date, Inter_int.Gl_date))))
        Where Inter_int.Rec_acct Is Null ;

--ER: 8588074
--Bug: 9183927
UPDATE fun_bal_inter_int_gt inter_int
SET rec_acct = (SELECT dr_ccid
             FROM fun_balance_accounts accts
             WHERE
            'OTHER1234567890123456789012345' = accts.cr_bsv
         AND 'OTHER1234567890123456789012345' = accts.dr_bsv
	 AND accts.template_id = (SELECT  NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = inter_int.ledger_id
             AND   opts.le_id   = DECODE(inter_int.intercompany_mode,
                   1, DECODE(inter_int.le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', inter_int.le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', inter_int.le_id, driving_cr_le_id),
		   4, DECODE(inter_int.type, 'C', inter_int.le_id, NULL),
                   NULL)
             AND   opts.je_source_name   = (select distinct je_source_name from fun_bal_le_bsv_map_gt le_bsv_map
					   where le_bsv_map.group_id = inter_int.group_id)
             AND   opts.je_category_name = (select distinct je_category_name from fun_bal_le_bsv_map_gt le_bsv_map
					   where le_bsv_map.group_id = inter_int.group_id)
             AND   opts.status_flag      = 'Y'),
      NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = inter_int.ledger_id
             AND   opts.le_id   = DECODE(inter_int.intercompany_mode,
                   1, DECODE(inter_int.le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', inter_int.le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', inter_int.le_id, driving_cr_le_id),
		   4, DECODE(inter_int.type, 'C', inter_int.le_id, NULL),
                   NULL)
             AND   opts.je_source_name   = (select distinct je_source_name from fun_bal_le_bsv_map_gt le_bsv_map
					   where le_bsv_map.group_id = inter_int.group_id)
             AND   opts.je_category_name = 'Other'
             AND   opts.status_flag      = 'Y'),
      NVL((SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = inter_int.ledger_id
             AND   opts.le_id   = DECODE(inter_int.intercompany_mode,
                   1, DECODE(inter_int.le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', inter_int.le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', inter_int.le_id, driving_cr_le_id),
		   4, DECODE(inter_int.type, 'C', inter_int.le_id, NULL),
                   NULL)
             AND   opts.je_source_name   = 'Other'
             AND   opts.je_category_name = (select distinct je_category_name from fun_bal_le_bsv_map_gt le_bsv_map
					   where le_bsv_map.group_id = inter_int.group_id)
             AND   opts.status_flag      = 'Y'),
      (SELECT opts.template_id
             FROM  fun_balance_options opts
             WHERE opts.ledger_id        = inter_int.ledger_id
             AND   opts.le_id   = DECODE(inter_int.intercompany_mode,
                   1, DECODE(inter_int.le_id, driving_cr_le_id,
                           DECODE(inter_int.type, 'C', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'C', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'C', inter_int.le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'C', inter_int.le_id, driving_cr_le_id),
		   4, DECODE(inter_int.type, 'C', inter_int.le_id, NULL),
                   NULL)
             AND   opts.je_source_name   = 'Other'
             AND   opts.je_category_name = 'Other'
             AND   opts.status_flag      = 'Y')))) template_id
  From Dual))
  WHERE inter_int.rec_acct IS NULL;

  ---- end ER: 8588074

      -- Update payables account for specific LE
      -- 1:1 mapping to begin with
      UPDATE fun_bal_inter_int_gt inter_int
      SET pay_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'D', driving_cr_le_id,le_id),
                   NULL) = accts.to_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id,driving_dr_le_id,
                              DECODE(inter_int.type, 'D', driving_dr_le_bsv,NULL),
                              DECODE(inter_int.type, 'D', driving_cr_le_bsv, NULL)),
                   2, DECODE(inter_int.type, 'D', line_le_bsv,driving_dr_le_bsv),
                   3, DECODE(inter_int.type, 'D', line_le_bsv,driving_cr_le_bsv),
                   NULL) = accts.trans_bsv
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id,driving_dr_le_id,
                               DECODE(inter_int.type, 'D', driving_cr_le_bsv,NULL),
                               DECODE(inter_int.type, 'D', driving_dr_le_bsv, NULL)),
                   2, DECODE(inter_int.type, 'D', driving_dr_le_bsv,line_le_bsv),
                   3, DECODE(inter_int.type, 'D', driving_cr_le_bsv,line_le_bsv),
                   NULL) = accts.tp_bsv -- To BSV
      AND accts.type = 'P'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND    driving_cr_le_bsv <> 'Many'
      AND    driving_dr_le_bsv <> 'Many';

      -- 1:M - next
      UPDATE fun_bal_inter_int_gt inter_int
      SET pay_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'D', driving_cr_le_id,le_id),
                   NULL) = accts.to_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id,driving_dr_le_id,
                              DECODE(inter_int.type, 'D', driving_dr_le_bsv,NULL),
                              DECODE(inter_int.type, 'D', driving_cr_le_bsv, NULL)),
                   2, DECODE(inter_int.type, 'D', line_le_bsv,driving_dr_le_bsv),
                   3, DECODE(inter_int.type, 'D', line_le_bsv,driving_cr_le_bsv),
                   NULL) = accts.trans_bsv
      AND  'OTHER1234567890123456789012345' = accts.tp_bsv -- To BSV
      AND accts.type = 'P'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND   inter_int.pay_acct IS NULL;

      -- M:1 - next
      UPDATE fun_bal_inter_int_gt inter_int
      SET pay_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'D', driving_cr_le_id,le_id),
                   NULL) = accts.to_le_id
      AND 'OTHER1234567890123456789012345' = accts.trans_bsv
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id,driving_dr_le_id,
                               DECODE(inter_int.type, 'D', driving_cr_le_bsv,NULL),
                               DECODE(inter_int.type, 'D', driving_dr_le_bsv, NULL)),
                   2, DECODE(inter_int.type, 'D', driving_dr_le_bsv,line_le_bsv),
                   3, DECODE(inter_int.type, 'D', driving_cr_le_bsv,line_le_bsv),
                   NULL) = accts.tp_bsv -- To BSV
      AND accts.type = 'P'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date))
                                    AND TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND   inter_int.pay_acct IS NULL ;

      -- If the payables account was not found, look for an account as per rule 4
      -- ie from le to te
      UPDATE fun_bal_inter_int_gt inter_int
      SET pay_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                   NULL) = accts.from_le_id
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', driving_dr_le_id, le_id),
                   3, DECODE(inter_int.type, 'D', driving_cr_le_id,le_id),
                   NULL) = accts.to_le_id
      AND 'OTHER1234567890123456789012345' = accts.trans_bsv --  From BSV
      AND 'OTHER1234567890123456789012345' = accts.tp_bsv --  To BSV
      AND accts.type = 'P'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date)) AND
                                                            TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.intercompany_mode IN (1,2,3)
      AND   inter_int.pay_acct IS NULL;
      -- End, Balancing API changes

      -- Update payables account for other LE if no account specified for specific LE
      -- This will deal with rule 5, From LE to All Others
      --Bug: 9183927
      UPDATE fun_bal_inter_int_gt inter_int
      SET pay_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND inter_int.pay_acct IS NULL
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                   4, DECODE(inter_int.type, 'D', le_id, NULL),
                   NULL) = accts.from_le_id
      AND accts.to_le_id = -99 -- To LE "All Other"
      AND DECODE(inter_int.intercompany_mode,
      1, DECODE(le_id,driving_dr_le_id,
      DECODE(inter_int.type, 'D', driving_dr_le_bsv,NULL),
      DECODE(inter_int.type, 'D', driving_cr_le_bsv, NULL)),
      2, DECODE(inter_int.type, 'D', line_le_bsv,driving_dr_le_bsv),
      3, DECODE(inter_int.type, 'D', line_le_bsv,driving_cr_le_bsv),
      NULL) = accts.trans_bsv
      AND  'OTHER1234567890123456789012345' = accts.tp_bsv -- To BSV
      AND accts.type = 'P'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date)) AND
                                                            TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.pay_acct IS NULL;

      UPDATE fun_bal_inter_int_gt inter_int
      SET pay_acct =
      (SELECT ccid
      FROM fun_inter_accounts accts
      WHERE inter_int.ledger_id = accts.ledger_id
      AND inter_int.pay_acct IS NULL
      AND DECODE(inter_int.intercompany_mode,
                   1, DECODE(le_id, driving_dr_le_id,
                           DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
                           DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                   2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                   3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                   4, DECODE(inter_int.type, 'D', le_id, NULL),
                   NULL) = accts.from_le_id
      AND accts.to_le_id = -99 -- To LE "All Other"
      AND 'OTHER1234567890123456789012345' = accts.trans_bsv --  From BSV
      AND 'OTHER1234567890123456789012345' = accts.tp_bsv --  To BSV
      AND accts.type = 'P'
      AND accts.default_flag = 'Y'
      AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(accts.start_date, inter_int.gl_date)) AND
                                                            TRUNC(NVL(accts.end_date, inter_int.gl_date))))
      WHERE inter_int.pay_acct IS NULL;
-- ER: 8588074
--Bug: 9183927
	UPDATE fun_bal_inter_int_gt inter_int
	SET pay_acct = (SELECT cr_ccid
		     FROM fun_balance_accounts accts
		     WHERE
		    'OTHER1234567890123456789012345' = accts.cr_bsv
		 AND 'OTHER1234567890123456789012345' = accts.dr_bsv
		 AND accts.template_id = (SELECT  NVL((SELECT opts.template_id
		     FROM  fun_balance_options opts
		     WHERE opts.ledger_id        = inter_int.ledger_id
		     AND   opts.le_id   = DECODE(inter_int.intercompany_mode,
			   1, DECODE(inter_int.le_id, driving_dr_le_id,
				   DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
				   DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
			   2, DECODE(inter_int.type, 'D', inter_int.le_id, driving_dr_le_id),
			   3, DECODE(inter_int.type, 'D', inter_int.le_id, driving_cr_le_id),
			   4, DECODE(inter_int.type, 'D', inter_int.le_id, NULL),
			   NULL)
		     AND   opts.je_source_name   = (select distinct je_source_name from fun_bal_le_bsv_map_gt le_bsv_map
						   where le_bsv_map.group_id = inter_int.group_id)
		     AND   opts.je_category_name = (select distinct je_category_name from fun_bal_le_bsv_map_gt le_bsv_map
						   where le_bsv_map.group_id = inter_int.group_id)
		     AND   opts.status_flag      = 'Y'),
	      NVL((SELECT opts.template_id
		     FROM  fun_balance_options opts
		     WHERE opts.ledger_id        = inter_int.ledger_id
		     AND   opts.le_id   = DECODE(inter_int.intercompany_mode,
			   1, DECODE(inter_int.le_id, driving_dr_le_id,
				   DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
				   DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
			   2, DECODE(inter_int.type, 'D', inter_int.le_id, driving_dr_le_id),
			   3, DECODE(inter_int.type, 'D', inter_int.le_id, driving_cr_le_id),
			   4, DECODE(inter_int.type, 'D', inter_int.le_id, NULL),
			   NULL)
		     AND   opts.je_source_name   = (select distinct je_source_name from fun_bal_le_bsv_map_gt le_bsv_map
						   where le_bsv_map.group_id = inter_int.group_id)
		     AND   opts.je_category_name = 'Other'
		     AND   opts.status_flag      = 'Y'),
	      NVL((SELECT opts.template_id
		     FROM  fun_balance_options opts
		     WHERE opts.ledger_id        = inter_int.ledger_id
		     AND   opts.le_id   =  DECODE(inter_int.intercompany_mode,
			   1, DECODE(inter_int.le_id, driving_dr_le_id,
				   DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
				   DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
			   2, DECODE(inter_int.type, 'D', inter_int.le_id, driving_dr_le_id),
			   3, DECODE(inter_int.type, 'D', inter_int.le_id, driving_cr_le_id),
			   4, DECODE(inter_int.type, 'D', inter_int.le_id, NULL),
			   NULL)
		     AND   opts.je_source_name   = 'Other'
		     AND   opts.je_category_name = (select distinct je_category_name from fun_bal_le_bsv_map_gt le_bsv_map
						   where le_bsv_map.group_id = inter_int.group_id)
		     AND   opts.status_flag      = 'Y'),
	      (SELECT opts.template_id
		     FROM  fun_balance_options opts
		     WHERE opts.ledger_id        = inter_int.ledger_id
		     AND   opts.le_id  = DECODE(inter_int.intercompany_mode,
			   1, DECODE(inter_int.le_id, driving_dr_le_id,
				   DECODE(inter_int.type, 'D', driving_dr_le_id, NULL),
				   DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
			   2, DECODE(inter_int.type, 'D', inter_int.le_id, driving_dr_le_id),
			   3, DECODE(inter_int.type, 'D', inter_int.le_id, driving_cr_le_id),
			   4, DECODE(inter_int.type, 'D', inter_int.le_id, NULL),
			   NULL)
		     AND   opts.je_source_name   = 'Other'
		     AND   opts.je_category_name = 'Other'
		     AND   opts.status_flag      = 'Y')))) template_id
	  From Dual))
	  WHERE inter_int.pay_acct IS NULL;
  --- END ER: 8588074
     --FND_STATS.GATHER_TABLE_STATS(g_fun_schema, 'FUN_BAL_INTER_INT_GT');

     UPDATE fun_bal_inter_int_gt inter_int
     SET rec_acct = -1
     WHERE rec_acct IS NULL AND
                 EXISTS (SELECT 'Receivables Accounts exist but not defaulted'
                               FROM fun_inter_accounts accts
                               WHERE inter_int.ledger_id = accts.ledger_id
                                   AND accts.type = 'R'
                                   AND DECODE(inter_int.intercompany_mode,
                                                  1, DECODE(le_id,
                                                     driving_cr_le_id, DECODE(inter_int.type, 'C', driving_cr_le_id,
                                                                                NULL),
                                                     DECODE(inter_int.type, 'C', driving_dr_le_id,
                                                   NULL)),
                                                 2, DECODE(inter_int.type, 'C', le_id, driving_dr_le_id),
                                                 3, DECODE(inter_int.type, 'C', le_id, driving_cr_le_id),
                                                 4, DECODE(inter_int.type, 'C', le_id, NULL),
                                               NULL) = accts.from_le_id
                                   AND (DECODE(inter_int.intercompany_mode,
                                                  1, DECODE(le_id,
                                                      driving_cr_le_id, DECODE(inter_int.type, 'C', driving_dr_le_id,
                                                                                 NULL),
                                                      DECODE(inter_int.type, 'C', driving_cr_le_id,
                                                      NULL)),
                                                  2, DECODE(inter_int.type, 'C', driving_dr_le_id, le_id),
                                                  3, DECODE(inter_int.type, 'C', driving_cr_le_id, le_id),
                                               NULL) = accts.to_le_id
                                              OR
                                            accts.to_le_id = -99));

     UPDATE fun_bal_inter_int_gt inter_int
     SET pay_acct = -1
     WHERE pay_acct IS NULL AND
                 EXISTS (SELECT 'Payables Accounts exist but not defaulted'
                               FROM fun_inter_accounts accts
                               WHERE inter_int.ledger_id = accts.ledger_id
                                   AND accts.type = 'P'
                                  AND DECODE(inter_int.intercompany_mode,
                                              1, DECODE(le_id,
                                              driving_dr_le_id, DECODE(inter_int.type, 'D', driving_dr_le_id,
                                                                                                    NULL),
                                               DECODE(inter_int.type, 'D', driving_cr_le_id, NULL)),
                                              2, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                                              3, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                                              4, DECODE(inter_int.type, 'C', le_id, NULL),
                                              NULL) = accts.from_le_id
                                   AND (DECODE(inter_int.intercompany_mode,
                                              1, DECODE(le_id,
                                              driving_dr_le_id, DECODE(inter_int.type, 'D', driving_cr_le_id,
                                                                                                    NULL),
                                              DECODE(inter_int.type, 'D', driving_dr_le_id, NULL)),
                                              2, DECODE(inter_int.type, 'D', le_id, driving_cr_le_id),
                                              3, DECODE(inter_int.type, 'D', le_id, driving_dr_le_id),
                                              NULL) = accts.to_le_id
                                            OR
                                            accts.to_le_id = -99));

     IF g_debug = FND_API.G_TRUE THEN
         OPEN l_inter_int_cursor;
         FETCH l_inter_int_cursor BULK COLLECT INTO l_inter_int_tab;
         l_inter_int_count := l_inter_int_cursor%ROWCOUNT;
         CLOSE l_inter_int_cursor;
        ins_t_tables_inter_2_auto(l_inter_int_tab, l_inter_int_count);
     END IF;


   -- Insert errors into FUN_BAL_ERRORS_GT
     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, from_le_id, to_le_id, ccid,
                                                           acct_type, ccid_concat_display,
                                   dr_bsv, cr_bsv)
     SELECT DISTINCT DECODE(inter_int.rec_acct, NULL, 'FUN_INTER_REC_NOT_ASSIGNED',
                                                                            -1, 'FUN_INTER_REC_NO_DEFAULT',
                                                                            'FUN_INTER_REC_NOT_VALID'),
      inter_int.group_id,
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_cr_le_id,
                                                               2, inter_int.le_id,
                                                               3, inter_int.driving_cr_le_id,
                                                               4, inter_int.le_id),
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_dr_le_id,
                                                               2, inter_int.driving_dr_le_id,
                                                               3, inter_int.le_id,
                                                               4, NULL),
     DECODE(inter_int.rec_acct, -1, NULL, inter_int.rec_acct), 'R',
     get_ccid_concat_disp(DECODE(inter_int.rec_acct, -1, NULL, inter_int.rec_acct), hdrs.chart_of_accounts_id,
                  NULL, NULL, NULL, NULL),
     inter_int.driving_dr_le_bsv, inter_int.driving_cr_le_bsv
     FROM fun_bal_inter_int_gt inter_int, fun_bal_headers_gt hdrs
     WHERE inter_int.group_id = hdrs.group_id AND
     ((inter_int.intercompany_mode = 1 AND
       inter_int.type = 'C')
      OR
      (inter_int.intercompany_mode = 2 AND
      inter_int.le_id <> inter_int.driving_dr_le_id)
      OR
      (inter_int.intercompany_mode = 3 AND
      inter_int.le_id <> inter_int.driving_cr_le_id)
      OR
       (inter_int.intercompany_mode = 4 AND
       inter_int.type = 'C'))
      AND (inter_int.rec_acct IS NULL
          OR
               inter_int.rec_acct = -1
          OR
              (inter_int.rec_acct IS NOT NULL AND
               NOT EXISTS   (SELECT 'Receivables account not valid'
                                    FROM gl_code_combinations cc
                                    WHERE inter_int.rec_acct = cc.code_combination_id
                                    AND cc.detail_posting_allowed_flag = 'Y'
                                    AND cc.enabled_flag = 'Y'
                                    AND cc.summary_flag = 'N'
									AND nvl(cc.reference3, 'N') = 'N'
                                    AND cc.template_id IS NULL
                                    AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(cc.start_date_active, inter_int.gl_date))
                                                   AND TRUNC(NVL(cc.end_date_active, inter_int.gl_date))))));

   -- Insert errors into FUN_BAL_ERRORS_GT
     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, from_le_id, to_le_id, ccid,
                                                           acct_type, ccid_concat_display,
                                   dr_bsv, cr_bsv)
     SELECT DISTINCT DECODE(inter_int.pay_acct, NULL, 'FUN_INTER_PAY_NOT_ASSIGNED',
                                                                             -1, 'FUN_INTER_PAY_NO_DEFAULT',
                                                                              'FUN_INTER_PAY_NOT_VALID'),
      inter_int.group_id,
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_dr_le_id,
                                                               2, inter_int.driving_dr_le_id,
                                                               3, inter_int.le_id,
                                                               4, inter_int.le_id),
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_cr_le_id,
                                                               2, inter_int.le_id,
                                                               3, inter_int.driving_cr_le_id,
                                                               4, NULL),
     DECODE(inter_int.pay_acct, -1, NULL, inter_int.pay_acct), 'P',
     get_ccid_concat_disp(DECODE(inter_int.pay_acct, -1, NULL, inter_int.pay_acct), hdrs.chart_of_accounts_id,
                  NULL, NULL, NULL, NULL),
     inter_int.driving_dr_le_bsv, inter_int.driving_cr_le_bsv
     FROM fun_bal_inter_int_gt inter_int, fun_bal_headers_gt hdrs
     WHERE inter_int.group_id = hdrs.group_id AND
     ((inter_int.intercompany_mode = 1 AND
       inter_int.type = 'D')
      OR
      (inter_int.intercompany_mode = 2 AND
      inter_int.le_id <> inter_int.driving_dr_le_id)
      OR
      (inter_int.intercompany_mode = 3 AND
      inter_int.le_id <> inter_int.driving_cr_le_id)
      OR
       (inter_int.intercompany_mode = 4 AND
       inter_int.type = 'D'))
        AND (inter_int.pay_acct IS NULL
             OR
               inter_int.pay_acct = -1
             OR
              (inter_int.pay_acct IS NOT NULL AND
               NOT EXISTS   (SELECT 'Payables account not valid'
                                    FROM gl_code_combinations cc
                                    WHERE inter_int.pay_acct = cc.code_combination_id
                                    AND cc.detail_posting_allowed_flag = 'Y'
                                    AND cc.enabled_flag = 'Y'
                                    AND cc.summary_flag = 'N'
									AND nvl(cc.reference3, 'N') = 'N'
                                    AND cc.template_id IS NULL
                                    AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(cc.start_date_active, inter_int.gl_date))
                                                   AND TRUNC(NVL(cc.end_date_active, inter_int.gl_date))))));


     UPDATE fun_bal_headers_gt headers
     SET status = 'ERROR'
     WHERE EXISTS (SELECT 'Errors for Rec and Pay Accts'
                               FROM FUN_BAL_ERRORS_GT errors
                               WHERE headers.group_id =  errors.group_id
                                    AND error_code IN ('FUN_INTER_PAY_NOT_ASSIGNED',
                                                                  'FUN_INTER_REC_NOT_ASSIGNED',
                                                                  'FUN_INTER_PAY_NO_DEFAULT',
                                                                  'FUN_INTER_REC_NO_DEFAULT',
                                                                  'FUN_INTER_PAY_NOT_VALID',
                                                                  'FUN_INTER_REC_NOT_VALID'))
     AND headers.status = 'OK';

     DELETE FROM fun_bal_inter_int_gt inter_int
     WHERE EXISTS (SELECT group_id
                               FROM fun_bal_headers_gt headers
                               WHERE headers.status = 'ERROR'
                               AND inter_int.group_id = headers.group_id);

	--Enhancement 7520196 Start
	-- Update the Payable and receivable BSV with the minimum unbalanced bsv
	-- for each of the transacting Legal Entity.
	--bug: 9008776
	Update fun_bal_inter_int_gt bal_inter_int
	set Rec_BSV = (select min_bal_seg_val from (
							select min(lines.bal_seg_val) min_bal_seg_val, le_bsv_map.le_id le_id, hdrs.group_id group_id
							FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines,
								  fun_bal_headers_gt hdrs
					  WHERE hdrs.group_id = lines.group_id
						AND lines.group_id = le_bsv_map.group_id
						AND lines.bal_seg_val = le_bsv_map.bal_seg_val
						AND hdrs.intercompany_mode IN (1,2,3)
						AND hdrs.status = 'OK'
						GROUP BY hdrs.group_id, hdrs.ledger_id, hdrs.gl_date, hdrs.status, hdrs.driving_dr_le_id, hdrs.driving_cr_le_id,
						   hdrs.intercompany_mode, le_bsv_map.le_id,
					   hdrs.bal_seg_column_name, hdrs.intercompany_column_number
					  HAVING SUM(NVL(lines.accounted_amt_cr, 0)) <> SUM(NVL(lines.accounted_amt_dr,0))
					  OR (SUM(NVL(lines.accounted_amt_cr, 0)) = SUM(NVL(lines.accounted_amt_dr,0))
						  AND SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0)) <>
							  SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0))) ) min_bsv
					   where min_bsv.le_id = Decode (bal_inter_int.Intercompany_mode, 1, bal_inter_int.DRIVING_CR_LE_ID,
																	 2, (decode (bal_inter_int.type, 'C', bal_inter_int.LE_ID, bal_inter_int.DRIVING_DR_LE_ID)),
																	 3, (decode (bal_inter_int.type, 'D', bal_inter_int.DRIVING_CR_LE_ID, bal_inter_int.LE_ID)), NULL)
							and min_bsv.group_id = bal_inter_int.group_id
							and bal_inter_int.status = 'OK')
              where REC_BSV IS NULL;

	Update fun_bal_inter_int_gt bal_inter_int
	set Pay_BSV = (select min_bal_seg_val from (
							select min(lines.bal_seg_val) min_bal_seg_val, le_bsv_map.le_id le_id, hdrs.group_id group_id
							FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines,
								  fun_bal_headers_gt hdrs
					  WHERE hdrs.group_id = lines.group_id
						AND lines.group_id = le_bsv_map.group_id
						AND lines.bal_seg_val = le_bsv_map.bal_seg_val
						AND hdrs.intercompany_mode IN (1,2,3)
						AND hdrs.status = 'OK'
						GROUP BY hdrs.group_id, hdrs.ledger_id, hdrs.gl_date, hdrs.status, hdrs.driving_dr_le_id, hdrs.driving_cr_le_id,
						   hdrs.intercompany_mode, le_bsv_map.le_id,
					   hdrs.bal_seg_column_name, hdrs.intercompany_column_number
					  HAVING SUM(NVL(lines.accounted_amt_cr, 0)) <> SUM(NVL(lines.accounted_amt_dr,0))
					  OR (SUM(NVL(lines.accounted_amt_cr, 0)) = SUM(NVL(lines.accounted_amt_dr,0))
						  AND SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0)) <>
							  SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0))) ) min_bsv
					   where min_bsv.le_id = Decode (bal_inter_int.Intercompany_mode, 1, bal_inter_int.DRIVING_DR_LE_ID,
																	 2, (decode (bal_inter_int.type, 'C', bal_inter_int.DRIVING_DR_LE_ID, bal_inter_int.LE_ID)),
																	 3, (decode (bal_inter_int.type, 'D', bal_inter_int.LE_ID, bal_inter_int.DRIVING_CR_LE_ID)), NULL)
							and min_bsv.group_id = bal_inter_int.group_id
							and bal_inter_int.status = 'OK')
              where Pay_BSV IS NULL;

	-- Switch the Intercompany and Balancing segment value for the
	-- Payables and Receivables accounts. And update the table with
	-- the new account numbers.
	Update fun_bal_inter_int_gt bal_inter_int
	Set (REC_ACCT, PAY_ACCT) =
		(select get_ccid (bal_inter_int.REC_ACCT,
						  hdrs.CHART_OF_ACCOUNTS_ID,
						  bal_inter_int.REC_BSV,
						  bal_inter_int.PAY_BSV,
						  hdrs.BAL_SEG_COLUMN_NUMBER,
						  hdrs.INTERCOMPANY_COLUMN_NUMBER,
						  bal_inter_int.GL_DATE
						 ),
				get_ccid (bal_inter_int.PAY_ACCT,
						  hdrs.CHART_OF_ACCOUNTS_ID,
						  bal_inter_int.PAY_BSV,
						  bal_inter_int.REC_BSV,
						  hdrs.BAL_SEG_COLUMN_NUMBER,
						  hdrs.INTERCOMPANY_COLUMN_NUMBER,
						  bal_inter_int.GL_DATE
						 )
		from fun_bal_headers_gt hdrs
		where bal_inter_int.group_id = hdrs.group_id)
	where bal_inter_int.intercompany_mode in (1, 2, 3)
	and bal_inter_int.status = 'OK';

	-- Enhancement 7520196 End

	/* Changes for Bug # 8212023 Start */
    -- Insert errors into FUN_BAL_ERRORS_GT
     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, from_le_id, to_le_id, ccid,
                                                           acct_type, ccid_concat_display,
                                   dr_bsv, cr_bsv)
     SELECT DISTINCT DECODE(inter_int.rec_acct, NULL, 'FUN_INTER_REC_NOT_ASSIGNED',
                                                                            -1, 'FUN_INTER_REC_NO_DEFAULT',
                                                                            'FUN_INTER_REC_NOT_VALID'),
      inter_int.group_id,
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_cr_le_id,
                                                               2, inter_int.le_id,
                                                               3, inter_int.driving_cr_le_id,
                                                               4, inter_int.le_id),
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_dr_le_id,
                                                               2, inter_int.driving_dr_le_id,
                                                               3, inter_int.le_id,
                                                               4, NULL),
     DECODE(inter_int.rec_acct, -1, NULL, inter_int.rec_acct), 'R',
     get_ccid_concat_disp(DECODE(inter_int.rec_acct, -1, NULL, inter_int.rec_acct), hdrs.chart_of_accounts_id,
                  NULL, NULL, NULL, NULL),
     inter_int.driving_dr_le_bsv, inter_int.driving_cr_le_bsv
     FROM fun_bal_inter_int_gt inter_int, fun_bal_headers_gt hdrs
     WHERE inter_int.group_id = hdrs.group_id AND
     ((inter_int.intercompany_mode = 1 AND
       inter_int.type = 'C')
      OR
      (inter_int.intercompany_mode = 2 AND
      inter_int.le_id <> inter_int.driving_dr_le_id)
      OR
      (inter_int.intercompany_mode = 3 AND
      inter_int.le_id <> inter_int.driving_cr_le_id)
      OR
       (inter_int.intercompany_mode = 4 AND
       inter_int.type = 'C'))
      AND (inter_int.rec_acct IS NULL
          OR
               inter_int.rec_acct = -1
          OR
              (inter_int.rec_acct IS NOT NULL AND
               NOT EXISTS   (SELECT 'Receivables account not valid'
                                    FROM gl_code_combinations cc
                                    WHERE inter_int.rec_acct = cc.code_combination_id
                                    AND cc.detail_posting_allowed_flag = 'Y'
                                    AND cc.enabled_flag = 'Y'
                                    AND cc.summary_flag = 'N'
									AND nvl(cc.reference3, 'N') = 'N'
                                    AND cc.template_id IS NULL
                                    AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(cc.start_date_active, inter_int.gl_date))
                                                   AND TRUNC(NVL(cc.end_date_active, inter_int.gl_date))))));

   -- Insert errors into FUN_BAL_ERRORS_GT
     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, from_le_id, to_le_id, ccid,
                                                           acct_type, ccid_concat_display,
                                   dr_bsv, cr_bsv)
     SELECT DISTINCT DECODE(inter_int.pay_acct, NULL, 'FUN_INTER_PAY_NOT_ASSIGNED',
                                                                             -1, 'FUN_INTER_PAY_NO_DEFAULT',
                                                                              'FUN_INTER_PAY_NOT_VALID'),
      inter_int.group_id,
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_dr_le_id,
                                                               2, inter_int.driving_dr_le_id,
                                                               3, inter_int.le_id,
                                                               4, inter_int.le_id),
      DECODE(inter_int.intercompany_mode, 1, inter_int.driving_cr_le_id,
                                                               2, inter_int.le_id,
                                                               3, inter_int.driving_cr_le_id,
                                                               4, NULL),
     DECODE(inter_int.pay_acct, -1, NULL, inter_int.pay_acct), 'P',
     get_ccid_concat_disp(DECODE(inter_int.pay_acct, -1, NULL, inter_int.pay_acct), hdrs.chart_of_accounts_id,
                  NULL, NULL, NULL, NULL),
     inter_int.driving_dr_le_bsv, inter_int.driving_cr_le_bsv
     FROM fun_bal_inter_int_gt inter_int, fun_bal_headers_gt hdrs
     WHERE inter_int.group_id = hdrs.group_id AND
     ((inter_int.intercompany_mode = 1 AND
       inter_int.type = 'D')
      OR
      (inter_int.intercompany_mode = 2 AND
      inter_int.le_id <> inter_int.driving_dr_le_id)
      OR
      (inter_int.intercompany_mode = 3 AND
      inter_int.le_id <> inter_int.driving_cr_le_id)
      OR
       (inter_int.intercompany_mode = 4 AND
       inter_int.type = 'D'))
        AND (inter_int.pay_acct IS NULL
             OR
               inter_int.pay_acct = -1
             OR
              (inter_int.pay_acct IS NOT NULL AND
               NOT EXISTS   (SELECT 'Payables account not valid'
                                    FROM gl_code_combinations cc
                                    WHERE inter_int.pay_acct = cc.code_combination_id
                                    AND cc.detail_posting_allowed_flag = 'Y'
                                    AND cc.enabled_flag = 'Y'
                                    AND cc.summary_flag = 'N'
									AND nvl(cc.reference3, 'N') = 'N'
                                    AND cc.template_id IS NULL
                                    AND (TRUNC(inter_int.gl_date) BETWEEN TRUNC(NVL(cc.start_date_active, inter_int.gl_date))
                                                   AND TRUNC(NVL(cc.end_date_active, inter_int.gl_date))))));


     UPDATE fun_bal_headers_gt headers
     SET status = 'ERROR'
     WHERE EXISTS (SELECT 'Errors for Rec and Pay Accts'
                               FROM FUN_BAL_ERRORS_GT errors
                               WHERE headers.group_id =  errors.group_id
                                    AND error_code IN ('FUN_INTER_PAY_NOT_ASSIGNED',
                                                                  'FUN_INTER_REC_NOT_ASSIGNED',
                                                                  'FUN_INTER_PAY_NO_DEFAULT',
                                                                  'FUN_INTER_REC_NO_DEFAULT',
                                                                  'FUN_INTER_PAY_NOT_VALID',
                                                                  'FUN_INTER_REC_NOT_VALID'))
     AND headers.status = 'OK';

     DELETE FROM fun_bal_inter_int_gt inter_int
     WHERE EXISTS (SELECT group_id
                               FROM fun_bal_headers_gt headers
                               WHERE headers.status = 'ERROR'
                               AND inter_int.group_id = headers.group_id);

	/* Changes for Bug # 8212023 End */

    -- Retrieve balancing segment value from the receivables and payables accounts
      update_inter_seg_val;
/* 8200511 */

	INSERT INTO FUN_INTER_ACCOUNTS_ADDL
           (FROM_LE_ID,
            LEDGER_ID,
            TO_LE_ID,
            CCID,
            TYPE,
            START_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TRANS_BSV,
            TP_BSV)
	SELECT DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_CR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_DR_LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.DRIVING_CR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              NULL),
       BAL_INTER_INT.LEDGER_ID,
       DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_DR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.DRIVING_DR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_CR_LE_ID)),
                                              NULL),
       BAL_INTER_INT.REC_ACCT,
       'R',
       SYSDATE,
       '1',
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       fnd_global.login_id,
       BAL_INTER_INT.REC_BSV,
       BAL_INTER_INT.PAY_BSV
	FROM   FUN_BAL_INTER_INT_GT BAL_INTER_INT
	WHERE  BAL_INTER_INT.STATUS = 'OK'
       AND BAL_INTER_INT.REC_ACCT IS NOT NULL
	   AND BAL_INTER_INT.PAY_BSV IS NOT NULL
	   AND BAL_INTER_INT.REC_BSV IS NOT NULL
	AND NOT EXISTS(
	        SELECT 'X'
		FROM FUN_INTER_ACCOUNTS_V ACCTV
		WHERE ACCTV.FROM_LE_ID = DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_CR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_DR_LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.DRIVING_CR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              NULL)
		AND ACCTV.LEDGER_ID = BAL_INTER_INT.LEDGER_ID
		AND ACCTV.TO_LE_ID = DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_DR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.DRIVING_DR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_CR_LE_ID)),
                                              NULL)
		AND ACCTV.CCID = BAL_INTER_INT.REC_ACCT
		AND ACCTV.TYPE = 'R'
		AND ACCTV.TRANS_BSV = BAL_INTER_INT.REC_BSV
		AND ACCTV.TP_BSV = BAL_INTER_INT.PAY_BSV
               );



	INSERT INTO FUN_INTER_ACCOUNTS_ADDL
           (FROM_LE_ID,
            LEDGER_ID,
            TO_LE_ID,
            CCID,
            TYPE,
            START_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            TRANS_BSV,
            TP_BSV)
	SELECT DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_DR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.DRIVING_DR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_CR_LE_ID)),
                                              NULL),
       BAL_INTER_INT.LEDGER_ID,
       DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_CR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_DR_LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.DRIVING_CR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              NULL),
       BAL_INTER_INT.PAY_ACCT,
       'P',
       SYSDATE,
       '1',
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       fnd_global.login_id,
       BAL_INTER_INT.PAY_BSV,
       BAL_INTER_INT.REC_BSV
	FROM   FUN_BAL_INTER_INT_GT BAL_INTER_INT
	WHERE  BAL_INTER_INT.STATUS = 'OK'
       AND BAL_INTER_INT.PAY_ACCT IS NOT NULL
	   AND BAL_INTER_INT.PAY_BSV IS NOT NULL
	   AND BAL_INTER_INT.REC_BSV IS NOT NULL
	   AND NOT EXISTS (
	   	SELECT 'X'
		FROM FUN_INTER_ACCOUNTS_V ACCTV
		WHERE ACCTV.FROM_LE_ID = DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_DR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.DRIVING_DR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_CR_LE_ID)),
                                              NULL)
		AND ACCTV.LEDGER_ID = BAL_INTER_INT.LEDGER_ID
		AND ACCTV.TO_LE_ID = DECODE(BAL_INTER_INT.INTERCOMPANY_MODE,1,BAL_INTER_INT.DRIVING_CR_LE_ID,
                                              2,(DECODE(BAL_INTER_INT.TYPE,'C',BAL_INTER_INT.LE_ID,
                                                                           BAL_INTER_INT.DRIVING_DR_LE_ID)),
                                              3,(DECODE(BAL_INTER_INT.TYPE,'D',BAL_INTER_INT.DRIVING_CR_LE_ID,
                                                                           BAL_INTER_INT.LE_ID)),
                                              NULL)
		AND ACCTV.CCID = BAL_INTER_INT.PAY_ACCT
		AND ACCTV.TYPE = 'P'
		AND ACCTV.TRANS_BSV = BAL_INTER_INT.PAY_BSV
		AND ACCTV.TP_BSV = BAL_INTER_INT.REC_BSV
	   );


	/* 8200511 */

          -- Insert intercompany balancing lines into the FUN_BAL_LINES_GT table.  These resulting lines
          -- are not yet inserted into the results table as intracompany balancing might need to be performed
          -- for these lines also.
          INSERT INTO fun_bal_lines_gt lines (group_id, bal_seg_val, entered_amt_dr,
            entered_amt_cr, entered_currency_code, exchange_date, exchange_rate, exchange_rate_type,
        accounted_amt_dr, accounted_amt_cr, ccid, generated)
          SELECT sum_lines.group_id,
                   DECODE(gen.value, 'D', sum_lines.rec_bsv,
                                            'C', sum_lines.pay_bsv,
                                            NULL),
               DECODE(gen.value, 'D', DECODE(sum_lines.type, 'C', sum_lines.entered_amt_cr,
                                                                                      'D', sum_lines.entered_amt_dr),
                                             NULL),
               DECODE(gen.value, 'C', DECODE(sum_lines.type, 'C', sum_lines.entered_amt_cr,
                                                                                      'D', sum_lines.entered_amt_dr),
                                             NULL),
                   sum_lines.entered_currency_code,
               sum_lines.exchange_date, sum_lines.exchange_rate, sum_lines.exchange_rate_type,
               DECODE(gen.value, 'D', DECODE(sum_lines.type, 'C', sum_lines.accounted_amt_cr,
                                                                                      'D', sum_lines.accounted_amt_dr),
                                             NULL),
               DECODE(gen.value, 'C', DECODE(sum_lines.type, 'C', sum_lines.accounted_amt_cr,
                                                                                      'D', sum_lines.accounted_amt_dr),
                                             NULL),
                DECODE(gen.value, 'C', sum_lines.pay_acct, 'D', sum_lines.rec_acct, NULL),
                   'Y'
          FROM fun_bal_inter_int_gt sum_lines, fun_bal_generate_lines gen
          WHERE gen.value = DECODE(sum_lines.intercompany_mode,
                      1, DECODE(sum_lines.type, gen.value, 'X', gen.value),
                          2, DECODE(sum_lines.le_id, sum_lines.driving_dr_le_id, 'X', gen.value),
                          3, DECODE(sum_lines.le_id, sum_lines.driving_cr_le_id, 'X', gen.value),
                      4, DECODE(sum_lines.type, gen.value, 'X', gen.value));
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_inter_bal.end', 'end');
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END do_inter_bal;

FUNCTION do_intra_bal RETURN VARCHAR2 IS
  l_le_bsv_map_tab intra_le_bsv_map_tab_type;
  l_intra_int_tab intra_int_tab_type;
  l_le_bsv_map_count NUMBER;
  l_intra_int_count NUMBER;
  CURSOR l_le_bsv_map_cursor IS
    SELECT * FROM fun_bal_le_bsv_map_gt;
  CURSOR l_intra_int_cursor IS
    SELECT * FROM fun_bal_intra_int_gt;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.begin', 'begin');
  END IF;


      -- Delete all records from FUN_BAL_LE_BSV_MAP_GT for reuse.
          DELETE FROM fun_bal_le_bsv_map_gt;

          -- Insert records into FUN_BAL_LE_BSV_MAP_GT
          INSERT INTO fun_bal_le_bsv_map_gt(group_id, ledger_id, bal_seg_val, gl_date,
      je_source_name, je_category_name, clearing_bsv,
      chart_of_accounts_id, bal_seg_column_number,intercompany_column_number)
          SELECT DISTINCT hdrs.group_id, hdrs.ledger_id, lines.bal_seg_val, hdrs.gl_date,
                          hdrs.je_source_name, hdrs.je_category_name, hdrs.clearing_bsv,
                      hdrs.chart_of_accounts_id, hdrs.bal_seg_column_number, hdrs.intercompany_column_number
          FROM fun_bal_headers_gt hdrs, fun_bal_lines_gt lines
          WHERE hdrs.group_id = lines.group_id
        AND hdrs.status = 'OK';


  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.insert_le_bsv_map.finish', 'finish');
  END IF;


      -- Update Legal entity for each ledger, BSV combination.  Legal entity can only be either null or has a specific value
          UPDATE fun_bal_le_bsv_map_gt bsv_le_map
          SET le_id =
            NVL((SELECT vals.legal_entity_id
             FROM gl_ledger_le_bsv_specific_v vals
             WHERE bsv_le_map.bal_seg_val = vals.segment_value
        AND (TRUNC(bsv_le_map.gl_date) BETWEEN TRUNC(NVL(vals.start_date, bsv_le_map.gl_date)) AND
                                                         TRUNC(NVL(vals.end_date, bsv_le_map.gl_date)))
                AND bsv_le_map.ledger_id = vals.ledger_id
        ), -99);


  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.update_le.finish', 'finish');
  END IF;

          -- Determine intracompany mode, driving_dr_bsv and driving_cr_bsv
          -- improve performance for not updating the lines of LE that uses clearing company
          UPDATE fun_bal_le_bsv_map_gt le_bsv_map_upd
          SET (driving_dr_bsv, intracompany_mode) =
            (SELECT /*+ leading(LE_BSV_MAP) use_nl(LINES)
			index(LE_BSV_MAP,FUN_BAL_LE_BSV_MAP_GT_N1) index(LINES,FUN_BAL_LINES_GT_N1) */
			MIN(le_bsv_map.bal_seg_val), SUM(COUNT(DISTINCT(le_bsv_map.bal_seg_val)))
             FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines
             WHERE le_bsv_map.group_id = lines.group_id
                AND le_bsv_map.bal_seg_val = lines.bal_seg_val
            AND le_bsv_map.group_id = le_bsv_map_upd.group_id
            AND le_bsv_map.le_id = le_bsv_map_upd.le_id
			AND LE_BSV_MAP_UPD.LEDGER_ID = LE_BSV_MAP.LEDGER_ID
             GROUP BY le_bsv_map.group_id, le_bsv_map.le_id, le_bsv_map.bal_seg_val
             HAVING (SUM(NVL(lines.accounted_amt_dr, 0)) >
                       SUM(NVL(lines.accounted_amt_cr, 0)))
                       OR
                   ((SUM(NVL(lines.accounted_amt_dr, 0)) =
                       SUM(NVL(lines.accounted_amt_cr, 0))) AND
                       (SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0)) >
                        SUM(DECODE(lines.exchange_rate, NULL,NVL(lines.entered_amt_cr,0), 0)))))
          WHERE le_bsv_map_upd.intracompany_mode IS NULL; -- OR le_bsv_map_upd.intracompany_mode <> 5;


  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.update_intracompany_mode_1.finish', 'finish');
  END IF;


     --Delete records that has intracompany mode NULL
     DELETE FROM fun_bal_le_bsv_map_gt
     WHERE intracompany_mode IS NULL;

     DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map_del
     WHERE EXISTS (SELECT /*+ leading(LE_BSV_MAP) use_nl(LINES)
                          index(LE_BSV_MAP,FUN_BAL_LE_BSV_MAP_GT_N1) index(LINES,FUN_BAL_LINES_GT_N1) */
						  'BSV already balanced'
                             FROM fun_bal_lines_gt lines, fun_bal_le_bsv_map_gt le_bsv_map
                             WHERE le_bsv_map_del.group_id = le_bsv_map.group_id
                                  AND le_bsv_map_del.le_id = le_bsv_map.le_id
                                  AND le_bsv_map_del.bal_seg_val = le_bsv_map.bal_seg_val
                                  AND le_bsv_map.group_id = lines.group_id
                                  AND le_bsv_map.bal_seg_val = lines.bal_seg_val
								  AND le_bsv_map_del.LEDGER_ID = le_bsv_map.LEDGER_ID
                             GROUP BY le_bsv_map.group_id, le_bsv_map.le_id, le_bsv_map.bal_seg_val
                             HAVING (SUM(NVL(lines.accounted_amt_dr, 0)) =
                                               SUM(NVL(lines.accounted_amt_cr, 0)))
                                               AND
                                               (SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0)) =
                                                SUM(DECODE(lines.exchange_rate, NULL,NVL(lines.entered_amt_cr,0),0))));

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map_upd
          SET (driving_cr_bsv, intracompany_mode) =
            (SELECT /*+ leading(LE_BSV_MAP) use_nl(LINES)
			index(LE_BSV_MAP,FUN_BAL_LE_BSV_MAP_GT_N1) index(LINES,FUN_BAL_LINES_GT_N1) */
			MIN(le_bsv_map.bal_seg_val), DECODE(SUM(COUNT(DISTINCT(le_bsv_map.bal_seg_val))),
                                                         1, DECODE(le_bsv_map_upd.intracompany_mode, 1, 1, 3),
                                                             DECODE(le_bsv_map_upd.intracompany_mode, 1, 2, 4))
             FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines
             WHERE le_bsv_map.group_id = lines.group_id
                AND le_bsv_map.bal_seg_val = lines.bal_seg_val
            AND le_bsv_map.group_id = le_bsv_map_upd.group_id
            AND le_bsv_map.le_id = le_bsv_map_upd.le_id
			AND LE_BSV_MAP_UPD.LEDGER_ID = LE_BSV_MAP.LEDGER_ID
             GROUP BY le_bsv_map.group_id, le_bsv_map.le_id, le_bsv_map.bal_seg_val
             --HAVING  (le_bsv_map.clearing_option = '1D' OR le_bsv_map.clearing_option = '4M')
         -- No need for this having clause as it has brought to the higher level to check
             HAVING (SUM(NVL(lines.accounted_amt_cr, 0)) >
                       SUM(NVL(lines.accounted_amt_dr, 0)))
                       OR
                   ((SUM(NVL(lines.accounted_amt_dr, 0)) =
                       SUM(NVL(lines.accounted_amt_cr, 0))) AND
                       (SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0)) >
                        SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0)))))
                  WHERE le_bsv_map_upd.intracompany_mode IS NOT NULL;
              -- AND le_bsv_map_upd.intracompany_mode <> 5;

        -- Don't balance for journals that does not have a credit or debit side
     DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map
     WHERE le_bsv_map.driving_dr_bsv IS NULL OR le_bsv_map.driving_cr_bsv IS NULL;


  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.update_intracompany_mode.finish', 'finish');
  END IF;


          -- Update intra_template_id in FUN_BAL_LE_BSV_MAP
          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET template_id =
            (SELECT opts.template_id
             FROM fun_balance_options opts
             WHERE le_bsv_map.ledger_id = opts.ledger_id
             AND Nvl(le_bsv_map.le_id, -99) = Nvl(opts.le_id,-99)
             AND le_bsv_map.je_source_name = opts.je_source_name
             AND le_bsv_map.je_category_name = opts.je_category_name
             AND opts.status_flag = 'Y')
          WHERE le_bsv_map.template_id IS NULL;

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET template_id =
            (SELECT opts.template_id
             FROM fun_balance_options opts
             WHERE le_bsv_map.ledger_id = opts.ledger_id
             AND Nvl(le_bsv_map.le_id, -99) = Nvl(opts.le_id,-99)
             AND le_bsv_map.je_source_name = opts.je_source_name
             AND opts.je_category_name = 'Other'
             AND opts.status_flag = 'Y')
          WHERE le_bsv_map.template_id IS NULL;

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET template_id =
            (SELECT opts.template_id
             FROM fun_balance_options opts
             WHERE le_bsv_map.ledger_id = opts.ledger_id
             AND Nvl(le_bsv_map.le_id, -99) = Nvl(opts.le_id,-99)
             AND opts.je_source_name = 'Other'
             AND le_bsv_map.je_category_name = opts.je_category_name
             AND opts.status_flag = 'Y')
          WHERE le_bsv_map.template_id IS NULL;

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET template_id =
            (SELECT opts.template_id
             FROM fun_balance_options opts
             WHERE le_bsv_map.ledger_id = opts.ledger_id
             AND Nvl(le_bsv_map.le_id, -99) = Nvl(opts.le_id,-99)
         -- No error here if null, since both le_id is -99 if no legal entity is specified
             AND opts.je_source_name = 'Other'
             AND opts.je_category_name = 'Other'
             AND opts.status_flag = 'Y')
          WHERE le_bsv_map.template_id IS NULL;

     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, template_id, le_id, dr_bsv, cr_bsv)
     SELECT  'FUN_INTRA_RULE_NOT_ASSIGNED',
              le_bsv_map.group_id, le_bsv_map.template_id,
              DECODE(le_bsv_map.le_id, -99, NULL, le_bsv_map.le_id),
              le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv
     FROM fun_bal_le_bsv_map_gt le_bsv_map
     WHERE le_bsv_map.template_id IS NULL;

     IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.update_template.finish', 'finish');
     END IF;


        -- Logic to update balancing segment values are shown as follows:
        -- 1.  Summary mode, No clearing
        --    Require the debit, credit accounts from one template only
        -- 2.  Summary mode, clearing
        --    Require the debit, credit accounts from both templates
        -- 3.  Detail mode, No clearing
        --    Require the debit, credit accounts from both templates
        -- 4.  Detail mode, clearing
        --    Require the debit, credit accounts from both templates
          -- Retrieve the debit account ccid and credit account ccid with bal_seg_val in debit side


     -- Update balance_by, clearing_option, clearing_bsv in FUN_BAL_LE_BSV_MAP

     -- Balancing API Changes, Start, Feb 2005
     -- Modified the following for the introduction of 'Enter Manually on Journal' option
     -- as a valid value for many_to_many_option (2E). This used to first be a value
     -- for the clearing_option

     -- clearing_option   many_to_many_option   Jrnl Type    CBSV From       CBSV Reqd
     ---------------------------------------------------------------------------------
     --      1A                 2E                Any        journal               Y
     --      1A                 1C                Any        journal/options       Y
     ---------------------------------------------------------------------------------
     --      3M                 2E               M:M (4)     journal               Y
     --      3M                 2E               1,2,3       journal               N
     --      3M                 1C               M:M (4)     journal/options       Y
     --      3M                 1C               1,2,3       journal               N
     --      3M                 2D               M:M (4)     None                  N
     --      3M                 2D               1,2,3       journal               N
     ---------------------------------------------------------------------------------
       UPDATE fun_bal_le_bsv_map_gt le_bsv_map
       SET (balance_by, clearing_option, clearing_bsv, many_to_many_option) =
            (SELECT opts.balance_by_flag, opts.clearing_option,
                     DECODE (opts.clearing_option,
                             '1A', DECODE (opts.many_to_many_option,
                                           '2E', le_bsv_map.clearing_bsv,
                                           '1C', Nvl(le_bsv_map.clearing_bsv,opts.clearing_bsv)),
                             '3M', DECODE (opts.many_to_many_option,
                                           '2E', le_bsv_map.clearing_bsv,
                                           '1C', DECODE (le_bsv_map.intracompany_mode,
                                                         4, Nvl(le_bsv_map.clearing_bsv,opts.clearing_bsv),
                                                         le_bsv_map.clearing_bsv),
                                           '2D', DECODE (le_bsv_map.intracompany_mode,
                                                         4, NULL,
                                                         le_bsv_map.clearing_bsv)),
                             NULL),
                  opts.many_to_many_option
             FROM fun_balance_options opts
             WHERE le_bsv_map.template_id = opts.template_id
             AND opts.status_flag = 'Y');


     -- Note:  A new intracompany mode 5 is introduced.  Intracompany mode is 5 if clearing BSV is used
     UPDATE fun_bal_le_bsv_map_gt le_bsv_map
     SET intracompany_mode = 5
     WHERE le_bsv_map.clearing_bsv IS NOT NULL
	AND    ((le_bsv_map.clearing_option = '1A')     OR
             (le_bsv_map.clearing_option = '3M'      AND
              le_bsv_map.intracompany_mode = 4       AND
              le_bsv_map.many_to_many_option  IN ('2E', '1C')));

     --FND_STATS.GATHER_TABLE_STATS(g_fun_schema, 'FUN_BAL_LE_BSV_MAP_GT');

     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, template_id, le_id, dr_bsv, cr_bsv)
     SELECT 'FUN_INTRA_NO_CLEARING_BSV',
            le_bsv_map.group_id, le_bsv_map.template_id,
            DECODE(le_bsv_map.le_id, -99, NULL, le_bsv_map.le_id),
            le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv
     FROM   fun_bal_le_bsv_map_gt le_bsv_map
     WHERE  le_bsv_map.clearing_bsv IS NULL
     AND    ((le_bsv_map.clearing_option = '1A')     OR
             (le_bsv_map.clearing_option = '3M'      AND
              le_bsv_map.intracompany_mode = 4       AND
              le_bsv_map.many_to_many_option  IN ('2E', '1C')));

     -- Check if the clearing BSV is valid (Bug 3345457)
     -- Perform this validation only if the Ledger BSV mapping is set to
     -- 'Specific' ('I')
     INSERT INTO FUN_BAL_ERRORS_GT(error_code, group_id, template_id, le_id, clearing_bsv,
                                   dr_bsv, cr_bsv)
     SELECT 'FUN_INTRA_CLEAR_BSV_INVALID',
            le_bsv_map.group_id, le_bsv_map.template_id,
            DECODE(le_bsv_map.le_id, -99, NULL, le_bsv_map.le_id),
            le_bsv_map.clearing_bsv,
            le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv
     FROM   fun_bal_le_bsv_map_gt le_bsv_map,
            gl_ledgers            ledger
     WHERE  le_bsv_map.clearing_bsv IS NOT NULL
     AND    ledger.ledger_id = le_bsv_map.ledger_id
     AND    ledger.bal_seg_value_option_code = 'I'
     AND    NOT EXISTS
                       (SELECT 'X'
                        FROM   gl_ledger_le_bsv_specific_v gl_seg
                        WHERE  gl_seg.ledger_id     = le_bsv_map.ledger_id
                        AND    gl_seg.segment_value = le_bsv_map.clearing_bsv
                        AND    TRUNC(le_bsv_map.gl_date) BETWEEN TRUNC(NVL(gl_seg.start_date, le_bsv_map.gl_date))
                                                         AND     TRUNC(NVL(gl_seg.end_date, le_bsv_map.gl_date)));

     -- Balancing API Changes, End , Feb 2005

     UPDATE fun_bal_headers_gt headers
     SET STATUS = 'ERROR'
     WHERE EXISTS (SELECT 'Errors for no template or no clearing bsv or clearing bsv invalid'
                               FROM FUN_BAL_ERRORS_GT errors
                               WHERE headers.group_id =  errors.group_id
                                    AND error_code IN ('FUN_INTRA_RULE_NOT_ASSIGNED',
                                                       'FUN_INTRA_NO_CLEARING_BSV',
                                                       'FUN_INTRA_CLEAR_BSV_INVALID'))
     AND headers.status = 'OK';

     DELETE FROM fun_bal_le_bsv_map_gt le_bsv_map
     WHERE EXISTS (SELECT group_id
                               FROM fun_bal_headers_gt headers
                               WHERE headers.status = 'ERROR'
                               AND le_bsv_map.group_id = headers.group_id);

      -- Update ccid for each DB BSV and CR BSV
          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (dr_cr_debit_ccid, dr_cr_credit_ccid, dr_cr_debit_complete, dr_cr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, 'Y', 'Y'
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND ((le_bsv_map.intracompany_mode = 5
                 AND le_bsv_map.bal_seg_val = accts.dr_bsv
                 AND le_bsv_map.clearing_bsv = accts.cr_bsv)
         OR (le_bsv_map.intracompany_mode  = 1
              AND le_bsv_map.bal_seg_val = accts.dr_bsv
              AND DECODE(le_bsv_map.bal_seg_val,
                                   le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv,
                                   le_bsv_map.driving_dr_bsv) = accts.cr_bsv)
         OR (le_bsv_map.intracompany_mode = 2
              AND le_bsv_map.bal_seg_val = accts.dr_bsv
              AND le_bsv_map.driving_dr_bsv = accts.cr_bsv)
         OR (le_bsv_map.intracompany_mode = 3
             AND le_bsv_map.bal_seg_val = accts.dr_bsv
             AND le_bsv_map.driving_cr_bsv = accts.cr_bsv)));


          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (dr_cr_debit_ccid, dr_cr_credit_ccid, dr_cr_debit_complete, dr_cr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, DECODE(le_bsv_map.intercompany_column_number,
                                                 NULL, 'Y', 'N'), 'N'
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND ((le_bsv_map.intracompany_mode = 5
                 AND 'OTHER1234567890123456789012345' = accts.cr_bsv
                 AND le_bsv_map.bal_seg_val = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode  IN (1,2,3)
              AND le_bsv_map.bal_seg_val = accts.dr_bsv
              AND 'OTHER1234567890123456789012345' = accts.cr_bsv)))
      WHERE dr_cr_debit_ccid IS NULL; --OR dr_cr_credit_ccid IS NULL; No need to check both

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (dr_cr_debit_ccid, dr_cr_credit_ccid, dr_cr_debit_complete, dr_cr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, 'N', DECODE(le_bsv_map.intercompany_column_number,
                                                 NULL, 'Y', 'N')
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND ((le_bsv_map.intracompany_mode = 5
                 AND le_bsv_map.clearing_bsv = accts.cr_bsv
                 AND 'OTHER1234567890123456789012345' = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode  = 1
              AND 'OTHER1234567890123456789012345' = accts.dr_bsv
              AND DECODE(le_bsv_map.bal_seg_val,
                                   le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv,
                                   le_bsv_map.driving_dr_bsv) = accts.cr_bsv)
         OR (le_bsv_map.intracompany_mode = 2
              AND 'OTHER1234567890123456789012345' = accts.dr_bsv
              AND le_bsv_map.driving_dr_bsv = accts.cr_bsv)
         OR (le_bsv_map.intracompany_mode = 3
             AND 'OTHER1234567890123456789012345' = accts.dr_bsv
             AND le_bsv_map.driving_cr_bsv = accts.cr_bsv)))
      WHERE dr_cr_debit_ccid IS NULL;

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (dr_cr_debit_ccid, dr_cr_credit_ccid, dr_cr_debit_complete, dr_cr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, 'N', 'N'
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND 'OTHER1234567890123456789012345' = accts.cr_bsv
         AND 'OTHER1234567890123456789012345' = accts.dr_bsv)
      WHERE dr_cr_debit_ccid IS NULL ;

-- Upating cr_dr_debit_ccid, cr_dr_credit_ccid
          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (cr_dr_debit_ccid, cr_dr_credit_ccid, cr_dr_debit_complete, cr_dr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, 'Y', 'Y'
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND ((le_bsv_map.intracompany_mode = 5
                 AND le_bsv_map.bal_seg_val = accts.cr_bsv
                 AND le_bsv_map.clearing_bsv = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode  = 1
              AND le_bsv_map.bal_seg_val = accts.cr_bsv
              AND DECODE(le_bsv_map.bal_seg_val,
                                   le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv,
                                   le_bsv_map.driving_dr_bsv) = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode = 2
              AND le_bsv_map.bal_seg_val = accts.cr_bsv
              AND le_bsv_map.driving_dr_bsv = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode = 3
             AND le_bsv_map.bal_seg_val = accts.cr_bsv
             AND le_bsv_map.driving_cr_bsv = accts.dr_bsv)));

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (cr_dr_debit_ccid, cr_dr_credit_ccid, cr_dr_debit_complete, cr_dr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, DECODE(le_bsv_map.intercompany_column_number,
                                                 NULL, 'Y', 'N'), 'N'
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND ((le_bsv_map.intracompany_mode = 5
                 AND 'OTHER1234567890123456789012345' = accts.cr_bsv
                 AND le_bsv_map.clearing_bsv = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode  = 1
              AND 'OTHER1234567890123456789012345' = accts.cr_bsv
              AND DECODE(le_bsv_map.bal_seg_val,
                                   le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv,
                                   le_bsv_map.driving_dr_bsv) = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode = 2
              AND 'OTHER1234567890123456789012345' = accts.cr_bsv
              AND le_bsv_map.driving_dr_bsv = accts.dr_bsv)
         OR (le_bsv_map.intracompany_mode = 3
             AND 'OTHER1234567890123456789012345' = accts.cr_bsv
             AND le_bsv_map.driving_cr_bsv = accts.dr_bsv)))
      WHERE cr_dr_debit_ccid IS NULL;

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (cr_dr_debit_ccid, cr_dr_credit_ccid, cr_dr_debit_complete, cr_dr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, 'N', DECODE(le_bsv_map.intercompany_column_number,
                                                 NULL, 'Y', 'N')
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND ((le_bsv_map.intracompany_mode = 5
                 AND 'OTHER1234567890123456789012345' = accts.dr_bsv
                 AND le_bsv_map.bal_seg_val = accts.cr_bsv)
         OR (le_bsv_map.intracompany_mode  IN (1,2,3)
              AND le_bsv_map.bal_seg_val = accts.cr_bsv
              AND 'OTHER1234567890123456789012345' = accts.dr_bsv)))
      WHERE cr_dr_debit_ccid IS NULL;

          UPDATE fun_bal_le_bsv_map_gt le_bsv_map
          SET (cr_dr_debit_ccid, cr_dr_credit_ccid, cr_dr_debit_complete, cr_dr_credit_complete) =
            (SELECT dr_ccid, cr_ccid, 'N', 'N'
             FROM fun_balance_accounts accts
             WHERE le_bsv_map.template_id = accts.template_id
             AND 'OTHER1234567890123456789012345' = accts.cr_bsv
         AND 'OTHER1234567890123456789012345' = accts.dr_bsv)
      WHERE cr_dr_debit_ccid IS NULL;

/*  Not done for checking ccid valid through gl_code_combinations directly
      UPDATE fun_bal_le_bsv_map_gt le_bsv_map
      SET (dr_cr_debit_ccid, dr_cr_debit_complete) =
        (SELECT code_combination_id, DECODE(ccid, NULL, 'N', 'Y')
        FROM gl_code_combinations cc1,
                  gl_code_combinations cc2
        WHERE le_bsv_map.dr_cr_debit_ccid = cc1.code_combination_id
             AND cc1.segment1 = DECODE(le_bsv_map.bal_seg_column_no, 1, le_bsv_)
     WHERE dr_cr_debit_complete = 'N'
*/

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.get_ccid.begin', 'begin');
  END IF;

      -- Retrieve correct ccid by replacing balancing segment and intercompany segment
      UPDATE fun_bal_le_bsv_map_gt le_bsv_map
      SET dr_cr_debit_ccid =
                   DECODE(le_bsv_map.dr_cr_debit_complete, 'Y', le_bsv_map.dr_cr_debit_ccid,
                              get_ccid(le_bsv_map.dr_cr_debit_ccid, le_bsv_map.chart_of_accounts_id, le_bsv_map.bal_seg_val,
                                   DECODE(le_bsv_map.intracompany_mode,
                                               1, DECODE(le_bsv_map.bal_seg_val, le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv, le_bsv_map.driving_dr_bsv),
                                               2, le_bsv_map.driving_dr_bsv,
                                               3, le_bsv_map.driving_cr_bsv,
                                               4, le_bsv_map.bal_seg_val,
                                               5, le_bsv_map.clearing_bsv,
                                               NULL),
                               le_bsv_map.bal_seg_column_number, le_bsv_map.intercompany_column_number,
                               le_bsv_map.gl_date)),
            dr_cr_credit_ccid =
                   DECODE(le_bsv_map.dr_cr_credit_complete, 'Y', le_bsv_map.dr_cr_credit_ccid,
                               get_ccid(le_bsv_map.dr_cr_credit_ccid,  le_bsv_map.chart_of_accounts_id,
                                   DECODE(le_bsv_map.intracompany_mode,
                                               1, DECODE(le_bsv_map.bal_seg_val, le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv, le_bsv_map.driving_dr_bsv),
                                               2, le_bsv_map.driving_dr_bsv,
                                               3, le_bsv_map.driving_cr_bsv,
                                               4, le_bsv_map.bal_seg_val,
                                               5, le_bsv_map.clearing_bsv,
                                               NULL),
                               le_bsv_map.bal_seg_val,
                               le_bsv_map.bal_seg_column_number, le_bsv_map.intercompany_column_number,
                               le_bsv_map.gl_date)),
            cr_dr_debit_ccid =
                   DECODE(le_bsv_map.cr_dr_debit_complete, 'Y', le_bsv_map.cr_dr_debit_ccid,
                              get_ccid(le_bsv_map.cr_dr_debit_ccid, le_bsv_map.chart_of_accounts_id,
                                   DECODE(le_bsv_map.intracompany_mode,
                                               1, DECODE(le_bsv_map.bal_seg_val, le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv, le_bsv_map.driving_dr_bsv),
                                               2, le_bsv_map.driving_dr_bsv,
                                               3, le_bsv_map.driving_cr_bsv,
                                               4, le_bsv_map.bal_seg_val,
                                               5, le_bsv_map.clearing_bsv,
                                               NULL),
                               le_bsv_map.bal_seg_val,
                               le_bsv_map.bal_seg_column_number, le_bsv_map.intercompany_column_number,
                               le_bsv_map.gl_date)),
            cr_dr_credit_ccid =
                   DECODE(le_bsv_map.cr_dr_credit_complete, 'Y', le_bsv_map.cr_dr_credit_ccid,
                               get_ccid(le_bsv_map.cr_dr_credit_ccid, le_bsv_map.chart_of_accounts_id, le_bsv_map.bal_seg_val,
                                   DECODE(le_bsv_map.intracompany_mode,
                                               1, DECODE(le_bsv_map.bal_seg_val, le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv, le_bsv_map.driving_dr_bsv),
                                               2, le_bsv_map.driving_dr_bsv,
                                               3, le_bsv_map.driving_cr_bsv,
                                               4, le_bsv_map.bal_seg_val,
                                               5, le_bsv_map.clearing_bsv,
                                               NULL),
                               le_bsv_map.bal_seg_column_number, le_bsv_map.intercompany_column_number,
                               le_bsv_map.gl_date));

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.get_ccid.end', 'end');
  END IF;

     IF g_debug = FND_API.G_TRUE THEN
         OPEN l_le_bsv_map_cursor;
         FETCH l_le_bsv_map_cursor BULK COLLECT INTO l_le_bsv_map_tab;
         l_le_bsv_map_count := l_le_bsv_map_cursor%ROWCOUNT;
         CLOSE l_le_bsv_map_cursor;
         ins_t_tables_intra_1_auto(l_le_bsv_map_tab, l_le_bsv_map_count);
     END IF;

      -- Insert into FUN_BAL_INTRA_INT_GT for lines that require Intracompany Balancing
      INSERT INTO fun_bal_intra_int_gt(group_id, gl_date, driving_dr_bsv, driving_cr_bsv,
        intracompany_mode, balance_by,  clearing_option, bal_seg_val, le_id, template_id, entered_currency_code,
        exchange_date, exchange_rate, exchange_rate_type, accounted_amt_cr, accounted_amt_dr,
        entered_amt_cr, entered_amt_dr,
        dr_cr_debit_ccid, dr_cr_credit_ccid, cr_dr_debit_ccid, cr_dr_credit_ccid,
        type, clearing_bsv)
        (SELECT hdrs.group_id, hdrs.gl_date, le_bsv_map.driving_dr_bsv,
                       le_bsv_map.driving_cr_bsv, le_bsv_map.intracompany_mode, le_bsv_map.balance_by,
                       le_bsv_map.clearing_option, le_bsv_map.bal_seg_val,
                       le_bsv_map.le_id, le_bsv_map.template_id, lines.entered_currency_code,
               SYSDATE,DECODE(LINES.EXCHANGE_RATE, NULL, NULL,DECODE (DECODE(SIGN(NVL(LINES.ACCOUNTED_AMT_CR, 0) - NVL(LINES.ACCOUNTED_AMT_DR, 0)),
	       1, 1,-1, -1,0, DECODE(SIGN((( NVL(LINES.ENTERED_AMT_CR, 0) - NVL(LINES.ENTERED_AMT_DR, 0)) ) - ( NVL(LINES.ACCOUNTED_AMT_DR, 0) - NVL(LINES.ACCOUNTED_AMT_CR, 0)) ),
	       1, 1, -1)), -1, LINES.ACCOUNTED_AMT_DR / LINES.ENTERED_AMT_DR, LINES.ACCOUNTED_AMT_CR / LINES.ENTERED_AMT_CR)) EXCHANGE_RATE,'User',
                       -- Bug 3223147 DECODE(SIGN(NVL(lines.accounted_amt_cr, 0) - NVL(lines.accounted_amt_dr, 0)),
                       --      1, ABS(NVL(lines.accounted_amt_cr, 0) - NVL(lines.accounted_amt_dr, 0)), NULL)
                             lines.accounted_amt_cr,
                       -- Bug 3223147 DECODE(SIGN(NVL(lines.accounted_amt_cr, 0) - NVL(lines.accounted_amt_dr, 0)),
                       --       -1, ABS(NVL(lines.accounted_amt_cr, 0) - NVL(lines.accounted_amt_dr, 0)), NULL)
                             lines.accounted_amt_dr,
                       -- Bug 3223147 DECODE(SIGN(NVL(lines.entered_amt_cr, 0) - NVL(lines.entered_amt_dr, 0)),
                       --       1, ABS(NVL(lines.entered_amt_cr, 0) - NVL(lines.entered_amt_dr, 0)), NULL)
                             lines.entered_amt_cr,
                       -- Bug 3223147 DECODE(SIGN(NVL(lines.entered_amt_cr, 0) - NVL(lines.entered_amt_dr, 0)),
                       --       -1, ABS(NVL(lines.entered_amt_cr, 0) - NVL(lines.entered_amt_dr, 0)), NULL)
                             lines.entered_amt_dr,
               le_bsv_map.dr_cr_debit_ccid, le_bsv_map.dr_cr_credit_ccid, le_bsv_map.cr_dr_debit_ccid,
               le_bsv_map.cr_dr_credit_ccid,

               /* Bug 3223147
               DECODE(SIGN(NVL(lines.accounted_amt_cr, 0)-NVL(lines.accounted_amt_dr,0)),
                        1, 'C',
                        -1, 'D',
                        0, DECODE(SIGN(NVL(lines.entered_amt_cr, 0) - NVL(lines.accounted_amt_dr, 0)),
                                     1, 'C',
                                     'D'))  type,
                                     */
               DECODE(lines.accounted_amt_cr, NULL, DECODE(lines.entered_amt_cr, NULL, 'D',  'C'), 'C') type,
                 le_bsv_map.clearing_bsv
                FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines, fun_bal_headers_gt hdrs
                WHERE hdrs.group_id = lines.group_id
                  AND lines.group_id = le_bsv_map.group_id
                  AND lines.bal_seg_val = le_bsv_map.bal_seg_val
                  AND hdrs.status = 'OK'
          AND le_bsv_map.balance_by = 'D'
              UNION ALL
                SELECT hdrs.group_id, hdrs.gl_date, le_bsv_map.driving_dr_bsv,
                       le_bsv_map.driving_cr_bsv, le_bsv_map.intracompany_mode, le_bsv_map.balance_by,
                       le_bsv_map.clearing_option, le_bsv_map.bal_seg_val,
                       le_bsv_map.le_id, le_bsv_map.template_id, lines.entered_currency_code,
                      SYSDATE,DECODE(MAX(LINES.EXCHANGE_RATE), NULL, NULL,( SUM(NVL(LINES.ACCOUNTED_AMT_DR, 0)) - SUM(NVL(LINES.ACCOUNTED_AMT_CR, 0))) / (( SUM(NVL(LINES.ENTERED_AMT_DR, 0)) - SUM(NVL(LINES.ENTERED_AMT_CR, 0))) ) ) EXCHANGE_RATE,'User',
                       DECODE(SIGN(SUM(NVL(lines.accounted_amt_cr, 0)) - SUM(NVL(lines.accounted_amt_dr, 0))),
                              1, ABS(SUM(NVL(lines.accounted_amt_cr, 0)) - SUM(NVL(lines.accounted_amt_dr, 0))), NULL)
                             accounted_amt_cr,
                       DECODE(SIGN(SUM(NVL(lines.accounted_amt_cr, 0)) - SUM(NVL(lines.accounted_amt_dr, 0))),
                              -1, ABS(SUM(NVL(lines.accounted_amt_cr, 0)) - SUM(NVL(lines.accounted_amt_dr, 0))), NULL)
                             accounted_amt_dr,
                       DECODE(SIGN(SUM(NVL(lines.entered_amt_cr, 0)) - SUM(NVL(lines.entered_amt_dr, 0))),
                               1, ABS(SUM(NVL(lines.entered_amt_cr, 0)) - SUM(NVL(lines.entered_amt_dr, 0))), NULL)
                             entered_amt_cr,
                       DECODE(SIGN(SUM(NVL(lines.entered_amt_cr, 0)) - SUM(NVL(lines.entered_amt_dr, 0))),
                              -1, ABS(SUM(NVL(lines.entered_amt_cr, 0)) - SUM(NVL(lines.entered_amt_dr, 0))), NULL)
                             entered_amt_dr,
               le_bsv_map.dr_cr_debit_ccid, le_bsv_map.dr_cr_credit_ccid, le_bsv_map.cr_dr_debit_ccid,
               le_bsv_map.cr_dr_credit_ccid,
               DECODE(SIGN(SUM(NVL(lines.accounted_amt_cr, 0))-SUM(NVL(lines.accounted_amt_dr,0))),
                        1, 'C',
                        -1, 'D',
                        0, DECODE(SIGN(SUM(NVL(lines.entered_amt_cr, 0)) - SUM(NVL(lines.accounted_amt_dr, 0))),
                                     1, 'C',
                                     'D'))  type,  le_bsv_map.clearing_bsv
                FROM fun_bal_le_bsv_map_gt le_bsv_map, fun_bal_lines_gt lines,
                     fun_bal_headers_gt hdrs
                WHERE hdrs.group_id = lines.group_id
                  AND lines.group_id = le_bsv_map.group_id
                  AND lines.bal_seg_val = le_bsv_map.bal_seg_val
                  AND hdrs.status = 'OK'
          AND le_bsv_map.balance_by = 'S'
                GROUP BY hdrs.group_id, hdrs.gl_date, hdrs.status, le_bsv_map.driving_dr_bsv, le_bsv_map.driving_cr_bsv,
                     le_bsv_map.intracompany_mode, le_bsv_map.balance_by, le_bsv_map.clearing_option, le_bsv_map.bal_seg_val,
                     le_bsv_map.le_id, lines.entered_currency_code, le_bsv_map.dr_cr_debit_ccid, le_bsv_map.dr_cr_credit_ccid, le_bsv_map.cr_dr_debit_ccid,
                 le_bsv_map.cr_dr_credit_ccid, le_bsv_map.clearing_bsv, le_bsv_map.template_id
                HAVING SUM(NVL(lines.accounted_amt_cr, 0)) <> SUM(NVL(lines.accounted_amt_dr,0))
                          OR (SUM(NVL(lines.accounted_amt_cr, 0)) = SUM(NVL(lines.accounted_amt_dr,0))
                              AND
                         SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_cr, 0), 0)) <>
                         SUM(DECODE(lines.exchange_rate, NULL, NVL(lines.entered_amt_dr, 0), 0))));

     --FND_STATS.GATHER_TABLE_STATS(g_fun_schema, 'FUN_BAL_INTRA_INT_GT');

     IF g_debug = FND_API.G_TRUE THEN
         OPEN l_intra_int_cursor;
         FETCH l_intra_int_cursor BULK COLLECT INTO l_intra_int_tab;
        l_intra_int_count := l_intra_int_cursor%ROWCOUNT;
         CLOSE l_intra_int_cursor;
       ins_t_tables_intra_2_auto(l_intra_int_tab, l_intra_int_count);
     END IF;

                 -- Insert intracompany balancing lines into the FUN_BAL_RESULTS_GT table.
                 -- These resulting lines would be directly inserted into the results table
             -- 'C' normally means that a credit line should be created, but when run in detail
             -- mode, it could mean a debit line.
          INSERT INTO fun_bal_results_gt lines(group_id, bal_seg_val, entered_amt_dr,
            entered_amt_cr, entered_currency_code, exchange_date, exchange_rate, exchange_rate_type,
        accounted_amt_dr, accounted_amt_cr, ccid, dr_bsv, cr_bsv, acct_type, le_id, template_id, balancing_type)
          SELECT intra_lines.group_id,
                  DECODE(intra_lines.intracompany_mode,
                               1, bal_seg_val,
                               2, DECODE(gen.value, 'C', intra_lines.driving_dr_bsv, intra_lines.bal_seg_val),
                               3, DECODE(gen.value, 'C', intra_lines.bal_seg_val, intra_lines.driving_cr_bsv),
                               4, bal_seg_val,
                               5, DECODE(gen.value, intra_lines.type, intra_lines.clearing_bsv, intra_lines.bal_seg_val),
                               NULL),
                 DECODE(intra_lines.intracompany_mode,
                              1, intra_lines.entered_amt_cr,
                              2, DECODE(gen.value, 'C', intra_lines.entered_amt_dr,
                                                              'D', intra_lines.entered_amt_cr,
                                                              -1),
                              3, DECODE(gen.value, 'C', intra_lines.entered_amt_cr,
                                                              'D', intra_lines.entered_amt_dr,
                                                              -1),
                              4, intra_lines.entered_amt_cr,
                              5, DECODE(gen.value, intra_lines.type, intra_lines.entered_amt_dr,
                                                                                      intra_lines.entered_amt_cr)),
                 DECODE(intra_lines.intracompany_mode,
                              1, intra_lines.entered_amt_dr,
                              2, DECODE(gen.value, 'C', intra_lines.entered_amt_cr,
                                                              'D', intra_lines.entered_amt_dr,
                                                              -1),
                              3, DECODE(gen.value, 'C', intra_lines.entered_amt_dr,
                                                              'D', intra_lines.entered_amt_cr,
                                                              -1),
                              4, intra_lines.entered_amt_dr,
                              5, DECODE(gen.value, intra_lines.type, intra_lines.entered_amt_cr,
                                                                                      intra_lines.entered_amt_dr)),
                 intra_lines.entered_currency_code,
                 intra_lines.exchange_date, intra_lines.exchange_rate, intra_lines.exchange_rate_type,
                 DECODE(intra_lines.intracompany_mode,
                              1, intra_lines.accounted_amt_cr,
                              2, DECODE(gen.value, 'C', intra_lines.accounted_amt_dr,
                                                              'D', intra_lines.accounted_amt_cr,
                                                              -1),
                              3, DECODE(gen.value, 'C', intra_lines.accounted_amt_cr,
                                                              'D', intra_lines.accounted_amt_dr,
                                                              -1),
                              4, intra_lines.accounted_amt_cr,
                              5, DECODE(gen.value, intra_lines.type, intra_lines.accounted_amt_dr,
                                                                                      intra_lines.accounted_amt_cr)),
                 DECODE(intra_lines.intracompany_mode,
                              1, intra_lines.accounted_amt_dr,
                              2, DECODE(gen.value, 'C', intra_lines.accounted_amt_cr,
                                                              'D', intra_lines.accounted_amt_dr,
                                                              -1),
                              3, DECODE(gen.value, 'C', intra_lines.accounted_amt_dr,
                                                              'D', intra_lines.accounted_amt_cr,
                                                              -1),
                              4, intra_lines.accounted_amt_dr,
                              5, DECODE(gen.value, intra_lines.type, intra_lines.accounted_amt_cr,
                                                                                      intra_lines.accounted_amt_dr)),
                 DECODE(intra_lines.intracompany_mode,
                              1, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'D', cr_dr_credit_ccid, -- bal_seg_val
                                                                                                         'C', dr_cr_debit_ccid,
                                                                                                         -1),
                                                              'D', DECODE(intra_lines.type, 'C', dr_cr_debit_ccid, -- bal_seg_val
                                                                                                        'D', cr_dr_credit_ccid,
                                                                                                        -1),
                                                               -1),
                              2, DECODE(gen.value, 'D', DECODE(intra_lines.type, 'C', dr_cr_debit_ccid, -- bal_seg_val
                                                                                                         'D', cr_dr_credit_ccid,
                                                                                                         -1),
                                                              'C', DECODE(intra_lines.type, 'C', dr_cr_credit_ccid, -- other_seg_val
                                                                                                        'D', cr_dr_debit_ccid,
                                                                                                        -1),
                                                               -1),
                              3, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'C', dr_cr_debit_ccid, -- bal_seg_val
                                                                                                        'D', cr_dr_credit_ccid,
                                                                                                        -1),
                                                               'D', DECODE(intra_lines.type, 'D', cr_dr_debit_ccid, -- other_seg_val
                                                                                                         'C', dr_cr_credit_ccid,
                                                                                                         -1),
                                                              -1),
                              4, DECODE(gen.value, 'C', cr_dr_credit_ccid,
                                                              'D', dr_cr_debit_ccid,
                                                              -1),
                              5, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'D', cr_dr_credit_ccid, -- bal_seg_val
                                                                                                        'C', dr_cr_credit_ccid, -- other_seg_val
                                                                                                        -1),
                                                              'D', DECODE(intra_lines.type, 'C', dr_cr_debit_ccid, -- bal_seg_val
                                                                                                         'D', cr_dr_debit_ccid, -- other_seg_val
                                                                                                         -1),
                                                               -1)),
                 DECODE(intra_lines.intracompany_mode,
                              1, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'D', driving_cr_bsv,
                                                                                                         'C', bal_seg_val,
                                                                                                         -1),
                                                              'D', DECODE(intra_lines.type, 'C', bal_seg_val,
                                                                                                        'D', driving_dr_bsv,
                                                                                                        -1),
                                                               -1),
                              2, DECODE(gen.value, 'D', DECODE(intra_lines.type, 'C', bal_seg_val,
                                                                                                         'D', driving_dr_bsv,
                                                                                                         -1),
                                                              'C', DECODE(intra_lines.type, 'C', bal_seg_val,
                                                                                                        'D', driving_dr_bsv,
                                                                                                        -1),
                                                               -1),
                              3, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'C', bal_seg_val,
                                                                                                        'D', driving_cr_bsv,
                                                                                                        -1),
                                                               'D', DECODE(intra_lines.type, 'D', driving_cr_bsv,
                                                                                                         'C', bal_seg_val,
                                                                                                         -1),
                                                              -1),
                              4, bal_seg_val,
                              5, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'D', clearing_bsv,
                                                                                                        'C', bal_seg_val,
                                                                                                        -1),
                                                              'D', DECODE(intra_lines.type, 'C', bal_seg_val,
                                                                                                         'D', clearing_bsv,
                                                                                                         -1),
                                                               -1)),
                 DECODE(intra_lines.intracompany_mode,
                              1, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'D', bal_seg_val,
                                                                                                         'C', driving_cr_bsv,
                                                                                                         -1),
                                                              'D', DECODE(intra_lines.type, 'C', driving_dr_bsv,
                                                                                                        'D', bal_seg_val,
                                                                                                        -1),
                                                               -1),
                              2, DECODE(gen.value, 'D', DECODE(intra_lines.type, 'C', driving_dr_bsv,
                                                                                                         'D', bal_seg_val,
                                                                                                         -1),
                                                              'C', DECODE(intra_lines.type, 'C', driving_dr_bsv,
                                                                                                        'D', bal_seg_val,
                                                                                                        -1),
                                                               -1),
                              3, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'C', driving_cr_bsv,
                                                                                                        'D', bal_seg_val,
                                                                                                        -1),
                                                               'D', DECODE(intra_lines.type, 'D', bal_seg_val,
                                                                                                         'C', driving_cr_bsv,
                                                                                                         -1),
                                                              -1),
                              4, bal_seg_val,
                              5, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'D', bal_seg_val,
                                                                                                        'C', clearing_bsv,
                                                                                                        -1),
                                                              'D', DECODE(intra_lines.type, 'C', clearing_bsv,
                                                                                                         'D', bal_seg_val,
                                                                                                         -1),
                                                               -1)),
                 DECODE(intra_lines.intracompany_mode,
                              1, DECODE(intra_lines.type, 'D', 'C',
                                                                       'C', 'D', -1),
                              2, DECODE(gen.value, 'D', DECODE(intra_lines.type, 'C', 'D',
                                                                                                         'D', 'C',
                                                                                                         -1),
                                                              'C', DECODE(intra_lines.type, 'C', 'C',
                                                                                                        'D', 'D',
                                                                                                        -1),
                                                               -1),
                              3, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'C', 'D',
                                                                                                        'D', 'C',
                                                                                                        -1),
                                                               'D', DECODE(intra_lines.type, 'D', 'D',
                                                                                                         'C', 'C',
                                                                                                         -1),
                                                              -1),
                              4, gen.value,
                              5, gen.value,
                                                               -1),
                  intra_lines.le_id, intra_lines.template_id, 'R'
          FROM FUN_BAL_INTRA_INT_GT intra_lines, FUN_BAL_GENERATE_LINES gen
          WHERE gen.value = DECODE(intra_lines.intracompany_mode,
                                                     1, DECODE(gen.value, 'C', DECODE(intra_lines.bal_seg_val,
                                                                                                    intra_lines.driving_cr_bsv, 'X', gen.value),
                                                                                 'D', DECODE(intra_lines.bal_seg_val,
                                                                                                    intra_lines.driving_dr_bsv, 'X', gen.value),
                                                                                 'X'),
                                                     2, DECODE(intra_lines.bal_seg_val, intra_lines.driving_dr_bsv, 'X', gen.value),
                                                 3, DECODE(intra_lines.bal_seg_val, intra_lines.driving_cr_bsv, 'X', gen.value),
                                                     4, DECODE(gen.value, 'C', DECODE(intra_lines.type, 'C', 'X', gen.value),
                                                                                 'D', DECODE(intra_lines.type, 'D', 'X', gen.value)),
                                                 5, DECODE(bal_seg_val, clearing_bsv, 'X', gen.value), -- bug 3203634
                                                 'X');

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.get_ccid_concat_disp.begin', 'begin');
  END IF;

      INSERT INTO fun_bal_errors_gt(error_code, group_id, template_id, le_id,
                                                     dr_bsv, cr_bsv, acct_type, ccid_concat_display)
      SELECT DISTINCT DECODE(SIGN(NVL(results.ccid, 0)),
                                              -1, 'FUN_INTRA_CC_NOT_CREATED',
                                               0, 'FUN_INTRA_CC_NOT_CREATED',
                                               DECODE(cc.summary_flag,
                                                            'Y', 'FUN_INTRA_CC_NOT_VALID',
                                                            DECODE(cc.template_id,
                                                                     NULL, 'FUN_INTRA_CC_NOT_ACTIVE',
                                                                     'FUN_INTRA_CC_NOT_VALID'))),
                  headers.group_id, results.template_id,
                  DECODE(results.le_id, -99, NULL, results.le_id),
                  results.dr_bsv, results.cr_bsv,
                  results.acct_type, get_ccid_concat_disp(results.ccid, headers.chart_of_accounts_id,
                  DECODE(results.acct_type, 'C', results.cr_bsv, results.dr_bsv),
                  DECODE(results.acct_type, 'C', results.dr_bsv, results.cr_bsv),
                  headers.bal_seg_column_number, headers.intercompany_column_number)
      FROM fun_bal_headers_gt headers, fun_bal_results_gt results, gl_code_combinations cc
      WHERE headers.group_id = results.group_id
      AND headers.status = 'OK'
      AND results.ccid = cc.code_combination_id(+)
      AND (results.ccid < 0
                OR results.ccid IS NULL -- NULL case should not happen, but just in case
                OR NOT (cc.detail_posting_allowed_flag = 'Y'
                              AND cc.enabled_flag = 'Y'
                              AND cc.summary_flag = 'N'
							  AND nvl(cc.reference3, 'N') = 'N'
                              AND cc.template_id IS NULL
                              AND (TRUNC(headers.gl_date) BETWEEN TRUNC(NVL(cc.start_date_active, headers.gl_date))
                              AND TRUNC(NVL(cc.end_date_active, headers.gl_date)))));

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.get_ccid_concat_disp.end', 'end');
  END IF;

     UPDATE fun_bal_headers_gt headers
     SET STATUS = 'ERROR'
     WHERE EXISTS (SELECT 'Invalid CCID error'
                               FROM FUN_BAL_ERRORS_GT errors
                               WHERE headers.group_id =  errors.group_id
                                    AND error_code IN ('FUN_INTRA_CC_NOT_VALID',
                                                                  'FUN_INTRA_CC_NOT_CREATED',
                                                                  'FUN_INTRA_CC_NOT_ACTIVE'));


     DELETE FROM fun_bal_results_gt results
     WHERE EXISTS (SELECT group_id
                               FROM fun_bal_headers_gt headers
                               WHERE headers.status = 'ERROR'
                               AND results.group_id = headers.group_id);

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.do_intra_bal.end', 'end');
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;
END do_intra_bal;


PROCEDURE journal_balancing
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 ,
  p_validation_level IN NUMBER,
  p_debug IN VARCHAR2 ,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_product_code IN VARCHAR2 -- Valid values are GL and SLA for this release
) IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'JOURNAL_BALANCING';
  l_api_version   CONSTANT NUMBER         := 1.0;
  l_return_status VARCHAR2(1);

BEGIN

 -- variable p_validation_level is not used .
  g_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.journal_balancing.begin', 'begin');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
     FND_MSG_PUB.initialize;
   END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- API body
  g_product_code := p_product_code;
  g_debug := nvl(p_debug,FND_API.G_FALSE);
  l_return_status := do_init;

  l_return_status := do_inter_bal;

  l_return_status := do_intra_bal;

  x_return_status := do_finalize;

  -- End of API body.
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  IF (FND_LOG.LEVEL_PROCEDURE >= g_debug_level) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'fun.plsql.fun_bal_pkg.journal_balancing.end', 'end');
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       do_save_in_error;
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'fun.plsql.fun_bal_pkg.journal_balancing.error', SUBSTR(SQLERRM,1, 4000));
       END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       do_save_in_error;
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'fun.plsql.fun_bal_pkg.journal_balancing.unexpected_error_norm', SUBSTR(SQLCODE ||
                                                                                                                                                        ' : ' || SQLERRM,1, 4000));
       END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
       do_save_in_error;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF (FND_LOG.LEVEL_ERROR>= g_debug_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'fun.plsql.fun_bal_pkg.journal_balancing.unexpected_error_others', SUBSTR(SQLCODE ||
                                                                                                                                                             ' : ' || SQLERRM,1, 4000));
       END IF;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
END journal_balancing;



END FUN_BAL_PKG;


/
