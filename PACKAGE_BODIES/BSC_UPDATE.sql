--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE" AS
/* $Header: BSCDUPDB.pls 120.20 2007/12/07 10:03:19 phattarg ship $ */

--
-- Package constants
--
g_process_id NUMBER;
g_process_name VARCHAR2(1);

-- Formats
c_fto_long_date_time CONSTANT VARCHAR2(30) := 'Month DD, YYYY HH24:MI:SS';


/*===========================================================================+
| FUNCTION Can_Load_Dim_Table
+============================================================================*/
FUNCTION Can_Load_Dim_Table(
	x_dim_table IN VARCHAR2,
	x_loaded_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_loaded_tables IN NUMBER,
        x_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_dim_tables IN NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    CURSOR c_parent_tables(p_dim_table VARCHAR2) is
        SELECT dp.level_table_name
        FROM bsc_sys_dim_levels_b d, bsc_sys_dim_levels_b dp, bsc_sys_dim_level_rels r
        WHERE d.dim_level_id = r.dim_level_id AND
              r.parent_dim_level_id = dp.dim_level_id AND
              DECODE(r.relation_type, 2, r.relation_col, d.level_table_name) = p_dim_table;

    h_parent_table bsc_sys_dim_levels_b.level_table_name%TYPE;
    h_ret BOOLEAN;

BEGIN
    h_ret := TRUE;

    OPEN c_parent_tables(x_dim_table);
    FETCH c_parent_tables INTO h_parent_table;
    WHILE c_parent_tables%FOUND LOOP
        IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_parent_table,
                                                         x_dim_tables,
                                                         x_num_dim_tables) THEN

            -- The parent table was or is going to be loaded in this process
            -- So, we need to check if this parent table is already loaded or not
            -- If it is not already loaded the dimension table cannot be
            -- loaded right now.

            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_parent_table,
	    						         x_loaded_tables,
							         x_num_loaded_tables) THEN
                h_ret := FALSE;
                EXIT;
            END IF;
        END IF;

        FETCH c_parent_tables INTO h_parent_table;
    END LOOP;

    CLOSE c_parent_tables;

    RETURN h_ret;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Can_Load_Dim_Table');
        RETURN NULL;

END Can_Load_Dim_Table;


/*===========================================================================+
| FUNCTION Can_Calculate_Sys_Table
+============================================================================*/
FUNCTION Can_Calculate_Sys_Table(
	x_system_table IN VARCHAR2,
	x_calculated_sys_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_calculated_sys_tables IN NUMBER,
        x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_system_tables IN NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_origin_tables t_cursor; -- x_system_table
    c_origin_tables_sql VARCHAR2(2000) := 'SELECT source_table_name'||
                                          ' FROM bsc_db_tables_rels'||
                                          ' WHERE table_name = :1';
    */
    CURSOR c_origin_tables (p_table_name VARCHAR2) IS
        SELECT source_table_name
        FROM bsc_db_tables_rels
        WHERE table_name = p_table_name;

    h_origin_table bsc_db_tables_rels.source_table_name%TYPE;
    h_ret BOOLEAN;

BEGIN
    h_ret := TRUE;

    --OPEN c_origin_tables FOR c_origin_tables_sql USING x_system_table;
    OPEN c_origin_tables(x_system_table);
    FETCH c_origin_tables INTO h_origin_table;
    WHILE c_origin_tables%FOUND LOOP
        IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_origin_table,
                                                         x_system_tables,
                                                         x_num_system_tables) THEN

            -- The origin table was or is going to be calculated in this process
            -- So, we need to check if this origin table is already calculated or not
            -- If it is not already calculated the the system table cannot be
            -- calculated right now.

            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_origin_table,
	    						         x_calculated_sys_tables,
							         x_num_calculated_sys_tables) THEN
                h_ret := FALSE;
                EXIT;
            END IF;
        END IF;

        FETCH c_origin_tables INTO h_origin_table;
    END LOOP;

    CLOSE c_origin_tables;

    RETURN h_ret;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Can_Calculate_Sys_Table');
        RETURN NULL;

END Can_Calculate_Sys_Table;


/*===========================================================================+
| FUNCTION Configure_Periodicity_Calc
+============================================================================*/
FUNCTION Configure_Periodicity_Calc(
    p_base_table IN VARCHAR2,
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    c_calculation_type NUMBER;

    h_base_table BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_base_table_periodicity NUMBER;

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;

    h_lst_where VARCHAR2(32700);
    h_i NUMBER;

    h_sql VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_periodicity_id NUMBER;

BEGIN
    c_calculation_type := 6;
    h_num_system_tables := 0;

    -- Delete current configuration
    DELETE FROM bsc_db_calculations
    WHERE table_name = p_base_table AND calculation_type = c_calculation_type;

    -- Get base table periodicity
    h_base_table_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(p_base_table);
    IF h_base_table_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Initialize the array h_system_tables with the system tables that are affected by the base table
    h_base_table(1) := p_base_table;

    IF NOT Insert_Affected_Tables(h_base_table, 1, h_system_tables, h_num_system_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get all the periodicities required in the system tables affected by the base table

    IF h_num_system_tables > 0 THEN
        h_lst_where := BSC_APPS.Get_New_Big_In_Cond_Varchar2NU(1, 'table_name');
        FOR h_i IN 1 .. h_num_system_tables LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, h_system_tables(h_i));
        END LOOP;

        h_sql := 'SELECT DISTINCT periodicity_id '||
                 'FROM bsc_db_tables '||
                 'WHERE '||h_lst_where;

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_periodicity_id;
        WHILE h_cursor%FOUND LOOP
            IF h_periodicity_id <> h_base_table_periodicity THEN
                INSERT INTO bsc_db_calculations (table_name, calculation_type, parameter1)
                VALUES (p_base_table, c_calculation_type, h_periodicity_id);
            END IF;

            FETCH h_cursor INTO h_periodicity_id;
        END LOOP;
        CLOSE h_cursor;

    END IF;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        x_error_message := BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR');
    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Configure_Periodicity_Calc;


/*===========================================================================+
| PROCEDURE Configure_Periodicity_Calc_VB
+============================================================================*/
PROCEDURE Configure_Periodicity_Calc_VB(
    p_base_table IN VARCHAR2
) IS

    e_error EXCEPTION;
    l_error_message 	VARCHAR2(2000);

BEGIN

    IF NOT Configure_Periodicity_Calc(p_base_table, l_error_message) THEN
        RAISE e_error;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => l_error_message,
                        x_source => 'BSC_UPDATE.Configure_Periodicity_Calc_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Configure_Periodicity_Calc_VB',
                        x_mode => 'I');
        COMMIT;

END Configure_Periodicity_Calc_VB;


/*===========================================================================+
| FUNCTION Configure_Profit_Calc
+============================================================================*/
FUNCTION Configure_Profit_Calc(
    x_error_message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    h_column_type_p VARCHAR2(1);
    h_base_table VARCHAR2(30);
    h_pk_level_subaccount VARCHAR2(50);
    h_calculation_type NUMBER;

    CURSOR h_cursor (p_table_type NUMBER, p_column_type VARCHAR2, p_indic_type NUMBER,
                     p_config_type NUMBER, p_dim_level_index NUMBER) IS
        SELECT table_name, column_name
        FROM bsc_db_tables_cols
        WHERE table_name IN (
                SELECT table_name
                FROM bsc_db_tables_rels
                WHERE source_table_name IN (
                        SELECT table_name
                        FROM bsc_db_tables
                        WHERE table_type = p_table_type
                      )
              ) AND
              column_type = p_column_type AND
              column_name IN (
                SELECT level_pk_col
                FROM bsc_kpi_dim_levels_b
                WHERE indicator IN (
                        SELECT indicator
                        FROM bsc_kpis_b
                        WHERE indicator_type = p_indic_type AND config_type = p_config_type
                       ) AND
                      dim_level_index = p_dim_level_index
              );

BEGIN

    h_column_type_p := 'P';
    h_calculation_type := 1;

    -- Fix bug#3796202,we need to delete all the profit calculations from bsc_db_calculations
    DELETE FROM bsc_db_calculations WHERE calculation_type = h_calculation_type;

    -- Next query find all the base tables using any sub-account dimension.
    -- It looks in all the PL indicators to know what are the different sub-account
    -- dimensions.
    OPEN h_cursor(0, h_column_type_p, 1, 3, 2);
    LOOP
        FETCH h_cursor INTO h_base_table, h_pk_level_subaccount;
        EXIT WHEN h_cursor%NOTFOUND;

        INSERT INTO bsc_db_calculations (table_name, calculation_type, parameter1)
        VALUES(h_base_table, h_calculation_type, h_pk_level_subaccount);
    END LOOP;
    CLOSE h_cursor;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Configure_Profit_Calc;


/*===========================================================================+
| PROCEDURE Configure_Profit_Calc_VB
+============================================================================*/
PROCEDURE Configure_Profit_Calc_VB IS
    e_error EXCEPTION;

    l_error_message 	VARCHAR2(2000);

BEGIN

    IF NOT Configure_Profit_Calc(l_error_message) THEN
        RAISE e_error;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => l_error_message,
                        x_source => 'BSC_UPDATE.Configure_Profit_Calc_VB',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Configure_Profit_Calc_VB',
                        x_mode => 'I');
        COMMIT;

END Configure_Profit_Calc_VB;


/*===========================================================================+
| PROCEDURE Execute_Update_Process
+============================================================================*/
PROCEDURE Execute_Update_Process (
    x_process_id IN NUMBER,
    x_process_name IN VARCHAR2,
    x_parameter_1 IN VARCHAR2
    ) IS

    e_update_error EXCEPTION;
    e_no_pending_process EXCEPTION;
    e_exists_prototype_indicators EXCEPTION;
    e_tmp_tbl_create_error EXCEPTION; --added for bug 3899523
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_log_file_name VARCHAR2(200);

    h_b BOOLEAN;
    h_i NUMBER;

    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;

    h_calendars BSC_UPDATE_UTIL.t_array_of_number;
    h_num_calendars NUMBER;

    h_edw_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_edw_dim_tables NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_indicator VARCHAR2(30);

    CURSOR c_indicators (p_process_id NUMBER) IS
        SELECT input_table_name
        FROM bsc_db_loader_control
        WHERE process_id = p_process_id;

    h_error_message VARCHAR2(2000);

    -- Fix bug#3923207: import dbi plans into bsc benchmarks
    e_import_dbi_plans EXCEPTION;

    -- TRACE
    h_stat_name VARCHAR2(100);
    h_stat_value NUMBER;

    h_load_type_into_aw BOOLEAN;

BEGIN
    h_num_input_tables := 0;
    h_num_indicators := 0;
    h_num_calendars := 0;
    h_num_edw_dim_tables := 0;

-- Initializes global variables

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    -- Check system lock
    -- This is done in two places:
    -- 1. At the beginning of the VB loader.
    -- 2. In function Run_Concurrent_Loader_Apps which is called when user launch the process
    --    from apps forms.
    -- So at this point the system is locked. WE DONT NEED TO LOCK THE SYSTEM HERE.

    -- Initializes g_session_id, g_user_id and g_schema_name
    IF NOT Init_Env_Values THEN
        RAISE e_update_error;
    END IF;

/*
    -- TRACE ----------------------------------------------------------------
    -- Set sql trace
    execute immediate 'alter session set MAX_DUMP_FILE_SIZE=UNLIMITED';
    execute immediate 'alter session set tracefile_identifier=''BSCLOADER''';
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

    -- Get the pending process id
    g_process_id := Get_Process_Id(x_process_id, x_process_name);
    g_process_name := x_process_name;

    IF g_process_id IS NULL THEN
        RAISE e_update_error;
    END IF;

    IF g_process_id = -1 THEN
        RAISE e_no_pending_process;
    END IF;

    -- Initiliaze log file
    IF NOT BSC_APPS.APPS_ENV THEN
        h_log_file_name := g_schema_name||g_process_id||'.log';

        IF NOT BSC_UPDATE_LOG.Init_Log_File(h_log_file_name) THEN
            RAISE e_update_error;
        END IF;
    END IF;

-- Write process_id to log file
    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'PROCESS_ID')||
                                  BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                  ' '||TO_CHAR(g_process_id), BSC_UPDATE_LOG.LOG);

    BSC_UPDATE_LOG.Write_Line_Log(USERENV('SESSIONID'), BSC_UPDATE_LOG.LOG);

-- Update the status of the pending process to running
    IF NOT Set_PStatus_Running() THEN
       RAISE e_update_error;
    END IF;
    COMMIT;

-- BSC-BIS-DIMENSIONS Note:
-- We are removing this validation. Loader process can load data for production indicators
-- even if there are indicators in prototype. When loader calculates summary tables
-- it will check that the indicator is in production.
--    IF x_process_name <> PC_LOAD_DIMENSIONS THEN
--        h_b := Exists_Prototype_Indicators();
--        IF h_b IS NULL THEN
--            RAISE e_update_error;
--        ELSIF h_b THEN
--            RAISE e_exists_prototype_indicators;
--        END IF;
--    END IF;


-- EDW Note: We need to refresh all EDW dimensions involved in the input tables
--           before check incremental changes.
-- BSC-MV Note: This code is not used. I will comment it out
--    IF x_process_name = PC_LOADER_PROCESS THEN
--        IF NOT Get_EDW_Dims_In_Input_Tables(h_edw_dim_tables, h_num_edw_dim_tables) THEN
--            RAISE e_update_error;
--        END IF;
--
--        IF h_num_edw_dim_tables > 0 THEN
--            IF NOT BSC_UPDATE_DIM.Refresh_EDW_Dimensions(h_edw_dim_tables, h_num_edw_dim_tables) THEN
--                RAISE e_update_error;
--            END IF;
--        END IF;
--    END IF;


    -- BSC-BIS-DIMENSIONS: Starting from this implementation the parameter
    -- x_parameter_1 may contain the list of indicators that we want to process.
    -- If this parameter is given, Loader only calculate summary tables for those indicators.
    g_num_indicators := 0;
    g_kpi_mode := FALSE;
    IF x_process_name = PC_LOADER_PROCESS OR x_process_name = PC_LOAD_DIMENSIONS THEN
        -- Decompose the list in x_parameter_1 into the array g_indicators
        IF x_parameter_1 IS NOT NULL THEN
            g_num_indicators := BSC_UPDATE_UTIL.Decompose_Numeric_List(x_parameter_1,
                                                                       g_indicators,
                                                                       ',');
            g_kpi_mode := TRUE;
        END IF;
    END IF;

-- create temp table to hold CODE COLUMN TYPE
  --LOCKING: Note I review code and the table created in BSC_OLAP_MAIN.create_tmp_col_type_table
  -- is created with the name BSC_TMP_COL_TYPE_<session_id>. So no problem with many sessions
  -- dropping and creting this table
  --Bug 3899523
  --check if the temp table for col datatype has already been created
  --if false drop the table and create it again
   if(BSC_OLAP_MAIN.b_table_col_type_created=false)then
        BSC_OLAP_MAIN.drop_tmp_col_type_table;
        if(BSC_OLAP_MAIN.create_tmp_col_type_table(h_error_message)) then
        	BSC_OLAP_MAIN.b_table_col_type_created := true;
        else
        	--Raise exception;
        	RAISE e_tmp_tbl_create_error;
        end if;
   end if;

   -- Fix bug#3923207: Load dbi plans into bsc benchmarks whenever Loader is called to load data
   IF x_process_name = PC_LOADER_PROCESS THEN
       --LOCKING: Get the locks needed to import benchmarks
       IF NOT BSC_UPDATE_LOCK.Lock_Import_Dbi_Plans THEN
           RAISE e_could_not_get_lock;
       END IF;

       -- LOCKING: Call the autonomous transaction function
       IF NOT BSC_UPDATE_DIM.Import_Dbi_Plans_AT(h_error_message) THEN
           RAISE e_import_dbi_plans;
       END IF;

       -- AW_INTEGRATION: Load TYPE dimension into AW
       -- LOCKING: encapsulate this code into an AT procedure
       -- Fix bug#4491629: If loader is running 'By Objective' we do not need to load type into AW
       -- if none of the objectives are implemented in AW
       h_load_type_into_aw := FALSE;
       IF g_kpi_mode THEN
           FOR h_i IN 1..g_num_indicators LOOP
               IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(g_indicators(h_i)) = 2 THEN
                   h_load_type_into_aw := TRUE;
                   EXIT;
               END IF;
           END LOOP;
       ELSE
           -- running by input tables
           IF BSC_UPDATE_UTIL.Exists_AW_Kpi THEN
               h_load_type_into_aw := TRUE;
           END IF;
       END IF;
       IF h_load_type_into_aw THEN
           BSC_UPDATE_DIM.Load_Type_Into_AW_AT;
       END IF;

       --LOCKING: commit to release the locks
       COMMIT;
   END IF;

-- Load dimensions: We run this process here before incremental changes.
--                  So, the indicators affected in this process will be refreshed
--                  immediately in incremental changes.
    IF x_process_name = PC_LOAD_DIMENSIONS THEN
        -- Process input tables in BSC_LOADER_CONTROL table
        -- Initialize the array h_input_tables with the input tables
        -- of the current process whose status is pending

        -- AW_INTEGRATION: Create temporary tables needed for AW dimension processing
        --LOCKING: Lock the temporal tables for dimensions
        IF NOT BSC_UPDATE_LOCK.Lock_Temp_Tables('DIMENSION') THEN
            RAISE e_could_not_get_lock;
        END IF;

        -- LOCKING: call the autonomous trnasaction function
        IF NOT BSC_UPDATE_DIM.Create_AW_Dim_Temp_Tables_AT THEN
            RAISE e_update_error;
        END IF;

        --LOCKING: commit to release locks
        COMMIT;

        IF NOT Get_Process_Input_Tables(h_input_tables, h_num_input_tables, LC_PENDING_STATUS) THEN
            RAISE e_update_error;
        END IF;

        -- Load input tables from database sources
        IF h_num_input_tables > 0 THEN
            IF NOT Import_ITables_From_DBSrc(h_input_tables, h_num_input_tables) THEN
                RAISE e_update_error;
            END IF;
        END IF;

        IF h_num_input_tables > 0 THEN
            IF NOT Load_Dim_Input_Tables(h_input_tables, h_num_input_tables) THEN
                RAISE e_update_error;
            END IF;
        END IF;

        -- Bug#3322259 Need to print the status of the input tables processed here.
        -- Write the result and invalid codes in the log
        IF NOT Write_Result_Log THEN
            NULL;
        END IF;
    END IF;

    -- Incremental functionality
    --LOCKING: Lock all the indicators that are going to be affected in the
    -- incremental logic. This is in cascade mode and in READ mode.
    -- This is to prevent Metadata Optimizer and Designer to modify those indicators
    -- during this process
    IF NOT BSC_UPDATE_LOCK.Lock_Incremental_Indicators THEN
        RAISE e_could_not_get_lock;
    END IF;

    --LOCKING: call the autonomous transaction function
    IF NOT BSC_UPDATE_INC.Do_Incremental_AT() THEN
        RAISE e_update_error;
    END IF;

    --LOCKING: commit to release the locks
    COMMIT;

-- Run the process
    IF x_process_name = PC_LOADER_PROCESS THEN
        -- Process input tables in BSC_LOADER_CONTROL table
        -- Initialize the array h_input_tables with the input tables
        -- of the current process whose status is pending
        IF NOT Get_Process_Input_Tables(h_input_tables, h_num_input_tables, LC_PENDING_STATUS) THEN
            RAISE e_update_error;
        END IF;

        --LOCKING: Lock all the indicators that are going to be affected.
        -- This is in cascade mode and in READ mode.
        -- This is to prevent Metadata Optimizer and Designer to modify those indicators
        -- during this process.

        IF NOT BSC_UPDATE_LOCK.Lock_Indicators(h_input_tables, h_num_input_tables) THEN
            RAISE e_could_not_get_lock;
        END IF;

        --LOCKING: Review no commit between this point and the commit to release the locks
        IF h_num_input_tables > 0 THEN
            -- Load input tables from database sources
            -- LOCKING: Call the autonomous transaction function
            IF NOT Import_ITables_From_DBSrc_AT(h_input_tables, h_num_input_tables) THEN
                RAISE e_update_error;
            END IF;

            -- Get again the input tables because some of them could be now in error status after importing from others sources
            IF NOT Get_Process_Input_Tables(h_input_tables, h_num_input_tables, LC_PENDING_STATUS) THEN
                RAISE e_update_error;
            END IF;
        END IF;

        IF h_num_input_tables > 0 THEN
            --LOCKING: Call the autonomous transaction function
            IF NOT BSC_UPDATE.Process_Input_Tables_AT(h_input_tables, h_num_input_tables, 0) THEN
                RAISE e_update_error;
            END IF;
        END IF;

        -- Bug#3322259 Need to print the status of the input tables processed here.
        -- Write the result, invalid codes and new input tables periods in the log
        IF NOT Write_Result_Log THEN
            NULL;
        END IF;

        --LOCKING: commit to release locks
        COMMIT;

    ELSIF x_process_name = PC_YEAR_CHANGE_PROCESS THEN
        -- Run the year change process

        -- Decompose the list in x_parameter_1 into the array h_calendars
        h_num_calendars := BSC_UPDATE_UTIL.Decompose_Numeric_List(x_parameter_1,
                                                                  h_calendars,
                                                                  ',');

        -- LOCKING: Lock the indicators in cascade mode and in read mode that are using
        -- any of the calendars. This is to prevent Metadata Optimizer to run on those
        -- indicators or Designer to midify those indicators, its measures and dimensions
        IF NOT BSC_UPDATE_LOCK.Lock_Indicators_by_Calendar(h_calendars, h_num_calendars) THEN
            RAISE e_could_not_get_lock;
        END IF;

        --LOCKING: Review no commit between this point and the commit to release the locks

        -- Change fiscal year by calendar
        FOR h_i IN 1..h_num_calendars LOOP
            -- LOCKING: call the autonomous transaction function
            IF NOT Execute_Year_Change_Process_AT(h_calendars(h_i)) THEN
                RAISE e_update_error;
            END IF;
        END LOOP;

        --LOCKING: commit to release the locks
        COMMIT;

    ELSIF x_process_name = PC_DELETE_KPI_DATA_PROCESS THEN
        -- Run delete kpis data process

        h_num_indicators := 0;

        /*
        h_sql := 'SELECT input_table_name'||
                 ' FROM bsc_db_loader_control'||
                 ' WHERE process_id = :1';
        OPEN h_cursor FOR h_sql USING  g_process_id;
        */
        OPEN c_indicators(g_process_id);
        LOOP
            FETCH c_indicators INTO h_indicator;
            EXIT WHEN c_indicators%NOTFOUND;

            h_num_indicators := h_num_indicators + 1;
	    h_indicators(h_num_indicators) := TO_NUMBER(h_indicator);
        END LOOP;
        CLOSE c_indicators;

        -- LOCKING: lock all the affected indicators in casscade mode and in read mode to prevent
        -- metadata optimizer and designers to run on those indicators during this process
        IF NOT BSC_UPDATE_LOCK.Lock_Indicators_To_Delete(h_indicators, h_num_indicators) THEN
            RAISE e_could_not_get_lock;
        END IF;

        IF g_keep_input_table_data IS NULL THEN
           g_keep_input_table_data := 'N';
        END IF;

        --LOCKING: Call the autonomous transaction function
        IF NOT BSC_UPDATE_INC.Purge_Indicators_Data_AT(h_indicators, h_num_indicators, g_keep_input_table_data) THEN
            RAISE e_update_error;
        END IF;

        --LOCKING: commit to release locks
        COMMIT;

    --LOCKING: remove EDW code
    --ELSIF x_process_name = PC_REFRESH_EDW_DIMENSION THEN
    --    -- Refresh EDW dimension table
    --    h_num_edw_dim_tables := 1;
    --    h_edw_dim_tables(1) := x_parameter_1;
    --    IF NOT BSC_UPDATE_DIM.Refresh_EDW_Dimensions(h_edw_dim_tables, h_num_edw_dim_tables) THEN
    --        RAISE e_update_error;
    --    END IF;
    END IF;


