--------------------------------------------------------
--  DDL for Package Body BSC_MO_UI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_UI_PKG" AS
/* $Header: BSCMOUIB.pls 120.15 2007/04/25 12:55:02 ashankar ship $ */

g_recursion_ctr NUMBER := 0;
g_ctr NUMBER := 0;

PROCEDURE truncateTable(pTableName IN VARCHAR2, pSchema IN VARCHAR2 DEFAULT null) IS
l_schema VARCHAR2(30);
l_stmt VARCHAR2(300);
BEGIN
    l_schema := pSchema;
    IF (l_schema IS NULL) THEN
        l_schema  := BSC_MO_HELPER_PKG.getBSCSchema;
    END IF;
    l_stmt := 'TRUNCATE TABLE '||l_schema||'.'||pTableName;
    execute immediate l_stmt;
END;


/****************************************************************************
--  InsertRelatedTables
--    DESCRIPTION:
--       Insert in the array garrTables() all the tables in the current
--       graph that have any relation with the tables in the array
--       arrTables().
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************/

PROCEDURE InsertRelatedTables(numTables IN NUMBER) IS

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
    l_start_time date := sysdate;

BEGIN
    IF BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  IS NULL THEN
        BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
    END IF;
    numNewTables := 0;

    g_recursion_ctr := g_recursion_ctr +1 ;

    If numTables > 0 Then
     --insert the children
     l_stmt := '   INSERT INTO '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.BSC_TMP_BIG_IN_COND (session_id, variable_id, value_v)
            SELECT distinct userenv(''SESSIONID''), 0, TABLE_NAME
            FROM BSC_DB_TABLES_RELS rels
            where source_table_name IN
                (SELECT /*+  index(tmp bsc_tmp_big_in_cond_n1)*/
                    tmp.value_v
                    from bsc_tmp_big_in_cond tmp
                    where tmp.session_id = userenv(''SESSIONID'') and tmp.variable_id = 0)
            minus
            select  /*+  index(cond bsc_tmp_big_in_cond_n1)*/ distinct userenv(''SESSIONID''), 0, value_v
            from bsc_tmp_big_in_cond cond where cond.session_id =userenv(''SESSIONID'')
            and cond.variable_id = 0';
        EXECUTE IMMEDIATE l_stmt;
        numNewTables := sql%ROWCOUNT;
        l_start_Time := sysdate;

        --insert the parents
        l_stmt := 'INSERT INTO '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.BSC_TMP_BIG_IN_COND (session_id, variable_id, value_v)
            SELECT distinct userenv(''SESSIONID''), 0, SOURCE_TABLE_NAME
            FROM BSC_DB_TABLES_RELS
            WHERE table_name IN
                (SELECT /*+  index(cond bsc_tmp_big_in_cond_n1)*/ value_v
                from BSC_TMP_BIG_IN_COND WHERE session_id = userenv(''SESSIONID'') and variable_id = 0)
            minus
            select /*+  index(cond bsc_tmp_big_in_cond_n1)*/ userenv(''SESSIONID''), 0, value_v
            from bsc_tmp_big_in_cond cond where session_id =userenv(''SESSIONID'') and variable_id = 0';

        EXECUTE IMMEDIATE l_stmt;
        numNewTables := numNewTables + sql%ROWCOUNT;
        l_start_Time := sysdate;

        If numNewTables > 0 Then
            l_stmt := 'INSERT INTO '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.BSC_TMP_BIG_IN_COND (session_id, variable_id, value_v)
             SELECT/*+ ordered */
                     distinct userenv(''SESSIONID''), 0, datab.TABLE_NAME
                     FROM
                     BSC_TMP_BIG_IN_COND tmp,
                     BSC_TMP_OPT_KPI_DATA dataa, BSC_TMP_OPT_KPI_DATA datab
                     WHERE
                        tmp.session_id = userenv(''SESSIONID'') and tmp.variable_id = 0
                        and dataa.indicator = datab.indicator
                        and dataa.table_name <> datab.table_name
                        and tmp.value_v=dataa.table_name
                     AND datab.TABLE_NAME IS NOT NULL
                     minus
                    select  userenv(''SESSIONID''), 0, value_v
                    from bsc_tmp_big_in_cond cond where session_id =userenv(''SESSIONID'') and variable_id = 0' ;
            EXECUTE IMMEDIATE l_stmt;
            numNewTables := numNewTables + sql%ROWCOUNT;
            InsertRelatedTables (numNewTables);
        End If;
    End If;

    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp( 'Compl. InsertRelatedTables');
    END IF;

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        bsc_mo_helper_pkg.writeTmp( 'Error in InsertRelatedTables :'||l_error, FND_LOG.LEVEL_UNEXPECTED);
        RAISE;
End;


Procedure MarkIndicsAndTables(pProcessId IN NUMBER) IS

    l_stmt varchar2(1000);
    strWhereInIndics varchar2(1000);
    strWhereNotInIndics varchar2(1000);
    strWhereInTables varchar2(1000);
    i number := 0;
    l_table varchar2(100);
    cv CurTyp;
    l_error VARCHAR2(400);
    l_start_time date := sysdate;

BEGIN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Inside MarkIndicsAndTables');
    END IF;
    --Initialize the array garrTables the tables used by the indicators in the array garrIndics()
    --EDW Integration note:
    --In BSC_KPI_DATA_TABLES, Metadata Optimizer is storing the name of the view (Example: BSC_3001_0_0_5_V)
    --and the name of the S table for BSC Kpis (Example: BSC_3002_0_0_5)
    --In this procedure we need to get tables names from a view BSC_KPI_DATA_TABLES_V.

    BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;
    BSC_METADATA_OPTIMIZER_PKG.garrTables.delete;

    IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics = 0 THEN
        return;
    END IF;

    l_stmt := 'delete '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.BSC_TMP_BIG_IN_COND where session_id = userenv(''SESSIONID'') and variable_id = 0';
    execute immediate l_stmt;

    strWhereInIndics := ' INDICATOR IN (SELECT INDICATOR FROM BSC_TMP_OPT_UI_KPIS WHERE PROCESS_ID = '||TO_CHAR(pProcessId)||')';
    strWhereNotInIndics := 'NOT ('|| strWhereInIndics ||')';

    l_stmt := 'INSERT INTO '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.BSC_TMP_BIG_IN_COND (session_id, variable_id, value_v )
                SELECT DISTINCT userenv(''SESSIONID''), 0, TABLE_NAME FROM BSC_TMP_OPT_KPI_DATA DATA, BSC_TMP_OPT_UI_KPIS TMP
                WHERE TMP.INDICATOR = DATA.INDICATOR AND TMP.PROCESS_ID = :1';
    execute immediate l_stmt using pProcessId;

    BSC_METADATA_OPTIMIZER_PKG.gnumTables := sql%rowcount;

    IF BSC_METADATA_OPTIMIZER_PKG.gnumTables > 0 THEN
       --Insert in the array garrTables() all the tables in the current
       --graph that have any relation with them
        InsertRelatedTables(BSC_METADATA_OPTIMIZER_PKG.gnumTables);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Done with InsertRelatedTables');
  END IF;

        l_stmt := 'INSERT INTO BSC_TMP_OPT_UI_KPIS (INDICATOR, PROTOTYPE_FLAG, PROCESS_ID)
                    SELECT DISTINCT INDICATOR, 3, :1 FROM BSC_TMP_OPT_KPI_DATA
                    WHERE TABLE_NAME IN
                        (SELECT /*+ index(cond bsc_tmp_big_in_cond_n1)*/VALUE_V FROM BSC_TMP_BIG_IN_COND cond WHERE SESSION_ID = :2 )
                    AND INDICATOR NOT IN
                        (SELECT INDICATOR FROM BSC_TMP_OPT_UI_KPIS WHERE PROCESS_ID = :3)';
        execute immediate l_stmt using pProcessId, USERENV('SESSIONID'), pProcessId;
        BSC_METADATA_OPTIMIZER_PKG.gnumIndics := BSC_METADATA_OPTIMIZER_PKG.gnumIndics + sql%ROWCOUNT;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        bsc_mo_helper_pkg.writeTmp('Exception in MarkIndicsAndTables : '||l_error);
        raise;
