--------------------------------------------------------
--  DDL for Package Body BSC_BIA_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIA_WRAPPER" AS
/* $Header: BSCBIAWB.pls 120.3 2006/04/19 11:46:08 meastmon noship $ */


/*===========================================================================+
| PROCEDURE Analyze_Table
+============================================================================*/
PROCEDURE Analyze_Table(
    p_table_name IN VARCHAR2
) IS
BEGIN
    IF Do_Analyze THEN
        -- Fix perf bug#4583017: pass cascade = false
        FND_STATS.gather_table_stats(
             OWNNAME => BSC_APPS.BSC_APPS_SCHEMA,
             TABNAME => p_table_name,
             CASCADE => FALSE);
    END IF;
END Analyze_Table;


/*===========================================================================+
| FUNCTION Do_Analyze
+============================================================================*/
FUNCTION Do_Analyze RETURN BOOLEAN IS
BEGIN
    RETURN TRUE;
END Do_Analyze;


/*===========================================================================+
| FUNCTION Drop_Rpt_Key_Table
+============================================================================*/
FUNCTION Drop_Rpt_Key_Table(
    p_user_id NUMBER,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_error EXCEPTION;
    h_error_message VARCHAR2(4000) := NULL;

BEGIN

    BSC_BSC_XTD_PKG.drop_rpt_key_table(
        p_user_id => p_user_id,
        p_error_message => h_error_message
    );

    IF h_error_message IS NOT NULL THEN
        x_error_message := h_error_message;
        RAISE e_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_error THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Drop_Rpt_Key_Table;


/*===========================================================================+
| PROCEDURE Drop_Rpt_Key_Table_VB
+============================================================================*/
PROCEDURE Drop_Rpt_Key_Table_VB(
    p_user_id NUMBER
) IS

    e_error EXCEPTION;

    l_error_message     VARCHAR2(2000);

BEGIN

    IF NOT Drop_Rpt_Key_Table(p_user_id, l_error_message) THEN
        RAISE e_error;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => l_error_message,
                        x_source => 'BSC_BIA_WRAPPER.Drop_Rpt_Key_Table_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_BIA_WRAPPER.Drop_Rpt_Key_Table_VB',
                        x_mode => 'I');
        COMMIT;

END Drop_Rpt_Key_Table_VB;


/*===========================================================================+
| FUNCTION Drop_Summary_MV
+============================================================================*/
FUNCTION Drop_Summary_MV(
    p_mv IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_error EXCEPTION;

    l_options       VARCHAR2(32000) := null;
    l_ret       BOOLEAN;

BEGIN

    IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
        l_options := 'DEBUG LOG';
    END IF;

    l_ret := BSC_OLAP_MAIN.drop_summary_mv(
                 p_mv => p_mv,
                 p_option_string => l_options,
                 p_error_message => x_error_message
             );

    IF NOT l_ret THEN
        RAISE e_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_error THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Drop_Summary_MV;


/*===========================================================================+
| PROCEDURE Drop_Summary_MV_VB
+============================================================================*/
PROCEDURE Drop_Summary_MV_VB(
    p_mv IN VARCHAR2
) IS

    e_error EXCEPTION;

    l_error_message     VARCHAR2(2000);

BEGIN

    IF NOT Drop_Summary_MV(p_mv, l_error_message) THEN
        RAISE e_error;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => l_error_message,
                        x_source => 'BSC_BIA_WRAPPER.Drop_Summary_MV_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_BIA_WRAPPER.Drop_Summary_MV_VB',
                        x_mode => 'I');
        COMMIT;

END Drop_Summary_MV_VB;


/*===========================================================================+
| FUNCTION Get_Sum_Table_MV_Name
+============================================================================*/
FUNCTION Get_Sum_Table_MV_Name(
    p_table_name IN VARCHAR2
    ) RETURN VARCHAR2 IS

    h_mv_name VARCHAR2(100) := NULL;
    h_pos NUMBER;

