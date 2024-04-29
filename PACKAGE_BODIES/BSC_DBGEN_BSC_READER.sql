--------------------------------------------------------
--  DDL for Package Body BSC_DBGEN_BSC_READER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DBGEN_BSC_READER" AS
/* $Header: BSCBSRDB.pls 120.19.12000000.2 2007/02/14 10:36:51 rkumar ship $*/

g_sys_measures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
g_sys_measures_loaded boolean :=false;
g_error VARCHAR2(4000);

procedure init is
begin
  if g_initialized=false then
    bsc_apps.Init_bsc_apps;
    bsc_apps.Init_Big_In_Cond_Table;
    g_initialized := true;
  end if;
end;

--****************************************************************************
--  IsIndicatorPnL
--  DESCRIPTION:
--     Return TRUE if the indicator is type PnL
--  PARAMETERS:
--     Ind: Indicator code
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IsIndicatorPnL(Ind IN Integer) return Boolean IS
CURSOR cBalance IS
SELECT indicator_type, config_type FROM BSC_KPIS_VL where INDICATOR= Ind;
l_indicator_type NUMBER;
l_config_type NUMBER;
BEGIN
  If l_indicator_type = 1 And l_config_type = 3 Then
      return true;
  Else
      return false;
  END IF;
  EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, 'Exception in IsIndicatorPnL for '||Ind||' : '||sqlerrm);
	RAISE;
End;

--****************************************************************************
--  EsIndicatorBalance
--
--  DESCRIPTION:
--     Returns TRUE is the indicator is type Balance
--
--  PARAMETERS:
--     Ind: Indicator code
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IsIndicatorBalance(Ind IN NUMBER) return Boolean IS
CURSOR cBalance IS
SELECT indicator_type, config_type FROM BSC_KPIS_VL where INDICATOR= Ind;
l_indicator_type NUMBER;
l_config_type NUMBER;
BEGIN
  OPEN cBalance;
  FETCH cBalance INTO l_indicator_type, l_config_type;
  CLOSE cBalance;

  If l_indicator_type = 1 And l_Config_Type = 2 Then
      return true;
  Else
	   return false;
  END IF;
  EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, 'Exception in IsIndicatorBalance for '||ind||' : '||sqlerrm);
  RAISE;
End;

--****************************************************************************
--  IsIndicatorBalanceOrPnL : EsIndicatorBalanceoPyg
--
--  DESCRIPTION:
--     Return TRUE if the indicator is type Balance or PnL
--
--  PARAMETERS:
--     Ind: indicator code
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IsIndicatorBalanceOrPnL(Ind IN Integer)  return Boolean IS
CURSOR cBalance IS
SELECT indicator_type, config_type FROM BSC_KPIS_VL where INDICATOR= Ind;
l_indicator_type NUMBER;
l_config_type NUMBER;
BEGIN
  OPEN cBalance;
  FETCH cBalance INTO l_indicator_type, l_config_type;
  CLOSE cBalance;
  If l_indicator_type = 1 And (l_Config_Type = 2 OR l_Config_Type = 3) Then
      return true;
  Else
	   return false;
  END IF;
  EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, 'Exception in IsIndicatorBalanceOrPnL for '||ind||' : '||sqlerrm);
  RAISE;
End;

--***************************************************************************
--  DESCRIPTION:
--     Get the number of data columns of the indicator for the given
--     dimension set.
--  PARAMETERS:
--     Indic: indicator code
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--**************************************************************************
Function get_num_measures(p_indicator IN NUMBER, p_dim_set IN NUMBER) RETURN NUMBER IS
    l_num_measures number;
    CURSOR cNumCols IS
    SELECT COUNT(M.MEASURE_COL) NUM_DATA_COLUMNS
    FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_DIM_SET_V I
    WHERE I.MEASURE_ID = M.MEASURE_ID
    AND I.DIM_SET_ID = p_dim_set
    AND I.INDICATOR = p_indicator
    AND M.TYPE = 0 AND NVL(M.SOURCE, 'BSC') in ( 'BSC', 'PMF');
BEGIN
  OPEN cNumCols;
  FETCH cNumCols INTO l_num_measures;
  CLOSE cNumCols;
  return l_num_measures;
  EXCEPTION WHEN OTHERS THEN
    raise;
End;


PROCEDURE load_sys_measures IS
  l_stmt varchar2(1000);
  l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
  l_measure_null BSC_DBGEN_STD_METADATA.clsMeasure;
  --BSC-PMF Integration: Need to filter out PMF measures
  CURSOR c1 IS
  SELECT ms.MEASURE_COL, ms.HELP, ms.MEASURE_GROUP_ID, ms.PROJECTION_ID, NVL(ms.MEASURE_TYPE, 1) MTYPE, sysm.source
  FROM BSC_DB_MEASURE_COLS_VL ms,
  BSC_SYS_MEASURES sysm
   WHERE ms.measure_col = sysm.measure_col
  ORDER BY MEASURE_COL;
  cRow c1%ROWTYPE;

BEGIN

  OPEN c1;
  LOOP
    FETCH c1 INTO cRow;
    EXIT WHEN c1%NOTFOUND;
    l_measure := l_measure_null;
    l_measure.measure_name := cRow.MEASURE_COL;
    IF (cRow.HELP IS NOT NULL) THEN
      l_measure.Description := substr(cRow.HELP, 1,240);
    END IF;
    IF (cRow.MEASURE_GROUP_ID IS NOT NULL) THEN
      l_measure.measure_group := cRow.MEASURE_GROUP_ID;
    ELSE
      l_measure.measure_group := -1;
    END IF;
    l_measure.measure_source := cRow.source;
    --projection method of the field
    --0: No Forecast
    --1: Moving Averge
    --2: Plan-Based (not used any more)
    --3: Plan-Based
    --4: Custom
    IF (cRow.PROJECTION_ID IS NOT NULL) THEN
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.PROJECTION_ID, to_char(cRow.PROJECTION_ID));
    Else
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.PROJECTION_ID, 0);--no projection
    END IF;
    l_measure.measure_type := cRow.MTYPE;
    g_sys_measures(g_sys_measures.count+1) := l_measure;
  END Loop;
  CLOSE c1;
  g_sys_measures_loaded := true;
  return;
  exception when others then
      l_stmt := sqlerrm;
      bsc_mo_helper_pkg.writeTmp('Exception in load_system_measures: '||l_stmt, FND_LOG.LEVEL_UNEXPECTED, true);
      bsc_mo_helper_pkg.TerminateWithError('BSC_VAR_LIST_INIT_FAILED', 'load_system_measures');
  	raise;
End;

--****************************************************************************
--sys_measure_exists
--
--  DESCRIPTION:
--     Return TRUE if the given field exist in the collection gLov
--
--  PARAMETERS:
--     measure: field name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function sys_measure_exists(p_measure_name IN VARCHAR2, p_measure_source IN VARCHAR2) RETURN BOOLEAN IS
    l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
    i NUMBER ;
BEGIN
  IF (g_sys_measures_loaded=false) THEN
    load_sys_measures;
  END IF;
  IF (g_sys_measures.count = 0) THEN
    return false;
  END IF;
  i :=  g_sys_measures.first;
  LOOP
	l_measure := g_sys_measures(i);
	IF (upper(l_measure.measure_Name) = upper(p_measure_name) AND upper(l_measure.measure_source) = upper(p_measure_source) ) THEN
	  return True;
	END IF;
    EXIT WHEN i = g_sys_measures.last;
	i := g_sys_measures.next(i);
  END LOOP;
  return false;
  EXCEPTION WHEN OTHERS THEN
	fnd_file.put_line(fnd_file.log, 'Exception in sys_measure_exists for field '||p_measure_name||' : '||sqlerrm);
    raise;
End ;

--****************************************************************************
--measure_exists :
--  DESCRIPTION:
--   Returns TRUE if the field exist in the collection. The collection
--   if of objects of class clsCampoDatos
--
--  PARAMETERS:
--   colMeasures: collection
--   measure: field name
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function measure_exists(p_measure_collection IN BSC_DBGEN_STD_METADATA.tab_clsMeasure, p_measure_name IN VARCHAR2, p_measure_source IN VARCHAR2)
RETURN BOOLEAN IS
  l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
  i NUMBER;

BEGIn

  IF p_measure_collection.count = 0 THEN
      return FALSE;
  END IF;

  i := p_measure_collection.first;
  LOOP
    l_measure := p_measure_collection(i);
    If (UPPER(l_measure.measure_name) = UPPER(p_measure_name) AND upper(l_measure.measure_source)=upper(p_measure_source)) Then
      return true;
    END IF;
    EXIT WHEN i = p_measure_collection.last;
    i := p_measure_collection.next(i);
  END LOOP;
  return false;

  EXCEPTION WHEN OTHERS THEN
      Fnd_File.Put_Line(Fnd_File.Log, 'Exception dataFieldExists, '||sqlerrm);
      raise;
End;



--****************************************************************************
--InsertDataColumnInDBMeasureCols
--
--  DESCRIPTION:
--   Creates the record for the internal column in BSC_DB_MEASURE_COLS_TL
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE  InsertInDBMeasureCols(P_Measure_Col IN BSC_METADATA_OPTIMIZER_PKG.clsMeasureLov) IS

l_stmt VARCHAR2(1000);
i NUMBER;

BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
   bsc_mo_helper_pkg.writeTmp( 'Inside InsertInDBMeasureCols, P_Measure_Col = ');
	END IF;

   bsc_mo_helper_pkg.write_this(P_Measure_Col);
  --Delete the records if exists
  l_stmt := 'DELETE FROM BSC_DB_MEASURE_COLS_TL WHERE MEASURE_COL = :1';
  EXECUTE IMMEDIATE l_stmt using P_Measure_Col.fieldName;

  --Because it is a TL table, we need to insert the record for every supported language
  i := BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.first;

  LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.count = 0;
      INSERT INTO BSC_DB_MEASURE_COLS_TL (
      	  MEASURE_COL, LANGUAGE, SOURCE_LANG,
        HELP, MEASURE_GROUP_ID, PROJECTION_ID, MEASURE_TYPE)
		VALUES (P_Measure_Col.fieldName, BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages(i),  BSC_METADATA_OPTIMIZER_PKG.gLangCode,
			 P_Measure_Col.Description, P_Measure_Col.groupCode, P_Measure_Col.prjMethod,P_Measure_Col.measureType );
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.last;
      i := BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.next(i);
  END LOOP;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  bsc_mo_helper_pkg.writeTmp( 'Compl. InsertInDBMeasureCols');
	END IF;


  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  Fnd_File.Put_Line(Fnd_File.Log, 'Exception in InsertInDBMeasureCols '||g_error);
	RAISE;

End;


--****************************************************************************
--AddInternalColumnInDB
--
--  DESCRIPTION:
--   Creates the record for the internal column in BSC_DB_MEASURE_COLS_TL
--   and also added to the collection gLov.
--   Projection method and type (balance or statistic) are deduced from
--   the base columns.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
/*
PROCEDURE AddInternalColumnInDB(internalColumn IN VARCHAR2, InternalColumnType NUMBER,
                  baseColumns IN dbms_sql.varchar2_table , numBaseColumns IN NUMBER) IS
  L_Measure_Col BSC_METADATA_OPTIMIZER_PKG.clsmeasureLov;
  i NUMBER;
  prjMethod NUMBER;


  l_temp number;
BEGIN

  L_Measure_Col.fieldName := internalColumn;
  l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(baseColumns.first));
  L_Measure_Col.groupCode := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode;
  L_Measure_Col.Description :=  BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INTERNAL_COLUMN');

  IF (InternalColumnType =1) THEN
        --Formula
        --The projection method of the calculated column is deduced from the
        --projection method of the operands:
        --If the projection method for one of the operands is 'No forecast'
        --then the projection method for the calculated column is 'No forecast'
        --Else, If the projection method of one of the operands is 'Custom' then:
        --If the projection method of one of the operands is 'Plan-based' then
        --the projection method of the calculated column is 'Plan-based'
        --Else, the projection method is 'Moving Average'
        --Else, if the projection method of one of the operands is 'Plan-based' then
        --the projection method of the calculated column is 'Plan-based'.
        --Else, the projection method of the calculated column is 'Moving Average'
        --Projection methods:
        --0: No Forecast
        --1: Moving Averge
        --3: Plan-Based
        --4: Custom

        L_Measure_Col.prjMethod := 1; --Moving average has the lowest priority
        i := baseColumns.first;
        LOOP
          EXIT WHEN baseColumns.count = 0;
          l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(i));
          prjMethod := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod;

          If prjMethod = 0 Then
              --No forecast
              L_Measure_Col.prjMethod := 0;
              EXIT;
          END IF;

          If prjMethod = 3 Then
              --Plan-Based
              L_Measure_Col.prjMethod := 3;
          Else
              --Moving Average of Custom
              If L_Measure_Col.prjMethod <> 3 Then
                L_Measure_Col.prjMethod := 1;
              END IF;
          END IF;
          EXIT WHEN i = baseColumns.last;
          i := baseColumns.next(i);
        END LOOP;

        --The type of the calculated column (Balance or Statistics) is
        --deduced from the type of the operands. If at least one of the operands
        --is Balance Type, then the calculated column is Balance.
        --Measure types:
        --1: Statistic
        --2: Balance
        i := baseColumns.first;
        LOOP
          EXIT WHEN baseColumns.count = 0;
          l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(i));
          L_Measure_Col.measureType := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).measureType;
          If L_Measure_Col.measureType = 2 Then
              EXIT;
          END IF;
          EXIT WHEN i = baseColumns.last;
          i := baseColumns.next(i);
        END LOOP;
  ELSIF (InternalColumnType=2 OR InternalColumnType=3) THEN
        --Total and counter for Average at Lowest Level

        --Projection method and type are the same of the base column
        --In this case there is only one base column
        l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(baseColumns.first));
        L_Measure_Col.prjMethod := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod;
        L_Measure_Col.measureType := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).measureType;
  END IF;

  If Not sys_measure_exists(internalColumn, 'BSC') Then
      IF (g_sys_measures.count>0) THEN
        g_sys_measures(g_sys_measures.last+1) := L_Measure_Col;
      ELSE
        g_sys_measures(1) := L_Measure_Col;
      END IF;
  Else
      --Update the filed with the new information
      l_temp := bsc_mo_helper_pkg.findIndex(g_sys_measures, internalColumn);
      g_sys_measures(l_temp).groupCode := L_Measure_Col.groupCode;
      g_sys_measures(l_temp).Description := L_Measure_Col.Description;
      g_sys_measures(l_temp).measureType := L_Measure_Col.measureType;
      g_sys_measures(l_temp).prjMethod := L_Measure_Col.prjMethod;
  END IF;
  InsertInDBMeasureCols( L_Measure_Col);

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Compl AddInternalColumnInDB');
  END IF;


  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      Fnd_File.Put_Line(Fnd_File.Log, 'Exception in AddInternalColumnInDB : '||g_error);
      raise;
End;
*/


--****************************************************************************
--SetMeasurePropertyDB
--  DESCRIPTION:
--   Update the given proeprty of the meaaure in the column
--   S_COLOR_FORMULA of BSC_SYS_MEAURES
--   given data column
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

PROCEDURE SetMeasurePropertyDB(dataColumn IN VARCHAR2, propertyName IN VARCHAR2, propertyValue IN VARCHAR2)
IS
   l_stmt VARCHAR2(1000);

