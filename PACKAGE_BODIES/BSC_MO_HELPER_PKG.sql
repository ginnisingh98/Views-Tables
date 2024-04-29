--------------------------------------------------------
--  DDL for Package Body BSC_MO_HELPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_HELPER_PKG" AS
/* $Header: BSCMOHPB.pls 120.39 2007/05/18 13:05:50 amitgupt ship $ */
g_write_count number := 0;
newline VARCHAR2(10):='
';
g_newline_length number:= length(newline);

TYPE cLookupMap IS RECORD(
value varchar2(2000));
TYPE tab_cLookupMap is table of cLookupMap index by VARCHAR2(300);
gLookup_Value tab_cLookupMap;

FUNCTION validate_dimension_views return BOOLEAN IS
 --  Bug 4937922 change to new api which returns error message correctly
 --  Moved API from PL/SQL for loop into SQL itself for performance
cursor cMissingViews is
select distinct sysdim.short_name, sysdim.level_view_name
  from bsc_sys_dim_levels_b sysdim,
       bsc_kpi_dim_levels_b kpidim,
       bsc_tmp_opt_ui_kpis  proc
 where proc.process_id = bsc_metadata_optimizer_pkg.g_ProcessID
   and proc.indicator=kpidim.indicator
   and kpidim.level_table_name = sysdim.level_table_name
   and sysdim.source = 'PMF'
   and BIS_UTILITIES_PVT.is_rolling_period_level(sysdim.short_name) = 0
minus
select sysdim.short_name, sysdim.level_view_name
  from user_views vws
     , bsc_sys_dim_levels_b sysdim
 where vws.view_name=sysdim.level_view_name;

x_return_status varchar2(1000);
x_msg_count number;
x_msg_data varchar2(1000);

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  FOR i in cMissingViews LOOP
    BSC_BIS_DIM_OBJ_PUB.Validate_Refresh_BSC_PMF_Views(i.short_name
        ,   x_return_status
        ,   x_msg_count
        ,   x_msg_data
    );
    --This API Requires Commit
    commit;
    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      writeTmp('Exception in BSC_BIS_DIM_OBJ_PUB.Validate_Refresh_BSC_PMF_Views for short_name='
                ||i.short_name||':'||x_msg_data, FND_LOG.LEVEL_EXCEPTION, true);
      raise BSC_METADATA_OPTIMIZER_PKG.optimizer_exception;
    ELSE
      writeTmp('Successfully generated BSC View '||i.level_view_name,  FND_LOG.LEVEL_EXCEPTION, true);
    END IF;
  END LOOP;
  commit;
  return true;

  EXCEPTION WHEN OTHERS THEN
    commit;
    TerminateWithMsg('Exception in validate_dimension_views:'||sqlerrm);
    return false;
END;

FUNCTION getSourceTable(p_table IN VARCHAR2) return VARCHAR2 IS
CURSOR cSource is
SELECT SOURCE_TABLE_NAME
FROM BSC_DB_TABLES_RELS
WHERE TABLE_NAME = p_table;
l_table VARCHAR2(100);
BEGIN
  OPEN cSource;
  FETCH cSource INTO l_table;
  CLOSE cSource;
  return l_table;
END;

FUNCTION filters_exist(p_kpi_number IN NUMBER, p_dim_set_id IN NUMBER, p_column_name IN VARCHAR2, p_filter_view OUT NOCOPY VARCHAR2) return boolean
IS
l_stmt varchar2(1000) := 'select level_view_name from '||BSC_METADATA_OPTIMIZER_PKG.g_filtered_indics||' where indicator=:1 and dim_set_id=:2 and level_pk_col=:3';
cv CurTyp;

BEGIN
  OPEN cv FOR l_stmt using p_kpi_number, p_dim_set_id, p_column_name;
  FETCH cv INTO p_filter_view;
  CLOSE cv;
  IF (p_filter_view IS NULL) THEN
    return false;
  ELSE
    return true;
  END IF;
END;

PROCEDURE DropAppsTables IS
l_count NUMBER;
l_stmt varchar2(1000);
BEGIN
  l_stmt := 'DROP TABLE ';
  l_count := bsc_metadata_optimizer_pkg.g_dropAppsTables.first;
  LOOP
    EXIT WHEN bsc_metadata_optimizer_pkg.g_dropAppsTables.count=0;
    begin
	execute immediate l_stmt||bsc_metadata_optimizer_pkg.g_dropAppsTables(l_count);
	exception when others then
	  null;
	end;
    EXIT WHEN l_count = bsc_metadata_optimizer_pkg.g_dropAppsTables.last;
    l_count := bsc_metadata_optimizer_pkg.g_dropAppsTables.next(l_count);
  END LOOP;
END;
-- performance fix, query bsc_kpi_Data_tables instead of bsc_kpi_data_tables_last
PROCEDURE CreateKPIDataTableTmp IS
  TableName varchar2(30);
  l_stmt varchar2(1000);

BEGIN
  bsc_metadata_optimizer_pkg.logProgress('INIT', 'Starting CreateKPIDataTableTmp');
  TableName := BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table ;
  DropTable(TableName);
  l_stmt := 'create table '||TableName||' TABLESPACE '|| BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName||' as ';
  --select distinct indicator, dim_set_id, table_name from bsc_kpi_data_tables';
  l_stmt := l_stmt || ' select distinct
       substr(table_name, instr(table_name, ''_'',  1, 2)+1, instr(table_name, ''_'',  1, 3)-instr(table_name, ''_'',  1, 2)-1) indicator,
       substr(table_name, instr(table_name, ''_'',  1, 3)+1, instr(table_name, ''_'',  1, 4)-instr(table_name, ''_'',  1, 3)-1) dim_set_id,
       table_name
       from bsc_db_tables_rels
       where table_name like ''BSC_S%''
       and (source_table_name like ''BSC_B%'' or source_table_name like ''BSC_T%'' )';

  do_ddl(l_stmt, ad_ddl.create_table, TableName);
  bsc_metadata_optimizer_pkg.logProgress('INIT', 'Created '||TableName);
  writeTmp('Created '||TableName, FND_LOG.LEVEL_STATEMENT, false);
  l_stmt := 'create unique index '||TableName||'_u1 on '||TableName||'(indicator, dim_set_id, table_name) TABLESPACE '||BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName;
  do_ddl(l_stmt, ad_ddl.create_index, TableName||'_U1');
  bsc_metadata_optimizer_pkg.logProgress('INIT', 'Created '||TableName||'_U1');
  writeTmp('Created index '||TableName||'_u1', FND_LOG.LEVEL_STATEMENT, false);
  l_stmt := 'create index '||TableName||'_n1 on '||TableName||'(table_name) TABLESPACE '||BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName;
  do_ddl(l_stmt, ad_ddl.create_index, TableName||'_N1');
  writeTmp('Created index '||TableName||'_n1', FND_LOG.LEVEL_STATEMENT, false);
  bsc_metadata_optimizer_pkg.logProgress('INIT', 'Created '||TableName||'_N1');
  bsc_metadata_optimizer_pkg.logProgress('INIT', 'Completed CreateKPIDataTableTmp');

  exception when others then
    writeTmp('Exception in CreateKPIDataTableTmp :'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    writeTmp('Exception in CreateKPIDataTableTmp stmt= :'||l_stmt, FND_LOG.LEVEL_EXCEPTION, true);
  	raise;
END;

-- performance fix, query bsc_kpi_Data_tables_ind instead of bsc_kpi_data_tables_last
PROCEDURE CreateDBMeasureByDimSetTmp IS
  TableName varchar2(30);
  l_stmt varchar2(1000);
  l_count NUMBER;
  cv   CurTyp;
  strWhereInIndics VARCHAR2(1000);
  l_index_name varchar2(30);
BEGIN
  return;
  -- using a SQL instead now...
END;

FUNCTION find_objectives_for_table_old(p_table IN VARCHAR2) return BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet  IS
CURSOR cObjectives IS
select distinct indicator, dim_set_id from bsc_kpi_data_tables
where table_name in
(select table_name from bsc_db_tables_rels
where table_name like 'BSC_S%'
connect by prior table_name = source_table_name
start with table_name = p_table);
l_objective number;
l_dim_set number;
l_results BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet;
l_KPI BSC_METADATA_OPTIMIZER_PKG.clsKPIDimSet;
BEGIN
  OPEN cObjectives;
  LOOP
    FETCH cObjectives INTO l_objective, l_dim_set;
    EXIT WHEN cObjectives%NOTFOUND;
    l_KPI.kpi_number := l_objective;
    l_KPI.dim_set_id := l_dim_set;
    l_results(l_results.count) := l_KPI;
  END LOOP;
  CLOSE cObjectives;
  return l_results;
  exception when others then
    writeTmp('Exception in find_objectives_for_table_old :'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
  	raise;
END;

FUNCTION find_objectives_for_table_new(p_table IN VARCHAR2) return BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet  IS
l_stmt VARCHAR2(1000) :=
'select distinct indicator, dim_set_id from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||'
where table_name in
(select table_name from bsc_db_tables_rels
where table_name like ''BSC_S%''
connect by prior table_name = source_table_name
start with table_name = :1)';
l_objective number;
l_results BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet;
cv CurTyp;
l_KPI BSC_METADATA_OPTIMIZER_PKG.clsKPIDimSet;
l_dim_set number;
BEGIN
  OPEN cv FOR l_stmt USING p_table;
  LOOP
    FETCH cv INTO l_objective, l_dim_set ;
    EXIT WHEN cv%NOTFOUND;
    l_KPI.kpi_number := l_objective;
    l_KPI.dim_set_id := l_dim_set;
    l_results(l_results.count) := l_KPI;
  END LOOP;
  CLOSE cv;
  RETURN l_results;
 exception when others then
    writeTmp('Exception in find_objectives_for_table_new :'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    writeTmp('l-stmt was :'||l_stmt||' with bind variable :1='||p_table, FND_LOG.LEVEL_EXCEPTION, true);
  	raise;

END;

FUNCTION find_objectives_for_table(p_table IN VARCHAR2) return BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet  IS
BEGIN
  IF NOT TableExists(BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table) then
    RETURN find_objectives_for_table_old(p_table);
  ELSE
    RETURN find_objectives_for_table_new(p_table);
  END IF;
 exception when others then
    writeTmp('Exception in find_objectives_for_table :'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
  	raise;

END;

FUNCTION getPeriodicityForTable(p_table_name IN VARCHAR2) return NUMBER IS
CURSOR cPeriodicity IS
select periodicity_id from bsc_db_tables
where table_name = upper(p_table_name);
l_value NUMBER;
BEGIN
  OPEN cPeriodicity;
  FETCH cPeriodicity INTO l_value;
  CLOSE cPeriodicity;
  return l_value;
END;

Function is_base_table(p_table IN VARCHAR2) RETURN Boolean IS
l_count NUMBER;
CURSOR cTableType IS
select count(1)
from bsc_db_tables tbl,
bsc_db_tables_rels rels
where
rels.table_name = p_table
and rels.source_table_name = tbl.table_name
and tbl.table_type = 0;

BEGIN
  OPEN cTableType;
  FETCH cTableType INTO l_count;
  CLOSE cTableType;
  IF (l_count=0) THEN
     return false;
  ELSE
     return true;
  END IF;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in is_Base_Table for '||p_table||':'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
  	raise;
End ;


PROCEDURE checkError(apiName IN VARCHAR2) IS
l_error VARCHAR2(32000) := null;
CURSOR cMsg IS
SELECT MESSAGE
FROM BSC_MESSAGE_LOGS
WHERE TYPE = 0
AND UPPER(SOURCE) = upper(apiName)
AND LAST_UPDATE_LOGIN = bsc_metadata_optimizer_pkg.g_session_id;

BEGIN
  OPEN cMsg;
  FETCH cMsg INTO l_error;
  CLOSE cMsg;
  If l_error IS NOT NULL Then
      --if there was an error then shows the error and exit
      bsc_utility.do_rollback;
      BSC_METADATA_OPTIMIZER_PKG.g_errbuf := l_error;
      BSC_METADATA_OPTIMIZER_PKG.g_retcode := 2;
      BSC_METADATA_OPTIMIZER_PKG.logProgress('CHECKERROR', apiName);
      BSC_MO_HELPER_PKG.TerminateWithMsg(l_error);
      raise BSC_METADATA_OPTIMIZER_PKG.optimizer_exception;
  END IF;

END;

FUNCTION get_time RETURN VARCHAR2 IS

BEGIN
  return to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss');
END;

FUNCTION getTablespaceClauseTbl RETURN VARCHAR2 IS
l_stmt varchar2(1000);
l_return_value varchar2(1000);
cv   CurTyp;
CURSOR cTableSpace IS
SELECT BSC_APPS.Get_Tablespace_Clause_Tbl FROM DUAL;
BEGIN

	OPEN cTableSpace;
	FETCH cTableSpace INTO l_return_value;
	CLOSE cTableSpace;
	RETURN l_return_value;

  	EXCEPTION WHEN others then
      bsc_mo_helper_pkg.writeTmp('EXCEPTION in getTablespaceClauseTbl', FND_LOG.LEVEL_UNEXPECTED, true);
  RAISE;
END;

FUNCTION getTablespaceClauseIdx RETURN VARCHAR2 IS
l_stmt varchar2(1000);
l_return_value varchar2(1000);

cv   CurTyp;
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Inside getTablespaceClauseIdx', FND_LOG.LEVEL_PROCEDURE);
	END IF;

	l_stmt := 'SELECT BSC_APPS.Get_Tablespace_Clause_Idx  FROM DUAL';

  OPEN cv FOR l_stmt;
	FETCH cv INTO l_return_value;
	CLOSE cv;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Completed getTablespaceClauseIdx, returning '||l_return_value, FND_LOG.LEVEL_PROCEDURE);
	END IF;

	RETURN l_return_value;

 	EXCEPTION WHEN others then
      bsc_mo_helper_pkg.writeTmp('EXCEPTION in getTablespaceClauseIdx', FND_LOG.LEVEL_UNEXPECTED, true);
	RAISE;
END;

FUNCTION getStorageClause RETURN VARCHAR2 IS
l_stmt varchar2(1000);
l_return_value varchar2(1000);
CURSOR cStorage IS
SELECT BSC_APPS.Get_Storage_Clause FROM DUAL;

BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Inside getStorageClause', FND_LOG.LEVEL_PROCEDURE);
	END IF;

	OPEN cStorage;
	FETCH cStorage INTO l_return_value;
	CLOSE cStorage;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Completed getStorageClause, returning '||l_return_value, FND_LOG.LEVEL_PROCEDURE);
	END IF;

	RETURN l_return_value;

  	EXCEPTION WHEN others then
        bsc_mo_helper_pkg.writeTmp('EXCEPTION in getStorageClause', FND_LOG.LEVEL_UNEXPECTED, true);
	   RAISE;
END;


PROCEDURE addStack(pStack IN OUT NOCOPY VARCHAR2, pMsg IN VARCHAR2) IS
BEGIn
  IF (length (pStack) + length(pMsg) > 30000) THEN
      pStack := null;
  END IF;
  pStack := pStack || newline||pMsg;
END;

FUNCTION boolean_decode (pVal IN BOOLEAN) RETURN VARCHAR2 IS
l_val VARCHAR2(10);
BEGIN
  IF pVal THEN
      l_val := 'Y';
  ELSE
      l_val := 'N';
  END IF;
  return l_val;
END;

FUNCTION boolean_decode_num (pVal IN BOOLEAN) RETURN NUMBER IS
l_val VARCHAR2(10);
BEGIN
  IF pVal THEN
      return 1;
  ELSE
      return 0;
  END IF;
  return 0;
END;




PROCEDURE InitTablespaceNames IS
  --Initialize the global variables with tablespace names
BEGIN

  BSC_METADATA_OPTIMIZER_PKG.gInputTableTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.input_table_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gInputIndexTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.input_index_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gBaseTableTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.base_table_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gBaseIndexTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.base_index_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.summary_table_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.summary_index_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gOtherTableTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.other_table_tbs_type);
  BSC_METADATA_OPTIMIZER_PKG.gOtherIndexTbsName := BSC_APPS.get_tablespace_name(BSC_APPS.other_table_tbs_type);
End ;


PROCEDURE write_this (
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsConfigKpiMV,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count number;
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
  writeTmp('LevelComb = '||pTable.LevelComb||' , MVName = '||
        pTable.MVName||', DataSource = '||pTable.MVName||', SqlStmt = '||pTable.SqlStmt,
			FND_LOG.LEVEL_STATEMENT, pForce);
	END IF;

END;


PROCEDURE write_this (
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsConfigKpiMV,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsConfigKpiMV;
BEGIN
  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;
  LOOP
      l_table := pTable(l_count);
      write_this(l_table, pSeverity, pForce);
      exit when l_count = pTable.last;
      l_count := pTable.next(l_count);
  END LOOP;
END;
/*
PROCEDURE write_this (pTable IN DBMS_SQL.VARCHAR2_TABLE, pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT, pForce IN boolean default false) IS
l_count NUMBER;
l_string VARCHAR2(4000);
BEGIN
  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;
  l_string := l_string ||'  ';
  LOOP
      l_string := l_string ||pTable(l_count);
      IF (length(l_string) > 3000) THEN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        writeTmp(l_string, pSeverity);
	END IF;

        l_string := null;
      END IF;
      EXIT WHEN l_count = pTable.last;
      l_count := pTable.next(l_count);
      l_string := l_string ||', ';
  END LOOP;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  writeTmp(l_string, pSeverity);
	END IF;


END;
*/

PROCEDURE write_this (
  pTable IN DBMS_SQL.VARCHAR2_TABLE,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false) IS
l_count NUMBER;
l_string VARCHAR2(4000);
BEGIN
  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;

  LOOP
	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
        writeTmp(pTable(l_count), pSeverity, pForce);
	END IF;

      EXIT WHEN l_count = pTable.last;
      l_count := pTable.next(l_count);
  END LOOP;
END;



PROCEDURE write_this (
  pTable IN DBMS_SQL.NUMBER_TABLE,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(3000);
BEGIN
  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;
  LOOP
      l_string := l_string ||pTable(l_count);
      EXIT WHEN l_count = pTable.last;
      l_count := pTable.next(l_count);
      l_string := l_string ||', ';
      IF (length(l_string) > 200) THEN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
        writeTmp(l_string, pSeverity, pForce);
	END IF;

        l_string := null;
      END IF;
  END LOOP;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(l_string, pSeverity, pForce);
	END IF;

  EXCEPTION WHEN OTHERS THEN
      raise;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsParent,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
  writeTmp(ind||' Name = '||pTable.name||', relationColumn = '||pTable.relationColumn, pSeverity, pForce);
	END IF;

END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsParent,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsParent;
BEGIN

  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;
  LOOP
      l_table := pTable(l_count);
      write_this(l_table, l_count, pSeverity, pForce);
      exit when l_count = pTable.last;
      l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsMasterTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_string varchar2(30000);
BEGIN
  l_string := ind||' Name = '||pTable.name||', keyName = '||pTable.keyName||', userTable = ';
  IF (pTable.userTable) THEN
      l_string := l_string ||'true';
  ELSE
      l_string := l_string ||'false';
  END IF;
  l_string := l_string ||', EDW_FLAG='||pTable.EDW_FLAG||', inputTable='||pTable.inputTable;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  writeTmp(l_string, pSeverity);
	END IF;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
  writeTmp('Parent_name='||pTable.parent_name||', parent_rel_col='||pTable.parent_rel_col, pSeverity, pForce);
  writeTmp('Auxillary='||pTable.auxillaryFields, pSeverity, pForce);
	END IF;

END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMasterTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsMasterTable;
BEGIN
  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;
  LOOP
      l_table := pTable(l_count);
      write_this(l_table, l_count, pSeverity, pForce);
      exit when l_count = pTable.last;
      l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsRelationMN,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
  writeTmp(ind||' TableA='||pTable.TableA||', keyNameA='||pTable.keyNameA, pSeverity, pForce);
  writeTmp(', TableB='||pTable.TableB||', keyNameB='||pTable.keyNameB
      ||', TableRel='||pTable.TableRel||', InputTable='||pTable.InputTable, pSeverity, pForce);
	END IF;

END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsRelationMN,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false) IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsRelationMN;
BEGIN
  IF (pTable.count=0) THEN
      return;
  END IF;
  l_count := pTable.first;
  LOOP
      l_table := pTable(l_count);
      write_this(l_table, l_count, pSeverity, pForce);
      exit when l_count = pTable.last;
      l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsIndicator,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log OR pForce THEN
  writeTmp(ind||' Code='||pTable.code||', Name='||pTable.Name||', IndicatorType='||pTable.IndicatorType||', ConfigType='||pTable.configType
      ||', periodicity='||pTable.periodicity||', OptimizationMode='||pTable.OptimizationMode||', Action_Flag='||pTable.Action_Flag||', Share_Flag='||pTable.Share_flag
      ||', source_Indicator='||pTable.source_Indicator||', EDW_Flag='||pTable.EDW_FLag||',impl_type='||pTable.impl_type, pSeverity, pForce);
	END IF;

END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false) IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false) IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Code='||pTable.code||', EDW_Flag='||pTable.EDW_Flag||', Yearly_Flag='||pTable.Yearly_flag
      ||', CalendarID='||pTable.calendarID||', PeriodicityType='||pTable.PeriodicityType
      ||'  Origin ='||pTable.PeriodicityOrigin , pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsPeriodicity ,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Code='||pTable.code||', TargetLevel='||pTable.TargetLevel, pSeverity, pForce);
  END IF;
END;
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity ,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsCalendar,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Code='||pTable.code||', EDW_FLAG='||pTable.EDW_FLAG||', Name='||pTable.Name
      ||', CurrFiscalYear='||pTable.CurrFiscalYear||', RangeYrMod='||pTable.RangeYrMod
      ||', NumOfYears='||pTable.NumOfYears||', PreviousYears='||pTable.PreviousYears, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsCalendar,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsCalendar;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsOldBTables,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Name='||pTable.name||', periodicity='||pTable.periodicity||', InputTable='||pTable.InputTable
      ||', numFields='||pTable.numFields||', NumIndicators='||pTable.NumIndicators||
        ', Fields='||pTable.fields||', Indicators='||pTable.Indicators, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsOldBTables,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsOldBTables;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' field='||pTable.fieldName||', source='||pTable.source||', desc='||pTable.description||', group='||pTable.groupCode
      ||', prj='||pTable.prjMethod||', measureType='||pTable.measureType, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMeasureLOV,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsLevels,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' key='||pTable.keyName||', dimTable='||pTable.dimTable||', Num='||pTable.Num
      ||', Name='||pTable.Name||', TargetLevel='||pTable.TargetLevel||', parents1N='||pTable.Parents1N||
      ', ParentsMN='||pTable.parentsMN, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false) IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsLevels;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(' group_id = '||pTable.group_id||', key='||pTable.keyName||', dimTable='||pTable.dimTable||', Num='||pTable.Num
      ||', Name='||pTable.Name||', TgtLevel='||pTable.TargetLevel||', parents1N='||pTable.Parents1N||
      ', ParentsMN='||pTable.parentsMN, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;


PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' LevelConfig='||pTable.LevelConfig||', levels='||pTable.levels, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevelCombinations,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(' group_id = '||pTable.group_id||', levels='||pTable.levels||', levelConfig='||pTable.levelConfig, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevelCombinations;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp('write_this for tab_tab_clsLevelCombinations, count = '||pTable.count);
  END IF;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(300) := null;
l_error VARCHAR2(1000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(' '||ind||l_string||' key='||pTable.keyName||', origin='||pTable.origin||', 0code='||boolean_decode(pTable.needsCode0)
      ||', calc0Code='||boolean_decode(pTable.calculateCode0)||', FilterView='||pTable.FilterViewName||', dimIndex = '||pTable.dimIndex , pSeverity, pForce);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    writeTmp('Exception in write_this for tab_clsKeyField :' ||l_error, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
l_error VARCHAR2(1000);
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    writeTmp('Exception in write_this for tab_clsKeyField :' ||l_error, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
END;


PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDataField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(300) := null;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||l_string||' field='||pTable.fieldName||', source='||pTable.source||', aggFon='||pTable.aggFunction||', Origin='||pTable.Origin
      ||', AvgLFlag='||pTable.AvgLFlag
	  ||', AvgLTotalColumn='||pTable.AvgLTotalColumn
      ||', AvgLCounter='||pTable.AvgLCounterColumn
	  ||', IntColumn='||pTable.InternalColumnType
      ||', IntColSource='||pTable.InternalColumnSource
	  ||', changeType='||pTable.changeType,
	   pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsDataField;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsBasicTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Name='||pTable.Name, pSeverity, pForce);
    writeTmp('   keyfields = ', pSeverity, pForce);
    --write_this(getAllkeyFields(pTable.name), pSeverity, pForce);
    write_this(pTable.keys, pSeverity, pForce);
    writeTmp('   Data = ', pSeverity, pForce);
	--write_this(getAllDataFields(pTable.name), pSeverity, pForce);
	write_this(pTable.data, pSeverity, pForce);
    writeTmp(' LevelConfig='||pTable.LevelConfig||', originTable='||pTable.originTable, pSeverity, pForce);
    writeTmp('----------------------------------', pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsBasicTable;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_string,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(pTable.value, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_string,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.tab_string;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
      writeTmp(l_table.value, pSeverity, pForce);
    END IF;
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.number_table,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
BEGIN
  write_this(pTable.value, pSeverity, pForce);
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsOriginTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Name='||pTable.Name, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsOriginTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsOriginTable;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Name='||pTable.Name||', Type ='||pTable.type||', Ind#='||pTable.indicator||
    ', DimSet='||pTable.configuration||', Per = '||pTable.periodicity||', EDW_Flag='||pTable.EDW_Flag||
    ', ProdTable='||boolean_decode(pTable.isProductionTable)||
    ', ProdTableAltered='||boolean_decode(pTable.isProductionTableAltered)||
    ', IsTargetTable='||boolean_decode(pTable.IsTargetTable)||
    ', HasTargets='||boolean_decode(pTable.HasTargets)||
    ', UsedForTargets='||boolean_decode(pTable.UsedForTargets)||',impl_type='||pTable.impl_type||', measure_group='||pTable.measureGroup, pSeverity, pForce);
    writeTmp('   KeyName=', pSeverity, pForce);
	--write_this(getAllKeyFields(pTable.Name), pSeverity, pForce);
	write_this(pTable.keys, pSeverity, pForce);
    writeTmp('   Data=', pSeverity, pForce);
	--write_this(getAllDataFields(pTable.name), pSeverity, pForce);
	write_this(pTable.data, pSeverity, pForce);
    writeTmp('   originTable='||pTable.originTable, pSeverity, pForce);
    writeTmp('   originTable1='||pTable.originTable1, pSeverity, pForce);
    writeTmp('   dbObjectType='||pTable.dbObjectType||
        ', MVName = '||pTable.MVName||
        ', upgradeFlag = '||pTable.upgradeFlag||
        ', currentPeriod = '||pTable.currentPeriod||
        ', projectionTable = '||pTable.projectionTable, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsTable,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false,
  pIgonoreProduction IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
      IF pIgonoreProduction AND (l_table.isProductionTable and NOT l_table.isProductionTableAltered) THEN
        null;
      ELSE
        writeTmp(' ', FND_LOG.LEVEL_STATEMENT, pForce);
        write_this(l_table, l_count, pSeverity, pForce);
        writeTmp(' ', FND_LOG.LEVEL_STATEMENT, pForce);
      END IF;
    END IF;
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;


PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisAggField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
l_table BSC_METADATA_OPTIMIZER_PKG.clsDisAggField;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, ind, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDisAggField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(
	' Code='||pTable.Code||', Periodicity ='||pTable.Periodicity||', Origin='||pTable.Origin||
    ', Registered='||boolean_decode(pTable.Registered)||', isProduction='||boolean_decode(pTable.isProduction), pSeverity, pForce);
    writeTmp('  disagg keys =', pSeverity, pForce);
    write_this(
	  pTable.keys,
	  pSeverity, pForce);
  END IF;
END;


PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pFieldName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDisAggField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false) IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp('    '||ind||' Code='||pTable.Code||', Periodicity ='||pTable.Periodicity||', Origin='||pTable.Origin||
    ', Registered='||boolean_decode(pTable.Registered), pSeverity, pForce);
    writeTmp('  disagg keys =', pSeverity, pForce);
    write_this(
	--getDisaggKeys(pTableName, pFieldName,  pTable.code),
	pTable.keys,
	pSeverity, pForce);
  END IF;

END;

PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pFieldName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisAggField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsDisAggField;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(pTableName, pFieldName, l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;


PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsUniqueField,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' field='||pTable.fieldName||', source='||pTable.source||', group='||pTable.measureGroup||', aggFunction ='||pTable.aggFunction||', EDW_Flag='||pTable.EDW_Flag||',impl_type='||pTable.impl_type||' key_combinations=', pSeverity, pForce);
    write_this(pTableName, pTable.fieldName,
      pTable.key_Combinations,
      pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTableName IN VARCHAR2,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(pTableName, l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;


PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.clsDBColumn,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' columnName='||pTable.columnName||', columnTYPE ='||pTable.columnTYPE||', columnLength='||pTable.columnLength
    ||' isKey='||boolean_decode(pTable.isKey), pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;
PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.TNewITables,
  ind IN NUMBER default null,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_string VARCHAR2(30000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log or pForce THEN
    writeTmp(ind||' Name='||pTable.Name||', periodicity ='||pTable.periodicity||', numFields='||pTable.numFields
    ||', NumIndicators='||pTable.NumIndicators ||',  Fields='||pTable.Fields|| ',   Indicators='||pTable.Indicators, pSeverity, pForce);
  END IF;
END;

PROCEDURE write_this(
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_TNewITables,
  pSeverity IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
  pForce IN boolean default false)
  IS
l_count NUMBER;
l_table BSC_METADATA_OPTIMIZER_PKG.TNewITables;
BEGIN
  IF (pTable.count=0) THEN
    return;
  END IF;
  l_count := pTable.first;
  LOOP
    l_table := pTable(l_count);
    write_this(l_table, l_count, pSeverity, pForce);
    exit when l_count = pTable.last;
    l_count := pTable.next(l_count);
  END LOOP;
END;


--****************************************************************************
--  addTable
--  DESCRIPTION:
--     Adds the table to the collection gTables
--  PARAMETERS:
--     pTable: Table to be added to gTables
--     proc: Procedure that calls this API
--****************************************************************************

PROCEDURE addTable (pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable,
      proc IN VARCHAR2) IS
  l_temp1 NUMBER;
  lTable BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_stack VARCHAR2(32000);
BEGIN
  l_stack := 'Inside addTable for Table name = '||pTable.name||' called from '||proc|| ', gTables_counter='||BSC_METADATA_OPTIMIZER_PKG.gTables_counter;
  lTable := pTable;
  IF findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, lTable.name) >=0 THEN -- exists
      return;
  END IF;
  l_temp1 := BSC_METADATA_OPTIMIZER_PKG.gTables_counter;
  BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp1) := lTable;
  l_stack := l_stack ||newline||'Adding gTables('||l_temp1||') = '||lTable.name;
  BSC_METADATA_OPTIMIZER_PKG.gTables_counter := BSC_METADATA_OPTIMIZER_PKG.gTables_counter + 1;
  EXCEPTION WHEN OTHERS THEN
      writeTmp('Exception in addTable : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
      BSC_MO_HELPER_PKG.write_this(pTable, 1, FND_LOG.LEVEL_UNEXPECTED, true);
      writeTmp('l_stack is  : '||l_stack, FND_LOG.LEVEL_UNEXPECTED, true);
      raise;
END;

--****************************************************************************
--  addTable
--  DESCRIPTION:
--     Adds the table to the collection gTables and inserts keys and data
--     into temp tables
--  PARAMETERS:
--     pTable: Table to be added to gTables
--     pKeyFields: Keyfields for the table
--     pData : Data fields for the table
--****************************************************************************


PROCEDURE addTable (pTable IN BSC_METADATA_OPTIMIZER_PKG.clsTable,
        pKeyFields IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
        pData     IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField,
      proc IN VARCHAR2) IS
  l_temp1 NUMBER;
  lTable BSC_METADATA_OPTIMIZER_PKG.clsTable;
BEGIN

  lTable := pTable;
  IF findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, lTable.name) >=0 THEN -- exists
      return;
  END IF;
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
   --BSC_MO_HELPER_PKG.writeTmp('Adding gTables thru PROC '||proc||
   --     ', gTables('||BSC_METADATA_OPTIMIZER_PKG.gTables_counter||') is '||lTable.name||' with Data = '||pData.count||', Keys='||pKeyFields.count, FND_LOG.LEVEL_STATEMENT);
     null;
   END IF;

  lTable.keys := pKeyFields;
  lTable.data := pData;
   BSC_METADATA_OPTIMIZER_PKG.gTables(BSC_METADATA_OPTIMIZER_PKG.gTables_counter) := lTable;
   BSC_METADATA_OPTIMIZER_PKG.gTables_counter := BSC_METADATA_OPTIMIZER_PKG.gTables_counter + 1;

  EXCEPTION WHEN OTHERS THEN
      writeTmp('Exception in addTable : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
      write_this(pTable, 1, FND_LOG.LEVEL_UNEXPECTED, true);
      writeTmp('keys are :' , FND_LOG.LEVEL_UNEXPECTED, true);
      write_this(pKeyFields, FND_LOG.LEVEL_UNEXPECTED, true);
      writeTmp('Data :', FND_LOG.LEVEL_UNEXPECTED, true );
      write_this(pData, FND_LOG.LEVEL_UNEXPECTED, true);
      raise;
END;

--****************************************************************************
--  CalcProjectionTable
--
--  DESCRIPTION:
--     Return true if the projection is calculated on the table
--****************************************************************************

Function CalcProjectionTable(TableName IN VARCHAR2) return BOOLEAN IS

CURSOR C1(p1 VARCHAR2) IS
SELECT PROJECT_FLAG FROM BSC_DB_TABLES
WHERE TABLE_NAME = p1;
l_proj NUMBER ;
l_ret  boolean;

l_error VARCHAR2(400);
BEGIN
  OPEN C1( Upper(tablename));
  FETCH c1 INTO l_proj;

  IF (c1%NOTFOUND) THEN
      l_ret := FALSE;
  Else
      IF l_proj = 0 THEN
        l_ret := false;
      Else
        l_ret := true;
      End IF;
  End IF;

  CLOSE c1;
  return l_ret;
      EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in CalcProjectionTable for table= '||TableName||', Exception is :' ||l_error,
		FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;


--****************************************************************************
--  WriteInfoMatrix : EscribirMatrixInfo
--
--  DESCRIPTION:
--     Write the given variable of the given indicator in BSC_KPI_PROPERTIES
--     table.
--
--  PARAMETERS:
--     Indic: indicator code
--     Variable: variable name
--     Valor: value
--     db_obj: database
--****************************************************************************
PROCEDURE WriteInfoMatrix(Indic IN NUMBER, Variable IN VARCHAR2, Valor IN NUMBER) IS

  CURSOR C1 IS
  SELECT PROPERTY_CODE FROM BSC_KPI_PROPERTIES
  WHERE INDICATOR = Indic
  AND UPPER(PROPERTY_CODE) = UPPER(Variable);
  l_Value varchar2(20);
  l_error VARCHAR2(400);
BEGIN


  OPEN c1;
  FETCH c1 INTO l_VALUE;

  IF c1%FOUND THEN
      UPDATE BSC_KPI_PROPERTIES SET PROPERTY_VALUE = Valor
          WHERE INDICATOR = Indic AND PROPERTY_CODE = Variable;

  Else
      INSERT INTO BSC_KPI_PROPERTIES (INDICATOR, PROPERTY_CODE, PROPERTY_VALUE)
          VALUES(Indic, Variable, Valor);
  End IF;
  Close c1;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in WriteInfoMatrix for Indic = '||indic||', variable = '||variable||', value = '||valor||' :'||l_error,
		FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End ;

--****************************************************************************
--  SaveOptimizationMode: GuardarOptimizationMode
--
--   DESCRIPTION:
--    Write in BSC_KPI_PROPERTIES the Optimization Mode of the kpis
--
--****************************************************************************

PROCEDURE SaveOptimizationMode IS
  i NUMBER;
  l_error VARCHAR2(400);
BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  BSC_MO_HELPER_PKG.writeTmp('Inside SaveOptimizationMode');
   END IF;

  IF (BSC_METADATA_OPTIMIZER_PKG.gINdicators.count = 0) THEN
      return;
  END IF;

  i := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;

  LOOP
      IF BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag <> 2 THEN
        --This is not a deleted Kpi
        WriteInfoMatrix(BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code, 'DB_TRANSFORM', BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).OptimizationMode);
      End IF;
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
      i := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(i);
  END LOOP;
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  BSC_MO_HELPER_PKG.writeTmp('Completed SaveOptimizationMode');
   END IF;


  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in SaveOptimizationMode:'||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;

END;

--****************************************************************************
--  table_column_exists
--
--  DESCRIPTION:
--     Returns TRUE if the given column exists in the table.
--
--  PARAMETERS:
--     Table: table name
--     Column: column name
--****************************************************************************
Function table_column_exists(p_table IN VARCHAR2, p_Column IN VARCHAR2) RETURN boolean IS
  l_res boolean := false;
  l_table VARCHAR2(100);
  CURSOR c1 (p3 VARCHAR2) IS
  SELECT TABLE_NAME FROM ALL_TAB_COLUMNS
  WHERE TABLE_NAME = p_table AND COLUMN_NAME = upper(p_column) AND OWNER = p3;
  l_error VARCHAR2(400);
BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  BSC_MO_HELPER_PKG.writeTmp('Inside table_column_exists', FND_LOG.LEVEL_STATEMENT);
   END IF;

  OPEN C1(UPPER(BSC_METADATA_OPTIMIZER_PKG.gBSCSchema));
  FETCH c1 INTO l_table;
  IF (c1%FOUND) THEN
      CLOSE c1;
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Completed table_column_exists, returning TRUE', FND_LOG.LEVEL_STATEMENT);
   END IF;

      return true;
  END IF;
  CLOSE c1;
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  BSC_MO_HELPER_PKG.writeTmp('Completed table_column_exists, returning FALSE', FND_LOG.LEVEL_STATEMENT);
   END IF;

  return false;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in table_column_exists: '||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      raise;
End ;


--****************************************************************************
--  get_lookup_value
--
--  DESCRIPTION:
--     Returns lookup value from fnd_lookup_values_vl
--
--  PARAMETERS:
--     p_lookup_type: Lookup Type
--     p_lookup_code: Lookup Code
--****************************************************************************
FUNCTION get_lookup_value(p_lookup_type IN VARCHAR2, p_lookup_code  IN VARCHAR2) return VARCHAR2 IS

CURSOR c1 IS
SELECT MEANING
FROM fnd_lookup_values_vl
WHERE LOOKUP_TYPE = p_lookup_type
AND LOOKUP_CODE = p_lookup_code;

l_val VARCHAR2(1000);
BEGIN
  IF gLookup_value.exists(p_lookup_type||p_lookup_code) THEN
    return gLookup_value(p_lookup_type||p_lookup_code).value;
  ELSE
    OPEN C1;
    FETCH C1 INTO l_val;
    cLOSE c1;
    gLookup_value(p_lookup_type||p_lookup_code).value := l_val;
  END IF;
  return l_val;
END;


--****************************************************************************
--  FindIndex
--  DESCRIPTION:
--     Returns position of the value within the array
--  PARAMETERS:
--     arrNum: Array to be searched
--     num: Value to be searched within the array
--****************************************************************************
Function FindIndex(arrNum IN dbms_sql.NUMBER_TABLE, num IN NUMBER) RETURN NUMBER IS
  l_count Number := 0;
BEGIN

  l_count := arrNum.Count;
  if l_count =0 then
	   return -1;
  END IF;

  l_count := arrNum.first;
  LOOP
      IF (arrNum(l_count) = num) THEN
        return l_count;
      END IF;
 	  EXIT WHEN l_count = arrNum.Last;
	  l_count := arrNum.next(l_count);
  END LOOP;
  return -1;
END;

--***************************************************************************
-- Find Index
--
--  DESCRIPTION:
--    Returns the index on the array arrStr() where the given string is
--     found. Returns -1 if it is not found.
--
--  PARAMETERS:
--     ArrStr : array
--     str: string to look for
--***************************************************************************

Function FindIndexVARCHAR2(arrStr IN dbms_sql.varchar2_table, str in varchar2) return NUMBER IS
  i NUMBER :=0;
BEGIN

  IF (arrStr.count =0) THEN
	   return -1;
  END IF;

  i:= arrStr.first;

  LOOP
      IF UPPER(arrStr(i)) = UPPER(str) THEN
        return i;
      END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;
End;

--***************************************************************************
-- Find Index
--
--  DESCRIPTION:
--    Returns the index on the array arrStr() where the given string is
--     found. Returns -1 if it is not found.
--
--  PARAMETERS:
--     ArrStr : array
--     str: string to look for
--***************************************************************************

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,  findThis in varchar2)
return NUMBER IS
  i NUMBER :=0;
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;

  LOOP
      IF (UPPER(arrStr(i).keyName) = UPPER(findThis) )THEN
        return i;
      END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;
End;

--***************************************************************************
-- Find Index
--
--  DESCRIPTION:
--    Returns the index on the array arrStr() where the given string is
--     found. Returns -1 if it is not found.
--
--  PARAMETERS:
--     ArrStr : array
--     str: string to look for
--***************************************************************************

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels,  findThis in varchar2)
return NUMBER IS
  i NUMBER :=0;
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;

  LOOP
      IF (UPPER(arrStr(i).keyName) = UPPER(findThis) )THEN
        return i;
      END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;
End;


Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMasterTable, findThis in varchar2) return NUMBER IS
  i NUMBER :=0;
BEGIN
  i := arrStr.count;
  IF (i =0) THEN
      RETURN -1;
  END IF;
  i:= arrStr.first;
  LOOP
      IF UPPER(arrStr(i).Name) = UPPER(findThis) THEN
        return i;
      END IF;
	EXIT WHEN i= arrStr.last;
	i:= arrStr.next(i);
  END LOOP;
  return -1;
End;

Function FindKeyIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMasterTable, keyName in varchar2) return NUMBER IS
  i NUMBER :=0;
BEGIN
  i := arrStr.count;
  IF (i =0) THEN
      RETURN -1;
  END IF;
  i:= arrStr.first;
  LOOP
      IF UPPER(arrStr(i).keyName) = UPPER(keyName) THEN
        return i;
      END IF;
	  EXIT WHEN i= arrStr.last;
	  i:= arrStr.next(i);
  END LOOP;
  return -1;
End;


Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsTable, findThis in varchar2) return NUMBER IS
  i NUMBER :=0;
BEGIN
  i := arrStr.count;

  IF (i =0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writetmp('Done with FindIndex for tab_clsTable, zero count, returning -1, findThis = '||findThis);
   END IF;

      RETURN -1;
  END IF;

  i:= arrStr.first;

  LOOP
      IF UPPER(arrStr(i).Name) = UPPER(findThis) THEN
        return i;
      END IF;
	EXIT WHEN i= arrStr.last;
	i:= arrStr.next(i);
  END LOOP;
  return -1;
End;


Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable, findThis in varchar2) return NUMBER IS
  i NUMBER :=0;
BEGIN
  i := arrStr.count;
  IF (i =0) THEN
      RETURN -1;
  END IF;
  i:= arrStr.first;

  LOOP
      IF UPPER(arrStr(i).Name) = UPPER(findThis) THEN
        return i;
      END IF;
	   EXIT WHEN i= arrStr.last;
	   i:= arrStr.next(i);
  END LOOP;
  return -1;
End;


Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator, findThis in number) return NUMBER IS
  i NUMBER :=0;
BEGIN

  i := arrStr.count;

  IF (i =0) THEN RETURN -1;
  END IF;

  i:= arrStr.first;

  LOOP
      IF arrStr(i).code = findThis THEN
        return i;
      END IF;
	EXIT WHEN i= arrStr.last;
	i:= arrStr.next(i);
  END LOOP;
  return -1;
End;

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField,  findThis in varchar2, p_source IN VARCHAR2, p_impl_type IN NUMBER)
return NUMBER IS
  i NUMBER :=0;
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;
  LOOP
    IF (UPPER(arrStr(i).fieldName) = UPPER(findThis)
	    AND arrStr(i).impl_type = p_impl_type
	    --BSC Autogen
		AND arrStr(i).source = p_source) THEN
      return i;
    END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;
End;


Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisaggField,  findThis in NUMBER)
return NUMBER IS
  i NUMBER :=0;
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;

  LOOP
      IF (arrStr(i).code = findThis)THEN
        return i;
      END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;
End;

--BSC Autogen
Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsMeasureLOV,  findThis in VARCHAR2, p_source IN VARCHAR2, pIgnoreCase In Boolean)
return NUMBER IS
  i NUMBER :=0;
  l_findThis VARCHAR2(100);
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;
  IF (pIgnoreCase) THEN
      l_findThis := UPPER(findThis);
      LOOP
        IF (UPPER(arrStr(i).fieldName) = l_findThis
            --BSC Autogen
		    AND arrStr(i).source=p_source)THEN
          return i;
        END IF;
  	EXIT WHEN i = arrStr.last;
  	i := arrStr.next(i);
      END LOOP;
  ELSE
      LOOP
        IF (arrStr(i).fieldName = findThis
            --BSC Autogen
		    AND arrStr(i).source=p_source)THEN
          return i;
        END IF;
  	EXIT WHEN i = arrStr.last;
  	i := arrStr.next(i);
      END LOOP;
  END IF;
  return -1;
