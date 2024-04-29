--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_INC" AS
/* $Header: BSCDINCB.pls 120.6 2007/03/01 14:42:47 ankgoel ship $ */


/*===========================================================================+
| FUNCTION Add_Related_Tables
+============================================================================*/
FUNCTION Add_Related_Tables (
	x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_tables IN NUMBER,
        x_purge_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_purge_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_new_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_new_tables NUMBER;

    h_i NUMBER;
    h_sql VARCHAR2(32700);

    h_table_name VARCHAR2(30);
    h_where_tables VARCHAR2(32700);

BEGIN
    h_num_new_tables := 0;
    h_where_tables := NULL;

    FOR h_i IN 1 .. x_num_tables LOOP
        -- Insert the table
        IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(x_tables(h_i), x_purge_tables, x_num_purge_tables) THEN
            x_num_purge_tables := x_num_purge_tables + 1;
            x_purge_tables(x_num_purge_tables) := x_tables(h_i);
        END IF;
    END LOOP;

    h_where_tables := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'table_name');

    FOR h_i IN 1 .. x_num_tables LOOP
        -- Insert the child tables
        h_sql := 'SELECT table_name';
        h_sql := h_sql||' FROM bsc_db_tables_rels';
        h_sql := h_sql||' WHERE source_table_name = :1';

        OPEN h_cursor FOR h_sql USING x_tables(h_i);
        FETCH h_cursor INTO h_table_name;
        WHILE h_cursor%FOUND LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table_name, x_purge_tables, x_num_purge_tables) THEN
                x_num_purge_tables := x_num_purge_tables + 1;
                x_purge_tables(x_num_purge_tables) := h_table_name;

                h_num_new_tables := h_num_new_tables + 1;
                h_new_tables(h_num_new_tables) := h_table_name;

                BSC_APPS.Add_Value_Big_In_Cond(1, h_table_name);
            END IF;

            FETCH h_cursor INTO h_table_name;
        END LOOP;
        CLOSE h_cursor;

        -- Insert the parent tables
        h_sql := 'SELECT source_table_name';
        h_sql := h_sql||' FROM bsc_db_tables_rels';
        h_sql := h_sql||' WHERE table_name = :1';

        OPEN h_cursor FOR h_sql USING x_tables(h_i);
        FETCH h_cursor INTO h_table_name;
        WHILE h_cursor%FOUND LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table_name, x_purge_tables, x_num_purge_tables) THEN
                x_num_purge_tables := x_num_purge_tables + 1;
                x_purge_tables(x_num_purge_tables) := h_table_name;

                h_num_new_tables := h_num_new_tables + 1;
                h_new_tables(h_num_new_tables) := h_table_name;

                BSC_APPS.Add_Value_Big_In_Cond(1, h_table_name);
            END IF;

            FETCH h_cursor INTO h_table_name;
        END LOOP;
        CLOSE h_cursor;

    END LOOP;

    IF h_num_new_tables > 0 THEN
        -- If one table of one indicator is marked then all tables of that indicator are marked
        h_sql := 'SELECT table_name';
        h_sql := h_sql||' FROM bsc_kpi_data_tables';
        h_sql := h_sql||' WHERE indicator IN (';
        h_sql := h_sql||' SELECT indicator';
        h_sql := h_sql||' FROM bsc_kpi_data_tables';
        h_sql := h_sql||' WHERE '||h_where_tables;
        h_sql := h_sql||' )';
        h_sql := h_sql||' AND NOT ('||h_where_tables||')';
        h_sql := h_sql||' AND table_name IS NOT NULL';

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_table_name;
        WHILE h_cursor%FOUND LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table_name, x_purge_tables, x_num_purge_tables) THEN
                x_num_purge_tables := x_num_purge_tables + 1;
                x_purge_tables(x_num_purge_tables) := h_table_name;

                h_num_new_tables := h_num_new_tables + 1;
                h_new_tables(h_num_new_tables) := h_table_name;
            END IF;

            FETCH h_cursor INTO h_table_name;
        END LOOP;
        CLOSE h_cursor;

        IF NOT Add_Related_Tables(h_new_tables, h_num_new_tables, x_purge_tables, x_num_purge_tables) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_ADD_REL_TABLES_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Add_Related_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Add_Related_Tables');
        RETURN FALSE;

END Add_Related_Tables;


/*===========================================================================+
| FUNCTION Do_Incremental
+============================================================================*/
FUNCTION Do_Incremental RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;
    e_error_load_rpt_cal EXCEPTION;

    h_i NUMBER;

    -- array for update incremental changes
    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;

    h_color_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_color_indicators NUMBER;

    h_current_fy NUMBER;

    h_message VARCHAR2(4000);

    h_changed_calendars BSC_UPDATE_UTIL.t_array_of_number;
    h_num_changed_calendars NUMBER;

    h_calendar_id NUMBER;
    h_error_message VARCHAR2(2000);

