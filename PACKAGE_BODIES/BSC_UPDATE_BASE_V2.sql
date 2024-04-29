--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_BASE_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_BASE_V2" AS
/* $Header: BSCDBV2B.pls 120.12.12000000.2 2007/01/30 10:04:30 rkumar ship $ */

--
-- Package constants
--

-- Formats

--
-- Package variables
--

/*===========================================================================+
| FUNCTION Calculate_Base_Table
+============================================================================*/
FUNCTION Calculate_Base_Table (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN
 ) RETURN BOOLEAN IS

    e_error_calc_base_table_v2 EXCEPTION;
    e_periodicity_null EXCEPTION;
    e_calc_period_input_table EXCEPTION;
    e_calc_period_base_table EXCEPTION;
    e_get_info_data_columns EXCEPTION;
    e_get_info_key_columns EXCEPTION;
    e_create_types_for_mv_load EXCEPTION;

    h_j NUMBER;

    h_return_status VARCHAR2(50);
    h_error_message VARCHAR2(4000);

    h_list dbms_sql.varchar2_table;
    h_values dbms_sql.varchar2_table;

    h_proj_tbl_name VARCHAR2(30);
    h_rowid_tbl_name VARCHAR2(30);

    h_partition_info BSC_DBGEN_STD_METADATA.clsTablePartition;
    h_num_partitions NUMBER;
    h_partition_names dbms_sql.varchar2_table;
    h_batch_values dbms_sql.number_table;

    h_parallel_jobs VARCHAR2(1);
    h_job_name VARCHAR2(100);
    h_process VARCHAR2(32000);
    h_job_status bsc_aw_utility.parallel_job_tb;

    h_aw_flag_t VARCHAR2(15);
    h_correction_flag_t VARCHAR2(15);

    h_change_vector_value NUMBER;

    h_periodicity NUMBER;
    h_calendar_id NUMBER;
    h_current_fy NUMBER;
    h_per_input_table NUMBER;
    h_current_per_base_table NUMBER;
    h_per_base_table NUMBER;

    h_sql VARCHAR2(32000);
    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

    h_num_rows NUMBER;
    h_num_loads NUMBER;

    h_data_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_formulas BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_proj_methods BSC_UPDATE_UTIL.t_array_of_number;
    h_data_measure_types BSC_UPDATE_UTIL.t_array_of_number;
    h_num_data_columns NUMBER;

    h_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns NUMBER;

BEGIN

    -- New strategy for better performance. B has only actual data and there is a projection table
    -- for projection. B and projection tables may be partitioned in which case
    -- we lauch n number of jobs for each partition.

    h_num_key_columns := 0;
    h_num_data_columns := 0;
    h_num_partitions := 0;
    h_num_bind_vars := 0;
    h_num_rows := 0;
    h_num_loads := 0;


    -- Get the periodicity of the base table
    -- Note: By design the periodicity of the input table and the base table are the same
    h_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_base_table);
    IF h_periodicity IS NULL THEN
        RAISE e_periodicity_null;
    END IF;

    -- Get the calendar id of the input/base table
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(h_periodicity);
    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

    -- Get the new period of the input table
    h_per_input_table := 0;
    -- If the base table is being re-calculated for incremental changes
    -- then we do not consider the input table to calculate new period of the base table.
    IF NOT x_correction_flag THEN
        Calc_New_Period_Input_Table(x_input_table,
                                    h_periodicity,
                                    h_current_fy,
                                    h_per_input_table,
                                    h_return_status,
                                    h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_calc_period_input_table;
        END IF;
    END IF;

    -- Calculate new period of the base table based on the new current period of the input table
    Calc_New_Period_Base_Table(x_base_table,
                               h_periodicity,
                               h_current_fy,
                               h_per_input_table,
                               h_current_per_base_table,
                               h_per_base_table,
                               h_return_status,
                               h_error_message);
    IF h_return_status = 'error' THEN
        RAISE e_calc_period_base_table;
    END IF;

    -- Get data columns
    IF NOT BSC_UPDATE_UTIL.Get_Information_Data_Columns(x_base_table,
                                                        h_data_columns,
                                                        h_data_formulas,
                                                        h_data_proj_methods,
                                                        h_data_measure_types,
                                                        h_num_data_columns) THEN
        RAISE e_get_info_data_columns;
    END IF;

    -- Get key columns
    IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(x_base_table,
                                                       h_key_columns,
                                                       h_key_dim_tables,
                                                       h_source_columns,
                                                       h_source_dim_tables,
                                                       h_num_key_columns) THEN
        RAISE e_get_info_key_columns;
    END IF;

    -- Get base table projection table name
    h_proj_tbl_name := Get_Base_Proj_Tbl_Name(x_base_table);

    -- Get input table row id table name
    h_list.delete;
    h_list(1) := BSC_DBGEN_STD_METADATA.BSC_I_ROWID_TABLE;
    h_values := BSC_DBGEN_METADATA_READER.Get_Table_Properties(x_input_table, h_list);
    h_rowid_tbl_name := h_values(1);

    -- Get base table partitions
    h_partition_info := BSC_DBGEN_METADATA_READER.Get_Partition_Info(x_base_table);
    h_num_partitions := h_partition_info.partition_count;
    -- Fix bug#4882239 If h_num_partitinos is NULL then assign it to 0
    IF h_num_partitions IS NULL THEN
        h_num_partitions := 0;
    END IF;
    FOR h_j IN 1..h_partition_info.partition_info.count LOOP
        h_partition_names(h_j) := h_partition_info.partition_info(h_j).partition_name;
        h_batch_values(h_j) := h_partition_info.partition_info(h_j).partition_value;
    END LOOP;

    -- Truncate projection table. It needs to be done here outside each job. We always recalculate projection
    BSC_UPDATE_UTIL.Truncate_Table(h_proj_tbl_name);

    -- Initialize the row id table. It needs to be done here outside each job.
    IF NOT x_correction_flag THEN
        BSC_UPDATE_UTIL.Truncate_Table(h_rowid_tbl_name);
        h_sql := 'insert /*+ append';
        IF BSC_UPDATE_UTIL.is_parallel THEN
            h_sql := h_sql||' parallel('||h_rowid_tbl_name||')';
        END IF;
        h_sql := h_sql||' */ into '||h_rowid_tbl_name||
                 ' select';
        IF BSC_UPDATE_UTIL.is_parallel THEN
            h_sql := h_sql||' /*+ parallel('||x_input_table||') */';
        END IF;
        h_sql := h_sql||' rowid, trunc((rownum - :1)/ :2)'||
                 ' from '||x_input_table;
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := 1;
        h_bind_vars_values(2) := 1000000;
        h_num_rows := BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, 2);
        commit;
        h_num_loads := trunc((h_num_rows - 1)/1000000);

    END IF;

    -- Create types needed to load input table in MV architecture. Need to be here outside each job.
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        Create_Types_For_MV_Load(x_base_table, h_key_columns, h_num_key_columns, h_data_columns, h_num_data_columns,
                                 h_return_status, h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_create_types_for_mv_load;
        END IF;
    END IF;

    --AW_INTEGRATION: init change vector value
    IF x_aw_flag THEN
        bsc_aw_load.init_bt_change_vector(x_base_table);
        bsc_aw_load.init_bt_change_vector(h_proj_tbl_name);
        h_change_vector_value := bsc_aw_load.get_bt_next_change_vector(x_base_table);
    ELSE
        h_change_vector_value := 0;
    END IF;

    -- Analyze the input table before loading it
    IF NOT x_correction_flag THEN
        BSC_BIA_WRAPPER.Analyze_Table(x_input_table);
        commit;
    END IF;

    IF h_num_partitions > 1 AND bsc_aw_utility.can_launch_dbms_job(h_num_partitions) = 'Y' THEN
        h_parallel_jobs := 'Y';
        bsc_aw_utility.clean_up_jobs('all');
        IF x_aw_flag THEN
            h_aw_flag_t := 'TRUE';
        ELSE
            h_aw_flag_t := 'FALSE';
        END IF;
        IF x_correction_flag THEN
            h_correction_flag_t := 'TRUE';
        ELSE
            h_correction_flag_t := 'FALSE';
        END IF;
        FOR h_j IN 1..h_num_partitions LOOP
            h_job_name := x_base_table||'_P_'||h_j;
            h_process := 'BSC_UPDATE_BASE_V2.Update_Base_Table_Job('||
                         ''''||x_base_table||''','||
                         ''''||x_input_table||''','||
                         h_correction_flag_t||','||
                         h_aw_flag_t||','||
                         h_change_vector_value||','||
                         h_periodicity||','||
                         h_calendar_id||','||
                         h_current_fy||','||
                         h_per_base_table||','||
                         h_current_per_base_table||','||
                         ''''||h_proj_tbl_name||''','||
                         ''''||h_rowid_tbl_name||''','||
                         ''''||h_partition_names(h_j)||''','||
                         h_batch_values(h_j)||','||
                         h_num_partitions||','||
                         h_num_loads||','||
                         ''''||h_job_name||''''||
                         ');';
            bsc_aw_utility.start_job(h_job_name, h_j, h_process, null);
        END LOOP;
        bsc_aw_utility.wait_on_jobs(null, h_job_status);

        FOR h_j IN 1..h_job_status.count LOOP
            IF h_job_status(h_j).status = 'error' THEN
                h_error_message := h_job_status(h_j).message;
                RAISE e_error_calc_base_table_v2;
            END IF;
        END LOOP;
    ELSE
        h_parallel_jobs := 'N';
        Update_Base_Table(x_base_table,
                          x_input_table,
                          x_correction_flag,
                          x_aw_flag,
                          h_change_vector_value,
                          h_periodicity,
                          h_calendar_id,
                          h_current_fy,
                          h_per_base_table,
                          h_current_per_base_table,
                          h_key_columns,
                          h_key_dim_tables,
                          h_num_key_columns,
                          h_data_columns,
                          h_data_formulas,
                          h_data_proj_methods,
                          h_data_measure_types,
                          h_num_data_columns,
                          h_proj_tbl_name,
                          h_rowid_tbl_name,
                          null,
                          null,
                          h_num_partitions,
                          h_num_loads,
                          h_parallel_jobs,
                          h_return_status,
                          h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_error_calc_base_table_v2;
        END IF;
    END IF;

    -- In AW architecture we need to update change vector value in aw metadata
    IF x_aw_flag THEN
        bsc_aw_load.update_bt_change_vector(x_base_table, h_change_vector_value);
        bsc_aw_load.update_bt_change_vector(h_proj_tbl_name, h_change_vector_value);
        commit;
    END IF;

    -- Store the update period of input table and base table
    IF NOT x_correction_flag THEN
        update bsc_db_tables
        set current_period = h_per_input_table
        where table_name = x_input_table;

        update bsc_db_tables
        set current_period = h_per_base_table
        where table_name = x_base_table;

        commit;

        -- Delete data from input table
        BSC_UPDATE_UTIL.Truncate_Table(x_input_table);
    END IF;

    --Fix bug#4962928: add this call
    IF x_aw_flag THEN
        BSC_AW_LOAD.update_bt_current_period(x_base_table, h_per_base_table, h_current_fy);
        commit;
    END IF;

    COMMIT;
    RETURN TRUE;

EXCEPTION
    WHEN e_error_calc_base_table_v2 THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => h_error_message,
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN e_periodicity_null THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_BTABLE_CALCULATION_FAILED'),
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN e_calc_period_input_table THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => h_error_message,
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN e_calc_period_base_table THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => h_error_message,
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN e_get_info_data_columns THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_BTABLE_CALCULATION_FAILED'),
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN e_get_info_key_columns THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_BTABLE_CALCULATION_FAILED'),
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN e_create_types_for_mv_load THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => h_error_message,
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_BASE_V2.Calculate_Base_Table');
        RETURN FALSE;

END Calculate_Base_Table;

/*===========================================================================+
| FUNCTION Calculate_Base_Table_AT
+============================================================================*/
FUNCTION Calculate_Base_Table_AT (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN
 ) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Calculate_Base_Table(x_base_table, x_input_table, x_correction_flag, x_aw_flag);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Calculate_Base_Table_AT;


/*===========================================================================+
| PROCEDURE Calc_New_Period_Input_Table
+============================================================================*/
PROCEDURE Calc_New_Period_Input_Table(
    x_input_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_current_fy IN NUMBER,
    x_period OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32700);

    h_current_period NUMBER;
    h_reported_period NUMBER;

    h_yearly_flag NUMBER;
    h_target_flag NUMBER;
    h_calendar_id NUMBER;
    h_calendar_source VARCHAR2(20);
    h_periodicity_type NUMBER;

BEGIN
    h_reported_period := 0;
    h_yearly_flag := 0;
    h_calendar_id := NULL;
    h_calendar_source := NULL;

    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity);
    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(h_calendar_id);

    -- Get Target_Flag of the input table
    h_target_flag := BSC_UPDATE_UTIL.Get_Table_Target_Flag(x_input_table);

    -- Get the current period of the input table
    BEGIN
        SELECT NVL(current_period, 0)
        INTO h_current_period
        FROM bsc_db_tables
        WHERE table_name = x_input_table;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_current_period := 0;
    END;

    -- Get yearly flag of the periodicity
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);

    -- Get the maximun period of real data reported in the input table
    IF h_yearly_flag = 1 THEN -- Annually
        -- The update period of an annual table is always the current
        -- fiscal year
        h_reported_period := x_current_fy;
    ELSE -- Other periodicities
        IF h_calendar_source = 'BSC' THEN
            h_sql := 'SELECT MAX(PERIOD) '||
                     'FROM '||x_input_table||' '||
                     'WHERE year = :1';

            IF h_target_flag = 1 THEN
                -- The input tables is used only for targets only
                -- No condition on TYPE to get the update period of the input table.
                OPEN h_cursor FOR h_sql USING x_current_fy;
            ELSE
                -- The input table is for fact and target data
                -- The update period is calculated based on fact data only.
                h_sql := h_sql||' AND type = :2';
                OPEN h_cursor FOR h_sql USING x_current_fy, 0;
            END IF;
        ELSE
            -- BIS periodicity
            --BSC-BIS-DIMENSIONS: The input table has a column called TIME_FK instead of YEAR, PERIOD

            h_periodicity_type := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_periodicity);

            IF h_periodicity_type = 9 THEN
                -- It is a daily periodicity. The TIME_FK column in the input table is of type DATE.
                h_sql := 'SELECT MAX(p.period_id)'||
                         ' FROM '||x_input_table||' i, bsc_sys_periods p'||
                         ' WHERE p.periodicity_id = :1 AND TRUNC(i.time_fk) = TRUNC(TO_DATE(p.time_fk, ''MM/DD/YYYY''))'||
                         ' AND p.year =:2';
            ELSE
                -- Other periodicity. TIME_FK is VARCHAR2
                h_sql := 'SELECT MAX(p.period_id)'||
                     ' FROM '||x_input_table||' i, bsc_sys_periods p'||
                     ' WHERE p.periodicity_id = :1 AND i.time_fk = p.time_fk AND p.year =:2';
            END IF;

            IF h_target_flag = 1 THEN
                -- The input tables is used only for targets only
                -- No condition on TYPE to get the update period of the input table.
                OPEN h_cursor FOR h_sql USING x_periodicity, x_current_fy;
            ELSE
                -- The input table is for fact and target data
                -- The update period is calculated based on fact data only.
                h_sql := h_sql||' AND type = :3';
                OPEN h_cursor FOR h_sql USING x_periodicity, x_current_fy, 0;
            END IF;
        END IF;

        FETCH h_cursor INTO h_reported_period;
        IF h_cursor%FOUND THEN
            IF h_reported_period IS NULL THEN
                h_reported_period := 0;
            END IF;
        ELSE
            h_reported_period := 0;
        END IF;
        CLOSE h_cursor;
    END IF;

    -- Assign the new update period
    IF h_reported_period > h_current_period THEN
        x_period := h_reported_period;
    ELSE
        x_period := h_current_period;
    END IF;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Calc_New_Period_Input_Table.e_others: '||SQLERRM;

END Calc_New_Period_Input_Table;