BEGIN

    h_pos := INSTR(p_table_name, '_', -1);
    IF h_pos > 0 THEN
        h_mv_name := SUBSTR(p_table_name, 1, h_pos)||'MV';
    ELSE
        h_mv_name := p_table_name||'_MV';
    END IF;

    RETURN h_mv_name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Sum_Table_MV_Name;


/*===========================================================================+
| FUNCTION Implement_Bsc_MV
+============================================================================*/
FUNCTION Implement_Bsc_MV(
    p_kpi IN NUMBER,
    p_adv_sum_level IN NUMBER,
    p_reset_mv_levels IN BOOLEAN,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_error EXCEPTION;

    l_kpi       VARCHAR2(30);
    l_options   VARCHAR2(32000);
    l_ret       BOOLEAN;

    l_mv_levels VARCHAR2(10);

    l_tablespace_param_tbl VARCHAR2(32000);
    l_tablespace_param_idx VARCHAR2(32000);
    l_storage_param VARCHAR2(32000);
    l_storage_param_tbl VARCHAR2(32000);
    l_storage_param_idx VARCHAR2(32000);

    h_pos NUMBER;
    l_db_version VARCHAR2(30);

BEGIN

    l_kpi := TO_CHAR(p_kpi);

    l_tablespace_param_tbl := 'TABLESPACE='||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_table_tbs_type);
    l_tablespace_param_idx := 'INDEX TABLESPACE='||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_index_tbs_type);

    l_storage_param := BSC_APPS.bsc_storage_clause;
    -- Remove any other hint after ) like INITRANS
    h_pos := INSTR(l_storage_param, ')');
    IF h_pos > 0 THEN
        l_storage_param := SUBSTR(l_storage_param, 1, h_pos);
    END IF;

    l_storage_param_tbl := 'STORAGE='||l_storage_param;
    l_storage_param_idx := 'INDEX STORAGE='||l_storage_param;

    l_db_version := BSC_IM_UTILS.get_db_version;


    IF p_reset_mv_levels THEN
        l_options := 'RESET MV LEVELS';
    ELSE
        l_options := 'RECREATE';
    END IF;

    IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
        l_options := l_options||',DEBUG LOG';
    END IF;

    -- bug 3835059, to support any number of keys and not hang while creating the mv
    l_options:= l_options||',NO ROLLUP='||MAX_ALLOWED_LEVELS;
    l_options:= l_options||',MV LEVELS='||p_adv_sum_level||',SUMMARY VIEWS';
    IF l_db_version = '8i' OR Indicator_Has_Projection(p_kpi) THEN
        l_options := l_options||',FULL REFRESH';
    END IF;
    l_options := l_options||',OUTPUT=NO';
    l_options := l_options||','||
                l_tablespace_param_tbl||','||l_storage_param_tbl||','||
                l_tablespace_param_idx||','||l_storage_param_idx;

    l_ret := BSC_OLAP_MAIN.implement_bsc_mv(
                 p_kpi => l_kpi,
                 p_option_string => l_options,
                 p_error_message => x_error_message
             );

    IF NOT l_ret THEN
        RAISE e_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_error THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Implement_Bsc_MV;


/*===========================================================================+
| FUNCTION Indicator_Has_Projection
+============================================================================*/
FUNCTION Indicator_Has_Projection(
    p_kpi IN NUMBER
) RETURN BOOLEAN IS

    CURSOR c1 (p1 varchar2, p2 varchar2, p3 varchar2, p4 number, p5 number) IS
      SELECT DISTINCT kt.indicator
      FROM bsc_kpi_data_tables kt, bsc_db_tables_cols tc, bsc_db_measure_cols_vl m
      WHERE kt.table_name = tc.table_name AND
            tc.column_type = p1 AND
            NVL(tc.source, p2) = p3 AND
            tc.column_name = m.measure_col AND
            NVL(m.projection_id, p4) <> p5;

