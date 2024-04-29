--------------------------------------------------------
--  DDL for Package Body HRI_OPL_CMPTNC_LVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_CMPTNC_LVL" AS
/* $Header: hripcmlv.pkb 120.1 2005/06/08 02:54:08 anmajumd noship $ */
--
-- Types required to support tables of column values.
--
-- @@ Code specific to this view/table below
-- @@ INTRUCTION TO DEVELOPER:
-- @@ 1/ For each column in your 'source view' create a TYPE in the format
-- @@    g_<col_name>_type.  Each TYPE should be a table of 'target table.
-- @@    column'%TYPE indexed by binary_integer. i.e.:
-- @@
-- @@    TYPE g_<col_name>_type IS TABLE OF
-- @@      <target_table>%TYPE
-- @@      INDEX BY BINARY_INTEGER;
-- @@
-- *** This can be generated using */
-- SELECT
-- 'TYPE g_' || lower(column_name) || '_type IS TABLE OF ' ||
-- table_name || '.' || column_name || '%TYPE INDEX BY BINARY_INTEGER;'
-- FROM all_tab_columns
-- WHERE owner = 'HRI'
-- AND table_name = '<Table Name>'
-- ORDER BY column_id
--
TYPE g_date_tabtype IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tabtype IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
--
-- @@ Code specific to this view/table below ENDS
--
--
-- PLSQL tables representing database table columns
--
g_row_ind              g_number_tabtype;
g_no_level_ind         g_number_tabtype;
g_scale_level_val      g_number_tabtype;
g_min_scale_level      g_number_tabtype;
g_max_scale_level      g_number_tabtype;
g_rank_level_val       g_number_tabtype;
g_min_rank_level       g_number_tabtype;
g_max_rank_level       g_number_tabtype;
g_nrmlzd_scale_lvl     g_number_tabtype;
g_nrmlzd_rank_lvl      g_number_tabtype;
g_competence_id        g_number_tabtype;
g_scale_id             g_number_tabtype;
g_level_id             g_number_tabtype;
g_eval_mthd_code       g_varchar2_tabtype;
g_rnwl_prd_freq        g_number_tabtype;
g_rnwl_prd_unit        g_varchar2_tabtype;
g_cert_reqrd_flag      g_varchar2_tabtype;
g_scale_flag           g_varchar2_tabtype;
g_scale_default_flag   g_varchar2_tabtype;
g_last_change_date     g_date_tabtype;
--
-- Holds the range for which the collection is to be run.
--
g_start_date    DATE;
g_end_date      DATE;
g_full_refresh  VARCHAR2(10);
--
-- The HRI schema
--
g_schema                  VARCHAR2(400);
--
-- Set to true to output to a concurrent log file
--
g_conc_request_flag       BOOLEAN := FALSE;
--
-- Number of rows bulk processed at a time
--
g_chunk_size              PLS_INTEGER;
--
-- End of time date
--
-- CONSTANTS
-- =========
--
-- @@ Code specific to this view/table below
-- @@ in the call to hri_bpl_conc_log.get_last_collect_to_date
-- @@ change param1/2 to be the concurrent program short name,
-- @@ and the target table name respectively.
--
g_target_table          VARCHAR2(30) DEFAULT 'HRI_CS_CMPTNC_LVL_CT';
g_cncrnt_prgrm_shrtnm   VARCHAR2(30) DEFAULT 'HRICMPTNCLVL';
--
-- @@ Code specific to this view/table below ENDS
--
-- constants that hold the value that indicates to full refresh or not.
--
g_is_full_refresh    VARCHAR2(5) DEFAULT 'Y';
g_not_full_refresh   VARCHAR2(5) DEFAULT 'N';
--
-- -------------------------------------------------------------------------
--
-- Inserts row into concurrent program log when the g_conc_request_flag has
-- been set to TRUE, otherwise does nothing
--
PROCEDURE output(p_text  VARCHAR2)
  IS
  --
BEGIN
  --
  -- Write to the concurrent request log if called from a concurrent request
  --
  IF (g_conc_request_flag = TRUE) THEN
    --
    -- Put text to log file
    --
    fnd_file.put_line(FND_FILE.log, p_text);
    --
  END IF;
  --
END output;
--
-- -------------------------------------------------------------------------
--
-- Recovers rows to insert when an exception occurs
--
PROCEDURE recover_insert_rows(p_stored_rows_to_insert NUMBER) IS