-- Update the process status to Completed
    IF NOT Set_PStatus_Finished(PC_COMPLETED_STATUS) THEN
        RAISE e_update_error;
    END IF;

    COMMIT;

    -- Write Program completed to log file
    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                  BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                  ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

    -- Delete records in the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    --Delete the temp table created for storing CODE Column type
    --LOCKING: Note I review code and the table created in BSC_OLAP_MAIN.create_tmp_col_type_table
    -- is created with the name BSC_TMP_COL_TYPE_<session_id>. So no problem with many sessions
    -- dropping and creting this table
    --Bug 3899523
    if(BSC_OLAP_MAIN.b_table_col_type_created) then
       BSC_OLAP_MAIN.drop_tmp_col_type_table;
    end if;

    --Enable parallel: need to disable parallel here since I am getting ORA-12838 error when concurrent manager
    -- is closing the concurrent program.
    IF BSC_UPDATE_UTIL.is_parallel THEN
        h_sql := 'alter session disable parallel dml';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        commit;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_no_pending_process THEN
	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_NO_PENDING_PROCESS'),
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

   WHEN e_exists_prototype_indicators THEN
	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_METADATA_PEND_CHANGES'),
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        IF g_process_id <> -1 THEN
            h_b := Set_PStatus_Finished(PC_ERROR_STATUS);
            COMMIT;
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

   WHEN e_update_error THEN
        ROLLBACK;

	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED'),
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        IF g_process_id <> -1 THEN
            h_b := Set_PStatus_Finished(PC_ERROR_STATUS);
            COMMIT;
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

    --catching the error in creating table for bug 3899523
    --added 3899523
    WHEN e_tmp_tbl_create_error THEN
        ROLLBACK;
 	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => 'BSC_OLAP_MAIN.create_tmp_col_type_table '||h_error_message,
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        IF g_process_id <> -1 THEN
            h_b := Set_PStatus_Finished(PC_ERROR_STATUS);
            COMMIT;
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

   --Fix bug#3923207: import dbi plans into bsc benchmarks
   WHEN e_import_dbi_plans THEN
        ROLLBACK;

	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => 'BSC_UPDATE_DIM.Import_Dbi_Plans: '||h_error_message,
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        IF g_process_id <> -1 THEN
            h_b := Set_PStatus_Finished(PC_ERROR_STATUS);
            COMMIT;
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

   --LOCKING
   WHEN e_could_not_get_lock THEN
        ROLLBACK;

	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;

        -- Error is already in the log file snet to the log file
        BSC_MESSAGE.Add(x_message => 'Loader could not get the required locks to continue.',
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        IF g_process_id <> -1 THEN
            h_b := Set_PStatus_Finished(PC_ERROR_STATUS);
            COMMIT;
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

    WHEN OTHERS THEN
        ROLLBACK;

	-- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Execute_Update_Process',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        IF g_process_id <> -1 THEN
            h_b := Set_PStatus_Finished(PC_ERROR_STATUS);
            COMMIT;
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

END Execute_Update_Process;


/*===========================================================================+
| FUNCTION Execute_Year_Change_Process
+============================================================================*/
FUNCTION Execute_Year_Change_Process(
	x_calendar_id IN NUMBER
	)  RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;
    e_error_load_rpt_cal EXCEPTION;

    h_current_fy NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    -- Fix perf bug#4924515 use bsc_sys_periodicities instead of bsc_sys_periodicities_vl
    CURSOR c_tables (p_table_type NUMBER, p_calendar_id NUMBER) IS
        SELECT t.table_name, t.periodicity_id, t.current_period, p.yearly_flag
        FROM bsc_db_tables t, bsc_sys_periodicities p
        WHERE t.periodicity_id = p.periodicity_id AND
              t.table_type = p_table_type AND p.calendar_id = p_calendar_id;

    CURSOR c_base_tables_mv (p_table_type1 NUMBER, p_gen_type NUMBER,
                             p_calendar_id NUMBER, p_table_type0 NUMBER) IS
        SELECT t.table_name, t.periodicity_id, t.current_period, p.yearly_flag
        FROM bsc_db_tables t, bsc_sys_periodicities p
        WHERE t.periodicity_id = p.periodicity_id AND
              t.table_type = p_table_type1 AND t.generation_type <> p_gen_type AND
              p.calendar_id = p_calendar_id AND
              t.table_name IN (
                  SELECT r.table_name
                  FROM bsc_db_tables_rels r, bsc_db_tables b
                  WHERE r.source_table_name = b.table_name and b.table_type = p_table_type0
              );

    -- BSC-BIS-DIMENSION: I am fixing this query. We should return the PT tables, that are the
    -- ones that store projections at kpi level in MV architecture
    /*
    CURSOR c_sum_tables_mv (p_table_type1 NUMBER, p_gen_type NUMBER,
                            p_calendar_id NUMBER, p_table_type0 NUMBER) IS
        SELECT t.table_name, t.periodicity_id, t.current_period, p.yearly_flag
        FROM bsc_db_tables t, bsc_sys_periodicities_vl p
        WHERE t.periodicity_id = p.periodicity_id AND
              t.table_type = p_table_type1 AND t.generation_type <> p_gen_type AND
              p.calendar_id = p_calendar_id AND
              NOT (t.table_name IN (
                  SELECT r.table_name
                  FROM bsc_db_tables_rels r, bsc_db_tables b
                  WHERE r.source_table_name = b.table_name and b.table_type = p_table_type0
              ));
    */
    --Fix perf bug#4924515 use bsc_sys_periodicities instead of bsc_sys_periodicities_vl
    CURSOR c_sum_tables_mv (p_calendar_id NUMBER) IS
        SELECT DISTINCT k.projection_data
        FROM bsc_kpi_data_tables k, bsc_sys_periodicities p
        WHERE k.periodicity_id = p.periodicity_id AND
              p.calendar_id = p_calendar_id AND
              projection_data IS NOT NULL;


    CURSOR c_other_periodicities (p_table_name VARCHAR2, p_calc_type NUMBER) IS
        SELECT c.parameter1, p.yearly_flag
        FROM bsc_db_calculations c, bsc_sys_periodicities p
        WHERE c.table_name = p_table_name AND c.calculation_type = p_calc_type AND
              c.parameter1 = p.periodicity_id;

    TYPE t_tables IS RECORD (
        table_name 	bsc_db_tables.table_name%TYPE,
        periodicity_id  bsc_db_tables.periodicity_id%TYPE,
        current_period  bsc_db_tables.current_period%TYPE,
        yearly_flag     bsc_sys_periodicities_vl.yearly_flag%TYPE
    );

    h_table_info t_tables;

    h_table_name VARCHAR2(50);

    CURSOR c_indicators (p_calendar_id NUMBER) IS
        SELECT indicator
        FROM bsc_kpis_vl
        WHERE calendar_id = p_calendar_id;

    h_indicator NUMBER;

    h_max_previous NUMBER;
    h_max_foryear NUMBER;
    h_init_year NUMBER;
    h_end_year NUMBER;

    h_sql VARCHAR2(2000);
    h_b BOOLEAN;
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    h_periodicity_id NUMBER;
    h_yearly_flag NUMBER;
    h_current_period NUMBER;

    h_base_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_base_tables NUMBER;

    h_calendar_source VARCHAR2(20);
    h_count NUMBER;
    h_new_fiscal_year NUMBER;

    h_message VARCHAR2(4000);
    h_calendar_name VARCHAR2(2000);

    --AW_INTEGRATION: New variables
    h_aw_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_aw_indicators NUMBER;
    h_aw_table_name VARCHAR2(30);
    h_aw_flag BOOLEAN;
    h_i NUMBER;
    h_kpi_list dbms_sql.varchar2_table;
    h_aw_base_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_aw_base_tables NUMBER;

    --LOCKING: new variables
    h_error_message VARCHAR2(2000);

    -- ENH_B_TABLES_PERF: new variable
    h_proj_tbl_name VARCHAR2(30);

BEGIN

    h_current_fy := 0;
    h_max_previous := 1;
    h_max_foryear := 1;
    l_num_bind_vars := 0;
    h_num_base_tables := 0;
    h_calendar_source := NULL;
    h_count := 0;
    -- AW_INTEGRATION: init this variable
    h_num_aw_indicators := 0;
    h_num_aw_base_tables := 0;

    --LOCKING: Lock the objects required to change the calendar
    IF NOT BSC_UPDATE_LOCK.Lock_Calendar_Change(x_calendar_id) THEN
        RAISE e_could_not_get_lock;
    END IF;

    --LOCKING: review no commit between this point and the commit to release the locks

    h_calendar_name := BSC_UPDATE_UTIL.Get_Calendar_Name(x_calendar_id);

    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_YEARCHANGE_PROCESS')||' ('||
                                  h_calendar_name||')', BSC_UPDATE_LOG.OUTPUT);

    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(x_calendar_id);
    h_new_fiscal_year := h_current_fy + 1;

    -- Get calendar source
    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(x_calendar_id);

    -- BSC-BIS-DIMENSIONS: If it is a BIS calendar we need to validate that the new fiscal
    -- year is already available in BSC
    IF h_calendar_source = 'PMF' THEN
        SELECT count(year)
        INTO h_count
        FROM bsc_db_calendar
        WHERE calendar_id = x_calendar_id AND year = h_new_fiscal_year;

        IF h_count = 0 THEN
            -- The new fiscal year is not available
            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_DBI_YEAR_NOT_AVAILABLE');
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'YEAR', TO_CHAR(h_new_fiscal_year));
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'CALENDAR_NAME', h_calendar_name);
            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
            --LOCKING: commit to release locks
            COMMIT;
            RETURN FALSE;
        END IF;
    END IF;

    -- Fix bug#3636273 We are going to drop indexes to avoid commit in the middle
    --LOCKING: we are not going to drop indexes in calendar tables. If we do so, we cannot
    --run year change process on different calendars at the same time
    --IF h_calendar_source = 'BSC' THEN
    --    IF NOT BSC_UPDATE_UTIL.Init_Calendar_Tables(x_calendar_id, 1) THEN
    --        RAISE e_unexpected_error;
    --    END IF;
    --END IF;

    -- Write new current fiscal year
    -- LOCKING: There is not commit inside this function
    IF NOT BSC_UPDATE_UTIL.Set_Calendar_Fiscal_Year(x_calendar_id, (h_current_fy + 1)) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Init calendar tables (BSC Calendars)
    -- BSC-BIS-DIMENSIONS: If the calendar is from BIS we do not need to initialize calendar tables.
    -- Removing code for EDW. This was never supported.
    IF h_calendar_source = 'BSC' THEN
        -- Fix bug#3636273 add second parameter.
        -- LOCKING: no commit inside this function
        IF NOT BSC_UPDATE_UTIL.Init_Calendar_Tables(x_calendar_id) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    -- Update indicators
    OPEN c_indicators(x_calendar_id);
    FETCH c_indicators INTO h_indicator;
    WHILE c_indicators%FOUND LOOP

        -- AW_INTEGRATION: Add AW indicators to the array x_aw_indicators
        IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(h_indicator) = 2 THEN
            h_num_aw_indicators := h_num_aw_indicators + 1;
            h_aw_indicators(h_num_aw_indicators) := h_indicator;
        END IF;

        -- Update indicator current period
        --Fix perf bug#4924515: use bsc_sys_periodicities instead of bsc_sys_periodiicties_vl
        UPDATE
            bsc_kpi_periodicities
        SET
            current_period = h_current_fy + 1
        WHERE
            indicator = h_indicator AND
            periodicity_id  IN (
                SELECT
                    periodicity_id
                FROM
                    bsc_sys_periodicities
                WHERE
                    calendar_id = x_calendar_id AND
                    yearly_flag = 1);

        UPDATE
            bsc_kpi_periodicities
        SET
            current_period = 1
        WHERE
            indicator = h_indicator AND
            periodicity_id IN (
                SELECT
                    periodicity_id
                FROM
                    bsc_sys_periodicities
                WHERE
                    calendar_id = x_calendar_id AND
                    yearly_flag = 0);


        -- All colors in the panel have to be gray
        UPDATE bsc_sys_kpi_colors
        SET kpi_color = BSC_UPDATE_COLOR.GRAY,
            actual_data = NULL,
            budget_data = NULL
        WHERE indicator = h_indicator;

        UPDATE bsc_sys_objective_colors
        SET obj_color = BSC_UPDATE_COLOR.GRAY
        WHERE indicator = h_indicator;


        -- Update the name of period of indicators in BSC_KPI_DEFAULTS_TL table
        IF NOT BSC_UPDATE_UTIL.Update_Kpi_Period_Name(h_indicator) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Update date of indicator
        UPDATE
            bsc_kpi_defaults_b
        SET
            last_update_date = SYSDATE
        WHERE
            indicator = h_indicator;

        -- Fix bug#3636273 No commit in the middle
        --COMMIT;

        FETCH c_indicators INTO h_indicator;
    END LOOP;
    CLOSE c_indicators;


    -- Delete projected data from tables
    IF BSC_APPS.bsc_mv THEN
        -- BSC-MV Note: Only delete projection from base tables

        -- The following are base tables. We need to delete the projection
        -- from all the periodicities
        OPEN c_base_tables_mv(1, -1, x_calendar_id, 0);
        LOOP
            FETCH c_base_tables_mv INTO h_table_info;
            EXIT WHEN c_base_tables_mv%NOTFOUND;

            -- AW_INTEGRATION: If the base table is for AW indicators, then we need to truncate
            -- the AW table created for the base table. I will add them to the array
            -- h_aw_base_tables to truncate them later. We cannot do DDL here.
            -- Also the base table is not added to
            -- to array h_base_tables because that array is for base table for MV indicators
            h_aw_flag := BSC_UPDATE_UTIL.Is_Table_For_AW_Kpi(h_table_info.table_name);
            IF h_aw_flag THEN
                -- Base table for AW indicators
                h_num_aw_base_tables := h_num_aw_base_tables + 1;
                h_aw_base_tables(h_num_aw_base_tables) := h_table_info.table_name;
            ELSE
                -- Base table for MV indicators
                -- Add the base tbale to the array h_base_tables
                h_num_base_tables := h_num_base_tables + 1;
                h_base_tables(h_num_base_tables) := h_table_info.table_name;
            END IF;

            -- Delete projection for base periodicity
            --AW_INTEGRATION: Base table does not have periodicity_id

            --ENH_B_TABLES_PERF: In the new strategy the base table may have a projection table
            -- In this case we need to truncate the projection table and we do not need to touch
            -- the base table since it contains only actuals.
            h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_table_info.table_name);
            IF h_proj_tbl_name IS NOT NULL THEN
                BSC_UPDATE_UTIL.Truncate_Table_AT(h_proj_tbl_name);
            ELSE
                IF h_table_info.yearly_flag = 1 THEN
                    -- Annual periodicity
                    h_sql := 'DELETE FROM '||h_table_info.table_name||
                             ' WHERE YEAR > :1 AND TYPE = 0';
                    IF NOT h_aw_flag THEN
                        h_sql := h_sql||' AND PERIODICITY_ID = :2';
                        l_bind_vars_values(1):=h_table_info.current_period;
                        l_bind_vars_values(2):=h_table_info.periodicity_id;
                        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);
                    ELSE
                        l_bind_vars_values(1):=h_table_info.current_period;
                        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
                    END IF;
                ELSE
                    -- Other periodicity
                    h_sql := 'DELETE FROM '||h_table_info.table_name||
                             ' WHERE YEAR = :1 AND PERIOD > :2 AND TYPE = 0';
                    IF NOT h_aw_flag THEN
                        h_sql := h_sql||' AND PERIODICITY_ID = :3';
                        l_bind_vars_values(1):=h_current_fy;
                        l_bind_vars_values(2):=h_table_info.current_period;
                        l_bind_vars_values(3):=h_table_info.periodicity_id;
                        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,3);
                    ELSE
                        l_bind_vars_values(1):=h_current_fy;
                        l_bind_vars_values(2):=h_table_info.current_period;
                        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);
                    END IF;
                END IF;

                -- Delete projection for other periodicities
                -- AW_INTEGRATION: Base table does not have other periodicities
                IF NOT h_aw_flag THEN
                    OPEN c_other_periodicities(h_table_info.table_name, 6);
                    LOOP
                        FETCH c_other_periodicities INTO h_periodicity_id, h_yearly_flag;
                        EXIT WHEN c_other_periodicities%NOTFOUND;

                        IF h_yearly_flag = 1 THEN
                            -- Annual periodicity
                            h_sql := 'DELETE FROM '||h_table_info.table_name||
                                     ' WHERE YEAR > :1 AND TYPE = 0 AND PERIODICITY_ID = :2';
                            l_bind_vars_values(1):=h_current_fy;
                            l_bind_vars_values(2):=h_periodicity_id;
                            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);
                        ELSE
                            -- Get current period of this periodicity based on the current period
                            -- of the base periodicity of the base table
                            h_current_period := BSC_UPDATE_UTIL.Get_Period_Other_Periodicity(
                                                    h_periodicity_id,
                                                    x_calendar_id,
                                                    h_yearly_flag,
                                                    h_current_fy,
                                                    h_table_info.periodicity_id,
                                                    h_table_info.current_period
                                                );

                            -- Other periodicity
                            h_sql := 'DELETE FROM '||h_table_info.table_name||
                                     ' WHERE YEAR = :1 AND PERIOD > :2 AND TYPE = 0 AND PERIODICITY_ID = :3';
                            l_bind_vars_values(1):=h_current_fy;
                            l_bind_vars_values(2):=h_current_period;
                            l_bind_vars_values(3):=h_periodicity_id;
                            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,3);
                        END IF;
                    END LOOP;
                    CLOSE c_other_periodicities;
                END IF;
            END IF;
        END LOOP;
        CLOSE c_base_tables_mv;
    ELSE
        l_bind_vars_values.delete;
        OPEN c_tables(1, x_calendar_id);
        FETCH c_tables INTO h_table_info;
        WHILE c_tables%FOUND LOOP
            IF BSC_UPDATE_UTIL.Table_Exists(h_table_info.table_name) THEN
                --ENH_B_TABLES_PERF: In the new strategy the base table may have a projection table
                -- In this case we need to truncate the projection table and we do not need to touch
                -- the base table since it contains only actuals.
                h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_table_info.table_name);
                IF h_proj_tbl_name IS NOT NULL THEN
                    BSC_UPDATE_UTIL.Truncate_Table_AT(h_proj_tbl_name);
                ELSE
                    IF h_table_info.yearly_flag = 1 THEN
                        -- Annual periodicity
                        h_sql := 'DELETE FROM '||h_table_info.table_name||
                                 ' WHERE YEAR > :1 AND TYPE = 0';
                        l_bind_vars_values(1):=h_table_info.current_period;
                        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
                    ELSE
                        -- Other periodicity
                        h_sql := 'DELETE FROM '||h_table_info.table_name||
                                 ' WHERE YEAR = :1 AND PERIOD > :2 AND TYPE = 0';
                        l_bind_vars_values(1):=h_current_fy;
                        l_bind_vars_values(2):=h_table_info.current_period;
                        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);
                    END IF;
                END IF;
            END IF;
            FETCH c_tables INTO h_table_info;
        END LOOP;
        CLOSE c_tables;
    END IF;

    -- Update the current period of data tables
    -- Fix perf bug#4924515 use bsc_sys_periodiicties instead of bsc_sys_periodicities_vl
    UPDATE
        bsc_db_tables
    SET
        current_period = h_current_fy + 1,
        current_subperiod = 0
    WHERE
        table_type <> 2 AND
        periodicity_id IN (
            SELECT
                periodicity_id
            FROM
                bsc_sys_periodicities
            WHERE
                calendar_id = x_calendar_id AND
                yearly_flag = 1);


    UPDATE
        bsc_db_tables
    SET
        current_period = 1,
        current_subperiod = 0
    WHERE
        table_type <> 2 AND
        periodicity_id IN (
            SELECT
                periodicity_id
            FROM
                bsc_sys_periodicities
            WHERE
                calendar_id = x_calendar_id AND
                yearly_flag = 0);

    -- Fix bug#3636273 Now calendar and periods in the kpis and tables are ok.
    -- We can commit here
    --LOCKING: commit to release the locks
    COMMIT;

    -- Fix bug#3636273 We are going to create indexes here to avoid commit in the middle
    --LOCKING: we are not going to drop indexes in calendar tables. If we do so, we cannot
    --run year change process on different calendars at the same time
    --IF h_calendar_source = 'BSC' THEN
    --    IF NOT BSC_UPDATE_UTIL.Init_Calendar_Tables(x_calendar_id, 3) THEN
    --        RAISE e_unexpected_error;
    --    END IF;
    --END IF;

    -- Fix bug#3636273 We are going to truncate tables created to store projection
    -- at kpi level in MV architecture here to avoid commit in the middle
    -- also we refresh all MV affected by the base tables here
    -- AW_INTEGRATION: By design there are not PT tables for AW indicators.
    -- So no change here. Also remember that the array h_base_tables only
    -- has base tables for MV indicators.
    IF BSC_APPS.bsc_mv THEN
        -- BSC-MV Note: Only delete projection from base tables and tables created
        -- to store projection at kpi level

        -- The following are summary tables used to store projection.
        -- We can just truncate those tables.
        l_bind_vars_values.delete;
        OPEN c_sum_tables_mv(x_calendar_id);
        LOOP
            FETCH c_sum_tables_mv INTO h_table_name;
            EXIT WHEN c_sum_tables_mv%NOTFOUND;

            --LOCKING: Lock the table
            IF NOT BSC_UPDATE_LOCK.Lock_Table(h_table_name) THEN
                RAISE e_could_not_get_lock;
            END IF;

            --LOCKING: Call the autonomous transaction function
            BSC_UPDATE_UTIL.Truncate_Table_AT(h_table_name);

            --LOCKING: commit to release locks
            COMMIT;
        END LOOP;
        CLOSE c_sum_tables_mv;

        -- Refresh all MVs in the system affected by base tables
        IF NOT BSC_UPDATE.Refresh_System_MVs(h_base_tables, h_num_base_tables) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;
    COMMIT;

    -- AW_INTEGRATION: Truncate the AW tables created for the base table
    -- bug 5660053 we are not creating AW tables for base tables so we do not need to truncate
    /*FOR h_i IN 1..h_num_aw_base_tables LOOP
        -- We need to truncate the AW table created for the base table
        --LOCKING: Lock the table
        IF NOT BSC_UPDATE_LOCK.Lock_Table(h_aw_base_tables(h_i)) THEN
            RAISE e_could_not_get_lock;
        END IF;

        h_aw_table_name := BSC_UPDATE_BASE.Get_Base_AW_Table_Name(h_aw_base_tables(h_i));

        --LOCKING: call the autonomous transaction function
        BSC_UPDATE_UTIL.Truncate_Table_AT(h_aw_table_name);

        --LOCKING: commit to release locks
        COMMIT;
    END LOOP;*/

    -- AW_INTEGRATION: Refresh indicators cubes
    FOR h_i IN 1..h_num_aw_indicators LOOP
        IF BSC_UPDATE_UTIL.Is_Kpi_In_Production(h_aw_indicators(h_i)) THEN
            --LOCKING: Lock the objects required to refresh the AW indicator cubes
            IF NOT BSC_UPDATE_LOCK.Lock_Refresh_AW_Indicator(h_aw_indicators(h_i)) THEN
                RAISE e_could_not_get_lock;
            END IF;

            --LOCKING: call the autonomous transaction procedure
            BSC_UPDATE_SUM.Refresh_AW_Kpi_AT(h_aw_indicators(h_i));

            -- LOCKING: commit to release locks
            COMMIT;
        END IF;
    END LOOP;
    COMMIT;

    -- Write the update date
    --LOCKING: Lock date of update process
    IF NOT BSC_UPDATE_LOCK.Lock_Update_Date THEN
        RAISE e_could_not_get_lock;
    END IF;

    IF NOT BSC_UPDATE_UTIL.Write_Init_Variable_Value('UPDATE_DATE', TO_CHAR(SYSDATE, 'DD/MM/YYYY')) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Fix bug#3636273 Move this call here.
    -- Update the system time stamp
    BSC_UPDATE_UTIL.Update_System_Time_Stamp;

    --LOCKING: commit to release locks
    COMMIT;

    --LOCKING: mode this code here
    -- BSC_MV Note: Populate reporting calendar
    -- Fix bug#4027813: move load reporting calendar here and pass calendar id
    IF BSC_APPS.bsc_mv THEN
        -- LOCKING: lock the calendar
        IF NOT BSC_UPDATE_LOCK.Lock_Calendar(x_calendar_id) THEN
            RAISE e_could_not_get_lock;
        END IF;

        --LOCKING: call the autonomous transaction
        IF NOT BSC_BIA_WRAPPER.Load_Reporting_Calendar_AT(x_calendar_id, h_error_message) THEN
            RAISE e_error_load_rpt_cal;
        END IF;

        --AW_INTEGRATION: call aw api to import calendars into aw world
        --LOCKING: call the autonomous transaction
        BSC_UPDATE_UTIL.Load_Calendar_Into_AW_AT(x_calendar_id);

        --LOCKING: commit to release locks
        COMMIT;
    END IF;

    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_YEARCHANGE_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => BSC_UPDATE_UTIL.Get_Message('BSC_YEARCHANGE_FAILED'),
                         x_source => 'BSC_UPDATE.Execute_Year_Change_Process');

        RETURN FALSE;

    --LOCKING
    WHEN e_could_not_get_lock THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => 'Loader could not get the required locks to continue.',
                         x_source => 'BSC_UPDATE.Execute_Year_Change_Process');

        RETURN FALSE;

    --LOCKING
   WHEN e_error_load_rpt_cal THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => 'BSC_BIA_WRAPPER.Load_Reporting_Calendar: '||h_error_message,
                         x_source => 'BSC_UPDATE.Execute_Year_Change_Process');

        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_UPDATE.Execute_Year_Change_Process');

        RETURN FALSE;

