--------------------------------------------------------
--  DDL for Package Body HR_TKPROF_PLUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TKPROF_PLUS" AS
/* $Header: hrtkplus.pkb 115.3 2004/01/20 09:49:47 mroberts noship $ */
  -- define global vars
  g_version                    CONSTANT VARCHAR2(30) := '115.1'; -- version
  -- define global log variables
  g_log_file_extention         CONSTANT VARCHAR2(4) := '.cbo'; -- log file extension
  g_script_file_extention      CONSTANT VARCHAR2(4) := '.sql'; -- script file extension
  g_log_level                           PLS_INTEGER; -- log level
  g_log_file                            UTL_FILE.file_type; -- log file handle
  g_log_filename                        VARCHAR2(120); -- log filename
  g_script_filename                     VARCHAR2(120); -- script filename
  g_filename                            VARCHAR2(120); -- tkprof filename
  g_script_file                         UTL_FILE.file_type; -- script file handle
  g_log_line_separator         CONSTANT VARCHAR2(80) := LPAD('-',78,'-');
  -- define global table structures
  g_table_counter                       BINARY_INTEGER;
  g_backup_stats                        VARCHAR2(1);
  g_script_stats                        VARCHAR2(1);
  TYPE g_table_owner_table_type IS TABLE OF VARCHAR2(61) INDEX BY BINARY_INTEGER;
  TYPE g_table_owner_status_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  g_table_owner_table                   g_table_owner_table_type;
  g_table_owner_status_table            g_table_owner_status_type;
  g_table_name_table                    g_table_owner_table_type;
  --
  g_stat_table_name            CONSTANT VARCHAR2(30) := 'FND_STATTAB';
  g_explain_sql_counter                 PLS_INTEGER;
  g_explained_sql_counter               PLS_INTEGER;
  g_not_explained_sql_counter           PLS_INTEGER;
  g_explain_sql_statement_text CONSTANT VARCHAR2(10) := 'expstmtid:';
  g_explain_sql_text_header    CONSTANT VARCHAR(50)  := 'EXPLAIN PLAN SET '||
                                                        'STATEMENT_ID=''' ||
                                                        g_explain_sql_statement_text;
  g_explain_table                       VARCHAR2(61);
  g_sql_text                            VARCHAR2(32767);
  g_error_text                          VARCHAR2(2000);
  g_error_std_text             CONSTANT VARCHAR2(45) := 'Unexpected internal error has '||
                                                        'occurred in ';
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   write_log
  -- description:
  --   write out the log text (p_text) to the log file if tge log level has been set at the
  --   correct level
  -- ---------------------------------------------------------------------------------------
  PROCEDURE write_log(p_text  IN VARCHAR2           DEFAULT NULL
                     ,p_level IN PLS_INTEGER        DEFAULT 1
                     ,p_file  IN UTL_FILE.file_type DEFAULT g_log_file) IS
  BEGIN
    IF g_log_level > 0 AND p_level <= g_log_level THEN
      IF p_text IS NULL THEN
        -- output new line
        UTL_FILE.new_line(file => p_file, lines => 1);
      ELSE
        -- output the log line
        UTL_FILE.put_line(file => p_file, buffer => p_text);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'write_log: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END write_log;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   delete_all_expstms
  -- description:
  --   deletes previously explained SQL stmts for the tkrpof file and commits if set.
  -- ---------------------------------------------------------------------------------------
  PROCEDURE delete_all_expstms(p_commit IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    -- delete all the explan plans which have been previously generated
    -- by this utility
    EXECUTE IMMEDIATE 'DELETE FROM '||g_explain_table||' pt WHERE pt.statement_id LIKE '''||
                       g_explain_sql_statement_text || '%''';
    -- check to see if the delete is to be committed
    IF p_commit THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'delete_all_expstms: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END delete_all_expstms;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   export_table_stats
  -- description:
  --   get a list of unique table names from the execution plans for the trace file and
  --   exports the stats
  -- ---------------------------------------------------------------------------------------
  PROCEDURE export_table_stats(p_statid IN VARCHAR2 DEFAULT NULL) IS
    --
    TYPE          l_cursor_type IS REF CURSOR;
    l_cursor      l_cursor_type;
    l_table_owner VARCHAR2(30);
    l_table_name  VARCHAR2(30);
    --
  BEGIN
    IF g_backup_stats = 'Y' THEN
      -- before we export the stats to the stats table
      -- delete any previously created stats for the same
      -- statid
      EXECUTE IMMEDIATE 'DELETE FROM '||
                        g_stat_table_name||
                        ' st WHERE st.statid = :statid' USING p_statid;
    END IF;
    -- open the dynamic cursor
    OPEN l_cursor FOR
      'SELECT   di.table_owner table_owner, '||
               'di.table_name  table_name '||
      'FROM    '||g_explain_table||' pt, dba_indexes di '||
      'WHERE    pt.statement_id LIKE ''exp%'' '||
      'AND      pt.object_owner NOT IN (''SYS'',''SYSTEM'') '||
      'AND      pt.object_type IN (''UNIQUE'',''NON-UNIQUE'') '||
      'AND      di.index_name = pt.object_name '||
      'AND      di.owner = pt.object_owner '||
      'UNION '||
      'SELECT   dt.owner       table_owner, '||
               'dt.table_name  table_name '||
      'FROM    '||g_explain_table||' pt, dba_tables dt '||
      'WHERE    pt.statement_id LIKE ''exp%'' '||
      'AND      pt.object_type IS NULL '||
      'AND      dt.table_name = pt.object_name '||
      'AND      dt.owner = pt.object_owner '||
      'AND      pt.object_owner NOT IN (''SYS'',''SYSTEM'') '||
      'ORDER BY 1,2';
    LOOP
      -- fetch each row
      FETCH l_cursor INTO l_table_owner, l_table_name;
      EXIT WHEN l_cursor%NOTFOUND;
      -- increment the table counter
      g_table_counter := g_table_counter + 1;
      -- add the owner,table name
      g_table_owner_table(g_table_counter) := l_table_owner;
      g_table_name_table(g_table_counter) := l_table_name;
      -- are the stats to be backed up?
      IF g_backup_stats = 'Y' THEN
        --
        BEGIN
          -- backup the stats for the table
          fnd_stats.backup_table_stats
            (schemaname => l_table_owner,
             tabname => l_table_name,
             statid   => p_statid,
             cascade  => TRUE);
           -- set the table status to Y
           g_table_owner_status_table(g_table_counter) := 'Y';
        EXCEPTION
          WHEN OTHERS THEN
            -- an error has occurred during gathering the stats so set the
            -- status to N but continue processing
            g_table_owner_status_table(g_table_counter) := 'N';
        END;
      ELSE
        -- set status to N
        g_table_owner_status_table(g_table_counter) := 'N';
      END IF;
    END LOOP;
    CLOSE l_cursor;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_cursor%ISOPEN THEN
        CLOSE l_cursor;
      END IF;
      -- an internal error has occurred
      g_error_text := g_error_std_text||'export_table_stats: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END export_table_stats;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   check_explain_table
  -- description:
  --   dynamically checks to see if the plan table exists
  -- ---------------------------------------------------------------------------------------
  PROCEDURE check_explain_table IS
    l_dummy NUMBER(1);
  BEGIN
    EXECUTE IMMEDIATE 'SELECT 1 FROM SYS.DUAL WHERE EXISTS (SELECT 1 FROM '||
                       g_explain_table||')' INTO l_dummy;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- the plan table is empty but exists so ignore error
      NULL;
    WHEN OTHERS THEN
      -- plan table does exist so error
      g_error_text := 'The Plan Table '||g_explain_table||
                      ' does not exist - please create it';
      RAISE;
  END check_explain_table;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   explain_sql
  -- description:
  --   dynamically explains the sql text
  -- ---------------------------------------------------------------------------------------
  PROCEDURE explain_sql(p_sql_text IN VARCHAR2) IS
    --
    TYPE l_cursor_type IS REF CURSOR;
    l_cursor   l_cursor_type;
    l_exp_line VARCHAR2(32767);
    --
  BEGIN
    write_log(p_level => 1);
    -- build the explain sql statement header in the following format:
    -- EXPLAIN PLAN SET STATEMENT_ID='expstmtid:<g_explain_sql_counter>' FOR <p_sql_text>
    -- and execute immediately
    -- execute the sql statment to be explained
    EXECUTE IMMEDIATE g_explain_sql_text_header ||g_explain_sql_counter|| ''' INTO '||
                      g_explain_table||' FOR ' ||p_sql_text;
    -- increment the explained counter
    g_explained_sql_counter  := g_explained_sql_counter + 1;
    -- output the explain plan to the log file
    write_log(p_text => 'Explain statement_id = '||
                        g_explain_sql_statement_text||
                        g_explain_sql_counter,
              p_level => 1);
    write_log(p_level => 1);
    -- write out the explain plan
    OPEN l_cursor FOR 'SELECT LPAD('' '',2*(LEVEL-1))||operation||'||
                      'DECODE(options, NULL,'''','' ''||'||
                      'options)||'' ''||object_name||''   (cost=''||'||
                      'cost||'', card=''||cardinality||'', bytes=''||bytes'||
                      '||'')'' exp_line '||
                      'FROM '||g_explain_table||' START WITH id=0 AND '||
                      'statement_id = :c_statement_id '||
                      'CONNECT BY PRIOR id = parent_id '||
                      'AND PRIOR NVL(statement_id, '' '') = NVL(statement_id, '' '') '||
                      'AND PRIOR timestamp <= timestamp'
                      USING g_explain_sql_statement_text||g_explain_sql_counter;
    LOOP
      -- fetch each explain line
      FETCH l_cursor INTO l_exp_line;
      EXIT WHEN l_cursor%NOTFOUND;
      -- write out the execution line
      write_log(p_text => l_exp_line, p_level => 1);
    END LOOP;
    CLOSE l_cursor;
    write_log(p_level => 1);
  EXCEPTION
    -- if an error has occurred during explaining, ignore it, setting the
    -- explained status to false
    WHEN OTHERS THEN
      IF l_cursor%ISOPEN THEN
        CLOSE l_cursor;
      END IF;
      write_log(p_text => 'Error explaining:'||TO_CHAR(SQLCODE)||', '||SQLERRM,p_level => 1);
      write_log(p_level => 1);
      g_not_explained_sql_counter := g_not_explained_sql_counter + 1;
  END explain_sql;
  -- ---------------------------------------------------------------------------------------
  -- function:
  --   get_line
  -- description:
  --   gets a line from the file
  -- ---------------------------------------------------------------------------------------
  FUNCTION get_line(
    p_file IN UTL_FILE.file_type)
    RETURN VARCHAR2 IS
    l_buffer VARCHAR2(32767);
  BEGIN
    -- get a line from the file
    UTL_FILE.get_line(file => p_file, buffer => l_buffer);
    RETURN (l_buffer);
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'get_line: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
  END get_line;
  -- ---------------------------------------------------------------------------------------
  -- function:
  --   sql_reserved_word
  -- description:
  --   determines if a sql reserve word is at position 1 in the specified string
  -- ---------------------------------------------------------------------------------------
  FUNCTION sql_reserved_word(
    p_text IN VARCHAR2)
    RETURN BOOLEAN IS
    l_text VARCHAR2(32767) := UPPER(p_text);
  BEGIN
    IF    INSTR(l_text, 'SELECT') = 1
       OR INSTR(l_text, 'INSERT') = 1
       OR INSTR(l_text, 'UPDATE') = 1
       OR INSTR(l_text, 'DELETE') = 1 THEN
      RETURN (TRUE);
    END IF;
    RETURN (FALSE);
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'sql_reserved_word: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
  END sql_reserved_word;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   process_tkprof_file
  -- description:
  --   processes the tkprof file extracting out the SQL stmts.
  -- ---------------------------------------------------------------------------------------
  PROCEDURE process_tkprof_file(
    p_file  IN UTL_FILE.file_type,
    p_limit IN PLS_INTEGER) IS
    --
    l_tkprof_line VARCHAR2(32767);
    l_sql_found   BOOLEAN         := FALSE;
    l_sql_text    VARCHAR2(32767);
  --
  BEGIN
    -- process TKPROF file
    <<get_lines>>
    LOOP
      BEGIN
        -- get next line from tkprof
        l_tkprof_line  := get_line(p_file);
        -- check to see if line is null and sql not found
        IF     l_tkprof_line IS NULL
           AND (NOT l_sql_found) THEN
          -- get next line to see if a SQL stmt reserved word exists
          l_tkprof_line  := get_line(p_file);
          IF sql_reserved_word(p_text => l_tkprof_line) THEN
            -- start of sql stmt has been found in the TKPROF file
            l_sql_found            := TRUE;
            l_sql_text             := l_tkprof_line;
            -- incremenet the explain counter
            g_explain_sql_counter := g_explain_sql_counter + 1;
            -- write out the SQL stmt to the log file
            write_log(p_text => g_log_line_separator, p_level => 1);
            write_log(p_text => 'SQL stmt:'||g_explain_sql_counter, p_level => 1);
            write_log(p_level => 1);
            write_log(p_text => l_tkprof_line, p_level => 1);
          END IF;
        -- check to see if the sql stmt is terminated
        ELSIF     l_tkprof_line IS NULL
              AND l_sql_found THEN
          -- sql stmt terminated
          l_sql_found := FALSE;
          -- explain the SQL stmt
          explain_sql(p_sql_text => l_sql_text);
          -- check to see if the limit has been reached
          IF g_explain_sql_counter = p_limit THEN
            -- limit reached, terminate the processing
            EXIT get_lines;
          END IF;
        -- check to see if we are processing a sql stmt line
        ELSIF     l_tkprof_line IS NOT NULL
              AND l_sql_found THEN
          l_sql_text  := l_sql_text || ' ' || l_tkprof_line;
          write_log(p_text => l_tkprof_line, p_level => 1);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          EXIT get_lines;
      END;
    END LOOP;
  END process_tkprof_file;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   show_header
  -- description:
  --   writes out to the log file if the log level is greater or equal to 1 the log header
  --   information which includes CBO INIT.ora parameter values
  -- ---------------------------------------------------------------------------------------
  PROCEDURE show_header
              (p_location  IN VARCHAR2,
               p_filename  IN VARCHAR2,
               p_limit     IN PLS_INTEGER) IS
    --
    TYPE     l_cursor_type IS REF CURSOR;
    l_cursor l_cursor_type;
    l_name   VARCHAR2(64);
    l_value  VARCHAR2(512);
    l_dvalue VARCHAR2(512);
    l_banner VARCHAR2(64);
    l_run_date VARCHAR2(22) := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS');
    --
  BEGIN
    IF g_log_level >= 1 THEN
      -- output the log file header info
      write_log(g_log_line_separator);
      write_log;
      write_log(p_text => 'TKPROF PLUS');
      write_log(p_text => '-----------');
      write_log(p_text => 'tkprof plus version       : '||g_version);
      write_log(p_text => 'tkprof file location      : '||p_location);
      write_log(p_text => 'tkprof file to process    : '||p_filename);
      write_log(p_text => 'No of SQL Stmts to process: '||NVL(TO_CHAR(p_limit),'ALL'));
      write_log(p_text => 'Backup stats?             : '||NVL(g_backup_stats,'N'));
      write_log(p_text => 'Script stats?             : '||NVL(g_script_stats,'N'));
      IF g_script_stats = 'Y' THEN
        write_log(p_text => 'Script file               : '||g_script_filename);
      END IF;
      write_log(p_text => 'Logging level             : '||g_log_level);
      write_log(p_text => 'Log file                  : '||g_log_filename);
      write_log(p_text => 'Date and Time of run      : '||l_run_date);
      --
      write_log;
      write_log(p_text => 'Version numbers of core library components in the Oracle server');
      write_log(p_text => '---------------------------------------------------------------');
      -- use native dynamic SQL because the USER may not have access to V$VERSION table
      BEGIN
        OPEN l_cursor FOR 'SELECT banner FROM v$version';
        LOOP
          -- fetch the version info
          FETCH l_cursor INTO l_banner;
          EXIT WHEN l_cursor%NOTFOUND;
          -- write out the version info
          write_log(p_text => l_banner);
        END LOOP;
        CLOSE l_cursor;
      EXCEPTION
        WHEN OTHERS THEN
          -- user doesn't have access to the v$version table
          write_log(p_text => 'Version information not available');
          IF l_cursor%ISOPEN THEN
            CLOSE l_cursor;
          END IF;
      END;
      write_log;
      --
      write_log(p_text => 'CBO INIT.ora parameters');
      write_log(p_text => '-----------------------');
      -- use native dynamic SQL because PL/SQL does not support the use of sub-query functionality
      -- in a select list
      OPEN l_cursor FOR
      'SELECT name pname,'||
            'value pvalue'||
           ',decode(name,'||
             '''_sort_elimination_cost_ratio'', decode(value,''5'',''OK'',''RECOMMEND => 5''),'||
             '''_optimizer_mode_force'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_fast_full_scan_enabled'', decode(value,''FALSE'',''OK'', ''RECOMMEND => FALSE''),'||
             '''_ordered_nested_loop'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_complex_view_merging'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_push_join_predicate'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_use_column_stats_for_function'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_push_join_union_view'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_like_with_bind_as_equality'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_or_expand_nvl_predicate'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_table_scan_cost_plus_one'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''_optimizer_undo_changes'', decode(value,''FALSE'',''OK'', ''RECOMMEND => FALSE''),'||
             '''db_file_multiblock_read_count'', decode(value,''8'',''OK'', ''RECOMMEND => 8''),'||
             '''optimizer_max_permutations'', decode(value,''79000'',''OK'', ''RECOMMEND => 79000''),'||
             '''optimizer_mode'', decode(value,''CHOOSE'',''OK'', ''RECOMMEND => CHOOSE''),'||
             '''optimizer_percent_parallel'', decode(value,''0'',''OK'', ''RECOMMEND => 0''),'||
             '''optimizer_features_enable'', decode(value,''8.1.6'',''OK'', ''RECOMMEND => 8.1.6''),'||
             '''query_rewrite_enabled'', decode(value,''TRUE'',''OK'', ''RECOMMEND => TRUE''),'||
             '''compatible'', decode(value,''8.1.6'',''OK'', ''RECOMMEND => 8.1.6''),'||
             '''optimizer_index_caching'', decode(value,''0'',''OK'', ''RECOMMEND => 0''),'||
             '''optimizer_index_cost_adj'', decode(value,''100'',''OK'', ''RECOMMEND => 100''),'||
             '''hash_area_size'', DECODE((SELECT TO_CHAR(TO_NUMBER(v1.value) * 2) '||
                                      'FROM   v$parameter v1 '||
                                      'WHERE  v1.name = ''sort_area_size''),'||
                                      'value,''OK'',''RECOMMEND => (2*sort area size)''),'||
             '''sort_area_size'', DECODE((SELECT  ''Y'' '||
                                      'FROM    SYS.DUAL '||
                                      'WHERE   TO_NUMBER(value) '||
                                      'BETWEEN 256000 AND 2000000), '||
                                      '''Y'',''OK'',''RECOMMEND => ( >= 256k <= 2M)''), '||
             ''' '') pdvalue '||
      'FROM   v$parameter '||
      'WHERE  name IN (''_sort_elimination_cost_ratio'','||
                      '''_optimizer_mode_force'','||
                      '''_fast_full_scan_enabled'','||
                      '''_ordered_nested_loop'','||
                      '''_complex_view_merging'','||
                      '''_push_join_predicate'','||
                      '''_use_column_stats_for_function'','||
                      '''_push_join_union_view'','||
                      '''_like_with_bind_as_equality'','||
                      '''_or_expand_nvl_predicate'','||
                      '''_table_scan_cost_plus_one'','||
                      '''_optimizer_undo_changes'','||
                      '''db_file_multiblock_read_count'','||
                      '''optimizer_max_permutations'','||
                      '''optimizer_mode'','||
                      '''optimizer_percent_parallel'','||
                      '''optimizer_features_enable'','||
                      '''query_rewrite_enabled'','||
                      '''compatible'','||
                      '''db_block_size'','||
                      '''optimizer_index_caching'','||
                      '''optimizer_index_cost_adj'','||
                      '''timed_statistics'','||
                      '''sort_area_size'','||
                      '''sort_multi_block_read_count'','||
                      '''hash_join_enabled'','||
                      '''hash_area_size'')'||
      ' ORDER BY 1';
      LOOP
        -- fetch each INIT.ora parameter
        FETCH l_cursor INTO l_name,l_value,l_dvalue;
        EXIT WHEN l_cursor%NOTFOUND;
        -- write out the INIT.ora parameter
        write_log(RPAD(l_name,30)||RPAD(l_value,15)||l_dvalue);
      END LOOP;
      CLOSE l_cursor;
      write_log;
      --
      IF g_script_stats = 'Y' AND g_log_level = 2 THEN
        write_log(p_text  =>'DECLARE'
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  =>'  -- This anonymous PL/SQL block has been generated from '||
                            'HR_TKPROF_PLUS'
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  =>'  -- and will import table, column and index statistics '||
                            'into the '||g_stat_table_name
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  =>'  -- table with the statid of '||g_filename
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  =>'  -- The statistics where gathered on '||l_run_date
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  => '  l_st   VARCHAR2(30) := '''||g_stat_table_name||'''; -- stat table name'
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  => '  l_stid VARCHAR2(30) := '''||g_filename||'''; -- statid'
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  => 'BEGIN'
                 ,p_level => 2
                 ,p_file => g_script_file);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'show_header: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      -- check to ensure the cursor is closed
      IF l_cursor%ISOPEN THEN
        CLOSE l_cursor;
      END IF;
  END show_header;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   show_stats
  -- description:
  --   writes out to the log file the table/column and index stats if the log level is 2.
  -- ---------------------------------------------------------------------------------------
  PROCEDURE show_stats IS
    --
    TYPE          l_cursor_type IS REF CURSOR;
    l_cursor      l_cursor_type;
    l_column_name VARCHAR2(30);
    l_nd          NUMBER;
    l_es          NUMBER;
    l_ec          NUMBER;
    l_nn          NUMBER;
    l_d           NUMBER;
    l_h           VARCHAR2(1);
    l_acl         NUMBER;
    --
    CURSOR csr_table(c_owner VARCHAR2, c_table_name VARCHAR2) IS
      SELECT db.table_name                       table_name,
             TO_CHAR(db.num_rows,999999999999)   num_rows,
             TO_CHAR(db.blocks,999999)           blocks,
             TO_CHAR(db.empty_blocks,9999999999) empty_blocks,
             TO_CHAR(db.avg_row_len,99999999999) arl,
             TO_CHAR(db.chain_cnt,9999999)       chcnt,
             TO_CHAR(db.last_analyzed, 'DD-MON-YYYY HH24:MI:SS') la
      FROM   dba_tables db
      WHERE  db.table_name = c_table_name
      AND    db.owner = c_owner;
   --
   CURSOR csr_index(c_owner VARCHAR2, c_table_name VARCHAR2) IS
     SELECT di.index_name                 index_name,
            TO_CHAR(di.num_rows,9999999999) num_rows,
            TO_CHAR(di.distinct_keys,9999999999) dk,
            TO_CHAR((1/di.distinct_keys),9.99999999) s,
            TO_CHAR((di.num_rows/di.distinct_keys),9999999999) ec,
            TO_CHAR(di.leaf_blocks,999999) lb,
            TO_CHAR(di.clustering_factor,9999999) cf,
            TO_CHAR(di.blevel,999999) bl,
            TO_CHAR(di.last_analyzed, 'DD/MM/YYYY HH24:MI:SS') la,
            di.avg_leaf_blocks_per_key albpk,
            di.avg_data_blocks_per_key adbpk
     FROM   dba_indexes di
     WHERE  di.table_name = c_table_name
     AND    di.table_owner = c_owner
     AND    di.owner = c_owner
     AND    di.num_rows > 0
     ORDER BY DECODE(di.uniqueness,'UNIQUE',1,2), 1;
   --
   CURSOR csr_index_cols(c_owner VARCHAR2, c_table_name VARCHAR2) IS
     SELECT c.index_name index_name,
            i.uniqueness uniqueness,
            SUBSTR(c.column_name,1,30) column_name,
            c.column_position column_position
     FROM   dba_ind_columns c,
            dba_indexes     i
     WHERE  i.table_name = c_table_name
     AND    i.table_owner = c_owner
     AND    i.owner       = c_owner
     AND    c.index_name  = i.index_name
     AND    c.index_owner = i.owner
     ORDER BY c.table_name,
              DECODE(i.uniqueness,'UNIQUE',1,2),
              c.index_name,
              c.column_position ASC;
    --
  BEGIN
    IF g_log_level = 2 THEN
      FOR i IN g_table_owner_table.FIRST..g_table_owner_table.LAST LOOP
        -- write out the table stats
        write_log(p_level => 2);
        write_log(LPAD('=',130,'=')
                 ,p_level => 2);
        write_log(p_level => 2);
        write_log(p_text => RPAD('Table Name',30)||
                            LPAD('Num Rows',13)||
                            LPAD('Blocks',7)||
                            LPAD('Empty Blks',11)||
                            LPAD('Avg Row Len',13)||
                            LPAD('Chained',8)||
                            LPAD('Last Analyzed',21)
                 ,p_level => 2);
        write_log(p_text => RPAD('-',30,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-',6,'-')||' '||
                            LPAD('-',10,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-',7,'-')||' '||
                            LPAD('-',20,'-')
                 ,p_level => 2);
        -- write the table stats out
        -- n.b: used a for loop even though only returning one row to
        --      save on var usage declaration (being lazy really!)
        FOR j IN csr_table(g_table_owner_table(i),g_table_name_table(i)) LOOP
          write_log(p_text => RPAD(j.table_name,30)||
                              LPAD(j.num_rows,13)||
                              LPAD(j.blocks,7)||
                              LPAD(j.empty_blocks,11)||
                              LPAD(j.arl,13)||
                              LPAD(j.chcnt,8)||' '||
                              j.la
                   ,p_level => 2);
          IF g_script_stats = 'Y' THEN
            write_log(p_text  => '  -- set the table, column and index stats for table '||j.table_name
                     ,p_level => 2
                     ,p_file  => g_script_file);
            write_log(p_text  => '  DBMS_STATS.SET_TABLE_STATS'
                     ,p_level => 2
                     ,p_file  => g_script_file);
            write_log(p_text  => '    (ownname=>'''||g_table_owner_table(i)||
                                 ''',tabname=>'''||j.table_name||
                                 ''',stattab=>l_st'||
                                 ',statid=>l_stid'||
                                 ',numrows=>'||TO_CHAR(TO_NUMBER(j.num_rows))||
                                 ',numblks=>'||TO_CHAR(TO_NUMBER(j.blocks))||
                                 ',avgrlen=>'||TO_CHAR(TO_NUMBER(j.arl))||');'
                     ,p_level => 2
                     ,p_file => g_script_file);
          END IF;
        END LOOP;
        -- write out column stats header
        write_log(p_level => 2);
        write_log(p_text => RPAD('Column Name',30)||
                            LPAD('NDV',13)||
                            LPAD('1/NDV',11)||
                            LPAD('Cardinality',12)||
                            LPAD('Num Of Nulls',13)||
                            LPAD('Density',8)||
                            LPAD('HGram',6)
                 ,p_level => 2);
        write_log(p_text => RPAD('-',30,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-',10,'-')||' '||
                            LPAD('-',11,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-', 7,'-')||' '||
                            LPAD('-', 5,'-')
                 ,p_level => 2);
        -- write the column stats out
        -- n.b. used native dynamic SQL to get around the sub-query in the select column
        --      list which is not supported directly in PL/SQL
        OPEN l_cursor FOR
        'SELECT   dc.column_name column_name,'||
        '         TO_CHAR(dc.num_distinct, 999999999999) nd,'||
        '         TO_CHAR(DECODE(NVL(dc.num_distinct,0), 0, 0, 1 / dc.num_distinct),'||
        '         ''9.999999999'') es,'||
        '         TO_CHAR(DECODE(NVL(dc.num_distinct,0), 0, 0, CEIL(dt.num_rows/dc.num_distinct)),'||
        '         ''99999999999'') ec,'||
        '         TO_CHAR(dc.num_nulls, 999999999999) nn,'||
        '         TO_CHAR(dc.density,''9.99999'') d,'||
        '         dc.avg_col_len acl,'||
        '         DECODE((SELECT 1'||
        '                 FROM   dba_histograms dh'||
        '                 WHERE  dh.owner = dt.owner'||
        '                 AND    dh.table_name = dt.table_name'||
        '                 AND    dh.column_name = dc.column_name'||
        '                 AND    dh.endpoint_number NOT IN (0,1)'||
        '                 AND    ROWNUM < 2),1,''Y'',''N'') h '||
        'FROM     dba_tab_columns dc, dba_tables dt '||
        'WHERE    dc.table_name = dt.table_name '||
        'AND      dc.num_distinct > 0 '||
        'AND      dt.table_name = :c_table_name '||
        'AND      dt.owner = :c_owner '||
        'AND      dc.owner = dt.owner '||
        'ORDER BY dc.column_id' USING g_table_name_table(i),g_table_owner_table(i);
        --
        LOOP
          -- fetch each COLUMN stat row
          FETCH l_cursor INTO l_column_name,l_nd,l_es,l_ec,l_nn,l_d,l_acl,l_h;
          EXIT WHEN l_cursor%NOTFOUND;
          -- write out each col stats
          write_log(p_text => RPAD(l_column_name,30)||
                              LPAD(l_nd,13)||
                              LPAD(l_es,11)||
                              LPAD(l_ec,12)||
                              LPAD(l_nn,13)||
                              LPAD(l_d,8)||
                              LPAD(l_h, 6)
                     ,p_level => 2);
          --
          IF g_script_stats = 'Y' THEN
            write_log(p_text  => '  DBMS_STATS.SET_COLUMN_STATS'
                     ,p_level => 2
                     ,p_file  => g_script_file);
            write_log(p_text  => '    (ownname=>'''||g_table_owner_table(i)||
                                 ''',tabname=>'''||g_table_name_table(i)||
                                 ''',colname=>'''||l_column_name||
                                 ''',stattab=>l_st'||
                                 ',statid=>l_stid'||
                                 ',distcnt=>'||TO_CHAR(TO_NUMBER(l_nd))||
                                 ',density=>'||TO_CHAR(TO_NUMBER(l_d))||
                                 ',nullcnt=>'||TO_CHAR(TO_NUMBER(l_nn))||
                                 ',avgclen=>'||TO_CHAR(l_acl)||');'
                     ,p_level => 2
                     ,p_file => g_script_file);
          END IF;
        END LOOP;
        CLOSE l_cursor;
        -- write out index stats header
        write_log(p_level => 2);
        write_log(p_text => RPAD('Index Name',30)||
                            LPAD('Num Rows',13)||
                            LPAD('Unique Keys',13)||
                            LPAD('1/NDK',11)||
                            LPAD('Cardinality',12)||
                            LPAD('LBlks',13)||
                            LPAD('ClustF',8)||
                            LPAD('Levels',7)||
                            LPAD('Last Analyzed',21)
                 ,p_level => 2);
        write_log(p_text => RPAD('-',30,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-',10,'-')||' '||
                            LPAD('-',11,'-')||' '||
                            LPAD('-',12,'-')||' '||
                            LPAD('-',7,'-')||' '||
                            LPAD('-',6,'-')||' '||
                            LPAD('-',20,'-')
                 ,p_level => 2);
        -- write out index stats
        FOR j IN csr_index(g_table_owner_table(i),g_table_name_table(i)) LOOP
          write_log(p_text => RPAD(j.index_name,30)||
                              LPAD(j.num_rows,13)||
                              LPAD(j.dk,13)||
                              LPAD(j.s,11)||
                              LPAD(j.ec,12)||
                              LPAD(j.lb,13)||
                              LPAD(j.cf,8)||
                              LPAD(j.bl,7)||' '||
                              j.la
                   ,p_level => 2);

          IF g_script_stats = 'Y' THEN
            write_log(p_text  => '  DBMS_STATS.SET_INDEX_STATS'
                     ,p_level => 2
                     ,p_file  => g_script_file);
            write_log(p_text  => '    (ownname=>'''||g_table_owner_table(i)||
                                 ''',indname=>'''||j.index_name||
                                 ''',stattab=>l_st'||
                                 ',statid=>l_stid'||
                                 ',numrows=>'||TO_CHAR(TO_NUMBER(j.num_rows))||
                                 ',numlblks=>'||TO_CHAR(TO_NUMBER(j.lb))||
                                 ',numdist=>'||TO_CHAR(TO_NUMBER(j.dk))||
                                 ',avglblk=>'||TO_CHAR(j.albpk)||
                                 ',avgdblk=>'||TO_CHAR(j.adbpk)||
                                 ',clstfct=>'||TO_CHAR(TO_NUMBER(j.cf))||
                                 ',indlevel=>'||TO_CHAR(TO_NUMBER(j.bl))||');'
                     ,p_level => 2
                     ,p_file => g_script_file);
          END IF;
        END LOOP;
        -- write out index key information header
        write_log(p_level => 2);
        write_log(p_text => RPAD('Index Name',31)||
                            RPAD('Uniqueness',11)||
                            RPAD('Column Name',31)||
                            LPAD('Position',8)
                 ,p_level => 2);
        write_log(p_text => RPAD('-',30,'-')||' '||
                            RPAD('-',10,'-')||' '||
                            RPAD('-',30,'-')||' '||
                            LPAD('-',8,'-')
                 ,p_level => 2);
        -- write out index key information
        FOR j IN csr_index_cols(g_table_owner_table(i),g_table_name_table(i)) LOOP
          IF j.column_position = 1 THEN
            write_log(p_text => RPAD(j.index_name,31)||
                                RPAD(j.uniqueness,11)||
                                RPAD(j.column_name,31)||
                                LPAD(j.column_position,8)
                     ,p_level => 2);
          ELSE
            write_log(p_text => RPAD(' ',31)||
                                RPAD(' ',11)||
                                RPAD(j.column_name,31)||
                                LPAD(j.column_position,8)
                     ,p_level => 2);
          END IF;
        END LOOP;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'show_stats: '||
                           TO_CHAR(SQLCODE)||': '||SQLERRM;
      IF l_cursor%ISOPEN THEN
        CLOSE l_cursor;
      END IF;
      RAISE;
  END show_stats;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   show_summary
  -- description:
  --   writes out to the log file a summary if the log level is greater or equal to 1.
  -- ---------------------------------------------------------------------------------------
  PROCEDURE show_summary IS
  BEGIN
    IF g_log_level >= 1 THEN
      -- write summary info
      write_log;
      write_log(g_log_line_separator);
      write_log(p_text => 'SUMMARY');
      write_log(p_text => '-------');
      write_log(p_text => 'SQL stmts processed     : '||g_explain_sql_counter);
      write_log(p_text => 'SQL stmts explained     : '||g_explained_sql_counter);
      write_log(p_text => 'SQL stmts not explained : '||g_not_explained_sql_counter);
      IF g_explained_sql_counter > 0 THEN
        write_log(p_text => 'Stats been backed up?   : '||NVL(g_backup_stats,'N'));
        IF g_backup_stats = 'Y' THEN
          write_log(p_text => 'Stats backed up to table: '||g_stat_table_name);
          write_log(p_text => 'The statid is           : '||g_filename);
        END IF;
        write_log;
        write_log(p_text => 'Table/Column/Indexs stats backed up for');
        write_log(p_text => '---------------------------------------');
        FOR i in 1..g_table_counter LOOP
          write_log(RPAD(g_table_owner_table(i)||'.'||g_table_name_table(i),62)||
                    'backed up = '||g_table_owner_status_table(i));
        END LOOP;
        -- write out table index stats if level 2
        show_stats;
      ELSE
        write_log(p_text => 'Stats been backed up?   : N - no stats to back up');
      END IF;
      write_log;
      IF g_script_stats = 'Y' AND g_log_level = 2 THEN
        write_log(p_text  => 'END;'
                 ,p_level => 2
                 ,p_file  => g_script_file);
        write_log(p_text  => '/'
                 ,p_level => 2
                 ,p_file  => g_script_file);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'show_summary: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END show_summary;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   open_log_file
  -- description:
  --   if the log level has been set (e.g. greater than zero) then the log file is opened
  --   for writing. the log file location is the same as the TKPROF location. the log file
  --   name is the TKRPOF filename with an extra extention indentified by the global
  --   g_log_file_extention
  -- ---------------------------------------------------------------------------------------
  PROCEDURE open_log_file
     (p_location  IN VARCHAR2,
      p_filename  IN VARCHAR2,
      p_log_level IN PLS_INTEGER,
      p_limit     IN PLS_INTEGER) IS
    --
  BEGIN
    -- check and set the log level
    IF p_log_level > 0 AND p_log_level <= 2 THEN
      -- set the log filename
      g_log_filename := p_filename||g_log_file_extention;
      -- open the log file for writing
      g_log_file := UTL_FILE.fopen
                      (location     => p_location,
                       filename     => g_log_filename,
                       open_mode    => 'w',
                       max_linesize => 32767);
      -- set the global log level
      g_log_level := p_log_level;
      --
      IF g_script_stats = 'Y' AND p_log_level = 2 THEN
        g_script_filename := p_filename||g_script_file_extention;
        g_script_file := UTL_FILE.fopen
                           (location     => p_location,
                            filename     => g_script_filename,
                            open_mode    => 'w',
                            max_linesize => 32767);
      END IF;
      -- write out the log file header
      show_header
        (p_location  => p_location,
         p_filename  => p_filename,
         p_limit     => p_limit);
    ELSE
      g_log_level := 0;
    END IF;
  EXCEPTION
    WHEN UTL_FILE.invalid_path THEN
      g_error_text := 'The LOG location path is invalid';
      RAISE;
    WHEN UTL_FILE.invalid_mode THEN
      g_error_text := 'The LOG file was opened with an invalid mode';
      RAISE;
    WHEN UTL_FILE.invalid_operation THEN
      g_error_text := 'The LOG file was opened with an invalid operation';
      RAISE;
    WHEN OTHERS THEN
      g_log_level := 0;
      g_error_text := g_error_std_text||'open_log_file: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END open_log_file;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   close_log_file
  -- description:
  --   if the log level has been set (e.g. greater than zero) or the log file is open
  --   flush out the buffer and close the log file.
  -- ---------------------------------------------------------------------------------------
  PROCEDURE close_log_file IS
    l_file UTL_FILE.file_type := g_log_file;
  BEGIN
    IF g_log_level > 0 THEN
      -- write out the log summary
      show_summary;
      -- flush the buffer
      UTL_FILE.FFLUSH(file => l_file);
      -- close the opened log file
      UTL_FILE.fclose(file => l_file);
      IF g_script_stats = 'Y' AND g_log_level = 2 THEN
        l_file := g_script_file;
        -- flush the buffer
        UTL_FILE.FFLUSH(file => l_file);
        -- close the opened script file
        UTL_FILE.fclose(file => l_file);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'close_log_file: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END close_log_file;
  -- ---------------------------------------------------------------------------------------
  -- function:
  --   open_tkprof_file
  -- description:
  --   open the specified tkprof file returning the tkprof file handle.
  -- ---------------------------------------------------------------------------------------
  FUNCTION open_tkprof_file(
    p_location IN VARCHAR2,
    p_filename IN VARCHAR2)
    RETURN UTL_FILE.file_type IS
    --
    l_location_null EXCEPTION;
    l_filename_null EXCEPTION;
    --
  BEGIN
    IF p_location IS NULL THEN
      RAISE l_location_null;
    ELSIF p_filename IS NULL THEN
      RAISE l_filename_null;
    END IF;
    -- open the tkprof file for reading and return the file type
    -- handle
    RETURN (
             UTL_FILE.fopen(
               location     => p_location,
               filename     => p_filename,
               open_mode    => 'r',
               max_linesize => 32767));
  EXCEPTION
    WHEN l_location_null THEN
      g_error_text := 'The TKPROF location path is required and cannot be NULL';
      RAISE;
    WHEN l_filename_null THEN
      g_error_text := 'The TKPROF filename is required and cannot be NULL';
      RAISE;
    WHEN UTL_FILE.invalid_path THEN
      g_error_text := 'The TKPROF location path is invalid';
      RAISE;
    WHEN UTL_FILE.invalid_mode THEN
      g_error_text := 'The TKPROF file was opened with an invalid mode';
      RAISE;
    WHEN UTL_FILE.invalid_operation THEN
      g_error_text := 'The TKRPOF file was opened with an invalid operation';
      RAISE;
    WHEN OTHERS THEN
      g_error_text := g_error_std_text||'open_tkprof_file: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END open_tkprof_file;
  -- ---------------------------------------------------------------------------------------
  -- procedure:
  --   close_tkprof_file
  -- description:
  --   close the tkprof file
  -- ---------------------------------------------------------------------------------------
  PROCEDURE close_tkprof_file(
    p_file IN UTL_FILE.file_type) IS
    l_file UTL_FILE.file_type := p_file;
  BEGIN
    IF UTL_FILE.IS_OPEN(l_file) THEN
      -- close the opened tkprof file
      UTL_FILE.fclose(file => l_file);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- an internal error has occurred
      g_error_text := g_error_std_text||'close_tkprof_file: '||
                      TO_CHAR(SQLCODE)||': '||SQLERRM;
      RAISE;
  END close_tkprof_file;
  --
  PROCEDURE run(
    p_location      IN VARCHAR2,
    p_filename      IN VARCHAR2,
    p_backup_stats  IN VARCHAR2    DEFAULT 'N',
    p_script_stats  IN VARCHAR2    DEFAULT 'N',
    p_limit         IN PLS_INTEGER DEFAULT 5,
    p_log_level     IN PLS_INTEGER DEFAULT 2,
    p_explain_table IN VARCHAR2    DEFAULT 'PLAN_TABLE') IS
    --
    l_file UTL_FILE.file_type;
  --
  BEGIN
    -- initialise the explain sql counters
    g_explain_sql_counter  := 0;
    g_explained_sql_counter := 0;
    g_not_explained_sql_counter := 0;
    g_table_counter := 0;
    g_table_owner_table.DELETE;
    g_table_owner_status_table.DELETE;
    g_table_name_table.DELETE;
    g_error_text := NULL;
    g_filename := p_filename;
    -- set the gather status
    IF UPPER(p_backup_stats) = 'Y' THEN
      g_backup_stats := 'Y';
    ELSE
      g_backup_stats := NULL;
    END IF;
    -- set the script status
    IF UPPER(p_script_stats) = 'Y' AND p_log_level = 2 THEN
      g_script_stats := 'Y';
    ELSE
      g_script_stats := NULL;
    END IF;
    -- set the g_explain_table global
    g_explain_table := NVL(UPPER(p_explain_table),'PLAN_TABLE');
    -- validate the plan table exists
    check_explain_table;
    -- open TKPROF file
    l_file := open_tkprof_file
                (p_location => p_location,
                 p_filename => p_filename);
    -- open the log file
    open_log_file
     (p_location  => p_location,
      p_filename  => p_filename,
      p_log_level => p_log_level,
      p_limit     => p_limit);
    -- delete any previously created explain plans
    delete_all_expstms(p_commit => TRUE);
    -- process TKPROF file
    process_tkprof_file
      (p_file  => l_file,
       p_limit => p_limit);
    -- close TKPROF file
    close_tkprof_file(p_file => l_file);
    -- gather/export table/column/index stats
    export_table_stats(p_statid => p_filename);
    -- close_log_file
    close_log_file;
  EXCEPTION
    WHEN OTHERS THEN
      -- close all open files
      UTL_FILE.fclose_all;
      raise_application_error(-20001,g_error_text);
  END run;
END hr_tkprof_plus;

/
