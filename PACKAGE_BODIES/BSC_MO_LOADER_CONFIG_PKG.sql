--------------------------------------------------------
--  DDL for Package Body BSC_MO_LOADER_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_LOADER_CONFIG_PKG" AS
/* $Header: BSCMOCFB.pls 120.9 2006/02/24 13:33:59 arsantha noship $ */

g_newline VARCHAR2(10) := '
';

--****************************************************************************
--  isBasicTable
--
--    DESCRIPTION:
--       Retunr TRUE if the table is a base table. It means that the table
--       is originated from an input table.
--
--    PARAMETERS:
--       NomTabla: Table name
--****************************************************************************
Function isBasicTable(p_table_name IN VARCHAR2) RETURN Boolean IS
l_temp NUMBER;
l_temp2 NUMBER;

l_origin_table DBMS_SQL.VARCHAR2_TABLE;

l_origin_name VARCHAR2(100);
CURSOR cTableType IS
select count(1)
from bsc_db_tables tbl,
bsc_db_tables_rels rels
where
rels.table_name = p_table_name
and rels.source_table_name = tbl.table_name
and tbl.table_type = 0;

l_table_type NUMBER;
BEGIN
  l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, p_table_name);
  If l_temp <> -1 AND BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp).originTable IS NOT NULL Then
    l_origin_table := BSC_MO_HELPER_PKG.getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp).originTable, ',');
    l_origin_name := l_origin_table(l_origin_table.first);
    l_temp2 := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, l_origin_name);
    IF (l_temp2 = -1) THEN
      OPEN cTableType;
      FETCH cTableType INTO l_table_type ;
      CLOSE cTableType;
      IF (l_table_type=0) THEN
        return false;
      ELSE
        return true;
      END IF;
    END IF;
    If BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp2).Type = 0 Then
      return true;
    Else
      return False;
    End If;
  Else--Added for alterations to production tables
     OPEN cTableType;
     FETCH cTableType INTO l_table_type ;
     CLOSE cTableType;
     IF (l_table_type=0) THEN
       return false;
     ELSE
        return true;
     END IF;
     return False;
  End If;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in isBasicTable:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.writeTmp('p_table_name = '||p_table_name||', l_temp = '||l_temp, FND_LOG.LEVEL_STATEMENT, true);
  	raise;
End ;

--****************************************************************************
--  GetPhantomLevelPosition
--
--  DESCRIPTION:
--     Returns the position of the given phantom drill within the collection
--     of drills families.
--
--  PARAMETERS:
--     colDimensions: collection of drills families
--     p_level_code: drill code
--****************************************************************************
Function GetPhantomLevelPosition(colDimensions IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels, p_level_code IN NUMBER) RETURN NUMBER IS
  posicion NUMBER;
  l_levels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
  l_level BSC_METADATA_OPTIMIZER_PKG.clsLevels;
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_groups DBMS_SQL.NUMBER_TABLE;
BEGIN
  posicion := 0;
  IF (colDimensions.count =0 ) THEN
      return posicion;
  END IF;
  l_groups := BSC_MO_HELPER_PKG.getGroupIds(colDimensions);
  l_index1 := l_groups.first;

  LOOP
      l_levels := BSC_MO_HELPER_PKG.get_tab_clsLevels(colDimensions, l_groups(l_index1));
      IF (l_levels.count >0) THEN
        l_index2 := l_levels.first;
      END IF;
      LOOP
        EXIT WHEN l_levels.count = 0;
        l_level := l_levels(l_index2);

        If p_level_code <= l_level.Num Then
          return posicion;
        End If;
        posicion := posicion + 1;
        EXIT WHEN l_index2 = l_levels.last;
        l_index2 := l_levels.next(l_index2);
      END LOOP;
      EXIT WHEN l_index1 = l_groups.last;
      l_index1 := l_groups.next(l_index1);
  END LOOP;
  return posicion;

  EXCEPTION WHEN OTHERS THEN
	bsc_mo_helper_pkg.writeTmp('Exception in GetPhantomLevelPosition:'||sqlerrm, FND_LOG.LEVEL_STATEMENT, true);
	raise;
End ;


--****************************************************************************
--  GetPhantomLevels
--
--  DESCRIPTION:
--     Returns phantom levels of the given indicator and given configuration
--  PARAMETERS:
--     Indicator: indicator code
--     Configuracion: indicator configuration
--     arrPhantomLevels(): array to return phantom drills
--****************************************************************************
Function GetPhantomLevels(pIndicator IN NUMBER,
                  Configuracion IN NUMBER,
                  arrPhantomLevels IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE) RETURN NUMBER IS
  numPhantomLevels NUMBER;
  l_stmt VARCHAR2(1000);

  l_level NUMBER;
  CURSOR C1 is
  SELECT DISTINCT DIM_LEVEL_INDEX FROM BSC_KPI_DIM_LEVELS_B
  WHERE INDICATOR = pIndicator
  AND DIM_SET_ID = Configuracion
  AND STATUS <> 2
  ORDER BY DIM_LEVEL_INDEX;
BEGIN
  OPEN c1;
  numPhantomLevels := 0;
  LOOP
      FETCH c1 INTO l_level;
      EXIT WHEN c1%NOTFOUND;
      arrPhantomLevels(numPhantomLevels) := l_level;
      numPhantomLevels := numPhantomLevels + 1;
  END Loop;
  Close c1;
  Return numPhantomLevels;

  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in GetPhantomLevels:'||sqlerrm, FND_LOG.LEVEL_STATEMENT, true);
    raise;
End;

--****************************************************************************
--  Corrections : CorreccionDrilesFantasmas
--
--  DESCRIPTION:
--     Completes the configuration of drills for the phantom drills with '?'
--****************************************************************************
PROCEDURE Corrections IS

  Indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
  colConfiguraciones DBMS_SQL.NUMBER_TABLE ;
  Configuracion NUMBER;
  colDimensions BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels;
  l_stmt VARCHAR2(1000);
  numPhantomLevels NUMBER;
  arrPhantomLevels DBMS_SQL.NUMBER_TABLE;
  i NUMBER;
  strDriles VARCHAR2(1000);
  strDrilesAnt VARCHAR2(1000);
  levelPos NUMBER;
  l_periodicity_id NUMBER;

  l_index1 NUMBER;
  l_index2 NUMBER;
  cv CurTyp ;

  CURSOR cLevelCombinations (pIndicator IN NUMBER, pDimSetID IN NUMBER) IS
  SELECT PERIODICITY_ID, LEVEL_COMB
  FROM BSC_KPI_DATA_TABLES
  WHERE INDICATOR = pIndicator
  AND DIM_SET_ID = pDimSetID;
BEGIN
  IF (BSC_METADATA_OPTIMIZER_PKG.gIndicators.count =0) THEN
    return;
  END IF;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
  LOOP
    Indicator := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index1);
    --Consider only new indicators or changed indicators
    --BSC-MV Note: If there is change of summarization level
    --we need to process all the indicators.
    If (Indicator.Action_Flag = 3) Or (Indicator.Action_Flag <> 2 And BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0) Then
      --Get the list of configurations of the kpi
      colConfiguraciones := BSC_MO_INDICATOR_PKG.GetConfigurationsForIndic(Indicator.Code);
      IF (colConfiguraciones.count > 0) THEN
      l_index2 := colConfiguraciones.first;
      END IF;
      LOOP
        EXIT WHEN colConfiguraciones.count = 0;
        Configuracion := colConfiguraciones(l_index2);
        numPhantomLevels := GetPhantomLevels(Indicator.Code, Configuracion, arrPhantomLevels);
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp('# of phantom levels = '||numPhantomLevels);
        END IF;
        If numPhantomLevels > 0 Then
          --Get the list of drills of the kpi in the given configuration
          colDimensions := BSC_MO_INDICATOR_PKG.GetLevelCollection(Indicator.Code, Configuracion);
          If colDimensions.Count > 0 Then
            --Only fix those having at least one family of drills
            --l_stmt := 'SELECT PERIODICITY_ID, LEVEL_COMB FROM BSC_KPI_DATA_TABLES WHERE INDICATOR = :1 AND DIM_SET_ID = :2';
            OPEN cLevelCombinations(Indicator.Code, Configuracion);
            LOOP
              FETCH cLevelCombinations INTO l_periodicity_id, strDriles;
              EXIT WHEN cLevelCombinations%NOTFOUND;
              strDrilesAnt := strDriles;
              For i IN 0..numPhantomLevels - 1 LOOP
                levelPos := GetPhantomLevelPosition(colDimensions, arrPhantomLevels(i)) + i;

                strDriles := substr(strDriles, 1, levelPos) || '?'||
                            substr(strDriles, levelPos - Length(strDriles) );
              END LOOP;

              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp('UPDATE BSC_KPI_DATA_TABLES SET LEVEL_COMB = '||
                  strDriles||' WHERE INDICATOR =  '|| Indicator.Code||' AND DIM_SET_ID =  '||
                  Configuracion||' AND PERIODICITY_ID =  '|| l_periodicity_id||' AND LEVEL_COMB = '||strDrilesAnt, FND_LOG.LEVEL_STATEMENT);
              END IF;

              UPDATE BSC_KPI_DATA_TABLES SET LEVEL_COMB = strDriles
              WHERE INDICATOR = Indicator.Code AND DIM_SET_ID = Configuracion
              AND PERIODICITY_ID = l_periodicity_id  AND LEVEL_COMB = strDrilesAnt;
              --EXECUTE IMMEDIATE l_stmt USING strDriles, Indicator.Code, Configuracion, l_periodicity_id, strDrilesAnt;

            END Loop;
            CLOSE cLevelCombinations;
          End If;
        End If;
        EXIT WHEN l_index2 = colConfiguraciones.last;
        l_index2 := colConfiguraciones.next(l_index2);
      END LOOP;
    End If;
    EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(l_index1);
  END LOOP;

  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in Corrections : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
	bsc_mo_helper_pkg.terminateWithError('BSC_DIMCONFIG_FAILED', 'Corrections');
  RAISE;