END Execute_Year_Change_Process;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Execute_Year_Change_Process_AT
+============================================================================*/
FUNCTION Execute_Year_Change_Process_AT(
	x_calendar_id IN NUMBER
	)  RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Execute_Year_Change_Process(x_calendar_id);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Execute_Year_Change_Process_AT;


/*===========================================================================+
| FUNCTION Exists_Prototype_Indicators
+============================================================================*/
FUNCTION Exists_Prototype_Indicators RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_prototype t_cursor;
    c_prototype_sql VARCHAR2(2000) := 'SELECT COUNT(prototype_flag)'||
                                      ' FROM bsc_kpis_vl'||
                                      ' WHERE prototype_flag IN (1, 2, 3, 4, 5)';
    */

    h_count NUMBER;
    h_res BOOLEAN;

BEGIN

    h_res := FALSE;

    /*
    OPEN c_prototype FOR c_prototype_sql;
    FETCH c_prototype INTO h_count;
    CLOSE c_prototype;
    */
    SELECT COUNT(prototype_flag)
    INTO h_count
    FROM bsc_kpis_vl
    WHERE prototype_flag IN (1, 2, 3, 4, 5);

    IF h_count > 0 THEN
       h_res := TRUE;
    END IF;

    RETURN h_res;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Exists_Prototype_Indicators');
        RETURN NULL;

END Exists_Prototype_Indicators;


/*===========================================================================+
| FUNCTION Flag_Last_Stage_Input_Table
+============================================================================*/
FUNCTION Flag_Last_Stage_Input_Table(
	x_input_table IN VARCHAR2
	) RETURN BOOLEAN IS
BEGIN

    UPDATE
        bsc_db_loader_control
    SET
        last_stage_flag = 0
    WHERE
        input_table_name = x_input_table;

    UPDATE
        bsc_db_loader_control
    SET
        last_stage_flag = 1
    WHERE
        input_table_name = x_input_table AND
        process_id = g_process_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Flag_Last_Stage_Input_Table');
        RETURN FALSE;

END Flag_Last_Stage_Input_Table;


/*===========================================================================+
| FUNCTION Get_Base_Table_Of_Input_Table
+============================================================================*/
FUNCTION Get_Base_Table_Of_Input_Table(
	x_input_table IN VARCHAR2,
        x_base_table OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_base_table t_cursor; -- x_input_table, 0
    c_base_table_sql VARCHAR2(2000) := 'SELECT table_name'||
                                       ' FROM bsc_db_tables_rels'||
                                       ' WHERE UPPER(source_table_name) = UPPER(:1) AND relation_type = :2';
    */

BEGIN
    /*
    OPEN c_base_table FOR c_base_table_sql USING x_input_table, 0;
    FETCH c_base_table INTO x_base_table;
    IF c_base_table%NOTFOUND THEN
        x_base_table := NULL;
    END IF;
    CLOSE c_base_table;
    */

    BEGIN
        SELECT table_name
        INTO x_base_table
        FROM bsc_db_tables_rels
        WHERE UPPER(source_table_name) = UPPER(x_input_table) AND relation_type = 0;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_base_table := NULL;
    END;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Base_Table_Of_Input_Table');
        RETURN FALSE;

END Get_Base_Table_Of_Input_Table;


/*===========================================================================+
| FUNCTION Get_EDW_Dims_In_Input_Tables
+============================================================================*/
FUNCTION Get_EDW_Dims_In_Input_Tables (
	x_edw_dim_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_edw_dim_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_edw_dimensions t_cursor; -- 1, h_column_type_p, g_process_id, LC_PENDING_STATUS
    c_edw_dimensions_sql VARCHAR2(2000) := 'SELECT level_table_name'||
                                           ' FROM bsc_sys_dim_levels_b'||
                                           ' WHERE NVL(edw_flag, 0) = :1 AND'||
                                           ' level_pk_col IN (SELECT column_name'||
                                           ' FROM bsc_db_tables_cols c, bsc_db_loader_control p'||
                                           ' WHERE c.table_name = p.input_table_name AND'||
                                           ' c.column_type = :2 AND p.process_id = :3 AND p.status = :4)';
    */
    CURSOR c_edw_dimensions (p_edw_flag NUMBER, p_column_type VARCHAR2, p_process_id NUMBER, p_status VARCHAR2) IS
        SELECT level_table_name
        FROM bsc_sys_dim_levels_b
        WHERE NVL(edw_flag, 0) = p_edw_flag AND
              level_pk_col IN (
                  SELECT column_name
                  FROM bsc_db_tables_cols c, bsc_db_loader_control p
                  WHERE c.table_name = p.input_table_name AND
                        c.column_type = p_column_type AND p.process_id = p_process_id AND p.status = p_status);

    h_column_type_p VARCHAR2(1);

    h_dim_table VARCHAR2(30);

BEGIN
    h_column_type_p := 'P';
    x_num_edw_dim_tables := 0;

    --OPEN c_edw_dimensions FOR c_edw_dimensions_sql USING 1, h_column_type_p, g_process_id, LC_PENDING_STATUS;
    OPEN c_edw_dimensions(1, h_column_type_p, g_process_id, LC_PENDING_STATUS);
    FETCH c_edw_dimensions INTO h_dim_table;
    WHILE c_edw_dimensions%FOUND LOOP
        x_num_edw_dim_tables := x_num_edw_dim_tables + 1;
        x_edw_dim_tables(x_num_edw_dim_tables) := h_dim_table;

        FETCH c_edw_dimensions INTO h_dim_table;
    END LOOP;
    CLOSE c_edw_dimensions;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_EDW_Dims_In_Input_Tables');
        RETURN FALSE;
END Get_EDW_Dims_In_Input_Tables;


/*===========================================================================+
| FUNCTION Get_Indicators_To_Color
+============================================================================*/
FUNCTION Get_Indicators_To_Color(
	x_base_tables_to_color IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_base_tables_to_color IN NUMBER,
        x_color_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
        x_num_color_indicators IN OUT NOCOPY NUMBER
        ) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;
    h_i NUMBER;
    h_lst_where VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);

    h_indicator NUMBER;

BEGIN

    h_num_system_tables := 0;
    h_lst_where := NULL;
    h_sql := NULL;

    -- If an indicator use a table that was calculated then that indicator
    -- will be colored

    IF NOT Insert_Affected_Tables(x_base_tables_to_color,
                                  x_num_base_tables_to_color,
                                  h_system_tables,
                                  h_num_system_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    h_lst_where := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'table_name');
    FOR h_i IN 1 .. x_num_base_tables_to_color LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_base_tables_to_color(h_i));
    END LOOP;

    FOR h_i IN 1 .. h_num_system_tables LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, h_system_tables(h_i));
    END LOOP;

    h_sql := 'SELECT DISTINCT indicator '||
             'FROM bsc_kpi_data_tables '||
             'WHERE '||h_lst_where;

    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_indicator;
    WHILE h_cursor%FOUND LOOP
        x_num_color_indicators := x_num_color_indicators + 1;
        x_color_indicators(x_num_color_indicators) := h_indicator;

        FETCH h_cursor INTO h_indicator;
    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_COLORKPILIST_FAILED'),
                        x_source => 'BSC_UPDATE.Get_Indicators_To_Color');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Indicators_To_Color');
        RETURN FALSE;

END Get_Indicators_To_Color;