End;


--****************************************************************************
--  MarkIndicsForNonStrucChanges
--    DESCRIPTION:
--       The array garrIndics4() is initialized with currently flagged indicators
--       for non-structural changes. (Protoype_Flag = 4)
--       This procedure adds to the same array the related indicators.
--       Designer is only flagging the indicators
--       that are using the measure direclty. We need to flag other indicators
--       using the same measures alone or as part of a formula.
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE MarkIndicsForNonStrucChanges IS
    l_stmt Varchar2(1000);
    strWhereInIndics Varchar2(1000);
    strWhereNotInIndics Varchar2(1000);
    strWhereInMeasures Varchar2(1000);
    i NUMBER := 0;
    arrMeasuresCols  DBMS_SQL.VARCHAR2_TABLE;
    numMeasures NUMBER;
    arrRelatedMeasuresIds DBMS_SQL.NUMBER_TABLE;

    --measureCol Varchar2(1000);
    Operands DBMS_SQL.VARCHAR2_TABLE;
    NumOperands NUMBER;

  l_measureID NUMBER;
  l_measureCol VARCHAR2(500);
     cv   CurTyp;

     l_error varchar2(400);
     l_stack VARCHAR2(32000);

BEGIN
        IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 <= 0 THEN
            return;
        END IF;
        --Init and array with the measures used by the indicators flagged for
        --non-structural changes

        numMeasures := 0;
        strWhereInIndics := bsc_mo_helper_pkg.Get_New_Big_In_Cond_Number(9, 'I.INDICATOR');
      i:= 0;
      LOOP
        EXIT WHEN i=BSC_METADATA_OPTIMIZER_PKG.gnumIndics4;
        bsc_mo_helper_pkg.Add_Value_Big_In_Cond_Number( 9, BSC_METADATA_OPTIMIZER_PKG.garrIndics4(i));
        i:=i+1;
        END LOOP;

        --PMF-BSC Integration: Filter out PMF measures
        l_stmt := 'SELECT DISTINCT M.MEASURE_COL FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_KPI_V I'
    || ' WHERE I.MEASURE_ID = M.MEASURE_ID AND ('|| strWhereInIndics ||' )'||
    '  AND M.TYPE = 0  AND NVL(M.SOURCE, ''BSC'') = ''BSC'' ';
     OPEN cv FOR l_stmt;

      LOOP
        FETCH cv INTO l_measureCol;
        EXIT when cv%NOTFOUND;
            arrMeasuresCols(numMeasures) := l_measureCol;
            numMeasures := numMeasures + 1;
        END Loop;
      CLOSE cv;


        /*The measures in the array arrMeasuresCols are the ones that could be changed
        For that reason the indicators were flagged to 4
        We need to see in all system measures if there is a formula using that measure.
        IF that happen we need to add that measure. Any kpi using that meaure should be flaged too.*/

        strWhereNotInIndics := ' NOT ( ' || strWhereInIndics || ')';

        l_stmt := 'SELECT DISTINCT M.MEASURE_ID, M.MEASURE_COL '
    ||'FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_KPI_V I '||
    ' WHERE I.MEASURE_ID = M.MEASURE_ID AND ('|| strWhereNotInIndics ||' ) '||
    '  AND M.TYPE = 0 AND NVL(M.SOURCE, ''BSC'') = ''BSC''';

      OPEN cv FOR l_stmt;

        LOOP
            FETCH cv into l_measureID, l_measureCol;
            EXIT WHEN cv%NOTFOUND;
            NumOperands := bsc_mo_helper_pkg.GetFieldExpression(Operands, l_measureCol);
          i:= Operands.first;
            LOOP
                EXIT WHEN Operands.count =0 ;
                IF bsc_mo_helper_pkg.SearchStringExists(arrMeasuresCols, numMeasures, Operands(i)) THEN
                    --One operand of the formula is one of the measures of a indicator flagged with 4
                    --We need to add this formula (measure) to the related ones
                    arrRelatedMeasuresIds(arrRelatedMeasuresIds.count) := l_measureID;
                END IF;
                EXIT WHEN i = Operands.last;
                i:= Operands.next(i);
            END LOOP;
        END Loop;
        close cv;

        l_stack := l_stack ||' Check 3,  arrRelatedMeasuresIds.count =  '|| to_char(arrRelatedMeasuresIds.count);
        --Now we need to add to garrIndics4() all the indicators using any of the measures
        --in arrRelatedMeasuresIds()

        IF  arrRelatedMeasuresIds.count > 0 THEN
            strWhereInMeasures := bsc_mo_helper_pkg.Get_New_Big_In_Cond_Number( 9, 'MEASURE_ID');
         i:= arrRelatedMeasuresIds.first;

         LOOP
                EXIT WHEN i=arrRelatedMeasuresIds.last;
                bsc_mo_helper_pkg.Add_Value_Big_In_Cond_Number( 9, arrRelatedMeasuresIds(i));
                i:= arrRelatedMeasuresIds.next(i);
           END LOOP;

           l_stmt := 'SELECT DISTINCT INDICATOR FROM BSC_DB_MEASURE_BY_KPI_V  '||
                ' WHERE ('|| strWhereInMeasures || ')';
           open cv for L_stmt;
           LOOP
                fetch cv into l_measureCol;
                EXIT WHEN cv%NOTFOUND;
                IF Not bsc_mo_helper_pkg.SearchNumberExists(BSC_METADATA_OPTIMIZER_PKG.garrIndics4, BSC_METADATA_OPTIMIZER_PKG.gnumIndics4, l_measureCol) THEN
                    BSC_METADATA_OPTIMIZER_PKG.garrIndics4(BSC_METADATA_OPTIMIZER_PKG.gnumIndics4) := l_measureCol;
                    BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 := BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 + 1;
                END IF;
           END Loop;
           close cv;
           l_stack := l_stack ||' Check 5 ';
        END IF;

    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Completed MarkIndicsForNonStrucChanges', FND_LOG.LEVEL_PROCEDURE);
    END IF;

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        bsc_mo_helper_pkg.writeTmp('Exception in MarkIndicsForNonStrucChanges : '||l_error);
        bsc_mo_helper_pkg.writeTmp('Local Stack dump = '||l_stack);
        raise;
End;


PROCEDURE create_ui_kpi_table IS
l_stmt varchar2(1000) := 'CREATE /*GLOBAL TEMPORARY */ TABLE BSC_TMP_OPT_UI_KPIS(
INDICATOR NUMBER, PROTOTYPE_FLAG NUMBER, PROCESS_ID NUMBER) ';

--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    --bsc_mo_helper_pkg.dropTable('BSC_TMP_OPT_UI_KPIS');
    BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.create_table, 'BSC_TMP_OPT_UI_KPIS');
    --commit;
END;

--Procedure added for bug 3911548
procedure create_tmp_opt_kpi_data is
    l_stmt varchar2(1000);