BEGIN


  UPDATE BSC_SYS_MEASURES
	SET S_COLOR_FORMULA = BSC_APPS.SET_PROPERTY_VALUE(S_COLOR_FORMULA, propertyName, propertyValue)
	WHERE UPPER(MEASURE_COL) =  upper(dataColumn)
	AND TYPE = 0 AND NVL(SOURCE, 'BSC') = 'BSC';

  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      Fnd_File.Put_Line(Fnd_File.Log, 'Exception in SetMeasurePropertyDB : '||g_error);
      raise;
End;

--***************************************************************************
--GetAgregFunction : GetAggregateFunction
--  DESCRIPTION:
--   Returns in p_aggregation_method and pAvgL the aggregation function of the
--   given data column
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE Get_Aggregate_Function(dataColumn IN VARCHAR2, p_aggregation_method IN OUT NOCOPY VARCHAR2, pAvgL IN OUT NOCOPY VARCHAR2,
              AvgLTotalColumn IN OUT NOCOPY VARCHAR2, AvgLCounterColumn IN OUT NOCOPY VARCHAR2) IS
  l_stmt VARCHAR2(1000);
  aggFunction VARCHAR2(1000);
CURSOR C1(p1 VARCHAR2, p2 VARCHAR2, p3 VARCHAR2, p4 VARCHAR2) IS
SELECT NVL(OPERATION, 'SUM') AS OPER,
 NVL(BSC_APPS.GET_PROPERTY_VALUE(S_COLOR_FORMULA, p1),'N') AS PAVGL,
 BSC_APPS.GET_PROPERTY_VALUE(S_COLOR_FORMULA, p2) AS PAVGLTOTAL,
 BSC_APPS.GET_PROPERTY_VALUE(S_COLOR_FORMULA, p3) AS PAVGLCOUNTER
 FROM BSC_SYS_MEASURES
 WHERE UPPER(MEASURE_COL) = UPPER(p4)
 AND TYPE = 0
 AND NVL(SOURCE, 'BSC') = 'BSC';

cRow c1%ROWTYPE;

BEGIN

  OPEN c1(BSC_METADATA_OPTIMIZER_PKG.C_PAVGL,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER,
		dataColumn);
  FETCH c1 INto cRow;
  If c1%NOTFOUND Then
    p_aggregation_method := null;
    pAvgL := null;
    AvgLTotalColumn := null;
    AvgLCounterColumn := null;
  Else
    p_aggregation_method := cRow.OPER;
    pAvgL := cRow.PAVGL;
    AvgLTotalColumn := null;
    If (crow.PAVGLTOTAL is not null) Then
      AvgLTotalColumn := cRow.PAVGLTOTAL;
    END IF;
    AvgLCounterColumn := null;
    If (cRow.PAVGLCOUNTER IS NOT NULL) Then
      AvgLCounterColumn := cRow.PAVGLCOUNTER;
    END IF;
  END IF;
  close c1;
  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  Fnd_File.Put_Line(Fnd_File.Log, 'Exception in GetAggregateFunction '||g_error);
	RAISE;

End;

--***************************************************************************
--getNextInternalColumnName
--  DESCRIPTION:
--   Returns the next Internal Column Name
--   BSCIC<next value from sequence BSC_INTERNAL_COLUMN_S>
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function get_Next_Internal_Column_Name RETURN VARCHAR2 IS
l_seq NUMBER;


BEGIN
  SELECT BSC_INTERNAL_COLUMN_S.NEXTVAL INTO l_seq FROM DUAL;
	return 'BSCIC'||l_seq;
End;

-- PRIVATE API
FUNCTION Get_All_Measures_For_Fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER)
return BSC_DBGEN_STD_METADATA.tab_clsMeasure IS
  l_measure_name varchar2(1000);
  measures dbms_sql.varchar2_table;
  l_num_measures NUMBER;
  l_aggregation_method varchar2(1000);
  l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
  l_measure_null BSC_DBGEN_STD_METADATA.clsMeasure;
  colMeasures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
  i  NUMBER;
  msg VARCHAR2(1000);

  pFormulaSource VARCHAR2(1000);
  pAvgL VARCHAR2(1000);
  pAvgLTotal VARCHAR2(1000);
  pAvgLCounter VARCHAR2(1000);
  FuncAgregSingleColumn VARCHAR2(1000);
  pAvgLSingleColumn VARCHAR2(1000);
  AvgLTotalColumn VARCHAR2(1000);
  AvgLCounterColumn VARCHAR2(1000);
  l_measure_type NUMBER;
  l_measure_id NUMBER;

  l_stmt2 VARCHAR2(1000):= 'SELECT distinct nvl(M.MEASURE_COL, C.COLUMN_NAME), NVL(M.OPERATION, ''SUM'') AS OPER,
  BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :1) AS PFORMULASOURCE,
  NVL(BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :2 ),''N'') AS PAVGL,
  BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :3) AS PAVGLTOTAL,
  BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :4) AS PAVGLCOUNTER,
  M.MEASURE_ID, nvl(cols.measure_type, 1) measure_type, m.source
  FROM BSC_SYS_MEASURES M, BSC_DB_TABLES_COLS C, BSC_DB_MEASURE_COLS_VL COLS
  WHERE  M.MEASURE_COL(+) = C.COLUMN_NAME
  AND COLS.measure_col(+) = c.column_name
  AND C.COLUMN_TYPE = ''A''
  AND C.TABLE_NAME LIKE ''BSC_S%'||p_fact||'_'||p_dim_set||'%'||'''
  AND M.TYPE(+) = 0';
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
  l_measure_source varchar2(30);
BEGIN

  OPEN cv for l_stmt2 USING BSC_METADATA_OPTIMIZER_PKG.C_PFORMULASOURCE,
       BSC_METADATA_OPTIMIZER_PKG.C_PAVGL,
       BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL,
       BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER;
  LOOP
    FETCH cv INTO l_measure_name, l_aggregation_method, pFormulaSource, pAvgL, pAvgLTotal, pAvgLCounter, l_measure_id, l_measure_type, l_measure_source;
    EXIT WHEN cv%NOTFOUND;
    Measures := BSC_DBGEN_UTILS.get_measure_list(l_measure_name);
    l_num_measures := Measures.count;
    i := Measures.first;
    LOOP
      EXIT WHEN Measures.count = 0;
      If Not measure_exists(colMeasures, Measures(i), l_measure_source) Then
        --Get the aggregation function and Avgl flag of the column (single column)
        Get_Aggregate_Function (Measures(i), FuncAgregSingleColumn, pAvgLSingleColumn, AvgLTotalColumn, AvgLCounterColumn);
        If FuncAgregSingleColumn IS NULL Then
          FuncAgregSingleColumn := l_aggregation_method;
        END IF;
        If pAvgLSingleColumn IS NULL Then
          pAvgLSingleColumn := pAvgL;
        END IF;
        l_measure := l_measure_null;
        l_measure.measure_Name := Measures(i);
        l_measure.measure_id := l_measure_id;
        l_measure.measure_type := l_measure_type;
        l_measure.AGGREGATION_method := FuncAgregSingleColumn;
        l_measure.datatype := 'NUMBER';
        l_measure.measure_source := l_measure_source;
        bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_SINGLE_COLUMN, pAvgLSingleColumn);
        If pAvgLSingleColumn = 'Y' Then
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_TOTAL_COLUMN, AvgLTotalColumn);
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_COUNTER_COLUMN, AvgLCounterColumn);
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.SOURCE_FORMULA, AvgLTotalColumn||'/'||AvgLCounterColumn);
        END IF;
      END IF;
      EXIT WHEN i = Measures.last;
      i := Measures.next(i);
    END LOOP;
    colMeasures(colMeasures.count +1 ) :=  l_measure;
  END Loop;
  close cv;
  return colMeasures;
  EXCEPTION WHEN OTHERS THEN
  raise;
END;



--***************************************************************************
--  DESCRIPTION:
--  handle missing levels, if Country<-State<-City is the actual relationship
--  and if only Country and City are configured for the KPI, return the
--  parent child relationship between Country and City as true if it can
--  be derived thru some rollup
--  PARAMETERS:
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
function is_parent_1N_any_level(p_child_level IN VARCHAR2, p_parent_level IN VARCHAR2,
   p_missing_levels OUT nocopy dbms_sql.varchar2_table ) RETURN boolean AS
 CURSOR cParent IS
WITH tree AS
(
   SELECT childlvl.level_Table_name child_lvl
        , parentlvl.level_Table_name parent_lvl
        , LEVEL lvl
     FROM bsc_sys_dim_level_rels rels, bsc_sys_dim_levels_b childlvl, bsc_sys_dim_levels_b parentlvl
    WHERE rels.parent_dim_level_id = parentlvl.dim_level_id
      AND rels.dim_level_id = childlvl.dim_level_id
    START WITH parent_dim_level_id = parentlvl.dim_level_id
      AND parentlvl.level_table_name = p_parent_level
  CONNECT BY rels.parent_dim_level_id||rels.relation_type  = PRIOR rels.dim_level_id||1
)
  SELECT parent_lvl, child_lvl
    FROM tree
 CONNECT BY PRIOR parent_lvl = child_lvl
     AND PRIOR lvl = lvl + 1
   START WITH child_lvl = p_child_level
     AND lvl =
        (
          SELECT MIN(lvl)
            FROM tree
           WHERE child_lvl = p_child_level
        );

    b_parent boolean := false;
BEGIN
  FOR i IN cParent LOOP
    b_parent := true;
    IF (i.parent_lvl <> p_parent_level) THEN
      p_missing_levels(p_missing_levels.count+1) := i.parent_lvl;
    END IF;
  END LOOP;
  return b_parent;
  EXCEPTION WHEN OTHERS THEN
    raise;
End;

--***************************************************************************
--  DESCRIPTION:
--  PARAMETERS:
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function is_parent_1N(p_child_level IN VARCHAR2, p_parent_level IN VARCHAR2 ) RETURN boolean IS

 CURSOR cParent is
  SELECT count(1)
  FROM BSC_SYS_DIM_LEVELS_B child_lvl, BSC_SYS_DIM_LEVELS_B parent_lvl, BSC_SYS_DIM_LEVEL_RELS Rels
  WHERE
  child_lvl.LEVEL_TABLE_NAME  = p_child_level
  AND parent_lvl.level_table_name= p_parent_level
  AND child_lvl.DIM_LEVEL_ID  = Rels.DIM_LEVEL_ID
  AND parent_lvl.DIM_LEVEL_ID = Rels.PARENT_DIM_LEVEL_ID
  AND Rels.RELATION_TYPE = 1;
  l_count NUMBER;
BEGIN

  OPEN cParent;
  FETCH cParent INTO l_count;
  CLOSE cParent;

  IF (l_count > 0) THEN
    return true;
  ELSE
    return false;
  END IF;
  EXCEPTION WHEN OTHERS THEN
    raise;
End;

--***************************************************************************
--  DESCRIPTION:
--  PARAMETERS:
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function is_parent_MN(p_child_level IN VARCHAR2, p_parent_level IN VARCHAR2 ) RETURN boolean IS
 CURSOR cParent IS
  SELECT count(1)
  FROM BSC_SYS_DIM_LEVELS_B child_lvl, BSC_SYS_DIM_LEVELS_B parent_lvl, BSC_SYS_DIM_LEVEL_RELS Rels
  WHERE
  child_lvl.LEVEL_TABLE_NAME  = p_child_level
  AND parent_lvl.level_table_name= p_parent_level
  AND child_lvl.DIM_LEVEL_ID  = Rels.DIM_LEVEL_ID
  AND parent_lvl.DIM_LEVEL_ID = Rels.PARENT_DIM_LEVEL_ID
  AND Rels.RELATION_TYPE = 2;
  l_count NUMBER;
BEGIN
  OPEN cParent;
  FETCH cParent INTO l_count;
  CLOSE cParent;
  IF (l_count > 0) THEN
    return true;
  ELSE
    return false;
  END IF;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in is_parent_MN : '||g_error||', p_child_level='||p_child_level||', p_parent_level='||p_parent_level);
    raise;
End;


--****************************************************************************
--  DESCRIPTION:
--   Returns the index of the Levels family of the collection
--   l_dimensions which the given dimension belongs to.
--
--  PARAMETERS:
--   l_dimensions: Levels families collection
--   Maestra: dimension table name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function get_Dimension_Index(p_dimensions IN BSC_DBGEN_STD_METADATA.tab_clsDimension,
                             p_level IN VARCHAR2,
							 p_include_missing_levels IN BOOLEAN,
							 p_missing_levels OUT nocopy DBMS_SQL.VARCHAR2_TABLE)
return NUMBER IS
  l_dimension BSC_DBGEN_STD_METADATA.clsDimension;
  l_level  BSC_DBGEN_STD_METADATA.clsLevel;
  l_ct NUMBER := 0;
  j NUMBER := 0;
  l_groups DBMS_SQL.NUMBER_TABLE;
  l_missing_levels DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  IF (p_dimensions.count =0 ) THEN
    return -1;
  END IF;
  IF (p_include_missing_levels = false) THEN
    FOR i IN p_dimensions.first..p_dimensions.last LOOP
	  l_dimension := p_dimensions(i);
	  FOR j IN l_dimension.Hierarchies(1).Levels.first..l_dimension.Hierarchies(1).Levels.last LOOP
	    l_level := l_dimension.Hierarchies(1).levels(j);
        If  is_parent_1N(p_level, l_level.level_table_name) Then
	      return i;
	    END IF;
        If is_parent_MN(p_level, l_level.level_table_name) Then
	      return i;
        END IF;
      END LOOP;
    END LOOP;
  ELSE
    FOR i IN p_dimensions.first..p_dimensions.last LOOP
	  l_dimension := p_dimensions(i);
	  FOR j IN l_dimension.Hierarchies(1).Levels.first..l_dimension.Hierarchies(1).Levels.last LOOP
	    l_level := l_dimension.Hierarchies(1).levels(j);
        If  is_parent_1N_any_level(p_level, l_level.level_table_name, l_missing_levels ) Then
	      return i;
	    END IF;
        If is_parent_MN(p_level, l_level.level_table_name) Then
	      return i;
        END IF;
      END LOOP;
    END LOOP;
  END IF;
  return -1;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in getDimensionIndex '||g_error);
    RAISE;
End ;


PROCEDURE insert_parents(p_periodicity IN NUMBER, p_parents IN VARCHAR2, p_periodicity_list IN BSC_DBGEN_STD_METADATA.tab_clsPeriodicity) IS
l_parents_list DBMS_SQL.NUMBER_TABLE;
l_table_name VARCHAR2(100) := 'bsc_tmp_per_circ_'||userenv('SESSIONID');
l_stmt VARCHAR2(1000) := 'INSERT INTO '||l_table_name||'(periodicity, source) values (:1, :2)';
l_index NUMBER;
l_per_id_list DBMS_SQL.NUMBER_TABLE;
BEGIN
  l_parents_list := bsc_mo_helper_pkg.decomposeStringtoNumber(p_parents, ',');
  IF (p_periodicity_list.count>0) THEN
    FOR i IN p_periodicity_list.first..p_periodicity_list.last LOOP
      l_per_id_list(l_per_id_list.count+1) :=p_periodicity_list(i).periodicity_id;
    END LOOP;
  END IF;
  IF l_parents_list.count>0 THEN
    FOR i IN l_parents_list.first..l_parents_list.last LOOP
      IF bsc_mo_helper_pkg.searchNumberExists(l_per_id_list, l_per_id_list.count, l_parents_list(i)) THEN
        execute immediate l_stmt USING p_periodicity, l_parents_list(i);
      END IF;
    end loop;
  END IF;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in bsc_dbgen_bsc_reader.insert_parents '||g_error);
    RAISE;
END;

