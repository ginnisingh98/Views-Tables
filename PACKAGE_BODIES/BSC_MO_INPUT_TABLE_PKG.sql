--------------------------------------------------------
--  DDL for Package Body BSC_MO_INPUT_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_INPUT_TABLE_PKG" AS
/* $Header: BSCMOIPB.pls 120.28 2006/04/19 16:29:18 arsantha noship $ */
g_newline VARCHAR2(10):= '
';


FUNCTION get_measure_group(p_field_name IN VARCHAR2, p_source IN VARCHAR2) return NUMBER IS
cursor cMeasureGroup  IS
select measure_group_id from bsc_db_measure_cols_vl
where measure_col = p_field_name;
--and measure_type = 0;
l_measure_group number;
l_temp number;
BEGIN
  l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, p_field_name, p_source, false);
  l_measure_group := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode;
  return l_measure_group;
END;


FUNCTION get_measures_for_table(p_table_pattern in varchar2) return  BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField IS
l_stmt varchar2(1000):='SELECT distinct column_Name, source
 FROM bsc_db_tables_cols
 WHERE column_type = :1
   AND table_name like :2
   AND column_name not like :3';
cv CurTyp;
l_measure_col VARCHAR2(320);
l_source VARCHAR2(100);
l_datafield BSC_METADATA_OPTIMIZER_PKG.clsDataField;
l_data  BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
BEGIN
  OPEN cv FOR l_stmt using 'A', p_table_pattern, 'BSCIC%';
  LOOP
    FETCH cv INTO l_measure_col, l_source;
    EXIT WHEN cv%NOTFOUND;
    l_datafield.fieldName := l_measure_col;
    l_datafield.source := l_source;
    l_data(l_data.count+1) := l_datafield;
  END LOOP;
  CLOSE cv;
  return l_data;
   EXCEPTION WHEN OTHERS THEN
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in get_measures_for_table:'||sqlerrm);
  raise;
END;

FUNCTION get_measure_group(p_table IN VARCHAR2, p_data IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField, p_indicator NUMBER, p_dim_set NUMBER) return NUMBER IS

l_obj_measures BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
l_table_measures  BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
cursor cMeasureGroup(p_measure VARCHAR2) IS
select measure_group_id from bsc_db_measure_cols_vl
where measure_col = p_measure
and measure_type = 0;
l_measure_group number;
BEGIN
  l_measure_group := -99999;
  IF (p_data.count =0) then
    return l_measure_group;
  END IF;
  l_obj_measures := get_measures_for_table('BSC_S_'||p_indicator||'_'||p_dim_set||'%');
  bsc_mo_helper_pkg.writeTmp('# of measures in BSC_S_'||p_indicator||'_'||p_dim_set ||'% is '||l_obj_measures.count||', # in p_data='||p_data.count);

  FOR i IN p_data.first..p_data.last LOOP
    FOR j IN 1..l_obj_measures.count LOOP
      IF (p_data(i).fieldName = l_obj_measures(j).fieldName AND
          p_data(i).source = l_obj_measures(j).source) THEN
        return get_measure_group(p_data(i).fieldName, p_data(i).source);
      END IF;
    END LOOP;
  END LOOP;
  return l_measure_group;
  EXCEPTION WHEN OTHERS THEN
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in get_measure_group:'||sqlerrm);
  raise;
END;


PROCEDURE set_origin_table_from_db(KpiTable IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.clsTable) IS
  TableName VARCHAR2(100);
  SourceTableName VARCHAR2(100);
  TablaOri VARCHAR2(1000);
  l_stmt VARCHAR2(1000);
  lstKeys VARCHAR2(1000);
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_index NUMBER;
  l_counter NUMBER;
  cv   CurTyp;
  KpiTableName VARCHAR2(100);
  l_error VARCHAR2(1000);
  CURSOR cTable(l_src IN VARCHAR2, l_tbl IN VARCHAR2) IS
  SELECT table_name  FROM bsc_db_tables_rels
  WHERE source_table_name = l_src  AND table_name LIKE l_tbl;

  CURSOR cColumns(l_table IN VARCHAR2, l_column IN VARCHAR2, l_column_type IN VARCHAR2)  IS
  SELECT source_column  FROM bsc_db_tables_cols
  WHERE table_name = l_table AND UPPER(column_name) = l_column AND column_type = l_column_type;

BEGIN

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('set_origin_table_from_db for table='||KpiTable.name);
  END IF;
  l_index := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, KpiTable.Indicator);
  If BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index).OptimizationMode = 0 Then
    --The indicator is pre-calculated.
    TableName := 'BSC_S_' || KpiTable.Indicator || '_' || KpiTable.Configuration || '%';
    If KpiTable.keys.Count = 0 Then
      l_stmt := 'SELECT DISTINCT r.source_table_name FROM bsc_db_tables_rels r, bsc_db_tables t
                WHERE r.table_name LIKE  :1  AND
                NOT r.source_table_name LIKE :2  AND
                r.table_name = t.table_name AND
                t.periodicity_id = :3 AND
                r.relation_type = 0';
    Else
      lstKeys := null;
      l_counter := KpiTable.keys.first;
      LOOP
        EXIT WHEN KpiTable.keys.count = 0;
        l_key := KpiTable.keys(l_counter);
        If lstKeys IS NOT NULL Then
          lstKeys := lstKeys || ',';
        End If;
        lstKeys := lstKeys || ''''|| l_key.keyName ||'''';
        EXIT WHEN l_counter = KpiTable.keys.last;
        l_counter := KpiTable.keys.next(l_counter);
      END LOOP;
      l_stmt := 'SELECT DISTINCT table_name AS SOURCE_TABLE_NAME
                FROM bsc_db_tables_cols
                WHERE table_name IN (
                SELECT r.source_table_name
                FROM bsc_db_tables_rels r, bsc_db_tables t
                WHERE r.table_name LIKE :1 AND
                NOT r.source_table_name LIKE :2 AND
                r.table_name = t.table_name AND
                t.periodicity_id = :3 AND
                r.relation_type = 0 ) AND
                column_name IN (' || lstKeys || ') AND
                column_type = ''P''
                GROUP BY table_name
                HAVING COUNT(column_name) = ' || KpiTable.keys.Count;
    END IF;
  ELSE
    --The indicator is not pre-calculated
    If KpiTable.IsTargetTable Then
      TableName := 'BSC_SB_' || KpiTable.Indicator || '_' || KpiTable.Configuration || '%';
    Else
      TableName := 'BSC_S_' || KpiTable.Indicator || '_' || KpiTable.Configuration || '%';
    End If;
    l_stmt := 'SELECT DISTINCT r.source_table_name
          FROM bsc_db_tables_rels r, bsc_db_tables t
          WHERE r.table_name LIKE :1 AND
          NOT r.source_table_name LIKE :2 AND
          r.table_name = t.table_name AND
          t.periodicity_id = :3 AND r.relation_type = 0';
  End If;

  OPEN cv FOR l_stmt using TableName,TableName, KpiTable.Periodicity;
  LOOP
    FETCH cv INTO SourceTableName;
    EXIT WHEN cv%NOTFOUND;
    --Add the table to the collection of origin tables of the table
    IF (KpiTable.originTable IS NOT NULL) THEN
      KpiTable.originTable := KpiTable.originTable ||',';
    END IF;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('1. Adding Origin table for '||KpiTable.name||' = '||SourceTableName);
	END IF;
    KpiTable.originTable := KpiTable.originTable ||SourceTableName;
    --Add the table to the gloabel array garrTablesUpgrade
    If Not bsc_mo_helper_pkg.searchStringExists(
              bsc_metadata_optimizer_pkg.garrTablesUpgradeT,
              bsc_metadata_optimizer_pkg.gnumTablesUpgradeT,
              SourceTableName) Then
      bsc_metadata_optimizer_pkg.garrTablesUpgradeT(bsc_metadata_optimizer_pkg.gnumTablesUpgradeT) := SourceTableName;
      bsc_metadata_optimizer_pkg.gnumTablesUpgradeT := bsc_metadata_optimizer_pkg.gnumTablesUpgradeT + 1;
    End If;
  END LOOP;
  Close cv;
  --Bug#3340878 Need to set the source key column of the table
  --Get the name of the table previous to the upgrade. Remember that the name of
  --the table was changed from BSC_S_3001_0_12345_5 to BSC_S_3001_0_0_5
  OPEN cTable(SourceTableName, TableName);
  FETCH cTable INTO KpiTableName;
  Close cTable;
  l_counter := KpiTable.keys.first;
  LOOP
    EXIT WHEN KpiTable.keys.count = 0;
    l_key := KpiTable.keys(l_counter);
    OPEN cColumns (KpiTableName, UPPER(l_key.keyName), 'P');
    FETCH cColumns INTO l_key.origin;
    close cColumns;
    KpiTable.keys(l_counter) := l_key ;
    EXIT WHEN l_counter = KpiTable.keys.last;
    l_counter := KpiTable.keys.next(l_counter);
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in set_origin_table_from_db : '||l_error);
    raise;
End ;

PROCEDURE load_upgrade_tables_db IS
i NUMBEr;
l_stmt VARCHAR2(4000);
l_table bsc_metadata_optimizer_pkg.clsTable;
l_key bsc_metadata_optimizer_pkg.clsKeyField;
l_measure bsc_metadata_optimizer_pkg.clsDataField;
TablaOri VARCHAR2(4000);
Target_Flag NUMBER;
cv   CurTyp;
New_clsKeyField bsc_metadata_optimizer_pkg.clsKeyField;
New_clsDataField bsc_metadata_optimizer_pkg.clsDataField;
CURSOR cTable (pTable IN VARCHAR2) IS
SELECT TABLE_NAME, TABLE_TYPE, PERIODICITY_ID, EDW_FLAG, CURRENT_PERIOD, TARGET_FLAG
              FROM BSC_DB_TABLES
              WHERE TABLE_NAME = pTable;
cTableRow cTable%ROWTYPE;

CURSOR cCols (pTable IN VARCHAR2) IS
  SELECT COLUMN_TYPE, COLUMN_NAME, SOURCE_COLUMN, SOURCE_FORMULA
         --BSC Autogen
         , SOURCE
         , measure_group_id
    FROM BSC_DB_TABLES_COLS cols, bsc_db_measure_cols_vl dbcols
   WHERE cols.TABLE_NAME = pTable
     AND cols.column_name = dbcols.measure_col(+);
cColsRow cCols%ROWTYPE;

CURSOR cTableRels0(pTable IN VARCHAR2) IS
  SELECT SOURCE_TABLE_NAME
  FROM BSC_DB_TABLES_RELS
  WHERE TABLE_NAME = pTable
  AND RELATION_TYPE = 0
  ORDER BY SOURCE_TABLE_NAME;
cTableRels0Row cTableRels0%ROWTYPE;

CURSOR cTableRels1(pTable IN VARCHAR2) IS
SELECT SOURCE_TABLE_NAME
        FROM BSC_DB_TABLES_RELS
        WHERE TABLE_NAME = pTable
        AND RELATION_TYPE = 1
        ORDER BY SOURCE_TABLE_NAME;
cTableRels1Row cTableRels1%ROWTYPE;
l_error VARCHAR2(1000);
l_stack varchar2(32000);
l_table_null bsc_metadata_optimizer_pkg.clsTable;
BEGIN

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside load_upgrade_tables_db, upg tables = '||bsc_metadata_optimizer_pkg.gnumTablesUpgrade);
  END IF;

  For i IN 0..bsc_metadata_optimizer_pkg.gnumTablesUpgrade - 1 LOOP
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('');
      BSC_MO_HELPER_PKG.writeTmp('Processing table '||bsc_metadata_optimizer_pkg.garrTablesUpgrade(i));
    END IF;
    OPEN cTable(bsc_metadata_optimizer_pkg.garrTablesUpgrade(i));
    FETCH cTable INTO cTableRow;
    l_stack := l_stack || g_newline||'Step 1';
    If cTable%FOUND Then
      l_table := l_table_null;
      l_table.Name := cTableRow.TABLE_NAME;
      l_table.Type := cTableRow.TABLE_TYPE;
      l_table.Periodicity := cTableRow.PERIODICITY_ID;
      l_table.EDW_Flag := cTableRow.EDW_FLAG;
      l_stack := l_stack || g_newline||'Step 1.1';
      If cTableRow.TARGET_FLAG = 1 Then
        l_table.IsTargetTable := True;
      Else
        l_table.IsTargetTable := False;
      End If;
      l_stack := l_stack || g_newline||'Step 1.2';
      l_table.currentPeriod := cTableRow.CURRENT_PERIOD;
      l_stack := l_stack || g_newline||'Step 2';
      OPEN cCols(UPPER(l_table.name));
      l_stack := l_stack || g_newline||'Step 2.1';
      LOOP
        l_stack := l_stack || g_newline||'Step 2.2';
        FETCH cCols INTO cColsRow;
        EXIT WHEN cCols%NOTFOUND;
        l_stack := l_stack || g_newline||'Step 2.3';
        If UPPER(cColsRow.COLUMN_TYPE) = 'P' Then
          --Key column
          l_stack := l_stack || g_newline||'Step 2.4';
          l_key := New_clsKeyField;
          l_key.keyName := cColsRow.COLUMN_NAME;
          l_key.Origin := cColsRow.SOURCE_COLUMN;
          l_key.NeedsCode0 := False;
          l_key.CalculateCode0 := False;
          l_key.FilterViewName := null;
          l_table.keys(l_table.keys.count) :=  l_key;
          l_stack := l_stack || g_newline||'Step 2.5';
        Else
          --Data column
          l_stack := l_stack || g_newline||'Step 2.6';
          l_measure := New_clsDataField;
          l_measure.fieldName := cColsRow.COLUMN_NAME;
          l_measure.source := cColsRow.source;
          l_measure.measureGroup := cColsRow.measure_group_id;
          l_measure.Origin := cColsRow.SOURCE_FORMULA;
          l_measure.AggFunction := null;
          l_table.data(l_table.data.count) := l_measure;
          l_stack := l_stack || g_newline||'Step 2.7';
        End If;
      END Loop;
      Close cCols;
      l_stack := l_stack || g_newline||'Step 3';
      --Source tables (Hard Relations)
      OPEN cTableRels0 (UPPER(l_table.name));
      l_stack := l_stack || g_newline||'Step 3.1';
      LOOP
        FETCH cTableRels0 INTO cTableRels0Row;
        l_stack := l_stack || g_newline||'Step 3.2';
        EXIT WHEN cTableRels0%NOTFOUND;
        l_stack := l_stack || g_newline||'Step 3.3';
        IF (l_table.originTable IS NOT NULL) THEN
          l_table.originTable := l_table.originTable ||',';
        END IF;
        l_stack := l_stack || g_newline||'Step 3.4';
        l_table.originTable := l_table.originTable || cTableRels0Row.SOURCE_TABLE_NAME;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp('Adding Origin table '||cTableRels0Row.SOURCE_TABLE_NAME);
        END IF;
      END LOOP;
      Close cTableRels0;
      l_stack := l_stack || g_newline||'Step 4';
      --Source table (Soft Relations)
      OPEN cTableRels1(UPPER(l_table.Name));
      l_stack := l_stack || g_newline||'Step 4.1';
      LOOP
        FETCH cTableRels1 INTO cTableRels1Row;
        l_stack := l_stack || g_newline||'Step 4.2';
        EXIT WHEN cTableRels1%NOTFOUND;
        l_stack := l_stack || g_newline||'Step 4.3';
        IF (l_table.originTable IS NOT NULL) THEN
          l_table.originTable := l_table.originTable ||',';
        END IF;
        l_stack := l_stack || g_newline||'Step 4.4';
        l_stack := l_stack || g_newline||'Adding Origin table '||cTableRels1Row.SOURCE_TABLE_NAME;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp('Adding Origin table '||cTableRels1Row.SOURCE_TABLE_NAME);
        END IF;
        l_table.originTable := l_table.originTable || cTableRels1Row.SOURCE_TABLE_NAME;
      END LOOP;
      Close cTableRels1;
      --The tables in garrTablesUpgrade() are not used direclty by any indicator
      l_table.Indicator := 0;
      l_table.Configuration := 0;
      l_table.upgradeFlag := 1;
      --Add table to collection
      BSC_MO_HELPER_PKG.addTable(l_table, l_table.keys, l_table.data, 'load_upgrade_tables_db');
      --l_table_keys.delete;
      --l_table_measures.Delete;
      l_table := BSC_MO_HELPER_PKG.new_clsTable;
    End If;
    Close cTable;
    IF (length(l_stack) > 30000) THEN
      l_stack := null;
    END IF;
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed load_upgrade_tables_db');
  END IF;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in load_upgrade_tables_db : '||l_error, FND_LOG.LEVEL_UNEXPECTED);
      BSC_MO_HELPER_PKG.writeTmp('l_stack ='||l_stack, FND_LOG.LEVEL_UNEXPECTED, true);
      raise;