BEGIN
    h_num_input_tables := 0;
    h_num_color_indicators := 0;
    h_num_changed_calendars := 0;

    BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_INCR_CHANGES_REVISION'), BSC_UPDATE_LOG.OUTPUT);

    -- Check for Fiscal year changes in all calendars

    -- Initialize the array h_changed_calendars with the code of the calendars
    -- whose fiscal year was changed
    IF NOT Get_Changed_Calendars(h_changed_calendars, h_num_changed_calendars) THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_num_changed_calendars > 0 THEN
        BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_FISCAL_YEAR_CHANGE'), BSC_UPDATE_LOG.OUTPUT);
    END IF;

    FOR h_i IN 1..h_num_changed_calendars LOOP
        h_calendar_id := h_changed_calendars(h_i);

        -- The beginning fiscal year or month was changed. This action invalidates
        -- the current data for indicators using this calnedar.
        -- BSC Loader will delete all current data for affected KPIs and recalculate the
        -- calendar tables.
        BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'CALENDAR_NAME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||' '||
                                      BSC_UPDATE_UTIL.Get_Calendar_Name(h_calendar_id), BSC_UPDATE_LOG.OUTPUT);

        IF BSC_UPDATE_UTIL.Get_Calendar_EDW_Flag(h_calendar_id) = 0 THEN
            -- This is just for BSC Calendars
            --LOCKING: Lock the calendar
            IF NOT BSC_UPDATE_LOCK.Lock_Calendar(h_calendar_id) THEN
                RAISE e_could_not_get_lock;
            END IF;

            -- Fix bug#3822940 We need to validate that this is not a DBI calendar
            IF BSC_UPDATE_UTIL.Get_Calendar_Source(h_calendar_id) = 'BSC' THEN
                BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_CALTABLES_INIT')||
                                          ' ('||BSC_UPDATE_UTIL.Get_Calendar_Name(h_calendar_id)||')', BSC_UPDATE_LOG.OUTPUT);
                --LOCKING: Call the autonomous transaction function
                IF NOT BSC_UPDATE_UTIL.Init_Calendar_Tables_AT(h_calendar_id) THEN
                    RAISE e_unexpected_error;
                END IF;

                BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_CALTABLES_INITIALIZED'), BSC_UPDATE_LOG.OUTPUT);
            END IF;

            -- We need to load reporting calendar and load calendar into aw
            IF BSC_APPS.bsc_mv THEN
                --LOCKING: call the autonomous transaction
                IF NOT BSC_BIA_WRAPPER.Load_Reporting_Calendar_AT(h_calendar_id, h_error_message) THEN
                    RAISE e_error_load_rpt_cal;
                END IF;

                --AW_INTEGRATION: call aw api to import calendars into aw world
                --LOCKING: call the autonomous transaction
                BSC_UPDATE_UTIL.Load_Calendar_Into_AW_AT(h_calendar_id);
            END IF;

            --LOCKING: commit to release the lock
            COMMIT;
        END IF;

        -- Purge the data for all indicators using this calendar
        IF NOT Purge_Data_Indicators_Calendar(h_calendar_id) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Reset FISCAL_CHANGE variable to 0
        --LOCKING: Lock the calendar
        IF NOT BSC_UPDATE_LOCK.Lock_Calendar(h_calendar_id) THEN
            RAISE e_could_not_get_lock;
        END IF;

        UPDATE bsc_sys_calendars_b
        SET fiscal_change = 0
        WHERE calendar_id = h_calendar_id;

        --LOCKING: commit to release the locks
        COMMIT;

        -- Reset the flags for the indicators (flag = 6 or 7) to 0 because now there
        -- is no data to update.
        --LOCKING: lock indicators prototype
        IF NOT BSC_UPDATE_LOCK.Lock_Prototype_Indicators(h_calendar_id) THEN
            RAISE e_could_not_get_lock;
        END IF;

        UPDATE bsc_kpis_b
        SET prototype_flag = 0, last_update_date = SYSDATE
        WHERE prototype_flag IN (6, 7) AND calendar_id = h_calendar_id;

        -- Color By KPI: Mark KPIs for color re-calculation
        -- We need to update KPI Prototype flag since it is a Calendar change.
        -- We would not have done so had it been a Periodicity change.
        UPDATE bsc_kpi_analysis_measures_b
        SET prototype_flag = 7
        WHERE indicator IN (SELECT indicator FROM bsc_kpis_b WHERE calendar_id = h_calendar_id);

        --LOCKING: commit to release the lock
        COMMIT;
    END LOOP;

    -- Check for indicators which need to be recalculated

    --BSC-BIS-DIMENSIONS: If Loader is running in KPI_MODE, we do not want to automatically
    -- refresh all the indicators in prototype 6 or 7. We only refresh the indicators in
    -- g_indicators. We must to do this becasue the base table must be recreated.
    -- This is implemented inside Get_Input_Tables_Incremental, Get_Color_Indics_Incremental
    -- and Reset_Flag_Indicators

    -- Initialize the array h_input_tables with the name of the input tables
    -- of the indicators with flag 6 (non-structural changes)
    IF NOT Get_Input_Tables_Incremental(h_input_tables, h_num_input_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_num_input_tables > 0 THEN
        BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_SUMTAB_RECALC_REQUIRED'),
                                      BSC_UPDATE_LOG.OUTPUT);
        IF NOT BSC_UPDATE.Process_Input_Tables(h_input_tables, h_num_input_tables, 1) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    -- Initialize the array h_color_indicators with the code of the indicators
    -- with flag 7 (re-color)
    IF NOT Get_Color_Indics_Incremental(h_color_indicators, h_num_color_indicators) THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_num_color_indicators > 0 THEN
        -- LOCKING: Lock temp tables for coloring
        IF NOT BSC_UPDATE_LOCK.Lock_Temp_Tables('COLOR') THEN
            RAISE e_could_not_get_lock;
        END IF;

        -- LOCKING: call the autonomous transaction function
        IF NOT BSC_UPDATE_COLOR.Create_Temp_Tab_Tables_AT() THEN
            RAISE e_unexpected_error;
        END IF;

        --LOCKING: Commit to release locks
        COMMIT;

        BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_RECALC_REQUIRED'),
                                      BSC_UPDATE_LOG.OUTPUT);
        FOR h_i IN 1 .. h_num_color_indicators LOOP
            BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_COLOR_CALC')||' '||h_color_indicators(h_i),
                                          BSC_UPDATE_LOG.OUTPUT);

            --LOCKING: Lock indicator color
            IF NOT BSC_UPDATE_LOCK.Lock_Color_Indicator(h_color_indicators(h_i)) THEN
                RAISE e_could_not_get_lock;
            END IF;

            -- LOCKING: Call the autonomous transaction
            IF NOT BSC_UPDATE_COLOR.Color_Indicator_AT(h_color_indicators(h_i)) THEN
                RAISE e_unexpected_error;
            END IF;

            -- LOCKING: Commit to release the locks
            COMMIT;

            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_COLOR_CALC_COMPLETED');
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'INDICATOR', TO_CHAR(h_color_indicators(h_i)));
            BSC_UPDATE_LOG.Write_Line_log(h_message,
                                          BSC_UPDATE_LOG.OUTPUT);


            --LOCKING: Lock the update period of the indicator
            IF NOT BSC_UPDATE_LOCK.Lock_Period_Indicator(h_color_indicators(h_i)) THEN
                RAISE e_could_not_get_lock;
            END IF;

            -- LOCKING: review not commit between this point and the commit to release the locks

            -- Update the name of period of indicator in BSC_KPI_DEFAULTS_TL table
            IF NOT BSC_UPDATE_UTIL.Update_Kpi_Period_Name(h_color_indicators(h_i)) THEN
                RAISE e_unexpected_error;
            END IF;

            -- Update kpi time stamp
            BSC_UPDATE_UTIL.Update_Kpi_Time_Stamp(h_color_indicators(h_i));

            -- Update Tabs time stamp
            BSC_UPDATE_UTIL.Update_Kpi_Tab_Time_Stamp(h_color_indicators(h_i));

            --LOCKING: commit to release locks
            COMMIT;
        END LOOP;

    END IF;

    -- Reset the flags for the indicators (flag = 6 or 7) to 0
    --LOCKING: lock the indicators with prototype flag 6 or 7
    IF NOT BSC_UPDATE_LOCK.Lock_Prototype_Indicators THEN
        RAISE e_could_not_get_lock;
    END IF;

    IF NOT Reset_Flag_Indicators() THEN
        RAISE e_unexpected_error;
    END IF;

    --LOCKING: commit to release locks
    COMMIT;

    BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_INCR_CHANGES_VERIF'), BSC_UPDATE_LOG.OUTPUT);

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_INCR_CHANGE_REV_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Do_Incremental');
        RETURN FALSE;

    --LOCKING
    WHEN e_could_not_get_lock THEN
        BSC_MESSAGE.Add(x_message => 'Loader could not get the required locks to continue.',
                        x_source => 'BSC_UPDATE_INC.Do_Incremental');
        RETURN FALSE;

    WHEN e_error_load_rpt_cal THEN
        BSC_MESSAGE.Add(x_message => 'BSC_BIA_WRAPPER.Load_Reporting_Calendar: '||h_error_message,
                        x_source => 'BSC_UPDATE_INC.Do_Incremental');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Do_Incremental');
        RETURN FALSE;