FUNCTION configure_parent_periods(p_periodicity_list IN OUT nocopy BSC_DBGEN_STD_METADATA.tab_clsPeriodicity)
RETURN BSC_DBGEN_STD_METADATA.tab_clsPeriodicity IS
PRAGMA AUTONOMOUS_TRANSACTION;
  l_table_name VARCHAR2(100) := 'bsc_tmp_per_circ_'||userenv('SESSIONID');
  l_stmt VARCHAR2(1000) := 'CREATE TABLE '||l_table_name||'(periodicity NUMBER, source NUMBER)';
  CURSOR cPeriods (p_periodicity NUMBER) IS
  SELECT SOURCE
  FROM BSC_SYS_PERIODICITIES_VL
  WHERE PERIODICITY_ID=p_periodicity;
  l_parents VARCHAR2(4000);
  l_temp NUMBER;
  l_periodicity_list BSC_DBGEN_STD_METADATA.tab_clsPeriodicity;
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
BEGIN
  l_periodicity_list := p_periodicity_list;
  bsc_mo_helper_pkg.dropTable(l_table_name);
  bsc_mo_helper_pkg.Do_DDL(l_stmt, ad_ddl.create_table, l_table_name);
  IF p_periodicity_list.count>0 THEN
    FOR i IN p_periodicity_list.first..p_periodicity_list.last LOOP
      OPEN cPeriods(p_periodicity_list(i).periodicity_id);
      FETCH cPeriods INTO l_parents;
      insert_parents(p_periodicity_list(i).periodicity_id, l_parents, p_periodicity_list);
      CLOSE cPeriods;
    END LOOP;
    commit;
  END IF;
  l_stmt := ' select distinct source from '||l_table_name||' connect by periodicity = prior source start with periodicity = :1';
  IF (p_periodicity_list.count>0) THEN
    FOR i IN p_periodicity_list.first..p_periodicity_list.last LOOP
      BEGIN
        OPEN cv FOR l_stmt USING p_periodicity_list(i).periodicity_id;
        LOOP
          FETCH cv INTO l_temp;
          EXIT WHEN cv%NOTFOUND;
          p_periodicity_list(i).parent_periods(p_periodicity_list(i).parent_periods.count+1) := l_temp;
        END LOOP;
        CLOSE cv;
        EXCEPTION WHEN OTHERS THEN
          raise;
        END ;
    END LOOP;
  END IF;
  bsc_mo_helper_pkg.dropTable(l_table_name);
  commit;
  return p_periodicity_list;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in bsc_dbgen_bsc_reader.configure_parent_periods '||g_error);
    RAISE;
END;


FUNCTION Get_Fact_Info(p_process_id IN NUMBER, p_prototype_flag IN NUMBER, p_fact_list IN DBMS_SQL.NUMBER_TABLE ) return BSC_DBGEN_STD_METADATA.tab_clsFact IS
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
TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
    l_fact BSC_DBGEN_STD_METADATA.clsFact;
  l_fact_list BSC_DBGEN_STD_METADATA.tab_clsFact;
  strWhereInIndics VARCHAR2(1000);
BEGIN


  l_stmt := 'SELECT DISTINCT INDICATOR, NAME, PROTOTYPE_FLAG,
      INDICATOR_TYPE, CONFIG_TYPE, PERIODICITY_ID,
      SHARE_FLAG, SOURCE_INDICATOR
      FROM BSC_KPIS_VL ';
  IF (p_process_id IS NOT NULL) THEN
    l_stmt := l_stmt || ' where prototype_flag =:prototype_flag and indicator in
	  (SELECT to_number(fact_name) FROM BSC_DB_GEN_KPI_LIST WHERE process_id = :process_ID)';
    l_Stmt := l_stmt || ' ORDER BY INDICATOR ';
    OPEN cv FOR l_stmt using p_prototype_flag, p_process_id;
  ELSE
    strWhereInIndics := BSC_DBGEN_UTILS.Get_New_Big_In_Cond_Number(10, 'INDICATOR');
    IF (l_fact_list.count>0) THEN
      FOR i IN l_fact_list.first..l_fact_list.last LOOP
  	    BSC_DBGEN_UTILS.Add_Value_Big_In_Cond_Number( 9, p_fact_list(i));
  	  END LOOP;
  	END IF;
  	l_stmt := l_stmt || ' where '||strWhereInIndics;
	l_Stmt := l_stmt || ' ORDER BY INDICATOR ';
    OPEN cv FOR l_stmt;
  END IF;
  LOOP
    FETCH cv into l_code, l_name, l_action_flag,
      l_IndicatorType, l_configType, l_per_inter, l_share_flag, l_source_indicator;
    EXIT WHEN cv%NOTFOUND;
    l_optimizationMode := BSC_DBGEN_UTILS.get_KPI_Property_Value(l_Code, 'DB_TRANSFORM', 1);
    IF l_Action_Flag <> 2 THEN
      l_Action_Flag := 3;
    END IF;
    l_fact.Fact_ID := l_code;
    l_fact.Fact_Name := l_name;
    l_fact.fact_type := l_indicatorType;
	l_fact.Application_short_name := 'BSC';
	bsc_dbgen_utils.add_property(l_fact.properties, BSC_DBGEN_STD_METADATA.PROTOTYPE_FLAG, l_action_flag);
    bsc_dbgen_utils.add_property(l_fact.properties, BSC_DBGEN_STD_METADATA.CONFIG_TYPE, l_ConfigType);
    bsc_dbgen_utils.add_property(l_fact.properties, BSC_DBGEN_STD_METADATA.PERIODICITY_ID, l_per_inter);
    bsc_dbgen_utils.add_property(l_fact.properties, BSC_DBGEN_STD_METADATA.OPTIMIZATION_MODE, l_OptimizationMode);
    bsc_dbgen_utils.add_property(l_fact.properties, BSC_DBGEN_STD_METADATA.SHARE_FLAG,l_share_flag);
    bsc_dbgen_utils.add_property(l_fact.properties, BSC_DBGEN_STD_METADATA.SOURCE_INDICATOR, nvl(l_source_indicator, 0));
    l_fact_list(l_fact_list.count+1) := l_fact;
  END Loop;
  CLOSE cv;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in bsc_dbgen_bsc_reader.get_fact_info '||g_error);
    RAISE;