begin
    IF (NOT BSC_DBGEN_UTILS.IS_TMP_TABLE_EXISTED('BSC_TMP_OPT_KPI_DATA')) THEN
        begin
            bsc_mo_helper_pkg.dropTable('BSC_TMP_OPT_KPI_DATA');
        exception when others then
            null;
        end;

        l_stmt := 'CREATE GLOBAL TEMPORARY TABLE BSC_TMP_OPT_KPI_DATA (INDICATOR NUMBER, TABLE_NAME VARCHAR2(100)) ON COMMIT PRESERVE ROWS';
        BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.create_table, 'BSC_TMP_OPT_KPI_DATA');
        l_stmt := 'create unique index bsc_tmp_opt_kpi_data_u1 on bsc_tmp_opt_kpi_data(indicator, table_name)';
        BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.create_index, 'BSC_TMP_OPT_KPI_DATA_U1');
        dbms_stats.gather_table_stats(BSC_METADATA_OPTIMIZER_PKG.gBSCSchema, 'BSC_TMP_OPT_KPI_DATA');
        dbms_stats.gather_index_stats(BSC_METADATA_OPTIMIZER_PKG.gBSCSchema, 'BSC_TMP_OPT_KPI_DATA_U1');
    END IF;
    -- table may not exist after upgrade, so have to make it dynamic
    execute immediate 'DELETE BSC_TMP_OPT_KPI_DATA';
    --l_stmt := 'INSERT INTO BSC_TMP_OPT_KPI_DATA
    --             SELECT DISTINCT INDICATOR, TABLE_NAME
    --             FROM BSC_KPI_DATA_TABLES
    --             WHERE TABLE_NAME IS NOT NULL';
    l_stmt := 'INSERT INTO BSC_TMP_OPT_KPI_DATA
                 SELECT DISTINCT
                   TO_NUMBER
                   (
                     SUBSTR
                     (
                       TABLE_NAME,
                       INSTR(TABLE_NAME,''_'',1,2)+1,
                       INSTR(TABLE_NAME,''_'',1,3)-INSTR(TABLE_NAME,''_'',1,2)-1
                     )
                   ),
                   TABLE_NAME
                 FROM  BSC_DB_TABLES_RELS
                 WHERE TABLE_NAME LIKE ''BSC_S%''
                 AND  (SOURCE_TABLE_NAME LIKE ''BSC_B%''
                 OR    SOURCE_TABLE_NAME LIKE ''BSC_T%'')';
    execute immediate l_stmt;
end;

PROCEDURE CreateDBMeasureByKpiView IS
  l_stmt varchar2(1000);