/*===========================================================================+
| PROCEDURE Calc_New_Period_Base_Table
+============================================================================*/
PROCEDURE Calc_New_Period_Base_Table(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_current_fy IN NUMBER,
    x_per_input_table IN NUMBER,
    x_current_per_base_table OUT NOCOPY NUMBER,
    x_per_base_table OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

     TYPE t_cursor IS REF CURSOR;
     h_cursor t_cursor;
     h_current_period NUMBER;
     h_calendar_id NUMBER;
     h_base_calendar_col_name VARCHAR2(30);
     h_yearly_flag NUMBER;
     h_edw_flag NUMBER;

BEGIN

    h_yearly_flag := 0;
    h_edw_flag := 0;

    -- Get the current period of the base table
    BEGIN
        SELECT NVL(current_period, 0)
        INTO h_current_period
        FROM bsc_db_tables
        WHERE table_name = x_base_table;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             h_current_period := 0;
     END;

    -- Calculate the period of the base table based on
    -- the period of the input table

    -- By design we know that there is no change of periodicity between input and base table
    x_per_base_table := x_per_input_table;

    -- The update period of the base table is the maximun between the current
    -- period and the period calculated from the input table,
    IF h_current_period > x_per_base_table THEN
        x_per_base_table := h_current_period;
    END IF;

    x_current_per_base_table := h_current_period;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Calc_New_Period_Base_Table.e_others: '||SQLERRM;

END Calc_New_Period_Base_Table;


/*===========================================================================+
| PROCEDURE Calc_Projection
+============================================================================*/
PROCEDURE Calc_Projection(
    x_base_table IN VARCHAR2,
    x_proj_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    --h_sql clob;
    h_sql dbms_sql.varchar2A;
    --h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_bind_vars_values dbms_sql.varchar2_table;
    h_num_bind_vars NUMBER;
    h_i NUMBER;
    h_j NUMBER;
    h_many_methods BOOLEAN;
    h_avg_cols BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_avg_cols NUMBER;
    h_perf_cols BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_perf_cols NUMBER;
    h_custom_cols BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_custom_cols NUMBER;
    h_num_proj_cols NUMBER;

    h_yearly_flag NUMBER;
    h_per_column VARCHAR2(100);
    h_num_of_years NUMBER;
    h_previous_years NUMBER;
    h_min_year NUMBER;
    h_max_year NUMBER;
    h_per_ini NUMBER;
    h_year_ini NUMBER;
    h_num_per_back NUMBER;
    h_init_per NUMBER;
    h_end_per NUMBER;

BEGIN
    h_num_avg_cols := 0;
    h_num_perf_cols := 0;
    h_num_custom_cols := 0;
    h_num_proj_cols := 0;
    h_num_bind_vars := 0;

    FOR h_i IN 1..x_num_data_columns LOOP
        IF x_data_proj_methods(h_i) = 1 THEN
            -- average last year method
            h_num_avg_cols := h_num_avg_cols + 1;
            h_avg_cols(h_num_avg_cols) := x_data_columns(h_i);
        ELSIF x_data_proj_methods(h_i) = 3 THEN
            -- 3 periods performance method
            h_num_perf_cols := h_num_perf_cols + 1;
            h_perf_cols(h_num_perf_cols) := x_data_columns(h_i);
            h_num_proj_cols := h_num_proj_cols + 1;
        ELSIF x_data_proj_methods(h_i) = 4 THEN
            -- Custom projection
            h_num_custom_cols := h_num_custom_cols + 1;
            h_custom_cols(h_num_custom_cols) := x_data_columns(h_i);
            h_num_proj_cols := h_num_proj_cols + 1;
        END IF;
    END LOOP;

    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_per_column := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);
    IF h_yearly_flag = 1 THEN
        IF NOT BSC_UPDATE_UTIL.Get_Table_Range_Of_Years(x_base_table, h_num_of_years, h_previous_years) THEN
            h_num_of_years := 2;
            h_previous_years := 1;
        END IF;
        h_min_year := x_current_fy - h_previous_years;
        h_max_year := h_min_year + h_num_of_years - 1;
    END IF;

    -- Calculate projection for data columns with projection method 3 (performance) and 4 (custom)
    -- Moving Average cannot be calculated with a single query so it is calculated later
    IF (h_num_perf_cols > 0) OR (h_num_custom_cols > 0) THEN
        IF (h_num_proj_cols = h_num_perf_cols) or (h_num_proj_cols = h_num_custom_cols) THEN
            h_many_methods := FALSE;
        ELSE
            h_many_methods := TRUE;
        END IF;

        bsc_dbgen_utils.add_string(h_sql, 'insert /*+ append');
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            bsc_dbgen_utils.add_string(h_sql, ' parallel('||x_proj_table||')');
        END IF;
        bsc_dbgen_utils.add_string(h_sql, ' */ into '||x_proj_table);
        IF x_parallel_jobs = 'Y' THEN
            bsc_dbgen_utils.add_string(h_sql, ' partition('||x_partition_name||')');
        END IF;
        bsc_dbgen_utils.add_string(h_sql, ' ('||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
        FOR h_i IN 1..x_num_key_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, 'year, type, period');
        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
        END IF;
        FOR h_i IN 1..x_num_data_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i));
        END LOOP;
        IF x_aw_flag THEN
            bsc_dbgen_utils.add_string(h_sql, ', projection, change_vector');
        END IF;
        bsc_dbgen_utils.add_string(h_sql, ')');
        IF h_many_methods THEN
            bsc_dbgen_utils.add_string(h_sql, ' select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(p) */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' p.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, 'p.key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'p.year, p.type, p.period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', p.periodicity_id');
            END IF;
            FOR h_i IN 1..x_num_data_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ', sum('||x_data_columns(h_i)||')');
            END LOOP;
            IF x_aw_flag THEN
                bsc_dbgen_utils.add_string(h_sql, ', p.projection, p.change_vector');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' from (');
        END IF;
        IF h_num_perf_cols > 0 THEN
            -- all measures with this projection method goes here other goes with null
            h_num_per_back := 3;
            IF h_yearly_flag = 1 THEN
                h_year_ini := x_current_fy - h_num_per_back + 1;
            ELSE
                h_per_ini := x_current_period - h_num_per_back + 1;
                IF h_per_ini <= 0 THEN
                    h_per_ini := 1;
                END IF;
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(p) parallel(tp) parallel(tr) parallel(pp) */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' p.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, 'p.key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'p.year, p.type, p.period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', p.periodicity_id');
            END IF;
            FOR h_i IN 1..x_num_data_columns LOOP
                IF x_data_proj_methods(h_i) = 3 THEN
                    bsc_dbgen_utils.add_string(h_sql,
                             ', case when (tr.tr'||h_i||'>0 and tp.tp'||h_i||'>0) and ((decode(tp.tp'||h_i||',0,'||
                             '0,tr.tr'||h_i||'/tp.tp'||h_i||')*pp.p'||h_i||')>(2*pp.p'||h_i||'))'||
                             ' then 2*pp.p'||h_i||
                             ' when tr.tr'||h_i||'>0 and tp.tp'||h_i||'>0'||
                             ' then (tr.tr'||h_i||'/tp.tp'||h_i||')*pp.p'||h_i||
                             ' when ((tr.tr'||h_i||'<0 and tp.tp'||h_i||'<0) or (tr.tr'||h_i||'<0 and tp.tp'||h_i||'>0)'||
                             ' or (tr.tr'||h_i||'>0 and tp.tp'||h_i||'<0)) and (pp.p'||h_i||'=0 or (pp.p'||h_i||' is null))'||
                             ' then (tr.tr'||h_i||'-tp.tp'||h_i||')/3'||
                             ' when ((tr.tr'||h_i||'<0 and tp.tp'||h_i||'<0) or (tr.tr'||h_i||'<0 and tp.tp'||h_i||'>0)'||
                             ' or (tr.tr'||h_i||'>0 and tp.tp'||h_i||'<0)) and not(pp.p'||h_i||'=0 or (pp.p'||h_i||' is null))'||
                             ' then pp.p'||h_i||'+((tr.tr'||h_i||'-tp.tp'||h_i||')/3)'||
                             ' when (tr.tr'||h_i||'<>0 and (tp.tp'||h_i||'=0 or (tp.tp'||h_i||' is null)))'||
                             ' and (pp.p'||h_i||'=0 or (pp.p'||h_i||' is null))'||
                             ' then tr.tr'||h_i||'/3'||
                             ' when (tr.tr'||h_i||'<>0 and (tp.tp'||h_i||'=0 or (tp.tp'||h_i||' is null)))'||
                             ' and not(pp.p'||h_i||'=0 or (pp.p'||h_i||' is null))'||
                             ' then pp.p'||h_i||'+(tr.tr'||h_i||'/3)'||
                             ' when ((tr.tr'||h_i||'=0 or (tr.tr'||h_i||' is null)) and (tp.tp'||h_i||'=0 or'||
                             ' (tp.tp'||h_i||' is null)))'||
                             ' then pp.p'||h_i||' end '||x_data_columns(h_i));
                ELSE
                    bsc_dbgen_utils.add_string(h_sql, ', null '||x_data_columns(h_i));
                END IF;
            END LOOP;
            IF x_aw_flag THEN
                bsc_dbgen_utils.add_string(h_sql, ', ''Y'' projection, '||x_change_vector_value||' change_vector');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' from (select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(a) parallel(bsc_tmp_all_periods) */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' a.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, 'a.'||x_key_columns(h_i)||' key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'bsc_tmp_all_periods.year, 0 type, bsc_tmp_all_periods.period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', '||x_periodicity||' periodicity_id');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' from (select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel('||x_base_table||') */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' distinct '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||x_key_columns(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table);
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' where periodicity_id = '||x_periodicity);
                IF x_parallel_jobs = 'Y' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
                END IF;
            ELSE
                IF x_parallel_jobs = 'Y' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' where '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
                END IF;
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') a,');
            IF h_yearly_flag <> 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' (select');
                IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(bsc_db_calendar) */');
                END IF;
                bsc_dbgen_utils.add_string(h_sql, ' distinct year, '||h_per_column||' period'||
                         ' from bsc_db_calendar'||
                         ' where year = '||x_current_fy||' and calendar_id = '||x_calendar_id||
                         ' and '||h_per_column||' > '||x_current_period||
                         ' ) bsc_tmp_all_periods');
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' (select');
                IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(bsc_db_calendar) */');
                END IF;
                bsc_dbgen_utils.add_string(h_sql, ' distinct year, 0 period'||
                         ' from bsc_db_calendar'||
                         ' where year > '||x_current_fy||' and year <= '||h_max_year||
                         ' and calendar_id = '||x_calendar_id||
                         ' ) bsc_tmp_all_periods');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' ) p,'||
                     ' (select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, '/*+ parallel('||x_base_table||') */ ');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||' key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, '0 type');
            FOR h_i IN 1..x_num_data_columns LOOP
                IF x_data_proj_methods(h_i) = 3 THEN
                    bsc_dbgen_utils.add_string(h_sql, ', sum('||x_data_columns(h_i)||') tp'||h_i);
                END IF;
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table||' where');
            IF h_yearly_flag <> 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' year = '||x_current_fy||' and type = 1 and'||
                         ' period >= '||h_per_ini||' and period <= '||x_current_period);
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' year >= '||h_year_ini||' and year <= '||x_current_fy||' and type = 1');
            END IF;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = '||x_periodicity);
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
            END IF;
            IF x_num_key_columns > 0 THEN
                bsc_dbgen_utils.add_string(h_sql, ' group by '||x_key_columns(1));
                FOR h_i IN 2..x_num_key_columns LOOP
                    bsc_dbgen_utils.add_string(h_sql, ', '||x_key_columns(h_i));
                END LOOP;
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') tp,'||
                     ' (select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, '/*+ parallel('||x_base_table||') */ ');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||' key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, '0 type');
            FOR h_i IN 1..x_num_data_columns LOOP
                IF x_data_proj_methods(h_i) = 3 THEN
                    bsc_dbgen_utils.add_string(h_sql, ', sum('||x_data_columns(h_i)||') tr'||h_i);
                END IF;
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table||' where');
            IF h_yearly_flag <> 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' year = '||x_current_fy||' and type = 0 and'||
                         ' period >= '||h_per_ini||' and period <= '||x_current_period);
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' year >= '||h_year_ini||' and year <= '||x_current_fy||' and type = 0');
            END IF;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = '||x_periodicity);
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
            END IF;
            IF x_num_key_columns > 0 THEN
                bsc_dbgen_utils.add_string(h_sql, ' group by '||x_key_columns(1));
                FOR h_i IN 2..x_num_key_columns LOOP
                    bsc_dbgen_utils.add_string(h_sql, ', '||x_key_columns(h_i));
                END LOOP;
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') tr,'||
                     ' (select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, '/*+ parallel('||x_base_table||') */ ');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||' key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'year, 0 type, period');
            FOR h_i IN 1..x_num_data_columns LOOP
                IF x_data_proj_methods(h_i) = 3 THEN
                    bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i)||' p'||h_i);
                END IF;
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table||' where');
            IF h_yearly_flag <> 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' year = '||x_current_fy||' and type = 1 and period > '||x_current_period);
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' year > '||x_current_fy||' and year <= '||h_max_year||' and type = 1');
            END IF;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = '||x_periodicity);
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') pp'||
                     ' where');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ' p.key'||h_i||' = tp.key'||h_i||'(+) and');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' p.type = tp.type(+) and');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ' p.key'||h_i||' = tr.key'||h_i||'(+) and');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' p.type = tr.type (+) and');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ' p.key'||h_i||' = pp.key'||h_i||'(+) and');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' p.year = pp.year (+) and'||
                     ' p.type = pp.type (+) and p.period = pp.period (+)');
        END IF;
        IF h_num_custom_cols > 0 THEN
            IF h_num_perf_cols > 0 THEN
                bsc_dbgen_utils.add_string(h_sql, ' UNION ALL');
            END IF;

            -- all measures with this projection method goes here other goes with null
            bsc_dbgen_utils.add_string(h_sql, ' select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(p) parallel(b) */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' p.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, 'p.key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'p.year, p.type, p.period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', p.periodicity_id');
            END IF;
            FOR h_i IN 1..x_num_data_columns LOOP
                IF x_data_proj_methods(h_i) = 4 THEN
                    bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i));
                ELSE
                    bsc_dbgen_utils.add_string(h_sql, ', null '||x_data_columns(h_i));
                END IF;
            END LOOP;
            IF x_aw_flag THEN
                bsc_dbgen_utils.add_string(h_sql, ', ''Y'' projection, '||x_change_vector_value||' change_vector');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' from (select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(a) parallel(bsc_tmp_all_periods) */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' a.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, 'a.'||x_key_columns(h_i)||' key'||h_i||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'bsc_tmp_all_periods.year year, 0 type, bsc_tmp_all_periods.period period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', '||x_periodicity||' periodicity_id');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' from (select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel('||x_base_table||') */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' distinct '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||x_key_columns(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table);
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' where periodicity_id = '||x_periodicity);
                IF x_parallel_jobs = 'Y' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
                END IF;
            ELSE
                IF x_parallel_jobs = 'Y' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' where '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
                END IF;
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') a,');
            IF h_yearly_flag <> 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' (select');
                IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(bsc_db_calendar) */');
                END IF;
                bsc_dbgen_utils.add_string(h_sql, ' distinct year, '||h_per_column||' period'||
                         ' from bsc_db_calendar'||
                         ' where year = '||x_current_fy||' and calendar_id = '||x_calendar_id||
                         ' and '||h_per_column||' > '||x_current_period||
                         ' ) bsc_tmp_all_periods');
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' (select');
                IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                    bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(bsc_db_calendar) */');
                END IF;
                bsc_dbgen_utils.add_string(h_sql, ' distinct year, 0 period'||
                         ' from bsc_db_calendar'||
                         ' where year > '||x_current_fy||' and year <= '||h_max_year||
                         ' and calendar_id = '||x_calendar_id||
                         ' ) bsc_tmp_all_periods');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') p,'||
                     ' (select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, '/*+ parallel('||x_base_table||') */ ');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'year, 0 type, period');
            FOR h_i IN 1..h_num_custom_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_custom_cols(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table||
                     ' where type = 90');
            IF h_yearly_flag <> 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' and year = '||x_current_fy||' and period > '||x_current_period);
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' and year > '||x_current_fy||' and year <= '||h_max_year);
            END IF;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = '||x_periodicity);
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = '||x_batch_value);
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') b'||
                     ' where');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ' p.key'||h_i||' = b.'||x_key_columns(h_i)||'(+) and');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' p.year = b.year(+) and  p.type = b.type(+) and'||
                     ' p.period = b.period(+)');
        END IF;
        IF h_many_methods THEN
            bsc_dbgen_utils.add_string(h_sql, ') p'||
                     ' group by p.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||',');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ' p.key'||h_i||',');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' p.year, p.type, p.period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', p.periodicity_id');
            END IF;
            --Fix bug#5155388
            IF x_aw_flag THEN
                bsc_dbgen_utils.add_string(h_sql, ', p.projection, p.change_vector');
            END IF;
        END IF;
        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        BSC_DBGEN_UTILS.Execute_Immediate(h_sql);
        commit;
    END IF;

    -- Now calculate projection for data columns with projection method 1 (moving average)
    --Fix bug#5155388
    h_sql.delete;

    IF h_num_avg_cols > 0 THEN
        IF h_yearly_flag = 1 THEN
            h_init_per := x_current_fy + 1;
            h_end_per := h_max_year;
        ELSE
            h_init_per := x_current_period + 1;
            h_end_per := BSC_UPDATE_UTIL.Get_Num_Periods_Periodicity(x_periodicity, x_current_fy);
        END IF;
        IF (h_num_perf_cols > 0) OR (h_num_custom_cols > 0) THEN
            -- There are rows in the projection table already. So we need to update.
            bsc_dbgen_utils.add_string(h_sql, 'update '||x_proj_table||' p'||
                     ' set ('||h_avg_cols(1));
            FOR h_i IN 2..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_avg_cols(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ') = ('||
                     ' select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(u) */ ');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, 'avg('||h_avg_cols(1)||')');
            FOR h_i IN 2..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', avg('||h_avg_cols(h_i)||')');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from ('||
                     ' select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel('||x_base_table||') */ ');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'year, type, period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;
            FOR h_i IN 1..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_avg_cols(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table||
                    ' where type = :1');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = :2');
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :3');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' union all'||
                     ' select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel('||x_proj_table||') */ ');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'year, type, period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;
            FOR h_i IN 1..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_avg_cols(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_proj_table||
                     ' WHERE type = :4');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = :5');
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :6');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') u'||
                     ' where');
            IF h_yearly_flag = 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' (u.year between :7 AND :8)');
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' (u.year * 1000 + u.period) between (:7 * 1000 + :8) and (:9 * 1000 + :10)');
            END IF;
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ' and p.'||x_key_columns(h_i)||' = u.'||x_key_columns(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' and p.type = u.type');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and p.periodicity_id = u.periodicity_id');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ')');
            IF h_yearly_flag = 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' where p.year = :11');
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' where p.year = :11 and p.period = :12');
            END IF;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and p.periodicity_id = :13');
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :14');
            END IF;

            FOR h_j IN h_init_per..h_end_per LOOP
                h_bind_vars_values.delete;
                h_num_bind_vars := 0;

                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := '0';
                IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_periodicity;
                END IF;
                IF x_parallel_jobs = 'Y' THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_batch_value;
                END IF;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := '0';
                IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_periodicity;
                END IF;
                IF x_parallel_jobs = 'Y' THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_batch_value;
                END IF;
                IF h_yearly_flag = 1 THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (h_j - h_previous_years);
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (h_j - 1);
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := h_j;
                ELSE
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (x_current_fy - 1);
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := h_j;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (h_j - 1);
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := h_j;
                END IF;
                IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_periodicity;
                END IF;
                IF x_parallel_jobs = 'Y' THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_batch_value;
                END IF;
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                BSC_DBGEN_UTILS.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                commit;
            END LOOP;
        ELSE
            -- There is no rows in the projection table. So we need to insert.
            bsc_dbgen_utils.add_string(h_sql, 'insert /*+ append');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' parallel('||x_proj_table||')');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' */ into '||x_proj_table);
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' partition('||x_partition_name||')');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' ('||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'year, type, period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;
            FOR h_i IN 1..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_avg_cols(h_i));
            END LOOP;
            IF x_aw_flag THEN
                bsc_dbgen_utils.add_string(h_sql, ', projection, change_vector');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ')'||
                     ' select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
               bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel(u) */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            IF h_yearly_flag = 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ':1, 0, 0');
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ':1, 0, :2');
            END IF;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;
            FOR h_i IN 1..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', avg('||h_avg_cols(h_i)||')');
            END LOOP;
            IF x_aw_flag THEN
                bsc_dbgen_utils.add_string(h_sql, ', :3, :4');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' from ('||
                     ' select');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel('||x_base_table||') */');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' year, type, period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;
            FOR h_i IN 1..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_avg_cols(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_base_table||
                    ' WHERE type = :5');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = :6');
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :7');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' union all'||
                     ' select ');
            IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
                bsc_dbgen_utils.add_string(h_sql, ' /*+ parallel('||x_proj_table||') */ ');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ');
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, 'year, type, period');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;
            FOR h_i IN 1..h_num_avg_cols LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||h_avg_cols(h_i));
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ' from '||x_proj_table||
                     ' WHERE type = :8');
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ' and periodicity_id = :9');
            END IF;
            IF x_parallel_jobs = 'Y' THEN
                bsc_dbgen_utils.add_string(h_sql, ' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :10');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ') u'||
                     ' where');
            IF h_yearly_flag = 1 THEN
                bsc_dbgen_utils.add_string(h_sql, ' (year between :11 AND :12)');
            ELSE
                bsc_dbgen_utils.add_string(h_sql, ' (year * 1000 + period) between (:11 * 1000 + :12) and (:13 * 1000 + :14)');
            END IF;
            bsc_dbgen_utils.add_string(h_sql, ' group by '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
            FOR h_i IN 1..x_num_key_columns LOOP
                bsc_dbgen_utils.add_string(h_sql, ', '||x_key_columns(h_i));
            END LOOP;
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                bsc_dbgen_utils.add_string(h_sql, ', periodicity_id');
            END IF;

            FOR h_j IN h_init_per..h_end_per LOOP
                h_bind_vars_values.delete;
                h_num_bind_vars := 0;

                IF h_yearly_flag = 1 THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := h_j;
                ELSE
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := h_j;
                END IF;
                IF x_aw_flag THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := 'Y';
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_change_vector_value;
                END IF;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := '0';
                IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_periodicity;
                END IF;
                IF x_parallel_jobs = 'Y' THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_batch_value;
                END IF;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := '0';
                IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_periodicity;
                END IF;
                IF x_parallel_jobs = 'Y' THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_batch_value;
                END IF;
                IF h_yearly_flag = 1 THEN
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (h_j - h_previous_years);
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (h_j - 1);
                ELSE
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (x_current_fy - 1);
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := h_j;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := (h_j - 1);
                END IF;
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                BSC_DBGEN_UTILS.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                commit;
            END LOOP;
        END IF;
    END IF;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Calc_Projection.e_others: '||SQLERRM;

END Calc_Projection;


/*===========================================================================+
| FUNCTION Create_Generic_Temp_Tables    				     |
+============================================================================*/
FUNCTION Create_Generic_Temp_Tables RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_table_name VARCHAR2(30);
    h_table_columns BSC_UPDATE_UTIL.t_array_temp_table_cols;
    h_num_columns NUMBER;

BEGIN

    -- BSC_DB_CALENDAR_TEMP:
    h_table_name := 'BSC_DB_CALENDAR_TEMP';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'LOWER_PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'UPPER_PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'LAST_PERIOD';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 2;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIODICITY_ID';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR'),
                      x_source => 'BSC_UPDATE_BASE_V2.Create_Generic_Temp_Tables');
      RETURN FALSE;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_BASE_V2.Create_Generic_Temp_Tables');
      RETURN FALSE;