/*===========================================================================+
| FUNCTION Get_Last_Stage_Input_Table
+============================================================================*/
FUNCTION Get_Last_Stage_Input_Table(
	x_input_table IN VARCHAR2,
        x_last_stage OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_last_stage t_cursor; -- x_input_table, 1
    c_last_stage_sql VARCHAR2(2000) := 'SELECT stage'||
                                       ' FROM bsc_db_loader_control'||
                                       ' WHERE input_table_name = :1 AND last_stage_flag = :2';
    */

BEGIN
    /*
    OPEN c_last_stage FOR c_last_stage_sql USING x_input_table, 1;
    FETCH c_last_stage INTO x_last_stage;
    IF c_last_stage%NOTFOUND THEN
        x_last_stage := '?';
    END IF;
    CLOSE c_last_stage;
    */
    BEGIN
        SELECT stage
        INTO x_last_stage
        FROM bsc_db_loader_control
        WHERE input_table_name = x_input_table AND last_stage_flag = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_last_stage := '?';
    END;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Last_Stage_Input_Table');
        RETURN FALSE;

END Get_Last_Stage_Input_Table;


/*===========================================================================+
| FUNCTION Get_Process_Id
+============================================================================*/
FUNCTION Get_Process_Id (
        x_process_id IN NUMBER,
	x_process_name IN VARCHAR2
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_process_status t_cursor; -- x_process_id
    c_process_status_sql VARCHAR2(2000) := 'SELECT status'||
                                           ' FROM bsc_db_process_control'||
                                           ' WHERE process_id = :1';
    */

    h_status VARCHAR2(1);
    h_process_id NUMBER;

BEGIN
    /*
    OPEN c_process_status FOR c_process_status_sql USING x_process_id;
    FETCH c_process_status INTO h_status;
    IF c_process_status%NOTFOUND THEN
        CLOSE c_process_status;
        -- The process does not exist
        h_process_id := -1;
        RETURN h_process_id;
    END IF;
    CLOSE c_process_status;
    */
    BEGIN
       SELECT status
       INTO h_status
       FROM bsc_db_process_control
       WHERE process_id = x_process_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- The process does not exist
            h_process_id := -1;
    END;

    IF h_process_id = -1 THEN
        -- The process does not exist
        RETURN h_process_id;
    END IF;

    IF h_status = PC_PENDING_STATUS THEN
        --The process is pending so this is the porcess to be executed
        h_process_id := x_process_id;
        RETURN x_process_id;
    END IF;

    -- Create a new process with same parameters as given one
    -- BSC_DB_PROCESS_CONTROL

    --LOCKING: get the sequence nextval here and then use it
    SELECT BSC_DB_PROCESS_ID_S.NEXTVAL
    INTO h_process_id
    FROM DUAL;

    INSERT INTO BSC_DB_PROCESS_CONTROL (
        PROCESS_ID,
        PROCESS_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        STATUS,
        DESCRIPTION
    )
    SELECT
        h_process_id,
        PROCESS_NAME,
        g_user_id,
        SYSDATE,
        g_user_id,
        SYSDATE,
        g_session_id,
        PC_PENDING_STATUS,
        DESCRIPTION
    FROM
        BSC_DB_PROCESS_CONTROL
    WHERE
        PROCESS_ID = x_process_id;

    IF x_process_name = PC_LOADER_PROCESS THEN
        -- Associate same input tables to new process
        --BUG 1473202 Input tables from a previous process may have been dropped due to
        --some system change, so we cannot take those input tables
        --BSC_DB_LOADER_CONTROL
        INSERT INTO BSC_DB_LOADER_CONTROL (
            PROCESS_ID,
            INPUT_TABLE_NAME,
            STATUS,
            ERROR_CODE,
            STAGE,
            LAST_STAGE_FLAG
        )
        SELECT
            h_process_id,
            INPUT_TABLE_NAME,
            LC_PENDING_STATUS,
            NULL,
            LC_PENDING_STAGE,
            0
        FROM
            BSC_DB_LOADER_CONTROL
        WHERE
            PROCESS_ID = x_process_id AND
            INPUT_TABLE_NAME IN (SELECT TABLE_NAME FROM BSC_DB_TABLES WHERE TABLE_TYPE = 0);
    END IF;

    IF x_process_name = PC_LOAD_DIMENSIONS THEN
        -- Associate same input tables to new process
        --BSC_DB_LOADER_CONTROL
        INSERT INTO BSC_DB_LOADER_CONTROL (
            PROCESS_ID,
            INPUT_TABLE_NAME,
            STATUS,
            ERROR_CODE,
            STAGE,
            LAST_STAGE_FLAG
        )
        SELECT
            h_process_id,
            INPUT_TABLE_NAME,
            LC_PENDING_STATUS,
            NULL,
            LC_PENDING_STAGE,
            0
        FROM
            BSC_DB_LOADER_CONTROL
        WHERE
            PROCESS_ID = x_process_id AND
            INPUT_TABLE_NAME IN (SELECT TABLE_NAME FROM BSC_DB_TABLES WHERE TABLE_TYPE = 2);
    END IF;

    COMMIT;

    RETURN h_process_id;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Process_Id');
        RETURN NULL;

END Get_Process_Id;


/*===========================================================================+
| FUNCTION Get_Process_Input_Tables
+============================================================================*/
FUNCTION Get_Process_Input_Tables (
	x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER,
        x_status IN VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_input_tables t_cursor; -- g_process_id, x_status
    c_input_tables_sql VARCHAR2(2000) := 'SELECT input_table_name'||
                                         ' FROM bsc_db_loader_control'||
                                         ' WHERE process_id = :1 AND status = :2';
    */
    CURSOR c_input_tables (p_process_id NUMBER, p_status VARCHAR2) IS
        SELECT input_table_name
        FROM bsc_db_loader_control
        WHERE process_id = p_process_id AND status = p_status;

    h_input_table_name VARCHAR2(30);

BEGIN
    x_num_input_tables := 0;
    --OPEN c_input_tables FOR c_input_tables_sql USING g_process_id, x_status;
    OPEN c_input_tables(g_process_id, x_status);
    FETCH c_input_tables INTO h_input_table_name;
    WHILE c_input_tables%FOUND LOOP
        x_num_input_tables := x_num_input_tables + 1;
        x_input_tables(x_num_input_tables) := h_input_table_name;

        FETCH c_input_tables INTO h_input_table_name;
    END LOOP;
    CLOSE c_input_tables;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Process_Input_Tables');
        RETURN FALSE;

END Get_Process_Input_Tables;


/*===========================================================================+
| FUNCTION Init_Env_Values
+============================================================================*/
FUNCTION Init_Env_Values RETURN BOOLEAN IS

BEGIN
    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    g_user_id := BSC_APPS.fnd_global_user_id;
    g_session_id := USERENV('SESSIONID');
    g_schema_name := BSC_APPS.fnd_apps_schema;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Init_Env_Values');
        RETURN FALSE;

END Init_Env_Values;


/*===========================================================================+
| FUNCTION Import_ITables_From_DBSrc
+============================================================================*/
FUNCTION Import_ITables_From_DBSrc(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_source_type NUMBER;
    h_source_name VARCHAR2(500);

    h_i NUMBER;
    h_message VARCHAR2(4000);

    h_input_table VARCHAR2(30);

BEGIN
    h_source_name := NULL;

    FOR h_i IN 1 .. x_num_input_tables LOOP
        h_input_table := x_input_tables(h_i);

        IF NOT BSC_UPDATE_UTIL.Get_Input_Table_Source(h_input_table, h_source_type, h_source_name) THEN
            RAISE e_unexpected_error;
        END IF;

        IF h_source_type = 4 THEN
            -- Stored procedure

            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_IMPORTING_TO_ITABLE');
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'INPUT_TABLE', h_input_table);
            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

            h_message := BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SOURCE')||
                         BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||' '||h_source_name;
            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

            -- LOCKING: Lock required objects
            IF NOT BSC_UPDATE_LOCK.Lock_Import_ITable(h_input_table) THEN
                RAISE e_could_not_get_lock;
            END IF;

            -- LOCKING: call the autonomous transaction
            IF NOT Import_ITable_StoredProc_AT(h_input_table, h_source_name) THEN
                 RAISE e_unexpected_error;
            END IF;

            -- LOCKING: commit to release the lock
            COMMIT;
        END IF;

    END LOOP;

    RETURN TRUE;

EXCEPTION
    --LOCKING
    WHEN e_could_not_get_lock THEN
        BSC_MESSAGE.Add (x_message => 'Loader could not get the required locks to continue.',
                         x_source => 'BSC_UPDATE.Import_ITables_From_DBSrc');
        RETURN FALSE;

    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_UPDATE_UTIL.Get_Message('BSC_IMPORT_ITABLES_FAILED'),
                         x_source => 'BSC_UPDATE.Import_ITables_From_DBSrc');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_UPDATE.Import_ITables_From_DBSrc');
        RETURN FALSE;
END Import_ITables_From_DBSrc;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Import_ITables_From_DBSrc_AT
+============================================================================*/
FUNCTION Import_ITables_From_DBSrc_AT(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Import_ITables_From_DBSrc(x_input_tables, x_num_input_tables);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Import_ITables_From_DBSrc_AT;


/*===========================================================================+
| FUNCTION Import_ITable_StoredProc
+============================================================================*/
FUNCTION Import_ITable_StoredProc(
	x_input_table IN VARCHAR2,
	x_stored_proc IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;

    /*
    c_status t_cursor; -- x_stored_proc, h_procedure
    c_status_sql VARCHAR2(2000) := 'SELECT status'||
                                   ' FROM user_objects'||
                                   ' WHERE object_name = :1 AND object_type = :2';
    */
    /*BUG#6598575 - logic for validating the Data Load Program(i.e.checking the status) is disabled*/
    /*CURSOR c_status (p_object_name VARCHAR2, p_object_type VARCHAR2) IS
        SELECT status
        FROM user_objects
        WHERE object_name = p_object_name AND object_type = p_object_type;

    h_procedure VARCHAR2(30);
    h_stored_proc VARCHAR(200);
    h_status VARCHAR2(20);*/
    h_message VARCHAR2(4000);

BEGIN
    h_sql := NULL;
    /*h_procedure := 'PROCEDURE';*/

    -- Delete data from the input table
    h_sql := 'DELETE FROM '||x_input_table;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    COMMIT;

    /*h_stored_proc := UPPER(x_stored_proc);

    -- Validate the stored procedure
    --OPEN c_status FOR c_status_sql USING h_stored_proc, h_procedure;
    OPEN c_status(h_stored_proc, h_procedure);
    FETCH c_status INTO h_status;
    IF c_status%FOUND THEN
        IF h_status = 'VALID' THEN*/
            -- Execute the stored procedure to populate the input table
            BEGIN
                h_sql := 'BEGIN '||x_stored_proc||'; END;';
                BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

                -- Update the stage of the input table to UPLOADED
                IF NOT Update_Stage_Input_Table(x_input_table, LC_UPLOADED_STAGE) THEN
                    RAISE e_unexpected_error;
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    -- Error executing the stored procedure
                    IF NOT Update_Status_Input_Table(x_input_table, LC_ERROR_STATUS, LC_UPLOAD_SP_EXECUTION_ERR) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    h_message := BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'ERROR')||
                                 BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||' '||
                                 BSC_UPDATE_UTIL.Get_Message('BSC_STOREDPROC_FAILED');
                    BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                    BSC_UPDATE_LOG.Write_Line_Log(SQLERRM, BSC_UPDATE_LOG.OUTPUT);
            END;
/*
        ELSE
            -- Stored procedure is invalid
            IF NOT Update_Status_Input_Table(x_input_table, LC_ERROR_STATUS, LC_UPLOAD_SP_INVALID_ERR) THEN
                RAISE e_unexpected_error;
            END IF;

            h_message := BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'ERROR')||
                         BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||' '||
                         BSC_UPDATE_UTIL.Get_Message('BSC_STOREDPROC_IS_INVALID');
            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
        END IF;
    ELSE
        -- Stored procedure does not exists
        IF NOT Update_Status_Input_Table(x_input_table, LC_ERROR_STATUS, LC_UPLOAD_SP_NOT_FOUND_ERR) THEN
            RAISE e_unexpected_error;
        END IF;

        h_message := BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'ERROR')||
                     BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||' '||
                     BSC_UPDATE_UTIL.Get_Message('BSC_STOREDPROC_NOT_FOUND');
        BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
    END IF;
    CLOSE c_status;
*/
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_UPDATE_UTIL.Get_Message('BSC_IMPORT_ITABLES_FAILED'),
                         x_source => 'BSC_UPDATE.Import_ITable_StoredProc');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_UPDATE.Import_ITable_StoredProc');
        RETURN FALSE;
END Import_ITable_StoredProc;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Import_ITable_StoredProc_AT
+============================================================================*/
FUNCTION Import_ITable_StoredProc_AT(
	x_input_table IN VARCHAR2,
	x_stored_proc IN VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Import_ITable_StoredProc(x_input_table, x_stored_proc);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Import_ITable_StoredProc_AT;


/*===========================================================================+
| FUNCTION Insert_Affected_Tables
+============================================================================*/
FUNCTION Insert_Affected_Tables (
	x_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_tables IN NUMBER,
        x_affected_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_affected_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    --h_cursor t_cursor;

    CURSOR c_tables (p_source_table_name VARCHAR2) IS
        SELECT table_name
        FROM bsc_db_tables_rels
        WHERE source_table_name = p_source_table_name;

    h_new_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_new_tables NUMBER;

    h_i NUMBER;
    h_sql VARCHAR2(32700);

    h_table_name VARCHAR2(30);

BEGIN

    h_num_new_tables := 0;

    FOR h_i IN 1 .. x_num_tables LOOP
        /*
        h_sql := 'SELECT table_name'||
                 ' FROM bsc_db_tables_rels'||
                 ' WHERE source_table_name = :1';
        --OPEN h_cursor FOR h_sql USING x_tables(h_i);
        */
        OPEN c_tables(x_tables(h_i));
        FETCH c_tables INTO h_table_name;
        WHILE c_tables%FOUND LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_table_name, x_affected_tables, x_num_affected_tables) THEN
                x_num_affected_tables := x_num_affected_tables + 1;
                x_affected_tables(x_num_affected_tables) := h_table_name;

                h_num_new_tables := h_num_new_tables + 1;
                h_new_tables(h_num_new_tables) := h_table_name;
            END IF;

            FETCH c_tables INTO h_table_name;
        END LOOP;
        CLOSE c_tables;

    END LOOP;

    IF h_num_new_tables > 0 THEN
        IF NOT Insert_Affected_Tables(h_new_tables, h_num_new_tables, x_affected_tables, x_num_affected_tables) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_TABLES_INSERT_FAILED'),
                        x_source => 'BSC_UPDATE.Insert_Affected_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Insert_Affected_Tables');
        RETURN FALSE;

END Insert_Affected_Tables;


/*===========================================================================+
| FUNCTION Load_Dim_Input_Tables
+============================================================================*/
FUNCTION Load_Dim_Input_Tables(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_dim_tables NUMBER;

    h_loaded_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_loaded_tables NUMBER;

    h_i NUMBER;
    h_b BOOLEAN;
    h_message VARCHAR2(4000);

    h_input_table VARCHAR2(30);
    h_dim_table VARCHAR2(30);

    h_table_has_any_row BOOLEAN;
    h_table_is_valid BOOLEAN;

    --AW_INTEGRATION: new variables
    h_dim_table_type NUMBER;
    h_dim_level_list dbms_sql.varchar2_table;
    h_dim_was_loaded BOOLEAN;

    h_input_tables_err_status BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables_err_status NUMBER;

    CURSOR c_input_tables_err_status IS
        SELECT input_table_name
        FROM bsc_db_loader_control
        WHERE process_id = g_process_id AND status = LC_ERROR_STATUS;

BEGIN
    h_num_dim_tables := 0;
    h_num_loaded_tables := 0;
    h_num_input_tables_err_status := 0;

    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_DIMTABLE_UPD_PROCESS'), BSC_UPDATE_LOG.OUTPUT);

    -- Get input table with status error
    OPEN c_input_tables_err_status;
    LOOP
        FETCH c_input_tables_err_status INTO h_input_table;
        EXIT WHEN c_input_tables_err_status%NOTFOUND;
        h_num_input_tables_err_status := h_num_input_tables_err_status + 1;
        h_input_tables_err_status(h_num_input_tables_err_status) := h_input_table;
    END LOOP;
    CLOSE c_input_tables_err_status;

    -- Update the status of all input tables from PENDING to RUNNING
    IF NOT Update_Status_All_Input_Tables(LC_PENDING_STATUS, LC_RUNNING_STATUS, NULL) THEN
        RAISE e_unexpected_error;
    END IF;
    COMMIT;

    -- Init array h_dim_tables which contains the dimension table corrsponding to input
    -- tables in array x_input_tables (same order)
    FOR h_i IN 1 .. x_num_input_tables LOOP
        h_dim_tables(h_i) := BSC_UPDATE_DIM.Get_Dim_Table_of_Input_Table(x_input_tables(h_i));
    END LOOP;
    h_num_dim_tables := x_num_input_tables;

    -- Load input tables
    -- We need to load the parent tables before child tables
    -- This is to avoid invalid relationships when a parent and a child table are going to be
    -- loaded in the same process.

    -- Until all system tables have been calculated
    WHILE h_num_loaded_tables <> h_num_dim_tables LOOP
        FOR h_i IN 1 .. h_num_dim_tables LOOP
            h_dim_table := h_dim_tables(h_i);

            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_dim_table,
                                                                 h_loaded_tables,
                                                                 h_num_loaded_tables) THEN
                -- The table has not been calculated yet

                -- Check if the table can be calculated now
                h_b := Can_Load_Dim_Table(h_dim_table,
                                          h_loaded_tables,
                                          h_num_loaded_tables,
                                          h_dim_tables,
                                          h_num_dim_tables);

                IF h_b IS NULL THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_b THEN
                    -- Table can be loaded because all the parent tables for that table
                    -- have already been loaded

                    h_input_table := x_input_tables(h_i);

                    --LOCKING: Lock the required objects to process this dimension table
                    --LOCKING: Remove any commit between this point and the commit to release the locks
                    IF NOT BSC_UPDATE_LOCK.Lock_Load_Dimension_Table(h_dim_table, h_input_table) THEN
                        RAISE e_could_not_get_lock;
                    END IF;

                    -- AW_INTEGRATION: init this variable
                    h_dim_was_loaded := FALSE;

                    IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_input_table,
                                                                         h_input_tables_err_status,
                                                                         h_num_input_tables_err_status) THEN
                        -- Input table is ok, there was no error before loading it from stored procedure

                        -- Know if the input table is empty or not.
                        h_table_has_any_row := BSC_UPDATE_UTIL.Table_Has_Any_Row(h_input_table);

                        IF h_table_has_any_row IS NULL THEN
                            RAISE e_unexpected_error;
                        END IF;

                        IF h_table_has_any_row THEN
                            -- Input table has records. The table can be processed

                            -- Validate input table
                            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_VALIDATION');
                            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                            --LOCKING: call the automous transaction function
                            h_table_is_valid := BSC_UPDATE_DIM.Validate_Input_Table_AT(h_input_table, h_dim_table);

                            IF h_table_is_valid IS NULL THEN
                                RAISE e_unexpected_error;
                            END IF;

                            IF h_table_is_valid THEN
                                -- Input table doesn't have invalid codes
                                h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_VALIDCONF');
                                h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                                BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                                -- Update the stage of the input table to VALIDATED
                                IF NOT Update_Stage_Input_Table(h_input_table, LC_VALIDATED_STAGE) THEN
                                    RAISE e_unexpected_error;
                                END IF;

                                -- Load the dimension table
                                BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_UPDATING_DIM_TABLE')||
                                                              ' '||h_dim_table, BSC_UPDATE_LOG.OUTPUT);

                                --LOCKING: Call the autonomous trnsaction
                                IF NOT BSC_UPDATE_DIM.Load_Dim_Table_AT(h_dim_table, h_input_table) THEN
                                    RAISE e_unexpected_error;
                                END IF;

                                -- AW_INTEGRATION: init this variable
                                h_dim_was_loaded := TRUE;

                                -- Update the stage of the input table to COMPLETED UPDATED
                                IF NOT Update_Stage_Input_Table(h_input_table, LC_COMPLETED_STAGE) THEN
                                    RAISE e_unexpected_error;
                                END IF;

                                h_message := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATED_DIM_TABLE');
                                h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_dim_table);
                                BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                            ELSE
                                -- Input table has invalid codes
                                h_message := BSC_UPDATE_UTIL.Get_Message('BSC_INVALID_CODES_ITABLE');
                                h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                                BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                                -- Update the status of input table to ERROR
                                IF NOT Update_Status_Input_Table(h_input_table, LC_ERROR_STATUS, LC_INVALID_CODES_ERR) THEN
                                    RAISE e_unexpected_error;
                                END IF;
                            END IF;
                        ELSE
                            -- Input table doesn't have any record.

                            -- The input table cannot be processed because is an empty table
                            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_MISSING_DATA_ITABLE');
                            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                            -- Update the status of the input table to NO_DATA
                            IF NOT Update_Status_Input_Table(h_input_table, LC_NO_DATA_STATUS, NULL) THEN
                                RAISE e_unexpected_error;
                            END IF;
                        END IF;
                    END IF;

                    --AW_INTEGRATION: We need to load the dimension into AW even if the table was not loaded
                    IF NOT h_dim_was_loaded THEN
                        h_dim_table_type := BSC_UPDATE_DIM.Get_Dim_Table_Type(h_dim_table);
                        IF h_dim_table_type = BSC_UPDATE_DIM.DIM_TABLE_TYPE_1N THEN
                            IF BSC_UPDATE_DIM.Dimension_Used_In_AW_Kpi(h_dim_table) THEN
                                BSC_UPDATE_LOG.Write_Line_Log('Loading '||h_dim_table||' into AW', BSC_UPDATE_LOG.OUTPUT);
                                --LOCKING: Call the autonomous transaction procedure
                                BSC_UPDATE_DIM.Load_Dim_Into_AW_AT(h_dim_table);
                            END IF;
                        END IF;
                    END IF;

                    -- Add table to array of loaded tables
                    h_num_loaded_tables := h_num_loaded_tables + 1;
                    h_loaded_tables(h_num_loaded_tables) := h_dim_tables(h_i);

                    --LOCKING: commit to release the locks
                    COMMIT;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    -- Update the date of update process
    IF NOT BSC_UPDATE_UTIL.Write_Init_Variable_Value('UPDATE_DATE_DIM', TO_CHAR(SYSDATE, 'DD/MM/YYYY')) THEN
        RAISE e_unexpected_error;
    END IF;
    COMMIT;

    -- Update the status of input tables
    IF NOT Update_Stage_Input_Tables(LC_RUNNING_STATUS, LC_COMPLETED_STAGE, FALSE) THEN
        RAISE e_unexpected_error;
    END IF;
    COMMIT;

    IF NOT Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_COMPLETED_STATUS, NULL) THEN
        RAISE e_unexpected_error;
    END IF;
    COMMIT;

    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_DIMTABLE_UPDATED'), BSC_UPDATE_LOG.OUTPUT);

    -- Write indicator with unexisting default dimenision values
    IF NOT BSC_UPDATE_DIM.WriteRemovedKeyItems THEN
        NULL;
    END IF;

    RETURN TRUE;
EXCEPTION
    --LOCKING
    WHEN e_could_not_get_lock THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => 'Loader could not get the required locks to continue.',
                         x_source => 'BSC_UPDATE.Load_Dim_Input_Tables');
        h_b := Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_ERROR_STATUS, LC_PROGRAM_ERR);
        COMMIT;

        RETURN FALSE;

    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DIMTABLE_UPDATE_FAILED'),
                         x_source => 'BSC_UPDATE.Load_Dim_Input_Tables');
        h_b := Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_ERROR_STATUS, LC_PROGRAM_ERR);
        COMMIT;

        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_UPDATE.Load_Dim_Input_Tables');

        h_b := Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_ERROR_STATUS, LC_PROGRAM_ERR);
        COMMIT;

        RETURN FALSE;
END Load_Dim_Input_Tables;


--AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Load_Dims_Into_AW
+============================================================================*/
FUNCTION Load_Dims_Into_AW(
    x_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_dim_tables IN NUMBER
) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_loaded_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_loaded_tables NUMBER;

    h_i NUMBER;
    h_b BOOLEAN;

    h_dim_table VARCHAR2(30);

    h_dim_level_list dbms_sql.varchar2_table;

BEGIN
    h_num_loaded_tables := 0;

    -- We need to load the parent tables before child tables

    -- Until all dimensions have been loaded
    WHILE h_num_loaded_tables <> x_num_dim_tables LOOP
        FOR h_i IN 1 .. x_num_dim_tables LOOP
            h_dim_table := x_dim_tables(h_i);

            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_dim_table,
                                                                 h_loaded_tables,
                                                                 h_num_loaded_tables) THEN
                -- The table has not been calculated yet

                -- Check if the table can be calculated now
                h_b := Can_Load_Dim_Table(h_dim_table,
                                          h_loaded_tables,
                                          h_num_loaded_tables,
                                          x_dim_tables,
                                          x_num_dim_tables);

                IF h_b IS NULL THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_b THEN
                    -- Table can be loaded because all the parent tables for that table
                    -- have already been loaded

                    h_dim_level_list.delete;
                    h_dim_level_list(1) := h_dim_table;
                    bsc_aw_load.load_dim(
                        p_dim_level_list => h_dim_level_list,
                        p_options => 'DEBUG LOG'
                    );

                    -- Add table to array of loaded tables
                    h_num_loaded_tables := h_num_loaded_tables + 1;
                    h_loaded_tables(h_num_loaded_tables) := x_dim_tables(h_i);

                    commit;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DIMTABLE_UPDATE_FAILED'),
                         x_source => 'BSC_UPDATE.Load_Dims_Into_AW');
        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_UPDATE.Load_Dims_Into_AW');
        RETURN FALSE;
END Load_Dims_Into_AW;


-- Update Prototype Flag for underlying KPI Measures for the Objective to 7,
-- so that color can be re-calculated for all of them.
FUNCTION Update_Kpis_Prototype_Flag (
  x_indicator IN NUMBER
) RETURN BOOLEAN IS
BEGIN
  -- Color By KPI: Mark KPIs for color re-calculation
  UPDATE bsc_kpi_analysis_measures_b
    SET prototype_flag = 7
    WHERE indicator = x_indicator;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add( x_message => SQLERRM
                   , x_source => 'BSC_UPDATE.Update_Kpis_Prototype_Flag');
    RETURN FALSE;
END Update_Kpis_Prototype_Flag;