BEGIN
  bsc_mo_helper_pkg.writeTmp('Started CreateDBMeasureByKpiView', FND_LOG.LEVEL_PROCEDURE);
  l_stmt := ' CREATE OR REPLACE VIEW BSC_DB_MEASURE_BY_KPI_V( INDICATOR, MEASURE_ID ) AS
                SELECT DB.INDICATOR, DS.MEASURE_ID1 AS MEASURE_ID
                FROM BSC_KPI_ANALYSIS_MEASURES_B DB, BSC_SYS_DATASETS_B DS
                WHERE DB.DATASET_ID = DS.DATASET_ID
                UNION
                SELECT DB.INDICATOR, DS.MEASURE_ID2 AS MEASURE_ID
                FROM BSC_KPI_ANALYSIS_MEASURES_B DB, BSC_SYS_DATASETS_B DS
                WHERE DB.DATASET_ID = DS.DATASET_ID AND DS.MEASURE_ID2 IS NOT NULL ';
  execute immediate l_stmt;
  bsc_mo_helper_pkg.writeTmp('Completed CreateDBMeasureByKpiView', FND_LOG.LEVEL_PROCEDURE);
  exception when others then
    bsc_mo_helper_pkg.writeTmp('Error in CreateDBMeasureByKpiView :'||sqlerrm, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
END;

-- pProcessId = -ICX_Session_Id (For cleanup)
PROCEDURE updateRelatedIndicators(
    pMode IN VARCHAR2,
    pProcessId IN NUMBER
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_stmt varchar2(1000);
    l_Code number;
    l_Name varchar2(100);
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
    l_start_time date := sysdate;
    l_total_kpis NUMBER := 0;

BEGIN
    bsc_apps.init_bsc_apps;
    BSC_METADATA_OPTIMIZER_PKG.g_log := false;
    BSC_METADATA_OPTIMIZER_PKG.gUIAPI := true;
    IF BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  IS NULL THEN
        BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
    END IF;
    BSC_METADATA_OPTIMIZER_PKG.garrIndics.delete;
    BSC_METADATA_OPTIMIZER_PKG.gnumIndics := 0;
    BSC_METADATA_OPTIMIZER_PKG.garrIndics4.delete;
    BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 := 0;
    BSC_METADATA_OPTIMIZER_PKG.garrTables.delete;
    BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;

    IF (NOT BSC_MO_HELPER_PKG.tableExists('BSC_TMP_OPT_UI_KPIS')) THEN
        create_ui_kpi_table;
    END IF;

    --EXECUTE IMMEDIATE 'delete BSC_TMP_OPT_UI_KPIS where process_Id = -200 or process_Id = 0 or process_Id is null';
    --truncateTable('BSC_TMP_OPT_UI_KPIS', BSC_METADATA_OPTIMIZER_PKG.gBSCSchema);
    l_stmt := 'DELETE BSC_TMP_OPT_UI_KPIS WHERE PROCESS_ID = :1 ';
    EXECUTE IMMEDIATE l_stmt USING pProcessId;
    COMMIT;

    -- Default list for Selected Objectives
    if (pMode = 'SELECTED' OR pMode = 'SELECTED_REPORTS' OR pMode = 'SELECTED_SIMULATIONS') then
        l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                    SELECT INDICATOR, prototype_flag, :1
                    FROM BSC_KPIS_VL
                    WHERE PROTOTYPE_FLAG NOT IN (1,2,3,4)';
        execute immediate l_stmt USING pProcessId;
        commit;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp( 'Completed updateRelatedIndicators');
        END IF;
        return;
    end if;

    create_tmp_opt_kpi_data;

    if (pMode = 'ALL') THEN
        l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                    SELECT INDICATOR, prototype_flag, :1
                    FROM BSC_KPIS_VL
                    WHERE BSC_DBGEN_UTILS.GET_OBJECTIVE_TYPE(SHORT_NAME) = :2 ';
        execute immediate l_stmt USING pProcessId, 'OBJECTIVE';
        commit;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp( 'Completed updateRelatedIndicators');
        END IF;
        return;
    end if;

    -- Only Modified mode, now, all other Modes would have returned.
    SELECT count(1) INTO l_total_kpis FROM BSC_KPIS_B;
    l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                SELECT INDICATOR, prototype_flag, :1
                FROM BSC_KPIS_VL
                WHERE (PROTOTYPE_FLAG = 2 OR PROTOTYPE_FLAG = 3) ';
    execute immediate l_stmt USING pProcessId;

    IF (SQL%ROWCOUNT = l_total_kpis) THEN
        commit;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp( 'Completed updateRelatedIndicators');
        END IF;
        return;
    END If;

    BSC_METADATA_OPTIMIZER_PKG.gnumIndics := SQL%ROWCOUNT;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('# of Indics = '||BSC_METADATA_OPTIMIZER_PKG.gnumIndics);
    END IF;

    MarkIndicsAndTables(pProcessId);

    BSC_METADATA_OPTIMIZER_PKG.gThereisStructureChange := False;

    --Add indicators with flag = 4 (reconfigure update)
    --in the collection gIndicadores
    --Of course if the indicator is already in gIndicadores (Structural changes) we do not change it.
    --Init an array with the Kpis in prototype 4 (changes in loader configuration)

    l_stmt := 'SELECT INDICATOR FROM BSC_KPIS_B WHERE PROTOTYPE_FLAG = 4
               MINUS
               SELECT INDICATOR FROM BSC_TMP_OPT_ui_kpis WHERE process_id = :1
               ORDER BY INDICATOR';
    open cv for l_stmt USING pProcessId;

    LOOP
        fetch cv into l_indicator4;
        exit when cv%NOTFOUND;
        BSC_METADATA_OPTIMIZER_PKG.garrIndics4(BSC_METADATA_OPTIMIZER_PKG.gnumIndics4) := l_indicator4;
        BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 := BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 + 1;
    END Loop;
    close cv;

    --We need to add the related indicators. Designer is only flagging the indicators
    --that are using the measure direclty. We need to flag other indicators
    --using the same measures alone or as part of a formula.

    IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 > 0 THEN
        CreateDBMeasureByKpiView;
        MarkIndicsForNonStrucChanges;
        --Add the indicators from garrIndics4() to gIndicadores
        strWhereInIndics4 := BSC_MO_HELPER_PKG.Get_New_Big_In_Cond_Number( 2, 'INDICATOR');
        i:= 0;
        LOOP
            exit when i = BSC_METADATA_OPTIMIZER_PKG.gnumIndics4;
            BSC_MO_HELPER_PKG.Add_Value_Big_In_Cond_Number( 2, BSC_METADATA_OPTIMIZER_PKG.garrIndics4(i));
            i:= i+1;
        END LOOP;
        strWhereNotInIndics4 := 'NOT (' || strWhereInIndics4 || ')';
        l_stmt := 'INSERT INTO BSC_TMP_OPT_UI_KPIS( INDICATOR, PROTOTYPE_FLAG, process_id)
                   SELECT DISTINCT INDICATOR, 4, :1
                   FROM BSC_KPIS_VL WHERE (' || strWhereInIndics4 || ')';
        IF BSC_METADATA_OPTIMIZER_PKG.gnumIndics > 0 THEN
            l_stmt := l_stmt || ' minus select indicator, 4, :2 from BSC_TMP_OPT_ui_kpis WHERE process_id = :3 ';
            execute immediate l_stmt USING pProcessId, pProcessId, pProcessId;
        ELSE
            execute immediate l_stmt USING pProcessId;
        END IF;
    END IF;

    IF BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0 THEN
        -- summarization change, add production indicators to the list.
        l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                    SELECT INDICATOR, prototype_flag, :1 FROM BSC_KPIS_VL a
                    WHERE NOT EXISTS (SELECT 1 FROM BSC_TMP_OPT_UI_KPIS b WHERE process_id = :2 and a.indicator = b.indicator)';
        execute immediate l_stmt USING pProcessId, pProcessId;

    END IF;

    -- take care of shared kpis, which are NOT marked by the builder, just in case
    l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                SELECT child.INDICATOR, parent.prototype_flag, :1
                FROM BSC_KPIS_VL parent,
                BSC_KPIS_VL child,
                BSC_TMP_OPT_UI_KPIS uitmp
                where uitmp.indicator = parent.indicator
                and uitmp.process_id = :2
                and parent.share_flag = 1
                and child.share_flag = 2
                and parent.indicator = child.source_indicator
                AND NOT EXISTS (SELECT 1 FROM BSC_TMP_OPT_UI_KPIS c WHERE process_id = :3 and c.indicator = child.indicator)';
        execute immediate l_stmt USING pProcessId, pProcessId, pProcessId;

    -- insert remaining KPIS finally, UI wants it
    l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                SELECT INDICATOR, prototype_flag, :1 FROM BSC_KPIS_VL a
                WHERE NOT EXISTS (SELECT 1 FROM BSC_TMP_OPT_UI_KPIS b WHERE process_id = :2 and a.indicator = b.indicator)';
    execute immediate l_stmt USING pProcessId, pProcessId;

    -- Get rid of the autogen. report generated objectives for ALL and MODIFIED modes
    IF (pMode='MODIFIED') THEN
        l_stmt := 'delete from BSC_TMP_OPT_UI_KPIS tmp
                   where process_id = :1
                   and indicator in
                      (select indicator from bsc_kpis_vl kpis
                       where kpis.short_name is not null
                       and BSC_DBGEN_UTILS.get_objective_type(kpis.short_name) <> ''OBJECTIVE'') ';
        execute immediate l_stmt USING pProcessId;
    END IF;
    commit;

    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp( 'Completed updateRelatedIndicators');
    END IF;

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.writeTmp('Exception in updateRelatedIndicators : '||l_error, FND_LOG.LEVEL_EXCEPTION);
        raise;
END;

-- Incremental Run call from UI
-- Update bsc_kpis_b for all indicators

PROCEDURE RenameInputTable(pOld IN VARCHAR2, pNew IN VARCHAR2, pStatus OUT NOCOPY VARCHAR2, pMessage OUT NOCOPY VARCHAR2)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_stmt VARCHAR2(1000);
    l_count NUMBER;

BEGIN

    IF pOld = pNew tHEN
        return;
    END IF;

    bsc_apps.init_bsc_apps;

    BSC_METADATA_OPTIMIZER_PKG.g_log := false;
    BSC_METADATA_OPTIMIZER_PKG.gUIAPI := true;

    pStatus := 'N';
    pMessage := null;

    -- Bug 3830308 : Added owner clause because of new GSCC validation added on aug 9, 2004
    --------------
    IF BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  IS NULL THEN
        BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
    END IF;

    IF BSC_METADATA_OPTIMIZER_PKG.gAppsSchema  IS NULL THEN
        BSC_METADATA_OPTIMIZER_PKG.gAppsSchema  := BSC_MO_HELPER_PKG.getAppsSchema;
    END IF;
    --------------
    -- Check if table already exists
    -- Bug 3830308 : Added owner clause because of new GSCC validation added on aug 9, 2004
    select count(1) INTO l_count
    from all_objects where object_name = pNew
  and owner IN (BSC_METADATA_OPTIMIZER_PKG.gBSCSchema, BSC_METADATA_OPTIMIZER_PKG.gAppsSchema);

    IF (l_count > 0) THEN
        fnd_message.set_name('BSC', 'BSC_DUPLICATED_TABLENAME');
        pMessage := fnd_message.get;
        return;
    END IF;


    --BSC_DB_TABLES
    UPDATE BSC_DB_TABLES set table_name = pNew where table_name = pOld;

    --BSC_DB_TABLES_COLS
    UPDATE BSC_DB_TABLES_COLS set table_name = pNew where table_name = pOld;

    --BSC_DB_TABLES_RELS
    UPDATE BSC_DB_TABLES_RELS set source_table_name = pNew where source_table_name = pOld;

    -- Need not update BSC_DB_CALCULATIONS as it wont have anything for Input tables
      execute immediate 'alter table '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.'||pOld||' rename to '||pNew;
      begin
      execute immediate 'drop synonym '||pOld;
      exception when others then
        null;
      end;
      execute immediate 'create synonym '||pNew||' for '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.'||pNew;
    --BSC_MO_HELPER_PKG.createCopyTable(pOld, pNew, BSC_APPS.get_tablespace_name(BSC_APPS.input_table_tbs_type));
    --BSC_MO_HELPER_PKG.CreateCopyIndexes (pOld, pNew, BSC_APPS.get_tablespace_name(BSC_APPS.input_index_tbs_type));
    --BSC_MO_HELPER_PKG.dropTable(pOld);
    pStatus := 'Y';

    EXCEPTION WHEN OTHERS THEN
        pMessage := sqlerrm;
        pStatus := 'N';
        rollback;
        raise;
END;

PROCEDURE create_ui_table IS
l_stmt varchar2(1000) := 'CREATE GLOBAL TEMPORARY TABLE BSC_TMP_OPT_UI_LEVELS(
INDICATOR NUMBER,
DIM_SET_ID NUMBER,
DIM_DISPLAY_ORDER NUMBER,
LEVEL_DISPLAY_ORDER NUMBER,
LEVEL_TABLE_NAME VARCHAR2(100),
LEVEL_DISPLAY_NAME VARCHAR2(300),
TARGET_LEVEL NUMBER)
  ON COMMIT PRESERVE ROWS';

PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.create_table, 'BSC_TMP_OPT_UI_LEVELS');
END;


PROCEDURE initializeIndicator (pIndicator IN NUMBER) IS
    -- used by UI API
    CURSOR cAPI IS
    SELECT DISTINCT INDICATOR, NAME, PROTOTYPE_FLAG,
        INDICATOR_TYPE, CONFIG_TYPE, PERIODICITY_ID,
        SHARE_FLAG, SOURCE_INDICATOR,
        EDW_FLAG FROM BSC_KPIS_VL WHERE
        INDICATOR = pIndicator;
    cIndAPI cAPI%ROWTYPE;

BEGIN
  IF (BSC_METADATA_OPTIMIZER_PKG.gUIAPI) THEN
    -- need to initialize gIndicators with this Ind
    OPEN cAPI;
    FETCH cAPI INTO cIndAPI;
    BSC_MO_HELPER_PKG.AddIndicator( BSC_METADATA_OPTIMIZER_PKG.gIndicators, cIndAPI.Indicator, cIndAPI.name,
          cIndAPI.indicator_type, cIndAPI.Config_Type,
          cIndAPI.periodicity_id, 1, cIndAPI.prototype_flag, cIndAPI.share_flag,
          cIndAPI.source_indicator, cIndAPI.edw_flag, 1);
  END IF;
  CLOSE cAPI;