END Create_Generic_Temp_Tables;


/*===========================================================================+
| FUNCTION Create_Generic_Temp_Tables_AT
+============================================================================*/
FUNCTION Create_Generic_Temp_Tables_AT RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Create_Generic_Temp_Tables;
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Create_Generic_Temp_Tables_AT;


/*===========================================================================+
| PROCEDURE Create_Proc_Load_Tbl_MV
+============================================================================*/
PROCEDURE  Create_Proc_Load_Tbl_MV(
    x_proc_name IN VARCHAR2,
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_num_loads IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS
    --h_sql CLOB;
    h_sql dbms_sql.varchar2A;
    h_i NUMBER;
    h_calendar_source VARCHAR2(20);
    h_yearly_flag NUMBER;
    h_periodicity_type NUMBER;
    h_bal_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_bal_columns NUMBER;
    l_sql varchar2(10000);
    l_newline varchar2(10):='
';
BEGIN

    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(x_calendar_id);
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_periodicity_type := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_periodicity);
    h_num_bal_columns := 0;
    FOR h_i IN 1..x_num_data_columns LOOP
        IF x_data_measure_types(h_i) <> 1 THEN
            h_num_bal_columns := h_num_bal_columns + 1;
            h_bal_columns(h_num_bal_columns) := x_data_columns(h_i);
        END IF;
    END LOOP;

    bsc_dbgen_utils.add_string(h_sql, 'create or replace procedure '||x_proc_name||' as'||l_newline||
             ' type bsc_b_r is record('||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        --Fix bug#4880895 use varchar2 to support bis dimensions
        bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||' varchar2(400), '||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'year number(5), type number(3), period number(5), periodicity_id number'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i)||' number'||l_newline||
                 ', B_DATA'||h_i||' number');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' number, row_id rowid);'||l_newline||
             ' type bsc_b_t is table of bsc_b_r index by pls_integer;'||l_newline||
             ' type t_rowid_table is table of rowid index by pls_integer;'||l_newline||
             ' h_load_batch number;'||l_newline);

    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' h_batch_value number := '||x_batch_value||';'||l_newline);
    ELSE
        bsc_dbgen_utils.add_string(h_sql, ' h_batch_value number := 0;'||l_newline);
    END IF;
    bsc_dbgen_utils.add_string(h_sql,
             ' h_num_partitions number := '||x_num_partitions||';'||l_newline||
             ' h_periodicity number := '||x_periodicity||';'||l_newline||
             ' h_current_fy number := '||x_current_fy||';'||l_newline||
             ' cursor c1 is'||l_newline||
             ' with bsc_i_data as ('||l_newline||
             ' SELECT ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_key_dim_tables(h_i)||'.CODE '||x_key_columns(h_i)||', '||l_newline);
    END LOOP;
    IF h_calendar_source = 'BSC' THEN
        bsc_dbgen_utils.add_string(h_sql, x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD');
    ELSE
        -- BIS calendar
        IF h_yearly_flag = 1 THEN
            bsc_dbgen_utils.add_string(h_sql, 'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, 0 PERIOD');
        ELSE
            bsc_dbgen_utils.add_string(h_sql, 'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, BSC_SYS_PERIODS.PERIOD_ID PERIOD');
        END IF;
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ', h_periodicity periodicity_id'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||x_data_columns(h_i)||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||l_newline||
             ' FROM (select /*+ordered*/ ');
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, 'h_batch_value '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
    ELSE
        IF x_num_partitions > 0 THEN
            bsc_dbgen_utils.add_string(h_sql, ' dbms_utility.get_hash_value(');
            FOR h_i IN 1..x_num_key_columns LOOP
                IF h_i = 1 THEN
                    bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||l_newline);
                ELSE
                    bsc_dbgen_utils.add_string(h_sql, '||''.''||'||x_key_columns(h_i)||l_newline);
                END IF;
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ', 0, h_num_partitions) '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
        ELSE
            bsc_dbgen_utils.add_string(h_sql, ' 0 '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
        END IF;
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.*'||
             ' FROM '||x_rowid_table||', '||x_input_table||
             ' WHERE '||x_rowid_table||'.row_id = '||x_input_table||'.rowid and'||
             ' '||x_rowid_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_load_batch');
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' and dbms_utility.get_hash_value(');
        FOR h_i IN 1..x_num_key_columns LOOP
            IF h_i = 1 THEN
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||l_newline);
            ELSE
                bsc_dbgen_utils.add_string(h_sql, '||''.''||'||x_key_columns(h_i)||l_newline);
            END IF;
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, ', 0, h_num_partitions) = h_batch_value');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ') '||x_input_table);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_key_dim_tables(h_i)||l_newline);
    END LOOP;
    IF h_calendar_source <> 'BSC' THEN
        -- BIS calendar
        bsc_dbgen_utils.add_string(h_sql, ', BSC_SYS_PERIODS');
    END IF;
    IF x_num_key_columns > 0 THEN
        bsc_dbgen_utils.add_string(h_sql, ' WHERE '||
                 x_input_table||'.'||x_key_columns(1)||' = '||x_key_dim_tables(1)||'.USER_CODE');
        FOR h_i IN 2..x_num_key_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, ' AND '||l_newline||
                     x_input_table||'.'||x_key_columns(h_i)||' = '||x_key_dim_tables(h_i)||'.USER_CODE');
        END LOOP;
    END IF;
    IF h_calendar_source <> 'BSC' THEN
        -- BIS calendar
        IF x_num_key_columns > 0 THEN
            bsc_dbgen_utils.add_string(h_sql, ' AND');
        ELSE
            bsc_dbgen_utils.add_string(h_sql, ' WHERE');
        END IF;
        IF h_periodicity_type = 9 THEN
            -- It is a daily periodicity. The TIME_FK column in the input table is of type DATE.
            bsc_dbgen_utils.add_string(h_sql,
                     ' TRUNC('||x_input_table||'.TIME_FK) = TRUNC(TO_DATE(BSC_SYS_PERIODS.TIME_FK, ''MM/DD/YYYY'')) AND'||
                     ' BSC_SYS_PERIODS.PERIODICITY_ID = h_periodicity');
        ELSE
            -- Other periodicity. TIME_FK is VARCHAR2
            -- Fix bug#5175277 missing space ANDBSC_SYS_PERIODS....
            bsc_dbgen_utils.add_string(h_sql,
                     ' '||x_input_table||'.TIME_FK = BSC_SYS_PERIODS.TIME_FK AND'||
		     ' BSC_SYS_PERIODS.PERIODICITY_ID = h_periodicity');
        END IF;
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ') select ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_input_table||'.'||x_key_columns(h_i)||', '||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD'||
             ', '||x_input_table||'.PERIODICITY_ID');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||x_data_columns(h_i)||l_newline||
                 ', '||x_base_table||'.'||x_data_columns(h_i));
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', '||x_base_table||'.rowid row_id'||
             ' FROM (SELECT ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, 'bsc_i_data.'||x_key_columns(h_i)||', '||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'bsc_i_data.YEAR, bsc_i_data.TYPE, bsc_i_data.PERIOD, bsc_i_data.periodicity_id');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', bsc_i_data.'||x_data_columns(h_i)||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', bsc_i_data.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||
             ' from bsc_i_data'||l_newline||
             ' union all'||l_newline||
             ' select '||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, 'bsc_i_data.'||x_key_columns(h_i)||', '||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'bsc_i_data.YEAR, bsc_i_data.TYPE, bsc_db_calendar_temp.upper_PERIOD PERIOD'||
             ', bsc_db_calendar_temp.periodicity_id');
    FOR h_i IN 1..x_num_data_columns LOOP
        IF x_data_measure_types(h_i) = 1 THEN
            -- Activity measure
            bsc_dbgen_utils.add_string(h_sql, ', '||x_data_formulas(h_i)||' '||x_data_columns(h_i));
        ELSE
            -- Balance measure
            bsc_dbgen_utils.add_string(h_sql, ', SUM(DECODE(BSC_DB_CALENDAR_TEMP.LAST_PERIOD,''Y'','||x_data_columns(h_i)||', NULL))'||
                     ' '||x_data_columns(h_i));
        END IF;
    END LOOP;
    --Fix bug#5155523 do not use max(bsc_i_data.batch_column_name) instead add it to the group by
    bsc_dbgen_utils.add_string(h_sql, ', bsc_i_data.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' '||
             BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||l_newline||
             ' from bsc_i_data, bsc_db_calendar_temp'||l_newline||
             ' where bsc_i_data.period = bsc_db_calendar_temp.lower_period and'||l_newline||
             ' bsc_i_data.year = bsc_db_calendar_temp.year'||l_newline||
             ' group by ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, 'BSC_I_DATA.'||x_key_columns(h_i)||', ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'BSC_I_DATA.YEAR, BSC_I_DATA.TYPE, BSC_DB_CALENDAR_TEMP.UPPER_PERIOD,'||l_newline||
             ' BSC_DB_CALENDAR_TEMP.PERIODICITY_ID, BSC_I_DATA.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||l_newline||
             ') '||x_input_table||l_newline||
             ',	(select * from '||x_base_table||l_newline);
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' where '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_batch_value');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ') '||x_base_table||l_newline||
             ' where ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_input_table||'.'||x_key_columns(h_i)||' = '||x_base_table||'.'||x_key_columns(h_i)||'(+) and '||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, x_input_table||'.YEAR = '||x_base_table||'.YEAR(+) and '||l_newline||
             x_input_table||'.TYPE = '||x_base_table||'.TYPE(+) and '||l_newline||
             x_input_table||'.PERIOD = '||x_base_table||'.PERIOD(+) and '||l_newline||
             x_input_table||'.PERIODICITY_ID = '||x_base_table||'.PERIODICITY_ID(+);'||l_newline||
             ' v1 bsc_b_t;'||l_newline||
             ' v1_join_rollup '||x_base_table||'_tt := '||x_base_table||'_tt();'||l_newline||
             ' v1_rollup bsc_b_t;'||l_newline||
             ' type temp_cal_tt is table of bsc_db_calendar_temp%rowtype index by pls_integer;'||l_newline||
             ' c1_correct temp_cal_tt;'||l_newline||
             ' before_period number := '||x_old_current_period||';'||l_newline||
             ' after_period number := '||x_current_period||';'||l_newline||
             ' cursor c2 is'||l_newline||
             ' select '||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_base_table||'.'||x_key_columns(h_i)||', '||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, x_base_table||'.YEAR, '||x_base_table||'.TYPE, '||
            'bsc_db_calendar_temp.upper_PERIOD period, bsc_db_calendar_temp.periodicity_id'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        IF x_data_measure_types(h_i) = 1 THEN
            -- Activity measure
            bsc_dbgen_utils.add_string(h_sql, ', '||
                     replace(x_data_formulas(h_i),
                             '('||x_data_columns(h_i)||')',
                             '('||x_base_table||'.'||x_data_columns(h_i)||')')||
                     ' '||x_data_columns(h_i)||
                     ', null B_DATA'||h_i);
        ELSE
            -- Balance measure
            bsc_dbgen_utils.add_string(h_sql, ', '||
                     'SUM(DECODE(BSC_DB_CALENDAR_TEMP.LAST_PERIOD,''Y'','||x_base_table||'.'||x_data_columns(h_i)||', NULL))'||
                     ' '||x_data_columns(h_i)||
                     ', null B_DATA'||h_i);

        END IF;
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', max('||x_base_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||') '||
             BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||
             ', chartorowid(tt.row_id) row_id'||
             ' from table(cast(v1_join_rollup as '||x_base_table||'_tt)) tt,'||
             ' bsc_db_calendar_temp, '||x_base_table||
             ' where ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, 'tt.'||x_key_columns(h_i)||' = '||x_base_table||'.'||x_key_columns(h_i)||' and ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'tt.year = bsc_db_calendar_temp.year and'||l_newline||
             ' tt.type = '||x_base_table||'.type and'||l_newline||
             ' tt.period = bsc_db_calendar_temp.upper_period and'||l_newline||
             ' tt.periodicity_id = bsc_db_calendar_temp.periodicity_id and'||l_newline||
             ' bsc_db_calendar_temp.year = '||x_base_table||'.year and'||l_newline||
             ' bsc_db_calendar_temp.lower_period = '||x_base_table||'.period and'||l_newline||
             ' '||x_base_table||'.periodicity_id = h_periodicity'||l_newline);
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' and '||x_base_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_batch_value'||l_newline);
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ' group by '||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_base_table||'.'||x_key_columns(h_i)||', ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, x_base_table||'.YEAR, '||x_base_table||'.TYPE,'||
             ' bsc_db_calendar_temp.upper_PERIOD, bsc_db_calendar_temp.periodicity_id, tt.row_id;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' u_data'||h_i||' dbms_sql.number_table;'||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ' u_rowid t_rowid_table;');
    FOR h_i IN 1..x_num_key_columns LOOP
        -- Fix bug#4880895 user varchar2 to support bis dimensions
        bsc_dbgen_utils.add_string(h_sql, ' i_'||x_key_columns(h_i)||' dbms_sql.varchar2_table;'||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_year dbms_sql.number_table;'||l_newline||
             ' i_type dbms_sql.number_table;'||l_newline||
             ' i_period dbms_sql.number_table;'||l_newline||
             ' i_periodicity_id dbms_sql.number_table;'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_data'||h_i||' dbms_sql.number_table;'||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_batch dbms_sql.number_table;'||l_newline||
             ' u_count integer := 0;'||l_newline||
             ' i_count integer := 0;'||l_newline||
             ' begin'||l_newline);
    -- Balance correction
    -- NOTE: Do this only if there are balance columns and the periodicity of the table is not yearly
    -- Also no need to do it if before_period = after_period
    -- Also this has to be done outside the p_load_batch loop
    IF (h_num_bal_columns > 0) AND (h_yearly_flag <> 1) AND (x_current_period > x_old_current_period) THEN
        bsc_dbgen_utils.add_string(h_sql, ' declare'||l_newline||
                 ' cursor c_t is'||l_newline||
                 ' select * from bsc_db_calendar_temp'||l_newline||
                 ' order by periodicity_id,year,lower_period;'||l_newline||
                 ' cursor c_cb(p_lower_periodicity number,p_lower_year number,p_lower_period number,'||l_newline||
                 ' p_upper_periodicity number,p_upper_year number,p_upper_period number) is'||l_newline||
                 ' select ');
        FOR h_i IN 1..h_num_bal_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, 'b_lower.'||h_bal_columns(h_i)||' '||h_bal_columns(h_i)||', '||l_newline);
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, 'b_upper.rowid row_id'||
                 ' from '||x_base_table||' b_lower, '||x_base_table||' b_upper'||l_newline||
                 ' where '||l_newline);
        IF x_parallel_jobs = 'Y' THEN
            bsc_dbgen_utils.add_string(h_sql, 'b_lower.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_batch_value and ');
        END IF;
        bsc_dbgen_utils.add_string(h_sql, 'b_lower.periodicity_id(+) = p_lower_periodicity and'||l_newline||
                 ' b_lower.year(+) = p_lower_year and'||l_newline||
                 ' b_lower.period(+) = p_lower_period and '||l_newline);
        IF x_parallel_jobs = 'Y' THEN
            bsc_dbgen_utils.add_string(h_sql, 'b_upper.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_batch_value and ');
        END IF;
        bsc_dbgen_utils.add_string(h_sql, 'b_upper.periodicity_id = p_upper_periodicity and'||l_newline||
                 ' b_upper.year = p_upper_year and'||l_newline||
                 ' b_upper.period = p_upper_period and '||l_newline);
        FOR h_i IN 1..x_num_key_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, 'b_lower.'||x_key_columns(h_i)||'(+) = b_upper.'||x_key_columns(h_i)||' and '||l_newline);
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, ' b_lower.type(+) = b_upper.type;'||l_newline);
        FOR h_i IN 1..h_num_bal_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, ' l_cb_data'||h_i||' dbms_sql.number_table;'||l_newline);
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, l_newline||
                 ' l_cb_rowid t_rowid_table;'||l_newline||
                 ' begin'||l_newline||
                 ' open c_t;'||l_newline||
                 ' loop'||l_newline||
                 ' fetch c_t bulk collect into c1_correct;'||l_newline||
                 ' exit when c_t%notfound;'||l_newline||
                 ' end loop;'||l_newline||
                 ' close c_t;'||l_newline||
                 ' for i in 1..c1_correct.count loop'||l_newline||
                 ' if c1_correct(i).lower_period = before_period and'||l_newline||
                 ' c1_correct(i).year = h_current_fy and c1_correct(i).last_period <> ''Y'' then'||l_newline||
                 ' for j in i..c1_correct.count loop'||l_newline||
                 ' if c1_correct(i).periodicity_id = c1_correct(j).periodicity_id and'||l_newline||
                 ' (c1_correct(j).last_period=''Y'' or'||l_newline||
                 ' (c1_correct(j).lower_period = after_period and c1_correct(j).year = h_current_fy)) then'||l_newline);
        FOR h_i IN 1..h_num_bal_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, ' l_cb_data'||h_i||'.delete;'||l_newline);
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql,
                 ' l_cb_rowid.delete;'||l_newline||
                 ' open c_cb(h_periodicity, c1_correct(j).year, c1_correct(j).lower_period,'||l_newline||
                 ' c1_correct(j).periodicity_id, c1_correct(j).year, c1_correct(j).upper_period);'||l_newline||
                 ' loop'||l_newline||
                 ' fetch c_cb bulk collect into ');
        FOR h_i IN 1..h_num_bal_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, ' l_cb_data'||h_i||', ');
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, 'l_cb_rowid;'||l_newline||
                 ' exit when c_cb%notfound;'||l_newline||
                 ' end loop;'||l_newline||
                 ' close c_cb;'||l_newline||
                 ' forall k in 1..l_cb_rowid.count'||l_newline||
                 ' update '||x_base_table||l_newline||
                 ' set '||h_bal_columns(1)||' = l_cb_data1(k)');
        FOR h_i IN 2..h_num_bal_columns LOOP
            bsc_dbgen_utils.add_string(h_sql,
                     ', '||h_bal_columns(h_i)||' = l_cb_data'||h_i||'(k)'||l_newline);
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, ' where rowid = l_cb_rowid(k);'||l_newline||
                 ' commit;'||l_newline||
                 ' exit;'||l_newline||
                 ' end if;'||l_newline||
                 ' end loop;'||l_newline||
                 ' end if;'||l_newline||
                 ' end loop;'||l_newline||
                 ' end;');
    END IF;
    -- Start key translation
    bsc_dbgen_utils.add_string(h_sql,
             ' for k in 0..'||x_num_loads||' loop'||l_newline||
             ' h_load_batch := k;'||l_newline||
             ' v1.delete;'||l_newline||
             ' v1_join_rollup.delete;'||l_newline||
             ' v1_rollup.delete;'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' u_data'||h_i||'.delete;'||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ' u_rowid.delete;'||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_'||x_key_columns(h_i)||'.delete;'||l_newline);
    END LOOP;

    bsc_dbgen_utils.add_string(h_sql,
             ' i_year.delete;'||l_newline||
             ' i_type.delete;'||l_newline||
             ' i_period.delete;'||l_newline||
             ' i_periodicity_id.delete;'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_data'||h_i||'.delete;'||l_newline);
    END LOOP;

    bsc_dbgen_utils.add_string(h_sql,
             ' i_batch.delete;'||l_newline||
             ' u_count := 0;'||l_newline||
             ' i_count := 0;'||l_newline||
             ' open c1;'||l_newline||
             ' loop'||l_newline||
             ' fetch c1 bulk collect into v1;'||l_newline||
             ' exit when c1%notfound;'||l_newline||
             ' end loop;'||l_newline||
             ' close c1;'||l_newline||
             ' for i in 1..v1.count loop'||l_newline||
             ' if v1(i).row_id is not null and v1(i).periodicity_id <> h_periodicity then'||l_newline||
             ' v1_join_rollup.extend;'||l_newline||
             ' v1_join_rollup(v1_join_rollup.count) := '||x_base_table||'_t('||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, 'v1(i).'||x_key_columns(h_i)||', '||l_newline);
    END LOOP;

    bsc_dbgen_utils.add_string(h_sql, 'v1(i).year, v1(i).type, v1(i).period, v1(i).periodicity_id');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', null');
    END LOOP;
    --Fix bug#4915276: use nvl() since 10<>null is false
    bsc_dbgen_utils.add_string(h_sql, ', rowidtochar(v1(i).row_id), null);'||l_newline||
             ' end if;'||l_newline||
             ' end loop;'||l_newline||
             ' u_count := 0;'||l_newline||
             ' for i in 1..v1.count loop'||l_newline||
             ' if v1(i).row_id is not null then'||l_newline||
             ' if (nvl(v1(i).b_data1,-9999999999)<>nvl(v1(i).'||x_data_columns(1)||',-9999999999))'||l_newline);
    FOR h_i IN 2..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' or (nvl(v1(i).b_data'||h_i||',-9999999999)<>nvl(v1(i).'||x_data_columns(h_i)||',-9999999999))'||l_newline);
    END LOOP;

    bsc_dbgen_utils.add_string(h_sql, ' then'||l_newline||
             ' if v1(i).periodicity_id = h_periodicity then'||l_newline||
             '  u_count:=u_count+1;'||l_newline||
             '  u_rowid(u_count):=v1(i).row_id;'||l_newline);
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' u_data'||h_i||'(u_count):=v1(i).'||x_data_columns(h_i)||';'||l_newline);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' end if;'||l_newline||
             ' end if;'||l_newline||
             ' else'||l_newline||
             ' i_count:=i_count+1;'||l_newline);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_'||x_key_columns(h_i)||'(i_count):=v1(i).'||x_key_columns(h_i)||';'||l_newline);
    END LOOP;

    bsc_dbgen_utils.add_string(h_sql,
             ' i_YEAR(i_count):=v1(i).year;'||l_newline||
             ' i_TYPE(i_count):=v1(i).type;'||l_newline||
             ' i_PERIOD(i_count):=v1(i).period;'||l_newline||
             ' i_periodicity_id(i_count):=v1(i).periodicity_id;'||l_newline);

   l_sql := null;
   FOR h_i IN 1..x_num_data_columns LOOP
     l_sql := l_sql ||' i_data'||h_i||'(i_count):=v1(i).'||x_data_columns(h_i)||';'||l_newline;
   END LOOP;
   bsc_dbgen_utils.add_string(h_sql, l_sql);
   l_sql := null;
   l_sql :=
            ' i_batch(i_count):=v1(i).'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||';'||l_newline||
            ' end if;'||l_newline||
            ' end loop;'||l_newline||
            ' forall i in 1..u_count'||l_newline||
            ' update '||x_base_table||l_newline;
    IF x_parallel_jobs = 'Y' THEN
        l_sql := l_sql||' partition('||x_partition_name||')';
    END IF;
   bsc_dbgen_utils.add_string(h_sql, l_sql);
   l_sql := null;
    l_sql := ' set '||x_data_columns(1)||'=u_data1(i)'||l_newline;
    FOR h_i IN 2..x_num_data_columns LOOP
      l_sql := l_sql||', '||x_data_columns(h_i)||' = u_data'||h_i||'(i)'||l_newline;
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, l_sql);
    l_sql := null;
    l_sql := ' where '||x_base_table||'.rowid=u_rowid(i);'||l_newline||
             ' forall i in 1..i_count'||l_newline||
             ' insert /*+append*/ into '||x_base_table||l_newline;
    bsc_dbgen_utils.add_string(h_sql, l_sql);
    l_sql := null;
    --         ' where '||x_base_table||'.rowid=u_rowid(i);'||l_newline||
    --         ' forall i in 1..i_count'||l_newline||
    --         ' insert /*+append*/ into '||x_base_table||l_newline;
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' partition('||x_partition_name||')');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ' (');
    FOR h_i IN 1..x_num_key_columns LOOP
       l_sql := x_key_columns(h_i)||', '||l_newline;
       bsc_dbgen_utils.add_string(h_sql, l_sql);
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'YEAR, TYPE, PERIOD, PERIODICITY_ID');
    FOR h_i IN 1..x_num_data_columns LOOP
        l_sql := ', '||x_data_columns(h_i)||l_newline;
        bsc_dbgen_utils.add_string(h_sql, l_sql);
    END LOOP;

    l_sql := ', '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||')'||l_newline||
             ' values('||l_newline;
    FOR h_i IN 1..x_num_key_columns LOOP
        l_sql := l_sql||'i_'||x_key_columns(h_i)||'(i), ';
    END LOOP;
    l_sql := l_sql||'i_YEAR(i),i_TYPE(i),i_PERIOD(i),i_periodicity_id(i)';
    bsc_dbgen_utils.add_string(h_sql, l_sql);
    l_sql := null;
    FOR h_i IN 1..x_num_data_columns LOOP
        l_sql := ', i_data'||h_i||'(i)';
        --bsc_dbgen_utils.add_string(h_sql, ', i_data'||h_i||'(i)';
        bsc_dbgen_utils.add_string(h_sql, l_sql);
    END LOOP;
    l_sql := ', i_BATCH(i));'||l_newline||
             ' commit;'||    l_newline||
             ' v1_rollup.delete;'||l_newline||
             ' open c2;'||l_newline||
             ' loop'||l_newline||
             ' fetch c2 bulk collect into v1_rollup;'||l_newline||
             ' exit when c2%notfound;'||l_newline||
             ' end loop;'||l_newline||
             ' close c2;'||l_newline||
             ' u_count:=0;'||l_newline||
             ' u_rowid.delete;'||l_newline;
    FOR h_i IN 1..x_num_data_columns LOOP
        l_sql := l_sql||' u_data'||h_i||'.delete;'||l_newline;
    END LOOP;
    l_sql := l_sql||
             ' for i in 1..v1_rollup.count loop'||l_newline||
             ' u_count:=u_count+1;'||l_newline||
             ' u_rowid(u_count):=v1_rollup(i).row_id;'||l_newline;
    FOR h_i IN 1..x_num_data_columns LOOP
        l_sql := l_sql||' u_data'||h_i||'(u_count):=v1_rollup(i).'||x_data_columns(h_i)||';'||l_newline;
    END LOOP;
    l_sql := l_sql||
             ' end loop;'||l_newline||
             ' forall i in 1..u_count'||l_newline||
             ' update '||x_base_table||l_newline;
    bsc_dbgen_utils.add_string(h_sql, l_sql);
    l_sql :=null;

    IF x_parallel_jobs = 'Y' THEN
        l_sql := l_sql||' partition('||x_partition_name||')';
    END IF;
    l_sql := l_sql||
             ' set '||x_data_columns(1)||'=u_data1(i)';
    FOR h_i IN 2..x_num_data_columns LOOP
        l_sql := l_sql||', '||x_data_columns(h_i)||' = u_data'||h_i||'(i)'||l_newline;
    END LOOP;
    l_sql := l_sql||
             ' where '||x_base_table||'.rowid=u_rowid(i);'||l_newline||
             ' commit;'||l_newline||
             ' end loop;'||l_newline||
             ' end;';
   bsc_dbgen_utils.add_string(h_sql, l_sql);

   --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
   BSC_DBGEN_UTILS.Execute_Immediate(h_sql);
    commit;
    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Create_Proc_Load_Tbl_MV.e_others: '||SQLERRM;

END Create_Proc_Load_Tbl_MV;


/*===========================================================================+
| PROCEDURE Create_Proc_Load_Tbl_SUM_AW
+============================================================================*/
PROCEDURE Create_Proc_Load_Tbl_SUM_AW(
    x_proc_name IN VARCHAR2,
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_num_loads IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS
    --h_sql CLOB;
    h_sql dbms_sql.varchar2A;
    h_i NUMBER;
    h_calendar_source VARCHAR2(20);
    h_yearly_flag NUMBER;
    h_periodicity_type NUMBER;

BEGIN
    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(x_calendar_id);
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_periodicity_type := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_periodicity);

    bsc_dbgen_utils.add_string(h_sql, 'create or replace procedure '||x_proc_name||' as'||
             ' type bsc_b_r is record(');
    FOR h_i IN 1..x_num_key_columns LOOP
        -- Fix bug#4880895 use varchar2 to support bis dimensions
        bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||' varchar2(400), ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'year number(5), type number(3), period number(5)');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i)||' number'||
                 ', B_DATA'||h_i||' number');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' number, row_id rowid);'||
             ' type bsc_b_t is table of bsc_b_r index by pls_integer;'||
             ' type t_rowid_table is table of rowid index by pls_integer;'||
             ' h_load_batch number;'||
             ' h_batch_value number;'||
             ' h_num_partitions number;'||
             ' h_periodicity number := '||x_periodicity||';'||
             ' cursor c1 is'||
             ' select ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_input_table||'.'||x_key_columns(h_i)||', ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||x_data_columns(h_i)||
                 ', '||x_base_table||'.'||x_data_columns(h_i));
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||
             ', '||x_base_table||'.rowid row_id'||
             ' FROM (SELECT ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_key_dim_tables(h_i)||'.CODE '||x_key_columns(h_i)||', ');
    END LOOP;
    IF h_calendar_source = 'BSC' THEN
        bsc_dbgen_utils.add_string(h_sql, x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD');
    ELSE
        -- BIS calendar
        IF h_yearly_flag = 1 THEN
            bsc_dbgen_utils.add_string(h_sql, 'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, 0 PERIOD');
        ELSE
            bsc_dbgen_utils.add_string(h_sql, 'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, BSC_SYS_PERIODS.PERIOD_ID PERIOD');
        END IF;
    END IF;
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||x_data_columns(h_i));
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||
             ' FROM (SELECT /*+ ordered */ ');
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, 'h_batch_value '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
    ELSE
        IF x_num_partitions > 0 THEN
            bsc_dbgen_utils.add_string(h_sql, ' dbms_utility.get_hash_value(');
            FOR h_i IN 1..x_num_key_columns LOOP
                IF h_i = 1 THEN
                    bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i));
                ELSE
                    bsc_dbgen_utils.add_string(h_sql, '||''.''||'||x_key_columns(h_i));
                END IF;
            END LOOP;
            bsc_dbgen_utils.add_string(h_sql, ', 0, h_num_partitions) '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
        ELSE
            bsc_dbgen_utils.add_string(h_sql, ' 0 '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);
        END IF;
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ', '||x_input_table||'.*'||
             ' FROM '||x_rowid_table||', '||x_input_table||
             ' WHERE '||x_rowid_table||'.row_id = '||x_input_table||'.rowid and'||
             ' '||x_rowid_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_load_batch');
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' and dbms_utility.get_hash_value(');
        FOR h_i IN 1..x_num_key_columns LOOP
            IF h_i = 1 THEN
                bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i));
            ELSE
                bsc_dbgen_utils.add_string(h_sql, '||''.''||'||x_key_columns(h_i));
            END IF;
        END LOOP;
        bsc_dbgen_utils.add_string(h_sql, ', 0, h_num_partitions) = h_batch_value');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ') '||x_input_table);
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_key_dim_tables(h_i));
    END LOOP;
    IF h_calendar_source <> 'BSC' THEN
        -- BIS calendar
        bsc_dbgen_utils.add_string(h_sql, ', BSC_SYS_PERIODS');
    END IF;
    IF x_num_key_columns > 0 THEN
        bsc_dbgen_utils.add_string(h_sql, ' WHERE '||
                 x_input_table||'.'||x_key_columns(1)||' = '||x_key_dim_tables(1)||'.USER_CODE');
        FOR h_i IN 2..x_num_key_columns LOOP
            bsc_dbgen_utils.add_string(h_sql, ' AND '||
                     x_input_table||'.'||x_key_columns(h_i)||' = '||x_key_dim_tables(h_i)||'.USER_CODE');
        END LOOP;
    END IF;
    IF h_calendar_source <> 'BSC' THEN
        -- BIS calendar
        IF x_num_key_columns > 0 THEN
            bsc_dbgen_utils.add_string(h_sql, ' AND');
        ELSE
            bsc_dbgen_utils.add_string(h_sql, ' WHERE');
        END IF;
        IF h_periodicity_type = 9 THEN
            -- It is a daily periodicity. The TIME_FK column in the input table is of type DATE.
            bsc_dbgen_utils.add_string(h_sql,
                     ' TRUNC('||x_input_table||'.TIME_FK) = TRUNC(TO_DATE(BSC_SYS_PERIODS.TIME_FK, ''MM/DD/YYYY'')) AND'||
                     ' BSC_SYS_PERIODS.PERIODICITY_ID = h_periodicity');
        ELSE
            -- Other periodicity. TIME_FK is VARCHAR2
            bsc_dbgen_utils.add_string(h_sql,
                     ' '||x_input_table||'.TIME_FK = BSC_SYS_PERIODS.TIME_FK AND'||
                     ' BSC_SYS_PERIODS.PERIODICITY_ID = h_periodicity');
        END IF;
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ') '||x_input_table||
             ',	(select * from '||x_base_table);
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' where '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = h_batch_value');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ') '||x_base_table||
             ' where ');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_input_table||'.'||x_key_columns(h_i)||' = '||x_base_table||'.'||x_key_columns(h_i)||'(+) and ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, x_input_table||'.YEAR = '||x_base_table||'.YEAR(+) and '||
             x_input_table||'.TYPE = '||x_base_table||'.TYPE(+) and '||
             x_input_table||'.PERIOD = '||x_base_table||'.PERIOD(+);'||
             ' v1 bsc_b_t;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' u_data'||h_i||'_table dbms_sql.number_table;');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ' u_rowid_table t_rowid_table;');
    FOR h_i IN 1..x_num_key_columns LOOP
        -- Fix bug#4880895 use varchar2 to support bis dimensions
        bsc_dbgen_utils.add_string(h_sql, ' i_'||x_key_columns(h_i)||' dbms_sql.varchar2_table;');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_YEAR dbms_sql.number_table;'||
             ' i_TYPE dbms_sql.number_table;'||
             ' i_PERIOD dbms_sql.number_table;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_data'||h_i||' dbms_sql.number_table;');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_BATCH dbms_sql.number_table;');
    IF x_aw_flag THEN
        bsc_dbgen_utils.add_string(h_sql,
                 ' i_PROJECTION dbms_sql.varchar2_table;');
    END IF;
    bsc_dbgen_utils.add_string(h_sql,
             ' u_count integer := 0;'||
             ' i_count integer := 0;'||
             ' begin');
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' h_batch_value := '||x_batch_value||';');
    ELSE
        bsc_dbgen_utils.add_string(h_sql, ' h_batch_value := 0;');
    END IF;
    bsc_dbgen_utils.add_string(h_sql,
             ' h_num_partitions := '||x_num_partitions||';'||
             ' for k in 0..'||x_num_loads||' loop'||
             ' h_load_batch := k;'||
             ' v1.delete;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' u_data'||h_i||'_table.delete;');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ' u_rowid_table.delete;');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_'||x_key_columns(h_i)||'.delete;');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_YEAR.delete;'||
             ' i_TYPE.delete;'||
             ' i_PERIOD.delete;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_data'||h_i||'.delete;');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_BATCH.delete;');
    IF x_aw_flag THEN
        bsc_dbgen_utils.add_string(h_sql,
                 ' i_PROJECTION.delete;');
    END IF;
    -- Fix bug#4915276: use nvl() since 10<>null is false
    bsc_dbgen_utils.add_string(h_sql,
             ' u_count := 0;'||
             ' i_count := 0;'||
             ' open c1;'||
             ' loop'||
             ' fetch c1 bulk collect into v1;'||
             ' exit when c1%notfound;'||
             ' end loop;'||
             ' close c1;'||
             ' for i in 1..v1.count loop'||
             ' if v1(i).row_id is not null then'||
             ' if nvl(v1(i).b_data1,-9999999999)<>nvl(v1(i).'||x_data_columns(1)||',-9999999999)');
    FOR h_i IN 2..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' OR nvl(v1(i).b_data'||h_i||',-9999999999)<>nvl(v1(i).'||x_data_columns(h_i)||',-9999999999)');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, ' then'||
             ' u_count := u_count+1;'||
             ' u_rowid_table(u_count) := v1(i).row_id;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' u_data'||h_i||'_table(u_count) := v1(i).'||x_data_columns(h_i)||';');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' end if;'||
             ' else'||
             ' i_count := i_count+1;');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_'||x_key_columns(h_i)||'(i_count) := v1(i).'||x_key_columns(h_i)||';');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_YEAR(i_count) := v1(i).year;'||
             ' i_TYPE(i_count) := v1(i).type;'||
             ' i_PERIOD(i_count) := v1(i).period;');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ' i_data'||h_i||'(i_count) := v1(i).'||x_data_columns(h_i)||';');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql,
             ' i_BATCH(i_count) := v1(i).'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||';');
    IF x_aw_flag THEN
        IF h_yearly_flag = 1 THEN
            bsc_dbgen_utils.add_string(h_sql,
                     ' if v1(i).year>'||x_current_fy||' then');
        ELSE
            bsc_dbgen_utils.add_string(h_sql,
                    ' if (v1(i).year='||x_current_fy||' and v1(i).period>'||x_current_period||') or'||
                    ' v1(i).year>'||x_current_fy||' then');
        END IF;
        bsc_dbgen_utils.add_string(h_sql,
                 ' i_PROJECTION(i_count) := ''Y'';'||
                 ' else'||
                 ' i_PROJECTION(i_count) := ''N'';'||
                 ' end if;');
    END IF;
    bsc_dbgen_utils.add_string(h_sql,
             ' end if;'||
             ' end loop;'||
             ' forall i in 1..u_count'||
             ' update '||x_base_table);
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' partition('||x_partition_name||')');
    END IF;
    bsc_dbgen_utils.add_string(h_sql,
             ' set '||x_data_columns(1)||' = u_data1_table(i)');
    FOR h_i IN 2..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i)||' = u_data'||h_i||'_table(i)');
    END LOOP;
    IF x_aw_flag THEN
        bsc_dbgen_utils.add_string(h_sql, ', CHANGE_VECTOR = '||x_change_vector_value);
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ' where '||x_base_table||'.rowid = u_rowid_table(i);'||
             ' forall i in 1..i_count'||
             ' insert /*+append*/ into '||x_base_table);
    IF x_parallel_jobs = 'Y' THEN
        bsc_dbgen_utils.add_string(h_sql, ' partition('||x_partition_name||')');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ' (');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, x_key_columns(h_i)||', ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'YEAR, TYPE, PERIOD');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', '||x_data_columns(h_i));
    END LOOP;
    IF x_aw_flag THEN
        bsc_dbgen_utils.add_string(h_sql, ', PROJECTION, CHANGE_VECTOR');
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ', '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||')'||
             ' values(');
    FOR h_i IN 1..x_num_key_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, 'i_'||x_key_columns(h_i)||'(i), ');
    END LOOP;
    bsc_dbgen_utils.add_string(h_sql, 'i_YEAR(i), i_TYPE(i), i_PERIOD(i)');
    FOR h_i IN 1..x_num_data_columns LOOP
        bsc_dbgen_utils.add_string(h_sql, ', i_data'||h_i||'(i)');
    END LOOP;
    IF x_aw_flag THEN
        bsc_dbgen_utils.add_string(h_sql, ', i_PROJECTION(i), '||x_change_vector_value);
    END IF;
    bsc_dbgen_utils.add_string(h_sql, ', i_BATCH(i));'||
             ' commit;'||
             ' end loop;'||
             ' end;');

    -- Create the stored procedure
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    BSC_DBGEN_UTILS.Execute_Immediate(h_sql);
    commit;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Create_Proc_Load_Tbl_SUM_AW.e_others: '||SQLERRM;

