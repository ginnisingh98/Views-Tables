--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_SUM" AS
/* $Header: BSCDSUMB.pls 120.5 2006/04/03 14:08:22 meastmon noship $ */


/*===========================================================================+
| FUNCTION Calculate_Period_Summary_Table
+============================================================================*/
FUNCTION Calculate_Period_Summary_Table(
	x_periodicity IN NUMBER,
        x_origin_periodicity IN NUMBER,
        x_origin_period IN NUMBER,
        x_current_fy IN NUMBER
        ) RETURN NUMBER IS

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(2000);

    h_period_summary_table NUMBER;
    h_origin_calendar_col_name VARCHAR2(30);
    h_calendar_col_name VARCHAR2(30);

    h_yearly_flag NUMBER;
    h_edw_flag NUMBER;
    h_calendar_id NUMBER;

BEGIN
    h_yearly_flag := 0;
    h_edw_flag := 0;

    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity);

    IF x_origin_periodicity = x_periodicity THEN
        -- There is no periodicity change. The period of summary table
        -- is the origin period
        h_period_summary_table := x_origin_period;

    ELSIF h_yearly_flag = 1 THEN
        -- If periodicity of summary table is Annual the period is
        -- the current fiscal year
        h_period_summary_table := x_current_fy;

    ELSE
        -- There is periodicity change
        h_edw_flag := BSC_UPDATE_UTIL.Get_Periodicity_EDW_Flag(x_periodicity);

        IF h_edw_flag = 0 THEN
            -- BSC Periodicity
            -- Note: We suppose that the change of periodicity is allowed
            -- (see bsc_sys_periodicites)
            h_origin_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_origin_periodicity);
            h_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);

            h_sql := 'SELECT DISTINCT '||h_calendar_col_name||
                     ' FROM bsc_db_calendar'||
                     ' WHERE calendar_id = :1 AND year = :2'||
                     ' AND '||h_origin_calendar_col_name||' = :3';

            OPEN h_cursor FOR h_sql USING h_calendar_id, x_current_fy, x_origin_period;
            FETCH h_cursor INTO h_period_summary_table;
            IF h_cursor%NOTFOUND THEN
                RAISE e_unexpected_error;
            END IF;
            CLOSE h_cursor;
        ELSE
            -- EDW Periodicity
            -- Use BSC_EDW_TIME_MAP table which was previously created for
            -- x_periodicity_input_table --> x_periodicity_base_table
            h_sql := 'SELECT bsc_target'||
                     ' FROM bsc_edw_time_map'||
                     ' WHERE year = :1 AND bsc_source = :2';
            OPEN h_cursor FOR h_sql USING x_current_fy, x_origin_period;
            FETCH h_cursor INTO h_period_summary_table;
            IF h_cursor%NOTFOUND THEN
               RAISE e_unexpected_error;
            END IF;
            CLOSE h_cursor;
        END IF;
    END IF;

    RETURN h_period_summary_table;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_SUMTBLE_PERIOD_CALC_FAILED'),
                        x_source => 'BSC_UPDATE_SUM.Calculate_Period_Summary_Table');
        RETURN NULL;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_SUM.Calculate_Period_Summary_Table');
        RETURN NULL;

END Calculate_Period_Summary_Table;