End ;


--****************************************************************************
--  TodasDesagsRegistradas
--
--  DESCRIPTION:
--     Returns TRUE if all the dissagregations in the given collection
--     have been registered
--
--  PARAMETERS:
--     p_key_combinations: dissagregations
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function all_key_comb_registered(p_key_combinations BSC_METADATA_OPTIMIZER_PKG.tab_clsDisaggField) return Boolean IS
key_combination BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
l_index NUMBER;
l_error VARCHAR2(1000);
BEGIN
  IF (p_key_combinations.count=0) THEN
      return true;
  END IF;
  l_index := p_key_combinations.first;
  LOOP
    key_combination := p_key_combinations(l_index);
    If Not key_combination.Registered Then
      return false;
    End If;
    EXIT WHEN l_index = p_key_combinations.last;
    l_index := p_key_combinations.next(l_index);
  END LOOP;
  return true;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in all_key_comb_registered : '||l_error, FND_LOG.LEVEL_UNEXPECTED);
    raise;
End;


--****************************************************************************
--  TableOriginExists
--
--  DESCRIPTION:
--     Return TRUE if the table exist in the collection. The collection
--     is of objects of type clsTablaOri
--
--  PARAMETERS:
--     p_table_origins: collection
--     p_table_name: table name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function TableOriginExists(p_table_origins IN VARCHAR2,
                p_table_name IN VARCHAR2) RETURN Boolean IS
  l_table VARCHAR2(100);
  l_count1 NUMBER;
  l_origins DBMS_SQL.VARCHAR2_TABLE;
  l_error VARCHAR2(1000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside TableOriginExists, key_combinations = ', FND_LOG.LEVEL_PROCEDURE);
    BSC_MO_HELPER_PKG.writeTmp(' Parameter p_table_name='||p_table_name
              ||', and p_table_origins is '||p_table_origins, FND_LOG.LEVEL_STATEMENT);
  END IF;
  l_origins := BSC_MO_HELPER_PKG.getDecomposedString(p_table_origins, ',');
  IF (l_origins.count = 0) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Completed TableOriginExists, returning false', FND_LOG.LEVEL_PROCEDURE);
    END IF;
    return false;
  END IF;
  l_count1 := l_origins.first;
  LOOP
    l_table := l_origins(l_count1);
    If UPPER(l_table) = UPPER(p_table_name) Then
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('Completed TableOriginExists, returning true', FND_LOG.LEVEL_PROCEDURE);
      END IF;
      return true;
    End If;
    EXIT WHEN l_count1= l_origins.last;
    l_count1 := l_origins.next(l_count1);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed TableOriginExists, returning false', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  return false;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in TableOriginExists : '||l_error);
    raise;
End ;
--****************************************************************************
--  IndexTablaTemporalMismaDesagyCodAgrupCampo : get_matching_tables
--
--  DESCRIPTION:
--     Returns the index on collection p_BTTables whose table
--     has the given periodicity and the given key columns and the first
--     data field of the temporal table has the given grouping code.
--     Returns -1 if it is not found.
--
--  PARAMETERS:
--     pPeriodicity: periodicity
--     keyCols: key columns
--     dataFieldGroup: grouping code of the data fields
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function get_matching_tables(
      p_measure_col IN VARCHAR2,
      --BSC Autogen
      p_measure_source IN VARCHAR2,
      pPeriodicity IN NUMBER,
      p_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
      dataFieldGroup IN NUMBER,
      p_impl_type IN NUMBER,
      p_BTTables IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_ClsTable) RETURN DBMS_SQL.NUMBER_TABLE IS
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  keysEqual Boolean;
  i Integer;
  toBeConsidered Boolean;
  l_return NUMBER := 0;
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_temp NUMBER;
  l_error VARCHAR2(1000);
  l_return_table DBMS_SQL.NUMBER_TABLE ;
BEGIN
  IF (p_BTTables.count = 0) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Done with get_matching_tables, returning -1', FND_LOG.LEVEL_PROCEDURE);
    END IF;
    return l_return_table;
  END IF;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Within get_matching_tables, measure='||p_measure_col||', source='||p_measure_source||', Periodicity = '||pPeriodicity||', dataFieldGroup ='||dataFieldGroup||', impl_type='||p_impl_type);
  END IF;
  i := p_BTTables.first;
  LOOP
    toBeConsidered := True;

    If p_BTTables(i).Data.Count > 0 Then
      l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov,
                                            p_BTTables(i).Data(0).fieldName,
                                            p_BTTables(i).Data(0).source);
      If BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode <> dataFieldGroup
        -- BSC AW
	     OR (p_BTTables(i).impl_type <> p_impl_type)
	    --BSC Autogen
        -- If new table(not production table), column shouldnt already exist
	     OR (p_BTTables(i).isProductionTable=false AND BSC_MO_INDICATOR_PKG.DataFieldExists(p_BTTables(i).Data, p_measure_col) )
	  Then
        toBeConsidered := False;
      End If;
    Else
       toBeConsidered := false;
    End If;
    If toBeConsidered Then
      If p_BTTables(i).Periodicity = pPeriodicity Then
        If p_BTTables(i).keys.Count = p_keys.Count Then
          keysEqual := True;
          l_index1 := p_BTTables(i).keys.first;
          LOOP
            EXIT WHEN p_BTTables(i).keys.count=0;
            l_key := p_BTTables(i).keys(l_index1);
            If Not BSC_MO_INDICATOR_PKG.keyFieldExists(p_keys, l_key.keyName) Then
              keysEqual := False;
              Exit ;
            Else
              l_temp := BSC_MO_HELPER_PKG.findIndex(p_keys, l_key.keyName);
              If UPPER(l_key.FilterViewName) <> UPPER(p_keys(l_temp).FilterViewName) Then
                keysEqual := False;
                Exit ;
              End If;
            End If;
            EXIT WHEN l_index1 = p_BTTables(i).keys.last;
            l_index1 := p_BTTables(i).keys.next(l_index1);
          END LOOP;
          If keysEqual Then -- see if this is a production table, and if so, if the column exists
            IF (p_BTTables(i).isProductionTable) THEN
              -- we can add a production table as a match ONLY if the column NAME doesnt exist
              IF BSC_MO_INDICATOR_PKG.DataFieldExists(p_BTTables(i).Data, p_measure_col)=true AND
                 BSC_MO_INDICATOR_PKG.DataFieldExistsforSource(p_BTTables(i).Data, p_measure_col, p_measure_source)=false  THEN
                null;
              ELSE
                l_return_table(l_return_table.count) := i;
                bsc_mo_helper_pkg.writeTmp('Adding table '||p_BTTables(i).name);
              END IF;
            ELSE
              l_return_table(l_return_table.count) := i;
              bsc_mo_helper_pkg.writeTmp('Adding table '||p_BTTables(i).name);
            END IF;
          End If;
        End If;
      End If;
    End If;
    EXIT WHEN i = p_BTTables.last;
    i := p_BTTables.next(i);
  END LOOP;
  return l_return_table;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in get_matching_tables : '||l_error, FND_LOG.LEVEL_UNEXPECTED);
    IF (l_temp=-1) THEN
      BSC_MO_HELPER_PKG.writeTmp('Measure '||p_BTTables(i).Data(0).fieldName||', source=' ||p_BTTables(i).Data(0).source||' does not exist in the list of measures in bsc_sys_measures.', FND_LOG.LEVEL_STATEMENT, true);
    END IF;
    raise;
End ;

--****************************************************************************
--  getMaxTableIndex : MaximoIndiceTablas
--
--    DESCRIPTION:
--       Look for tables whose name start with the given word in BSC_DB_TABLES
--       From those tables whose name end with a number, this function return
--       the maximun number.
--       Example. startsWith = 'T_'
--            In BSC_DB_TABLES exists the following tables that start with 'T_':
--            'T_1', 'T_A', 'T_2' and 'T_3'. This function return 3
--
--    PARAMETERS:
--       startsWith: Word by which the table name start.
--
--   AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function getMaxTableIndex(startsWith IN VARCHAR2) return NUMBER IS
  l_max  NUMBER := 0;
  cv   CurTyp;
  l_startsWith VARCHAR2(100);
  cursor cTables(pStart IN VARCHAR2) IS
  SELECT table_name from bsc_db_tables
  where table_name like pStart;


  l_str_len number := 0;

  l_error VARCHAR2(2000);
  l_table varchar2(100);
BEGIN

  l_startsWith := startsWith;
  l_max := 0;
  IF (instr(l_startsWith, '%') = 0) THEN
      l_startsWith := l_startsWith||'%';
      l_str_len := length(startsWith) ;
  ELSE
      l_str_len := length(startsWith)-1 ;
  END IF;


  OPEN cTables(l_startsWith);
  LOOP
      FETCH cTables INTO l_table;
      EXIT WHEN CTables%NOTFOUND;
      l_table := substr(l_table, l_str_len +1);

      BEGIN
        If to_number(l_table) > l_max Then
          l_max := to_number(l_table);
        End If;
        EXCEPTION WHEN OTHERS THEN -- not a number
          null;
      END ;
  END Loop;
  close cTables;
  IF (l_max IS NULL) THEN
      l_max := 0;
  END IF;

  return l_max;

  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in getMaxTableIndex :  '||l_error);
      raise;

End;



--****************************************************************************
--  HacerTablasEyConectarATablasBasicas : connect_i_to_b_tables
--
--  DESCRIPTION:
--     Make input tables and connect to the base tables
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE connect_i_to_b_tables IS
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  TablaE BSC_METADATA_OPTIMIZER_PKG.clsTable;

  Tabla_Origin DBMS_SQL.VARCHAR2_TABLE;

  TablaE_Origin DBMS_SQL.VARCHAR2_TABLE;

  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_keyE BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  l_measureE BSC_METADATA_OPTIMIZER_PKG.clsDataField;

  l_table_origin VARCHAR2(100);
  l_index1 NUMBER;
  l_index2 NUMBER;

  l_error VARCHAR2(1000);
  l_table_null BSC_METADATA_OPTIMIZER_PKG.clsTable;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside connect_i_to_b_tables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count=0) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Completed connect_i_to_b_tables, gTables.count was 0', FND_LOG.LEVEL_PROCEDURE);
    END IF;
    return;
  END IF;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
  LOOP
    l_table := l_Table_null;
    l_table := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
    IF (l_table.isProductionTable) THEN
      goto ignore;
    END IF;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('');
      BSC_MO_HELPER_PKG.writeTmp('Processing table gTables('||l_index1||
                        ') : '||l_table.name, FND_LOG.LEVEL_STATEMENT);
    END IF;
    Tabla_Origin.delete;
    Tabla_Origin := BSC_MO_HELPER_PKG.getDecomposedString(l_table.originTable, ',');
    --For tables with no origin (base tables)
    If Tabla_origin.Count = 0 And l_table.Type <> 0 Then
      TablaE := bsc_mo_helper_pkg.new_clsTable;
      TablaE.Name := 'BSC_I_' ||( BSC_METADATA_OPTIMIZER_PKG.gMaxI + 1);
      BSC_METADATA_OPTIMIZER_PKG.gMaxI := BSC_METADATA_OPTIMIZER_PKG.gMaxI + 1;
      TablaE.Type := 0;
      TablaE.Periodicity := l_table.Periodicity;
      TablaE.EDW_Flag := l_table.EDW_Flag;
      TablaE.IsTargetTable := l_table.IsTargetTable;
      TablaE.impl_type := l_table.impl_type;

      --Key columns
      IF (l_table.keys.count>0)THEN
        l_index2 := l_table.keys.first;
        LOOP
          l_keyE := bsc_mo_helper_pkg.new_clskeyfield;
          l_keyE  := l_table.keys(l_index2);
          TablaE.keys(TablaE.keys.count) := l_keyE;
          l_table.keys(L_INDEX2).Origin := l_table.keys(L_INDEX2).keyName;
          EXIT WHEN l_index2 = l_table.keys.last;
          l_index2 := l_table.keys.next(l_index2);
        END LOOP;
        --l_table.keys := l_table_keys;
      END IF;
      --Data columns
      IF (l_table.data.count>0) THEN
        l_index2 := l_table.data.first;
        LOOP
          l_measureE := bsc_mo_helper_pkg.new_clsDataField;
          l_measure := l_table.data(l_index2);
          l_measureE.fieldName := l_measure.fieldName;
          l_measureE.source := l_measure.source;
          l_measureE.measureGroup := l_measure.measureGroup;
          l_measureE.aggFunction := l_measure.aggFunction;
          --Note: other properties for internal columns are not used in input tables
          TablaE.Data(TablaE.Data.count) := l_measureE;
          EXIT WHEN l_index2 = l_table.data.last;
          l_index2 := l_table.data.next(l_index2);
        END LOOP;
      END IF;
      BSC_MO_HELPER_PKG.addTable(TablaE, TablaE.keys, TablaE.Data, 'connect_i_to_b_tables');
      l_table_origin := TablaE.Name;
      IF (l_table.originTable IS NOT NULL ) THEN
        l_table.originTable := l_table.originTable||',';
      END IF;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('2. Adding Origin table for '||l_table.name||' = '||l_table_origin);
      END IF;
      l_table.originTable := l_table.originTable||l_table_origin;
    End If;
    BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1) := l_table;
 <<ignore>>
    EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed connect_i_to_b_tables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in connect_i_to_b_tables : '||l_error, FND_LOG.LEVEL_UNEXPECTED);
    raise;
