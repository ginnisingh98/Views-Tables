--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_LOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_LOCK" AS
/* $Header: BSCDLCKB.pls 120.2 2005/08/05 09:40:29 meastmon noship $ */


/*===========================================================================+
|  FUNCTION  Lock_AW_Indicator_Cubes
+============================================================================*/
FUNCTION Lock_AW_Indicator_Cubes(
    x_indicator IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_indicator;
    h_object_types(h_num_objects) := 'AW_INDICATOR_CUBES';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_AW_Indicator_Cubes;


/*===========================================================================+
|  FUNCTION Lock_Calendar
+============================================================================*/
FUNCTION Lock_Calendar (
    x_calendar_id IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_periodicities IS
        SELECT periodicity_id
        FROM bsc_sys_periodicities
        WHERE calendar_id = x_calendar_id;

    h_periodicity_id NUMBER;

BEGIN
    h_num_objects := 0;

    -- Lock Calendar
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_calendar_id;
    h_object_types(h_num_objects) := 'CALENDAR';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Lock all the periodicities of this calendar
    OPEN c_periodicities;
    LOOP
        FETCH c_periodicities INTO h_periodicity_id;
        EXIT WHEN c_periodicities%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_periodicity_id;
        h_object_types(h_num_objects) := 'PERIODICITY';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_periodicities;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Calendar;


/*===========================================================================+
|  FUNCTION Lock_Calendar_Change
+============================================================================*/
FUNCTION Lock_Calendar_Change (
    x_calendar_id IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_periodicities IS
        SELECT periodicity_id
        FROM bsc_sys_periodicities
        WHERE calendar_id = x_calendar_id;

    h_periodicity_id NUMBER;

    CURSOR c_indics IS
        SELECT indicator
        FROM bsc_kpis_b
        WHERE calendar_id = x_calendar_id;

    h_indicator NUMBER;

    CURSOR c_tables IS
        SELECT table_name
        FROM bsc_db_tables
        WHERE periodicity_id IN (
            SELECT periodicity_id
            FROM bsc_sys_periodicities
            WHERE calendar_id = x_calendar_id
         );

    h_table_name VARCHAR2(50);

BEGIN
    h_num_objects := 0;

    -- Lock Calendar
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_calendar_id;
    h_object_types(h_num_objects) := 'CALENDAR';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Lock all the periodicities of this calendar
    OPEN c_periodicities;
    LOOP
        FETCH c_periodicities INTO h_periodicity_id;
        EXIT WHEN c_periodicities%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_periodicity_id;
        h_object_types(h_num_objects) := 'PERIODICITY';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_periodicities;

    --Lock the indicator period and indicator color of the indicators using this calendar
    OPEN c_indics;
    LOOP
        FETCH c_indics INTO h_indicator;
        EXIT WHEN c_indics%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_indicator;
        h_object_types(h_num_objects) := 'INDICATOR_PERIOD';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_indicator;
        h_object_types(h_num_objects) := 'INDICATOR_COLOR';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_indics;

    --Lock the tables using this calendar
    OPEN c_tables;
    LOOP
        FETCH c_tables INTO h_table_name;
        EXIT WHEN c_tables%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_table_name;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_tables;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Calendar_Change;


/*===========================================================================+
|  FUNCTION Lock_Color_Indicator
+============================================================================*/
FUNCTION Lock_Color_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_sum_tables IS
        select distinct table_name
        from bsc_kpi_data_tables
        where indicator = x_indicator and table_name is not null;

    h_table_name VARCHAR2(50);

BEGIN
    h_num_objects := 0;

    -- Lock the color of the indicator
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_indicator;
    h_object_types(h_num_objects) := 'INDICATOR_COLOR';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Lock in READ mode the indicators summary tables
    -- Remember the when we are refreshing MVs we are locking the summary tables not the MVs
    -- If the indicator is implemented in AW we need to lock the AW cubes of the indicator
    IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(x_indicator) = 2 THEN
        --AW indicator
        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := x_indicator;
        h_object_types(h_num_objects) := 'AW_INDICATOR_CUBES';
        h_lock_types(h_num_objects) := 'R';
        h_cascade_levels(h_num_objects) := 0;
    END IF;

    OPEN c_sum_tables;
    LOOP
        FETCH c_sum_tables INTO h_table_name;
        EXIT WHEN c_sum_tables%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_table_name;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'R';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_sum_tables;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Color_Indicator;


/*===========================================================================+
|  FUNCTION Lock_Color_Indicators
+============================================================================*/
FUNCTION Lock_Color_Indicators(
    x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_indicators IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    FOR h_i IN 1..x_num_indicators LOOP
        -- Lock the table
        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := x_indicators(h_i);
        h_object_types(h_num_objects) := 'INDICATOR_COLOR';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Color_Indicators;


/*===========================================================================+
|  FUNCTION Lock_DBI_Dimension
+============================================================================*/
FUNCTION Lock_DBI_Dimension(
    x_dim_short_name IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_dim_level_id IS
        SELECT dim_level_id
        FROM bsc_sys_dim_levels_b
        WHERE short_name = x_dim_short_name;

    h_dim_level_id VARCHAR2(50);

BEGIN
    h_num_objects := 0;

    OPEN c_dim_level_id;
    FETCH c_dim_level_id INTO h_dim_level_id;
    IF c_dim_level_id%NOTFOUND THEN
        CLOSE c_dim_level_id;
        RETURN FALSE;
    END IF;
    CLOSE c_dim_level_id;

    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := h_dim_level_id;
    h_object_types(h_num_objects) := 'DIMENSION_OBJECT';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_DBI_Dimension;


/*===========================================================================+
|  FUNCTION Lock_Import_Dbi_Plans
+============================================================================*/
FUNCTION Lock_Import_Dbi_Plans RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    -- Lock BSC_SYS_BENCHMARKS
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := 'BSC_SYS_BENCHMARKS';
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Import_Dbi_Plans;


/*===========================================================================+
|  FUNCTION Lock_Import_ITable
+============================================================================*/
FUNCTION Lock_Import_ITable(
    x_input_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    -- Lock the input table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_input_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Import_ITable;


/*===========================================================================+
|  FUNCTION Lock_Incremental_Indicators
+============================================================================*/
FUNCTION Lock_Incremental_Indicators RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;
    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;

    CURSOR c_mod_cal_kpis IS
        select distinct indicator
        from bsc_kpis_vl
        where calendar_id in (
            select calendar_id
            from bsc_sys_calendars_b
            where fiscal_change = 1
        );

    h_indicator NUMBER;

    TYPE t_cursor IS REF CURSOR;
    c_indicators t_cursor;
    h_sql VARCHAR2(32000);
    h_where_indics VARCHAR2(32000);

BEGIN
    h_num_objects := 0;
    h_num_indicators := 0;
    h_num_input_tables := 0;

    -- Lock indicators using modified calendars with fiscal change =1
    OPEN c_mod_cal_kpis;
    LOOP
        FETCH c_mod_cal_kpis INTO h_indicator;
        EXIT WHEN c_mod_cal_kpis%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_indicator;
        h_object_types(h_num_objects) := 'OBJECTIVE';
        h_lock_types(h_num_objects) := 'R';
        h_cascade_levels(h_num_objects) := -1;
    END LOOP;
    CLOSE c_mod_cal_kpis;

    -- Lock indicators with prototype flag 6 or 7
    -- If Loader is running only for some specific indicators then we need to lock
    -- only those indicators
    h_sql := 'SELECT DISTINCT indicator'||
             ' FROM bsc_kpis_vl'||
             ' WHERE prototype_flag IN (6,7)';
    IF BSC_UPDATE.g_kpi_mode THEN
        IF BSC_UPDATE.g_num_indicators > 0 THEN
            h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
            FOR h_i IN 1..BSC_UPDATE.g_num_indicators LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, BSC_UPDATE.g_indicators(h_i));
            END LOOP;
            h_sql := h_sql||' AND ('||h_where_indics||')';
        END IF;
    END IF;

    OPEN c_indicators FOR h_sql;
    LOOP
        FETCH c_indicators INTO h_indicator;
        EXIT WHEN c_indicators%NOTFOUND;

        -- We are not going to consider the indicators affected by modified calendars.
        -- The data of those indicators will be deleted
        -- and the prototype flag will be set to 0. So they are not going to be recalculated
        IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_indicator, h_object_keys, h_num_objects) THEN
            h_num_indicators := h_num_indicators + 1;
            h_indicators(h_num_indicators) := h_indicator;
        END IF;
    END LOOP;
    CLOSE c_indicators;

    -- Get the affected indicators too
    IF NOT BSC_UPDATE.Get_Input_Tables_Kpis(h_indicators, h_num_indicators, h_input_tables, h_num_input_tables) THEN
        RETURN FALSE;
    END IF;

    IF NOT BSC_UPDATE.get_kpi_for_input_tables(h_input_tables,h_num_input_tables,h_indicators,h_num_indicators) THEN
        RETURN FALSE;
    END IF;

    FOR h_i IN 1..h_num_indicators LOOP
        IF BSC_UPDATE.g_kpi_mode THEN
            IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_indicators(h_i),
                                                           BSC_UPDATE.g_indicators,
                                                           BSC_UPDATE.g_num_indicators) THEN
                IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_indicators(h_i), h_object_keys, h_num_objects) THEN
                    h_num_objects := h_num_objects + 1;
                    h_object_keys(h_num_objects) := h_indicators(h_i);
                    h_object_types(h_num_objects) := 'OBJECTIVE';
                    h_lock_types(h_num_objects) := 'R';
                    h_cascade_levels(h_num_objects) := -1;
                END IF;
            END IF;
         ELSE
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_indicators(h_i), h_object_keys, h_num_objects) THEN
                h_num_objects := h_num_objects + 1;
                h_object_keys(h_num_objects) := h_indicators(h_i);
                h_object_types(h_num_objects) := 'OBJECTIVE';
                h_lock_types(h_num_objects) := 'R';
                h_cascade_levels(h_num_objects) := -1;
            END IF;
         END IF;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    --need to commit because it used bsc_tmp_big_in_cond
    commit;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Incremental_Indicators;


/*===========================================================================+
|  FUNCTION Lock_Indicators
+============================================================================*/
FUNCTION Lock_Indicators (
    x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_input_tables IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;
BEGIN
    h_num_objects := 0;
    h_num_indicators := 0;

    IF NOT BSC_UPDATE.get_kpi_for_input_tables(x_input_tables,x_num_input_tables,h_indicators,h_num_indicators) THEN
        RETURN FALSE;
    END IF;

    FOR h_i IN 1..h_num_indicators LOOP
        IF BSC_UPDATE.g_kpi_mode THEN
            IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_indicators(h_i),
                                                           BSC_UPDATE.g_indicators,
                                                           BSC_UPDATE.g_num_indicators) THEN
                IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_indicators(h_i), h_object_keys, h_num_objects) THEN
                    h_num_objects := h_num_objects + 1;
                    h_object_keys(h_num_objects) := h_indicators(h_i);
                    h_object_types(h_num_objects) := 'OBJECTIVE';
                    h_lock_types(h_num_objects) := 'R';
                    h_cascade_levels(h_num_objects) := -1;
                END IF;
            END IF;
         ELSE
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_indicators(h_i), h_object_keys, h_num_objects) THEN
                h_num_objects := h_num_objects + 1;
                h_object_keys(h_num_objects) := h_indicators(h_i);
                h_object_types(h_num_objects) := 'OBJECTIVE';
                h_lock_types(h_num_objects) := 'R';
                h_cascade_levels(h_num_objects) := -1;
            END IF;
         END IF;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Indicators;