END Do_Incremental;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Do_Incremental_AT
+============================================================================*/
FUNCTION Do_Incremental_AT RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Do_Incremental;
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Do_Incremental_AT;


/*===========================================================================+
| FUNCTION Get_Changed_Calendars
+============================================================================*/
FUNCTION Get_Changed_Calendars (
	x_changed_calendars IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
        x_num_changed_calendars IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    cursor c_calendars( pFiscalChg number) is
    SELECT calendar_id
    FROM bsc_sys_calendars_b
    WHERE fiscal_change = pFiscalChg ;

    h_calendar NUMBER;

BEGIN
    -- OPEN c_calendars FOR c_calendars_sql USING 1;
    OPEN c_calendars (1);
    FETCH c_calendars INTO h_calendar;
    WHILE c_calendars%FOUND LOOP
        x_num_changed_calendars := x_num_changed_calendars + 1;
        x_changed_calendars(x_num_changed_calendars) := h_calendar;

        FETCH c_calendars INTO h_calendar;
    END LOOP;
    CLOSE c_calendars;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Get_Changed_Calendars');
        RETURN FALSE;

END Get_Changed_Calendars;


/*===========================================================================+
| FUNCTION Get_Color_Indics_Incremental
+============================================================================*/
FUNCTION Get_Color_Indics_Incremental (
	x_color_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
	x_num_color_indicators IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    c_indicators t_cursor;
    h_sql VARCHAR2(32000);

    h_indicator NUMBER;
    h_i NUMBER;
    h_where_indics VARCHAR2(32000);

BEGIN
    -- Insert into the array x_color_indicators the indicators
    -- indicators with prototype flag = 7

    h_sql := 'SELECT DISTINCT indicator ' ||
               'FROM bsc_kpis_b obj ' ||
               'WHERE ( obj.prototype_flag = :1 ' ||
                         'OR ( obj.prototype_flag = :2 AND EXISTS ( ' ||
                                    'SELECT 1 FROM bsc_kpi_analysis_measures_b kpi_meas ' ||
                                      'WHERE kpi_meas.indicator = obj.indicator ' ||
                                      'AND kpi_meas.prototype_flag = :3 ' ||
                                    ')' ||
                             ')' ||
                     ') ';

    --BSC-BIS-DIMENSIONS: If  Loader is running in KPI_MODE only consider indicators
    -- in g_indicators
    IF BSC_UPDATE.g_kpi_mode THEN

        IF BSC_UPDATE.g_num_indicators > 0 THEN

            h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
            FOR h_i IN 1 .. BSC_UPDATE.g_num_indicators LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, BSC_UPDATE.g_indicators(h_i));
            END LOOP;
            h_sql := h_sql||' AND ('||h_where_indics||')';
        END IF;
    END IF;

    OPEN c_indicators FOR h_sql USING 7, 0, 7;
    FETCH c_indicators INTO h_indicator;
    WHILE c_indicators%FOUND LOOP
        x_num_color_indicators := x_num_color_indicators + 1;
        x_color_indicators(x_num_color_indicators) := h_indicator;

        FETCH c_indicators INTO h_indicator;
    END LOOP;
    CLOSE c_indicators;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Get_Color_Indics_Incremental');
        RETURN FALSE;

END Get_Color_Indics_Incremental;


/*===========================================================================+
| FUNCTION Get_Input_Tables
+============================================================================*/
FUNCTION Get_Input_Tables(
	x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER,
	x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_tables IN NUMBER
	) RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    h_i NUMBER;

    h_new_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_new_tables NUMBER;

    h_table VARCHAR2(30);

    TYPE t_cursor IS REF CURSOR;

    cursor c_source_tables(pTableName varchar2) is
    SELECT source_table_name
    FROM bsc_db_tables_rels
     WHERE table_name =  pTableName ;

    h_source_table VARCHAR2(30);

BEGIN
    h_num_new_tables:= 0;

    FOR h_i IN 1 .. x_num_tables LOOP
        h_num_new_tables := 0;

        h_table := x_tables(h_i);
        -- OPEN c_source_tables FOR c_source_tables_sql USING h_table;
        OPEN c_source_tables (h_table);
        FETCH c_source_tables INTO h_source_table;
        IF c_source_tables%NOTFOUND THEN
            -- h_table is a input table => add to x_input_tables
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table, x_input_tables, x_num_input_tables) THEN
                x_num_input_tables := x_num_input_tables + 1;
                x_input_tables(x_num_input_tables) := h_table;
            END IF;
        ELSE
            WHILE c_source_tables%FOUND LOOP
                h_num_new_tables := h_num_new_tables + 1;
                h_new_tables(h_num_new_tables) := h_source_table;

                FETCH c_source_tables INTO h_source_table;
            END LOOP;
        END IF;
        CLOSE c_source_tables;

        IF h_num_new_tables > 0 THEN
            IF NOT Get_Input_Tables(x_input_tables, x_num_input_tables, h_new_tables, h_num_new_tables) THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_ITABLES_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Get_Input_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Get_Input_Tables');
        RETURN FALSE;