End ;


--****************************************************************************
--  RecreateMaterializedViewsIndic
--
--  DESCRIPTION:
--     Recreate the materialized view for the given indicator
--     The indicator is a EDW Kpi.
--****************************************************************************
PROCEDURE ReCreateMaterializedViewsIndic(Indic in number) IS
   l_STMT VARCHAR2(300);
   uv_name VARCHAR2(300);
   table_name VARCHAR2(300);
   periodicity_id NUMBER;
   cal_id NUMBER;
   num_years NUMBER;
   num_prev_years NUMBER;
   fiscal_year NUMBER;
   start_year NUMBER;
   end_year NUMBER;

  CURSOR c1 IS
  SELECT DISTINCT TABLE_NAME, PERIODICITY_ID
  FROM BSC_KPI_DATA_TABLES_V
  WHERE INDICATOR = indic
  AND TABLE_NAME IS NOT NULL;
  l_temp NUMBER;
BEGIN
  --Populate mapping tables for the indicator before create materialized views
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside ReCreateMaterializedViewsIndic', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  --l_stmt := 'begin BSC_INTEGRATION_APIS.Populate_Mapping_Tables('|| Indic ||'); end;';
  --EXECUTE IMMEDIATE l_stmt;
  -- Obsoleted
  --BSC_INTEGRATION_APIS.Populate_Mapping_Tables(Indic);

  OPEN c1;

  LOOP
    FETCH c1 INTO table_name, periodicity_id;
    EXIT WHEN c1%NOTFOUND;
    --Create the materialized view
    l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, periodicity_id);

    cal_id := BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp).CalendarID;
    l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gCalendars, cal_id);
    num_years := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp).NumOfYears;
    num_prev_years := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp).PreviousYears;
    fiscal_year := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp).CurrFiscalYear;

    start_year := fiscal_year - num_prev_years;
    end_year := start_year + num_years - 1;

    --Create the union view
    --We have to recreate the union view because the materializaed
    --view is invalid until loader refresh it
    uv_name := table_name || BSC_METADATA_OPTIMIZER_PKG.EDW_UNION_VIEW_EXT;
    l_stmt := 'CREATE OR REPLACE VIEW '||  uv_name ||' AS SELECT * FROM '||  table_name;
    BSC_MO_HELPER_PKG.do_ddl(l_stmt, ad_ddl.create_view, uv_name);

  END Loop;
  CLOSE C1;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed ReCreateMaterializedViewsIndic', FND_LOG.LEVEL_PROCEDURE);
  END IF;

  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in ReCreateMaterializedViewsIndic : '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.terminateWithMsg('Exception in ReCreateMaterializedViewsIndic : '||sqlerrm);
    raise;
End ;


--****************************************************************************
--  CalcProjectionTable
--
--  DESCRIPTION:
--   Return true if the projection is calculated on the table
--****************************************************************************

Function CalcProjectionTable(TableName IN VARCHAR2) return BOOLEAN IS