BEGIN
  --
  -- loop through rows still to insert one at a time
  --
  FOR i IN 1..p_stored_rows_to_insert LOOP
    --
    -- Trap unique constraint errors
    --
    BEGIN
      --
      -- @@ Code specific to this view/table below
      -- @@ INTRUCTION TO DEVELOPER:
      -- @@ 1/ For each column in your view put a column in the insert
      -- @@ statement below.
      -- @@ 2/ Prefix each column in the VALUE clause with g_
      -- @@ 3/ make sure (i) is at the end of each column in the value clause
      --
      INSERT INTO hri_cs_cmptnc_lvl_ct
        (row_indicator
        ,no_level_indicator
        ,scale_level_value
        ,min_scale_level_value
        ,max_scale_level_value
        ,rank_level_value
        ,min_rank_level_value
        ,max_rank_level_value
        ,nrmlzd_scale_level_value
        ,nrmlzd_rank_level_value
        ,competence_id
        ,scale_id
        ,level_id
        ,cmptnc_eval_mthd_code
        ,cmptnc_rnwl_prd_freq_value
        ,cmptnc_rnwl_prd_unit_code
        ,cmptnc_cert_reqrd_flag_code
        ,scale_flag_code
        ,scale_dflt_flag_code
        ,last_change_date)
        VALUES
          (g_row_ind(i)
          ,g_no_level_ind(i)
          ,g_scale_level_val(i)
          ,g_min_scale_level(i)
          ,g_max_scale_level(i)
          ,g_rank_level_val(i)
          ,g_min_rank_level(i)
          ,g_max_rank_level(i)
          ,g_nrmlzd_scale_lvl(i)
          ,g_nrmlzd_rank_lvl(i)
          ,g_competence_id(i)
          ,g_scale_id(i)
          ,g_level_id(i)
          ,g_eval_mthd_code(i)
          ,g_rnwl_prd_freq(i)
          ,g_rnwl_prd_unit(i)
          ,g_cert_reqrd_flag(i)
          ,g_scale_flag(i)
          ,g_scale_default_flag(i)
          ,g_last_change_date(i));
      --
      -- @@Code specific to this view/table below ENDS
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
      --
      -- @@ Code specific to this view/table below
      -- @@ INTRUCTION TO DEVELOPER:
      -- @@ 1/ Add a useful log message in the event of an insert failing
      --
        output('Single insert error: ' || to_char(g_competence_id(i)) ||
               ' - ' || to_char(g_level_id(i)) ||
               ' - ' || to_char(g_scale_id(i)));
        --
        output(sqlerrm);
        output(sqlcode);
        --
      --
    END;
    --
  END LOOP;
  --
  COMMIT;
  --
END recover_insert_rows;
--
-- -------------------------------------------------------------------------
--
-- Bulk inserts rows from global temporary table to database table
--
PROCEDURE bulk_insert_rows(p_stored_rows_to_insert NUMBER) IS
  --
BEGIN
  --
  -- insert chunk of rows
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ For each column in your view put a column in the insert statement
  --       below.
  -- @@ 2/ Prefix each column in the VALUE clause with g_
  -- @@ 3/ make sure (i) is at the end of each column in the value clause
  --
  FORALL i IN 1..p_stored_rows_to_insert
      INSERT INTO hri_cs_cmptnc_lvl_ct
        (row_indicator
        ,no_level_indicator
        ,scale_level_value
        ,min_scale_level_value
        ,max_scale_level_value
        ,rank_level_value
        ,min_rank_level_value
        ,max_rank_level_value
        ,nrmlzd_scale_level_value
        ,nrmlzd_rank_level_value
        ,competence_id
        ,scale_id
        ,level_id
        ,cmptnc_eval_mthd_code
        ,cmptnc_rnwl_prd_freq_value
        ,cmptnc_rnwl_prd_unit_code
        ,cmptnc_cert_reqrd_flag_code
        ,scale_flag_code
        ,scale_dflt_flag_code
        ,last_change_date)
        VALUES
          (g_row_ind(i)
          ,g_no_level_ind(i)
          ,g_scale_level_val(i)
          ,g_min_scale_level(i)
          ,g_max_scale_level(i)
          ,g_rank_level_val(i)
          ,g_min_rank_level(i)
          ,g_max_rank_level(i)
          ,g_nrmlzd_scale_lvl(i)
          ,g_nrmlzd_rank_lvl(i)
          ,g_competence_id(i)
          ,g_scale_id(i)
          ,g_level_id(i)
          ,g_eval_mthd_code(i)
          ,g_rnwl_prd_freq(i)
          ,g_rnwl_prd_unit(i)
          ,g_cert_reqrd_flag(i)
          ,g_scale_flag(i)
          ,g_scale_default_flag(i)
          ,g_last_change_date(i));
  --
  -- @@Code specific to this view/table below ENDS
  --
  -- commit the chunk of rows
  --
  COMMIT;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- Probable unique constraint error
    --
    ROLLBACK;
    --
    recover_insert_rows(p_stored_rows_to_insert);
    --