/*===========================================================================+
| FUNCTION Process_Input_Tables
+============================================================================*/
FUNCTION Process_Input_Tables(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER,
	x_start_from IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_b BOOLEAN;

    h_i NUMBER;

    h_input_table VARCHAR2(30);
    h_table_has_any_row BOOLEAN;
    h_table_is_valid BOOLEAN;
    h_last_stage VARCHAR2(1);

    h_base_table VARCHAR2(30);

    h_base_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_base_tables NUMBER;

    h_base_tables_to_color BSC_UPDATE_UTIL.t_array_of_varchar2;

    h_num_base_tables_to_color NUMBER;

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;

    h_calculated_sys_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_calculated_sys_tables NUMBER;

    h_color_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_color_indicators NUMBER;

    h_message VARCHAR2(4000);

    h_table_edw_flag NUMBER;

    h_sql VARCHAR2(32000);

    h_kpis BSC_UPDATE_UTIL.t_array_kpis;
    h_num_kpis NUMBER;
    h_calc_summary_table BOOLEAN;
    h_calc_color BOOLEAN;

    -- AW_INTEGRATION: need these new variables
    h_base_tables_aw BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_base_tables_aw NUMBER;
    h_system_tables_aw BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables_aw NUMBER;
    h_indicators_aw BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators_aw NUMBER;
    h_aw_flag BOOLEAN;
    h_calc_aw_kpi BOOLEAN;
    h_kpi_list dbms_sql.varchar2_table;

    -- ENH_B_TABLES_PERF: new variables
    h_proj_tbl_name VARCHAR2(30);

BEGIN
    h_num_base_tables := 0;
    h_num_base_tables_to_color := 0;
    h_num_system_tables := 0;
    h_num_calculated_sys_tables := 0;
    h_num_color_indicators := 0;
    -- AW_INTEGRATION: init these two variables
    h_num_base_tables_aw := 0;
    h_num_system_tables_aw := 0;
    h_num_indicators_aw := 0;

    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_DATATABLE_UPD_PROCESS'), BSC_UPDATE_LOG.OUTPUT);

    -- Create generic temporal tables for the process
    --LOCKING: lock the temporary tables
    IF NOT BSC_UPDATE_LOCK.Lock_Temp_Tables('DATA') THEN
        RAISE e_could_not_get_lock;
    END IF;

    --LOCKING: call the autonomous transaction function
    IF NOT BSC_UPDATE_BASE.Create_Generic_Temp_Tables_AT THEN
        RAISE e_unexpected_error;
    END IF;

    -- ENH_B_TABLES_PERF: create new temporary tables needed in the new strategy
    IF NOT BSC_UPDATE_BASE_V2.Create_Generic_Temp_Tables_AT THEN
        RAISE e_unexpected_error;
    END IF;

    --LOCKING: commit to release the locks
    COMMIT;

    IF x_start_from = 0 THEN
        -- The process starts from input tables. This means that the program
        -- takes input tables, make codes validation and updates base tables

        -- Update the status of all input tables from PENDING to RUNNING
        IF NOT Update_Status_All_Input_Tables(LC_PENDING_STATUS, LC_RUNNING_STATUS, NULL) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;

        -- Loop into the input tables in the array x_input_tables.
        -- These tables have status RUNNING;
        -- The tables with status ERROR are not processed.

        FOR h_i IN 1 .. x_num_input_tables LOOP
            h_input_table := x_input_tables(h_i);

            -- Fix bug#4341554. move this delete here, we need to commit this deletion
            -- Fix bug#3813853. Delete invalid codes for this input table from bsc_db_validation
            DELETE FROM bsc_db_validation
            WHERE input_table_name = h_input_table;
            commit;

            --LOCKING: need to know the base table name here
            IF NOT Get_Base_Table_Of_Input_Table(h_input_table, h_base_table) THEN
                RAISE e_unexpected_error;
            END IF;

            -- AW_INTEGRATION: Know if the base table belongs to an AW Kpi
            IF BSC_APPS.bsc_mv THEN
                h_aw_flag := BSC_UPDATE_UTIL.Is_Table_For_AW_Kpi(h_base_table);
            ELSE
                h_aw_flag := FALSE;
            END IF;

            --LOCKING: lock the input table and the base table
            IF NOT BSC_UPDATE_LOCK.Lock_Update_Base_Table(h_input_table, h_base_table) THEN
                RAISE e_could_not_get_lock;
            END IF;

            --LOCKING: review no commit between this point and the commit to release the locks

            -- Know if the input table is empty or not.
            h_table_has_any_row := BSC_UPDATE_UTIL.Table_Has_Any_Row(h_input_table);

            IF h_table_has_any_row IS NULL THEN
                RAISE e_unexpected_error;
            END IF;

            IF h_table_has_any_row THEN

                -- Input table has records. The table can be processed
                -- There is new data in the input table. Therefore, this is the last
                -- stage.

                --LOCKING: no commit inside this function
                IF NOT Flag_Last_Stage_Input_Table(h_input_table) THEN
                    RAISE e_unexpected_error;
                END IF;

                -- Validate input table
                h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_VALIDATION');
                h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                --LOCKING: Call the autonomous transaction function
                h_table_is_valid := BSC_UPDATE_VAL.Validate_Codes_AT(h_input_table);

                IF h_table_is_valid IS NULL THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_table_is_valid THEN
                    -- Input table doesn't have invalid codes
                    h_message := BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_NAME_VALIDCONF');
                    h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                    BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                    -- Update the stage of the input table to VALIDATED
                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Update_Stage_Input_Table(h_input_table, LC_VALIDATED_STAGE) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- Update the base table
                    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_UPDATING_BASE_TABLE')||
                                                  ' '||h_base_table, BSC_UPDATE_LOG.OUTPUT);

                    -- ENH_B_TABLES_PERF: If the base table has a projection table then this is a new strategy.
                    h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_base_table);
                    IF h_proj_tbl_name IS NULL THEN
                        -- AW_INTEGRATION: pass h_aw_flag
                        -- LOCKING: call the autonomous transaction function
                        IF NOT BSC_UPDATE_BASE.Calculate_Base_Table_AT(h_base_table, h_input_table, FALSE, h_aw_flag) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    ELSE
                        -- New strategy for better performance.
                        IF NOT BSC_UPDATE_BASE_V2.Calculate_Base_Table_AT(h_base_table, h_input_table, FALSE, h_aw_flag) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    END IF;

                    -- Update the stage of the input table to BASE UPDATED
                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Update_Stage_Input_Table(h_input_table, LC_BASE_UPDATED_STAGE) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- The base table was calculated successfully. This is the last stage.
                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Flag_Last_Stage_Input_Table(h_input_table) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- Add the base table of the input table to the array h_base_tables. This array has the
                    -- base tables that are going to be used to calculate all the summary tables in this process.

                    h_num_base_tables := h_num_base_tables + 1;
                    h_base_tables(h_num_base_tables) := h_base_table;

                    -- AW_INTEGRATION: If the base table if for an AW kpi we add this table to the array
                    -- h_base_tables_aw
                    IF h_aw_flag THEN
                        h_num_base_tables_aw := h_num_base_tables_aw + 1;
                        h_base_tables_aw(h_num_base_tables_aw) := h_base_table;
                    END IF;

                    -- Add the base table of the input table to the array h_base_tables_to_color. This array has the
                    -- base tables that are going to be used to identify which indicators need to be
                    -- colored.
                    h_num_base_tables_to_color := h_num_base_tables_to_color + 1;
                    h_base_tables_to_color(h_num_base_tables_to_color) := h_base_table;

                    h_message := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATED_BASE_TABLE');
                    h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_base_table);
                    BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                    --LOCKING: we do not need to call this here. base tables are not used by any kpi
                    -- Update Time Stamp of the indicators using this table directly
                    --BSC_UPDATE_UTIL.Update_Kpi_Table_Time_Stamp(h_base_table);

                ELSE
                    -- Input table has invalid codes
                    h_message := BSC_UPDATE_UTIL.Get_Message('BSC_INVALID_CODES_ITABLE');
                    h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                    BSC_UPDATE_LOG.Write_Line_Log(h_message,
						  BSC_UPDATE_LOG.OUTPUT);

                    -- Update the status of input table to ERROR
                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Update_Status_Input_Table(h_input_table, LC_ERROR_STATUS, LC_INVALID_CODES_ERR) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;

            ELSE
                -- Input table doesn't have any record.

                -- Fix bug#4545799: If loader is running 'By Objective' we need to refresh
                -- the summaries of the objectives even that the input table is empty
                IF g_kpi_mode THEN
                    -- loader running 'by objective'

                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Update_Stage_Input_Table(h_input_table, LC_BASE_UPDATED_STAGE) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- Add the base table of the input table to the array h_base_tables. This array has the
                    -- base tables that are going to be used to calculate all the summary tables in this process.
                    h_num_base_tables := h_num_base_tables + 1;
                    h_base_tables(h_num_base_tables) := h_base_table;

                    -- AW_INTEGRATION: If the base table if for an AW kpi we add this table to the array
                    -- h_base_tables_aw
                    IF h_aw_flag THEN
                        h_num_base_tables_aw := h_num_base_tables_aw + 1;
                        h_base_tables_aw(h_num_base_tables_aw) := h_base_table;
                    END IF;

                    -- Add the base table of the input table to the array h_base_tables_to_color. This array has the
                    -- base tables that are going to be used to identify which indicators need to be
                    -- colored.
                    h_num_base_tables_to_color := h_num_base_tables_to_color + 1;
                    h_base_tables_to_color(h_num_base_tables_to_color) := h_base_table;

                    -- Fix bug#4630260: Even that this input table is going to be processed
                    -- QA want that this input table appears in the  log file as empty and complete
                    -- with warning.
                    -- Update the status of the input table to NO_DATA
                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Update_Status_Input_Table(h_input_table, LC_NO_DATA_STATUS, NULL) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    h_message := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATED_BASE_TABLE');
                    h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_base_table);
                    BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                ELSE
                    -- The input table cannot be processed because is an empty table
                    h_message := BSC_UPDATE_UTIL.Get_Message('BSC_MISSING_DATA_ITABLE');
                    h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_input_table);
                    BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                    -- Update the status of the input table to NO_DATA
                    --LOCKING: there is no commit inside this function so we do not need AT
                    IF NOT Update_Status_Input_Table(h_input_table, LC_NO_DATA_STATUS, NULL) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;
            END IF;

            --LOCKING: Commit to release locks
            COMMIT;
        END LOOP;

    ELSE
        -- The process starts from system tables. This means that the base tables of the
        -- input tables given in the array already are updated and the process starts

        -- calculating the system tables affected by those input tables.
        -- This mode is uused by incremental update before launch the real update process
        -- with the selected input tables.

        FOR h_i IN 1 .. x_num_input_tables LOOP
            -- Add the base table of the input table to the array h_base_tables. This array has the
            -- base tables that are going to be used to calculate all the summary tables in this process.

            IF NOT Get_Base_Table_Of_Input_Table(x_input_tables(h_i), h_base_table) THEN
                RAISE e_unexpected_error;
            END IF;

            --LOCKING: lock the input table and the base table
            IF NOT BSC_UPDATE_LOCK.Lock_Update_Base_Table(x_input_tables(h_i), h_base_table) THEN
                RAISE e_could_not_get_lock;
            END IF;

            --LOCKING: review no commit between this point and the commit to release the locks

            -- BSC-MV Note: In this architecture we calculate higher periodicities in the base table.
            -- For that reason if some non-structural change like change form SUM to AVG
            -- happens, we need to recalculate the higher periodicities and projection.
            -- Bug#3768015: We need to do it also in summary tables architecture. The projections
            -- are calculated in the base tables and the user could have activated projection
            -- so it needs to be calculatated.

            -- Update the base table
            BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_UPDATING_BASE_TABLE')||
                                          ' '||h_base_table, BSC_UPDATE_LOG.OUTPUT);

            -- AW_INTEGRATION: Know if the base table belongs to an AW Kpi
            IF BSC_APPS.bsc_mv THEN
                h_aw_flag := BSC_UPDATE_UTIL.Is_Table_For_AW_Kpi(h_base_table);
            ELSE
                h_aw_flag := FALSE;
            END IF;

            -- ENH_B_TABLES_PERF: If the base table has a projection table then this is a new strategy.
            h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_base_table);
            IF h_proj_tbl_name IS NULL THEN
                -- AW_INTEGRATION: pass h_aw_flag
                -- LOCKING: call the autonomous transaction function
                IF NOT BSC_UPDATE_BASE.Calculate_Base_Table_AT(h_base_table, x_input_tables(h_i), TRUE, h_aw_flag) THEN
                    RAISE e_unexpected_error;
                END IF;
            ELSE
                -- New strategy for better performance.
                IF NOT BSC_UPDATE_BASE_V2.Calculate_Base_Table_AT(h_base_table, x_input_tables(h_i), TRUE, h_aw_flag) THEN
                    RAISE e_unexpected_error;
                END IF;
            END IF;

            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATED_BASE_TABLE');
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_base_table);
            BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

            h_num_base_tables := h_num_base_tables + 1;
            h_base_tables(h_num_base_tables) := h_base_table;

            -- AW_INTEGRATION: If the base table if for an AW kpi we add this table to the array
            -- h_base_tables_aw
            IF h_aw_flag THEN
                h_num_base_tables_aw := h_num_base_tables_aw + 1;
                h_base_tables_aw(h_num_base_tables_aw) := h_base_table;
            END IF;

            -- Add the base table of the input table to the array h_base_tables_to_color. This array has the
            -- base tables that are going to be used to identify which indicators need to be
            -- colored.
            h_num_base_tables_to_color := h_num_base_tables_to_color + 1;
            h_base_tables_to_color(h_num_base_tables_to_color) := h_base_table;

            --LOCKING: commit to release the lock
            COMMIT;
        END LOOP;
    END IF;

    -- So far, we have in the array h_base_tables the base tables to take to calculate the system tables

    -- Initialize the array h_system_tables with the system tables that are affected by the base tables
    -- in the array h_base_tables

    IF NOT Insert_Affected_Tables(h_base_tables, h_num_base_tables, h_system_tables, h_num_system_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Fix bug#4681065: write warning message with indicators that Laoder plan to calculate but
    -- are in prototype and cannot be calculated.
    -- Note that this procedure sets the global variable g_warning to true if there are
    -- indicators in prototype
    Write_Warning_Kpis_In_Prot(h_system_tables, h_num_system_tables);

    -- AW_INTEGRATION: Initialize the array h_system_tables_aw with the system tables that are affected by
    -- the base tables for AW Kpis. By design we know that AW indicators does not share base tables
    -- with kpis implemented with MVs. By design AW is never implemented along Summary tables architecture
    IF BSC_APPS.bsc_mv THEN
        IF NOT Insert_Affected_Tables(h_base_tables_aw, h_num_base_tables_aw, h_system_tables_aw, h_num_system_tables_aw) THEN
           RAISE e_unexpected_error;
        END IF;
    END IF;

    -- Calculate the system tables
    BSC_UPDATE_SUM.g_refreshed_mvs.delete;
    BSC_UPDATE_SUM.g_num_refreshed_mvs := 0;

    -- Until all system tables have been calculated
    WHILE h_num_calculated_sys_tables <> h_num_system_tables LOOP
        FOR h_i IN 1 .. h_num_system_tables LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_system_tables(h_i),
                                                                 h_calculated_sys_tables,
                                                                 h_num_calculated_sys_tables) THEN
                -- The table has not been calculated yet

                -- Check if the table can be calculated now
                h_b := Can_Calculate_Sys_Table(h_system_tables(h_i),
                                               h_calculated_sys_tables,
                                               h_num_calculated_sys_tables,
                                               h_system_tables,
                                               h_num_system_tables);

                IF h_b IS NULL THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_b THEN
                    -- Table can be calculated because all the origin tables for that table
                    -- have already been calculated

                    -- BSC-BIS-DIMENSIONS Note:
                    -- From this implementation allow to run loader when there are indicators in prototype.
                    -- If the table is used direclty by a Kpi and the Kpi is in production then we calculate
                    -- the table.

                    -- If the table is not used directly by a Kpi then this fuctions returns 0;
                    h_num_kpis := BSC_UPDATE_UTIL.Get_Kpis_Using_Table(h_system_tables(h_i), h_kpis);

                    IF h_num_kpis = 0 THEN
                        -- This table is not used directly by any Kpi (T table) so we need to
                        -- to calculate the table.
                        h_calc_summary_table := TRUE;
                    ELSE
                        -- If at least one indicator using the table is in production then we calculate the table.
                        -- Also, if we are running in KPI_MODE we need to validate that the Kpi belong
                        -- to the list in g_indicators
                        h_calc_summary_table := FALSE;
                        FOR h_i IN 1..h_num_kpis LOOP
                            IF h_kpis(h_i).prototype_flag IN (0,6,7) THEN
                                IF g_kpi_mode THEN
                                    IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_kpis(h_i).indicator,
                                                                                   g_indicators,
                                                                                   g_num_indicators) THEN
                                        h_calc_summary_table := TRUE;
                                        EXIT;
                                    END IF;
                                ELSE
                                    h_calc_summary_table := TRUE;
                                    EXIT;
                                END IF;
                            END IF;
                        END LOOP;
                    END IF;

                    IF h_calc_summary_table THEN
                        -- Calculate the summary (system) table
                        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_SUMTABLE_CALC_PROCESS')||
                                                      ' '||h_system_tables(h_i),
			  			      BSC_UPDATE_LOG.OUTPUT);


                        -- BSC-MV Note: In new architecture, call  Calculate_Sum_Table_MV()
                        IF BSC_APPS.bsc_mv THEN
                            -- AW_INTEGRATION: Know if the table is used in a AW indicator
                            IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_system_tables(h_i),
                                                                             h_system_tables_aw,
                                                                             h_num_system_tables_aw) THEN
                                -- This table is for an AW indicator
                                --LOCKING: lock the tables needed to refresh this table
                                IF NOT BSC_UPDATE_LOCK.Lock_Refresh_AW_Table(h_system_tables(h_i)) THEN
                                    RAISE e_could_not_get_lock;
                                END IF;

                                --LOCKING: call the autonomous transaction function
                                IF NOT BSC_UPDATE_SUM.Calculate_Sum_Table_AW_AT(h_system_tables(h_i)) THEN
                                    RAISE e_unexpected_error;
                                END IF;

                                --LOCKING: commit to release locks
                                COMMIT;
                            ELSE
                                -- This table is for a MV indicator
                                --LOCKING: lock the tables needed to refresh this table
                                IF NOT BSC_UPDATE_LOCK.Lock_Refresh_MV(h_system_tables(h_i)) THEN
                                    RAISE e_could_not_get_lock;
                                END IF;

                                -- LOCKING: call the autonomous transaction function
                                IF NOT BSC_UPDATE_SUM.Calculate_Sum_Table_MV_AT(h_system_tables(h_i),
                                                                             h_calculated_sys_tables,
                                                                             h_num_calculated_sys_tables,
                                                                             h_system_tables,
                                                                             h_num_system_tables) THEN
                                    RAISE e_unexpected_error;
                                END IF;

                                --LOCKING: commit to release the locks
                                COMMIT;
                            END IF;
                        ELSE
                            --LOCKING: lock the tables needed to refresh this table
                            IF NOT BSC_UPDATE_LOCK.Lock_Refresh_Sum_Table(h_system_tables(h_i)) THEN
                                RAISE e_could_not_get_lock;
                            END IF;

                            --LOCKING: call the autonomous transaction function
                            IF NOT BSC_UPDATE_SUM.Calculate_Sum_Table_AT(h_system_tables(h_i)) THEN
                                RAISE e_unexpected_error;
                            END IF;

                            --LOCKING: commit to refresh the locks
                            COMMIT;
                        END IF;
                        COMMIT;

                        h_message := BSC_UPDATE_UTIL.Get_Message('BSC_SUMTABLE_CALCULATED');
                        h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'TABLE_NAME', h_system_tables(h_i));
                        BSC_UPDATE_LOG.Write_Line_Log(h_message,
	   					      BSC_UPDATE_LOG.OUTPUT);

                        --LOCKING: remove this call
                        -- Update Time Stamp of the indicators using this table directly
                        --LOCKING: Lock the indicator period fo the indicators using this table
                        IF NOT BSC_UPDATE_LOCK.Lock_Period_Indicators(h_system_tables(h_i)) THEN
                            RAISE e_could_not_get_lock;
                        END IF;

                        BSC_UPDATE_UTIL.Update_Kpi_Table_Time_Stamp(h_system_tables(h_i));

                        --LOCKING: commit to release lock
                        COMMIT;
                    END IF;

                    -- Add table to array of calculated tables
                    h_num_calculated_sys_tables := h_num_calculated_sys_tables + 1;
                    h_calculated_sys_tables(h_num_calculated_sys_tables) := h_system_tables(h_i);

                END IF;
            END IF;
        END LOOP;
    END LOOP;

    -- AW_INTEGRATION: Refresh AW indicators' cubes. I will use Get_Indicators_To_Color()
    -- to get the lost of indicators affected by the base tables of AW indicators
    IF BSC_APPS.bsc_mv THEN

        IF NOT Get_Indicators_To_Color(h_base_tables_aw,
                                       h_num_base_tables_aw,
                                       h_indicators_aw,
                                       h_num_indicators_aw) THEN
            RAISE e_unexpected_error;
        END IF;

        FOR h_i IN 1 .. h_num_indicators_aw LOOP
            -- BSC-BIS-DIMENSIONS: Starting from this implementation we can run Loader even if there
            -- are indicators in prototype. We need to check and only color indicators in production mode.
            -- Additionally if we are running in KPI_MODE we need to color only indicators
            -- that belong to the array g_indicators.
            h_calc_aw_kpi := FALSE;
            IF BSC_UPDATE_UTIL.Is_Kpi_In_Production(h_indicators_aw(h_i)) THEN
                IF g_kpi_mode THEN
                    IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_indicators_aw(h_i),
                                                                   g_indicators,
                                                                   g_num_indicators) THEN
                        h_calc_aw_kpi := TRUE;
                    END IF;
                ELSE
                    h_calc_aw_kpi := TRUE;
                END IF;
            END IF;

            IF h_calc_aw_kpi THEN
                BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_IVIEWER', 'REFRESH')||
                                              BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                              ' '||h_indicators_aw(h_i),
			    		      BSC_UPDATE_LOG.OUTPUT);

                --LOCKING: Lock the objects required to refresh the AW indicator cubes
                IF NOT BSC_UPDATE_LOCK.Lock_Refresh_AW_Indicator(h_indicators_aw(h_i)) THEN
                    RAISE e_could_not_get_lock;
                END IF;

                -- AW_INTEGRATION: Call the aw api to refresh the indicator cubes
                --LOCKING: call the autonomous transaction procedure
                BSC_UPDATE_SUM.Refresh_AW_Kpi_AT(h_indicators_aw(h_i));

                --LOCKING: commit to release the locks
                COMMIT;
            END IF;
        END LOOP;
    END IF;

    --LOCKING: Comment this code. I am going to calculate the indicator period
    -- indicator by indicator just before calculate the color
    --IF NOT Update_Indicators_Periods() THEN
    --    RAISE e_unexpected_error;
    --END IF;
    --COMMIT;

    -- Update the stage of the input tables whose status in RUNNING to SYSTEM UPDATED
    IF x_start_from = 0 THEN
        IF NOT Update_Stage_Input_Tables(LC_RUNNING_STATUS, LC_SYSTEM_UPDATED_STAGE, FALSE) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;
    END IF;

    -- Coloring process
    -- We have in the array h_base_tables_to_color the base tables to take to identify the indicators to color
    -- Initialize the array h_color_indicators with the system indicators that are affected by the base tables
    -- in the array h_base_tables_to_color
    IF NOT Get_Indicators_To_Color(h_base_tables_to_color,
                                   h_num_base_tables_to_color,
                                   h_color_indicators,
                                   h_num_color_indicators) THEN
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

        FOR h_i IN 1 .. h_num_color_indicators LOOP
            -- BSC-BIS-DIMENSIONS: Starting from this implementation we can run Loader even if there
            -- are indicators in prototype. We need to check and only color indicators in production mode.
            -- Additionally if we are runnign in KPI_MODE we need to color only indicators
            -- that belong to the array g_indicators.
            h_calc_color := FALSE;
            IF BSC_UPDATE_UTIL.Is_Kpi_In_Production(h_color_indicators(h_i)) THEN
                IF g_kpi_mode THEN
                    IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_color_indicators(h_i),
                                                                   g_indicators,
                                                                   g_num_indicators) THEN
                        h_calc_color := TRUE;
                    END IF;
                ELSE
                    h_calc_color := TRUE;
                END IF;
            END IF;

            IF h_calc_color THEN
                BSC_UPDATE_LOG.Write_Line_log(BSC_UPDATE_UTIL.Get_Message('BSC_COLOR_CALC')||
                                              ' '||h_color_indicators(h_i),
			    		      BSC_UPDATE_LOG.OUTPUT);

                --LOCKING: Calculate indicator period here
                IF NOT BSC_UPDATE_LOCK.Lock_Period_Indicator(h_color_indicators(h_i)) THEN
                    RAISE e_could_not_get_lock;
                END IF;

                IF NOT Update_Indicator_Period(h_color_indicators(h_i)) THEN
                    RAISE e_unexpected_error;
                END IF;

                -- Update Prototype Flag for underlying KPI Measures for the Objective to 7.
                /* Not required since the prototype flag of KPI is not checked for inside Color_Indicator
                IF NOT Update_Kpis_Prototype_Flag(h_color_indicators(h_i)) THEN
		  RAISE e_unexpected_error;
                END IF;*/

                --LOCKING: commit to release lock
                COMMIT;

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

                -- Update date of indicator
                UPDATE bsc_kpi_defaults_b SET last_update_date = SYSDATE
                WHERE indicator = h_color_indicators(h_i);

                -- Update kpi time stamp
                BSC_UPDATE_UTIL.Update_Kpi_Time_Stamp(h_color_indicators(h_i));

                -- Update Tabs time stamp
                BSC_UPDATE_UTIL.Update_Kpi_Tab_Time_Stamp(h_color_indicators(h_i));

                --LOCKING: commit to release locks
                COMMIT;

                -- BSC-BIS-DIMENSIONS: Since we can run on indicators with prototype flag 6 or 7
                -- we need to update the indicator to prototype flag 0
                --LOCKING: lock the prototype flag of the indicator
                IF NOT BSC_UPDATE_LOCK.Lock_Prototype_Indicator(h_color_indicators(h_i)) THEN
                    RAISE e_could_not_get_lock;
                END IF;

                UPDATE bsc_kpis_b
                SET prototype_flag = 0, last_updated_by = BSC_APPS.fnd_global_user_id, last_update_date = SYSDATE
                WHERE indicator = h_color_indicators(h_i) AND prototype_flag IN (6, 7);

                -- Color By KPI: Mark KPIs for color done
                UPDATE bsc_kpi_analysis_measures_b
		  SET prototype_flag = 0
                  WHERE indicator = h_color_indicators(h_i) AND prototype_flag = 7;

                --LOCKING: commit to release the lock
                COMMIT;

            END IF;

        END LOOP;
    END IF;

    -- Update the date of update process
    --LOCKING: Lock date of update process
    IF NOT BSC_UPDATE_LOCK.Lock_Update_Date THEN
        RAISE e_could_not_get_lock;
    END IF;

    IF NOT BSC_UPDATE_UTIL.Write_Init_Variable_Value('UPDATE_DATE', TO_CHAR(SYSDATE, 'DD/MM/YYYY')) THEN
        RAISE e_unexpected_error;
    END IF;

    --LOCKING: commit to release lock
    COMMIT;

    IF x_start_from = 0 THEN
        IF NOT Update_Stage_Input_Tables(LC_RUNNING_STATUS, LC_COMPLETED_STAGE, FALSE) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;

        IF NOT Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_COMPLETED_STATUS, NULL) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;
    END IF;

    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_DATATABLE_UPDATED'), BSC_UPDATE_LOG.OUTPUT);

    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DATATABLE_UPDATE_FAILED'),
                         x_source => 'BSC_UPDATE.Process_Input_Tables');
        IF x_start_from = 0 THEN
            h_b := Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_ERROR_STATUS, LC_PROGRAM_ERR);
            COMMIT;
        END IF;

        RETURN FALSE;

    --LOCKING
    WHEN e_could_not_get_lock THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => 'Loader could not get the required locks to continue.',
                         x_source => 'BSC_UPDATE.Process_Input_Tables');
        IF x_start_from = 0 THEN
            h_b := Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_ERROR_STATUS, LC_PROGRAM_ERR);
            COMMIT;
        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_UPDATE.Process_Input_Tables');

        IF x_start_from = 0 THEN
            h_b := Update_Status_All_Input_Tables(LC_RUNNING_STATUS, LC_ERROR_STATUS, LC_PROGRAM_ERR);
            COMMIT;
        END IF;

        RETURN FALSE;
