--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_BASE" AS
/* $Header: BSCDBASB.pls 120.6 2006/02/16 09:08 meastmon noship $ */

--
-- Global Variables
--

/*===========================================================================+
| FUNCTION Calc_New_Period_Base_Table
+============================================================================*/
FUNCTION Calc_New_Period_Base_Table(
	x_base_table IN VARCHAR2,
        x_periodicity_base_table IN NUMBER,
        x_periodicity_input_table IN NUMBER,
        x_current_fy IN NUMBER,
        x_per_input_table IN NUMBER,
        x_subper_input_table IN NUMBER,
        x_current_per_base_table OUT NOCOPY NUMBER,
        x_per_base_table OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

     TYPE t_cursor IS REF CURSOR;
     h_cursor t_cursor;

     h_sql VARCHAR2(32700);

     h_current_period NUMBER;
     h_calendar_id NUMBER;

     h_base_calendar_col_name VARCHAR2(30);
     h_input_calendar_col_name VARCHAR2(30);

     h_yearly_flag NUMBER;
     h_edw_flag NUMBER;

     h_periodicity_type_base_table NUMBER;
     h_periodicity_type_input_table NUMBER;

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

    IF x_periodicity_base_table = x_periodicity_input_table THEN
        -- There is no periodicity change. The period of the base table is
        -- the period of the input table.
        x_per_base_table := x_per_input_table;
    ELSE
        -- BSC-BIS-DIMENSIONS Note: We know that never there is change of periodicity
        -- between the input and the base table for BIS periodicities. So this code
        -- is only for BSC periodicities.

        -- There is periodicity change
        -- Note: We suppose that the change of periodicity is allowed
        -- (see bsc_sys_periodicites) plus:
        -- Always is possible to pass to Annual periodicity
        -- From periodicity type 12 (Month Day) is possible to pass to any periodicity
        -- From periodicity type 11 (Month Week) is possible to pass only to 7 (Week52)

        h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity_base_table);
        h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity_base_table);

        h_periodicity_type_input_table := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_periodicity_input_table);
        h_periodicity_type_base_table := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_periodicity_base_table);

        IF h_yearly_flag = 1 THEN
            -- The base table has annual periodicity
            -- The period of an annual table is the current fiscal year
            x_per_base_table := x_current_fy;

        ELSIF h_periodicity_type_base_table = 7 AND h_periodicity_type_input_table = 11 THEN
            -- The base table is Weekly52 and the input table is Month Week
            -- This is the special case that use bsc_db_week_maps table to make the
            -- transformation
            BEGIN
                SELECT week52
                INTO x_per_base_table
                FROM bsc_db_week_maps
                WHERE year = x_current_fy AND month = x_per_input_table AND
                      week = x_subper_input_table AND calendar_id = h_calendar_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_per_base_table := 0;
            END;

        ELSE
            -- Other periodicity changes
            h_edw_flag := BSC_UPDATE_UTIL.Get_Periodicity_EDW_Flag(x_periodicity_base_table);

            IF h_edw_flag = 0 THEN
                -- BSC periodicity

                -- Use bsc_db_calendar to make the transformation
                h_base_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity_base_table);

                IF h_periodicity_type_input_table = 12 THEN
                    -- The input table is Month-Day
                    h_sql := 'SELECT '||h_base_calendar_col_name||' '||
                             'FROM bsc_db_calendar '||
                             'WHERE year = :1 '||
                             'AND month = :2 '||
                             'AND day30 = :3 '||
                             'AND calendar_id = :4';
                    OPEN h_cursor FOR h_sql USING x_current_fy, x_per_input_table, x_subper_input_table, h_calendar_id;
                    FETCH h_cursor INTO x_per_base_table;
                    IF h_cursor%NOTFOUND THEN
                        x_per_base_table := 0;
                    END IF;
                    CLOSE h_cursor;
                ELSE
                    h_input_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity_input_table);
                    h_sql := 'SELECT MAX('||h_base_calendar_col_name||') '||
                             'FROM bsc_db_calendar '||
                             'WHERE year = :1 '||
                             'AND '||h_input_calendar_col_name||' = :2 '||
                             'AND calendar_id = :3';
                    OPEN h_cursor FOR h_sql USING x_current_fy, x_per_input_table, h_calendar_id;
                    FETCH h_cursor INTO x_per_base_table;
                    IF h_cursor%NOTFOUND THEN
                        x_per_base_table := 0;
                    END IF;
                    CLOSE h_cursor;
                END IF;
            ELSE
                -- EDW periodicity
                -- Use BSC_EDW_TIME_MAP table which was previously created for
                -- x_periodicity_input_table --> x_periodicity_base_table
                h_sql := 'SELECT MAX(bsc_target) '||
                         'FROM bsc_edw_time_map '||
                         'WHERE year = :1 '||
                         'AND bsc_source = :2';
                OPEN h_cursor FOR h_sql USING x_current_fy, x_per_input_table;
                FETCH h_cursor INTO x_per_base_table;
                IF h_cursor%NOTFOUND THEN
                    x_per_base_table := 0;
                END IF;
                CLOSE h_cursor;
            END IF;
        END IF;
    END IF;

    -- The update period of the base table is the maximun between the current
    -- period and the period calculated from the input table,

    IF h_current_period > x_per_base_table THEN
        x_per_base_table := h_current_period;
    END IF;

    x_current_per_base_table := h_current_period;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_BASE.Calc_New_Period_Base_Table');
      RETURN FALSE;

END Calc_New_Period_Base_Table;


/*===========================================================================+
| FUNCTION Calc_New_Period_Input_Table
+============================================================================*/
FUNCTION Calc_New_Period_Input_Table(
	x_input_table IN VARCHAR2,
 	x_periodicity IN NUMBER,
        x_period_col_name IN VARCHAR2,
        x_subperiod_col_name IN VARCHAR2,
        x_current_fy IN NUMBER,
	x_period OUT NOCOPY NUMBER,
	x_subperiod OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);

    h_current_period NUMBER;
    h_current_subperiod NUMBER;

    h_reported_period NUMBER;
    h_reported_subperiod NUMBER;

    h_yearly_flag NUMBER;

    h_target_flag NUMBER;

    h_calendar_id NUMBER;
    h_calendar_source VARCHAR2(20);

    h_periodicity_type NUMBER;

BEGIN

    h_reported_period := 0;
    h_reported_subperiod := 0;
    h_yearly_flag := 0;
    h_calendar_id := NULL;
    h_calendar_source := NULL;

    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity);
    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(h_calendar_id);

    -- Get Target_Flag of the input table
    h_target_flag := BSC_UPDATE_UTIL.Get_Table_Target_Flag(x_input_table);

    -- Get the current period and subperiod of the input table
    BEGIN
        SELECT NVL(current_period, 0), NVL(current_subperiod, 0)
        INTO h_current_period, h_current_subperiod
        FROM bsc_db_tables
        WHERE table_name = x_input_table;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_current_period := 0;
            h_current_subperiod := 0;
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
            h_sql := 'SELECT MAX('||x_period_col_name||') '||
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

    -- Get the maximun sub-period of real data reported in the input table
    -- BSC-BIS-DIMENSIONS: Input table never has sub-period for BIS periodicities
     h_reported_subperiod := 0;
    IF h_calendar_source = 'BSC' THEN
        IF x_subperiod_col_name IS NULL THEN
            h_reported_subperiod := 0;
        ELSE
            h_sql := 'SELECT MAX('||x_subperiod_col_name||') '||
                     'FROM '||x_input_table||' '||
                     'WHERE year = :1 '||
                     'AND '||x_period_col_name||' = :2';
            IF h_target_flag = 1 THEN
                -- The input tables is used only for targets only
                -- No condition on TYPE to get the update period of the input table.
                OPEN h_cursor FOR h_sql USING x_current_fy, h_reported_period;
            ELSE
                -- The input table is for fact and target data
                -- The update period is calculated based on fact data only.
                h_sql := h_sql||'AND type = :3';
                OPEN h_cursor FOR h_sql USING x_current_fy, h_reported_period, 0;
            END IF;

            FETCH h_cursor INTO h_reported_subperiod;
            IF h_cursor%FOUND THEN
                IF h_reported_subperiod IS NULL THEN
                    h_reported_subperiod := 0;
                END IF;
            ELSE
                h_reported_subperiod := 0;
            END IF;
            CLOSE h_cursor;
        END IF;
    END IF;

    -- Assign the new update period and sub-period
    IF h_current_period > h_reported_period THEN
        x_period := h_current_period;
        x_subperiod := h_current_subperiod;
    ELSIF h_current_period < h_reported_period THEN
        x_period := h_reported_period;
        x_subperiod := h_reported_subperiod;
    ELSE
        x_period := h_current_period;
        IF h_current_subperiod > h_reported_subperiod THEN
            x_subperiod := h_current_subperiod;
        ELSE
            x_subperiod := h_reported_subperiod;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_BASE.Calc_New_Period_Input_Table');
      RETURN FALSE;

END Calc_New_Period_Input_Table;