END bulk_insert_rows;
--
PROCEDURE Full_Refresh IS
  --
  -- Select all from the source view for materialization
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the select beloe to select all the columns from your view
  -- @@ 2/ Change the FROM statement to point at the relevant source view
  --
  CURSOR source_view_csr IS
  SELECT
         row_indicator
        ,no_level_indicator
        ,scale_level_value
        ,min_scale_level_value
        ,max_scale_level_value
        ,rank_level_value
        ,min_rank_level_value
        ,max_rank_level_value
        ,nrmlzd_scale_level_value
        ,nrmlzd_rank_level_value
        ,competence_id
        ,scale_id
        ,level_id
        ,cmptnc_eval_mthd_code
        ,cmptnc_rnwl_prd_freq_value
        ,cmptnc_rnwl_prd_unit_code
        ,cmptnc_cert_reqrd_flag_code
        ,scale_flag_code
        ,scale_dflt_flag_code
        ,last_change_date
  FROM hri_cs_cmptnc_lvl_v;
  --
  -- @@Code specific to this view/table below ENDS
  --
  l_exit_main_loop       BOOLEAN := FALSE;
  l_rows_fetched         PLS_INTEGER := g_chunk_size;
  l_sql_stmt      VARCHAR2(2000);
  --
BEGIN
  -- log('here ...');
  --
  -- Truncate the target table prior to full refresh.
  --
  l_sql_stmt := 'TRUNCATE TABLE ' || g_schema || '.'||g_target_table;
  -- log('>'||l_sql_stmt||'<');
  --
  EXECUTE IMMEDIATE(l_sql_stmt);
  -- log('trunced ...');
  --
  -- Write timing information to log
  --
  output('Truncated the table:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- open main cursor
  --
  -- log('open cursor ...');
  OPEN source_view_csr;
  --
  <<main_loop>>
  LOOP
    --
    -- bulk fetch rows limit the fetch to value of g_chunk_size
    --
    -- @@ Code specific to this view/table below
    -- @@ INTRUCTION TO DEVELOPER:
    -- @@ Change the bulk collect below to select all the columns from your
    -- @@ view
    --
    -- log('start fetch ...');
    -- log('>'||TO_CHAR(g_chunk_size)||'<');
    FETCH source_view_csr
    BULK COLLECT INTO
           g_row_ind
          ,g_no_level_ind
          ,g_scale_level_val
          ,g_min_scale_level
          ,g_max_scale_level
          ,g_rank_level_val
          ,g_min_rank_level
          ,g_max_rank_level
          ,g_nrmlzd_scale_lvl
          ,g_nrmlzd_rank_lvl
          ,g_competence_id
          ,g_scale_id
          ,g_level_id
          ,g_eval_mthd_code
          ,g_rnwl_prd_freq
          ,g_rnwl_prd_unit
          ,g_cert_reqrd_flag
          ,g_scale_flag
          ,g_scale_default_flag
          ,g_last_change_date
    LIMIT g_chunk_size;
    -- log('finish fetch ...');
    --
    -- @@Code specific to this view/table below ENDS
    --
    -- check to see if the last row has been fetched
    --
    IF source_view_csr%NOTFOUND THEN
      --
      -- last row fetched, set exit loop flag
      --
      l_exit_main_loop := TRUE;
      --
      -- do we have any rows to process?
      --
      l_rows_fetched := MOD(source_view_csr%ROWCOUNT,g_chunk_size);
      --
      -- note: if l_rows_fetched > 0 then more rows are required to be
      -- processed and the l_rows_fetched will contain the exact number of
      -- rows left to process
      --
      IF l_rows_fetched = 0 THEN
        --
        -- no more rows to process so exit loop
        --
        EXIT main_loop;
      END IF;
    END IF;
    --
    -- bulk insert rows processed so far
    --
    -- log('call bulk ...');
    bulk_insert_rows (l_rows_fetched);
    -- log('end bulk ...');
    --
    -- exit loop if required
    --
    IF l_exit_main_loop THEN
      --
      EXIT main_loop;
      --
    END IF;
    --
  END LOOP;
  --
  CLOSE source_view_csr;
  --
  -- log('End ...');
EXCEPTION
  WHEN OTHERS THEN
    --
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    --
    IF source_view_csr%ISOPEN THEN
      --
      CLOSE source_view_csr;
      --
    END IF;
    --
    -- re-raise error
    RAISE;
    --
  --
END Full_Refresh;
--
-- -------------------------------------------------------------------------
-- Checks what mode you are running in, and if g_full_refresh =
-- g_is_full_refresh calls
-- Full_Refresh procedure, otherwise Incremental_Update is called.
--
PROCEDURE Collect IS
  --
BEGIN
  --
  -- If in full refresh mode change the dates so that the collection history
  -- is correctly maintained.
  --
  IF g_full_refresh = g_is_full_refresh THEN
    --
    IF (g_start_date IS NULL) THEN
      g_start_date := hr_general.start_of_time;
    END IF;
    IF (g_end_date IS NULL) THEN
      g_end_date     := SYSDATE;
    END IF;
    --
    -- log('Doing full refresh.');
    Full_Refresh;
    --
  END IF;
  --
END Collect;
--
-- -------------------------------------------------------------------------
-- Checks if the Target table is Empty
--
-- -------------------------------------------------------------------------
--
-- Main entry point to load the table.
--
PROCEDURE Load(p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2) IS
  --
  -- Variables required for table truncation.
  --
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  --
BEGIN
  --
  output('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  -- Set globals
  --
  g_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
  g_end_date   := to_date(p_end_date,   'YYYY/MM/DD HH24:MI:SS');
  --
  IF p_chunk_size IS NULL
  THEN
    --
    g_chunk_size := 1000;
    --
  ELSE
    --
    g_chunk_size   := p_chunk_size;
    --
  END IF;
  --
  IF p_full_refresh IS NULL
  THEN
    --
    g_full_refresh := g_not_full_refresh;
    --
  ELSE
    --
    g_full_refresh := p_full_refresh;
    --
  END IF;
  --
  -- log('p_chunk_size>'||TO_CHAR(g_chunk_size)||'<');
  -- Find the schema we are running in.
  --
  IF NOT fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, g_schema)
  THEN
    --
    -- Could not find the schema raising exception.
    --
    output('Could not find schema to run in.');
    --
    -- log('Could not find schema.');
    RAISE NO_DATA_FOUND;
    --
  END IF;
  --
  -- Update information about collection
  --
  -- log('Record process start.');
  /* double check correct val passed in below */
  hri_bpl_conc_log.record_process_start(g_cncrnt_prgrm_shrtnm);
  --
  -- Time at start
  --
  -- log('collect.');
  --
  -- Get HRI schema name - get_app_info populates l_schema
  --
  -- Insert new records
  --
  collect;
  -- log('collectED.');
  --
  -- Write timing information to log
  --
  output('Finished changes to the table:  '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- Gather index stats
  --
  -- log('gather stats.');
  fnd_stats.gather_table_stats(g_schema, g_target_table);
  --
  -- Write timing information to log
  --
  output('Gathered stats:   '  ||
         to_char(sysdate,'HH24:MI:SS'));
  --
  -- log('log end.');
  hri_bpl_conc_log.log_process_end(
        p_status         => TRUE,
        p_period_from    => TRUNC(g_start_date),
        p_period_to      => TRUNC(g_end_date),
        p_attribute1     => p_full_refresh,
        p_attribute2     => p_chunk_size);
  -- log('-END-');
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    ROLLBACK;
    RAISE;
    --
  --
END Load;
--
-- -------------------------------------------------------------------------
--
-- Entry point to be called from the concurrent manager
--
PROCEDURE Load(errbuf          OUT NOCOPY VARCHAR2,
               retcode         OUT NOCOPY VARCHAR2,
               p_chunk_size    IN NUMBER,
               p_start_date    IN VARCHAR2,
               p_end_date      IN VARCHAR2,
               p_full_refresh  IN VARCHAR2)
IS
  --
BEGIN
  --
  -- Enable output to concurrent request log
  --
  g_conc_request_flag := TRUE;
  --
  load(p_chunk_size   => p_chunk_size,
       p_start_date   => p_start_date,
       p_end_date     => p_end_date,
       p_full_refresh => p_full_refresh);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    errbuf  := SQLERRM;
    retcode := SQLCODE;
    --
  --
END load;
--
END HRI_OPL_CMPTNC_LVL;

/