End;
--****************************************************************************
--  add_to_gtables: AdicTablasTempATablasSistema
--
--    DESCRIPTION:
--       Add each table of the collection g_bt_tables to the collection
--       gTablas.
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE add_to_gtables(p_tables IN BSC_METADATA_OPTIMIZER_PKG.tab_clsTable) IS
  TablaTemp BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_keyTemp BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_measureTemp BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  l_index1 NUMBER;
  l_index2 NUMBER;

  l_error VARCHAR2(1000);
BEGIN

  IF (p_tables.count =0) THEN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Done with add_to_gtables, p_tables.count=0',
        FND_LOG.LEVEL_PROCEDURE);
	END IF;
    return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside add_to_gtables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  l_index1 := p_tables.first;
  LOOP
    BSC_MO_HELPER_PKG.addTable(p_tables(l_index1), 'add_to_gtables');
    EXIT WHEN l_index1 = p_tables.last;
    l_index1 := p_tables.next(l_index1);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed add_to_gtables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in add_to_gtables : '||l_error);
    raise;
End;


--****************************************************************************
--  get_origin_table: GetNombreTablaTempOri
--
--    DESCRIPTION:
--       Return the name of the tempral table where the given field is found,
--       for the specified dissagregation and periodicity.
--       It look in the collection p_tables.
--       Note: By design, we know that it will be found.
--
--    PARAMETERS:
--       pPeriodicity: periodicity
--       Llaves: dissagregation
--       NombreCampo: field name
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function get_origin_table(
                pPeriodicity IN NUMBER,
                keys IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
                fieldName IN VARCHAR2,
                p_source IN VARCHAR2,
                p_measure_group IN OUT NOCOPY NUMBER,
		p_impl_type IN NUMBER,
                p_tables IN BSC_METADATA_OPTIMIZER_PKG.tab_clsTable) return VARCHAR2 IS
  L_Table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  keysEqual Boolean;
  l_return VARCHAR2(300);
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_index3 NUMBER;
  l_measure_index   NUMBER;
  l_start_time date := sysdate;
  l_error VARCHAR2(1000);
  l_temp number;
  l_measure_group number;
BEGIN
  IF (p_tables.count=0) THEN
    return null;
  END IF;
  if (p_measure_group is null) then
    p_measure_group := get_measure_group(fieldName, p_source);
  end if;
  l_measure_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, fieldName, p_source);
  l_measure_group := BSC_METADATA_OPTIMIZER_PKG.gLov(l_measure_index).groupCode;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside get_origin_table, pPeriodicity='||pPeriodicity
        ||', fieldName ='||fieldName||', source='||p_source||', measure_group='||p_measure_group||',  p_impl_type='||p_impl_type||', p_tables.count = '||
        p_tables.count, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  l_index1 := p_tables.first;

  LOOP
    L_Table := p_tables(l_index1);
    IF BSC_MO_INDICATOR_PKG.DataFieldExistsForSource(L_Table.Data, fieldName, p_source) AND
       L_Table.impl_type = p_impl_type AND
       nvl(l_table.measureGroup, -1) = nvl(p_measure_group, -1) THEN
      If L_Table.Periodicity = pPeriodicity THEN
        If L_Table.keys.Count = keys.Count THEN
          keysEqual := True;
          l_index2 := L_Table.keys.first;
          LOOP
            EXIT WHEN L_Table.keys.count = 0;
            l_key := L_Table.keys(l_index2);
            If Not BSC_MO_INDICATOR_PKG.keyFieldExists(keys, l_key.keyName) Then
              keysEqual := False;
            Else
              l_temp := BSC_MO_HELPER_PKG.findIndex(keys, l_key.keyName);
              If UPPER(l_key.FilterViewName) <> UPPER(keys(l_temp).FilterViewName) Then
                keysEqual := False;
                Exit ;
              End If;
            End If;
            EXIT WHEN l_index2 = L_Table.keys.last;
            l_index2 := L_Table.keys.next(l_index2);
          END LOOP;
          If keysEqual Then
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              BSC_MO_HELPER_PKG.writeTmp('Compl get_origin_table, returning '||
                                L_Table.Name, FND_LOG.LEVEL_PROCEDURE);
              BSC_MO_HELPER_PKG.writeTmp('Elapsed time (secs) '||
                                (sysdate-l_start_time)*86400, FND_LOG.LEVEL_STATEMENT);
            END IF;
            return L_Table.Name;
          End If;
        End If;
      End If;
    End If;
    EXIT WHEN l_index1 = p_tables.last;
    l_index1 := p_tables.next(l_index1);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Compl get_origin_table, returning null', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  return null;

  EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in get_origin_table : '||l_error);
        raise;
End ;
--****************************************************************************
--  ConectarTablasIndicadoresConTemporales : connect_s_to_b_tables
--
--    DESCRIPTION:
--       Connect the base tables of the indicators with the temporal tables.
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE connect_s_to_b_tables IS
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_table_origin VARCHAR2(100);
  Tabla_originTable DBMS_SQL.VARCHAR2_TABLE;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  l_origin_table VARCHAR2(300);
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_index3 NUMBER;
  l_temp NUMBER;

  l_start_time date := sysdate;
  l_end date;
  l_error VARCHAR2(1000);

BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside connect_s_to_b_tables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
    BSC_MO_HELPER_PKG.writeTmp('System time is '||to_char(sysdate, 'hh24:mi:ss'), FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count=0) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Compl connect_s_to_b_tables, gTables.count was 0', FND_LOG.LEVEL_PROCEDURE);
    END IF;
    return;
  END IF;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
  LOOP
    l_table := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
    Tabla_originTable.delete;
    Tabla_originTable := BSC_MO_HELPER_PKG.getDecomposedString(l_table.originTable, ',');
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('');
      BSC_MO_HELPER_PKG.writeTmp('Processing table '||l_index1||' '||
                    l_table.name||', System time is '||bsc_mo_helper_pkg.get_time,
                    FND_LOG.LEVEL_STATEMENT);
      BSC_MO_HELPER_PKG.writeTmp('------------------------------------------------');
    END IF;
    --Only consider tables with no origin
    If Tabla_OriginTable.Count = 0 Then
      --Key columns
      --For each key assign the origin key name with the same key name
      IF l_table.keys.count >0 THEN
        FOR l_index2 IN l_table.keys.first..l_table.keys.last LOOP
          l_table.keys(l_index2).Origin := l_table.keys(l_index2).keyName;
         END LOOP;
      END IF;
      IF (l_table.data.count>0) THEN
        FOR l_index2 IN l_table.data.first..l_table.data.last LOOP
          l_measure := l_table.data(l_index2);
          If l_measure.InternalColumnType = 0 Then
            --Do not see internal columns. They are not in base or temporal tables
            l_temp := BSC_MO_HELPER_PKG.findIndex(  BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_table.Indicator);
            If BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_temp).OptimizationMode <> 0 Then
              --non pre-calculated
              If l_table.IsTargetTable Then
                l_origin_table := get_origin_table(
		                    l_table.Periodicity,
                                    l_table.keys,
                                    l_measure.fieldName,
                                    l_measure.source,
                                    l_measure.measureGroup,
                                    l_table.impl_type,
                                    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt);
              Else
                l_origin_table := get_origin_table(
			            l_table.Periodicity,
                                    l_table.keys,
                                    l_measure.fieldName,
                                    l_measure.source,
                                    l_measure.measureGroup,
                                    l_table.impl_type,
                                    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables);
              End If;
            Else
              --pre-calculated
              l_origin_table := get_origin_table(
			          l_table.Periodicity,
                                  l_table.keys,
                                  l_measure.fieldName,
                                  l_measure.source,
                                  l_measure.MeasureGroup,
                                  l_table.impl_type,
                                  BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc);
            End If;
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              BSC_MO_HELPER_PKG.writeTmp('10. Origin = '||l_origin_table, FND_LOG.LEVEL_STATEMENT);
            END IF;
            IF (l_origin_table is null) THEN
               BSC_MO_HELPER_PKG.writeTmp('ERROR:connect_s_to_b_tables: Unable to find source table for '||
                 l_table.name||'.'||l_measure.fieldName, FND_LOG.LEVEL_EXCEPTION, true);
               raise bsc_metadata_optimizer_pkg.optimizer_exception;
            END IF;
            --In the Indicator tables l_measure.Origen was already set
            --TablasOri
            If Not TableOriginExists(l_table.originTable, l_origin_table) Then
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('11. Table does not have source ', FND_LOG.LEVEL_STATEMENT);
              END IF;
              l_table_origin := l_origin_table;
              IF (l_table.originTable IS NOT NULL) THEN
                l_table.originTable := l_table.originTable||',';
              END IF;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp('3. Adding Origin table for '||l_table.name||' = '||l_table_origin);
              END IF;
              l_table.originTable := l_table.originTable||l_table_origin;
            End If;
          End If;
        END LOOP;
      END IF;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Origin count for gTables('||l_index1||') was zero, reassigning this table ');
      END IF;
      BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1) := l_table;
    End If;

    EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
  END LOOP;
  l_end := sysdate;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Elapsed time (secs) '||(l_end-l_start_time)*86400, FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed connect_s_to_b_tables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in connect_s_to_b_tables : '||l_error);
        raise;
End ;


--****************************************************************************
--  InicListaTablasTemporalesyBasicasPreCalc : deduce_bt_tables_precalc
--
--    DESCRIPTION:
--       Initialize the collection g_bt_tables
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE deduce_bt_tables_precalc IS
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  uniqueField BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
  l_key_combination BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  iMatchingTableIndex DBMS_SQL.number_table;
  l_datafield BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  needNewTable Boolean;
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_index3 NUMBER;
  l_temp NUMBER;

  --l_key_combination_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  l_error VARCHAR2(1000);
  l_loop_Ctr NUMBER;