End;

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsPeriodicity, findThis in NUMBER) return NUMBER  IS
i NUMBER;
l_error VARCHAR2(4000);
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;

  LOOP
      IF (arrStr(i).code = findThis)THEN
        return i;
      END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;

  EXCEPTION WHEN OTHERS THEN

      writeTmp('Exception in FindIndex for tab_clsPeriodicity', FND_LOG.LEVEL_STATEMENT, true);
      l_error := sqlerrm;
      writeTmp('Exception is '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;

Function FindIndex(arrStr IN BSC_METADATA_OPTIMIZER_PKG.tab_clsCalendar, findThis in NUMBER) return NUMBER  IS
i NUMBER;
BEGIN
  IF (arrStr.count =0) THEN
   	return -1;
  END IF;
  i:= arrStr.first;

  LOOP
      IF (arrStr(i).Code = findThis)THEN
        return i;
      END IF;
	EXIT WHEN i = arrStr.last;
	i := arrStr.next(i);
  END LOOP;
  return -1;
End;

--***************************************************************************
-- new_clsUniqueField
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsUniqueField.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************

FUNCTION new_clsUniqueField return BSC_METADATA_OPTIMIZER_PKG.clsUniqueField IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsUniqueField ;
BEGIn
  return l_new;
END;

--***************************************************************************
-- new_clsTable
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsTable.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************

FUNCTION new_clsTable return BSC_METADATA_OPTIMIZER_PKG.clsTable IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsTable ;
BEGIn
  l_new.isProductionTable := false;
  return l_new;
END;

--***************************************************************************
-- new_clsDataField
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsDataField.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsDataField return BSC_METADATA_OPTIMIZER_PKG.clsDataField IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsDataField ;
BEGIn
  return l_new;
END;

--***************************************************************************
-- new_clsDisAggField
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsDisAggField.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsDisAggField return BSC_METADATA_OPTIMIZER_PKG.clsDisAggField IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsDisAggField ;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsKeyField
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsKeyField.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsKeyField return BSC_METADATA_OPTIMIZER_PKG.clsKeyField IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsKeyField ;
BEGIn
  return l_new;
END;

--***************************************************************************
-- new_clsOriginTable
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsOriginTable.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsOriginTable return BSC_METADATA_OPTIMIZER_PKG.clsOriginTable IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsOriginTable ;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsDBColumn
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsDBColumn.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsDBColumn return BSC_METADATA_OPTIMIZER_PKG.clsDBColumn IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsDBColumn ;
BEGIn
  return l_new;
END;

--***************************************************************************
-- new_clsMeasureLOV
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsMeasureLOV.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsMeasureLOV return BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV ;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsPeriodicity
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsPeriodicity.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsPeriodicity return BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsCalendar
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsCalendar.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsCalendar return BSC_METADATA_OPTIMIZER_PKG.clsCalendar IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsCalendar;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsMasterTable
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsMasterTable.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsMasterTable return BSC_METADATA_OPTIMIZER_PKG.clsMasterTable IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsMasterTable;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsLevels
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsLevels.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsLevels return BSC_METADATA_OPTIMIZER_PKG.clsLevels IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsLevels;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_tabrec_clsLevels
--
--  DESCRIPTION:
--    Returns an unitialized variable of class tabrec_clsLevels.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_tabrec_clsLevels return BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels IS
l_new BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsBasicTable
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsBasicTable.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsBasicTable return BSC_METADATA_OPTIMIZER_PKG.clsBasicTable IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsBasicTable;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_clsLevelCombinations
--
--  DESCRIPTION:
--    Returns an unitialized variable of class clsLevelCombinations.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_clsLevelCombinations return BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations;
BEGIn
  return l_new;
END;
--***************************************************************************
-- new_TNewITables
--
--  DESCRIPTION:
--    Returns an unitialized variable of class TNewITables.
--    This is to clear up the memory of the object it is assigned to.
--***************************************************************************
FUNCTION new_TNewITables return BSC_METADATA_OPTIMIZER_PKG.TNewITables IS
l_new BSC_METADATA_OPTIMIZER_PKG.TNewITables;
BEGIn
  return l_new;
END;

--****************************************************************************
--  InitArrReservedWords
--
--  DESCRIPTION:
--     Initialize the array of reserved words
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--     Arun Santhanam 09 July 2003
--****************************************************************************

PROCEDURE InitArrReservedWords IS
BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  BSC_MO_HELPER_PKG.writeTmp('Inside InitArrReservedWords', FND_LOG.LEVEL_PROCEDURE);
   END IF;

  BSC_METADATA_OPTIMIZER_PKG.gNumArrReservedWords := 556;

  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(0) := 'ABORT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(1) := 'ACCESS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(2) := 'ACCOUNT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(3) := 'ACCEPT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(4) := 'ACCESS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(5) := 'ACTIVATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(6) := 'ADD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(7) := 'ADMIN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(8) := 'AFTER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(9) := 'ALL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(10) := 'ALL_ROWS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(11) := 'ALLOCATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(12) := 'ALTER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(13) := 'ANALYZE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(14) := 'AND';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(15) := 'ANY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(16) := 'ARCHIVE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(17) := 'ARCHIVELOG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(18) := 'ARRAY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(19) := 'ARRAYLEN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(20) := 'AS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(21) := 'ASC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(22) := 'ASSERT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(23) := 'ASSIGN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(24) := 'AT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(25) := 'AUDIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(26) := 'AUTHENTICATED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(27) := 'AUTHORIZATION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(28) := 'AUTOEXTEND';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(29) := 'AUTOMATIC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(30) := 'AVG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(31) := 'BACKUP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(32) := 'BASE_TABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(33) := 'BECOME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(34) := 'BEFORE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(35) := 'BEGIN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(36) := 'BETWEEN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(37) := 'BFILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(38) := 'BIGINTBY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(39) := 'BINARY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(40) := 'BINARY_INTEGER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(41) := 'BIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(42) := 'BITMAP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(43) := 'BLOB';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(44) := 'BLOCK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(45) := 'BODY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(46) := 'BOOLEAN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(47) := 'BY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(48) := 'CACHE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(49) := 'CACHE_INSTANCES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(50) := 'CANCEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(51) := 'CASCADE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(52) := 'CASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(53) := 'CAST';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(54) := 'CFILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(55) := 'CHAINED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(56) := 'CHANGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(57) := 'CHAR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(58) := 'CHAR_BASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(59) := 'CHAR_CS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(60) := 'CHARACTER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(61) := 'CHARACTERS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(62) := 'CHECK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(63) := 'CHECKPOINT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(64) := 'CHOOSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(65) := 'CHUNK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(66) := 'CLEAR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(67) := 'CLOB';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(68) := 'CLONE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(69) := 'CLOSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(70) := 'CLOSED_CACHED_OPEN_';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(71) := 'CLUSTER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(72) := 'CLUSTERS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(73) := 'COALESCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(74) := 'COLAUTH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(75) := 'COLUMN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(76) := 'COLUMNS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(77) := 'COMMENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(78) := 'COMMIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(79) := 'COMMITTED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(80) := 'COMPATIBILITY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(81) := 'COMPILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(82) := 'COMPLETE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(83) := 'COMPOSITE_LIMIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(84) := 'COMPRESS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(85) := 'COMPUTE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(86) := 'CONNECT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(87) := 'CONNECT_TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(88) := 'CONNECTCREATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(89) := 'CONSTANT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(90) := 'CONSTRAINT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(91) := 'CONSTRAINTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(92) := 'CONTENTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(93) := 'CONTINUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(94) := 'CONTROLFILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(95) := 'CONVERT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(96) := 'COST';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(97) := 'COUNT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(98) := 'CPU_PER_CALL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(99) := 'CPU_PER_SESSION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(100) := 'CRASH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(101) := 'CREATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(102) := 'CURRENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(103) := 'CURRENT_SCHEMA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(104) := 'CURRENT_USER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(105) := 'CURRVAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(106) := 'CURSOR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(107) := 'CURSORS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(108) := 'CYCLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(109) := 'DANGLING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(110) := 'DATA_BASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(111) := 'DATABASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(112) := 'DATABASEDATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(113) := 'DATAFILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(114) := 'DATAFILES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(115) := 'DATAOBJNO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(116) := 'DATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(117) := 'DBA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(118) := 'DEALLOCATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(119) := 'DEBUG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(120) := 'DEBUGOFF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(121) := 'DEBUGON';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(122) := 'DEC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(123) := 'DECIMAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(124) := 'DECLARE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(125) := 'DEFAULT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(126) := 'DEFERRABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(127) := 'DEFERRED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(128) := 'DEFINITION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(129) := 'DEGREE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(130) := 'DELAY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(131) := 'DELETE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(132) := 'DEREF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(133) := 'DESC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(134) := 'DIGITS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(135) := 'DIRECTORY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(136) := 'DISABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(137) := 'DISCONNECT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(138) := 'DISMOUNT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(139) := 'DISPOSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(140) := 'DISTINCT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(141) := 'DISTRIBUTED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(142) := 'DML';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(143) := 'DO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(144) := 'DOUBLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(145) := 'DROP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(146) := 'DUMP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(147) := 'EACH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(148) := 'ELSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(149) := 'ELSIF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(150) := 'ENABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(151) := 'END';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(152) := 'ENFORCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(153) := 'ENTRY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(154) := 'ESCAPE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(155) := 'ESTIMATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(156) := 'EVENTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(157) := 'EXCEPTION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(158) := 'EXCEPTION_INIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(159) := 'EXCEPTIONS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(160) := 'EXCHANGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(161) := 'EXCLUDING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(162) := 'EXCLUSIVE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(163) := 'EXECUTE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(164) := 'EXEMPT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(165) := 'EXISTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(166) := 'EXIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(167) := 'EXPIRE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(168) := 'EXPLAIN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(169) := 'EXTENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(170) := 'EXTENTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(171) := 'EXTERNALLY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(172) := 'FAILED_LOGIN_ATTEMPTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(173) := 'FALSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(174) := 'FAST';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(175) := 'FETCH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(176) := 'FILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(177) := 'FIRST_ROWS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(178) := 'FLAGGER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(179) := 'FLOAT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(180) := 'FLUSH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(181) := 'FOR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(182) := 'FORCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(183) := 'FOREIGN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(184) := 'FORM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(185) := 'FREELIST';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(186) := 'FREELISTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(187) := 'FROM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(188) := 'FULL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(189) := 'FUNCTION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(190) := 'GENERIC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(191) := 'GLOBAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(192) := 'GLOBAL_NAME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(193) := 'GLOBALLY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(194) := 'GOTO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(195) := 'GRANT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(196) := 'GROUP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(197) := 'GROUPS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(198) := 'HASH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(199) := 'HASHKEYS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(200) := 'HAVING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(201) := 'HEADER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(202) := 'HEAP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(203) := 'IDENTIFIED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(204) := 'IDLE_TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(205) := 'IF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(206) := 'IMMEDIATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(207) := 'IN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(208) := 'INCLUDING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(209) := 'INCREMENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(210) := 'IND_PARTITION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(211) := 'INDEX';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(212) := 'INDEXED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(213) := 'INDEXES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(214) := 'INDICATOR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(215) := 'INITIAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(216) := 'INITIALLY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(217) := 'INITRANS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(218) := 'INSERT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(219) := 'INSTANCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(220) := 'INSTANCES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(221) := 'INSTEAD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(222) := 'INT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(223) := 'INTEGER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(224) := 'INTERFACE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(225) := 'INTERMEDIATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(226) := 'INTERSECT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(227) := 'INTO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(228) := 'IS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(229) := 'ISOLATION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(230) := 'ISOLATION_LEVEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(231) := 'KEEP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(232) := 'KEY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(233) := 'KILL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(234) := 'LAYER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(235) := 'LESS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(236) := 'LEVEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(237) := 'LEVELLIKE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(238) := 'LIBRARY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(239) := 'LIKE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(240) := 'LIMIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(241) := 'LIMITED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(242) := 'LINK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(243) := 'LIST';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(244) := 'LOB';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(245) := 'LOCAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(246) := 'LOCK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(247) := 'LOG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(248) := 'LOGFILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(249) := 'LOGGING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(250) := 'LOGICAL_READS_PER_';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(251) := 'LOGICAL_READS_PER_CALL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(252) := 'LONG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(253) := 'LOOP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(254) := 'MANAGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(255) := 'MASTER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(256) := 'MAX';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(257) := 'MAXARCHLOGS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(258) := 'MAXDATAFILES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(259) := 'MAXEXTENTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(260) := 'MAXINSTANCES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(261) := 'MAXLOGFILES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(262) := 'MAXLOGHISTORY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(263) := 'MAXLOGMEMBERS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(264) := 'MAXSIZE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(265) := 'MAXTRANS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(266) := 'MAXVALUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(267) := 'MEMBER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(268) := 'MIN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(269) := 'MINEXTENTS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(270) := 'MINIMUM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(271) := 'MINUS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(272) := 'MINVALUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(273) := 'MLSLABEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(274) := 'MOD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(275) := 'MODE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(276) := 'MODIFY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(277) := 'MOUNT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(278) := 'MOVE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(279) := 'MTS_DISPATCHERS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(280) := 'MULTISET';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(281) := 'NATIONAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(282) := 'NATURAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(283) := 'NATURALN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(284) := 'NCHAR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(285) := 'NCHAR_CS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(286) := 'NCLOB';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(287) := 'NEEDED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(288) := 'NESTED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(289) := 'NETWORK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(290) := 'NEW';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(291) := 'NEXT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(292) := 'NEXTVAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(293) := 'NLS_CALENDAR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(294) := 'NLS_CHARACTERSET';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(295) := 'NLS_ISO_CURRENCY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(296) := 'NLS_LANGUAGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(297) := 'NLS_NUMERIC_';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(298) := 'NLS_SORT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(299) := 'NLS_TERRITORY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(300) := 'NOARCHIVELOG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(301) := 'NOAUDIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(302) := 'NOCACHE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(303) := 'NOCOMPRESS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(304) := 'NOCYCLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(305) := 'NOFORCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(306) := 'NOLOGGING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(307) := 'NOMAXVALUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(308) := 'NOMINVALUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(309) := 'NONE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(310) := 'NOORDER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(311) := 'NOOVERIDE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(312) := 'NOPARALLEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(313) := 'NORESETLOGS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(314) := 'NOREVERSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(315) := 'NORMAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(316) := 'NOS_SPECIAL_CHARS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(317) := 'NOSORT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(318) := 'NOT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(319) := 'NOTHING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(320) := 'NOWAIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(321) := 'NULL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(322) := 'NUMBER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(323) := 'NUMBER_BASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(324) := 'NUMERIC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(325) := 'NVARCHAR2';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(326) := 'OBJECT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(327) := 'OBJNO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(328) := 'OBJNO_REUSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(329) := 'OF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(330) := 'OFF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(331) := 'OFFLINE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(332) := 'OID';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(333) := 'OIDINDEX';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(334) := 'OLD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(335) := 'ON';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(336) := 'ONLINE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(337) := 'ONLY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(338) := 'OPCODE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(339) := 'OPEN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(340) := 'OPTIMAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(341) := 'OPTIMIZER_GOAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(342) := 'OPTION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(343) := 'OR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(344) := 'ORDER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(345) := 'ORGANIZATION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(346) := 'OTHERS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(347) := 'OUT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(348) := 'OVERFLOW';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(349) := 'OWN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(350) := 'PACKAGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(351) := 'PARALLEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(352) := 'PARTITION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(353) := 'PASSWORD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(354) := 'PASSWORD_GRACE_TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(355) := 'PASSWORD_LIFE_TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(356) := 'PASSWORD_LOCK_TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(357) := 'PASSWORD_REUSE_MAX';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(358) := 'PASSWORD_REUSE_TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(359) := 'PASSWORD_VERIFY_';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(360) := 'PCTFREE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(361) := 'PCTINCREASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(362) := 'PCTTHRESHOLD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(363) := 'PCTUSED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(364) := 'PCTVERSION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(365) := 'PERCENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(366) := 'PERMANENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(367) := 'PLAN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(368) := 'PLS_INTEGER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(369) := 'PLSQL_DEBUG';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(370) := 'POSITIVE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(371) := 'POSITIVEN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(372) := 'POST_TRANSACTION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(373) := 'PRAGMA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(374) := 'PRECISION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(375) := 'PRESERVE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(376) := 'PRIMARY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(377) := 'PRIOR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(378) := 'PRIVATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(379) := 'PRIVATE_SGA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(380) := 'PRIVILEGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(381) := 'PRIVILEGES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(382) := 'PROCEDURE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(383) := 'PROFILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(384) := 'PUBLIC';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(385) := 'PURGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(386) := 'QUARTER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(387) := 'QUEUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(388) := 'QUOTA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(389) := 'RAISE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(390) := 'RANGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(391) := 'RAW';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(392) := 'RBA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(393) := 'READ';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(394) := 'REAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(395) := 'REBUILD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(396) := 'RECORD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(397) := 'RECOVER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(398) := 'RECOVERABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(399) := 'RECOVERY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(400) := 'REF';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(401) := 'REFERENCES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(402) := 'REFERENCING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(403) := 'RELEASE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(404) := 'REFRESH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(405) := 'RENAME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(406) := 'REMR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(407) := 'REPLACE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(408) := 'RESET';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(409) := 'RESETLOGS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(410) := 'RESIZE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(411) := 'RESOURCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(412) := 'RESTRICTED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(413) := 'RETURN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(414) := 'RETURNING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(415) := 'REUSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(416) := 'REVERSE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(417) := 'REVOKE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(418) := 'ROLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(419) := 'ROLES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(420) := 'ROLLBACK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(421) := 'ROW';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(422) := 'ROWID';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(423) := 'ROWLABEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(424) := 'ROWNUM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(425) := 'ROWS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(426) := 'ROWTYPE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(427) := 'RULE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(428) := 'RUN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(429) := 'SAMPLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(430) := 'SAVEPOINT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(431) := 'SCAN_INSTANCES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(432) := 'SCHEMA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(433) := 'SCN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(434) := 'SCOPE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(435) := 'SD_ALL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(436) := 'SD_INHIBIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(437) := 'SD_SHOW';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(438) := 'SEG_BLOCK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(439) := 'SEG_FILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(440) := 'SEGMENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(441) := 'SELECT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(442) := 'SEPARATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(443) := 'SEQUENCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(444) := 'SERIALIZABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(445) := 'SESSION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(446) := 'SESSION_CACHED_';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(447) := 'SESSIONS_PER_USER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(448) := 'SET';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(449) := 'SHARE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(450) := 'SHARED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(451) := 'SHARED_POOL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(452) := 'SHRINK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(453) := 'SIZE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(454) := 'SKIM_UNUSABLE_INDEXES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(455) := 'SMALLINT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(456) := 'SNAPSHOT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(457) := 'SOME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(458) := 'SORT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(459) := 'SPACE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(460) := 'SPECIFICATION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(461) := 'SPLIT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(462) := 'SQL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(463) := 'SQL_TRACE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(464) := 'SQLCODE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(465) := 'SQLERRM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(466) := 'SQLERROR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(467) := 'STANDBY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(468) := 'START';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(469) := 'STATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(470) := 'STATEMENT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(471) := 'STATEMENT_ID';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(472) := 'STATISTICS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(473) := 'STOP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(474) := 'STORAGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(475) := 'STORE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(476) := 'STRUCTURE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(477) := 'STTDEV';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(478) := 'SUBTYPE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(479) := 'SUCCESSFUL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(480) := 'SUM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(481) := 'SWITCH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(482) := 'SYNONYM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(483) := 'SYSDATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(484) := 'SYSDBA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(485) := 'SYSOPER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(486) := 'SYSTEM';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(487) := 'TABAUTH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(488) := 'TABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(489) := 'TABLES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(490) := 'TABLESPACE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(491) := 'TABLESPACE_NO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(492) := 'TABNO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(493) := 'TASK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(494) := 'TEMPORARY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(495) := 'TERMINATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(496) := 'THAN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(497) := 'THE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(498) := 'THEN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(499) := 'THENTINYINT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(500) := 'THREAD';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(501) := 'TIME';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(502) := 'TIMESTAMP';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(503) := 'TO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(504) := 'TOPLEVEL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(505) := 'TRACE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(506) := 'TRACING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(507) := 'TRANSACTION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(508) := 'TRANSITIONAL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(509) := 'TRIGGER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(510) := 'TRIGGERS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(511) := 'TRUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(512) := 'TRUNCATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(513) := 'TX';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(514) := 'TYPE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(515) := 'UBA';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(516) := 'UID';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(517) := 'UNARCHIVED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(518) := 'UNDER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(519) := 'UNDO';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(520) := 'UNION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(521) := 'UNIQUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(522) := 'UNLIMITED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(523) := 'UNLOCK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(524) := 'UNRECOVERABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(525) := 'UNTIL';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(526) := 'UNUSABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(527) := 'UNUSED';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(528) := 'UPDATABLE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(529) := 'UPDATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(530) := 'USAGE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(531) := 'USE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(532) := 'USER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(533) := 'USING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(534) := 'VALIDATE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(535) := 'VALIDATION';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(536) := 'VALUE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(537) := 'VALUES';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(538) := 'VARBINARY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(539) := 'VARCHAR';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(540) := 'VARCHAR2';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(541) := 'VARIANCE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(542) := 'VARRAY';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(543) := 'VARYING';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(544) := 'VIEW';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(545) := 'VIEWS';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(546) := 'WHEN';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(547) := 'WHENEVER';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(548) := 'WHERE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(549) := 'WHILE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(550) := 'WITH';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(551) := 'WITHOUT';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(552) := 'WORK';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(553) := 'WRITE';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(554) := 'XID';
  BSC_METADATA_OPTIMIZER_PKG.gArrReservedWords(555) := 'XOR';

   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  BSC_MO_HELPER_PKG.writeTmp('Completed InitArrReservedWords', FND_LOG.LEVEL_PROCEDURE);
   END IF;

End;



--****************************************************************************
-- InitLOV
--
--  DESCRIPTION:
--     Initialize collection gLUV with the unique list of variables
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE InitLOV IS

	l_stmt varchar2(1000);
  FieldLOV BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV;
  --BSC-PMF Integration: It is not necessary to filter out PMF measures
  --because in BSC_DB_MEASURE_COLS_VL are only BSC measures
  --CURSOR c1 IS
  --SELECT MEASURE_COL, HELP, MEASURE_GROUP_ID, PROJECTION_ID, NVL(MEASURE_TYPE, 1) MTYPE
	 --FROM BSC_DB_MEASURE_COLS_VL ORDER BY MEASURE_COL ;

  --BSC-PMF Integration: Need to filter out PMF measures

  /*CURSOR c1 IS
  SELECT MEASURE_COL, HELP, MEASURE_GROUP_ID, PROJECTION_ID, NVL(MEASURE_TYPE, 1) MTYPE
  FROM BSC_DB_MEASURE_COLS_VL
   WHERE MEASURE_COL NOT IN
   (
       SELECT MEASURE_COL FROM BSC_SYS_MEASURES M
       WHERE NVL(M.SOURCE, 'BSC') = 'PMF'
      and  not exists( select 1 from BSC_SYS_MEASURES P where p.Measure_Col = m.measure_col
	           and NVL(p.SOURCE, 'BSC') = 'BSC')
   ) ORDER BY MEASURE_COL;*/
  --BSC autogen

  CURSOR c1 IS
  SELECT DB.MEASURE_COL, DB.HELP, DB.MEASURE_GROUP_ID, DB.PROJECTION_ID, NVL(DB.MEASURE_TYPE, 1) MTYPE, M.SOURCE
    FROM BSC_DB_MEASURE_COLS_VL DB,
         BSC_SYS_MEASURES M
   WHERE db.Measure_Col = m.measure_col
     AND M.SOURCE = 'BSC'
   UNION
  SELECT M.MEASURE_COL, null HELP, -1 MEASURE_GROUP_ID, 0 PROJECTION_ID, 1 MTYPE, M.SOURCE
    FROM BSC_SYS_MEASURES M
   WHERE M.SOURCE='PMF'
   ORDER BY MEASURE_COL;

  cRow c1%ROWTYPE;

BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside InitLOV', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  OPEN c1;
  LOOP
    FETCH c1 INTO cRow;
    EXIT WHEN c1%NOTFOUND;
    FieldLOV := bsc_mo_helper_pkg.new_clsMeasureLOV;
    FieldLOV.fieldName := cRow.MEASURE_COL;
    FieldLOV.source := nvl(cRow.Source, 'BSC');
	IF (cRow.HELP IS NOT NULL) THEN
      FieldLOV.Description := cRow.HELP;
    END IF;
    IF (cRow.MEASURE_GROUP_ID IS NOT NULL) THEN
      FieldLOV.groupCode := cRow.MEASURE_GROUP_ID;
    Else
      FieldLOV.groupCode := -1;
    END IF;
    IF (cRow.PROJECTION_ID IS NOT NULL) THEN
      FieldLOV.prjMethod := cRow.PROJECTION_ID;
    Else
      FieldLOV.prjMethod := 0; --no projection
    END IF;
    FieldLOV.measureType := cRow.MTYPE;
    --BSC autogen
    BSC_METADATA_OPTIMIZER_PKG.gLOV(BSC_METADATA_OPTIMIZER_PKG.gLOV.Count) := FieldLOV;
  END Loop;
  CLOSE c1;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Completed InitLOV', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  return;
  exception when others then
    bsc_mo_helper_pkg.writeTmp('Exception in InitLOV : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    TerminateWithError('BSC_VAR_LIST_INIT_FAILED', 'InitLOV');
  	raise;
End;

--***************************************************************************
--  getKPIPropertyValue : LeerMatrixINfo
--  DESCRIPTION:
--     Return the value oif the given variable of the given indicator from
--     table BSC_KPI_PROPERTIES.
--
--  PARAMETERS:
--     Indic: indicator code
--     Variable: variable name
--     Default: default value
--     db_obj: database
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function getKPIPropertyValue(Indic IN NUMBER, Variable IN VARCHAR2,
	def IN NUMBER) return NUMBER IS
l_temp number := null;
l_stmt varchar2(1000);
cv   CurTyp;
l_error VARCHAR2(400);

CURSOR cProperty IS
  SELECT PROPERTY_VALUE
  FROM BSC_KPI_PROPERTIES
  WHERE INDICATOR = Indic
  AND PROPERTY_CODE = Variable;

BEGIN
  OPEN cProperty;
  FETCH cProperty INTO l_temp;
  CLOSE cProperty;

  -- if its not MV, ignore AW's IMPLEMENTATION_TYPE value, override it with 1
  If Variable=BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE AND BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV =false Then
    l_temp := 1;
  END IF;

  IF l_temp is not null THEN
    return l_temp;
  END IF;

   return def;
   EXCEPTION WHEN OTHERS THEN
      writeTmp('Exception in getKPIPropertyValue for Indic='||Indic||', Variable='||Variable||', def='||def,
		FND_LOG.LEVEL_EXCEPTION, true);
      l_error := sqlerrm;
      writeTmp('Exception is '||l_error, FND_LOG.LEVEL_EXCEPTION, true);

      raise;
End;
--===========================================================================+
--
--   Name:      IsNumber
--   Description:   Returns true if the string is a number
--   Parameters:
--============================================================================*/
FUNCTION IsNumber (str IN VARCHAR2) RETURN BOOLEAN IS
l_temp NUMBER := -1;
BEGIN
	l_temp:= to_number(str);
	return true;
	exception when others then
		return false;
END;

--===========================================================================+
--
--  Name:      Get_New_Big_In_Cond_Number
--   Description:   Clean values for the given variable_id and return a 'IN'
--            condition string.
--   Parameters:  x_variable_id  variable id.
--            x_column_name  column name (left part of the condition)
--============================================================================

Function Get_New_Big_In_Cond_Number( x_variable_id IN NUMBER, x_column_name IN VARCHAR2)
return VARCHAR2 IS
  l_stmt varchar2(1000);
  l_cond varchar2(1000);
  l_error VARCHAR2(2000);
BEGIN


  DELETE FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = bsc_metadata_optimizer_pkg.g_session_id AND VARIABLE_ID = x_variable_id;

  l_cond := x_column_name || ' IN (' ||
  		' SELECT VALUE_N FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = '||bsc_metadata_optimizer_pkg.g_session_id||
  		' AND VARIABLE_ID = ' || x_variable_id || ')';

  return l_cond;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception in Get_New_Big_In_Cond_Number :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;
End;

PROCEDURE Add_Value_BULK(x_variable_id IN NUMBER, x_value IN DBMS_SQL.NUMBER_TABLE) IS

BEGIN
  IF (x_value.count=0) THEN
    return;
  END IF;
  FORALL i IN x_value.first..x_value.last
   INSERT INTO BSC_TMP_BIG_IN_COND(session_id, variable_id, value_n)
   VALUES
   (bsc_metadata_optimizer_pkg.g_session_id, x_variable_id, x_value(i));
  exception when others then
   writeTmp('exception in add_value_bulk for number table', FND_LOG.LEVEL_EXCEPTION, true);
   raise;
END;

PROCEDURE Add_Value_BULK(x_variable_id IN NUMBER, x_value IN DBMS_SQL.VARCHAR2_TABLE) IS

BEGIN
  IF (x_value.count=0) THEN
    return;
  END IF;
 FORALL i IN x_value.first..x_value.last
   INSERT INTO BSC_TMP_BIG_IN_COND(session_id, variable_id, value_v)
   VALUES
   (bsc_metadata_optimizer_pkg.g_session_id, x_variable_id, x_value(i));
 exception when others then
   writeTmp('exception in add_value_bulk for varchar2 table', FND_LOG.LEVEL_EXCEPTION, true);
   raise;
END;
--===========================================================================+
--   Name:      Add_Value_Big_In_Cond_Number
--   Description:   Insert the given value into the temporary table of big
--            'in' conditions for the given variable_id.
--   Parameters:  x_variable_id  variable id.
--            x_value      value
--============================================================================
PROCEDURE Add_Value_Big_In_Cond_Number(x_variable_id IN NUMBER, x_value IN NUMBER) IS
l_stmt varchar2(300);
l_error varchar2(2000);
BEGIN
	bsc_apps.Add_Value_Big_In_Cond(x_variable_id , x_value);

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception in Add_Value_Big_In_Cond_Number :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;
End;


--===========================================================================+
--   Name:      Get_New_Big_In_Cond_Varchar2
--   Description:   Clean values for the given variable_id and return a 'IN'
--            condition string.
--   Parameters:  x_variable_id  variable id.
--            x_column_name  column name (left part of the condition)
--============================================================================
Function Get_New_Big_In_Cond_Varchar2( x_variable_id in number, x_column_name in varchar2)
return VARCHAR2 IS

  l_stmt varchar2(300);
  cond   varchar2(1000);
  l_error varchar2(1000);
BEGIN
  DELETE FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = bsc_metadata_optimizer_pkg.g_session_id AND VARIABLE_ID = x_variable_id;
  cond := 'UPPER('||  x_column_name  || ') IN ('||
  		' SELECT UPPER(VALUE_V) FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = '||bsc_metadata_optimizer_pkg.g_session_id
                 ||' AND VARIABLE_ID = '||x_variable_id||')';
  return cond;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception in Get_New_Big_In_Cond_Varchar2 :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;
End;

--===========================================================================+
--   Name:      Add_Value_Big_In_Cond_Varchar2
--   Description:   Insert the given value into the temporary table of big
--            --in' conditions for the given variable_id.
--   Parameters:  x_variable_id  variable id.
--            x_value      value
--============================================================================*/
PROCEDURE Add_Value_Big_In_Cond_Varchar2(x_variable_id IN NUMBER, x_value IN VARCHAR2) IS
l_stmt varchar2(300);
l_error varchar2(2000);
BEGIN

	bsc_apps.Add_Value_Big_In_Cond(x_variable_id , x_value);

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception in Add_Value_Big_In_Cond_Varchar2 :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;
End;


/****************************************************************************
--  InsertRelatedTables
--  DESCRIPTION:
--     Insert in the array garrTables() all the tables in the current
--     graph that have any relation with the tables in the array
--     arrTables().
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************/

PROCEDURE InsertRelatedTables(arrTables in dbms_Sql.varchar2_table,
		 numTables in number) IS

  arrNewTables dbms_sql.varchar2_table;
  numNewTables number := 0;
  strWhereInNewTables varchar2(1000);
  strWhereNotInNewTables varchar2(1000);
  l_stmt varchar2(1000);
  l_table varchar2(100);
  cv   CurTyp;


  strWhereInChildTables VARCHAR2(1000);
  strWhereInParentTables VARCHAR2(1000);

  l_error varchar2(1000);
  l_test number;

  l_arr_tables dbms_sql.varchar2_table;
BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
     writeTmp( 'Inside InsertRelatedTables, numTables='||numTables, fnd_log.level_procedure, false);
   END IF;
   writeTmp('Insert related tables, tables are ', fnd_log.level_statement, false);
   write_this(arrNewTables, fnd_log.level_statement, false);

   numNewTables := 0;

   --BSC-MV Note: Review this procedure. I changed the logic to improve performance

   If numTables > 0 Then
     strWhereInNewTables := Get_New_Big_In_Cond_Varchar2(3, 'TABLE_NAME');
     strWhereNotInNewTables := null;
     strWhereInChildTables := Get_New_Big_In_Cond_Varchar2(4, 'SOURCE_TABLE_NAME');
     strWhereInParentTables := Get_New_Big_In_Cond_Varchar2(5, 'TABLE_NAME');
     Add_Value_Bulk(4, arrTables);
     Add_Value_Bulk(5, arrTables);

     /*For i IN 0..numTables - 1 LOOP
       Add_Value_Big_In_Cond_Varchar2 (4, arrTables(i));
       Add_Value_Big_In_Cond_Varchar2 (5, arrTables(i));
     END LOOP; */

     --insert the children
     l_stmt := 'SELECT TABLE_NAME FROM BSC_DB_TABLES_RELS WHERE '|| strWhereInChildTables;
     OPEN cv FOR l_stmt;
     LOOP
       FETCH cv INTO l_table;
       EXIT WHEN cv%NOTFOUND;
       If Not SearchStringExists(BSC_METADATA_OPTIMIZER_PKG.garrTables, BSC_METADATA_OPTIMIZER_PKG.gnumTables, l_table) Then
         BSC_METADATA_OPTIMIZER_PKG.garrTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables) := l_table;
         BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.gnumTables + 1;
         arrNewTables(numNewTables) := l_table;
         numNewTables := numNewTables + 1;
         --Add_Value_Big_In_Cond_Varchar2 (3, l_table);
       End If;
     END LOOP;
     Close cv;
     --Add_value_Bulk(3, arrNewTables);
     l_test := numNewTables;
     IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
       writeTmp('No. of new children = '||   numNewTables);
     END IF;
     --insert the parents
     l_stmt := 'SELECT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS WHERE '|| strWhereInParentTables;
     l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'TABLE_NAME');
     l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'VALUE_V');
     OPEN cv FOR l_stmt;
     FETCH cv BULK COLLECT INTO l_arr_tables;
     CLOSE cv;
     FOR i IN 1..l_arr_tables.count LOOP
       l_table := l_arr_tables(i);
       If Not searchStringExists(BSC_METADATA_OPTIMIZER_PKG.garrTables, BSC_METADATA_OPTIMIZER_PKG.gnumTables, l_table) Then
         BSC_METADATA_OPTIMIZER_PKG.garrTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables) := l_table;
         BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.gnumTables + 1;
         arrNewTables(numNewTables) := l_table;
         numNewTables := numNewTables + 1;
       End If;
     END LOOP;

     IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
       writeTmp('No. of new parents = '||   (numNewTables-l_test));
     END IF;
     Add_Value_Bulk(3, arrNewTables);

     If numNewTables > 0 Then
     --if one table of one indicator is marked then all tables of this indicator are marked
     --EDW Integration note:
     --In BSC_KPI_DATA_TABLES, Metadata Optimizer is storing the name of the view (Example: BSC_3001_0_0_5_V)
     --and the name of the S table for BSC Kpis (Example: BSC_3002_0_0_5)
     --In this procedure we need to get tables names from a view BSC_KPI_DATA_TABLES_V.

     --BSC-MV Note: We are going to use BSC_KPI_DATA_TABLES in all the code.
     --EDW logic is not used and need to be reviewd in the future.

       strWhereNotInNewTables := 'NOT (' || strWhereInNewTables || ')';
       l_stmt := 'SELECT TABLE_NAME FROM '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' WHERE INDICATOR IN (
                SELECT INDICATOR FROM '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' WHERE '|| strWhereInNewTables||')
                AND '|| strWhereNotInNewTables ||' AND TABLE_NAME IS NOT NULL ';
       l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'TABLE_NAME');
       l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'VALUE_V');
       OPEN cv FOR l_stmt;
       FETCH cv BULK COLLECT INTO l_arr_tables;
       CLOSE cv;
       FOR i in 1..l_arr_tables.count LOOP
         l_table := l_arr_tables(i);
         If Not searchStringExists(BSC_METADATA_OPTIMIZER_PKG.garrTables, BSC_METADATA_OPTIMIZER_PKG.gnumTables, l_table) Then
           BSC_METADATA_OPTIMIZER_PKG.garrTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables) := l_table;
           BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.gnumTables + 1;
           arrNewTables(numNewTables) := l_table;
           numNewTables := numNewTables + 1;
         End If;
       END Loop;
       InsertRelatedTables (arrNewTables, numNewTables);
     End If;
   End If;

   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
     writeTmp( 'Compl. InsertRelatedTables', fnd_log.level_procedure, false);
   END IF;


  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception in InsertRelatedTables :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;