END;


PROCEDURE updateTargets(pIndicator IN NUMBER) IS
l_stmt VARCHAR2(1000) := 'UPDATE BSC_TMP_OPT_UI_LEVELS UI SET TARGET_LEVEL =
    ( SELECT TARGET_LEVEL FROM bsc_kpi_dim_levels_vl DIM
        WHERE UI.DIM_SET_ID = DIM.DIM_SET_ID
        AND UI.INDICATOR = DIM.INDICATOR
        AND UI.INDICATOR = : 1
        AND UI.LEVEL_TABLE_NAME= DIM.LEVEL_TABLE_NAME)
        WHERE UI.indicator = :2';
BEGIN

    EXECUTE IMMEDIATE l_stmt USING pIndicator, pIndicator;
END;


PROCEDURE insert_dimension_set (--pReturnArray IN OUT tab_clsIndicatorLevels,
                                pIndicator IN NUMBER, p_set IN NUMBER,
                                p_levels IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels ) IS
l_groupids DBMS_SQL.NUMBER_TABLE;
l_dim_index NUMBER;

l_level_index NUMBER :=0 ;
l_stmt VARCHAR2(300) := ' INSERT INTO BSC_TMP_OPT_UI_LEVELS (INDICATOR, DIM_SET_ID, DIM_DISPLAY_ORDER, LEVEL_DISPLAY_ORDER, LEVEL_TABLE_NAME, LEVEL_DISPLAY_NAME) '||
            ' values (:1, :2, :3, :4, :5, :6)';
DimensionLevels BSC_METADATA_OPTIMIZER_PKG.Tab_clsLevels;

--l_indLevel clsIndicatorLevels;

BEGIN

    l_groupids := BSC_MO_HELPER_PKG.getGroupIds(p_levels);
    l_dim_index := l_groupids.first;

    LOOP
        EXIT WHEN l_groupids.count = 0;
        DimensionLevels := BSC_MO_HELPER_PKG.get_Tab_clsLevels(p_levels, l_groupids(l_dim_index)) ;
        l_level_index := DimensionLevels.first;
        LOOP
            EXIT WHEN DimensionLevels.count = 0;

            execute immediate l_stmt USING pIndicator, p_set, l_dim_index, l_level_index,
                DimensionLevels(l_level_index).dimTable, DimensionLevels(l_level_index).name;

            EXIT WHEN l_level_index = DimensionLevels.last;
            l_level_index := DimensionLevels.next(l_level_index);
        END LOOP;
        EXIT WHEN l_dim_index = l_groupids.last;
        l_dim_index := l_groupids.next(l_dim_index);
    END LOOP;

END;


PROCEDURE GetLevelsForIndicator(pIndicator IN NUMBER) IS -- RETURN tab_clsIndicatorLevels IS
    l_stmt VARCHAR2(1000);
    l_count NUMBER;
    l_levels BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels ;
    colConfigurations DBMS_SQL.NUMBER_TABLE;
    l_config_index NUMBER;
    l_insert_count NUMBER := 0;
    cv CurTyp;
BEGIN
  BSC_METADATA_OPTIMIZER_PKG.g_log := false;
  BSC_METADATA_OPTIMIZER_PKG.gUIAPI := true;
  IF BSC_METADATA_OPTIMIZER_PKG.gBSCSchema IS NULL THEN
    BSC_METADATA_OPTIMIZER_PKG.gBSCSchema := BSC_MO_HELPER_PKG.getBSCSchema;
  END IF;
  IF (NOT BSC_MO_HELPER_PKG.tableExists('BSC_TMP_OPT_UI_LEVELS')) THEN
    create_ui_table;
  ELSE
    execute immediate 'delete BSC_TMP_OPT_UI_LEVELS';
    commit;
  END IF;

  --l_stmt := 'select count(1) from BSC_TMP_OPT_UI_LEVELS where indicator = :1 ';
  --OPEN CV FOR l_stmt USING pIndicator;
  --FETCH CV INTO l_insert_count;
  --CLOSE CV;
  --IF (l_insert_count <>0 ) THEN
  --  return; -- already exists, dont do anything, table to be cleaned up by UI
  --  -- everytime the metadata optimizer UI is launched, the cleanup will be done, as its a perm. temp table
  --END IF;

  initializeIndicator(pIndicator);
  BSC_MO_HELPER_PKG.InitializeMasterTables;
  colConfigurations := bsc_mo_indicator_pkg.GetColConfigForIndic(pIndicator);
  l_config_index := colConfigurations.first;
  LOOP
    EXIT WHEN colConfigurations.count = 0;
    l_levels.delete;
    l_levels := BSC_MO_INDICATOR_PKG.getLevelCollection(pIndicator, colConfigurations(l_config_index));
    insert_dimension_set(/*l_return_array, */pIndicator, colConfigurations(l_config_index), l_levels);
    EXIT WHEN l_config_index = colConfigurations.last;
    l_config_index := colConfigurations.next(l_config_index);
  END LOOP;
  select count(1) INTO l_count FROM bsc_kpi_dim_levels_vl
  where indicator = pIndicator
  and target_level = 0;
  IF (l_count > 0) THEN
    -- update table for target levels
    updateTargets(pIndicator);
  END IF;
  -- added for possible corner case, bug 4158914
  commit;
END;

FUNCTION GetDescriptionForColumn(pTableName IN VARCHAR2, pColumnName IN VARCHAR2) RETURN VARCHAR2 IS
cursor cCols IS
select lvl.help description from
bsc_sys_dim_levels_vl lvl
where
upper(pColumnName) = upper(lvl.level_pk_col)
UNION
select measure.help description from
bsc_db_measure_cols_vl measure
WHERE upper(pColumnName) = upper(measure.measure_col);
cRow cCols%ROWTYPE;
l_count NUMBER := 0;
CURSOR cTable (l_table IN VARCHAR2) IS
    SELECT TABLE_NAME, TABLE_TYPE, PERIODICITY_ID, EDW_FLAG, TARGET_FLAG
    FROM BSC_DB_TABLES
    WHERE TABLE_TYPE <> 2
    AND TABLE_NAME = l_table
    ORDER BY TABLE_NAME;
cRow1 cTable%ROWTYPE;
    NomPeriodicity VARCHAR2(100);
    NomCampoPeriod VARCHAR2(100);
    MaxPeriod NUMBER;
    NomCampoSubPeriod VARCHAR2(100);
    MaxSubPeriod NUMBER;
    isBaseTable boolean := false;

CURSOR cPeriods (pPer NUMBER) IS
    SELECT YEARLY_FLAG
    FROM BSC_SYS_PERIODICITIES_VL
    WHERE PERIODICITY_ID = pPer
    ORDER BY PERIODICITY_ID;

    yearly_flag number := 0;


    l_description VARCHAR2(1024);
    l_stmt VARCHAR2(1000) :=
        'select table_name from bsc_kpi_data_tables where mv_name = :1';
    cv CurTyp;

    l_table_name VARCHAR2(300);

    l_test NUMBER := -1;