BEGIN

  IF ( BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.count=0) THEN
    return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp(g_newline||g_newline||g_newline);
    BSC_MO_HELPER_PKG.writeTmp('Inside deduce_bt_tables_precalc, # of precalc measures = '||BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.count||', system time is '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.first;

  LOOP
    uniqueField := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_index1);
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Looping for pre calc field = '||    uniqueField.fieldName||', has '||
             uniqueField.key_combinations.count||' disaggs ');
      bsc_mo_helper_pkg.write_this(g_unique, uniqueField);
	END IF;
    --Until all disagregations of the unique field are registered
    IF NOT all_key_comb_registered(uniqueField.key_combinations)  THEN
      FOR l_index2 IN uniqueField.key_combinations.first..uniqueField.key_combinations.last
      LOOP
        l_key_combination := uniqueField.key_combinations(l_index2);
        bsc_mo_helper_pkg.writeTmp('Processing key combination '||l_index2);
        IF (l_key_combination.registered=false) THEN
          l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, uniqueField.fieldName, uniqueField.source);
          iMatchingTableIndex := get_matching_tables(
                               uniqueField.fieldName,
                               uniqueField.source,
	                       l_key_combination.Periodicity,
                               l_key_combination.keys,
                               BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode,
                               uniqueField.impl_type,
                               BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc);
          If iMatchingTableIndex.count = 0 Then
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              BSC_MO_HELPER_PKG.writeTmp(' No existing temporal table with the same periodicity and disagregation');
       	    END IF;
            --There was not found an existing temporal table with the same periodicity and disagregation
            --and filter and whose fields can be grouped with this field
            l_table := bsc_mo_helper_pkg.new_clsTable;
            l_table.Name := 'BSC_B_'||( BSC_METADATA_OPTIMIZER_PKG.gMaxB + 1);
            BSC_METADATA_OPTIMIZER_PKG.gMaxB := BSC_METADATA_OPTIMIZER_PKG.gMaxB + 1;
            l_table.Type := 1;
            l_table.Periodicity := l_key_combination.Periodicity;
            l_table.EDW_Flag := uniqueField.EDW_Flag;
            l_table.IsTargetTable := False;
            l_table.impl_type := uniqueField.impl_type;
            l_table.keys := l_key_combination.keys;
            l_table.measureGroup := get_measure_group(uniqueField.fieldname, uniqueField.source);
            --Data columns
            --It is initialized with only with the this field
            l_datafield := bsc_mo_helper_pkg.new_clsDataField;
            l_datafield.fieldName := uniqueField.fieldName;
            l_datafield.source := uniqueField.source;
            l_datafield.measureGroup := l_table.measureGroup;
            l_datafield.aggFunction := uniqueField.aggFunction;
            l_datafield.Origin := l_datafield.aggFunction || '(' ||l_datafield.fieldName ||')';
            --Note: other properties for internal columns are not used in input, base, temporal tables
            l_table.data(l_table.data.count) := l_datafield;
            --Add the table to the collection g_bt_tables_precalc
            BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc.count) := l_table;
            bsc_mo_helper_pkg.writeTmp('Adding following table to g_bt_tables_precalc', FND_LOG.LEVEL_STATEMENT,false);
            bsc_mo_helper_pkg.write_this(l_table);
          ELSE
            --Add the field to the temporal table
            --Data columns
            --Add this field
            l_datafield := bsc_mo_helper_pkg.new_clsDataField;
            l_datafield.fieldName := uniqueField.fieldName;
            l_datafield.source := uniqueField.source;
            l_datafield.measureGroup := get_measure_group(uniqueField.fieldname, uniqueField.source);
            l_datafield.aggFunction := uniqueField.aggFunction;
            l_datafield.Origin := l_datafield.aggFunction || '(' || l_datafield.fieldName || ')';
            --Note: other properties for internal columns are not used in input, base, temporal tables
            IF (BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc(iMatchingTableIndex(0)).isProductionTable) THEN
              BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc(iMatchingTableIndex(0)).isProductionTableAltered := true;
              l_datafield.changeType := 'NEW';
            END IF;
            BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc(iMatchingTableIndex(0)).data
              (BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc(iMatchingTableIndex(0)).data.count) := l_datafield;
          End If;
        END IF; -- if not registered
      END LOOP;
    END IF;
    EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.last;
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.next(l_index1);
  END LOOP;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('g_bt_tables_precalc is ', FND_LOG.LEVEL_STATEMENT);
        BSC_MO_HELPER_PKG.write_THIS(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc, FND_LOG.LEVEL_STATEMENT);
        BSC_MO_HELPER_PKG.writeTmp('Completed deduce_bt_tables_precalc, system time is '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
	END IF;

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in deduce_bt_tables_precalc : '||l_error);
        raise;
End;

--****************************************************************************
--  areDisaggsSame : SonMismasDesagregaciones
--
--    DESCRIPTION:
--       Say if the dissagregations are the same
--
--    PARAMETERS:
--       pPeriodicityA: periodicity A
--       KeysA: Dissagregation A
--       pPeriodicityB: peridiodicity B
--       KeysB: Dissagregation B
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function areDisaggsSame(
  pPeriodicityA   IN NUMBER,
  keysA       IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
  pPeriodicityB   IN NUMBER,
  keysB       IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField) return Boolean IS
  keysEqual Boolean;
  l_keyA BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_index1 NUMBER ;

  l_error VARCHAR2(4000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside areDisaggsSame', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  If pPeriodicityA = pPeriodicityB Then
    If keysA.Count = keysB.Count Then
      keysEqual := True;
      IF (keysA.count> 0) THEN
        l_index1 := keysA.first;
        LOOP
          l_keyA := keysA(l_index1);
          If Not BSC_MO_INDICATOR_PKG.keyFieldExists(keysB, l_keyA.keyName) Then
            keysEqual := False;
            Exit;
          End If;
          EXIT WHEN l_index1 = keysA.last;
          l_index1 := keysA.next(l_index1);
        END LOOP;
      END IF;
      If keysEqual Then
	    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          BSC_MO_HELPER_PKG.writeTmp('Completed areDisaggsSame, ret true', FND_LOG.LEVEL_PROCEDURE);
	    END IF;
        return true;
      End If;
    End If;
  End If;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed areDisaggsSame ret false', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  return false;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in areDisaggsSame, '||l_error);
    BSC_MO_HELPER_PKG.writeTmp('pPeriodicityA='||pPeriodicityA||', pPeriodicityB='||pPeriodicityB, FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.writeTmp('KeysA=', FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.write_this(keysA, FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.writeTmp('KeysB=', FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.write_this(keysB, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
End ;
--****************************************************************************
--  CreaLoopDesagDestOri:circular_dependency_exists
--
--  DESCRIPTION:
--     Returns TRUE if there will be a loop when the target dissagregation
--     is originated from the source dissagregation.
--     Example. Desag1 --> DesagOri ---> DesagDest ---
--            ^-----------------------------------
--
--  PARAMETERS:
--     p_target_keys: Target dissagregation
--     p_origin_keys: Source dissagregation
--     p_key_combinations: Collection of dissagregations
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function circular_dependency_exists(
        p_target_keys IN NUMBER,
        p_origin_keys IN NUMBER,
        p_key_combinations BSC_METADATA_OPTIMIZER_PKG.tab_clsDisaggField) RETURN Boolean is
  res Boolean;
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_error VARCHAR2(4000);
begin
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside circular_dependency_exists for p_target_keys='||p_target_keys||', p_origin_keys='||p_origin_keys, FND_LOG.LEVEL_PROCEDURE);
    BSC_MO_HELPER_PKG.write_this(p_key_combinations);
  END IF;
  l_index1 := BSC_MO_HELPER_PKG.findIndex(p_key_combinations, p_origin_keys);
  l_index2 := BSC_MO_HELPER_PKG.findIndex(p_key_combinations, p_target_keys);
  If p_key_combinations(l_index1).Origin = 0 Then
    res := False;
  ElsIf p_key_combinations(l_index1).Origin = p_target_keys Then
    res := True;
  Else
      res := circular_dependency_exists(p_target_keys, p_key_combinations(l_index1).Origin, p_key_combinations);
  End If;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed circular_dependency_exists, res='||
      bsc_mo_helper_pkg.boolean_decode(res), FND_LOG.LEVEL_PROCEDURE);
  END IF;
  return res;
  EXCEPTION WHEN OTHERS THEN
      l_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in circular_dependency_exists, '||l_error);
      raise;
End ;


--****************************************************************************
--  can_derive_keys: SePuedeOriginarDesag
--
--    DESCRIPTION:
--       Say if the target dissagregation can be originated from the source
--       dissagregation.
--       One dissagregation can be originated from another if:
--       1. The periodicities are the same or can be originated.
--       2. Each of the keys in the target dissagregation can be originated
--          from any key of the source dissagregation.
--       One key can be originated from another if they are the same or
--       if the target key is parent of the sopurce key.
--       There could exist several changes of dissagregation but one souce key
--       can originate onlyu one target key
--
--    PARAMETERS:
--       DesagDest: Target dissagregation
--       DesagOri: Source dissagregation
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function can_derive_keys(
        p_key_comb_target BSC_METADATA_OPTIMIZER_PKG.clsDisAggField,
        p_key_comb_targetCode NUMBER,
        p_key_comb_origin BSC_METADATA_OPTIMIZER_PKG.clsDisAggField,
        p_key_comb_originCode NUMBER,
        pTableName VARCHAR2)
        return Boolean IS
  l_key_origin BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_key_target BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  isDerivable Boolean;
  l_changed_levels BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  changedDrill BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_index NUMBER;
  l_return boolean;
  l_index1 number;
  l_index2 number;
  l_per_origin DBMS_SQL.NUMBER_TABLE;
  l_dummy NUMBER;
  l_error varchar2(1000);
BEGIN
  If p_key_comb_target.Periodicity <> p_key_comb_origin.Periodicity Then
    l_index := BSC_MO_HELPER_PKG.FindIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, p_key_comb_target.Periodicity);
    IF (l_index = -1) THEN -- metadata bad
        BSC_MO_HELPER_PKG.writeTmp('Bad Periodicities metadata for Periodicity='||p_key_comb_target.Periodicity, FND_LOG.LEVEL_EXCEPTION, true);
    END IF;
	l_per_origin := BSC_MO_HELPER_PKG.decomposeStringtoNumber(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_index).PeriodicityOrigin, ',' );
    If BSC_MO_HELPER_PKG.findIndex(l_per_origin, p_key_comb_origin.Periodicity) = -1 Then
      return false;
    End If;
  End If;

  IF p_key_comb_target.keys.count >0 THEN
  FOR i IN p_key_comb_target.keys.first..p_key_comb_target.keys.last
  LOOP
    l_key_target := p_key_comb_target.keys(i);
    isDerivable := False;
    IF (p_key_comb_origin.keys.count>0) THEN
    FOR j IN p_key_comb_origin.keys.first..p_key_comb_origin.keys.last
    LOOP
      l_key_origin := null;
      l_key_origin := p_key_comb_origin.keys(j);
      If UPPER(l_key_target.keyName) = Upper(l_key_origin.keyName) Then
        isDerivable := True;
        Exit;
      End If;
      l_index1 := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, l_key_origin.keyName);
      l_index2 := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, l_key_target.keyName);
      IF (l_index1 = -1) THEN -- metadata bad
        BSC_MO_HELPER_PKG.writeTmp('Bad dimension metadata for key='||l_key_origin.keyName, FND_LOG.LEVEL_EXCEPTION, true);
      END IF;
      IF (l_index2 = -1) THEN -- metadata bad
        BSC_MO_HELPER_PKG.writeTmp('Bad dimension metadata for key='||l_key_target.keyName, FND_LOG.LEVEL_EXCEPTION, true);
      END IF;
      If BSC_MO_INDICATOR_PKG.IndexRelation1N(BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_index1).Name,
                               BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_index2).Name) >= 0 Then
        If Not BSC_MO_INDICATOR_PKG.keyFieldExists(l_changed_levels, l_key_origin.keyName) Then
          isDerivable := True;
          changedDrill := bsc_mo_helper_pkg.new_clsKeyField;
          changedDrill.keyName := l_key_origin.keyName;
          l_changed_levels(l_changed_levels.count) := changedDrill;
          Exit ;
        End If;
      End If;
    END LOOP;
    END IF;
    If Not isDerivable Then
      return False;
    End If;
  END LOOP;
  END IF;
  return true;

  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in can_derive_keys : '||l_error);
    BSC_MO_HELPER_PKG.writeTmp('p_key_comb_targetCode ='||p_key_comb_targetCode||',p_key_comb_originCode ='||p_key_comb_originCode||', pTableName='||pTableName,  FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.write_this(p_key_comb_target, 1, FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.write_this(p_key_comb_origin, 1, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
End ;
--****************************************************************************
--  InicListaTablasTemporalesyBasicas :deduce_bt_tables
--
--    DESCRIPTION:
--       Initialize the collection g_bt_tables/g_bt_tables_tgt
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE  deduce_bt_tables(forTargets IN Boolean) IS
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  uniqueField BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
  l_key_combination BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  toBeConsidered Boolean;
  iMatchingTableIndex DBMS_SQL.NUMBER_TABLE;
  l_origin_table VARCHAR2(300);
  l_measure_column BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  needNewTable Boolean;
  l_unique_measures BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField;
  l_BTTables BSC_METADATA_OPTIMIZER_PKG.tab_clsTable;
  l_count1 NUMBER;
  l_count2 NUMBER;
  l_count3 NUMBER;
  l_index NUMBER;
  l_temp NUMBER;

  l_temp3 NUMBER;
  l_BTTables_origin DBMS_SQL.VARCHAR2_TABLE;
  l_tablename VARCHAR2(100);
  l_error VARCHAR2(1000);
  l_loop_ctr NUMBER:=0;
    bMeasureLogged boolean ;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside deduce_bt_tables, forTargets = '||
            bsc_mo_helper_pkg.boolean_decode(forTargets)||' , system time is '||
            bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;

  If forTargets Then
    l_unique_measures := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt;
    l_BTTables := BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt;
    l_tablename := g_target;
  Else
    l_unique_measures := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures ;
    l_BTTables := BSC_METADATA_OPTIMIZER_PKG.g_bt_tables;
    l_tablename := g_unique;
  End If;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Total # of unique measures = '||l_unique_measures.count||', Temp measures = '||l_BTTables.count);
  END IF;

  l_count1 := l_unique_measures.first;
  LOOP
    EXIT WHEN l_unique_measures.count=0;
    uniqueField := l_unique_measures(l_count1);
    bMeasureLogged := false;
    --Loop through list of dissagregations of the unique field until all have been registered
    WHILE NOT all_key_comb_registered(uniqueField.key_combinations) LOOP
      IF bMeasureLogged =false AND BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('---------------------------------');
        BSC_MO_HELPER_PKG.writeTmp('Looping for Measure '||l_count1||' = '|| uniqueField.fieldName ||
                           ', source='||uniqueField.source||', disaggs are ');
        BSC_MO_HELPER_PKG.writeTmp('---------------------------------');
        BSC_MO_HELPER_PKG.write_this(l_tablename, uniqueField.fieldName, uniqueField.key_combinations);
      END IF;
      bMeasureLogged := true;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('Atleast one disagg is not registered', FND_LOG.LEVEL_STATEMENT);
      END IF;
      IF (uniqueField.key_combinations.count>0) THEN
      FOR l_count2 IN uniqueField.key_combinations.first..uniqueField.key_combinations.last
      LOOP
        l_key_combination := uniqueField.key_combinations(l_count2);
        If Not l_key_combination.Registered Then
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp(' Considering disagg ');
            BSC_MO_HELPER_PKG.write_this(l_tablename, uniqueField.fieldName, l_key_combination);
          END IF;
          If (l_key_combination.Origin = 0) Then
            toBeConsidered := True;
          ElsIf (l_key_combination.Origin <> 0 And
            uniqueField.key_combinations(BSC_MO_HELPER_PKG.FindIndex(uniqueField.key_combinations, l_key_combination.Origin)).Registered) Then
            toBeConsidered := True;
          Else
            toBeConsidered := False;
          End If;

	  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp(' To be considered = '||bsc_mo_helper_pkg.boolean_decode(toBeConsidered));
	  END IF;
          If toBeConsidered Then
            l_temp := BSC_MO_HELPER_PKG.findindex(BSC_METADATA_OPTIMIZER_PKG.gLov, uniqueField.fieldName, uniqueField.source);
            iMatchingTableIndex := get_matching_tables(
                                                       uniqueField.fieldName,
                                                       uniqueField.source,
                                                       l_key_combination.Periodicity,
                                                       l_key_combination.keys,
                                                       BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode,
                                                       uniqueField.impl_type,
                                                       l_BTTables
                                                       );
            needNewTable := True;
            l_loop_ctr := iMatchingTableIndex.first;
            LOOP
              EXIT WHEN iMatchingTableIndex.count = 0;
              --It was found a existing temporal table with the same periodicity and disagregation and same field grouping.
              --Check if the disagregation and periodicity of the origin tables of the temporal table
              --are the same as origin disagregation of the current one
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('Found a existing temporal table with the same periodicity and '||
                                    ' disagregation and same field grouping.');
                BSC_MO_HELPER_PKG.writeTmp('Table name = '||l_BTTables(iMatchingTableIndex(l_loop_ctr)).Name||
                                    ', origin table = '||l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable , FND_LOG.LEVEL_STATEMENT);
              END IF;
              l_BTTables_origin := BSC_MO_HELPER_PKG.getDecomposedString(l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable, ',');
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('7. l_key_combination.Origin  = '||l_key_combination.Origin ||
                                    ', l_BTTables_origin.Count = '||l_BTTables_origin.Count||' , system time is '||
                                    bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT);
              END IF;
              If l_key_combination.Origin = 0 Then
                If l_BTTables_origin.Count = 0 -- if its a B table added in this run
                 -- or if its a production B table
				OR (l_BTTables(iMatchingTableIndex(l_loop_ctr)).isProductionTable
				    AND BSC_DBGEN_UTILS.get_table_type(l_BTTables(iMatchingTableIndex(l_loop_ctr)).Name)='B')
				  Then
                  needNewTable := False;
                End If;
              Else -- this key combination can be derived from another key combination
                If l_BTTables_origin.Count <> 0 THEN --AND (NOT l_BTTables(l_loop_ctr).isProductionTable)Then
                  l_temp  := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, l_key_combination.Origin);
                  BSC_MO_HELPER_PKG.write_to_stack('7.1 l_temp='||l_temp);
                  l_temp3 := BSC_MO_HELPER_PKG.findIndex(l_BTTables, l_BTTables_origin(l_BTTables_origin.first));
                  IF (l_temp3 = -1 AND
                      l_BTTables(iMatchingTableIndex(l_loop_ctr)).isProductionTable AND
                      BSC_DBGEN_UTILS.get_table_type(l_BTTables(iMatchingTableIndex(l_loop_ctr)).Name)='B') THEN
                       -- this is a production B table, but we havent loaded I table into memory
                    l_temp3 := iMatchingTableIndex(l_loop_ctr);
                  END IF;
                  BSC_MO_HELPER_PKG.write_to_stack('7.2 l_temp3='||l_temp3);
                  BSC_MO_HELPER_PKG.write_to_stack('7.3 l_BTTables(l_temp3).Keys.count='||l_BTTables(l_temp3).Keys.count);
                  If areDisaggsSame(uniqueField.key_combinations(l_temp).Periodicity,
                                    uniqueField.key_combinations(l_temp).keys,
                                    l_BTTables(l_temp3).Periodicity,
                                    l_BTTables(l_temp3).Keys) Then
                    needNewTable := False;
                    BSC_MO_HELPER_PKG.write_to_stack('7.5 needNewTable := False;');
                  End If;
                End If;
              End If;
              IF (NOT needNewTable) THEN
                exit;
              END IF;
              exit when l_loop_ctr = iMatchingTableIndex.last;
              l_loop_ctr:= iMatchingTableIndex.next(l_loop_ctr);
            END LOOP;
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              BSC_MO_HELPER_PKG.writeTmp('needNewTable = '||bsc_mo_helper_pkg.boolean_decode(needNewTable));
            END IF;
            If needNewTable Then
              --Add a new table
              --Name
              l_table := bsc_mo_helper_pkg.new_clsTable;
              If l_key_combination.Origin <> 0 Then
                l_table.Name := 'BSC_T_' || (BSC_METADATA_OPTIMIZER_PKG.gMaxT + 1);
                BSC_METADATA_OPTIMIZER_PKG.gMaxT := BSC_METADATA_OPTIMIZER_PKG.gMaxT + 1;
              Else
                l_table.Name := 'BSC_B_' || (BSC_METADATA_OPTIMIZER_PKG.gMaxB + 1);
                BSC_METADATA_OPTIMIZER_PKG.gMaxB := BSC_METADATA_OPTIMIZER_PKG.gMaxB + 1;
              End If;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('Going to add table '||l_table.Name);
              END IF;
              l_table.measureGroup := get_measure_group(uniqueField.fieldname, uniqueField.source);
              l_table.Type := 1;
              l_table.Periodicity := l_key_combination.Periodicity;
              l_table.EDW_Flag := uniqueField.EDW_Flag;
              l_table.IsTargetTable := forTargets;
              l_table.IsProductionTable := false;
              l_table.impl_type := uniqueField.impl_type;
              -- BSC AW
              --l_key_combination_keys := BSC_MO_HELPER_PKG.getDisaggKeys(l_tablename, uniqueField.fieldName, l_key_combination.code);
              l_index := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, l_key_combination.code);
              l_key_combination.keys := UniqueField.key_Combinations(l_index).keys;
              l_count3 := l_key_combination.keys.first;
              --Key columns
              l_table.keys := l_key_combination.keys;
              --Data columns
              --It is initialized only with the current field
              l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
              l_measure_column.fieldName := uniqueField.fieldName;
              l_measure_column.source := uniqueField.source;
              l_measure_column.MeasureGroup := l_table.measureGroup;
              l_measure_column.aggFunction := uniqueField.aggFunction;

              If l_key_combination.Origin <> 0 Then
                l_index := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, l_key_combination.Origin);
                l_origin_table := get_origin_table(
				    uniqueField.key_combinations(l_index).Periodicity,
				    uniqueField.key_combinations(l_index).keys,
                                    uniqueField.fieldName,
                                    uniqueField.source,
                                    uniqueField.MeasureGroup,
                                    uniqueField.impl_type,
                                    l_BTTables);
              End If;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('14. l_origin_table = '||l_origin_table||' system time is '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT);
              END IF;
              --Note: removed the name of the table as prefix of the column
              --I do not see that the same column could be in two origin tables.
              l_measure_column.Origin := l_measure_column.aggFunction|| '('|| l_measure_column.fieldName || ')';
              --Note: other properties for internal columns are not used in input, base, temporal tables
              l_table.data(l_table.data.count) := l_measure_column;
              --TablasOri
              --It is initializes with only the name of the origin table
              IF l_key_combination.Origin <> 0 Then
                IF (l_table.originTable IS NOT NULL) THEN
                  l_table.originTable := l_table.originTable||',';
                END IF;
                IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                  bsc_mo_helper_pkg.writeTmp('4. Adding Origin table for '||l_table.name||' = '||l_origin_table);
                END IF;
                l_table.originTable := l_table.originTable||l_origin_table;
              END IF;

              --Add the table to the collection l_BTTables
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp('Adding table at l_BTTables('||l_BTTables.count||'), table is ');
                bsc_mo_helper_pkg.write_this(l_table);
              END IF;
              l_BTTables(l_BTTables.count) := l_table;
              l_key_combination.Registered := True;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('15. Registered key combination', FND_LOG.LEVEL_STATEMENT);
              END IF;
            Else -- Table already exists
              --Add the field to the temporal table
              --Data columns
              --Add the current field
              l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
              l_measure_column.fieldName := uniqueField.fieldName;
              l_measure_column.source := uniqueField.source;
              l_measure_column.MeasureGroup := get_measure_group(uniqueField.fieldname, uniqueField.source);
              l_measure_column.aggFunction := uniqueField.aggFunction;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('16. Add current field '||l_measure_column.fieldName, FND_LOG.LEVEL_STATEMENT);
              END IF;
              If l_key_combination.Origin <> 0 Then
                l_index := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, l_key_combination.Origin);
                l_origin_table := get_origin_table(
				    uniqueField.key_combinations(l_index).Periodicity,
				    uniqueField.key_combinations(l_index).keys,
                                    uniqueField.fieldName,
                                    uniqueField.source,
                                    uniqueField.measureGroup,
                                    uniqueField.impl_type,
                                    l_BTTables);
              End If;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('17. Origin table is '||l_origin_table, FND_LOG.LEVEL_STATEMENT);
              END IF;
              --Note: removed the name of the table as prefix of the column
              --I do not see that the same column could be in two origin tables.
              l_measure_column.Origin := l_measure_column.aggFunction || '(' || l_measure_column.fieldName || ')';
              IF (l_BTTables(iMatchingTableIndex(l_loop_ctr)).isProductionTable AND
			     NOT BSC_MO_INDICATOR_PKG.DataFieldExists(l_BTTables(iMatchingTableIndex(l_loop_ctr)).Data, l_measure_column.fieldName)) THEN
                l_BTTables(iMatchingTableIndex(l_loop_ctr)).isProductionTableAltered := true;
                l_measure_column.changeType := 'NEW';
                IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                  BSC_MO_HELPER_PKG.writeTmp('ChangeType for '||l_measure_column.fieldName ||' = NEW', FND_LOG.LEVEL_STATEMENT);
                END IF;
              END IF;
              --Note: other properties for internal columns are not used in input, base, temporal tables
              -- If the field does not exist already in the table, then add it.
              IF( NOT BSC_MO_INDICATOR_PKG.DataFieldExists(l_BTTables(iMatchingTableIndex(l_loop_ctr)).Data, l_measure_column.fieldName))THEN
                l_BTTables(iMatchingTableIndex(l_loop_ctr)).Data(l_BTTables(iMatchingTableIndex(l_loop_ctr)).Data.count) := l_measure_column;
                BSC_MO_HELPER_PKG.writeTmp('18. Add origin table '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT);
                --TablasOri
                --Add to the list the name of the origin table
                IF l_key_combination.Origin <> 0 Then
                  IF Not TableOriginExists(l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable, l_origin_table) Then
                    IF (l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable IS NOT NULL) THEN
                      l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable := l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable||',';
                    END IF;
	                IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                      bsc_mo_helper_pkg.writeTmp('5. Adding Origin table for '||l_BTTables(iMatchingTableIndex(l_loop_ctr)).name||' = '||l_origin_table);
                    END IF;
                    l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable := l_BTTables(iMatchingTableIndex(l_loop_ctr)).originTable||l_origin_table;
                  END If;
                END If;
              END IF;

              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('19. Registered key combination', FND_LOG.LEVEL_STATEMENT);
              END IF;
              l_key_combination.Registered := True;
            End If; -- End of NeedNewTable
          End If;-- ENd of to be considered
          uniqueField.key_combinations(l_count2) := l_key_combination;
        End If; --End of registered
      END LOOP;
      END IF;
    END Loop; -- end of while
    EXIT WHEN l_count1 = l_unique_measures.last;
    l_count1 := l_unique_measures.next(l_count1);
  END LOOP;


  IF forTargets THEN
    BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt := l_unique_measures ;
    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt := l_BTTables;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('g_unique_measures_tgt is ');
      BSC_MO_HELPER_PKG.write_this(g_target, BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt);
      BSC_MO_HELPER_PKG.writeTmp('g_bt_tables_tgt is ');
      BSC_MO_HELPER_PKG.write_this(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt);
    END IF;
  ELSE
    BSC_METADATA_OPTIMIZER_PKG.g_unique_measures  := l_unique_measures;
    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables := l_BTTables;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('g_unique_measures  is ');
      BSC_MO_HELPER_PKG.write_this(g_unique, BSC_METADATA_OPTIMIZER_PKG.g_unique_measures, FND_LOG.LEVEL_STATEMENT, false);
      BSC_MO_HELPER_PKG.writeTmp('g_bt_tables is ');
      BSC_MO_HELPER_PKG.write_this(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables, FND_LOG.LEVEL_STATEMENT, false, false);
    END IF;
  END IF;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Compl deduce_bt_tables, system time is '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;

  EXCEPTION WHEN OTHERS THEN
	l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in deduce_bt_tables : '||l_error);
    BSC_MO_HELPER_PKG.terminateWithError('BSC_RETR_TTABLES_FAILED', 'deduce_bt_tables');
	raise;