End;


--***************************************************************************
--  AddIndicator
--  DESCRIPTION:
--     Add the given indicator to the given indicator collection.
--     The collection is made of objects of class clsIndicador
--  PARAMETERS:
--     collIndicadores: indicators collection
--     Cod: indicator code
--     Name: indicator name
--     TipoIndic: type of indicator
--     TipoConfig: type of configuration
--     Per_Inter: periodicity in the panel
--     OptimizationMode: 0- pre-calculated, 1- standard, 2-benchamarks at diff level.
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

PROCEDURE AddIndicator(collIndicadores IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicator, p_Code NUMBER,
			p_Name varchar2, p_indicatorType NUMBER, p_configType NUMBER,
			p_per_inter NUMBER, p_optMode NUMBER, p_action_flag NUMBER,
			p_share_flag NUMBER, p_src_ind NUMBER, p_edw_flag NUMBER,
			p_impl_type NUMBER) IS
  Indic BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
  l_error varchar2(1000);
BEGIN

  Indic.Code := p_code;
  Indic.Name := p_Name;
  Indic.IndicatorType := p_indicatorType;
  Indic.ConfigType := p_configType;
  Indic.Periodicity := p_Per_Inter;
  Indic.OptimizationMode := p_OptMode;
  Indic.Action_Flag := p_action_Flag;
  Indic.Share_Flag := p_share_Flag;
  Indic.Source_Indicator := p_Src_Ind ;
  Indic.EDW_Flag := p_EDW_Flag;
  Indic.Impl_type := p_impl_type;
  IF  (collIndicadores.count>0) THEN
      collIndicadores(collINdicadores.LAST+1) := indic;
  ELSE
      collIndicadores(0) := indic;
  END IF;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception in AddIndicator :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;
End;

/****************************************************************************
--  GetCamposExpresion
--  DESCRIPTION:
--     Get in an array the list of fields in the given expression.
--     Return the number of fields.
--     Example. Expresion = 'IIF(Not IsNull(SUM(A)), C, B)'
--     CamposExpresion() = |A|C|B|, GetCamposExpresion = 2
--  PARAMETERS:
--     CamposExpresion(): array to be populated
--     Expresion: expression
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************/
Function GetFieldExpression(FieldExpresion IN OUT NOCOPY dbms_sql.varchar2_table, Expresion IN VARCHAR2)
return NUMBER is

  i number;
  NumFieldsExpresion varchar2(1000);
  fields dbms_sql.varchar2_table;
  NumFields number;
  cExpresion varchar2(1000);
  l_error VARCHAR2(400);
BEGIN

  cExpresion := Expresion;
  --Replace the operators by ' '
  i := 0;
  LOOP
	EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gNumReservedOperators;
      cExpresion := replace(cExpresion, BSC_METADATA_OPTIMIZER_PKG.gReservedOperators(i), ' ');
      i:= i +1;
  END LOOP;

  --Break down the expression which is separated by ' '
  NumFields := DecomposeString(cExpresion,  ' ', fields);

  NumFieldsExpresion := 0;

  i:=0;
  LOOP
	EXIT WHEN i= NumFields;
      IF fields(i) IS NOT NULL THEN
        IF FindIndexVARCHAR2(BSC_METADATA_OPTIMIZER_PKG.gReservedFunctions, Fields(i)) = -1 THEN
          --The word fields(i) is not a reserved function
          IF UPPER(Fields(i)) <> 'NULL' THEN
              --the word is not 'NULL'
              IF Not IsNumber(Fields(i)) THEN
                --the word is not a constant
                FieldExpresion(NumFieldsExpresion) := Fields(i);
                NumFieldsExpresion := NumFieldsExpresion + 1;
              END IF;
          END IF;
        END IF;
      END IF;
	i:= i+1;
  END LOOP;
	return NumFieldsExpresion;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in GetFieldExpression : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;

End;



