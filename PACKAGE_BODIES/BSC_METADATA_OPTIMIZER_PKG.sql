--------------------------------------------------------
--  DDL for Package Body BSC_METADATA_OPTIMIZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_METADATA_OPTIMIZER_PKG" AS
/* $Header: BSCMOPTB.pls 120.25 2006/03/27 12:47:07 arsantha noship $ */


g_doc_file utl_file.file_type;
g_progressCounter NUMBER := 0;

PROCEDURE createTmpLogTables IS
l_stmt varchar2(1000);
l_table_name varchar2(30) := g_filtered_indics;
BEGIN
  l_stmt := 'drop table '||l_table_name ;
  begin
    BSC_MO_HELPER_PKG.writeTmp('Going to drop '||l_table_name , FND_LOG.LEVEL_STATEMENT, false);
    BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.drop_table, l_table_name);
    exception when others then
      null;
      --BSC_MO_HELPER_PKG.writeTmp(l_table_name ||' does not exist... ignoring error while trying to drop');
  end;
  l_stmt := 'create table '||l_table_name ||' TABLESPACE '||BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName||' '|| BSC_METADATA_OPTIMIZER_PKG.gStorageClause||
     ' as
      SELECT distinct k.indicator, k.dim_set_id, k.level_pk_col, k.level_view_name
      FROM BSC_KPI_DIM_LEVELS_B K, BSC_SYS_DIM_LEVELS_B S, bsc_kpis_b kpi
      WHERE
      kpi.share_flag = 2
      and kpi.indicator = k.indicator
      and UPPER(K.LEVEL_TABLE_NAME) = UPPER(S.LEVEL_TABLE_NAME)
      AND K.INDICATOR = kpi.indicator
      --AND K.DIM_SET_ID = dimset.dim_set_id
      AND UPPER(S.LEVEL_VIEW_NAME) <> UPPER(K.LEVEL_VIEW_NAME)
      AND K.STATUS = 2 ';
  BSC_MO_HELPER_PKG.writeTmp('Going to create '||l_table_name , FND_LOG.LEVEL_STATEMENT, false);
  BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.create_table, l_table_name);
  l_stmt := 'create unique index '||l_table_name||'_u1 on '||l_table_name ||'(indicator, dim_set_id, level_pk_col)';
  l_stmt := l_stmt ||' TABLESPACE '||  BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName||' '|| BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
  BSC_MO_HELPER_PKG.writeTmp('Going to create '||l_table_name ||'_u1', FND_LOG.LEVEL_STATEMENT, false);
  BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.create_index, l_table_name ||'_u1');

END;

PROCEDURE writeTableCounts IS
l_num NUMBER;
l_problem_indics VARCHAR2(32000) := null;
cv   CurTyp;
l_stmt varchar2(4000) := 'select distinct kpi.indicator, kpi.share_flag
from
bsc_kpis_b kpi,
bsc_tmp_opt_kpis_with_measures considerkpi
where kpi.indicator = considerkpi.indicator
and kpi.prototype_flag <> 2
-- get indicators without rows in bsc_db_tables
and not exists
(select 1 from bsc_db_tables where table_name like ''BSC_S_''||kpi.indicator||''%'')
-- skip shared but unfiltered indicators
and ( kpi.share_flag in (0,1)
    or
    (kpi.share_flag = 2
      and exists
     (SELECT 1
      FROM bsc_tmp_opt_filtered_indics fil
      where fil.indicator = kpi.indicator
      )
     )
  )';
l_count number := 0;

BEGIN
  return;
  /*
  bsc_mo_helper_pkg.writeTmp( 'Starting writeTableCounts, System time is '
    ||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  SELECT count(1) INTO l_num
    FROM bsc_db_tables
   WHERE table_name like 'BSC_I_%';
  bsc_mo_helper_pkg.writeTmp('No. of I tables in DB_tables = '||l_num, FND_LOG.LEVEL_STATEMENT, true);
  SELECT count(1)INTO l_num
    FROM bsc_db_tables
   WHERE table_name like 'BSC_B_%';
  bsc_mo_helper_pkg.writeTmp('No. of B tables in DB_tables = '||l_num, FND_LOG.LEVEL_STATEMENT, true);
  SELECT count(1)INTO l_num
    FROM bsc_db_tables
   WHERE table_name like 'BSC_T_%';
  bsc_mo_helper_pkg.writeTmp('No. of T tables in DB_tables = '||l_num, FND_LOG.LEVEL_STATEMENT, true);
  SELECT count(1) INTO l_num
    FROM bsc_db_tables
   WHERE table_name like 'BSC_S_%';
  bsc_mo_helper_pkg.writeTmp('No. of S tables in DB_tables = '||l_num, FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp(bsc_mo_helper_pkg.get_time||' Indicators with no rows in BSC_DB_tables : ', FND_LOG.LEVEL_STATEMENT, true);
  OPEN cv for l_stmt;
  LOOP
    FETCH cv INTO l_num;
    EXIT WHEN cv%NOTFOUND;
    l_count:= l_count + 1;
    l_problem_indics := l_problem_indics||', '||l_num;
    IF (l_count = 15) THEN
      bsc_mo_helper_pkg.writeTmp(l_problem_indics, FND_LOG.LEVEL_STATEMENT, true);
      l_count := 0;
          l_problem_indics := null;
    END IF;
  END LOOP;
  close cv;
  if (l_count > 0 ) THEN
    bsc_mo_helper_pkg.writeTmp(l_problem_indics, FND_LOG.LEVEL_STATEMENT, true);
  end if;
  bsc_mo_helper_pkg.writeTmp( 'Done writeTableCounts, System time is '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  */
END;

Function getUtlFileDir return VARCHAR2 IS
  l_dir VARCHAR2(1000);
  l_utl_dir VARCHAR2(100);
  l_count    NUMBER := 0;
  l_log_begin    NUMBER := 0;
  l_log_end    NUMBER := 0;
  l_comma_pos    NUMBER := 0;
  stmt     VARCHAR2(200);
  cid     NUMBER;
  l_dummy     NUMBER;