BEGIN
    l_table_name := pTableName;

    If fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL') IS NULL Then
            BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV := False;
    Else
            BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV := True;
    End If;

    If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then

        select count(1) into l_test from bsc_db_tables tab, bsc_db_tables_rels rels
        where rels.table_name = l_table_name
        and rels.source_table_name = tab.table_name
        and tab.table_type = 0 ; -- input table
        IF (l_test > 0) THEN
            isBaseTable := true;
        ELSE
            isBaseTable := false;
        END IF;
    End If;
    OPEN cTable (l_table_name);
    FETCH cTable INTO cRow1;
    IF (cTable%NOTFOUND) THEN -- mv
        CLOSE cTable;
        OPEN cv for l_stmt USING l_table_name;
        FETCH CV INTO l_table_name;
        CLOSE CV;
        OPEN cTable (l_table_name);
        FETCH cTable INTO cRow1;
    END IF;
    CLOSE cTable;
    OPEN cPeriods(cRow1.periodicity_id);
    FETCH cPeriods INTO yearly_flag;
    CLOSE cPeriods;

    If cRow1.TABLE_TYPE = 0 Then
        --input table
        NomPeriodicity := BSC_MO_DOC_PKG.GetPeriodicityName(cRow1.PERIODICITY_ID);
        NomPeriodicity := NomPeriodicity || ' (' || BSC_MO_DOC_PKG.GetPeriodicityCalendarName(cRow1.PERIODICITY_ID) || ')';
        NomCampoPeriod := BSC_MO_DB_PKG.GetPeriodColumnName(cRow1.PERIODICITY_ID);
        MaxPeriod := BSC_MO_DOC_PKG.GetMaxPeriod(cRow1.PERIODICITY_ID);
        NomCampoSubPeriod := BSC_MO_DB_PKG.GetSubperiodColumnName(cRow1.PERIODICITY_ID);
        MaxSubPeriod := BSC_MO_DOC_PKG.GetMaxSubPeriodUsr(cRow1.PERIODICITY_ID);

    Else
        --system table
        NomPeriodicity := BSC_MO_DOC_PKG.GetPeriodicityName(cRow1.PERIODICITY_ID) ;
        NomPeriodicity := NomPeriodicity || ' (' || BSC_MO_DOC_PKG.GetPeriodicityCalendarName(cRow1.PERIODICITY_ID) || ')';
        NomCampoPeriod := 'PERIOD';
        MaxPeriod := BSC_MO_DOC_PKG.GetMaxPeriod(cRow1.PERIODICITY_ID);
        NomCampoSubPeriod := null;
        MaxSubPeriod := 0;
    End If;

    OPEN cCols;
    FETCH cCols INTO l_description;
    CLOSE cCols;

        --Bug 3900047
        -- Added condition UPPER(pColumnName) = 'TIME_FK' to return Desc as Internal Column
        --Bug 3919130 superseds bug 3900047
        -- Description for the TIME_FK should be Date
        IF (l_description IS NULL) THEN
            If UPPER(pColumnName) = 'PERIODICITY_ID' OR UPPER(pColumnName) = 'PERIOD_TYPE_ID' Then
                l_description := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INTERNAL_COLUMN');
            ElsIf UPPER(pColumnName) = 'TIME_FK' Then
                l_description := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'DATE');
            ElsIf UPPER(pColumnName) = 'YEAR' Then
                l_description := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'YEAR_1999_2000_ACTUAL_YEAR');
            ElsIf UPPER(pColumnName) = 'TYPE' Then
                l_description := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE_0_ACTUAL_1_PLAN');
    IF (cRow1.target_flag =1) THEN -- this is a target table
      l_description := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE1_PLAN');
    END IF;
            ElsIf UPPER(pColumnName) = UPPER(NomCampoPeriod) Then

                If (BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV And (cRow1.Table_Type = 0 Or isBaseTable)) Or (Not BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV) Then

                    If Yearly_Flag = 1 Then
                        l_description := l_description || '0';  --bug#3980028
                    Else
                        l_description := l_description||BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'PERIOD') ||
                            BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' 1' || ' ' ||
                            BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_IVIEWER', 'TO') || ' ' || MaxPeriod;
                    End If;
                Else
                    --Do not mention more info about period. MV has multiple periodicities.
                    l_description := l_description||BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'PERIOD');
                End If;
            ElsIf UPPER(pColumnName) = UPPER(NomCampoSubPeriod) Then
                l_description := l_description ||BSC_MO_HELPER_PKG.Get_LookUp_Value(
                'BSC_UI_BACKEND', 'SUBPERIOD_1_TO') || ' ' || MaxSubPeriod;
            End If;

        END IF;

    return l_description;
Exception when others then
  return null;
END;

PROCEDURE launchOptimizer(pMode IN VARCHAR2, pRequestID OUT NOCOPY NUMBER, pStatus OUT NOCOPY VARCHAR2, pMessage OUT NOCOPY VARCHAR2) IS
l_mode NUMBER;
l_reqid NUMBER;
BEGIN
    IF (pMode = 'INCREMENTAL') THEN
        l_mode := 1;
    ELSE
        l_mode := 0;
    END IF;

    pRequestID := FND_REQUEST.SUBMIT_REQUEST(
                    application=>'BSC',
                    program=>'BSC_METADATA_OPTIMIZER',
                    argument1=>l_mode);
    commit;
    pStatus := 'Y';
    pMessage := null;

    EXCEPTION WHEN OTHERS THEN
        pMessage := sqlerrm;
        pStatus := 'N';
        raise;
END;

FUNCTION getColDetails(pColType IN VARCHAR2, pTableName IN VARCHAR2, pTabType IN VARCHAR2) return CLOB IS

cursor cDims (l_schema IN VARCHAR2) IS
select lvl.name, cols.column_name
from
all_tab_columns cols,
bsc_sys_dim_levels_vl lvl
where cols.table_name = pTableName
and cols.owner = l_schema
and cols.column_name = upper(lvl.level_pk_col)
and cols.column_name not in ('YEAR', 'TYPE', 'PERIOD', 'TIME_FK', 'PERIODICITY_ID', 'PERIOD_TYPE_ID')
order by lvl.name,cols.column_name;   --order by clause for bug 3869698

--query modified for bug fix 3826281
--As extra columns were also returned as measure from the previous query
--Added one more condition to filter out those columns
cursor cMeasures (l_schema IN VARCHAR2) IS
select datasets.name, cols.column_name
from
all_tab_columns cols,
bsc_sys_measures measure, bsc_sys_datasets_vl datasets
where cols.table_name = pTableName
and cols.owner = l_schema
and cols.column_name not in ('YEAR', 'TYPE', 'PERIOD', 'TIME_FK', 'PERIODICITY_ID', 'PERIOD_TYPE_ID')
and cols.column_name = upper(measure.measure_col(+))
and measure.measure_id = datasets.measure_id1  (+)
--and clause added for bug 3826281
and datasets.name is not null
and cols.column_name not in
(select cols.column_name
from
all_tab_columns cols,
bsc_sys_dim_levels_vl lvl
where cols.table_name = pTableName
and cols.owner = l_schema
and cols.column_name = upper(lvl.level_pk_col))
order by datasets.name,cols.column_name; --order by clause for bug 3869698

cursor getDimObjName IS
  select Name from bsc_sys_dim_levels_vl where  LEVEL_TABLE_NAME = pTableName
  UNION
  select Name from bsc_sys_dim_levels_vl, bsc_Db_tables_rels r
  where  LEVEL_TABLE_NAME = r.table_name
  and r.source_table_name = pTableName;

cursor getDimObjNameForMN(l_schema IN VARCHAR2) IS
  select lvl.name, cols.column_name
  from all_tab_columns cols,   bsc_sys_dim_levels_vl lvl
  where cols.table_name = pTableName
  and cols.owner = l_schema
  and cols.column_name = upper(lvl.level_pk_col)
  union
  select lvl.name, cols.column_name
  from all_tab_columns cols,
  bsc_sys_dim_levels_vl lvl, bsc_db_tables_rels r
  where r.source_table_name = pTableName
  and cols.table_name = r.TABLE_NAME
  and cols.owner = l_schema
  and cols.column_name = upper(lvl.level_pk_col)
  order by 1,2;

l_column VARCHAR2(30);
l_description VARCHAR2(400);

l_return VARCHAR2(32000) := null;

l_schema VARCHAR2(30) ;