END;
FUNCTION Get_Fact_Info(p_process_id IN NUMBER, p_prototype_flag IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact IS
l_id_list DBMS_SQL.NUMBER_TABLE;
BEGIN
  return Get_Fact_Info(p_process_id, p_prototype_flag, l_id_list);
END;

FUNCTION Get_Facts_To_Recreate(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact IS
BEGIN
  return get_fact_info(p_process_id, 3);
END;

FUNCTION Get_Facts_To_Delete(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact IS
BEGIN
  return get_fact_info(p_process_id, 2);
END;

FUNCTION Get_Facts_To_Recalculate(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact IS
  l_stmt Varchar2(1000);
  strWhereInIndics Varchar2(1000);
  strWhereNotInIndics Varchar2(1000);
  strWhereInMeasures Varchar2(1000);
  i NUMBER := 0;
  arrMeasuresCols  DBMS_SQL.VARCHAR2_TABLE;
  arrRelatedMeasuresIds DBMS_SQL.NUMBER_TABLE;

  --measureCol Varchar2(1000);
  Operands DBMS_SQL.VARCHAR2_TABLE;
  NumOperands NUMBER;
	l_measureID NUMBER;
	l_measureCol VARCHAR2(500);
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;

  l_error varchar2(400);
  l_indicator_id NUMBER;
  l_fact_list BSC_DBGEN_STD_METADATA.tab_clsFact;
  l_fact BSC_DBGEN_STD_METADATA.clsFact;
  l_fact_ids DBMS_SQL.NUMBER_TABLE;
  l_num_measures NUMBER;
BEGIN
  l_fact_list := get_fact_info(p_process_id, 4);
  IF (l_fact_list.count = 0) THEN
    return l_fact_list;
  END IF;
  --Init and array with the measures used by the indicators flagged for
  --non-structural changes
  l_num_measures := 0;
  strWhereInIndics := BSC_DBGEN_UTILS.Get_New_Big_In_Cond_Number(9, 'I.INDICATOR');
  i:= 0;
  LOOP
  	EXIT WHEN i=l_fact_list.count;
  	BSC_DBGEN_UTILS.Add_Value_Big_In_Cond_Number( 9, l_fact_list(i).fact_id);
  	i:=i+1;
  END LOOP;
  --PMF-BSC Integration: Filter out PMF measures
  l_stmt := 'SELECT DISTINCT M.MEASURE_COL FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_DIM_SET_V I'
		|| ' WHERE I.MEASURE_ID = M.MEASURE_ID AND ('|| strWhereInIndics ||' )'||
		'  AND M.TYPE = 0  AND NVL(M.SOURCE, ''BSC'') in (''PMF'', ''BSC'') ';
  OPEN cv FOR l_stmt;
  LOOP
  	FETCH cv INTO l_measureCol;
  	EXIT when cv%NOTFOUND;
    arrMeasuresCols(l_num_measures) := l_measureCol;
  END Loop;
  CLOSE cv;
  /*The measures in the array arrMeasuresCols are the ones that could be changed
      For that reason the indicators were flaged to 4
      We need to see in all system measures if there is a formula using that measure.
      IF that happen we need to add that measure. Any kpi using that meaure should be flaged too.*/
  strWhereNotInIndics := ' NOT ( ' || strWhereInIndics || ')';
  l_stmt := 'SELECT DISTINCT M.MEASURE_ID, M.MEASURE_COL '
		||'FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_DIM_SET_V I '||
		' WHERE I.MEASURE_ID = M.MEASURE_ID AND ('|| strWhereNotInIndics ||' ) '||
		'  AND M.TYPE = 0 AND NVL(M.SOURCE, ''BSC'') in (''BSC'', ''PMF'')';
  OPEN cv FOR l_stmt;
  LOOP
  	FETCH cv into l_measureID, l_measureCol;
  	EXIT WHEN cv%NOTFOUND;
    NumOperands := BSC_MO_HELPER_PKG.GetFieldExpression(Operands, l_measureCol);
    i:= Operands.first;
    LOOP
      EXIT WHEN Operands.count =0 ;
      IF BSC_MO_HELPER_PKG.SearchStringExists(arrMeasuresCols, arrMeasuresCols.count, Operands(i)) THEN
        --One operand of the formula is one of the measures of a indicator flagged with 4
        --We need to add this formula (measure) to the related ones
        arrRelatedMeasuresIds(arrRelatedMeasuresIds.count+1) := l_measureID;
      END IF;
      EXIT WHEN i = Operands.last;
      i:= Operands.next(i);
    END LOOP;
  END Loop;
  CLOSE cv;
  --Now we need to add to the indicator list all the indicators using any of the measures
  --in arrRelatedMeasuresIds()
  IF arrRelatedMeasuresIds.count > 0 THEN
    strWhereInMeasures := BSC_DBGEN_UTILS.Get_New_Big_In_Cond_Number( 9, 'MEASURE_ID');
    i:= arrRelatedMeasuresIds.first;
    LOOP
      EXIT WHEN i=arrRelatedMeasuresIds.last;
      BSC_DBGEN_UTILS.Add_Value_Big_In_Cond_Number( 9, arrRelatedMeasuresIds(i));
      i:= arrRelatedMeasuresIds.next(i);
    END LOOP;
    l_stmt := 'SELECT DISTINCT INDICATOR FROM BSC_DB_MEASURE_BY_DIM_SET_V  '||
              ' WHERE ('|| strWhereInMeasures || ')';
    open cv for L_stmt;
    LOOP
      FETCH cv into l_indicator_id;/*Indicator*/
      EXIT WHEN cv%NOTFOUND;
      IF Not bsc_mo_helper_pkg.SearchNumberExists(l_fact_ids, l_fact_ids.count, l_indicator_id) THEN
        l_fact_ids(l_fact_ids.count+1) := l_indicator_id;
      END IF;
    END Loop;
    CLOSE cv;
  END IF;
  return Get_Fact_Info(null, null, l_fact_ids);
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in Get_Facts_To_Recalculate : '||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
END;

FUNCTION Fact_ID_Exists(p_facts IN BSC_DBGEN_STD_METADATA.tab_clsFact, p_fact_id IN NUMBER) RETURN BOOLEAN IS
BEGIN
  IF (p_facts.count=0) THEN
    return false;
  END IF;
  FOR i IN p_facts.first..p_facts.last LOOP
    IF (p_facts(i).fact_id = p_fact_id) THEN
      return true;
    END IF;
  END LOOP;
  return false;
END;

-- PUBLIC APIs

--first find the highest S table for this kpi, dim_set, then reuse get_levels_for_table api
--note we ignore the periodicity here
FUNCTION get_highest_s_table(p_fact IN VARCHAR2, p_dim_set IN NUMBER) return VARCHAR2 IS
  CURSOR cSTable(p_table varchar2) IS
  select table_name, count(1) ct from bsc_db_calculations
where table_name like p_table
and calculation_type=4
group by table_name
having count(1)=
(
select max(ct) from(
select table_name, count(1) ct from bsc_db_calculations
where table_name like p_table
and calculation_type=4
group by table_name )
);

l_s_tablename VARCHAR2(300);
l_dummy number;
BEGIn
  OPEN cSTable('BSC_S_'||p_fact||'_'||p_dim_set||'%');
  FETCH cSTable INTO l_s_tablename, l_dummy;
  CLOSE cSTable;
  return l_s_tablename;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in bsc_dbgen_bsc_reader.get_highest_s_table '||g_error);
    RAISE;
END;

FUNCTION get_lowest_s_table(p_fact IN VARCHAR2, p_dim_set IN NUMBER) return VARCHAR2 IS
  CURSOR cSTable(p_fact_pattern varchar2, p_s_pattern varchar2) IS
select table_name from bsc_db_Tables_rels
where table_name like p_fact_pattern
and source_table_name not like p_s_pattern;
l_s_tablename VARCHAR2(300);
BEGIn
  OPEN cSTable('BSC_S_'||p_fact||'_'||p_dim_set||'%', 'BSC_S%');
  FETCH cSTable INTO l_s_tablename;
  CLOSE cSTable;
  return l_s_tablename;
END;

FUNCTION Get_Facts_To_Process(p_process_id IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsFact IS
l_fact_list BSC_DBGEN_STD_METADATA.tab_clsFact;
l_fact_list_temp BSC_DBGEN_STD_METADATA.tab_clsFact;
BEGIN
  l_fact_list := Get_Facts_To_Recreate(p_process_id);
  l_fact_list_temp := Get_Facts_To_Delete(p_process_id);
  IF l_fact_list_temp.count >0 THEN
    FOR i IN l_fact_list_temp.first..l_fact_list_temp.last LOOP
      IF fact_id_exists(l_fact_list, l_fact_list_temp(i).fact_id)=false THEN
        l_fact_list(l_fact_list.count+1) := l_fact_list_temp(i);
      END IF;
    END LOOP;
  END IF;
  l_fact_list_temp := Get_Facts_To_recalculate(p_process_id);
  IF l_fact_list_temp.count >0 THEN
    FOR i IN l_fact_list_temp.first..l_fact_list_temp.last LOOP
      IF fact_id_exists(l_fact_list, l_fact_list_temp(i).fact_id)=false THEN
        l_fact_list(l_fact_list.count+1) := l_fact_list_temp(i);
      END IF;
    END LOOP;
  END IF;
  return l_fact_list;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in bsc_dbgen_bsc_reader.get_lowest_s_table'||g_error);
    RAISE;
END;



FUNCTION Get_Measures_For_Fact_dbgen(p_fact IN VARCHAR2, p_dim_set IN NUMBER) return BSC_DBGEN_STD_METADATA.tab_clsMeasure IS
  l_stmt  VARCHAR2(1000);
  l_measure_name varchar2(1000);
  measures dbms_sql.varchar2_table;
  l_num_measures NUMBER;
  l_aggregation_method varchar2(1000);
  l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
  l_measure_null BSC_DBGEN_STD_METADATA.clsMeasure;
  colMeasures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
  i  NUMBER;
  msg VARCHAR2(1000);

  pFormulaSource VARCHAR2(1000);
  pAvgL VARCHAR2(1000);
  pAvgLTotal VARCHAR2(1000);
  pAvgLCounter VARCHAR2(1000);
  FuncAgregSingleColumn VARCHAR2(1000);
  pAvgLSingleColumn VARCHAR2(1000);
  AvgLTotalColumn VARCHAR2(1000);
  AvgLCounterColumn VARCHAR2(1000);
  baseColumn dbms_sql.varchar2_table;

  l_stmt2 VARCHAR2(1000):= 'SELECT M.MEASURE_COL, NVL(M.OPERATION, ''SUM'') AS OPER,
  BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :1) AS PFORMULASOURCE,
  NVL(BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :2 ),''N'') AS PAVGL,
  BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :3) AS PAVGLTOTAL,
  BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :4) AS PAVGLCOUNTER,
  M.source
  FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_DIM_SET_V I
  WHERE I.MEASURE_ID = M.MEASURE_ID
  AND I.MEASURE_COL = M.MEASURE_COL
  AND I.DIM_SET_ID = :5
  AND I.INDICATOR = :6
  AND M.TYPE = 0
  AND NVL(M.SOURCE, ''BSC'') in(''PMF'', ''BSC'') ';
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
  l_measure_source varchar2(30);
BEGIN
  bsc_mo_helper_pkg.writeTmp( 'Inside GetMeasuresForFact, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
  OPEN cv for l_stmt2 USING BSC_METADATA_OPTIMIZER_PKG.C_PFORMULASOURCE,
       BSC_METADATA_OPTIMIZER_PKG.C_PAVGL,
       BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL,
       BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER, p_dim_set, to_number(p_fact);

  LOOP
    FETCH cv INTO l_measure_name, l_aggregation_method, pFormulaSource, pAvgL, pAvgLTotal, pAvgLCounter, l_measure_source ;
    EXIT WHEN cv%NOTFOUND;
    Measures := BSC_DBGEN_UTILS.get_measure_list(l_measure_name);
    l_num_measures := Measures.count;
    i := Measures.first;
    LOOP
      EXIT WHEN Measures.count = 0;
      If sys_measure_exists(Measures(i), l_measure_source) Then
        If Not measure_exists(colMeasures, Measures(i), l_measure_source) Then
          --Get the aggregation function and Avgl flag of the column (single column)
          Get_Aggregate_Function (Measures(i), FuncAgregSingleColumn, pAvgLSingleColumn, AvgLTotalColumn, AvgLCounterColumn);
          If FuncAgregSingleColumn IS NULL Then
            FuncAgregSingleColumn := l_aggregation_method;
          END IF;
          If pAvgLSingleColumn IS NULL Then
            pAvgLSingleColumn := pAvgL;
          END IF;
          l_measure := l_measure_null;
          l_measure.measure_Name := Measures(i);
          l_measure.AGGREGATION_method := FuncAgregSingleColumn;
          l_measure.datatype := 'NUMBER';
          l_measure.measure_source := l_measure_source;
          --l_measure.Origen is not set
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_SINGLE_COLUMN, pAvgLSingleColumn);
          If pAvgLSingleColumn = 'Y' Then
            --This is a single column, we can have AvgL on a single column.
            --We need two internal columns: one for total and one for counter
            --Also we need to add the internal columns in gLov and in
            --BSC_DB_MEASURES_COLS_TL table
            baseColumn(0) := Measures(i);
            If AvgLTotalColumn IS NULL Then
              AvgLTotalColumn := get_Next_Internal_Column_Name;
              --Update the measure property pAvgLTotal in the database
              SetMeasurePropertyDB (Measures(i), BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL, AvgLTotalColumn);
            END IF;
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_TOTAL_COLUMN, AvgLTotalColumn);
            --AddInternalColumnInDB(AvgLTotalColumn, 2, baseColumn, 1);
            If AvgLCounterColumn IS NULL Then
              AvgLCounterColumn := get_Next_Internal_Column_Name;
              --Update the measure property pAvgLCounter in the database
              SetMeasurePropertyDB (Measures(i), BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER, AvgLCounterColumn);
            END IF;
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_COUNTER_COLUMN, AvgLCounterColumn);
            --AddInternalColumnInDB(AvgLCounterColumn, 3, baseColumn, 1);
          END IF;
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_TYPE, 0); -- Normal
          colMeasures(colMeasures.count+1) :=  l_measure;

          If pAvgLSingleColumn = 'Y' Then
            --Add the two internal column for AvgL in the collection
            --Column for Total
            l_measure := l_measure_null;
            l_measure.measure_name := AvgLTotalColumn;
            l_measure.aggregation_method := 'SUM';
            l_measure.datatype := 'NUMBER';
            --l_measure.Origen is not set
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_FLAG, 'N');
            --l_measure.avgLTotalColumn does not apply
            --l_measure.avgLCounterColumn does not apply

			bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_TYPE, 2); --Internal column for Total of AvgL
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_SOURCE, Measures(i));
            colMeasures(colMeasures.count+1) := l_measure;
            --Column for Counter
            l_measure := l_measure_null;
			l_measure.measure_Name := AvgLCounterColumn;
            l_measure.AGGREGATION_method := 'SUM';
            l_measure.datatype := 'NUMBER';
            --l_measure.Origen is not set
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_FLAG, 'N');
            --l_measure.avgLTotalColumn does not apply
            --l_measure.avgLCounterColumn does not apply
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_TYPE, 3); --Internal column for Counter of AvgL
            bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_SOURCE, Measures(i));
            colMeasures(colMeasures.count+1) := l_measure;
          END IF;
        END IF;

      ELSE
        raise bsc_metadata_optimizer_pkg.optimizer_exception ;
        EXIT ;
      END IF;
      EXIT WHEN i = Measures.last;
      i := Measures.next(i);
    END LOOP;

    --Now add internal column if the formula needs to calculated in another column
    If pFormulaSource IS NOT NULL Then
      --Add the internal column in gLov and in BSC_DB_MEASURES_COLS_TL table
      --AddInternalColumnInDB(pFormulaSource, 1, Measures, l_num_measures);
      l_measure := l_measure_null;
      l_measure.measure_Name := pFormulaSource;
      l_measure.aggregation_method := l_aggregation_method;
      l_measure.datatype := 'NUMBER';
      --l_measure.Origen is not set
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_FLAG, pAvgL);
      If pAvgL = 'Y' Then
        --This is a formula calculated in another column, we can have AvgL on a that.
        --We need to internal columns: one for total and one for counter
        --Also we need to add the internal columns in gLov and in
        --BSC_DB_MEASURES_COLS_TL table
        If pAvgLTotal IS NULL Then
          pAvgLTotal := get_Next_Internal_Column_Name ;
          --Update the measure property pAvgLTotal in the database
          SetMeasurePropertyDB( l_measure_name, BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL, pAvgLTotal);
        END IF;
        --AddInternalColumnInDB(pAvgLTotal, 2, Measures, l_num_measures);
        bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_TOTAL_COLUMN, pAvgLTotal);
        If pAvgLCounter IS NULL Then
          pAvgLCounter := get_Next_Internal_Column_Name;
          --Update the measure property pAvgLTotal in the database
          SetMeasurePropertyDB( l_measure_name, BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER, pAvgLCounter);
        END IF;
        --AddInternalColumnInDB( pAvgLCounter, 3, Measures, l_num_measures);
        bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_COUNTER_COLUMN, pAvgLCounter);
      END IF;
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_TYPE, 1); --Internal column for formula
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_SOURCE, l_measure_name); -- Formula Example A/
      colMeasures(colMeasures.last +1 ) :=  l_measure;
      If pAvgL = 'Y' Then
        --Add the two internal column for AvgL in the collection
        --Bug 2993089: When the column is not a formula but has the option
        --Apply rollup to formula', the columns for Average at lowest level
        --are already in colCamporDatos.
        --We need to evaluate this situation adding te condition
        --If Not Existel_measure(colMeasures, <internal column for AvgL>)
        --Column for Total
        If Not measure_exists(colMeasures, pAvgLTotal, 'BSC') Then
          l_measure := l_measure_null;
          l_measure.measure_Name := pAvgLTotal;
          l_measure.AGGREGATION_method := 'SUM';
          l_measure.datatype := 'NUMBER';
		  --l_measure.Origen is not set
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_FLAG, 'N');
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_TYPE, 2); -- 'Internal column for Total of AvgL
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_SOURCE, l_measure_name); -- Formula Example A/B
          colMeasures(colMeasures.last+1) :=  l_measure ;
        END IF;
        --Column for Counter
        If Not measure_exists(colMeasures, pAvgLCounter, 'BSC') Then
          l_measure := l_measure_null;
          l_measure.measure_name := pAvgLCounter;
          l_measure.AGGREGATION_METHOD := 'SUM';
          l_measure.datatype := 'NUMBER';
		  --l_measure.Origen is not set
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.AVGL_FLAG, 'N');
          --l_measure.avgLTotalColumn does not apply
          --l_measure.avgLCounterColumn does not apply
		  bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_TYPE, 3); --Internal column for Counter of AvgL
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.INTERNAL_COLUMN_SOURCE, l_measure_name); -- Formula Example A/B
          colMeasures(colMeasures.last+1) := l_measure ;
        END IF;
      END IF;
    END IF;
  END Loop;
  close cv;

  bsc_mo_helper_pkg.writeTmp( 'Compl. GetMeasuresForFact, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
  return colMeasures;
EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    fnd_file.put_line(fnd_file.log, 'Exception in bsc_dbgen_bsc_reader.get_measures_for_fact, p_fact='||p_fact||', dimset='||p_dim_set||g_error);
    RAISE;
END;

FUNCTION Get_Measures_For_Fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_derived_columns IN BOOLEAN default false) return BSC_DBGEN_STD_METADATA.tab_clsMeasure IS

  CURSOR cMeasureList IS
  SELECT M.MEASURE_COL, NVL(M.OPERATION, 'SUM') AS OPER, m.source measure_source
    FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_DIM_SET_V I
   WHERE I.MEASURE_ID = M.MEASURE_ID
     AND I.DIM_SET_ID = p_dim_set
     AND I.INDICATOR = to_number(p_fact)
     AND M.TYPE = 0
     AND NVL(M.SOURCE, 'BSC') in('PMF', 'BSC');

 CURSOR cProperties(p_col VARCHAR2) IS
 SELECT sysm.measure_id, nvl(COLS.MEASURE_GROUP_ID,-1) measure_group_id, nvl(COLS.PROJECTION_ID, 0) projection_id , NVL(COLS.MEASURE_TYPE, 1) MEASURE_TYPE
   FROM BSC_DB_MEASURE_COLS_VL COLS , BSC_SYS_MEASURES sysm
  WHERE sysm.measure_col = cols.measure_col(+)
    AND sysm.measure_col = p_col;
  l_measure_row cProperties%ROWTYPE;
  ColMeasures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
  l_num_measures NUMBER;
  l_measures_list DBMS_SQL.VARCHAR2_TABLE;
  l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
  l_measure_null BSC_DBGEN_STD_METADATA.clsMeasure;

BEGIN
  IF (p_include_derived_columns) THEN
    return get_all_measures_for_fact(p_fact, p_dim_set);
  END IF;
  --BSC-PMF Integration: Even though a PMF measure cannot be present in a BSC
  --dimension set, I am going to do the validation to filter out PMF measures
  FOR i IN cMeasureList LOOP
    l_measures_list := BSC_DBGEN_UTILS.get_measure_list(i.measure_col);
    l_num_measures := l_measures_list.count;
    IF (l_measures_list.count>0) THEN
      FOR j IN l_measures_list.first..l_measures_list.last LOOP
        If Not measure_exists(colMeasures, l_measures_list(j), i.measure_source) Then
          --Get the aggregation function and Avgl flag of the column (single column)
          OPEN cProperties(l_measures_list(j));
          FETCH cProperties INTO l_measure_row;
          CLOSE cProperties;
          l_measure := l_measure_null;
          l_measure.measure_Name := l_measures_list(j);
          l_measure.aggregation_method := i.oper;
          l_measure.datatype := 'NUMBER';
          l_measure.measure_id := l_measure_row.measure_id;
          l_measure.measure_source := i.measure_source;
          -- Possible measure type values
          --1: Statistic
          --2: Balance
          l_measure.Measure_Type := l_measure_row.measure_type;
          l_measure.measure_group := l_measure_row.measure_group_id;
          bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.PROJECTION_ID, l_measure_row.projection_id);
          colMeasures(colMeasures.count+1) :=  l_measure;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
  return colMeasures;

  EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(FND_FILE.LOG, 'Error in Get_Measures_For_Fact:fact='||p_fact||', error='||sqlerrm);
  raise;
END;

--****************************************************************************
--GetPeriodicities: GetColPeriodicidadesIndic
--  DESCRIPTION:
--   Get the collection of periodicity codes of the indicator
--  PARAMETERS:
--   Indic: indicator code
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

FUNCTION Get_Periodicities_For_Fact(p_fact IN VARCHAR2) RETURN BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity IS
  colPeriodicities BSC_DBGEN_STD_METADATA.tab_ClsPeriodicity;
  CURSOR cPeriodicities IS
    SELECT kpi.PERIODICITY_ID, NVL(TARGET_LEVEL, 1) AS TARGET_LEVEL, s.calendar_id
    FROM BSC_KPI_PERIODICITIES kpi, bsc_sys_periodicities s
    WHERE
    kpi.periodicity_id = s.periodicity_id
    AND kpi.INDICATOR = to_number(p_fact)
	ORDER BY PERIODICITY_ID;
  l_periodicity BSC_DBGEN_STD_METADATA.ClsPeriodicity ;
  cRow cPeriodicities%ROWTYPE;
BEGIN

  OPEN cPeriodicities;
  LOOP
	 FETCH cPeriodicities INTO cRow;
	 EXIT WHEN cPeriodicities%NOTFOUND;
     l_periodicity.periodicity_id := cRow.periodicity_id;
     l_periodicity.calendar_id := cRow.calendar_id;
     bsc_dbgen_utils.add_property(l_periodicity.properties, BSC_DBGEN_STD_METADATA.TARGET_LEVEL, cRow.target_level);
     colPeriodicities(colPeriodicities.count+1) := l_periodicity;
  END LOOP;
  close cPeriodicities;
  colPeriodicities := configure_parent_periods(colPeriodicities);
  return colPeriodicities;
  EXCEPTION WHEN OTHERS THEN

  fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_Periodicities_For_Fact:fact='||p_fact||',error='||sqlerrm);
  raise;
End;