BEGIN
  SELECT value INTO l_dir
  FROM v$parameter param where upper(param.name) = 'UTL_FILE_DIR';
  l_log_begin := INSTR(l_dir, '/log');

  IF (l_log_begin = 0) THEN /* then get the first string */
    l_utl_dir := substr(l_dir, 1, INSTR(l_dir, ',') - 1);
    IF (l_utl_dir IS NOT NULL) THEN
      return l_utl_dir;
    ELSE
      return l_dir;
    END IF;
  END IF;
  l_log_end  := INSTR(l_dir, ',', l_log_begin) - 1;
  IF (l_log_end <= 0) THEN
    l_log_end := length(l_dir);
  END IF;
  --have now determined the first occurrence of '/log' and the end pos
  -- now to determine the start position of the log directory
  l_dir := substr(l_dir, 0, l_log_end);
  LOOP
    l_comma_pos := INSTR(l_dir, ',', l_comma_pos+1);
    IF (l_comma_pos <> 0) THEN
      l_count :=   l_comma_pos + 1;
    END IF;
    EXIT WHEN l_comma_pos = 0;
  END LOOP;
  l_utl_dir := substr(l_dir, l_count+1, l_log_end);
  RETURN l_utl_dir;
END;

/*---------------------------------------------------------------------
      Write to the log file using utl_file. Write only IF the logging
      flag is TRUE.
---------------------------------------------------------------------*/

--Procedure writeLog(p_message IN VARCHAR2) IS
--BEGIN
--  fnd_file.put_line(FND_FILE.LOG, p_message);
--END;

/*Procedure writeOut(p_message IN VARCHAR2) IS
BEGIN
  IF (g_OUT) THEN
    fnd_file.put_line(FND_FILE.OUTPUT, p_message);
  END IF;
END;
*/

PROCEDURE InitLanguages IS
l_stmt VARCHAR2(1000);
l_lang_code varchar2(100);
l_nls_lang  Varchar2(100);
cv   CurTyp;

CURSOR c1 is
SELECT userenv('LANG') from dual;

CURSOR cLangs IS
SELECT DISTINCT LANGUAGE_CODE, NLS_LANGUAGE FROM FND_LANGUAGES
WHERE INSTALLED_FLAG IN ('I', 'B');

BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside InitLanguages', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  gNumInstalled_Languages := 0;
  OPEN c1;
  FETCH c1 INTO gNLSLang;
  close c1;
  OPEN cLangs;
  LOOP
    Fetch cLangs INTO l_lang_code, l_nls_lang;
    EXIT WHEN cLangs%NOTFOUND;
    gInstalled_Languages(gNumInstalled_Languages) := l_lang_code;
    gNumInstalled_Languages := gNumInstalled_Languages + 1;
    If l_lang_code = gNLSLang Then
      gLangCode := l_lang_code;
    End If ;
  END LOOP;
  close cLangs;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Compl InitLanguages', FND_LOG.LEVEL_PROCEDURE);
    bsc_mo_helper_pkg.writeTmp('gInstalled_Languages IS', FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.write_this(gInstalled_Languages, FND_LOG.LEVEL_STATEMENT);
  END IF;
  EXCEPTION WHEN others then
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in InitLanguages:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    RAISE;
END;

PROCEDURE InitReservedFunctions IS

l_stmt varchar2(1000);
l_reserved_word VARCHAR2(100);
cv   CurTyp;
l_type number;
BEGIN
  -- return if already initialized
  IF (gNumReservedFunctions >0 and gNumReservedOperators >0) THEN
    return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside InitReservedFunctions', FND_LOG.LEVEL_PROCEDURE);
  END IF;
    l_stmt := 'SELECT WORD FROM BSC_DB_RESERVED_WORDS WHERE WORD IS NOT NULL AND TYPE = 1';
  gNumReservedFunctions := 0;

  OPEN CV for l_stmt;
  LOOP
    FETCH cv INTO l_reserved_word;
    EXIT WHEN cv%NOTFOUND;
    gReservedFunctions(gNumReservedFunctions) := l_reserved_word;
    gNumReservedFunctions := gNumReservedFunctions + 1;

  END LOOP;
  CLOSE CV;
  gNumReservedOperators := 0;
  l_stmt := 'SELECT WORD FROM BSC_DB_RESERVED_WORDS WHERE WORD IS NOT NULL AND TYPE = 2';
  OPEN CV for l_stmt;
  LOOP
    FETCH cv INTO l_reserved_word;
    EXIT WHEN cv%NOTFOUND;
      --08/14/00 Bug#1377900 Exclude NOT, MOD from operators. They are reserved words
      If Length(l_reserved_word) = 1 Then
      gReservedOperators(gNumReservedOperators) := l_reserved_word;
      gNumReservedOperators := gNumReservedOperators + 1;
      END IF;

  END LOOP;
  CLOSE CV;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Compl InitReservedFunctions', FND_LOG.LEVEL_PROCEDURE);--commit;
    bsc_mo_helper_pkg.writeTmp( 'gReservedOperators are', FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.write_this(gReservedOperators, FND_LOG.LEVEL_STATEMENT);
  END IF;

  EXCEPTION WHEN others then
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in InitReservedFunctions', FND_LOG.LEVEL_UNEXPECTED, TRUE);
  RAISE;
END;


PROCEDURE logProgress(pStage IN VARCHAR2, pMessage IN VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  g_progressCounter := g_progressCounter+1;

  INSERT INTO BSC_TMP_BIG_IN_COND(session_id, VARIABLE_ID, VALUE_N, VALUE_V)
  values   (USERENV('SESSIONID'), -200, g_progressCounter,
  pStage||' '||pMessage||' '||bsc_mo_helper_pkg.get_time);
  commit;
  EXCEPTION WHEN others then
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in logProgress'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    RAISE;
END;

function is_totally_shared_obj(p_objective in number) return boolean is
cursor cShared(p_pattern varchar2) is
select count(1) from bsc_kpis_vl
where indicator=p_objective
and share_flag=2
and not exists (select 1 from bsc_db_tables where instr(table_name, p_pattern)>0);
l_count number;
begin
  open cShared ('BSC_S_'||p_objective||'_') ;
  fetch cShared into l_count;
  close cShared;
  if l_count>0 then
    return true;
  else
    return false;
  end if;
end;

/***********************************************************************
  DESCRIPTION:
     This PROCEDURE is the body of the Metadata Optimizer process
     Form this PROCEDURE are called all the sub-process
     1. Initialize system
     2. Dimension Tables
     3. Indicators tables
     4. Input Tables
     5. Create tables in the database
     6. Configure Loader
     7. Documentation

  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
*************************************************************************/

PROCEDURE  GenerateActualization IS
i NUMBER;
j NUMBER;
Indicator  clsIndicator;
msg  VARCHAR2(1000);
l_msg_metadata_proc_completion VARCHAR2(1000);
l_msg_path_file_creation VARCHAR2(1000);
l_msg_system_table_descrip VARCHAR2(1000);
l_msg_system_conf_tree VARCHAR2(1000);
l_msg_metadata_opt_result VARCHAR2(1000);

indic clsIndicator;

l_count NUMBER;
advSumLevel NUMBER;
l_stmt VARCHAR2(1000);

l_error VARCHAR2(1000);
l_num number;
l_aw_kpi_list DBMS_SQL.VARCHAR2_TABLE;

l_dummy1 varchar2(1000);
l_dummy2 varchar2(1000);
BEGIN
  bsc_mo_helper_pkg.writeTmp('Inside GenerateActualization, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp('Starting InitializePeriodicities, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INIT', 'Starting InitializePeriodicities');
  BSC_MO_HELPER_PKG.InitializePeriodicities;
  IF (g_retcode = 0) THEN
     logProgress('INIT', 'Completed InitializePeriodicities');
  ELSE
    logProgress('INIT', 'InitializePeriodicities return code='||g_retcode||', so quitting');
    return;
  END IF;
  bsc_mo_helper_pkg.writeTmp('Starting InitializeCalendars, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INIT', 'Starting InitializeCalendars');
  BSC_MO_HELPER_PKG.InitializeCalendars;
  logProgress('INIT', 'Completed InitializeCalendars');
  IF (g_retcode = 0) THEN
    logProgress('INIT', 'Completed InitializeCalendars');
  ELSE
    logProgress('INIT', 'InitializeCalendars return code='||g_retcode||', so quitting');
    return;
  END IF;
  If gSYSTEM_STAGE = 2 Then
    -- Create _LAST tables. This tables are to
    -- get old input tables for the each kpi for
    -- the result report.
    logProgress('INIT', 'Starting CreateLastTables');
    bsc_mo_helper_pkg.CreateLastTables;
    logProgress('INIT', 'Completed CreateLastTables');
    bsc_mo_helper_pkg.writeTmp('Done with createLastTables, system time is '||
        bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
    --Initialize array of old kpis and old base tables.
    --This is done based on _LAST tables.
    logProgress('INIT', 'Starting InitInfoOldSystem');
    bsc_mo_helper_pkg.writeTmp('Starting InitInfoOldSystem, system time is '||
      bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
    bsc_mo_helper_pkg.InitInfoOldSystem;
    bsc_mo_helper_pkg.writeTmp('Done InitInfoOldSystem, system time is '||
      bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
    logProgress('INIT', 'Completed InitInfoOldSystem');
  End If;
  writeTableCounts;
  bsc_mo_helper_pkg.writeTmp('Calling deletePreviousRunTables, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INIT', 'Starting deletePreviousRunTables');
  bsc_mo_helper_pkg.deletePreviousRunTables;
  logProgress('INIT', 'Completed deletePreviousRunTables');
  bsc_mo_helper_pkg.writeTmp('Done with deletePreviousRunTables, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  writeTableCounts;
  ------------------------------------------------------------
  --Indicator Tables
  --BSC-MV Note: Process indicator tables when there is structural changes
  --or when there is summarization level change
  bsc_mo_helper_pkg.writeTmp('Starting Indicator tables, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INDICATORS', 'Starting IndicatorTables');
  BSC_MO_INDICATOR_PKG.IndicatorTables;
  logProgress('INDICATORS', 'Completed IndicatorTables');
  bsc_mo_helper_pkg.writeTmp('Done with Indicator tables, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( newline||newline, FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.writeTmp( 'gTables is ', FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.write_this(BSC_METADATA_OPTIMIZER_PKG.gTables, FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.writeTmp( newline||newline, FND_LOG.LEVEL_STATEMENT);
  END IF;
  ------------------------------------------------------------
  --Input tables
      --BSC-MV Note: We need to process input tables when there is structural changes
      --or when there is summarization level change (upgrade case only)
  bsc_mo_helper_pkg.writeTmp('Starting InputTables in GenerateActualization, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);

  logProgress('INPUT', 'Starting InputTables');
  BSC_MO_INPUT_TABLE_PKG.InputTables;
  logProgress('INPUT', 'Completed InputTables');
  bsc_mo_helper_pkg.writeTmp('Done with InputTables in GenerateActualization, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'gTables is ', FND_LOG.LEVEL_STATEMENT, false);
    bsc_mo_helper_pkg.write_this(BSC_METADATA_OPTIMIZER_PKG.gTables, FND_LOG.LEVEL_STATEMENT, false, true);
    bsc_mo_helper_pkg.writeTmp( ' ');
  END IF;
  ------------------------------------------------------------
  --Loader Configuration
  bsc_mo_helper_pkg.writeTmp('Starting Loader Configuration, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
    --BSC-MV Note: We need to configure loader when there is structural changes
    --or when there is summarization level change (upgrade case only)

  logProgress('CONFIG', 'Starting Loader Configuration');
  BSC_MO_LOADER_CONFIG_PKG.ConfigureActualization;
  logProgress('CONFIG', 'Completed Loader Configuration');
  bsc_mo_helper_pkg.writeTmp('Done Loader Configuration... '||
    'checking for incremental changes, system time is '||bsc_mo_helper_pkg.get_time,
    FND_LOG.LEVEL_STATEMENT, true);

  If gGAA_RUN_MODE <> 0 Then -- incremental
    IF (gIndicators.count>0 ) THEN
      i := gIndicators.first;
      LOOP
        Indic := gIndicators(i);
        If Indic.Action_Flag = 4 Then
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            bsc_mo_helper_pkg.writeTmp( 'Has non structural change, calling ReConfigureUploadFieldsIndic', FND_LOG.LEVEL_STATEMENT);
          END IF;
          BSC_MO_LOADER_CONFIG_PKG.ReConfigureUploadFieldsIndic (Indic.Code);

          --EDW Note: The materialize views are created taking rollup
          --functions from BSC Metadata. So We need to recreate the
          --Materialized views.
          If Indic.EDW_Flag = 1 Then
            BSC_MO_LOADER_CONFIG_PKG.ReCreateMaterializedViewsIndic   (Indic.Code);
          End If;
        End If;
        EXIT WHEN i = gIndicators.last;
        i := gIndicators.next(i);
      END LOOP;
    END IF;
  End If;
  logProgress('CONFIG', 'Completed All of ConfigureActualization');
  bsc_mo_helper_pkg.writeTmp('Done Loader Configuration, system time is '||
  bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  writeTableCounts;
  logProgress('MISC', 'Starting drop_unused_columns');
  IF BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 2 THEN
    bsc_mo_helper_pkg.writeTmp('Starting drop_unused_columns');
    bsc_mo_helper_pkg.drop_unused_columns(null);
    bsc_mo_helper_pkg.writeTmp('Done drop_unused_columns');
  END IF;
  -- Adjustments
  --BSC-MV Note: Process indicators when there is structural changes
  --or when there is summarization level change
  bsc_mo_helper_pkg.writeTmp('Starting Corrections, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);

  logProgress('MISC', 'Starting Corrections');
  BSC_MO_LOADER_CONFIG_PKG.Corrections;
  logProgress('MISC', 'Completed Corrections');
  bsc_mo_helper_pkg.writeTmp('Done with Corrections, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  writetableCounts;

  --Create tables in the database
  --BSC-MV Note: Process tables when there is structural changes
  --or when there is summarization level change
  bsc_mo_helper_pkg.writeTmp('Starting CreateAllTables,system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('DB', 'Starting CreateAllTables');
  BSC_MO_DB_PKG.CreateAllTables;
  logProgress('DB', 'Completed CreateAllTables');
  bsc_mo_helper_pkg.writeTmp('Done with CreateAllTables, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  writetableCounts;
  --Initialize year
  --bug#3426728 Need to run reporting calendar before creating MVs
  bsc_mo_helper_pkg.writeTmp('Initializing year', FND_LOG.LEVEL_STATEMENT, true);
  logProgress('MISC', 'Starting InitializeYear');
  BSC_MO_HELPER_PKG.InitializeYear;
  logProgress('MISC', 'Completed InitializeYear');
  writetableCounts;

  --BSC-MV Note: In upgrade mode, we need to populate reporting calendar for first time
  IF g_bsc_mv THEN
    logProgress('MISC', 'Starting Load_Reporting_Calendar');
    bsc_mo_helper_pkg.load_reporting_calendars;
    logProgress('MISC', 'Completed Load_Reporting_Calendar');
  END IF;
  --BSC-MV Note: Drop reporting key global temporary tables
  If g_BSC_MV Then
   bsc_mo_helper_pkg.writeTmp('Drop reporting key global temporary tables', FND_LOG.LEVEL_STATEMENT, true);
    logProgress('MISC', 'Drop reporting key global temporary tables');
    BSC_BIA_WRAPPER.Drop_Rpt_Key_Table_VB(NULL);
    BSC_MO_HELPER_PKG.CheckError('BSC_BIA_WRAPPER.Drop_Rpt_Key_Table_VB');
    writetableCounts;
  End If;
  --BSC-MV Note: Create the MVs for the Kpis.
  --Only for APPS systems.
  --For each Kpi with structural change or with non-structural changes,
  --implement the MV where it is appropiate.
  IF g_BSC_MV THEN
    -- Create DBI Dimension tables.
    -- Added 03/14/2005 for AW project
    IF NOT bsc_update_dim.create_dbi_dim_tables(l_error) THEN
      logprogress('ERROR', 'Exception in bsc_update_dim.create_dbi_dim_tables');
      BSC_MO_HELPER_PKG.TerminateWithMsg('EXCEPTION in bsc_update_dim.create_dbi_dim_tables : '||l_error, FND_LOG.LEVEL_UNEXPECTED);
      raise  optimizer_exception;
	END IF;
    bsc_mo_helper_pkg.writeTmp('Create MVs for all Indicators', FND_LOG.LEVEL_STATEMENT, true);
    logProgress('DB', 'Starting CreateMVs');
    writetableCounts;
    --For kpis with structural changes or non-structural changes
    --Also create MVs when summarization level has changed
    l_count := gIndicators.first;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Total indics = '||gIndicators.count, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    LOOP
      EXIT WHEN gIndicators.count = 0;
      indic := gIndicators(l_count);
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Processing Indic '||l_count);
      END IF;
        --totally shared objectives dont need MVs or AW summary objects
      IF not is_totally_shared_obj(Indic.code) then
        IF (Indic.impl_type=2) THEN
          IF (Indic.Action_Flag = 3 OR Indic.Action_flag=4) THEN
            bsc_mo_helper_pkg.writeTmp('AW implementation, so dont create MVs');
            l_aw_kpi_list(l_aw_kpi_list.count+1) := Indic.code;
          END IF;
        ELSIF (Indic.Action_Flag = 3 Or Indic.Action_Flag = 4) Or (Indic.Action_Flag = 0 And g_Sum_Level_Change <> 0) Then
          advSumLevel := to_number(g_Adv_Summarization_Level);
          --BSC-MV Note: If the change is only the summarization level (example from 2 to 3)
          --we pass pass Reset MV Levels in TRUE
           bsc_mo_helper_pkg.writeTmp('Calling Create MV for Indicator '||Indic.code||', Time is '||
             bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, false);
          logProgress('MV', 'Creating MV for '||Indic.code);
          If Indic.Action_Flag = 0 And g_Sum_Level_Change = 2 Then
            BSC_BIA_WRAPPER.Implement_Bsc_MV_VB(indic.code, advSumLevel, TRUE);
          Else
            BSC_BIA_WRAPPER.Implement_Bsc_MV_VB(indic.code, advSumLevel, FALSE);
          End If;
          logProgress('MISC', 'Compl creating MV for '||Indic.code||', checking error');
          BSC_MO_HELPER_PKG.CheckError('BSC_BIA_WRAPPER.Implement_Bsc_MV_VB');
        End If;
      END IF;  -- totally shared
      EXIT WHEN l_count = gIndicators.last;
      l_count := gIndicators.next(l_count);
    END LOOP;
    logProgress('DB', 'Completed CreateMVs');
    IF (l_aw_kpi_list.count>0) THEN
      logProgress('DB', 'Calling CreateAW');
      bsc_mo_helper_pkg.writeTmp('Implementing AW objectives');
      bsc_mo_helper_pkg.implement_aws(l_aw_kpi_list);
      logProgress('DB', 'Completed Creating AWs');
    END IF;
    --Drop the tmp table created to store the CODE datatype
    --Bug 3878968
    if(BSC_OLAP_MAIN.b_table_col_type_created) then
      BSC_OLAP_MAIN.drop_tmp_col_type_table;
    end if;
  END IF;
  writetableCounts;
  logProgress('MISC', 'Completed Reporting calendar calls');
  --Clean un-used tables from the database
  --This is just to make sure that the system is clean after user run Metadata Optmizer
  --It will drop all tables that are not being used by any indidator.
  --This situation should not happen, but due to some unkown issue in the past
  --some tables could be there but no indicator is using it.

  bsc_mo_helper_pkg.writeTmp('Starting CleanDatabase, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  logProgress('MISC', 'Starting CleanDatabase');
  BSC_MO_HELPER_PKG.CleanDatabase;
  logProgress('MISC', 'Completed CleanDatabase');
  writeTableCounts;

  --Generate documentation
    bsc_mo_helper_pkg.writeTmp('Starting Doc, system time is '||bsc_mo_helper_pkg.get_time,
      FND_LOG.LEVEL_STATEMENT, true);
  logProgress('DOC', 'Starting Doc');
  BSC_MO_DOC_PKG.Documentation(1);
  logProgress('DOC', 'Completed Doc');
  bsc_mo_helper_pkg.writeTmp('Done with Doc, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  writetableCounts;
  bsc_mo_helper_pkg.writeTmp('Starting UpdateFlags, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  logProgress('MISC', 'Calling UpdateFlags');
  --Update flags
  BSC_MO_HELPER_PKG.UpdateFlags;
  logProgress('MISC', 'Completed UpdateFlags');
  bsc_mo_helper_pkg.writeTmp('Done with UpdateFlags, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  -- Call OUT API to populate display tables used by the UI
  BEGIN
    logProgress('MISC', 'Calling BSC_PMD_OPT_DOC_UTIL.GEN_TBL_RELS_DISPLAY');
    execute immediate 'begin BSC_PMD_OPT_DOC_UTIL.GEN_TBL_RELS_DISPLAY; end;';
    logProgress('MISC', 'Completed BSC_PMD_OPT_DOC_UTIL.GEN_TBL_RELS_DISPLAY');
    EXCEPTION when others then
      l_error := sqlerrm;
      bsc_mo_helper_pkg.writeTmp('EXCEPTION in UI Call OUT BSC_PMD_OPT_DOC_UTIL.GEN_TBL_RELS_DISPLAY : '||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
  END;
  bsc_mo_helper_pkg.writeTmp('Done with display tables API call, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  writeTableCounts;

  fnd_stats.gather_table_stats(l_dummy1, l_dummy2, gBSCSchema,'BSC_KPI_DATA_TABLES');

  EXCEPTION when others then
    logprogress('ERROR', 'Exception in generateACtualization');
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('EXCEPTION in generateACtualization : '||l_error, FND_LOG.LEVEL_UNEXPECTED);
    RAISE;
END;

PROCEDURE initMVFlags IS
BEGIN
  --BSC-MV Note: Get advanced summarization level profile value
  g_Sum_Level_Change := 0;
  g_Adv_Summarization_Level := fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');
  g_Current_Adv_Sum_Level := bsc_mo_helper_pkg.getInitColumn('ADV_SUM_LEVEL');

  If (g_Current_Adv_Sum_Level IS NOT NULL AND g_Adv_Summarization_Level IS NULL) Then
      --User cannot go back to old architecture.
      bsc_mo_helper_pkg.writeTmp('Current MV levels ='||g_Current_Adv_Sum_Level ||', Target MV levels='||g_Adv_Summarization_Level, FND_LOG.LEVEL_STATEMENT,true);
      bsc_mo_helper_pkg.writeTmp('Cannot go back to Summary table architecture', FND_LOG.LEVEL_STATEMENT, true); --force this OUT
      BSC_MO_HELPER_PKG.TerminateWithError('BSC_SUM_LEVEL_INVALID');
      raise optimizer_exception;
      return;
  End If;

  --Bug 3305148: Even in gSYSTEM_STAGE=1 we need to set g_Sum_Level_Change = 1
  --when it is the first time the system runs in MV architecture.

  If (g_Current_Adv_Sum_Level IS NULL ) And (g_Adv_Summarization_Level IS NOT NULL) Then
    --User wants to uptake the new architecture. Show warning messages.
    IF (bsc_metadata_optimizer_pkg.gGAA_RUN_MODE=0) THEN
      g_sum_level_change := 0;  -- Entire system running for MVs first time, so not an upgrade
    ELSE
      g_Sum_Level_Change := 1; --Upgrade to new architecture (null to notnull)
    END IF;
    bsc_mo_helper_pkg.writeTmp('Upgrading to MV architecture, MV levels='|| g_Adv_Summarization_Level , FND_LOG.LEVEL_STATEMENT, true);
  Else
    If g_Current_Adv_Sum_Level <> g_Adv_Summarization_Level Then
      g_Sum_Level_Change := 2;
    Else
      g_Sum_Level_Change := 0;
    End If;
    bsc_mo_helper_pkg.writeTmp('Current MV level = '||g_Current_Adv_Sum_Level||', Target MV level = '|| g_Adv_Summarization_Level , FND_LOG.LEVEL_STATEMENT, true); --force this OUT
  End If;
  If g_Adv_Summarization_Level IS NULL Then
    bsc_mo_helper_pkg.writeTmp('Summary Table architecture', FND_LOG.LEVEL_STATEMENT, true);
    g_BSC_MV := False;
  Else
    bsc_mo_helper_pkg.writeTmp('MV architecture', FND_LOG.LEVEL_STATEMENT, true);
    g_BSC_MV := True;
  End If;
END;

FUNCTION get_partition_clause return VARCHAR2 IS
l_stmt varchar2(1000);
BEGIN
  if g_num_partitions <2 then
    return null;
  end if;
  l_stmt := ' partition by list('||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||') (';
  for i in 1..g_num_partitions loop
    if (i>1) then -- need comma
      l_stmt := l_stmt ||',';
    end if;
    l_stmt := l_stmt ||' partition p_'||(i-1)||' values('||(i-1)||')';
  end loop;
  l_stmt := l_stmt ||')';
  return l_stmt;
END;

PROCEDURE InitGlobalVars IS
BEGIN
  bsc_mo_helper_pkg.writeTmp('Inside InitGlobalVars', FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INIT', 'Starting InitGlobalVars');
  InitLanguages;
  InitReservedFunctions;
  BSC_MO_HELPER_PKG.InitArrReservedWords;
  gSYSTEM_STAGE := BSC_MO_HELPER_PKG.getInitColumn('SYSTEM_STAGE');

  gStorageClause := BSC_MO_HELPER_PKG.getStorageClause;

  BSC_MO_HELPER_PKG.InitTablespaceNames;

  gAppsSchema := BSC_MO_HELPER_PKG.getAppsSchema;
  gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
  gApplsysSchema := BSC_MO_HELPER_PKG.getApplsysSchema;
  g_num_partitions := bsc_dbgen_metadata_reader.get_max_partitions;
  g_partition_clause := get_partition_clause;
  -- Initialize DImension tables
  logProgress('INIT', 'Starting InitializeMasterTables');
  bsc_mo_helper_pkg.InitializeMasterTables;
  logProgress('INIT', 'Starting CreateKPIDataTableTmp');
  bsc_mo_helper_pkg.CreateKPIDataTableTmp;
  logProgress('INIT', 'Starting CreateDBMeasureByDimSetTmp');
  bsc_mo_helper_pkg.CreateDBMeasureByDimSetTmp;

  logProgress('INIT', 'Starting CreateKPIDataTableTmp');
  bsc_mo_helper_pkg.CreateKPIDataTableTmp;

  logProgress('INIT', 'Starting CheckAllIndicsHaveSystem');
  If gGAA_RUN_MODE = 0 Then -- entire system
    BSC_MO_HELPER_PKG.CheckAllIndicsHaveSystem;
  END IF;
  --bsc_mo_helper_pkg.CheckError('BSC_SECURITY.CHECK_SYSTEM_LOCK');
  logProgress('INIT', 'Starting CheckAllSharedIndicsSync');
  BSC_MO_HELPER_PKG.CheckAllSharedIndicsSync;

  --Check all EDW kpis have been fully mapped. Dimensions, Periodicities, Datasets are from EDW
   --logProgress('INIT', 'Starting CheckAllEDWIndicsFullyMapped');
  --BSC_MO_HELPER_PKG.CheckAllEDWIndicsFullyMapped;

  --Initalize collection of indicators
  logProgress('INIT', 'Starting initIndicators');
  BSC_MO_HELPER_PKG.initIndicators;
  logProgress('INIT', 'Completed initIndicators');

  IF (g_retcode <> 0) THEN
     bsc_mo_helper_pkg.writeTmp('initIndicators did not succeed :'||g_errbuf);
     return;
  END IF;

  IF (BSC_MO_HELPER_PKG.validate_dimension_views=false) THEN
    bsc_mo_helper_pkg.TerminateWithMsg('Validating Dimension Views did not succeed :'||sqlerrm);
    return;
  END IF;

  If gIndicators.Count = 0 Then
      If gSYSTEM_STAGE = 1 Then
        --There is no configured indicators
        BSC_MO_HELPER_PKG.TerminateWithError ('BSC_KPIS_MISSING', 'InitGlobalVars');
        return;
      Else
        --There is no changed indicators
        BSC_MO_HELPER_PKG.TerminateWithError ('BSC_NO_PENDING_CHANGES', 'Init');
        fnd_message.set_name('BSC', 'BSC_NO_PENDING_CHANGES');
		g_retcode := 1;
		g_errbuf := fnd_message.get;
        return;
      End If;
  End If;
  -- called again to add measures for only the current objectives
  logProgress('INIT', 'Starting CreateDBMeasureByDimSetTmp');
  bsc_mo_helper_pkg.CreateDBMeasureByDimSetTmp;
  logProgress('INIT', 'Starting initLOV');
  BSC_MO_HELPER_PKG.InitLOV;
  logProgress('INIT', 'Completed initLOV');
  bsc_mo_helper_pkg.writeTmp('Completed InitGlobalVars', FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INIT', 'Completed InitGlobalVars');
  EXCEPTION when others then
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in InitGlobalVars:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    RAISE;
END;

PROCEDURE writeKPIList IS
cursor cList IS
SELECT KPIS.INDICATOR, KPIS.NAME, KPIS.PROTOTYPE_FLAG , decode(nvl(prop.property_value, 1), 1, 'Summary Tables/MVs', 'Analytical Workspace') impl_type
FROM BSC_KPIS_VL KPIS, BSC_KPI_PROPERTIES prop
WHERE kpis.INDICATOR IN
(SELECT INDICATOR FROM BSC_TMP_OPT_UI_KPIS WHERE process_id=g_processID)
AND kpis.indicator=prop.indicator(+)
and prop.property_code(+) = 'IMPLEMENTATION_TYPE'
order by indicator;
BEGIN
  FOR i IN cList LOOP
    bsc_mo_helper_pkg.writeTmp('Code = '||i.indicator||', Name ='||i.name||', prototype_flag='||i.prototype_flag||', Implementation='||i.impl_type, FND_LOG.LEVEL_PROCEDURE, true);
  END LOOP;
END;

PROCEDURE Setup IS
l_error VARCHAR2(4000);
BEGIN

  bsc_apps.init_bsc_apps;
  g_bsc_apps_initialized := true;
  bsc_apps.Init_Big_In_Cond_Table;
  logProgress('INIT', 'Starting Setup');
  g_dir := null;
  g_dir:=fnd_profile.value('UTL_FILE_LOG');
  IF g_dir is null THEN
    g_dir:=getUtlFileDir;
  END IF;
  g_log_level := fnd_profile.value('AFLOG_LEVEL');
  IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
    g_log := TRUE;
  ELSE -- IF BIS_PMF_DEBUG is set, then enable logging automatically
    g_log_level := FND_LOG.g_current_runtime_level;
  END IF;
  IF (g_dir is null OR fnd_global.CONC_REQUEST_ID = -1) THEN -- run manually
    BSC_METADATA_OPTIMIZER_PKG.g_dir:=BSC_METADATA_OPTIMIZER_PKG.getUtlFileDir;
    g_log := TRUE;
    g_log_level := FND_LOG.LEVEL_STATEMENT;
  END IF;
  g_log_level := FND_LOG.LEVEL_STATEMENT;
  fnd_file.put_names(g_filename||'.log', g_filename||'.OUT', g_dir);
  g_fileOpened := TRUE;
  --g_doc_file := utl_file.fOPEN(g_dir, 'METADATA.OUT' ,'w');
  logProgress('INIT', 'Completed Setup');

  bsc_mo_helper_pkg.writeTmp('---------------------------------------------------------'
    ||newline, fnd_log.level_procedure, true);
  bsc_mo_helper_pkg.writeTmp('Database Generator, Start Time is '
    ||bsc_mo_helper_pkg.get_time, fnd_log.level_procedure, true);
  bsc_mo_helper_pkg.writeTmp('---------------------------------------------------------'
    ||newline, fnd_log.level_procedure, true);
  bsc_mo_helper_pkg.writeTmp(newline);
  bsc_mo_helper_pkg.writeTmp('Logging = '||bsc_mo_helper_pkg.boolean_decode(g_log)||
    ', logging level='||g_log_level, FND_LOG.LEVEL_PROCEDURE, true);

  EXCEPTION WHEN OTHERS THEN
     l_error := sqlerrm;
  bsc_mo_helper_pkg.writeTmp('EXCEPTION in Setup : '||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
  bsc_mo_helper_pkg.TerminatewithMsg('EXCEPTION in Seti[ : '||l_error);
  RAISE;
end;

PROCEDURE Initialize IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_error VARCHAR2(4000);
begin

  IF (g_debug) THEN
     bsc_message.init('Y');
  ELSE
     bsc_message.init('N');
  END IF;
  logProgress('INIT', 'Completed bsc_message.init');
  logProgress('INIT', 'Starting initMVFlags');
  initMVFlags;
  logProgress('INIT', 'Completed initMVFlags');
  IF (gGAA_RUN_MODE=0) THEN
    bsc_mo_helper_pkg.writeTmp('Processing all objectives', FND_LOG.LEVEL_STATEMENT, true);
  ELSIF (gGAA_RUN_MODE=1) THEN
    bsc_mo_helper_pkg.writeTmp('Processing modified objectives', FND_LOG.LEVEL_STATEMENT, true);
    writeKPIList;
  ELSIF (gGAA_RUN_MODE=2) THEN
    bsc_mo_helper_pkg.writeTmp('Processing selected objectives', FND_LOG.LEVEL_STATEMENT, true);
    writeKPIList;
  ELSE
    bsc_mo_helper_pkg.writeTmp('Processing selected reports', FND_LOG.LEVEL_STATEMENT, true);
    writeKPIList;
  END IF;
  bsc_mo_helper_pkg.writeTmp('---------------------------------------------------------'
    ||newline, fnd_log.level_procedure, true);

  bsc_mo_helper_pkg.writeTmp(' ',  FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp('Starting database generation process ',  FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp('Initializing System', FND_LOG.LEVEL_PROCEDURE, true);

  InitGlobalVars;
  IF (g_retcode <> 0) THEN
     bsc_mo_helper_pkg.writeTmp('InitGlobalVars did not succeed :'||g_errbuf);
     --autonomous txn, have to commit
     commit;
     return;
  END IF;
  -- new logging to check metadata corruption
  createTmpLogTables;
  IF (g_retcode <> 0) THEN
     bsc_mo_helper_pkg.writeTmp('createTmpLogTables did not succeed :'||g_errbuf);
     --autonomous txn, have to commit
     commit;
     return;
  END IF;
  bsc_mo_helper_pkg.writeTmp('Initialization completed.', FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('INIT', 'Completed Initialize');
  --autonomous txn, have to commit
  commit;
  EXCEPTION when others then
  l_error := sqlerrm;
  bsc_mo_helper_pkg.writeTmp('EXCEPTION in Initialize : '||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
  bsc_mo_helper_pkg.TerminatewithMsg('EXCEPTION in Initialize : '||l_error);
  commit;
  RAISE;
END;

PROCEDURE wrapup IS
l_docRequestID NUMBER :=0;
x_return_status varchar2(1000);
x_msg_count number;
x_msg_data varchar2(1000);

BEGIN

  bsc_mo_helper_pkg.writeTmp('Inside Wrapup', FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp('Starting Doc CP, system time is '||
    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  --Launch doc as a separate process
  l_docRequestID := FND_REQUEST.SUBMIT_REQUEST(
              application=>'BSC',
              program=>'BSC_METADATA_OPTIMIZER_DOC');

  commit;
  logProgress('DOC', 'Completed Submitting Doc process, request id = '||l_docRequestID);
  bsc_mo_helper_pkg.writeTmp('Done with Doc, system time is '||
  bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp('Starting Doc CP, system time is '||
  bsc_mo_helper_pkg.get_time||', request id = '||l_docRequestID, FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp('Submitted Doc process, request id = '||l_docRequestID, FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp(' ', FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp(' ', FND_LOG.LEVEL_STATEMENT, true);
  bsc_mo_helper_pkg.writeTmp(' ', FND_LOG.LEVEL_STATEMENT, true);
  BEGIN
    logProgress('MISC', 'Calling BSC_LOCKS_PUB.SYNCHRONIZE');
    BSC_LOCKS_PUB.SYNCHRONIZE (-200, BSC_APPS.apps_user_id, x_return_status, x_msg_count, x_msg_data);
    logProgress('MISC', 'Completed BSC_LOCKS_PUB.SYNCHRONIZE');
    EXCEPTION when others then
      g_retcode := 1;
      bsc_mo_helper_pkg.writeTmp('WARNING: EXCEPTION in Call OUT BSC_LOCKS_PUB.SYNCHRONIZE : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
  END;
  bsc_mo_helper_pkg.writeTmp('Completed Wrapup', FND_LOG.LEVEL_PROCEDURE, true);
  EXCEPTION when others then
      logProgress('ALL', 'Exception in wrapup:'||sqlerrm);
      bsc_mo_helper_pkg.writeTmp('Uh oh... EXCEPTION in Wrapup : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
  RAISE;
END;

PROCEDURE  run_metadata_optimizer_pvt IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF (g_retcode = 0) THEN
      GenerateActualization;
  ELSE
     bsc_mo_helper_pkg.writeTmp('Initalize did not succeed :'||g_errbuf);
  END IF;
  --bsc_security.Delete_Bsc_Session;
  bsc_locks_pub.REMOVE_SYSTEM_LOCK;
  IF (g_retcode = 0) THEN
    logProgress('ALL', 'Completed GenerateActualization');
    Wrapup;
    logProgress('ALL', 'Completed Wrapup, retcode='||g_retcode);
  ELSE
    bsc_mo_helper_pkg.writeTmp('GenerateActualization did not succeed :retcode='||g_retcode||', error buffer='||g_errbuf, FND_LOG.level_exception, true);
    logProgress('ALL', 'GenerateActualization did not succeed :retcode='||g_retcode||', error buffer='||g_errbuf);
  END IF;

  bsc_mo_helper_pkg.writeTmp('System time is '|| bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp('Completed Generating Database, releasing file handle after the following message.... goodbye' , FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp(' ', FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp('---------------------------------------------------------', FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp('Generate Database process has completed successfully. Now, you must load data ', FND_LOG.LEVEL_PROCEDURE, true);
  bsc_mo_helper_pkg.writeTmp('in the Interface Tables and run Data Loader to get information in the system.', FND_LOG.LEVEL_PROCEDURE, true);
  logProgress('ALL', 'Completed Generate Database successfully');
  fnd_file.release_names(g_filename||'.log', g_filename||'.OUT');
  g_fileOpened := false;
  commit;
END;

PROCEDURE Init_Locks IS
x_return_status varchar2(1000);
x_msg_count number;
x_msg_data varchar2(1000);
l_logging_flag boolean;
BEGIN
  l_logging_flag := g_log;
  g_log := false;
  FND_MSG_PUB.Initialize;
  BSC_LOCKS_PUB.GET_SYSTEM_LOCK (-200,BSC_APPS.apps_user_id, -1, x_return_status, x_msg_count, x_msg_data);
  IF (gGAA_RUN_MODE = 0) THEN -- whole system
    bsc_mo_helper_pkg.writeTmp('LOCKING going to lock entire system ', fnd_log.level_statement, true);
    BSC_LOCKS_PUB.GET_SYSTEM_LOCK ('OBJECTIVE', 'W', sysdate, -200,
         BSC_APPS.apps_user_id, -1, x_return_status, x_msg_count, x_msg_data);
    IF (x_return_status<>   FND_API.G_RET_STS_SUCCESS) THEN
      bsc_mo_helper_pkg.writeTmp('EXCEPTION while trying to Lock in Initialize : '||
                                    x_msg_data, FND_LOG.LEVEL_UNEXPECTED, true);
      bsc_mo_helper_pkg.TerminateWithMsg(x_msg_data);
      fnd_message.set_name('BSC', 'BSC_MUSERS_LOCKED_SYSTEM');
      app_exception.raise_exception;
      return;
    END IF;
  ELSE--selected or inter-related
    FOR i IN (select indicator from bsc_tmp_opt_ui_kpis where process_id = g_processID) LOOP
      logProgress('LOCK', 'Locking '||i.indicator);
      bsc_mo_helper_pkg.writeTmp('LOCKING going to lock objective '||i.indicator, fnd_log.level_statement, true);
      BSC_LOCKS_PUB.GET_SYSTEM_LOCK (
          i.indicator, 'OBJECTIVE', 'W', sysdate, -200,BSC_APPS.apps_user_id, -1, x_return_status, x_msg_count, x_msg_data);
      IF (x_return_status<>   FND_API.G_RET_STS_SUCCESS) THEN
        bsc_mo_helper_pkg.writeTmp('EXCEPTION while trying to Lock in Initialize : '||
                                      x_msg_data, FND_LOG.LEVEL_UNEXPECTED, true);
        bsc_mo_helper_pkg.TerminateWithMsg(x_msg_data);
        fnd_message.set_name('BSC', 'BSC_MUSERS_LOCKED_SYSTEM');
        app_exception.raise_exception;
        return;
      END IF;
    END LOOP;
  END IF;
  g_log := l_logging_flag;
  EXCEPTION WHEN OTHERS THEN
    g_retcode := 2;
    g_errbuf := x_msg_data;
    raise;
END;
PROCEDURE run_metadata_optimizer(
    Errbuf         OUT NOCOPY  Varchar2,
    Retcode        OUT NOCOPY  Varchar2,
    p_runMode     IN NUMBER, -- 0 ALL, 1 INCREMENTAL, 2 SELECTED , (9 obsolete)
    p_processID		IN NUMBER)
IS

BEGIN
  gGAA_RUN_MODE := p_runMode;
  g_retcode := 0;
  g_processID := p_processID;
  delete bsc_tmp_big_in_cond where variable_id = -200;
  Setup;
  Init_Locks;
  Initialize;
  run_metadata_optimizer_pvt;
  retcode := g_retcode;
  errbuf := g_errbuf;

  EXCEPTION
  when optimizer_exception then-- user defined exception, not a general failure
    logProgress('ALL', 'Failed to Generate Database, user_defined error:'||sqlerrm);
    retcode := g_retcode;
    errbuf := g_errbuf;
    --bsc_security.Delete_Bsc_Session;
    bsc_locks_pub.remove_system_lock;
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in run_metadata_optimizer : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    fnd_file.release_names(g_filename||'.log', g_filename||'.OUT');
  when others then -- general failure, dump the stack
    logProgress('ALL', 'Failed to Generate Database, general failure, dumping stack');
    retcode := g_retcode;
    errbuf := g_errbuf;
    --bsc_security.Delete_Bsc_Session;
    bsc_locks_pub.remove_system_lock;
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in run_metadata_optimizer : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.writeTmp('gTables is ', FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.write_this(gTables, FND_LOG.LEVEL_ERROR, true);
    bsc_mo_helper_pkg.dump_stack;
    fnd_file.release_names(g_filename||'.log', g_filename||'.OUT');
END;
PROCEDURE Documentation(
    Errbuf         OUT NOCOPY  Varchar2,
    Retcode    OUT NOCOPY  Varchar2) IS
 x_return_status varchar2(1000);
 x_msg_count number;
 x_msg_data varchar2(1000);
BEGIN
  gAppsSchema := BSC_MO_HELPER_PKG.getAppsSchema;
  gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
  gApplsysSchema := BSC_MO_HELPER_PKG.getApplsysSchema;
  -- modified call to include user_id so that session management module can recognise the
  -- session lock #bug 3593694
  --bsc_security.Check_System_Lock(-201,NULL,BSC_APPS.apps_user_id);
  bsc_mo_helper_pkg.writeTmp('LOCKING going to lock for documentation ', fnd_log.level_statement, true);
  BSC_LOCKS_PUB.GET_SYSTEM_LOCK(-201,BSC_APPS.apps_user_id, -1, x_return_status, x_msg_count, x_msg_data);
  IF (x_return_status<>   FND_API.G_RET_STS_SUCCESS) THEN
    bsc_mo_helper_pkg.writeTmp('EXCEPTION while trying to Lock in Initialize : '||x_msg_data, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.TerminateWithMsg(x_msg_data);
    fnd_message.set_name('BSC', 'BSC_MUSERS_LOCKED_SYSTEM');
    app_exception.raise_exception;
    return;
  END IF;

  BSC_MO_DOC_PKG.Documentation(2);
 -- bsc_security.Delete_Bsc_Session;
  bsc_locks_pub.remove_system_lock;
  EXCEPTION WHEN OTHERS THEN
    --bsc_security.Delete_Bsc_Session;
    bsc_locks_pub.remove_system_lock;
    bsc_mo_helper_pkg.writeTmp('EXCEPTION in Documentation : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    raise;
END;
END BSC_METADATA_OPTIMIZER_PKG;

/