--****************************************************************************
--  MarkIndicsForNonStrucChanges
--  DESCRIPTION:
--     The array garrIndics4() is initialized with currently flagged indicators
--     for non-structural changes. (Protoype_Flag = 4)
--     This procedure adds to the same array the related indicators.
--     Designer is only flagging the indicators
--     that are using the measure direclty. We need to flag other indicators
--     using the same measures alone or as part of a formula.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE MarkIndicsForNonStrucChanges IS
  l_stmt Varchar2(1000);
  strWhereInIndics Varchar2(1000);
  strWhereNotInIndics Varchar2(1000);
  strWhereInMeasures Varchar2(1000);
  i NUMBER := 0;
  arrMeasuresCols  DBMS_SQL.VARCHAR2_TABLE;
  arrMeasures_src  DBMS_SQL.VARCHAR2_TABLE;
  numMeasures NUMBER;
  arrRelatedMeasuresIds DBMS_SQL.NUMBER_TABLE;

  --measureCol Varchar2(1000);
  Operands DBMS_SQL.VARCHAR2_TABLE;
  NumOperands NUMBER;
  l_measureID NUMBER;
  l_measureCol VARCHAR2(1000);
  l_source VARCHAR2(1000);
  cv   CurTyp;
  l_error varchar2(4000);
  l_stack VARCHAR2(32000);
  l_indicator NUMBER;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp('Inside MarkIndicsForNonStrucChanges', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 <= 0 THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Completed MarkIndicsForNonStrucChanges, count was 0', FND_LOG.LEVEL_PROCEDURE);
    END IF;
    return;
  END IF;
  --Init and array with the measures used by the indicators flagged for
  --non-structural changes
  numMeasures := 0;
  strWhereInIndics := Get_New_Big_In_Cond_Number(9, 'I.INDICATOR');
  /*i:= 0;
  LOOP
    EXIT WHEN i=BSC_METADATA_OPTIMIZER_PKG.gnumIndics4;
    Add_Value_Big_In_Cond_Number( 9, BSC_METADATA_OPTIMIZER_PKG.garrIndics4(i));
    i:=i+1;
  END LOOP;*/

  Add_value_BULK(9, BSC_METADATA_OPTIMIZER_PKG.garrIndics4);
  l_stmt := 'SELECT DISTINCT M.MEASURE_COL, M.SOURCE, M.MEASURE_ID FROM BSC_SYS_MEASURES M, '||
            BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table||' I
            WHERE I.MEASURE_ID = M.MEASURE_ID AND ('|| strWhereInIndics ||' )
            AND M.TYPE = 0';
  OPEN cv FOR l_stmt;
  l_stack := l_stack ||' Going to execute l_stmt = '||l_stmt;
  l_stack := l_stack || newline||bsc_metadata_optimizer_pkg.gIndent;
  LOOP
    FETCH cv INTO l_measureCol, l_source, l_measureID;
    EXIT when cv%NOTFOUND;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Measure = '||l_measureCol, FND_LOG.LEVEL_PROCEDURE);
    END IF;
    arrMeasuresCols(numMeasures) := l_measureCol;
    arrMeasures_src(numMeasures) := l_source;
    numMeasures := numMeasures + 1;
    arrRelatedMeasuresIds(arrRelatedMeasuresIds.count) := l_measureID;
  END Loop;
  CLOSE cv;
  l_stack := l_stack ||' Check 1' ||newline||bsc_metadata_optimizer_pkg.gIndent;
  /*The measures in the array arrMeasuresCols are the ones that could be changed
    For that reason the indicators were flaged to 4
    We need to see in all system measures if there is a formula using that measure.
    IF that happen we need to add that measure. Any kpi using that meaure should be flaged too.*/
  strWhereNotInIndics := ' NOT ( ' || strWhereInIndics || ')';
  l_stmt := 'SELECT DISTINCT M.MEASURE_ID, M.MEASURE_COL FROM BSC_SYS_MEASURES M, '
            ||BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table||
             ' I WHERE I.MEASURE_ID = M.MEASURE_ID
  	       AND ('|| strWhereNotInIndics ||' )
            AND M.TYPE = 0 ';
  OPEN cv FOR l_stmt ;
  LOOP
    FETCH cv into l_measureID, l_measureCol;
    EXIT WHEN cv%NOTFOUND;
    NumOperands := GetFieldExpression(Operands, l_measureCol);
    i:= Operands.first;
    LOOP
      EXIT WHEN Operands.count =0 ;
      IF SearchStringExists(arrMeasuresCols, numMeasures, Operands(i)) THEN
        --One operand of the formula is one of the measures of a indicator flagged with 4
        --We need to add this formula (measure) to the related ones
        arrRelatedMeasuresIds(arrRelatedMeasuresIds.count) := l_measureID;
        EXIT;
      END IF;
      EXIT WHEN i = Operands.last;
      i:= Operands.next(i);
    END LOOP;
  END Loop;
  CLOSE cv;
  l_stack := l_stack ||' Check 3,  arrRelatedMeasuresIds.count =  '|| arrRelatedMeasuresIds.count;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp(' arrRelatedMeasuresIds.count = '||arrRelatedMeasuresIds.count);
  END IF;
  --Now we need to add to garrIndics4() all the indicators using any of the measures
  --in arrRelatedMeasuresIds()
  IF  arrRelatedMeasuresIds.count > 0 THEN
    strWhereInMeasures := Get_New_Big_In_Cond_Number( 9, 'MEASURE_ID');
    /*i:= arrRelatedMeasuresIds.first;
    LOOP
      EXIT WHEN arrRelatedMeasuresIds.count=0;
      Add_Value_Big_In_Cond_Number( 9, arrRelatedMeasuresIds(i));
      l_stack := l_stack || newline||' Added measure id '||arrRelatedMeasuresIds(i);
      EXIT WHEN i=arrRelatedMeasuresIds.last;
      i:= arrRelatedMeasuresIds.next(i);
      IF (length(l_stack) > 30000) THEN
         l_stack := substr(l_stack, 20000);
      END IF;
    END LOOP;*/
    Add_value_bulk(9, arrRelatedMeasuresIds);
    l_stmt := 'SELECT DISTINCT INDICATOR FROM BSC_DB_MEASURE_BY_DIM_SET_V WHERE ('|| strWhereInMeasures || ')';
    l_stack := l_stack ||' Check 4, l_stmt =  '||l_stmt ||newline;
    open cv for L_stmt;
    l_stack := l_stack ||newline ||'Opened cursor';
    LOOP
      FETCH cv into l_indicator;        /*Indicator*/
      l_stack := l_stack ||newline||' fetched';
      EXIT WHEN cv%NOTFOUND;
      -- PMD does not update the related indicators
      l_stack := l_stack ||newline||'going to update...';
      UPDATE BSC_KPIS_B
         SET PROTOTYPE_FLAG   = DECODE(PROTOTYPE_FLAG, 2, 2, 3, 3, 4),
             LAST_UPDATED_BY  = BSC_METADATA_OPTIMIZER_PKG.gUserId,
             LAST_UPDATE_DATE = SYSDATE
	   WHERE INDICATOR = l_indicator
             AND prototype_flag not in (2,3);
      IF (SQL%rowcount>0) THEN
        l_stack := l_stack ||'updated '||l_indicator||' to 4';
        bsc_mo_helper_pkg.writeTmp('Updating prototype_flag for '||l_indicator ||' to 4');
      END IF;
      IF (length(l_stack)>30000) THEN
        l_stack := substr(l_stack, 20000);
      END IF;
    END Loop;
    CLOSE cv;
    l_stack := l_stack ||' Check 5 ';
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp('Completed MarkIndicsForNonStrucChanges', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    writeTmp('Exception in MarkIndicsForNonStrucChanges : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
    writeTmp('Local Stack dump = '||l_stack, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
End;



--****************************************************************************
--  Inic: getInitColumn
--  DESCRIPTION:
--     Read the given variable from BSC_SYS_INIT
--
--  PARAMETERS:
--     Variable: variable name
--****************************************************************************

FUNCTION getInitColumn(p_column IN VARCHAR2) return VARCHAR2 IS
l_stmt varchar2(1000);
l_value varchar2(300);
cv   CurTyp;
l_error VARCHAR2(400);
BEGIN
	l_stmt := 'SELECT PROPERTY_VALUE FROM BSC_SYS_INIT WHERE UPPER(PROPERTY_CODE) = :1';
	open cv for l_stmt using p_column;
	FETCH cv into l_value;
	CLOSE cv;
	return l_value;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in getInitColumn : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
END;

--****************************************************************************
--  decomposeString
--  DESCRIPTION:
--     Break up a comma separated string (or some separated string)
--     into separate elements and return an array
--
--  PARAMETERS:
--     p_string: Comma or character separated string
--     p_separator: Separator
--     p_return_array: return array
--****************************************************************************

FUNCTION decomposeString(p_string IN VARCHAR2, p_separator IN VARCHAR2, p_return_array OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE)
return NUMBER IS

l_str VARCHAR2(32000);
--l_substr VARCHAR2(4000) := null;
position NUMBER := 0;
l_count  NUMBER := 0 ;
l_error VARCHAR2(400) := null;
l_LOOP_stack VARCHAR2(32000) := null;
l_value VARCHAR2(100);

BEGIN

  IF p_string IS NOT NULL  THEN
	   l_LOOP_stack := 'Check1';
     l_str := p_string;
     position := Instr(l_str, p_separator);
	   l_LOOP_stack := 'Check2, position = '||position;
	   IF (position = 0) THEN
        p_return_array(0) := p_string;
        return 1;
	   END IF;

      LOOP
        l_LOOP_stack := l_LOOP_stack||newline||'l_count= '||l_count;
        EXIT WHEN POSITION = 0 OR position is NULL or trim(l_str) is null;
        l_value :=  Trim(substr(l_str,1, position - 1));
        l_LOOP_stack := l_LOOP_stack||newline||'l_value= '||l_value;
        IF (l_value IS NOT NULL) THEN
          p_return_array(l_count) := l_value;
          l_count := l_count + 1;
        END IF;
        l_LOOP_stack := l_LOOP_stack||newline||'l_count= '||l_count;
        l_str := substr(l_str, position+1, length(l_str)- position);
        l_LOOP_stack := l_LOOP_stack||newline||'Check 3';
        position := InStr(l_str, p_separator);
        l_LOOP_stack := l_LOOP_stack||newline||'Check 4';

        IF (length(l_LOOP_stack) > 20000) THEN
          l_LOOP_stack := null;
        END IF;

      END LOOP;

      IF (trim(l_str) IS NOT NULL) THEN
        p_return_array(l_count) := Trim(l_str);
      END IF;
      l_LOOP_stack := l_LOOP_stack||newline||' Going to assign return array';
      l_LOOP_stack := l_LOOP_stack||newline||' Going to return '||l_count;
      return p_return_array.count;
  Else
	  return 0;
  END IF;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in decomposeString : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
  	  WriteTmp('Parameters were p_string ='||p_string||'and  p_separator = '||p_separator, FND_LOG.LEVEL_EXCEPTION, true);
	  writeTmp('Loop counter = '||l_count||' and Loop stack is '||l_LOOP_stack, FND_LOG.LEVEL_EXCEPTION, true);
      raise;

END;

--****************************************************************************
--  decomposeStringtoNumber
--  DESCRIPTION:
--     Break up a comma separated string (or some separated string)
--     into separate numbers and return an number array
--
--  PARAMETERS:
--     p_string: Comma or character separated string
--     p_separator: Separator
--     p_return_array: return array of numbers
--****************************************************************************


FUNCTION decomposeStringtoNumber(p_string IN VARCHAR2, p_separator IN VARCHAR2 )
return DBMS_SQL.NUMBER_TABLE IS

l_str VARCHAR2(32000);
l_substr VARCHAR2(32000);
position NUMBER;
l_count  NUMBER;
l_return_array DBMS_SQL.NUMBER_TABLE;
l_error VARCHAR2(400);
BEGIN

  IF p_string IS NOT NULL  THEN
      l_str := p_string;
      position := Instr(l_str, p_separator);
      l_count := 0;
  	LOOP
	      EXIT WHEN POSITION = 0;
        l_return_array(l_count) := to_number(Trim(substr(l_str,1, position - 1)));
        l_count := l_count + 1;
	      l_str := substr(l_str, position+1, length(l_str)- position);
        position := InStr(l_str, p_separator);
      END Loop;

      l_return_array(l_count) := to_number(Trim(l_str));
	  l_count := l_count + 1;
  END IF;
  return l_return_array;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in decomposeStringtoNumber : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
END;

--****************************************************************************
--  getDecomposedString
--  DESCRIPTION:
--     Break up a comma separated string (or some separated string)
--     into separate elements and return an array
--
--  PARAMETERS:
--     p_string: Comma or character separated string
--     p_separator: Separator
--   RETURNS
--     return array (this is a function as opposed to decomposeString)
--****************************************************************************


FUNCTION getDecomposedString(p_string IN VARCHAR2, p_separator IN VARCHAR2) RETURN
DBMS_SQL.VARCHAR2_TABLE IS
l_table DBMS_SQL.VARCHAR2_TABLE ;
l_dummy NUMBER;
BEGIN
  l_dummy := decomposeString(p_string, p_separator, l_table);
  return l_table;
END;

PROCEDURE insert_per(p_periodicity IN NUMBER, p_origin IN VARCHAR2) IS
l_origin_list DBMS_SQL.NUMBER_TABLE;
l_table_name VARCHAR2(100) := bsc_metadata_optimizer_pkg.g_period_circ_check ;
l_stmt VARCHAR2(1000) := 'INSERT INTO '||l_table_name||'(periodicity, source) values (:1, :2)';
l_index NUMBER;
BEGIN
  l_origin_list := decomposeStringtoNumber(p_origin, ',');
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'p_origin='||p_origin||', l_origin_list.count='||l_origin_list.count);
  if (l_origin_list.count>0) then
    forall i in l_origin_list.first..l_origin_list.last
      execute immediate l_stmt USING p_periodicity, l_origin_list(i);
  end if;
  exception when others then
    writeTmp('Exception in insert_per:'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
END;

PROCEDURE check_circular_dependency IS
l_table_name VARCHAR2(100) := bsc_metadata_optimizer_pkg.g_period_circ_check ;
l_stmt VARCHAR2(1000) := 'CREATE TABLE '||l_table_name||'(periodicity NUMBER, source NUMBER)';
--modified for bug 6052711
-- we should check for all existing periodicities in the system. Because in
-- Initialize_periodicities we initialize array for all the periodicities in the system
  CURSOR cPeriods IS
  SELECT distinct sysper.PERIODICITY_ID, sysper.SOURCE
  FROM BSC_SYS_PERIODICITIES sysper
  ORDER BY PERIODICITY_ID;
  cPeriodRow cPeriods%ROWTYPE;
  cv CurTyp;
  l_temp NUMBER;

BEGIN
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'Inside check_circular_dependency');
  dropTable(l_table_name);
  IF BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName is NULL THEN
    InitTablespaceNames;
  END IF;
  l_stmt := l_stmt ||' TABLESPACE '|| BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName||' '|| BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
  Do_DDL(l_stmt, ad_ddl.create_table, l_table_name);
  OPEN cPeriods;
  LOOP
      FETCH cPeriods INTO cPeriodRow;
      EXIT WHEN cPeriods%NOTFOUND;
      insert_per(cPeriodRow.periodicity_id, cPeriodRow.source);
  END LOOP;
  CLOSE cPeriods;
  commit;

  l_stmt := ' select periodicity from '||l_table_name||' connect by periodicity = prior source start with periodicity = :1';
  OPEN cPeriods;
  LOOP
      FETCH cPeriods INTO cPeriodRow;
      EXIT WHEN cPeriods%NOTFOUND;

      BEGIN
        OPEN cv FOR l_stmt USING cPeriodRow.PERIODICITY_ID;
        LOOP
          FETCH cv INTO l_temp;
          EXIT WHEN cv%NOTFOUND;
        END LOOP;
        CLOSE cv;
        EXCEPTION WHEN OTHERS THEN
        --IF (SQLCODE = -01436) THEN
          BSC_METADATA_OPTIMIZER_PKG.logprogress('ERROR', 'Ciruclar dependency for periodicity_id = '||cPeriodRow.PERIODICITY_ID);
          writeTmp('Ciruclar dependency for periodicity_id = '||cPeriodRow.PERIODICITY_ID, FND_LOG.LEVEL_EXCEPTION, true);
          terminateWithMsg('Ciruclar dependency for periodicity_id = '||cPeriodRow.PERIODICITY_ID);
        --END IF;
        raise;
      END ;
  END LOOP;
  CLOSE cPeriods;
  dropTable(l_table_name);
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'Completed check_circular_dependency');
  exception when others then
    writeTmp('Exception in check_circular_dependency:'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
END;


--****************************************************************************
--  InitializePeriodicities
--  DESCRIPTION:
--     Read periodicities table and initialize variable gPeriodicities.
--     Find parents for each periodicity too.
--
--  PARAMETERS:
--     None
--   RETURNS
--     None
--****************************************************************************

PROCEDURE InitializePeriodicities IS

  L_Periodicity BSC_METADATA_OPTIMIZER_PKG.clsPeriodicity;
  PerOri NUMBER;
  Origen VARCHAR2(1000);
  arrPerOri DBMS_SQL.VARCHAR2_TABLE;
  NumPerOri NUMBER;
  i NUMBER;
  l_stmt VARCHAR2(1000);

  allSourcesCompleted Boolean;
  arrPerSourceCompleted DBMS_SQL.NUMBER_TABLE;
  numPerSourceCompleted NUMBER;
  srcPerOri NUMBER;
  newPerOri NUMBER;

  -- adding a distinct to avoid infinite loop
  -- in case of issues with BIS -> BSC calendar synching...
  CURSOR cPeriods IS
  SELECT distinct sysper.PERIODICITY_ID, sysper.SOURCE, sysper.EDW_FLAG, sysper.YEARLY_FLAG,
  sysper.CALENDAR_ID, NVL(sysper.PERIODICITY_TYPE, 0) AS PERIODICITY_TYPE
  FROM BSC_SYS_PERIODICITIES_VL sysper
  ORDER BY PERIODICITY_ID;

  cPeriodRow cPeriods%ROWTYPE;

  l_index NUMBER;
  l_origin_list DBMS_SQL.VARCHAR2_TABLE;
  l_origin_index NUMBER;
  l_src_origin_index NUMBER;
  l_src_origin_list DBMS_SQL.VARCHAR2_TABLE;
  l_error VARCHAR2(400);
  l_time date := sysdate;
  l_seconds number := 0;
  l_prev_counter number := 0;

  l_too_long boolean := false;
BEGIN

  check_circular_dependency;
  OPEN cPeriods;
  LOOP
      FETCH cPeriods INTO cPeriodRow;
      EXIT WHEN cPeriods%NOTFOUND;
      L_Periodicity.Code := cPeriodRow.PERIODICITY_ID;
      L_Periodicity.EDW_Flag := cPeriodRow.EDW_FLAG;
      L_Periodicity.Yearly_Flag := cPeriodRow.YEARLY_FLAG;
      L_Periodicity.CalendarID := cPeriodRow.CALENDAR_ID;
      L_Periodicity.PeriodicityType := cPeriodRow.PERIODICITY_TYPE;
      L_Periodicity.periodicityOrigin := cPeriodRow.SOURCE ;
      BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.count) := L_Periodicity;
  END LOOP;
  CLOSE cPeriods;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('# Periodicities = '||BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.count);
      bsc_mo_helper_pkg.write_this(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities);
  END IF;


  --Completes the source of periodicities. For example
  --if periodicity A can be calculated from B and B can be calculated from C then
  --A also can be calculated from C

  numPerSourceCompleted := 0;
  WHILE (numPerSourceCompleted < BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.Count) LOOP
    l_seconds := (sysdate - l_time) *86400;
    l_index := BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.first;
    LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.count = 0;
      L_Periodicity := BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_index);
      If Not SearchNumberExists(arrPerSourceCompleted, numPerSourceCompleted, L_Periodicity.Code) Then
        --We have not completed the sources of this periodicity
        --Check that all the source periodicities are completed
        if (mod(l_seconds, 100)=0 ) then -- more than 100 secs
          if (l_seconds <> l_prev_counter) then
           writetmp('Spent '||l_seconds ||' seconds inside InitializePeriodicities, periodicity w/o source = '||L_Periodicity.Code);
           l_prev_counter := l_seconds;
           BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'Spent '||l_seconds ||' seconds inside InitializePeriodicities, periodicity w/o source = '||L_Periodicity.Code);
           l_too_long:=true;
         end if;
        end if;
        allSourcesCompleted := True;
        l_origin_list := getDecomposedString (L_Periodicity.PeriodicityOrigin, ',');
        l_origin_index := l_origin_list.first;
        LOOP
          EXIT WHEN l_origin_list.count= 0;
          PerOri := l_origin_list(l_origin_index);
          If Not searchNumberExists(arrPerSourceCompleted, numPerSourceCompleted, PerOri) Then
            --This periodicity is not complete
            allSourcesCompleted := False;
            if findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, PerOri)=-1 then
              terminateWithMsg('Periodicity id '||L_Periodicity.Code||' has invalid source periodicity='||PerOri);
              raise bsc_metadata_optimizer_pkg.optimizer_exception;
              return; -- Mark as error in CP status
            end if;
            if(l_too_long) then
              bsc_metadata_optimizer_pkg.logProgress('ERROR?', 'Periodicity id='||L_Periodicity.Code||', origin ='||PerOri||' not completed');
            end if;
            Exit;
          End If;
          EXIT WHEN l_origin_index = l_origin_list.last;
          l_origin_index := l_origin_list.next(l_origin_index);
        END LOOP;

        If allSourcesCompleted Then
          --Add all the source periodicities of the sources in the list
          --of source of this periodicity
          l_origin_index := l_origin_list.first;
          LOOP
            EXIT WHEN l_origin_list.count= 0;
            PerOri := l_origin_list(l_origin_index);
            l_src_origin_index := findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, PerOri);
            l_src_origin_list := getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_src_origin_index).periodicityOrigin, ',');
            l_src_origin_index := l_src_origin_list.first;

            LOOP
              EXIT WHEN l_src_origin_list.count = 0;
              srcPerOri := l_src_origin_list(l_src_origin_index);
              If instr(L_Periodicity.PeriodicityOrigin, to_char(srcPerOri)) = 0 Then
                --The source periodicity is not already in the list of sources
                newPerOri := srcPerOri;
                BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_index).periodicityOrigin :=
                BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_index).periodicityOrigin||','||newPerOri;
              End If;
              EXIT WHEN l_src_origin_index = l_src_origin_list.last;
              l_src_origin_index := l_src_origin_list.next(l_src_origin_index);
            END LOOP;

            EXIT WHEN l_origin_index = l_origin_list.last;
            l_origin_index := l_origin_list.next(l_origin_index);
          END LOOP;
          --Add this periodicity to the array arrPerSourceCompleted()
          arrPerSourceCompleted(numPerSourceCompleted) := L_Periodicity.Code;
          numPerSourceCompleted := numPerSourceCompleted + 1;
        End If; --allSourcesCompleted
      End If;
      EXIT WHEN l_index = BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.last;
      l_index := BSC_METADATA_OPTIMIZER_PKG.gPeriodicities.next(l_index);
    END LOOP;
  END LOOP;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in initializePeriodicities : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
END;

PROCEDURE InitializeCalendars IS

cursor cCal IS
SELECT
B.CALENDAR_ID,
B.EDW_FLAG,
B.NAME,
B.FISCAL_YEAR,
B.RANGE_YR_MOD,
NVL(B.EDW_CALENDAR_TYPE_ID, 0) SOURCE,
(
 NVL((SELECT MAX(NUM_OF_YEARS - PREVIOUS_YEARS)
 FROM BSC_KPI_PERIODICITIES
 WHERE NVL(NUM_OF_YEARS, 0) > 0 AND
     PERIODICITY_ID IN (SELECT PERIODICITY_ID
                  FROM BSC_SYS_PERIODICITIES S
                  WHERE S.CALENDAR_ID = B.CALENDAR_ID))
   , 1)
) AS MAX_FORYEAR,
(
 NVL((SELECT MAX(PREVIOUS_YEARS)
 FROM BSC_KPI_PERIODICITIES
 WHERE NVL(NUM_OF_YEARS, 0) > 0 AND
     PERIODICITY_ID IN (SELECT PERIODICITY_ID
                  FROM BSC_SYS_PERIODICITIES S
                  WHERE S.CALENDAR_ID = B.CALENDAR_ID))
   , 1)
) AS MAX_PREVIOUS,
--Added 05/18/2005 after conversation with Venu
--DBI calendar ids should be 1001, 1002 or 1003
EDW_CALENDAR_ID
FROM
BSC_SYS_CALENDARS_VL B;

cRow cCal%ROWTYPE;
l_count NUMBER := 0;
l_calendar BSC_METADATA_OPTIMIZER_PKG.clsCalendar;
l_error VARCHAR2(400);
BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp( 'Inside InitializeCalendars');--commit;
   END IF;

	open cCal;

	LOOP
	  FETCH cCal into cRow;
	  EXIT WHEN cCal%NOTFOUND;
      l_calendar := new_clsCalendar ;
	  l_calendar.Code := cRow.calendar_id;
	  l_calendar.EDW_Flag := cRow.edw_flag;
	  l_calendar.CurrFiscalYear := cRow.Fiscal_Year;
	  l_calendar.RangeYrMod := cRow.Range_Yr_Mod;
	  l_calendar.NumOfYears := cRow.Max_foryear + cRow.Max_previous;
	  l_calendar.previousYears := cRow.Max_Previous;
      --BIS DIMENSIONS: new property: source
      -- Changed 05/18/2005, added check for EDW_CALENDAR_ID to be in 1001, 1002 and 1003 for dBI calendars
      If cRow.SOURCE = 1 and cRow.EDW_CALENDAR_ID IN (1001,1002,1003) Then
        l_calendar.Source := 'PMF';
      Else
        l_calendar.Source := 'BSC';
      End If;
	  BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_count) := l_calendar;
	  l_count := l_count+1;
	END LOOP;
	CLOSE cCal;
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
     writeTmp( 'Completed InitializeCalendars');
   END IF;


  EXCEPTION WHEN OTHERS THEN
     l_error := sqlerrm;
      writeTmp('Exception in InitializeCalendars : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
     TerminateWithError ('BSC_CALENDAR_INIT_FAILED', 'InitializeCalendars');
     raise;
END;

-- Given a list of S tables, find the list of tables in the tree
-- starting from the S table going towards the I table. We need this to figure out which tables
-- can be dropped safely while running the optimizer for a list
-- of selected indicators

PROCEDURE InsertDirectTables(arrTables in out nocopy dbms_Sql.varchar2_table, p_variable_id IN NUMBER) IS
CURSOR cStoITables IS
select distinct source_table_name from bsc_db_tables_rels
connect by table_name = prior source_table_name
start with table_name in (
    SELECT VALUE_V FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = bsc_metadata_optimizer_pkg.g_session_id
    AND VARIABLE_ID = p_variable_id);
lTable VARCHAR2(100);
BEGIN
	OPEN cStoITables;
	LOOP
		FETCH cStoITables INTO lTable;
		EXIT WHEN cStoITables%NOTFOUND;
		arrTables(arrTables.count) := lTable;
	END LOOP;

END;

-- Given a list of production indicators, get the list of production tables they need
-- Start with BSC_KPI_DATA_TABLES to get the S table name and then move from S to I table

FUNCTION GetAffectedProductionTables(inIndicators in VARCHAR2) return dbms_Sql.varchar2_table IS

cv CurTyp;

l_stmt VARCHAR2(1000):= 'select distinct source_table_name from bsc_db_tables_rels
connect by table_name = prior source_table_name
start with table_name in (';

l_tables dbms_Sql.varchar2_table ;
l_table varchar2(100);
BEGIN
	l_stmt := l_stmt ||inIndicators ||' )';
	OPEN cv for l_stmt;
	LOOP
		FETCH cv INTO l_table;
		EXIT WHEN cv%NOTFOUND;
		l_tables(l_tables.count) := l_table;
	END LOOP;
END;

-- add to garrTables the list of tables that are used  ONLY by the specified indicators
-- if two indicators share a table, but only one of them

Procedure MarkTablesForSelectedKPIs IS

    l_stmt varchar2(1000);
    strWhereInIndics varchar2(1000);
    strWhereNotInIndics varchar2(1000);
    strWhereInTables varchar2(1000);
    i number := 0;
    lTable varchar2(100);
    cv CurTyp;
    lError VARCHAR2(400);
    arrayDirectTables dbms_sql.varchar2_table;
    strWhereInDirectTables varchar2(1000);
    strWhereInDirectIndics varchar2(1000);

    arrayAllAffectedTables dbms_sql.varchar2_table;
    l_varchar2_list dbms_sql.varchar2_table;

    l_dontProcessIndics VARCHAR2(1000);
    l_dontDropTables VARCHAR2(1000);
    l_DropTables VARCHAR2(1000);
    l_varchar2_table dbms_sql.varchar2_table;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Inside MarkTablesForSelectedKPIs', FND_LOG.LEVEL_PROCEDURE, false);
  END IF;

  --Initialize the array garrTables the tables used by the indicators in the array garrIndics()
  --EDW Integration note:
  --In BSC_KPI_DATA_TABLES, Metadata Optimizer is storing the name of the view (Example: BSC_3001_0_0_5_V)
  --and the name of the S table for BSC Kpis (Example: BSC_3002_0_0_5)
  --In this procedure we need to get tables names from a view BSC_KPI_DATA_TABLES_V.

  BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;
  BSC_METADATA_OPTIMIZER_PKG.garrTables.delete;

  IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics > 0 THEN
    strWhereInIndics := Get_New_Big_In_Cond_Number( 20, 'INDICATOR');
    strWhereNotInIndics := null;
    i:= 0;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp( 'gnumIndics is '||BSC_METADATA_OPTIMIZER_PKG.gnumIndics);
    END IF;
    Add_Value_Bulk(20, BSC_METADATA_OPTIMIZER_PKG.garrIndics);
    strWhereNotInIndics := 'NOT ('|| strWhereInIndics ||')';
    --Bug 5138449, dont use tmp table, use kpi_data_tables as we need all S tables, not just the lowest level S tables
    l_stmt := ' SELECT DISTINCT TABLE_NAME FROM BSC_KPI_DATA_TABLES WHERE ('||
       	 strWhereInIndics|| ') AND TABLE_NAME IS NOT NULL';
    writeTmp( 'l_stmt = '||l_stmt, FND_LOG.LEVEL_STATEMENT, false);
    OPEN cv for l_stmt;
    LOOP
      FETCH cv into lTable;
      EXIT WHEN cv%NOTFOUND;
      BSC_METADATA_OPTIMIZER_PKG.garrTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables) := lTable;
      BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.gnumTables + 1;
      --Add_Value_Big_In_Cond_VARCHAR2( 21, lTable);
      l_varchar2_list(l_varchar2_list.count+1) := lTable;
    END Loop;
    CLOSE cv;
    -- just in case garrTables is  already populated ahead
    Add_Value_Bulk(21, l_varchar2_list);
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'gnumTables is '||BSC_METADATA_OPTIMIZER_PKG.gnumTables);
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.gnumTables > 0 THEN
    -- we need to follow this algorithm to find which tables can be dropped :
    --0. Get List of Indicators to be processed
    --1. Find list of tables for 0. going from S to I tables
    --2. Find list of inter-related tables for 1.
    --3. Find list of indicators using any table from 2.
    --4. Affected inter-related indicators 3 - 0
    --5. For indicators in 4, get list of tables going from S to I tables
    --6. Subtract 1-5
    --7. Drop tables in 6

    --0. Get List of Indicators to be processed
    -- Step 0 is already taken care of in InitIndicators
    ---------------------------------------------------------------
    -- Step 1. Find list of tables for 0. going from S to I tables
    ---------------------------------------------------------------
    writeTmp( 'Calling InsertDirectTables', FND_LOG.LEVEL_STATEMENT, false);
    InsertDirectTables(BSC_METADATA_OPTIMIZER_PKG.garrTables, 21);
    writeTmp( 'Done with InsertDirectTables', FND_LOG.LEVEL_STATEMENT, false);
    strWhereInDirectTables := Get_New_Big_In_Cond_Varchar2( 22, 'TABLE_NAME');
    BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.garrTables.count;
    Add_Value_Bulk(22, BSC_METADATA_OPTIMIZER_PKG.garrTables);
    arrayDirectTables := BSC_METADATA_OPTIMIZER_PKG.garrTables;
    ---------------------------------------------------
    -- Step 2. Find list of inter-related tables for 1.
    ---------------------------------------------------
    writeTmp( 'Calling InsertRelatedTables', FND_LOG.LEVEL_STATEMENT, false);
    InsertRelatedTables( arrayDirectTables, BSC_METADATA_OPTIMIZER_PKG.gnumTables);
    writeTmp( 'Done InsertRelatedTables', FND_LOG.LEVEL_STATEMENT, false);
    --Mark the indicators affected by those tables
    strWhereInTables := Get_New_Big_In_Cond_Varchar2( 23, 'TABLE_NAME');
    i:= 0;
    writeTmp( 'strWhereInTables='||strWhereInTables, FND_LOG.LEVEL_STATEMENT, false);
    writeTmp( 'BSC_METADATA_OPTIMIZER_PKG.garrTables.count='||BSC_METADATA_OPTIMIZER_PKG.garrTables.count, FND_LOG.LEVEL_STATEMENT, false);
    l_varchar2_list.delete;
    LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.garrTables.count=0;
      IF searchStringExists(arrayDirectTables, arrayDirectTables.count, BSC_METADATA_OPTIMIZER_PKG.garrTables(i)) THEN
        null;
      ELSE
        l_varchar2_list(l_varchar2_list.count+1):= BSC_METADATA_OPTIMIZER_PKG.garrTables(i);
      END IF;
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.garrTables.last;
      i := BSC_METADATA_OPTIMIZER_PKG.garrTables.next(i);
    END LOOP;
    Add_Value_Bulk(23, l_varchar2_list);
    l_varchar2_list.delete;
    writeTmp( 'Done loop', FND_LOG.LEVEL_STATEMENT, false);
    writeTmp( 'strWhereInTables ='||strWhereInTables, FND_LOG.LEVEL_STATEMENT, false);
    writeTmp( 'strWhereNotInIndics ='||strWhereNotInIndics, FND_LOG.LEVEL_STATEMENT, false);
    ----------------------------------------------------------
    --Step 3. Find list of indicators using any table from 2.
    ----------------------------------------------------------
    l_dontProcessIndics  := 'SELECT DISTINCT INDICATOR FROM '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' WHERE ('||strWhereInTables|| ')';
    --------------------------------------------------
    --Step 4. Affected inter-related indicators 3 - 0
    --------------------------------------------------
    l_dontProcessIndics := l_dontProcessIndics||' AND ('||strWhereNotInIndics||')';
    writeTmp( 'l_dontProcessIndics ='||l_dontProcessIndics, FND_LOG.LEVEL_STATEMENT, false);
    -- for the indicators that are impacted but are not being processed, we need to preserve
    -- the tables. so get the list of tables used by these indicators
    ---------------------------------------------------------------------
    --Step 5. For indicators in 4, get list of tables going from S to I tables
    ---------------------------------------------------------------------
    l_dontDropTables := ' select source_table_name from bsc_db_tables_rels
                  connect by table_name = prior source_table_name start with table_name in
                 (select table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' where indicator in ('||l_dontProcessIndics||') )';
    writeTmp( 'l_dontDropTables ='||l_dontDropTables, FND_LOG.LEVEL_STATEMENT, false);
    ---------------------------------------------------
    --Step 6. Subtract 1-5
    ---------------------------------------------------
    l_dropTables := 'select table_name from bsc_db_tables where ('||strWhereInDirectTables||') '||' and table_name not in ('||
                      l_dontDropTables||')';
    writeTmp( 'l_dropTables ='||l_dropTables, FND_LOG.LEVEL_STATEMENT, false);
    BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;
    BSC_METADATA_OPTIMIZER_PKG.garrTables.delete;
    l_dropTables := replace(l_dropTables, 'UPPER(TABLE_NAME)', 'TABLE_NAME');
    l_dropTables := replace(l_dropTables, 'UPPER(VALUE_V)', 'VALUE_V');
    OPEN cv for l_dropTables;
    FETCH cv BULK COLLECT INTO l_varchar2_table;
    CLOSE cv;
    FOR k in 1..l_varchar2_table.count LOOP
      lTable := l_varchar2_table(k);
      BSC_METADATA_OPTIMIZER_PKG.garrTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables) := lTable;
      BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.gnumTables + 1;
      writeTmp( 'will drop ' || lTable, FND_LOG.LEVEL_STATEMENT, false);
    END Loop;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Completed MarkTablesForSelectedKPIs', FND_LOG.LEVEL_PROCEDURE, false);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    lError := sqlerrm;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Exception in MarkTablesForSelectedKPIs : '||lError);
    END IF;
    raise;
End;

/****************************************************************************
--  CheckAllIndicsHaveSystem
--
--  DESCRIPTION:
--     Check that all indicators in BSC_KPIS_B have been assigned to some Tab.
--     IF some indicator has not been assigned the GAA cannot continue.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--     Arun Santhanam
--***************************************************************************/
Procedure CheckAllIndicsHaveSystem IS
	l_stmt varchar2(4000);
	kpilist varchar2(32000);
	l_indicator varchar2(100);
 cv   CurTyp;
  l_error VARCHAR2(4000);

  CURSOR cIndics IS
  SELECT DISTINCT K.INDICATOR
  FROM BSC_KPIS_B K, BSC_TAB_INDICATORS T WHERE K.INDICATOR = T.INDICATOR (+)
  AND T.INDICATOR IS NULL AND K.PROTOTYPE_FLAG <> 2 ORDER BY K.INDICATOR;

BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  	      writeTmp( 'Inside CheckAllIndicsHaveSystem');   --commit;
   END IF;

  IF (getInitColumn('MODEL_TYPE') = 6) THEN
      --only if the system is a Tab panel
     kpilist := null;
     OPEN cIndics;
     LOOP
       FETCH cIndics INTO l_indicator;
       EXIT when cIndics%NOTFOUND;
       IF kpilist IS NULL THEN
         kpilist := l_indicator;
       Else
         kpilist := kpilist || ', '|| l_indicator;
       END IF;
     END Loop;
     CLOSE cIndics;
    IF kpilist IS NOT NULL THEN
      fnd_message.set_name('BSC','BSC_MISSING_KPI_TAB_ASSIG');
      l_indicator := fnd_message.get;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        writeTmp( 'Compl. CheckAllIndicsHaveSystem, error BSC_MISSING_KPI_TAB_ASSIG');
      END IF;
      FND_FILE.put_line(FND_FILE.LOG, l_indicator||':'||kpilist);
      terminateWithError('BSC_MISSING_KPI_TAB_ASSIG', 'CheckAllIndicsHaveSystem');
      terminateWithMsg(kpiList);
      raise bsc_metadata_optimizer_pkg.optimizer_exception;
      return; -- Mark as error in CP status
    END IF;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl. CheckAllIndicsHaveSystem');
  END IF;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      	writeTmp('Exception in CheckAllIndicsHaveSystem : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;

/****************************************************************************
--  CheckAllSharedIndicsSync : CheckAllSharedIndicsSynchronyzed
--
--  DESCRIPTION:
--     Check that all shared indicators in BSC_KPIS_B have been synchronized
--     IF some shared indicator has not been synchronized,GAA cannot continue.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--     Arun Santhanam
--***************************************************************************/
PROCEDURE CheckAllSharedIndicsSync IS
l_error varchar2(1000);
	kpilist varchar2(1000);
	l_indicator number;
	l_source_indicator number;

  CURSOR cSharedIndics IS
  SELECT DISTINCT INDICATOR, SOURCE_INDICATOR FROM BSC_KPIS_B
  WHERE SHARE_FLAG = 3 AND SOURCE_INDICATOR IS NOT NULL AND PROTOTYPE_FLAG <> 2 ;

BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Inside CheckAllSharedIndicsSync');   --commit;
  END IF;
  OPEN cSharedIndics;
  --Try to re-syncronized those indicators
  LOOP
    FETCH cSharedIndics INTO l_indicator, l_source_indicator;
    EXIT WHEN cSharedIndics%NOTFOUND;
    BSC_DESIGNER_PVT.Duplicate_KPI_Metadata(l_source_indicator, l_indicator, 0, NULL);
    CheckError('Duplicate_KPI_Metadata');
  END Loop;
  CLOSE cSharedIndics;
  --Check again to see which indicator are still not synchronized
  kpilist := null;
  OPEN cSharedIndics;
  LOOP
    FETCH cSharedIndics into l_indicator, l_source_indicator;
    EXIT WHEN cSharedIndics%NOTFOUND;
    IF kpilist IS NULL THEN
      kpilist := l_indicator;
    Else
      kpilist := kpilist ||','||l_indicator;
    END IF;
  END Loop;
  CLOSE cSharedIndics;
  IF kpilist IS NOT NULL THEN
    fnd_message.set_name('BSC','BSC_SHARED_NOT_SYNCR' );
    l_error := fnd_message.get || '('||kpilist||')';
    terminateWithMsg(l_error);
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl CheckAllSharedIndicsSync');   --commit;
  END IF;
End;

/****************************************************************************
--  CheckAllEDWIndicsFullyMapped
--  DESCRIPTION:
--     Check all EDW kpis have been fully mapped. Dimensions, Periodicities,
--     Datasets are from EDW
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************/
PROCEDURE CheckAllEDWIndicsFullyMapped IS

 kpilist varchar2(1000);
 l_indicator number;
cv   CurTyp;
l_error varchar2(1000);

  CURSOR cEDWIndics IS
  SELECT DISTINCT K.INDICATOR
  FROM BSC_KPIS_B K
  WHERE EDW_FLAG = 1
		AND EXISTS ( SELECT P.PROPERTY_CODE FROM BSC_KPI_PROPERTIES P
		WHERE P.INDICATOR = K.INDICATOR AND P.PROPERTY_VALUE = 0
		AND P.PROPERTY_CODE IN ('EDW_DATASET_STATUS', 'EDW_CALENDAR_STATUS', 'EDW_DIMENSION_STATUS'));

BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Inside CheckAllEDWIndicsFullyMapped');--commit;
  END IF;
  --There are 3 flags in BSC_KPI_PROPERTIES to check when a EDW Kpi
  --is fully mapped

  kpilist := null;
  OPEN cEDWIndics;
  LOOP
    FETCH cEDWIndics INTO  l_indicator;
    EXIT WHEN cEDWIndics%NOTFOUND;
    IF kpilist IS NULL THEN
      kpilist := to_char(l_indicator);
    Else
      kpilist := kpilist || ', ' ||to_char(l_indicator);
    END IF;
  END LOOP;
  CLOSE cEDWIndics;
  IF kpilist IS NOT NULL THEN
    terminateWithError('BSC_EDW_KPIS_NOT_FULL_MAP', 'CheckAllEDWIndicsFullyMapped');
    --Get_Message('BSC_EDW_KPIS_NOT_FULL_MAP')  ' (' kpilist ')')
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl CheckAllEDWIndicsFullyMapped');--commit;
  END IF;