--****************************************************************************
--
--
--  DESCRIPTION:
--   Get the collection of drill families of the indicator
--
--  PARAMETERS:
--   Indic: indicator code
--   p_dim_set: p_dim_set
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function get_dimensions_for_fact(p_fact IN VARCHAR2, p_dim_set IN NUMBER, p_include_missing_levels IN boolean)
RETURN BSC_DBGEN_STD_METADATA.tab_clsDimension IS

  l_dimensions BSC_DBGEN_STD_METADATA.tab_clsDimension;
  DimensionLevels BSC_DBGEN_STD_METADATA.clsDimension;
  l_missing_levels DBMS_SQL.VARCHAR2_TABLE;
  cLevel BSC_DBGEN_STD_METADATA.clsLevel;

  Level_null BSC_DBGEN_STD_METADATA.clsLevel;
  Parents1N varchar2(1000);
  ParentsMN varchar2(1000);
  tParents1N  varchar2(1000);
  tParentsMN varchar2(1000);

  l_level_index NUMBER;
  l_level_table VARCHAR2(1000);
  l_level_pk VARCHAR2(1000);
  l_level_name VARCHAR2(1000);
  l_level_id NUMBER;
  l_level_fk VARCHAR2(100);
  TargetLevel NUMBER;
  l_stmt varchar2(1000);
  l_dimension_index NUMBER;
  msg VARCHAR2(1000);
  l_count number;
  l_ct Number;
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
  l_group_id NUMBER := 0;

  cursor cMissing(p_missing_level VARCHAR2) IS
  SELECT DISTINCT LEVEL_PK_COL, NAME, 1  TAR_LEVEL
  FROM BSC_SYS_DIM_LEVELS_VL WHERE LEVEL_TABLE_NAME = p_missing_level;
  l_missing_level_info cMissing%ROWTYPE;
  l_missing_level  BSC_DBGEN_STD_METADATA.clsLevel;
  l_current_level_index NUMBER := 0;

  l_level_parent BSC_DBGEN_STD_METADATA.clsLevel;
  l_level_null BSC_DBGEN_STD_METADATA.clsLevel;

BEGIN
  l_stmt := 'SELECT DISTINCT kpidim.DIM_LEVEL_INDEX, kpidim.LEVEL_TABLE_NAME, kpidim.LEVEL_PK_COL, kpidim.NAME, NVL(kpidim.TARGET_LEVEL,1) AS TAR_LEVEL' ||
   	' , sysdim.dim_level_id, kpidim.parent_level_rel FROM BSC_KPI_DIM_LEVELS_VL kpidim, BSC_SYS_DIM_LEVELS_B sysdim
	   WHERE
	   kpidim.level_table_name = sysdim.level_table_name
	   AND kpidim.INDICATOR = :1 AND kpidim.DIM_SET_ID = :2  AND kpidim.STATUS = 2';

  IF IsIndicatorBalanceOrPnL(to_number(p_fact)) Then
    --The level 0 which is the Type of Account drill is excluded. This drill is
    --not considered to generate the tables
    l_stmt:= l_stmt||' AND DIM_LEVEL_INDEX <> 0';
  END IF;
  l_stmt := l_stmt||' ORDER BY DIM_LEVEL_INDEX';
  OPEN cv FOR l_stmt using to_number(p_fact), p_dim_set;
  LOOP
    Fetch cv into l_level_index, l_level_table, l_level_pk, l_level_name, TargetLevel, l_level_id, l_level_fk ;
	EXIT WHEN cv%NOTFOUND;
	cLevel := level_null;
	cLevel := get_level_info(l_level_table);
	cLevel.level_id := l_level_id;
	cLevel.level_pk := l_level_pk;
    cLevel.level_table_name := l_level_table;
    cLevel.level_Name := l_level_table;
    cLevel.level_fk := l_level_Fk;
	bsc_dbgen_utils.add_property(cLevel.properties, BSC_DBGEN_STD_METADATA.TARGET_LEVEL, TargetLevel);
    l_dimension_index := get_dimension_index(l_dimensions, l_level_table, p_include_missing_levels, l_missing_levels);
    --Get the index of the drill family which this drill belongs to.
    If l_dimension_index <> -1 Then
      --Level belongs to family l_dimension_index.
      -- If there are missing levels, add it to the list of levels
      IF (l_missing_levels.count<>0) THEN
        FOR i IN l_missing_levels.first..l_missing_levels.last LOOP
          OPEN cMissing(l_missing_levels(i));
          FETCH cMissing INTO l_missing_level_info;
          CLOSE cMissing;
          l_missing_level := level_null;
          l_missing_level.level_pk := l_missing_level_info.level_pk_col;
          l_missing_level.level_table_name := l_missing_levels(i);
          l_missing_level.level_name := l_missing_levels(i);
          bsc_dbgen_utils.add_property(l_missing_level.properties, BSC_DBGEN_STD_METADATA.MISSING_LEVEL, 'Y');
          l_current_level_index := l_current_level_index + 1;
          l_missing_level.level_index := l_current_level_index ;
          l_dimensions(l_dimensions.count).Hierarchies(1).Levels(l_current_level_index) := l_missing_level;
		END LOOP;
	  ELSE
	    l_current_level_index := l_current_level_index+1;
      END IF;
      -- needed to handle missing levels
	  cLevel.level_index    := l_current_level_index;
      --Review target levels
      IF bsc_dbgen_utils.get_property_value(cLevel.properties, BSC_DBGEN_STD_METADATA.TARGET_LEVEL) = '1' Then
        --If target apply to this level, then
        --it must apply for all parents
        IF l_dimensions(l_dimension_index).Hierarchies(1).Levels.count>0 THEN
          FOR j IN l_dimensions(l_dimension_index).Hierarchies(1).Levels.first..l_dimensions(l_dimension_index).Hierarchies(1).Levels.last LOOP
            bsc_dbgen_utils.add_property(l_dimensions(l_dimension_index).Hierarchies(1).Levels(j).properties, BSC_DBGEN_STD_METADATA.TARGET_LEVEL, 1);
          END LOOP;
        END IF;
      END IF;
      -- set parent levels
      l_count := l_dimensions(l_dimension_index).hierarchies(1).levels.first;
      LOOP
        EXIT WHEN l_dimensions(l_dimension_index).hierarchies(1).levels.count= 0;
        l_level_parent := l_level_null;
        l_level_parent := l_dimensions(l_dimension_index).hierarchies(1).levels(l_count);
        If is_parent_1N(l_level_table, l_level_parent.level_name) Then
          --There is 1n relationship with this drill
          cLevel.Parents1N(cLevel.Parents1N.count+1) := l_level_parent.level_name;
          --The 1n relations of the parent drill are also (by transitivity)
          --1n with the current drill
          IF (l_level_parent.parents1N.count>0)THEN
            FOR j IN l_level_parent.parents1N.first..l_level_parent.parents1N.last LOOP
              cLevel.Parents1N(cLevel.Parents1N.count+1) := l_level_parent.parents1N(j);
            END LOOP;
          END IF;
        END IF;
        EXIT WHEN l_count = l_dimensions(l_dimension_index).hierarchies(1).levels.last;
        l_count := l_dimensions(l_dimension_index).hierarchies(1).levels.next(l_count);
      END LOOP;
      l_dimensions(l_dimensions.count).Hierarchies(1).Levels(l_current_level_index) := cLevel;
    ELSE
      --The Level does not belong to any family previously created.
      --So, create a new dimension with this Level
      --Review target level
      --This is the first Level in this family, then target must apply
      l_current_level_index := 1;
      cLevel.level_index    := l_current_level_index;
      bsc_dbgen_utils.add_property(cLevel.properties, BSC_DBGEN_STD_METADATA.TARGET_LEVEL, 1);
      l_dimensions(l_dimensions.count+1).Hierarchies(1).Levels(1) := cLevel;
    END IF;
  END Loop;
  close cv;

  return l_dimensions;
  EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_Dimensions_For_Fact:fact='||p_fact||', dimset='||p_dim_set||', missing levels='||bsc_mo_helper_pkg.boolean_decode(p_include_missing_levels)||', error='||sqlerrm);
    raise;
END;


function get_parents_for_level(
  p_level_name varchar2,
  p_num_levels number default 1000000
) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship IS
  CURSOR cParents IS
  select parent_lvl.level_table_name parent_level, lvl.level_table_name child_level, 'CODE' parent_pk, parent_lvl.level_pk_col child_fk, level
  from
    bsc_sys_dim_level_rels rels,
    bsc_sys_dim_levels_b lvl,
    bsc_sys_dim_levels_b parent_lvl
  where
    lvl.dim_level_id = rels.dim_level_id and
    rels.parent_dim_level_id = parent_lvl.dim_level_id and
    rels.relation_type <> 2 and
    level <= p_num_levels
  connect by rels.dim_level_id= PRIOR rels.parent_dim_level_id
  and rels.relation_type<>2
  and rels.dim_level_id <> rels.parent_dim_level_id
  start with rels.dim_level_id in
   (select dim_level_id from bsc_sys_dim_levels_b where level_table_name = p_level_name)
  order by level;

  l_lvl_rel BSC_DBGEN_STD_METADATA.ClsLevelRelationship;
  l_tab_rels BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
  l_count NUMBER := 1;
BEGIN
  FOR i IN cParents
  LOOP
    l_lvl_rel.Parent_Level         := i.parent_level;
    l_lvl_rel.child_level          := i.child_level;
    l_lvl_rel.child_level_fk       := i.child_fk;
    l_lvl_rel.Parent_Level_pk      := i.parent_pk;
    l_tab_rels(l_count) :=  l_lvl_rel;
    l_count := l_count + 1;
  END LOOP;
  return l_tab_rels;
  EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_Parents_For_Level:p_level='||p_level_name||', p_num_levels='||p_num_levels||', error='||sqlerrm);
    raise;
END;

function get_children_for_level(
  p_level_name varchar2,
  p_num_levels number default 1000000
) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship IS
  CURSOR cChildren IS
  select parent_lvl.level_table_name parent_level, lvl.level_table_name child_level, 'CODE' parent_pk, rels.relation_col child_fk, level
  from
    bsc_sys_dim_level_rels rels,
    bsc_sys_dim_levels_b lvl,
    bsc_sys_dim_levels_b parent_lvl
  where
    lvl.dim_level_id = rels.dim_level_id and
    rels.parent_dim_level_id = parent_lvl.dim_level_id and
    rels.relation_type <> 2 and
    level <= p_num_levels
  connect by PRIOR rels.dim_level_id||rels.relation_type = rels.parent_dim_level_id||1
  and rels.dim_level_id <> rels.parent_dim_level_id
  start with rels.parent_dim_level_id in
    (select dim_level_id from bsc_sys_dim_levels_b where level_table_name = p_level_name)
  order by level;
  l_lvl_rel BSC_DBGEN_STD_METADATA.ClsLevelRelationship;
  l_tab_rels BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
BEGIN
  FOR i IN cChildren
  LOOP
    l_lvl_rel.Parent_Level         := i.parent_level;
	l_lvl_rel.child_level          := i.child_level;
    l_lvl_rel.child_level_fk       := i.child_fk;
	l_lvl_rel.Parent_Level_pk      := i.parent_pk;
    l_tab_rels(l_tab_rels.count + 1) :=  l_lvl_rel;
  END LOOP;
  return l_tab_rels;
    EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.get_children_for_level:p_level='||p_level_name||', p_num_levels='||p_num_levels||', error='||sqlerrm);
    raise;
END;

function get_level_info(
p_level varchar2
) return BSC_DBGEN_STD_METADATA.clsLevel is
l_level BSC_DBGEN_STD_METADATA.clsLevel ;
 CURSOR c_level IS
 SELECT dim_level_id , level_pk_col
 FROM bsc_sys_dim_levels_b
 WHERE level_table_name = p_level;
Begin
  l_level.Level_Name := p_level;
  OPEN c_level;
  FETCH c_level INTO l_level.Level_id, l_level.level_fk;
  CLOSE c_level;
  l_level.Level_PK := 'CODE';
  l_level.Level_PK_Datatype := BSC_DBGEN_UTILS.get_datatype(p_level, l_level.Level_PK);
  l_level.level_type := 0; -- normal
  return l_level;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_Level_Info:level='||p_level||', error='||sqlerrm);
    raise;
End;

function get_facts_for_levels(p_levels dbms_sql.varchar2_table) return BSC_DBGEN_STD_METADATA.tab_clsFact is
  l_facts BSC_DBGEN_STD_METADATA.tab_clsFact ;
  l_fact  BSC_DBGEN_STD_METADATA.clsFact;
  l_stmt VARCHAR2(1000);
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
  l_dim_sets DBMS_SQL.NUMBER_TABLE;
Begin
  IF (p_levels.count=0) THEN
    return l_facts;
  END IF;
  init;
  l_stmt := BSC_DBGEN_UTILS.Get_New_Big_In_Cond_Varchar2(1, 'level_table_name');
  For i IN p_levels.first..p_levels.last LOOP
    BSC_DBGEN_UTILS.Add_Value_Big_In_Cond_Varchar2 (1, p_levels(i));
  END LOOP;
  --insert the children
  l_stmt := 'SELECT distinct dim.INDICATOR, dim.DIM_SET_ID, kpi.name , ''BSC''
             FROM BSC_KPI_DIM_LEVELS_B dim, BSC_KPIS_VL kpi
			 WHERE dim.indicator = kpi.indicator and ('|| l_stmt||') order by indicator, dim_set_id';
  OPEN cv FOR l_stmt;
  LOOP
    FETCH cv INTO l_fact.fact_id, l_fact.dimension_set(1), l_fact.fact_name, l_fact.application_short_name;
    EXIT WHEN cv%NOTFOUND;
    IF (l_facts.count>0) THEN
      -- if its the same fact, but different dim set, then add to dim_set
      IF (l_facts(l_facts.last).fact_id = l_fact.fact_id) THEN
        l_facts(l_facts.last).dimension_set(l_facts(l_facts.last).dimension_set.last+1) := l_fact.dimension_set(1);
      ELSE
	    l_facts(l_facts.last+1) := l_fact;
      END IF;
	ELSE
	  l_facts(l_facts.count+1) := l_fact;
	END IF;
  END LOOP;
  CLOSE cv;
  return l_facts;
Exception when others then
 fnd_file.put_line(FND_FILE.LOG, 'Exception in get_facts_for_levels :'||sqlerrm);
 for i in p_levels.first..p_levels.last loop
   fnd_file.put_line(FND_FILE.LOG, 'Level '||i||':'||p_levels(i));
 end loop;
 raise;
End;


Function get_dim_sets_for_fact(p_fact IN VARCHAR2) return DBMS_SQL.NUMBER_TABLE IS
  l_dim_sets dbms_sql.number_table;
  l_dim_set NUMBER;
  CURSOR cDimSets IS
    SELECT DISTINCT DIM_SET_ID
     FROM BSC_DB_DATASET_DIM_SETS_V
    WHERE INDICATOR = to_number(p_fact)
 ORDER BY DIM_SET_ID;
BEGIN
  OPEN cDimSets;
  LOOP
    FETCH cDimSets INTO l_dim_set;
    EXIT WHEN cDimSets%NOTFOUND;
    --BSC-PMF Integration: Only get BSC dimension sets
    If get_num_measures(p_fact, l_dim_set) > 0 Then
      l_dim_sets(l_dim_sets.count+1) := l_dim_set;
    END IF;
  END LOOP;
  CLOSE cDimSets;
  return l_dim_sets;
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_dim_sets_for_fact:'||p_fact||':'||sqlerrm);
    raise;
End;


function get_s_views(
p_fact IN VARCHAR2,
p_dim_set IN NUMBER)
return dbms_sql.varchar2_table is
cursor cList is
select distinct mv_name from bsc_kpi_data_tables
where indicator = to_number(p_fact)
and dim_set_id = p_dim_set
and mv_name not like 'BSC_S_%ZMV';
l_mv_list dbms_sql.varchar2_table ;
Begin
 FOR i IN cList LOOP
   l_mv_list(l_mv_list.count+1) := i.mv_name;
 END LOOP;
 return l_mv_list;
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_s_views:'||p_fact||','||p_dim_set||':'||sqlerrm);
    raise;