End ;

--****************************************************************************
--  ResolverOrigenDesagsCamposUnicos : resolve_key_origins
--    DESCRIPTION:
--       Resolve the origin of each dissagregation of each unique field
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE resolve_key_origins(p_unique_measures IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField,
        pTargets IN BOOLEAN) IS
  uniqueField BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
  l_key_combination BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
  Desag1 BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  i NUMBER;
  j NUMBER;
  k NUMBER;
  l NUMBER;
  --l_key_combination_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  --Desag1_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  l_tableName VARCHAR2(100);
  l_error VARCHAR2(1000);
  l_index NUMBER;
  bMeasureLogged boolean ;
BEGIN
  IF (pTargets) THEN
    l_tableName := g_target;
  ELSE
    l_tableName := g_unique;
  END IF;
  IF (p_unique_measures.count =0) THEN
    return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp(' ');
    BSC_MO_HELPER_PKG.writeTmp(' ');
    BSC_MO_HELPER_PKG.writeTmp('Inside resolve_key_origins '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  IF (p_unique_measures.count>0) THEN
    FOR i IN p_unique_measures.first..p_unique_measures.last
    LOOP
      uniqueField := p_unique_measures(i);
      bmeasureLogged := false;
      --for each dissagregation look if it could be originated from another
      IF uniqueField.key_combinations.count>0 THEN
      FOR j IN uniqueField.key_combinations.first..uniqueField.key_combinations.last
      LOOP
        l_key_combination := uniqueField.key_combinations(j);
        IF (l_key_combination.registered = false) THEN -- ignore registered disaggs from prod. tables

          IF bMeasureLogged =false and BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp(' ');
            BSC_MO_HELPER_PKG.writeTmp('Looping for unique field : '||uniqueField.fieldName||', source='||uniqueField.source, FND_LOG.LEVEL_STATEMENT);
            bsc_mo_helper_pkg.write_this(null, uniqueField);
          END IF;
          bMeasureLogged := true;
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp('   Disagg is '||l_key_combination.code, FND_LOG.LEVEL_STATEMENT);
          END IF;
          l_index := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, l_key_combination.code);
          l_key_combination.keys := uniqueField.key_combinations(l_index).keys;
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp('   Disagg Keys are ', FND_LOG.LEVEL_STATEMENT);
            BSC_MO_HELPER_PKG.write_this(l_key_combination.keys);
          END IF;
          FOR k IN uniqueField.key_combinations.first..uniqueField.key_combinations.last
          LOOP
            Desag1 := uniqueField.key_combinations(k);
            l_index := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, desag1.code);
            If Desag1.Code <> l_key_combination.Code Then
              If can_derive_keys(--uniqueField.fieldName,
  	  	      l_key_combination, l_key_combination.code, Desag1, Desag1.code, l_tablename) Then
                IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                  BSC_MO_HELPER_PKG.writeTmp('   Disagg.code is '||l_key_combination.code||' and Disagg1.code is '||desag1.code, FND_LOG.LEVEL_STATEMENT);
                  BSC_MO_HELPER_PKG.writeTmp('Origin exists, verify there is no loop ', FND_LOG.LEVEL_STATEMENT);
                END IF;
                --verify that it is not creating a loop when l_key_combination is originated from Desag1
                If Not circular_dependency_exists(l_key_combination.Code, Desag1.Code, uniqueField.key_combinations) Then
                  l_key_combination.Origin := Desag1.Code;
                  IF (l_key_combination.keys.count>0) THEN
                    FOR l IN l_key_combination.keys.first..l_key_combination.keys.last
                    LOOP
                      l_key := l_key_combination.keys(l);
                      l_key.Origin := BSC_MO_INDICATOR_PKG.getKeyOrigin(Desag1.keys, l_key.keyName);
                      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                        bsc_mo_helper_pkg.writeTmp('Changing table = '||l_tableName ||', field '||uniqueField.fieldName
                                            ||', code = '||l_key_combination.code||'''s origin to '||l_key.Origin);
                      END IF;
                      l_key_combination.keys(l) := l_key;
                    END LOOP;
                  END IF;
                  uniqueField.key_combinations(j) := l_key_combination;
                  uniqueField.key_combinations(j) := l_key_combination;
                  uniqueField.key_combinations(j).keys := l_key_combination.keys;
                  EXIT ;
                End If;
              End If;
            End If;
          END LOOP;
        END IF;
	  END LOOP;
    END IF;
    p_unique_measures(i) := uniqueField;
  END LOOP;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed resolve_key_origins '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
    BSC_MO_HELPER_PKG.write_This(null,p_unique_measures, FND_LOG.LEVEL_STATEMENT, true);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in resolve_key_origins : '||l_error);
    raise;
End ;


--****************************************************************************
--  GetCodDesagregacion : GetDisaggCode
--
--    DESCRIPTION:
--       Returns the code of the dissagregation on collection colDesags where
--       the periodicity and key columns are identical to the given ones.
--       Return 0 if it is not found.
--       Note: Additionally, it verify that it has the same filter.
--       There is no filter defined for tables of no pre-calculated indicators,
--       so the filter is not verified.
--       Filter is taken into accout for tables of precalculated indicators.
--       colDesags is a collection of objects of class clsdisaggField.
--       p_keys is a collection of objects of class clsCampoLlave
--
--    PARAMETERS:
--       colDesags: collection of dissagregations
--       pPeriodicity: periodicity
--       p_keys: key columns
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function GetDisaggCode(pFieldName IN VARCHAR2,
                       colDesags IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDisaggField,
                       pPeriodicity in number,
                       p_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
                       pTableName IN VARCHAR2)
return NUMBER IS
  l_key_combination BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
  l_key BSC_METADATA_OPTIMIZER_PKG.clskeyField;
  keysEqual Boolean;
  l_temp   NUMBER;

    --l_key_combination_keys BSC_METADATA_OPTIMIZER_PKG.tab_clskeyField;
    l_error VARCHAR2(1000);
    l_stack VARCHAR2(32000);

BEGIN

  IF( colDesags.count= 0) THEN
    return -1;
  END IF;
  l_stack := 'Inside GetDisaggCode, pPeriodicity='||pPeriodicity;
  FOR i IN colDesags.first..colDesags.last
  LOOP
    IF (length(l_stack) > 31000) THEN
      l_stack := null;
    END IF;
    l_stack := l_stack || g_newline||'Loop1';
    l_key_combination := colDesags(i);
    --BSC AW
    --l_key_combination_keys := BSC_MO_HELPER_PKG.getDisaggKeys(pTableName, pFieldName, l_key_combination.Code);
	--l_key_combination_keys := l_key_combination.keys;
	If l_key_combination.Periodicity = pPeriodicity Then
      If l_key_combination.keys.Count = p_keys.Count Then
        keysEqual := True;
        IF (l_key_combination.keys.count>0) THEN
        FOR j IN l_key_combination.keys.first..l_key_combination.keys.last
        LOOP
          l_stack := l_stack || g_newline||'Loop2 begin';
          l_key := l_key_combination.keys(j);
          If Not BSC_MO_INDICATOR_PKG.KeyfieldExists(p_keys, l_key.keyName) Then
            keysEqual := False;
            Exit ;
          Else
            l_temp := BSC_MO_HELPER_PKG.findIndex(p_keys, l_key.keyName);
            If UPPER(l_key.FilterViewName) <> UPPER(p_keys(l_temp).FilterViewName) Then
              keysEqual := False;
              Exit ;
            End If;
          End If;
        END LOOP;
        END IF;
          l_stack := l_stack || g_newline||'Loop2 end';
      END IF;
      If keysEqual Then
        l_stack := l_stack || g_newline||'Compl GetDisaggCode, returning '||l_key_combination.Code;
        return l_key_combination.Code;
      End If;
    End If;
  END LOOP;
  l_stack := l_stack || g_newline||'Compl GetDisaggCode, returning -1';
  return -1;

  EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in GetDisaggCode :'||l_error);
            BSC_MO_HELPER_PKG.writeTmp('Stack is  :'||l_stack, FND_LOG.LEVEL_UNEXPECTED, true);
        raise;

End ;



--****************************************************************************
--  ExisteuniqueField : UniqueFieldExists
--
--    DESCRIPTION:
--       Return TRUE if the given field belongs to collection g_unique_measures .
--
--    PARAMETERS:
--       Campo: field name
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function UniqueFieldExists(p_measure_name IN VARCHAR2,
-- BSC Autogen
p_source IN VARCHAR2,
p_impl_type IN NUMBER, p_unique_measure_list IN BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField) return Boolean IS
  l_uniqueField BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
  l_count NUMBER ;
BEGIN
  IF (p_unique_measure_list.count =0) THEN
      return false;
  END IF;
  l_count := p_unique_measure_list.first;
  LOOP
     l_uniqueField  := p_unique_measure_list(l_count);
      If UPPER(l_uniqueField.fieldName) = UPPER(p_measure_name)
        -- for AW
	    and l_uniqueField.impl_type = p_impl_type
	    --BSC Autogen
		and l_uniqueField.source = p_source THEN
        return true;
      End If;
      EXIT WHEN l_count = p_unique_measure_list.last;
      l_count := p_unique_measure_list.next(l_count);
  END LOOP;
  return FALSE;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.writeTmp('Exception in UniqueFieldExists, '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in UniqueFieldExists, '||sqlerrm);
    raise;
End ;

--****************************************************************************
--  init_s_table_measures_precalc : InicListaUnicaCamposPreCalc
--  DESCRIPTION:
--     Initialize the collection g_unique_measures_precalc, where are the data fields
--     with all the information: field name, agregation function, and the list
--     of all disagregations used by the indicators for the field.
--****************************************************************************
PROCEDURE init_s_table_measures_precalc(p_tables IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsTable )IS

  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_measure   BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  uniqueField BSC_METADATA_OPTIMIZER_PKG.clsUniqueField;
  disaggField BSC_METADATA_OPTIMIZER_PKG.clsDisaggField;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  disaggKeyField BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  CodDesag NUMBER;
  l_count1 NUMBER;
  l_count2 NUMBER;
  l_count3 NUMBER;
  l_temp   NUMBER;
  l_field_index NUMBER;
  l_disagg_index NUMBER;
  l_index  NUMBER;

  Tabla_OriginTable DBMS_SQL.VARCHAR2_TABLE;

  uniqueField_disAggKeys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;

  l_stack varchar2(32000):= null;
  l_error varchar2(2000);
  l_optimizationMode NUMBER;
  l_impl_type number;
BEGIN
  IF (p_tables.count=0) THEN
    return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside init_s_table_measures_precalc, g_unique_measures_precalc.count='||
      BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.count||' '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  l_count1 := p_tables.first;
  LOOP
    IF (length(l_stack) > 30000) THEN
      l_stack := null;
    END IF;
    l_table := p_tables(l_count1);
    IF (Tabla_OriginTable IS NOT NULL) THEN
      Tabla_OriginTable := bsc_mo_helper_pkg.getDecomposedString(l_table.originTable, ',');
    END IF;
    --Only consider tables not having origin and belong to indicators precalculated
    l_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_table.Indicator);
    IF (l_index = -1) THEN
      l_optimizationMode := BSC_MO_HELPER_PKG.getKPIPropertyValue(l_table.Indicator, 'DB_TRANSFORM', 1);
      l_impl_type := BSC_MO_HELPER_PKG.getKPIPropertyValue(l_table.Indicator, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1);
    ELSE
      l_optimizationMode := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index).OptimizationMode;
      l_impl_type := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index).impl_type;
    END IF;

    IF (l_table.isProductionTable is null) THEN
      l_table.isProductionTable:=false;
    END IF;
    If ((l_table.originTable IS NULL AND l_table.isProductionTable=false) OR
        (l_table.originTable IS NOT NULL AND l_table.isProductionTable=true))
       And l_optimizationMode = 0 Then
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('');
        bsc_mo_helper_pkg.writeTmp(' Processing table '||l_table.name);
        bsc_mo_helper_pkg.write_this(l_table);
      END IF;

      l_count2 := l_table.data.first;
      LOOP
        EXIT WHEN l_table.data.count=0;
        l_measure := l_table.data(l_count2);
        --Do not consider internal columns. They are used only in indicator
        --tables and are not going to be base or input tables.
        If l_measure.InternalColumnType = 0 Then
          If Not UniqueFieldExists(l_measure.fieldName, l_measure.source, l_impl_type, BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc) Then
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              bsc_mo_helper_pkg.writeTmp('  '||l_measure.fieldName||'('||l_measure.source||') Field does not exist --> Add it');
            END IF;
            --Field does not exists --> Add it
            uniqueField := bsc_mo_helper_pkg.new_clsUniqueField;
            uniqueField.fieldName := l_measure.fieldName;
            uniqueField.source := l_measure.source;
            uniqueField.measureGroup := get_measure_Group(l_measure.fieldName, l_measure.source);
            uniqueField.aggFunction := l_measure.aggFunction;
            IF (l_index <> -1) THEN
              uniqueField.EDW_Flag := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index).EDW_Flag;
            ELSE
              uniqueField.EDW_Flag := 0;
            END IF;
            uniqueField.impl_type := l_impl_type;
            --Desags. It initialized with one element that correspond to the disagregation
            --and periodicity of the table
            disaggField := bsc_mo_helper_pkg.new_clsDisAggField;
            disaggField.Code := 1;
            disaggField.Periodicity := l_table.Periodicity;
            --Key columns. Same as the table
            l_count3 := l_table.keys.first;
            disaggField.keys := l_table.keys;
            disaggField.Origin := 0;
            IF (l_table.isProductionTable ) THEN
              disaggField.Registered := True;
            ELSE
              disaggField.Registered := False;
            END IF;
            uniqueField.key_combinations(uniqueField.key_combinations.count) := disaggField;
            --uniqueField.key_combinations(0).keys := disaggField.Keys;
            --Add the unique field to the collection g_unique_measures_precalc
            BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.count) := uniqueField;
          ELSE
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              bsc_mo_helper_pkg.writeTmp( l_measure.fieldName||'('||l_measure.source||') field already exists. Check periodicity and disaggregation');
            END IF;
            --The field already exists. So check if its periodicity and disagregation
            -- is in its list of disagregations
            l_field_index := BSC_MO_HELPER_PKG.findIndex(
                                BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc,
                                l_measure.fieldName,
                                l_measure.source,
				l_table.impl_type);
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              bsc_mo_helper_pkg.writeTmp('Field Index is '||l_field_index);
            END IF;
            uniqueField.key_combinations.delete;
            uniqueField.key_combinations := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_field_index).key_combinations;
            CodDesag := GetDisaggCode(
                                    uniqueField.fieldName,
                                    uniqueField.key_combinations,
                                    l_table.Periodicity,
                                    l_table.keys,
                                    l_table.name);
            If CodDesag = -1 Then
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp( 'Disaggregation does not exist, add it');
              END IF;
              --It does not exist --> Add it
              disaggField := bsc_mo_helper_pkg.new_clsDisAggField;
              uniqueField.key_combinations.delete;
              uniqueField.key_combinations := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_field_index).key_combinations;
	      disaggField.Code := uniqueField.key_combinations.Count + 1;
              disaggField.Periodicity := l_table.Periodicity;
              --Key columns. Same as the table
              disaggField.keys := l_table.keys;
              disaggField.Origin := 0;
              IF (l_table.isProductionTable ) THEN
                disaggField.Registered := True;
              ELSE
                disaggField.Registered := False;
              END IF;
              --Add the disagregation to the collection Desags of the unique field
              BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_field_index).key_combinations
                (BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_field_index).key_combinations.count) := disaggField;
            ELSE
              --The dissagregation exists. We need to use the property NecesitaCod0 because
              --the table could need zero code in some key where the dissagregation dont need
              --so far.
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp( 'Disaggregation already exists');
              END IF;
              l_disagg_index := BSC_MO_HELPER_PKG.findIndex(uniqueField.key_combinations, CodDesag);
              uniqueField_disAggKeys.delete;
              uniqueField_disAggKeys := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_field_index).key_combinations(l_disagg_index).keys;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp( 'Matching disagg index '||l_disagg_index);
              END IF;
              IF uniqueField_disAggKeys.count>0 THEN
	        FOR l_count3 IN uniqueField_disAggKeys.first..uniqueField_disAggKeys.last
                LOOP
                  l_key := uniqueField_disAggKeys(l_count3);
                  l_temp := BSC_MO_HELPER_PKG.findIndex(l_table.keys, l_key.keyName);
                  If l_table.keys(l_temp).NeedsCode0 Then
                    l_key.NeedsCode0 := l_table.keys(l_temp).NeedsCode0;
                  End If;
                  uniqueField_disAggKeys(l_count3) := l_key;
                END LOOP;
              END IF;
              IF (l_table.isProductionTable) THEN
                  BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc (l_field_index).key_combinations(CodDesag-1).Registered := true;
                  BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc (l_field_index).key_combinations(CodDesag-1).isProduction := true;
              END IF;
              BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc(l_field_index).key_combinations(l_disagg_index).keys := uniqueField_disAggKeys;

            END IF;
          END IF;
        END IF;
        EXIT WHEN l_count2=l_table.data.last;
        l_count2 := l_table.data.next(l_count2);
      END LOOP;
      p_tables(l_count1) := l_table;
    End If;
    EXIT WHEN l_count1 = p_tables.last;
    l_count1 := p_tables.next(l_count1);
    l_stack := null;
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed init_s_table_measures_precalc, g_unique_measures_precalc.count='||
            BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc.count||' '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
   BSC_MO_HELPER_PKG.writeTmp('g_unique_measures_precalc  = ');
    BSC_MO_HELPER_PKG.write_this(g_unique, BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_precalc );

  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in init_s_table_measures_precalc : '||l_error);
    BSC_MO_HELPER_PKG.writeTmp('l_stack  : '||l_stack, FND_LOG.LEVEL_UNEXPECTED, true);
    BSC_MO_HELPER_PKG.TerminateWithError('BSC_RETR_PC_DATACOL_FAILED', 'init_s_table_measures_precalc');
    raise;
End;


--****************************************************************************
--  InicListaUnicaCampos : init_s_table_measures
--
--   DESCRIPTION:
--       Initialize the collection g_unique_measures /g_unique_measures_tgt,
--       where are the data fields with all the information: field name,
--       agregation function, and the list of all disagregations used by the
--       indicators for the field.
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE init_s_table_measures(p_tables IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsTable ) IS

  l_clstable           BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_measure          BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  uniqueField      BSC_METADATA_OPTIMIZER_PKG.clsUniqueField ;
  l_unique_measures    BSC_METADATA_OPTIMIZER_PKG.tab_clsUniqueField ;
  disaggField      BSC_METADATA_OPTIMIZER_PKG.clsDisAggField;
  l_key           BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  disaggKeyField   BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_count         NUMBER := 0;
  l_count2        NUMBER := 0;
  l_count3        NUMBER := 0;
  l_index         NUMBER := null;
  l_temp          NUMBER;
  l_index2        NUMBER;

  Tabla_OriginTable DBMS_SQL.VARCHAR2_TABLE;
  l_tablename VARCHAR2(100) ;
  l_error VARCHAR2(1000);

  l_stack VARCHAR2(32000);
  l_OptimizationMode NUMBER;
  l_impl_type NUMBER;
  l_disagg_code NUMBER;
BEGIN
  IF (p_tables.count=0) THEN
    return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside init_s_table_measures, p_tables.count = '||p_tables.count||', g_unique_measures .count='||
      BSC_METADATA_OPTIMIZER_PKG.g_unique_measures .count||
        ', g_unique_measures_tgt.count='||BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt.count||' '||bsc_mo_helper_pkg.get_time
        , FND_LOG.LEVEL_PROCEDURE);
  END IF;
  l_count := p_tables.first;
  LOOP
    l_clstable := p_tables(l_count);
    IF (l_clstable.IsTargetTable) THEN
      l_tablename := g_target;
    ELSE
      l_tablename := g_unique;
    END IF;
    --Only consider tables not having origin and belong to indicators no-precalculated
    --Also only consider tables that are not for targets
    l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_clstable.Indicator);
    IF (l_temp = -1) THEN
      l_optimizationMode := BSC_MO_HELPER_PKG.getKPIPropertyValue(l_clstable.Indicator, 'DB_TRANSFORM', 1);
      l_impl_type := BSC_MO_HELPER_PKG.getKPIPropertyValue(l_clstable.Indicator, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1);
    ELSE
      l_optimizationMode := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_temp).OptimizationMode;
      l_impl_type := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_temp).impl_type;
    END IF;
    l_stack := l_stack ||g_newline||'Table = '||l_clstable.name||', l_optimizationMode = '||l_optimizationmode||', l_impl_type='||l_impl_type;

    IF (l_clstable.isProductionTable is null) THEN
      l_clstable.isProductionTable:=false;
    END IF;
    If ((l_clstable.originTable IS NULL AND l_clstable.isProductionTable=false) OR
        l_clstable.isProductionTable=true
		)
	    And  l_optimizationMode <> 0 Then
	  BSC_MO_HELPER_PKG.writeTmp(' ');
      BSC_MO_HELPER_PKG.writeTmp(' ');
	  BSC_MO_HELPER_PKG.writeTmp('Processing table '||l_clstable.name);
      --l_table_measures := l_clstable.Data;
      --l_table_keys := l_clstable.keys;
      BSC_MO_HELPER_PKG.writeTmp('  l_clstable.data.count = '||l_clstable.data.count||', l_clstable.keys.count='||l_clstable.keys.count );
      If l_clstable.IsTargetTable Then
        l_stack := l_stack||' Target table';
        l_unique_measures := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt;
      Else
        l_stack := l_stack||g_newline||' Not a target table';
        l_unique_measures := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures ;
      End If;
      l_stack := l_stack||g_newline||' l_unique_measures.count = '||l_unique_measures.count;
      IF length(l_stack )> 31000 THEN
        l_stack := substr(l_stack, 30000);
      END IF;
      --We maintain a separate collection for data fields of targets tables
      IF l_clstable.data.count>0 THEN
      FOR l_count2 in l_clstable.data.first..l_clstable.data.last
      LOOP
        l_measure := l_clstable.data(l_count2);
        --Do not consider internal columns. They are used only in indicator
        --tables and are not going to be base or input tables.
        If l_measure.InternalColumnType = 0 Then
          l_stack := l_stack||g_newline||'  Checking field '||l_measure.fieldName;
          l_stack := l_stack||g_newline||'  --------------------';
          BSC_MO_HELPER_PKG.writeTmp('  ');
          BSC_MO_HELPER_PKG.writeTmp('  Checking field '||l_measure.fieldName||', source='||l_measure.source);
          BSC_MO_HELPER_PKG.writeTmp('  --------------------------------------');
          IF length(l_stack )> 31000 THEN
            l_stack := substr(l_stack, 30000);
          END IF;
          If UniqueFieldExists(l_measure.fieldName, l_measure.source, l_impl_type, l_unique_measures)=false Then
            l_stack := l_stack||g_newline||'..Field does not exist';
            -- If its a production table, dont add the measures that are used by Indicators in this iteration
              BSC_MO_HELPER_PKG.writeTmp('..does not exist --> Add it');
              --Field does not exists --> Add it
              uniqueField := BSC_Mo_helper_PKG.new_clsUniqueField;
              uniqueField.fieldName := l_measure.fieldName;
              uniqueField.source := l_measure.source;
              uniqueField.measureGroup := get_measure_group(uniqueField.fieldName, l_measure.source);
              uniqueField.aggFunction := l_measure.aggFunction;
              l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_clstable.Indicator);
              IF (l_temp <> -1) THEN
                uniqueField.EDW_Flag := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_temp).EDW_Flag;
              END IF;
              l_stack := l_stack||g_newline||'l_impl_type='||l_impl_type;
			  uniqueField.impl_type := l_impl_type;
              --Desags. It initialized with one element that correspond to the disagregation
              --and periodicity of the table
              disaggField := BSC_Mo_helper_PKG.new_clsDisAggField;
              disaggField.Code := 1;
              disaggField.Periodicity := l_clstable.Periodicity;
              -- Important, mark this as from existing table
              disaggField.isProduction := l_clsTable.isProductionTable;
              --Key columns. Same as the table
              --Dissagg_Keys.delete;
              l_stack := l_stack||g_newline||'Table keys.count='||l_clstable.keys.count;
              IF (l_clstable.keys.count>0) THEN
              FOR l_count3 IN l_clstable.keys.first..l_clstable.keys.last
              LOOP
                l_key := BSC_Mo_helper_PKG.new_clsKeyField;
                l_key := l_clstable.keys (l_count3);
                disaggKeyField := bsc_mo_helper_pkg.new_clsKeyField;
                disaggKeyField.keyName := l_key.keyName;
                disaggKeyField.Origin := l_key.Origin;
                disaggKeyField.NeedsCode0 := False;
                disaggKeyField.CalculateCode0 := False;
                disaggKeyField.FilterViewName := null;
                l_stack := l_stack||g_newline||'Adding disagg key='||disaggKeyField.keyName;
                disaggField.keys(disaggField.keys.count) := disaggKeyField;
              END LOOP;
              END IF;
              disaggField.Origin := 0;
              IF (l_clstable.isProductionTable) THEN
                disaggField.Registered := true;
                disaggField.isProduction := true;
              ELSE
                disaggField.Registered := False;
                disaggField.isProduction := False;
              END IF;
              l_stack := l_stack||g_newline||'Disagg keys = '||disaggField.keys.count;
              uniqueField.key_combinations(uniqueField.key_combinations.count) := disaggField;
              BSC_MO_HELPER_PKG.writeTmp('Adding to unique field');
              BSC_MO_HELPER_PKG.write_this(null, uniqueField);
              --Add the unique field to the collection l_unique_measures
              If l_clstable.IsTargetTable Then
                l_index2 := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt.count;
                BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt(l_index2) := uniqueField;
                l_stack := l_stack||g_newline||'Added g_unique_measures ('||l_index2||'), count = '||l_index2;
                BSC_MO_HELPER_PKG.writeTMp('Added '||l_measure.fieldName||', source='||l_measure.source||
                                   ' to g_unique_measures_tgt at index='||l_index2 );
              Else
                l_index2 := BSC_METADATA_OPTIMIZER_PKG.g_unique_measures.count;
                BSC_METADATA_OPTIMIZER_PKG.g_unique_measures (l_index2) := uniqueField;
                l_stack := l_stack||g_newline||'Added g_unique_measures ('||l_index2||'), count = '||l_index2;
                BSC_MO_HELPER_PKG.writeTMp('Added '||l_measure.fieldName||', source='||l_measure.source||
                                   ' to g_unique_measures at index='||l_index2);
              End If;
          Else
            --The field already exists. So check if its periodicity and disagregation
            -- is in its list of disagregations
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              BSC_MO_HELPER_PKG.writeTMp(l_measure.fieldName||'..Field already exists --> check periodicity and disagregation');
            END IF;
            l_temp := BSC_MO_HELPER_PKG.findIndex (l_unique_measures, l_measure.fieldName, l_measure.source, l_impl_type);
            l_disagg_code := GetDisaggCode(l_unique_measures(l_temp).fieldName,
                               l_unique_measures(l_temp).key_combinations,
                               l_clstable.Periodicity,
                               l_clstable.keys,
                               l_Tablename);
            IF l_disagg_code = -1 Then
              l_stack := l_stack||g_newline||'Disagg does not exist -> Add it ';
              bsc_mo_helper_pkg.writeTmp( 'Disagg does not exist -> Add it ');
              --It does not exist --> Add it
              l_temp := bsc_mo_helper_pkg.findIndex(l_unique_measures, l_measure.fieldName, l_measure.source, l_impl_type);
              disaggField := bsc_mo_helper_pkg.new_clsDisAggField;
              disaggField.Code := l_unique_measures(l_temp).key_combinations.count + 1;
              disaggField.Periodicity := l_clstable.Periodicity;
              --Key columns. Same as the table
              IF (l_clstable.keys.count>0) THEN
                FOR l_count3 IN l_clstable.keys.first..l_clstable.keys.last LOOP
                  l_key := l_clstable.keys(l_count3);
                  disaggKeyField := bsc_mo_helper_pkg.new_clsKeyField;
                  disaggKeyField.keyName := l_key.keyName;
                  disaggKeyField.Origin := l_key.Origin;
                  disaggKeyField.NeedsCode0 := False;
                  disaggKeyField.CalculateCode0 := False;
                  disaggKeyField.FilterViewName := null;
                  disaggField.keys(disaggField.keys.count) := disaggKeyField;
                END LOOP;
              END IF;
	      --Origin
              disaggField.Origin := 0;
              --disaggField.Registered := False;
              IF (l_clstable.isProductionTable) THEN
                disaggField.Registered := true;
                disaggField.isProduction := true;
              ELSE
                disaggField.Registered := False;
                disaggField.isProduction := False;
              END IF;
              l_stack := l_stack||g_newline||'2. Disagg keys = '||disaggField.keys.count;
              --Add the disagregation to the collection Desags of the unique field
              l_temp := BSC_MO_HELPER_PKG.findIndex (l_unique_measures, l_measure.fieldName, l_measure.source, l_impl_type);
	      --Copy back the unique field to the collection l_unique_measures
              If l_clstable.IsTargetTable Then
                BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt(l_temp).key_combinations
                  (BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt(l_temp).key_combinations.count) := disaggField;
	        bsc_mo_helper_pkg.writeTmp('Copy back disagg to g_unique_measures_tgt at index='||l_temp);
              Else
                BSC_METADATA_OPTIMIZER_PKG.g_unique_measures (l_temp).key_combinations
                  (BSC_METADATA_OPTIMIZER_PKG.g_unique_measures(l_temp).key_combinations.count) := disaggField;
                bsc_mo_helper_pkg.writeTmp('Copy back disagg to g_unique_measures at index='||l_temp);
              End If;
            ELSE -- disagg code is <> -1
              IF (l_clstable.isProductionTable) THEN
                l_temp := BSC_MO_HELPER_PKG.findIndex (l_unique_measures, l_measure.fieldName, l_measure.source, l_impl_type);
                If l_clstable.IsTargetTable Then
                  -- If another table requires this disagg, then we should still leave it as unregistered
                  IF BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt(l_temp).key_combinations(l_disagg_code-1).Registered = false THEN
                    null;
                  ELSE
                    BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt(l_temp).key_combinations(l_disagg_code-1).Registered := true;
		    BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt(l_temp).key_combinations(l_disagg_code-1).isProduction := true;
                  END IF;
                Else
                  IF (BSC_METADATA_OPTIMIZER_PKG.g_unique_measures (l_temp).key_combinations(l_disagg_code-1).Registered =false) THEN
                    null;
                  ELSE
                    BSC_METADATA_OPTIMIZER_PKG.g_unique_measures (l_temp).key_combinations(l_disagg_code-1).Registered := true;
                    BSC_METADATA_OPTIMIZER_PKG.g_unique_measures (l_temp).key_combinations(l_disagg_code-1).isProduction := true;
                  END IF;
                End If;
              END IF;
            End If;
          End If;
        End If;
      END LOOP;
      END IF;
    End If;
    IF length(l_stack )> 31000 THEN
      l_stack := substr(l_stack, 30000);
    END IF;
    p_tables(l_count) := l_clstable;
    EXIT WHEN l_count = p_tables.last;
    l_count := p_tables.next(l_count);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Done with init_s_table_measures, writing output now');
    BSC_MO_HELPER_PKG.writeTmp('g_unique_measures  = ');
    BSC_MO_HELPER_PKG.write_this(g_unique, BSC_METADATA_OPTIMIZER_PKG.g_unique_measures );
    BSC_MO_HELPER_PKG.writeTmp('g_unique_measures_tgt = ');
    BSC_MO_HELPER_PKG.write_this(g_Target, BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt);
    BSC_MO_HELPER_PKG.writeTmp('Completed init_s_table_measures, system time is '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in init_s_table_measures : '||sqlerrm);
	BSC_MO_HELPER_PKG.writeTmp('l_stack = '||l_stack, FND_LOG.LEVEL_UNEXPECTED, true);
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in init_s_table_measures : '||sqlerrm);
    raise;
End ;


--****************************************************************************
--  InputTables : TablasEntrada
--
--   DESCRIPTION:
--       Deduce the input tables.
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE InputTables IS
  l_counter NUMBER;
  KpiTable bsc_metadata_optimizer_pkg.clsTable;
  l_index NUMBER;
  l_error VARCHAR2(3000);
BEGIN
  BSC_MO_HELPER_PKG.writeTmp('    ', FND_LOG.LEVEL_STATEMENT, true);
  BSC_MO_HELPER_PKG.writeTmp('Inside InputTables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  --BSC-MV Note: If the indicator is not processed for structural changes and
  --the summarization level was changed from NULL to NOT NULL (upgrade)
  --then I need to get from the database the source table of the indicator and set
  --the origin in gTablas.
  --By doing this Metadata will not try to get new input, base and T tables for
  --those indicators.
  --Also add those tables to the global array garrTablesUpgradeT(). Those tables
  --will be used as start point to load all related tables from database to gTables.

  If bsc_metadata_optimizer_pkg.g_Sum_Level_Change = 1 Then
    bsc_metadata_optimizer_pkg.gnumTablesUpgradeT := 0;
    l_counter := bsc_metadata_optimizer_pkg.gTables.first;
    LOOP
      EXIT WHEN bsc_metadata_optimizer_pkg.gTables.count = 0;
      KpiTable := bsc_metadata_optimizer_pkg.gTables(l_counter);
      l_index := bsc_mo_helper_pkg.findIndex(bsc_metadata_optimizer_pkg.gIndicators, KpiTable.Indicator);
      If bsc_metadata_optimizer_pkg.gIndicators(l_index).Action_Flag <> 3 And KpiTable.originTable IS NULL Then
        set_origin_table_from_db(KpiTable);
      End If;
      bsc_metadata_optimizer_pkg.gTables(l_counter) := KpiTable;
      EXIT WHEN l_counter = bsc_metadata_optimizer_pkg.gTables.last;
      l_counter := bsc_metadata_optimizer_pkg.gTables.next(l_counter);
    END LOOP;
  End If;

    --EDW Note:
    --I don't need to do anything special to separate tables for EDW KPIs from
    --BSC Kpis because the following reasons (Actually just one of them is enough):
    --a. EDW KPIs and BSC KPIs dont share dimensions.
    --b. EDW KPIs and BSC KPIs dont share periodicities.
    --c. EDW KPIs and BSC KPIs dont share measures.
    --Initilize the list of unique measures for indicators being processed
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling init_s_table_measures');
    BSC_MO_HELPER_PKG.writeTmp('Calling init_s_table_measures', FND_LOG.LEVEL_STATEMENT, true);
    init_s_table_measures(BSC_METADATA_OPTIMIZER_PKG.gTables);

    --Initilize the list of unique measures for indicators being processed - Precalc
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling init_s_table_measures_precalc');
    BSC_MO_HELPER_PKG.writeTmp('Calling init_s_table_measures_precalc', FND_LOG.LEVEL_STATEMENT, true);
    init_s_table_measures_precalc(BSC_METADATA_OPTIMIZER_PKG.gTables);

    -- Load the existing B and T tables into memory for better optimization
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling LOAD_B_T_TABLES_FROM_DB');
    BSC_MO_HELPER_PKG.writeTmp('Calling LOAD_B_T_TABLES_FROM_DB', FND_LOG.LEVEL_STATEMENT, true);
    LOAD_B_T_TABLES_FROM_DB;

    --Resolve the origin of each dissagregation of each field
    --This is done only for non-precalculated fields
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling resolve_key_origins');
    BSC_MO_HELPER_PKG.writeTmp('Calling resolve_key_origins', FND_LOG.LEVEL_STATEMENT, true);
    resolve_key_origins (BSC_METADATA_OPTIMIZER_PKG.g_unique_measures , false);

    --Resolve the origin of each dissagregation for Targets
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling resolve_key_origins for Targets');
    BSC_MO_HELPER_PKG.writeTmp('Calling resolve_key_origins for Targets', FND_LOG.LEVEL_STATEMENT, true);
    resolve_key_origins ( BSC_METADATA_OPTIMIZER_PKG.g_unique_measures_tgt, true);

    --Make the list of temporal and base tables
    BSC_METADATA_OPTIMIZER_PKG.gMaxT := getMaxTableIndex('BSC_T_');
    BSC_METADATA_OPTIMIZER_PKG.gMaxB := getMaxTableIndex('BSC_B_');
    BSC_METADATA_OPTIMIZER_PKG.gMaxI := getMaxTableIndex('BSC_I_');
    IF (BSC_METADATA_OPTIMIZER_PKG.gMaxB>BSC_METADATA_OPTIMIZER_PKG.gMaxI) THEN
      BSC_METADATA_OPTIMIZER_PKG.gMaxI := BSC_METADATA_OPTIMIZER_PKG.gMaxB;
    ELSE
      BSC_METADATA_OPTIMIZER_PKG.gMaxB := BSC_METADATA_OPTIMIZER_PKG.gMaxI;
    END IF;
    BSC_MO_HELPER_PKG.writeTmp('gMaxT = '||BSC_METADATA_OPTIMIZER_PKG.gMaxT||', gMaxB is '||
    BSC_METADATA_OPTIMIZER_PKG.gMaxB||', gMaxI='||BSC_METADATA_OPTIMIZER_PKG.gMaxI);
    IF (bsc_metadata_optimizer_pkg.g_retcode <> 0) THEN
      return;
    END IF;
    BSC_MO_HELPER_PKG.writeTmp('Calling deduce_bt_tables - Normal', FND_LOG.LEVEL_STATEMENT, true);
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling deduce_bt_tables - Normal');
    deduce_bt_tables(False);

    BSC_MO_HELPER_PKG.writeTmp('Calling deduce_bt_tables - Targets', FND_LOG.LEVEL_STATEMENT, true);
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling deduce_bt_tables - Targets');
    deduce_bt_tables (True );--For targets

    IF (bsc_metadata_optimizer_pkg.g_retcode <> 0) THEN
      return;
    END IF;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Calling deduce_bt_tables_precalc', FND_LOG.LEVEL_STATEMENT);
    END IF;
    BSC_MO_HELPER_PKG.writeTmp('Calling deduce_bt_tables_precalc', FND_LOG.LEVEL_STATEMENT, true);
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling deduce_bt_tables_precalc');
    deduce_bt_tables_precalc;

    IF (bsc_metadata_optimizer_pkg.g_retcode <> 0) THEN
      return;
    END IF;

    --Connect base indicator tables with temporal tables
    BSC_MO_HELPER_PKG.writeTmp('Calling connect_s_to_b_tables', FND_LOG.LEVEL_STATEMENT, true);
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling connect_s_to_b_tables');
    connect_s_to_b_tables;

    --Add each temporal table to the collection of system tables
    BSC_MO_HELPER_PKG.writeTmp('Calling add_to_gtables', FND_LOG.LEVEL_STATEMENT, true);

    add_to_gtables (BSC_METADATA_OPTIMIZER_PKG.g_bt_tables);
    add_to_gtables (BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt);
    add_to_gtables (BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc);

    --Make input tables and connect them to the base tables
    BSC_MO_HELPER_PKG.writeTmp('Calling connect_i_to_b_tables', FND_LOG.LEVEL_STATEMENT, true);
    BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling connect_i_to_b_tables');
    connect_i_to_b_tables;


    --BSC-MV note: Stating from the tables in garrTablesUpgradeT()
    --we need to get all the origin tables until the input tables and
    --insert them into garrTablesUpgrade()
    --Then we need to add those tables in gTablas.
    --Loader configuration will be re-done and we need all those tables in gTablas
    If bsc_metadata_optimizer_pkg.g_Sum_Level_Change = 1 Then
        bsc_metadata_optimizer_pkg.gnumTablesUpgrade := 0;
        BSC_MO_LOADER_CONFIG_PKG.InsertOriginTables (bsc_metadata_optimizer_pkg.garrTablesUpgradeT,
                            bsc_metadata_optimizer_pkg.garrTablesUpgrade);
        bsc_metadata_optimizer_pkg.gnumTablesUpgrade := bsc_metadata_optimizer_pkg.garrTablesUpgrade.count;
        load_upgrade_tables_db;
    End If;
    BSC_MO_HELPER_PKG.writeTmp('-------------------------------------', FND_LOG.LEVEL_STATEMENT, true);
    BSC_MO_HELPER_PKG.writeTmp('Completed InputTables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in InputTables : '||l_error);
        BSC_MO_HELPER_PKG.TerminateWithError ('BSC_ITABLE_PROD_FAILED', 'InputTables');
        raise;
End ;


-- Load the metadata for the specified table into memory variables
PROCEDURE Load_Table_From_DB(p_table IN VARCHAR2, p_indicator_num NUMBER, p_dim_set NUMBER) IS

CURSOR cKeys IS
SELECT column_name
FROM
bsc_db_tables_cols cols
WHERE
cols.table_name = p_table
AND cols.column_type = 'P'
ORDER BY cols.column_name;

CURSOR cData(p_owner varchar2) IS
SELECT cols.column_name, nvl(cols.source, 'BSC'), nvl(dbcols.measure_group_id, -1)
FROM
bsc_db_tables_cols cols,
all_tab_columns tabcols,
bsc_sys_measures sysm,
bsc_db_measure_cols_vl dbcols
WHERE
cols.table_name = p_table
AND cols.table_name = tabcols.table_name
and cols.column_name = tabcols.column_name
and tabcols.owner = p_owner
AND cols.column_type = 'A'
AND cols.column_name = sysm.measure_col
AND cols.column_name = dbcols.measure_col
ORDER BY cols.column_name;

CURSOR cZeroCode (p_column in varchar2) IS
select source_column, nvl(calculation_type, 0) from
bsc_db_Tables_cols cols,
bsc_db_calculations calc
where
cols.table_name = calc.table_name (+)
and cols.table_name = p_table
and cols.column_type = 'P'
and calc.calculation_type (+)= 4
and cols.column_name = p_column;

CURSOR cOriginTables IS
SELECT source_table_name FROM
BSC_DB_TABLES_RELS
WHERE table_name=p_table;

l_stmt varchar2(1000);
l_column VARCHAR2(100);
l_source VARCHAR2(100);
l_measure_group number;

l_kpis_using_table BSC_METADATA_OPTIMIZER_PKG.tab_clsKPIDimSet ;
------------------------------------------------------------
l_key  BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
l_key_list  BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
l_source_column VARCHAR2(100);
l_calc_type NUMBER;
l_filter_view VARCHAR2(1000);
------------------------------------------------------------
l_data BSC_METADATA_OPTIMIZER_PKG.clsDataField;
l_data_list BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
------------------------------------------------------------
l_index NUMBER := 0;
l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
l_optimizationMode NUMBER;
l_src_table VARCHAR2(100);
l_state varchar2(4000);

BEGIN
  bsc_mo_helper_pkg.writeTmp('Loading table '||p_table||' '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, false);
  l_kpis_using_table := BSC_MO_HELPER_PKG.find_objectives_for_table(p_table);
  IF (l_kpis_using_table.count=0) THEN
    return;
  END IF;
  bsc_mo_helper_pkg.writeTmp('# of objectives using this table= '||l_kpis_using_table.count||' '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, false);
  OPEN cKeys;
  LOOP
    FETCH cKeys INTO l_column;
    EXIT WHEN cKeys%NOTFOUND;
    l_key.tableName := p_table;
    l_key.keyName := l_column;
    -- find out source column and zero code requirement
    OPEN cZeroCode(l_column);
    FETCH cZeroCode INTO l_source_column, l_calc_type;
    CLOSE cZeroCode;
    l_key.origin := l_source_column;
    IF (l_calc_type=4) THEN
      l_key.needsCode0 := true;
      l_key.calculateCode0 := true;
    END IF;
	-- find out if filters exist
    IF BSC_MO_HELPER_PKG.filters_exist(
                      l_kpis_using_table(0).kpi_number,
                      l_kpis_using_table(0).dim_set_id,
                      l_column,
                      l_filter_view ) THEN
      l_key.filterViewName := l_filter_view;
    END IF;
    l_key_list(l_key_list.count) := l_key;
  END LOOP;
  CLOSE cKeys;
  l_state := 'Loaded keys '||bsc_mo_helper_pkg.get_time;
  -- now onto the measure columns
  OPEN cData(bsc_metadata_optimizer_pkg.gBSCSchema);
  LOOP
    FETCH cData INTO l_column, l_source, l_measure_group;
    EXIT WHEN cData%NOTFOUND;
    l_data.tableName := p_table;
    l_data.fieldName := l_column;
    l_data.source := l_source;
    l_data.InternalColumnType := 0;
    l_data.measureGroup := l_measure_group;

    l_data_list(l_data_list.count) := l_data;
  END LOOP;
  CLOSE cData;
  l_state := l_state||' Loaded Data.count= '||l_data_list.count;
  l_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, l_kpis_using_table(0).kpi_number);
  IF (l_index <> -1) THEN
    l_optimizationMode := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index).optimizationMode ;
  ELSE
    l_optimizationMode := BSC_MO_HELPER_PKG.getKPIPropertyValue(l_kpis_using_table(0).kpi_number, 'DB_TRANSFORM', 1);
  END IF;
  l_table.Name := p_table;
  l_table.Type := 1;--  base, temporal or summary
  l_table.keys := l_key_list;
  l_table.data := l_data_list;
  l_table.Periodicity  := BSC_MO_HELPER_PKG.getPeriodicityForTable(p_table);
  l_table.originTable	:= null;--BSC_MO_HELPER_PKG.getSourceTable(p_table);
  l_table.Indicator := l_kpis_using_table(0).kpi_number;
  l_table.Configuration 	:= l_kpis_using_table(0).dim_set_id;
  l_table.EDW_Flag 	    := 0;
  l_table.IsTargetTable := false;
  l_table.HasTargets 	:= false;
  l_table.UsedForTargets := false;
  l_table.upgradeFlag  := 0;
  if (l_data_list.count>0) then
    l_table.measureGroup := l_data_list(l_data_list.first).measureGroup;
  else
    l_table.measureGroup := get_measure_group(p_table, l_data_list, p_indicator_num, p_dim_set);
  end if;
  bsc_mo_helper_pkg.writeTmp('measure group = '||l_table.measureGroup);
  -- Important, flag that this is as a production table, so it isnt dropped and recreated !
  l_table.isProductionTable := true;
  l_table.isProductionTableAltered := false;
  l_state := l_state || '  Loaded other properties ';
  FOR i IN cOriginTables LOOP
    l_table.originTable := l_table.originTable||i.source_table_name||',';
  END LOOP;
  IF l_table.originTable IS NOT NULL THEN
    l_table.originTable := substr(l_table.originTable, 1, length(l_table.originTable)-1);
  END IF;
  l_state:= l_state||' Loaded origin tables ';

  -- For AW
  IF (bsc_mo_helper_pkg.getKPIPropertyValue(l_table.Indicator, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1) = 2) THEN
    l_table.impl_type := 2;
  ELSE
    l_table.impl_type := 1;
  END IF;
  IF (l_optimizationMode = 0 ) THEN -- precalc
    l_state:=l_state|| '
'||' Adding table '||p_table||' to g_bt_tables_precalc';
    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc.count) := l_table;
  ELSIF  (  l_optimizationMode = 2 ) THEN -- targets
    l_state := l_state||'
'||'Adding table '||p_table||'  to g_bt_tables_tgt';
    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt.count) := l_table;
  ELSE
    l_state:=l_state||'
'||'Adding table  '||p_table||' to g_bt_tables';
    BSC_METADATA_OPTIMIZER_PKG.g_bt_tables(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables.count) := l_table;
  END IF;
  l_state := l_state||'
Loaded table '||p_table;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.writeTmp('state = '||l_state, FND_LOG.LEVEL_EXCEPTION, true);
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Load_Table_From_DB : '||sqlerrm);

    BSC_MO_HELPER_PKG.terminateWithError('BSC_RETR_TTABLES_FAILED', 'Load_Table_From_DB');
	raise;
END;

FUNCTION is_production_table(p_table_name IN VARCHAR2, p_indicator OUT NOCOPY NUMBER, p_dim_set OUT NOCOPY NUMBER) return boolean
IS
l_stmt VARCHAR2(1000) ;
cv   CurTyp;
BEGIN
  l_stmt :=
  '  select kpi.indicator, tmp.dim_set_id
       from  bsc_kpis_vl kpi,
          (
             select substr(table_name, instr(table_name, ''_'', 1, 2)+1,
                         instr(table_name, ''_'', 1, 3)-instr(table_name, ''_'', 1, 2)-1) indicator,
                    substr(table_name, instr(table_name, ''_'', 1, 3)+1,
                         instr(table_name, ''_'', 1, 4)-instr(table_name, ''_'', 1, 3)-1) dim_set_id
               from bsc_db_tables_rels
              where table_name like ''BSC_S%''
            connect by prior  table_name = source_table_name
              start with source_table_name = :1
          ) tmp
      where kpi.indicator = tmp.indicator
        and prototype_flag not in (2,3) -- no need for 4 as the B table typically doesnt get dropped for 4
        and kpi.share_flag<>2
        and rownum=1';
  OPEN cv FOR l_stmt USING p_table_name;
  FETCH cv INTO p_indicator, p_dim_set;
  CLOSE cv;
  IF (p_indicator is not null) THEN -- atleast one production table is using this
    return true;
  ELSE
    return false;
  END IF;
END;
-- Load the production tables which have measures belonging to indicators
-- in the current metadata run
PROCEDURE LOAD_B_T_TABLES_FROM_DB IS
  inMeasures VARCHAR2(1000);
  cv   CurTyp;
  l_table VARCHAR2(100);
  l_src_table VARCHAR2(100);
  i NUMBER;
  l_stmt VARCHAR2(1000);
  l_indicator_num number;
  l_dim_set number;
BEGIN
  BSC_MO_HELPER_PKG.writeTmp('Inside LOAD_B_T_TABLES_FROM_DB, system time is '||
            bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  l_stmt := 'select distinct table_name from bsc_db_tables where (table_name like ''BSC_B%'' or table_name like ''BSC_T%'' ) and table_type=1';
  OPEN cv FOR l_stmt ;
  LOOP
    FETCH cv INTO l_table;
    EXIT WHEN cv%NOTFOUND;
    IF is_production_table(l_table, l_indicator_num, l_dim_set) THEN
      BSC_MO_HELPER_PKG.writeTmp('Loading production table '||l_table||' into memory '||BSC_MO_HELPER_PKG.get_time, FND_LOG.LEVEL_PROCEDURE, false);
      Load_Table_From_DB(l_table, l_indicator_num, l_dim_set);
    END IF;
  END LOOP;

  -- Intialize the disaggregations in the Production tables - Targets
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling init_s_table_measures for Production tables - Targets');
  BSC_MO_HELPER_PKG.writeTmp('Calling init_s_table_measures for Production tables - Targets', FND_LOG.LEVEL_STATEMENT, true);
  init_s_table_measures(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt);

  -- Intialize the disaggregations in the Production tables
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling init_s_table_measures for Production tables - Normal');
  BSC_MO_HELPER_PKG.writeTmp('Calling init_s_table_measures for Production tables - Normal', FND_LOG.LEVEL_STATEMENT, true);
  init_s_table_measures(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables);

  -- Intialize the disaggregations in the Production tables - precalc
  BSC_METADATA_OPTIMIZER_PKG.logProgress('INPUT', 'Calling init_s_table_measures_precalc for Production tables');
  BSC_MO_HELPER_PKG.writeTmp('Calling init_s_table_measures_precalc for Production tables', FND_LOG.LEVEL_STATEMENT, true);
  init_s_table_measures_precalc(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_precalc);

  BSC_MO_HELPER_PKG.writeTmp('Completed LOAD_B_T_TABLES_FROM_DB, system time is '||
            bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE, true);
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in LOAD_B_T_TABLES_FROM_DB : '||sqlerrm);
    BSC_MO_HELPER_PKG.terminateWithError('BSC_RETR_TTABLES_FAILED', 'LOAD_B_T_TABLES_FROM_DB');
	raise;
END;

END BSC_MO_INPUT_TABLE_PKG ;

/