l_ret_clob CLOB;
BEGIN

  IF (pTableName like 'BSC%MV') THEN
    l_schema := bsc_mo_helper_pkg.getAppsSchema;
  ELSE
    l_schema := bsc_mo_helper_pkg.getBSCSchema;
  END IF;

  IF (pTabType <> 2) THEN
    IF (pColType like 'DIM%') THEN
      OPEN cDims(l_schema);
      LOOP
        FETCH cDims INTO l_description, l_column;
        EXIT WHEN cDims%NOTFOUND;
        IF (L_return IS NOT NULL)   THEN
            l_return := l_return || ', ';
        END IF;
        IF (trim(l_description) IS NOT NULL) THEN
            if( (length(l_return)+length(l_description)) <31999) then
              l_return := l_return || l_description;
            else
              IF(l_ret_clob IS NULL) THEN
                WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
              ELSE
                WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
              END IF;
              l_return := l_description;
            end if;
        ELSE
            if( (length(l_return)+length(l_column)) <31999) then
              l_return := l_return || l_column;
            else
              IF(l_ret_clob IS NULL) THEN
                WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
              ELSE
                WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
              END IF;
              l_return := l_column;
            end if;
        END IF;
      END LOOP;
      CLOSE cDims;
    ELSE
      OPEN cMeasures(l_schema);
      LOOP
        FETCH cMeasures INTO l_description, l_column;
        EXIT WHEN cMeasures%NOTFOUND;
        IF (L_return IS NOT NULL)   THEN
            l_return := l_return || ', ';
        END IF;
        IF (trim(l_description) IS NOT NULL) THEN
            if( (length(l_return)+length(l_description)) <31999) then
              l_return := l_return || l_description;
            else
              IF(l_ret_clob IS NULL) THEN
                WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
              ELSE
                WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
              END IF;
              l_return := l_description;
            end if;
        ELSE
            if( (length(l_return)+length(l_column)) <31999) then
              l_return := l_return || l_column;
            else
              IF(l_ret_clob IS NULL) THEN
                WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
              ELSE
                WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
              END IF;
              l_return := l_column;
            end if;
        END IF;
      END LOOP;
      CLOSE cMeasures;
    END IF;
  ELSE
    IF (pColType like 'DIM%') THEN
      OPEN getDimObjName;
      FETCH getDimObjName INTO l_return;
      CLOSE getDimObjName;
      IF (l_return is null) then -- it will be null for MN Dim Tables
        OPEN getDimObjNameForMN(l_schema);
        LOOP
          FETCH getDimObjNameForMN INTO l_description, l_column;
          EXIT WHEN getDimObjNameForMN%NOTFOUND;
          IF (L_return IS NOT NULL)   THEN
            l_return := l_return || ', ';
          END IF;
          IF (trim(l_description) IS NOT NULL) THEN
            if( (length(l_return)+length(l_description)) <31999) then
              l_return := l_return || l_description;
            else
              IF(l_ret_clob IS NULL) THEN
                WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
              ELSE
                WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
              END IF;
              l_return := l_description;
            end if;
          ELSE
            if( (length(l_return)+length(l_column)) <31999) then
              l_return := l_return || l_column;
            else
              IF(l_ret_clob IS NULL) THEN
                WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
              ELSE
                WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
              END IF;
              l_return := l_column;
            end if;
          END IF;
        END LOOP;
        CLOSE getDimObjNameForMN;
      END IF;
    END IF;
 END IF;
 IF(l_return IS NOT NULL) THEN
   IF(l_ret_clob IS NULL) THEN
     WF_NOTIFICATION.NewClob(l_ret_clob, l_return);
   ELSE
     WF_NOTIFICATION.WriteToClob(l_ret_clob,l_return);
   END IF;
 END IF;
 return l_ret_clob;
END;