/*===========================================================================+
|  FUNCTION Lock_Indicators_by_Calendar
+============================================================================*/
FUNCTION Lock_Indicators_by_Calendar (
    x_calendars IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_calendars IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_indics (p_calendar_id NUMBER) IS
        select indicator
        from bsc_kpis_b
        where calendar_id = p_calendar_id;

    h_indicator NUMBER;

BEGIN
    h_num_objects := 0;

    FOR h_i IN 1..x_num_calendars LOOP
        OPEN c_indics(x_calendars(h_i));
        LOOP
            FETCH c_indics INTO h_indicator;
            EXIT WHEN c_indics%NOTFOUND;

            h_num_objects := h_num_objects + 1;
            h_object_keys(h_num_objects) := h_indicator;
            h_object_types(h_num_objects) := 'OBJECTIVE';
            h_lock_types(h_num_objects) := 'R';
            h_cascade_levels(h_num_objects) := -1;
        END LOOP;
        CLOSE c_indics;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Indicators_by_Calendar;


/*===========================================================================+
|  FUNCTION Lock_Indicators_To_Delete
+============================================================================*/
FUNCTION Lock_Indicators_To_Delete (
    x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_indicators IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;
    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;

    TYPE t_cursor IS REF CURSOR;
    c_indicators t_cursor;
    h_sql VARCHAR2(32000);
    h_where_indics VARCHAR2(32000);

BEGIN
    h_num_objects := 0;
    h_num_indicators := 0;
    h_num_input_tables := 0;

    -- Lock given indicators
    FOR h_i IN 1..x_num_indicators LOOP
        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := x_indicators(h_i);
        h_object_types(h_num_objects) := 'OBJECTIVE';
        h_lock_types(h_num_objects) := 'R';
        h_cascade_levels(h_num_objects) := -1;

        h_num_indicators := h_num_indicators + 1;
        h_indicators(h_num_indicators) := x_indicators(h_i);
    END LOOP;

    -- Lock the affected indicators too
    IF NOT BSC_UPDATE.Get_Input_Tables_Kpis(h_indicators, h_num_indicators, h_input_tables, h_num_input_tables) THEN
        RETURN FALSE;
    END IF;

    IF NOT BSC_UPDATE.get_kpi_for_input_tables(h_input_tables,h_num_input_tables,h_indicators,h_num_indicators) THEN
        RETURN FALSE;
    END IF;

    FOR h_i IN 1..h_num_indicators LOOP
        IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_indicators(h_i), x_indicators, x_num_indicators) THEN
            h_num_objects := h_num_objects + 1;
            h_object_keys(h_num_objects) := h_indicators(h_i);
            h_object_types(h_num_objects) := 'OBJECTIVE';
            h_lock_types(h_num_objects) := 'R';
            h_cascade_levels(h_num_objects) := -1;
        END IF;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Indicators_To_Delete;


/*===========================================================================+
|  FUNCTION Lock_Load_Dimension_Table
+============================================================================*/
FUNCTION Lock_Load_Dimension_Table (
    x_dim_table IN VARCHAR2,
    x_input_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
    h_dim_table_type NUMBER;
    h_dim_level_id NUMBER;

    CURSOR c_parent_dims IS
        SELECT dp.dim_level_id
        FROM bsc_sys_dim_levels_b d, bsc_sys_dim_levels_b dp, bsc_sys_dim_level_rels r
        WHERE d.dim_level_id = r.dim_level_id AND
              r.parent_dim_level_id = dp.dim_level_id AND
              DECODE(r.relation_type, 2, r.relation_col, d.level_table_name) = x_dim_table;

    h_parent_level_id NUMBER;

    CURSOR c_child_dims (p_dim_level_id NUMBER) IS
        select distinct dim_level_id
        from
          (select dim_level_id, parent_dim_level_id
           from bsc_sys_dim_level_rels
           where relation_type = 1
          )
        start with parent_dim_level_id = p_dim_level_id
        connect by parent_dim_level_id = prior dim_level_id;

    h_child_level_id NUMBER;
    h_child_rel_type NUMBER;
    h_child_rel_col VARCHAR(50);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);
    h_condition VARCHAR2(32000);
    h_base_table VARCHAR2(50);
    h_cond_for_base_tables VARCHAR2(32000);

BEGIN
    h_num_objects := 0;
    h_cond_for_base_tables := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'dim_level_id');

    -- Lock the input table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_input_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Lock the dimension table
    h_dim_table_type := BSC_UPDATE_DIM.Get_Dim_Table_Type(x_dim_table);
    IF h_dim_table_type = BSC_UPDATE_DIM.DIM_TABLE_TYPE_UNKNOWN THEN
        RETURN FALSE;
    END IF;
    IF h_dim_table_type = BSC_UPDATE_DIM.DIM_TABLE_TYPE_1N THEN
        SELECT dim_level_id
        INTO h_dim_level_id
        FROM bsc_sys_dim_levels_b
        WHERE level_table_name = x_dim_table;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_dim_level_id;
        h_object_types(h_num_objects) := 'DIMENSION_OBJECT';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;

        BSC_APPS.Add_Value_Big_In_Cond(1, h_dim_level_id);
    ELSE
        -- mn dimension table
        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := x_dim_table;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END IF;

    --Lock the parent dimensions
    OPEN c_parent_dims;
    LOOP
        FETCH c_parent_dims INTO h_parent_level_id;
        EXIT WHEN c_parent_dims%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_parent_level_id;
        h_object_types(h_num_objects) := 'DIMENSION_OBJECT';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;

        IF h_dim_table_type = BSC_UPDATE_DIM.DIM_TABLE_TYPE_MN THEN
            BSC_APPS.Add_Value_Big_In_Cond(1, h_parent_level_id);
        END IF;
    END LOOP;
    CLOSE c_parent_dims;

    -- Lock the child dimensions (all the childs, grand childs etc)
    IF h_dim_table_type = BSC_UPDATE_DIM.DIM_TABLE_TYPE_1N THEN
        --This query gets all the child, grand child all the way down.
        OPEN c_child_dims(h_dim_level_id);
        LOOP
            FETCH c_child_dims INTO h_child_level_id;
            EXIT WHEN c_child_dims%NOTFOUND;

            --lock the child dimension
            h_num_objects := h_num_objects + 1;
            h_object_keys(h_num_objects) := h_child_level_id;
            h_object_types(h_num_objects) := 'DIMENSION_OBJECT';
            h_lock_types(h_num_objects) := 'W';
            h_cascade_levels(h_num_objects) := 0;

            BSC_APPS.Add_Value_Big_In_Cond(1, h_child_level_id);
        END LOOP;
        CLOSE c_child_dims;
    END IF;

    -- Lock base tables used by the dimension or any of the child dimensions
    h_sql := 'SELECT DISTINCT bt.table_name'||
             ' FROM ('||
             ' SELECT DISTINCT table_name FROM bsc_db_tables_rels'||
             ' WHERE source_table_name IN ('||
             ' SELECT table_name FROM bsc_db_tables WHERE table_type = :1)) bt,'||
             ' bsc_db_tables_cols c'||
             ' WHERE bt.table_name = c.table_name AND'||
             ' c.column_type = :2 AND c.column_name IN ('||
             ' SELECT level_pk_col FROM bsc_sys_dim_levels_b'||
             ' WHERE '||h_cond_for_base_tables||')';
    OPEN h_cursor FOR h_sql USING 0, 'P';
    LOOP
        FETCH h_cursor INTO h_base_table;
        EXIT WHEN h_cursor%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_base_table;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE h_cursor;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    --need to commit because it used bsc_tmp_big_in_cond
    commit;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Load_Dimension_Table;