/*===========================================================================+
| FUNCTION Calculate_Base_Table
+============================================================================*/
FUNCTION Calculate_Base_Table(
        x_base_table IN VARCHAR2,
        x_input_table IN VARCHAR2,
        x_correction_flag IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    h_b BOOLEAN;
    h_sql VARCHAR2(32700);

    -- Current fiscal year
    h_current_fy NUMBER;

    -- Table periodicities
    h_periodicity_input_table NUMBER;
    h_periodicity_base_table NUMBER;

    -- Period and subperiod column name of input table
    h_period_col_name VARCHAR2(15);
    h_subperiod_col_name VARCHAR2(15);

    -- Update period and subperiod of the tables
    h_per_input_table NUMBER;
    h_subper_input_table NUMBER;
    h_current_per_base_table NUMBER;
    h_per_base_table NUMBER;

    -- Generation type (1: total or balance columns)
    h_generation_type NUMBER;

    -- Projection flag
    h_projection_flag VARCHAR2(3); -- This indicates that at least one data column has projection
    h_project_flag NUMBER; -- This indicates that the table has project_flag = 1 or 0

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
    h_lst_key_columns   VARCHAR2(32700);

    -- Number of year and previous years of the table
    h_num_of_years NUMBER;
    h_previous_years NUMBER;

    -- Zero code calcualtion method
    h_zero_code_calc_method NUMBER;

    -- Calendar id used by the input/base table
    h_calendar_id NUMBER;

    h_start_year NUMBER;
    h_end_year NUMBER;

    CURSOR c_other_periodicities (p_table_name VARCHAR2, p_calc_type NUMBER) IS
        SELECT c.parameter1, p.yearly_flag
        FROM bsc_db_calculations c, bsc_sys_periodicities p
        WHERE c.table_name = p_table_name AND c.calculation_type = p_calc_type AND
              c.parameter1 = p.periodicity_id;

    h_other_periodicity_id NUMBER;
    h_yearly_flag NUMBER;
    h_current_period NUMBER;

    TYPE t_periodicity IS RECORD (
        periodicity_id 	NUMBER,
        yearly_flag NUMBER,
        current_period NUMBER,
        new_current_period NUMBER
    );

    TYPE t_array_periodicities IS TABLE OF t_periodicity
        INDEX BY BINARY_INTEGER;

    h_arr_other_periodicities t_array_periodicities;
    h_num_other_periodicities NUMBER;
    h_i NUMBER;

    --AW_INTEGRATION: new variables
    h_aw_table VARCHAR2(30);
    h_proj_filter VARCHAR2(32000);
    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;
    h_change_vector_value NUMBER;

BEGIN

    h_projection_flag := 'NO';
    h_num_data_columns := 0;
    h_num_key_columns := 0;
    h_lst_key_columns := NULL;
    h_num_other_periodicities := 0;

    --AW_INTEGRATION: init change vector value
    IF x_aw_flag THEN
        bsc_aw_load.init_bt_change_vector(x_base_table);
        h_change_vector_value := bsc_aw_load.get_bt_next_change_vector(x_base_table);
    END IF;

    -- Get the periodicity of the base table
    h_periodicity_base_table := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_base_table);

    IF h_periodicity_base_table IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the periodicity of the input table
    h_periodicity_input_table := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_input_table);

    IF h_periodicity_input_table IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the calendar id of the input/base table
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(h_periodicity_base_table);

    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

    -- Get the number of years and previous years of the table
    IF NOT BSC_UPDATE_UTIL.Get_Table_Range_Of_Years(x_base_table, h_num_of_years, h_previous_years) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get period column name and subperiod column name in the input table
    IF NOT BSC_UPDATE_UTIL.Get_Period_Cols_Names(h_periodicity_input_table, h_period_col_name, h_subperiod_col_name) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Create BSC_EDW_TIME_MAP table, in case there is change of periodicity
    -- on EDW tables
    -- I have deleted that code. EDW is not supported

    -- Get the new period and subperiod of the input table
    h_per_input_table := 0;
    h_subper_input_table := 0;
    -- If the base table is being re-calculated for incremental changes
    -- then we do not consider the input table to calcualte new period of the base table.
    IF NOT x_correction_flag THEN
        IF NOT Calc_New_Period_Input_Table(x_input_table,
                                           h_periodicity_input_table,
                                           h_period_col_name,
                                           h_subperiod_col_name,
                                           h_current_fy,
                                           h_per_input_table,
                                           h_subper_input_table) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    -- Get the new period of the base table
    IF NOT Calc_New_Period_Base_Table(x_base_table,
                                      h_periodicity_base_table,
                                      h_periodicity_input_table,
                                      h_current_fy,
                                      h_per_input_table,
                                      h_subper_input_table,
                                      h_current_per_base_table,
                                      h_per_base_table) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Retrieve information of the input and base table to be processed.

    -- Base table generation type
    h_generation_type := BSC_UPDATE_UTIL.Get_Table_Generation_Type(x_base_table);

    IF h_generation_type IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    IF NOT BSC_UPDATE_UTIL.Get_Information_Data_Columns(x_base_table,
                                                        h_data_columns,
                                                        h_data_formulas,
                                                        h_data_proj_methods,
                                                        h_data_measure_types,
                                                        h_num_data_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(x_base_table,
                                                       h_key_columns,
                                                       h_key_dim_tables,
                                                       h_source_columns,
                                                       h_source_dim_tables,
                                                       h_num_key_columns) THEN
        RAISE e_unexpected_error;
    END IF;


    -- Create temporary tables used for calculation and tranformations
    -- Projection
    h_b := BSC_UPDATE_CALC.Table_Has_Proj_Calc(x_base_table);
    IF h_b IS NULL THEN
        RAISE e_unexpected_error;
     END IF;

    IF h_b THEN
        h_projection_flag := 'YES';
    ELSE
        h_projection_flag := 'NO';
    END IF;

    -- No temporary tables for code zero calculation.

    COMMIT;


    --- BSC-MV Note: Get info other periodicities
    -- AW_INTEGRATION: If the base table is for AW there are not higher periodicities
    -- in the base table, so we do not need info for other periodicities.
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        OPEN c_other_periodicities(x_base_table, 6);
        LOOP
            FETCH c_other_periodicities INTO h_other_periodicity_id, h_yearly_flag;
            EXIT WHEN c_other_periodicities%NOTFOUND;

            h_current_period := BSC_UPDATE_UTIL.Get_Period_Other_Periodicity(
                                       h_other_periodicity_id,
                                       h_calendar_id,
                                       h_yearly_flag,
                                       h_current_fy,
                                       h_periodicity_base_table,
                                       h_current_per_base_table
                                );
            h_num_other_periodicities := h_num_other_periodicities + 1;
            h_arr_other_periodicities(h_num_other_periodicities).periodicity_id := h_other_periodicity_id;
            h_arr_other_periodicities(h_num_other_periodicities).yearly_flag := h_yearly_flag;
            h_arr_other_periodicities(h_num_other_periodicities).current_period := h_current_period;

            -- Fix bug: In calculate projection for other periodicities we need to pass the new
            -- current period not the current current period!!!
            h_current_period := BSC_UPDATE_UTIL.Get_Period_Other_Periodicity(
                                       h_other_periodicity_id,
                                       h_calendar_id,
                                       h_yearly_flag,
                                       h_current_fy,
                                       h_periodicity_base_table,
                                       h_per_base_table
                                );
            h_arr_other_periodicities(h_num_other_periodicities).new_current_period := h_current_period;

        END LOOP;
        CLOSE c_other_periodicities;
   END IF;


    -- Delete the current projection in the base table

    -- With the optimization of the projection method we are going to delete projection (set NULL)
    -- only the records for periods >current_period and <=new_current_period.

    SELECT project_flag INTO h_project_flag
    FROM bsc_db_tables
    WHERE table_name = x_base_table;

    IF h_project_flag = 1 THEN
        -- Delete the projection from all the data columns in the table
        --AW_INTEGRATION: Pass x_aw_flag and h_change_vector_value to Delete_Projection_Base_Table
        IF NOT BSC_UPDATE_CALC.Delete_Projection_Base_Table(x_base_table,
                                                 h_periodicity_base_table,
                                                 h_current_per_base_table,
                                                 h_per_base_table,
                                                 h_data_columns,
                                                 h_data_proj_methods,
                                                 h_num_data_columns,
                                                 h_current_fy,
                                                 x_aw_flag,
                                                 h_change_vector_value) THEN
            RAISE e_unexpected_error;
        END IF;
        commit;

        -- BSC-MV Note: For this architecture we need to delete the projection
        -- from all other periodicities stored in the base table.
        -- AW_INTEGRATION: If the base table is for AW then there are not higher periodicities
        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            FOR h_i IN 1..h_num_other_periodicities LOOP
                --AW_INTEGRATION: Pass x_aw_flag to Delete_Projection_Base_Table and h_change_vector_value
                IF NOT BSC_UPDATE_CALC.Delete_Projection_Base_Table(x_base_table,
                                                         h_arr_other_periodicities(h_i).periodicity_id,
                                                         h_arr_other_periodicities(h_i).current_period,
                                                         h_arr_other_periodicities(h_i).new_current_period,
                                                         h_data_columns,
                                                         h_data_proj_methods,
                                                         h_num_data_columns,
                                                         h_current_fy,
                                                         x_aw_flag,
                                                         h_change_vector_value) THEN
                    RAISE e_unexpected_error;
                END IF;
                commit;
            END LOOP;
        END IF;
    END IF;
    commit;

    -- Fix bug#4653405: AW_INTEGRATION: PROJECTION flag is now set to Y for all the rows beyond
    -- current period no matter if it is target or actual. So if the current period changes
    -- we need to update to N betwen old current period and new current period for type <> 0
    IF x_aw_flag THEN
        h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(h_periodicity_base_table);
        IF (h_yearly_flag <> 1) AND (h_per_base_table > h_current_per_base_table) THEN
            h_num_bind_vars := 0;
            h_bind_vars_values.delete;

            h_sql := 'UPDATE '||x_base_table||
                     ' SET projection = ''N'', change_vector = :1'||
                     ' WHERE YEAR = :2 AND PERIOD > :3 AND PERIOD <= :4 AND TYPE <> :5';
            h_bind_vars_values(1) := h_change_vector_value;
            h_bind_vars_values(2) := h_current_fy;
            h_bind_vars_values(3) := h_current_per_base_table;
            h_bind_vars_values(4) := h_per_base_table;
            h_bind_vars_values(5) := 0;
            h_num_bind_vars := 5 ;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
            commit;
        END IF;
    END IF;

    -- Update base table from the input data in the corresponding input table.
    -- This step performs the bulk upload of input data into the base table.

    --Fix bug#4235448 : Need to pass current current period of the base table h_current_per_base_table
    --AW_INTEGRATION: pass x_aw_flag and h_change_vector_value
    IF NOT Update_Base_Table(x_base_table,
                             x_input_table,
                             h_key_columns,
                             h_key_dim_tables,
                             h_num_key_columns,
                             h_data_columns,
                             h_data_formulas,
                             h_data_measure_types,
                             h_num_data_columns,
                             h_periodicity_base_table,
                             h_periodicity_input_table,
                             h_period_col_name,
                             h_subperiod_col_name,
                             h_projection_flag,
                             h_current_fy,
                             h_per_base_table,
                             h_current_per_base_table,
                             x_correction_flag,
                             x_aw_flag,
                             h_change_vector_value
                             ) THEN
        RAISE e_unexpected_error;
    END IF;

    COMMIT;

    -- A base table is never used direclty by an indicator.
    -- So, there is no need to:
    -- Refresh any EDW materialized view.
    -- Calculate filters.
    -- Merge benchmarks from another table
    -- Calculate profit.
    -- By design there is no zero code calculation on base tables

    -- Calculate projection
    IF h_projection_flag = 'YES' THEN
        --ENH_PROJECTION_4235711: pass TRUE to x_trunc_proj_table parameter
        IF NOT BSC_UPDATE_CALC.Create_Proj_Temps(h_periodicity_base_table,
						 h_current_fy,
						 h_num_of_years,
						 h_previous_years,
                                                 TRUE) THEN
            RAISE e_unexpected_error;
         END IF;

        -- AW_INTEGRATION: Pass x_aw_flag and h_change_vector_value to Calculate_Projection
        IF NOT BSC_UPDATE_CALC.Calculate_Projection(x_base_table,
						    h_periodicity_base_table,
 						    h_per_base_table,
						    h_key_columns,
						    h_num_key_columns,
						    h_data_columns,
						    h_data_proj_methods,
						    h_num_data_columns,
						    h_current_fy,
						    h_num_of_years,
						    h_previous_years,
						    TRUE,
                                                    x_aw_flag,
                                                    h_change_vector_value) THEN
            RAISE e_unexpected_error;
        END IF;
        COMMIT;

        -- AW_INTEGRATION: If x_correction_flag is TRUE we need to set change_vector for the whole base table
        IF x_aw_flag AND x_correction_flag THEN
            h_sql := 'UPDATE '||x_base_table||' SET change_vector = :1';
            execute immediate h_sql using h_change_vector_value;
            commit;
        END IF;

        -- BSC-MV Note: For this architecture we need to calculate projection
        -- from all other periodicities stored in the base table.
        -- AW_INTEGRATION: If the base table is for AW there are no higher peridicities

        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN

            -- For other periodicities, the projection is calculated by rolling up
            -- the projection in the base periodicity.
            -- We know that for Yearly periodicity we need to re-calculate projection.

            FOR h_i IN 1..h_num_other_periodicities LOOP
                --ENH_PROJECTION_4235711: pass FALSE to x_trunc_proj_table parameter
                IF NOT BSC_UPDATE_CALC.Create_Proj_Temps(h_arr_other_periodicities(h_i).periodicity_id,
      					                 h_current_fy,
						         h_num_of_years,
						         h_previous_years,
                                                         FALSE) THEN
                    RAISE e_unexpected_error;
                END IF;

                IF h_arr_other_periodicities(h_i).yearly_flag = 1 THEN
                    -- We know that for yearly periodicity, we need to re-calculate
                    -- projection
                    -- AW_INTEGRATION: Pass x_aw_flag and change_vector value to Calculate_Projection
                    IF NOT BSC_UPDATE_CALC.Calculate_Projection(
                              x_base_table,
     	                      h_arr_other_periodicities(h_i).periodicity_id,
 			      h_arr_other_periodicities(h_i).new_current_period,
			      h_key_columns,
			      h_num_key_columns,
			      h_data_columns,
			      h_data_proj_methods,
			      h_num_data_columns,
			      h_current_fy,
			      h_num_of_years,
			      h_previous_years,
			      TRUE,
                              x_aw_flag,
                              NULL) THEN
                        RAISE e_unexpected_error;
                    END IF;
                    COMMIT;
                ELSE
                    -- For other periodicites, the projection is calculated by rolling up the projection
                    -- already calculated for the base periodicity.
                    -- ENH_PROJECTION_4235711: no need to pass table name
                    IF NOT BSC_UPDATE_CALC.Rollup_Projection(
     	                      h_arr_other_periodicities(h_i).periodicity_id,
 			      h_arr_other_periodicities(h_i).new_current_period,
                              h_periodicity_base_table,
                              h_per_base_table,
			      h_key_columns,
			      h_num_key_columns,
			      h_data_columns,
                              h_data_formulas,
                              h_data_measure_types,
			      h_num_data_columns,
			      h_current_fy,
                              TRUE) THEN
                        RAISE e_unexpected_error;
                    END IF;
                    COMMIT;
                END IF;
            END LOOP;

            --ENH_PROJECTION_4235711: Projection for all the periodicities is already calculated in
            -- BSC_TMP_PROC_CALC table. We can now merge the projection into the base table
            IF NOT BSC_UPDATE_CALC.Merge_Projection(x_base_table,
                                    h_key_columns,
                                    h_num_key_columns,
                                    h_data_columns,
                                    h_num_data_columns,
                                    TRUE,
                                    x_aw_flag) THEN
                RAISE e_unexpected_error;
            END IF;

            -- Fix bug#4463132: Truncate temporary table after use
            BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJ_CALC');
            commit;
        END IF;
    END IF;

    -- Calculate Profit
    -- BSC-MV Note: Only in this architecture the profit is calculated in the base table
    -- AW_INTEGRATION: Profit needs to be calculated in this architecture too
    IF BSC_APPS.bsc_mv THEN
        h_b := BSC_UPDATE_CALC.Table_Has_Profit_Calc(x_base_table);
        IF h_b IS NULL THEN
            RAISE e_unexpected_error;
        END IF;

        IF h_b THEN
            -- AW_INTEGRATION: Pass x_aw_flag and change vector value to Calculate_Profit
            IF NOT BSC_UPDATE_CALC.Calculate_Profit(x_base_table,
                                                    h_key_columns,
                                                    h_key_dim_tables,
                                                    h_num_key_columns,
                                                    h_data_columns,
                                                    h_num_data_columns,
                                                    x_aw_flag,
                                                    h_change_vector_value
                                                    ) THEN
                RAISE e_unexpected_error;
            END IF;
            COMMIT;
        END IF;
    END IF;

    -- Store the update period of input table and base table
    -- BSC-MV Note: If the base table is being re-calculated for incremental changes
    -- we do not need to update the current period of the table.
    -- Also we do not need to deelte data from input table

    --AW_INTEGRATION: update change vector value in aw metadata
    IF x_aw_flag THEN
        bsc_aw_load.update_bt_change_vector(x_base_table, h_change_vector_value);
        commit;
    END IF;

    IF NOT x_correction_flag THEN
        UPDATE
            bsc_db_tables
        SET
            current_period = h_per_input_table,
            current_subperiod = h_subper_input_table
        WHERE
            table_name = x_input_table;

        UPDATE
            bsc_db_tables
        SET
            current_period = h_per_base_table
        WHERE
            table_name = x_base_table;

        COMMIT;

        -- Delete data from input table
        BSC_UPDATE_UTIL.Truncate_Table(x_input_table);
    END IF;

    COMMIT;

    --Fix bug#4962928: add this call
    IF x_aw_flag THEN
        BSC_AW_LOAD.update_bt_current_period(x_base_table, h_per_base_table, h_current_fy);
        commit;
    END IF;

    -- Fix bug#4463132: Truncate temporary table after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE');
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_BTABLE_CALCULATION_FAILED'),
                      x_source => 'BSC_UPDATE_BASE.Calculate_Base_Table');
      RETURN FALSE;

    WHEN OTHERS THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_BASE.Calculate_Base_Table');
      RETURN FALSE;