End;

Procedure InitIndicators IS
  l_stmt varchar2(1000);
  l_Code number;
  l_Name BSC_KPIS_VL.NAME%TYPE;
  l_IndicatorType number;
  l_ConfigType number;
  l_per_inter number;
  l_OptimizationMode number;
  l_Action_Flag number;
  l_Share_Flag number;
  l_Source_Indicator number;
  l_EDW_Flag number;
  strWhereInIndics Varchar2(1000);
  strWhereNotInIndics Varchar2(1000);
  strWhereInIndics4 Varchar2(1000);
  strWhereNotInIndics4 Varchar2(1000);
  i number;
  cv   CurTyp;
  l_indicator number;
  l_indicator4 number;

  l_table VARCHAR2(100);
  l_error VARCHAR2(400);

  CURSOR cTables IS
  SELECT TABLE_NAME FROM BSC_DB_TABLES WHERE TABLE_TYPE <> 2;
  CURSOR cIndics4 IS
  SELECT INDICATOR FROM BSC_KPIS_B WHERE PROTOTYPE_FLAG = 4 ORDER BY INDICATOR;

  l_original_count number := 0;
  l_impl_type NUMBER := 1;

  l_total_count NUMBER := 0;
  l_objectives_count NUMBER:=0;
  l_counter number;
  l_aw_kpi_list dbms_sql.varchar2_table;

BEGIN


  writeTmp( 'Inside InitIndicators, system time is '||get_time, FND_LOG.LEVEL_PROCEDURE, true);

  BSC_METADATA_OPTIMIZER_PKG.garrIndics.delete;
  BSC_METADATA_OPTIMIZER_PKG.gnumIndics := 0;

  BSC_METADATA_OPTIMIZER_PKG.garrIndics4.delete;
  BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 := 0;

  BSC_METADATA_OPTIMIZER_PKG.garrTables.delete;
  BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;


  --If we are running optimizer for the first time, the prototype_flag will be 1, so treat it as 3.
  IF BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 1  THEN
    UPDATE bsc_kpis_b
	   SET prototype_flag = 3
	 WHERE prototype_flag=1;
  END IF;

  l_stmt := 'SELECT DISTINCT INDICATOR, NAME, PROTOTYPE_FLAG,
      INDICATOR_TYPE, CONFIG_TYPE, PERIODICITY_ID,
      SHARE_FLAG, SOURCE_INDICATOR,
      EDW_FLAG FROM BSC_KPIS_VL ';

  IF BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE = 0 THEN
    l_stmt := l_stmt || ' where short_name is null OR
	 (short_name is not null and BSC_DBGEN_UTILS.Get_Objective_Type(short_name) = ''OBJECTIVE'')';
	 -- NOTE NOTE NOTE
	 -- Change MODE to modified as ALL doesnt make sense anymore
	 -- as ALL should now exclude KPIs created using report designer
     DELETE FROM BSC_TMP_OPT_UI_KPIS WHERE process_id = BSC_METADATA_OPTIMIZER_PKG.g_processID;
	 INSERT INTO BSC_TMP_OPT_UI_KPIS (INDICATOR, PROTOTYPE_FLAG, PROCESS_ID)
	 SELECT INDICATOR, PROTOTYPE_FLAG, BSC_METADATA_OPTIMIZER_PKG.g_processID
	 FROM BSC_KPIS_VL
	 where short_name is null OR
	 (short_name is not null and BSC_DBGEN_UTILS.Get_Objective_Type(short_name) = 'OBJECTIVE');
	 l_objectives_count := SQL%ROWCOUNT;
	 commit;
	 SELECT COUNT(1) INTO l_total_count FROM BSC_KPIS_VL;
	 IF (l_objectives_count <> l_total_count) THEN -- there are autogenerated reports, dont process them
	   BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE := 1;
	 ELSE
	   writeTmp('Entire system consists of objectives, no autogenerated reports found', FND_LOG.LEVEL_PROCEDURE, true);
	 END IF;
  ELSE-- Modified or Selected indicators
    l_stmt := l_stmt || ' where prototype_flag in (2,3) and indicator in (SELECT INDICATOR FROM BSC_TMP_OPT_UI_KPIS WHERE process_id = '||BSC_METADATA_OPTIMIZER_PKG.g_processID||')';
  END IF;
  l_Stmt := l_stmt || ' ORDER BY INDICATOR ';
  writeTmp(l_Stmt, FND_LOG.LEVEL_STATEMENT, false);
  open cv for l_stmt;
  LOOP
    FETCH cv into l_code, l_name, l_action_flag,
    l_IndicatorType, l_configType, l_per_inter, l_share_flag,
    l_source_indicator, l_edw_flag;
    EXIT WHEN cv%NOTFOUND;
    IF (l_SOURCE_INDICATOR is null) THEN
      l_Source_Indicator := 0;
    END IF;
    l_optimizationMode := getKPIPropertyValue(l_Code, 'DB_TRANSFORM', 1);
    If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
      l_impl_type := getKPIPropertyValue(l_Code, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1);
    END IF;
	IF l_Action_Flag <> 2 THEN
      l_Action_Flag := 3;
      BSC_METADATA_OPTIMIZER_PKG.gThereisStructureChange := True;
    END IF;
    AddIndicator( BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_Code, l_name, l_indicatorType, l_ConfigType,
			l_per_inter, l_OptimizationMode, l_action_flag, l_share_flag, l_source_indicator, l_edw_flag, l_impl_type);
    BSC_METADATA_OPTIMIZER_PKG.garrIndics(BSC_METADATA_OPTIMIZER_PKG.gnumIndics) := l_code;
    BSC_METADATA_OPTIMIZER_PKG.gnumIndics := BSC_METADATA_OPTIMIZER_PKG.gnumIndics + 1;
  END Loop;
  CLOSE cv;

  --With the array garrIndics() initialized, the following function initialize
  --the array arrTables() with all tables related to the tables used directly by the indicators
  --in the array garrIndics(). Additionally, add in the array garrIndics() the related indicators.
  --BSC-MV Note: Performance fix: if metadata is running for all indicators we do not need
  --that complex logic to figure out all the affected tables
  IF BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE = 0 THEN
    --Metadata is running for the whole system
    BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;
    OPEN cTables;
    LOOP
      FETCH cTables INTO l_table;
      EXIT WHEN cTables%NOTFOUND;
      BSC_METADATA_OPTIMIZER_PKG.garrTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables) := l_table;
      BSC_METADATA_OPTIMIZER_PKG.gnumTables := BSC_METADATA_OPTIMIZER_PKG.gnumTables + 1;
    END LOOP;
    CLOSE cTables;
  ELSE -- incremental mode or selected mode

    MarkTablesForSelectedKPIs;
    writeTmp(' # of indicators now = '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count, fnd_log.level_statement, false);
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'Getting Indics with non structural changes ');
	--Add indicators with flag = 4 (reconfigure update)
    --in the collection gIndicadores
    --Of course if the indicator is already in gIndicadores (Structural changes) we do not change it.
    --Init an array with the Kpis in prototype 4 (changes in loader configuration)
    l_stmt := 'SELECT DISTINCT INDICATOR, NAME, PROTOTYPE_FLAG,
      INDICATOR_TYPE, CONFIG_TYPE, PERIODICITY_ID,
      SHARE_FLAG, SOURCE_INDICATOR,
      EDW_FLAG FROM BSC_KPIS_VL WHERE INDICATOR in
	  (select indicator from bsc_tmp_opt_ui_kpis where prototype_flag =4 and process_id= :1) ORDER BY INDICATOR';
    open cv for l_stmt using BSC_METADATA_OPTIMIZER_PKG.g_processID;
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'Indics with non structural changes are');
    LOOP
      FETCH cv into l_code, l_name, l_action_flag,
      l_IndicatorType, l_configType, l_per_inter, l_share_flag,
      l_source_indicator, l_edw_flag;
      exit when cv%NOTFOUND;
      BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', l_code);
      l_indicator4 := l_code;
      BSC_METADATA_OPTIMIZER_PKG.garrIndics4(BSC_METADATA_OPTIMIZER_PKG.gnumIndics4) := l_indicator4;
      BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 := BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 + 1;
      IF (l_SOURCE_INDICATOR is null) THEN
          l_Source_Indicator := 0;
      END IF;
      IF l_Action_Flag <> 2 THEN
          l_Action_Flag := 4;
      END IF;
      l_OptimizationMode := getKPIPropertyValue(l_Code, 'DB_TRANSFORM', 1);
      l_impl_type := getKPIPropertyValue(l_Code, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1);
      AddIndicator( BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_Code, l_name, l_indicatorType, l_ConfigType,
			l_per_inter, l_OptimizationMode, l_action_flag, l_share_flag, l_source_indicator, l_edw_flag, l_impl_type);
    END Loop;
    CLOSE cv;
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', '# of Indics now 2 '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count||', BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 ='||BSC_METADATA_OPTIMIZER_PKG.gnumIndics4);
    writeTmp(' # of indicators now 2= '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count||
               ', BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 ='||BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 , fnd_log.level_statement, false);
    strWhereInIndics := Get_New_Big_In_Cond_Number( 1, 'INDICATOR');
    strWhereNotInIndics := null;
    IF (BSC_METADATA_OPTIMIZER_PKG.garrIndics.count>0) THEN
      /*FOR i IN BSC_METADATA_OPTIMIZER_PKG.garrIndics.first..BSC_METADATA_OPTIMIZER_PKG.garrIndics.last LOOP
        Add_Value_Big_In_Cond_Number( 1, BSC_METADATA_OPTIMIZER_PKG.garrIndics(i));
      END LOOP;*/
      Add_value_bulk(1, BSC_METADATA_OPTIMIZER_PKG.garrIndics);
    END IF;
    strWhereNotInIndics := 'NOT ('|| strWhereInIndics ||')';

    --We need to update the related indicators' prototype_flag as 4 in bsc_kpis_b .
    -- Designer is only flagging the indicators
    --that are using the measure direclty. We need to flag other indicators
    --using the same measures alone or as part of a formula.
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', 'Mark indics for non struc changes');
    IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 > 0 THEN
      MarkIndicsForNonStrucChanges;
      --Add the indicators from garrIndics4() to gIndicadores
      strWhereInIndics4 := Get_New_Big_In_Cond_Number( 2, 'INDICATOR');
      /*i:= 0;
      LOOP
        exit when i = BSC_METADATA_OPTIMIZER_PKG.gnumIndics4;
        Add_Value_Big_In_Cond_Number( 2, BSC_METADATA_OPTIMIZER_PKG.garrIndics4(i));
        i:= i+1;
      END LOOP;*/
      Add_Value_Bulk(2, BSC_METADATA_OPTIMIZER_PKG.garrIndics4);
      strWhereNotInIndics4 := 'NOT (' || strWhereInIndics4 || ')';
    END IF; -- numIndics4 >0

    --BSC-MV Note: IF the summarization level was changed, we need to add all indicators
    --in production (all indicators not for structural changes or for non-structural changes)
    --to the collection of indicators
    IF BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0 THEN
      --There is change of summarization level
      l_stmt := 'SELECT DISTINCT INDICATOR, NAME, PROTOTYPE_FLAG, INDICATOR_TYPE,
                  CONFIG_TYPE, PERIODICITY_ID, SHARE_FLAG, SOURCE_INDICATOR,
                  EDW_FLAG FROM BSC_KPIS_VL ';
      -- added for selected indicators
      l_stmt := l_stmt ||' WHERE INDICATOR IN (SELECT INDICATOR FROM BSC_TMP_OPT_UI_KPIS WHERE process_id=:1) ';
      IF (BSC_METADATA_OPTIMIZER_PKG.gnumIndics > 0) And (BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 > 0) THEN
        l_stmt := l_stmt ||' AND (' || strWhereNotInIndics || ')  AND ('|| strWhereNotInIndics4 || ')';
      ELSIF (BSC_METADATA_OPTIMIZER_PKG.gnumIndics > 0) THEN
        l_stmt := l_stmt ||' AND (' || strWhereNotInIndics || ')';
      ELSIF (BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 > 0) THEN
        l_stmt := l_stmt ||' AND (' || strWhereNotInIndics4 || ')';
      End IF;
      l_stmt := l_stmt ||' ORDER BY INDICATOR';
      writeTmp(' Finding indicators for MV level change : '||l_stmt, fnd_log.level_statement, false);
      OPEN cv FOR l_stmt using BSC_METADATA_OPTIMIZER_PKG.g_processID;
      LOOP
        FETCH cv INTO l_code, l_name, l_action_flag, l_indicatorType,
                      l_configType, l_per_inter, l_share_flag, l_source_indicator, l_edw_flag;
        EXIT WHEN cv%NOTFOUND;
        l_OptimizationMode := getKPIPropertyValue(l_Code, 'DB_TRANSFORM', 1);
        l_impl_type := getKPIPropertyValue(l_Code, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1);
        IF l_Action_Flag <> 2 THEN
          l_Action_Flag := 0;
        End IF;
        AddIndicator( BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_Code, l_Name, l_IndicatorType, l_ConfigType,
    				l_Per_Inter, l_OptimizationMode, l_Action_Flag, l_Share_Flag, l_Source_Indicator, l_EDW_Flag, l_impl_type);
      END LOOP;
      CLOSE CV;
    END IF;
  END IF; -- mode <>0
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INIT', ' # of indicators to process = '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count);
  writeTmp(' # of indicators to process = '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count,FND_LOG.LEVEL_STATEMENT, true);

  -- populate the variables in bsc_dbgen_metadata_reader as it needs to consider the
  -- objectives in the current run as also production
  writeTmp('Checking if AW objectives exists and marking them');
  l_counter := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
  loop
    exit when BSC_METADATA_OPTIMIZER_PKG.gIndicators.count=0;
    if (BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_counter).impl_type =2 AND
        BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_counter).action_flag<>2) then -- aw
      l_aw_kpi_list(l_aw_kpi_list.count+1):= to_char(BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_counter).code);
    end if;
    EXIT WHEN l_counter=BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
    l_counter := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(l_counter);
  end loop;

  if (l_aw_kpi_list.count>0) then
    bsc_dbgen_metadata_reader.mark_facts_in_process(l_aw_kpi_list);
  end if;

  writeTmp( 'Completed InitIndicators, system time is '||get_time, FND_LOG.LEVEL_STATEMENT, true);
  write_this(BSC_METADATA_OPTIMIZER_PKG.gIndicators, FND_LOG.LEVEL_STATEMENT, false);

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in InitIndicators : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;



/****************************************************************************
  DBObjectExists
  DESCRIPTION:
     Returns TRUE if the given database object exists. Otherwise,
     returns FALSE.

  PARAMETERS:
     ObjectName: Object Name
     db_obj: database

  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
****************************************************************************/
Function DBObjectExists(ObjectName IN VARCHAR2)return boolean IS
  l_count NUMBER;
  l_stmt varchar2(1000);

  CURSOR cObject IS
  SELECT count(1) FROM USER_OBJECTS
  WHERE OBJECT_NAME = upper(ObjectName);
BEGIN
  l_count := 0;
  --The object name is searched in USER_OBJECTS. It works for APPS or Personal
  --mode. IF the object is in BSC schema in APPS schema should exist a SYNONYM.

  open cObject;
  FETCH cObject into l_count;
  CLOSE cObject;

  IF (l_count =0) THEN
      return false;
  END IF;
  return true;
End;

/****************************************************************************
  TableExists

  DESCRIPTION:
     Returns TRUE if the given table exists in the database.
  PARAMETERS:
     Tabla: table name
     db_obj: database
  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
****************************************************************************/
Function TableExists(Table_Name IN VARCHAR2) return Boolean IS

l_count NUMBER;
cv   CurTyp;

CURSOR cTables(pTableName IN VARCHAR2, pOwner IN VARCHAR2) IS
SELECT 1 FROM ALL_TABLES
WHERE TABLE_NAME = pTableName
AND OWNER = pOwner;

BEGIN
	l_count := 0;

  IF (BSC_METADATA_OPTIMIZER_PKG.gBscSchema IS NULL) THEN
      BSC_METADATA_OPTIMIZER_PKG.gBscSchema := getBSCSchema ;
  END IF;

	open cTables(table_name, BSC_METADATA_OPTIMIZER_PKG.gBscSchema);
	FETCH cTables into l_count;
	IF (cTables%NOTFOUND) THEN
      CLOSE cTables;
		return false;
	ELSE
      CLOSE cTables;
		return true;
	END IF;

End;


/****************************************************************************
  CreateCopyTable
--
--  DESCRIPTION:
--     Create a copy of the given table. It copies the data too.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
****************************************************************************/

PROCEDURE CreateCopyTable(TableName IN VARCHAR2, CopyTableName IN VARCHAR2, TbsName IN VARCHAR2, p_where_clause IN VARCHAR2 default null) IS
  l_stmt VARCHAR2(32000) := null;
  l_val NUMBER;
  cv CurTyp;