END Process_Input_Tables;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Process_Input_Tables_AT
+============================================================================*/
FUNCTION Process_Input_Tables_AT(
	x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_input_tables IN NUMBER,
	x_start_from IN NUMBER
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Process_Input_Tables(x_input_tables, x_num_input_tables, x_start_from);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Process_Input_Tables_AT;


/*===========================================================================+
| FUNCTION Refresh_System_MVs
+============================================================================*/
FUNCTION Refresh_System_MVs(
    p_base_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    p_num_base_tables IN NUMBER
) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;

    h_calculated_sys_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_calculated_sys_tables NUMBER;

    h_refreshed_mvs BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_refreshed_mvs NUMBER;

    h_i NUMBER;
    h_b BOOLEAN;

    mv_name VARCHAR2(50);

    e_error_refresh EXCEPTION;
    e_error_refresh_zero EXCEPTION;
    h_error_refresh VARCHAR2(2000);

    h_kpis BSC_UPDATE_UTIL.t_array_kpis;
    h_num_kpis NUMBER;
    h_calc_summary_table BOOLEAN;

BEGIN
    h_num_system_tables := 0;
    h_num_calculated_sys_tables := 0;
    h_num_refreshed_mvs := 0;


    -- Initialize the array h_system_tables with the system tables that are affected by the base tables
    -- in the array p_base_tables

    IF NOT Insert_Affected_Tables(p_base_tables, p_num_base_tables, h_system_tables, h_num_system_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Until all MVs have been refreshed
    WHILE h_num_calculated_sys_tables <> h_num_system_tables LOOP
        FOR h_i IN 1 .. h_num_system_tables LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_system_tables(h_i),
                                                                 h_calculated_sys_tables,
                                                                 h_num_calculated_sys_tables) THEN
                -- The table has not been calculated yet

                -- Check if the table can be calculated
                h_b := Can_Calculate_Sys_Table(h_system_tables(h_i),
                                               h_calculated_sys_tables,
                                               h_num_calculated_sys_tables,
                                               h_system_tables,
                                               h_num_system_tables);

                IF h_b IS NULL THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_b THEN
                    -- The table can be calculated because all the origin tables for that table
                    -- have already been calculated

                    -- Fix bug#5023588 Only calculate the MV if it is used by an indicator in production mode
                    -- If the table is not used directly by a Kpi then this fuctions returns 0;
                    h_num_kpis := BSC_UPDATE_UTIL.Get_Kpis_Using_Table(h_system_tables(h_i), h_kpis);
                    IF h_num_kpis > 0 THEN
                        -- If at least one indicator using the table is in production then we calculate the table.
                        h_calc_summary_table := FALSE;
                        FOR i IN 1..h_num_kpis LOOP
                            IF h_kpis(i).prototype_flag IN (0,6,7) THEN
                                h_calc_summary_table := TRUE;
                                EXIT;
                            END IF;
                        END LOOP;
                        IF h_calc_summary_table THEN
                            -- Refresh the MV.
                            -- Make sure to refresh the MV only one time. Remember that same MV
                            -- has data for different periodicities.
                            -- Note: The api to refresh the MV does not fail if the MV does not exists
                            -- or if the MV is actually a normal view
                            mv_name := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(h_system_tables(h_i));
                            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(mv_name,
                                                                                 h_refreshed_mvs,
                                                                                 h_num_refreshed_mvs) THEN

                                --LOCKING: Lock the objects required for the mv refresh
                                --LOCKING: review that no commits between this point and the commit to
                                -- to release the locks
                                IF NOT BSC_UPDATE_LOCK.Lock_Refresh_MV(h_system_tables(h_i)) THEN
                                    RAISE e_could_not_get_lock;
                                END IF;

                                --LOCKING: call the autonomous transaction function
                                IF NOT BSC_BIA_WRAPPER.Refresh_Summary_MV_AT(mv_name, h_error_refresh) THEN
                                    RAISE e_error_refresh;
                                END IF;

                                -- Also refresh the MV created for zero code (if it exists)
                                --LOCKING: call the autonomous transaction function
                                IF NOT BSC_UPDATE_SUM.Refresh_Zero_MVs_AT(h_system_tables(h_i),
                                                                       mv_name, h_error_refresh) THEN
                                    RAISE e_error_refresh_zero;
                                END IF;

                                --LOCKING: commit to release locks
                                COMMIT;

                                -- Add mv to array of refreshed mvs
                                h_num_refreshed_mvs := h_num_refreshed_mvs + 1;
                                h_refreshed_mvs(h_num_refreshed_mvs) := mv_name;
                            END IF;
                        END IF;
                    END IF;

                    -- Add table to array of calculated tables
                    h_num_calculated_sys_tables := h_num_calculated_sys_tables + 1;
                    h_calculated_sys_tables(h_num_calculated_sys_tables) := h_system_tables(h_i);

                END IF;
            END IF;
        END LOOP;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    --LOCKING
    WHEN e_could_not_get_lock THEN
        BSC_MESSAGE.Add(x_message => 'Loader could not get the required locks to continue.',
                        x_source => 'BSC_UPDATE.Refresh_System_MVs');
        RETURN FALSE;

    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DATATABLE_UPDATE_FAILED'),
                        x_source => 'BSC_UPDATE.Refresh_System_MVs');
        RETURN FALSE;

    WHEN e_error_refresh THEN
        BSC_MESSAGE.Add(x_message => 'BSC_BIA_WRAPPER.Refresh_Summary_MV '||mv_name||' '||h_error_refresh,
                        x_source => 'BSC_UPDATE.Refresh_System_MVs');
        RETURN FALSE;

    WHEN e_error_refresh_zero THEN
        BSC_MESSAGE.Add(x_message => 'BSC_UPDATE_SUM.Refresh_Zero_MVs '||mv_name||' '||h_error_refresh,
                        x_source => 'BSC_UPDATE.Refresh_System_MVs');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Refresh_System_MVs');
        RETURN FALSE;
END Refresh_System_MVs;


--LOCKING: new fucntion: In migration we cannot use lock inside this function
/*===========================================================================+
| FUNCTION Refresh_System_MVs_Mig
+============================================================================*/
FUNCTION Refresh_System_MVs_Mig(
    p_base_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    p_num_base_tables IN NUMBER
) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;

    h_calculated_sys_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_calculated_sys_tables NUMBER;

    h_refreshed_mvs BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_refreshed_mvs NUMBER;

    h_i NUMBER;
    h_b BOOLEAN;

    mv_name VARCHAR2(50);

    e_error_refresh EXCEPTION;
    e_error_refresh_zero EXCEPTION;
    h_error_refresh VARCHAR2(2000);

BEGIN
    h_num_system_tables := 0;
    h_num_calculated_sys_tables := 0;
    h_num_refreshed_mvs := 0;


    -- Initialize the array h_system_tables with the system tables that are affected by the base tables
    -- in the array p_base_tables

    IF NOT Insert_Affected_Tables(p_base_tables, p_num_base_tables, h_system_tables, h_num_system_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Until all MVs have been refreshed
    WHILE h_num_calculated_sys_tables <> h_num_system_tables LOOP
        FOR h_i IN 1 .. h_num_system_tables LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_system_tables(h_i),
                                                                 h_calculated_sys_tables,
                                                                 h_num_calculated_sys_tables) THEN
                -- The table has not been calculated yet

                -- Check if the table can be calculated
                h_b := Can_Calculate_Sys_Table(h_system_tables(h_i),
                                               h_calculated_sys_tables,
                                               h_num_calculated_sys_tables,
                                               h_system_tables,
                                               h_num_system_tables);

                IF h_b IS NULL THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_b THEN
                    -- The table can be calculated because all the origin tables for that table
                    -- have already been calculated

                    -- Refresh the MV.
                    -- Make sure to refresh the MV only one time. Remember that same MV
                    -- has data for different periodicities.
                    -- Note: The api to refresh the MV does not fail if the MV does not exists
                    -- or if the MV is actually a normal view
                    mv_name := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(h_system_tables(h_i));
                    IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(mv_name,
                                                                         h_refreshed_mvs,
                                                                         h_num_refreshed_mvs) THEN

                        IF NOT BSC_BIA_WRAPPER.Refresh_Summary_MV(mv_name, h_error_refresh) THEN
                            RAISE e_error_refresh;
                        END IF;

                        -- Also refresh the MV created for zero code (if it exists)
                        IF NOT BSC_UPDATE_SUM.Refresh_Zero_MVs(h_system_tables(h_i),
                                                               mv_name, h_error_refresh) THEN
                            RAISE e_error_refresh_zero;
                        END IF;

                        commit;

                        -- Add mv to array of refreshed mvs
                        h_num_refreshed_mvs := h_num_refreshed_mvs + 1;
                        h_refreshed_mvs(h_num_refreshed_mvs) := mv_name;
                    END IF;

                    -- Add table to array of calculated tables
                    h_num_calculated_sys_tables := h_num_calculated_sys_tables + 1;
                    h_calculated_sys_tables(h_num_calculated_sys_tables) := h_system_tables(h_i);

                END IF;
            END IF;
        END LOOP;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DATATABLE_UPDATE_FAILED'),
                        x_source => 'BSC_UPDATE.Refresh_System_MVs_Mig');
        RETURN FALSE;

    WHEN e_error_refresh THEN
        BSC_MESSAGE.Add(x_message => 'BSC_BIA_WRAPPER.Refresh_Summary_MV '||mv_name||' '||h_error_refresh,
                        x_source => 'BSC_UPDATE.Refresh_System_MVs_Mig');
        RETURN FALSE;

    WHEN e_error_refresh_zero THEN
        BSC_MESSAGE.Add(x_message => 'BSC_UPDATE_SUM.Refresh_Zero_MVs '||mv_name||' '||h_error_refresh,
                        x_source => 'BSC_UPDATE.Refresh_System_MVs_Mig');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Refresh_System_MVs_Mig');
        RETURN FALSE;
END Refresh_System_MVs_Mig;


/*===========================================================================+
| PROCEDURE Run_Concurrent_Loader
+============================================================================*/
PROCEDURE Run_Concurrent_Loader (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_process_id IN VARCHAR2,
	x_process_name IN VARCHAR2,
	x_parameter_1 IN VARCHAR2
	) IS

    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    e_warning EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);
    h_sessionid NUMBER;

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

BEGIN
    h_sessionid := USERENV('SESSIONID');
    -- Bug#4681065
    g_warning := FALSE;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = h_sessionid;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    Execute_Update_Process(TO_NUMBER(x_process_id), x_process_name, x_parameter_1);

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = h_sessionid;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    SELECT count(*)
    INTO h_count
    FROM bsc_db_loader_control
    WHERE process_id = g_process_id AND status IN (LC_ERROR_STATUS, LC_NO_DATA_STATUS);

    IF h_count > 0 THEN
        RAISE e_warning;
    END IF;

    -- Bug#4681065
    IF g_warning THEN
        RAISE e_warning;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_warning THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := '';
        RETCODE := 1; -- Request completed with warning

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Run_Concurrent_Loader;


/*===========================================================================+
| PROCEDURE Run_Concurrent_Loader_Apps
+============================================================================*/
PROCEDURE Run_Concurrent_Loader_Apps (
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
x_process_id IN VARCHAR2
)IS
Begin
  Run_Concurrent_Loader_Apps(ERRBUF,RETCODE,x_process_id,'N');
EXCEPTION when others then
  BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors
End;

PROCEDURE Run_Concurrent_Loader_Apps (
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
x_process_id IN VARCHAR2,
x_load_dim_affected_indicators varchar2
) IS

    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    e_warning EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);
    h_sessionid NUMBER;
    --
    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;
    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;
    h_indicator_string varchar2(32000);
    --

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

BEGIN
    h_sessionid := USERENV('SESSIONID');
    -- Bug#4681065
    g_warning := FALSE;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = h_sessionid;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    if x_load_dim_affected_indicators is not null and x_load_dim_affected_indicators='Y' then
      g_process_id := Get_Process_Id(x_process_id, PC_LOADER_PROCESS);
      g_process_name := PC_LOADER_PROCESS;

      IF NOT Get_Process_Input_Tables(h_input_tables, h_num_input_tables, LC_PENDING_STATUS) THEN
        RAISE e_update_error;
      END IF;

      if h_num_input_tables>0 then
        h_num_indicators:=0;
        if get_kpi_for_input_tables(h_input_tables,h_num_input_tables,h_indicators,h_num_indicators)=false then
          raise e_update_error;
        end if;
        if h_num_indicators>0 then
          h_indicator_string:=null;
          for i in 1..h_num_indicators loop
            h_indicator_string:=h_indicator_string||h_indicators(i)||',';
          end loop;
          h_indicator_string:=substr(h_indicator_string,1,length(h_indicator_string)-1);
          --load the dimensions first
          Load_Indicators_Dims (ERRBUF,RETCODE,h_indicator_string,'N');
          if RETCODE='2' or RETCODE=2 then
            raise e_update_error;
          end if;
          --LOCKING: lock again since Load_Indicators_Dims removed the lock
          BSC_LOCKS_PUB.Get_System_Lock (
            p_program_id => -101,
            p_user_id => BSC_APPS.apps_user_id,
            p_icx_session_id => null,
            x_return_status => h_return_status,
            x_msg_count => h_msg_count,
            x_msg_data => h_msg_data
          );
          IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE e_system_lock;
          END IF;
        end if;
      end if;
    end if;

    -- clean bsc_message_logs
    BSC_MESSAGE.Clean;

    -- Run loader
    Execute_Update_Process(TO_NUMBER(x_process_id), PC_LOADER_PROCESS, NULL);

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    /*
    h_sql := 'SELECT count(*)'||
             ' FROM bsc_message_logs'||
             ' WHERE type = :1'||
             ' AND UPPER(source) = :2 AND last_update_login = :3';
    OPEN h_cursor FOR h_sql USING 0, h_source, h_sessionid;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;
    */
    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = h_sessionid;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    /*
    h_sql := 'SELECT count(*)'||
             ' FROM bsc_db_loader_control'||
             ' WHERE process_id = :1 AND status IN (:2, :3)';
    OPEN h_cursor FOR h_sql USING g_process_id, LC_ERROR_STATUS, LC_NO_DATA_STATUS;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;
    */
    SELECT count(*)
    INTO h_count
    FROM bsc_db_loader_control
    WHERE process_id = g_process_id AND status IN (LC_ERROR_STATUS, LC_NO_DATA_STATUS);

    IF h_count > 0 THEN
        RAISE e_warning;
    END IF;

    -- Bug#4681065
    IF g_warning THEN
        RAISE e_warning;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_warning THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := '';
        RETCODE := 1; -- Request completed with warning

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Run_Concurrent_Loader_Apps;


/*===========================================================================+
| PROCEDURE Run_Concurrent_Loader_Dim_Apps
+============================================================================*/
PROCEDURE Run_Concurrent_Loader_Dim_Apps (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_process_id IN VARCHAR2
	) IS

    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    e_warning EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);
    h_sessionid NUMBER;

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

BEGIN

    h_sessionid := USERENV('SESSIONID');
    -- Bug#4681065
    g_warning := FALSE;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = h_sessionid;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    -- Run loader
    Execute_Update_Process(TO_NUMBER(x_process_id), PC_LOAD_DIMENSIONS, NULL);

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    /*
    h_sql := 'SELECT count(*)'||
             ' FROM bsc_message_logs'||
             ' WHERE type = :1'||
             ' AND UPPER(source) = :2 AND last_update_login = :3';
    OPEN h_cursor FOR h_sql USING 0, h_source, h_sessionid;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;
    */
    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = h_sessionid;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    /*
    h_sql := 'SELECT count(*)'||
             ' FROM bsc_db_loader_control'||
             ' WHERE process_id = :1 AND status IN (:2, :3)';
    OPEN h_cursor FOR h_sql USING g_process_id, LC_ERROR_STATUS, LC_NO_DATA_STATUS;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;
    */
    SELECT count(*)
    INTO h_count
    FROM bsc_db_loader_control
    WHERE process_id = g_process_id AND status IN (LC_ERROR_STATUS, LC_NO_DATA_STATUS);

    IF h_count > 0 THEN
        RAISE e_warning;
    END IF;

    -- Bug#4681065
    IF g_warning THEN
        RAISE e_warning;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_warning THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := '';
        RETCODE := 1; -- Request completed with warning

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Run_Concurrent_Loader_Dim_Apps',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

END Run_Concurrent_Loader_Dim_Apps;

/*
This is the new procedure to change current year
This is same as calling Submit Request to Load Input Tables (VB) (Flag = Y)
This is for new OA UI. this api in contrast to Submit Request to Load Input Tables (VB) (Flag = Y)
will acquire lock. Submit Request to Load Input Tables (VB) (Flag = Y)  is launched from VB
where the lock is already there with VB
*/
PROCEDURE Run_change_current_year (
ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
x_process_id IN VARCHAR2,
x_calendars IN VARCHAR2
)IS
    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

Begin
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initializes g_session_id, g_user_id and g_schema_name
    IF NOT Init_Env_Values THEN
        RAISE e_update_error;
    END IF;

    IF x_calendars IS NULL THEN
        -- No calendars to be processed.
        RETURN;
    END IF;

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    -- Run loader
    Execute_Update_Process(TO_NUMBER(x_process_id), PC_YEAR_CHANGE_PROCESS, x_calendars);

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Run_change_current_year',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Run_change_current_year;