CURSOR C1(p1 VARCHAR2) IS
SELECT PROJECT_FLAG FROM BSC_DB_TABLES
WHERE TABLE_NAME = p1;
l_proj NUMBER ;
l_ret  boolean;
BEGIN
  OPEN C1( Upper(tablename));
  FETCH c1 INTO l_proj;

  IF (c1%NOTFOUND) THEN
    l_ret := FALSE;
  Else
    If l_proj = 0 Then
      l_ret := false;
    Else
      l_ret := true;
    End If;
  End If;

  close c1;
  return l_ret;

  EXCEPTION WHEN OTHERS THEN
   bsc_mo_helper_pkg.writeTmp('Exception in CalcProjectionTable:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
   raise;
End;


--****************************************************************************
--  GetIndicTableType
--
--  DESCRIPTION:
--     Return the type of the table according to BSC_DB_TABLES_RELS and BSC_DB_TABLES
--     arrIndicTables() contains the tables used directly by the indicator
--     0 - Input table
--     1 - Base table
--     2 - Temporal Table
--     3 - Indicator table (lowest level)
--     4 - Indicator table (summary level)
--****************************************************************************
Function GetIndicTableType(TableName IN VARCHAR2,
                  arrIndicTables IN DBMS_SQL.VARCHAR2_TABLE,
                  numIndicTables IN NUMBER) RETURN NUMBER IS
  l_table_name VARCHAR2(100);
  l_table_type NUMBER;
  CURSOR c1(p1 VARCHAR2) IS
  SELECT T.TABLE_NAME, T.TABLE_TYPE
  FROM BSC_DB_TABLES T, BSC_DB_TABLES_RELS R
  WHERE T.TABLE_NAME = R.SOURCE_TABLE_NAME
  AND R.TABLE_NAME = p1;
  l_return NUMBER;
BEGIN
  OPEN c1 (UPPER(TableName));
  FETCH c1 INTO l_table_name, l_table_type;
  IF (c1%NOTFOUND) THEN
    l_return := 0; -- input table
  Else
    If (l_table_type) = 0 Then
      l_return := 1; -- base table
    Else
      If BSC_MO_HELPER_PKG.findIndexVARCHAR2(arrIndicTables, TableName)>-1 Then
        If BSC_MO_HELPER_PKG.findIndexVARCHAR2(arrIndicTables, l_table_name)=-1 Then
          l_return := 3; -- Indicator table (lowest level)
        Else
          l_return := 4; -- Indicator table (summary level)
        End If;
      Else
        l_return := 2; -- temporal table
      End If;
    End If;
  End If;
  CLOSE C1;
  return l_return;

  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in GetIndicTableType:'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
End ;


--****************************************************************************
--  InsertOriginTables
--
--  DESCRIPTION:
--     Insert in the arry arrOriginTables() all the tables in the graph
--     where the tables in the array arrTables() come from, including
--     themself.
--****************************************************************************
PROCEDURE InsertOriginTables(arrTables IN DBMS_SQL.VARCHAR2_TABLE ,
                  arrOriginTables IN OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE
                  ) IS

  arrTablesAux DBMS_SQL.VARCHAR2_TABLE;
  l_stmt  VARCHAR2(2000) := null;

  l_table VARCHAR2(100);
  l_index NUMBER;
  cv CurTyp ;

  strWhereInTables VARCHAR2(1000);
  l_varchar2_list dbms_sql.varchar2_table;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside InsertOriginTables, arrTables.count = '||arrTables.count);
  END IF;

  IF (arrTables.count = 0) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Completed InsertOriginTables, count = 0');
    END IF;
    return;
  END IF;

  strWhereInTables := BSC_MO_HELPER_PKG.Get_New_Big_In_Cond_Varchar2(1, 'TABLE_NAME');
  l_index := arrTables.first;

  LOOP
    EXIT WHEN arrTables.count = 0;
    If Not BSC_MO_HELPER_PKG.searchStringExists(arrOriginTables, arrOriginTables.count, arrTables(l_index)) Then
          arrOriginTables(arrOriginTables.count) := arrTables(l_index);
          l_varchar2_list(l_varchar2_list.count+1) := arrTables(l_index);
          --BSC_MO_HELPER_PKG.Add_Value_Big_In_Cond_Varchar2 (1, arrTables(l_index));
    End If;
    EXIT WHEN l_index = arrTables.last;
    l_index := arrTables.next(l_index);
  END LOOP;
  bsc_mo_helper_pkg.add_value_bulk(1, l_varchar2_list);
  l_varchar2_list.delete;
  l_stmt := 'SELECT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS WHERE '|| strWhereInTables;
  OPEN CV for l_stmt;
  LOOP
    FETCH CV INTO l_table;
    EXIT WHEN CV%NOTFOUND;
    arrTablesAux(arrTablesAux.count ) := l_table;
  END Loop;
  Close CV;

  InsertOriginTables (arrTablesAux, arrOriginTables);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed InsertOriginTables, arrOriginTables.count = '||arrOriginTables.count);
  END IF;


  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in InsertOriginTables:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    raise;
End;


--****************************************************************************
--  InitarrTablesIndic
--
--  DESCRIPTION:
--     Initialize the array arrIndicTables() with the tables used directly
--     by the indicator in the given configuration.
--     Also initializes arrTables() with the tables being used directly
--     by the indicator and all related tables until the input tables.
--****************************************************************************
PROCEDURE InitarrTablesIndic(Indic IN NUMBER, Configuration IN NUMBER,
               arrTables OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE, numTables OUT NOCOPY NUMBER,
               arrIndicTables OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE, numIndicTables OUT NOCOPY NUMBER) IS

  l_STMT VARCHAR2(1000);
  CURSOR C1 (p1 NUMBER, p2 NUMBER) IS
  SELECT DISTINCT TABLE_NAME FROM BSC_KPI_DATA_TABLES_V
  WHERE INDICATOR = p1
  AND DIM_SET_ID = p2
  AND TABLE_NAME IS NOT NULL;

  CURSOR c2 (p1 NUMBER, p2 NUMBER) IS
  SELECT DISTINCT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS
  WHERE TABLE_NAME IN (
  SELECT TABLE_NAME
  FROM BSC_KPI_DATA_TABLES_V
  WHERE INDICATOR = p1
  AND DIM_SET_ID = p2
  AND TABLE_NAME IS NOT NULL)
  AND RELATION_TYPE = 1;

  l_table VARCHAR2(100);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside InitarrTablesIndic');
  END IF;
  numTables := 0;
  numIndicTables := 0;

  OPEN c1(Indic, Configuration);

  LOOP
    FETCH c1 INTO l_table;
    EXIT WHEN c1%NOTFOUND;
    arrIndicTables(numIndicTables) := l_table;
    numIndicTables := numIndicTables + 1;
  END Loop;
  CLOSE c1;

  --Insert in the array arrIndicTables() the indicator tables created for targets (BSC_SB_<kpi code>_%)
  --We need to consider them as tables used directly by the indicator

  OPEN c2(Indic, Configuration);

  LOOP
    FETCH c2 INTO l_table;
    EXIT WHEN c2%NOTFOUND;
    arrIndicTables(numIndicTables) := l_table;
    numIndicTables := numIndicTables + 1;
  END Loop;
  InsertOriginTables( arrIndicTables, arrTables);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed InitarrTablesIndic');
  END IF;

  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in InitarrTablesIndic:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    raise;
End ;



--****************************************************************************
--  NumeroDrilIndic
--  DESCRIPTION:
--     Returns the drill index of the given drill, configuration and indicator
--  PARAMETERS:
--     CodIndic: indicator code
--     Configuracion: indicator configuration
--     NomDril: drill name
--****************************************************************************
Function getLevelIndex(CodIndic IN NUMBER, Configuracion IN NUMBER, NomDril IN VARCHAR2) RETURN NUMBER IS

l_STMT VARCHAR2(1000);
l_ret NUMBER := -1;
CURSOR C1 (p1 NUMBER, p2 NUMBER, p3 VARCHAR2) IS
SELECT DIM_LEVEL_INDEX FROM BSC_KPI_DIM_LEVELS_B
WHERE
INDICATOR = p1 AND
DIM_SET_ID = p2 AND
LEVEL_PK_COL = p3;
BEGIN

  OPEN c1(CodIndic, Configuracion, UPPER(nomDril));

  FETCH c1 INTO l_ret;
  CLOSE c1;
  return l_ret;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in getLevelIndex:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    raise;
End;


PROCEDURE get_projection_and_gen_type(
  Tabla BSC_METADATA_OPTIMIZER_PKG.clsTable,
  PeriodicityOrigin IN NUMBER,
  p_projection OUT NOCOPY NUMBER,
  p_gen_type OUT NOCOPY NUMBER) IS
  Tabla_originTable DBMS_SQL.VARCHAR2_TABLE;
  Tabla_originTable1 DBMS_SQL.VARCHAR2_TABLE;
  l_index2 number;
  l_temp number;
  l_table_origin VARCHAR2(100);

BEGIN
    If Tabla.Type = 0 Then
      p_gen_type := 0;
      p_projection := 0;
    Else
      --BSC-MV Note: generation_type will means:
      --  1: The table exists, calculate the table from source tables
      --   -1: the table do not exists
      If BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV Then
        If isBasicTable(Tabla.Name) Then
          p_gen_type := 1;
        Else
          --In BSC-MV implementation none of the summary tables exists.
          --There are projection tables (when targets at different levels
          --but they are not the same summary tables.
          p_gen_type := -1;
        End If;
      Else
        p_gen_type := 1;
      End If;
      --If the table is only for targets, then this table is not projected.
      If Tabla.IsTargetTable Then
        p_projection := 0;
      Else
        If Tabla.EDW_Flag = 0 Then
          --Table is for a BSC KPI
          p_projection := 0;
          If isBasicTable(Tabla.Name) Then
            p_projection := 1;
          Else
            --BSC-MV Note: In this architecture we only calculate projection
            --on tables receiving directly targets (targets at different level)
            If Not BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV Then
              l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, Tabla.Periodicity);
              If (BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp).Yearly_Flag = 1) And
                (Tabla.Periodicity <> PeriodicityOrigin) Then
                p_projection := 1;
              End If;
            End If;
          End If;
        End If;
        --If any of the source tables (soft relations) is a target table then we need to proyect this table.
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp('Checking Soft Relations');
        END IF;
        IF (Tabla.originTable1 IS NOT NULL) THEN
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            bsc_mo_helper_pkg.writeTmp('Tabla.originTable1 is not null');
          END IF;
          Tabla_originTable1 := BSC_MO_HELPER_PKG.getDecomposedString(Tabla.originTable1, ',');
          l_index2 := Tabla_originTable1.first;
          LOOP
            l_table_origin := Tabla_originTable1(l_index2);
            l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, l_table_origin);
            If BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp).IsTargetTable Then
              p_projection := 1;
              Exit;
            End If;
            EXIT WHEN l_index2 = Tabla_originTable1.last;
            l_index2 := Tabla_originTable1.next(l_index2);
          END LOOP;
        END IF;
      End If;--If Tabla.IsTargetTable Then
    End If;--Tabla.Type = 0 Then
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in get_projection_and_gen_type:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    raise;

END;

PROCEDURE add_dependant_tables(p_del_s_tables IN dbms_sql.varchar2_table, p_del_tables IN OUT NOCOPY dbms_sql.varchar2_table )is

l_dummy varchar2(1000);

cursor MissingSTables IS
select table_name from bsc_db_Tables_rels
connect by source_table_name = prior table_name
start with source_table_name in
(
select value_v from bsc_tmp_big_in_cond
where variable_id=10
and session_id = userenv('SESSIONID')
)
union -- add deleted periodicities
select table_name from bsc_db_tables_rels
where substr(table_name, 1, instr(table_name, '_', -1)) in
   (select substr(value_v, 1, instr(value_v, '_', -1))
      from bsc_tmp_big_in_cond
     where variable_id = 10
       and session_id=userenv('SESSIONID')
   )
;

begin
  IF (p_del_s_tables.count=0) then
    return;
  END IF;
  l_dummy := BSC_MO_HELPER_PKG.Get_New_Big_In_Cond_Varchar2(10, 'SOURCE_TABLE_NAME');
  bsc_mo_helper_pkg.add_value_bulk(10, p_del_s_tables);
  for i in MissingSTables loop
    p_del_tables(p_del_tables.count+1) := i.table_name;
  end loop;
  return;
end;