BEGIN
  IF (BSC_METADATA_OPTIMIZER_PKG.gStorageClause IS NULL) THEN
      BSC_METADATA_OPTIMIZER_PKG.gStorageClause := getStorageClause;
  END IF;
  l_stmt := 'create table ' ||CopyTableName ||' TABLESPACE ';
  IF (TbsName IS NULL) THEN
      l_stmt := l_stmt ||BSC_APPS.get_tablespace_name(BSC_APPS.other_table_tbs_type);
  ELSE
      l_stmt := l_stmt ||TbsName;
  END IF;
  l_stmt := l_stmt||' AS SELECT * FROM '||TableName||' '||p_where_clause;
  Do_DDL(l_stmt, ad_ddl.create_table, CopyTableName);
  l_stmt := 'select count(1) from '||CopyTableName;
  OPEN cv FOR l_stmt;
  FETCH cv INTO l_Val;
  CLOSE cv;
  writeTmp(l_stmt);
  writeTmp('# of rows inserted into '||CopyTableName||':'||l_val, FND_LOG.LEVEL_STATEMENT, false);
  exception when others then
    bsc_metadata_optimizer_pkg.logprogress('INIT', 'Error while creating '||CopyTableName);
    writeTmp('Exception in CreateCopyTable : '||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    writeTmp('Statement executed was : '||l_stmt, FND_LOG.LEVEL_EXCEPTION, true);
    raise;

End;

--****************************************************************************
--  CreateCopyIndexes
--
--  DESCRIPTION:
--     Create same indexes on TableName for CopyTableName
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE CreateCopyIndexes(TableName IN VARCHAR2, CopyTableName IN VARCHAR2, TbsName IN VARCHAR2) IS

  LstColumns VARCHAR2(1000);
  IndexName  VARCHAR2(100);
  isUnique VARCHAR2(100);
  newIndexName VARCHAR2(100);

  CURSOR cIndex(pOwner IN VARCHAR2) IS
  SELECT index_name, uniqueness
  FROM all_indexes
  WHERE table_name = TableName
  AND owner = pOwner;

  CURSOR cIndexCols(pIndex IN VARCHAR2, pOwner IN VARCHAR2) IS
  SELECT column_name
  FROM all_ind_columns
  WHERE index_name = pIndex
  AND table_owner = pOwner
  AND column_name not like 'SYS%$'
  ORDER BY column_position;

  l_column_name VARCHAR2(100);
  uIndex NUMBER := 1;
  nIndex NUMBER := 1;

  l_stmt VARCHAR2(1000);
  l_tmp_index number;
  l_len_ses  number;
  l_tmp_ses  varchar2(30);
BEGIN
  uIndex := 1;
  nIndex := 1;

  IF (BSC_METADATA_OPTIMIZER_PKG.gBscSchema IS NULL) THEN
      BSC_METADATA_OPTIMIZER_PKG.gBscSchema := BSC_MO_HELPER_PKG.getBSCSchema;
  END IF;

  IF (BSC_METADATA_OPTIMIZER_PKG.gStorageClause IS NULL) THEN
      BSC_METADATA_OPTIMIZER_PKG.gStorageClause := getStorageClause;
  END IF;

  OPEN cIndex (BSC_METADATA_OPTIMIZER_PKG.gBscSchema);

  LOOP
      FETCH cIndex INTO IndexName, isUnique;
      EXIT WHEN cIndex%NOTFOUND;
      LstColumns := null;

      OPEN cIndexCols(IndexName, BSC_METADATA_OPTIMIZER_PKG.gBscSchema);

      LOOP
        FETCH cIndexCols INTO l_column_name;
        EXIT WHEN cIndexCols%NOTFOUND;

        If LstColumns IS NOT NULL Then
          LstColumns := LstColumns ||', ';
        End If;
        LstColumns := LstColumns || l_column_name;
      END LOOP;
      CLOSE cIndexCols;

      --bug fix 5416808 amitgupt, index name len should not exceed 30 chars
      -- assuming that table will not have MORE THAN 99 INDEXES
      if(length(CopyTableName)>26) then
        l_tmp_index := INSTR(CopyTableName,'_',-1,1);
        l_tmp_ses   := to_char(BSC_METADATA_OPTIMIZER_PKG.g_session_id);
        l_len_ses   := length(l_tmp_ses);
        newIndexName :=
          substr(CopyTableName,1,l_tmp_index)||substr(l_tmp_ses,l_len_ses-(25-l_tmp_index));
      else
        newIndexName := CopyTableName;
      end if;

      If LstColumns IS NOT NULL Then
        If isUnique = 'UNIQUE' Then
          newIndexName :=  newIndexName || '_U' || uIndex;
          uIndex := uIndex + 1;
          l_stmt := 'CREATE UNIQUE INDEX '|| newIndexName;
        Else
          newIndexName := newIndexName || '_N' || nIndex;
          nIndex := nIndex + 1;
          l_stmt := 'CREATE INDEX ' || newIndexName;
        End If;
        l_stmt := l_stmt||' ON ' || CopyTableName || ' (' || LstColumns || ')';
        IF (TbsName IS NULL) THEN
          l_stmt := l_stmt||' TABLESPACE '||  BSC_APPS.get_tablespace_name(BSC_APPS.other_table_tbs_type);
        ELSE
          l_stmt := l_stmt||' TABLESPACE '||  TbsName;
        END IF;
        l_stmt := l_stmt|| ' ' || BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
        Do_DDL(l_stmt, ad_ddl.create_index, newIndexName);
      End If;

  END LOOP;
  Close cIndex;
  exception when others then
    bsc_metadata_optimizer_pkg.logprogress('INIT', 'Error while creating index'||IndexName);
    writeTmp('Exception in CreateCopyIndexes : '||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    writeTmp('Statement executed was : '||l_stmt, FND_LOG.LEVEL_EXCEPTION, true);
    raise;

End ;


/****************************************************************************
  CreateBackupBaseTables

  DESCRIPTION:
     Create backup tables of all base tables

  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
****************************************************************************/
/*Procedure CreateBackupBaseTables IS

  i  NUMBER;
  l_stmt VARCHAR2(1000);
  BaseTable VARCHAR2(1000);
  cv   CurTyp;

  CURSOR cBaseTables IS
  SELECT R.TABLE_NAME
	FROM BSC_DB_TABLES_RELS R, BSC_DB_TABLES T
	WHERE R.SOURCE_TABLE_NAME = T.TABLE_NAME
	AND T.TABLE_TYPE = 0;

BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
       writeTmp( 'Inside CreateBackupBaseTables');
   END IF;


  open cBaseTables;
  LOOP
    FETCH cBaseTables INTO BaseTable;
    EXIT when cBaseTables%NOTFOUND;
    IF TableExists(BaseTable) THEN
      DropTable( BaseTable|| '_BAK');
      bsc_metadata_optimizer_pkg.logprogress('INIT', 'Backing up '||BaseTable);
      CreateCopyTable(BaseTable, BaseTable|| '_BAK', BSC_METADATA_OPTIMIZER_PKG.gBaseTableTbsName);
    END IF;
  END LOOP;
  CLOSE cBaseTables;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl CreateBackupBaseTables');
  END IF;
End;
*/
Procedure backup_b_table(p_table IN VARCHAR2)
IS

  i  NUMBER;
  l_stmt VARCHAR2(1000);
  cv   CurTyp;
  l_backup_name varchar2(100);
  l_index_name varchar2(30);
  CURSOR cv_index IS
     SELECT index_name FROM ALL_INDEXES WHERE
     table_name = UPPER(p_table) AND table_owner = bsc_metadata_optimizer_pkg.gBscSchema;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Inside backup_b_table : '||p_table);
  END IF;
  l_backup_name := p_table||'_BAK';
  IF TableExists(p_table) THEN
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE '||bsc_metadata_optimizer_pkg.gBscSchema||'.'||l_backup_name||' CASCADE CONSTRAINTS';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
     EXECUTE IMMEDIATE 'DROP SYNONYM '||l_backup_name;
    EXCEPTION
      WHEN OTHERS THEN
         NULL;
    END;
    bsc_metadata_optimizer_pkg.logprogress('INIT', 'Backing up '||p_table);
    --CreateCopyTable(p_table, p_table|| '_BAK', BSC_METADATA_OPTIMIZER_PKG.gBaseTableTbsName);
    begin
    --dropping indexes first
    --bug fix 5647971
    FOR rec IN cv_index LOOP
       IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
           writeTmp( 'Dropping index '||rec.index_name);
       END IF;
       EXECUTE IMMEDIATE 'DROP INDEX '||bsc_metadata_optimizer_pkg.gBscSchema||'.'||rec.index_name;
    END LOOP;
    execute immediate 'alter table '||bsc_metadata_optimizer_pkg.gBscSchema||'.'||p_table||' rename to '||l_backup_name;
    execute immediate 'drop synonym '||p_table;
    execute immediate 'create synonym '||l_backup_name||' for '||bsc_metadata_optimizer_pkg.gBscSchema||'.'||l_backup_name;
    exception when others then
      if sqlcode=-26563 then -- rneame not allowed, dunno why
        CreateCopyTable(p_table, p_table|| '_BAK', BSC_METADATA_OPTIMIZER_PKG.gBaseTableTbsName);
      else
        raise;
      end if;
    end;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl backup_b_table : '||p_table);
  END IF;
End;

/****************************************************************************
  CreateLastTables

  DESCRIPTION:
     Creates the tables BSC_DB_TABLES_LAST, BSC_DB_TABLES_RELS_LAST,
     BSC_KPI_DATA_TABLES_LAST

  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
***************************************************************************/
PROCEDURE CreateLastTables IS
  TableName varchar2(30);
  l_stmt varchar2(1000);
  l_where_clause varchar2(1000);
  l_threshold number := 100;
  i number;
  strWhereInTables VARCHAR2(1000);
BEGIN
  l_where_clause := null;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Inside CreateLastTables, time is '||get_time);
  END IF;
  IF (BSC_METADATA_OPTIMIZER_PKG.gBscSchema IS NULL) THEN
      BSC_METADATA_OPTIMIZER_PKG.gBscSchema := getBSCSchema ;
  END IF;

  TableName := 'BSC_DB_TABLES';

  IF BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE <>0 AND  BSC_METADATA_OPTIMIZER_PKG.gIndicators.count < l_threshold THEN
    l_where_clause := ' WHERE table_name in (
	  SELECT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS
	  CONNECT BY TABLE_NAME=prior SOURCE_TABLE_NAME
	  start with table_name in
	    (select distinct table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' where indicator in
	         (select indicator from bsc_tmp_opt_ui_kpis where process_id='||BSC_METADATA_OPTIMIZER_PKG.g_processID||')
	     )
	  UNION
	  SELECT TABLE_NAME FROM BSC_DB_TABLES_RELS
	  CONNECT BY TABLE_NAME=prior SOURCE_TABLE_NAME
	  start with table_name in
	    (select distinct table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' where indicator in
	         (select indicator from bsc_tmp_opt_ui_kpis where process_id='||BSC_METADATA_OPTIMIZER_PKG.g_processID||')
	     )
      )';
  END IF;
  CreateCopyTable(TableName, BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName, l_where_clause);
  CreateCopyIndexes (TableName, BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName);
  dbms_stats.gather_table_stats(BSC_METADATA_OPTIMIZER_PKG.gBscSchema, BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last);
  TableName := 'BSC_DB_TABLES_RELS';
  CreateCopyTable(TableName, BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName, l_where_clause);
  CreateCopyIndexes(TableName, BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName);
  dbms_stats.gather_table_stats(BSC_METADATA_OPTIMIZER_PKG.gBscSchema, BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last);
  IF BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE <>0 AND BSC_METADATA_OPTIMIZER_PKG.gIndicators.count < l_threshold  THEN
    l_where_clause := ' WHERE indicator in
	         (select indicator from bsc_tmp_opt_ui_kpis where process_id='||BSC_METADATA_OPTIMIZER_PKG.g_processID||')';
  END IF;
  TableName := 'BSC_KPI_DATA_TABLES';
  --DropTable(TableName||'_LAST');
  CreateCopyTable(TableName, BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName, l_where_clause);
  CreateCopyIndexes(TableName, BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName);
  dbms_stats.gather_table_stats(BSC_METADATA_OPTIMIZER_PKG.gBscSchema, BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last);

  IF BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE <>0 AND BSC_METADATA_OPTIMIZER_PKG.gIndicators.count < l_threshold  THEN
    l_where_clause := ' WHERE table_name in
    (select source_table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last||'
    connect by table_name = prior source_table_name
    start with table_name in (select table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last||'))';
  END IF;
  TableName := 'BSC_DB_TABLES_COLS';
  CreateCopyTable(TableName, BSC_METADATA_OPTIMIZER_PKG.g_db_tables_cols_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName, l_where_clause);
  CreateCopyIndexes(TableName, BSC_METADATA_OPTIMIZER_PKG.g_db_tables_cols_last, BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName);
  dbms_stats.gather_table_stats(BSC_METADATA_OPTIMIZER_PKG.gBscSchema, BSC_METADATA_OPTIMIZER_PKG.g_db_tables_cols_last);

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl CreateLastTables, time is '||get_time);
  END IF;
    EXCEPTION WHEN OTHERS THEN
      writeTmp('Exception in CreateLastTables '||TableName||' : '||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;
/****************************************************************************
  DropTable

  DESCRIPTION:
     Drop a given table using Ad_ddl.do_ddl, ignore errors
***************************************************************************/

PROCEDURE DropTable(p_table_name in VARCHAR2) IS
BEGIN
  BSC_METADATA_OPTIMIZER_PKG.gDropTable := BSC_METADATA_OPTIMIZER_PKG.gDropTable +1;

  IF (mod(BSC_METADATA_OPTIMIZER_PKG.gDropTable, 500) = 0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Call # '||BSC_METADATA_OPTIMIZER_PKG.gDropTable||' to API DropTable');
   END IF;

  END IF;

  BEGIN
      do_ddl('DROP TABLE '||p_table_name|| ' CASCADE CONSTRAINTS', ad_ddl.drop_table, p_table_name);
  EXCEPTION WHEN OTHERS THEN
      null;
  END;
END;

/****************************************************************************
  DropTable

  DESCRIPTION:
     Drop a given view using Ad_ddl.do_ddl, ignore errors
***************************************************************************/

PROCEDURE DropView(p_view_name in VARCHAR2) IS
BEGIN

	do_ddl('DROP VIEW '||p_view_name, ad_ddl.drop_view, p_view_name);
  EXCEPTION WHEN OTHERS THEN
      null;

END;

/****************************************************************************
  Do_DDL

  DESCRIPTION:
     Wrapper for ad_ddl.do_ddl
***************************************************************************/

PROCEDURE Do_DDL(
	x_statement IN VARCHAR2,
      x_statement_type IN INTEGER := 0,
      x_object_name IN VARCHAR2
	) IS
BEGIN
  IF (BSC_METADATA_OPTIMIZER_PKG.gApplsysSchema IS NULL) THEN
      BSC_METADATA_OPTIMIZER_PKG.gApplsysSchema := BSC_MO_HELPER_PKG.getApplsysSchema;
  END IF;
  BSC_APPS.DO_DDL(x_statement=>x_statement ,
        x_statement_type => x_statement_type,
        x_object_name=> x_object_name);

END Do_DDL;

/*---------------------------------------------------------------------
 Get the actual schema name for the 'APPS' schema as it could be different
 in different implementations.

---------------------------------------------------------------------*/

Function getAppsSchema  RETURN VARCHAR2 IS


BEGIN
  if (	bsc_metadata_optimizer_pkg.gAppsSchema is not null) then
    return bsc_metadata_optimizer_pkg.gAppsSchema;
  end if;
  if ( bsc_metadata_optimizer_pkg.g_bsc_apps_initialized=false) then
    bsc_apps.init_bsc_apps;
     bsc_metadata_optimizer_pkg.g_bsc_apps_initialized := true;
  end if;
  bsc_metadata_optimizer_pkg.gAppsSchema :=  bsc_apps.get_user_schema('APPS');
  return bsc_metadata_optimizer_pkg.gAppsSchema;

END;


/****************************************************************************
  Do_DDL

  DESCRIPTION:
     Returns the BSC schema name
***************************************************************************/
FUNCTION getBSCSchema  return varchar2 is
begin
  if (bsc_metadata_optimizer_pkg.gBSCSchema is not null) then
    return bsc_metadata_optimizer_pkg.gBSCSchema;
  end if;
  if ( bsc_metadata_optimizer_pkg.g_bsc_apps_initialized=false) then
    bsc_apps.init_bsc_apps;
     bsc_metadata_optimizer_pkg.g_bsc_apps_initialized := true;
  end if;
  bsc_metadata_optimizer_pkg.gBSCSchema:= bsc_apps.get_user_schema('BSC');
  return bsc_metadata_optimizer_pkg.gBSCSchema;

END;


/****************************************************************************
  Do_DDL

  DESCRIPTION:
     Returns the FND schema name
***************************************************************************/
FUNCTION getApplsysSchema  return varchar2 is
begin
 if (bsc_metadata_optimizer_pkg.gApplsysSchema is not null) then
   return bsc_metadata_optimizer_pkg.gApplsysSchema;
 end if;

 if ( bsc_metadata_optimizer_pkg.g_bsc_apps_initialized=false) then
    bsc_apps.init_bsc_apps;
     bsc_metadata_optimizer_pkg.g_bsc_apps_initialized := true;
  end if;
  bsc_metadata_optimizer_pkg.gApplsysSchema := bsc_apps.get_user_schema('FND');
  return bsc_metadata_optimizer_pkg.gApplsysSchema;
END;

--****************************************************************************
--  PerteneceArregloStr: searchStringExists
--
--  DESCRIPTION:
--     Return TRUE if the given string belong to the given array.
--
--  PARAMETERS:
--     arrStr(): array of strings
--     Num: Size of the array (not used)
--     Cadena: String to look for.
--****************************************************************************

Function searchStringExists(arrStr dbms_sql.varchar2_table, Num number, str varchar2)
return Boolean IS
l_count number := 0;
l_error Varchar2(1000);

BEGIN
  IF (arrStr.count = 0) THEN
      return false;
  END IF;
  l_count := arrStr.first;
  LOOP
      IF (upper(arrStr(l_count)) = upper(str)) THEN
	     return true;
      END IF;
	   EXIT WHEN l_count = arrStr.last;
	   l_count := arrStr.next(l_count);
  END LOOP;

  return false;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in searchStringExists : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;

--****************************************************************************
--  PerteneceArregloStr: searchStringExists
--
--  DESCRIPTION:
--     Return TRUE if the given number belong to the given array.
--
--  PARAMETERS:
--     arrStr(): array of numbers
--     Num: Size of the array (not used)
--     Cadena: Number to look for.
--****************************************************************************
Function searchNumberExists(arrStr dbms_sql.number_table, Num number, l_findThis NUMBER)
return Boolean IS
l_count number := 0;
l_error Varchar2(1000);

BEGIN
  IF (arrStr.count = 0) THEN
      return false;
  END IF;
  l_count := arrStr.first;
  LOOP
	IF (upper(arrStr(l_count)) = upper(l_findThis)) THEN
	  return true;
  END IF;
	EXIT WHEN l_count = arrStr.last;
	l_count := arrStr.next(l_count);
  END LOOP;
  return false;


  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in searchNumberExists : '||l_error, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;


--*****************************************************************************
--  InsertChildTables_LAST
--  DESCRIPTION:
--     Insert in the arry arrChildTables() all the tables in the graph
--     that are affected by the tables in the array arrTables(), including
--     themself.
--     Note: This procedure uses BSC_DB_TABLES_RELS_LAST
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************


PROCEDURE InsertChildTables_LAST(arrTables IN dbms_sql.varchar2_table,
                       numTables IN OUT NOCOPY number,
           				 arrChildTables IN OUT NOCOPY dbms_sql.varchar2_table,
                       numChildTables IN OUT NOCOPY number) IS

l_table_name varchar2(300);
l_source_table_name VARCHAR2(300);
arrTablesAux dbms_sql.varchar2_table;
numTablesAux NUMBER;

--l_stmt VARCHAR2(2000) := 'SELECT TABLE_NAME FROM BSC_DB_TABLES_RELS_LAST WHERE UPPER(SOURCE_TABLE_NAME) = :1' ;
CURSOR cChildTables (pOriginTable IN VARCHAR2) IS
select  table_name  from bsc_db_tables_rels
connect by prior table_name = source_Table_name
start with source_table_name = pOriginTable;
l_error VARCHAR2(4000);

BEGIN

  For i IN 0..(numTables - 1) LOOP
      If Not searchStringExists(arrChildTables, numChildTables, arrTables(i)) Then
        arrChildTables(numChildTables) := arrTables(i);
        numChildTables := numChildTables + 1;
      End If;

      OPEN cChildTables(upper(arrTables(i)));

      arrTablesAux.delete;
      numTablesAux := 0;
      LOOP
        FETCH cChildTables INTO l_table_name;
        EXIT WHEN cChildTables%NOTFOUND;
        arrTablesAux(numTablesAux) := l_table_name;
        numTablesAux := numTablesAux + 1;
      END Loop;
      Close cChildTables;

      InsertChildTables_LAST (arrTablesAux, numTablesAux, arrChildTables, numChildTables);
  END LOOP;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp( 'Exception  in InsertChildTables_LAST :'||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      RAISE;

END;


--===========================================================================+
--   Name:      Add_Value_Big_In_Cond_Varchar2
--   Description:   Insert the given value into the temporary table of big
--            'in' conditions for the given variable_id.
--   Parameters:  x_variable_id  variable id.
--            x_value      value
--
--============================================================================
PROCEDURE Add_Value_Big_In_Cond_Varchar2(x_variable_id number, x_value number) IS
BEGIN
  bsc_apps.Add_Value_Big_In_Cond(x_variable_id, x_value);
End;

--****************************************************************************
--  InitInfoOldSystem
--  DESCRIPTION:
--     Initialize the array garrOldBTables() with base tables existing in the
--     system before run metadata.
--     Initialize the array garrOldIndicators() with the indicators existing
--     in the system before run metadata.
--     Because the metdata can be canceled in the middle and the metdata tables
--     are overwritten, we keep a set of _LAST tables and we delete them when
--     Metadata finish sucessfully.
--****************************************************************************


PROCEDURE  InitInfoOldSystem IS
  i  PLS_Integer;
  j  PLS_INTEGER;

  BaseTable VARCHAR2(1000);
  BakTable VARCHAR2(100);
  l_InputTable varchar2(100);
  periodicity pls_Integer;
  arrChildTables dbms_sql.varchar2_table;
  numChildTables pls_Integer;
  arrTables dbms_sql.varchar2_table;
  numTables pls_Integer;
  strWhereInChildTables varchar2(1000);

  l_stmt VARCHAR2(1000):='SELECT R.TABLE_NAME, R.SOURCE_TABLE_NAME, BT.PERIODICITY_ID
	FROM '||BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last||' R, '||
	BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last||' IT, '||
	BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last||' BT
	WHERE R.SOURCE_TABLE_NAME = IT.TABLE_NAME
	AND IT.TABLE_TYPE = 0
	AND R.TABLE_NAME = BT.TABLE_NAME
	AND IT.TABLE_NAME IN
	 (SELECT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS
	  CONNECT BY TABLE_NAME=prior SOURCE_TABLE_NAME
	  start with table_name in
	    (select distinct table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' where indicator in
	         (select indicator from bsc_tmp_opt_ui_kpis where process_id=:1)
	     )
      )
	ORDER BY R.SOURCE_TABLE_NAME';
  l_table_name varchar2(300);
  l_source_table_name varchar2(300);
  l_periodicity_id number;
  l_column VARCHAR2(100);
  l_indicator VARCHAR2(100);
  cv   CurTyp;
  cv1   CurTyp;
  CURSOR cColumns (pTableName IN VARCHAR2, pOwner IN VARCHAR2) IS
  SELECT column_name FROM all_tab_columns
			WHERE table_name = pTableName
			AND owner = pOwner
			ORDER BY column_id;

  l_error varchar2(1000);
  l_arr_indicators dbms_sql.number_table;
BEGIN

   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
     writeTmp( 'Inside InitInfoOldSystem, time is '||get_time);  --commit;
   END IF;
   open cv1 for l_stmt using BSC_METADATA_OPTIMIZER_PKG.g_processID;
   LOOP
     FETCH cv1 into l_table_name, l_source_table_name, l_periodicity_id;
	 EXIT when cv1%NOTFOUND;
     BaseTable := l_table_name;
     BakTable := BaseTable||'_BAK';
     l_InputTable := l_SOURCE_TABLE_NAME;
     periodicity := l_PERIODICITY_ID;
     --Add base table to array garrOldBTables
     BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Name := BaseTable;
     BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).periodicity := periodicity;
     BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).InputTable := l_InputTable;
     OPEN cColumns(UPPER(BakTable), UPPER(BSC_METADATA_OPTIMIZER_PKG.gBscSchema));
     BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).numFields := 0;
     LOOP
       FETCH cColumns into l_column;
       EXIT WHEN cColumns%NOTFOUND;
       IF (BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Fields IS NOT NULL) THEN
         BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Fields :=
                BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Fields||',';
       END IF;
       BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Fields :=
                BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Fields||l_column;
       BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).numFields :=
              BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).numFields + 1;
     END LOOP;
     CLOSE cColumns;
     numChildTables := 0;
     arrTables(0) := BaseTable;
     numTables := 1;
     --get all the tables affected by the base table
     InsertChildTables_LAST(arrTables, numTables, arrChildTables, numChildTables);
     --get all the indicator affected by these tables
     strWhereInChildTables := Get_New_Big_In_Cond_Varchar2(1, 'TABLE_NAME');
     Add_Value_Bulk(1, arrChildTables);
     l_stmt := 'SELECT DISTINCT INDICATOR FROM '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' WHERE '||strWhereInChildTables;
     l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'TABLE_NAME');
     l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'VALUE_V');
     BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).NumIndicators := 0;
     open cv for l_stmt;
     FETCH cv BULK COLLECT into l_arr_indicators;
     close cv;
     FOR i IN 1..l_arr_indicators.count LOOP
       l_indicator := l_arr_indicators(i);
       IF (BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Indicators IS NOT NULL) THEN
          BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Indicators :=
             BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Indicators|| ',';
       END IF;
       BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Indicators :=
          BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Indicators||l_indicator;
       BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).NumIndicators :=
           BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).NumIndicators + 1;
     END LOOP;
     IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
       writeTmp('Indicator list for table '||BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(
          BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).name||' - '|| BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(
          BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables).Indicators);
     END IF;
     BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables := BSC_METADATA_OPTIMIZER_PKG.gnumOldBTables + 1;
  END Loop;
  Close cv1;
  --Initialize array of old indicators
  l_stmt := 'SELECT DISTINCT INDICATOR FROM '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||' WHERE TABLE_NAME IS NOT NULL';
  BSC_METADATA_OPTIMIZER_PKG.gnumOldIndicators := 0;
  BSC_METADATA_OPTIMIZER_PKG.garrOldIndicators.delete;
  l_arr_indicators.delete;
  open cv for l_stmt;
  fetch cv bulk collect into l_arr_indicators;
  close cv;
  FOR i in 1..l_arr_indicators.count LOOP
    l_indicator := l_arr_indicators(i);
    BSC_METADATA_OPTIMIZER_PKG.garrOldIndicators(BSC_METADATA_OPTIMIZER_PKG.gnumOldIndicators) := l_indicator;
    BSC_METADATA_OPTIMIZER_PKG.gnumOldIndicators := BSC_METADATA_OPTIMIZER_PKG.gnumOldIndicators + 1;
  END Loop;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Compl InitInfoOldSystem, time is '||get_time);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    l_ERROR := sqlerrm;
    bsc_mo_helper_pkg.writeTmp( 'Exception in InitInfoOldSystem '||l_ERROR, FND_LOG.LEVEL_UNEXPECTED, true);
    RAISE;
END;


--***************************************************************************
--  deletePreviousRunTables
--
--   DESCRIPTION:
--     Delete all tables and records created by a previous execution of
--    Metadatada Optimizer.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************

PROCEDURE deletePreviousRunTables IS
  l_stmt varchar2(1000);
  l_table varchar2(100);
  strWhereInTables varchar2(1000);
  strWhereInIndics varchar2(1000);
  strWhereNotInIndics varchar2(1000);
  strWhereInIndics4 varchar2(1000);
  i number;
  mv_name varchar2(100);
  uv_name varchar2(100);
  pt_name varchar2(100);
  cv   CurTyp;
  l_error VARCHAR2(1000);
  l_drop_list_aw DBMS_SQL.VARCHAR2_TABLE;
  l_drop_list_number DBMS_SQL.NUMBER_TABLE;

  l_child_table VARCHAR2(1000);
BEGIN
  writeTmp( 'Inside deletePreviousRunTables, time is '||get_time, FND_LOG.LEVEL_STATEMENT, true);
  -- drop UI table used for getRelatedIndicators
  begin
    bsc_mo_helper_pkg.dropTable('BSC_TMP_OPT_KPI_DATA');
     exception when others then
     null;
  end;
  strWhereInIndics := Get_New_Big_In_Cond_Number( 1, 'INDICATOR');
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp('Will Loop '||BSC_METADATA_OPTIMIZER_PKG.garrIndics.count||' times for garrIndics');
  END IF;
  i:= BSC_METADATA_OPTIMIZER_PKG.garrIndics.first;
  LOOP
    EXIT when BSC_METADATA_OPTIMIZER_PKG.garrIndics.count = 0;
    --Add_Value_Big_In_Cond_Number(1, BSC_METADATA_OPTIMIZER_PKG.garrIndics(i));
    -- Feb 16, 2006, AW attach/detach taking too long in 9i
    -- first check if objective was implemented as AW previously
    -- Needed for AW call out , start with index = 1 for Venu :)
    if   BSC_AW_MD_API.is_kpi_present(to_char(BSC_METADATA_OPTIMIZER_PKG.garrIndics(i))) then
      l_drop_list_aw(l_drop_list_aw.count+1) := BSC_METADATA_OPTIMIZER_PKG.garrIndics(i);
    end if;
    l_drop_list_number(l_drop_list_number.count+1) := BSC_METADATA_OPTIMIZER_PKG.garrIndics(i);
    EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.garrIndics.last;
    i:= BSC_METADATA_OPTIMIZER_PKG.garrIndics.next(i);
  END LOOP;
  Add_Value_Bulk(1, l_drop_list_number);
  strWhereNotInIndics := ' NOT (' || strWhereInIndics ||')';
  strWhereInIndics4 := Get_New_Big_In_Cond_Number( 3, 'INDICATOR');
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp('Will Loop '||BSC_METADATA_OPTIMIZER_PKG.garrIndics4.count||' times for garrIndics4');
  END IF;

  Add_Value_Bulk(3, BSC_METADATA_OPTIMIZER_PKG.garrIndics4);
  strWhereInTables := Get_New_Big_In_Cond_Varchar2( 2, 'TABLE_NAME');
  Add_Value_Bulk(2, BSC_METADATA_OPTIMIZER_PKG.garrTables);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp( 'Loop thru and drop all tables');
  END IF;

  IF BSC_METADATA_OPTIMIZER_PKG.garrIndics.count  > 0 THEN
    --Set the prototype flag to 3 for the indicators that are going to be re-created
    --So, if Metadata fail, those indicators are marked and the next time
    --will be recreated and no matter that the configuration of BSC_KPI_DATA_TABLES
    --had been deleted.
    --Also, since the documentation is done for all indicators, the documentation
    --re-load all indicator from the database. So, it is necessary to update the
    --prototype flag with the correct one (remember that due to the relations between
    --kpi, some kpi could be flagged too)
    IF BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 2 THEN
      l_stmt := ' UPDATE BSC_KPIS_B
                  SET PROTOTYPE_FLAG = DECODE(PROTOTYPE_FLAG, 2, 2, 3),
                  LAST_UPDATED_BY = :1,
                  LAST_UPDATE_DATE = SYSDATE  WHERE '|| strWhereInIndics;
      execute immediate l_stmt using BSC_METADATA_OPTIMIZER_PKG.gUserId;
    END IF;
    --BSC-MV Note: Drop all the MV used for those KPis
    l_stmt := 'SELECT DISTINCT MV_NAME FROM BSC_KPI_DATA_TABLES WHERE ('||  strWhereInIndics ||')  AND MV_NAME IS NOT NULL';
    writeTmp(l_stmt);
    OPEN cv FOR l_stmt;
    LOOP
      FETCH cv INTO mv_name;
      EXIT WHEN cv%NOTFOUND;
      writeTmp('Drop mv '||mv_name, 1, true);
      BSC_BIA_WRAPPER.Drop_Summary_MV_VB(mv_name);
      BSC_MO_HELPER_PKG.CheckError('BSC_BIA_WRAPPER.Drop_Summary_MV_VB');
    END LOOP;
    CLOSE cv;
    --BSC-MV Note: Drop all MV used for targets for those KPIs
    l_stmt := 'SELECT DISTINCT BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(SOURCE_TABLE_NAME) MV_NAME
            FROM BSC_DB_TABLES_RELS WHERE TABLE_NAME IN (
              SELECT TABLE_NAME
              FROM '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table||'
              WHERE (' || strWhereInIndics || ') AND TABLE_NAME IS NOT NULL ) AND RELATION_TYPE = 1';

    OPEN cv FOR l_stmt;
    LOOP
      FETCH cv INTO mv_name;
      EXIT WHEN cv%NOTFOUND;
      BSC_BIA_WRAPPER.Drop_Summary_MV_VB(mv_name);
      BSC_MO_HELPER_PKG.CheckError('BSC_BIA_WRAPPER.Drop_Summary_MV_VB');
    END LOOP;
    Close cv;
    --BSC-MV Note: Drop all tables created for projections
    l_stmt := 'SELECT DISTINCT PROJECTION_DATA FROM BSC_KPI_DATA_TABLES  WHERE ('|| strWhereInIndics || ')
              AND PROJECTION_DATA IS NOT NULL';
    OPEN cv FOR l_stmt;
    LOOP
      FETCH cv INTO pt_name;
      EXIT WHEN cv%NOTFOUND;
      If TableExists(pt_name) Then
        Droptable( pt_name);
      End If;
    END LOOP;
    CLOSE cv;
    --Update column TABLE_NAME to NULL in BSC_KPI_DATA_TABLES
    --BSC-MV Note: Set MV_NAME to NULL in BSC_KPI_DATA_TABLES
    l_stmt := 'UPDATE BSC_KPI_DATA_TABLES
		       SET   TABLE_NAME = NULL, MV_NAME = NULL, DATA_SOURCE = NULL,
                 SQL_STMT = NULL, PROJECTION_SOURCE = 0, PROJECTION_DATA = NULL
		       WHERE '|| strWhereInIndics;
    writeTmp(l_stmt, fnd_log.level_statement, false);
    Execute immediate l_stmt;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.garrIndics4.count > 0 THEN
    --Set the prototype flag to 4 for the indicators that are going to be re-configured
    --So, if Metadata fail, those indicators are marked and the next time
    --will be re-configured no matter that the configuration of BSC_KPI_DATA_TABLES
    --had been deleted.
    --Also, since the documentation is done for all indicators, the documentation
    --re-load all indicator from the database. So, it is necessary to update the
    --prototype flag with the correct one (remember that due to the relations between
    --kpi, some kpi could be flagged too)

    IF BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 2 THEN
      l_stmt := 'UPDATE BSC_KPIS_B SET PROTOTYPE_FLAG = DECODE(PROTOTYPE_FLAG, 2, 2, 4), '||
			' LAST_UPDATED_BY = :1 ,'||
			' LAST_UPDATE_DATE = SYSDATE '||
			' WHERE (' || strWhereInIndics4 || ')';
      IF BSC_METADATA_OPTIMIZER_PKG.garrIndics.count > 0 THEN
        l_stmt:= l_stmt|| ' AND ('||  strWhereNotInIndics ||')';
      END IF;
      Execute immediate l_stmt using BSC_METADATA_OPTIMIZER_PKG.gUserId;
    END IF;
    --BSC-MV Note: If there is summarization level change (example from 3 to 2 or 2 to 3)
    --It is necessary to drop the existing MV of the indicator. They will be re-created
    --and bSC_KPI_DATA_TABLES will be reconfigured
    If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 2 Then
      --BSC-MV Note: Drop all the MV used for those KPis
      l_stmt := 'SELECT DISTINCT MV_NAME FROM BSC_KPI_DATA_TABLES WHERE ('|| strWhereInIndics4 ||')';
      If BSC_METADATA_OPTIMIZER_PKG.garrIndics.count > 0 Then
        l_stmt := l_stmt ||' AND (' || strWhereNotInIndics || ')';
      End If;
      l_stmt := l_stmt ||' AND MV_NAME IS NOT NULL';

      OPEN cv FOR l_stmt;
      LOOP
        FETCH cv INTO mv_name;
        EXIT WHEN cv%NOTFOUND;
        BSC_BIA_WRAPPER.Drop_Summary_MV_VB(mv_name);
        IF (bsc_metadata_optimizer_pkg.g_log) then
          writeTmp('Dropping summary mv '||mv_name, fnd_log.level_statement, false);
        END IF;
        BSC_MO_HELPER_PKG.CheckError('BSC_BIA_WRAPPER.Drop_Summary_MV_VB');
      END LOOP;
      CLOSE cv;

      --BSC-MV Note: Drop all MV used for targets for those KPIs
      l_stmt := 'SELECT DISTINCT BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(SOURCE_TABLE_NAME) MV_NAME
                FROM BSC_DB_TABLES_RELS WHERE TABLE_NAME IN (
                SELECT TABLE_NAME FROM BSC_KPI_DATA_TABLES WHERE ('|| strWhereInIndics4 || ')';
      If BSC_METADATA_OPTIMIZER_PKG.garrIndics.count > 0 Then
        l_stmt := l_stmt || ' AND (' || strWhereNotInIndics || ')';
      End If;

      l_stmt := l_stmt || ' AND TABLE_NAME IS NOT NULL  ) AND RELATION_TYPE = 1';
      OPEN cv FOR l_stmt;
      LOOP
        FETCH cv INTO mv_name;
        EXIT WHEN cv%NOTFOUND;
        BSC_BIA_WRAPPER.Drop_Summary_MV_VB(mv_name);
        writeTmp('Dropping mv '||mv_name, fnd_log.level_statement, false);
        BSC_MO_HELPER_PKG.CheckError('BSC_BIA_WRAPPER.Drop_Summary_MV_VB');
      END LOOP;
      Close cv;
    END IF;
    --BSC-MV Note: Do NOT drop tables created for projections. For non-structural
    --changes those tables are not going to be re-created
  END IF;
  --Delete all input, base, temporal and summary tables
  i:= BSC_METADATA_OPTIMIZER_PKG.garrTables.first;
  writeTmp('Dropping Table and related metadata for ', FND_LOG.LEVEL_STATEMENT, true);
  LOOP
    EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.garrTables.count = 0;
    IF substr(BSC_METADATA_OPTIMIZER_PKG.garrTables(i), 1, 6)=  'BSC_B_' THEN
      IF is_base_table(BSC_METADATA_OPTIMIZER_PKG.garrTables(i)) THEN
        backup_b_table(BSC_METADATA_OPTIMIZER_PKG.garrTables(i));
        BSC_METADATA_OPTIMIZER_PKG.gBackedUpBTables(BSC_METADATA_OPTIMIZER_PKG.gBackedUpBTables.count):= BSC_METADATA_OPTIMIZER_PKG.garrTables(i);
        IF BSC_DBGEN_UTILS.get_objective_type_for_b_table(BSC_METADATA_OPTIMIZER_PKG.garrTables(i))='AW' THEN
          bsc_aw_load.drop_bt_change_vector(BSC_METADATA_OPTIMIZER_PKG.garrTables(i));
        END IF;
        -- drop B_PRJ table if it exists
        writeTmp('Table Type=B, child_table='||l_child_table);
        l_child_table:= BSC_DBGEN_METADATA_READER.get_table_properties(BSC_METADATA_OPTIMIZER_PKG.garrTables(i),
                                                                       BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE) ;
        if (l_child_table is not null) then
          DropTable(l_child_table);
        end if;
      END IF;
    END IF;
    -- drop i_rowid table if it exists
    IF (bsc_dbgen_utils.get_table_type(bsc_metadata_optimizer_pkg.garrTables(i))='I') THEN
      l_child_table := BSC_DBGEN_METADATA_READER.get_table_properties(BSC_METADATA_OPTIMIZER_PKG.garrTables(i),
                                                                      BSC_DBGEN_STD_METADATA.BSC_I_ROWID_TABLE) ;
      writeTmp('Table Type=I, child_table='||l_child_table);
      if (l_child_table is not null) then
        DropTable(l_child_table);
      end if;
    END IF;
    DropTable( BSC_METADATA_OPTIMIZER_PKG.garrTables(i));
    -- force this to the output.
    l_error := l_error || BSC_METADATA_OPTIMIZER_PKG.garrTables(i) ||', ';
    IF (i>0 AND mod(i, 10) = 0) THEN
      writeTmp(l_error, FND_LOG.LEVEL_STATEMENT, true);
      l_error := null;
    END IF;
    EXIT WHEN i=BSC_METADATA_OPTIMIZER_PKG.garrTables.last;
    i := BSC_METADATA_OPTIMIZER_PKG.garrTables.next(i);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.garrTables.count > 0 THEN
    --BSC_DB_TABLES
    l_stmt := 'DELETE FROM BSC_DB_TABLES WHERE '||strWhereInTables;
    l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'table_name');
    l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'value_v');
    Execute immediate l_stmt;
    --BSC_DB_TABLES_RELS
    l_stmt := 'DELETE FROM BSC_DB_TABLES_RELS WHERE '|| strWhereInTables;
    l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'table_name');
    l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'value_v');
    Execute immediate l_stmt;
    --BSC_DB_TABLES_COLS
    l_stmt := 'DELETE FROM BSC_DB_TABLES_COLS WHERE '||  strWhereInTables;
    l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'table_name');
    l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'value_v');
    Execute immediate l_stmt;
    --BSC_DB_CALCULATIONS
    l_stmt := 'DELETE FROM BSC_DB_CALCULATIONS WHERE '||  strWhereInTables;
    l_stmt := replace(l_stmt, 'UPPER(TABLE_NAME)', 'table_name');
    l_stmt := replace(l_stmt, 'UPPER(VALUE_V)', 'value_v');
    Execute immediate l_stmt;
  END IF;

  IF (bsc_metadata_optimizer_pkg.g_bsc_mv and l_drop_list_aw.count>0) then
      -- DROP ALL OBJECTS IMPLEMENTED AS AW
    l_stmt := null;
    IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
      l_stmt := 'DEBUG LOG';
    END IF;
    BEGIN
    BSC_AW_ADAPTER.drop_kpi(l_drop_list_aw, l_stmt);
     EXCEPTION WHEN OTHERS THEN
      null;
    END;
  END IF;

  writeTmp( 'Compl deletePreviousRunTables, system time is '||get_time, FND_LOG.LEVEL_STATEMENT, true);
  EXCEPTION WHEN OTHERS THEN
  l_ERROR := sqlerrm;
  bsc_mo_helper_pkg.writeTmp( 'Exception in deletePreviousRunTables '||l_ERROR, FND_LOG.LEVEL_UNEXPECTED, true);
  RAISE;
End;

--****************************************************************************
--  EscribirInic : WriteInitTable
--
--  DESCRIPTION:
--     Write the given variable in BSC_SYS_INIT table.
--  PARAMETERS:
--     Variable: variable name
--     Valor: value
--     db_obj: database
--****************************************************************************
PROCEDURE WriteInitTable(propertyCode IN VARCHAR2, propertyValue IN VARCHAR2) IS
  l_stmt VARCHAR2(3000);
  l_count NUMBER;
BEGIN

  IF propertyValue IS NOT NULL THEN
    SELECT Count(1) INTO l_count FROM BSC_SYS_INIT
    WHERE UPPER(PROPERTY_CODE) = UPPER(propertyCode);

    IF l_count > 0 THEN
      UPDATE BSC_SYS_INIT SET PROPERTY_VALUE = propertyValue, LAST_UPDATED_BY = BSC_METADATA_OPTIMIZER_PKG.gUserID, LAST_UPDATE_DATE = SYSDATE
      WHERE UPPER(PROPERTY_CODE) = UPPER(propertyCode);
        --Execute IMMEDIATE l_stmt using propertyValue, BSC_METADATA_OPTIMIZER_PKG.gUserID, UPPER(propertyCode);
    Else
      INSERT INTO BSC_SYS_INIT (PROPERTY_CODE, PROPERTY_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE)
      VALUES(propertyCode, propertyValue, BSC_METADATA_OPTIMIZER_PKG.gUserID, SYSDATE, BSC_METADATA_OPTIMIZER_PKG.gUserID, SYSDATE);
    End IF;
  End IF;
End;



--****************************************************************************
--  Inic_ano: InitializeYear
--
--  DESCRIPTION:
--     Initialize the year for indicators and BSC_DB_CALENDAR table
--****************************************************************************
PROCEDURE InitializeYear IS

  l_stmt VARCHAR2(3000);
  Indicador BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
  Calendar BSC_METADATA_OPTIMIZER_PKG.clsCalendar;
  num_anos NUMBER;
  num_anosant NUMBER;
  table_name VARCHAR2(100);
  mv_name VARCHAR2(100);
  Indic NUMBER;
  doit Boolean;
  l_index1 NUMBER;
  l_index2 NUMBER;

  l_temp NUMBER;