/*===========================================================================+
| PROCEDURE Load_Indicators_Data
+============================================================================*/
PROCEDURE Load_Indicators_Data (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_indicators IN VARCHAR2,
        x_load_affected_indicators varchar2
	) IS

    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    e_unexpected_error EXCEPTION;
    e_warning EXCEPTION;
    --Fix bug#3923207: import dbi plans was moved to execute_update_process
    --e_import_dbi_plans EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;

    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;

    h_process_id NUMBER;
    h_i NUMBER;

    h_where_indics VARCHAR2(32000);
    h_plan_snapshot VARCHAR2(100);
    h_error_msg VARCHAR2(2000);

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

    -- Bug#4681065
    h_prod_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_prod_indicators NUMBER;
    h_lst_prod_indicators VARCHAR2(32000);
    h_first_prot_indic BOOLEAN;
    h_indic_name VARCHAR2(2000);
    h_prototype_flag NUMBER;

    CURSOR c_indicator (p_kpi NUMBER) IS
        SELECT prototype_flag, name
        FROM bsc_kpis_vl
        WHERE indicator = p_kpi;

BEGIN
    h_num_indicators := 0;
    h_num_input_tables := 0;
    --Bug#4681065
    h_num_prod_indicators := 0;
    h_lst_prod_indicators := NULL;
    h_first_prot_indic := TRUE;

    -- Bug#4681065
    g_warning := FALSE;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    -- Initializes g_session_id, g_user_id and g_schema_name
    IF NOT Init_Env_Values THEN
        RAISE e_update_error;
    END IF;

    IF x_indicators IS NULL THEN
        -- No indicators to be processed
        RETURN;
    END IF;

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    -- Decompose the list in x_parameter_1 into the array h_indicators
    h_num_indicators := BSC_UPDATE_UTIL.Decompose_Numeric_List(x_indicators,
                                                               h_indicators,
                                                               ',');

    IF h_num_indicators = 0 THEN
        -- No indicators to be processed
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        RETURN;
    END IF;

    --Fix bug#3923207: import dbi plans was moved to execute_update_process
    --IF NOT BSC_UPDATE_DIM.Import_Dbi_Plans(h_error_msg) THEN
    --      RAISE e_import_dbi_plans;
    --END IF;

    -- Bug#4681065: we are going to process only indicators in production.
    -- Write warning message for indicators in prototype and complete with warning
    FOR h_i IN 1..h_num_indicators LOOP
        OPEN c_indicator(h_indicators(h_i));
        FETCH c_indicator INTO h_prototype_flag, h_indic_name;
        CLOSE c_indicator;

        IF h_prototype_flag IN (0,6,7) THEN
            h_num_prod_indicators := h_num_prod_indicators + 1;
            h_prod_indicators(h_num_prod_indicators) := h_indicators(h_i);
            IF h_lst_prod_indicators IS NOT NULL THEN
                h_lst_prod_indicators := h_lst_prod_indicators||',';
            END IF;
            h_lst_prod_indicators := h_lst_prod_indicators||h_indicators(h_i);
        ELSE
            IF h_first_prot_indic THEN
                BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_CANNOT_LOAD_OBJS_IN_PROT'),
                                              BSC_UPDATE_LOG.OUTPUT);
               h_first_prot_indic := FALSE;
               g_warning := TRUE;
            END IF;
            BSC_UPDATE_LOG.Write_Line_Log(h_indicators(h_i)||' '||h_indic_name, BSC_UPDATE_LOG.OUTPUT);
        END IF;
    END LOOP;

    -- Get input tables used for the indicators
    IF NOT Get_Input_Tables_Kpis(h_prod_indicators, h_num_prod_indicators, h_input_tables, h_num_input_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_num_input_tables = 0 THEN
        -- No input tables to load
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        IF g_warning THEN
            ERRBUF := '';
            RETCODE := 1; -- Request completed with warning
        END IF;
        RETURN;
    END IF;

    -- Create a new process in BSC_DB_PROCESS_CONTROL
    --LOCKING: get the sequence nextval here and then use it
    SELECT bsc_db_process_id_s.nextval
    INTO h_process_id
    FROM DUAL;

    INSERT INTO bsc_db_process_control (process_id, process_name,
        creation_date, created_by, last_update_date,last_updated_by,
        last_update_login, status)
    VALUES (h_process_id, PC_LOADER_PROCESS,
        SYSDATE, g_user_id, SYSDATE, g_user_id, g_session_id, PC_PENDING_STATUS);

    -- Insert input tables in BSC_DB_LOADER_CONTROL
    FOR h_i IN 1..h_num_input_tables LOOP
        INSERT INTO bsc_db_loader_control (process_id, input_table_name, status,
            error_code, stage, last_stage_flag)
        VALUES (h_process_id, h_input_tables(h_i), LC_PENDING_STATUS, NULL, LC_PENDING_STAGE, 0);
    END LOOP;
    COMMIT;

    -- Run loader
    IF x_load_affected_indicators IS NOT NULL AND x_load_affected_indicators = 'Y' THEN
        -- Load all the indicators affected by the input tables
        Execute_Update_Process(h_process_id, PC_LOADER_PROCESS, NULL);
    ELSE
        -- Only load summary levels of the specified indicators
        Execute_Update_Process(h_process_id, PC_LOADER_PROCESS, h_lst_prod_indicators);

    END IF;

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    SELECT count(*)
    INTO h_count
    FROM bsc_db_loader_control
    WHERE process_id = g_process_id AND status IN (LC_ERROR_STATUS, LC_NO_DATA_STATUS);

    IF h_count > 0 THEN
        RAISE e_warning;
    END IF;

    -- Bug#4681065
    IF g_warning THEN
        RAISE e_warning;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_warning THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := '';
        RETCODE := 1; -- Request completed with warning

    WHEN e_unexpected_error THEN
        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

    --Fix bug#3923207: import dbi plans was moved to execute_update_process
    --WHEN e_import_dbi_plans THEN

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Load_Indicators_Data',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Load_Indicators_Data;


/*===========================================================================+
| PROCEDURE Load_Indicators_Dims
+============================================================================*/
PROCEDURE Load_Indicators_Dims (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_indicators IN VARCHAR2,
        x_load_dim_affected_indicators varchar2
	) IS

    e_unexpected_error EXCEPTION;
    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    e_warning EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;

    h_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_input_tables NUMBER;

    l_input_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_input_tables NUMBER;

    h_process_id NUMBER;
    h_i NUMBER;

    h_dbi_dimensions BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_dbi_dimensions NUMBER;
    h_dbi_dim_requests BSC_UPDATE_UTIL.t_array_of_number;

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

BEGIN
    h_num_indicators := 0;
    h_num_input_tables := 0;

    -- Bug#4681065
    g_warning := FALSE;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    -- Initializes g_session_id, g_user_id and g_schema_name
    IF NOT Init_Env_Values THEN
        RAISE e_update_error;
    END IF;

    IF x_indicators IS NULL THEN
        -- No indicators to be processed
        RETURN;
    END IF;

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    -- Decompose the list in x_parameter_1 into the array h_indicators
    h_num_indicators := BSC_UPDATE_UTIL.Decompose_Numeric_List(x_indicators,
                                                               h_indicators,
                                                               ',');

    IF h_num_indicators = 0 THEN
        -- No indicators to be processed
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        RETURN;
    END IF;

    if x_load_dim_affected_indicators is not null and x_load_dim_affected_indicators='Y' then
      l_num_input_tables:=0;
      -- Get input tables used for the indicators
      IF NOT Get_Input_Tables_Kpis(h_indicators, h_num_indicators, l_input_tables, l_num_input_tables) THEN
          RAISE e_unexpected_error;
      END IF;
      /*
      for these input tables, get the affected indicators..these indicators also have to be loaded
      */
      if get_kpi_for_input_tables(l_input_tables,l_num_input_tables,h_indicators,h_num_indicators)=false then
        raise e_unexpected_error;
      end if;
    end if;

    -- ---------------------- Refresh DBI dimensions ---------------------------
    -- Get short name of the DBI dimensions used by the indicators
    -- AW_INTEGRATION: Since we need to bring all the BIS dimensions used by AW indicators into AW world
    -- I need to change the next function to return all the BIS dimensions and not only the
    -- ones that are materialized in BSC
    IF NOT BSC_UPDATE_DIM.Get_Dbi_Dims_Kpis(h_indicators, h_num_indicators, h_dbi_dimensions, h_num_dbi_dimensions) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Launch a concurrent program to refresh each DBI dim table created in BSC to materialize
    -- the DBi dimension view.

    -- Create the global temporary tables needed in this process (one time)
    IF h_num_dbi_dimensions > 0 THEN
        IF NOT BSC_UPDATE_DIM.Create_Dbi_Dim_Temp_Tables THEN
            RAISE e_unexpected_error;
        END IF;
        -- AW_INTEGRATION: Create temporary tables needed for AW dimension processing
        IF NOT BSC_UPDATE_DIM.Create_AW_Dim_Temp_Tables THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    h_dbi_dim_requests.delete;
    FOR h_i IN 1..h_num_dbi_dimensions LOOP
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_IVIEWER', 'REFRESH')||
                                      ' '||h_dbi_dimensions(h_i), BSC_UPDATE_LOG.OUTPUT);

        h_dbi_dim_requests(h_i) :=  FND_REQUEST.Submit_Request(application => BSC_APPS.bsc_apps_short_name,
                                                               program => 'BSC_REFRESH_DBI_DIM',
                                                               argument1 => h_dbi_dimensions(h_i));


        IF h_dbi_dim_requests(h_i) = 0 THEN
            -- Request error;
            BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_SUBMMITREQ_FAILED'), BSC_UPDATE_LOG.OUTPUT);
        ELSE
            BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_LOADER_REQ_ID')||
                                          ' '||h_dbi_dim_requests(h_i), BSC_UPDATE_LOG.OUTPUT);
        END IF;
        COMMIT;
    END LOOP;
    -- --------------------------------------------------------------------------------

    -- Get dimension input tables used for the indicators
    IF NOT Get_Dim_Input_Tables_Kpis(h_indicators, h_num_indicators, h_input_tables, h_num_input_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_num_input_tables = 0 THEN
        -- No input tables to load
        IF h_num_dbi_dimensions > 0 THEN
            IF NOT Wait_For_Requests(h_dbi_dim_requests, h_num_dbi_dimensions) THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;
        RETURN;
    END IF;

    --LOCKING: get the sequence nextval here and then use it
    SELECT bsc_db_process_id_s.nextval
    INTO h_process_id
    FROM DUAL;

    -- Create a new process in BSC_DB_PROCESS_CONTROL
    INSERT INTO bsc_db_process_control (process_id, process_name,
        creation_date, created_by, last_update_date,last_updated_by,
        last_update_login, status)
    VALUES (h_process_id, PC_LOAD_DIMENSIONS,
        SYSDATE, g_user_id, SYSDATE, g_user_id, g_session_id, PC_PENDING_STATUS);

    -- Insert input tables in BSC_DB_LOADER_CONTROL
    FOR h_i IN 1..h_num_input_tables LOOP
        INSERT INTO bsc_db_loader_control (process_id, input_table_name, status,
            error_code, stage, last_stage_flag)
        VALUES (h_process_id, h_input_tables(h_i), LC_PENDING_STATUS, NULL, LC_PENDING_STAGE, 0);
    END LOOP;
    COMMIT;

    -- Run loader
    Execute_Update_Process(h_process_id, PC_LOAD_DIMENSIONS, x_indicators);


    -- ------------- Wait for DBI Dimensions refresh ---------------------
    IF h_num_dbi_dimensions > 0 THEN
        IF NOT Wait_For_Requests(h_dbi_dim_requests, h_num_dbi_dimensions) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;
    -- -------------------------------------------------------------------

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    SELECT count(*)
    INTO h_count
    FROM bsc_db_loader_control
    WHERE process_id = g_process_id AND status IN (LC_ERROR_STATUS, LC_NO_DATA_STATUS);

    IF h_count > 0 THEN
        RAISE e_warning;
    END IF;

    -- Bug#4681065
    IF g_warning THEN
        RAISE e_warning;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_warning THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        ERRBUF := '';
        RETCODE := 1; -- Request completed with warning

    WHEN e_unexpected_error THEN
        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Load_Indicators_Dims',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Load_Indicators_Dims;


/*===========================================================================+
| PROCEDURE Delete_Indicators_Data
+============================================================================*/
PROCEDURE Delete_Indicators_Data (
        ERRBUF OUT NOCOPY VARCHAR2,
	RETCODE OUT NOCOPY VARCHAR2,
        x_indicators IN VARCHAR2,
        x_keep_input_table_data IN VARCHAR2
	) IS

    e_system_lock EXCEPTION;
    e_update_error EXCEPTION;
    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_source VARCHAR2(200);

    h_indicators BSC_UPDATE_UTIL.t_array_of_number;
    h_num_indicators NUMBER;

    h_process_id NUMBER;
    h_i NUMBER;

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);

BEGIN
    h_num_indicators := 0;
    g_keep_input_table_data := x_keep_input_table_data;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call thi api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    g_debug_flag := 'NO';
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    -- Initializes g_session_id, g_user_id and g_schema_name
    IF NOT Init_Env_Values THEN
        RAISE e_update_error;
    END IF;

    -- Check system lock
    --LOCKING: Do not use BSC_SECURITY.
    --BSC_SECURITY.Check_System_Lock(-101, NULL, BSC_APPS.apps_user_id);
    --h_source := 'BSC_SECURITY.CHECK_SYSTEM_LOCK';
    --SELECT count(*)
    --INTO h_count
    --FROM bsc_message_logs
    --WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;
    --IF h_count > 0 THEN
    --    RAISE e_system_lock;
    --END IF;
    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -101,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    -- Bug Fix: From now on if this concurrent program is called from Loader UI
    -- it is passing in the parameter x_indicators the process id in this way: PROCESS_ID:<process_id>
    -- Now, if this concurrent program is called from RSG it continue passing the list
    -- of indicators

    IF SUBSTR(x_indicators, 1, 11) = 'PROCESS_ID:' THEN
        -- it is called from loader ui and it is passing the process id
        h_process_id := TO_NUMBER(SUBSTR(x_indicators, 12));
    ELSE
        -- called from RSG, it is passing a list of indicators
        --Decompose the list in x_indicators into the array h_indicators
        h_num_indicators := BSC_UPDATE_UTIL.Decompose_Numeric_List(x_indicators,
                                                                   h_indicators,
                                                                   ',');

        IF h_num_indicators = 0 THEN
            -- No indicators to be processed
            -- LOCKING
            BSC_LOCKS_PUB.Remove_System_Lock;
            RETURN;
        END IF;

        -- LOCKING: get the sequence next val here and then use it
        SELECT bsc_db_process_id_s.nextval
        INTO h_process_id
        FROM DUAL;

        -- Create a new process in BSC_DB_PROCESS_CONTROL
        INSERT INTO bsc_db_process_control (process_id, process_name,
           creation_date, created_by, last_update_date,last_updated_by,
           last_update_login, status)
        VALUES (h_process_id, PC_DELETE_KPI_DATA_PROCESS,
           SYSDATE, g_user_id, SYSDATE, g_user_id, g_session_id, PC_PENDING_STATUS);

        -- Insert indicators in BSC_DB_LOADER_CONTROL
        FOR h_i IN 1..h_num_indicators LOOP
            INSERT INTO bsc_db_loader_control (process_id, input_table_name, status,
                error_code, stage, last_stage_flag)
            VALUES (h_process_id, h_indicators(h_i), NULL, NULL, NULL, 0);
        END LOOP;
        COMMIT;
    END IF;

    -- Run loader
    Execute_Update_Process(h_process_id, PC_DELETE_KPI_DATA_PROCESS, NULL);

    h_source := 'BSC_UPDATE.EXECUTE_UPDATE_PROCESS';

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0 AND UPPER(source) = h_source AND last_update_login = g_session_id;

    IF h_count > 0 THEN
        RAISE e_update_error;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

EXCEPTION
    WHEN e_system_lock THEN
        --LOCKING: h_msg_data has the error message
        BSC_MESSAGE.Add(
                X_Message => h_msg_data,
                X_Source  => 'BSC_UPDATE.Run_Concurrent_Loader_Apps',
                X_Mode    => 'I'
        );

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN e_update_error THEN
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Delete_Indicators_Data',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                      BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                      ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_UPDATE_LOG.OUTPUT);

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;

        ERRBUF := SQLERRM;
        RETCODE := 2; -- Request completed with errors

END Delete_Indicators_Data;


/*===========================================================================+
| FUNCTION Get_Input_Tables_Kpis
+============================================================================*/
FUNCTION Get_Input_Tables_Kpis(
	x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_indicators IN NUMBER,
        x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_where_indics VARCHAR2(32000);
    h_i NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32700);

    h_table_name VARCHAR2(50);

    h_system_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_system_tables NUMBER;

BEGIN
    h_where_indics := NULL;
    h_sql := NULL;
    h_num_system_tables := 0;

    h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
    FOR h_i IN 1 .. x_num_indicators LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_indicators(h_i));
    END LOOP;

    h_sql := 'SELECT table_name'||
             ' FROM bsc_kpi_data_tables'||
             ' WHERE ('||h_where_indics||') AND table_name IS NOT NULL';

    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_table_name;
    WHILE h_cursor%FOUND LOOP
        h_num_system_tables := h_num_system_tables + 1;
        h_system_tables(h_num_system_tables) := h_table_name;

        FETCH h_cursor INTO h_table_name;
    END LOOP;
    CLOSE h_cursor;

    -- Insert into the array x_input_tables the input tables from where the system tables are originated.
    IF NOT BSC_UPDATE_INC.Get_Input_Tables(x_input_tables, x_num_input_tables, h_system_tables, h_num_system_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_ITABLES_FAILED'),
                        x_source => 'BSC_UPDATE.Get_Input_Tables_Kpis');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Input_Tables_Kpis');
        RETURN FALSE;

END Get_Input_Tables_Kpis;

function get_kpi_for_input_tables(
x_input_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
x_num_input_tables IN NUMBER,
x_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
x_num_indicators IN OUT NOCOPY NUMBER
)return boolean is
--
e_unexpected_error exception;
--
Begin
  if x_num_indicators is null then
    x_num_indicators:=0;
  end if;
  for i in 1..x_num_input_tables loop
    if get_kpi_for_input_tables(x_input_tables(i),x_indicators,x_num_indicators)=false then
      raise e_unexpected_error;
    end if;
  end loop;
  return true;
EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_ITABLES_FAILED'),
                        x_source => 'BSC_UPDATE.get_kpi_for_input_tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.get_kpi_for_input_tables');
        RETURN FALSE;

END get_kpi_for_input_tables;

--called recursively
function get_kpi_for_input_tables(
x_input_table varchar2,
x_indicators IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
x_num_indicators IN OUT NOCOPY NUMBER
)return boolean is
--
cursor c1(p_table varchar2) is select table_name from bsc_db_tables_rels where source_table_name=p_table;
--
cursor c2(p_table varchar2) is select distinct indicator from bsc_kpi_data_tables where table_name=p_table;
--
l_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
l_num_tables number;
l_indicator number;
--
Begin
  l_num_tables:=1;
  open c1(x_input_table);
  loop
    fetch c1 into l_tables(l_num_tables);
    exit when c1%notfound;
    l_num_tables:=l_num_tables+1;
  end loop;
  l_num_tables:=l_num_tables-1;
  close c1;
  for i in 1..l_num_tables loop
    l_indicator:=null;
    open c2(l_tables(i));
    fetch c2 into l_indicator;
    close c2;
    if l_indicator is not null then
      if value_in_array(l_indicator,x_indicators,x_num_indicators)=false then
        x_num_indicators:=x_num_indicators+1;
        x_indicators(x_num_indicators):=l_indicator;
      end if;
    else
      --continue
      if get_kpi_for_input_tables(l_tables(i),x_indicators,x_num_indicators)=false then
        return false;
      end if;
    end if;
  end loop;
  return true;
EXCEPTION when others then
  return false;
END get_kpi_for_input_tables;

function value_in_array(
x_value number,
x_array BSC_UPDATE_UTIL.t_array_of_number,
x_num_array NUMBER
)return boolean is
Begin
  for i in 1..x_num_array loop
    if x_array(i)=x_value then
      return true;
    end if;
  end loop;
  return false;
EXCEPTION when others then
  raise;
End;

/*===========================================================================+
| FUNCTION Get_Dim_Input_Tables_Kpis
+============================================================================*/
FUNCTION Get_Dim_Input_Tables_Kpis(
	x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_indicators IN NUMBER,
        x_input_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_input_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_where_indics VARCHAR2(32000);
    h_i NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32700);

    h_table_name VARCHAR2(50);

    h_source VARCHAR2(10);