END Create_Proc_Load_Tbl_SUM_AW;


/*===========================================================================+
| PROCEDURE Create_Types_for_MV_Load
+============================================================================*/
PROCEDURE Create_Types_For_MV_Load(
    x_base_table IN VARCHAR2,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_data_columns IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    h_i NUMBER;
    h_sql VARCHAR2(32000);

BEGIN

   h_sql := 'drop type '||x_base_table||'_tt';
   begin execute immediate h_sql; exception when others then null; end;

   h_sql := 'drop type '||x_base_table||'_t';
   begin execute immediate h_sql; exception when others then null; end;

   h_sql := 'create or replace type '||x_base_table||'_t as object(';
   for h_i IN 1..x_num_key_columns loop
       -- Fix bug#4880895 use varchar2 to support bis dimensions
       h_sql := h_sql|| ' '||x_key_columns(h_i)||' varchar2(400),';
   end loop;
   h_sql := h_sql|| ' year number(5), type number(3), period number(5), periodicity_id number';
   for h_i IN 1..x_num_data_columns loop
       h_sql := h_sql|| ', '||x_data_columns(h_i)||' number';
   end loop;
   h_sql := h_sql|| ', row_id varchar2(32), is_null number)';
   execute immediate h_sql;

   h_sql := 'create or replace type '||x_base_table||'_tt is table of '||x_base_table||'_t';
   execute immediate h_sql;

   x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Create_Types_For_MV_Load.e_others: '||SQLERRM;

END Create_Types_For_MV_Load;


/*===========================================================================+
| FUNCTION Get_Base_Proj_Tbl_Name
+============================================================================*/
FUNCTION Get_Base_Proj_Tbl_Name(
    x_base_table IN VARCHAR2
) RETURN VARCHAR2 IS
    h_list dbms_sql.varchar2_table;
    h_values dbms_sql.varchar2_table;
BEGIN
    h_list.delete;
    h_list(1) := BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE;
    h_values := BSC_DBGEN_METADATA_READER.Get_Table_Properties(x_base_table, h_list);
    RETURN h_values(1);
END Get_Base_Proj_Tbl_Name;


/*===========================================================================+
| PROCEDURE Init_Bsc_Db_Calendar_Temp
+============================================================================*/
PROCEDURE Init_Bsc_Db_Calendar_Temp(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    CURSOR c_upper_periodicities (p_table_name VARCHAR2, p_calc_type NUMBER) IS
        SELECT c.parameter1, p.yearly_flag, p.db_column_name
        FROM bsc_db_calculations c, bsc_sys_periodicities p
        WHERE c.table_name = p_table_name AND c.calculation_type = p_calc_type AND
              c.parameter1 = p.periodicity_id;

    h_column_name VARCHAR2(30);
    h_up_periodicity NUMBER;
    h_up_yearly_flag NUMBER;
    h_up_column_name VARCHAR2(30);
    h_up_current_period NUMBER;
    h_y VARCHAR2(1);
    h_n VARCHAR2(1);

BEGIN
    BSC_UPDATE_UTIL.Truncate_Table('BSC_DB_CALENDAR_TEMP');
    commit;

    h_column_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);
    h_y := 'Y';
    h_n := 'N';

    OPEN c_upper_periodicities(x_base_table, 6);
    LOOP
        FETCH c_upper_periodicities INTO h_up_periodicity, h_up_yearly_flag, h_up_column_name;
        EXIT WHEN c_upper_periodicities%NOTFOUND;

        IF h_up_yearly_flag = 1 THEN
            h_sql := 'insert into bsc_db_calendar_temp ('||
                     ' lower_period, upper_period, year, last_period, periodicity_id)'||
                     ' select cal.'||h_column_name||', 0, cal.year,'||
                     ' case when cal.'||h_column_name||' = :1 and cal.year = :2 then :3'||
                     ' when cal.year <> :4 and bal.'||h_column_name||' is not null then :5'||
                     ' else :6 end case, :7'||
                     ' from '||
                     ' (select distinct '||h_column_name||', year'||
                     '  from bsc_db_calendar'||
                     '  where calendar_id = :8) cal,'||
                     ' (select max('||h_column_name||') '||h_column_name||', year'||
                     '  from bsc_db_calendar'||
                     '  where calendar_id = :9'||
                     '  group by year) bal'||
                     '  where cal.'||h_column_name||' = bal.'||h_column_name||' (+) and'||
                     '  cal.year = bal.year (+)';
            execute immediate h_sql using x_current_period, x_current_fy, h_y, x_current_fy,
                h_y, h_n, h_up_periodicity, x_calendar_id, x_calendar_id;
            commit;
        ELSE
            -- Get current period in upper periodicity
            h_sql :=  'select max('||h_up_column_name||')'||
                     ' from bsc_db_calendar'||
                     ' where calendar_id = :1 and '||h_column_name||' = :2 and year = :3';
            OPEN h_cursor FOR h_sql USING x_calendar_id, x_current_period, x_current_fy;
            FETCH h_cursor INTO h_up_current_period;
            CLOSE h_cursor;

            h_sql := 'insert into bsc_db_calendar_temp ('||
                     ' lower_period, upper_period, year, last_period, periodicity_id)'||
                     ' select cal.'||h_column_name||', cal.'||h_up_column_name||', cal.year,'||
                     ' case when cal.'||h_column_name||' = :1 and cal.year = :2 then :3'||
                     ' when not (cal.'||h_up_column_name||' = :4 and cal.year = :5) and'||
                     ' bal.'||h_column_name||' is not null then :6'||
                     ' else :7 end case, :8'||
                     ' from'||
                     ' (select distinct '||h_column_name||', '||h_up_column_name||', year'||
                     '  from bsc_db_calendar'||
                     '  where calendar_id = :9) cal,'||
                     ' (select max('||h_column_name||') '||h_column_name||', '||h_up_column_name||', year'||
                     ' from bsc_db_calendar'||
                     ' where calendar_id = :10'||
                     ' group by '||h_up_column_name||', year) bal'||
                     ' where cal.'||h_column_name||' = bal.'||h_column_name||' (+) and'||
                     ' cal.'||h_up_column_name||' = bal.'||h_up_column_name||' (+) and'||
                     ' cal.year = bal.year (+)';
            execute immediate h_sql using x_current_period, x_current_fy, h_y, h_up_current_period,
                x_current_fy, h_y, h_n, h_up_periodicity, x_calendar_id, x_calendar_id;
            commit;
        END IF;
    END LOOP;
    CLOSE c_upper_periodicities;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Init_Bsc_Db_Calendar_Temp.e_others: '||SQLERRM;

END Init_Bsc_Db_Calendar_Temp;


/*===========================================================================+
| PROCEDURE Init_Bsc_Db_Calendar_Temp_Proj
+============================================================================*/
PROCEDURE Init_Bsc_Db_Calendar_Temp_Proj(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    CURSOR c_upper_periodicities (p_table_name VARCHAR2, p_calc_type NUMBER) IS
        SELECT c.parameter1, p.yearly_flag, p.db_column_name
        FROM bsc_db_calculations c, bsc_sys_periodicities p
        WHERE c.table_name = p_table_name AND c.calculation_type = p_calc_type AND
              c.parameter1 = p.periodicity_id;

    h_column_name VARCHAR2(30);
    h_up_periodicity NUMBER;
    h_up_yearly_flag NUMBER;
    h_up_column_name VARCHAR2(30);
    h_up_current_period NUMBER;
    h_y VARCHAR2(1);
    h_n VARCHAR2(1);

BEGIN
    BSC_UPDATE_UTIL.Truncate_Table('BSC_DB_CALENDAR_TEMP');
    commit;

    h_column_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);
    h_y := 'Y';
    h_n := 'N';

    OPEN c_upper_periodicities(x_base_table, 6);
    LOOP
        FETCH c_upper_periodicities INTO h_up_periodicity, h_up_yearly_flag, h_up_column_name;
        EXIT WHEN c_upper_periodicities%NOTFOUND;

        -- We do not insert yearly periodicity. Projection need to be recalculated for yearly.
        -- We do not want periods corresponding to actual

        IF h_up_yearly_flag <> 1 THEN
            -- Get current period in upper periodicity
            h_sql := 'select max('||h_up_column_name||')'||
                     ' from bsc_db_calendar'||
                     ' where calendar_id = :1 and '||h_column_name||' = :2 and year = :3';
            OPEN h_cursor FOR h_sql USING x_calendar_id, x_current_period, x_current_fy;
            FETCH h_cursor INTO h_up_current_period;
            CLOSE h_cursor;

            h_sql := 'insert into bsc_db_calendar_temp ('||
                     ' lower_period, upper_period, year, last_period, periodicity_id)'||
                     ' select cal.'||h_column_name||', cal.'||h_up_column_name||', cal.year,'||
                     ' case when bal.'||h_column_name||' is not null then :1'||
                     ' else :2 end case, :3'||
                     ' from (select distinct '||h_column_name||', '||h_up_column_name||', year'||
                     ' from bsc_db_calendar'||
                     ' where calendar_id = :4 and year = :5 and '||h_up_column_name||' > :6) cal,'||
                     ' (select max('||h_column_name||') '||h_column_name||', '||h_up_column_name||', year'||
                     ' from bsc_db_calendar'||
                     ' where calendar_id = :7 and year = :8 and '||h_up_column_name||' > :9'||
                     ' group by '||h_up_column_name||', year) bal'||
                     ' where cal.'||h_column_name||' = bal.'||h_column_name||' (+) and'||
                     ' cal.'||h_up_column_name||' = bal.'||h_up_column_name||' (+) and'||
                     ' cal.year = bal.year (+)';
            execute immediate h_sql using h_y, h_n, h_up_periodicity, x_calendar_id, x_current_fy,
                h_up_current_period, x_calendar_id, x_current_fy, h_up_current_period;
            commit;
        END IF;
    END LOOP;
    CLOSE c_upper_periodicities;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := 'error';
        x_error_message := 'Init_Bsc_Db_Calendar_Temp_Proj.e_others: '||SQLERRM;

END Init_Bsc_Db_Calendar_Temp_Proj;


/*===========================================================================+
| PROCEDURE Load_Input_Table_Inc
+============================================================================*/
PROCEDURE Load_Input_Table_Inc(
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_num_loads IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    e_create_proc_load_tbl_sum_aw EXCEPTION;
    e_create_proc_load_tbl_mv EXCEPTION;
    e_create_dynamic_proc_name EXCEPTION;

    h_return_status VARCHAR2(50);
    h_error_message VARCHAR2(2000);

    h_i NUMBER;
    h_sql VARCHAR2(32000);
    h_key_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;

    h_level_table_name VARCHAR2(100);
    h_level_short_name VARCHAR2(300);
    h_level_source VARCHAR2(100);
    h_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

    h_proc_name VARCHAR2(30);
    h_proc_temp VARCHAR2(30);
    h_proc_occur NUMBER;
    h_proc_loop_size NUMBER;
    h_proc_count NUMBER; --rkumar:bug#5721341
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

BEGIN

    FOR h_i IN 1..x_num_key_columns LOOP
        h_level_table_name := x_key_dim_tables(h_i);
        -- BSC-BIS-DIMENSIONS: If the dimension is a DBI dimension and it is materialized and
        -- the table exists then we use the table created in BSC to materialize
        -- the DBI dimension to translate from USER_CODE into CODE.
        -- Note that is only in MV Architecture.
        IF BSC_APPS.bsc_mv THEN
            SELECT short_name, source
            INTO h_level_short_name, h_level_source
            FROM bsc_sys_dim_levels_b
            WHERE level_view_name = h_level_table_name;

            IF (h_level_source = 'PMF') AND (h_level_short_name IS NOT NULL) THEN
                BSC_UPDATE_DIM.Get_Dbi_Dim_Data(h_level_short_name, h_dbi_dim_data);
                IF (h_dbi_dim_data.short_name IS NOT NULL) AND
                   (h_dbi_dim_data.table_name IS NOT NULL) AND
                   (h_dbi_dim_data.materialized='YES') THEN
                    IF BSC_APPS.Table_Exists(h_dbi_dim_data.table_name) THEN
                        h_level_table_name := h_dbi_dim_data.table_name;
                    END IF;
                END IF;
            END IF;
        END IF;
        h_key_dim_tables(h_i) := h_level_table_name;
    END LOOP;

	--rkumar:bug5721341 (Long input table names results in "character string buffer too small error")
	--h_proc_count is the counter based on which we are creating the dynamic procedure
	--h_proc_occur stores the number of time a particular request occurs (if at all)
	--h_proc_loop_size determines how many times should we loop (normally its 99
	--but in case of parallel jobs its 9 only
	h_proc_name	:= x_input_table;
	h_proc_loop_size :=99;
	h_proc_count :=0;
	h_proc_occur :=0;
        h_sql:='select count (*) from USER_OBJECTS where OBJECT_TYPE=''PROCEDURE'''||
	        'and OBJECT_NAME=:1';
	IF x_parallel_jobs = 'Y' THEN
	  h_proc_name := h_proc_name||substr(x_partition_name,instr(x_partition_name,'_')+1);
	  h_proc_loop_size :=9;
	END IF;
	h_proc_temp :='LD$'||h_proc_name;
	--rkumar:check if the procedure is already there in the database.
	open h_cursor for h_sql using h_proc_temp;
	fetch h_cursor into h_proc_occur;
        close h_cursor;
	while h_proc_occur > 0 LOOP
	  if (h_proc_count > h_proc_loop_size) then
	    h_error_message:='Loader process can not create load procedure '||h_proc_name
		  ||'as it already exists. Please contact your System Administrator or Oracle Support.';
        RAISE e_create_dynamic_proc_name;
	  end if;
	  h_proc_occur :=0;
	  h_proc_temp := 'LD$'||h_proc_count||h_proc_name;
	  h_proc_count := h_proc_count +1;
	  open h_cursor for h_sql using h_proc_temp;
	  fetch h_cursor into h_proc_occur;
      close h_cursor;
	END LOOP;
	h_proc_name := h_proc_temp;    --rkumar:this is the final procedure name, now create it in the next line

    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        -- MV architecture
        Create_Proc_Load_Tbl_MV(h_proc_name,
                                x_base_table,
                                x_input_table,
                                x_periodicity,
                                x_calendar_id,
                                x_current_period,
                                x_old_current_period,
                                x_current_fy,
                                x_key_columns,
                                h_key_dim_tables,
                                x_num_key_columns,
                                x_data_columns,
                                x_data_formulas,
                                x_data_measure_types,
                                x_num_data_columns,
                                x_partition_name,
                                x_batch_value,
                                x_num_partitions,
                                x_parallel_jobs,
                                x_rowid_table,
                                x_num_loads,
                                h_return_status,
                                h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_create_proc_load_tbl_mv;
        END IF;

    ELSE
        -- Summary or AW architecture
        -- Create dynamically the stored procedure to load the input table
        Create_Proc_Load_Tbl_SUM_AW(h_proc_name,
                                    x_base_table,
                                    x_input_table,
                                    x_aw_flag,
                                    x_change_vector_value,
                                    x_periodicity,
                                    x_calendar_id,
                                    x_current_period,
                                    x_current_fy,
                                    x_key_columns,
                                    h_key_dim_tables,
                                    x_num_key_columns,
                                    x_data_columns,
                                    x_num_data_columns,
                                    x_partition_name,
                                    x_batch_value,
                                    x_num_partitions,
                                    x_parallel_jobs,
                                    x_rowid_table,
                                    x_num_loads,
                                    h_return_status,
                                    h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_create_proc_load_tbl_sum_aw;
        END IF;
    END IF;

    -- Execute the stored procedure
    h_sql := 'BEGIN '||h_proc_name||'; END;';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    COMMIT;

    -- Drop the stored procedure
    h_sql := 'DROP PROCEDURE '||h_proc_name;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    COMMIT;
    x_return_status := 'success';

EXCEPTION
    WHEN e_create_proc_load_tbl_sum_aw THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Load_Input_Table_Inc.e_create_proc_load_tbl_sum_aw: '||h_error_message;

    WHEN e_create_proc_load_tbl_mv THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Load_Input_Table_Inc.e_create_proc_load_tbl_mv: '||h_error_message;

    WHEN e_create_dynamic_proc_name THEN  --rkumar:bug5721341
        rollback;
        x_return_status := 'error';
        x_error_message := 'Load_Input_Table_Inc.e_create_dynamic_proc_name: '||h_error_message;

    WHEN OTHERS THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Load_Input_Table_Inc.e_others: '||SQLERRM;

END Load_Input_Table_Inc;



/*===========================================================================+
| PROCEDURE  Load_Input_Table_Initial
+============================================================================*/
PROCEDURE Load_Input_Table_Initial(
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_period IN NUMBER,
    x_current_fy IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    h_sql VARCHAR2(32000);
    h_i NUMBER;
    h_key_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;

    h_level_table_name VARCHAR2(100);
    h_level_short_name VARCHAR2(300);
    h_level_source VARCHAR2(100);
    h_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

    h_calendar_source VARCHAR2(20);
    h_yearly_flag NUMBER;
    h_periodicity_type NUMBER;

BEGIN
    h_num_bind_vars := 0;

    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(x_calendar_id);
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_periodicity_type := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_periodicity);

    FOR h_i IN 1..x_num_key_columns LOOP
        h_level_table_name := x_key_dim_tables(h_i);
        -- BSC-BIS-DIMENSIONS: If the dimension is a DBI dimension and it is materialized and
        -- the table exists then we use the table created in BSC to materialize
        -- the DBI dimension to translate from USER_CODE into CODE.
        -- Note that is only in MV Architecture.
        IF BSC_APPS.bsc_mv THEN
            SELECT short_name, source
            INTO h_level_short_name, h_level_source
            FROM bsc_sys_dim_levels_b
            WHERE level_view_name = h_level_table_name;

            IF (h_level_source = 'PMF') AND (h_level_short_name IS NOT NULL) THEN
                BSC_UPDATE_DIM.Get_Dbi_Dim_Data(h_level_short_name, h_dbi_dim_data);
                IF (h_dbi_dim_data.short_name IS NOT NULL) AND
                   (h_dbi_dim_data.table_name IS NOT NULL) AND
                   (h_dbi_dim_data.materialized='YES') THEN
                    IF BSC_APPS.Table_Exists(h_dbi_dim_data.table_name) THEN
                        h_level_table_name := h_dbi_dim_data.table_name;
                    END IF;
                END IF;
            END IF;
        END IF;
        h_key_dim_tables(h_i) := h_level_table_name;
    END LOOP;

    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        -- MV Architecture
        h_num_bind_vars := 0;
        h_bind_vars_values.delete;

        h_sql := 'INSERT /*+ append';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' parallel ('||x_base_table||')';
        END IF;
        h_sql := h_sql||' */ INTO '||x_base_table;
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' PARTITION('||x_partition_name||')';
        END IF;
        h_sql := h_sql||' ('||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||x_key_columns(h_i)||', ';
        END LOOP;
        h_sql := h_sql||'YEAR, TYPE, PERIOD, PERIODICITY_ID';
        FOR h_i IN 1..x_num_data_columns LOOP
            h_sql := h_sql||', '||x_data_columns(h_i);
        END LOOP;
        h_sql := h_sql||')'||
                 ' WITH BSC_I_DATA AS ('||
                 ' SELECT';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' /*+ parallel ('||x_input_table||')';
            FOR h_i IN 1..x_num_key_columns LOOP
                h_sql := h_sql||' parallel('||h_key_dim_tables(h_i)||')';
            END LOOP;
            IF h_calendar_source <> 'BSC' THEN
                -- Input table is using a BIS calendar
                h_sql := h_sql||' parallel(BSC_SYS_PERIODS)';
            END IF;
            h_sql := h_sql||' */';
        END IF;
        h_sql := h_sql||' '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||h_key_dim_tables(h_i)||'.CODE '||x_key_columns(h_i)||', ';
        END LOOP;
        IF h_calendar_source = 'BSC' THEN
            h_sql := h_sql||x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD';
        ELSE
            -- BIS calendar
            IF h_yearly_flag = 1 THEN
                h_sql := h_sql||'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, 0 PERIOD';
            ELSE
                h_sql := h_sql||'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, BSC_SYS_PERIODS.PERIOD_ID PERIOD';
            END IF;
        END IF;
        h_sql := h_sql||', :1 PERIODICITY_ID';
        h_num_bind_vars := h_num_bind_vars + 1;
        h_bind_vars_values(h_num_bind_vars) := x_periodicity;
        FOR h_i IN 1..x_num_data_columns LOOP
            h_sql := h_sql||', '||x_input_table||'.'||x_data_columns(h_i);
        END LOOP;
        h_sql := h_sql||' FROM (SELECT';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' /*+ parallel ('||x_input_table||') */';
        END IF;
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' :2 '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_batch_value;
        ELSE
            IF x_num_partitions > 0 THEN
                h_sql := h_sql||' DBMS_UTILITY.Get_Hash_Value(';
                FOR h_i IN 1..x_num_key_columns LOOP
                    IF h_i = 1 THEN
                        h_sql := h_sql||x_key_columns(h_i);
                    ELSE
                        h_sql := h_sql||'||''.''||'||x_key_columns(h_i);
                    END IF;
                END LOOP;
                h_sql := h_sql||', 0, :2) '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := x_num_partitions;
            ELSE
                h_sql := h_sql||' :2 '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := 0;
            END IF;
        END IF;
        h_sql := h_sql||', '||x_input_table||'.*'||
                 ' FROM '||x_input_table;
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' WHERE DBMS_UTILITY.Get_Hash_Value(';
            FOR h_i IN 1..x_num_key_columns LOOP
                IF h_i = 1 THEN
                    h_sql := h_sql||x_key_columns(h_i);
                ELSE
                    h_sql := h_sql||'||''.''||'||x_key_columns(h_i);
                END IF;
            END LOOP;
            h_sql := h_sql||', 0, :3) = :4';
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_num_partitions;
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_batch_value;
        END IF;
        h_sql := h_sql||') '||x_input_table;
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||', '||h_key_dim_tables(h_i);
        END LOOP;
        IF h_calendar_source <> 'BSC' THEN
            -- BIS calendar
            h_sql := h_sql||', BSC_SYS_PERIODS';
        END IF;
        IF x_num_key_columns > 0 THEN
            h_sql := h_sql||' WHERE'||
                     ' '||x_input_table||'.'||x_key_columns(1)||' = '||h_key_dim_tables(1)||'.USER_CODE';
            FOR h_i IN 2..x_num_key_columns LOOP
                h_sql := h_sql||' AND '||x_input_table||'.'||x_key_columns(h_i)||' = '||h_key_dim_tables(h_i)||'.USER_CODE';
            END LOOP;
        END IF;
        IF h_calendar_source <> 'BSC' THEN
            -- BIS calendar
            IF x_num_key_columns > 0 THEN
                h_sql := h_sql||' AND';
            ELSE
                h_sql := h_sql||' WHERE';
            END IF;
            IF h_periodicity_type = 9 THEN
                -- It is a daily periodicity. The TIME_FK column in the input table is of type DATE.
                h_sql := h_sql||
                         ' TRUNC('||x_input_table||'.TIME_FK) = TRUNC(TO_DATE(BSC_SYS_PERIODS.TIME_FK, ''MM/DD/YYYY'')) AND'||
                         ' BSC_SYS_PERIODS.PERIODICITY_ID = :5';
            ELSE
                -- Other periodicity. TIME_FK is VARCHAR2
                h_sql := h_sql||
                         ' '||x_input_table||'.TIME_FK = BSC_SYS_PERIODS.TIME_FK AND'||
		    	 ' BSC_SYS_PERIODS.PERIODICITY_ID = :5';
            END IF;
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_periodicity;
        END IF;
        h_sql := h_sql||')'||
                 ' SELECT';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' /*+ parallel ('||x_input_table||') */';
        END IF;
        h_sql := h_sql||' '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||x_input_table||'.'||x_key_columns(h_i)||', ';
        END LOOP;
        h_sql := h_sql||x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD, '||
                 x_input_table||'.PERIODICITY_ID';
        FOR h_i IN 1..x_num_data_columns LOOP
            h_sql := h_sql||', '||x_input_table||'.'||x_data_columns(h_i);
        END LOOP;
        h_sql := h_sql||' FROM ('||
                 ' SELECT';
        -- Fix bug#5155523 Do not use parallel hint on BSC_I_DATA
        --IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
        --    h_sql := h_sql||' /*+ parallel (BSC_I_DATA) */';
        --END IF;
        h_sql := h_sql||' BSC_I_DATA.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||'BSC_I_DATA.'||x_key_columns(h_i)||', ';
        END LOOP;
        h_sql := h_sql||'BSC_I_DATA.YEAR, BSC_I_DATA.TYPE, BSC_I_DATA.PERIOD, BSC_I_DATA.PERIODICITY_ID';
        FOR h_i IN 1..x_num_data_columns LOOP
            h_sql := h_sql||', BSC_I_DATA.'||x_data_columns(h_i);
        END LOOP;
        h_sql := h_sql||' FROM BSC_I_DATA'||
                 ' UNION ALL'||
                 ' SELECT';
        -- Fix bug#5155523 Do not use parallel hint on BSC_I_DATA or BSC_DB_CALENDAR_TEMP
        --IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
        --    h_sql := h_sql||' /*+ parallel (BSC_I_DATA) parallel (BSC_DB_CALENDAR_TEMP) */';
        --END IF;
        --Fix bug#5155523 Do not use max(bsc_i_data.batch_column_name) instead add it to the group by
        h_sql := h_sql||' BSC_I_DATA.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' '||
                 BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||'BSC_I_DATA.'||x_key_columns(h_i)||', ';
        END LOOP;
        h_sql := h_sql||'BSC_I_DATA.YEAR, BSC_I_DATA.TYPE, BSC_DB_CALENDAR_TEMP.UPPER_PERIOD PERIOD,'||
                 ' BSC_DB_CALENDAR_TEMP.PERIODICITY_ID';
        FOR h_i IN 1..x_num_data_columns LOOP
            IF x_data_measure_types(h_i) = 1 THEN
                -- Activity measure
                h_sql := h_sql||', '||x_data_formulas(h_i)||' '||x_data_columns(h_i);
            ELSE
                -- Balance measure
                h_sql := h_sql||', SUM(DECODE(BSC_DB_CALENDAR_TEMP.LAST_PERIOD,''Y'','||x_data_columns(h_i)||', NULL))'||
                         ' '||x_data_columns(h_i);
            END IF;
        END LOOP;
        h_sql := h_sql||' FROM BSC_I_DATA, BSC_DB_CALENDAR_TEMP'||
                 ' WHERE BSC_I_DATA.PERIOD = BSC_DB_CALENDAR_TEMP.LOWER_PERIOD AND'||
                 ' BSC_I_DATA.YEAR = BSC_DB_CALENDAR_TEMP.YEAR'||
                 ' GROUP BY BSC_I_DATA.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||'BSC_I_DATA.'||x_key_columns(h_i)||', ';
        END LOOP;
        h_sql := h_sql||'BSC_I_DATA.YEAR, BSC_I_DATA.TYPE, BSC_DB_CALENDAR_TEMP.UPPER_PERIOD,'||
                 ' BSC_DB_CALENDAR_TEMP.PERIODICITY_ID'||
                 ') '||x_input_table;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
        COMMIT;
    ELSE
        -- Summary or AW architecture. No higher periodicities in the base table
        h_num_bind_vars := 0;
        h_bind_vars_values.delete;

        h_sql := 'INSERT /*+ append';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' parallel ('||x_base_table||')';
        END IF;
        h_sql := h_sql||' */ INTO '||x_base_table;
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' PARTITION('||x_partition_name||')';
        END IF;
        h_sql := h_sql||' ('||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||x_key_columns(h_i)||', ';
        END LOOP;
        h_sql := h_sql||'YEAR, TYPE, PERIOD';
        FOR h_i IN 1..x_num_data_columns LOOP
            h_sql := h_sql||', '||x_data_columns(h_i);
        END LOOP;
        IF x_aw_flag THEN
            h_sql := h_sql||', PROJECTION, CHANGE_VECTOR';
        END IF;
        h_sql := h_sql||')'||
                 ' SELECT';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' /*+ parallel ('||x_input_table||')';
            FOR h_i IN 1..x_num_key_columns LOOP
                h_sql := h_sql||' parallel('||h_key_dim_tables(h_i)||')';
            END LOOP;
            IF h_calendar_source <> 'BSC' THEN
                -- Input table is using a BIS calendar
                h_sql := h_sql||' parallel(BSC_SYS_PERIODS)';
            END IF;
            h_sql := h_sql||' */';
        END IF;
        h_sql := h_sql||' '||x_input_table||'.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||h_key_dim_tables(h_i)||'.CODE, ';
        END LOOP;
        IF h_calendar_source = 'BSC' THEN
            h_sql := h_sql||x_input_table||'.YEAR, '||x_input_table||'.TYPE, '||x_input_table||'.PERIOD';
        ELSE
            -- BIS calendar
            IF h_yearly_flag = 1 THEN
                h_sql := h_sql||'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, 0 PERIOD';
            ELSE
                h_sql := h_sql||'BSC_SYS_PERIODS.YEAR, '||x_input_table||'.TYPE, BSC_SYS_PERIODS.PERIOD_ID PERIOD';
            END IF;
        END IF;
        FOR h_i IN 1..x_num_data_columns LOOP
            h_sql := h_sql||', '||x_input_table||'.'||x_data_columns(h_i);
        END LOOP;
        IF x_aw_flag THEN
            IF h_calendar_source = 'BSC' THEN
                IF h_yearly_flag = 1 THEN
                    h_sql := h_sql||', '||
                             ' case when '||x_input_table||'.YEAR > :1'||
                             ' then ''Y'' else ''N'' end PROJECTION';
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                ELSE
                    h_sql := h_sql||', '||
                             ' case when ('||x_input_table||'.YEAR = :1 AND '||
                             x_input_table||'.PERIOD > :2) OR ('||
                             x_input_table||'.YEAR > :3)'||
                             ' then ''Y'' else ''N'' end PROJECTION';
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_period;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                END IF;
            ELSE
                -- BIS calendar
                IF h_yearly_flag = 1 THEN
                    h_sql := h_sql||', '||
                             ' case when BSC_SYS_PERIODS.YEAR > :1'||
                            ' then ''Y'' else ''N'' end PROJECTION';
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                ELSE
                    h_sql := h_sql||', '||
                             ' case when (BSC_SYS_PERIODS.YEAR = :1 AND '||
                             'BSC_SYS_PERIODS.PERIOD_ID > :2) OR ('||
                             'BSC_SYS_PERIODS.YEAR > :3)'||
                             ' then ''Y'' else ''N'' end PROJECTION';
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_period;
                    h_num_bind_vars := h_num_bind_vars + 1;
                    h_bind_vars_values(h_num_bind_vars) := x_current_fy;
                END IF;
            END IF;
            h_sql := h_sql||', :4 CHANGE_VECTOR';
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_change_vector_value;
        END IF;
        h_sql := h_sql||' FROM (SELECT';
        IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
            h_sql := h_sql||' /*+ parallel ('||x_input_table||') */';
        END IF;
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' :5 '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_batch_value;
        ELSE
            IF x_num_partitions > 0 THEN
                h_sql := h_sql||' DBMS_UTILITY.Get_Hash_Value(';
                FOR h_i IN 1..x_num_key_columns LOOP
                    IF h_i = 1 THEN
                        h_sql := h_sql||x_key_columns(h_i);
                    ELSE
                        h_sql := h_sql||'||''.''||'||x_key_columns(h_i);
                    END IF;
                END LOOP;
                h_sql := h_sql||', 0, :5) '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := x_num_partitions;
            ELSE
                h_sql := h_sql||' :5 '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := 0;
            END IF;
        END IF;
        h_sql := h_sql||', '||x_input_table||'.*'||
                 ' FROM '||x_input_table;
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' WHERE DBMS_UTILITY.Get_Hash_Value(';
            FOR h_i IN 1..x_num_key_columns LOOP
                IF h_i = 1 THEN
                    h_sql := h_sql||x_key_columns(h_i);
                ELSE
                    h_sql := h_sql||'||''.''||'||x_key_columns(h_i);
                END IF;
            END LOOP;
            h_sql := h_sql||', 0, :6) = :7';
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_num_partitions;
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_batch_value;
        END IF;
        h_sql := h_sql||') '||x_input_table;
        FOR h_i IN 1..x_num_key_columns LOOP
            h_sql := h_sql||', '||h_key_dim_tables(h_i);
        END LOOP;
        IF h_calendar_source <> 'BSC' THEN
            -- BIS calendar
            h_sql := h_sql||', BSC_SYS_PERIODS';
        END IF;
        IF x_num_key_columns > 0 THEN
            h_sql := h_sql||' WHERE'||
                     ' '||x_input_table||'.'||x_key_columns(1)||' = '||h_key_dim_tables(1)||'.USER_CODE';
            FOR h_i IN 2..x_num_key_columns LOOP
                h_sql := h_sql||' AND '||x_input_table||'.'||x_key_columns(h_i)||' = '||h_key_dim_tables(h_i)||'.USER_CODE';
            END LOOP;
        END IF;
        IF h_calendar_source <> 'BSC' THEN
            -- BIS calendar
            IF x_num_key_columns > 0 THEN
                h_sql := h_sql||' AND';
            ELSE
                h_sql := h_sql||' WHERE';
            END IF;
            IF h_periodicity_type = 9 THEN
                -- It is a daily periodicity. The TIME_FK column in the input table is of type DATE.
                h_sql := h_sql||
                         ' TRUNC('||x_input_table||'.TIME_FK) = TRUNC(TO_DATE(BSC_SYS_PERIODS.TIME_FK, ''MM/DD/YYYY'')) AND'||
                         ' BSC_SYS_PERIODS.PERIODICITY_ID = :8';
            ELSE
                -- Other periodicity. TIME_FK is VARCHAR2
                h_sql := h_sql||
                         ' '||x_input_table||'.TIME_FK = BSC_SYS_PERIODS.TIME_FK AND'||
		    	 ' BSC_SYS_PERIODS.PERIODICITY_ID = :8';
            END IF;
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_periodicity;
        END IF;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
        COMMIT;
    END IF;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Load_Input_Table_Initial.e_others: '||SQLERRM;
END Load_Input_Table_Initial;


/*===========================================================================+
| PROCEDURE  Calc_Higher_Periodicities
+============================================================================*/
PROCEDURE Calc_Higher_Periodicities(
    x_base_table IN VARCHAR2,
    x_periodicity IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) IS

    h_sql VARCHAR2(32000);
    h_i NUMBER;
    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    -- Insert higher periodicities
    h_bind_vars_values.delete;
    h_num_bind_vars := 0;

    h_sql := 'INSERT /*+ append';
    IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
        h_sql := h_sql||' parallel ('||x_base_table||')';
    END IF;
    h_sql := h_sql||' */ INTO '||x_base_table;
    IF x_parallel_jobs = 'Y' THEN
        h_sql := h_sql||' PARTITION('||x_partition_name||')';
    END IF;
    h_sql := h_sql||' ('||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
    FOR h_i IN 1..x_num_key_columns LOOP
        h_sql := h_sql||x_key_columns(h_i)||', ';
    END LOOP;
    h_sql := h_sql||'YEAR, TYPE, PERIOD, PERIODICITY_ID';
    FOR h_i IN 1..x_num_data_columns LOOP
        h_sql := h_sql||', '||x_data_columns(h_i);
    END LOOP;
    h_sql := h_sql||')'||
             ' SELECT';
    IF BSC_UPDATE_UTIL.is_parallel AND x_parallel_jobs = 'N' THEN
        -- Fix bug#5155523 Do not use parallel hint on BSC_DB_CALENDAR_TEMP
        h_sql := h_sql||' /*+ parallel (BSC_B_DATA) */';
    END IF;
    h_sql := h_sql||' MAX(BSC_B_DATA.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||') '||
             BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||', ';
    FOR h_i IN 1..x_num_key_columns LOOP
        h_sql := h_sql||'BSC_B_DATA.'||x_key_columns(h_i)||', ';
    END LOOP;
    h_sql := h_sql||'BSC_B_DATA.YEAR, BSC_B_DATA.TYPE, BSC_DB_CALENDAR_TEMP.UPPER_PERIOD PERIOD,'||
                 ' BSC_DB_CALENDAR_TEMP.PERIODICITY_ID';
    FOR h_i IN 1..x_num_data_columns LOOP
        IF x_data_measure_types(h_i) = 1 THEN
            -- Activity measure
            h_sql := h_sql||', '||x_data_formulas(h_i)||' '||x_data_columns(h_i);
        ELSE
            -- Balance measure
            h_sql := h_sql||', SUM(DECODE(BSC_DB_CALENDAR_TEMP.LAST_PERIOD,''Y'','||x_data_columns(h_i)||', NULL))'||
                     ' '||x_data_columns(h_i);
        END IF;
    END LOOP;
    h_sql := h_sql||' FROM '||x_base_table||' BSC_B_DATA, BSC_DB_CALENDAR_TEMP'||
             ' WHERE BSC_B_DATA.PERIODICITY_ID = :1'||
             ' AND BSC_B_DATA.PERIOD = BSC_DB_CALENDAR_TEMP.LOWER_PERIOD'||
             ' AND BSC_B_DATA.YEAR = BSC_DB_CALENDAR_TEMP.YEAR';
    h_num_bind_vars := h_num_bind_vars + 1;
    h_bind_vars_values(h_num_bind_vars) := x_periodicity;
    IF x_parallel_jobs = 'Y' THEN
        h_sql := h_sql||' AND BSC_B_DATA.'||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :2';
        h_num_bind_vars := h_num_bind_vars + 1;
        h_bind_vars_values(h_num_bind_vars) := x_batch_value;
    END IF;
    h_sql := h_sql||' GROUP BY ';
    FOR h_i IN 1..x_num_key_columns LOOP
        h_sql := h_sql||'BSC_B_DATA.'||x_key_columns(h_i)||', ';
    END LOOP;
    h_sql := h_sql||'BSC_B_DATA.YEAR, BSC_B_DATA.TYPE, BSC_DB_CALENDAR_TEMP.UPPER_PERIOD,'||
             ' BSC_DB_CALENDAR_TEMP.PERIODICITY_ID';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
    COMMIT;

    x_return_status := 'success';

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Calc_Higher_Periodicities.e_others: '||SQLERRM;

END Calc_Higher_Periodicities;


/*===========================================================================+
| PROCEDURE Update_Base_Table_Job
+============================================================================*/
PROCEDURE Update_Base_Table_Job (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_fy IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_proj_table IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_num_loads IN NUMBER,
    x_job_name IN VARCHAR2
 ) IS

    h_return_status VARCHAR2(50);
    h_error_message VARCHAR2(2000);
    h_sql VARCHAR2(32000);

    e_error_calc_base_table EXCEPTION;
    e_get_info_data_columns EXCEPTION;
    e_get_info_key_columns EXCEPTION;
    e_unexpected_error EXCEPTION;

    h_data_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_formulas BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_proj_methods BSC_UPDATE_UTIL.t_array_of_number;
    h_data_measure_types BSC_UPDATE_UTIL.t_array_of_number;
    h_num_data_columns NUMBER;

    h_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns NUMBER;

BEGIN

    --- Note that each job runs in a new session, we need to initialized session variables
    h_num_key_columns := 0;
    h_num_data_columns := 0;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;
    BSC_MESSAGE.Init('NO');

    -- Initializes g_session_id, g_user_id and g_schema_name
    IF NOT BSC_UPDATE.Init_Env_Values THEN
        RAISE e_unexpected_error;
    END IF;

    /*
    -- TRACE ----------------------------------------------------------------
    -- Set sql trace
    execute immediate 'alter session set MAX_DUMP_FILE_SIZE=UNLIMITED';
    execute immediate 'alter session set tracefile_identifier='''||x_base_table||'_'||x_partition_name||'''';
    execute immediate 'alter session set sql_trace=true';
    --execute immediate 'alter session set events= ''10046 trace name context forever, level 12''';
    -- ----------------------------------------------------------------------------------
    */

    h_sql := 'alter session set hash_area_size=50000000';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    h_sql := 'alter session set sort_area_size=50000000';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    IF BSC_UPDATE_UTIL.is_parallel THEN
        COMMIT;
        h_sql := 'alter session enable parallel dml';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        COMMIT;
    END IF;

    -- Get data columns
    IF NOT BSC_UPDATE_UTIL.Get_Information_Data_Columns(x_base_table,
                                                        h_data_columns,
                                                        h_data_formulas,
                                                        h_data_proj_methods,
                                                        h_data_measure_types,
                                                        h_num_data_columns) THEN
        RAISE e_get_info_data_columns;
    END IF;

    -- Get key columns
    IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(x_base_table,
                                                       h_key_columns,
                                                       h_key_dim_tables,
                                                       h_source_columns,
                                                       h_source_dim_tables,
                                                       h_num_key_columns) THEN
        RAISE e_get_info_key_columns;
    END IF;

    Update_Base_Table(x_base_table,
                      x_input_table,
                      x_correction_flag,
                      x_aw_flag,
                      x_change_vector_value,
                      x_periodicity,
                      x_calendar_id,
                      x_current_fy,
                      x_current_period,
                      x_old_current_period,
                      h_key_columns,
                      h_key_dim_tables,
                      h_num_key_columns,
                      h_data_columns,
                      h_data_formulas,
                      h_data_proj_methods,
                      h_data_measure_types,
                      h_num_data_columns,
                      x_proj_table,
                      x_rowid_table,
                      x_partition_name,
                      x_batch_value,
                      x_num_partitions,
                      x_num_loads,
                      'Y',
                      h_return_status,
                      h_error_message);

    IF h_return_status = 'error' THEN
        RAISE e_error_calc_base_table;
    END IF;

    bsc_aw_utility.send_pipe_message(x_job_name, 'status=success');

EXCEPTION
    WHEN e_get_info_data_columns THEN
        rollback;
        bsc_aw_utility.send_pipe_message(x_job_name, 'status=error,message=e_get_info_data_columns');

    WHEN e_get_info_key_columns THEN
        rollback;
        bsc_aw_utility.send_pipe_message(x_job_name, 'status=error,message=e_get_info_key_columns');

    WHEN e_error_calc_base_table THEN
        rollback;
        bsc_aw_utility.send_pipe_message(x_job_name, 'status=error,message='||h_error_message);

    WHEN e_unexpected_error THEN
        rollback;
        bsc_aw_utility.send_pipe_message(x_job_name, 'status=error,message=e_unexpected_error');

    WHEN OTHERS THEN
        rollback;
        bsc_aw_utility.send_pipe_message(x_job_name, 'status=error,message='||SQLERRM);

END Update_Base_Table_Job;


/*===========================================================================+
| PROCEDURE Update_Base_Table
+============================================================================*/
PROCEDURE Update_Base_Table (
    x_base_table IN VARCHAR2,
    x_input_table IN VARCHAR2,
    x_correction_flag IN BOOLEAN,
    x_aw_flag IN BOOLEAN,
    x_change_vector_value IN NUMBER,
    x_periodicity IN NUMBER,
    x_calendar_id IN NUMBER,
    x_current_fy IN NUMBER,
    x_current_period IN NUMBER,
    x_old_current_period IN NUMBER,
    x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns IN NUMBER,
    x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
    x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_data_columns IN NUMBER,
    x_proj_table IN VARCHAR2,
    x_rowid_table IN VARCHAR2,
    x_partition_name IN VARCHAR2,
    x_batch_value IN NUMBER,
    x_num_partitions IN NUMBER,
    x_num_loads IN NUMBER,
    x_parallel_jobs IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
 ) IS

    e_init_calendar_temp_tbl EXCEPTION;
    e_load_input_table_initial EXCEPTION;
    e_load_input_table_inc EXCEPTION;
    e_calc_higher_periodicities EXCEPTION;
    e_init_calendar_temp_tbl_proj EXCEPTION;
    e_calc_projection EXCEPTION;

    h_return_status VARCHAR2(50);
    h_error_message VARCHAR2(2000);
    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;
    h_num_rows NUMBER;
    h_projection_flag VARCHAR2(3);
    h_yearly_periodicity NUMBER;
    h_yearly_flag NUMBER;

BEGIN

    h_num_bind_vars := 0;
    h_num_rows := 0;

    -- Init temporary table BSC_DB_CALENDAR_TEMP to do the rollup to higher periodicities
    -- in MV architecture
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        Init_Bsc_Db_Calendar_Temp(x_base_table,
                                  x_periodicity,
                                  x_calendar_id,
                                  x_current_period,
                                  x_current_fy,
                                  h_return_status,
                                  h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_init_calendar_temp_tbl;
        END IF;
    END IF;

    -- Load data from the input table
    IF NOT x_correction_flag THEN
        -- Know if the base table has data or not
        h_sql := 'select count(*) from '||x_base_table||' where rownum < :1';
        IF x_parallel_jobs = 'Y' THEN
            h_sql := h_sql||' and '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :2';
            OPEN h_cursor FOR h_sql USING 2, x_batch_value;
        ELSE
            OPEN h_cursor FOR h_sql USING 2;
        END IF;
        FETCH h_cursor INTO h_num_rows;
        CLOSE h_cursor;

        IF h_num_rows > 0  THEN
            -- Base table has data --> Incremental Load

            -- AW_INTEGRATION: PROJECTION flag is now set to Y for all the rows beyond
            -- current period no matter if it is target or actual. So if the current period changes
            -- we need to update to N between old current period and new current period for type <> 0
            IF x_aw_flag THEN
                h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
                IF (h_yearly_flag <> 1) AND (x_current_period > x_old_current_period) THEN
                    h_num_bind_vars := 0;
                    h_bind_vars_values.delete;

                    h_sql := 'UPDATE '||x_base_table;
                    IF x_parallel_jobs = 'Y' THEN
                        h_sql := h_sql||' partition('||x_partition_name||')';
                    END IF;
                    h_sql := h_sql||
                             ' SET projection = ''N'', change_vector = :1'||
                             ' WHERE YEAR = :2 AND PERIOD > :3 AND PERIOD <= :4 AND TYPE <> :5';
                    h_bind_vars_values(1) := x_change_vector_value;
                    h_bind_vars_values(2) := x_current_fy;
                    h_bind_vars_values(3) := x_old_current_period;
                    h_bind_vars_values(4) := x_current_period;
                    h_bind_vars_values(5) := 0;
                    h_num_bind_vars := 5;
                    IF x_parallel_jobs = 'Y' THEN
                        h_sql := h_sql||' AND '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :6';
                        h_num_bind_vars := h_num_bind_vars + 1;
                        h_bind_vars_values(h_num_bind_vars) := x_batch_value;
                    END IF;
                    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                    commit;
                END IF;
            END IF;

            Load_Input_Table_Inc(x_base_table,
                                 x_input_table,
                                 x_aw_flag,
                                 x_change_vector_value,
                                 x_periodicity,
                                 x_calendar_id,
                                 x_current_period,
                                 x_old_current_period,
                                 x_current_fy,
                                 x_key_columns,
                                 x_key_dim_tables,
                                 x_num_key_columns,
                                 x_data_columns,
                                 x_data_formulas,
                                 x_data_measure_types,
                                 x_num_data_columns,
                                 x_partition_name,
                                 x_batch_value,
                                 x_num_partitions,
                                 x_parallel_jobs,
                                 x_rowid_table,
                                 x_num_loads,
                                 h_return_status,
                                 h_error_message);
            IF h_return_status = 'error' THEN
                RAISE e_load_input_table_inc;
            END IF;
        ELSE
            -- Base table is empty --> Initial Load
            Load_Input_Table_Initial(x_base_table,
                                     x_input_table,
                                     x_aw_flag,
                                     x_change_vector_value,
                                     x_periodicity,
                                     x_calendar_id,
                                     x_current_period,
                                     x_current_fy,
                                     x_key_columns,
                                     x_key_dim_tables,
                                     x_num_key_columns,
                                     x_data_columns,
                                     x_data_formulas,
                                     x_data_measure_types,
                                     x_num_data_columns,
                                     x_partition_name,
                                     x_batch_value,
                                     x_num_partitions,
                                     x_parallel_jobs,
                                     h_return_status,
                                     h_error_message);
            IF h_return_status = 'error' THEN
                RAISE e_load_input_table_initial;
            END IF;
        END IF;
    ELSE
        -- No data coming from the input table
        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            -- In MV architecture we need to re-rollup to higher periodicities since the aggregation function
            -- or the balance type could have changed. We re-rollup the entire table

            -- Delete rows for highwer periodicities
            h_num_bind_vars := 0;
            h_sql := 'DELETE FROM '||x_base_table;
            IF x_parallel_jobs = 'Y' THEN
                h_sql := h_sql||' partition('||x_partition_name||')';
            END IF;
            h_sql := h_sql||' WHERE PERIODICITY_ID <> :1';
            h_num_bind_vars := h_num_bind_vars + 1;
            h_bind_vars_values(h_num_bind_vars) := x_periodicity;
            IF x_parallel_jobs = 'Y' THEN
                h_sql := h_sql||' AND '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' = :2';
                h_num_bind_vars := h_num_bind_vars + 1;
                h_bind_vars_values(h_num_bind_vars) := x_batch_value;
            END IF;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
            COMMIT;

            -- Insert rows for higer periodicities
            Calc_Higher_Periodicities(x_base_table,
                                      x_periodicity,
                                      x_key_columns,
                                      x_num_key_columns,
                                      x_data_columns,
                                      x_data_formulas,
                                      x_data_measure_types,
                                      x_num_data_columns,
                                      x_partition_name,
                                      x_batch_value,
                                      x_parallel_jobs,
                                      h_return_status,
                                      h_error_message);
            IF h_return_status = 'error' THEN
                RAISE e_calc_higher_periodicities;
            END IF;
        END IF;
    END IF;

    -- Analyze the B table partition
    IF x_parallel_jobs = 'Y' THEN
        dbms_stats.gather_table_stats(
             ownname => BSC_APPS.BSC_APPS_SCHEMA,
             tabname => x_base_table,
             partname => x_partition_name,
             estimate_percent => 1);
    ELSE
        dbms_stats.gather_table_stats(
             ownname => BSC_APPS.BSC_APPS_SCHEMA,
             tabname => x_base_table);
    END IF;
    commit;

    -- Calculate projection
    -- Note that the projection table is empty. It was truncated already outside this procedure.
    IF BSC_UPDATE_CALC.Table_Has_Proj_Calc(x_base_table) THEN
        -- Calculate projection for base periodicity
        Calc_Projection(x_base_table,
                        x_proj_table,
                        x_aw_flag,
                        x_change_vector_value,
                        x_periodicity,
                        x_calendar_id,
                        x_current_period,
                        x_current_fy,
                        x_key_columns,
                        x_num_key_columns,
                        x_data_columns,
                        x_data_proj_methods,
                        x_num_data_columns,
                        x_partition_name,
                        x_batch_value,
                        x_parallel_jobs,
                        h_return_status,
                        h_error_message);
        IF h_return_status = 'error' THEN
            RAISE e_calc_projection;
        END IF;

        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            -- Init temporary table BSC_DB_CALENDAR_TEMP to do the rollup to higher periodicities
            -- for projection.
            Init_Bsc_Db_Calendar_Temp_Proj(x_base_table,
                                           x_periodicity,
                                           x_calendar_id,
                                           x_current_period,
                                           x_current_fy,
                                           h_return_status,
                                           h_error_message);
            IF h_return_status = 'error' THEN
                RAISE e_init_calendar_temp_tbl_proj;
            END IF;

            -- In MV architecture we need to rollup the projection table
            -- to higher periodicities different from yearly
            Calc_Higher_Periodicities(x_proj_table,
                                      x_periodicity,
                                      x_key_columns,
                                      x_num_key_columns,
                                      x_data_columns,
                                      x_data_formulas,
                                      x_data_measure_types,
                                      x_num_data_columns,
                                      x_partition_name,
                                      x_batch_value,
                                      x_parallel_jobs,
                                      h_return_status,
                                      h_error_message);
            IF h_return_status = 'error' THEN
                RAISE e_calc_higher_periodicities;
            END IF;

            -- Calculate projection for yearly periodicity if this is the case
            -- See if yearly is one of the higher periodicities
            BEGIN
                select c.parameter1
                into h_yearly_periodicity
                from bsc_db_calculations c, bsc_sys_periodicities p
                where c.table_name = x_base_table and
                      c.calculation_type = 6 and
                      c.parameter1 = p.periodicity_id and
                      p.yearly_flag = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    h_yearly_periodicity := NULL;
            END;
            IF h_yearly_periodicity IS NOT NULL THEN
                Calc_Projection(x_base_table,
                                x_proj_table,
                                x_aw_flag,
                                x_change_vector_value,
                                h_yearly_periodicity,
                                x_calendar_id,
                                x_current_fy,
                                x_current_fy,
                                x_key_columns,
                                x_num_key_columns,
                                x_data_columns,
                                x_data_proj_methods,
                                x_num_data_columns,
                                x_partition_name,
                                x_batch_value,
                                x_parallel_jobs,
                                h_return_status,
                                h_error_message);
                IF h_return_status = 'error' THEN
                    RAISE e_calc_projection;
                END IF;
            END IF;
        END IF;
    END IF;

    commit;
    x_return_status := 'success';

EXCEPTION
    WHEN e_init_calendar_temp_tbl THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_init_calendar_temp_tbl: '||h_error_message;

    WHEN e_load_input_table_initial THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_load_input_table_initial: '||h_error_message;

    WHEN e_load_input_table_inc THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_load_input_table_inc: '||h_error_message;

    WHEN e_calc_higher_periodicities THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_calc_higher_periodicities: '||h_error_message;

    WHEN e_init_calendar_temp_tbl_proj THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_init_calendar_temp_tbl_proj: '||h_error_message;

    WHEN e_calc_projection THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_calc_projection: '||h_error_message;

    WHEN OTHERS THEN
        rollback;
        x_return_status := 'error';
        x_error_message := 'Update_Base_Table.e_others: '||SQLERRM;

END Update_Base_Table;

END BSC_UPDATE_BASE_V2;

/