END Get_Input_Tables;


/*===========================================================================+
| FUNCTION Get_Input_Tables_Incremental
+============================================================================*/
FUNCTION Get_Input_Tables_Incremental (
	x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    c_tables t_cursor;
    h_sql VARCHAR2(32700);

    h_table VARCHAR2(30);

    h_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_tables NUMBER;

    h_i NUMBER;
    h_where_indics VARCHAR2(32700);

BEGIN
    h_num_tables := 0;

    -- Insert into the local array h_tables the system tables used
    -- by the indicators with prototype flag = 6

    h_sql := 'SELECT DISTINCT t.table_name'||
             ' FROM bsc_kpis_vl k, bsc_kpi_data_tables t'||
             ' WHERE k.indicator = t.indicator AND'||
             ' k.prototype_flag = :1 AND t.table_name IS NOT NULL';

    --BSC-BIS-DIMENSIONS: If  Loader is running in KPI_MODE only consider indicators
    -- in g_indicators
    IF BSC_UPDATE.g_kpi_mode THEN
        IF BSC_UPDATE.g_num_indicators > 0 THEN
            h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'k.indicator');
            FOR h_i IN 1 .. BSC_UPDATE.g_num_indicators LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, BSC_UPDATE.g_indicators(h_i));
            END LOOP;
            h_sql := h_sql||' AND ('||h_where_indics||')';
        END IF;
    END IF;

    OPEN c_tables FOR h_sql USING 6;
    FETCH c_tables INTO h_table;
    WHILE c_tables%FOUND LOOP
        h_num_tables := h_num_tables + 1;
        h_tables(h_num_tables) := h_table;

        FETCH c_tables INTO h_table;
    END LOOP;
    CLOSE c_tables;

    -- Insert into the array x_input_tables the input tables from
    -- where the system tables are originated.
    IF NOT Get_Input_Tables(x_input_tables, x_num_input_tables, h_tables, h_num_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_INCR_ITABLES_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Get_Input_Tables_Incremental');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Get_Input_Tables_Incremental');
        RETURN FALSE;

END Get_Input_Tables_Incremental;


/*===========================================================================+
| FUNCTION Purge_Data_All_Indicators
+============================================================================*/
FUNCTION Purge_Data_All_Indicators RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    h_purge_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_purge_indicators NUMBER;

    TYPE t_cursor IS REF CURSOR;

    cursor c_All_Indicators is
    SELECT indicator
    FROM bsc_kpis_vl;

    h_indicator NUMBER;

BEGIN
    h_num_purge_indicators := 0;

    -- Initialize the array h_purge_indicators with all the indicators
    -- in the system.

    OPEN c_All_Indicators ;
    FETCH c_All_Indicators INTO h_indicator;
    WHILE c_All_Indicators%FOUND LOOP
        h_num_purge_indicators := h_num_purge_indicators + 1;
        h_purge_indicators(h_num_purge_indicators) := h_indicator;

        FETCH c_All_Indicators INTO h_indicator;
    END LOOP;
    CLOSE c_All_Indicators;

    -- Purge the indicators in the array h_purge_indicators
    IF NOT Purge_Indicators_Data(h_purge_indicators, h_num_purge_indicators) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_PURGE_KPIS_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Purge_Data_All_Indicators');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Purge_Data_All_Indicators');
        RETURN FALSE;

END Purge_Data_All_Indicators;


/*===========================================================================+
| FUNCTION Purge_Data_Indicators_Calendar
+============================================================================*/
FUNCTION Purge_Data_Indicators_Calendar(
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_purge_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_purge_indicators NUMBER;

    TYPE t_cursor IS REF CURSOR;

    cursor c_indicators(pCalId number) is
    SELECT indicator
    FROM bsc_kpis_vl
    WHERE calendar_id = pCalId ;

    h_indicator NUMBER;

BEGIN

    h_num_purge_indicators := 0;

    -- Initialize the array h_purge_indicators

    OPEN c_indicators (x_calendar_id);
    FETCH c_indicators INTO h_indicator;
    WHILE c_indicators%FOUND LOOP
        h_num_purge_indicators := h_num_purge_indicators + 1;
        h_purge_indicators(h_num_purge_indicators) := h_indicator;

        FETCH c_indicators INTO h_indicator;
    END LOOP;
    CLOSE c_indicators;

    -- Purge the indicators in the array h_purge_indicators
    IF NOT Purge_Indicators_Data(h_purge_indicators, h_num_purge_indicators) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    --LOCKING
    WHEN e_could_not_get_lock THEN
        BSC_MESSAGE.Add(x_message => 'Loader could not get the required locks to continue.',
                        x_source => 'BSC_UPDATE_INC.Purge_Data_Indicators_Calendar');
        RETURN FALSE;

    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_PURGE_KPIS_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Purge_Data_Indicators_Calendar');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Purge_Data_Indicators_Calendar');
        RETURN FALSE;