BEGIN
    h_where_indics := NULL;
    h_sql := NULL;
    h_source := 'BSC';

    h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'k.indicator');
    FOR h_i IN 1 .. x_num_indicators LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_indicators(h_i));
    END LOOP;

    h_sql := 'SELECT DISTINCT source_table_name'||
             ' FROM bsc_kpi_dim_levels_vl k, bsc_db_tables_rels r'||
             ' WHERE ('||h_where_indics||') AND k.level_source = :1 '||
             ' AND  k.level_table_name = r.table_name';

    OPEN h_cursor FOR h_sql USING h_source;
    FETCH h_cursor INTO h_table_name;
    WHILE h_cursor%FOUND LOOP
        x_num_input_tables := x_num_input_tables + 1;
        x_input_tables(x_num_input_tables) := h_table_name;

        FETCH h_cursor INTO h_table_name;
    END LOOP;
    CLOSE h_cursor;

    -- Also include Input tables for MN dimensions
    h_sql := 'SELECT DISTINCT source_table_name'||
             ' FROM bsc_kpi_dim_levels_vl k, bsc_db_tables_rels r'||
             ' WHERE ('||h_where_indics||') AND k.level_source = :1 '||
             ' AND  k.table_relation = r.table_name';

    OPEN h_cursor FOR h_sql USING h_source;
    FETCH h_cursor INTO h_table_name;
    WHILE h_cursor%FOUND LOOP
        x_num_input_tables := x_num_input_tables + 1;
        x_input_tables(x_num_input_tables) := h_table_name;

        FETCH h_cursor INTO h_table_name;
    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_ITABLES_FAILED'),
                        x_source => 'BSC_UPDATE.Get_Dim_Input_Tables_Kpis');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Get_Dim_Input_Tables_Kpis');
        RETURN FALSE;

END Get_Dim_Input_Tables_Kpis;


/*===========================================================================+
| FUNCTION Set_PStatus_Finished
+============================================================================*/
FUNCTION Set_PStatus_Finished(
	x_status IN VARCHAR2
	) RETURN BOOLEAN IS
BEGIN
    UPDATE
        bsc_db_process_control
    SET
        last_update_date = SYSDATE,
        last_updated_by = g_user_id,
        last_update_login = g_session_id,
        status = x_status,
        end_time = SYSDATE
    WHERE
        process_id = g_process_id;

  RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Set_PStatus_Finished');
        RETURN FALSE;

END Set_PStatus_Finished;


/*===========================================================================+
| FUNCTION Set_PStatus_Running
+============================================================================*/
FUNCTION Set_PStatus_Running RETURN BOOLEAN IS

    h_complete_log_file_name VARCHAR2(500);

BEGIN
    IF BSC_UPDATE_LOG.Log_File_Name IS NULL THEN
        h_complete_log_file_name := NULL;
    ELSE
        h_complete_log_file_name := BSC_UPDATE_LOG.Log_File_Dir||'/'||BSC_UPDATE_LOG.Log_File_Name;
    END IF;

    UPDATE
        bsc_db_process_control
    SET
        last_update_date = SYSDATE,
        last_updated_by = g_user_id,
        last_update_login = g_session_id,
        status = PC_RUNNING_STATUS,
        log_file_location = h_complete_log_file_name,
        start_time = SYSDATE
    WHERE
        process_id = g_process_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE.Set_PStatus_Running');
      RETURN FALSE;

END Set_PStatus_Running;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Update_Indicator_Period
+============================================================================*/
FUNCTION Update_Indicator_Period (
    x_indicator IN NUMBER
) RETURN BOOLEAN IS
BEGIN
    -- The update period of an indicator is the minimun period of the tables
    -- used by the indicator.

    -- BSC-PMF Integration:Fix this query by adding NVL, to avoid assigning NULL
    -- to the current period when all of the analysis options of a kpi are for PMF measures.

    UPDATE bsc_kpi_periodicities p
    SET current_period = (
        SELECT DISTINCT
            NVL(MIN(t.current_period), p.current_period)
        FROM
            bsc_kpi_data_tables k,
            bsc_db_tables t
        WHERE
            k.table_name = t.table_name AND
            k.indicator = p.indicator AND
	    t.periodicity_id = p.periodicity_id)
    WHERE p.indicator = x_indicator;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Update_Indicator_Period');
        RETURN FALSE;

END Update_Indicator_Period;


/*===========================================================================+
| FUNCTION Update_Indicators_Periods
+============================================================================*/
FUNCTION Update_Indicators_Periods RETURN BOOLEAN IS
BEGIN
    -- The update period of an indicator is the minimun period of the tables
    -- used by the indicator.

    -- BSC-PMF Integration:Fix this query by adding NVL, to avoid assigning NULL
    -- to the current period when all of the analysis options of a kpi are for PMF measures.

    UPDATE bsc_kpi_periodicities p
    SET current_period = (
        SELECT DISTINCT
            NVL(MIN(t.current_period), p.current_period)
        FROM
            bsc_kpi_data_tables k,
            bsc_db_tables t
        WHERE
            k.table_name = t.table_name AND
            k.indicator = p.indicator AND
	    t.periodicity_id = p.periodicity_id)
    WHERE p.indicator IN (
        SELECT
            indicator
        FROM
            bsc_kpis_vl);


    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Update_Indicators_Periods');
        RETURN FALSE;

END Update_Indicators_Periods;


/*===========================================================================+
| FUNCTION Update_Stage_Input_Table
+============================================================================*/
FUNCTION Update_Stage_Input_Table(
	x_input_table IN VARCHAR2,
        x_target_stage IN VARCHAR2
	) RETURN BOOLEAN IS
BEGIN
    UPDATE
        bsc_db_loader_control
    SET
        stage = x_target_stage
    WHERE
        input_table_name = x_input_table AND
        process_id = g_process_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE.Update_Stage_Input_Table');
      RETURN FALSE;

END Update_Stage_Input_Table;


/*===========================================================================+
| FUNCTION Update_Stage_Input_Tables
+============================================================================*/
FUNCTION Update_Stage_Input_Tables(
	x_current_status IN VARCHAR2,
	x_target_stage IN VARCHAR2,
	x_last_stage_flag IN BOOLEAN
	) RETURN BOOLEAN IS
BEGIN
    IF x_last_stage_flag THEN
        UPDATE
            bsc_db_loader_control
        SET
            last_stage_flag = 0
        WHERE
            input_table_name IN (
                SELECT
                    input_table_name
                FROM
                    bsc_db_loader_control
                WHERE
                    process_id = g_process_id AND
                    status = x_current_status
            );

        UPDATE
            bsc_db_loader_control
        SET
            stage = x_target_stage,
            last_stage_flag = 1
        WHERE
            process_id = g_process_id AND
            status = x_current_status;

    ELSE
        UPDATE
            bsc_db_loader_control
        SET
            stage = x_target_stage
        WHERE
            process_id = g_process_id AND
            status = x_current_status;

    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Update_Stage_Input_Tables');
        RETURN FALSE;

END Update_Stage_Input_Tables;


/*===========================================================================+
| FUNCTION Update_Status_All_Input_Tables
+============================================================================*/
FUNCTION Update_Status_All_Input_Tables(
	x_current_status IN VARCHAR2,
	x_target_status IN VARCHAR2,
	x_error_code IN VARCHAR2
	) RETURN BOOLEAN IS
BEGIN
    UPDATE
        bsc_db_loader_control
    SET
        status = x_target_status,
        error_code = x_error_code
    WHERE
        status = x_current_status AND
        process_id = g_process_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE.Update_Status_All_Input_Tables');
      RETURN FALSE;

END Update_Status_All_Input_Tables;


/*===========================================================================+
| FUNCTION Update_Status_Input_Table
+============================================================================*/
FUNCTION Update_Status_Input_Table(
	x_input_table IN VARCHAR2,
        x_target_status IN VARCHAR2,
	x_error_code IN VARCHAR2
	) RETURN BOOLEAN IS
BEGIN
    UPDATE
        bsc_db_loader_control
    SET
        status = x_target_status,
        error_code = x_error_code
    WHERE
        input_table_name = x_input_table AND
        process_id = g_process_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE.Update_Status_Input_Table');
      RETURN FALSE;

END Update_Status_Input_Table;


/*===========================================================================+
| FUNCTION Wait_For_Requests
+============================================================================*/
FUNCTION Wait_For_Requests(
    x_requests IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_requests IN NUMBER
) RETURN BOOLEAN IS

    h_i NUMBER;
    h_b BOOLEAN;
    h_phase VARCHAR2(32000);
    h_status VARCHAR2(2000);
    h_dev_phase VARCHAR2(2000);
    h_dev_status VARCHAR2(2000);
    h_message VARCHAR2(2000);

BEGIN
    FOR h_i IN 1..x_num_requests LOOP
        IF x_requests(h_i) <> 0 THEN
            h_b := FND_CONCURRENT.Wait_For_Request(request_id => x_requests(h_i),
                                                   phase => h_phase,
                                                   status => h_status,
                                                   dev_phase => h_dev_phase,
                                                   dev_status => h_dev_status,
                                                   message => h_message);
            COMMIT;
        END IF;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE.Wait_For_Requests');
        RETURN FALSE;
 END Wait_For_Requests;


/*===========================================================================+
| FUNCTION Write_Result_Log
+============================================================================*/
FUNCTION Write_Result_Log RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    C_TABLE_W CONSTANT NUMBER := 32;
    C_STATUS_W CONSTANT NUMBER := 48;
    C_COLUMN_W CONSTANT NUMBER := 24;
    C_INVALID_CODE_W CONSTANT NUMBER := 24;

    C_TABLE_NAME_W CONSTANT NUMBER := 32;
    C_PERIODICITY_W CONSTANT NUMBER := 33;
    C_PERIOD_W CONSTANT NUMBER := 15;

    h_update_date VARCHAR2(200);

    TYPE t_cursor IS REF CURSOR;

    /*
    c_status t_cursor; -- g_process_id
    c_status_sql VARCHAR2(2000) := 'SELECT input_table_name, status, error_code'||
                                   ' FROM bsc_db_loader_control'||
                                   ' WHERE process_id = :1'||
                                   ' ORDER BY input_table_name';
    */
    CURSOR c_status (p_process_id NUMBER) IS
        SELECT input_table_name, status, error_code
        FROM bsc_db_loader_control
        WHERE process_id = p_process_id
        ORDER BY input_table_name;


    h_input_table_name VARCHAR2(30);
    h_status VARCHAR2(1);
    h_error_code VARCHAR2(25);
    h_line VARCHAR2(200);

    /*
    c_invalid_codes t_cursor; -- g_process_name, PC_LOADER_PROCESS, 0, 2
    c_invalid_codes_sql VARCHAR2(2000) := 'SELECT input_table_name, column_name, invalid_code'||
                                          ' FROM bsc_db_validation'||
                                          ' WHERE input_table_name IN ('||
                                          ' SELECT table_name'||
                                          ' FROM bsc_db_tables'||
                                          ' WHERE table_type = DECODE(:1, :2, :3, :4))'||
                                          ' ORDER BY input_table_name';
    */
    --Fix bug#4581846: show invalid codes for input tables involved in this process only
    CURSOR c_invalid_codes (p_process_id NUMBER) IS
        SELECT input_table_name, column_name, invalid_code
        FROM bsc_db_validation
        WHERE input_table_name IN (
            SELECT input_table_name
            FROM bsc_db_loader_control
            WHERE process_id = p_process_id
        )
        ORDER BY input_table_name;

    h_column_name VARCHAR2(250);
    h_invalid_code VARCHAR2(250);

    /*
    c_tables t_cursor; -- g_process_id
    c_tables_sql VARCHAR2(2000) := 'SELECT lc.input_table_name, t.periodicity_id,'||
                                   ' p.name, t.current_period, t.current_subperiod'||
                                   ' FROM bsc_db_tables t, bsc_db_loader_control lc, bsc_sys_periodicities_vl p'||
                                   ' WHERE lc.input_table_name = t.table_name AND'||
                                   ' lc.process_id = :1 AND t.periodicity_id = p.periodicity_id';
    */
    CURSOR c_tables (p_process_id NUMBER) IS
        SELECT lc.input_table_name, t.periodicity_id,
               p.name, t.current_period, t.current_subperiod
        FROM bsc_db_tables t, bsc_db_loader_control lc, bsc_sys_periodicities_vl p
        WHERE lc.input_table_name = t.table_name AND
              lc.process_id = p_process_id AND t.periodicity_id = p.periodicity_id;

    h_periodicity_id NUMBER;
    h_periodicity_name VARCHAR2(200);
    h_current_period NUMBER;
    h_current_subperiod NUMBER;

    h_periodicity_type NUMBER;

BEGIN
-- Result
    BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);
    BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                  BSC_UPDATE_LOG.OUTPUT);
    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_PROCESS_RESULT'), BSC_UPDATE_LOG.OUTPUT);
    BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                  BSC_UPDATE_LOG.OUTPUT);
    -- Get update date
    IF NOT BSC_UPDATE_UTIL.Get_Init_Variable_Value('UPDATE_DATE', h_update_date) THEN
        RAISE e_unexpected_error;
    END IF;
    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_LAST_UPDATE')||' '||h_update_date, BSC_UPDATE_LOG.OUTPUT);
    BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);

    --OPEN c_status FOR c_status_sql USING g_process_id;
    OPEN c_status(g_process_id);
    FETCH c_status INTO h_input_table_name, h_status, h_error_code;

    IF c_status%FOUND THEN
        BSC_UPDATE_LOG.Write_Line_Log(RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'INPUT_TABLE_NAME'), C_TABLE_W)||
                                      RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'STATUS'), C_STATUS_W),
                                      BSC_UPDATE_LOG.OUTPUT);
    END IF;

    WHILE c_status%FOUND LOOP
        h_line := RPAD(h_input_table_name, C_TABLE_W);
        IF h_status = LC_ERROR_STATUS THEN
            h_line := h_line||BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_UPDATE_FAILED');

            IF h_error_code = LC_INVALID_CODES_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_INVALID_CODES_FOUND');
            ELSIF h_error_code = LC_PROGRAM_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_LOADER_PROC_FAILED');
            ELSIF h_error_code =  LC_UPLOAD_OPEN_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_SRCFILE_FAILED');
            ELSIF h_error_code = LC_UPLOAD_NUM_COLS_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_SRC_FIELDNUMBER_FAILED');
            ELSIF h_error_code = LC_UPLOAD_INV_KEY_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_SRC_NULL_KEYVALUES');
            ELSIF h_error_code = LC_UPLOAD_INSERT_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_INVALID_DATATYPE');
            ELSIF h_error_code = LC_UPLOAD_NOT_FOUND_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_SRCFILE_NOT_FOUND');
            ELSIF h_error_code = LC_UPLOAD_EXCEL_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_EXCEL_CONNECTION_FAILED');
            ELSIF h_error_code = LC_UPLOAD_SP_NOT_FOUND_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_STOREDPROC_NOT_FOUND');
            ELSIF h_error_code = LC_UPLOAD_SP_INVALID_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_STOREDPROC_IS_INVALID');
            ELSIF h_error_code = LC_UPLOAD_SP_EXECUTION_ERR THEN
                h_line := h_line||' '||BSC_UPDATE_UTIL.Get_Message('BSC_STOREDPROC_FAILED');
           END IF;

        ELSIF h_status =  LC_NO_DATA_STATUS THEN
            h_line := h_line||BSC_UPDATE_UTIL.Get_Message('BSC_TABLE_UPDATE_FAILED')||' '||
                      BSC_UPDATE_UTIL.Get_Message('BSC_ITABLE_EMPTY');
        ELSIF h_status = LC_COMPLETED_STATUS THEN
            h_line := h_line||BSC_UPDATE_UTIL.Get_Message('BSC_UPDATED_STATUS');
        END IF;

        BSC_UPDATE_LOG.Write_Line_Log(h_line, BSC_UPDATE_LOG.OUTPUT);

        FETCH c_status INTO h_input_table_name, h_status, h_error_code;
    END LOOP;
    CLOSE c_status;

-- Invalid codes
    OPEN c_invalid_codes(g_process_id);
    FETCH c_invalid_codes INTO h_input_table_name, h_column_name, h_invalid_code;
    IF c_invalid_codes%FOUND THEN
        BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                      BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'INVALID_RECORDS'),
                                      BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                      BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'INPUT_TABLE_NAME'), C_TABLE_W)||
                                      RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'COLUMN'), C_COLUMN_W)||
                                      RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'INVALID_CODE'), C_INVALID_CODE_W),
                                      BSC_UPDATE_LOG.OUTPUT);
    END IF;

    WHILE c_invalid_codes%FOUND LOOP
        BSC_UPDATE_LOG.Write_Line_Log(RPAD(h_input_table_name, C_TABLE_W)||
                                      RPAD(h_column_name, C_COLUMN_W)||
                                      RPAD(h_invalid_code, C_INVALID_CODE_W), BSC_UPDATE_LOG.OUTPUT);
        FETCH c_invalid_codes INTO h_input_table_name, h_column_name, h_invalid_code;
    END LOOP;
    CLOSE c_invalid_codes;


-- Update periods
    IF g_process_name = PC_LOADER_PROCESS THEN
        BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                      BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'TABLE_UPDATE_PERIOD'),
                                      BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                      BSC_UPDATE_LOG.OUTPUT);
        BSC_UPDATE_LOG.Write_Line_Log(RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'INPUT_TABLE_NAME'), C_TABLE_NAME_W)||
                                      RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'PERIODICITY'), C_PERIODICITY_W)||
                                      RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'PERIOD'), C_PERIOD_W),
                                      BSC_UPDATE_LOG.OUTPUT);

        --OPEN c_tables FOR c_tables_sql USING g_process_id;
        OPEN c_tables(g_process_id);
        FETCH c_tables INTO h_input_table_name, h_periodicity_id, h_periodicity_name, h_current_period, h_current_subperiod;

        WHILE c_tables%FOUND LOOP
            h_line := RPAD(h_input_table_name, C_TABLE_NAME_W)||RPAD(h_periodicity_name, C_PERIODICITY_W)||TO_CHAR(h_current_period);

            h_periodicity_type := BSC_UPDATE_UTIL.Get_Periodicity_Type(h_periodicity_id);

            IF h_periodicity_type = 11 OR h_periodicity_type = 12 THEN
                h_line := h_line||', '||TO_CHAR(h_current_subperiod);
            END IF;

            BSC_UPDATE_LOG.Write_Line_Log(h_line, BSC_UPDATE_LOG.OUTPUT);

            FETCH c_tables INTO h_input_table_name, h_periodicity_id, h_periodicity_name, h_current_period, h_current_subperiod;
        END LOOP;
        CLOSE c_tables;
    END IF;

    BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_WR_LOGFILE_RES_FAILED'),
                      x_source => 'BSC_UPDATE.Write_Result_Log');
      RETURN FALSE;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE.Write_Result_Log');
      RETURN FALSE;

END Write_Result_Log;

/*===========================================================================+
| FUNCTION Get_Indicator_List
+============================================================================*/
FUNCTION Get_Indicator_List(x_number_array IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number)
RETURN NUMBER IS
  CURSOR cIndics is
    SELECT value_n
    FROM BSC_TMP_BIG_IN_COND
    WHERE session_id = -500 and variable_id = -500;
  indicator NUMBER;
  h_num_items NUMBER;
BEGIN
  h_num_items := 0;
  OPEN cIndics;
  FETCH cIndics INTO indicator;
  WHILE cIndics%FOUND LOOP
    h_num_items := h_num_items + 1;
    x_number_array(h_num_items) := indicator;
    FETCH cIndics INTO indicator;
  END LOOP;
  CLOSE cIndics;
  DELETE BSC_TMP_BIG_IN_COND where session_id = -500 and variable_id = -500;
  RETURN h_num_items;
END Get_Indicator_List;


--Fix bug#4681065
/*===========================================================================+
| PROCEDURE Write_Warning_Kpis_In_Prot
+============================================================================*/
PROCEDURE Write_Warning_Kpis_In_Prot (
    x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_system_tables IN NUMBER
) IS

    h_where_cond VARCHAR2(32700);
    h_i NUMBER;
    h_sql VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_kpi NUMBER;
    h_name VARCHAR2(2000);
    h_message VARCHAR2(5000);

BEGIN
    IF g_kpi_mode THEN
        h_where_cond := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
        FOR h_i IN 1 .. g_num_indicators LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, g_indicators(h_i));
        END LOOP;

        h_sql := 'select indicator, name'||
                 ' from bsc_kpis_vl'||
                 ' where prototype_flag NOT IN (:1, :2, :3) and '||h_where_cond;
        h_i := 0;
        OPEN h_cursor FOR h_sql USING 0, 6, 7;
        LOOP
            FETCH h_cursor INTO h_kpi, h_name;
            EXIT WHEN h_cursor%NOTFOUND;

            IF h_i = 0 THEN
                h_message := BSC_UPDATE_UTIL.Get_Message('BSC_CANNOT_LOAD_OBJS_IN_PROT');
                BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                h_i := 1;
            END IF;
            BSC_UPDATE_LOG.Write_Line_Log(h_kpi||' '||h_name, BSC_UPDATE_LOG.OUTPUT);
            g_warning := TRUE;
        END LOOP;
        CLOSE h_cursor;
    ELSE
        h_where_cond := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'table_name');
        FOR h_i IN 1 .. x_num_system_tables LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, x_system_tables(h_i));
        END LOOP;

        h_sql := 'select indicator, name'||
                 ' from bsc_kpis_vl'||
                 ' where prototype_flag NOT IN (:1, :2, :3) and'||
                 ' indicator in (select indicator'||
                 ' from bsc_kpi_data_tables'||
                 ' where '||h_where_cond||
                 ' )';
       h_i := 0;
       OPEN h_cursor FOR h_sql USING 0, 6, 7;
       LOOP
           FETCH h_cursor INTO h_kpi, h_name;
           EXIT WHEN h_cursor%NOTFOUND;

           IF h_i = 0 THEN
               h_message := BSC_UPDATE_UTIL.Get_Message('BSC_CANNOT_LOAD_OBJS_IN_PROT');
               BSC_UPDATE_LOG.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
               h_i := 1;
           END IF;
           BSC_UPDATE_LOG.Write_Line_Log(h_kpi||' '||h_name, BSC_UPDATE_LOG.OUTPUT);
           g_warning := TRUE;
       END LOOP;
       CLOSE h_cursor;
    END IF;
END Write_Warning_Kpis_In_Prot;


END BSC_UPDATE;

/