End;


function get_levels_for_table(
p_table_name varchar2,
p_table_type VARCHAR2) return BSC_DBGEN_STD_METADATA.tab_clsLevel is
l_level BSC_DBGEN_STD_METADATA.clsLevel ;
cursor cLevels(p_s_table VARCHAR2) IS
select distinct dim_level_id, level_table_name, level_pk_col from bsc_db_tables_cols cols, bsc_sys_dim_levels_b lvl
    where
    cols.table_name like p_s_table
    and cols.column_type='P'
    and cols.column_name = lvl.level_pk_col;
  l_table_name VARCHAR2(100) ;
  l_level_list BSC_DBGEN_STD_METADATA.tab_clsLevel ;
Begin
  IF (p_table_type='MV' or p_Table_type='VIEW') THEN
    IF (p_table_name like '%ZMV') THEN
      l_table_name :=substr(p_table_name, 1, instr(p_table_name, '_ZMV'))||'%';
    ELSE
	  l_table_name :=substr(p_table_name, 1, instr(p_table_name, '_MV'))||'%';
    END IF;
  ELSE
    l_table_name := p_table_name;
  END IF;
  FOR i IN cLevels(l_table_name) LOOP
    l_level := get_level_info(l_table_name);
    l_level.level_id := i.dim_level_id;
	l_level.level_name := i.level_table_name;
	l_level.level_table_name := i.level_table_name;
	l_level.level_fk := i.level_pk_col;
    l_level.level_pk := 'CODE';
    l_level.level_pk_datatype := BSC_DBGEN_UTILS.get_datatype(l_level.level_table_name, l_level.level_pk);
    l_level_list(l_level_list.count+1) := l_level;
  END LOOP;
  return l_level_list;
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_levels_for_Table:'||p_table_name||','||p_table_type||':'||sqlerrm);
    raise;
End;


--
function column_exists_in_table (p_b_table in varchar2, p_column in varchar2) return boolean is
l_count number;
begin
  select count(1) into l_count from bsc_db_tables_cols where table_name=p_b_table and column_name=p_column;
  if (l_count>0) then
    return true;
  end if;
  return false;
end;

-- used to see if an BSCIC column is from a B table
function is_BSCIC_column_from_b_table(p_s_table in varchar2, p_b_table in varchar2, p_column in varchar2) return boolean is
cursor cFormula is
select source_formula
from bsc_db_tables_cols
where table_name=p_s_table
and column_type='A'
and column_name=p_column;
l_column_name varchar2(400);
begin
  open cFormula;
  fetch cFormula into l_column_name;
  close cFormula;
  l_column_name := replace(l_column_name, 'SUM(', '');
  l_column_name := replace(l_column_name, 'COUNT(', '');
  l_column_name := replace(l_column_name, ')', '');
  return column_exists_in_table(p_b_table, l_column_name);
end;

function is_b_table_a_source(p_s_table in varchar2, p_b_table in varchar2) return boolean is
l_count number;
begin
  select count(1) into l_count from bsc_db_tables_rels
  where table_name = p_s_table and source_table_name=p_b_table;
  if l_count>0 then
    return true;
  end if;
  return false;
end;

function get_b_table_measures_for_fact(
p_fact varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_include_derived_columns boolean)
return BSC_DBGEN_STD_METADATA.tab_clsMeasure IS
  CURSOR cMeasures(p_s_table IN VARCHAR2) is
  select distinct s_table.column_name
       , s_table.source_formula
       , measures.MEASURE_GROUP_ID
	   , measures.PROJECTION_ID
	   , NVL(measures.MEASURE_TYPE, 1) MEASURE_TYPE
	   , sysm.MEASURE_ID
   From  bsc_db_tables_cols s_table,
         bsc_db_tables_cols b_table,
         BSC_DB_MEASURE_COLS_VL measures,
         BSC_SYS_MEASURES sysm
  where  s_table.table_name = p_s_table
    and b_table.table_name = p_base_table
    and s_table.column_name = b_table.column_name
    and s_table.column_type = 'A'
    and measures.measure_col = s_table.column_name
    AND measures.measure_col = sysm.measure_col;

  CURSOR cMeasuresIncludeDerived (p_s_table IN VARCHAR2)is
  select distinct s_table.column_name, s_table.source_formula,
         measures.MEASURE_GROUP_ID, measures.PROJECTION_ID, NVL(measures.MEASURE_TYPE, 1) MEASURE_TYPE,
         sysm.MEASURE_ID
    from
         bsc_db_tables_cols s_table,
         bsc_db_tables_cols b_table,
         BSC_DB_MEASURE_COLS_VL measures,
         BSC_SYS_MEASURES sysm
   where s_table.table_name =p_s_table
    and b_table.table_name = p_base_table
    and s_table.column_name = b_table.column_name
    and s_table.column_type = 'A'
    and measures.measure_col = s_table.column_name
    AND measures.measure_col = sysm.measure_col
  union all
   select distinct s_table.column_name, s_table.source_formula,
         measures.MEASURE_GROUP_ID, measures.PROJECTION_ID, NVL(measures.MEASURE_TYPE, 1) MEASURE_TYPE,
         sysm.MEASURE_ID
    from
         bsc_db_tables_cols s_table,
         bsc_db_tables_cols b_table,
         BSC_DB_MEASURE_COLS_VL measures,
         BSC_SYS_MEASURES sysm
   where s_table.table_name =p_s_table
    and b_table.table_name(+) = p_base_table
    and s_table.column_name = b_table.column_name(+)
    and s_table.column_name like 'BSCIC%'
    and s_table.column_type = 'A'
    and measures.measure_col = s_table.column_name
    AND measures.measure_col = sysm.measure_col(+);
l_measure BSC_DBGEN_STD_METADATA.clsMeasure;
l_measure_list BSC_DBGEN_STD_METADATA.tab_clsMeasure;
 -- there can be multiple Base tables feeding this kpi
 -- this may be because of different lowest level periodicities or different measures from diff. tables
CURSOR cLowestStable IS
  SELECT table_name FROM
  BSC_DB_TABLES_RELS rels
  WHERE table_name like 'BSC_S%'||p_fact||'_'||p_dim_set||'%'
  AND source_table_name not like 'BSC_S%'
  AND p_base_table IN (select table_name from bsc_db_tables_rels rels2 connect by table_name=prior source_table_name start with table_name = rels.table_name);


  l_lowest_s_table VARCHAR2(100);
Begin

  -- Here there may be 2 or more lowest level S tables, for eg monthly and weekly periodicity
  FOR i IN cLowestSTable LOOP
   IF is_b_table_a_source(i.table_name, p_base_table) THEN
     l_lowest_s_table := i.table_name;
     exit;
   END IF;
  END LOOP;

  IF (p_include_derived_columns=false) THEN
    FOR i IN cMeasures(l_lowest_s_table) LOOP
      l_measure.measure_id := i.measure_id;
	  l_measure.measure_Name := i.column_name;
      l_measure.Measure_Type := i.measure_type;
      -- just get the operator
      l_measure.aggregation_method := substr(i.source_formula, 1, instr(i.source_formula, '(')-1);
      l_measure.datatype := 'NUMBER';
      l_measure.measure_group := i.measure_group_id;
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.PROJECTION_ID, i.projection_id);
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.SOURCE_FORMULA, i.source_formula);
      l_measure_list(l_measure_list.count+1) :=  l_measure;
    END LOOP;
  ELSE
    FOR i IN cMeasuresIncludeDerived(l_lowest_s_table) LOOP
      l_measure.measure_id := i.measure_id;
      l_measure.measure_Name := i.column_name;
      l_measure.Measure_Type := i.measure_type;
      -- just get the operator
      l_measure.aggregation_method := substr(i.source_formula, 1, instr(i.source_formula, '(')-1);
      l_measure.datatype := 'NUMBER';
      l_measure.measure_group := i.measure_group_id;
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.PROJECTION_ID, i.projection_id);
      bsc_dbgen_utils.add_property(l_measure.properties, BSC_DBGEN_STD_METADATA.SOURCE_FORMULA, i.source_formula);
      -- Bug 4540103 if its a BSCIC column check which B table its from
      if i.column_name like 'BSCIC%' then
        if is_BSCIC_column_from_b_table(l_lowest_s_table, p_base_table, i.column_name) then
          l_measure_list(l_measure_list.count+1) :=  l_measure;
        end if;
      else
        l_measure_list(l_measure_list.count+1) :=  l_measure;
      end if;
    END LOOP;
  END IF;
  return l_measure_list;

 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_b_table_measures_for_fact:'||p_fact||','||p_dim_set||','||p_base_table||','||bsc_mo_helper_pkg.boolean_decode(p_include_derived_columns)||':'||sqlerrm);
    raise;
End;

function get_periodicity_for_table(
p_table varchar2) return NUMBER is
CURSOR cTablePer IS
SELECT periodicity_id from bsc_db_tables where table_name=p_table;
l_per NUMBER;
Begin
  OPEN cTablePer;
  FETCH cTablePer into l_per;
  CLOSE cTablePer;
  return l_per;

 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_periodicity_for_table:'||p_table||':'||sqlerrm);
    raise;
End;

function get_db_calendar_column(
p_calendar_id number,
p_periodicity_id number) return varchar2 is
CURSOR cDBColumn IS
SELECT db_column_name FROM bsc_sys_periodicities
WHERE periodicity_id = p_periodicity_id AND calendar_id = p_calendar_id;
l_db_column VARCHAR2(100);
Begin
  OPEN cDBColumn;
  FETCH cDBColumn INTO l_db_column;
  CLOSE cDBColumn;
  return l_db_column;
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_db_calendar_column: calendar='||p_calendar_id||',per id='||p_periodicity_id||':'||sqlerrm);
    raise;
End;


function get_zero_code_levels(
p_fact varchar2,
p_dim_set varchar2) return BSC_DBGEN_STD_METADATA.tab_clsLevel is
CURSOR cSTable(p_num_zero_code in number) IS
select table_name, count(1) ct from bsc_db_calculations
where table_name like 'BSC_S_%'||p_fact||'_'||p_dim_set||'%'
and calculation_type=4
group by table_name
having count(1)= p_num_zero_code;

l_s_table_name VARCHAR2(300);
l_num_zero_code number;
/*5014050 */
cursor c1(p_kpi number) is
select
a.DIM_LEVEL_ID,a.LEVEL_TABLE_NAME,a.level_pk_col
from
bsc_sys_dim_levels_b a,
(select a.LEVEL_TABLE_NAME,0 RELATION_TYPE
from
bsc_kpi_dim_levels_b a
where
a.indicator=p_kpi
and a.PARENT_LEVEL_INDEX is null
union all
select a.LEVEL_TABLE_NAME,e.RELATION_TYPE
from
bsc_kpi_dim_levels_b a,
bsc_kpi_dim_levels_b b,
bsc_sys_dim_levels_b c,
bsc_sys_dim_levels_b d,
bsc_sys_dim_level_rels e
where
a.indicator=p_kpi
and b.indicator=p_kpi
and a.PARENT_LEVEL_INDEX=b.DIM_LEVEL_INDEX
and a.LEVEL_TABLE_NAME=c.LEVEL_TABLE_NAME
and b.LEVEL_TABLE_NAME=d.LEVEL_TABLE_NAME
and e.DIM_LEVEL_ID=c.DIM_LEVEL_ID
and e.PARENT_DIM_LEVEL_ID=d.DIM_LEVEL_ID) b
where b.LEVEL_TABLE_NAME=a.LEVEL_TABLE_NAME
and b.relation_type<>1;
l_level BSC_DBGEN_STD_METADATA.clsLevel ;
l_level_list BSC_DBGEN_STD_METADATA.tab_clsLevel ;
Begin
  --l_s_table_name := get_highest_s_table(p_fact, p_dim_set);
  --return get_levels_for_table(l_s_table_name, 'TABLE');
  /*5014050
  this issue came from m:n relations. now, we look for all levels of the kpi and minus those that are child levels*/
  FOR i IN c1(to_number(p_fact)) LOOP
    l_level.level_id := i.dim_level_id;
	l_level.level_name := i.level_table_name;
	l_level.level_table_name := i.level_table_name;
	l_level.level_fk := i.level_pk_col;
    l_level.level_pk := 'CODE';
    l_level.level_pk_datatype := BSC_DBGEN_UTILS.get_datatype(l_level.level_table_name, l_level.level_pk);
    l_level_list(l_level_list.count+1) := l_level;
  END LOOP;
  return l_level_list;
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_zero_code_levels:'||p_fact||','||p_dim_set||':'||sqlerrm);
    raise;
End;

function get_base_tables_for_dim_set(
p_fact in varchar2,
p_dim_set in number,
p_targets in boolean) return dbms_sql.varchar2_table is
CURSOR cBTables(p_prefix VARCHAR2)  IS
select distinct rels.table_name
from bsc_db_Tables_rels rels,
bsc_db_tables src
where
rels.source_table_name = src.table_name
and src.table_type=0
and rels.table_name like 'BSC_B%'
connect by rels.table_name=prior rels.source_table_name
start with rels.table_name in -- lowest level S tables
( SELECT table_name FROM
  BSC_DB_TABLES_RELS rels
  WHERE table_name like p_prefix||p_fact||'_'||p_dim_set||'%'
  AND source_table_name not like 'BSC_S%'
) ;

l_table_list dbms_sql.varchar2_table ;
l_prefix varchar2(10) := 'BSC_S_';
 -- this may be because of different lowest level periodicities or different measures from diff. tables

Begin
  IF (p_targets) THEN
    l_prefix := 'BSC_SB_';
  END IF;
  FOR i IN cBTables(l_prefix) LOOP
    l_table_list(l_table_list.count+1) := i.table_name;
  END LOOP;
  return l_table_list;
   Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_base_tables_for_dim_set:'||p_fact||','||p_dim_set||','||bsc_mo_helper_pkg.boolean_decode(p_targets)||':'||sqlerrm);
    raise;
END;


/*function get_filter_for_dim_level(
p_fact varchar2,
p_level varchar2) return varchar2 is
l_stmt VARCHAR2(1000);
CURSOR cFilter IS
select sysdim.dim_level_id, source_type, source_code
   from bsc_kpi_dim_levels_b kpidim,
   bsc_sys_dim_levels_b sysdim,
   bsc_sys_filters_views filters
   where
   kpidim.level_table_name = sysdim.level_table_name
   and kpidim.level_view_name <> sysdim.level_view_name
   and sysdim.dim_level_id = filters.dim_level_id
   and filters.level_view_name = kpidim.level_view_name
   and kpidim.indicator = to_number(p_fact)
   and kpidim.level_table_name = p_level;
  l_row cFilter%ROWTYPE;
Begin
  l_stmt := '(select dim_level_value from bsc_sys_filters where ';
  OPEN cFilter;
  FETCH cFilter INTO l_row;
  IF (cFilter%FOUND) THEN
    l_stmt := l_stmt||' source_type='||l_row.source_type||' and source_code='||l_row.source_code||' and dim_level_id='||l_row.dim_level_id||')';
    return l_stmt;
  ELSE
    return null;
  END IF;
  CLOSE cFilter;

Exception when others then
 raise;
End;*/

function get_filter_for_dim_level(
p_fact varchar2,
p_level varchar2) return varchar2 is
l_stmt VARCHAR2(1000);
CURSOR cFilter IS
 SELECT level_view_name
   FROM bsc_kpi_dim_levels_b
  WHERE indicator=to_number(p_fact)
    AND level_table_name = p_level;
  l_level_view varchar2(100);