BEGIN

   -- Fix bug#5069433 Use bulk collect

   -- SUPPORT_BSC_BIS_MEASURES: Only BSC measures exists in bsc_db_measure_cols_vl and
   -- by design we assumed that BIS measures do not have projection.
   -- I have added the condition on source in bsc_db_tables_cols

    IF g_projection_kpis_set IS NULL OR g_projection_kpis_set = FALSE THEN
        g_projection_kpis.delete;
        OPEN c1('A','BSC','BSC',0,0);
        LOOP
            FETCH c1 BULK COLLECT INTO g_projection_kpis;
            EXIT WHEN c1%NOTFOUND;
        END LOOP;
        CLOSE c1;
        g_projection_kpis_set := TRUE;
    END IF;

    FOR i IN 1..g_projection_kpis.count LOOP
        IF g_projection_kpis(i) = p_kpi THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Indicator_Has_Projection;


/*===========================================================================+
| PROCEDURE Implement_Bsc_MV_VB
+============================================================================*/
PROCEDURE Implement_Bsc_MV_VB(
    p_kpi IN NUMBER,
    p_adv_sum_level IN NUMBER,
    p_reset_mv_levels IN BOOLEAN
) IS

    e_error EXCEPTION;

    l_error_message     VARCHAR2(2000);

BEGIN

    IF NOT Implement_Bsc_MV(p_kpi, p_adv_sum_level, p_reset_mv_levels, l_error_message) THEN
        RAISE e_error;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => l_error_message||'. p_kpi='||p_kpi,
                        x_source => 'BSC_BIA_WRAPPER.Implement_Bsc_MV_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM||'. p_kpi='||p_kpi,
                        x_source => 'BSC_BIA_WRAPPER.Implement_Bsc_MV_VB',
                        x_mode => 'I');
        COMMIT;

END Implement_Bsc_MV_VB;