/*===========================================================================+
|  FUNCTION Lock_Period_Indicator
+============================================================================*/
FUNCTION Lock_Period_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_indicator;
    h_object_types(h_num_objects) := 'INDICATOR_PERIOD';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Period_Indicator;


/*===========================================================================+
|  FUNCTION Lock_Period_Indicators
+============================================================================*/
FUNCTION Lock_Period_Indicators(
    x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_indicators IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    FOR h_i IN 1..x_num_indicators LOOP
        -- Lock the table
        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := x_indicators(h_i);
        h_object_types(h_num_objects) := 'INDICATOR_PERIOD';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Period_Indicators;


/*===========================================================================+
|  FUNCTION Lock_Period_Indicators
+============================================================================*/
FUNCTION Lock_Period_Indicators(
    x_table_name IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_indicators IS
        select distinct indicator
        from bsc_kpi_data_tables
        where table_name = x_table_name;

    h_indicator NUMBER;

BEGIN
    h_num_objects := 0;

    --Lock the period of the indicators using the given table
    OPEN c_indicators;
    LOOP
        FETCH c_indicators INTO h_indicator;
        EXIT WHEN c_indicators%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_indicator;
        h_object_types(h_num_objects) := 'INDICATOR_PERIOD';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_indicators;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Period_Indicators;


/*===========================================================================+
|  FUNCTION Lock_Prototype_Indicator
+============================================================================*/
FUNCTION Lock_Prototype_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

BEGIN
    h_num_objects := 0;

    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_indicator;
    h_object_types(h_num_objects) := 'INDICATOR_PROTOTYPE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Prototype_Indicator;


/*===========================================================================+
|  FUNCTION Lock_Prototype_Indicators
+============================================================================*/
FUNCTION Lock_Prototype_Indicators(
    x_calendar_id IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_indicators IS
        select distinct indicator
        from bsc_kpis_b
        where calendar_id = x_calendar_id;

    h_indicator NUMBER;

BEGIN
    h_num_objects := 0;

    OPEN c_indicators;
    LOOP
        FETCH c_indicators INTO h_indicator;
        EXIT WHEN c_indicators%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_indicator;
        h_object_types(h_num_objects) := 'INDICATOR_PROTOTYPE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_indicators;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Prototype_Indicators;


/*===========================================================================+
|  FUNCTION Lock_Prototype_Indicators
+============================================================================*/
FUNCTION Lock_Prototype_Indicators
RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    TYPE t_cursor IS REF CURSOR;
    c_indicators t_cursor;
    h_sql VARCHAR2(32000);
    h_where_indics VARCHAR2(32000);
    h_indicator NUMBER;

BEGIN
    h_num_objects := 0;

    h_sql := 'SELECT DISTINCT indicator'||
             ' FROM bsc_kpis_vl'||
             ' WHERE prototype_flag IN (6,7)';
    IF BSC_UPDATE.g_kpi_mode THEN
        IF BSC_UPDATE.g_num_indicators > 0 THEN
            h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
            FOR h_i IN 1..BSC_UPDATE.g_num_indicators LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, BSC_UPDATE.g_indicators(h_i));
            END LOOP;
            h_sql := h_sql||' AND ('||h_where_indics||')';
        END IF;
    END IF;

    OPEN c_indicators FOR h_sql;
    LOOP
        FETCH c_indicators INTO h_indicator;
        EXIT WHEN c_indicators%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_indicator;
        h_object_types(h_num_objects) := 'INDICATOR_PROTOTYPE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_indicators;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    --need to commit because it used bsc_tmp_big_in_cond
    commit;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Prototype_Indicators;


/*===========================================================================+
|  FUNCTION Lock_Refresh_AW_Indicator
+============================================================================*/
FUNCTION Lock_Refresh_AW_Indicator(
    x_indicator IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_indic_tables IS
        select distinct table_name
        from bsc_db_tables_rels
        start with table_name in (
            select distinct table_name
            from bsc_kpi_data_tables
            where indicator = x_indicator and
                  table_name is not null
        )
        connect by table_name = prior source_table_name;

    h_table_name VARCHAR2(50);

BEGIN
    h_num_objects := 0;

    -- Lock the indicator aw cubes
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_indicator;
    h_object_types(h_num_objects) := 'AW_INDICATOR_CUBES';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Now all the summary tables of this indicator and its base tables
    OPEN c_indic_tables;
    LOOP
        FETCH c_indic_tables INTO h_table_name;
        EXIT WHEN c_indic_tables%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_table_name;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_indic_tables;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Refresh_AW_Indicator;


/*===========================================================================+
|  FUNCTION Lock_Refresh_AW_Table
+============================================================================*/
FUNCTION Lock_Refresh_AW_Table(
    x_summary_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_source_tables IS
        select distinct source_table_name
        from bsc_db_tables_rels
        where table_name = x_summary_table;

    h_table_name VARCHAR2(50);

BEGIN
    h_num_objects := 0;

    -- Lock the summary table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_summary_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Now lock the source tables
    OPEN c_source_tables;
    LOOP
        FETCH c_source_tables INTO h_table_name;
        EXIT WHEN c_source_tables%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_table_name;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_source_tables;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Refresh_AW_Table;


/*===========================================================================+
|  FUNCTION Lock_Refresh_MV
+============================================================================*/
FUNCTION Lock_Refresh_MV(
    x_summary_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_other_tables (p_like_name varchar2) IS
        select distinct table_name
        from bsc_db_tables
        where table_name like p_like_name;

    CURSOR c_source_tables (p_like_name varchar2) IS
        select distinct source_table_name
        from bsc_db_tables_rels
        where table_name like p_like_name;

    h_table_name VARCHAR2(50);
    h_like_name VARCHAR2(50);
    h_pos NUMBER;

BEGIN
    h_num_objects := 0;

    -- Lock the summary table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_summary_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- If the summary table is a BSC_T table then we do not need to lock any other object
    IF substr(x_summary_table, 1, 5) <> 'BSC_T' THEN
        -- Lock the other summary tables of the same level but with different periodicity
        -- that are contained in the same MV
        h_pos := INSTR(x_summary_table, '_', -1);
        h_like_name := SUBSTR(x_summary_table, 1, h_pos)||'%';

        OPEN c_other_tables(h_like_name);
        LOOP
            FETCH c_other_tables INTO h_table_name;
            EXIT WHEN c_other_tables%NOTFOUND;

            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table_name, h_object_keys, h_num_objects) THEN
                h_num_objects := h_num_objects + 1;
                h_object_keys(h_num_objects) := h_table_name;
                h_object_types(h_num_objects) := 'TABLE';
                h_lock_types(h_num_objects) := 'W';
                h_cascade_levels(h_num_objects) := 0;
            END IF;
        END LOOP;
        CLOSE c_other_tables;

        --Now lock the source tables contained in the source MVs
        OPEN c_source_tables(h_like_name);
        LOOP
            FETCH c_source_tables INTO h_table_name;
            EXIT WHEN c_source_tables%NOTFOUND;

            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table_name, h_object_keys, h_num_objects) THEN
                h_num_objects := h_num_objects + 1;
                h_object_keys(h_num_objects) := h_table_name;
                h_object_types(h_num_objects) := 'TABLE';
                h_lock_types(h_num_objects) := 'W';
                h_cascade_levels(h_num_objects) := 0;
            END IF;
        END LOOP;
        CLOSE c_source_tables;
    END IF;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Refresh_MV;


/*===========================================================================+
|  FUNCTION Lock_Refresh_Sum_Table
+============================================================================*/
FUNCTION Lock_Refresh_Sum_Table(
    x_summary_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;

    CURSOR c_source_tables IS
        select distinct source_table_name
        from bsc_db_tables_rels
        where table_name = x_summary_table;

    h_table_name VARCHAR2(50);

BEGIN
    h_num_objects := 0;

    -- Lock the summary table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_summary_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Now lock the source tables
    OPEN c_source_tables;
    LOOP
        FETCH c_source_tables INTO h_table_name;
        EXIT WHEN c_source_tables%NOTFOUND;

        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := h_table_name;
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;
    CLOSE c_source_tables;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Refresh_Sum_Table;


/*===========================================================================+
|  FUNCTION Lock_Update_Base_Table
+============================================================================*/
FUNCTION Lock_Update_Base_Table(
    x_input_table IN VARCHAR2,
    x_base_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    -- Lock the input table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_input_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    -- Lock the base table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_base_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Update_Base_Table;


/*===========================================================================+
|  FUNCTION Lock_Update_Date
+============================================================================*/
FUNCTION Lock_Update_Date RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := 0;
    h_object_types(h_num_objects) := 'UPDATE_DATE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Update_Date;


/*===========================================================================+
|  FUNCTION Lock_Table
+============================================================================*/
FUNCTION Lock_Table(
    x_table IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    -- Lock the table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_table;
    h_object_types(h_num_objects) := 'TABLE';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Table;


/*===========================================================================+
|  FUNCTION Lock_Tables
+============================================================================*/
FUNCTION Lock_Tables(
    x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_tables IN NUMBER
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    FOR h_i IN 1..x_num_tables LOOP
        -- Lock the table
        h_num_objects := h_num_objects + 1;
        h_object_keys(h_num_objects) := x_tables(h_i);
        h_object_types(h_num_objects) := 'TABLE';
        h_lock_types(h_num_objects) := 'W';
        h_cascade_levels(h_num_objects) := 0;
    END LOOP;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Tables;


/*===========================================================================+
|  FUNCTION Lock_Temp_Tables
+============================================================================*/
FUNCTION Lock_Temp_Tables(
    x_type IN VARCHAR2
) RETURN BOOLEAN IS
    h_object_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_object_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lock_types BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_cascade_levels BSC_UPDATE_UTIL.t_array_of_number;
    h_num_objects NUMBER;
    h_b BOOLEAN;
    h_i NUMBER;
BEGIN
    h_num_objects := 0;

    -- Lock the table
    h_num_objects := h_num_objects + 1;
    h_object_keys(h_num_objects) := x_type;
    h_object_types(h_num_objects) := 'TEMP_TABLES';
    h_lock_types(h_num_objects) := 'W';
    h_cascade_levels(h_num_objects) := 0;

    FOR h_i IN 1..h_num_objects LOOP
        BSC_UPDATE_LOG.Write_Line_Log('Locking: '||h_object_keys(h_i)||' '||h_object_types(h_i)||
                                      ' '||h_lock_types(h_i)||' '||h_cascade_levels(h_i),
                                      BSC_UPDATE_LOG.OUTPUT);
    END LOOP;

    h_b := Request_Lock(h_object_keys, h_object_types, h_lock_types, h_cascade_levels, h_num_objects);

    RETURN h_b;
END Lock_Temp_Tables;


/*===========================================================================+
|  FUNCTION Request_Lock
+============================================================================*/
FUNCTION Request_Lock (
    x_object_keys IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_object_types IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_lock_types IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_cascade_levels IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_objects IN NUMBER
) RETURN BOOLEAN IS

    h_i NUMBER;
    h_j NUMBER;
    h_num_locked_objects NUMBER;

    h_return_status VARCHAR2(2000);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

BEGIN

    LOOP
        h_num_locked_objects := 0;

        FOR h_i IN 1..x_num_objects LOOP
            -- Try to get the lock
            BSC_LOCKS_PUB.GET_SYSTEM_LOCK (
                p_object_key => x_object_keys(h_i),
                p_object_type => x_object_types(h_i),
                p_lock_type => x_lock_types(h_i),
                p_query_time => SYSDATE, --BSC_LOCKS_PUB.Get_System_Time,
                p_program_id => -101,
                p_user_id => BSC_APPS.apps_user_id,
                p_cascade_lock_level => x_cascade_levels(h_i),
                x_return_status => h_return_status,
                x_msg_count => h_msg_count,
                x_msg_data => h_msg_data
            );

            IF h_return_status = FND_API.G_RET_STS_SUCCESS THEN
                -- It got the lock
                h_num_locked_objects := h_num_locked_objects + 1;
            ELSE
                IF h_return_status = FND_API.G_RET_STS_ERROR THEN
                    -- It could not get the lock
                    -- Commit to release the objects already locked so far
                    BSC_UPDATE_LOG.Write_Line_Log(x_object_keys(h_i)||' '||x_object_types(h_i)||': '||h_msg_data,
                                                  BSC_UPDATE_LOG.OUTPUT);
                    COMMIT;
                ELSE
                    -- This is an unexpected error in the locking api
                    -- Commit to release the objects already locked so far
                    -- No reason to continue
                    BSC_UPDATE_LOG.Write_Line_Log(h_msg_data, BSC_UPDATE_LOG.OUTPUT);
                    COMMIT;
                    RETURN FALSE;
                END IF;

                EXIT;
            END IF;
        END LOOP;

        IF h_num_locked_objects = x_num_objects THEN
            -- It got the lock on all the objects
            EXIT;
        END IF;

        -- Wait for 2 seconds before trying to lock all the objects again
        DBMS_LOCK.Sleep(2);
    END LOOP;

    RETURN TRUE;

END Request_Lock;

END BSC_UPDATE_LOCK;

/