Begin
  OPEN cFilter;
  FETCH cFilter INTO l_level_view ;
  IF (cFilter%FOUND) THEN
    l_level_view  := '(select code from '||l_level_view ||')';
    CLOSE cFilter;
	return l_level_view;
  ELSE
    CLOSE cFilter;
    return null;
  END IF;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_Filter_for_dim_level:'||p_fact||','||p_level||':'||sqlerrm);
    raise;
End;

function get_year_periodicity_for_fact(p_fact varchar2) return number is
cursor cYearPeriodicity IS
select p.periodicity_id from
bsc_sys_periodicities p, bsc_kpis_vl k
where
p.yearly_flag =1
and p.calendar_id=k.calendar_id
and k.indicator = to_number(p_fact);

l_year_periodicity NUMBER;
Begin
  OPEN cYearPeriodicity;
  FETCH cYearPeriodicity INTO l_year_periodicity;
  CLOSE cYearPeriodicity;
  return l_year_periodicity;

end;

/* Changed Aug 11, 2005 by Arun
   Bug 4549520
   Discussed this with Venu, he asked me to change the code to first check bsc_db_tables.
   If its null, then we goto bsc_sys_calendars
*/

function get_current_year_for_fact(
p_fact varchar2) return number is

-- changed for bug 4549520
cursor cCurrentYearFromCal IS
select c.fiscal_year
from bsc_sys_calendars_b c, bsc_kpis_vl k
where c.calendar_id = k.calendar_id
and k.indicator = to_number(p_fact);

l_current_year NUMBER;
l_year_periodicity NUMBER;
Begin
  l_year_periodicity := get_year_periodicity_for_fact(p_fact);
  OPEN cCurrentYearFromCal;
  FETCH cCurrentYearFromCal INTO l_current_year;
  CLOSE cCurrentYearFromCal;
  return l_current_year;

   Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.get_current_year_for_fact:'||p_fact||':'||sqlerrm);
    raise;
End;

--added Jan 12, 2006
function get_current_period_for_table(
  p_table_name varchar2) return number is
cursor cPeriod is
select current_period
  from bsc_db_tables
 where table_name=p_table_name;
l_period number;
begin
  open cPeriod;
  fetch cPeriod into l_period;
  close cPeriod;
  return l_period;
end;

function get_current_year_for_table(
  p_table_name varchar2) return number is
cursor cPeriod is
select current_year
  from bsc_sys_calendars_b cal
     , bsc_sys_periodicities per
     , bsc_db_tables dbtbl
 where dbtbl.table_name = p_table_name
   and dbtbl.periodicity_id = per.periodicity_id
   and per.calendar_id = cal.calendar_id;
l_year number;
begin
  open cPeriod;
  fetch cPeriod into l_year;
  close cPeriod;
  return l_year;
end;

function get_current_period_for_fact(
  p_fact varchar2,
  p_periodicity number) return number is
   ------------------------------
  cursor cCurrentPeriod IS
  select current_period from bsc_kpi_periodicities
  where indicator=to_number(p_fact)
    and periodicity_id=p_periodicity;
  l_current_period NUMBER;
  ------------------------------
  cursor cSourcePeriodicities(pp_periodicity number) is
  select source, db_column_name, calendar_id from bsc_sys_periodicities
  where periodicity_id=pp_periodicity;
  ------------------------------
  cursor cKPIPeriodicity is
  select periodicity_id from bsc_kpi_periodicities
  where indicator = to_number(p_fact);
  ------------------------------
  l_kpi_periodicity number;
  l_stmt VARCHAR2(1000);
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
  l_current_year NUMBER;
  l_source_periodicities VARCHAR2(1000);
  l_db_col VARCHAR2(100);
  l_cal_id NUMBER;
  l_number_table DBMS_SQL.NUMBER_TABLE;


Begin
  OPEN cCurrentPeriod;
  FETCH cCurrentPeriod INTO l_current_period;
  CLOSE cCurrentPeriod;
  IF (l_current_period is not null) THEN
    return l_current_period;
  END IF;

  -- IF it is null, then find the source periodicity for this periodicity
  -- This is reqd as AW will may call this API for semester periodicity
  -- and semester periodicity may not exist for most objectives
  -- In this case, we find the sources of semester, see if any of them
  -- is attached to the objective.
  -- Lets say month is a valid periodicty for the objective and a source
  -- for semester. Now, we get the current_period for month, say 7.
  -- Then we get the current_year for month using the get_current_year API
  -- Once we have the year and the month, we can query bsc_db_calendar
  -- to get the value for Semester... whew... :D

  -- Get the source_periodicity, db_column_name for p_periodicity

  OPEN cSourcePeriodicities(p_periodicity);
  FETCH cSourcePeriodicities into l_source_periodicities, l_db_col, l_cal_id;
  CLOSE cSourcePeriodicities;
  l_source_periodicities:= ','||l_source_periodicities ||',';


  OPEN cKPIPeriodicity;
  LOOP
    FETCH cKPIPeriodicity INTO l_kpi_periodicity ;
    EXIT WHEN cKPIPeriodicity%NOTFOUND;
    IF (instr(l_source_periodicities, ','||l_kpi_periodicity||',')>0) THEN -- this is a source periodicity
      EXIT;
    ELSE
      l_kpi_periodicity := null;
    END IF;
  END LOOP;

  -- Assuming month is a periodicity in the objective
  -- we now get the current_period for month, say 7
  l_current_period := get_current_period_for_fact (p_fact, l_kpi_periodicity);

  -- Get the current year also, now that we have the current_period for month, say 2003
  l_current_year:= get_current_year_for_fact(p_fact);

  -- Select semester (eg.) from bsc_db_calendar where calendar_id=2 and month=7 and year = 2003
  l_stmt := 'select '||l_db_col  ||' from bsc_db_calendar where calendar_id=:1 and '||
  			get_db_calendar_column(l_cal_id, l_kpi_periodicity) ||' = :2 and year = :3';
  OPEN cv FOR l_stmt using l_cal_id, l_current_period, l_current_year;
  FETCH cv INTO l_current_period;
  CLOSE cv;
  return l_current_period;

 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_current_period_for_fact:'||p_fact||','||p_periodicity||':'||sqlerrm);
    raise;

End;


-- this API is only called from the BSC Metadata Optimizer UI for AW support
function is_projection_enabled_for_kpi(
  p_kpi in varchar2
) return varchar2 is
  l_dim_sets dbms_sql.number_table;
  l_measures BSC_DBGEN_STD_METADATA.tab_clsMeasure;
  l_properties BSC_DBGEN_STD_METADATA.tab_ClsProperties;
Begin
  l_dim_sets := bsc_dbgen_metadata_reader.get_dim_sets_for_fact(p_kpi);
  --DBMS_OUTPUT.PUT_LINE('L_DIM_SETS.COUNT = '||TO_CHAR(l_dim_sets.count));
  IF (l_dim_sets.count > 0) THEN
    FOR i IN l_dim_sets.first..l_dim_sets.last LOOP
      l_measures := bsc_dbgen_metadata_reader.get_measures_for_fact(p_kpi, l_dim_sets(i));
      IF (l_measures.count > 0) THEN
        FOR j IN l_measures.first..l_measures.last LOOP
          l_properties := l_measures(j).Properties;
          IF (bsc_dbgen_utils.get_property_value(l_properties, BSC_DBGEN_STD_METADATA.PROJECTION_ID) <> '0') THEN
            RETURN 'Y';
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;
  RETURN 'N';
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.is_projection_enabled_for_kpi:'||p_kpi||':'||sqlerrm);
    raise;

End;

function get_all_facts_in_aw return  dbms_sql.varchar2_table is
CURSOR cAWFacts IS
SELECT kpi.indicator
  FROM BSC_KPIS_VL KPI,
       BSC_KPI_PROPERTIES PROP
 WHERE KPI.INDICATOR = PROP.INDICATOR
   AND PROP.PROPERTY_CODE = BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE
   AND PROP.PROPERTY_VALUE = '2';
 l_facts DBMS_SQL.VARCHAR2_TABLE;
Begin
 FOR i IN cAWFacts
 LOOP
   l_facts(l_facts.count+1) := i.indicator;
 END LOOP;
 return l_facts;
 Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_all_facts_in_aw:'||sqlerrm);
    raise;

End;

--get the ZMV for a kpi and dimset
function get_z_s_views(
p_fact IN VARCHAR2,
p_dim_set IN NUMBER)
return dbms_sql.varchar2_table is
cursor cList is
SELECT DISTINCT mv_name
  FROM bsc_kpi_data_tables
 WHERE indicator = to_number(p_fact)
   AND dim_set_id = p_dim_set
   AND mv_name like 'BSC%ZMV';
l_mv_list dbms_sql.varchar2_table ;
Begin
 FOR i IN cList LOOP
   l_mv_list(l_mv_list.count+1) := i.mv_name;
 END LOOP;
 return l_mv_list;
Exception when others then
  fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.get_z_s_views:'||p_fact||','||p_dim_set||':'||sqlerrm);
  raise;

End;

Function get_all_levels_for_fact(p_fact IN VARCHAR2)
RETURN DBMS_SQL.VARCHAR2_TABLE IS
  l_stmt VARCHAR2(1000);
  l_level VARCHAR2(1000);
  l_level_index number;
  l_return DBMS_SQL.VARCHAR2_TABLE;
  TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
BEGIN
  l_stmt := 'SELECT DISTINCT LEVEL_TABLE_NAME, DIM_LEVEL_INDEX ' ||
   	' FROM BSC_KPI_DIM_LEVELS_VL WHERE INDICATOR = :1 AND STATUS = 2';
  IF IsIndicatorBalanceOrPnL(to_number(p_fact)) Then
    --The level 0 which is the Type of Account drill is excluded. This level is not considered to generate the tables
    l_stmt:= l_stmt||' AND DIM_LEVEL_INDEX <> 0';
  END IF;
  l_stmt := l_stmt||' ORDER BY DIM_LEVEL_INDEX';
  OPEN cv FOR l_stmt using to_number(p_fact);
  LOOP
    FETCH cv INTO l_level, l_level_index;
    EXIT WHEN cv%NOTFOUND;
    l_return(l_return.count+1) := l_level;
  END LOOP;
  CLOSE cv;
  return l_return;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_all_levels_for_fact:'||p_fact||':'||sqlerrm);
    raise;
END;

function get_dimension_level_short_name(p_dim_level_table_name IN VARCHAR2) return VARCHAR2
IS
CURSOR cShortName IS
SELECT short_name
  FROM bsc_sys_dim_levels_b
 WHERE level_table_name = p_dim_level_table_name;
 l_short_name VARCHAR2(100);
BEGIN
  OPEN cShortName;
  FETCH cShortName INTO l_short_name;
  CLOSE cShortName;
  return l_short_name;
END;


function get_measures_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table is
l_measure_cols dbms_sql.varchar2_table;
l_session_id number := userenv('SESSIONID');
--l_counter number := 0;
l_index number;
l_variable_id number := 1;
CURSOR c1(p_session_id NUMBER, p_variable_id NUMBER) IS
SELECT nvl(sysm.measure_col, tmp.value_v) measure_col
FROM bsc_sys_measures sysm, bsc_tmp_big_in_cond tmp
where tmp.session_id = p_session_id
and tmp.variable_id = p_variable_id
and tmp.value_v = sysm.short_name(+)
order by tmp.value_n;
begin
  DELETE bsc_tmp_big_in_cond WHERE session_id=l_session_id and variable_id=l_variable_id;
  l_index := p_short_names.first;
  LOOP
    EXIT WHEN p_short_names.count=0;
    --l_counter := l_counter+1;
    INSERT INTO BSC_TMP_BIG_IN_COND (session_id, variable_id, value_n, value_v)
    VALUES (l_session_id, l_variable_id, l_index/*l_counter*/, p_short_names(l_index));
    EXIT WHEN l_index = p_short_names.last;
    l_index := p_short_names.next(l_index);
  END LOOP;
  l_index := p_short_names.first;
  FOR i IN c1(l_session_id, l_variable_id) LOOP
    l_measure_cols(l_index) := i.measure_col;
    IF (l_index<> p_short_names.last) THEN
      l_index:= p_short_names.next(l_index);
    END IF;
  END LOOP;
  return l_measure_cols;
   Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_measures_for_short_names:'||sqlerrm);
    raise;
end;



function get_dim_levels_for_short_names(p_short_names in dbms_sql.varchar2_table) return dbms_sql.varchar2_table is
l_dim_levels  dbms_sql.varchar2_table;
l_session_id number := userenv('SESSIONID');
--l_counter number := 0;
l_index number;
l_variable_id number := 1;
CURSOR c1(p_session_id NUMBER, p_variable_id NUMBER) IS
SELECT nvl(sysd.level_table_name, tmp.value_v) level_table_name
FROM bsc_sys_dim_levels_b sysd, bsc_tmp_big_in_cond tmp
where tmp.session_id = p_session_id
and tmp.variable_id = p_variable_id
and tmp.value_v = sysd.short_name(+)
order by tmp.value_n;
l_counter number;
begin
  DELETE bsc_tmp_big_in_cond WHERE session_id=l_session_id and variable_id=l_variable_id;
  l_index := p_short_names.first;
  LOOP
    EXIT WHEN p_short_names.count=0;
    INSERT INTO BSC_TMP_BIG_IN_COND (session_id, variable_id, value_n, value_v)
    VALUES (l_session_id, l_variable_id, l_index/*l_counter*/, p_short_names(l_index));
    EXIT WHEN l_index = p_short_names.last;
    l_index := p_short_names.next(l_index);
  END LOOP;
  l_index := p_short_names.first;
  FOR i IN c1(l_session_id, l_variable_id) LOOP
    l_dim_levels(l_index) := i.level_table_name;
    IF (l_index<> p_short_names.last) THEN
      l_index:= p_short_names.next(l_index);
    END IF;
  END LOOP;
  return l_dim_levels;
   Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_dim_levels_for_short_names:'||':'||sqlerrm);
    raise;
end;

function get_fact_implementation_type(p_fact in varchar2) return varchar2 is
cursor cImplType is
SELECT property_value
  FROM
       BSC_KPI_PROPERTIES
 WHERE INDICATOR = p_fact
   AND PROPERTY_CODE = BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE;
 l_impl_type varchar2(30);

l_mv_level number;
begin
  open cImplType;
  fetch cImplType into l_impl_type;
  close cimplType;
  if (l_impl_type = 2) then
    l_impl_type := 'AW';--Analytical Workspaces
  else
    SELECT fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL') into l_mv_level from dual;
    if (l_mv_level) is null then
      l_impl_type:='ST'; -- summary tables
    else
      l_impl_type := 'MV';-- Materialized view
    end if;
  end if;
  return l_impl_type;
   Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_fact_implementation_type:'||p_fact||':'||sqlerrm);
    raise;
end;

function is_level_used_by_prod_aw_fact(p_level_name in varchar2) return boolean is
l_count number;
begin
 select count(1) into l_count
 from bsc_kpi_dim_levels_b lvl,
 bsc_kpi_properties prop,
 bsc_kpis_vl kpis
 where kpis.indicator= lvl.indicator
 and kpis.indicator=prop.indicator
 and lvl.level_table_name=p_level_name
 and prop.property_code='IMPLEMENTATION_TYPE'
 and prop.property_value=2
 and kpis.prototype_flag not in (2,3,4);
 --dbms_output.put_line('is_level-used_by_prod_aw_fact='||l_count);
 if (l_count>0) then
   return true;
 end if;
 return false;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.is_level_used_by_prod_aw_fact:'||p_level_name||':'||sqlerrm);
    raise;