--****************************************************************************
--  ConfigurarActualizacion
--
--  DESCRIPTION:
--     Configure metadata tables for Loader.
--****************************************************************************
PROCEDURE ConfigureActualization IS
  Tabla BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  l_table_origin VARCHAR2(100);
  l_stmt VARCHAR2(1000);
  Indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
  l_generation_type NUMBER := 0;
  projection NUMBER := 0;
  arrZeroCodeKeys DBMS_SQL.VARCHAR2_TABLE;
  numZeroCodeKeys NUMBER := 0;
  l_prj_method NUMBER := 0;
  ZeroCodeOrigin VARCHAR2(300);
  Periodo_Act NUMBER := 0;
  SubPeriodo_Act NUMBER := 0;
  EDW_Flag NUMBER := 0;
  Dril1 VARCHAR2(300);
  --MaestraDril1 VARCHAR2(300);
  --Desag_Oper VARCHAR2(300);
  --Operadores VARCHAR2(300);
  i NUMBER := 0;
  PeriodicityOrigin NUMBER := 0;
  OriTableName VARCHAR2(300);
  Calendar_id NUMBER := 0;
  num_years VARCHAR2(300);
  num_prev_years VARCHAR2(300);
  fiscal_year NUMBER := 0;
  Target_Flag NUMBER := 0;
  l_index1 NUMBER := 0;
  l_index2 NUMBER := 0;
  l_index3 NUMBER := 0;
  l_temp   NUMBER := 0;
  l_tempv varchar2(1000);

  Tabla_originTable DBMS_SQL.VARCHAR2_TABLE;
  Tabla_originTable1 DBMS_SQL.VARCHAR2_TABLE;
  Tabla_keyName BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  Tabla_Data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;

  l_dump DBMS_SQL.VARCHAR2_TABLE;
  l_dumpcount NUMBER := 0;

  -- Added 08/23/2005 for performance bug 4559323
  l_tbl_delete dbms_sql.varchar2_table;
  l_tblrels_table_name dbms_sql.varchar2_table;
  l_tblrels_src_table_name dbms_sql.varchar2_table;
  l_tblrels_relation_type dbms_sql.number_table;

  TYPE tab_clsRels IS TABLE OF BSC_DB_TABLES_RELS%ROWTYPE index by binary_integer;
  l_rels_record BSC_DB_TABLES_RELS%ROWTYPE ;
  l_tab_rels tab_clsRels;

  TYPE tab_clsDBTables IS TABLE OF BSC_DB_TABLES%ROWTYPE index by binary_integer;
  l_db_tables_record BSC_DB_TABLES%ROWTYPE ;
  l_tab_db_tables tab_clsDBTables;

  TYPE tab_clsDBCalculations IS TABLE OF BSC_DB_CALCULATIONS%ROWTYPE index by binary_integer;
  l_db_calculations_record BSC_DB_CALCULATIONS%ROWTYPE ;
  l_tab_db_calculations tab_clsDBCalculations;

  TYPE tab_clsDBTablesCols IS TABLE OF BSC_DB_TABLES_COLS%ROWTYPE index by binary_integer;
  l_db_tables_cols_record BSC_DB_TABLES_COLS%ROWTYPE ;
  l_tab_db_tables_cols tab_clsDBTablesCols;

  l_db_calc_1_delete dbms_sql.varchar2_table;

  l_db_cols_1_delete_table_name dbms_sql.varchar2_table;
  l_db_cols_1_delete_field_name dbms_sql.varchar2_table;

  l_calc4 number := 4;
  l_calc5 number := 5;
  l_colP varchar2(1) := 'P';
  l_colA varchar2(1) := 'A';

  l_dep_tables dbms_sql.varchar2_table;
  l_del_s_tables dbms_sql.varchar2_table;