/*===========================================================================+
| FUNCTION Load_Reporting_Calendar
+============================================================================*/
FUNCTION Load_Reporting_Calendar(
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_error EXCEPTION;
    l_options       VARCHAR2(32000);
    l_ret       BOOLEAN;

BEGIN

    l_options := 'ANALYZE';

    IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
        l_options := l_options||',DEBUG LOG';
    END IF;

    l_ret := BSC_OLAP_MAIN.load_reporting_calendar(
                 p_apps => 'BSC',
                 p_option_string => l_options,
                 p_error_message => x_error_message
             );

    IF NOT l_ret THEN
        RAISE e_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_error THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Load_Reporting_Calendar;


--Fix bug#4027813: Add this function to load reporting calendar for only
-- the specified calendar id
/*===========================================================================+
| FUNCTION Load_Reporting_Calendar
+============================================================================*/
FUNCTION Load_Reporting_Calendar(
    x_calendar_id IN NUMBER,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_error EXCEPTION;
    l_options       VARCHAR2(32000);
    l_ret       BOOLEAN;

BEGIN

    l_options := 'ANALYZE';

    IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
        l_options := l_options||',DEBUG LOG';
    END IF;

    l_ret := BSC_OLAP_MAIN.load_reporting_calendar(
                 p_calendar_id => x_calendar_id,
                 p_apps => 'BSC',
                 p_option_string => l_options,
                 p_error_message => x_error_message
             );

    IF NOT l_ret THEN
        RAISE e_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_error THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Load_Reporting_Calendar;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Load_Reporting_Calendar_AT
+============================================================================*/
FUNCTION Load_Reporting_Calendar_AT(
    x_calendar_id IN NUMBER,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Load_Reporting_Calendar(x_calendar_id, x_error_message);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Load_Reporting_Calendar_AT;


/*===========================================================================+
| PROCEDURE Load_Reporting_Calendar_VB
+============================================================================*/
PROCEDURE Load_Reporting_Calendar_VB IS

    e_error EXCEPTION;

    l_error_message     VARCHAR2(2000);

BEGIN

    IF NOT Load_Reporting_Calendar(l_error_message) THEN
        RAISE e_error;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => l_error_message,
                        x_source => 'BSC_BIA_WRAPPER.Load_Reporting_Calendar_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_BIA_WRAPPER.Load_Reporting_Calendar_VB',
                        x_mode => 'I');
        COMMIT;

END Load_Reporting_Calendar_VB;


/*===========================================================================+
| FUNCTION Refresh_Summary_MV
|
| Convered Dynamic SQL to Static Cursors -- Bug #3236356
+============================================================================*/
FUNCTION Refresh_Summary_MV(
    p_mv IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_error EXCEPTION;

    l_options       VARCHAR2(32000);
    l_ret       BOOLEAN;
    l_kpi       NUMBER;


    l_tablespace_param_idx VARCHAR2(32000);
    l_storage_param VARCHAR2(32000);
    l_storage_param_idx VARCHAR2(32000);
    h_pos NUMBER;

    -- Bug #3236356
    CURSOR c_Kpi_For_MV IS
    SELECT DISTINCT INDICATOR
    FROM   BSC_KPI_DATA_TABLES
    WHERE  MV_NAME = p_mv;

    -- Bug #3236356
    CURSOR c_Kpi_For_SB_MV IS
    SELECT DISTINCT T.INDICATOR
    FROM   BSC_KPI_DATA_TABLES T, BSC_DB_TABLES_RELS R
    WHERE  T.TABLE_NAME    = R.TABLE_NAME
    AND    R.RELATION_TYPE = 1
    AND    BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(SOURCE_TABLE_NAME) = p_mv;

BEGIN

    -- Get the KPI using the given MV

    -- Bug #3236356
    OPEN c_Kpi_For_MV;
    FETCH c_Kpi_For_MV INTO l_kpi;
    IF c_Kpi_For_MV%NOTFOUND THEN
        l_kpi := NULL;
    END IF;
    CLOSE c_Kpi_For_MV;

    IF l_kpi IS NULL THEN
        -- The MV is not used direclty by any Kpi, so it can be a SB MV
        -- Bug #3236356
        OPEN  c_Kpi_For_SB_MV;
        FETCH c_Kpi_For_SB_MV INTO l_kpi;
        IF c_Kpi_For_SB_MV%NOTFOUND THEN
            l_kpi := NULL;
        END IF;
        CLOSE c_Kpi_For_SB_MV;
    END IF;

    IF l_kpi IS NULL THEN
        -- The MV does not have corresponding KPI. So we do not need to refresh that MV.
        RETURN TRUE;
    END IF;

    l_tablespace_param_idx := 'INDEX TABLESPACE='||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_index_tbs_type);

    l_storage_param := BSC_APPS.bsc_storage_clause;
    -- Remove any other hint after ) like INITRANS
    h_pos := INSTR(l_storage_param, ')');
    IF h_pos > 0 THEN
        l_storage_param := SUBSTR(l_storage_param, 1, h_pos);
    END IF;

    l_storage_param_idx := 'INDEX STORAGE='||l_storage_param;

    -- l_options := 'DEBUG LOG';
    IF Do_Analyze THEN
        l_options := 'ANALYZE,';
    END IF;
    l_options := l_options||'DROP INDEX,'||
                 l_tablespace_param_idx||','||l_storage_param_idx;

    IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
        l_options := l_options||',DEBUG LOG';
    END IF;

    l_ret := BSC_OLAP_MAIN.refresh_summary_mv(
                 p_mv => p_mv,
                 p_kpi => TO_CHAR(l_kpi),
                 p_option_string => l_options,
                 p_error_message => x_error_message
             );

    IF NOT l_ret THEN
        RAISE e_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_error THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN

        x_error_message := SQLERRM;
        RETURN FALSE;

END Refresh_Summary_MV;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Refresh_Summary_MV_AT
+============================================================================*/
FUNCTION Refresh_Summary_MV_AT(
    p_mv IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Refresh_Summary_MV(p_mv, x_error_message);
    commit; --all autonomous transaction needs to commit
    RETURN h_b;
END Refresh_Summary_MV_AT;


END BSC_BIA_WRAPPER;

/