END Purge_Data_Indicators_Calendar;


/*===========================================================================+
| FUNCTION Purge_Indicators_Data
+============================================================================*/
FUNCTION Purge_Indicators_Data (
	x_purge_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_purge_indicators IN NUMBER
	) RETURN BOOLEAN IS
e_unexpected_error EXCEPTION;
 Begin
  return Purge_Indicators_Data(x_purge_indicators,x_num_purge_indicators,'N');
EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_PURGE_KPIS_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Purge_Indicators_Data');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Purge_Indicators_Data');
        RETURN FALSE;

END Purge_Indicators_Data;

FUNCTION Purge_Indicators_Data (
	x_purge_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_purge_indicators IN NUMBER,
        x_keep_input_data varchar2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_purge_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_purge_tables NUMBER;

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_where_indics VARCHAR2(32700);
    h_where_tables VARCHAR2(32700);
    h_sql VARCHAR2(32700);

    h_i NUMBER;
    h_table_name VARCHAR2(30);
    h_indicator NUMBER;

    h_current_fy NUMBER;
    h_message VARCHAR2(4000);

    h_calendar_id NUMBER;
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    h_where_tables_mv VARCHAR2(32700);
    h_base_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_base_tables NUMBER;

    --AW_INTEGRATION: New variables
    h_aw_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_aw_indicators NUMBER;
    h_aw_table_name VARCHAR2(30);

    --LOCKING: new variables
    h_lock_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_lock_indicators NUMBER;

    -- ENH_B_TABLES_PERF: new variable
    h_proj_tbl_name VARCHAR2(30);

BEGIN
    h_num_purge_tables := 0;
    h_num_system_tables := 0;
    h_where_indics := NULL;
    h_where_tables := NULL;
    h_sql := NULL;
    l_num_bind_vars := 0;
    h_where_tables_mv := NULL;
    h_num_base_tables := 0;
    --AW_INTEGRATION: init this variable
    h_num_aw_indicators := 0;
    --LOCKING
    h_num_lock_indicators := 0;

    -- Initialize the array h_system_tables with the tables used for the
    -- indicators in x_purge_indicators
    IF x_num_purge_indicators > 0 THEN
        h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
        FOR h_i IN 1 .. x_num_purge_indicators LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, x_purge_indicators(h_i));

            --AW_INTEGRATION: We need to truncate the cubes of the Aw indicators.
            --I am going to add aw kpis in the array h_aw_indicators to be truncated later.
            IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(x_purge_indicators(h_i)) = 2 THEN
                h_num_aw_indicators := h_num_aw_indicators + 1;
                h_aw_indicators(h_num_aw_indicators) := x_purge_indicators(h_i);
            END IF;

            --LOCKING: Add kpis to array h_lock_indicators. Later I need to lock the
            -- period of those indicators
            h_num_lock_indicators := h_num_lock_indicators + 1;
            h_lock_indicators(h_num_lock_indicators) := x_purge_indicators(h_i);
        END LOOP;

        h_sql := 'SELECT DISTINCT table_name';
        h_sql := h_sql||' FROM bsc_kpi_data_tables';
        h_sql := h_sql||' WHERE ('||h_where_indics||') AND table_name IS NOT NULL';

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_table_name;
        WHILE h_cursor%FOUND LOOP
            h_num_system_tables := h_num_system_tables + 1;
            h_system_tables(h_num_system_tables) := h_table_name;

            FETCH h_cursor INTO h_table_name;
        END LOOP;
        CLOSE h_cursor;

    END IF;

    IF h_num_system_tables > 0 Then
        -- Insert in the array h_purge_tables all the tables in the current graph that have
        -- any relation with the system tables in the array h_system_tables.

        IF NOT Add_Related_Tables(h_system_tables, h_num_system_tables, h_purge_tables, h_num_purge_tables) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Build the condition string on the tables names to purge
        h_where_tables := BSC_APPS.Get_New_Big_In_Cond_Varchar2(2, 'table_name');
        FOR h_i IN 1 .. h_num_purge_tables LOOP
            BSC_APPS.Add_Value_Big_In_Cond(2, h_purge_tables(h_i));
        END LOOP;

        BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_KPIDATA_DELETION'), BSC_UPDATE_LOG.OUTPUT);

        FOR h_i IN 1 .. x_num_purge_indicators LOOP
            BSC_UPDATE_LOG.Write_Line_log(x_purge_indicators(h_i), BSC_UPDATE_LOG.OUTPUT);
        END LOOP;

        -- Add to the condition string of the indicators the interrelated
        -- indicators
        h_sql := 'SELECT DISTINCT indicator';
        h_sql := h_sql||' FROM bsc_kpi_data_tables';
        h_sql := h_sql||' WHERE ('||h_where_tables||')';
        h_sql := h_sql||' AND NOT ('||h_where_indics||')';

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_indicator;
        WHILE h_cursor%FOUND LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, h_indicator);

            BSC_UPDATE_LOG.Write_Line_log(h_indicator, BSC_UPDATE_LOG.OUTPUT);

            --AW_INTEGRATION: We need to truncate the cubes of the Aw indicators.
            --I am going to add aw kpis in the array h_aw_indicators to be truncated later.
            IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(h_indicator) = 2 THEN
                IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_indicator, h_aw_indicators, h_num_aw_indicators) THEN
                    h_num_aw_indicators := h_num_aw_indicators + 1;
                    h_aw_indicators(h_num_aw_indicators) := h_indicator;
                END IF;
            END IF;

            --LOCKING: Add kpis to array h_lock_indicators. Later I need to lock the
            -- period of those indicators
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_indicator, h_lock_indicators, h_num_lock_indicators) THEN
                h_num_lock_indicators := h_num_lock_indicators + 1;
                h_lock_indicators(h_num_lock_indicators) := h_indicator;
            END IF;

            FETCH h_cursor INTO h_indicator;
        END LOOP;
        CLOSE h_cursor;

        -- Delete the tables
        -- BSC-MV Note: For new architecture we need to truncate only the base tables
        -- and summary tables created for projections at kpi level.
        -- By design those tables has generation_type <> -1
        -- Then we need to refresh all the MVs affected by those base tables to delete the data.
        -- AW_INTEGRATION: no changes to this portion of code, same logic applies to AW
        IF BSC_APPS.bsc_mv THEN
            h_where_tables_mv := BSC_APPS.Get_New_Big_In_Cond_Varchar2(3, 'r.table_name');
        END IF;

        FOR h_i IN 1 .. h_num_purge_tables LOOP
            IF BSC_APPS.bsc_mv THEN
                -- BSC-MV Architecture

                IF BSC_UPDATE_UTIL.Get_Table_Generation_Type(h_purge_tables(h_i)) <> -1 THEN
                    -- It is an input, base table or a table created to store the projection at kpi level

                    --added for 5.2  when launched from RSG, we should not truncate the input tables
                    --input tables will be populated first. then rsg called. for initial load, rsg will call
                    --purge. then immediately, it will call load. if we truncate input table, there are no rows
                    --to process

                    IF x_keep_input_data='Y' THEN
                        IF BSC_UPDATE_UTIL.Get_Table_Type(h_purge_tables(h_i)) <> 0 THEN
                            -- It is not an input table, we can truncate it.

                            --LOCKING: Lock the table
                            IF NOT BSC_UPDATE_LOCK.Lock_Table(h_purge_tables(h_i)) THEN
                                RAISE e_could_not_get_lock;
                            END IF;

                            --LOCKING: Call the autonomous transaction function
                            BSC_UPDATE_UTIL.Truncate_Table_AT(h_purge_tables(h_i));

                            -- ENH_B_TABLES_PERF: with the new strategy the B table may have a projection table
                            -- We need to truncate the projection table too.
                            h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_purge_tables(h_i));
                            IF h_proj_tbl_name IS NOT NULL THEN
                                BSC_UPDATE_UTIL.Truncate_Table_AT(h_proj_tbl_name);
                            END IF;

                            --LOCKING: commit to release locks
                            COMMIT;

                            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_DELETION');
                            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_purge_tables(h_i));
                            BSC_UPDATE_LOG.Write_Line_log(h_message, BSC_UPDATE_LOG.OUTPUT);

                            BSC_APPS.Add_Value_Big_In_Cond(3, h_purge_tables(h_i));
                        END IF;
                    ELSE
                        -- We can truncate the table no matter if it is an input table

                        --LOCKING: Lock the table
                        IF NOT BSC_UPDATE_LOCK.Lock_Table(h_purge_tables(h_i)) THEN
                             RAISE e_could_not_get_lock;
                        END IF;

                        --LOCKING: Call the autonomous transaction function
                        BSC_UPDATE_UTIL.Truncate_Table_AT(h_purge_tables(h_i));

                        -- ENH_B_TABLES_PERF: with the new strategy the B table may have a projection table
                        -- We need to truncate the projection table too.
                        h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_purge_tables(h_i));
                        IF h_proj_tbl_name IS NOT NULL THEN
                            BSC_UPDATE_UTIL.Truncate_Table_AT(h_proj_tbl_name);
                        END IF;

                        --LOCKING: commit to release locks
                        COMMIT;

                        h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_DELETION');
                        h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_purge_tables(h_i));
                        BSC_UPDATE_LOG.Write_Line_log(h_message, BSC_UPDATE_LOG.OUTPUT);

                        BSC_APPS.Add_Value_Big_In_Cond(3, h_purge_tables(h_i));
                    END IF;
                END IF;
            ELSE
                -- Summary tables architecture

                --added for 5.2  when launched from RSG, we should not truncate the input tables
                --input tables will be populated first. then rsg called. for initial load, rsg will call
                --purge. then immediately, it will call load. if we truncate input table, there are no rows
                --to process

                IF x_keep_input_data='Y' THEN
                    IF BSC_UPDATE_UTIL.Get_Table_Type(h_purge_tables(h_i)) <> 0 THEN
                        -- It is not an input table, we can truncate it.

                        --LOCKING: Lock the table
                        IF NOT BSC_UPDATE_LOCK.Lock_Table(h_purge_tables(h_i)) THEN
                             RAISE e_could_not_get_lock;
                        END IF;

                        --LOCKING: Call the autonomous transaction function
                        BSC_UPDATE_UTIL.Truncate_Table_AT(h_purge_tables(h_i));

                        -- ENH_B_TABLES_PERF: with the new strategy the B table may have a projection table
                        -- We need to truncate the projection table too.
                        h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_purge_tables(h_i));
                        IF h_proj_tbl_name IS NOT NULL THEN
                            BSC_UPDATE_UTIL.Truncate_Table_AT(h_proj_tbl_name);
                        END IF;

                        --LOCKING: commit to release locks
                        COMMIT;

                        h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_DELETION');
                        h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_purge_tables(h_i));
                       BSC_UPDATE_LOG.Write_Line_log(h_message, BSC_UPDATE_LOG.OUTPUT);
                    END IF;
                ELSE
                    -- We can truncate all tables no matter if it is an input table
                    --LOCKING: Lock the table
                    IF NOT BSC_UPDATE_LOCK.Lock_Table(h_purge_tables(h_i)) THEN
                         RAISE e_could_not_get_lock;
                    END IF;

                    --LOCKING: Call the autonomous transaction function
                    BSC_UPDATE_UTIL.Truncate_Table_AT(h_purge_tables(h_i));

                    -- ENH_B_TABLES_PERF: with the new strategy the B table may have a projection table
                    -- We need to truncate the projection table too.
                    h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_purge_tables(h_i));
                    IF h_proj_tbl_name IS NOT NULL THEN
                        BSC_UPDATE_UTIL.Truncate_Table_AT(h_proj_tbl_name);
                    END IF;

                    --LOCKING: commit to release locks
                    COMMIT;

                    h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_DELETION');
                    h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_purge_tables(h_i));
                    BSC_UPDATE_LOG.Write_Line_log(h_message, BSC_UPDATE_LOG.OUTPUT);
                END IF;
            END IF;
        END LOOP;

        -- BSC-MV Note: Refresh all MVs affected by the base tables
        -- AW_INTEGRATION: For Aw kpis, we need to truncate the AW table created for the base table
        -- and also we need to tuncate the kpi cubes.
        IF BSC_APPS.bsc_mv THEN
            -- Get the base tables
            h_sql := 'SELECT r.table_name'||
                     ' FROM bsc_db_tables_rels r, bsc_db_tables t'||
                     ' WHERE r.source_table_name = t.table_name AND'||
                     ' t.table_type = :1 AND ('||h_where_tables_mv||')';
            OPEN h_cursor FOR h_sql USING 0;
            LOOP
                FETCH h_cursor INTO h_table_name;
                EXIT WHEN h_cursor%NOTFOUND;

                IF BSC_UPDATE_UTIL.Is_Table_For_AW_Kpi(h_table_name) THEN
                    -- Base table for AW indicators

                    -- Fix bug#4567847: there is no aw table created for the base table any more.
                    NULL;
                ELSE
                    -- Base table for MV indicators
                    h_num_base_tables := h_num_base_tables + 1;
                    h_base_tables(h_num_base_tables) := h_table_name;
                END IF;
            END LOOP;
            CLOSE h_cursor;

            -- Refresh Mvs
            IF h_num_base_tables > 0 THEN
                IF NOT BSC_UPDATE.Refresh_System_MVs(h_base_tables, h_num_base_tables) THEN
                    RAISE e_unexpected_error;
                END IF;
            END IF;

            -- AW_INTEGRATION: Truncate kpis cubes
            FOR h_i IN 1..h_num_aw_indicators LOOP
                --LOCKING: lock the aw cubes of the indicator
                IF NOT BSC_UPDATE_LOCK.Lock_AW_Indicator_Cubes(h_aw_indicators(h_i)) THEN
                    RAISE e_could_not_get_lock;
                END IF;

                --LOCKING: call the autonomous transaction procedure
                Purge_AW_Indicator_AT(h_aw_indicators(h_i));

                --LOCKING: commit to release the locks
                COMMIT;
            END LOOP;
        END IF;

        -- Reset to gray the color of the indicators
        --LOCKING: Lock the color of the indicators
        IF NOT BSC_UPDATE_LOCK.Lock_Color_Indicators(h_lock_indicators, h_num_lock_indicators) THEN
            RAISE e_could_not_get_lock;
        END IF;

        h_sql := 'UPDATE bsc_sys_kpi_colors';
        h_sql := h_sql||' SET kpi_color = :1,';
        h_sql := h_sql||' actual_data = NULL,';
        h_sql := h_sql||' budget_data = NULL';
        h_sql := h_sql||' WHERE ('||h_where_indics||')';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := BSC_UPDATE_COLOR.GRAY;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);

        h_sql := 'UPDATE bsc_sys_objective_colors';
        h_sql := h_sql||' SET obj_color = :1 ';
        h_sql := h_sql||' WHERE ('||h_where_indics||')';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := BSC_UPDATE_COLOR.GRAY;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);


        --LOCKING: commit to release the locks
        COMMIT;

        -- Reset some information by calendar
        --LOCKING: Lock the tables. We are going to udate the current period of
        -- all the tables and we need to prevent loader is processing those tables at the same time
        IF NOT BSC_UPDATE_LOCK.Lock_Tables(h_purge_tables, h_num_purge_tables) THEN
            RAISE e_could_not_get_lock;
        END IF;

        --LOCKING: Lock the update period of the indicators. We are going to upadte the current period
        -- of all the affected indicators
        IF NOT BSC_UPDATE_LOCK.Lock_Period_Indicators(h_lock_indicators, h_num_lock_indicators) THEN
            RAISE e_could_not_get_lock;
        END IF;

        -- LOCKING: review not commit between this point and the commit to release the locks

        h_sql := 'SELECT DISTINCT calendar_id'||
                 ' FROM bsc_kpis_b'||
                 ' WHERE ('||h_where_indics||')';

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_calendar_id;
        WHILE h_cursor%FOUND LOOP
            -- Get the current fiscal year
            h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

            -- Reset the current period of the tables
            h_sql := 'UPDATE'||
                     '    bsc_db_tables '||
                     'SET '||
                     '    current_period = :1, '||
                     '    current_subperiod = 0 '||
                     'WHERE '||
                     '    table_type <> 2 AND '||
                     '    periodicity_id IN ('||
                     '        SELECT '||
                     '            periodicity_id '||
                     '        FROM '||
                     '            bsc_sys_periodicities_vl'||
                     '        WHERE '||
                     '            calendar_id = :2 AND '||
                     '            yearly_flag = 1) AND '||
                     '    ('||h_where_tables||')';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := h_current_fy;
            l_bind_vars_values(2) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);

            h_sql := 'UPDATE'||
                     '    bsc_db_tables '||
                     'SET '||
                     '    current_period = 1, '||
                     '    current_subperiod = 0 '||
                     'WHERE '||
                     '    table_type <> 2 AND '||
                     '    periodicity_id IN ('||
                     '        SELECT '||
                     '            periodicity_id '||
                     '        FROM '||
                     '            bsc_sys_periodicities_vl'||
                     '        WHERE '||
                     '            calendar_id = :1 AND '||
                     '            yearly_flag = 0) AND '||
                     '    ('||h_where_tables||')';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);

            -- Reset the current period of the indicators
            h_sql := 'UPDATE '||
                     '    bsc_kpi_periodicities '||
                     'SET '||
                     '    current_period = :1 '||
                     'WHERE '||
                     '    periodicity_id IN ('||
                     '        SELECT '||
                     '            periodicity_id '||
                     '        FROM '||
                     '            bsc_sys_periodicities_vl'||
                     '        WHERE '||
                     '            calendar_id = :2 AND '||
                     '            yearly_flag = 1) AND '||
                     '    ('||h_where_indics||')';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := h_current_fy;
            l_bind_vars_values(2) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);

            h_sql := 'UPDATE '||
                     '    bsc_kpi_periodicities '||
                     'SET '||
                     '    current_period = 1 '||
                     'WHERE '||
                     '    periodicity_id IN ('||
                     '        SELECT '||
                     '            periodicity_id '||
                     '        FROM '||
                     '            bsc_sys_periodicities_vl'||
                     '        WHERE '||
                     '            calendar_id = :1 AND '||
                     '            yearly_flag = 0) AND '||
                     '    ('||h_where_indics||')';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);

            FETCH h_cursor INTO h_calendar_id;
        END LOOP;
        CLOSE h_cursor;

        -- Update the name of period of indicators in BSC_KPI_DEFAULTS_TL table
        FOR h_i IN 1 .. x_num_purge_indicators LOOP
            --LOCKING: there is not commit inside this function, so no need to call
            -- an autonomous transaction
            IF NOT BSC_UPDATE_UTIL.Update_Kpi_Period_Name(x_purge_indicators(h_i)) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;

        -- Update date of indicators
        h_sql := 'UPDATE bsc_kpi_defaults_b SET last_update_date = SYSDATE';
        h_sql := h_sql||' WHERE ('||h_where_indics||')';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

        -- Update Kpis time stamp
        BSC_UPDATE_UTIL.Update_Kpi_Time_Stamp(h_where_indics);

        -- Update Tabs time stamp
        BSC_UPDATE_UTIL.Update_Kpi_Tab_Time_Stamp(h_where_indics);

        -- LOCKING: commit to release the locks
        COMMIT;
    END IF;

    RETURN TRUE;