end;

function is_level_used_by_aw_fact(p_level_name in varchar2) return boolean is
l_count number;
l_session_id number;
begin
  if is_level_used_by_prod_aw_fact(p_level_name) then
    return true;
  end if;
  --dbms_output.put_line('assume count='||BSC_DBGEN_METADATA_READER.g_assume_production_facts.count);

  -- Not used by any production facts, now check if any processing facts have it
  -- This memory variable is populated by GDB during process time
  IF (BSC_DBGEN_METADATA_READER.g_assume_production_facts.count=0) THEN
     return false;
  END IF;
  -- now see if objectives being processed have these levels
  l_session_id := userenv('SESSIONID');
  delete bsc_tmp_big_in_cond where session_id=l_session_id and variable_id=1;
  FORALL i in 1..BSC_DBGEN_METADATA_READER.g_assume_production_facts.count
    insert into bsc_tmp_big_in_cond (session_id, variable_id, value_n) values (l_session_id, 1,
        to_number(BSC_DBGEN_METADATA_READER.g_assume_production_facts(i)));

  select count(1) into l_count
  from bsc_kpi_dim_levels_b lvl,
  bsc_kpi_properties prop,
  bsc_kpis_vl kpis
  where kpis.indicator= lvl.indicator
  and kpis.indicator=prop.indicator
  and lvl.level_table_name=p_level_name
  and prop.property_code='IMPLEMENTATION_TYPE'
  and prop.property_value=2
  and kpis.prototype_flag<>2
  and kpis.indicator in
  (select value_n from bsc_tmp_big_in_cond where session_id=l_session_id
   and variable_id=1);
  if l_count > 0 then
    return true;
  end if;
  --dbms_output.put_line('returning false in is_level_used_by_aw_fact');
  return false;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.is_level_used_by_aw_fact:'||p_level_name||':'||sqlerrm);
    raise;
end;

function get_parents_for_level_aw(
  p_level_name varchar2,
  p_num_levels number default 1000000
) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship IS
  CURSOR cParents IS
  select parent_lvl.level_table_name parent_level, lvl.level_table_name child_level, 'CODE' parent_pk,
  -- bug 5168537
  --rels.relation_col child_fk,
  parent_lvl.level_pk_col child_fk,
  level
  from
    bsc_sys_dim_level_rels rels,
    bsc_sys_dim_levels_b lvl,
    bsc_sys_dim_levels_b parent_lvl
  where
    lvl.dim_level_id = rels.dim_level_id and
    rels.parent_dim_level_id = parent_lvl.dim_level_id and
    rels.relation_type <> 2 and
    level <= p_num_levels
  connect by rels.dim_level_id= PRIOR rels.parent_dim_level_id
  and rels.relation_type<>2
  and rels.dim_level_id <> rels.parent_dim_level_id
  start with rels.dim_level_id in
   (select dim_level_id from bsc_sys_dim_levels_b where level_table_name = p_level_name)
  order by level;

  l_lvl_rel BSC_DBGEN_STD_METADATA.ClsLevelRelationship;
  l_tab_rels BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
  l_count NUMBER := 1;


BEGIN
  FOR i IN cParents
  LOOP
    l_lvl_rel.Parent_Level         := i.parent_level;
    l_lvl_rel.child_level          := i.child_level;
    l_lvl_rel.child_level_fk       := i.child_fk;
    l_lvl_rel.Parent_Level_pk      := i.parent_pk;
    -- Add it only if BOTH parent and child are used by an AW objective
    if is_level_used_by_aw_fact(i.parent_level) and is_level_used_by_aw_fact(i.child_level) then
      l_tab_rels(l_count) :=  l_lvl_rel;
      l_count := l_count + 1;
    end if;
  END LOOP;
  return l_tab_rels;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_parent_levels_for_aw:'||p_level_name||',levels='||p_num_levels||', error:'||sqlerrm);
    raise;
END;

function get_children_for_level_aw(
  p_level_name varchar2,
  p_num_levels number default 1000000
) RETURN BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship IS
  CURSOR cChildren IS
  select parent_lvl.level_table_name parent_level, lvl.level_table_name child_level, 'CODE' parent_pk, rels.relation_col child_fk, level
  from
    bsc_sys_dim_level_rels rels,
    bsc_sys_dim_levels_b lvl,
    bsc_sys_dim_levels_b parent_lvl
  where
    lvl.dim_level_id = rels.dim_level_id and
    rels.parent_dim_level_id = parent_lvl.dim_level_id and
    rels.relation_type <> 2 and
    level <= p_num_levels
  connect by PRIOR rels.dim_level_id||rels.relation_type = rels.parent_dim_level_id||1
  and rels.dim_level_id <> rels.parent_dim_level_id
  start with rels.parent_dim_level_id in
    (select dim_level_id from bsc_sys_dim_levels_b where level_table_name = p_level_name)
  order by level;
  l_lvl_rel BSC_DBGEN_STD_METADATA.ClsLevelRelationship;
  l_tab_rels BSC_DBGEN_STD_METADATA.tab_ClsLevelRelationship;
BEGIN
  FOR i IN cChildren
  LOOP
    l_lvl_rel.Parent_Level         := i.parent_level;
    l_lvl_rel.child_level          := i.child_level;
    l_lvl_rel.child_level_fk       := i.child_fk;
    l_lvl_rel.Parent_Level_pk      := i.parent_pk;
    -- Aug 8, 2005, added to handle dim. level changes within aw
    -- Add it only if BOTH parent and child are used by an AW objective
    if is_level_used_by_aw_fact(i.parent_level) and is_level_used_by_aw_fact(i.child_level) then
      l_tab_rels(l_tab_rels.count + 1) :=  l_lvl_rel;
    end if;
  END LOOP;
  return l_tab_rels;
    Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_children_for_level_aw:'||p_level_name||':'||sqlerrm);
    raise;
END;


function get_target_per_for_b_table(p_fact in varchar2, p_dim_set in number, p_b_table in varchar2) return dbms_sql.varchar2_table is
cursor cTgtPeriodicities is
select periodicity_id from bsc_db_tables where table_name in
(
select distinct table_name from bsc_db_tables_rels rels
where
rels.table_name like 'BSC_S%'||p_fact||'_'||p_dim_set||'%'
and rels.source_table_name not like 'BSC_S%'||p_fact||'_'||p_dim_set||'%'
connect by prior rels.table_name=rels.source_table_name
and rels.relation_type<>2
start with rels.source_table_name = p_b_table
);
l_periodicities dbms_sql.varchar2_table;
l_stmt varchar2(1000);
 TYPE CurTyp IS REF CURSOR;
  cv CurTyp;
l_pattern varchar2(30);
l_per number;
BEGIN

  l_pattern := 'BSC_S%'||p_fact||'_'||p_dim_set||'%';
  FOR i IN cTgtPeriodicities LOOP
    l_periodicities(l_periodicities.count+1):=i.periodicity_id;
  END LOOP;
  return l_periodicities;
  Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.get_target_per_for_b_table:'||p_fact||','||p_dim_set||','||p_b_table||':'||sqlerrm);
    raise;
END;


function get_last_update_date_for_fact(p_fact in varchar2) return date is
cursor cdate is
select last_update_date from bsc_kpis_vl
where indicator=p_fact;
l_date date;
begin
  open cdate;
  fetch cdate into l_date;
  close cdate;
  return l_date;
end;

function get_fact_cols_from_b_table(
p_fact in varchar2,
p_dim_set in number,
p_b_table_name in varchar2,
p_col_type in varchar2
) return BSC_DBGEN_STD_METADATA.tab_clsColumnMaps
--BSC_DBGEN_STD_METADATA.tab_clsLevel
 is
--Find Summary Table fed by this B table
cursor cSummary(p_pattern in varchar2) is
select distinct table_name from bsc_db_tables_rels
where instr(table_name, p_pattern)=1
and source_table_name not like p_pattern||'%'
connect by  source_table_name = prior table_name
start with source_table_name = p_b_table_name;

l_s_table varchar2(100);

cursor cPath(p_parent_level varchar2, p_child_level varchar2) is
WITH tree AS
(
   SELECT table_name child_lvl
        , source_Table_name parent_lvl
        , LEVEL lvl
     FROM bsc_db_tables_rels rels
    START WITH source_table_name = p_parent_level
  CONNECT BY source_table_name  = PRIOR table_name
)
  SELECT parent_lvl, child_lvl, lvl
    FROM tree
 CONNECT BY PRIOR parent_lvl = child_lvl
     AND PRIOR lvl = lvl + 1
   START WITH child_lvl = p_child_level
     AND lvl =
        (
          SELECT MIN(lvl)
            FROM tree
           WHERE child_lvl = p_child_level
        )
   union
   select source_table_name,table_name , -1 from bsc_db_Tables_rels
    where table_name=p_parent_level
    order by lvl ;

cursor cCols (p_table_name in varchar2, p_col_type1 in varchar2, p_col_type2 in varchar2) is
select column_name, source_column source_column_name from bsc_db_Tables_cols
where table_name = p_table_name
and column_type in(p_col_type1, p_col_type2);


l_var1 dbms_sql.varchar2_table;
l_var2 dbms_sql.varchar2_table;
l_var3 dbms_sql.varchar2_table;
l_var4 dbms_sql.varchar2_table;

l_col_maps_table varchar2(100) := 'BSC_TMP_OPT_COL_MAPS';
l_stmt varchar2(1000) :='create global temporary table '||l_col_maps_table||' (column_name varchar2(100), source_column_name varchar2(100), table_name varchar2(100), source_table_name varchar2(100))';
PRAGMA AUTONOMOUS_TRANSACTION;
l_col_type1 VARCHAR2(10);
l_col_type2 VARCHAR2(10);
TYPE CurTyp IS REF CURSOR;
  cv CurTyp;

l_col_map  BSC_DBGEN_STD_METADATA.clsColumnMaps;
l_col_maps BSC_DBGEN_STD_METADATA.tab_clsColumnMaps;

Begin
  init;
  if (bsc_apps.table_exists(l_col_maps_table)=false) then
     bsc_apps.Do_DDL(l_stmt, ad_ddl.create_table, l_col_maps_table);
  end if;

  if (p_col_type='ALL') then
    l_col_type1 := 'A';
    l_col_type2 := 'P';
  elsif (p_col_type='KEYS') then
    l_col_type1 := 'P';
    l_col_type2 := 'P';
  elsif (p_col_type='MEASURES') then
    l_col_type1 := 'A';
    l_col_type2 := 'A';
  end if;

--rkumar: modified for bug#5506476
  IF BSC_MO_HELPER_PKG.FindIndex(BSC_METADATA_OPTIMIZER_PKG.g_bt_tables_tgt,p_b_table_name) = -1 THEN
    open  cSummary('BSC_S_'||p_fact);
    fetch cSummary into l_s_table;
    close cSummary;
  ELSE
    open  cSummary('BSC_SB_'||p_fact);
    fetch cSummary into l_s_table;
    close cSummary;
  END IF;

  -- get shortest path and their correpsonding tables/source_tables/cols/source_cols
  for i in cPath(p_b_table_name, l_s_table) loop
    --match_columns
     for j in cCols(i.child_lvl, l_col_type1, l_col_type2) loop
       l_var1(l_var1.count+1) := i.child_lvl;
       l_var2(l_var2.count+1) := i.parent_lvl;
       l_var3(l_var3.count+1) := j.column_name;
       l_var4(l_var4.count+1) := j.source_column_name;
     end loop;
  end loop;

  forall i in 1..l_var1.count
    execute immediate 'insert into '||l_col_maps_table||'(table_name, source_table_name, column_name, source_column_name) '
      ||' values (:1, :2, :3, :4)' using l_var1(i), l_var2(i), l_var3(i), l_var4(i);

  l_stmt := 'SELECT column_name FROM '||l_col_maps_table||' WHERE TABLE_NAME LIKE :1
             CONNECT BY  TABLE_NAME = PRIOR SOURCE_TABLE_NAME
             AND  COLUMN_NAME = PRIOR SOURCE_COLUMN_NAME
             START WITH TABLE_NAME = :2';
  OPEN cv FOR l_stmt USING 'BSC_B%', l_s_table;
  LOOP
    FETCH cv INTO l_col_map.source_column_name;
    EXIT WHEN cv%NOTFOUND;
    l_col_maps(l_col_maps.count+1) := l_col_map;
  end loop;
  CLOSE cv;

  l_stmt :=  'SELECT  column_name FROM '||l_col_maps_table||
             ' WHERE TABLE_NAME= :1
               CONNECT BY  PRIOR TABLE_NAME =  SOURCE_TABLE_NAME
               AND  PRIOR COLUMN_NAME =  SOURCE_COLUMN_NAME
               START WITH SOURCE_TABLE_NAME= :2 AND SOURCE_COLUMN_NAME =:3';

  -- now requery temp table to get the target column fed by this source_column
  for i in 1..l_col_maps.count loop
    open cv for l_stmt using l_s_table, p_b_table_name, l_col_maps(i).source_column_name;
    fetch cv into l_col_maps(i).column_name;
    close cv;
  end loop;
  commit;
  return l_col_maps;
  Exception when others then
    commit;
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.Get_fact_cols_from_b_table:'||p_fact||','||p_dim_set||','||p_b_table_name||','||p_col_type||':'||sqlerrm);
    raise;

End;


procedure set_table_property(p_table_name in varchar2, p_property_name in varchar2, p_property_value in varchar2) is
cursor get_old_value is
select properties from bsc_db_tables where table_name=p_table_name;
l_old_value varchar2(4000);
l_final_value varchar2(4000);
l_pos number;
l_property_value varchar2(4000);

begin
  open get_old_value;
  fetch get_old_value into l_old_value;
  close get_old_value;
  l_property_value := p_property_name||BSC_DBGEN_STD_METADATA.BSC_ASSIGNMENT||
                     p_property_value||BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR;
  if (l_old_value is null) then
    update bsc_db_tables
    set properties = l_property_value
    where table_name = p_table_name;
    return;
  end if;
  -- already has some value, update it in place
  l_pos := instr(l_old_value, BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR||p_property_name||BSC_DBGEN_STD_METADATA.BSC_ASSIGNMENT);
  if l_pos = 0 then -- check if first value
    l_pos := instr(l_old_value, p_property_name||BSC_DBGEN_STD_METADATA.BSC_ASSIGNMENT);
  end if;
  if l_pos =0 then -- this value does not exist, so append it
    update bsc_db_tables
    set properties = properties||l_property_value
    where table_name = p_table_name;
    return;
  end if;
  -- value exists, so update old value
  if l_pos = 1 then --first value
    l_final_value := l_property_Value;
    l_final_value := l_final_value||substr(l_old_value,
                                       instr(l_old_value, BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR, l_pos)+
                                             length(BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR) );
  else -- intermediate value
    l_final_value := substr(l_old_value, 1, l_pos-1+length(BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR))||l_property_value;
    l_final_value := l_final_value||substr(l_old_value,
                                       instr(l_old_value, BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR, l_pos, 2)+
                                             length(BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR) );
  end if;
  -- now add the rest of the string back

  update bsc_db_tables
    set properties = l_final_value
    where table_name = p_table_name;
  return;
   Exception when others then
    fnd_file.put_line(FND_FILE.LOG, 'Error in BSC_DBGEN_BSC_READER.set_table_property:table='||p_table_name||', property='||p_property_name||', value='||p_property_value||':'||sqlerrm);
    raise;
end;

END BSC_DBGEN_BSC_READER ;

/