END Calculate_Base_Table;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Calculate_Base_Table_AT
+============================================================================*/
FUNCTION Calculate_Base_Table_AT(
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
| FUNCTION Create_Generic_Temp_Tables    				     |
+============================================================================*/
FUNCTION Create_Generic_Temp_Tables RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_num_key_columns NUMBER;
    h_num_keys_for_index NUMBER;
    h_num_data_columns NUMBER;
    h_i NUMBER;

    h_table_name VARCHAR2(30);
    h_table_columns BSC_UPDATE_UTIL.t_array_temp_table_cols;
    h_num_columns NUMBER;

BEGIN

    h_num_key_columns := 100;
    h_num_data_columns := 300;
    h_num_keys_for_index := 8;

    -- BSC-BIS-DIMENSIONS: In order to support NUMBER or VARCHAR2 in key columns
    -- we need to create these temporary tables with VARCHAR2 in the key columns.

    -- BSC_TMP_BASE:
    -- Structure <KEY1...KEYN YEAR TYPE PERIOD DATA1...DATAN>
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_BASE';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF BSC_APPS.bsc_mv THEN
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PERIODICITY_ID';
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
        --ENH_PROJECTION_4235711: need this column in BSC_TMP_PROJ_CALC.
        --It it not needed in other tables but it is OK
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PERIOD_TYPE_ID';
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END IF;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'DATA'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    -- AW_INTEGRATION: bsc_tmp_base needs an additional column called PROJECTION VARCHAR2(60)
    -- and CHANGE_VECTOR NUMBER
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PROJECTION';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 60;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CHANGE_VECTOR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC-MV Note: These temp tables are used only in bsc-mv architecture
    ---------------venu--------------------------------------------
    --because we aggregate the data to higher periodicities, we need to
    --capture the before update signature from the base table and then
    --we use this to subtract from the base table
    IF BSC_APPS.bsc_mv THEN
        -- BSC_TMP_BASE_BU
        --Bug#3875046: Do not create index on temporary tables
        h_table_name := 'BSC_TMP_BASE_BU';
        IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
            RAISE e_unexpected_error;
        END IF;

        ---------------venu--------------------------------------------
        --we need this table for balance calculations
        -- BSC_TMP_BASE_BAL
        h_table_name := 'BSC_TMP_BASE_BAL';
        --Bug#3875046: Do not create index on temporary tables
        IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
            RAISE e_unexpected_error;
        END IF;
        -----------------------------------------------------------------
    END IF;

    -- BSC_TMP_PROJECTIONS (Note this table has same structure as previous table
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_PROJECTIONS';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    --ENH_PROJECTION_4235711: New temporary table used to calculate projection
    -- BSC_TMP_PROJ_CALC (Note this table has same structure as previous table
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_PROJ_CALC';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_TOT_DATA (Note this table has same structure as previous table
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_TOT_DATA';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_BAL_DATA (Note this table has same structure as previous table
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_BAL_DATA';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_PER_CHANGE
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_PER_CHANGE';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'SRC_PER';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TRG_PER';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_PER_CHANGE_BAL (Note it has the same strucutre as the previouos table)
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_PER_CHANGE_BAL';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_ALL_PERIODS
    h_table_name := 'BSC_TMP_ALL_PERIODS';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_DISAG_ALL_PERIODS
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_DISAG_ALL_PERIODS';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF BSC_APPS.bsc_mv THEN
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PERIODICITY_ID';
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PERIOD_TYPE_ID';
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END IF;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_TOT_PLAN
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_TOT_PLAN';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'TOTPLAN'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_TOT_REAL
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_TOT_REAL';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'TOTREAL'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_PLAN_PROJECTIONS
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_PLAN_PROJECTIONS';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PLAN'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_PROJECTIONS_Y
    h_table_name := 'BSC_TMP_PROJECTIONS_Y';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'ROW_ID';
    h_table_columns(h_num_columns).data_type := 'ROWID';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'DATA'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_XMD
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_XMD';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF BSC_APPS.bsc_mv THEN
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PERIODICITY_ID';
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END IF;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'XMED'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_XMD_Y
    h_table_name := 'BSC_TMP_XMD_Y';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'ROW_ID';
    h_table_columns(h_num_columns).data_type := 'ROWID';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'XMED'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_UNION
    --Bug#3875046: Do not create index on temporary tables
    h_table_name := 'BSC_TMP_UNION';
    h_table_columns.delete;
    h_num_columns := 0;
    FOR h_i IN 1..h_num_key_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'YEAR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Bug#3842096 Need this new temporary table
    -- BSC_TMP_BASE_UPDATE
    h_table_name := 'BSC_TMP_BASE_UPDATE';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'ROW_ID';
    h_table_columns(h_num_columns).data_type := 'ROWID';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    FOR h_i IN 1..h_num_data_columns LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'DATA'||h_i;
        h_table_columns(h_num_columns).data_type := 'NUMBER';
        h_table_columns(h_num_columns).data_size := NULL;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    --AW_INTEGRATION: need PROJECTION column VARCHAR2(60) and CHANGE_VECTOR NUMBER
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PROJECTION';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 60;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CHANGE_VECTOR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Bug#3875046 Need this new temporary table. No index needed
    -- BSC_TMP_BASE_ROWID
    h_table_name := 'BSC_TMP_BASE_ROWID';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'ROW_ID_TMP';
    h_table_columns(h_num_columns).data_type := 'ROWID';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'ROW_ID_BASE';
    h_table_columns(h_num_columns).data_type := 'ROWID';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR'),
                      x_source => 'BSC_UPDATE_BASE.Create_Generic_Temp_Tables');
      RETURN FALSE;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_BASE.Create_Generic_Temp_Tables');
      RETURN FALSE;
END Create_Generic_Temp_Tables;

--LOCKING: new function
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


/*
given a bace table, this gives all the higher level periodicities for the base fact
*/
-------------------------------venu-----------------

-- Bug Fix for #3236356

FUNCTION Get_Base_Higher_Periodicities(
   p_table_name         VARCHAR2,
   p_periodicity        OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
   p_calendar_id        OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
   p_column_name        OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
   p_number_periodicity OUT NOCOPY NUMBER
) RETURN BOOLEAN IS

  CURSOR c_Calc_Period IS
  SELECT TO_NUMBER(C.PARAMETER1) Parameter1, P.CALENDAR_ID Calendar_Id, P.DB_COLUMN_NAME Db_Column_Name
  FROM   BSC_DB_CALCULATIONS C, BSC_SYS_PERIODICITIES P
  WHERE  C.Parameter1       = P.Periodicity_Id
  AND    C.Calculation_Type = 6
  AND    C.Table_Name       = p_table_name;

BEGIN


  p_number_periodicity := 1;

  FOR cr IN c_Calc_Period LOOP
    p_periodicity(p_number_periodicity) := cr.Parameter1;
    p_calendar_id(p_number_periodicity) := cr.Calendar_Id;
    p_column_name(p_number_periodicity) := cr.Db_Column_Name;

    p_number_periodicity := p_number_periodicity + 1;
  END LOOP;
  p_number_periodicity := p_number_periodicity - 1;


  RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source  => 'BSC_UPDATE_BASE.get_base_higher_periodicities');
      RETURN FALSE;
End Get_Base_Higher_Periodicities;
------------------------venu------------------------------


/*===========================================================================+
| FUNCTION Update_Base_Table						     |
+============================================================================*/
FUNCTION Update_Base_Table(
	x_base_tbl		VARCHAR2,
	x_in_tbl		VARCHAR2,
	x_key_columns 		BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_key_dim_tables	BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns 	NUMBER,
        x_data_columns 	        BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_formulas		BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_measure_types    BSC_UPDATE_UTIL.t_array_of_number,
        x_num_data_columns 	NUMBER,
	x_base_percode		NUMBER,
	x_in_percode		NUMBER,
	x_in_per_fld		VARCHAR2,
	x_in_subper_fld		VARCHAR2,
	x_projection_flag	VARCHAR2,
        x_current_fy            NUMBER,
        x_current_per_base_table NUMBER,
        x_prev_current_period NUMBER,  --Fix bug#4235448 Need this parameter
        x_correction_flag       BOOLEAN,
        x_aw_flag               BOOLEAN,
        x_change_vector_value   NUMBER
    ) RETURN BOOLEAN IS
	e_unexpected_error 	EXCEPTION;
	h_sql			VARCHAR2(32700);
        h_i			NUMBER;
	h_lst_key_columns	VARCHAR2(32700);
	h_lst_data_columns	VARCHAR2(32700);
	h_lst_key_columns_temp	VARCHAR2(32700);
	h_lst_data_columns_temp	VARCHAR2(32700);
        h_lst_data_formulas     VARCHAR2(32700);
	h_lst_select		VARCHAR2(32700);
	h_lst_from		VARCHAR2(32700);
	h_lst_where		VARCHAR2(32700);
        h_lst_join		VARCHAR2(32700);
        h_lst_cond_null		VARCHAR2(32700);
        h_trg_table		VARCHAR2(30);

        -- Name of the column of bsc_db_calendar according to the periodicity
        -- of input and base tables
        h_input_calendar_col_name VARCHAR2(30);
        h_base_calendar_col_name VARCHAR2(30);

        h_yearly_flag NUMBER;
        h_edw_flag NUMBER;
        h_periodicity_type_input_table NUMBER;
        h_periodicity_type_base_table NUMBER;

        h_calendar_id NUMBER;

        h_key_columns_temp  BSC_UPDATE_UTIL.t_array_of_varchar2;
        h_data_columns_temp BSC_UPDATE_UTIL.t_array_of_varchar2;

        -- Posco bind variable fix
        l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
        l_num_bind_vars NUMBER;

        l_bind_var_per NUMBER;

        l_parallel_hint varchar2(20000);

        ------------------venu---------------------
        l_periodicity BSC_UPDATE_UTIL.t_array_of_number;
        l_calendar_id BSC_UPDATE_UTIL.t_array_of_number;
        l_column_name BSC_UPDATE_UTIL.t_array_of_varchar2;
        l_number_periodicity number;
        -------------------------------------
        l_bf_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
        l_bf_column_formulas BSC_UPDATE_UTIL.t_array_of_varchar2;
        -------------------------------------
        l_stmt varchar2(32000);
        l_table varchar2(320);
        l_op varchar2(32);
        l_periodicity_stmt varchar2(3000);
        l_balance_flag boolean;
        l_found boolean;
        l_calendar_sql varchar2(3000);
        l_yearly_flag number;
        ------------------venu---------------------

        h_calendar_source VARCHAR2(20);

        h_level_table_name VARCHAR2(30);
        h_level_short_name VARCHAR2(80);
        h_level_source VARCHAR2(10);
        h_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

        --Fix bug#3875046: need this variables
	h_lst_data_columns_temp_p VARCHAR2(32700);
        h_row_count NUMBER;
        h_num_rows_tmp NUMBER;
        h_num_rows_base NUMBER;
        l_hint VARCHAR2(2000);

        --AW_INTEGRATION: New variables
        h_projection_col_temp VARCHAR2(30);
        h_aw_table VARCHAR2(30);

        --Fix bug#4235448: need this new variable
        l_current_period NUMBER;
        l_prev_current_period NUMBER;
        TYPE t_cursor IS REF CURSOR;
        h_cursor t_cursor;

BEGIN
	h_sql := NULL;
	h_lst_key_columns := NULL;
	h_lst_data_columns := NULL;
	h_lst_key_columns_temp := NULL;
	h_lst_data_columns_temp := NULL;
        h_lst_data_formulas := NULL;
	h_lst_select := NULL;
	h_lst_from := NULL;
	h_lst_where := NULL;
        h_lst_join := NULL;
        h_lst_cond_null := NULL;
        h_trg_table := NULL;
        h_yearly_flag := 0;
        h_edw_flag := 0;        -- Fix bug#3875046
	h_lst_data_columns_temp_p := NULL;
        h_row_count := 0;
        h_num_rows_tmp := 0;
        h_num_rows_base := 0;

    -- Use temporal table BSC_TMP_BASE
    -- In this table we will insert all data from the input table but doing user_codes transformation
    -- and change of periodicity if it is necessary.

    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE');
    commit;

    --Fix bug#3875046 Need to delete bsc_tmp_base_rowid. this is used one time at the end.
    -- Better to truncate here that delete later
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_ROWID');
    commit;

    -- BSC-MV Note: This table only used in this architecture
    -- AW_INTEGRATION: If the base table is for AW there are not higher periodicities.
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        --h_sql := 'DELETE FROM BSC_TMP_BASE_BU';
        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_BU');
        commit;
    END IF;

    -- Fix bug#4480258 Perf Issues: analyze the input table before loading it
    BSC_BIA_WRAPPER.Analyze_Table(x_in_tbl);
    commit;

   /*--------------------------------------------------------------+
     | Determine the values for the the sql components to translate|
     | user codes into codes                                       |
     +--------------------------------------------------------------*/

    -- Fix bug#4653405: Need to move the initialization of these variable here
    h_base_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_base_percode);
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_base_percode);
    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(h_calendar_id);
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_base_percode);


    h_lst_key_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    h_lst_key_columns_temp := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_key_columns);

    IF h_lst_key_columns IS NOT NULL THEN
        h_lst_key_columns := h_lst_key_columns||', ';
        h_lst_key_columns_temp := h_lst_key_columns_temp||', ';
    END IF;

    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);
    h_lst_data_columns_temp := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('DATA', x_num_data_columns);
    h_lst_data_formulas := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_formulas, x_num_data_columns);

    --AW_INTEGRATION: Base table has an additional column called PROJECTION and CHANGE_VECTOR
    IF BSC_APPS.bsc_mv AND x_aw_flag THEN
        h_lst_data_columns := h_lst_data_columns||', PROJECTION, CHANGE_VECTOR';
        h_lst_data_columns_temp := h_lst_data_columns_temp||', PROJECTION, CHANGE_VECTOR';
        -- Fix bug#4653405: AW_INTEGRATION: we need to set projection flag Y for any period
        -- beyond the current period no matter if it is target
        -- Note: we assume no change of periodicity between I and B tables
        IF h_calendar_source = 'BSC' THEN
            IF h_yearly_flag = 1 THEN
                h_lst_data_formulas := h_lst_data_formulas||', '||
                                       ' case when '||x_in_tbl||'.YEAR > '||x_current_fy||
                                       ' then ''Y'' else ''N'' end';
            ELSE
                h_lst_data_formulas := h_lst_data_formulas||', '||
                                       ' case when ('||x_in_tbl||'.YEAR = '||x_current_fy||' AND '||
                                       x_in_tbl||'.PERIOD > '||x_current_per_base_table||') OR ('||
                                       x_in_tbl||'.YEAR > '||x_current_fy||')'||
                                       ' then ''Y'' else ''N'' end';
            END IF;
        ELSE
            -- BIS calendar
            IF h_yearly_flag = 1 THEN
                h_lst_data_formulas := h_lst_data_formulas||', '||
                                       ' case when BSC_SYS_PERIODS.YEAR > '||x_current_fy||
                                       ' then ''Y'' else ''N'' end';
            ELSE
                h_lst_data_formulas := h_lst_data_formulas||', '||
                                       ' case when (BSC_SYS_PERIODS.YEAR = '||x_current_fy||' AND '||
                                       'BSC_SYS_PERIODS.PERIOD_ID > '||x_current_per_base_table||') OR ('||
                                       'BSC_SYS_PERIODS.YEAR > '||x_current_fy||')'||
                                       ' then ''Y'' else ''N'' end';
            END IF;
        END IF;
        h_lst_data_formulas := h_lst_data_formulas||', '||x_change_vector_value;
    END IF;

    h_lst_select := NULL;
    h_lst_from := x_in_tbl;
    l_parallel_hint:='parallel ('||x_in_tbl||')';
    h_lst_where := NULL;

    FOR h_i IN 1 .. x_num_key_columns LOOP
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

        h_lst_select := h_lst_select||h_level_table_name||'.CODE, ';

        h_lst_from := h_lst_from||', '||h_level_table_name;
        l_parallel_hint:=l_parallel_hint||' parallel ('||h_level_table_name||')';

        IF h_lst_where IS NOT NULL THEN
            h_lst_where := h_lst_where||' AND ';
        END IF;
        h_lst_where := h_lst_where||x_in_tbl||'.'||x_key_columns(h_i)||' = '||h_level_table_name||'.USER_CODE';

        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    --Fix bug#3875046: Need to initialize h_lst_data_columns_temp_p
    h_lst_data_columns_temp_p := NULL;
    FOR h_i IN 1 .. x_num_data_columns LOOP
        h_data_columns_temp(h_i) := 'DATA'||h_i;

        IF h_i > 1 THEN
            h_lst_data_columns_temp_p := h_lst_data_columns_temp_p||',';
        END IF;
        h_lst_data_columns_temp_p := h_lst_data_columns_temp_p||'BSC_TMP_BASE.DATA'||h_i;
    END LOOP;
    -- AW_INTEGRATION: Base table has an additional column called projection and change_vector
    IF BSC_APPS.bsc_mv AND x_aw_flag THEN
        h_lst_data_columns_temp_p := h_lst_data_columns_temp_p||',BSC_TMP_BASE.PROJECTION, BSC_TMP_BASE.CHANGE_VECTOR';
    END IF;

    /*--------------------------------------------------------------+
     | Determine the values for the rest of the sql components      |
     | based on the basic transformation type -- periodicity change |
     | and balance transfer.  The following component values vary   |
     | depending on the transformation type.                        |
     |                                                              |
     | Note: By design there is no change of periodicity between    |
     | input table and base table. The only two cases are:          |
     | month week --> week52 and month week --> daily345. So we     |
     | dont care about balance data columns                         |
     +--------------------------------------------------------------*/

    l_bind_var_per := NULL;

    IF x_base_percode = x_in_percode THEN
        -- There is no change of periodicity

        -- BSC-BIS-DIMENSIONS Note:
        -- We know that never there is change of periodicity from input to base table
        -- when the table is using a BIS calendar, so the code always get here.

        IF h_calendar_source = 'BSC' THEN
            h_lst_select := h_lst_select||x_in_tbl||'.YEAR, '||x_in_tbl||'.TYPE, '||x_in_tbl||'.'||x_in_per_fld;
        ELSE
            -- Table is using a BIS calendar. We need to translate from TIME_FK (in input table) to
            -- YEAR, PERIOD in base table. It uses BSC_SYS_PERIODS to do so.

            IF h_yearly_flag = 1 THEN
                h_lst_select := h_lst_select||'BSC_SYS_PERIODS.YEAR, '||x_in_tbl||'.TYPE, 0';
            ELSE
                h_lst_select := h_lst_select||'BSC_SYS_PERIODS.YEAR, '||x_in_tbl||'.TYPE, BSC_SYS_PERIODS.PERIOD_ID';
            END IF;

            h_lst_from := h_lst_from||', BSC_SYS_PERIODS';
            l_parallel_hint:=l_parallel_hint||' parallel (BSC_SYS_PERIODS)';

            IF h_lst_where IS NOT NULL THEN
                h_lst_where := h_lst_where||' AND ';
            END IF;

            h_periodicity_type_base_table := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_base_percode);

            IF h_periodicity_type_base_table = 9 THEN
                -- It is a daily periodicity. The TIME_FK column in the input table is of type DATE.
                h_lst_where := h_lst_where||
	                       'TRUNC('||x_in_tbl||'.TIME_FK) = TRUNC(TO_DATE(BSC_SYS_PERIODS.TIME_FK, ''MM/DD/YYYY'')) AND '||
		    	       'BSC_SYS_PERIODS.PERIODICITY_ID = :2';
                l_bind_var_per := x_base_percode;
            ELSE
                -- Other periodicity. TIME_FK is VARCHAR2
                h_lst_where := h_lst_where||
	                       x_in_tbl||'.TIME_FK = BSC_SYS_PERIODS.TIME_FK AND '||
		    	       'BSC_SYS_PERIODS.PERIODICITY_ID = :2';
                l_bind_var_per := x_base_percode;
            END IF;
        END IF;
    ELSE
        -- BSC-BIS-DIMENSIONS Note:
        -- We know that never there is change of periodicity from input to base table
        -- when the table is using a BIS calendar. So I do not need to change this code

        -- There is change of periodicity
        -- Note: We suppose that the change of periodicity is allowed
        -- (see bsc_sys_periodicites) plus:
        -- Always is possible to pass to periodicity 1 (Annual)
        -- From periodicity 12 (Month Day) is possible to pass to any periodicity
        -- From periodicity 11 (Month Week) is possible to pass only to 7 (Week52)

        h_periodicity_type_input_table := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_in_percode);
        h_periodicity_type_base_table := BSC_UPDATE_UTIL.Get_Periodicity_Type(x_base_percode);

        IF h_yearly_flag = 1 THEN
            -- The periodicity of base table is annual
            h_lst_select := h_lst_select||x_in_tbl||'.YEAR, '||x_in_tbl||'.TYPE, 0';

        ELSIF h_periodicity_type_base_table = 7 AND h_periodicity_type_input_table = 11 THEN
            -- The base table is Weekly52 and the input table is Month Week
            -- This is the special case that use bsc_db_week_maps table to make the
            -- transformation
            h_lst_from := h_lst_from||', BSC_DB_WEEK_MAPS';
            l_parallel_hint:=l_parallel_hint||' parallel (BSC_DB_WEEK_MAPS)';

            h_lst_select := h_lst_select||x_in_tbl||'.YEAR, '||x_in_tbl||'.TYPE, BSC_DB_WEEK_MAPS.WEEK52';

            IF h_lst_where IS NOT NULL THEN
                h_lst_where := h_lst_where||' AND ';
            END IF;
            h_lst_where := h_lst_where||
	                   x_in_tbl||'.YEAR = BSC_DB_WEEK_MAPS.YEAR AND '||
			   x_in_tbl||'.'||x_in_per_fld||' = BSC_DB_WEEK_MAPS.MONTH AND '||
			   x_in_tbl||'.'||x_in_subper_fld||' = BSC_DB_WEEK_MAPS.WEEK AND '||
                           'BSC_DB_WEEK_MAPS.CALENDAR_ID = :2';
            l_bind_var_per := h_calendar_id;
        ELSE
            -- Other periodicities changes
            h_edw_flag := BSC_UPDATE_UTIL.Get_Periodicity_EDW_Flag(x_base_percode);

            IF h_edw_flag = 0 THEN
                -- BSC Periodicity
                -- Use bsc_db_calendar to make the transformation
                h_lst_from := h_lst_from||', BSC_DB_CALENDAR';
                l_parallel_hint:=l_parallel_hint||' parallel (BSC_DB_CALENDAR)';

                --h_base_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_base_percode);
                IF h_periodicity_type_input_table = 12 THEN
                    -- The input table is Month-Day
                    h_lst_select := h_lst_select||x_in_tbl||'.YEAR, '||
                                    x_in_tbl||'.TYPE, BSC_DB_CALENDAR.'||h_base_calendar_col_name;

                    IF h_lst_where IS NOT NULL THEN
                        h_lst_where := h_lst_where||' AND ';
                    END IF;
                    h_lst_where := h_lst_where||
	                           x_in_tbl||'.YEAR = BSC_DB_CALENDAR.YEAR AND '||
			           x_in_tbl||'.'||x_in_per_fld||' = BSC_DB_CALENDAR.MONTH AND '||
			           x_in_tbl||'.'||x_in_subper_fld||' = BSC_DB_CALENDAR.DAY30 AND '||
                                   'BSC_DB_CALENDAR.CALENDAR_ID = :2';
                    l_bind_var_per := h_calendar_id;
                ELSE
                    h_input_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_in_percode);
                    h_lst_select := h_lst_select||x_in_tbl||'.YEAR, '||
                                    x_in_tbl||'.TYPE, BSC_DB_CALENDAR.'||h_base_calendar_col_name;

                    IF h_lst_where IS NOT NULL THEN
                        h_lst_where := h_lst_where||' AND ';
                    END IF;
                    h_lst_where := h_lst_where||
	                           x_in_tbl||'.YEAR = BSC_DB_CALENDAR.YEAR AND '||
			           x_in_tbl||'.'||x_in_per_fld||' = BSC_DB_CALENDAR.'||h_input_calendar_col_name||' AND '||
                                   'BSC_DB_CALENDAR.CALENDAR_ID = :2';
                    l_bind_var_per := h_calendar_id;
                END IF;

            ELSE
                -- EDW periodicity
                -- Use bsc_edw_time_map to make the transformation.
                -- This table was previously created for X_In_Percode --> X_Base_Percode
                h_lst_from := h_lst_from||', BSC_EDW_TIME_MAP';
                l_parallel_hint:=l_parallel_hint||' parallel (BSC_EDW_TIME_MAP)';
                h_lst_select := h_lst_select||x_in_tbl||'.YEAR, '||
                                    x_in_tbl||'.TYPE, BSC_EDW_TIME_MAP.BSC_TARGET';

                IF h_lst_where IS NOT NULL THEN
                    h_lst_where := h_lst_where||' AND ';
                END IF;
                h_lst_where := h_lst_where||
                               x_in_tbl||'.YEAR = BSC_EDW_TIME_MAP.YEAR AND '||
	   	               x_in_tbl||'.'||x_in_per_fld||' = BSC_EDW_TIME_MAP.BSC_SOURCE';
            END IF;
        END IF;
    END IF;

    --BSC-MV Note: Add column periodicity_id
    --AW_INTEGRATION: If the base table is for AW, it does not have periodicity_id
    -- Insert records
    h_sql := 'INSERT /*+ append';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||' parallel (bsc_tmp_base)';
    end if;
    h_sql := h_sql||' */';
    h_sql :=h_sql||'INTO BSC_TMP_BASE ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, ';
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||'PERIODICITY_ID, ';
    END IF;
    h_sql := h_sql||h_lst_data_columns_temp||')'||
             ' SELECT ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'/*+ '||l_parallel_hint||' */ ';
    end if;
    h_sql:=h_sql||h_lst_select||', ';
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||':1, ';
    END IF;
    h_sql := h_sql||h_lst_data_formulas||
             ' FROM '||h_lst_from;
    IF h_lst_where IS NOT NULL THEN
        h_sql := h_sql||' WHERE '||h_lst_where;
    END IF;
    h_sql := h_sql||' GROUP BY '||h_lst_select;
    -------------------venu------------------------------
    if BSC_APPS.bsc_mv and x_correction_flag and (NOT x_aw_flag) then
        /*
        the user has made some mistake. say user entered sum(m1), then loaded BSC. later, user changes
        sum(m1) to avg(m1). in this case, the higher periodicities in the base table are first deleted,
        and then data from the base table is moved to the tmp table. so the step of pulling data from
        the imput table is skipped.
        */
        --delete data from the base table for higher periodicities
        --Bug#3875046: We are not going to remove higher periodcities from the base table
        --l_stmt:='delete '||x_base_tbl||' where periodicity_id <> :1';
        l_bind_vars_values.delete;
        l_bind_vars_values(1):=x_base_percode;
        --BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,1);
        --commit;
        ---------------move data from base into tmp--------
        h_sql := 'INSERT /*+ append';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||' parallel (bsc_tmp_base)';
        end if;
        h_sql := h_sql||' */';
        h_sql :=h_sql||'INTO BSC_TMP_BASE ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD,PERIODICITY_ID, ';
        h_sql := h_sql||h_lst_data_columns_temp||') SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql := h_sql||' /*+ parallel('||x_base_tbl||')*/ ';
        end if;
        --Bug#3875046 Add condition on periodicity_id.(Changes next 3 lines)
        h_sql := h_sql||h_lst_key_columns||'YEAR, TYPE, PERIOD, PERIODICITY_ID, ';
        h_sql := h_sql||h_lst_data_columns||' from '||x_base_tbl;
        h_sql := h_sql||' where PERIODICITY_ID = :1';
        --Fix bug#3875046: Need to maintain track of number of rpws in tmp table to be used later
        h_row_count := BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
        h_num_rows_tmp := h_num_rows_tmp + h_row_count;
        ---------------------------------------------------
    elsif ((NOT BSC_APPS.bsc_mv) OR x_aw_flag) AND x_correction_flag then
        /*
        in summary tables architecture and incremental mode, no need to pull data from the
        input table. We jsut need to insert all the rows from the base table to the BSC_TMP_BASE table.
        AW_INTEGRATION: If the base table is for AW then there are not higher periodicities.
        It is the same structure as summary tables architecture
        */
        h_sql := 'INSERT /*+ append';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||' parallel (bsc_tmp_base)';
        end if;
        h_sql := h_sql||' */';
        h_sql :=h_sql||'INTO BSC_TMP_BASE ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, ';
        h_sql := h_sql||h_lst_data_columns_temp||') SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql := h_sql||' /*+ parallel('||x_base_tbl||')*/ ';
        end if;
        h_sql := h_sql||h_lst_key_columns||'YEAR, TYPE, PERIOD, ';
        h_sql := h_sql||h_lst_data_columns||' from '||x_base_tbl;
        --Fix bug#3875046: Need to maintain track of number of rpws in tmp table to be used later
        h_row_count := BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        h_num_rows_tmp := h_num_rows_tmp + h_row_count;
        ---------------------------------------------------
    else
        l_bind_vars_values.delete;
        l_num_bind_vars := 0;

        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            l_bind_vars_values(1):= x_base_percode;
            l_num_bind_vars := 1;
        END IF;
        IF l_bind_var_per IS NOT NULL THEN
            l_num_bind_vars := l_num_bind_vars + 1;
            l_bind_vars_values(l_num_bind_vars) := l_bind_var_per;
        END IF;
        IF l_num_bind_vars > 0 THEN
            --Fix bug#3875046: Need to maintain track of number of rpws in tmp table to be used later
            h_row_count := BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars);
            h_num_rows_tmp := h_num_rows_tmp + h_row_count;
        ELSE
            --Fix bug#3875046: Need to maintain track of number of rpws in tmp table to be used later
            h_row_count := BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
            h_num_rows_tmp := h_num_rows_tmp + h_row_count;
        END IF;
        commit;
    end if;
    commit;

    -- Update existing records in base table
    --AW_INTEGRATION: If the base table is for AW, it does not have periodicity_id
    h_lst_join := NULL;
    IF x_num_key_columns > 0 THEN
        h_lst_join := BSC_UPDATE_UTIL.Make_Lst_Cond_Join(x_base_tbl,
                                                         x_key_columns,
                                                         'BSC_TMP_BASE',
	  	      	                                 h_key_columns_temp,
							 x_num_key_columns,
						         'AND');
        h_lst_join := h_lst_join||' AND ';
    END IF;

    -- BSC-MV Note: Add periodicity_id column in the join
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_join := h_lst_join||
                      x_base_tbl||'.PERIODICITY_ID = BSC_TMP_BASE.PERIODICITY_ID AND ';
    END IF;
    h_lst_join := h_lst_join||
                  x_base_tbl||'.YEAR = BSC_TMP_BASE.YEAR AND '||
                  x_base_tbl||'.TYPE = BSC_TMP_BASE.TYPE AND '||
                  x_base_tbl||'.PERIOD = BSC_TMP_BASE.PERIOD';

    -----venu-------------------------------------------------------------------
    --BSC-MV Note: This code applies only for new architecture
    --AW_INTEGRATION: If the base table is for AW, it does not have higher periodicities
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
      --get all the higher periodicities for the base table
      if get_base_higher_periodicities(
        x_base_tbl,
        l_periodicity,
        l_calendar_id,
        l_column_name,
        l_number_periodicity)=false then
        RAISE e_unexpected_error;
      end if;
      --before we update the data in the base fact, we need to capture the
      --data in the base fact. this is because, we will later need to subtract
      --this data from the higher level aggregation
      --if x_correction_flag then we dont need to process lowest periodicity data into the base table
      if x_correction_flag=false then
        if l_number_periodicity>0 then
          l_stmt:='insert /*+ append';
          if BSC_UPDATE_UTIL.is_parallel then
            l_stmt:=l_stmt||' parallel (bsc_tmp_base_bu)';
          end if;
          l_stmt := l_stmt||' */';
          l_stmt :=l_stmt||'INTO BSC_TMP_BASE_BU ('||h_lst_key_columns_temp||'PERIODICITY_ID,YEAR, TYPE, PERIOD, '||
          h_lst_data_columns_temp||')'||
                   ' SELECT ';
          if BSC_UPDATE_UTIL.is_parallel then
            l_stmt:=l_stmt||'/*+ parallel (bsc_tmp_base) parallel ('||x_base_tbl||') */ ';
          end if;
          l_stmt:=l_stmt||'/*+ ordered use_nl('||x_base_tbl||') */ ';
          for i in 1..x_num_key_columns loop
            l_stmt:=l_stmt||'bsc_tmp_base.'||h_key_columns_temp(i)||',';
          end loop;
          l_stmt:=l_stmt||'bsc_tmp_base.PERIODICITY_ID,bsc_tmp_base.YEAR,bsc_tmp_base.TYPE,bsc_tmp_base.PERIOD,';
          for i in 1..x_num_data_columns loop
            l_stmt:=l_stmt||x_base_tbl||'.'||x_data_columns(i)||',';
          end loop;
          l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
          l_stmt:=l_stmt||' from bsc_tmp_base,'||x_base_tbl||' where ';
          for i in 1..x_num_key_columns loop
            l_stmt:=l_stmt||x_base_tbl||'.'||x_key_columns(i)||'=bsc_tmp_base.'||h_key_columns_temp(i)||' and ';
          end loop;
          l_stmt:=l_stmt||'bsc_tmp_base.PERIODICITY_ID='||x_base_tbl||'.PERIODICITY_ID and '||
          'bsc_tmp_base.YEAR='||x_base_tbl||'.YEAR and '||
          'bsc_tmp_base.TYPE='||x_base_tbl||'.TYPE and '||
          'bsc_tmp_base.PERIOD='||x_base_tbl||'.PERIOD';
          commit;
          BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
          commit;
        end if;
      end if;
      ------------------------------------------------------------------------
    END IF;

    -- BSC-MV Note: add periodicity_id in condition
    --Fix bug#3875046: Replace this update stmt with the strategy of inserting into
    -- bsc_tmp_base_update with row id and then update the base table
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_UPDATE');
    commit;
    l_bind_vars_values.delete;
    h_sql := 'INSERT /*+ append ';
    IF BSC_UPDATE_UTIL.is_parallel THEN
        h_sql := h_sql||'parallel (bsc_tmp_base_update) ';
    END IF;
    h_sql := h_sql||' */'||
             ' INTO bsc_tmp_base_update (row_id, '||h_lst_data_columns_temp||')'||
             ' SELECT '||x_base_tbl||'.rowid, '||h_lst_data_columns_temp_p||
             ' FROM '||x_base_tbl||', bsc_tmp_base'||
             ' WHERE '||h_lst_join;
    --if x_correction_flag then we dont need to do updates and inserts into the base
    --table for lowest periodicity data
    if not x_correction_flag then
      BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
      commit;
    end if;

    h_sql := 'UPDATE /*+ordered use_nl(B)*/ '||x_base_tbl||' B'||
             ' SET ('||h_lst_data_columns||')=('||
             ' SELECT '||h_lst_data_columns_temp||
             ' FROM bsc_tmp_base_update P'||
             ' WHERE P.row_id = B.rowid)'||
             ' WHERE B.rowid IN (SELECT row_id FROM bsc_tmp_base_update)';
    --if x_correction_flag then we dont need to do updates and inserts into the base
    --table for lowest periodicity data
    if not x_correction_flag then
      BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
      commit;
    end if;

    -- Insert new rows
    h_lst_select := NULL;
    h_lst_join := NULL;
    h_lst_cond_null := NULL;

    IF x_num_key_columns > 0 THEN
        h_lst_select := BSC_UPDATE_UTIL.Make_Lst_Table_Column('BSC_TMP_BASE',
                                                              h_key_columns_temp,
                                                              x_num_key_columns);
        h_lst_select := h_lst_select||', ';

        h_lst_join := BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join('BSC_TMP_BASE',
                                                              h_key_columns_temp,
                                                              x_base_tbl,
	  	      	                                      x_key_columns,
							      x_num_key_columns,
						              'AND');
        h_lst_join := h_lst_join||' AND ';

        h_lst_cond_null := BSC_UPDATE_UTIL.Make_Lst_Cond_Null(x_base_tbl,
                                                              x_key_columns,
                                                              x_num_key_columns,
                                                              'OR');
        h_lst_cond_null := h_lst_cond_null||' OR ';

    END IF;

    --BSC-MV Note: Add periodicity id
    --AW_INTEGRATION: no need periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_select := h_lst_select||'BSC_TMP_BASE.PERIODICITY_ID,';
    END IF;
    h_lst_select := h_lst_select||'BSC_TMP_BASE.YEAR, BSC_TMP_BASE.TYPE, BSC_TMP_BASE.PERIOD, '||
                    h_lst_data_columns_temp_p;

    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_join := h_lst_join||
                      'BSC_TMP_BASE.PERIODICITY_ID = '||x_base_tbl||'.PERIODICITY_ID (+) AND ';
    END IF;
    h_lst_join := h_lst_join||
                  'BSC_TMP_BASE.YEAR = '||x_base_tbl||'.YEAR (+) AND '||
                  'BSC_TMP_BASE.TYPE = '||x_base_tbl||'.TYPE (+) AND '||
                  'BSC_TMP_BASE.PERIOD = '||x_base_tbl||'.PERIOD (+)';

    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_cond_null := h_lst_cond_null||
                           x_base_tbl||'.PERIODICITY_ID IS NULL OR ';
    END IF;
    h_lst_cond_null := h_lst_cond_null||
                       x_base_tbl||'.YEAR IS NULL OR '||
                       x_base_tbl||'.TYPE IS NULL OR '||
                       x_base_tbl||'.PERIOD IS NULL';
    /*
    9/26/03
    before we insert into the base table, we need to see if we can use append hint.
    the logic is as follows.
    for I->B
    if the base table has data, then this is inc and do not use append if there is
    snapshot log on the base table.
    for Projections
    if the base table has a snapshot log on it and the snashot log has at-least
    one row of data in it, then this insert is incremental and we cannot use
    append hint. append hint will not write into the snapshot log
    */
    declare
      ll_use_append boolean;
      ll_base_count number;
    begin
      ll_use_append:=true;
      if BSC_IM_UTILS.check_snapshot_log(x_base_tbl,BSC_APPS.bsc_apps_schema) then
        --see if the base table has any data
        --does_table_have_data will return 2 if the snapshot log has data, 0 if there is some error and
        --1 if there is no data
        ll_base_count:=BSC_IM_UTILS.does_table_have_data(x_base_tbl,null);
        if ll_base_count<>1 then
          ll_use_append:=false;--to be on the safe side
        end if;
      end if;
      if ll_use_append then
        h_sql := 'INSERT /*+append';
        if BSC_UPDATE_UTIL.is_parallel then
          h_sql:=h_sql||' parallel ('||x_base_tbl||')';
        end if;
      else
        h_sql := 'INSERT /*+';
      end if;
    end;
    h_sql := h_sql||' */';
    h_sql := h_sql ||'INTO '||x_base_tbl||' ('||h_lst_key_columns;
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||'PERIODICITY_ID, ';
    END IF;
    h_sql := h_sql||'YEAR, TYPE, PERIOD, '||h_lst_data_columns||')'||
             ' SELECT ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'/*+ parallel ('||x_base_tbl||') parallel (bsc_tmp_base) */ ';
    end if;
    h_sql:=h_sql||h_lst_select||
           ' FROM '||x_base_tbl||', BSC_TMP_BASE'||
           ' WHERE '||h_lst_join||' AND ('||h_lst_cond_null||')';

    --if x_correction_flag then we dont need to do updates and inserts into the base
    if not x_correction_flag then
      commit;
      BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    end if;
    commit;

    -- Fix bug#3875046: Analize base table
    BSC_BIA_WRAPPER.Analyze_Table(x_base_tbl);
    commit;

    -- Fix bug#4463131: truncate temp tables after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_UPDATE');
    -- note that we cannot truncate bsc_tmp_base since it is used in projection

    ---------------------venu------------------------------------------
    --BSC-MV Note: This code only applies for new architecture
    --AW_INTEGRATION: This code does not apply if the base table of fo AW
    IF (NOT BSC_APPS.bsc_mv) OR x_aw_flag THEN
        RETURN TRUE;
    END IF;

    -- Fix bug#4235448: If there is at least one balance column we need to
    -- insert into BSC_TMP_BASE the rows from current period to new current period
    -- that do not exist in BSC_TMP_PERIOD.
    -- We do this only when current_period < new_current_period and there are higher periodicities
    -- Also when x_correction_flag is TRUE we are doing full refresh so not need to do this.
    l_balance_flag:=false;
    for i in 1..x_num_data_columns loop
      if x_data_measure_types(i)<>1 then
        l_balance_flag:=true;
        exit;
      end if;
    end loop;
    IF (l_number_periodicity>0) AND l_balance_flag AND (NOT x_correction_flag) AND
       (x_current_per_base_table > x_prev_current_period) THEN
      for j in 1..2 loop
        if j=1 then
          l_table:='bsc_tmp_base';
        else
          l_table:='bsc_tmp_base_bu';
        end if;
        h_lst_select := NULL;
        h_lst_join := NULL;
        h_lst_cond_null := NULL;
        IF x_num_key_columns > 0 THEN
          h_lst_select := BSC_UPDATE_UTIL.Make_Lst_Table_Column(x_base_tbl, x_key_columns, x_num_key_columns);
          h_lst_select := h_lst_select||', ';
          h_lst_join := BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join(x_base_tbl,
                                                                x_key_columns,
                                                                l_table,
	  	      	                                        h_key_columns_temp,
							        x_num_key_columns,
						                'AND');
          h_lst_join := h_lst_join||' AND ';
          -- Fix bug#4480258: perf issue. no need null condition on all the keys. We just
          --need on YEAR, if it is null then the other keys are null too.
          --h_lst_cond_null := BSC_UPDATE_UTIL.Make_Lst_Cond_Null(l_table,
          --                                                      h_key_columns_temp,
          --                                                      x_num_key_columns,
          --                                                      'OR');
          --h_lst_cond_null := h_lst_cond_null||' OR ';
        END IF;
        h_lst_select := h_lst_select||x_base_tbl||'.PERIODICITY_ID, '||
                        x_base_tbl||'.YEAR, '||x_base_tbl||'.TYPE, '||x_base_tbl||'.PERIOD';
        for i in 1..x_num_data_columns loop
          if x_data_measure_types(i)=1 then
            h_lst_select := h_lst_select||', 0';
          else
            h_lst_select := h_lst_select||', '||x_base_tbl||'.'||x_data_columns(i);
          end if;
        end loop;
        h_lst_join := h_lst_join||x_base_tbl||'.PERIODICITY_ID = '||l_table||'.PERIODICITY_ID (+) AND '||
                      x_base_tbl||'.YEAR = '||l_table||'.YEAR (+) AND '||
                      x_base_tbl||'.TYPE = '||l_table||'.TYPE (+) AND '||
                      x_base_tbl||'.PERIOD = '||l_table||'.PERIOD (+)';
        -- Fix bug#4480258: perf issue. no need null condition on all the keys. We just
        --need on YEAR, if it is null then the other keys are null too.
        --h_lst_cond_null := h_lst_cond_null||l_table||'.PERIODICITY_ID IS NULL OR '||
        --                   l_table||'.YEAR IS NULL OR '||l_table||'.TYPE IS NULL OR '||
        --                   l_table||'.PERIOD IS NULL';
        h_lst_cond_null := l_table||'.YEAR IS NULL';

        l_stmt := 'INSERT /*+append';
        IF BSC_UPDATE_UTIL.is_parallel THEN
          l_stmt := l_stmt||' parallel ('||l_table||')';
        END IF;
        l_stmt := l_stmt||' */ INTO '||l_table||' ('||h_lst_key_columns_temp||'PERIODICITY_ID, YEAR, TYPE, PERIOD, '||
                  h_lst_data_columns_temp||') SELECT ';
        IF BSC_UPDATE_UTIL.is_parallel THEN
          l_stmt := l_stmt||'/*+ parallel ('||x_base_tbl||') parallel ('||l_table||') */';
        END IF;
        l_stmt := l_stmt||h_lst_select||
                  ' FROM '||x_base_tbl||', '||l_table||
                  ' WHERE '||h_lst_join||' AND '||
                  x_base_tbl||'.PERIODICITY_ID = :1 AND '||x_base_tbl||'.YEAR = :2 AND '||
                  x_base_tbl||'.PERIOD >= :3 AND '||x_base_tbl||'.PERIOD <= :4 AND ('||h_lst_cond_null||')';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := x_base_percode;
        l_bind_vars_values(2) := x_current_fy;
        l_bind_vars_values(3) := x_prev_current_period;
        l_bind_vars_values(4) := x_current_per_base_table;
        -- need to maintain track of the number of rows in bsc_tmp_base
        h_row_count := BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,4);
        if j=1 then
          h_num_rows_tmp := h_num_rows_tmp + h_row_count;
        end if;
        commit;
      end loop;
    END IF;

    /*
    after the base periodicity data is inserted into the base table, we are going to
    rollup the data to higher periodicities and then perform an update / insert
    */
    if l_number_periodicity>0 then
      FOR h_i IN 1 .. x_num_data_columns LOOP
        --h_data_columns_temp(h_i) := 'DATA'||h_i;
        --we need this because we are going to aggregate the data in the tmp table and store it in the tmp table
        l_bf_columns(h_i):=x_data_columns(h_i);
        -- Fix bug#4026328:replace('sum(m)','m','data1') --> sudata1(data1) error!!
        -- The fix is: replace('sum(m)','(m)', '(data1)') --> sum(data1)
        l_bf_column_formulas(h_i):=replace(x_data_formulas(h_i),'('||x_data_columns(h_i)||')','('||h_data_columns_temp(h_i)||')');
      END LOOP;
      --for each of the periodicity, rollup
      --we always rollup from the base periodicity data in the tmp table.
      --if we rollup from month to qtr, we again rollup from month to year. this is for simplicity
      --we rollup the data in bsc_tmp_base and bsc_tmp_base_bu
      for i in 1..l_number_periodicity loop
        if l_periodicity(i)<>x_base_percode then
          l_calendar_sql:='select distinct calendar_id,year,';
          if lower(l_column_name(i))<>'year' and lower(l_column_name(i))<>lower(h_base_calendar_col_name) then
            l_calendar_sql:=l_calendar_sql||l_column_name(i)||',';
          end if;
          if lower(h_base_calendar_col_name)<>'year' then
            l_calendar_sql:=l_calendar_sql||h_base_calendar_col_name||',';
          end if;
          l_calendar_sql:=substr(l_calendar_sql,1,length(l_calendar_sql)-1);
          l_calendar_sql:=l_calendar_sql||' from bsc_db_calendar';
          --Fix bug#4235448: get the current period and previous period in this periodicity
          if BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(l_periodicity(i))<>1 then
            l_stmt := 'select max('||l_column_name(i)||') from bsc_db_calendar'||
                      ' where '||h_base_calendar_col_name||' = :1 and year = :2  and calendar_id = :3';
            open h_cursor for l_stmt using x_current_per_base_table, x_current_fy, l_calendar_id(i);
            fetch h_cursor into l_current_period;
            close h_cursor;
            l_stmt := 'select max('||l_column_name(i)||') from bsc_db_calendar'||
                      ' where '||h_base_calendar_col_name||' = :1 and year = :2  and calendar_id = :3';
            open h_cursor for l_stmt using x_prev_current_period, x_current_fy, l_calendar_id(i);
            fetch h_cursor into l_prev_current_period;
            close h_cursor;
          end if;
          for j in 1..2 loop
            if j=1 then
              l_table:='bsc_tmp_base';
            else
              l_table:='bsc_tmp_base_bu';
            end if;
            l_stmt:='insert /*+ append';
            if BSC_UPDATE_UTIL.is_parallel then
              l_stmt:=l_stmt||' parallel ('||l_table||')';
            end if;
            l_stmt := l_stmt||' */';
            l_stmt:=l_stmt||'INTO '||l_table||'('||h_lst_key_columns_temp||'PERIODICITY_ID,YEAR, TYPE, PERIOD,'||
            h_lst_data_columns_temp||')'||
            ' SELECT ';
            if BSC_UPDATE_UTIL.is_parallel then
              l_stmt:=l_stmt||'/*+ parallel ('||l_table||') parallel (bsc_db_calendar)*/ ';
            end if;
            l_stmt:=l_stmt||h_lst_key_columns_temp||':1,'||l_table||'.YEAR,'||l_table||'.TYPE,';
            --bug 3348797
            --if l_periodicity(i)=1 then --for year we need to put 0 into PERIOD column
            if BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(l_periodicity(i))=1 then
              l_stmt:=l_stmt||'0,';
            else
              l_stmt:=l_stmt||'bsc_db_calendar.'||l_column_name(i)||',';
            end if;
            for k in 1..x_num_data_columns loop
              if x_data_measure_types(k)=1 then --do the aggregation only for TOTAL columns and not balance
                l_stmt:=l_stmt||l_bf_column_formulas(k)||',';
              else --for balance columns, null for now.
                -- Fix bug#4235448: If there is no chnage of periodicity then we use -999999999999 for now.
                -- If there is chnage of periodicity we do this: For periods between l_prev_current_period and
                -- l_current_period we insert null for other periods we insert -999999999999
                if x_current_per_base_table > x_prev_current_period then
                  if BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(l_periodicity(i))<>1 then
                    l_stmt:=l_stmt||'case when '||l_table||'.YEAR = '||x_current_fy||' and'||
                            ' bsc_db_calendar.'||l_column_name(i)||' >= '||l_prev_current_period||' and'||
                            ' bsc_db_calendar.'||l_column_name(i)||' <= '||l_current_period||
                            ' then null else -999999999999 end case,';
                  else
                    l_stmt:=l_stmt||'case when '||l_table||'.YEAR = '||x_current_fy||
                            ' then null else -999999999999 end case,';
                  end if;
                else
                  l_stmt:=l_stmt||'-999999999999,';
                end if;
              end if;
            end loop;
            l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
            l_stmt:=l_stmt||' from '||l_table||',('||l_calendar_sql||') bsc_db_calendar where '||
            l_table||'.year=bsc_db_calendar.year and '||
            l_table||'.period=bsc_db_calendar.'||h_base_calendar_col_name||' and bsc_db_calendar.calendar_id=:2 and '||
            l_table||'.periodicity_id=:3 group by '||h_lst_key_columns_temp||l_table||'.periodicity_id,'||
            l_table||'.YEAR,'||l_table||'.TYPE,'||
            'bsc_db_calendar.'||l_column_name(i);
            l_bind_vars_values.delete;
            l_bind_vars_values(1):=l_periodicity(i);
            l_bind_vars_values(2):=l_calendar_id(i);
            l_bind_vars_values(3):=x_base_percode;
            commit;
            --Fix bug#3875046 need to maintain track of the number of rows in bsc_tmp_base
            h_row_count := BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,3);
            if j=1 then
                h_num_rows_tmp := h_num_rows_tmp + h_row_count;
            end if;
            commit;
          end loop;--for j in 1..2
        end if;
        commit;
      end loop;
      ---------------------for balance-------------------------------
      --see if there are balance columns. if there are ba;ance columns, we need special logic
      --also this needs to happen in every loop
      l_balance_flag:=false;
      for i in 1..x_num_data_columns loop
        if x_data_measure_types(i)<>1 then
          l_balance_flag:=true;
          exit;
        end if;
      end loop;
      if l_balance_flag then
        --Fix bug#3875046 We need to truncate bsc_tmp_base_update because is going to be used
        -- to replace the update stmt at the end of the loop
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_UPDATE');
        commit;
        for i in 1..l_number_periodicity loop
          if l_periodicity(i)<>x_base_percode then
            ------------first set bsc_tmp_per_change_bal------------
            l_stmt:='DELETE FROM bsc_tmp_per_change_bal';
            BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
            l_yearly_flag:=BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(l_periodicity(i));
            IF l_yearly_flag <> 1 THEN
              --h_period_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);
              --h_origin_period_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_origin_periodicity);
              l_stmt:='INSERT INTO bsc_tmp_per_change_bal (year, src_per, trg_per)'||
              ' SELECT year, MAX('||h_base_calendar_col_name||') AS src_per, '||
              l_column_name(i)||' AS trg_per'||
              ' FROM bsc_db_calendar where calendar_id=:1';
              l_stmt:=l_stmt||' GROUP BY year,'||l_column_name(i);
              l_bind_vars_values.delete;
              l_bind_vars_values(1):=l_calendar_id(i);
              BSC_UPDATE_UTIL.Execute_Immediate(l_stmt, l_bind_vars_values,1);
              l_bind_vars_values.delete;
              l_bind_vars_values(1) := (x_current_per_base_table);
              l_bind_vars_values(2) := (x_current_fy) ;
              l_bind_vars_values(3) := (x_current_per_base_table);
              l_bind_vars_values(4) := (x_current_fy);
              l_stmt:='UPDATE bsc_tmp_per_change_bal'||
              ' SET src_per = :1'||
              ' WHERE year = :2'||
              ' AND trg_per = ('||
              ' SELECT '||l_column_name(i)||
              ' FROM bsc_db_calendar '||
              ' WHERE '||h_base_calendar_col_name||' = :3'||
              ' AND year = :4';
              l_stmt:=l_stmt||' AND calendar_id=:5';
              l_bind_vars_values(5) := l_calendar_id(i);
              l_stmt:=l_stmt||' GROUP BY '||l_column_name(i)||')';
              BSC_UPDATE_UTIL.Execute_Immediate(l_stmt, l_bind_vars_values,5);
            ELSE
              -- Anual periodicity
              l_stmt:='INSERT INTO bsc_tmp_per_change_bal (year, src_per, trg_per)'||
              ' SELECT year, MAX('||h_base_calendar_col_name||') AS src_per, 0 AS trg_per'||
              ' FROM bsc_db_calendar ';
              l_stmt:=l_stmt||' WHERE calendar_id=:1 ';
              l_stmt:=l_stmt||' GROUP BY year';
              l_bind_vars_values.delete;
              l_bind_vars_values(1):=l_calendar_id(i);
              BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,1);
              l_bind_vars_values.delete;
              l_bind_vars_values(1) := (x_current_per_base_table);
              l_bind_vars_values(2) := (x_current_fy);
              l_stmt:='UPDATE bsc_tmp_per_change_bal'||
              ' SET src_per = :1'||
              ' WHERE year = :2';
              BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,2);
            END IF;
            --this logic is happening for every higher level periodicity
            --delete the table first
            --l_stmt := 'DELETE FROM BSC_TMP_BASE_BAL';
            --BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
            BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_BAL');
            commit;
            l_stmt:='insert /*+ append';
            if BSC_UPDATE_UTIL.is_parallel then
              l_stmt:=l_stmt||' parallel (BSC_TMP_BASE_BAL)';
            end if;
            l_stmt := l_stmt||' */ ';
            l_stmt := l_stmt||' into BSC_TMP_BASE_BAL('||h_lst_key_columns_temp||'PERIODICITY_ID, YEAR, TYPE, PERIOD, '||
            h_lst_data_columns_temp||') SELECT ';
            -- Fix bug#3875046: use  hash hint
            l_stmt := l_stmt||'/*+use_hash(bsc_tmp_base) use_hash(bsc_tmp_per_change_bal)*/ ';
            if BSC_UPDATE_UTIL.is_parallel then
              l_stmt:=l_stmt||'/*+ parallel (bsc_tmp_base) parallel (bsc_tmp_per_change_bal) */';
            end if;
            l_stmt:=l_stmt||h_lst_key_columns_temp||':1,bsc_tmp_base.YEAR,'||
            'bsc_tmp_base.TYPE,bsc_tmp_per_change_bal.trg_per, ';
            for j in 1..x_num_data_columns loop
              if x_data_measure_types(j)=1 then
                --if these are total columns, select null.
                l_stmt:=l_stmt||'null,';
              else
                --please note that there is no aggregation for balance values
                l_stmt:=l_stmt||h_data_columns_temp(j)||',';
              end if;
            end loop;
            l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
            l_stmt:=l_stmt||' from bsc_tmp_base,bsc_tmp_per_change_bal where '||
            'bsc_tmp_base.year=bsc_tmp_per_change_bal.year and '||
            'bsc_tmp_base.period=bsc_tmp_per_change_bal.src_per and '||
            'bsc_tmp_base.periodicity_id=:2';
            --please note that we select the lowest level data from bsc_tmp_base
            l_bind_vars_values.delete;
            l_bind_vars_values(1):=l_periodicity(i);
            l_bind_vars_values(2):=x_base_percode;
            commit;
            BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,2);
            commit;
            --now we have to update bsc_tmp_base
            --Fix bug#3875046: Performance fix. We are going to replace the update statement.
            --We are going to insert into bsc_tmp_base_update with row_id. Then out of the loop
            --we are going to update bsc_tmp_base
            l_stmt:='insert into bsc_tmp_base_update (row_id,';
            for j in 1..x_num_data_columns loop
              if x_data_measure_types(j)<>1 then
                l_stmt:=l_stmt||h_data_columns_temp(j)||',';
              end if;
            end loop;
            -- Fix bug#4097873: perf fix. remove ordered hint
            l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||')'||
                    ' select /*+ use_hash(bsc_tmp_base) use_hash(bsc_tmp_base_bal)*/'||
                    ' bsc_tmp_base.rowid,';
            for j in 1..x_num_data_columns loop
              if x_data_measure_types(j)<>1 then
                l_stmt:=l_stmt||'bsc_tmp_base_bal.'||h_data_columns_temp(j)||',';
              end if;
            end loop;
            l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||
                    ' from bsc_tmp_base, bsc_tmp_base_bal'||
                    ' where ';
            for j in 1..x_num_key_columns loop
              l_stmt:=l_stmt||'bsc_tmp_base_bal.'||h_key_columns_temp(j)||'=bsc_tmp_base.'||
                      h_key_columns_temp(j)||' and ';
            end loop;
            l_stmt:=l_stmt||'bsc_tmp_base_bal.periodicity_id=bsc_tmp_base.periodicity_id and ';
            l_stmt:=l_stmt||'bsc_tmp_base_bal.period=bsc_tmp_base.period and ';
            l_stmt:=l_stmt||'bsc_tmp_base_bal.year=bsc_tmp_base.year and ';
            l_stmt:=l_stmt||'bsc_tmp_base_bal.type=bsc_tmp_base.type and ';
            l_stmt:=l_stmt||'bsc_tmp_base.periodicity_id=:1';
            l_bind_vars_values.delete;
            l_bind_vars_values(1):=l_periodicity(i);
            commit;
            BSC_UPDATE_UTIL.Execute_Immediate(l_stmt,l_bind_vars_values,1);
            commit;
            --------------------
            ---------------------------------------------------------
          end if;
        end loop;--for i in 1..l_number_periodicity loop
        --Fix bug#3875046: Now we can update bsc_tmp_base
        l_stmt:='update /*+ordered use_nl(bsc_tmp_base)*/ bsc_tmp_base set(';
        for j in 1..x_num_data_columns loop
          if x_data_measure_types(j)<>1 then
            l_stmt:=l_stmt||h_data_columns_temp(j)||',';
          end if;
        end loop;
        l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||')=(select ';
        for j in 1..x_num_data_columns loop
          if x_data_measure_types(j)<>1 then
            l_stmt:=l_stmt||h_data_columns_temp(j)||',';
          end if;
        end loop;
        l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||
                ' from bsc_tmp_base_update'||
                ' where bsc_tmp_base_update.row_id=bsc_tmp_base.rowid)'||
                ' where rowid in (select row_id from bsc_tmp_base_update)';
        BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
        commit;
      end if;--if l_balance_flag then
      ---------------------------------------------------------------
      --we need l_periodicity_stmt because when we update the base fact with higher level data,
      --we dont want to touch the lowest periodicity data in the base fact
      l_periodicity_stmt:=null;
      for i in 1..l_number_periodicity loop
        l_periodicity_stmt:=l_periodicity_stmt||l_periodicity(i)||',';
      end loop;
      l_periodicity_stmt:=substr(l_periodicity_stmt,1,length(l_periodicity_stmt)-1);
      --------------------------------------
      -- Fix bug#3911201: If x_correction_flag is TRUE (higher periodicities are being full refreshed)
      -- then we do not need to add/substract, we just update base table from bsc_tmp_base
      if x_correction_flag then
        l_table:='bsc_tmp_base';

        -- Bug#3842096 Insert into a temporal table with row_id and then update the base table
        -- instead of updating direclty to the base table
        -- Note: we cannot use append or parallel hint since we cannot commit until the end.

        l_stmt := 'DELETE FROM bsc_tmp_base_update';
        BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);

        l_stmt := 'INSERT INTO bsc_tmp_base_update (row_id,';
        for j in 1..x_num_data_columns loop
            l_stmt := l_stmt||h_data_columns_temp(j)||',';
        end loop;
        l_stmt := substr(l_stmt,1,length(l_stmt)-1);
        l_stmt := l_stmt||')'||
                  ' SELECT '||x_base_tbl||'.rowid,';
        for j in 1..x_num_data_columns loop
          l_stmt:=l_stmt||l_table||'.'||h_data_columns_temp(j)||',';
        end loop;
        l_stmt := substr(l_stmt,1,length(l_stmt)-1)||
                  ' FROM '||l_table||', '||x_base_tbl||
                  ' WHERE ';
        for j in 1..x_num_key_columns loop
          l_stmt := l_stmt||x_base_tbl||'.'||x_key_columns(j)||'='||l_table||'.'||h_key_columns_temp(j)||' and ';
        end loop;
        l_stmt := l_stmt||x_base_tbl||'.periodicity_id='||l_table||'.periodicity_id and '||
                  x_base_tbl||'.year='||l_table||'.year and '||
                  x_base_tbl||'.type='||l_table||'.type and '||
                  x_base_tbl||'.period='||l_table||'.period and '||
                  l_table||'.periodicity_id in ('||l_periodicity_stmt||')';
        BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);

        l_stmt := 'UPDATE /*+ORDERED USE_NL('||x_base_tbl||')*/ '||x_base_tbl||
                  ' SET(';
        for j in 1..x_num_data_columns loop
          l_stmt:=l_stmt||x_data_columns(j)||',';
        end loop;
        l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||')=(SELECT ';
        for j in 1..x_num_data_columns loop
          l_stmt:=l_stmt||'bsc_tmp_base_update.'||h_data_columns_temp(j)||',';
        end loop;
        l_stmt := substr(l_stmt,1,length(l_stmt)-1)||
                  ' FROM bsc_tmp_base_update'||
                  ' WHERE bsc_tmp_base_update.row_id='||x_base_tbl||'.rowid)'||
                  ' WHERE rowid IN (SELECT row_id FROM bsc_tmp_base_update)';
        BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
      else
        --add bsc_tmp_base data to the base table and then subtract the data from bsc_tmp_base_bu
        --l_periodicity_stmt we need this because here, we only update the higher periodicity
        for i in 1..2 loop
          if i=1 then
            l_table:='bsc_tmp_base';
            l_op:='+';
          else
            l_table:='bsc_tmp_base_bu';
            l_op:='-';
          end if;
          if i=2 then
            --if there are only balance columns, we dont need to do this step of subtraction
            l_found:=false;
            for j in 1..x_num_data_columns loop
              if x_data_measure_types(j)=1 then
                l_found:=true;
                exit;
              end if;
            end loop;
            if l_found=false then
              exit;--from the for loop for i in 1..2 loop
            end if;
          end if;

          -- Bug#3842096 Insert into a temporal table with row_id and then update the base table
          -- instead of updating direclty to the base table
          -- Note: we cannot use append or parallel hint since we cannot commit until the end.

          l_stmt := 'DELETE FROM bsc_tmp_base_update';
          BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);

          --i=1 is with bsc_tmp_base
          --i=2 is with bsc_tmp_base_bu

          l_stmt := 'INSERT INTO bsc_tmp_base_update (row_id,';
          for j in 1..x_num_data_columns loop
            if i=1 OR (i=2 and x_data_measure_types(j)=1) then
              l_stmt := l_stmt||h_data_columns_temp(j)||',';
            end if;
          end loop;
          l_stmt := substr(l_stmt,1,length(l_stmt)-1);
          l_stmt := l_stmt||')'||
                    ' SELECT '||x_base_tbl||'.rowid,';
          for j in 1..x_num_data_columns loop
            if i=1 OR (i=2 and x_data_measure_types(j)=1) then
              --Fix bug#4235448: for balance measures we should allow null
              if x_data_measure_types(j) = 1 then
                l_stmt:=l_stmt||'nvl('||l_table||'.'||h_data_columns_temp(j)||',0),';
              else
                l_stmt:=l_stmt||l_table||'.'||h_data_columns_temp(j)||',';
              end if;
            end if;
          end loop;
          l_stmt := substr(l_stmt,1,length(l_stmt)-1)||
                    ' FROM '||l_table||', '||x_base_tbl||
                    ' WHERE ';
          for j in 1..x_num_key_columns loop
            l_stmt := l_stmt||x_base_tbl||'.'||x_key_columns(j)||'='||l_table||'.'||h_key_columns_temp(j)||' and ';
          end loop;
          l_stmt := l_stmt||x_base_tbl||'.periodicity_id='||l_table||'.periodicity_id and '||
                    x_base_tbl||'.year='||l_table||'.year and '||
                    x_base_tbl||'.type='||l_table||'.type and '||
                    x_base_tbl||'.period='||l_table||'.period and '||
                    l_table||'.periodicity_id in ('||l_periodicity_stmt||')';
          BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);

          l_stmt := 'UPDATE /*+ORDERED USE_NL('||x_base_tbl||')*/ '||x_base_tbl||
                    ' SET(';
          for j in 1..x_num_data_columns loop
            if i=1 OR (i=2 and x_data_measure_types(j)=1) then
              l_stmt:=l_stmt||x_data_columns(j)||',';
            end if;
          end loop;
          l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||')=(SELECT ';
          for j in 1..x_num_data_columns loop
            if i=1 then
              if x_data_measure_types(j)=1 then
                --total column
                l_stmt := l_stmt||'nvl('||x_base_tbl||'.'||x_data_columns(j)||',0) '||l_op||
                          ' bsc_tmp_base_update.'||h_data_columns_temp(j)||',';
              else
                --balance column
                --Fix bug#4235448: need decode.
                --l_stmt:=l_stmt||'bsc_tmp_base_update.'||h_data_columns_temp(j)||',';
                l_stmt:=l_stmt||'decode(bsc_tmp_base_update.'||h_data_columns_temp(j)||',-999999999999,'||
                        x_base_tbl||'.'||x_data_columns(j)||',bsc_tmp_base_update.'||h_data_columns_temp(j)||'),';
              end if;
            else
              --here, there can be no balance since its bsc_tmp_base_bu
              --we must never subtract the balance column
              if x_data_measure_types(j)=1 then
                --total column
                l_stmt := l_stmt||'nvl('||x_base_tbl||'.'||x_data_columns(j)||',0) '||l_op||
                          ' bsc_tmp_base_update.'||h_data_columns_temp(j)||',';
              end if;
            end if;
          end loop;
          l_stmt := substr(l_stmt,1,length(l_stmt)-1)||
                    ' FROM bsc_tmp_base_update'||
                    ' WHERE bsc_tmp_base_update.row_id='||x_base_tbl||'.rowid)'||
                    ' WHERE rowid IN (SELECT row_id FROM bsc_tmp_base_update)';
          BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
        end loop;--for i in 1..2
      end if; --if x_correction_flag
      --in the base table
      --NO COMMIT HERE. COMMIT ONLY AFTER INSERT ALSO COMPLETE!!!
      --we can now insert the new data
      --we cannot have parallel insert due to commit issue. we can have a commit only after the
      --insert is complete
      -- Fix bug#3875046: Replace the insert stmt with following logic
      -- a. get number of rows of the base table. Since the base table is analyzed we can do:
      select nvl(num_rows,0)
      into h_num_rows_base
      from all_tables
      where table_name = x_base_tbl and owner= BSC_APPS.BSC_APPS_SCHEMA;
      --b. see what hint to use
      -- Fix bug#4097873: remove ordered hint
      if h_num_rows_base = 0 then
          l_hint := '/*+ use_hash(bsc_tmp_base) use_hash('||x_base_tbl||') */';
      else
          if (h_num_rows_tmp/h_num_rows_base) > 0.1 then
              l_hint := '/*+ use_hash(bsc_tmp_base) use_hash('||x_base_tbl||') */';
          else
              l_hint:= '/*+ordered */';
          end if;
      end if;
      --c. insert into bsc_tmp_base_rowid
      l_stmt := 'insert into bsc_tmp_base_rowid(row_id_tmp, row_id_base)'||
                ' select '||l_hint||' bsc_tmp_base.rowid, '||x_base_tbl||'.rowid'||
                ' from bsc_tmp_base, '||x_base_tbl||
                ' where ';
      for i in 1..x_num_key_columns loop
        l_stmt:=l_stmt||'bsc_tmp_base.'||h_key_columns_temp(i)||'='||x_base_tbl||'.'||x_key_columns(i)||' (+) and ';
      end loop;
      l_stmt:=l_stmt||'bsc_tmp_base.periodicity_id='||x_base_tbl||'.periodicity_id (+) and '||
              'bsc_tmp_base.year='||x_base_tbl||'.year (+) and '||
              'bsc_tmp_base.type='||x_base_tbl||'.type (+) and '||
              'bsc_tmp_base.period='||x_base_tbl||'.period (+)';
      BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
      --d. insert into the base table
      --Fix bug#4097873: perf fix: use_hash instead of ordered hint
      l_stmt := 'insert into '||x_base_tbl||' ('||
                h_lst_key_columns||'PERIODICITY_ID,YEAR,TYPE,PERIOD,'||h_lst_data_columns||')'||
                ' select /*+ use_hash(bsc_tmp_base_rowid) use_hash(bsc_tmp_base)*/ '||
                h_lst_key_columns_temp||'PERIODICITY_ID,YEAR,TYPE,PERIOD,';
      --Fix bug#4235448: insert null when find -999999999 for balance measure.
      for k in 1..x_num_data_columns loop
        if x_data_measure_types(k)=1 then
          l_stmt:=l_stmt||h_data_columns_temp(k)||',';
        else --for balance
          l_stmt:=l_stmt||'decode('||h_data_columns_temp(k)||',-999999999999,null,'||h_data_columns_temp(k)||'),';
        end if;
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1)||
              ' from bsc_tmp_base_rowid, bsc_tmp_base'||
              ' where bsc_tmp_base_rowid.row_id_tmp= bsc_tmp_base.rowid'||
              ' and bsc_tmp_base_rowid.row_id_base is null';
      BSC_UPDATE_UTIL.Execute_Immediate(l_stmt);
      commit;--we can have a commit only after both update and insert, otherwise there is data corruption
    end if;--if l_number_periodicity>0
    ---------------------------------------------------------------

    -- Fix bug#4463132: Truncate temporary table after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_BU');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_UPDATE');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_BAL');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE_BAL');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BASE_ROWID');

    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
	BSC_MESSAGE.Add(
		X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_BTABLE_UPDATE_FAILED'),
		X_Source => 'BSC_UPDATE_BASE.Update_Base_Table');
        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;

BSC_MESSAGE.Add(
X_Message => h_sql,
X_Source => 'BSC_UPDATE_BASE.Update_Base_Table');

	BSC_MESSAGE.Add(
		X_Message => SQLERRM,
		X_Source => 'BSC_UPDATE_BASE.Update_Base_Table');
        RETURN FALSE;

END Update_Base_Table;


-- AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Get_Base_AW_Table_Name
+============================================================================*/
FUNCTION Get_Base_AW_Table_Name(
	x_base_tbl IN VARCHAR2
    ) RETURN VARCHAR2 IS
    h_aw_table VARCHAR2(30);
BEGIN
    h_aw_table := x_base_tbl||'_AW';
    RETURN h_aw_table;
END Get_Base_AW_Table_Name;

END BSC_UPDATE_BASE;

/