EXCEPTION
    --LOCKING
    WHEN e_could_not_get_lock THEN
        BSC_MESSAGE.Add(x_message => 'Loader could not get the required locks to continue.',
                        x_source => 'BSC_UPDATE_INC.Purge_Indicators_Data');
        RETURN FALSE;

    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_PURGE_KPIS_FAILED'),
                        x_source => 'BSC_UPDATE_INC.Purge_Indicators_Data');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Purge_Indicators_Data');
        RETURN FALSE;

END Purge_Indicators_Data;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Purge_Indicators_Data_AT
+============================================================================*/
FUNCTION Purge_Indicators_Data_AT (
	x_purge_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_purge_indicators IN NUMBER,
        x_keep_input_data varchar2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Purge_Indicators_Data(x_purge_indicators, x_num_purge_indicators, x_keep_input_data);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Purge_Indicators_Data_AT;


/*===========================================================================+
| FUNCTION Reset_Flag_Indicators
+============================================================================*/
FUNCTION Reset_Flag_Indicators
RETURN BOOLEAN
IS
  h_sql          VARCHAR2(32000);
  h_sql_kpi      VARCHAR2(32000);
  h_where_indics VARCHAR2(32000);
  h_i            NUMBER;
BEGIN
    IF (BSC_UPDATE.g_kpi_mode) AND (BSC_UPDATE.g_num_indicators > 0) THEN
        h_sql := 'UPDATE bsc_kpis_b'||
                 ' SET prototype_flag = 0, last_update_date = SYSDATE'||
                 ' WHERE prototype_flag IN (6, 7)';

        -- Color By KPI: Mark KPIs for color re-calculation
        h_sql_kpi := 'UPDATE bsc_kpi_analysis_measures_b ' ||
		     ' SET prototype_flag = 0 ' ||
                     ' WHERE prototype_flag = 7 ';

        h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
        FOR h_i IN 1 .. BSC_UPDATE.g_num_indicators LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, BSC_UPDATE.g_indicators(h_i));
        END LOOP;
        h_sql := h_sql || ' AND (' || h_where_indics || ')';
        h_sql_kpi := h_sql_kpi || ' AND (' || h_where_indics || ')';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql_kpi);
    ELSE
        UPDATE bsc_kpis_b
          SET prototype_flag = 0, last_update_date = SYSDATE
          WHERE prototype_flag IN (6, 7);

        -- Color By KPI: Mark KPIs for color re-calculation
        UPDATE bsc_kpi_analysis_measures_b
	  SET prototype_flag = 0
          WHERE prototype_flag = 7;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_INC.Reset_Flag_Indicators');
        RETURN FALSE;
END Reset_Flag_Indicators;


--LOCKING: new procedure
/*===========================================================================+
| PROCEDURE Purge_AW_Indicator_AT
+============================================================================*/
PROCEDURE Purge_AW_Indicator_AT (
    x_indicator IN NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    bsc_aw_load.purge_kpi(
        p_kpi => x_indicator,
        p_options => 'DEBUG LOG'
    );
    commit; -- autonomous transactions need to commit
END Purge_AW_Indicator_AT;

END BSC_UPDATE_INC;

/