/*===========================================================================+
| FUNCTION Calculate_Sum_Table
+============================================================================*/
FUNCTION Calculate_Sum_Table(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_b BOOLEAN;

    h_current_fy NUMBER;

    h_origin_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_origin_tables NUMBER;

    h_origin_period NUMBER;
    h_origin_periodicity NUMBER;

    h_period NUMBER;
    h_periodicity NUMBER;

    -- Generation type: Total or balance
    h_generation_type NUMBER;

    -- Data columns information
    h_data_columns  	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_formulas 	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_proj_methods BSC_UPDATE_UTIL.t_array_of_number;
    h_data_measure_types BSC_UPDATE_UTIL.t_array_of_number;
    h_num_data_columns  NUMBER;

    -- Key column information
    h_key_columns	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns	NUMBER;

    -- Key column information for the origin tables
    -- All origin tables have the same dissagregation
    h_key_columns_ori		BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables_ori	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns_ori	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables_ori	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns_ori	NUMBER;

    -- Projection flag
    h_projection_flag VARCHAR2(3);

    -- Number of year and previous years of the table
    h_num_of_years NUMBER;
    h_previous_years NUMBER;

    -- Zero code calculation method
    h_zero_code_calc_method NUMBER;

    h_calendar_id NUMBER;
    h_calendar_edw_flag NUMBER;
    h_yearly_flag NUMBER;
    h_start_year NUMBER;
    h_end_year NUMBER;

    h_target_flag NUMBER;
BEGIN
    h_num_origin_tables := 0;
    h_num_data_columns := 0;
    h_num_key_columns := 0;
    h_num_key_columns_ori := 0;
    h_projection_flag := 'NO';
    h_yearly_flag := 0;


    -- Initialize the array h_origin_tables with the tables from where
    -- the summary table is generated. There is at least one origin table.
    IF NOT Get_Origin_Tables(x_sum_table, h_origin_tables, h_num_origin_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the minimum period of the origin tables
    h_origin_period := Get_Minimun_Origin_Period(h_origin_tables, h_num_origin_tables);
    IF h_origin_period IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the origin tables.
    -- If a summary table comes from several tables, all origin tables have the
    -- same periodicity
    h_origin_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(h_origin_tables(1));
    IF h_origin_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the summary table
    h_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_sum_table);
    IF h_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the calendar id of the summary table
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(h_periodicity);
    h_calendar_edw_flag := BSC_UPDATE_UTIL.Get_Calendar_EDW_Flag(h_calendar_id);

    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

    -- Get the number of years and previous years of the table
    IF NOT BSC_UPDATE_UTIL.Get_Table_Range_Of_Years(x_sum_table, h_num_of_years, h_previous_years) THEN
        RAISE e_unexpected_error;
    END IF;

    --BSC-MV Note: EDW logic need to be reviews in the future
    -- Create BSC_EDW_TIME_MAP table, in case there is change of periodicity
    -- on EDW tables.
    --IF (h_periodicity <> h_origin_periodicity) AND (h_calendar_edw_flag = 1) THEN
    --    -- There is change of periodicity in a EDW calendar
    --    h_start_year := h_current_fy - h_previous_years;
    --    h_end_year := h_start_year + h_num_of_years - 1;
    --
    --    -- Create table to transform EDW periodicities
    --    BSC_INTEGRATION_APIS.Translate_EDW_Time(h_calendar_id,
    --                                            TO_CHAR(h_start_year)||'-'||TO_CHAR(h_end_year),
    --                                            h_origin_periodicity,
    --                                            h_periodicity);
    --    IF BSC_APPS.CheckError('BSC_INTEGRATION_APIS.Translate_EDW_Time') THEN
    --        RAISE e_unexpected_error;
    --    END IF;
    --END IF;

    -- Calculate the current period of summary table
    h_period := Calculate_Period_Summary_Table(h_periodicity,
                                               h_origin_periodicity,
                                               h_origin_period,
                                               h_current_fy);
    IF h_period IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Retrieve information of summary table to be processed

    -- Summary table generation type: Normal (Total or Balance data fields = 1 (default))
    h_generation_type := BSC_UPDATE_UTIL.Get_Table_Generation_Type(x_sum_table);
    IF h_generation_type IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Information of data columns of summary table
    IF NOT BSC_UPDATE_UTIL.Get_Information_Data_Columns(x_sum_table,
                                                        h_data_columns,
                                                        h_data_formulas,
                                                        h_data_proj_methods,
                                                        h_data_measure_types,
                                                        h_num_data_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Information of key columns of summary table
    IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(x_sum_table,
                                                       h_key_columns,
                                                       h_key_dim_tables,
                                                       h_source_columns,
                                                       h_source_dim_tables,
                                                       h_num_key_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Information of key columns of origin tables
    -- All origin tables have the same dissagregation
    -- I just need the array h_key_columns_ori.
    IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(h_origin_tables(1),
                                                       h_key_columns_ori,
                                                       h_key_dim_tables_ori,
                                                       h_source_columns_ori,
                                                       h_source_dim_tables_ori,
                                                       h_num_key_columns_ori) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Create temporary tables used for calculation and tranformations

    -- Projection
    h_b := BSC_UPDATE_CALC.Table_Has_Proj_Calc(x_sum_table);
    IF h_b IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_b THEN
        h_projection_flag := 'YES';
        --ENH_PROJECTION_4235711: pass TRUE in x_trunc_proj_table parameter
        IF NOT BSC_UPDATE_CALC.Create_Proj_Temps(h_periodicity,
  				                 h_current_fy,
						 h_num_of_years,
						 h_previous_years,
                                                 TRUE) THEN
            RAISE e_unexpected_error;
        END IF;
    ELSE
        h_projection_flag := 'NO';
    END IF;

    -- Note: Support of special codes calculation is pending
    -- No temporary table for profit calculation.
    -- No temporary tables for code zero calculation.

    COMMIT;

    -- Calculate the summary table
    IF h_generation_type = 1 THEN
        -- Calculate the summary table (support total or balance fields)
        -- Fix bug#4177794. Need to pass h_period
        IF NOT Calculate_Sum_Table_Total(x_sum_table,
                                         h_key_columns,
                                         h_key_dim_tables,
                                         h_source_columns,
                                         h_source_dim_tables,
                                         h_num_key_columns,
                                         h_data_columns,
                                         h_data_formulas,
                                         h_data_measure_types,
                                         h_num_data_columns,
                                         h_origin_tables,
                                         h_num_origin_tables,
                                         h_key_columns_ori,
                                         h_num_key_columns_ori,
                                         h_periodicity,
                                         h_origin_periodicity,
                                         h_period,
                                         h_origin_period,
                                         h_current_fy) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;
    END IF;

    --BSC-MV Note: EDW logic need to be reviewed in the future
    -- EDW Note: If this table is used directly by an EDW Kpi then this table has a corresponding
    --           materialized view with actuals
    --IF BSC_UPDATE_UTIL.Is_EDW_Kpi_Table(x_sum_table) THEN
    --    -- Refresh materialized view
    --    -- Refresh union view
    --    -- Delete from BSC table any data existing in the materialized view
    --    -- Period of the base table is the maximun reported in the materialized view
    --    IF NOT BSC_UPDATE_CALC.Refresh_EDW_Views(x_sum_table,
    --                                          h_key_columns,
    --						h_num_key_columns,
    --						h_data_columns,
    --						h_num_data_columns,
    --						h_current_fy,
    --                                          h_periodicity,
    --                                          h_period) THEN
    --        RAISE e_unexpected_error;
    --    END IF;
    --END IF;

    -- EDW Note: Materialized view already was filtered and already has zero codes for actuals
    --           So we dont need to calculate filters or zero codes for the materialized view
    --           No changes in this two functions.


    -- Filter the table
    IF NOT BSC_UPDATE_CALC.Apply_Filters(x_sum_table) THEN
        RAISE e_unexpected_error;
    END IF;
    COMMIT;


    -- Merge data from target tables
    IF NOT BSC_UPDATE_CALC.Merge_Data_From_Tables(x_sum_table,
	  					  h_key_columns,
						  h_num_key_columns) THEN
        RAISE e_unexpected_error;
    END IF;
    COMMIT;

    -- Calculate projection
    IF h_projection_flag = 'YES' THEN
        -- AW_INTEGRATION: Pass FALSE to x_aw_flag and change_vector parameter of Calculate_Projection. This is not for AW.
        IF NOT BSC_UPDATE_CALC.Calculate_Projection(x_sum_table,
   					            h_periodicity,
 						    h_period,
						    h_key_columns,
						    h_num_key_columns,
						    h_data_columns,
						    h_data_proj_methods,
						    h_num_data_columns,
						    h_current_fy,
						    h_num_of_years,
						    h_previous_years,
						    FALSE,
                                                    FALSE,
                                                    NULL) THEN
            RAISE e_unexpected_error;
        END IF;

        COMMIT;
    END IF;

    -- Calculate special codes is pending

    -- EDW Note: Materialized view already has profits for actuals
    --           So we dont need to calculate profit for the materialized view
    --           No changes in this function.

    -- Calculate Profit
    h_b := BSC_UPDATE_CALC.Table_Has_Profit_Calc(x_sum_table);
    IF h_b IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_b THEN
        --AW_INTEGRATION: Pass FALSE to x_aw_flag and change vector. This is not for AW
        IF NOT BSC_UPDATE_CALC.Calculate_Profit(x_sum_table,
                                                h_key_columns,
                                                h_key_dim_tables,
                                                h_num_key_columns,
                                                h_data_columns,
                                                h_num_data_columns,
                                                FALSE,
                                                NULL) THEN
            RAISE e_unexpected_error;
        END IF;

        COMMIT;
    END IF;

    -- Calculate zero codes
    --Fix bug#3542344 : Zero codes should be the last step to make it consistent with MV architecture
    --Also:
    --  - If this table is receiving targets we need to re-calculate zero code for the keys that already
    --    has zero code in the summary table.
    --  - We do not need to calculate zero code on tables used only for targets
    h_target_flag := BSC_UPDATE_UTIL.Get_Table_Target_Flag(x_sum_table);
    IF h_target_flag = 0 THEN
        h_zero_code_calc_method := 4; -- This is the only zero code method supported;
        IF NOT BSC_UPDATE_CALC.Calculate_Zero_Code(x_sum_table,
	                   		           h_zero_code_calc_method,
					           h_key_columns,
					           h_num_key_columns,
                                                   NULL) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;
    END IF;

    -- Store the update period of summary table
    UPDATE
        bsc_db_tables
    SET
        current_period = h_period
    WHERE
        table_name = x_sum_table;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_SUMTABLE_CALC_FAILED'),
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table');
      RETURN FALSE;

    WHEN OTHERS THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table');
      RETURN FALSE;

END Calculate_Sum_Table;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Calculate_Sum_Table_AT
+============================================================================*/
FUNCTION Calculate_Sum_Table_AT(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Calculate_Sum_Table(x_sum_table);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Calculate_Sum_Table_AT;

/*===========================================================================+
| FUNCTION Calculate_Sum_Table_MV
+============================================================================*/
FUNCTION Calculate_Sum_Table_MV(
	x_sum_table IN VARCHAR2,
	x_calculated_sys_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_calculated_sys_tables IN NUMBER,
	x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_system_tables IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_b BOOLEAN;

    h_current_fy NUMBER;

    h_origin_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_origin_tables NUMBER;

    h_origin_period NUMBER;
    h_origin_periodicity NUMBER;

    h_period NUMBER;
    h_periodicity NUMBER;

    -- Generation type: Total or balance
    h_generation_type NUMBER;

    -- Data columns information
    h_data_columns  	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_formulas 	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_data_proj_methods BSC_UPDATE_UTIL.t_array_of_number;
    h_data_measure_types BSC_UPDATE_UTIL.t_array_of_number;
    h_num_data_columns  NUMBER;

    -- Key column information
    h_key_columns	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns	NUMBER;

    -- Key column information for the origin tables
    -- All origin tables have the same dissagregation
    h_key_columns_ori		BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables_ori	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns_ori	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables_ori	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns_ori	NUMBER;

    -- Projection flag
    h_projection_flag VARCHAR2(3);

    -- Number of year and previous years of the table
    h_num_of_years NUMBER;
    h_previous_years NUMBER;

    -- Zero code calculation method
    h_zero_code_calc_method NUMBER;

    h_calendar_id NUMBER;
    h_calendar_edw_flag NUMBER;
    h_yearly_flag NUMBER;
    h_start_year NUMBER;
    h_end_year NUMBER;

    h_mv_name VARCHAR2(30);
    e_error_refresh EXCEPTION;
    e_error_refresh_zero EXCEPTION;
    h_error_refresh VARCHAR2(2000);

    CURSOR c_pt_name (p_sum_table VARCHAR2) IS
        SELECT DISTINCT projection_data
        FROM bsc_kpi_data_tables
        WHERE table_name = p_sum_table;

    h_pt_name VARCHAR2(30);
    h_process_pt BOOLEAN;
    h_origin_pt_name VARCHAR2(30);
    h_origin_pts BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_origin_pts NUMBER;

    CURSOR c_other_tables (p_pt_name VARCHAR2, p_table_name VARCHAR2) IS
        SELECT DISTINCT kt.table_name, t.project_flag
        FROM bsc_kpi_data_tables kt, bsc_db_tables t
        WHERE kt.projection_data = p_pt_name AND
              kt.table_name <> p_table_name AND
              kt.table_name = t.table_name;

    h_other_table_name VARCHAR2(30);
    h_other_project_flag NUMBER;

    h_i NUMBER;
    h_j NUMBER;

    TYPE t_pt_periodicity IS RECORD (
        periodicity_id NUMBER,
        yearly_flag NUMBER,
        current_period NUMBER,
        source_periodicity NUMBER,
        source_current_period NUMBER,
        calculated BOOLEAN
    );

    TYPE t_array_pt_periodicities IS TABLE OF t_pt_periodicity
        INDEX BY BINARY_INTEGER;

    h_arr_pt_periodicities t_array_pt_periodicities;
    h_num_pt_periodicities NUMBER;

    CURSOR c_pt_periodicities (p_pt_name VARCHAR2) IS
        SELECT DISTINCT p.periodicity_id, p.yearly_flag, t.current_period
        FROM bsc_kpi_data_tables kt, bsc_sys_periodicities p, bsc_db_tables t
        WHERE kt.projection_data = p_pt_name AND
              kt.periodicity_id = p.periodicity_id AND
              kt.table_name = t.table_name;

    h_periodicity_id NUMBER;
    h_current_period NUMBER;

    h_exit_cond BOOLEAN;
    h_can_calculate BOOLEAN;

    h_project_flag NUMBER;

BEGIN
    h_num_origin_tables := 0;
    h_num_data_columns := 0;
    h_num_key_columns := 0;
    h_num_key_columns_ori := 0;
    h_projection_flag := 'NO';
    h_yearly_flag := 0;
    h_pt_name := NULL;
    h_origin_pt_name := NULL;
    h_num_origin_pts := 0;
    h_num_pt_periodicities := 0;


    -- Initialize the array h_origin_tables with the tables from where
    -- the summary table is generated. There is at least one origin table.
    IF NOT Get_Origin_Tables(x_sum_table, h_origin_tables, h_num_origin_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the minimum period of the origin tables
    h_origin_period := Get_Minimun_Origin_Period(h_origin_tables, h_num_origin_tables);
    IF h_origin_period IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the origin tables.
    -- If a summary table comes from several tables, all origin tables have the
    -- same periodicity
    h_origin_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(h_origin_tables(1));
    IF h_origin_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the summary table
    h_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_sum_table);
    IF h_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the calendar id of the summary table
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(h_periodicity);
    h_calendar_edw_flag := BSC_UPDATE_UTIL.Get_Calendar_EDW_Flag(h_calendar_id);

    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

    -- Get the number of years and previous years of the table
    IF NOT BSC_UPDATE_UTIL.Get_Table_Range_Of_Years(x_sum_table, h_num_of_years, h_previous_years) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Calculate the current period of summary table
    h_period := Calculate_Period_Summary_Table(h_periodicity,
                                               h_origin_periodicity,
                                               h_origin_period,
                                               h_current_fy);
    IF h_period IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Retrieve information of summary table to be processed

    -- BSC-MV Note: In this architecture none of the summary tables exists and
    -- generation type is always -1. For now this property is not used in this procedure.

    -- BSC-MV Note: All summary tables are implemented as MV/Views
    -- We need to refresh the MV corresponding to this summary table
    -- Make sure to refresh the MV only one time. Remember that same MV
    -- has data for different periodicities.
    -- Note: The api to refresh the MV does not fail if the MV does not exists
    -- or if the MV is actually a normal view
    h_mv_name := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(x_sum_table);
    IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_mv_name,
                                                         g_refreshed_mvs,
                                                         g_num_refreshed_mvs) THEN

        IF NOT BSC_BIA_WRAPPER.Refresh_Summary_MV(h_mv_name, h_error_refresh) THEN
            RAISE e_error_refresh;
        END IF;
        COMMIT;

        -- Also refresh the MV created for zero code (if it exists)
        IF NOT Refresh_Zero_MVs(x_sum_table, h_mv_name, h_error_refresh) THEN
            RAISE e_error_refresh_zero;
        END IF;
        COMMIT;

        -- Add mv to array of refreshed mvs
        g_num_refreshed_mvs := g_num_refreshed_mvs + 1;
        g_refreshed_mvs(g_num_refreshed_mvs) := h_mv_name;
    END IF;

    -- Store the update period of summary table
    UPDATE
        bsc_db_tables
    SET
        current_period = h_period
    WHERE
        table_name = x_sum_table;
    COMMIT;

    -- BSC-MV Note: In this architecture we create projection tables
    -- for Targets at different level. This tables will store the projection
    -- at Kpi level.

    -- Check if the table has a projection table (PT table) and
    -- see if we need to process it (the PT table is processed only one time,
    -- remember that the same PT table can correspond to multiple
    -- summary tables)
    -- Also, the Projection Table must be processed only when all other summary
    -- tables for the same Projection Table has been calcualted. We need that
    -- the current period had been updated before we can calculate the projection.
    h_process_pt := FALSE;
    OPEN c_pt_name(x_sum_table);
    FETCH c_pt_name INTO h_pt_name;
    IF c_pt_name%NOTFOUND THEN
        h_pt_name := NULL;
    END IF;
    CLOSE c_pt_name;

    IF h_pt_name IS NOT NULL THEN
        -- We can calculate the Projection Table only when all other
        -- summary tables associated to the PT table has been calculated before

        h_process_pt := TRUE;

        -- Get the projection flag of this table
        SELECT project_flag INTO h_project_flag
        FROM bsc_db_tables
        WHERE table_name = x_sum_table;

        IF h_project_flag = 1 THEN
            h_projection_flag := 'YES';
        ELSE
            h_projection_flag := 'NO';
        END IF;

        OPEN c_other_tables(h_pt_name, x_sum_table);
        LOOP
            FETCH c_other_tables INTO h_other_table_name, h_other_project_flag;
            EXIT WHEN c_other_tables%NOTFOUND;

            -- If at least one of the tables needs projection, then we calcualte projection
            -- for all the periodicities
            IF h_other_project_flag = 1 THEN
                h_projection_flag := 'YES';
            END IF;

            IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_other_table_name,
                                                             x_system_tables,
                                                             x_num_system_tables) THEN
                -- The other table was or is going to be calculated in this process
                -- Now check that it was already calculated
                IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_other_table_name,
	    						             x_calculated_sys_tables,
							             x_num_calculated_sys_tables) THEN
                    -- The other table has not been calculated, so we cannot process the PT
                    -- table right now
                    h_process_pt := FALSE;
                    EXIT;
                END IF;
            END IF;
        END LOOP;
        CLOSE c_other_tables;
    END IF;

    IF h_process_pt THEN
        -- Information of data columns of summary table
        IF NOT BSC_UPDATE_UTIL.Get_Information_Data_Columns(x_sum_table,
                                                            h_data_columns,
                                                            h_data_formulas,
                                                            h_data_proj_methods,
                                                            h_data_measure_types,
                                                            h_num_data_columns) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Information of key columns of summary table
        IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(x_sum_table,
                                                           h_key_columns,
                                                           h_key_dim_tables,
                                                           h_source_columns,
                                                           h_source_dim_tables,
                                                           h_num_key_columns) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Information of key columns of origin tables
        -- All origin tables have the same dissagregation
        -- I just need the array h_key_columns_ori.
        IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(h_origin_tables(1),
                                                           h_key_columns_ori,
                                                           h_key_dim_tables_ori,
                                                           h_source_columns_ori,
                                                           h_source_dim_tables_ori,
                                                           h_num_key_columns_ori) THEN
            RAISE e_unexpected_error;
        END IF;

        IF h_projection_flag = 'NO' THEN
            -- Rollup the projection table
            -- We know that there is no change of periodicity, all periodicities are in the table
            -- just consider PERIODICITY_TYPE and PERIOD_TYPE_ID as other two key columns...

            -- Get the origin projection table name
            -- By design there is only one origin projection table
            OPEN c_pt_name(h_origin_tables(1));
            FETCH c_pt_name INTO  h_origin_pt_name;
            IF c_pt_name%NOTFOUND THEN
                 h_origin_pt_name := NULL;
            END IF;
            CLOSE c_pt_name;

            IF h_origin_pt_name IS NOT NULL THEN
                h_origin_pts(1) := h_origin_pt_name;
                h_num_origin_pts := 1;

                -- Fix bug#4177794. Need to pass h_period
                IF NOT Calculate_Sum_Table_Total(h_pt_name,
                                                 h_key_columns,
                                                 h_key_dim_tables,
                                                 h_source_columns,
                                                 h_source_dim_tables,
                                                 h_num_key_columns,
                                                 h_data_columns,
                                                 h_data_formulas,
                                                 h_data_measure_types,
                                                 h_num_data_columns,
                                                 h_origin_pts,
                                                 h_num_origin_pts,
                                                 h_key_columns_ori,
                                                 h_num_key_columns_ori,
                                                 h_periodicity,
                                                 h_origin_periodicity,
                                                 h_period,
                                                 h_origin_period,
                                                 h_current_fy) THEN
                    RAISE e_unexpected_error;
                END IF;
                COMMIT;
            END IF;
        ELSE
            -- BSC-MV Note: Need to calculate projection in the projection table for all the periodicities.
            -- For new architecture, we need to calculate projection
            -- before calculate the zero codes. Merging the targets already happened in the MV

            -- We need to calcualte the projection on base periodicities. In a PT table
            -- there can be multiple base periodicities Example Montlhy and Weekly. For
            -- higer periodicities we rollup the projection.
            -- We always calculate projection on yearly periodicity.
            -- The projection calculation must be in order. Fisrt the base periodicities
            -- and the the others.

            -- Truncate the table
            BSC_UPDATE_UTIL.Truncate_Table(h_pt_name);

            -- Initilize a global array with the relations between periodicities
            IF NOT BSC_UPDATE_UTIL.Load_Periodicity_Rels THEN
                RAISE e_unexpected_error;
            END IF;

            -- Get all the periodicities of the PT table
            OPEN c_pt_periodicities(h_pt_name);
            LOOP
                FETCH c_pt_periodicities INTO h_periodicity_id, h_yearly_flag, h_current_period;
                EXIT WHEN c_pt_periodicities%NOTFOUND;

                h_num_pt_periodicities := h_num_pt_periodicities + 1;
                h_arr_pt_periodicities(h_num_pt_periodicities).periodicity_id := h_periodicity_id;
                h_arr_pt_periodicities(h_num_pt_periodicities).yearly_flag := h_yearly_flag;
                h_arr_pt_periodicities(h_num_pt_periodicities).current_period := h_current_period;
                h_arr_pt_periodicities(h_num_pt_periodicities).source_periodicity := NULL;
                h_arr_pt_periodicities(h_num_pt_periodicities).source_current_period := NULL;
                h_arr_pt_periodicities(h_num_pt_periodicities).calculated := FALSE;
            END LOOP;
            CLOSE c_pt_periodicities;

            -- Get the source periodicity and source current period of each periodicity.
            FOR h_i IN 1..h_num_pt_periodicities LOOP
                FOR h_j IN 1..h_num_pt_periodicities LOOP
                    IF h_i <> h_j THEN
                        IF BSC_UPDATE_UTIL.Exist_Periodicity_Rel(h_arr_pt_periodicities(h_i).periodicity_id,
                                                                 h_arr_pt_periodicities(h_j).periodicity_id) THEN
                            h_arr_pt_periodicities(h_i).source_periodicity := h_arr_pt_periodicities(h_j).periodicity_id;
                            h_arr_pt_periodicities(h_i).source_current_period := h_arr_pt_periodicities(h_j).current_period;
                        END IF;
                    END IF;
                END LOOP;
            END LOOP;

            -- Calculate the projection in order
            --ENH_PROJECTION_4235711: We can only truncate the projection table here
            BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJ_CALC');
            LOOP
                FOR h_i IN 1..h_num_pt_periodicities LOOP
                    IF NOT h_arr_pt_periodicities(h_i).calculated THEN
                        IF (h_arr_pt_periodicities(h_i).yearly_flag = 1) OR
                           (h_arr_pt_periodicities(h_i).source_periodicity IS NULL) THEN
                            -- The periodicity is yearly or it is a base periodicity
                            -- Calculate projection for this periodicity
                            IF NOT BSC_UPDATE_CALC.Create_Proj_Temps(h_arr_pt_periodicities(h_i).periodicity_id,
  		    		                                     h_current_fy,
					                 	     h_num_of_years,
						                     h_previous_years,
                                                                     FALSE) THEN
                                RAISE e_unexpected_error;
                            END IF;

                            -- AW_INTEGRATION: Pass FALSE to x_aw_flag and change vector parameter. This is not for AW
                            IF NOT BSC_UPDATE_CALC.Calculate_Projection(h_pt_name,
	    			              		                h_arr_pt_periodicities(h_i).periodicity_id,
 						                        h_arr_pt_periodicities(h_i).current_period,
						                        h_key_columns,
						                        h_num_key_columns,
						                        h_data_columns,
						                        h_data_proj_methods,
						                        h_num_data_columns,
						                        h_current_fy,
						                        h_num_of_years,
						                        h_previous_years,
						                        FALSE,
                                                                        FALSE,
                                                                        NULL) THEN
                                RAISE e_unexpected_error;
                            END IF;
                            COMMIT;

                            h_arr_pt_periodicities(h_i).calculated := TRUE;
                        ELSE
                            -- The projection of this periodicity is calculated by rolling
                            -- up from the source periodicity

                            -- We can calculate it now only if the source periodicity is already calculated
                            h_can_calculate := FALSE;
                            FOR h_j IN 1..h_num_pt_periodicities LOOP
                                IF h_arr_pt_periodicities(h_j).periodicity_id =  h_arr_pt_periodicities(h_i).source_periodicity THEN
                                    IF h_arr_pt_periodicities(h_j).calculated THEN
                                        h_can_calculate := TRUE;
                                    END IF;
                                END IF;
                            END LOOP;

                            IF h_can_calculate THEN
                                IF NOT BSC_UPDATE_CALC.Create_Proj_Temps(h_arr_pt_periodicities(h_i).periodicity_id,
  	    	    		                                         h_current_fy,
					                 	         h_num_of_years,
						                         h_previous_years,
                                                                         FALSE) THEN
                                    RAISE e_unexpected_error;
                                END IF;

                                --ENH_PROJECTION_4235711: no need to pass table name
                                IF NOT BSC_UPDATE_CALC.Rollup_Projection(
     	                                           h_arr_pt_periodicities(h_i).periodicity_id,
 			                           h_arr_pt_periodicities(h_i).current_period,
                                                   h_arr_pt_periodicities(h_i).source_periodicity,
                                                   h_arr_pt_periodicities(h_i).source_current_period,
			                           h_key_columns,
			                           h_num_key_columns,
			                           h_data_columns,
                                                   h_data_formulas,
                                                   h_data_measure_types,
			                           h_num_data_columns,
			                           h_current_fy,
                                                   FALSE) THEN
                                    RAISE e_unexpected_error;
                                END IF;
                                COMMIT;

                                h_arr_pt_periodicities(h_i).calculated := TRUE;
                            END IF;
                        END IF;
                    END IF;
                END LOOP;

                -- Check if all the periodicities has been calculated
                h_exit_cond := TRUE;
                FOR h_i IN 1..h_num_pt_periodicities LOOP
                    IF NOT h_arr_pt_periodicities(h_i).calculated THEN
                        h_exit_cond := FALSE;
                    END IF;
                END LOOP;

                EXIT WHEN h_exit_cond;
            END LOOP;

            --ENH_PROJECTION_4235711: Merge projection into the PT table. Projection is calculated
            --in BSC_TMP_PROJ_CALC
            IF NOT BSC_UPDATE_CALC.Merge_Projection(h_pt_name,
                                    h_key_columns,
                                    h_num_key_columns,
                                    h_data_columns,
                                    h_num_data_columns,
                                    FALSE,
                                    FALSE) THEN
                RAISE e_unexpected_error;
            END IF;

            -- Fix bug#4463132: Truncate temporary table after use
            BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJ_CALC');
        END IF;

        -- BSC-MV Note: There is no need to calculate filters here. The MV already is filtered
        -- and there is no cases where the summary table is based on T or B tables.

        -- Calculate zero codes
        h_zero_code_calc_method := BSC_UPDATE_CALC.Get_Zero_Code_Calc_Method(x_sum_table);
        IF h_zero_code_calc_method IS NULL THEN
            RAISE e_unexpected_error;
        END IF;

        IF h_zero_code_calc_method <> 0 THEN
            IF h_projection_flag = 'YES' THEN
                -- BSC-MV Note: In this architecture if the projection table exists
                -- it is only to store projection at kpi level. If the table
                -- has projection it only contains data with no zero codes (from the MV)
                -- So in this case we can calcualte the zero code in all required keys.
                IF NOT BSC_UPDATE_CALC.Calculate_Zero_Code(x_sum_table,
		        			           h_zero_code_calc_method,
						           h_key_columns,
						           h_num_key_columns,
                                                           NULL) THEN
                    RAISE e_unexpected_error;
                END IF;
                COMMIT;
            ELSE
                -- BSC-MV Note: In this new architecture if the table exist and does not
                -- has projection, this table is to rollup projection to another level.
                -- In this case we need to check to avoid calculating zero code on keys
                -- that already has zero codes inherit from the source table.
                IF NOT BSC_UPDATE_CALC.Calculate_Zero_Code(x_sum_table,
		      			                   h_zero_code_calc_method,
						           h_key_columns,
						           h_num_key_columns,
                                                           h_origin_tables(1)) THEN
                    RAISE e_unexpected_error;
                END IF;
                COMMIT;
            END IF;
        END IF;

        -- Merge data from target tables
        -- BSC-MV Note: No need this calculation. Targets are already merged into the MV

        -- Calculate Profit
        --BSC-MV Note: In this architectute profit is calculated in the base tables
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_SUMTABLE_CALC_FAILED'),
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_MV');
      RETURN FALSE;

    WHEN e_error_refresh THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => 'BSC_BIA_WRAPPER.Refresh_Summary_MV '||h_mv_name||' '||h_error_refresh,
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_MV');
      RETURN FALSE;

    WHEN e_error_refresh_zero THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => 'BSC_UPDATE_SUM.Refresh_Zero_MVs '||h_mv_name||' '||h_error_refresh,
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_MV');
      RETURN FALSE;

    WHEN OTHERS THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_MV');
      RETURN FALSE;

END Calculate_Sum_Table_MV;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Calculate_Sum_Table_MV_AT
+============================================================================*/
FUNCTION Calculate_Sum_Table_MV_AT(
	x_sum_table IN VARCHAR2,
	x_calculated_sys_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_calculated_sys_tables IN NUMBER,
	x_system_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_system_tables IN NUMBER
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Calculate_Sum_Table_MV(x_sum_table, x_calculated_sys_tables, x_num_calculated_sys_tables,
                                  x_system_tables, x_num_system_tables);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Calculate_Sum_Table_MV_AT;


-- AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Calculate_Sum_Table_AW
+============================================================================*/
FUNCTION Calculate_Sum_Table_AW(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_current_fy NUMBER;
    h_origin_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_origin_tables NUMBER;
    h_origin_period NUMBER;
    h_origin_periodicity NUMBER;
    h_period NUMBER;
    h_periodicity NUMBER;
    h_calendar_id NUMBER;

BEGIN
    h_num_origin_tables := 0;

    -- AW_INTEGRATION: We only need to update the current period of the table

    -- Initialize the array h_origin_tables with the tables from where
    -- the summary table is generated. There is at least one origin table.
    IF NOT Get_Origin_Tables(x_sum_table, h_origin_tables, h_num_origin_tables) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the minimum period of the origin tables
    h_origin_period := Get_Minimun_Origin_Period(h_origin_tables, h_num_origin_tables);
    IF h_origin_period IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the origin tables.
    -- If a summary table comes from several tables, all origin tables have the
    -- same periodicity
    h_origin_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(h_origin_tables(1));
    IF h_origin_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the summary table
    h_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_sum_table);
    IF h_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(h_periodicity);

    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

    -- Calculate the current period of summary table
    h_period := Calculate_Period_Summary_Table(h_periodicity,
                                               h_origin_periodicity,
                                               h_origin_period,
                                               h_current_fy);
    IF h_period IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Store the update period of summary table
    UPDATE
        bsc_db_tables
    SET
        current_period = h_period
    WHERE
        table_name = x_sum_table;
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_SUMTABLE_CALC_FAILED'),
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_AW');
      RETURN FALSE;

    WHEN OTHERS THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_AW');
      RETURN FALSE;

END Calculate_Sum_Table_AW;

--LOCKING: New function
/*===========================================================================+
| FUNCTION Calculate_Sum_Table_AW_AT
+============================================================================*/
FUNCTION Calculate_Sum_Table_AW_AT(
	x_sum_table IN VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Calculate_Sum_Table_AW(x_sum_table);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Calculate_Sum_Table_AW_AT;


/*===========================================================================+
| FUNCTION Calculate_Sum_Table_Total
+============================================================================*/
FUNCTION Calculate_Sum_Table_Total(
        x_sum_table IN VARCHAR2,
        x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_source_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_source_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_data_columns IN NUMBER,
        x_origin_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_origin_tables IN NUMBER,
        x_key_columns_ori IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns_ori IN NUMBER,
        x_periodicity IN NUMBER,
        x_origin_periodicity IN NUMBER,
        x_period IN NUMBER,
        x_origin_period IN NUMBER,
        x_current_fy IN NUMBER) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);
    h_i NUMBER;
    h_j NUMBER;

    h_period_col_name VARCHAR2(30);
    h_origin_period_col_name VARCHAR2(30);
    h_period_map_table VARCHAR2(30);
    h_period_map_condition VARCHAR2(200);

    h_lst_key_columns VARCHAR2(32700);

    h_lst_data_columns VARCHAR2(32700);
    h_lst_data_formulas VARCHAR2(32700);

    h_lst_key_columns_ori VARCHAR2(32700);

    h_lst_from VARCHAR2(32700);
    h_lst_on VARCHAR2(32700);
    h_lst_where VARCHAR2(32700);

    h_lst_select_disag VARCHAR2(32700);
    h_lst_select_per VARCHAR2(32700);

    h_num_tot_data_columns NUMBER;
    h_lst_tot_data_columns VARCHAR2(32700);
    h_lst_tot_data_formulas VARCHAR2(32700);
    h_target_table_tot VARCHAR2(30);
    h_lst_from_tot VARCHAR2(32700);
    h_lst_on_tot VARCHAR2(32700);

    h_num_bal_data_columns NUMBER;
    h_lst_bal_data_columns VARCHAR2(32700);
    h_lst_bal_data_formulas VARCHAR2(32700);
    h_target_table_bal VARCHAR2(30);
    h_lst_from_bal VARCHAR2(32700);
    h_lst_on_bal VARCHAR2(32700);

    h_periodicity_edw_flag NUMBER;
    h_yearly_flag NUMBER;
    h_calendar_id NUMBER;

    h_union_table VARCHAR2(30);
    h_cond_zero_codes_src VARCHAR2(32000);

    -- Bind var fix for Posco
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    l_parallel_hint varchar2(20000);
    l_parallel_hint1 varchar2(20000);
    l_parallel_hint2 varchar2(20000);

    h_key_columns_ori_temp BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_key_columns_ori_temp VARCHAR2(32000);

    h_key VARCHAR(100);

    h_key_columns_temp BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_key_columns_temp VARCHAR2(32000);

    h_lst_tot_data_columns_temp VARCHAR2(32000);
    h_lst_bal_data_columns_temp VARCHAR2(32000);
    h_lst_tot_data_columns_temp_t VARCHAR2(32000);
    h_lst_bal_data_columns_temp_b VARCHAR2(32000);

    --Fix bug#3895181: Need the following 2 variables
    h_lst_tot_data_columns_temp_p VARCHAR2(32000);
    h_lst_tot_data_columns_p VARCHAR2(32000);

    -- ENH_B_TABLES_PERF: new variable
    h_origin_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_proj_table_name VARCHAR2(30);
    h_union_table_from VARCHAR2(32000);

BEGIN

    h_sql := NULL;
    h_lst_key_columns := NULL;
    h_lst_data_columns := NULL;
    h_lst_data_formulas := NULL;
    h_lst_key_columns_ori := NULL;
    h_lst_from := NULL;
    h_lst_on := NULL;
    h_lst_where := NULL;
    h_lst_select_disag := NULL;
    h_lst_select_per := NULL;
    h_num_tot_data_columns := 0;
    h_lst_tot_data_columns := NULL;
    h_lst_tot_data_formulas := NULL;
    h_target_table_tot := NULL;
    h_lst_from_tot := NULL;
    h_lst_on_tot := NULL;
    h_num_bal_data_columns := 0;
    h_lst_bal_data_columns := NULL;
    h_lst_bal_data_formulas := NULL;
    h_target_table_bal := NULL;
    h_lst_from_bal := NULL;
    h_lst_on_bal := NULL;
    h_periodicity_edw_flag := 0;
    h_yearly_flag := 0;
    h_union_table := NULL;
    h_cond_zero_codes_src := NULL;
    l_num_bind_vars := 0;
    h_lst_key_columns_temp := NULL;
    h_lst_tot_data_columns_temp := NULL;
    h_lst_bal_data_columns_temp := NULL;
    h_lst_tot_data_columns_temp_t := NULL;
    h_lst_bal_data_columns_temp_b := NULL;
    --Fix bug#3895181: Need the following 2 variables
    h_lst_tot_data_columns_temp_p := NULL;
    h_lst_tot_data_columns_p := NULL;

    -- New array used with generic temporary tables
    FOR h_i IN 1..x_num_key_columns_ori LOOP
        h_key_columns_ori_temp(h_i) := 'KEY'||h_i;
    END LOOP;
    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    -- Some information about the periodicity
    h_periodicity_edw_flag := BSC_UPDATE_UTIL.Get_Periodicity_EDW_Flag(x_periodicity);
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity);

    -- BSC-MV Note: In this architecture, the summary table is the projection table
    -- create for targets at different levels.
    -- It contains all periodicities and columns PERIODICITY_ID and PERIOD_TYPE_ID.
    -- We do not need to handle change of periodicity
    -- Also the origin table is also projection table with all the periodicities
    -- By design there is only one origin table

    IF NOT BSC_APPS.bsc_mv THEN
        -- Initialize some variables required only when there is change of periodicity
        -- to handle balance and total data columns
        IF x_periodicity <> x_origin_periodicity THEN
            -- Calculate the number of balance and total data columns
            -- By the way initialize arrays for total and balance data columns
            FOR h_i IN 1..x_num_data_columns LOOP
                IF x_data_measure_types(h_i) = 1 THEN
                    -- Total data column
                    h_num_tot_data_columns := h_num_tot_data_columns + 1;
                    IF h_num_tot_data_columns = 1 THEN
                        h_lst_tot_data_columns := x_data_columns(h_i);
                        h_lst_tot_data_columns_temp := 'DATA'||h_i;
                        h_lst_tot_data_columns_temp_t := 'T.DATA'||h_i;
                        h_lst_tot_data_formulas := x_data_formulas(h_i);
                        --Fix bug#3895181: Need the following 2 variables
                        h_lst_tot_data_columns_temp_p := 'P.DATA'||h_i;
                        h_lst_tot_data_columns_p := 'P.'||x_data_columns(h_i);
                    ELSE
                        h_lst_tot_data_columns := h_lst_tot_data_columns||', '||x_data_columns(h_i);
                        h_lst_tot_data_columns_temp := h_lst_tot_data_columns_temp||', DATA'||h_i;
                        h_lst_tot_data_columns_temp_t := h_lst_tot_data_columns_temp_t||', T.DATA'||h_i;
                        h_lst_tot_data_formulas := h_lst_tot_data_formulas||', '||x_data_formulas(h_i);
                        --Fix bug#3895181: Need the following 2 variables
                        h_lst_tot_data_columns_temp_p := h_lst_tot_data_columns_temp_p||', P.DATA'||h_i;
                        h_lst_tot_data_columns_p := h_lst_tot_data_columns_p||', P.'||x_data_columns(h_i);
                    END IF;
                ELSE
                    -- Balance data column
                    h_num_bal_data_columns := h_num_bal_data_columns + 1;
                    IF h_num_bal_data_columns = 1 THEN
                        h_lst_bal_data_columns := x_data_columns(h_i);
                        h_lst_bal_data_columns_temp := 'DATA'||h_i;
                        h_lst_bal_data_columns_temp_b := 'B.DATA'||h_i;
                        h_lst_bal_data_formulas := x_data_formulas(h_i);
                    ELSE
                        h_lst_bal_data_columns := h_lst_bal_data_columns||', '||x_data_columns(h_i);
                        h_lst_bal_data_columns_temp := h_lst_bal_data_columns_temp||', DATA'||h_i;
                        h_lst_bal_data_columns_temp_b := h_lst_bal_data_columns_temp_b||', B.DATA'||h_i;
                        h_lst_bal_data_formulas := h_lst_bal_data_formulas||', '||x_data_formulas(h_i);
                    END IF;
                END IF;
            END LOOP;

            -- Create a temporal table to make the change of periodicity between
            -- the origin tables and the summary table
            IF h_periodicity_edw_flag = 0 THEN
                -- BSC periodicity
                h_period_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);
                h_origin_period_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_origin_periodicity);
                h_period_map_table := 'bsc_db_calendar';
                h_period_map_condition := 'calendar_id = :1';
                l_bind_vars_values.delete;
                l_bind_vars_values(1) := h_calendar_id;
                l_num_bind_vars := 1;
            ELSE
                -- EDW periodicity
                h_period_col_name := 'BSC_TARGET';
                h_origin_period_col_name := 'BSC_SOURCE';
                h_period_map_table := 'bsc_edw_time_map';
                h_period_map_condition := NULL;
                l_bind_vars_values.delete;
                l_num_bind_vars := 0;
            END IF;

            IF h_num_tot_data_columns > 0 THEN
                -- Clean current records from bsc_tmp_per_change
                --h_sql := 'DELETE FROM bsc_tmp_per_change';
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
                BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE');

                IF h_yearly_flag <> 1 THEN
                    h_sql := 'INSERT /*+ append ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'parallel (bsc_tmp_per_change) ';
                    end if;
                    h_sql:=h_sql||' */';
                    h_sql:=h_sql||'INTO bsc_tmp_per_change (year, src_per, trg_per)'||
                           ' SELECT ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'/*+ parallel ('||h_period_map_table||')*/ ';
                    end if;
                    h_sql:=h_sql||
                        'DISTINCT year, '||h_origin_period_col_name||' AS src_per, '||
                         h_period_col_name||' AS trg_per'||
                         ' FROM '||h_period_map_table;

                    IF h_period_map_condition IS NOT NULL THEN
                        h_sql := h_sql||' WHERE '||h_period_map_condition;
                    END IF;
                ELSE
                    -- Anual periodicity
                    h_sql := 'INSERT  /*+ append ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'parallel (bsc_tmp_per_change) ';
                    end if;
                    h_sql:=h_sql||' */';
                    h_sql:=h_sql||'INTO bsc_tmp_per_change (year, src_per, trg_per)'||
                             ' SELECT ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'/*+ parallel ('||h_period_map_table||')*/ ';
                    end if;
                    h_sql:=h_sql||'DISTINCT year, '||h_origin_period_col_name||' AS src_per, 0 AS trg_per'||
                             ' FROM '||h_period_map_table;

                    IF h_period_map_condition IS NOT NULL THEN
                        h_sql := h_sql||' WHERE '||h_period_map_condition;
                    END IF;
                END IF;
                BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
                commit;
            END IF;

            IF h_num_bal_data_columns > 0 THEN
                -- Clean current records from bsc_tmp_per_change_bal
                --h_sql := 'DELETE FROM bsc_tmp_per_change_bal';
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
                BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE_BAL');

                IF h_yearly_flag <> 1 THEN
                    h_sql := 'INSERT /*+ append ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'parallel (bsc_tmp_per_change_bal) ';
                    end if;
                    h_sql:=h_sql||' */';
                    h_sql:=h_sql||'INTO bsc_tmp_per_change_bal (year, src_per, trg_per)'||
                              ' SELECT ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'/*+ parallel ('||h_period_map_table||')*/ ';
                    end if;
                    h_sql:=h_sql||'year, MAX('||h_origin_period_col_name||') AS src_per, '||h_period_col_name||' AS trg_per'||
                              ' FROM '||h_period_map_table;
                    IF h_period_map_condition IS NOT NULL THEN
                        h_sql := h_sql||' WHERE '||h_period_map_condition;
                    END IF;
                    h_sql := h_sql||' GROUP BY year, '||h_period_col_name;
                    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
                    commit;

                    l_bind_vars_values.delete;
                    l_bind_vars_values(1) := (x_origin_period);
                    l_bind_vars_values(2) := (x_current_fy) ;
                    l_bind_vars_values(3) := (x_origin_period);
                    l_bind_vars_values(4) := (x_current_fy);
                    l_num_bind_vars := 4;

                    h_sql := 'UPDATE bsc_tmp_per_change_bal'||
                             ' SET src_per = :1'||
                             ' WHERE year = :2'||
                             ' AND trg_per = ('||
                             ' SELECT '||h_period_col_name||
                             ' FROM '||h_period_map_table||
                             ' WHERE '||h_origin_period_col_name||' = :3'||
                             ' AND year = :4';
                    IF h_period_map_condition IS NOT NULL THEN
                        h_sql := h_sql||' AND '||h_period_map_condition;
                        l_bind_vars_values(5) := (h_calendar_id);
                        l_num_bind_vars := 5;
                    END IF;
                    h_sql := h_sql||' GROUP BY '||h_period_col_name||
                             ')';
                    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
                ELSE
                    -- Anual periodicity
                    h_sql := 'INSERT /*+ append ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'parallel (bsc_tmp_per_change_bal) ';
                    end if;
                    h_sql:=h_sql||' */';
                    h_sql:=h_sql||'INTO bsc_tmp_per_change_bal (year, src_per, trg_per)'||
                              ' SELECT ';
                    if BSC_UPDATE_UTIL.is_parallel then
                        h_sql:=h_sql||'/*+ parallel ('||h_period_map_table||')*/ ';
                    end if;
                    h_sql:=h_sql||'year, MAX('||h_origin_period_col_name||') AS src_per, 0 AS trg_per'||
                             ' FROM '||h_period_map_table;
                    IF h_period_map_condition IS NOT NULL THEN
                        h_sql := h_sql||' WHERE '||h_period_map_condition;
                    END IF;
                    h_sql := h_sql||' GROUP BY year';
                    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
                    commit;

                    l_bind_vars_values.delete;
                    l_bind_vars_values(1) := (x_origin_period);
                    l_bind_vars_values(2) := (x_current_fy);
                    l_num_bind_vars := 2;
                    h_sql := 'UPDATE bsc_tmp_per_change_bal'||
                             ' SET src_per = :1'||
                             ' WHERE year = :2';
                    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
                END IF;
            END IF;

            -- Create temporal tables to calculate total data columns and balance data columns separately
            -- and then merge them into the target summary table
            -- If all data columns are total or balance we dont need those temporal tables
            IF (h_num_tot_data_columns > 0) AND (h_num_bal_data_columns > 0) THEN
                -- BSC_TMP_TOT_DATA
                -- Clean temporal table
                --h_sql := 'DELETE FROM BSC_TMP_TOT_DATA';
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
                BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_DATA');

                h_target_table_tot := 'BSC_TMP_TOT_DATA';

                -- BSC_TMP_BAL_DATA
                -- Clean temporal table
                --h_sql := 'DELETE FROM BSC_TMP_BAL_DATA';
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
                BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BAL_DATA');

                h_target_table_bal := 'BSC_TMP_BAL_DATA';
            ELSE
                h_target_table_tot := x_sum_table;
                h_target_table_bal := x_sum_table;
            END IF;
        END IF;
    END IF;

    -- ENH_B_TABLES_PERF: If the origin table is a base table and the base table has a projection
    -- table then we need to do union all and that will be the origin table.
    -- I am going to initialize the array h_origin_tables with the proper origin and use it
    -- instead of x_origin_tables
    FOR h_i IN 1..x_num_origin_tables LOOP
        h_origin_tables(h_i) := x_origin_tables(h_i);
        IF NOT BSC_APPS.bsc_mv THEN
            IF BSC_UPDATE_UTIL.Is_Base_Table(x_origin_tables(h_i)) THEN
                h_proj_table_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(x_origin_tables(h_i));
                IF h_proj_table_name IS NOT NULL THEN
                    -- Base table is splitted in two: actuals and projection
                    -- Note that actual and projection table has the same structure
                    h_origin_tables(h_i) := '(SELECT * FROM '||x_origin_tables(h_i)||
                                            ' UNION ALL'||
                                            ' SELECT * FROM '||h_proj_table_name||
                                            ') '||x_origin_tables(h_i);
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- Create a temporal table bsc_tmp_union with all records from the origin tables
    -- Performance fix: Do not create BSC_TMP_UNION when the summary table is calculated
    -- from only one table.
    IF x_num_origin_tables > 1 THEN
        -- BSC-MV Note: By design this part is not executed because in this architecture
        -- there is only one origin table

        h_lst_key_columns_ori := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns_ori,
                                                                              x_num_key_columns_ori);
        h_lst_key_columns_ori_temp := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(h_key_columns_ori_temp,
                                                                                   x_num_key_columns_ori);
        IF h_lst_key_columns_ori IS NOT NULL THEN
            h_lst_key_columns_ori := h_lst_key_columns_ori||', ';
            h_lst_key_columns_ori_temp := h_lst_key_columns_ori_temp||', ';
        END IF;

        -- Clean temporary table
        --h_sql := 'DELETE FROM BSC_TMP_UNION';
        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_UNION');

        -- Insert data
        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
           h_sql:=h_sql||'parallel (BSC_TMP_UNION) ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO BSC_TMP_UNION ('||h_lst_key_columns_ori_temp||'YEAR, TYPE, PERIOD)'||
                 ' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
          h_sql:=h_sql||'/*+ parallel ('||x_origin_tables(1)||')*/ ';
        end if;
        -- ENH_B_TABLES_PERF: use h_origin_tables
        h_sql:=h_sql||h_lst_key_columns_ori||'YEAR, TYPE, PERIOD'||
                 ' FROM '||h_origin_tables(1);

        FOR h_i IN 2 .. x_num_origin_tables LOOP
            -- ENH_B_TABLES_PERF: use h_origin_tables
            h_sql := h_sql||' UNION'||
                     ' SELECT '||h_lst_key_columns_ori||'YEAR, TYPE, PERIOD'||
                     ' FROM '||h_origin_tables(h_i);
        END LOOP;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        commit;

        -- We need to delete (this is no the general case but in the future could happen)
        -- from BSC_TMP_UNION those rows with any zero code in the key columns that are
        -- not part of the target table.
        -- Example: Keys in the source tables: REG_CODE PROD_CODE
        --                                            1        0
        --                                            1        1
        --                                            1        2
        --          Keys in the target table:  REG_CODE
        --                                            1
        --          The total for REG_CODE 1 is PROD_CODE 1 + 2 (We cannot add the zero code
        --          because the total for REG_CODE 1 would be duplicated.

        -- BSC-BIS-DIMENSIONS: Need to use '0' in the condiction to be compatible with
        -- NUMBER of VARCHAR2 in the key columns

        h_lst_where := NULL;
        FOR h_i IN 1..x_num_key_columns_ori LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(x_key_columns_ori(h_i),
					                         x_source_columns,
							         x_num_key_columns) THEN
                IF h_lst_where IS NULL THEN
                    h_lst_where := h_key_columns_ori_temp(h_i)||' = ''0''';
                ELSE
                    h_lst_where := h_lst_where||' OR '||h_key_columns_ori_temp(h_i)||' = ''0''';
                END IF;
            END IF;
        END LOOP;
        IF h_lst_where IS NOT NULL THEN
            h_sql := 'DELETE FROM BSC_TMP_UNION'||
                     ' WHERE '||h_lst_where;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        END IF;

        -- ENH_B_TABLES_PERF: add this line, we need to differenciate between the name of the union
        -- table and the query for the union
        h_union_table_from := 'BSC_TMP_UNION';
        h_union_table := 'BSC_TMP_UNION';
    ELSE
        -- ENH_B_TABLES_PERF: add this line, we need to differenciate between the name of the union
        -- table and the query for the union
        h_union_table_from := h_origin_tables(1);
        h_union_table := x_origin_tables(1);

        -- We need to filter off any zero code in the key columns that are
        -- not part of the target table.
        -- Example: Keys in the source tables: REG_CODE PROD_CODE
        --                                            1        0
        --                                            1        1
        --                                            1        2
        --          Keys in the target table:  REG_CODE
        --                                            1
        --          The total for REG_CODE 1 is PROD_CODE 1 + 2 (We cannot add the zero code
        --          because the total for REG_CODE 1 would be duplicated.

        -- BSC-BIS-DIMENSIONS: Need to use '0' in the condiction to be compatible with
        -- NUMBER of VARCHAR2 in the key columns

        h_cond_zero_codes_src := NULL;
        FOR h_i IN 1..x_num_key_columns_ori LOOP
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(x_key_columns_ori(h_i),
					                         x_source_columns,
							         x_num_key_columns) THEN
                IF h_cond_zero_codes_src IS NULL THEN
                    h_cond_zero_codes_src := x_key_columns_ori(h_i)||' <> ''0''';
                ELSE
                    h_cond_zero_codes_src := h_cond_zero_codes_src||' AND '||x_key_columns_ori(h_i)||' <> ''0''';
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- create the string for FROM sub-statement
    -- ENH_B_TABLES_PERF: use h_union_table_from
    h_lst_from := h_union_table_from;
    l_parallel_hint:=l_parallel_hint||' parallel ('||h_union_table||')';

    IF x_num_origin_tables > 1 THEN
        -- BSC-MV Note: By design this part is not executed because in this architecture
        -- there is only one origin table

        FOR h_i IN 1 .. x_num_origin_tables LOOP
            -- ENH_B_TABLES_PERF: use h_origin_tables
            h_lst_from := h_lst_from||', '||h_origin_tables(h_i);
            l_parallel_hint:=l_parallel_hint||' parallel ('||x_origin_tables(h_i)||')';
            IF h_lst_on IS NOT NULL THEN
                h_lst_on := h_lst_on||' AND ';
            END IF;
            IF x_num_key_columns_ori > 0 THEN
               h_lst_on := h_lst_on||
                            BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join('BSC_TMP_UNION',
                                                                    h_key_columns_ori_temp,
                                                                    x_origin_tables(h_i),
                                                                    x_key_columns_ori,
                                                                    x_num_key_columns_ori,
                                                                    'AND')||
                            ' AND ';
            END IF;
            IF BSC_APPS.bsc_mv THEN
                h_lst_on := h_lst_on||'BSC_TMP_UNION.PERIODICITY_ID = '||x_origin_tables(h_i)||'.PERIODICITY_ID (+) AND ';
            END IF;
            h_lst_on := h_lst_on||'BSC_TMP_UNION.YEAR = '||x_origin_tables(h_i)||'.YEAR (+)'||
                        ' AND '||'BSC_TMP_UNION.TYPE = '||x_origin_tables(h_i)||'.TYPE (+)'||
                        ' AND '||'BSC_TMP_UNION.PERIOD = '||x_origin_tables(h_i)||'.PERIOD (+)';
        END LOOP;
    ELSE
        h_lst_on := h_cond_zero_codes_src;
    END IF;

    -- Initialize some lists that will be part of the query to generate the summary table
    h_lst_key_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    h_lst_key_columns_temp := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(h_key_columns_temp, x_num_key_columns);

    IF h_lst_key_columns IS NOT NULL THEN
        h_lst_key_columns := h_lst_key_columns||', ';
        h_lst_key_columns_temp := h_lst_key_columns_temp||', ';
    END IF;

    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);
    h_lst_data_formulas := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_formulas, x_num_data_columns);

    -- Delete all records of summary table.
    BSC_UPDATE_UTIL.Truncate_Table(x_sum_table);

    -- Disable indexes for improve performance
    IF NOT BSC_UPDATE_UTIL.Drop_Index(x_sum_table||'_U1') THEN
        RAISE e_unexpected_error;
    END IF;

    -- Create the string for the SELECT and FROM sub-statement
    FOR h_i IN 1 .. x_num_key_columns LOOP
        IF h_i > 1 THEN
            h_lst_select_disag := h_lst_select_disag||', ';
        END IF;

        IF x_num_origin_tables > 1 THEN
            --Get KEY column of BSC_TMP_UNION that correspond to x_source_columns(h_i)
            FOR h_j IN 1..x_num_key_columns_ori LOOP
                IF x_key_columns_ori(h_j) = x_source_columns(h_i) THEN
                    h_key := 'KEY'||h_j;
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            h_key := x_source_columns(h_i);
        END IF;

        IF x_key_columns(h_i) = x_source_columns(h_i) THEN
            -- There is no change of dissagregation for this key

            -- BSC-BIS-DIMENSIONS Note: From now on, even if there is no change of dissagregation
            -- we are going to join to the dimension table to make sure that we do not pass
            -- rows corresponding to items that were deleted from the dimension.
            -- This is implemeted no matter if the dimension is BSC of BIS.

            --h_lst_select_disag := h_lst_select_disag||h_union_table||'.'||h_key;
            h_lst_select_disag := h_lst_select_disag||x_source_dim_tables(h_i)||'.CODE';
            h_lst_from := h_lst_from||', '||x_source_dim_tables(h_i);
            l_parallel_hint:=l_parallel_hint||' parallel ('||x_source_dim_tables(h_i)||')';

            IF h_lst_on IS NOT NULL THEN
                h_lst_on := h_lst_on||' AND ';
            END IF;
            h_lst_on := h_lst_on||h_union_table||'.'||h_key||' = '||x_source_dim_tables(h_i)||'.CODE';

        ELSE
            -- There is change of dissagregation for this key
            h_lst_select_disag := h_lst_select_disag||x_source_dim_tables(h_i)||'.'||x_key_columns(h_i);
            h_lst_from := h_lst_from||', '||x_source_dim_tables(h_i);
            l_parallel_hint:=l_parallel_hint||' parallel ('||x_source_dim_tables(h_i)||')';

            IF h_lst_on IS NOT NULL THEN
                h_lst_on := h_lst_on||' AND ';
            END IF;
            h_lst_on := h_lst_on||h_union_table||'.'||h_key||' = '||x_source_dim_tables(h_i)||'.CODE';
        END IF;
    END LOOP;

    IF h_lst_select_disag IS NOT NULL THEN
        h_lst_select_disag := h_lst_select_disag||', ';
    END IF;

    -- Create the string for the SELECT and FROM sub-statement when there is periodicity change.
    IF (BSC_APPS.bsc_mv) OR (x_periodicity = x_origin_periodicity) THEN
        -- BSC-MV Note: In this architecture there is no change of periodicity

        -- There is no change of periodicity
        h_lst_select_per := h_union_table||'.YEAR, '||h_union_table||'.TYPE, '||h_union_table||'.PERIOD';

        -- Generates the summary table
        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
          h_sql:=h_sql||'parallel ('||x_sum_table||') ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO '||x_sum_table;
        IF BSC_APPS.bsc_mv THEN
            h_sql := h_sql||' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD, PERIODICITY_ID, PERIOD_TYPE_ID, '||
                     h_lst_data_columns||')';
        ELSE
            h_sql := h_sql||' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||
                     h_lst_data_columns||')';
        END IF;
        h_sql := h_sql||' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
          h_sql:=h_sql||'/*+'||l_parallel_hint||'*/ ';
        end if;
        h_sql := h_sql||h_lst_select_disag||h_lst_select_per;
        IF BSC_APPS.bsc_mv THEN
            h_sql := h_sql||', '||h_union_table||'.PERIODICITY_ID, '||h_union_table||'.PERIOD_TYPE_ID';
        END IF;
        h_sql := h_sql||', '||h_lst_data_formulas||
                 ' FROM '||h_lst_from;
        IF h_lst_on IS NOT NULL THEN
           h_sql := h_sql||
                 ' WHERE '||h_lst_on;
        END IF;
        h_sql := h_sql||
                 ' GROUP BY '||h_lst_select_disag||h_lst_select_per;
        IF BSC_APPS.bsc_mv THEN
            h_sql := h_sql||', '||h_union_table||'.PERIODICITY_ID, '||h_union_table||'.PERIOD_TYPE_ID';
        END IF;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        COMMIT;

        -- Enable indexes
        IF BSC_APPS.bsc_mv THEN
            IF NOT BSC_UPDATE_UTIL.Create_Unique_Index(x_sum_table,
                                                       x_sum_table||'_U1',
                                                      h_lst_key_columns||
                                                      'YEAR, TYPE, PERIOD, PERIODICITY_ID, PERIOD_TYPE_ID',
                                                       BSC_APPS.summary_index_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;
        ELSE
            IF NOT BSC_UPDATE_UTIL.Create_Unique_Index(x_sum_table,
                                                       x_sum_table||'_U1',
                                                      h_lst_key_columns||'YEAR, TYPE, PERIOD',
                                                      BSC_APPS.summary_index_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;

    ELSE
        -- There is periodicity change
        -- Note: We suppose that the change of periodicity is allowed
        -- (see bsc_sys_periodicites)
        IF h_num_tot_data_columns > 0 THEN
            --Fix bug#4177794: Loader is not fixing correctly the real value for the
            -- current period. I am changing this code. The change is also a better
            -- approach for perfomance.
            -- We need to do this because we dont want to show the wrong value
            -- because projection in the origin tables.

            h_lst_from_tot := h_lst_from||', BSC_TMP_PER_CHANGE';
            l_parallel_hint1:=l_parallel_hint||' parallel (BSC_TMP_PER_CHANGE)';
            IF h_lst_on IS NOT NULL THEN
                h_lst_on_tot := h_lst_on||' AND ';
            END IF;
            h_lst_on_tot := h_lst_on_tot||h_union_table||'.YEAR = BSC_TMP_PER_CHANGE.YEAR'||
                            ' AND '||h_union_table||'.PERIOD = BSC_TMP_PER_CHANGE.SRC_PER';

            h_lst_select_per :=  h_union_table||'.YEAR, '||h_union_table||'.TYPE, BSC_TMP_PER_CHANGE.TRG_PER';

            -- First, insert the rows for real data of current. We do not take into account projection
            h_lst_where := '('||h_union_table||'.YEAR = :1'||
                           ' AND '||h_union_table||'.TYPE = :2 '||
                           ' AND '||h_union_table||'.PERIOD <= :3)';

            l_bind_vars_values.delete;
            l_bind_vars_values(1) := x_current_fy ;
            l_bind_vars_values(2) := 0 ;
            l_bind_vars_values(3) := x_origin_period ;
            l_num_bind_vars := 3;

            h_sql := 'INSERT /*+ append ';
            if BSC_UPDATE_UTIL.is_parallel then
             h_sql:=h_sql||'parallel ('||h_target_table_tot||') ';
            end if;
            h_sql:=h_sql||' */';
            h_sql:=h_sql||'INTO '||h_target_table_tot;
            IF h_target_table_tot = 'BSC_TMP_TOT_DATA' THEN
                h_sql:=h_sql||' ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, '||h_lst_tot_data_columns_temp||')';
            ELSE
                h_sql:=h_sql||' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||h_lst_tot_data_columns||')';
            END IF;
            h_sql:=h_sql||' SELECT ';
            if BSC_UPDATE_UTIL.is_parallel then
             h_sql:=h_sql||'/*+'||l_parallel_hint1||'*/ ';
            end if;
            h_sql:=h_sql||h_lst_select_disag||h_lst_select_per||', '||h_lst_tot_data_formulas||
                     ' FROM '||h_lst_from_tot||
                     ' WHERE '||h_lst_on_tot||' AND '||h_lst_where||
                     ' GROUP BY '||h_lst_select_disag||h_lst_select_per;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
            commit;

            -- Now, insert rows for projection, previous year and other types
            IF h_yearly_flag <> 1 THEN
                h_lst_where := '(('||h_union_table||'.YEAR <> :1) OR'||
                               ' ('||h_union_table||'.YEAR = :2 AND '||h_union_table||'.TYPE <> :3) OR'||
                               ' ('||h_union_table||'.YEAR = :4 AND '||h_union_table||'.TYPE = :5 AND'||
                               ' BSC_TMP_PER_CHANGE.TRG_PER > :6))';

                l_bind_vars_values.delete;
                l_bind_vars_values(1) := x_current_fy;
                l_bind_vars_values(2) := x_current_fy;
                l_bind_vars_values(3) := 0;
                l_bind_vars_values(4) := x_current_fy;
                l_bind_vars_values(5) := 0;
                l_bind_vars_values(6) := x_period;
                l_num_bind_vars := 6;
            ELSE
                h_lst_where := '(('||h_union_table||'.YEAR <> :1) OR'||
                               ' ('||h_union_table||'.YEAR = :2 AND '||h_union_table||'.TYPE <> :3))';

                l_bind_vars_values.delete;
                l_bind_vars_values(1) := x_current_fy;
                l_bind_vars_values(2) := x_current_fy;
                l_bind_vars_values(3) := 0;
                l_num_bind_vars := 3;
            END IF;

            h_sql := 'INSERT /*+ append ';
            if BSC_UPDATE_UTIL.is_parallel then
             h_sql:=h_sql||'parallel ('||h_target_table_tot||') ';
            end if;
            h_sql:=h_sql||' */';
            h_sql:=h_sql||'INTO '||h_target_table_tot;
            IF h_target_table_tot = 'BSC_TMP_TOT_DATA' THEN
                h_sql:=h_sql||' ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, '||h_lst_tot_data_columns_temp||')';
            ELSE
                h_sql:=h_sql||' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||h_lst_tot_data_columns||')';
            END IF;
            h_sql:=h_sql||' SELECT ';
            if BSC_UPDATE_UTIL.is_parallel then
             h_sql:=h_sql||'/*+'||l_parallel_hint1||'*/ ';
            end if;
            h_sql:=h_sql||h_lst_select_disag||h_lst_select_per||', '||h_lst_tot_data_formulas||
                     ' FROM '||h_lst_from_tot||
                     ' WHERE '||h_lst_on_tot||' AND '||h_lst_where||
                     ' GROUP BY '||h_lst_select_disag||h_lst_select_per;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
            commit;

            -- Enable indexes
            IF h_target_table_tot <> 'BSC_TMP_TOT_DATA' THEN
                IF NOT BSC_UPDATE_UTIL.Create_Unique_Index(h_target_table_tot,
                                                           h_target_table_tot||'_U1',
                                                           h_lst_key_columns||'YEAR, TYPE, PERIOD',
                                                           BSC_APPS.summary_index_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;
            END IF;
        END IF;

        IF h_num_bal_data_columns > 0 THEN
            h_lst_from_bal := h_lst_from||', BSC_TMP_PER_CHANGE_BAL';
            l_parallel_hint2:=l_parallel_hint||' parallel (BSC_TMP_PER_CHANGE_BAL)';
            IF h_lst_on IS NOT NULL THEN
                h_lst_on_bal := h_lst_on||' AND ';
            END IF;
            h_lst_on_bal := h_lst_on_bal||h_union_table||'.YEAR = BSC_TMP_PER_CHANGE_BAL.YEAR'||
                        ' AND '||h_union_table||'.PERIOD = BSC_TMP_PER_CHANGE_BAL.SRC_PER';
            h_lst_select_per :=  h_union_table||'.YEAR, '||h_union_table||'.TYPE, BSC_TMP_PER_CHANGE_BAL.TRG_PER';

            -- Generates the summary table
            h_sql := 'INSERT /*+ append ';
            if BSC_UPDATE_UTIL.is_parallel then
              h_sql:=h_sql||'parallel ('||h_target_table_bal||') ';
            end if;
            h_sql:=h_sql||' */';
            h_sql:=h_sql||'INTO '||h_target_table_bal;
            IF h_target_table_bal = 'BSC_TMP_BAL_DATA' THEN
                h_sql:=h_sql||' ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, '||h_lst_bal_data_columns_temp||')';
            ELSE
                h_sql:=h_sql||' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||h_lst_bal_data_columns||')';
            END IF;
            h_sql := h_sql||' SELECT ';
            if BSC_UPDATE_UTIL.is_parallel then
               h_sql:=h_sql||'/*+'||l_parallel_hint2||'*/ ';
            end if;
            h_sql:=h_sql||h_lst_select_disag||h_lst_select_per||', '||h_lst_bal_data_formulas||
                     ' FROM '||h_lst_from_bal||
                     ' WHERE '||h_lst_on_bal||
                     ' GROUP BY '||h_lst_select_disag||h_lst_select_per;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
            commit;

            -- Enable indexes
            IF h_target_table_bal <> 'BSC_TMP_BAL_DATA' THEN
                IF NOT BSC_UPDATE_UTIL.Create_Unique_Index(h_target_table_bal,
                                                           h_target_table_bal||'_U1',
                                                           h_lst_key_columns||'YEAR, TYPE, PERIOD',
                                                           BSC_APPS.summary_index_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;
            END IF;
        END IF;

        IF (h_num_tot_data_columns > 0) AND (h_num_bal_data_columns > 0) THEN
            -- We need to merge BSC_TMP_TOT_DATA and BSC_TMP_BAL_DATA into the summary table
            -- Fix Bug#3131339 Do left join
            h_lst_on := BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join('T', h_key_columns_temp, 'B', h_key_columns_temp,
                                                                x_num_key_columns, 'AND');
            IF h_lst_on IS NOT NULL THEN
                h_lst_on := h_lst_on||' AND ';
            END IF;

            h_lst_select_disag := BSC_UPDATE_UTIL.Make_Lst_Table_Column('T', h_key_columns_temp, x_num_key_columns);
            IF h_lst_select_disag IS NOT NULL THEN
                h_lst_select_disag := h_lst_select_disag||', ';
            END IF;

            h_sql := 'INSERT /*+ append ';
            if BSC_UPDATE_UTIL.is_parallel then
              h_sql:=h_sql||'parallel ('||x_sum_table||') ';
            end if;
            h_sql:=h_sql||' */';
            h_sql:=h_sql||'INTO '||x_sum_table||
                     ' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||
                     h_lst_tot_data_columns||', '||h_lst_bal_data_columns||')'||
                     ' SELECT ';
            if BSC_UPDATE_UTIL.is_parallel then
              h_sql:=h_sql||'/*+ parallel (T) parallel (B)*/ ';
            end if;
            h_sql:=h_sql||h_lst_select_disag||'T.YEAR, T.TYPE, T.PERIOD, '||
                     h_lst_tot_data_columns_temp_t||', '||h_lst_bal_data_columns_temp_b||
                     ' FROM BSC_TMP_TOT_DATA T, BSC_TMP_BAL_DATA B'||
                     ' WHERE '||h_lst_on;
            h_sql := h_sql||'T.YEAR = B.YEAR (+) AND T.TYPE = B.TYPE (+) AND T.PERIOD = B.PERIOD (+)';
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
            commit;

            -- Enable indexes
            IF NOT BSC_UPDATE_UTIL.Create_Unique_Index(x_sum_table,
                                                       x_sum_table||'_U1',
                                                       h_lst_key_columns||'YEAR, TYPE, PERIOD',
                                                       BSC_APPS.summary_index_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;

        END IF;
    END IF;

    COMMIT;

    -- Fix bug#4463132: Truncate temporary table after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE_BAL');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_DATA');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BAL_DATA');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_UNION');
    commit;

    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_SUMTABLE_CALC_FAILED'),
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_Total');
      RETURN FALSE;

    WHEN OTHERS THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_SUM.Calculate_Sum_Table_Total');
      RETURN FALSE;

END Calculate_Sum_Table_Total;


/*===========================================================================+
| FUNCTION Get_Minimun_Origin_Period
+============================================================================*/
FUNCTION Get_Minimun_Origin_Period(
	x_origin_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_origin_tables IN NUMBER
        ) RETURN NUMBER IS

    h_table_name VARCHAR2(30);

    TYPE t_cursor IS REF CURSOR;

    /*
    c_current_period t_cursor; -- h_table_name
    c_current_period_sql VARCHAR2(2000) := 'SELECT NVL(current_period, 0)'||
                                           ' FROM bsc_db_tables'||
                                           ' WHERE table_name = :1';
    */

    h_current_period NUMBER;

    h_i NUMBER;
    h_ret NUMBER;

BEGIN

    -- there is at least one origin table

    h_table_name := x_origin_tables(1);
    /*
    OPEN c_current_period FOR c_current_period_sql USING h_table_name;
    FETCH c_current_period INTO h_current_period;
    IF c_current_period%NOTFOUND THEN
        h_current_period := 0;
    END IF;
    CLOSE c_current_period;
    */
    BEGIN
        SELECT NVL(current_period, 0)
        INTO h_current_period
        FROM bsc_db_tables
        WHERE table_name = h_table_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_current_period := 0;
    END;

    h_ret := h_current_period;


    FOR h_i IN 2 .. x_num_origin_tables LOOP
        h_table_name := x_origin_tables(h_i);

        /*
        OPEN c_current_period FOR c_current_period_sql USING h_table_name;
        FETCH c_current_period INTO h_current_period;
        IF c_current_period%NOTFOUND THEN
            h_current_period := 0;
        END IF;
        CLOSE c_current_period;
        */
        BEGIN
            SELECT NVL(current_period, 0)
            INTO h_current_period
            FROM bsc_db_tables
            WHERE table_name = h_table_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                h_current_period := 0;
        END;

        IF h_current_period < h_ret THEN
            h_ret := h_current_period;
        END IF;

    END LOOP;

    RETURN h_ret;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_SUM.Get_Minimun_Origin_Period');
        RETURN NULL;

END Get_Minimun_Origin_Period;


/*===========================================================================+
| FUNCTION Get_Origin_Tables
+============================================================================*/
FUNCTION Get_Origin_Tables(
	x_table_name IN VARCHAR2,
	x_origin_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_origin_tables IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_origin_tables t_cursor; -- x_table_name, 0
    c_origin_tables_sql VARCHAR2(2000) := 'SELECT source_table_name'||
                                          ' FROM bsc_db_tables_rels'||
                                          ' WHERE table_name = :1 AND relation_type = :2';
    */
    CURSOR c_origin_tables (p_table_name VARCHAR2, p_relation_type NUMBER) IS
        SELECT source_table_name
        FROM bsc_db_tables_rels
        WHERE table_name = p_table_name AND relation_type = p_relation_type;

    h_origin_table bsc_db_tables_rels.source_table_name%TYPE;

BEGIN
    --OPEN c_origin_tables FOR c_origin_tables_sql USING x_table_name, 0;
    OPEN c_origin_tables(x_table_name, 0);
    FETCH c_origin_tables INTO h_origin_table;
    WHILE c_origin_tables%FOUND LOOP
        x_num_origin_tables := x_num_origin_tables + 1;
        x_origin_tables(x_num_origin_tables) := h_origin_table;

        FETCH c_origin_tables INTO h_origin_table;
    END LOOP;
    CLOSE c_origin_tables;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_SUM.Get_Origin_Tables');
        RETURN FALSE;

END Get_Origin_Tables;


--LOCKING: New procedure
/*===========================================================================+
| PROCEDURE Refresh_AW_Kpi_AT
+============================================================================*/
PROCEDURE Refresh_AW_Kpi_AT (
    x_indicator IN NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_kpi_list dbms_sql.varchar2_table;
BEGIN
    -- Fix bug#5134927 verify the aw cubes exists for this kpi
    IF BSC_AW_MD_API.Is_Kpi_Present(x_indicator) THEN
       h_kpi_list.delete;
       h_kpi_list(1) := x_indicator;
       bsc_aw_load.load_kpi(
           p_kpi_list => h_kpi_list,
           p_options => 'DEBUG LOG'
       );
    END IF;

    commit; -- autonomous transactions need to commit
END Refresh_AW_Kpi_AT;


/*===========================================================================+
| FUNCTION Refresh_Zero_MVs
+============================================================================*/
FUNCTION Refresh_Zero_MVs(
	x_table_name IN VARCHAR2,
	x_mv_name IN VARCHAR2,
        x_error_message IN OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(2000);
    h_data_source_mv VARCHAR2(10);
    e_error_refresh EXCEPTION;
    h_zero_mv VARCHAR2(30);

BEGIN
    h_data_source_mv := 'MV';

    h_sql := 'SELECT DISTINCT mv_name'||
             ' FROM bsc_kpi_data_tables'||
             ' WHERE table_name = :1 AND data_source = :2'||
             ' AND mv_name <> :3';
    OPEN h_cursor FOR h_sql USING x_table_name, h_data_source_mv, x_mv_name;
    LOOP
        FETCH h_cursor INTO h_zero_mv;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT BSC_BIA_WRAPPER.Refresh_Summary_MV(h_zero_mv, x_error_message) THEN
            RAISE e_error_refresh;
        END IF;
        COMMIT;

    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN e_error_refresh THEN
        -- x_error_message should have the error
        RETURN FALSE;

    WHEN OTHERS THEN
        x_error_message := SQLERRM;
        RETURN FALSE;

END Refresh_Zero_MVs;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Refresh_Zero_MVs_AT
+============================================================================*/
FUNCTION Refresh_Zero_MVs_AT(
	x_table_name IN VARCHAR2,
	x_mv_name IN VARCHAR2,
        x_error_message IN OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Refresh_Zero_MVs(x_table_name, x_mv_name, x_error_message);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Refresh_Zero_MVs_AT;

END BSC_UPDATE_SUM;

/