BEGIN
  --
  IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count =0) THEN
    return;
  END IF;
  --
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside Loader Configuration ');
  END IF;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
  -- Added 08/23/2005 for performance bug 4559323
  --
  LOOP
    Tabla := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
    IF (Tabla.isProductionTable) THEN
      null;
    ELSE
      l_tbl_delete(l_tbl_delete.count+1) := upper(Tabla.Name);
      -- Bug 4928585, see below
      IF (tabla.name like 'BSC_S%') then
        l_del_s_tables(l_del_s_tables.count+1):= upper(Tabla.Name);
      END IF;
    END IF;
    exit when l_index1= BSC_METADATA_OPTIMIZER_PKG.gTables.last;
    l_index1 :=  BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
  END LOOP;
  --
  -- Bug 4928585 - get the levels that have this as the source table
  -- If dimensions are deleted, there could be other higher level tables that we need to delete
  -- for eg. if initially there was a dim with 3 dim objects parent->child and independant
  -- there would be two levels in the summary
  -- Now if we delete the parent->child from the dim, there would be only 1 level,
  -- and so we need to clean out the higher levels (in this eg. 2nd level)
  --
  -- this procedure will add any missing S tables to l_tbl_delete
  add_dependant_tables(l_del_s_tables, l_tbl_delete);
  FORALL i IN 1..l_tbl_delete.count
    DELETE FROM BSC_DB_TABLES_RELS WHERE TABLE_NAME = l_tbl_delete(i);
  FORALL i IN 1..l_tbl_delete.count
    DELETE FROM BSC_DB_TABLES WHERE TABLE_NAME = l_tbl_delete(i);
  FORALL i IN 1..l_tbl_delete.count
    DELETE FROM BSC_DB_CALCULATIONS WHERE TABLE_NAME = l_tbl_delete(i) AND CALCULATION_TYPE in (l_calc4,l_calc5);
  FORALL i IN 1..l_tbl_delete.count
    DELETE FROM BSC_DB_TABLES_COLS WHERE TABLE_NAME = l_tbl_delete(i) AND COLUMN_TYPE in (l_colP,l_colA);
  l_tab_rels.delete;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
  LOOP
    Tabla := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
    IF (Tabla.isProductionTable) THEN
      goto skip_table;
    END IF;
    Tabla_keyName.delete;
    Tabla_keyName := Tabla.keys;
	Tabla_data.delete;
    Tabla_Data := Tabla.Data;
    Tabla_originTable.delete;
    Tabla_originTable := BSC_MO_HELPER_PKG.getDecomposedString(Tabla.originTable, ',');
    Tabla_originTable1.delete;
    Tabla_originTable1 := BSC_MO_HELPER_PKG.getDecomposedString(Tabla.originTable1, ',');
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp(' ');
      BSC_MO_HELPER_PKG.writeTmp(' ');
      BSC_MO_HELPER_PKG.writeTmp('Processing gTables('||l_index1||') '||bsc_mo_helper_pkg.get_time);
      BSC_MO_HELPER_PKG.write_this(Tabla);
    END IF;
    bsc_mo_helper_pkg.writeTmp('Going to Delete Metadata tables for '||UPPER(Tabla.Name), FND_LOG.LEVEL_STATEMENT, false);
    --BSC_DB_TABLES_RELS
    If Tabla.Type = 1 Then
      -- Changed to bulk deletes/inserts for better performance - bug 4559323
      PeriodicityOrigin := 0;
      OriTableName := null;
      IF (Tabla_originTable.count >0 ) THEN
        l_index2 := Tabla_originTable.first;
        LOOP
          l_table_origin := Tabla_originTable(l_index2);
          l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, l_table_origin);
          IF (l_temp = -1 AND BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0) THEN
            PeriodicityOrigin := Tabla.periodicity;
          ELSE
            PeriodicityOrigin := BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp).Periodicity;
          END IF;
          OriTableName := l_table_origin;
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES_RELS1:'||Tabla.Name||', '||l_table_origin||', 0');
          END IF;
          l_rels_record.table_name := upper(Tabla.Name);
          l_rels_record.source_table_name := upper(l_table_origin);
          l_rels_record.relation_type := 0;
          l_tab_rels(l_tab_rels.count+1) := l_rels_record;
          EXIT WHEN l_index2 = Tabla_originTable.last;
          l_index2 := Tabla_originTable.next(l_index2);
        END LOOP;
      END IF;
      --Soft relations
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Checking Soft Relations1');
        bsc_mo_helper_pkg.writeTmp('Tabla_originTable1 = '||Tabla.originTable1||', Tabla_originTable1.count = '||Tabla_originTable1.count);
      END IF;
      IF (Tabla_originTable1.count > 0 ) THEN
        l_index2 := Tabla_originTable1.first;
        LOOP
          l_table_origin := Tabla_originTable1(l_index2);
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES_RELS2:'||Tabla.Name||','||l_table_origin||',1');
          END IF;
          l_rels_record.table_name := upper(Tabla.Name);
          l_rels_record.source_table_name := upper(l_table_origin);
          l_rels_record.relation_type := 1;
          l_tab_rels(l_tab_rels.count+1) := l_rels_record;
          EXIT WHEN l_index2 = Tabla_originTable1.last;
          l_index2 := Tabla_originTable1.next(l_index2);
        END LOOP;
      END IF;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Done checking Soft Relations1');
      END IF;
    End If; -- IF TABLA.type = 1

    --BSC_DB_TABLES
    get_projection_and_gen_type(Tabla, PeriodicityOrigin, projection, l_generation_type);

    --EDW Note: Each calendar has his own fiscal year, and range of years
    l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, Tabla.Periodicity);
    Calendar_id := BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp).CalendarId;
    l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gCalendars, calendar_id);
    num_years := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp).NumOfYears;
    num_prev_years := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp).PreviousYears;
    fiscal_year := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp).CurrFiscalYear;
    l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, Tabla.Periodicity);
    If BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp).Yearly_Flag = 1 Then
      --Annual periodicity
      Periodo_Act := fiscal_year;
    Else
      --No Annual periodicity
      Periodo_Act := 1;
    End If;

    --BSC-MV Note: In the upgrade process (sum level change from NULL to NOTNULL)
    --we canot reset the current period, specially in the base and input table.
    --We need to use the current period of the table
    If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 1 Then
      If Tabla.currentPeriod <> 0 Then
          Periodo_Act := Tabla.currentPeriod;
      End If;
    End If;
    If Tabla.Type = 0 Then
       --Note: From version 4.6.0 we are not going to use Periodicities
       --month-day and month-week (11, 12)
       SubPeriodo_Act := 0;
    Else
       SubPeriodo_Act := 0;
    End If;
    EDW_Flag := Tabla.EDW_Flag;
    If Tabla.IsTargetTable Then
      Target_Flag := 1;
    Else
      Target_Flag := 0;
    End If;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES:'||
          Tabla.Name||', type='|| Tabla.Type||', periodicity='||Tabla.Periodicity||', gen_type='||
          l_generation_type ||', projection = '|| projection||', num_years'|| num_years||', num_prev_years= '||
          num_prev_years||','||Periodo_Act||','|| SubPeriodo_Act||','|| EDW_Flag||',' ||Target_Flag||'  '||bsc_mo_helper_pkg.get_time);
    END IF;
    l_db_tables_record.TABLE_NAME := upper(Tabla.Name);
    l_db_tables_record.TABLE_TYPE := Tabla.Type;
    l_db_tables_record.PERIODICITY_ID := Tabla.Periodicity;
    l_db_tables_record.GENERATION_TYPE := l_generation_type;
    l_db_tables_record.PROJECT_FLAG := projection;
    l_db_tables_record.NUM_OF_YEARS := num_years;
    l_db_tables_record.PREVIOUS_YEARS := num_prev_years;
    l_db_tables_record.SOURCE_DATA_TYPE := 0;
    l_db_tables_record.SOURCE_FILE_NAME := null;
    l_db_tables_record.CURRENT_PERIOD := Periodo_Act;
    l_db_tables_record.CURRENT_SUBPERIOD := SubPeriodo_Act;
    l_db_tables_record.EDW_FLAG := EDW_Flag;
    l_db_tables_record.TARGET_FLAG := Target_Flag;
    l_tab_db_tables(l_tab_db_tables.count+1) := l_db_tables_record;

    --BSC_DB_CALCULATIONS (Calculation of zero code)

    numZeroCodeKeys := 0;
    IF (Tabla_keyname.count >0 ) THEN
      l_index2 := Tabla_keyname.first;
      LOOP
        l_key := Tabla_keyname(l_index2);
        If l_key.CalculateCode0 Then
          arrZeroCodeKeys(numZeroCodeKeys) := l_key.keyName;
          numZeroCodeKeys := numZeroCodeKeys + 1;
        End If;
        Tabla_keyName(l_index2) := l_key;
        EXIT WHEN l_index2 = Tabla_keyname.last;
        l_index2 := Tabla_keyname.next(l_index2);
      END LOOP;
    END IF;

    For i IN 0..numZeroCodeKeys - 1 LOOP
      l_index2 := Tabla_Data.First;
      LOOP
        EXIT WHEN Tabla_Data.count = 0;
        l_measure := Tabla_Data(l_index2);
        If l_measure.AvgLFlag = 'Y' Then
          ZeroCodeOrigin := BSC_MO_INDICATOR_PKG.GetFreeDivZeroExpression('SUM(' || l_measure.AvgLTotalColumn || ')/SUM('
					 || l_measure.AvgLCounterColumn || ')');
        Else
          ZeroCodeOrigin := l_measure.aggFunction|| '('|| l_measure.fieldName || ')';
        End If;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          BSC_MO_HELPER_PKG.writeTmp('INSERT DB_CALCULATIONS1:'||
              Tabla.name||','||arrZeroCodeKeys(i)||','||i||','|| l_measure.fieldName||','||ZeroCodeOrigin||'  '||bsc_mo_helper_pkg.get_time);
        END IF;
        l_db_calculations_record.TABLE_NAME := upper(Tabla.name);
        l_db_calculations_record.CALCULATION_TYPE := 4;
        l_db_calculations_record.PARAMETER1 := arrZeroCodeKeys(i);
        l_db_calculations_record.PARAMETER2 := i;
        l_db_calculations_record.PARAMETER3 := l_measure.fieldName;
        l_db_calculations_record.PARAMETER4 := null;
        l_db_calculations_record.PARAMETER5 := ZeroCodeOrigin;
        l_tab_db_calculations(l_tab_db_calculations.count+1) := l_db_calculations_record;
        EXIT WHEN l_index2 = Tabla_Data.last;
        l_index2 := Tabla_Data.next(l_index2);
      END LOOP;
    END LOOP;
    --BSC_DB_CALCULATIONS (Merge targets)

    IF (Tabla_originTable1.count>0) THEN
      l_index2 := Tabla_originTable1.first;
      LOOP
        l_table_origin := Tabla_originTable1(l_index2);
        l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, l_table_origin);
        If BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp).IsTargetTable Then
          IF ( Tabla_Data.count>0) THEN
            l_index3 := Tabla_Data.first;
            LOOP
              l_measure := Tabla_Data(l_index3);
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('INSERT DB_CALCULATIONS2:'||
                  Tabla.Name||',5,'|| l_table_origin||','|| l_measure.fieldName);
              END IF;
              l_db_calculations_record.TABLE_NAME := upper(Tabla.name);
              l_db_calculations_record.CALCULATION_TYPE := 5;
              l_db_calculations_record.PARAMETER1 := l_table_origin;
              l_db_calculations_record.PARAMETER2 := l_measure.fieldName;
              l_db_calculations_record.PARAMETER3 := null;
              l_db_calculations_record.PARAMETER4 := null;
              l_db_calculations_record.PARAMETER5 := null;
              l_tab_db_calculations(l_tab_db_calculations.count+1) := l_db_calculations_record;
              EXIT WHEN l_index3 = Tabla_Data.last;
              l_index3 := Tabla_Data.next(l_index3);
            END LOOP;
          END IF;
        End If;
        EXIT WHEN l_index2 = Tabla_originTable1.last;
        l_index2 := Tabla_originTable1.next(l_index2);
      END LOOP;
    END IF;

    --BSC_DB_TABLES_COLS (Key columns)

    IF (Tabla_keyName.count>0) THEN
      l_index2 := Tabla_keyName.first;
      LOOP
        l_key := Tabla_keyName(l_index2);
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES_COLS2: table_name='||Tabla.Name||
            ', column_type=P, column_name = '||l_key.keyName||', source_column='||l_key.Origin||'  '||bsc_mo_helper_pkg.get_time);
        END IF;
        BEGIN
          l_db_tables_cols_record.TABLE_NAME := upper(Tabla.Name);
          l_db_tables_cols_record.COLUMN_TYPE := 'P';
          l_db_tables_cols_record.COLUMN_NAME := l_key.keyName;
          l_db_tables_cols_record.SOURCE_COLUMN := l_key.Origin;
          l_tab_db_tables_cols(l_tab_db_tables_cols.count+1) := l_db_tables_cols_record;
        END;
        EXIT WHEN l_index2 = Tabla_keyName.last;
        l_index2 := Tabla_keyName.next(l_index2);
      END LOOP;
    END IF;

    --BSC_DB_TABLES_COLS (Data columns)

    IF (Tabla_Data.count >0) THEN
      l_index2 := Tabla_Data.first;
      LOOP
        l_measure := Tabla_Data(l_index2);
        If projection = 1 Then
          l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, l_measure.fieldName, l_measure.source);
          l_prj_method := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod;
        Else
          l_prj_method := 0;
        End If;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES_COLS2: Table_name = '||Tabla.Name||', column_type = A, Column Name= '||
					l_measure.fieldName||', source='||l_measure.source||', projection='||l_prj_method||', origin = '||l_measure.Origin||'  '||bsc_mo_helper_pkg.get_time );
        END IF;
        l_db_tables_cols_record.TABLE_NAME := upper(Tabla.Name);
        l_db_tables_cols_record.COLUMN_TYPE := 'A';
        l_db_tables_cols_record.COLUMN_NAME := l_measure.fieldName;
        l_db_tables_cols_record.SOURCE := l_measure.source;
        l_db_tables_cols_record.projection_id := l_prj_method;
        l_db_tables_cols_record.SOURCE_FORMULA := l_measure.Origin;
        l_tab_db_tables_cols(l_tab_db_tables_cols.count+1) := l_db_tables_cols_record;
        EXIT WHEN l_index2 = Tabla_Data.last;
        l_index2 := Tabla_Data.next(l_index2);
      END LOOP;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('Data Cols insertion completed for Table='||Tabla.Name);
      END IF;
    END IF;
    --Special cases: This is a table of a Balance or PnL indicator
    --BSC-MV Note: Profit calculation will be done in the base tables at sub-account level
    If Not BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV Then
      --current architecture
      If Tabla.Indicator <> 0 Then
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          BSC_MO_HELPER_PKG.writeTmp('Indicator<>0');
        END IF;
        If BSC_MO_INDICATOR_PKG.IsIndicatorPnL(Tabla.Indicator, true ) Then
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp('Indicator is PnL');
          END IF;
          --This is a table of a PnL indicator
          IF (tabla_keyName.count > 0 ) THEN
            Dril1 := Tabla_keyName(Tabla_keyName.first).keyName;
          END IF;
          If getLevelIndex(Tabla.Indicator, Tabla.Configuration, Dril1) = 1 Then
            --This is the table for the first drill (account drill).
            --We need to calculate the profit
            --BSC_DB_CALCULATIONS
            l_db_calc_1_delete(l_db_calc_1_delete.count+1) := UPPER(Tabla.Name);
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              BSC_MO_HELPER_PKG.writeTmp('INSERT DB_CALCULATIONS3:'||Tabla.Name||',1,'|| Dril1||'  '||bsc_mo_helper_pkg.get_time);
            END IF;
            l_db_calculations_record.TABLE_NAME := upper(Tabla.name);
            l_db_calculations_record.CALCULATION_TYPE := 1;
            l_db_calculations_record.PARAMETER1 := Dril1;
            l_db_calculations_record.PARAMETER2 := null;
            l_db_calculations_record.PARAMETER3 := null;
            l_db_calculations_record.PARAMETER4 := null;
            l_db_calculations_record.PARAMETER5 := null;
            l_tab_db_calculations(l_tab_db_calculations.count+1) := l_db_calculations_record;
           End If;
        End If;
      END IF;
    End If;
