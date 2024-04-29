--------------------------------------------------------
--  DDL for Package Body HRI_OPL_PER_ORGCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_PER_ORGCC" AS
/* $Header: hrippcc.pkb 120.0 2005/05/29 06:56:42 appldev noship $ */
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
--
TYPE g_organization_id_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.organization_id%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_cost_centre_code_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.cost_centre_code%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_cc_mngr_person_id_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.cc_mngr_person_id%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_effective_start_date_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.effective_start_date%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_effective_end_date_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.effective_end_date%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_company_code_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.company_code%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_reporting_name_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.reporting_name%TYPE
  INDEX BY BINARY_INTEGER;
TYPE g_last_change_date_type IS TABLE OF
  HRI_CS_PER_ORGCC_CT.last_change_date%TYPE
  INDEX BY BINARY_INTEGER;
--
-- @@ Code specific to this view/table below ENDS
--
--
-- PLSQL tables representing database table columns
--
g_organization_id        g_organization_id_type;
g_cost_centre_code       g_cost_centre_code_type;
g_cc_mngr_person_id      g_cc_mngr_person_id_type;
g_effective_start_date   g_effective_start_date_type;
g_effective_end_date     g_effective_end_date_type;
g_company_code           g_company_code_type;
g_reporting_name         g_reporting_name_type;
g_last_change_date       g_last_change_date_type;
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
g_target_table          VARCHAR2(30) DEFAULT 'HRI_CS_PER_ORGCC_CT';
g_cncrnt_prgrm_shrtnm   VARCHAR2(30) DEFAULT 'HRIPORGC';
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
      INSERT INTO hri_cs_per_orgcc_ct
        (organization_id
        ,cost_centre_code
        ,cc_mngr_person_id
        ,effective_start_date
        ,effective_end_date
        ,company_code
        ,reporting_name
        ,last_change_date)
      VALUES
        (g_organization_id(i)
        ,g_cost_centre_code(i)
        ,g_cc_mngr_person_id(i)
        ,g_effective_start_date(i)
        ,g_effective_end_date(i)
        ,g_company_code(i)
        ,g_reporting_name(i)
        ,g_last_change_date(i));
      --
      -- @@Code specific to this view/table below ENDS
      --
    EXCEPTION
      --
      WHEN OTHERS THEN
        --
        -- Probable overlap on date tracked assignment rows
        --
        output('Single insert error: ' || to_char(g_organization_id(i)) ||
               ' - ' || to_char(g_cc_mngr_person_id(i)));
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
      INSERT INTO hri_cs_per_orgcc_ct
        (organization_id
        ,cost_centre_code
        ,cc_mngr_person_id
        ,effective_start_date
        ,effective_end_date
        ,company_code
        ,reporting_name
        ,last_change_date)
      VALUES
        (g_organization_id(i)
        ,g_cost_centre_code(i)
        ,g_cc_mngr_person_id(i)
        ,g_effective_start_date(i)
        ,g_effective_end_date(i)
        ,g_company_code(i)
        ,g_reporting_name(i)
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
  --
END bulk_insert_rows;
--
-- -------------------------------------------------------------------------
--
-- Loops through table and collects into table structure.
--
PROCEDURE Incremental_Update IS
  --
BEGIN
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ 1/ Change the code below to reflect the columns in your view / table
  -- @@ 2/ Change the FROM, INSERT, DELETE statements to point at the relevant
  -- @@    source view / table
  --
  -- Insert completly new rows
  --
  -- log('Doing insert.');
  INSERT INTO hri_cs_per_orgcc_ct
  (organization_id
  ,cost_centre_code
  ,cc_mngr_person_id
  ,effective_start_date
  ,effective_end_date
  ,company_code
  ,reporting_name
  ,last_change_date)
  SELECT
   organization_id
  ,cost_centre_code
  ,cc_mngr_person_id
  ,effective_start_date
  ,effective_end_date
  ,company_code
  ,reporting_name
  ,last_change_date
  FROM hri_cs_per_orgcc_v svw
  --
  -- 4303724, Used TRUNC function
  --
  WHERE TRUNC(last_change_date) BETWEEN g_start_date
                                AND     g_end_date
  AND NOT EXISTS (SELECT 'x'
                  FROM   hri_cs_per_orgcc_ct tbl
                  WHERE  svw.organization_id    = tbl.organization_id
                  AND    svw.effective_start_date   = tbl.effective_start_date
                  AND    svw.effective_end_date     = tbl.effective_end_date);
  -- log('Insert >'||TO_CHAR(sql%rowcount));
  -- log('Doing update.');
  --
  -- Update changed rows
  -- Bug 3658494: Query made performant
  --
  UPDATE hri_cs_per_orgcc_ct tbl
    SET (organization_id
        ,cost_centre_code
        ,cc_mngr_person_id
        ,effective_start_date
        ,effective_end_date
        ,company_code
        ,reporting_name
        ,last_change_date) =
          (SELECT svw.organization_id
                 ,svw.cost_centre_code
                 ,svw.cc_mngr_person_id
                 ,svw.effective_start_date
                 ,svw.effective_end_date
                 ,svw.company_code
                 ,svw.reporting_name
                 ,svw.last_change_date
           FROM hri_cs_per_orgcc_v     svw
	   --
	   -- 4303724, Used TRUNC function
	   --
           WHERE TRUNC(svw.last_change_date) BETWEEN g_start_date
                                             AND     g_end_date
           AND   svw.organization_id        = tbl.organization_id
           AND   svw.effective_start_date   = tbl.effective_start_date
           AND   svw.effective_end_date     = tbl.effective_end_date
           )
    WHERE (tbl.organization_id,
           tbl.effective_start_date,
           tbl.effective_end_date)
          IN
          (SELECT svw.organization_id,
                  svw.effective_start_date,
                  svw.effective_end_date
           FROM   hri_cs_per_orgcc_v     svw
	   --
	   -- 4303724, Used TRUNC function
	   --
           WHERE  TRUNC(svw.last_change_date) BETWEEN g_start_date
                                              AND     g_end_date);
  --
  -- log('Update >'||TO_CHAR(sql%rowcount));
  --
  -- Delete rows that no longer exist in the source view.
  --
  -- log('Doing delete.');
  DELETE
  FROM hri_cs_per_orgcc_ct tbl
  WHERE NOT EXISTS (SELECT 'x'
                    FROM  hri_cs_per_orgcc_v svw
                    WHERE svw.organization_id      = tbl.organization_id
                    AND   svw.effective_start_date = tbl.effective_start_date
                    AND   svw.effective_end_date   = tbl.effective_end_date);
  -- log('Delete >'||TO_CHAR(sql%rowcount));
  --
  -- @@ Code specific to this view/table below ENDS
  --
  COMMIT;
  -- log('Done incremental update.');
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    Output('Failure in incremental update process.');
    --
    RAISE;
    --
  --
END;
--
-- -------------------------------------------------------------------------
--
--
-- Loops through table and collects into table structure.
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
     organization_id
    ,cost_centre_code
    ,cc_mngr_person_id
    ,effective_start_date
    ,effective_end_date
    ,company_code
    ,reporting_name
    ,last_change_date
  FROM hri_cs_per_orgcc_v svw;
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
       g_organization_id
      ,g_cost_centre_code
      ,g_cc_mngr_person_id
      ,g_effective_start_date
      ,g_effective_end_date
      ,g_company_code
      ,g_reporting_name
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
  -- If in full refresh mode chnage the dates so that the collection history
  -- is correctly maintained.
  --
  IF g_full_refresh = g_is_full_refresh THEN
    --
    g_start_date   := hr_general.start_of_time;
    g_end_date     := SYSDATE;
    --
    -- log('Doing full refresh.');
    Full_Refresh;
    --
  ELSE
    --
    -- log('Doing incremental update.');
    --
    -- If the passed in date range is NULL default it.
    --
    IF g_start_date IS NULL OR
       g_end_date   IS NULL
    THEN
    -- log('Input dates NULL.');
      --
      g_start_date   :=  fnd_date.displaydt_to_date(
                                  hri_bpl_conc_log.get_last_collect_to_date(
                                        g_cncrnt_prgrm_shrtnm
                                       ,g_target_table));
      --
      g_end_date     := SYSDATE;
      -- log('start >'||TO_CHAR(g_start_date));
      -- log('end >'||TO_CHAR(g_end_date));
      -- log('Defaulted input DATES.');
      --
    END IF;
    --
    -- log('Calling incremenatal update.');
    Incremental_Update;
    -- log('Called incremenatal update.');
    --
  END IF;
  --
END Collect;
--
-- -------------------------------------------------------------------------
-- Checks if the Target table is Empty
--
FUNCTION Target_table_is_Empty RETURN BOOLEAN IS
  --
  -- @@ Code specific to this view/table below
  -- @@ INTRUCTION TO DEVELOPER:
  -- @@ Change the table in the FROM clause below to be the same as  your
  -- @@ target table.
  --
  CURSOR csr_recs_exist IS
  SELECT 'x'
  FROM   hri_cs_per_orgcc_ct;
  --
  -- @@ Code specific to this view/table ENDS
  --
  l_exists_chr    VARCHAR2(1);
  l_exists        BOOLEAN;
  --
BEGIN
  --
  OPEN csr_recs_exist;
  --
  FETCH csr_recs_exist INTO l_exists_chr;
  --
  IF (csr_recs_exist%NOTFOUND)
  THEN
    --
    l_exists := TRUE;
    -- log('no data in table');
    --
  ELSE
    --
    l_exists := FALSE;
    -- log('data is in table');
    --
  END IF;
  --
  CLOSE csr_recs_exist;
  --
  RETURN l_exists;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    CLOSE csr_recs_exist;
    RAISE;
    --
  --
END Target_table_is_Empty;
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
    g_chunk_size := 500;
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
  -- If the target table is empty default to full refresh.
  --
  IF Target_table_is_Empty
  THEN
    --
    output('Target table '||g_target_table||
           ' is empty, so doing a full refresh.');
    -- log('Doing a full refresh....');
    --
    g_full_refresh := g_is_full_refresh;
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
END HRI_OPL_PER_ORGCC;

/