-- pProcessId = -ICX_Session_Id (For cleanup)
PROCEDURE getRelatedIndicators(
    pKPIList IN VARCHAR2,
    pProcessId IN NUMBER
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_stmt VARCHAR2(1000);
    l_total_kpis NUMBER;
    l_selected_kpis NUMBER;
    l_old_pos NUMBER;
    l_cur_pos NUMBER;
    l_cur_kpi VARCHAR2(32);
    l_error VARCHAR2(400);

BEGIN
    IF LENGTH(pKPIList) <= 0 THEN
        RETURN;
    END IF;

    BSC_METADATA_OPTIMIZER_PKG.g_log := false;
    BSC_METADATA_OPTIMIZER_PKG.gUIAPI := true;
    IF BSC_METADATA_OPTIMIZER_PKG.gBSCSchema IS NULL THEN
        BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
    END IF;

    IF (NOT BSC_MO_HELPER_PKG.tableExists('BSC_TMP_OPT_UI_KPIS')) THEN
        create_ui_kpi_table;
    END IF;
    create_tmp_opt_kpi_data;

    --EXECUTE IMMEDIATE 'DELETE BSC_TMP_OPT_UI_KPIS WHERE PROCESS_ID = -200 OR PROCESS_ID = 0 OR PROCESS_ID IS NULL';
    l_stmt := 'DELETE BSC_TMP_OPT_UI_KPIS WHERE PROCESS_ID = :1 ';
    EXECUTE IMMEDIATE l_stmt USING pProcessId;
    COMMIT;

    BSC_METADATA_OPTIMIZER_PKG.garrIndics.delete;
    BSC_METADATA_OPTIMIZER_PKG.gnumIndics := 0;
    --BSC_METADATA_OPTIMIZER_PKG.garrIndics4.delete;
    --BSC_METADATA_OPTIMIZER_PKG.gnumIndics4 := 0;
    BSC_METADATA_OPTIMIZER_PKG.garrTables.delete;
    BSC_METADATA_OPTIMIZER_PKG.gnumTables := 0;

    l_cur_pos := 1;
    l_old_pos := 1;
    l_selected_kpis := 0;
    WHILE (l_cur_pos > 0) LOOP
        l_selected_kpis := l_selected_kpis + 1;
        l_cur_pos := INSTR(pKPIList, ',', l_old_pos);
        IF l_cur_pos <= 0 THEN
            l_cur_kpi := SUBSTR(pKPIList, l_old_pos);
        ELSE
            l_cur_kpi := SUBSTR(pKPIList, l_old_pos, l_cur_pos-l_old_pos);
        END IF;
        --DBMS_OUTPUT.PUT_LINE(TO_CHAR(l_selected_kpis)||' '||l_cur_kpi);
        IF LENGTH(l_cur_kpi) > 0 THEN
            l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                        SELECT INDICATOR, PROTOTYPE_FLAG, :1
                        FROM BSC_KPIS_B
                        WHERE INDICATOR = :2 ';
            EXECUTE IMMEDIATE l_stmt using pProcessId, l_cur_kpi;
        END IF;
        l_old_pos := l_cur_pos+1;
    END LOOP;

    IF (l_selected_kpis = 0) THEN
        RETURN;
    END IF;
    SELECT COUNT(1) INTO l_total_kpis FROM BSC_KPIS_B;
    IF (l_selected_kpis = l_total_kpis) THEN
        COMMIT;
        RETURN;
    END IF;
    BSC_METADATA_OPTIMIZER_PKG.gnumIndics := l_selected_kpis;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('# of Indics = '||BSC_METADATA_OPTIMIZER_PKG.gnumIndics);
    END IF;

    MarkIndicsAndTables(pProcessId);

    -- take care of shared kpis
    l_stmt := ' INSERT INTO BSC_TMP_OPT_UI_KPIS (indicator, prototype_flag, process_id)
                SELECT k.INDICATOR, k.PROTOTYPE_FLAG, :1
                FROM   BSC_KPIS_VL k,
                       BSC_TMP_OPT_UI_KPIS t
                WHERE ((k.SHARE_FLAG = 2 AND k.SOURCE_INDICATOR = t.INDICATOR)
                OR     (k.SHARE_FLAG = 2 AND k.SOURCE_INDICATOR IN
                        (SELECT I.SOURCE_INDICATOR FROM BSC_KPIS_B I WHERE I.SHARE_FLAG = 2 AND I.INDICATOR = t.INDICATOR))
                OR     (k.SHARE_FLAG = 1 AND k.INDICATOR IN
                        (SELECT I.SOURCE_INDICATOR FROM BSC_KPIS_B I WHERE I.SHARE_FLAG = 2 AND I.INDICATOR = t.INDICATOR)))
                AND t.PROCESS_ID = :2
                AND NOT EXISTS (SELECT 1 FROM BSC_TMP_OPT_UI_KPIS c WHERE c.indicator = k.indicator AND c.PROCESS_ID = :3)';
    EXECUTE IMMEDIATE l_stmt using pProcessId, pProcessId, pProcessId;

    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp( 'Completed getRelatedIndicators');
    END IF;
    COMMIT;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        l_error := sqlerrm;
        BSC_MO_HELPER_PKG.writeTmp('Exception in getRelatedIndicators : '||l_error, FND_LOG.LEVEL_EXCEPTION);
        raise;
END;

PROCEDURE deleteBSCSession(pSession IN NUMBER) IS
BEGIN
    delete bsc_current_sessions where session_id = pSession;
END;

-- Remove entries in BSC_TMP_OPT_UI_KPIS
PROCEDURE cleanUITempTable IS
  l_del_stmt varchar2(2000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp( 'Started cleanUITempTable');
  END IF;

  -- Removed entries for concurrent requests that were finished
  DELETE BSC_TMP_OPT_UI_KPIS
  WHERE  PROCESS_ID > 0
  AND    TO_CHAR(PROCESS_ID) NOT IN (
           SELECT /*+ INDEX(R FND_CONCURRENT_REQUESTS_N6)*/ R.ARGUMENT2
           FROM   FND_CONCURRENT_REQUESTS R, FND_CONCURRENT_PROGRAMS_VL P, FND_APPLICATION A
           WHERE  A.APPLICATION_SHORT_NAME = BSC_MO_HELPER_PKG.getBSCSchema
           AND    A.APPLICATION_ID = P.APPLICATION_ID
           AND    P.APPLICATION_ID = R.PROGRAM_APPLICATION_ID
           AND    P.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
           AND    P.CONCURRENT_PROGRAM_NAME = 'BSC_METADATA_OPTIMIZER'
           AND    R.PHASE_CODE IN ('P','R')
           AND    R.ARGUMENT2 IS NOT NULL);
  COMMIT;

  -- Removed entries for invalid ui sessions
  DELETE BSC_TMP_OPT_UI_KPIS
  WHERE  PROCESS_ID < 0
  AND    PROCESS_ID NOT IN (
           SELECT SESSION_ID*-1
           FROM ICX_SESSIONS
           WHERE (FND_SESSION_MANAGEMENT.CHECK_SESSION(SESSION_ID,NULL,NULL,'N') = 'VALID'));
  COMMIT;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp( 'Completed cleanUITempTable');
  END IF;

EXCEPTION WHEN OTHERS THEN
  BSC_MO_HELPER_PKG.writeTmp('Exception in cleanUITempTable : '||sqlerrm, FND_LOG.LEVEL_EXCEPTION);
  raise;
END;

/*------------------------------------------------------------------------------------------
Procedure checkSystemLock
        This procedure loops through the BSC_TMP_OPT_UI_KPIS table and checks
        for locks for all the Objectives corresponding to the process_id
  <parameters>
        p_all_objectives: 1 = all, 0 = modified or selected
        p_program_id: The program ID
        p_user_id: Application User ID
        p_process_id: The process ID
-------------------------------------------------------------------------------------------*/
Procedure checkSystemLock (
          p_all_objectives  IN            number
         ,p_program_id      IN            number
         ,p_user_id         IN            number
         ,p_process_id      IN            number
         ,x_return_status   OUT NOCOPY    varchar2
         ,x_msg_count       OUT NOCOPY    number
         ,x_msg_data        OUT NOCOPY    varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'checkSystemLock';

    CURSOR c_get_all_objectives(
        c_process_id NUMBER
    ) IS
        SELECT DISTINCT INDICATOR
        FROM   BSC_TMP_OPT_UI_KPIS
        WHERE  PROCESS_ID = c_process_id;

    CURSOR c_get_objectives(
        c_process_id NUMBER
    ) IS
        SELECT DISTINCT INDICATOR
        FROM   BSC_TMP_OPT_UI_KPIS
        WHERE  PROCESS_ID = c_process_id
        AND    PROTOTYPE_FLAG IN (1,2,3,4,-3);

BEGIN
    --DBMS_OUTPUT.PUT_LINE('checkSystemLock');
    SAVEPOINT BSCMOUIPKGCheckSystemLock;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_all_objectives = 1) THEN
        FOR cobj IN c_get_all_objectives(p_process_id) LOOP
            BSC_LOCKS_PUB.CHECK_SYSTEM_LOCK
            (
                p_object_key         => cobj.INDICATOR
               ,p_object_type        => 'OBJECTIVE'
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_cascade_lock_level => '0'
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                ROLLBACK TO BSCMOUIPKGCheckSystemLock;
                EXIT;
            END IF;
        END LOOP;
    ELSE
        FOR cobj IN c_get_objectives(p_process_id) LOOP
            BSC_LOCKS_PUB.CHECK_SYSTEM_LOCK
            (
                p_object_key         => cobj.INDICATOR
               ,p_object_type        => 'OBJECTIVE'
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_cascade_lock_level => '0'
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                ROLLBACK TO BSCMOUIPKGCheckSystemLock;
                EXIT;
            END IF;
        END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCMOUIPKGCheckSystemLock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCMOUIPKGCheckSystemLock;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCMOUIPKGCheckSystemLock;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END checkSystemLock;

/*------------------------------------------------------------------------------------------
Procedure getSystemLock
        This procedure loops through the BSC_TMP_OPT_UI_KPIS table
        and locks all the Objectives corresponding to the process_id
  <parameters>
        p_all_objectives: 1 = all, 0 = modified or selected
        p_program_id: The program ID
        p_query_time: The query time at the start of the process flow
        p_user_id: Application User ID
        p_process_id: The process ID
-------------------------------------------------------------------------------------------*/
Procedure getSystemLock (
          p_all_objectives  IN            number
         ,p_query_time      IN            date
         ,p_program_id      IN            number
         ,p_user_id         IN            number
         ,p_process_id      IN            number
         ,x_return_status   OUT NOCOPY    varchar2
         ,x_msg_count       OUT NOCOPY    number
         ,x_msg_data        OUT NOCOPY    varchar2
) IS

    l_api_name CONSTANT VARCHAR2(30) := 'getSystemLock';

    CURSOR c_get_all_objectives(
        c_process_id NUMBER
    ) IS
        SELECT INDICATOR
        FROM   BSC_TMP_OPT_UI_KPIS
        WHERE  PROCESS_ID = c_process_id;

    CURSOR c_get_objectives(
        c_process_id NUMBER
    ) IS
        SELECT DISTINCT INDICATOR
        FROM   BSC_TMP_OPT_UI_KPIS
        WHERE  PROCESS_ID = c_process_id
        AND    PROTOTYPE_FLAG IN (1,2,3,4,-3);

BEGIN
    --DBMS_OUTPUT.PUT_LINE('getSystemLock');
    SAVEPOINT BSCMOUIPKGGetSystemLock;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_all_objectives = 1) THEN
        FOR cobj IN c_get_all_objectives(p_process_id) LOOP
            BSC_LOCKS_PUB.GET_SYSTEM_LOCK
            (
                p_object_key         => cobj.INDICATOR
               ,p_object_type        => 'OBJECTIVE'
               ,p_lock_type          => 'W'
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_cascade_lock_level => '0'
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                ROLLBACK TO BSCMOUIPKGGetSystemLock;
                EXIT;
            END IF;
        END LOOP;
    ELSE
        FOR cobj IN c_get_objectives(p_process_id) LOOP
            BSC_LOCKS_PUB.GET_SYSTEM_LOCK
            (
                p_object_key         => cobj.INDICATOR
               ,p_object_type        => 'OBJECTIVE'
               ,p_lock_type          => 'W'
               ,p_query_time         => p_query_time
               ,p_program_id         => p_program_id
               ,p_user_id            => p_user_id
               ,p_cascade_lock_level => '0'
               ,x_return_status      => x_return_status
               ,x_msg_count          => x_msg_count
               ,x_msg_data           => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                ROLLBACK TO BSCMOUIPKGGetSystemLock;
                EXIT;
            END IF;
        END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCMOUIPKGGetSystemLock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCMOUIPKGGetSystemLock;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BSCMOUIPKGGetSystemLock;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            SQLERRM
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
END getSystemLock;

END BSC_MO_UI_PKG;

/