<<skip_table>>
    IF ( Tabla.isProductionTable AND Tabla.isProductionTableAltered) THEN
      BSC_MO_HELPER_PKG.writeTmp('Production table altered', FND_LOG.LEVEL_STATEMENT, false);
      BSC_MO_HELPER_PKG.write_to_stack('Production table altered');
      -- table has been altered, so insert into bsc_db_tables_cols
      If Tabla.Type = 1 Then
        BSC_MO_HELPER_PKG.write_to_stack('Table Type=1');
        PeriodicityOrigin := 0;
        Tabla_originTable := BSC_MO_HELPER_PKG.getDecomposedString(Tabla.originTable, ',');
        BSC_MO_HELPER_PKG.write_to_stack('OriginTable='||Tabla.originTable);
        OriTableName := null;
        IF (Tabla_originTable.count >0 ) THEN
          l_table_origin := Tabla_originTable(0);
          l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, l_table_origin);
          BSC_MO_HELPER_PKG.write_to_stack('l_temp='||l_temp);
          IF (l_temp = -1 OR BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0) THEN
            PeriodicityOrigin := Tabla.periodicity;
          ELSE
            PeriodicityOrigin := BSC_METADATA_OPTIMIZER_PKG.gTables(l_temp).Periodicity;
          END IF;
          BSC_MO_HELPER_PKG.write_to_stack('PeriodicityOrigin='||PeriodicityOrigin);
        END IF;
      END IF;
      IF (Tabla.data.count>0) THEN
        BSC_MO_HELPER_PKG.write_to_stack('going to get_projection_and_gen_type');
        get_projection_and_gen_type(Tabla, PeriodicityOrigin, projection, l_generation_type);
        -- Get list of source tables from this table to the Input table
        Tabla_originTable := BSC_DBGEN_UTILS.get_source_table_names(Tabla.name);
        Tabla_originTable(Tabla_originTable.count) := Tabla.Name;
        FOR i IN Tabla.data.first..Tabla.data.last LOOP
          l_measure := Tabla.data(i);
          BSC_MO_HELPER_PKG.writeTmp('Considering '||Tabla.data(i).fieldName, FND_LOG.LEVEL_STATEMENT, false);
          BSC_MO_HELPER_PKG.write_this(Tabla.data(i));
          IF Tabla.data(i).changeType='NEW' THEN -- new column, insert into db_tables_cols
            If projection = 1 Then
              l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, l_measure.fieldName, l_measure.source);
              BSC_MO_HELPER_PKG.writeTmp('gLov, l_temp='||l_temp, FND_LOG.LEVEL_STATEMENT, false);
              l_prj_method := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod;
            Else
              l_prj_method := 0;
            End If;
            BSC_MO_HELPER_PKG.writeTmp('l_prj_method='||l_prj_method, FND_LOG.LEVEL_STATEMENT, false);
            FOR j IN Tabla_originTable.first..Tabla_originTable.last LOOP
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES_COLS5: Table_name = '||Tabla_originTable(j)||', column_type = A, Column Name= '||
                    l_measure.fieldName||', source='||l_measure.source||', projection='||l_prj_method||', origin = '||l_measure.Origin );
              END IF;
              l_db_cols_1_delete_table_name(l_db_cols_1_delete_table_name.count+1) := upper(Tabla_originTable(j));
              l_db_cols_1_delete_field_name(l_db_cols_1_delete_field_name.count+1) := l_measure.fieldName;
              --DELETE FROM BSC_DB_TABLES_COLS WHERE table_name = upper(Tabla_originTable(j)) AND column_type='A' and column_name=l_measure.fieldName;
              l_db_tables_cols_record.TABLE_NAME := upper(Tabla_originTable(j));
              l_db_tables_cols_record.COLUMN_TYPE := 'A';
	      l_db_tables_cols_record.COLUMN_NAME := l_measure.fieldName;
              l_db_tables_cols_record.SOURCE := l_measure.source;
              l_db_tables_cols_record.projection_id := l_prj_method;
              l_db_tables_cols_record.SOURCE_FORMULA := l_measure.Origin;
              l_tab_db_tables_cols(l_tab_db_tables_cols.count+1) := l_db_tables_cols_record;
            END LOOP;
          END IF;
        END LOOP;
      END IF;
    END IF;
    EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
  END LOOP;
  BSC_MO_HELPER_PKG.writeTmp('Checkpoint 11  '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, false);

  --BULK DELETES
  FORALL i IN 1..l_db_calc_1_delete.count
    DELETE FROM BSC_DB_CALCULATIONS WHERE TABLE_NAME = l_db_calc_1_delete(i) AND CALCULATION_TYPE = 1;

  FORALL i IN 1..l_db_cols_1_delete_table_name.count
    DELETE FROM BSC_DB_TABLES_COLS WHERE TABLE_NAME=l_db_cols_1_delete_table_name(i) AND column_name=l_db_cols_1_delete_field_name(i) and column_type='A';


  -- BULK INSERTS
  BEGIN
  FORALL i IN 1..l_tab_rels.count
    INSERT INTO BSC_DB_TABLES_RELS VALUES l_tab_rels(i);
  EXCEPTION
  WHEN others THEN
    FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT LOOP
      bsc_mo_helper_pkg.writeTmp('Error ' || i || ' occurred during '||
         'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX, FND_LOG.LEVEL_EXCEPTION, true);
      bsc_mo_helper_pkg.writeTmp('Oracle error is ' ||
         SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),FND_LOG.LEVEL_EXCEPTION, true);
    END LOOP;
    FOR i IN 1..l_tab_rels.count LOOP
       bsc_mo_helper_pkg.writeTmp('Table='||l_tab_rels(i).table_name||', Source='||l_tab_rels(i).source_table_name||', Type='||l_tab_rels(i).relation_type,FND_LOG.LEVEL_EXCEPTION, true);
    END LOOP;
  END;

  BEGIN
  FORALL i IN 1..l_tab_db_calculations.count
    INSERT INTO BSC_DB_CALCULATIONS VALUES l_tab_db_calculations(i);
  EXCEPTION
  WHEN others THEN

   bsc_mo_helper_pkg.writeTmp('Insert calculations: Number of errors is ' || SQL%BULK_EXCEPTIONS.COUNT, FND_LOG.LEVEL_EXCEPTION, true);
   FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT LOOP
      bsc_mo_helper_pkg.writeTmp('Error ' || i || ' occurred during '||
         'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX, FND_LOG.LEVEL_EXCEPTION, true);
      bsc_mo_helper_pkg.writeTmp('Oracle error is ' ||
         SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),FND_LOG.LEVEL_EXCEPTION, true);
   END LOOP;
  END;

  BEGIN
  FORALL i IN 1..l_tab_db_tables.count
    INSERT INTO BSC_DB_TABLES VALUES l_tab_db_tables(i);
  EXCEPTION
  WHEN others THEN

   bsc_mo_helper_pkg.writeTmp('Insert tables: Number of errors is ' || SQL%BULK_EXCEPTIONS.COUNT, FND_LOG.LEVEL_EXCEPTION, true);
   FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT LOOP
      bsc_mo_helper_pkg.writeTmp('Error ' || i || ' occurred during '||
         'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX, FND_LOG.LEVEL_EXCEPTION, true);
      bsc_mo_helper_pkg.writeTmp('Oracle error is ' ||
         SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),FND_LOG.LEVEL_EXCEPTION, true);
   END LOOP;
  END;

  BEGIN
  FORALL i IN 1..l_tab_db_tables_cols.count
    INSERT INTO BSC_DB_TABLES_COLS VALUES l_tab_db_tables_cols(i);
  EXCEPTION
  WHEN others THEN

   bsc_mo_helper_pkg.writeTmp('Insert Cols: Number of errors is ' || SQL%BULK_EXCEPTIONS.COUNT, FND_LOG.LEVEL_EXCEPTION, true);
   FOR i IN 1.. SQL%BULK_EXCEPTIONS.COUNT LOOP
      bsc_mo_helper_pkg.writeTmp('Error ' || i || ' occurred during '||
         'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX, FND_LOG.LEVEL_EXCEPTION, true);
      bsc_mo_helper_pkg.writeTmp('Oracle error is ' ||
         SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),FND_LOG.LEVEL_EXCEPTION, true);
   END LOOP;
  END;


  If BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV Then
    --BSC-MV Note: Now that all the Loader metadata is configured, We need to configure
    --the periodicity calculation in the base tables. It is going to call a Loader API
    --to do it. The same API is re-used in upgrade.
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
    LOOP
      Tabla := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
      -- bug 4581847, should call this for production tables also
      If isBasicTable(Tabla.Name) Then
          BSC_UPDATE.Configure_Periodicity_Calc_VB(tabla.name);
          BSC_MO_HELPER_PKG.CHeckError('BSC_UPDATE.Configure_Periodicity_Calc_VB');
      End If;
      EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
    END LOOP;
    BSC_MO_HELPER_PKG.writeTmp('Going to configure Profit Calculations  '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);

    --BSC-MV Note: Now that all the Loader metadata is configured, We need to configure
    --the Profit calculation in the base tables. It is going to call a Loader API
    --to do it. The same API is re-used in upgrade.
    BSC_UPDATE.Configure_Profit_Calc_VB;
    BSC_MO_HELPER_PKG.CheckError('BSC_UPDATE.Configure_Profit_Calc_VB');
  End If;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed Loader Configuration  '||bsc_mo_helper_pkg.get_time);
  END IF;

  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp( ' Exception in Loader Configuration:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    fnd_message.set_name('BSC', 'BSC_LOAD_CONFIGURATION_FAILED');
    app_exception.raise_exception;
    RAISE;
End;

--****************************************************************************
--  ReConfigureUploadFieldsIndic
--
--    DESCRIPTION:
--       Re-configure the fields of data of the indicator tables.
--
--****************************************************************************

PROCEDURE ReConfigureUploadFieldsIndic(Indic IN NUMBER) IS
  arrTables DBMS_SQL.VARCHAR2_TABLE;
  numTables NUMBER;
  arrIndicTables DBMS_SQL.VARCHAR2_TABLE;
  numIndicTables NUMBER;
  colDatos BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
  l_measure        BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  i           NUMBER;
  l_table_origin      VARCHAR2(100);
  l_table_type     NUMBER;
  l_stmt      VARCHAR2(1000);

  colConfiguraciones DBMS_SQL.NUMBER_TABLE;
  Configuracion Number;
  newColumnFlag Boolean;
  ZeroCodeOrigin VARCHAR2(1000);
  l_source VARCHAR2(1000);
  ddl_sql VARCHAR2(1000);

  l_index1 NUMBER;
  l_index2 NUMBER;
  l_index3 NUMBER;
  l_temp NUMBER;

  l_table_name VARCHAR2(100);
  zeroCodeDataColumns VARCHAR2(1000) ;
  l_3 VARCHAR2(250);
  l_5 VARCHAR2(250);
  cv CurTyp ;
  l_stack varchar2(32000);

  CURSOR cRollups(pIndicator IN NUMBER, pDimSetID IN NUMBER) IS
  SELECT DISTINCT parameter3, parameter5 FROM bsc_db_calculations
  WHERE table_name IN (SELECT table_name
                FROM bsc_kpi_data_tables
                WHERE indicator = pIndicator
                AND dim_set_id = pDimSetID
                AND sql_stmt IS NOT NULL)
                AND CALCULATION_TYPE = 4 ;
-- bug 4114501
l_optimizationMode number := 1;
l_count number;
l_cols_used VARCHAR2(32000);
BEGIN
  bsc_mo_helper_pkg.writeTmp('Inside ReConfigureUploadFieldsIndic');
  --Get the list of configurations of the kpi
  colConfiguraciones := BSC_MO_INDICATOR_PKG.GetConfigurationsForIndic(Indic);
  IF (colConfiguraciones.count=0) THEN
      bsc_mo_helper_pkg.writeTmp('Completed ReConfigureUploadFieldsIndic, 0 count');
      return;
  END IF;

  l_index1 := colConfiguraciones.first;

  LOOP
      Configuracion := colConfiguraciones(l_index1);
      --Initialize the array arrTables() with all tables used by the indicator
      --in the given configuration
      --IndicTables() contains the tables used direclty by the indicator in the given configuration
      --including the target tables created for the indicator
      InitarrTablesIndic( Indic, Configuracion, arrTables, numTables, arrIndicTables, numIndicTables);
      --Initialize the collection of data columns of the indicator
      colDatos := BSC_MO_INDICATOR_PKG.GetDataFields(Indic, Configuracion, True);
      bsc_mo_helper_pkg.write_this(colDatos, FND_LOG.LEVEL_STATEMENT, false);
      --Reconfigure
      --The only non-structural changes that could happen are:
      --Change in the rollup method
      --Change in the projection method
      --Change on the rollup to formula option
      bsc_mo_helper_pkg.addStack (l_stack,  ' NumTables = '||numTables);
      bsc_mo_helper_pkg.writeTmp(' NumTables = '||numTables);
      For i IN arrTables.first..arrTables.last LOOP
        l_table_type := GetIndicTableType(arrTables(i), arrIndicTables, numIndicTables);
        bsc_mo_helper_pkg.addStack (l_stack,  ' Table = '||arrTables(i)||', l_table_type = '||l_table_type);
        bsc_mo_helper_pkg.writeTmp(' Table = '||arrTables(i)||', l_table_type = '||l_table_type);
        If l_table_type <> 0 Then --It is not an input table
          IF (colDatos.count > 0) THEN
              l_index2 := colDatos.First;
          END IF;
          LOOP
            EXIT WHEN colDatos.count = 0;
            l_measure := colDatos(l_index2);
            newColumnFlag := False;
            bsc_mo_helper_pkg.writeTmp('Processing '||l_measure.fieldName);
            If (l_table_type = 3) Or (l_table_type = 4) Then
              --BSC-MV Note: In this Architecture there COULD be a projection
              --table created for target at different levels. In this case we
              --need to add this new column to the projection table.
              If BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV Then
                l_optimizationMode := bsc_mo_helper_pkg.getKPIPropertyValue(Indic, 'DB_TRANSFORM', 1);
                IF (l_optimizationMode = 2) THEN -- targets at different levels, PT tables shd exist
                  l_table_name := BSC_MO_INDICATOR_PKG.GetProjectionTableName(arrTables(i));
                ELSE
                  l_table_name := arrTables(i);
                END IF;
              Else
                l_table_name := arrTables(i);
              End If;
              bsc_mo_helper_pkg.addStack (l_stack,  ' Check1 : l_table_name = '||l_table_name);
              --This is table used directly by the indicator
              --We need to make sure that the internal column exists
              If substr(l_measure.fieldName, 1, 5) = 'BSCIC' Then
                IF (BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV =false) OR  (BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV AND l_optimizationMode=2) THEN
                  If Not BSC_MO_HELPER_PKG.table_column_exists(l_table_name, l_measure.fieldName) Then
                      --Add the internal column
                      ddl_sql := 'ALTER TABLE ' || l_table_name ||' ADD ' || l_measure.fieldName ||' NUMBER ';
                      begin
                        BSC_MO_HELPER_PKG.Do_DDL( ddl_sql , ad_ddl.alter_table, l_table_name);
                        newColumnFlag := True;
                        exception when others then
                          BSC_MO_HELPER_PKG.writeTmp('Error while executing : '||ddl_sql||', Error is '||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
                          raise;
                      end;
                  End If;
                END IF;
                -- Bug 4466627
                IF (BSC_METADATA_OPTIMIZER_PKG.G_BSC_MV) THEN
                  SELECT COUNT(1) INTO l_count
                  FROM BSC_DB_TABLES_COLS
                  WHERE table_name=l_table_name AND column_name=l_measure.fieldName;
                  BSC_MO_HELPER_PKG.writeTmp('MV arch, l_count= '||l_count||' for '||l_table_name ||' field='||l_measure.fieldName);
                  IF (l_count=0) THEN
                    newColumnFlag := true;
                    BSC_MO_HELPER_PKG.writeTmp('Setting new col flag to true');
                  END IF;
                END IF;
              End If;
              bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt2 ');
            End If;
            --BSC_DB_CALCULATIONS (Zero code calculation)
            If ((l_table_type = 3) Or (l_table_type = 4)) And (l_measure.AvgLFlag = 'Y') Then
              --This is table used directly by the indicator
              --and the data is AVGL
              ZeroCodeOrigin := BSC_MO_INDICATOR_PKG.GetFreeDivZeroExpression('SUM(' || l_measure.AvgLTotalColumn ||')/SUM('||
				l_measure.AvgLCounterColumn ||')');
            Else
              ZeroCodeOrigin := l_measure.aggFunction || '(' || l_measure.fieldName || ')';
            End If;
            bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt3 ');
            If newColumnFlag Then
              --This is a internal column that was added to the indicator table
              --If the table does not calculate zero code then no record is inserted
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('4 INSERT DB_CALCULATIONS:');
              END IF;
              l_stmt := 'INSERT INTO BSC_DB_CALCULATIONS (TABLE_NAME, CALCULATION_TYPE, PARAMETER1, PARAMETER2 '||
                ', PARAMETER3, PARAMETER4, PARAMETER5) '||
                ' SELECT DISTINCT TABLE_NAME, CALCULATION_TYPE, PARAMETER1, PARAMETER2, :1, parameter4, :2 FROM BSC_DB_CALCULATIONS '||
                ' WHERE TABLE_NAME = :3 AND CALCULATION_TYPE = 4';
              bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt4.1, L_STMT = '||l_stmt);
              INSERT INTO BSC_DB_CALCULATIONS
                  (TABLE_NAME, CALCULATION_TYPE, PARAMETER1, PARAMETER2
                  , PARAMETER3, PARAMETER4, PARAMETER5)
              SELECT DISTINCT
                  TABLE_NAME, CALCULATION_TYPE, PARAMETER1, PARAMETER2,
                  l_measure.fieldName, parameter4, ZeroCodeOrigin
                  FROM BSC_DB_CALCULATIONS
                  WHERE TABLE_NAME = UPPER(arrTables(i)) AND CALCULATION_TYPE = 4;
            Else
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('4 UPDATE DB_CALCULATIONS:');
              END IF;
              --If the table does not calculate zero code then no record is updated
              l_stmt :=  'UPDATE BSC_DB_CALCULATIONS  SET PARAMETER5 = :1 WHERE '||
                ' TABLE_NAME = :2 AND PARAMETER3 = :3 AND CALCULATION_TYPE = 4 ';
              bsc_mo_helper_pkg.writeTmp(' Chkpt4.2, L_STMT = '||l_stmt||', :1='||ZeroCodeOrigin||', :2='||UPPER(arrTables(i))||', :3='||
              l_measure.fieldName);
              UPDATE BSC_DB_CALCULATIONS
              SET PARAMETER5 = ZeroCodeOrigin
              WHERE
              TABLE_NAME = UPPER(arrTables(i))
              AND PARAMETER3 = l_measure.fieldName
              AND CALCULATION_TYPE = 4 ;
            End If;
            --BSC_DB_CALCULATIONS (Merge targets)
            --No changes for current columns
            If newColumnFlag Then
              --This is a internal column that was added to the indicator table
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('5 INSERT DB_CALCULATIONS:');
              END IF;
              l_stmt:= 'INSERT INTO BSC_DB_CALCULATIONS (TABLE_NAME, CALCULATION_TYPE, PARAMETER1, PARAMETER2) '||
                    ' SELECT DISTINCT TABLE_NAME, CALCULATION_TYPE, PARAMETER1, :2'||
                    ' FROM BSC_DB_CALCULATIONS WHERE TABLE_NAME = :2 AND CALCULATION_TYPE = 5';
              bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt4.3, L_STMT = '||l_stmt);
              INSERT INTO BSC_DB_CALCULATIONS(TABLE_NAME, CALCULATION_TYPE, PARAMETER1, PARAMETER2)
              SELECT DISTINCT TABLE_NAME, CALCULATION_TYPE, PARAMETER1, l_measure.fieldName
              FROM BSC_DB_CALCULATIONS
              WHERE TABLE_NAME = UPPER(arrTables(i))
              AND CALCULATION_TYPE = 5;
            End If;
            --BSC_DB_TABLES_COLS
            IF (l_table_type =3) THEN
              --Case 3
              --The table is not generated from another indicator table
              --This is a base table o the indicator.
              --We calculate average at lowest level and formula at lowest level
              --where the lowest level is the lowest level of the kpi.
              IF (l_measure.InternalColumnType=0) THEN
                --Case 0 --Normal (Non-Internal column)
                l_source := l_measure.aggFunction|| '(' || l_measure.fieldName || ')';
              ELSIF (l_measure.InternalColumnType=1) THEN
                --Case 1 --Formula at lowest level
                l_source := BSC_MO_INDICATOR_PKG.GetFreeDivZeroExpression(l_measure.aggFunction|| '(' ||
						l_measure.InternalColumnSource || ')');
              ELSIF (l_measure.InternalColumnType=2) THEN
                --Case 2 --Total for Average at Lowest Level
                l_source := BSC_MO_INDICATOR_PKG.GetFreeDivZeroExpression('SUM(' || l_measure.InternalColumnSource || ')');
              ELSIF (l_measure.InternalColumnType=3) THEN
                --Case 3 --Counter for Average at Lowest Level
                l_source := BSC_MO_INDICATOR_PKG.GetFreeDivZeroExpression('COUNT(' || l_measure.InternalColumnSource || ')');
              End IF;
              bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt5.1, l_source = '||l_source);
            ELSIF (l_table_type =4) THEN
              --Case 4
              --The table is originated from another indicator table
              If l_measure.AvgLFlag = 'Y' Then
                l_source := BSC_MO_INDICATOR_PKG.GetFreeDivZeroExpression('SUM(' || l_measure.AvgLTotalColumn || ')/SUM('||
					  l_measure.AvgLCounterColumn || ')');
              Else
                l_source := l_measure.aggFunction || '(' || l_measure.fieldName || ')';
              End If;
              bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt5.1b, l_source = '||l_source);
            ELSE -- Case else
              --Base tables, temporal tables
              l_source := l_measure.aggFunction || '(' || l_measure.fieldName || ')';
              bsc_mo_helper_pkg.addStack (l_stack,  ' Chkpt5.1c, l_source = '||l_source);
            End IF;
            If newColumnFlag Then
              --This is a internal column that was added to the indicator table
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('INSERT DB_TABLES_COLS newcol: table_name='||
                    arrTables(i)||', column_type=A, column_name = '||l_measure.fieldName||', source_column='||l_source);
              END IF;
              INSERT INTO BSC_DB_TABLES_COLS (TABLE_NAME, COLUMN_TYPE, COLUMN_NAME, SOURCE, PROJECTION_ID, SOURCE_FORMULA)
              VALUES(upper(arrTables(i)), 'A', l_measure.fieldName, l_measure.source, 0, l_source);
            Else
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('UPDATE DB_TABLES_COLS newcol: table_name='||
                    arrTables(i)||', column_type=A, column_name = '||l_measure.fieldName||', source='||l_measure.source||', source_column='||l_source);
              END IF;
              UPDATE BSC_DB_TABLES_COLS
              SET SOURCE_FORMULA = l_source
              WHERE TABLE_NAME =UPPER(arrTables(i))
              AND COLUMN_NAME = l_measure.fieldName
              AND SOURCE = l_measure.source
              AND COLUMN_TYPE = 'A';
            End If;
            --BSC_DB_TABLES_COLS (Projection method)
            If CalcProjectionTable(arrTables(i)) Then
              l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, l_measure.fieldName, l_measure.source);
              UPDATE BSC_DB_TABLES_COLS
			  SET PROJECTION_ID = BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).PrjMethod
              WHERE TABLE_NAME = UPPER(arrTables(i))
              AND COLUMN_NAME = l_measure.fieldName
              AND SOURCE = l_measure.source
              AND COLUMN_TYPE = 'A';
            End If;
            EXIT WHEN l_index2 = colDatos.last;
            l_index2 := colDatos.next(l_index2);
          END LOOP;
        End If;
      END LOOP;
      --Fix bug#3350103 If the user change the rollup method we need to update
      --the sql statements configured in BSC_KPI_DATA_TABLES for zero codes
      If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then

        OPEN cRollups(indic, Configuracion);
        bsc_mo_helper_pkg.addStack (l_stack,  ' Chk 8');
        zeroCodeDataColumns := null;
        LOOP
          FETCH cRollups INTO l_3, l_5;
          EXIT WHEN cRollups%NOTFOUND;
          zeroCodeDataColumns := zeroCodeDataColumns || ', ' || l_5|| ' ' || l_3;
        END Loop;
        Close cRollups;
        If zeroCodeDataColumns IS NOT NULL Then
          bsc_mo_helper_pkg.addStack (l_stack,  ' Chk 9');
          l_stmt := ' UPDATE bsc_kpi_data_tables '||
                  ' SET sql_stmt = SUBSTR(sql_stmt, 1, INSTR(sql_stmt, ''PERIOD_TYPE_ID'') - 1)||''PERIOD_TYPE_ID''||'''|| zeroCodeDataColumns || '''|| '||
                  ' SUBSTR(sql_stmt, INSTR(sql_stmt, '' FROM ''))'||
                  ' WHERE indicator = :1 ' ||
                  ' AND dim_set_id  = :2 '  ||
                  ' AND sql_stmt IS NOT NULL';

          EXECUTE IMMEDIATE l_stmt USING Indic, Configuracion;
        End If;
        bsc_mo_helper_pkg.addStack (l_stack,  ' Chk 10');
      End If;


  EXIT WHEN l_index1 = colConfiguraciones.last;
  l_index1 := colConfiguraciones.next(l_index1);
  END LOOP;
  bsc_mo_helper_pkg.writeTmp('Completed ReConfigureUploadFieldsIndic');
  EXCEPTION WHEN OTHERS THEN
	bsc_mo_helper_pkg.writeTmp('Exception in ReConfigureUploadFieldsIndic:'||sqlerrm, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.writeTmp('Stack is : '||l_stack, FND_LOG.LEVEL_UNEXPECTED, true);
    raise;
End ;

END BSC_MO_LOADER_CONFIG_PKG;

/