BEGIN
  IF (BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 1) THEN
    --Initilaize BSC Calendar if this is the first time
    --Populate calendar tables according to fiscal year
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gCalendars.first;

    LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gCalendars.count=0;
      Calendar := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_index1);
      --BIS DIMENSIONS: We cannot call Populate_Calendar_Tables for BIS Calendars
      --The API that imported the BIS Calendars already populated BSC_DB_CALENDAR and
      --BSC_SYS_PERIODS_TL, etc
      IF Calendar.Source = 'BSC' THEN
        --BSC Calendar
        BSC_UPDATE_UTIL.Populate_Calendar_Tables(Calendar.Code);
        BSC_MO_HELPER_PKG.CheckError('BSC_UPDATE_UTIL.Populate_Calendar_Tables');
      End IF;
      EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gCalendars.last;
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gCalendars.next(l_index1);
    END LOOP;
  Else
    --gSYSTEM_STAGE = 2
    --Check for any change in year range of all calendars
    IF (BSC_METADATA_OPTIMIZER_PKG.gCalendars.count >0) THEN
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gCalendars.first;
      LOOP
        Calendar := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_index1);
        IF Calendar.RangeYrMod = 1 THEN
          --There was a change in the range of years
          num_anos := Calendar.NumOfYears;
          num_anosant := Calendar.PreviousYears;
          --Update the range of years in BSC_DB_TABLES for tables
          --belonging to this calendar.
          --Remember that BSC Calendar is code -1 in gCalendars
          UPDATE BSC_DB_TABLES SET NUM_OF_YEARS = num_anos, PREVIOUS_YEARS = num_anosant
                  WHERE PERIODICITY_ID IN (
                  SELECT PERIODICITY_ID FROM BSC_SYS_PERIODICITIES
                  WHERE CALENDAR_ID = Calendar.Code );
          IF Calendar.Source = 'BSC' THEN
            --BSC Calendar
            BSC_UPDATE_UTIL.Populate_Calendar_Tables(Calendar.Code);
            BSC_MO_HELPER_PKG.CheckError('BSC_UPDATE_UTIL.Populate_Calendar_Tables');
          End IF;

          --BIS DIMENSIONS: We cannot call Populate_Calendar_Tables for BIS Calendars
          --The API that imported the BIS Calendars already populated BSC_DB_CALENDAR and
          --BSC_SYS_PERIODS_TL, etc

        End IF;
        EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gCalendars.last;
        l_index1 := BSC_METADATA_OPTIMIZER_PKG.gCalendars.next(l_index1);
      END LOOP;
    END IF; -- OF (BSC_METADATA_OPTIMIZER_PKG.gCalendars.count >0)
  End IF;

  IF BSC_METADATA_OPTIMIZER_PKG.gThereisStructureChange THEN
    IF (BSC_METADATA_OPTIMIZER_PKG.gIndicators.count >0) THEN
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
    END IF;
    LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gIndicators.count = 0;
      Indicador := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index1);
      IF Indicador.Action_Flag = 3 THEN
        --Update indicators current period in BSC_KPI_PERIODICITIES
        --IF the periodicity is not yearly then the period need to be 1,
        --otherwise the period ned to be the current fiscal year of the calendar
        UPDATE BSC_KPI_PERIODICITIES K
           SET CURRENT_PERIOD =
		       (SELECT  DECODE(P.YEARLY_FLAG, 1, C.FISCAL_YEAR, 1)
                  FROM BSC_SYS_PERIODICITIES P, BSC_SYS_CALENDARS_B C
                 WHERE K.PERIODICITY_ID = P.PERIODICITY_ID
				   AND P.CALENDAR_ID = C.CALENDAR_ID
				)
         WHERE INDICATOR = Indicador.Code;
        --All colors in the panel have to be gray
        UPDATE BSC_SYS_KPI_COLORS
          SET  KPI_COLOR = BSC_METADATA_OPTIMIZER_PKG.ColorG,
               ACTUAL_DATA = NULL,
               BUDGET_DATA = NULL
          WHERE INDICATOR = Indicador.Code;
        UPDATE bsc_sys_objective_colors
           SET obj_color = BSC_METADATA_OPTIMIZER_PKG.ColorG
           WHERE indicator = Indicador.Code;
        --Update the name of period of indicators in BSC_KPI_DEFAULTS_TL table
        --BSC Kpi => BSC Periodicity
        --Labels are in BSC_SYS_PERIODS_TL
        BEGIN
         UPDATE BSC_KPI_DEFAULTS_TL D
             SET PERIOD_NAME = (
               SELECT
                 CASE WHEN NVL(C.EDW_CALENDAR_TYPE_ID, 0) = 0 AND P.YEARLY_FLAG = 1  THEN
                 K.PERIODICITY_ID||'-'||C.FISCAL_YEAR
                 ELSE
                 (SELECT
                    K.PERIODICITY_ID||'-'||L.NAME
                  FROM
                    BSC_KPI_PERIODICITIES KP,
                    BSC_SYS_PERIODS_TL L
                  WHERE
                    K.INDICATOR = KP.INDICATOR AND
                    K.PERIODICITY_ID = KP.PERIODICITY_ID AND
                    C.FISCAL_YEAR = L.YEAR AND
                    KP.PERIODICITY_ID = L.PERIODICITY_ID AND
                    KP.CURRENT_PERIOD = L.PERIOD_ID AND
                    D.LANGUAGE = L.LANGUAGE
                 )
                 END
               FROM
                 BSC_DB_COLOR_KPI_V K,
                 BSC_SYS_PERIODICITIES P,
                 BSC_SYS_CALENDARS_B C
               WHERE
                 K.TAB_ID = D.TAB_ID AND
                 K.INDICATOR = D.INDICATOR AND
                 K.PERIODICITY_ID = P.PERIODICITY_ID AND
                 P.CALENDAR_ID = C.CALENDAR_ID
             )
            WHERE
            INDICATOR = Indicador.Code;
          EXCEPTION WHEN OTHERS THEN
              writeTmp('Ignoring Error while updating BSC_KPI_DEFAULTS_TL in InitializeYear for Indic= '||Indicador.code||':'||sqlerrm);
          END;
		  --Update date of indicator
          UPDATE BSC_KPI_DEFAULTS_B SET LAST_UPDATE_DATE = SYSDATE  WHERE INDICATOR = Indicador.Code;
          --EXECUTE IMMEDIATE l_stmt USING Indicador.Code;
      End IF;
      EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(l_index1);
    END LOOP;
  End IF;

  --Update BSC_SYS_INIT
  WriteInitTable( 'UPDATE_DATE', to_char(sysdate, 'dd/mm/yyyy'));

  --TerminarPorError (Get_Message('BSC_TABLES_INIT_FAILED'))
End ;

FUNCTION all_columns_used(p_arr_source_table DBMS_SQL.VARCHAR2_TABLE, p_table_name OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE, p_unused_columns OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE) return boolean IS

l_stmt VARCHAR2(1000):=
'SELECT last.table_name, last.column_name
   FROM '||bsc_metadata_optimizer_pkg.g_db_tables_cols_last||' last
      , bsc_tmp_big_in_cond cond
  WHERE last.table_name = cond.value_v
    AND cond.variable_id = :1
    AND cond.session_id = :2
    AND last.column_type = :3
  MINUS
 SELECT cols.table_name, cols.column_name
   FROM bsc_db_tables_cols cols
      , bsc_db_tables_rels rels
      , bsc_tmp_big_in_cond cond
  WHERE cond.value_v = rels.source_table_name
    AND rels.table_name = cols.table_name
    AND cond.variable_id = :4
    AND cond.session_id = :5
    AND cols.column_type = :6';
b_all_columns_used boolean;
cv CurTyp;
l_col VARCHAR2(100);

l_dummy varchar2(1000);
BEGIN
  b_all_columns_used := true;

  l_dummy := Get_New_Big_In_Cond_varchar2(11, 'table_name');
  Add_Value_Bulk(11, p_table_name);

  OPEN cv FOR l_stmt using 11, userenv('SESSIONID'), 'A', 11, userenv('SESSIONID'), 'A';
  FETCH cv BULK COLLECT INTO p_table_name, p_unused_columns;
  CLOSE cv;
  if (p_table_name.count>0) then
    b_all_columns_used := false;
  end if;
  return b_all_columns_used ;
  EXCEPTION WHEN OTHERS THEN
   writeTmp('Exception in all_columns_used:'||sqlerrm||', l_stmt='||l_stmt,  FND_LOG.LEVEL_UNEXPECTED, true);
   raise;
END;

PROCEDURE drop_column(p_Table_name IN VARCHAR2, p_column_name IN VARCHAR2) IS
l_stmt VARCHAR2(1000);

BEGIN
  l_stmt := 'alter table '||p_Table_name ||' drop column '||p_column_name;
  --writeTmp(l_stmt);
  IF (table_column_exists(p_table_name, p_column_name)) THEN
    writeTmp(l_stmt);
    BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, p_Table_name );
  ELSE
    writeTmp(p_table_name||'.'||p_column_name||' doesnt exist, so not calling alter table as this was possibly dropped earlier');
  END IF;
  DELETE bsc_db_tables_cols
   WHERE table_name = p_Table_name
     AND column_name = p_column_name;
END;

PROCEDURE drop_unused_columns_for_tables(p_table_name IN DBMS_SQL.VARCHAR2_TABLE) IS
  strWhereInIndics VARCHAR2(1000);
  cv CurTyp;
  l_stmt VARCHAR2(1000):=
    'select distinct source_table_name from '||BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last||'
    connect by table_name = prior source_table_name
    start with table_name in (select value_v from bsc_tmp_big_in_cond where variable_id=:1 and session_id=:2)';
  l_unused_columns DBMS_SQL.VARCHAR2_TABLE;
  l_mvlog_name VARCHAR2(100);
  l_source_table_name VARCHAR2(100);
  l_i_table DBMS_SQL.VARCHAR2_TABLE;

  l_arr_source_table dbms_sql.varchar2_table;
  l_arr_table_name  dbms_sql.varchar2_table;

  l_dummy varchar2(1000);
BEGIN
  writeTmp('Drop unused columns for tables');

  l_dummy  := Get_New_Big_In_Cond_varchar2(11, 'table_name');
  Add_Value_Bulk(11, p_table_name);

  OPEN cv FOR l_stmt USING 11, userenv('SESSIONID');
  FETCH cv BULK COLLECT INTO l_arr_source_table;
  CLOSE cv;
  writeTmp('Drop unused columns for tables ');
  IF all_columns_used(l_arr_source_table, l_arr_table_name, l_unused_columns)=false THEN
      for j in l_unused_columns.first..l_unused_columns.last loop
        drop_column(l_arr_table_name(j), l_unused_columns(j));
        IF bsc_dbgen_utils.get_table_type(l_arr_table_name(j)) = 'B' THEN -- drop mv log column
          BEGIN
            l_mvlog_name := bsc_dbgen_utils.get_mvlog_for_table(l_arr_table_name(j));
            IF (l_mvlog_name IS NOT NULL) THEN
              drop_column(l_mvlog_name, l_unused_columns(j));
            END IF;
            EXCEPTION WHEN OTHERS THEN
              null;
          END;
        END IF;
      end loop;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
  IF (SQLCODE <> -942) THEN -- table doesnt exist, so ignore
   writeTmp('Exception in drop_unused_columns_for_table:'||sqlerrm,  FND_LOG.LEVEL_UNEXPECTED, true);
   writeTmp('drop_unused_columns_for_table, l_stmt='||l_stmt,  FND_LOG.LEVEL_UNEXPECTED, true);
   raise;
  END IF;
END;

PROCEDURE drop_unused_columns(p_drop_tables_sql IN VARCHAR2) IS
  strWhereInIndics VARCHAR2(1000);
  l_stmt varchar2(4000);
  cv CurTyp;
  L_TABLE_NAME VARCHAR2(100);
  l_number_list dbms_sql.number_table;
  l_arr_table_names dbms_sql.varchar2_table;
BEGIN

  writeTmp('Starting drop_unused_columns');
  strWhereInIndics := Get_New_Big_In_Cond_Number(11, 'INDICATOR');
  FOR i IN BSC_METADATA_OPTIMIZER_PKG.gIndicators.first..BSC_METADATA_OPTIMIZER_PKG.gIndicators.last LOOP
    l_number_list(l_number_list.count+1):= BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).code;
  END LOOP;
  Add_Value_Bulk(11, l_number_list);

  l_stmt := '
  SELECT distinct table_name FROM '||BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last||' last
   WHERE table_name LIKE ''BSC_S%'' AND source_table_name NOT like ''BSC_S%''
     AND table_name in
         (select distinct table_name
            from '||BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last||' )';

  writeTmp('Drop table SQL in drop unused columns is :'||l_stmt, FND_LOG.LEVEL_STATEMENT, FALSE);
  writeTmp(BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||','|| BSC_METADATA_OPTIMIZER_PKG.gAppsSchema,
     FND_LOG.LEVEL_STATEMENT, FALSE);
  OPEN cv FOR l_stmt ;
  FETCH cv BULK COLLECT INTO l_arr_table_names;
  CLOSE cv;

  drop_unused_columns_for_Tables(l_arr_Table_names);
  EXCEPTION WHEN OTHERS THEN
   writeTmp('Exception in drop_unused_columns:'||sqlerrm,  FND_LOG.LEVEL_UNEXPECTED, true);
   writeTmp('drop_unused_columns:l_stmt='||l_stmt,  FND_LOG.LEVEL_UNEXPECTED, true);
   --raise;

END;


PROCEDURE drop_unused_mvlogs IS
CURSOR cDropThese IS
select distinct level_table_name
from bsc_sys_dim_levels_b lvl
   , all_snapshot_logs log
where log.log_owner=BSC_METADATA_OPTIMIZER_PKG.gBSCSchema
  and log.master = lvl.level_Table_name
minus
select distinct level_table_name
from bsc_sys_dim_levels_b lvl
   , all_snapshot_logs log
   , all_dependencies db
   , all_mviews mv
where log.log_owner=BSC_METADATA_OPTIMIZER_PKG.gBSCSchema
  and log.master = lvl.level_Table_name
  and db.referenced_owner=BSC_METADATA_OPTIMIZER_PKG.gBSCSchema
  and db.referenced_type = 'TABLE'
  and db.referenced_name = lvl.level_table_name
  and db.type = 'MATERIALIZED VIEW'
  and db.owner=mv.owner
  and db.name=mv.mview_name
  and mv.owner = BSC_METADATA_OPTIMIZER_PKG.gAppsSchema
  and mv.fast_refreshable<>'NO';
BEGIN
  FOR i IN cDropThese LOOP
    execute immediate 'drop materialized view log on '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.'||i.level_table_name;
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
   writeTmp('Exception in drop_unused_mvlogs:'||sqlerrm,  FND_LOG.LEVEL_UNEXPECTED, true);
   raise;
END;

--****************************************************************************
--  CleanDatabase
--
--  DESCRIPTION:
--     Clean un-used tables from the database
--     This is just to make sure that the system is clean after user run Metadata Optmizer
--     It will drop all tables that are not being used by any indidator.
--     This situation should not happen, but due to some unkown issue in the past
--     some tables could be there but no indicator is using it.
--****************************************************************************
PROCEDURE CleanDatabase IS
  arrAllTables DBMS_SQL.VARCHAR2_TABLE;
  numAllTables NUMBER;

  l_stmt VARCHAR2(1000);
  i NUMBER;
  arrNotUsedTables DBMS_SQL.VARCHAR2_TABLE;
  numNotUsedTables NUMBER;
  strWhereInCondition VARCHAR2(1000);

  mv_name VARCHAR2(100);
  uv_name VARCHAR2(100);
  l_table VARCHAR2(100);

  cv   CurTyp;
  l_index NUMBER;

  /*CURSOR cAllTables IS
    with kpi_data as(SELECT DISTINCT TABLE_NAME
    FROM BSC_KPI_DATA_TABLES
    WHERE TABLE_NAME IS NOT NULL )
    SELECT table_name from kpi_data
    UNION
    SELECT DISTINCT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS
    START WITH table_name IN (SELECT TABLE_NAME from kpi_data)
    CONNECT BY PRIOR source_table_name = table_name ; */
   CURSOR cAllTables IS
    select table_name from bsc_db_tables where table_type=0
    union all
    SELECT DISTINCT table_name
    from BSC_DB_TABLES_RELS
    START WITH source_TABLE_NAME IN
    (select table_name from bsc_db_tables where table_type=0)
    CONNECT BY PRIOR TABLE_NAME = source_TABLE_NAME;

  l_drop_these VARCHAR2(32000);
  l_drop_threshold NUMBER := 200;

  CURSOR cDropThese IS
  WITH btable as (
  SELECT table_name, owner
    FROM all_tables
   WHERE (table_name like BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table_pfx||'%'
      OR table_name like BSC_METADATA_OPTIMIZER_PKG.g_period_circ_check_pfx||'%'
      OR table_name like BSC_METADATA_OPTIMIZER_PKG.g_filtered_indics_pfx||'%'
      OR table_name like BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last_pfx||'%'
      OR table_name like BSC_METADATA_OPTIMIZER_PKG.g_db_tables_rels_last_pfx||'%'
      OR table_name like BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last_pfx||'%'
      OR table_name like BSC_METADATA_OPTIMIZER_PKG.g_db_tables_cols_last_pfx||'%'
      OR table_name like 'BSC_TMP_COL_TYPE%'
	   )
	 AND owner in (BSC_METADATA_OPTIMIZER_PKG.gAppsSchema, BSC_METADATA_OPTIMIZER_PKG.gBSCSchema))
   SELECT table_name, owner
    FROM btable
   MINUS
   SELECT table_name, owner
    FROM btable, v$session
	WHERE substr(table_name, instr(table_name, '_', -1)+1, 100) in
        (select to_char(audsid) from v$session where status<>'KILLED');

	l_table_name VARCHAR2(100);
	l_owner   VARCHAR2(100);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside cleanDatabase '||get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  -- Applicable only for MV architecture and non-upgrade scenario
  IF (bsc_metadata_optimizer_pkg.g_bsc_mv and bsc_metadata_optimizer_pkg.g_Sum_Level_Change<>1) then
    -- Bug 4318566:drop unused MV logs
    drop_unused_mvlogs;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Dropped unused mv logs '||get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;

  numAllTables := 0;
  --Get all the tables used by all indicators
  OPEN cAllTables;
  FETCH cAllTables BULK COLLECT INTO arrAllTables;
  --LOOP
    --  FETCH cAllTables into l_table;
    --  EXIT WHEN cAllTables%NOTFOUND;
    --  arrAllTables(arrAllTables.count) := l_table;
  --END Loop;
  Close cAllTables;
  --Bug Fix#4071757, No need to call InsertOriginTables
  --BSC_MO_LOADER_CONFIG_PKG.InsertOriginTables (arrKpiTables, arrAllTables);
  numAllTables := arrAllTables.count;
  --So far the array arrAllTables() contains all input, base and summary tables
  --used in the whole system
  --Tables that are in BSC_DB_TABLES (excluding input tables for dimensions) and are not
  --in the array arrAllTables() are not used. We need to delete those tables from database
  -- and BSC metadata.
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('numAllTables = '||numAllTables||', arrAllTables.count = '||arrAllTables.count||' '||get_time);
  END IF;
  --So far the array arrAllTables() contains all input, base and summary tables
  --used in the whole system
  --Tables that are in BSC_DB_TABLES (excluding input tables for dimensions) and are not
  --in the array arrAllTables() are not used. We need to delete those tables from database
  -- and BSC metadata.
  numNotUsedTables := 0;
  strWhereInCondition := Get_New_Big_In_Cond_Varchar2(1, 'TABLE_NAME');
  Add_Value_Bulk(1, arrAllTables);

  l_stmt := 'SELECT DISTINCT TABLE_NAME FROM BSC_DB_TABLES WHERE TABLE_TYPE <> 2 AND NOT (' ||
           strWhereInCondition || ')';

  l_stmt := 'SELECT DISTINCT TABLE_NAME FROM BSC_DB_TABLES WHERE TABLE_TYPE <> :1
   minus
   select upper(value_v) from bsc_tmp_big_in_cond where variable_id=:2 and session_id = :3';
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('l_stmt = '||l_stmt||' '||get_time);
  END IF;

  OPEN cv FOR L_stmt using 2, 1, bsc_metadata_optimizer_pkg.g_session_id;
  LOOP
    FETCH cv INTO l_table;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('after fetch '||get_time);
    END IF;
    EXIT WHEN CV%NOTFOUND;
    arrNotUsedTables(arrNotUsedTables.count) := l_table;
  END Loop;
  Close cv;

  numNotUsedTables := arrNotUsedTables.count;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    writeTmp('numNotUsedTables = '||numNotUsedTables||' '||get_time);
  END IF;

  strWhereInCondition := Get_New_Big_In_Cond_Varchar2(1, 'TABLE_NAME');
  l_drop_these := '(';
  --Drop the table from the database
  If numNotUsedTables >  0 Then
    For i IN 0..numNotUsedTables - 1 LOOP
      writeTmp('Dropping unused table = '||arrNotUsedTables(i)||' '||get_time, FND_LOG.LEVEL_STATEMENT, true);
      bsc_metadata_optimizer_pkg.logProgress('MISC', 'Dropping unused table = '||arrNotUsedTables(i));
      DropTable(arrNotUsedTables(i));
      IF (numNotUsedTables>l_drop_threshold) THEN
        null;
      ELSE
        l_drop_these := l_drop_these|| ''''||arrNotUsedTables(i)||''''||',';
      END IF;
    END LOOP;
    IF (numNotUsedTables>l_drop_threshold) THEN
      Add_Value_Bulk(1, arrNotUsedTables);
    END IF;
    --Delete tables from BSC metadata
    --BSC_DB_TABLES

    IF (numNotUsedTables>l_drop_threshold) THEN
      writeTmp('Deleting entries from BSC_DB_TABLES '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_TABLES');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_TABLES WHERE '||strWhereInCondition;
      writeTmp('Deleting entries from BSC_DB_TABLES_RELS '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_TABLES_RELS');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_TABLES_RELS WHERE '|| strWhereInCondition;
      writeTmp('Deleting entries from BSC_DB_TABLES_COLS '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_TABLES_COLS');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_TABLES_COLS WHERE '|| strWhereInCondition;
      writeTmp('Deleting entries from BSC_DB_CALCULATIONS '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_CALCULATIONS');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_CALCULATIONS WHERE '|| strWhereInCondition;
    ELSE
      l_drop_these := substr(l_drop_these, 1, length(l_drop_these)-1)||')';
      writeTmp('Deleting entries from BSC_DB_TABLES '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_TABLES');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_TABLES WHERE table_name IN '||l_drop_these;
      writeTmp('Deleting entries from BSC_DB_TABLES_RELS '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_TABLES_RELS');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_TABLES_RELS WHERE table_name IN '||l_drop_these;
      writeTmp('Deleting entries from BSC_DB_TABLES_COLS '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_TABLES_COLS');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_TABLES_COLS WHERE table_name IN '||l_drop_these;
      writeTmp('Deleting entries from BSC_DB_CALCULATIONS '||get_time);
      bsc_metadata_optimizer_pkg.logProgress('CLEANUP', 'Deleting entries from BSC_DB_CALCULATIONS');
      EXECUTE IMMEDIATE ' DELETE FROM BSC_DB_CALCULATIONS WHERE table_name IN '||l_drop_these;
    END IF;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Deleted invalid entries from metadata tables '||get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  -- If the system is in summary tables mode, then bsc_kpi_properties.implementation_type should be 1
  -- clean up any corruption caused by foll. case
  -- System in in Summary tables. User changes MV level to 2. User sets KPI as AW impl.
  -- Then user changes MV level to null (note that he may have NOT run database generator)
  IF (BSC_METADATA_OPTIMIZER_PKG.g_BSC_mv=false) THEN
    UPDATE BSC_KPI_PROPERTIES set property_value = 1 where property_code = BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Updated kpi_properties '||get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  --DropTable(BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table );
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_period_circ_check);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_filtered_indics);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_kpi_tmp_table);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_db_tables_last);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_db_table_rels_last);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_kpi_data_last);
  DropTable(BSC_METADATA_OPTIMIZER_PKG.g_db_tables_cols_last);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Dropped temp tables '||get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  OPEN cDropThese;
  LOOP
    FETCH cDropThese INTO l_table_name, l_owner;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('After fetching cursor time is '||get_time, FND_LOG.LEVEL_PROCEDURE);
    END IF;
    EXIT WHEN cDropThese%NOTFOUND;
    IF (l_owner = BSC_METADATA_OPTIMIZER_PKG.gAppsSchema) THEN -- table in apps schema
      execute immediate 'drop table '||l_table_name;
    ELSE
      DropTable(l_table_name);
    END IF;
    BSC_MO_HELPER_PKG.writeTmp('Dropped left over table '||l_table_name||' '||get_time, FND_LOG.LEVEL_STATEMENT, false);
  END LOOP;
  CLOSE cDropThese;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed cleanDatabase '||get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    writeTmp('Exception in cleanDatabase:'||sqlerrm,  FND_LOG.LEVEL_UNEXPECTED, true);
    raise;
End;


-- Stack to store the last 150 * 2000 characters of the log file
PROCEDURE write_to_stack(msg IN VARCHAR2) IS
l_msg_length number;
BEGIN
  IF msg IS NULL THEN
    return;
  END IF;

  l_msg_length := length(msg);
  IF (g_stack_length + l_msg_length > 2000) THEN
    g_stack_index := g_stack_index + 1;
    g_stack_length := 0;
  END IF;
  IF g_stack_length <> 0 THEN
    g_stack(g_stack_index) := g_stack(g_stack_index) ||newline||msg;
  ELSE
    g_stack(g_stack_index) := msg;
  END IF;
  g_stack_length := g_stack_length + g_newline_length+l_msg_length;
  IF (g_stack.count > 150) THEN
    g_stack.delete(g_stack.first);
  END IF;
  EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'Exception in write_to_stack:'||sqlerrm);
      fnd_file.put_line(FND_FILE.LOG, 'Stack length='||length(g_stack(g_stack_index)));
      fnd_file.put_line(FND_FILE.LOG, 'g_stack_length='||g_stack_length);
      fnd_file.put_line(FND_FILE.LOG, 'length(msg) = '||length(msg));
	  fnd_file.put_line(FND_FILE.LOG, 'msg = '||msg);
      raise;
END;

PROCEDURE dump_stack IS
l_msg VARCHAR2(2000);
l_chunk VARCHAR2(256);
l_varchar2_table DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  fnd_file.put_line(FND_FILE.LOG, ' ');
  BSC_MO_HELPER_PKG.TerminateWithMsg( 'Dumping stack contents ');
  fnd_file.put_line(FND_FILE.LOG, '-------------START OF STACK CONTENTS------------ ');
  IF g_stack.count = 0 THEN
    return;
  END IF;
  FOR i IN g_stack.first..g_stack.last LOOP
    l_msg := g_stack(i);
    --fnd_file.put_line(FND_FILE.LOG, g_stack(i));
    IF length(l_msg) <=256 THEN
      fnd_file.put_line(FND_FILE.LOG, l_msg);
    ELSE
      l_varchar2_table := bsc_dbgen_utils.get_char_chunks(l_msg, 256);
      FOR j in l_varchar2_table.first..l_varchar2_table.last LOOP
        fnd_file.put_line(FND_FILE.LOG, l_varchar2_table(j));
      END LOOP;
    END IF;
  END LOOP;
  fnd_file.put_line(FND_FILE.LOG, '-------------END OF STACK CONTENTS--------------- ');
END;


PROCEDURE write_debug (
  msg IN VARCHAR2,
  pSeverity IN NUMBER DEFAULT NULL) IS
  l_severity NUMBER;
BEGIN

  IF pSeverity IS NULL THEN
    l_severity := FND_LOG.LEVEL_STATEMENT;
  ELSE
    l_severity := pSeverity;
  END IF;
  if( l_severity >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(l_severity, 'bsc.pma.opt.optimize', msg);
  end if;
  EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'Exception in write_debug:'||sqlerrm);
      raise;
END;


PROCEDURE writeTmp (
  msg IN VARCHAR2,
  pSeverity IN NUMBER DEFAULT NULL,
  pForce IN boolean default false)
  IS

  l_msg VARCHAR2(32767);
  l_chunk VARCHAR2(4000);
  l_severity NUMBER;
  l_force_logging boolean := false;
  l_varchar2_table DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  IF (msg is null) THEN
    return;
  END IF;
  IF (pForce is null) then
    l_force_logging := false;
  ELSE
    l_force_logging := pForce;
  END IF;
  IF (pSeverity IS NULL) THEN
    l_severity := FND_LOG.LEVEL_STATEMENT;
  ELSE
    l_severity := pSeverity;
  END IF;
  IF (l_force_logging=false) THEN
    IF (NOT BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
      write_to_stack(msg);
      write_debug(msg);
      return;
    END IF;
    IF (l_severity < BSC_METADATA_OPTIMIZER_PKG.g_log_level) THEN
      write_to_stack(msg);
      write_debug(msg);
      return;
    END IF;
  END IF;
  bsc_metadata_optimizer_pkg.gSequence := bsc_metadata_optimizer_pkg.gSequence  +1 ;
  l_msg := substr(msg, 1, 32767);
  IF (l_msg IS NULL) THEN
    l_msg := ' ';
  END IF;
  IF (l_msg like 'Completed %' OR l_msg like 'Compl %' OR l_msg like 'Compl. %') THEN
      bsc_metadata_optimizer_pkg.gIndent := substr(bsc_metadata_optimizer_pkg.gIndent,
              1, length(bsc_metadata_optimizer_pkg.gIndent) - length(bsc_metadata_optimizer_pkg.gSpacing));
  END IF;

  IF (NOT BSC_METADATA_OPTIMIZER_PKG.g_fileOpened) THEN
      BSC_METADATA_OPTIMIZER_PKG.g_dir:=fnd_profile.value('UTL_FILE_LOG');
      BSC_METADATA_OPTIMIZER_PKG.g_dir := null;
      IF BSC_METADATA_OPTIMIZER_PKG.g_dir is null THEN
        BSC_METADATA_OPTIMIZER_PKG.g_dir:=BSC_METADATA_OPTIMIZER_PKG.getUtlFileDir;
      END IF;
      fnd_file.put_names(BSC_METADATA_OPTIMIZER_PKG.g_filename||'.log', BSC_METADATA_OPTIMIZER_PKG.g_filename||'.out', BSC_METADATA_OPTIMIZER_PKG.g_dir);
      BSC_METADATA_OPTIMIZER_PKG.g_file := utl_file.fopen(BSC_METADATA_OPTIMIZER_PKG.g_dir, 'METADATA.log' ,'w');
      BSC_METADATA_OPTIMIZER_PKG.g_fileOpened := true;
  END IF;
  IF (length(l_msg) <=256) THEN
    fnd_file.put_line(FND_FILE.LOG, bsc_metadata_optimizer_pkg.gIndent||l_msg);
  ELSE
    l_varchar2_table := bsc_dbgen_utils.get_char_chunks(l_msg, 256);
    FOR i IN l_varchar2_table.first..l_varchar2_table.last LOOP
      fnd_file.put_line(FND_FILE.LOG, bsc_metadata_optimizer_pkg.gIndent||l_varchar2_table(i));
    END LOOP;
  END IF;
  IF (l_msg like 'Inside%') THEN
      bsc_metadata_optimizer_pkg.gIndent := bsc_metadata_optimizer_pkg.gIndent || bsc_metadata_optimizer_pkg.gSpacing;
  END IF;
  IF length(bsc_metadata_optimizer_pkg.gIndent) > 256 THEN
      bsc_metadata_optimizer_pkg.gIndent := substr(bsc_metadata_optimizer_pkg.gIndent, 1, 64);
  END IF;
  EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'Exception in writeTmp:'||sqlerrm);
      raise;
END;


PROCEDURE UpdateFlags IS
l_stmt VARCHAR2(300);
i NUMBER;
l_index NUMBER;
BEGIN

  BSC_MO_HELPER_PKG.writeTmp('Inside UpdateFlags '||get_time, FND_LOG.LEVEL_PROCEDURE, true);

  IF  (BSC_METADATA_OPTIMIZER_PKG.gIndicators.count>0) THEN
      i := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
  END IF;
  LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gIndicators.count = 0;

      IF (BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag=2) THEN
        --Case 2
          DELETE FROM BSC_KPIS_B WHERE INDICATOR = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          DELETE FROM BSC_KPIS_TL WHERE INDICATOR = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).code;
          DELETE FROM BSC_KPI_DATA_TABLES WHERE INDICATOR = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).code;
          writeTmp('Deleting entries for indicator='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code||', old value='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag, FND_LOG.LEVEL_STATEMENT, false);
      ELSIF (BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag=1 OR BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag=3) THEN
        --Case 1, 3
          UPDATE BSC_KPIS_B SET PROTOTYPE_FLAG = 0,
                  LAST_UPDATED_BY = BSC_METADATA_OPTIMIZER_PKG.gUserId,
                  LAST_UPDATE_DATE = SYSDATE
                  WHERE INDICATOR = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          -- Color By KPI: Mark KPIs to Production mode in tendem with Objective's prototype flag.
          -- This is done so that both Objective and underlying KPIs come with the same color in IViewer,
          -- once GDB is run for the Objective. i.e. DARK_GRAY color
	  UPDATE bsc_kpi_analysis_measures_b
	    SET prototype_flag = 0
            WHERE indicator = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          --Execute IMMEDIATE l_stmt USING BSC_METADATA_OPTIMIZER_PKG.gUserId, BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          writeTmp('Updating prototype_flag=0 for indicator='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code||' from old value='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag, FND_LOG.LEVEL_STATEMENT, false);
      ELSIF (BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag=4) THEN
        --Case 4
          UPDATE BSC_KPIS_B SET PROTOTYPE_FLAG = 6,
                  LAST_UPDATED_BY = BSC_METADATA_OPTIMIZER_PKG.gUserId,
                  LAST_UPDATE_DATE = SYSDATE
                  WHERE INDICATOR = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          -- Color By KPI: Mark KPIs for color re-calculation
	  UPDATE bsc_kpi_analysis_measures_b
	    SET prototype_flag = 7
            WHERE indicator = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          --Execute IMMEDIATE l_stmt USING BSC_METADATA_OPTIMIZER_PKG.gUserId, BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
          writeTmp('Updating prototype_flag=6 for indicator='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code||' from old value='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag, FND_LOG.LEVEL_STATEMENT, false);
      ELSE
        --BSC_MV Note: If summarizarion level changed then update prototype flag to 6
          If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0 Then
              UPDATE BSC_KPIS_B SET PROTOTYPE_FLAG = 6,
                      LAST_UPDATED_BY = BSC_METADATA_OPTIMIZER_PKG.gUserId,
                      LAST_UPDATE_DATE = SYSDATE
                      WHERE INDICATOR = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
              -- Color By KPI: Mark KPIs for color re-calculation
	      UPDATE bsc_kpi_analysis_measures_b
	        SET prototype_flag = 7
                WHERE indicator = BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code;
              writeTmp('Updating prototype_flag=6 for indicator='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Code||' from old value='||BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag, FND_LOG.LEVEL_STATEMENT, false);
          END IF;
      END IF;
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
      i := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(i);
  END LOOP;

  --BSC-PMF Integration: Update ALL PMF measures to production mode
  -- no need
  /*UPDATE BSC_KPI_ANALYSIS_MEASURES_B
          SET PROTOTYPE_FLAG = 0
          WHERE DATASET_ID IN (
          SELECT DATASET_ID FROM BSC_SYS_DATASETS_B
          WHERE NVL(SOURCE, 'BSC') = 'PMF')
		  AND INDICATOR IN (SELECT INDICATOR FROM BSC_TMP_OPT_UI_KPIS WHERE process_id = BSC_METADATA_OPTIMIZER_PKG.g_processID);*/

  WriteInitTable('SYSTEM_STAGE', '2');

  --BSC-MV Note: Store new summarization level into BSC_SYS_INIT
  If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
      WriteInitTable('ADV_SUM_LEVEL', BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level);
  End If;


  --Update range_yr_mod in BSC_SYS_CALENDARS_B
  UPDATE BSC_SYS_CALENDARS_B SET RANGE_YR_MOD = 0;


  IF BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 2 THEN
      DropAppsTables;
  End IF;
  execute immediate 'delete bsc_tmp_opt_ui_kpis where process_id=:1' using BSC_METADATA_OPTIMIZER_PKG.g_processID;

  BSC_MO_HELPER_PKG.writeTmp('Completed UpdateFlags'||get_time, FND_LOG.LEVEL_PROCEDURE, true);
  EXCEPTION WHEN OTHERS THEN
      writeTmp('Exception in UpdateFlags:'||sqlerrm,  FND_LOG.LEVEL_UNEXPECTED, true);
      raise;

END;


/*
FUNCTION getOneKeyField(table_name IN VARCHAR2, key_name IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.clsKeyField IS

CURSOR cKey IS
SELECT key_name, Origin, Need_zero_code, Calc_zero_code,
Filter_View_Name, dim_index
from BSC_TMP_OPT_KEY_COLS
WHERE
table_name = table_name
and key_name = key_name;

keyfield BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
cv   CurTyp;
l_start_time date := sysdate;
l_needsCode0 NUMBER := 0;
l_calcCode0 NUMBER := 0;

BEGIN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  writeTmp('Inside getOneKeyField');
   END IF;


  BSC_METADATA_OPTIMIZER_PKG.ggetOneKeyField := BSC_METADATA_OPTIMIZER_PKG.ggetOneKeyField +1;

  IF (mod(BSC_METADATA_OPTIMIZER_PKG.ggetOneKeyField, 500) = 0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Call # '||BSC_METADATA_OPTIMIZER_PKG.ggetOneKeyField||' to API getOneKeyField');
   END IF;

  END IF;


  OPEN cKey;
  FETCH cKey INTO keyField.keyName, keyField.origin,
  l_needsCode0, l_calcCode0,
  keyField.FilterViewName, keyField.dimIndex;
  CLOSE cKey;
   IF (l_needsCode0 = 1) THEN
   keyField.needsCode0 := true;
   ELSE
   keyField.needsCode0 := false;
   END IF;

   IF (l_calcCode0 = 1) THEN
   keyField.calculateCode0 := true;
   ELSE
   keyField.calculateCode0 := false;
   END IF;

   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  writeTmp('Completed getOneKeyField');
   END IF;

  BSC_METADATA_OPTIMIZER_PKG.g_time_getOneKeyField := BSC_METADATA_OPTIMIZER_PKG.g_time_getOneKeyField + (sysdate-l_start_time) * 86400;
  return keyfield;
END;

FUNCTION getAllKeyFields(pTableName IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField IS

keyfield BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
keyFields BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
cv   CurTyp;
l_needsCode0 NUMBER;
l_calcCode0 NUMBER;

CURSOR cKeys IS SELECT key_name, Origin, Need_zero_code, Calc_zero_code,
Filter_View_Name, dim_index from BSC_TMP_OPT_KEY_COLS WHERE table_name = pTableName
order by seqnum;

cKeysRow cKeys%ROWTYPE;
l_error VARCHAR2(1000);
l_start_time date := sysdate;
BEGIN


  BSC_METADATA_OPTIMIZER_PKG.ggetAllKeyFields := BSC_METADATA_OPTIMIZER_PKG.ggetAllKeyFields +1;

  IF (mod(BSC_METADATA_OPTIMIZER_PKG.ggetAllKeyFields, 1000) = 0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Call # '||BSC_METADATA_OPTIMIZER_PKG.ggetAllKeyFields||' to API getAllKeyFields');
   END IF;

  END IF;

	OPEN cKeys;
	LOOP
		FETCH cKeys INTO cKeysRow;
		EXIT WHEN cKeys%NOTFOUND;
		keyField.keyName :=  cKeysRow.key_name;
		keyField.origin := cKeysRow.Origin;
		keyField.filterViewName := cKeysRow.Filter_View_Name;
      keyField.dimIndex := cKeysRow.dim_index;

		IF (cKeysRow.need_zero_code = 0) THEN
	        keyField.needsCode0 := false;
      ELSE
	        keyField.needsCode0 := true;
	  END IF;

      IF (cKeysRow.calc_zero_code = 0) THEN
	        keyField.calculateCode0 := false;
      ELSE
	        keyField.calculateCode0 := true;
	  END IF;
		keyFields(keyFields.count) := keyField;
	END LOOP;
	CLOSE cKeys;
  BSC_METADATA_OPTIMIZER_PKG.g_time_getAllKeyFields := BSC_METADATA_OPTIMIZER_PKG.g_time_getAllKeyFields + (sysdate - l_start_time) * 86400;
  return keyFields;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in getAllKeyFields for table='||pTableName||' : '||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      raise;

END;


FUNCTION getOneDataField(table_name IN VARCHAR2, field_name IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.clsDataField IS
CURSOR cData IS
SELECT
  field_name, aggfunction, origin, avglflag, avgltotalcolumn, avglcountercolumn,
  Internal_Column_Type, Internal_Column_Source
from BSC_TMP_OPT_DATA_COLS
WHERE
table_name = table_name
and upper(field_name) = upper(field_name);

dataField BSC_METADATA_OPTIMIZER_PKG.clsDataField;
cv   CurTyp;
l_error VARCHAR2(1000);
l_start_time date := sysdate;
BEGIN
  BSC_METADATA_OPTIMIZER_PKG.ggetOneDataField := BSC_METADATA_OPTIMIZER_PKG.ggetOneDataField +1;

  IF (mod(BSC_METADATA_OPTIMIZER_PKG.ggetOneDataField, 500) = 0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Call # '||BSC_METADATA_OPTIMIZER_PKG.ggetOneDataField||' to API ggetOneDataField');
   END IF;

  END IF;



   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  writeTmp('Inside getOneDataField');
   END IF;

  OPEN cData;
  FETCH cData INTO dataField.fieldName, dataField.aggFunction, dataField.origin, dataField.avglFlag,
      dataField.avglTotalColumn, dataField.avglCounterColumn, dataField.internalColumnType, dataField.internalColumnSource;
  CLOSE cData;
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  writeTmp('Completed getOneDataField');
   END IF;



  BSC_METADATA_OPTIMIZER_PKG.g_time_updateOneDisagg := BSC_METADATA_OPTIMIZER_PKG.g_time_updateOneDisagg + (sysdate - l_start_time) * 86400;
  return dataField;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception in getOneDataField for table='||table_name||', field = '||field_name||' : '||l_error, FND_LOG.LEVEL_UNEXPECTED, true);
      raise;
END;

FUNCTION getAllDataFields(pTableName IN VARCHAR2) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField IS

dataFields BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
dataField BSC_METADATA_OPTIMIZER_PKG.clsDataField;
cv   CurTyp;

cursor cData is
SELECT field_name, aggfunction, origin, avglflag, avgltotalcolumn, avglcountercolumn,
      Internal_Column_Type, Internal_Column_Source
from BSC_TMP_OPT_DATA_COLS WHERE
table_name = pTableName
order by seqnum;
cDataRow cData%ROWTYPE;
l_error varchar2(1000);

l_start_time date := sysdate;
BEGIN
  BSC_METADATA_OPTIMIZER_PKG.ggetAllDataFields := BSC_METADATA_OPTIMIZER_PKG.ggetAllDataFields +1;

  IF (mod(BSC_METADATA_OPTIMIZER_PKG.ggetAllDataFields, 1000) = 0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Call # '||BSC_METADATA_OPTIMIZER_PKG.ggetAllDataFields||' to API getAllDataFields');
   END IF;

  END IF;

	OPEN cData;
	LOOP
		FETCH cData INTO cDataRow;
		EXIT WHEN cData%NOTFOUND;
		dataField.fieldName := cDataRow.field_name;
		dataField.aggFunction := cDataRow.aggFunction;
		dataField.origin := cDataRow.origin;
		dataField.avglFlag := cDataRow.avglflag;
	      dataField.avglTotalColumn := cDataRow.avgltotalcolumn;
		dataField.avglCounterColumn:= cDataRow.avglcountercolumn;
		dataField.internalColumnType := cDataRow.Internal_Column_Type;
		dataField.internalColumnSource := cDataRow.Internal_Column_Source;
		dataFields(dataFields.count) := dataField;
	END LOOP;
	CLOSE cData;

  BSC_METADATA_OPTIMIZER_PKG.g_time_getAllDataFields := BSC_METADATA_OPTIMIZER_PKG.g_time_getAllDataFields + (sysdate - l_start_time) * 86400;
  return dataFields;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      writeTmp('Exception getAllDataFields for table_name ='||pTableName||' : '||l_error, fnd_log.LEVEL_UNEXPECTED, true);
      raise;
END;
*/

FUNCTION getGroupIds (levels IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels) RETURN DBMS_SQL.NUMBER_TABLE IS
l_groups DBMS_SQL.NUMBER_TABLE;
l_count NUMBER := 0;
i NUMBER;
BEGIN
  i := levels.first;
  LOOP
      EXIT WHEN levels.count=0;
      IF (BSC_MO_HELPER_PKG.findIndex(l_groups, levels(i).group_id) = -1 ) THEN -- new entry
        l_groups(l_count) := levels(i).group_id;
        l_count := l_count+1;
      END IF;
      EXIT WHEN i = levels.last;
      i := levels.next(i);
  END LOOP;
  return l_groups;
END;

FUNCTION getGroupIds (levels IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations) RETURN DBMS_SQL.NUMBER_TABLE IS
l_groups DBMS_SQL.NUMBER_TABLE;
l_count NUMBER := 0;
i NUMBER;
BEGIN
  i := levels.first;
  LOOP
      EXIT WHEN levels.count=0;
      IF (BSC_MO_HELPER_PKG.findIndex(l_groups, levels(i).group_id) = -1 ) THEN -- new entry
        l_groups(l_count) := levels(i).group_id;
        l_count := l_count+1;
      END IF;
      EXIT WHEN i = levels.last;
      i := levels.next(i);
  END LOOP;
  return l_groups;
END;

FUNCTION get_tab_clsLevels (Coll IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels, group_id IN NUMBER)
RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels IS
l_levels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels ;
l_lvl BSC_METADATA_OPTIMIZER_PKG.clsLevels;
l_counter NUMBER;
BEGIN
  IF (Coll.count=0) THEN
      return l_levels;
  END IF;

  l_counter := Coll.first;
  LOOP
      IF (Coll(l_counter).group_id = group_id) THEN -- add this record to the list
        l_lvl.keyName := Coll(l_counter).keyName;
        l_lvl.dimTable := Coll(l_counter).dimTable;
        l_lvl.Num := Coll(l_counter).Num;
        l_lvl.Name := Coll(l_counter).Name;
        l_lvl.TargetLevel := Coll(l_counter).TargetLevel;
        l_lvl.Parents1N := Coll(l_counter).Parents1N;
        l_lvl.ParentsMN := Coll(l_counter).ParentsMN;

        l_levels(l_levels.count) := l_lvl;
      END IF;
      EXIT WHEN l_counter  = Coll.last;
      l_counter := Coll.next(l_counter);
  END LOOP;
  return l_levels;
END;


FUNCTION get_tab_clsLevelCombinations (Coll IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations, group_id IN NUMBER)
RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations IS
l_levelCombinations BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations ;
l_lvl BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations;
l_counter NUMBER;
BEGIN
  IF (Coll.count=0) THEN
      return l_levelCombinations;
  END IF;

  l_counter := Coll.first;
  LOOP
      IF (Coll(l_counter).group_id = group_id) THEN -- add this record to the list
        l_lvl.levels := Coll(l_counter).levels;
        l_lvl.LevelConfig := Coll(l_counter).levelConfig;
        l_levelCombinations(l_levelCombinations.count) := l_lvl;
      END IF;
      EXIT WHEN l_counter = Coll.last;
      l_counter := Coll.next(l_counter);
  END LOOP;
  return l_levelCombinations;
END;



PROCEDURE add_tabrec_clsLevelComb(
  pInput IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations,
  l_group_id IN NUMBER)  IS
l_tabrec BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevelCombinations;
i NUMBER;
BEGIN
  IF (pTable.count = 0) THEN
      return;
  END IF;
  i := pTable.first;

  LOOP
      l_tabrec.group_id := l_group_id;
      l_tabrec.levels := pTable(i).levels;
      l_tabrec.levelConfig := pTable(i).levelConfig;
      IF (pInput.count = 0) THEN
        pInput(0) := l_tabrec;
      ELSE
        pInput(pInput.last+1) := l_tabrec;
      END IF;

      EXIT WHEN i = pTable.last;
      i := pTable.next(i);
  END LOOP;
END;

PROCEDURE add_tabrec_clsLevels(
  pInput IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
  pTable IN BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels,
  l_group_id IN NUMBER) IS
l_tabrec BSC_METADATA_OPTIMIZER_PKG.tabrec_clsLevels;
i NUMBER;
BEGIN
  IF (pTable.count = 0) THEN
      return;
  END IF;

  i := pTable.first;
  LOOP
      l_tabrec.group_id := l_group_id;
      l_tabrec.keyname := pTable(i).keyname;
      l_tabrec.dimTable := pTable(i).dimTable;
      l_tabrec.Num := pTable(i).Num;
      l_tabrec.Name := pTable(i).Name;
      l_tabrec.TargetLevel := pTable(i).targetLevel;
      l_tabrec.Parents1N := pTable(i).Parents1N;
      l_tabrec.ParentsMN := pTable(i).ParentsMN;
      IF (pInput.count = 0) THEN
        pInput(0) := l_tabrec;
      ELSE
        pInput(pInput.last+1) := l_tabrec;
      END IF;
      EXIT WHEN i = pTable.last;
      i := pTable.next(i);
  END LOOP;

END;

-- Opposite of decompose
-- Given a VARCHAR2_TABLE, this API will return a comma separated string

FUNCTION consolidateString (pTable IN DBMS_SQL.VARCHAR2_TABLE, pSeparator IN VARCHAR2) RETURN VARCHAR2 IS
l_return VARCHAR2(32000) := null;
l_count NUMBER;
BEGIN

  BSC_METADATA_OPTIMIZER_PKG.gconsolidateString := BSC_METADATA_OPTIMIZER_PKG.gconsolidateString +1;

  IF (mod(BSC_METADATA_OPTIMIZER_PKG.gconsolidateString, 500) = 0) THEN
   IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      writeTmp('Call # '||BSC_METADATA_OPTIMIZER_PKG.gconsolidateString||' to API consolidateString');
   END IF;

  END IF;


  IF (pTable.count=0) THEN
      return null;
  END IF;
  l_count := pTable.first;

  LOOP
      IF (l_return IS NOT NULL) THEN
        l_return := l_return || pSeparator;
      END IF;
      l_return := l_return ||pTable(l_count);
      EXIT WHEN l_count = pTable.last;
      l_count := pTable.next(l_count);
  END LOOP;
  return l_return;
END;

PROCEDURE terminateWithError(pErrorShortName IN VARCHAR2, pAPI IN VARCHAR2 default null) IS
l_error VARCHAR2(1000);
BEGIN


	fnd_message.set_name('BSC', pErrorShortName);
  l_error := fnd_message.get;
  BSC_METADATA_OPTIMIZER_PKG.logProgress('ERROR', pAPI||' '||l_error);
  FND_FILE.put_line(FND_FILE.log, 'Exception '||pAPI||' : '||l_error);
  --fnd_file.release_names(bsc_metadata_optimizer_pkg.g_filename||'.log', bsc_metadata_optimizer_pkg.g_filename||'.out');
	fnd_message.set_name('BSC', pErrorShortName);
	BSC_METADATA_OPTIMIZER_PKG.g_retcode := 2;
	BSC_METADATA_OPTIMIZER_PKG.g_errbuf := l_error;

END;

PROCEDURE terminateWithMsg(pMessage IN VARCHAR2, pAPI in varchar2 default null)
IS
BEGIN

   BSC_METADATA_OPTIMIZER_PKG.logProgress('ERROR', pAPI||' '||pMessage);
   FND_FILE.put_line(FND_FILE.log, ' -------------------');
   FND_FILE.put_line(FND_FILE.log, ' ERROR ');
   FND_FILE.put_line(FND_FILE.log, ' -------------------');
   FND_FILE.put_line(FND_FILE.log, pMessage);
   BSC_METADATA_OPTIMIZER_PKG.g_retcode := 2;
   BSC_METADATA_OPTIMIZER_PKG.g_errbuf := pMessage;
END;

PROCEDURE writeKeysTest IS
BEGIN
  null;
END;


PROCEDURE InitializeMasterTables IS
l_stmt varchar2(1000);
cv   CurTyp;
cursor c1 is
SELECT S.DIM_LEVEL_ID, S.LEVEL_TABLE_NAME, S.TABLE_TYPE, S.source,
        S.LEVEL_PK_COL, S.USER_KEY_SIZE, S.DISP_KEY_SIZE, NVL(S.EDW_FLAG, 0) AS EDW_FLAG, R.SOURCE_TABLE_NAME
        FROM BSC_SYS_DIM_LEVELS_B S, BSC_DB_TABLES_RELS R
      WHERE S.LEVEL_TABLE_NAME  = R.TABLE_NAME (+)
      ORDER BY LEVEL_TABLE_NAME;
cRow1 c1%ROWTYPE;

l_count_master NUMBER := 0;
masterTable BSC_METADATA_OPTIMIZER_PKG.clsMasterTable;
parents_rel_col    VARCHAR2(32000);--tab_clsParent;
parents_name       VARCHAR2(32000);--tab_clsParent;
l_count_parents NUMBER := 0;
auxillaryField VARCHAR2(32000);--tab_clsAuxillaryField;
l_count_aux NUMBER := 0;


cursor C2 (p_dimID IN NUMBER, p_relation_type number)is
  SELECT D.LEVEL_TABLE_NAME, D.LEVEL_PK_COL
  FROM BSC_SYS_DIM_LEVELS_B D, BSC_SYS_DIM_LEVEL_RELS R
  WHERE D.DIM_LEVEL_ID = R.PARENT_DIM_LEVEL_ID
  AND R.DIM_LEVEL_ID =  p_dimID
  AND R.RELATION_TYPE = p_relation_type;

cRow2 c2%ROWTYPE;

RelMN BSC_METADATA_OPTIMIZER_PKG.clsRelationMN;

cursor C3 (p_dim_level_id IN NUMBER) IS
  SELECT COLUMN_NAME
  FROM BSC_SYS_DIM_LEVEL_COLS
  WHERE DIM_LEVEL_ID = p_DIM_LEVEL_ID
  AND UPPER(COLUMN_TYPE) = 'A';

cRow3 c3%ROWTYPE;

cursor c4 is
  SELECT DISTINCT D.RELATION_COL, T.SOURCE_TABLE_NAME
  FROM BSC_SYS_DIM_LEVEL_RELS D, BSC_DB_TABLES_RELS T
  WHERE D.RELATION_TYPE = 2 AND D.RELATION_COL = T.TABLE_NAME (+);

cRow4 c4%ROWTYPE;

cursor c5 (pRelation VARCHAR2) is
  SELECT A.LEVEL_TABLE_NAME AS TABLE_A,
  A.LEVEL_PK_COL AS PK_COL_A,
  B.LEVEL_TABLE_NAME AS TABLE_B,
  B.LEVEL_PK_COL AS PK_COL_B
  FROM BSC_SYS_DIM_LEVELS_B A,
       BSC_SYS_DIM_LEVEL_RELS R,
       BSC_SYS_DIM_LEVELS_B B
  WHERE
      A.DIM_LEVEL_ID = R.DIM_LEVEL_ID AND
      R.PARENT_DIM_LEVEL_ID = B.DIM_LEVEL_ID AND
      UPPER(R.RELATION_COL) = upper(pRelation);

cRow5 c5%ROWTYPE;



BEGIN
  bsc_mo_helper_pkg.writeTmp('Inside InitializeMasterTables', FND_LOG.LEVEL_PROCEDURE, false);
  OPEN c1;
  LOOP
    FETCH c1 INTO cRow1;
    EXIT when c1%NOTFOUND;
    masterTable := bsc_mo_helper_pkg.new_clsMasterTable;
    masterTable.Name := cRow1.LEVEL_TABLE_NAME;
    masterTable.keyName := cRow1.LEVEL_PK_COL;
    IF (cRow1.Table_TYPE = 1) THEN
      masterTable.userTable := true;
    ELSE
      masterTable.userTable := false;
    END IF;
    masterTable.EDW_Flag := cRow1.EDW_FLAG;
    masterTable.InputTable := CRow1.SOURCE_TABLE_NAME;
    masterTable.source := cRow1.source;
    parents_name := null; -- comma separated
    parents_rel_col := null; -- comma separated
    Open c2 (cRow1.DIM_LEVEL_ID, 1);
    LOOP
      FETCH c2 into cRow2;
      EXIT WHEN c2%NOTFOUND;
      IF (parents_name IS NOT NULL) THEN
        parents_name := parents_name || ',';
      END IF;
      parents_name := parents_name|| nvl(cRow2.LEVEL_TABLE_NAME, ' ');
      parents_rel_col := parents_rel_col||nvl(cRow2.LEVEL_PK_COL, ' ');
    END LOOP;
    CLOSE c2;
    masterTable.parent_name := parents_name;
    masterTable.parent_rel_col := parents_rel_col;
    auxillaryField := null;
    IF masterTable.Source = 'BSC' THEN
      Open c3(cRow1.DIM_LEVEL_ID);
      LOOP
      	FETCH c3 into cRow3;
      	EXIT WHEN c3%NOTFOUND;
        IF (auxillaryField IS NOT NULL) THEN
          auxillaryField := auxillaryField || ',';
        END IF;
      	auxillaryField := auxillaryField||cRow3.COLUMN_NAME;
      END LOOP;
      CLOSE c3;
    END IF;
    masterTable.auxillaryFields := auxillaryField;
    bsc_metadata_optimizer_pkg.gMasterTable(bsc_metadata_optimizer_pkg.gMasterTable.count) := masterTable;
    l_count_master := l_count_master + 1;
  END LOOP;
  CLOSE c1;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Starting MN ');--commit;
  END IF;
  --gRelacionesMN
  --EDW Note: There are no M-N Relations in EDW
  --BSC-PMF Integration: There are no M-N Relations in PMF
  OPEN c4;
  LOOP
    FETCH c4 into cRow4;
	EXIT WHEN c4%NOTFOUND;
    RelMN.TableRel := cRow4.RELATION_COL;
    If (cRow4.SOURCE_TABLE_NAME IS NOT NULL) Then
      RelMN.InputTable := cRow4.SOURCE_TABLE_NAME;
    Else
      RelMN.InputTable := null;
    End If;
  	OPEN c5(cRow4.Relation_col);
    FETCH C5 INTO cRow5;
    RelMN.TableA := cRow5.TABLE_A;
    RelMN.keyNameA := cRow5.PK_COL_A;
    RelMN.TableB := cRow5.TABLE_B;
    RelMN.keyNameB := cRow5.PK_COL_B;
    BSC_METADATA_OPTIMIZER_PKG.gRelationsMN(bsc_metadata_optimizer_pkg.gRelationsMN.count):= RelMN;
    CLOSE C5;
  END Loop;
  CLOSE c4;
  bsc_mo_helper_pkg.writeTmp('Completed InitializeMasterTables', FND_LOG.LEVEL_PROCEDURE, false);
  Exception when others then
  bsc_mo_helper_pkg.writeTmp('exception in InitializeMasterTables', FND_LOG.LEVEL_UNEXPECTED, true);
  bsc_mo_helper_pkg.writeTmp('gMasterTables are ', FND_LOG.LEVEL_EXCEPTION, true);
  bsc_mo_helper_pkg.write_this(bsc_metadata_optimizer_pkg.gMasterTable, FND_LOG.LEVEL_EXCEPTION, true);
	raise;

END;


--consider only production objectives
FUNCTION aw_objective_exists return boolean is
l_count number;
begin
  select count(1) into l_count
    from bsc_kpi_properties p
       , bsc_kpis_vl k
   where p.indicator=k.indicator
     and p.property_code=bsc_metadata_optimizer_pkg.impl_type
     and p.property_value = 2
         -- only production objectives
     and k.prototype_flag not in (1,2,3,4)
      ;
  if (l_count>0) then
    return true;
  else
    return false;
  end if;
end;

PROCEDURE load_reporting_calendars IS

l_lud_stmt varchar2(1000):= 'select last_update_date
from bsc_reporting_calendar
where calendar_id=:1 and rownum=1';

cursor cCalendars is
select calendar_id, last_update_date
from bsc_sys_calendars_b;

l_option_string varchar2(100);
l_error_message varchar2(4000);

l_dropped_aw_objectives dbms_sql.varchar2_table;
l_rpt_lud date;

cv CurTyp;

BEGIN
  writeTmp('In bsc_mo_helper_pkg.load_reporting_calendars '||get_time);
  IF BSC_METADATA_OPTIMIZER_PKG.g_bsc_mv THEN
    writeTmp('going to loop for calendars');
    FOR i IN cCalendars LOOP
      open cv for l_lud_stmt using i.calendar_id;
      fetch cv into l_rpt_lud;
      close cv;
      writeTmp('LUD for sys calendar '||i.calendar_id ||':'||to_char(i.last_update_date, 'mm/dd/yy hh24:mi:ss')||
        ' and rpt calendar:'||to_char( l_rpt_lud, 'mm/dd/yy hh24:mi:ss' ));
      -- IF last update date in rpt cal is not null, then check if its > calendar's last update date
      -- IF rpt lud is null, it hasnt been refreshed even once, so refresh
      IF (l_rpt_lud is not null and l_rpt_lud>=i.last_update_date) then
        null;
      ELSE
        writeTmp('Attempting to refresh Calendar id '||i.calendar_id ||
          ' changed, calling load reporting calendar for this:'||get_time);
        IF NOT BSC_BIA_WRAPPER.Load_Reporting_Calendar(i.calendar_id, l_error_message) THEN
          writeTmp('Error Loading reporting calendar :'||l_error_message, FND_LOG.LEVEL_UNEXPECTED, true);
          BSC_MO_HELPER_PKG.TerminateWithMsg(l_error_message);
          raise BSC_METADATA_OPTIMIZER_PKG.optimizer_exception;
        END IF;
        writeTmp('Done refreshing Calendar id '||i.calendar_id ||' '||get_time);
        -- AW_INTEGRATION: Call aw api to import calendar into aw world
        -- Fix bug#4360037: load calendar into aw only if there are aw indicators
        IF aw_objective_exists THEN
          if (bsc_metadata_optimizer_pkg.g_log) then
            l_option_string := 'DEBUG LOG';
          end if;
          bsc_aw_calendar.create_calendar
                (    i.calendar_id
                   , l_option_string
                 );
          bsc_aw_calendar.load_calendar(
                     p_calendar => i.calendar_id,
                     p_options => l_option_string
                 );
        END IF;
      END IF;
    END LOOP;
  END IF;
END;

PROCEDURE implement_aws (p_objectives in dbms_Sql.varchar2_table) IS

BEGIN
  bsc_aw_adapter.implement_kpi_aw(
                  p_objectives,
                  'DEBUG LOG,RECREATE KPI,SUMMARIZATION LEVEL=1000');
END;

/*BUG FIX 5647971
  this function added so any future change in naming convention of index does not impact code much
  we will have one place to change the code
  this function can be flexibly extended for other tyype of tables as well
  currently this is written for B tables indexes only*/
FUNCTION generate_index_name(p_table_name IN VARCHAR2,
                      p_table_type IN VARCHAR2,p_index_type IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  IF (p_table_type = 'B') THEN
    RETURN p_table_name||'_N' || p_index_type;
  END IF;
END;

END BSC_MO_HELPER_PKG;

/
