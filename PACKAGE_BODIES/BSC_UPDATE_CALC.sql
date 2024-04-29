--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_CALC" AS
/* $Header: BSCDCALB.pls 120.6 2006/03/07 13:37:07 meastmon noship $ */


/*===========================================================================+
| FUNCTION Apply_Filters
+============================================================================*/
FUNCTION Apply_Filters(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    -- If a table is used directly by an indicator, this table is in BSC_KPI_DATA_TABLES
    -- Additionally, a table is used by an indicator if it is connected to an indicator table
    -- by calculation type = 5 (Merge targets)
    -- We need to filter target tables.
    TYPE t_cursor IS REF CURSOR;

    /* c_indicator t_cursor;
    c_indicator_sql VARCHAR2(2000) := 'SELECT indicator, dim_set_id'||
                                      ' FROM bsc_kpi_data_tables'||
                                      ' WHERE table_name = :1 OR'||
                                      ' table_name = ('||
                                      ' SELECT DISTINCT table_name'||
                                      ' FROM bsc_db_calculations'||
                                      ' WHERE parameter1 = :2 AND'||
                                      ' calculation_type = :3)'; */
    cursor c_indicator( pTableName varchar2, pParam1 varchar2,pCalcType number) is
        SELECT indicator, dim_set_id
        FROM bsc_kpi_data_tables
        WHERE table_name = pTableName
        OR table_name = (
        SELECT DISTINCT table_name
        FROM bsc_db_calculations
        WHERE parameter1 = pParam1
        AND calculation_type = pCalcType );
    h_calculation_type NUMBER;

    h_indicator NUMBER;
    h_dim_set_id NUMBER;

    /* c_filters t_cursor;
    c_filters_sql VARCHAR2(2000) := 'SELECT d.level_pk_col, d.level_view_name'||
                                    ' FROM bsc_kpi_dim_levels_b d, bsc_db_tables_cols c'||
                                    ' WHERE d.indicator = :1 AND d.dim_set_id = :2 AND d.status = :3 AND'||
                                    ' d.level_view_name <> ('||
                                    ' SELECT level_view_name'||
                                    ' FROM bsc_sys_dim_levels_b s'||
                                    ' WHERE d.level_pk_col = s.level_pk_col) AND'||
                                    ' c.table_name = :4 AND'||
                                    ' c.column_name = d.level_pk_col AND'||
                                    ' c.column_type = :5'; */
    cursor c_filters(pIndicator number,pDimSetId number , pStatus number,
                     pTableName varchar2,pColumnType varchar2) is
         SELECT d.level_pk_col, d.level_view_name
         FROM bsc_kpi_dim_levels_b d, bsc_db_tables_cols c
         WHERE d.indicator =  pIndicator AND d.dim_set_id = pDimSetId
         AND d.status = pStatus
         AND d.level_view_name <> (SELECT level_view_name
               FROM bsc_sys_dim_levels_b s
               WHERE d.level_pk_col = s.level_pk_col)
         AND c.table_name = pTableName
         AND c.column_name = d.level_pk_col
         AND c.column_type = pColumnType;

    h_status NUMBER;
    h_column_type VARCHAR2(1);

    h_key_column_name VARCHAR2(30);
    h_view_name VARCHAR2(30);

    h_sql VARCHAR2(32700);

BEGIN

    h_calculation_type := 5;
    h_status := 2;
    h_column_type := 'P';

    -- Get the indicator and dimension set that uses the table
    -- OPEN c_indicator FOR c_indicator_sql USING x_table_name, x_table_name,  h_calculation_type;
    OPEN c_indicator(x_table_name,x_table_name,h_calculation_type);
    FETCH c_indicator INTO h_indicator, h_dim_set_id;
    IF c_indicator%NOTFOUND THEN
        -- The table is not used by any indicator. So, the table doesn't have filter.
        CLOSE c_indicator;
        RETURN TRUE;
    END IF;
    CLOSE c_indicator;

    -- Get the key columns and correspondig filter views for the table.
    -- OPEN c_filters FOR c_filters_sql USING h_indicator, h_dim_set_id, h_status, x_table_name, h_column_type;
    OPEN c_filters(h_indicator,h_dim_set_id,h_status,x_table_name,h_column_type);

    FETCH c_filters INTO h_key_column_name, h_view_name;
    WHILE c_filters%FOUND LOOP
        -- Delete from table those records that dont belong to filter view
        h_sql := 'DELETE FROM '||x_table_name||
                 ' WHERE '||h_key_column_name||' NOT IN ('||
                 ' SELECT CODE FROM '||h_view_name||
                 ')';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

        FETCH c_filters INTO h_key_column_name, h_view_name;
    END LOOP;
    CLOSE c_filters;


    RETURN TRUE;
EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_APPLY_FILTER_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Apply_Filters');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Apply_Filters');
        RETURN FALSE;
END Apply_Filters;


/*===========================================================================+
| FUNCTION Calculate_Profit
+============================================================================*/
FUNCTION Calculate_Profit(
	x_table_name IN VARCHAR2,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_key_dim_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_i NUMBER;
    h_sql VARCHAR2(32700);

    cursor c_account_key( pTableName varchar2,pCalcType number) is
        SELECT parameter1
        FROM bsc_db_calculations
        WHERE table_name = pTableName AND
              calculation_type = pCalcType ;

    h_calculation_type NUMBER;

    h_account_key VARCHAR2(30);

    cursor c_type_of_account_key( pLevelPkCol varchar2) is
        SELECT r.relation_col
        FROM bsc_sys_dim_levels_b e, bsc_sys_dim_level_rels r
        WHERE e.dim_level_id = r.dim_level_id AND
              e.level_pk_col = pLevelPkCol;

    h_type_of_account_key VARCHAR2(30);

    h_account_dim_table VARCHAR2(30);

    h_profit_account NUMBER;

    h_lst_keys_no_account VARCHAR2(32700);
    h_arr_keys_no_account BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_keys_no_account NUMBER;

    h_lst_data_columns VARCHAR2(32700);
    h_lst_sum_profit VARCHAR2(32700);

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;

    cursor c_dim_table_name(pLevelPkCol varchar2) is
        SELECT level_view_name
        FROM bsc_sys_dim_levels_b
        WHERE level_pk_col = pLevelPkCol;

    h_acc_key VARCHAR2(30);
    h_acc_table VARCHAR2(30);

BEGIN

    h_calculation_type := 1;
    h_lst_keys_no_account := NULL;
    h_lst_data_columns := NULL;
    h_lst_sum_profit := NULL;

    -- BSC-MV Note: In this architecture profit calculation is only calculated in the base table
    -- and the base table has sub_account not account.
    -- In this context h_account_key means subaccount

    -- Get the name of the account key
    OPEN c_account_key (x_table_name, h_calculation_type);
    FETCH c_account_key INTO h_account_key;
    IF c_account_key%NOTFOUND THEN
        RAISE e_unexpected_error;
    END IF;
    CLOSE c_account_key;

    IF h_account_key IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Initialize the array of keys that are not the account key
    h_num_keys_no_account := 0;

    FOR h_i IN 1 .. x_num_key_columns LOOP
        IF x_key_columns(h_i) <> h_account_key THEN
            IF h_lst_keys_no_account IS NULL THEN
                h_lst_keys_no_account := x_key_columns(h_i);
            ELSE
                h_lst_keys_no_account := h_lst_keys_no_account||', '||x_key_columns(h_i);
            END IF;

            h_num_keys_no_account := h_num_keys_no_account + 1;
            h_arr_keys_no_account(h_num_keys_no_account) := x_key_columns(h_i);
        ELSE
            h_account_dim_table := x_key_dim_tables(h_i);
        END IF;
    END LOOP;

    IF h_account_dim_table IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    h_arr_keys_no_account(h_num_keys_no_account + 1) := 'YEAR';
    h_arr_keys_no_account(h_num_keys_no_account + 2) := 'TYPE';
    h_arr_keys_no_account(h_num_keys_no_account + 3) := 'PERIOD';
    h_num_keys_no_account := h_num_keys_no_account + 3;

    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_arr_keys_no_account(h_num_keys_no_account + 1) := 'PERIODICITY_ID';
        h_num_keys_no_account := h_num_keys_no_account + 1;
    END IF;

    IF h_lst_keys_no_account IS NULL THEN
       h_lst_keys_no_account := 'YEAR, TYPE, PERIOD';
    ELSE
       h_lst_keys_no_account := h_lst_keys_no_account||', YEAR, TYPE, PERIOD';
    END IF;

    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_keys_no_account := h_lst_keys_no_account||', PERIODICITY_ID';
    END IF;

    -- Get the name of key column for type of account
    OPEN c_type_of_account_key (h_account_key);
    FETCH c_type_of_account_key INTO h_type_of_account_key;
    IF c_type_of_account_key%NOTFOUND THEN
        RAISE e_unexpected_error;
    END IF;
    CLOSE c_type_of_account_key;
    IF BSC_APPS.bsc_mv THEN
        -- Since h_account_key is subaccount, what we got was the key column
        -- for account. We need to do it again to get the type of account
        h_acc_key := h_type_of_account_key;
        OPEN c_type_of_account_key (h_acc_key);
        FETCH c_type_of_account_key INTO h_type_of_account_key;
        IF c_type_of_account_key%NOTFOUND THEN
           RAISE e_unexpected_error;
        END IF;
        CLOSE c_type_of_account_key;
    END IF;

    IF h_type_of_account_key IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the profit account
    IF NOT BSC_APPS.bsc_mv THEN
        h_sql := 'SELECT code'||
                 ' FROM '||h_account_dim_table||
                 ' WHERE '||h_type_of_account_key||' = :1';
        OPEN h_cursor FOR h_sql USING 3;
        FETCH h_cursor INTO h_profit_account;
        IF h_cursor%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE h_cursor;
    ELSE
        -- h_account_dim_table is the name of the subaccount table.
        -- I need the name of the account table
        OPEN c_dim_table_name(h_acc_key);
        FETCH c_dim_table_name INTO h_acc_table;
        IF c_dim_table_name%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE c_dim_table_name;

        h_sql := 'SELECT code'||
                 ' FROM '||h_account_dim_table||
                 ' WHERE '||h_acc_key||' = ('||
                 ' SELECT code'||
                 ' FROM '||h_acc_table||
                 ' WHERE '||h_type_of_account_key||' = :1)';
        OPEN h_cursor FOR h_sql USING 3;
        FETCH h_cursor INTO h_profit_account;
        IF h_cursor%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE h_cursor;
    END IF;

    -- Deletes the current profits records from the table
    l_bind_vars_values.delete;
    h_sql := 'DELETE FROM '||x_table_name||
             ' WHERE '||h_account_key||' = :1';
    l_bind_vars_values(1) := h_profit_account ;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
    --Fix bug#4116490 Need commit
    commit;

    -- Calculates the profit and insert it with the profit code

    -- Initialize a list with the data columns
    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);

    -- Get a list with the calculation of the profit for all data fields
    FOR h_i IN 1 .. x_num_data_columns LOOP
        IF h_lst_sum_profit IS NULL THEN
            IF BSC_APPS.bsc_mv THEN
                 h_lst_sum_profit := 'SUM(DECODE('||h_acc_table;
            ELSE
                 h_lst_sum_profit := 'SUM(DECODE('||h_account_dim_table;
            END IF;
            h_lst_sum_profit := h_lst_sum_profit||'.'||h_type_of_account_key||', '||
                                '1, '||x_table_name||'.'||x_data_columns(h_i)||', '||
                                '-'||x_table_name||'.'||x_data_columns(h_i)||'))';
        ELSE
            IF BSC_APPS.bsc_mv THEN
                h_lst_sum_profit := h_lst_sum_profit||', '||
                                'SUM(DECODE('||h_acc_table;
            ELSE
                h_lst_sum_profit := h_lst_sum_profit||', '||
                                'SUM(DECODE('||h_account_dim_table;
            END IF;
            h_lst_sum_profit := h_lst_sum_profit||'.'||h_type_of_account_key||', '||
                                '1, '||x_table_name||'.'||x_data_columns(h_i)||', '||
                                '-'||x_table_name||'.'||x_data_columns(h_i)||'))';
        END IF;
    END LOOP;

    -- Built and execute the query to calculate the profit
    h_sql := 'INSERT /*+ append ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'parallel ('||x_table_name||') ';
    end if;
    h_sql:=h_sql||' */';
    h_sql:=h_sql||'INTO '||x_table_name||
             ' ( '||h_account_key||', '||h_lst_keys_no_account||', '||h_lst_data_columns;
    IF x_aw_flag THEN
        h_sql:=h_sql||', PROJECTION, CHANGE_VECTOR';
    END IF;
    h_sql:=h_sql||') SELECT ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'/*+ parallel ('||x_table_name||') parallel ('||h_account_dim_table||')*/ ';
    end if;
    h_sql:=h_sql||h_profit_account||', '||
             BSC_UPDATE_UTIL.Make_Lst_Table_Column(x_table_name, h_arr_keys_no_account, h_num_keys_no_account)||', '||
             h_lst_sum_profit;
    IF x_aw_flag THEN
        h_sql:=h_sql||', '||x_table_name||'.PROJECTION, '||x_change_vector_value;
    END IF;
    h_sql:=h_sql||' FROM '||x_table_name||', '||h_account_dim_table;
    IF BSC_APPS.bsc_mv THEN
        h_sql := h_sql||', '||h_acc_table;
    END IF;
    h_sql := h_sql||' WHERE '||x_table_name||'.'||h_account_key||' = '||h_account_dim_table||'.CODE';
    IF BSC_APPS.bsc_mv THEN
        h_sql := h_sql||' AND '||h_account_dim_table||'.'||h_acc_key||' = '||h_acc_table||'.CODE';
    END IF;
    h_sql := h_sql||' GROUP BY '||
             BSC_UPDATE_UTIL.Make_Lst_Table_Column(x_table_name, h_arr_keys_no_account, h_num_keys_no_account);
    --Fix bug#4593671: add projection to the group by in aw architecture
    IF x_aw_flag THEN
        h_sql := h_sql||', '||x_table_name||'.PROJECTION';
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;
    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROFIT_CALC_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Calculate_Profit');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Calculate_Profit');
        RETURN FALSE;

END Calculate_Profit;


/*===========================================================================+
| FUNCTION Calculate_Proj_Avg_Last_Year
+============================================================================*/
FUNCTION Calculate_Proj_Avg_Last_Year(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_lst_data_temp IN VARCHAR2, -- list of data columns in the projection table i.e: 'DATA1, DATA5'
	x_current_fy IN NUMBER,
	x_num_of_years IN NUMBER,
	x_previous_years IN NUMBER,
     	x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_lst_keys VARCHAR2(32700);
    h_lst_keys_temp VARCHAR2(32700);
    h_lst_keys_tochar VARCHAR2(32700);
    h_lst_keys_nc VARCHAR2(32700);

    h_num_periods NUMBER;
    h_num_previous_periods NUMBER;

    h_i NUMBER;
    h_j NUMBER;

    h_sql VARCHAR2(32700);

    h_init_per NUMBER;

    h_min_year NUMBER;
    h_min_per NUMBER;

    h_yearly_flag NUMBER;

    h_uni_table VARCHAR2(32000);

    l_bind_vars_union BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars_union NUMBER;
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;
    l_bind_vars_post BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars_post NUMBER;

    h_key_columns_temp  BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_select VARCHAR2(32000);
    h_mv_name VARCHAR2(30);
    h_ref_table VARCHAR2(30);

    h_lst_data_columns VARCHAR2(32000);
    h_lst_data_columns_temp VARCHAR2(32000);
    h_lst_xmed_columns VARCHAR2(32000);
    h_lst_xmed_columns_p VARCHAR2(32000);
    h_lst_avg_columns VARCHAR2(32000);

BEGIN

    --ENH_PROJECTION_4235711: In this function we are going to calculate projection
    --in the table BSC_TMP_PROJ_CALC. Later we will merge the projection into the base/summary table
    --BSC_TMP_PROJ_CALC already have all the rows for the projected periods and only for the
    --dimension combinations we need to calculate projection

    -- Fix bug#4700221 Review this function completely. We need to consider projected periods already calculated
    -- in bsc_tmp_xmd in order to calculate the next projection periods. This is a truly moving average

    h_yearly_flag := 0;
    l_num_bind_vars_union := 0;
    l_num_bind_vars := 0;
    l_num_bind_vars_post := 0;
    h_lst_select := NULL;
    h_lst_data_columns := NULL;
    h_lst_data_columns_temp := NULL;
    h_lst_xmed_columns := NULL;
    h_lst_xmed_columns_p := NULL;
    h_lst_avg_columns := NULL;
    h_lst_keys_temp := NULL;
    h_lst_keys_tochar := NULL;

    -- New optimization: We are going to calculate projection on all data columns at the same time

    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
        h_lst_keys_temp := h_lst_keys_temp||'KEY'||h_i||' '||x_key_columns(h_i)||', ';
        h_lst_keys_tochar := h_lst_keys_tochar||'TO_CHAR('||x_key_columns(h_i)||') '||x_key_columns(h_i)||', ';
    END LOOP;

    h_lst_select := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_key_columns);

    h_lst_keys := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    h_lst_keys_nc := h_lst_keys;
    IF h_lst_keys IS NOT NULL THEN
        h_lst_keys := h_lst_keys||', ';
        h_lst_select := h_lst_select||', ';
    END IF;

    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);
    h_lst_xmed_columns := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('XMED', x_num_data_columns);

    FOR h_i IN 1..x_num_data_columns LOOP
        IF h_i > 1 THEN
            h_lst_avg_columns := h_lst_avg_columns||', ';
            h_lst_xmed_columns_p := h_lst_xmed_columns_p||', ';
            h_lst_data_columns_temp := h_lst_data_columns_temp||', ';
        END IF;

        h_lst_avg_columns := h_lst_avg_columns||'AVG('||x_data_columns(h_i)||')';
        h_lst_xmed_columns_p := h_lst_xmed_columns_p||'P.XMED'||h_i;
        h_lst_data_columns_temp := h_lst_data_columns_temp||'XMED'||h_i||' '||x_data_columns(h_i);
    END LOOP;

    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);

    --BSC-MV Note: In this architecture if the table is not a base table
    -- the projected data is in the summary table and the other data including
    -- targets are in the MV
    --AW_INTEGRATION: In this architecture we never calculate projection in PT tables, only
    -- in the base table. So no changes here
    IF BSC_APPS.bsc_mv AND (NOT x_is_base) THEN
        h_mv_name := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(x_table_name);
        h_ref_table := h_mv_name;
    ELSE
        h_ref_table := x_table_name;
    END IF;

    l_bind_vars_union.delete;
    l_num_bind_vars_union := 0;
    h_uni_table := '(SELECT '||h_lst_keys_tochar||'YEAR, TYPE, PERIOD, ';
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_uni_table := h_uni_table||'PERIODICITY_ID, ';
    END IF;
    h_uni_table := h_uni_table||h_lst_data_columns||
                   ' FROM '||h_ref_table||
                   ' WHERE TYPE = :1';
    l_num_bind_vars_union := l_num_bind_vars_union + 1;
    l_bind_vars_union(l_num_bind_vars_union) := 0;
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_uni_table := h_uni_table||' AND PERIODICITY_ID = :2';
        l_num_bind_vars_union := l_num_bind_vars_union + 1;
        l_bind_vars_union(l_num_bind_vars_union) := x_periodicity;
    END IF;
    IF h_yearly_flag = 1 THEN
        h_uni_table := h_uni_table||' AND YEAR <= :3';
        l_num_bind_vars_union := l_num_bind_vars_union + 1;
        l_bind_vars_union(l_num_bind_vars_union) := x_current_fy;
    ELSE
        h_uni_table := h_uni_table||' AND (YEAR < :3 OR (YEAR = :4 AND PERIOD <= :5))';
        l_num_bind_vars_union := l_num_bind_vars_union + 1;
        l_bind_vars_union(l_num_bind_vars_union) := x_current_fy;
        l_num_bind_vars_union := l_num_bind_vars_union + 1;
        l_bind_vars_union(l_num_bind_vars_union) := x_current_fy;
        l_num_bind_vars_union := l_num_bind_vars_union + 1;
        l_bind_vars_union(l_num_bind_vars_union) := x_period;
    END IF;
    h_uni_table := h_uni_table||' UNION '||
                   'SELECT '||h_lst_keys_temp||'YEAR, TYPE, PERIOD, ';
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_uni_table := h_uni_table||'PERIODICITY_ID, ';
    END IF;
    h_uni_table := h_uni_table||h_lst_data_columns_temp||
                   ' FROM bsc_tmp_xmd'||
                   ') u';

    IF h_yearly_flag = 1 THEN -- Annual
        -- For annual peridicity this method look back the number of previous years
        -- defined for the table
        h_num_periods := x_period + (x_num_of_years - x_previous_years) - 1;
        h_num_previous_periods := x_previous_years;
    ELSE
        -- For other periodicities this method looks one year back
        h_num_periods := BSC_UPDATE_UTIL.Get_Num_Periods_Periodicity(x_periodicity, x_current_fy);
        IF h_num_periods IS NULL THEN
            RAISE e_unexpected_error;
        END IF;

        h_num_previous_periods :=  h_num_periods;
    END IF;

    h_init_per := x_period + 1;

    --Fix bug#3875046: We are going to insert all the records in bsc_tmp_xmd for all the periods
    --and at the end we update the projection table BSC_TMP_PROJ_CALC only one time.
    --For this reason I need to take out from the loop this truncate stmt
    -- Delete all data from temporary table
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_XMD');
    commit;

    FOR h_i IN h_init_per .. h_num_periods LOOP
        l_bind_vars_values.delete;
        l_num_bind_vars := 0;
        l_bind_vars_post.delete;
        l_num_bind_vars_post := 0;

        IF h_yearly_flag = 1 THEN -- Annual
            h_min_year := h_i - h_num_previous_periods;
        ELSE
            h_min_year := x_current_fy - 1;
            -- Fix bug#4700221 moving average is not calculated correclty
            --h_min_per := h_num_periods - MOD(h_num_previous_periods - x_period, h_num_periods);
            h_min_per := h_i;
        END IF;

        -- Calculate the temporary table BSC_TMP_XMD with the average

        -- Insert
        l_bind_vars_values.delete ;
        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
         h_sql:=h_sql||'parallel (bsc_tmp_xmd) ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO bsc_tmp_xmd ('||h_lst_select||'YEAR, TYPE, PERIOD, ';
        -- AW_INTEGRATION: Base table does not have periodicity_id
        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            h_sql := h_sql||'PERIODICITY_ID, ';
        END IF;
        h_sql := h_sql||h_lst_xmed_columns||')';
        h_sql := h_sql||' SELECT ';
        IF h_yearly_flag = 1 THEN -- Annual
            h_sql := h_sql||h_lst_keys||':11, 0, 0, ';
            l_bind_vars_values(1) := h_i;
            l_num_bind_vars := 1;
        ELSE
            h_sql := h_sql||h_lst_keys||':11, 0, :12, ';
            l_bind_vars_values(1) := x_current_fy;
            l_bind_vars_values(2) := h_i;
            l_num_bind_vars := 2;
        END IF;
        -- AW_INTEGRATION: Base table does not have periodicity_id
        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            h_sql := h_sql||'PERIODICITY_ID, ';
        END IF;
        h_sql := h_sql||h_lst_avg_columns||
                 ' FROM '||h_uni_table;
        IF h_yearly_flag = 1 THEN --Annual
            h_sql := h_sql||' WHERE (year BETWEEN :13 AND :14) AND';
            l_bind_vars_post(1) := h_min_year;
            l_bind_vars_post(2) := h_i - 1;
            l_num_bind_vars_post := 2;
        ELSE
            h_sql := h_sql||' WHERE (year * 1000 + period) BETWEEN (:13'
                     ||' * 1000 + :14 ) AND (:15 * 1000 + :16) AND';
            l_bind_vars_post(1) := h_min_year;
            l_bind_vars_post(2) := h_min_per;
            l_bind_vars_post(3) := x_current_fy;
            l_bind_vars_post(4) := h_i - 1;
            l_num_bind_vars_post := 4;
        END IF;
        h_sql := h_sql||' type = 0';
        -- AW_INTEGRATION: Base table does not have periodicity_id
        IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
            h_sql := h_sql||' AND periodicity_id = :17';
            l_num_bind_vars_post := l_num_bind_vars_post + 1;
            l_bind_vars_post(l_num_bind_vars_post) := x_periodicity;
        END IF;

        IF h_lst_keys IS NOT NULL THEN
            h_sql := h_sql||' GROUP BY '||h_lst_keys_nc;
            -- AW_INTEGRATION: Base table does not have periodicity_id
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                h_sql := h_sql||', PERIODICITY_ID';
            END IF;
        ELSE
            -- Fix bug#3381324 If there is no key columns we need to group by periodicity_id
            -- AW_INTEGRATION: Base table does not have periodicity_id
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                h_sql := h_sql||' GROUP BY PERIODICITY_ID';
            END IF;
        END IF;

        FOR h_j IN 1..l_num_bind_vars_union LOOP
            l_num_bind_vars := l_num_bind_vars+1;
            l_bind_vars_values(l_num_bind_vars) := l_bind_vars_union(h_j);
        END LOOP;
        FOR h_j IN 1..l_num_bind_vars_post LOOP
            l_num_bind_vars := l_num_bind_vars+1;
            l_bind_vars_values(l_num_bind_vars) := l_bind_vars_post(h_j);
        END LOOP;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars);
        commit;

        l_bind_vars_values.delete;

        --Fix bug#3875046: We are going to insert all the records in bsc_tmp_xmd for all the periods
        --and at the end we update the base table only one time.
        --For this reason I need to take out from the loop the update part
    END LOOP;

    -- Update the projection table table BSC_TMP_PROJ_CALC
    -- Fix performance bug#3665014. Instead of update the base table with a complex query
    -- we are going to insert the records in BSC_TMP_XMD_Y with row_id
    -- and then update the base table.
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_XMD_Y');
    commit;

    h_sql := 'INSERT /*+ append ';
    IF BSC_UPDATE_UTIL.is_parallel THEN
        h_sql := h_sql||'parallel (BSC_TMP_XMD_Y) ';
    END IF;
    h_sql := h_sql||' */';
    h_sql := h_sql||' INTO BSC_TMP_XMD_Y (ROW_ID, '||h_lst_xmed_columns||')'||
             ' SELECT B.ROWID, '||h_lst_xmed_columns_p||
             ' FROM BSC_TMP_PROJ_CALC B, BSC_TMP_XMD P'||
             ' WHERE ';
    IF x_num_key_columns > 0 THEN
        h_sql := h_sql||
                 BSC_UPDATE_UTIL.Make_Lst_Cond_Join('B',
                                                    h_key_columns_temp,
                                                   'P',
                                                    h_key_columns_temp,
                                                    x_num_key_columns,
                                                    'AND')||
                 ' AND';
    END IF;
    h_sql := h_sql||' B.YEAR = P.YEAR AND B.TYPE = P.TYPE AND B.PERIOD = P.PERIOD';
    --AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND B.PERIODICITY_ID = P.PERIODICITY_ID';
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- Analyze the BSC_TMP_XMD_Y
    -- Bug#3740230: We cannot analyze. It is causing Loader hangs truncating this table
    -- Bug#3756654: Oracle 8i does not support gathering stacts on temporary tables
    --IF BSC_IM_UTILS.get_db_version <> '8i' THEN
    --    BSC_BIA_WRAPPER.Analyze_Table('BSC_TMP_XMD_Y');
    --END IF;

    -- Update the base table
    h_sql := 'UPDATE /*+ORDERED USE_NL(B)*/ BSC_TMP_PROJ_CALC B'||
             ' SET ('||x_lst_data_temp;
    h_sql := h_sql||') = ('||
             ' SELECT '||h_lst_xmed_columns;
    h_sql := h_sql||
             ' FROM BSC_TMP_XMD_Y P'||
             ' WHERE P.ROW_ID = B.ROWID)'||
             ' WHERE B.ROWID IN (SELECT ROW_ID FROM BSC_TMP_XMD_Y)';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- Fix bug#4463132: Truncate temporary table after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_XMD');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_XMD_Y');
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROJ_ALY_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Calculate_Proj_Avg_Last_Year');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Calculate_Proj_Avg_Last_Year');
        RETURN FALSE;

END Calculate_Proj_Avg_Last_Year;


/*===========================================================================+
| FUNCTION Calculate_Proj_3_Periods_Perf
+============================================================================*/
FUNCTION Calculate_Proj_3_Periods_Perf(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_lst_data_temp IN VARCHAR2, -- list of data columns in the projection table i.e: 'DATA1, DATA5'
        x_current_fy IN NUMBER,
        x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);

    h_num_per_back NUMBER;
    h_per_ini NUMBER;
    h_per_end NUMBER;
    h_num_pers NUMBER;

    h_lst_keys VARCHAR2(32700);
    h_lst_groupby VARCHAR2(32700);

    h_sql_join VARCHAR2(32700);

    h_yearly_flag NUMBER;

    h_uni_table VARCHAR2(30);

    -- Posco bind var fix
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    h_key_columns_temp  BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_select VARCHAR2(32700);
    h_lst_totplan VARCHAR2(32700);
    h_lst_totreal VARCHAR2(32700);
    h_lst_plan VARCHAR2(32700);
    h_lst_data VARCHAR2(32700);
    h_lst_data_p VARCHAR2(32700);
    h_lst_data_columns VARCHAR2(32700);
    h_lst_sumdata VARCHAR2(32700);
    h_lst_keys_p VARCHAR2(32700);
    h_lst_data_proj VARCHAR2(32700);

BEGIN

    --ENH_PROJECTION_4235711: In this function we are going to calculate projection
    --in the table BSC_TMP_PROJ_CALC. Later we will merge the projection into the base/summary table
    --BSC_TMP_PROJ_CALC already have all the rows for the projected periods and only for the
    --dimension combinations we need to calculate projection

    h_lst_keys := NULL;
    h_lst_groupby := NULL;
    h_sql_join := NULL;
    h_yearly_flag := 0;
    l_num_bind_vars := 0;
    h_lst_select := NULL;
    h_lst_totplan := NULL;
    h_lst_totreal := NULL;
    h_lst_plan := NULL;
    h_lst_data := NULL;
    h_lst_data_p := NULL;
    h_lst_data_columns := NULL;
    h_lst_sumdata := NULL;
    h_lst_keys_p := NULL;
    h_lst_data_proj := NULL;

    h_num_per_back := 3;

    -- BSC-MV Note: In this architecture if this is a summary table the it only
    -- contains the projections. Base information is on the MV
    --AW_INTEGRATION: In this architecture we never calculate projection in PT tables, only
    -- in the base table. So no changes here
    IF BSC_APPS.bsc_mv AND (NOT x_is_base) THEN
        h_uni_table := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(x_table_name);
    ELSE
        h_uni_table := x_table_name;
    END IF;

    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    h_lst_select := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_key_columns);

    h_lst_keys := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    h_lst_keys_p := BSC_UPDATE_UTIL.Make_Lst_Table_Column('P', h_key_columns_temp, x_num_key_columns);
    h_lst_groupby := h_lst_keys;

    IF h_lst_keys IS NOT NULL THEN
        h_lst_keys := h_lst_keys||', ';
        h_lst_keys_p := h_lst_keys_p||', ';
        h_lst_select := h_lst_select||', ';
    END IF;

    h_lst_totplan := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('TOTPLAN', x_num_data_columns);
    h_lst_totreal := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('TOTREAL', x_num_data_columns);
    h_lst_plan := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('PLAN', x_num_data_columns);
    h_lst_data := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('DATA', x_num_data_columns);
    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);

    FOR h_i IN 1..x_num_data_columns LOOP
        IF h_i > 1 THEN
            h_lst_sumdata := h_lst_sumdata||', ';
            h_lst_data_proj := h_lst_data_proj||', ';
            h_lst_data_p := h_lst_data_p||', ';
        END IF;

        h_lst_sumdata := h_lst_sumdata||'SUM('||x_data_columns(h_i)||')';

        h_lst_data_proj := h_lst_data_proj||
                           'case'||
                           ' when (tr.totreal'||h_i||'>0 and tp.totplan'||h_i||'>0) and'||
                           ' ((decode(tp.totplan'||h_i||',0,0,tr.totreal'||h_i||'/tp.totplan'||h_i||')*pp.plan'||h_i||')>(2*pp.plan'||h_i||'))'||
                           ' then 2*pp.plan'||h_i||''||
                           ' when tr.totreal'||h_i||'>0 and tp.totplan'||h_i||'>0'||
                           ' then (tr.totreal'||h_i||'/tp.totplan'||h_i||')*pp.plan'||h_i||''||
                           ' when ((tr.totreal'||h_i||'<0 and tp.totplan'||h_i||'<0) or (tr.totreal'||h_i||'<0 and tp.totplan'||h_i||'>0) or'||
                           ' (tr.totreal'||h_i||'>0 and tp.totplan'||h_i||'<0)) and (pp.plan'||h_i||'=0 or (pp.plan'||h_i||' IS NULL))'||
                           ' then (tr.totreal'||h_i||'-tp.totplan'||h_i||')/3'||
                           ' when ((tr.totreal'||h_i||'<0 and tp.totplan'||h_i||'<0) or (tr.totreal'||h_i||'<0 and tp.totplan'||h_i||'>0) or'||
                           ' (tr.totreal'||h_i||'>0 AND tp.totplan'||h_i||'<0)) and not(pp.plan'||h_i||'=0 or (pp.plan'||h_i||' IS NULL))'||
                           ' then pp.plan'||h_i||'+((tr.totreal'||h_i||'-tp.totplan'||h_i||')/3)'||
                           ' when (tr.totreal'||h_i||'<>0 and (tp.totplan'||h_i||'=0 or (tp.totplan'||h_i||' is null))) and'||
                           ' (pp.plan'||h_i||'=0 or (pp.plan'||h_i||' is null))'||
                           ' then tr.totreal'||h_i||'/3'||
                           ' when (tr.totreal'||h_i||'<>0 and (tp.totplan'||h_i||'=0 or (tp.totplan'||h_i||' is null))) and'||
                           ' not(pp.plan'||h_i||'=0 or (pp.plan'||h_i||' is null))'||
                           ' then pp.plan'||h_i||'+(tr.totreal'||h_i||'/3)'||
                           ' when ((tr.totreal'||h_i||'=0 or (tr.totreal'||h_i||' is null)) and'||
                           ' (tp.totplan'||h_i||'=0 or (tp.totplan'||h_i||' is null)))'||
                           ' then pp.plan'||h_i||''||
                           ' end';

        h_lst_data_p := h_lst_data_p||'P.DATA'||h_i;

    END LOOP;

    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    IF h_yearly_flag = 1 THEN -- Annual
        h_per_end := x_current_fy;
        h_per_ini := x_current_fy - h_num_per_back + 1;
        h_num_pers := h_per_end - h_per_ini + 1;
    ELSE
        h_per_end := x_period;
        h_per_ini := x_period - h_num_per_back + 1;

        IF h_per_ini <= 0 THEN
            h_per_ini := 1;
        END IF;

        h_num_pers := h_per_end - h_per_ini + 1;
    END IF;

    -- Make a temporal table with the total of plan data of the last n-periods,
    -- where n is the value of the variable h_num_per_back
    --h_sql := 'DELETE FROM BSC_TMP_TOT_PLAN';
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_PLAN');
    commit;

    l_bind_vars_values.delete ;
    h_sql := 'INSERT /*+ append ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'parallel (bsc_tmp_tot_plan) ';
    end if;
    h_sql:=h_sql||' */';
    h_sql:=h_sql||'INTO BSC_TMP_TOT_PLAN ('||h_lst_select||'TYPE, '||h_lst_totplan||')'||
             ' SELECT ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'/*+ parallel ('||h_uni_table||')*/ ';
    end if;
    h_sql:=h_sql||h_lst_keys||'0, '||h_lst_sumdata||
             ' FROM '||h_uni_table;
    IF h_yearly_flag = 1 THEN
        h_sql := h_sql||' WHERE YEAR >= :1 '||
                 ' And YEAR <= :2 '||
                 ' And TYPE = :3'||
                 ' And PERIOD = :4';
       l_bind_vars_values(1) := h_per_ini;
       l_bind_vars_values(2) := h_per_end;
       l_bind_vars_values(3) := 1;
       l_bind_vars_values(4) := 0;
       l_num_bind_vars := 4;
    ELSE
        h_sql := h_sql||' WHERE YEAR = :1'||
                 ' And TYPE = :2'||
                 ' And PERIOD >= :3'||
                 ' And PERIOD <= :4';
       l_bind_vars_values(1) := x_current_fy;
       l_bind_vars_values(2) := 1 ;
       l_bind_vars_values(3) := h_per_ini ;
       l_bind_vars_values(4) := h_per_end ;
       l_num_bind_vars := 4;
    END IF;
    --AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND PERIODICITY_ID = :5';
        l_bind_vars_values(5) := x_periodicity;
        l_num_bind_vars := 5;
    END IF;
    IF h_lst_groupby IS NOT NULL THEN
        h_sql := h_sql||' GROUP BY '||h_lst_groupby;
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars);
    commit;

    -- Make a temporal table with the total of real data of the last n-periods,
    -- where n is the value of the variable h_num_per_back
    --h_sql := 'DELETE FROM BSC_TMP_TOT_REAL';
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_REAL');
    commit;

    l_bind_vars_values.delete ;
    h_sql := 'INSERT /*+ append ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'parallel (bsc_tmp_tot_real) ';
    end if;
    h_sql:=h_sql||' */';
    h_sql:=h_sql||'INTO BSC_TMP_TOT_REAL('||h_lst_select||'TYPE, '||h_lst_totreal||')'||
             ' SELECT ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'/*+ parallel ('||h_uni_table||')*/ ';
    end if;
    h_sql:=h_sql||h_lst_keys||'0, '||h_lst_sumdata||
             ' FROM '||h_uni_table;
    IF h_yearly_flag = 1 THEN
         h_sql := h_sql||' WHERE YEAR >= :1'||
                 ' And YEAR <= :2'||
                 ' And TYPE = :3'||
                 ' And PERIOD = :4';
         l_bind_vars_values(1) := (h_per_ini);
         l_bind_vars_values(2) := (h_per_end);
         l_bind_vars_values(3) := 0;
         l_bind_vars_values(4) := 0;
         l_num_bind_vars := 4;
    ELSE
        h_sql := h_sql||' WHERE YEAR = :1'||
                 ' And TYPE = :2'||
                 ' And PERIOD >= :3'||
                 ' And PERIOD <= :4';
         l_bind_vars_values(1) := (x_current_fy);
         l_bind_vars_values(2) := 0 ;
         l_bind_vars_values(3) := (h_per_ini) ;
         l_bind_vars_values(4) := (h_per_end) ;
         l_num_bind_vars := 4;
    END IF;
    -- AW_INTEGRATION: Base table does not have peridicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND PERIODICITY_ID = :5';
        l_bind_vars_values(5) := (x_periodicity);
        l_num_bind_vars := 5;
    END IF;
    IF h_lst_groupby IS NOT NULL THEN
        h_sql := h_sql||' GROUP BY '||h_lst_groupby;
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars );
    commit;

    -- Make a temporal table with the plan of the projected periods
    --h_sql := 'DELETE FROM BSC_TMP_PLAN_PROJECTIONS';
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PLAN_PROJECTIONS');
    commit;

    l_bind_vars_values.delete;
    h_sql := 'INSERT /*+ append ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'parallel (BSC_TMP_PLAN_PROJECTIONS) ';
    end if;
    h_sql:=h_sql||' */';
    h_sql:=h_sql||'INTO BSC_TMP_PLAN_PROJECTIONS ('||h_lst_select||'YEAR, TYPE, PERIOD, '||h_lst_plan||')'||
             ' SELECT ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'/*+ parallel ('||h_uni_table||')*/ ';
    end if;
    h_sql:=h_sql||h_lst_keys||'YEAR, 0, PERIOD, '||h_lst_data_columns||
             ' FROM '||h_uni_table;
    l_bind_vars_values.delete ;
    IF h_yearly_flag = 1 THEN
        h_sql := h_sql||' WHERE YEAR > :1'||
                 ' AND TYPE = :2'||
                 ' AND PERIOD = :3';
        l_bind_vars_values(1) := (h_per_end);
        l_bind_vars_values(2) := 1;
        l_bind_vars_values(3) := 0;
        l_num_bind_vars  := 3;
    ELSE
        h_sql := h_sql||' WHERE YEAR = :1'||
                 ' AND TYPE = :2'||
                 ' AND PERIOD > :3';
        l_bind_vars_values(1) := (x_current_fy);
        l_bind_vars_values(2) := 1;
        l_bind_vars_values(3) := (h_per_end) ;
        l_num_bind_vars  := 3;
    END IF;
    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND PERIODICITY_ID = :4';
        l_bind_vars_values(4) := (x_periodicity);
        l_num_bind_vars := 4;
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars);
    commit;

    -- Calculate the projection in temporal table BSC_TMP_PROJECTIONS
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJECTIONS');
    commit;

    l_bind_vars_values.delete;
    h_sql := 'INSERT /*+ append ';
    if BSC_UPDATE_UTIL.is_parallel then
      h_sql:=h_sql||'parallel (BSC_TMP_PROJECTIONS) ';
    end if;
    h_sql:=h_sql||' */';
    h_sql:=h_sql||'INTO BSC_TMP_PROJECTIONS ('||h_lst_select||'YEAR, TYPE, PERIOD, ';
    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||'PERIODICITY_ID, ';
    END IF;
    h_sql := h_sql||h_lst_data||')'||
             ' SELECT '||h_lst_keys_p||'P.YEAR, P.TYPE, P.PERIOD, ';
    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||'P.PERIODICITY_ID, ';
    END IF;
    h_sql := h_sql||h_lst_data_proj||
             ' FROM BSC_TMP_PROJ_CALC P, BSC_TMP_TOT_PLAN TP, BSC_TMP_TOT_REAL TR, BSC_TMP_PLAN_PROJECTIONS PP'||
             ' WHERE ';
    IF x_num_key_columns > 0 THEN
        h_sql := h_sql||
                 BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join('P',
                                                         h_key_columns_temp,
                                                         'TP',
	  	    	                                 h_key_columns_temp,
							 x_num_key_columns,
						         'AND')||
                 ' AND ';
    END IF;
    h_sql := h_sql||'P.TYPE = TP.TYPE (+) AND ';
    IF x_num_key_columns > 0 THEN
        h_sql := h_sql||
                 BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join('P',
                                                         h_key_columns_temp,
                                                         'TR',
	  	    	                                 h_key_columns_temp,
							 x_num_key_columns,
						         'AND')||
                 ' AND ';
    END IF;
    h_sql := h_sql||'P.TYPE = TR.TYPE (+) AND ';
    IF x_num_key_columns > 0 THEN
        h_sql := h_sql||
                 BSC_UPDATE_UTIL.Make_Lst_Cond_Left_Join('P',
                                                         h_key_columns_temp,
                                                         'PP',
	  	    	                                 h_key_columns_temp,
							 x_num_key_columns,
						         'AND')||
                 ' AND ';
    END IF;
    h_sql := h_sql||'P.YEAR = PP.YEAR (+) AND P.TYPE = PP.TYPE (+) AND P.PERIOD = PP.PERIOD (+) AND ';
    l_bind_vars_values.delete ;
    IF h_yearly_flag = 1 THEN
        h_sql := h_sql||'P.YEAR > :1 AND P.TYPE = :2 AND P.PERIOD = :3';
        l_bind_vars_values(1) := (h_per_end);
        l_bind_vars_values(2) := 0;
        l_bind_vars_values(3) := 0;
        l_num_bind_vars := 3;
    ELSE
        h_sql := h_sql||'P.YEAR = :1 AND P.TYPE = :2 AND P.PERIOD > :3';
        l_bind_vars_values(1) := (x_current_fy);
        l_bind_vars_values(2) := 0;
        l_bind_vars_values(3) := (h_per_end) ;
        l_num_bind_vars := 3;
    END IF;
    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND P.PERIODICITY_ID = :4';
        l_bind_vars_values(4) := (x_periodicity);
        l_num_bind_vars := 4;
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars);
    commit;

    l_bind_vars_values.delete;

    -- Update the projection table BSC_TMP_PROJ_CALC
    -- Fix performance bug#3665014. Instead of update the base table with a complex query
    -- we are going to insert the records in BSC_TMP_PROJECTIONS_Y with row_id
    -- and then update the base table.

    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJECTIONS_Y');
    commit;

    h_sql := 'INSERT /*+ append ';
    IF BSC_UPDATE_UTIL.is_parallel THEN
        h_sql := h_sql||'parallel (BSC_TMP_PROJECTIONS_Y) ';
    END IF;
    h_sql := h_sql||' */';
    h_sql := h_sql||' INTO BSC_TMP_PROJECTIONS_Y (ROW_ID, '||h_lst_data||')'||
             ' SELECT B.ROWID, '||h_lst_data_p||
             ' FROM BSC_TMP_PROJ_CALC B, BSC_TMP_PROJECTIONS P'||
             ' WHERE ';
    IF x_num_key_columns > 0 THEN
        h_sql := h_sql||
                 BSC_UPDATE_UTIL.Make_Lst_Cond_Join('B',
                                                    h_key_columns_temp,
                                                    'P',
                                                    h_key_columns_temp,
                                                    x_num_key_columns,
                                                    'AND')||
                 ' AND';
    END IF;
    h_sql := h_sql||' B.YEAR = P.YEAR AND B.TYPE = P.TYPE AND B.PERIOD = P.PERIOD';
    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND B.PERIODICITY_ID = P.PERIODICITY_ID';
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- Analyze the BSC_TMP_PROJECTIONS_Y
    -- Bug#3740230: We cannot analyze. It is causing Loader hangs truncating this table
    -- Bug#3756654: Oracle 8i does not support gathering stacts on temporary tables
    --IF BSC_IM_UTILS.get_db_version <> '8i' THEN
    --    BSC_BIA_WRAPPER.Analyze_Table('BSC_TMP_PROJECTIONS_Y');
    --END IF;

    -- Update the projection table BSC_TMP_PROJ_CALC
    h_sql := 'UPDATE /*+ORDERED USE_NL(B)*/ BSC_TMP_PROJ_CALC B'||
             ' SET ('||x_lst_data_temp;
    h_sql := h_sql||') = ('||
             ' SELECT '||h_lst_data;
    h_sql := h_sql||
             ' FROM BSC_TMP_PROJECTIONS_Y P'||
             ' WHERE P.ROW_ID = B.ROWID)'||
             ' WHERE B.ROWID IN (SELECT ROW_ID FROM BSC_TMP_PROJECTIONS_Y)';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- Fix bug#4463132: Truncate temporary table after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_PLAN');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_REAL');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PLAN_PROJECTIONS');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJECTIONS');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJECTIONS_Y');
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROJ_THREEMONTH_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Calculate_Proj_3_Periods_Perf');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Calculate_Proj_3_Periods_Perf');
        RETURN FALSE;

END Calculate_Proj_3_Periods_Perf;


/*===========================================================================+
| FUNCTION Calculate_Proj_User_Defined
+============================================================================*/
FUNCTION Calculate_Proj_User_Defined(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_data_columns IN NUMBER,
        x_lst_data_temp IN VARCHAR2, -- list of data columns in the projection table i.e: 'DATA1, DATA5'
        x_current_fy IN NUMBER,
     	x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);

    h_yearly_flag NUMBER;

    h_src_table VARCHAR2(30);

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    h_lst_data_columns VARCHAR2(32700);

    h_key_columns_temp  BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_i NUMBER;

BEGIN
    h_yearly_flag := 0;
    l_num_bind_vars := 0;
    h_lst_data_columns := NULL;

    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);

    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    --BSC-MV Note: In this architecture if this is a summary table the
    -- the custom projection TYPE=90 is in the MV.
    --AW_INTEGRATION: In this architecture we never calculate projection on PT tables,
    -- only on base tables, so no changes here
    IF BSC_APPS.bsc_mv AND (NOT x_is_base) THEN
        h_src_table := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(x_table_name);
    ELSE
        h_src_table := x_table_name;
    END IF;

    l_bind_vars_values.delete;

    h_sql := 'UPDATE BSC_TMP_PROJ_CALC T'||
             ' SET ('||x_lst_data_temp;
    h_sql := h_sql||') = ('||
             ' SELECT '||h_lst_data_columns;
    h_sql := h_sql||
             ' FROM '||h_src_table||' B'||
             ' WHERE ';
    IF x_num_key_columns > 0 THEN
        h_sql := h_sql||
                 BSC_UPDATE_UTIL.Make_Lst_Cond_Join('T',
                                                    h_key_columns_temp,
                                                    'B',
                                                    x_key_columns,
                                                    x_num_key_columns,
                                                    'AND')||
                 ' AND ';
    END IF;
    --AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||'T.PERIODICITY_ID = B.PERIODICITY_ID AND ';
    END IF;
    h_sql := h_sql||'T.YEAR = B.YEAR'||
             ' AND T.PERIOD = B.PERIOD'||
             ' AND B.TYPE = 90'||
             ')';
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    IF h_yearly_flag = 1 THEN -- Annual
        h_sql := h_sql||' WHERE T.YEAR > :1'||
                 ' AND T.TYPE = :2'||
                 ' AND T.PERIOD = :3';
        l_bind_vars_values(1) := x_period;
        l_bind_vars_values(2) := 0;
        l_bind_vars_values(3) := 0;
        l_num_bind_vars := 3;
    ELSE
        h_sql := h_sql||' WHERE T.YEAR = :1'||
                 ' AND T.TYPE = :2'||
                 ' AND T.PERIOD > :3';
        l_bind_vars_values(1) := x_current_fy;
        l_bind_vars_values(2) := 0;
        l_bind_vars_values(3) := x_period;
        l_num_bind_vars := 3;
    END IF;
    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_sql := h_sql||' AND T.PERIODICITY_ID = :4';
        l_bind_vars_values(4) := x_periodicity;
        l_num_bind_vars := 4;
    END IF;

    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,l_num_bind_vars);
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROJ_UD_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Calculate_Proj_User_Defined');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Calculate_Proj_User_Defined');
        RETURN FALSE;

END Calculate_Proj_User_Defined;


/*===========================================================================+
| FUNCTION Calculate_Projection
+============================================================================*/
FUNCTION Calculate_Projection(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
	x_current_fy IN NUMBER,
	x_num_of_years IN NUMBER,
	x_previous_years IN NUMBER,
	x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_i NUMBER;

    h_sql VARCHAR2(32000);
    h_lst_key_columns VARCHAR2(32000);
    h_lst_data_columns VARCHAR2(32000);
    h_mv_name VARCHAR2(30);
    h_yearly_flag NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

    h_data_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_data_columns NUMBER;

    h_lst_data_temp VARCHAR2(32000);

BEGIN

    h_lst_key_columns := NULL;
    h_lst_data_columns := NULL;
    h_lst_data_temp := NULL;

    --ENH_PROJECTION_4235711: Please review changes in this function and the functions called from here.
    -- We are going to calculate the projection in a temporary table called BSC_TMP_PROJ_CALC
    -- If it is a base table:
    --   1. If the new current period is greater than the current period then we nedd to calculate
    --      projection for all the dimensions combinations.
    --   2. If the new current period is equal to the current perido then we need to calculate projection
    --      only for the dimension combinations coming from bsc_tmp_base (rows from the input table)
    -- If it is in MV architecture we do not merge to the base/summary table here. There will be
    -- another function that will rollup the projection in BSC_TMP_PROJ_CALC to higher periodicities
    -- and then we will merge to the base/summary table once. This is to reduce the hit to the base table
    -- If it is Summary Tables Architecture or the table if for AW we know that there are no higher
    -- periodicities so we merge to the base/summary table here.

--BSC_UPDATE_LOG.Write_Line_Log('Calculating projection in '||x_table_name, BSC_UPDATE_LOG.LOG);

    -- BSC-MV Note: In this architecture the summary table correspond to the projection table.
    -- The projection table was created to store the projection for indicators
    -- with targets at different levels.

    -- Init BSC_TMP_PROJ_CALC with the rows for projection for the dimension combinations
    -- we need to recalculate projection
    -- AW_INTEGRATION: pass x_aw_flag to Init_Projection_Table
    IF NOT Init_Projection_Table(x_table_name,
                                 x_periodicity,
                                 x_key_columns,
                                 x_num_key_columns,
                                 x_current_fy,
                                 x_period,
				 x_is_base,
                                 x_aw_flag,
                                 x_change_vector_value) THEN
        RAISE e_unexpected_error;
    END IF;

    -- From now on we are going to calculate projection on all the data columns with same
    -- projection method at the same time.

    -- Method 1: Avg last year
    h_num_data_columns := 0;
    h_lst_data_temp := NULL;
    FOR h_i IN 1 .. x_num_data_columns LOOP
        IF x_data_proj_methods(h_i) = 1 THEN
            h_num_data_columns := h_num_data_columns + 1;
            h_data_columns(h_num_data_columns) := x_data_columns(h_i);
            IF h_lst_data_temp IS NULL THEN
                h_lst_data_temp := 'DATA'||h_i;
            ELSE
                h_lst_data_temp := h_lst_data_temp||', DATA'||h_i;
            END IF;
        END IF;
    END LOOP;

    IF h_num_data_columns > 0 THEN
        -- AW_INTEGRATION: Pass x_aw_flag to Calculate_Proj_Avg_Last_Year
        IF NOT Calculate_Proj_Avg_Last_Year(x_table_name,
                                            x_periodicity,
 	    	                            x_period,
	                                    x_key_columns,
		    			    x_num_key_columns,
			    		    h_data_columns,
                                            h_num_data_columns,
                                            h_lst_data_temp,
	                                    x_current_fy,
					    x_num_of_years,
					    x_previous_years,
                                            x_is_base,
                                            x_aw_flag) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    -- Method 3: Last 3 Periods Performance
    h_num_data_columns := 0;
    h_lst_data_temp := NULL;
    FOR h_i IN 1 .. x_num_data_columns LOOP
        IF x_data_proj_methods(h_i) = 3 THEN
            h_num_data_columns := h_num_data_columns + 1;
            h_data_columns(h_num_data_columns) := x_data_columns(h_i);
            IF h_lst_data_temp IS NULL THEN
                h_lst_data_temp := 'DATA'||h_i;
            ELSE
                h_lst_data_temp := h_lst_data_temp||', DATA'||h_i;
            END IF;
        END IF;

        -- We can calculate projection on maximum 25 measures at the time.
        -- This restriction is for the big sql generated.
        IF (h_num_data_columns = 25) OR ((h_i = x_num_data_columns) AND (h_num_data_columns > 0)) THEN
            -- AW_INTEGRATION: Pass x_aw_flag to Calculate_Proj_3_Periods_Perf
            IF NOT Calculate_Proj_3_Periods_Perf(x_table_name,
                                                 x_periodicity,
                                                 x_period,
                                                 x_key_columns,
                                                 x_num_key_columns,
                                                 h_data_columns,
                                                 h_num_data_columns,
                                                 h_lst_data_temp,
                                                 x_current_fy,
                                                 x_is_base,
                                                 x_aw_flag) THEN
                RAISE e_unexpected_error;
            END IF;
            h_num_data_columns := 0;
            h_lst_data_temp := NULL;
        END IF;
    END LOOP;

    -- Method 4: Custom projection
    h_num_data_columns := 0;
    h_lst_data_temp := NULL;
    FOR h_i IN 1 .. x_num_data_columns LOOP
        IF x_data_proj_methods(h_i) = 4 THEN
            h_num_data_columns := h_num_data_columns + 1;
            h_data_columns(h_num_data_columns) := x_data_columns(h_i);
            IF h_lst_data_temp IS NULL THEN
                h_lst_data_temp := 'DATA'||h_i;
            ELSE
                h_lst_data_temp := h_lst_data_temp||', DATA'||h_i;
            END IF;
        END IF;
    END LOOP;

    IF h_num_data_columns > 0 THEN
        -- AW_INTEGRATION: pass x_aw_flag to Calculate_Proj_User_Defined
        IF NOT Calculate_Proj_User_Defined(x_table_name,
                                           x_periodicity,
                                           x_period,
                                           x_key_columns,
                                           x_num_key_columns,
                                           h_data_columns,
                                           h_num_data_columns,
                                           h_lst_data_temp,
                                           x_current_fy,
                                           x_is_base,
                                           x_aw_flag) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    -- If we are in Summary tables architecture or AW we merge to the base table here
    -- If it is MV architecture we meger to the base table later when the projection
    -- have been rolled up to higher periodicities
    IF (NOT BSC_APPS.bsc_mv) OR x_aw_flag THEN
        IF NOT Merge_Projection(x_table_name,
                                x_key_columns,
                                x_num_key_columns,
                                x_data_columns,
                                x_num_data_columns,
                                x_is_base,
                                x_aw_flag) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Fix bug#4463132: Truncate temporary table after use
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJ_CALC');
        commit;
    END IF;

--BSC_UPDATE_LOG.Write_Line_Log('End Calculating projection in '||x_table_name, BSC_UPDATE_LOG.LOG);

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROJ_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Calculate_Projection');
        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Calculate_Projection');
        RETURN FALSE;

END Calculate_Projection;


/*===========================================================================+
| FUNCTION Calculate_Zero_Code
+============================================================================*/
FUNCTION Calculate_Zero_Code(
	x_table_name IN VARCHAR2,
        x_zero_code_calc_method IN NUMBER,
        x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_src_table IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    -- x_zero_code_calc_method = 4
    -- Calculate the zero code for one or more key columns that
    -- are independents (Example: region_code, product_code)

    -- Meaning of parameters in bsc_db_calculations
    -- parameter1 = key column name
    -- parameter2 = order
    -- parameter3 = data column name
    -- parameter4 = condition
    -- parameter5 = expression or formula

    TYPE t_cursor IS REF CURSOR;

    h_sql 	VARCHAR2(32700);
    h_i 	NUMBER;
    h_j		NUMBER;
    h_count	NUMBER;

    cursor c_key_columns(pTableName varchar2, pCalcType number,
                         pSrcTableName varchar2, pSrcCalcType number) is
       SELECT parameter1
       FROM bsc_db_calculations
       WHERE table_name = pTableName
       AND calculation_type = pCalcType
       AND parameter1 NOT IN (
           SELECT parameter1
           FROM bsc_db_calculations
           WHERE table_name = pSrcTableName
           AND calculation_type = pSrcCalcType
           )
       GROUP BY parameter1, TO_NUMBER(parameter2)
       ORDER BY TO_NUMBER(parameter2);

    h_key_zero_code 	bsc_db_calculations.parameter1%TYPE;

    cursor c_keys_needing_zero_code(pTableName varchar2) is
        SELECT DISTINCT c.parameter1
        FROM bsc_db_calculations c, bsc_kpi_data_tables kt, bsc_kpi_data_tables ktp
        WHERE c.table_name = kt.table_name AND
              c.calculation_type = 4 AND
              kt.indicator = ktp.indicator AND
              kt.dim_set_id = ktp.dim_set_id AND
              ktp.table_name = pTableName;

    h_key VARCHAR2(50);

    cursor c_data_columns(pTableName varchar2,pColumnType varchar2) is
        SELECT column_name, source_formula
        FROM  bsc_db_tables_cols
        WHERE table_name = pTableName AND column_type = pColumnType;

    --Fix bug#5057247 fix data type of this variables
    h_data_column 	bsc_db_tables_cols.column_name%TYPE;
    h_expression 	bsc_db_tables_cols.source_formula%TYPE;

    h_lst_where		VARCHAR2(32700);
    h_lst_keys	 	VARCHAR2(32700);
    h_lst_select	VARCHAR2(32700);
    h_lst_groupby  	VARCHAR2(32700);

    h_lst_data_columns	VARCHAR2(32700);
    h_lst_expressions   VARCHAR2(32700);

    CURSOR c_pt_name (p_sum_table VARCHAR2) IS
        SELECT DISTINCT projection_data
        FROM bsc_kpi_data_tables
        WHERE table_name = p_sum_table;

    h_ref_table VARCHAR2(30);

    h_zero_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_zero_key_columns NUMBER;

    h_column_type VARCHAR2(10);

BEGIN
    h_lst_where	:= NULL;
    h_lst_keys := NULL;
    h_lst_select := NULL;
    h_lst_groupby := NULL;
    h_lst_data_columns := NULL;
    h_lst_expressions := NULL;
    h_ref_table := NULL;

    -- BSC-MV Note: If this procedure is called, then the summary table has a
    -- corresponding projection table. The zero codes will be calculated on the projection
    -- table for all the periodicities. PERIODICITY_ID and PERIOD_TYPE_ID will be
    -- considered as key columns.
    IF BSC_APPS.bsc_mv THEN
        OPEN c_pt_name(x_table_name);
        FETCH c_pt_name INTO h_ref_table;
        CLOSE c_pt_name;
    ELSE
        h_ref_table := x_table_name;
    END IF;

    -- Get the keys for zero codes
    h_num_zero_key_columns := 0;
    OPEN c_key_columns (x_table_name, x_zero_code_calc_method, x_src_table, x_zero_code_calc_method);
    FETCH c_key_columns INTO h_key_zero_code;
    WHILE c_key_columns%FOUND LOOP
        h_num_zero_key_columns := h_num_zero_key_columns + 1;
        h_zero_key_columns(h_num_zero_key_columns) := h_key_zero_code;

        FETCH c_key_columns INTO h_key_zero_code;
    END LOOP;
    CLOSE c_key_columns;

    -- Bug#3542344: Only in summary tables architecture, when this table receives targets,
    -- we need to re-calculate the zero code on keys needing zero.
    -- Keys needing zero code may not be configured in bsc_db_calculations for this table,
    -- for this reason we need to look in the origin tables until the base table looking
    -- for the keys that calcualted zero code.
    IF NOT BSC_APPS.bsc_mv THEN
        -- Only for summary tables architecture
        SELECT count(table_name)
        INTO h_count
        FROM bsc_db_calculations
        WHERE table_name = x_table_name AND calculation_type = 5;

        IF h_count > 0 THEN
            -- This table receives targets
            -- We need to re-calculate zero code in all the keys needing zero cdoe.

            -- The next cursor returns all the key columns calculating zero code
            -- between the tables used by the indicator and dim_set_id using this table.
            -- If this table is using one of those keys and the key is not
            -- already in h_zero_key_columns then we ned to add it.
            OPEN c_keys_needing_zero_code(x_table_name);
            LOOP
                FETCH c_keys_needing_zero_code INTO h_key;
                EXIT WHEN c_keys_needing_zero_code%NOTFOUND;

                IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_key, x_key_columns, x_num_key_columns) THEN
                    IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_key, h_zero_key_columns, h_num_zero_key_columns) THEN
                        h_num_zero_key_columns := h_num_zero_key_columns + 1;
                        h_zero_key_columns(h_num_zero_key_columns) := h_key;
                    END IF;
                END IF;
            END LOOP;
            CLOSE c_keys_needing_zero_code;
        END IF;
    END IF;

    -- Note: We only use and support method 4.

    IF h_num_zero_key_columns = 0 THEN
        -- No columns to calculate zero code
        RETURN TRUE;
    END IF;

    -- Delete existing zero codes
    -- BSC-BIS-DIMENSIONS: Need to use '0' in the condition to be compatible with
    -- NUMBER of VARCHAR2 in the key columns
    FOR h_j IN 1..h_num_zero_key_columns LOOP
        IF h_lst_where IS NULL THEN
            h_lst_where := '('||h_zero_key_columns(h_j)||' = ''0'')';
        ELSE
            h_lst_where := h_lst_where||' OR ('||h_zero_key_columns(h_j)||' = ''0'')';
        END IF;
    END LOOP;

    h_sql := 'DELETE FROM '||h_ref_table||
             ' WHERE '||h_lst_where;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    -- Fix bug#4116490 need commit
    commit;

    -- Data columns
    h_lst_data_columns := NULL;
    h_lst_expressions := NULL;

    h_column_type := 'A';
    OPEN c_data_columns (x_table_name, h_column_type) ;
    FETCH c_data_columns INTO h_data_column, h_expression;
    WHILE c_data_columns%FOUND LOOP
        IF h_lst_data_columns IS NULL THEN
            h_lst_data_columns := h_data_column;
        ELSE
            h_lst_data_columns := h_lst_data_columns||', '||h_data_column;
        END IF;

        IF h_lst_expressions IS NULL THEN
            h_lst_expressions := h_expression;
        ELSE
            h_lst_expressions := h_lst_expressions||', '||h_expression;
        END IF;

        FETCH c_data_columns INTO h_data_column, h_expression;
    END LOOP;
    CLOSE c_data_columns;

    -- Calculate the zero code per each key column
    FOR h_j IN 1..h_num_zero_key_columns LOOP
        -- Get each part of the query

        -- Keys columns
        h_lst_keys := x_key_columns(1);
        IF x_key_columns(1) = h_zero_key_columns(h_j) THEN
            h_lst_select := '''0''';
            h_lst_groupby := NULL;
        ELSE
            h_lst_select := x_key_columns(1);
            h_lst_groupby := x_key_columns(1);
        END IF;

        FOR h_i IN 2 .. x_num_key_columns LOOP
            h_lst_keys := h_lst_keys||', '||x_key_columns(h_i);

            IF x_key_columns(h_i) = h_zero_key_columns(h_j) THEN
                h_lst_select := h_lst_select||', ''0''';
            ELSE
                h_lst_select := h_lst_select||', '||x_key_columns(h_i);
                IF h_lst_groupby IS NULL THEN
                    h_lst_groupby := x_key_columns(h_i);
                ELSE
                    h_lst_groupby := h_lst_groupby||', '||x_key_columns(h_i);
                END IF;
            END IF;
        END LOOP;

        h_lst_keys := h_lst_keys||', YEAR, TYPE, PERIOD';
        h_lst_select := h_lst_select||', YEAR, TYPE, PERIOD';
        IF h_lst_groupby IS NULL THEN
            h_lst_groupby := 'YEAR, TYPE, PERIOD';
        ELSE
            h_lst_groupby := h_lst_groupby||', YEAR, TYPE, PERIOD';
        END IF;

        --BSC-MV Note: Add periodicity_id and period_type_id
        IF BSC_APPS.bsc_mv THEN
            h_lst_keys := h_lst_keys||', PERIODICITY_ID, PERIOD_TYPE_ID';
            h_lst_select := h_lst_select||', PERIODICITY_ID, PERIOD_TYPE_ID';
            IF h_lst_groupby IS NULL THEN
                 h_lst_groupby := 'PERIODICITY_ID, PERIOD_TYPE_ID';
            ELSE
                 h_lst_groupby := h_lst_groupby||', PERIODICITY_ID, PERIOD_TYPE_ID';
            END IF;
        END IF;

        -- Insert the zero code for the key column, h_zero_key_columns(h_j)
        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
          h_sql:=h_sql||'parallel ('||h_ref_table||') ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO '||h_ref_table||
                 ' ('||h_lst_keys||', '||h_lst_data_columns||')'||
                 ' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
          h_sql:=h_sql||'/*+ parallel ('||h_ref_table||')*/ ';
        end if;
        h_sql:=h_sql||h_lst_select||', '||h_lst_expressions||
                 ' FROM '||h_ref_table;
        h_sql := h_sql||' GROUP BY '||h_lst_groupby;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        commit;
    END LOOP;
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_ZEROCODE_CALC_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Calculate_Zero_Code');
        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Calculate_Zero_Code');
        RETURN FALSE;

END Calculate_Zero_Code;


/*===========================================================================+
| FUNCTION Create_Proj_Temps
+============================================================================*/
FUNCTION Create_Proj_Temps(
        x_periodicity IN NUMBER,
        x_current_fy IN NUMBER,
        x_num_of_years IN NUMBER,
        x_previous_years IN NUMBER,
        x_trunc_proj_table IN BOOLEAN
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);
    h_i NUMBER;

    h_init_period NUMBER;
    h_end_period NUMBER;

    h_calendar_col_name VARCHAR2(30);

    h_calendar_id NUMBER;
    h_yearly_flag NUMBER;
    h_edw_flag NUMBER;

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;

BEGIN

    h_yearly_flag := 0;
    h_edw_flag := 0;

    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    h_edw_flag := BSC_UPDATE_UTIL.Get_Periodicity_EDW_Flag(x_periodicity);
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity);

    -- BSC_TMP_ALL_PERIODS
    --h_sql := 'DELETE FROM BSC_TMP_ALL_PERIODS';
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_ALL_PERIODS');
    commit;

    IF h_yearly_flag = 1 THEN -- Annual
        h_init_period := x_current_fy - x_previous_years;
        h_end_period := h_init_period + x_num_of_years - 1;

        FOR h_i IN h_init_period..h_end_period LOOP
            l_bind_vars_values.delete ;
            h_sql := 'INSERT INTO BSC_TMP_ALL_PERIODS (PERIOD)'||
                     ' VALUES (:1)';
            l_bind_vars_values(1) := (h_i);
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
        END LOOP;
    ELSE
        -- Periodicity different to Annual
        IF h_edw_flag = 0 THEN
            -- BSC periodicity
            h_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);

            l_bind_vars_values.delete ;
            h_sql := 'INSERT INTO BSC_TMP_ALL_PERIODS'||
                     ' SELECT DISTINCT '||h_calendar_col_name||
                     ' FROM bsc_db_calendar'||
                     ' WHERE YEAR = :1'||' AND CALENDAR_ID = :2'||
                     ' GROUP BY '||h_calendar_col_name;
            l_bind_vars_values(1) := (x_current_fy);
            l_bind_vars_values(2) := (h_calendar_id) ;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);
        ELSE
            -- EDW periodicity
            h_init_period := 1;
            h_end_period := BSC_INTEGRATION_APIS.Get_Number_Of_Periods(x_current_fy, x_periodicity, h_calendar_id);
            IF BSC_APPS.CheckError('BSC_INTEGRATION_APIS.Get_Number_Of_Periods') THEN
 	         RAISE e_unexpected_error;
            END IF;

            FOR h_i IN h_init_period..h_end_period LOOP
                l_bind_vars_values.delete ;
                h_sql := 'INSERT INTO BSC_TMP_ALL_PERIODS (PERIOD)'||
                         ' VALUES (:1)';
                l_bind_vars_values(1) := (h_i) ;
                BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
            END LOOP;
        END IF;
    END IF;

    --ENH_PROJECTION_4235711: truncate projectio table
    IF x_trunc_proj_table THEN
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PROJ_CALC');
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROJ_TTABLES_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Create_Proj_Temps');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Create_Proj_Temps');
        RETURN FALSE;

END Create_Proj_Temps;


/*===========================================================================+
| FUNCTION Init_Projection_Table
+============================================================================*/
FUNCTION Init_Projection_Table(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
        x_current_fy IN NUMBER,
        x_current_period IN NUMBER,
        x_is_base IN BOOLEAN,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN IS

    h_i NUMBER;
    h_sql VARCHAR2(32700);

    h_ref_table VARCHAR2(30);

    h_lst_table_keys VARCHAR2(32700);
    h_lst_table_keys_a VARCHAR2(32700);
    h_lst_keys VARCHAR2(32700);
    h_lst_keys_nc VARCHAR2(32700);

    h_yearly_flag NUMBER;

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    h_key_columns_temp  BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_select VARCHAR2(32000);

    h_old_current_period NUMBER;

BEGIN

    h_lst_table_keys := NULL;
    h_lst_table_keys_a := NULL;
    h_lst_keys := NULL;
    h_lst_keys_nc := NULL;
    h_yearly_flag := 0;
    l_num_bind_vars := 0;
    h_lst_select := NULL;

    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    IF x_is_base THEN
        SELECT current_period
        INTO h_old_current_period
        FROM bsc_db_tables
        WHERE table_name = x_table_name;

        IF x_current_period > h_old_current_period THEN
            -- New current period, then we need to recalculate projection for all
            -- dimension combinations existing in the base table
            h_ref_table := x_table_name;

            h_lst_table_keys := BSC_UPDATE_UTIL.Make_Lst_Table_Column(h_ref_table,
                                                                      x_key_columns,
                                                                      x_num_key_columns);

            h_lst_table_keys_a := BSC_UPDATE_UTIL.Make_Lst_Table_Column('A',
                                                                        x_key_columns,
                                                                        x_num_key_columns);

            h_lst_keys_nc := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
        ELSE
            -- There is no change in the current period, then we just need to
            -- recalculate projection for dimension combinations coming from
            -- the input table
            h_ref_table := 'BSC_TMP_BASE';

            h_lst_table_keys := BSC_UPDATE_UTIL.Make_Lst_Table_Column(h_ref_table,
                                                                      h_key_columns_temp,
                                                                      x_num_key_columns);

            h_lst_table_keys_a := BSC_UPDATE_UTIL.Make_Lst_Table_Column('A',
                                                                        h_key_columns_temp,
                                                                        x_num_key_columns);

            h_lst_keys_nc := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_key_columns);
        END IF;
    ELSE
        --AW_INTEGRATION: In this architecture we do not calculate projections in PT tables
        -- only on base tables. So we know that the code does not get here. No changes here.
        IF BSC_APPS.bsc_mv THEN
            h_ref_table := BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(x_table_name);
        ELSE
            h_ref_table := x_table_name;
        END IF;

        h_lst_table_keys := BSC_UPDATE_UTIL.Make_Lst_Table_Column(h_ref_table,
                                                                  x_key_columns,
                                                                  x_num_key_columns);

        h_lst_table_keys_a := BSC_UPDATE_UTIL.Make_Lst_Table_Column('A',
                                                                    x_key_columns,
                                                                    x_num_key_columns);

        h_lst_keys_nc := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    END IF;

    h_lst_select := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_key_columns);

    IF h_lst_table_keys IS NOT NULL THEN
        h_lst_table_keys := h_lst_table_keys||', ';
        h_lst_table_keys_a := h_lst_table_keys_a||', ';
        h_lst_select := h_lst_select||', ';
    END IF;

    -- AW_INTEGRATION: Base table does not have periodicity_id
    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_table_keys := h_lst_table_keys||h_ref_table||'.PERIODICITY_ID, ';
        h_lst_table_keys_a := h_lst_table_keys_a||'A.PERIODICITY_ID, ';
        h_lst_select := h_lst_select||'PERIODICITY_ID, ';

        IF h_lst_keys_nc IS NULL THEN
            h_lst_keys_nc := 'PERIODICITY_ID';
        ELSE
            h_lst_keys_nc := h_lst_keys_nc||', PERIODICITY_ID';
        END IF;

        IF NOT x_is_base THEN
            h_lst_table_keys := h_lst_table_keys||h_ref_table||'.PERIOD_TYPE_ID, ';
            h_lst_table_keys_a := h_lst_table_keys_a||'A.PERIOD_TYPE_ID, ';
            h_lst_select := h_lst_select||'PERIOD_TYPE_ID, ';
            h_lst_keys_nc := h_lst_keys_nc||', PERIOD_TYPE_ID';
        END IF;
    END IF;

    -- BSC-MV Note: Add condition on periodicity_id for new architecture
    -- Insert in the projection table BSC_TMP_PROJ_CALC the rows for the projected periods.
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    l_bind_vars_values.delete ;
    IF h_yearly_flag = 1 THEN -- Annual
        h_sql := 'INSERT /*+ append ';
        IF BSC_UPDATE_UTIL.is_parallel THEN
            h_sql := h_sql||'parallel (BSC_TMP_PROJ_CALC) ';
        END IF;
        h_sql := h_sql||' */'||
                 ' INTO BSC_TMP_PROJ_CALC ('||h_lst_select||'YEAR, TYPE, PERIOD';
        -- AW_INTEGRATION: insert projection and change vector too
        IF x_aw_flag THEN
            h_sql := h_sql||', PROJECTION, CHANGE_VECTOR';
        END IF;
        h_sql := h_sql||')'||
                 ' SELECT /*+ ordered */ '||h_lst_table_keys_a||'bsc_tmp_all_periods.period, 0, 0';
        -- AW_INTEGRATION: insert Y to projection column  and x_change_vector to change_vector column
        IF x_aw_flag THEN
            h_sql := h_sql||', ''Y'', '||x_change_vector_value;
        END IF;
        h_sql := h_sql||' FROM ';
        IF h_lst_keys_nc IS NOT NULL THEN
            h_sql := h_sql||'('||
                     '   SELECT DISTINCT '||h_lst_keys_nc||
                     '   FROM '||h_ref_table;
            -- AW_INTEGRATION: Base table does not have periodicity_id
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                h_sql := h_sql||' WHERE PERIODICITY_ID = :1';
            END IF;
            h_sql := h_sql||' ) A, ';
        END IF;
        h_sql := h_sql||'bsc_tmp_all_periods'||
                ' WHERE bsc_tmp_all_periods.period > :2';
        -- AW_INTEGRATION: Base table does not have periodicity_id
        IF (BSC_APPS.bsc_mv) AND (NOT x_aw_flag) AND (h_lst_keys_nc IS NOT NULL) THEN
            l_bind_vars_values(1) := (x_periodicity);
            l_bind_vars_values(2) := (x_current_fy);
            l_num_bind_vars := 2;
        ELSE
            l_bind_vars_values(1) := (x_current_fy);
            l_num_bind_vars := 1;
        END IF;
    ELSE
        h_sql := 'INSERT /*+ append ';
        IF BSC_UPDATE_UTIL.is_parallel THEN
            h_sql := h_sql||'parallel (BSC_TMP_PROJ_CALC) ';
        END IF;
        h_sql := h_sql||' */'||
                 ' INTO BSC_TMP_PROJ_CALC ('||h_lst_select||'YEAR, TYPE, PERIOD';
        -- AW_INTEGRATION: insert projection and change vector too
        IF x_aw_flag THEN
            h_sql := h_sql||', PROJECTION, CHANGE_VECTOR';
        END IF;
        h_sql := h_sql||')'||
                 ' SELECT /*+ ordered */ '||h_lst_table_keys_a||':1, 0, bsc_tmp_all_periods.period';
        -- AW_INTEGRATION: insert Y to projection column  and x_change_vector to change_vector column
        IF x_aw_flag THEN
            h_sql := h_sql||', ''Y'', '||x_change_vector_value;
        END IF;
        h_sql := h_sql||' FROM ';
        IF h_lst_keys_nc IS NOT NULL THEN
            h_sql := h_sql||'('||
                     '   SELECT DISTINCT '||h_lst_keys_nc||
                     '   FROM '||h_ref_table;
            -- AW_INTEGRATION: Base table does not have periodicity_id
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                h_sql := h_sql||' WHERE PERIODICITY_ID = :2';
            END IF;
            h_sql := h_sql||' ) A, ';
        END IF;
        h_sql := h_sql||'bsc_tmp_all_periods'||
                 ' WHERE bsc_tmp_all_periods.period > :3';
        -- AW_INTEGRATION: Base table does not have periodicity_id
        IF (BSC_APPS.bsc_mv) AND (NOT x_aw_flag) AND (h_lst_keys_nc IS NOT NULL) THEN
            l_bind_vars_values(1) := (x_current_fy);
            l_bind_vars_values(2) := (x_periodicity);
            l_bind_vars_values(3) := (x_current_period);
            l_num_bind_vars := 3;
        ELSE
            l_bind_vars_values(1) := (x_current_fy);
            l_bind_vars_values(2) := (x_current_period);
            l_num_bind_vars := 2;
        END IF;
    END IF;
    commit;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Init_Projection_Table');
        RETURN FALSE;

END Init_Projection_Table;


/*===========================================================================+
| FUNCTION Delete_Projection
+============================================================================*/
FUNCTION Delete_Projection(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
	x_period IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
        x_current_fy IN NUMBER,
        x_is_base IN BOOLEAN
	) RETURN BOOLEAN IS

    h_i NUMBER;
    h_sql VARCHAR2(32700);

    h_lst_set VARCHAR2(32700);

    h_yearly_flag NUMBER;

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars  NUMBER;

BEGIN
    h_lst_set := NULL;
    h_yearly_flag := 0;
    l_num_bind_vars := 0;

    FOR h_i IN 1 .. x_num_data_columns LOOP
        -- If it is a base table the delete the projection from all the data columns
        -- This is because some data column could had projection in the past but now
        -- do not aply projection
        IF x_is_base OR (x_data_proj_methods(h_i) <> 0) THEN
            IF h_lst_set IS NULL THEN
                h_lst_set := x_data_columns(h_i)||' = NULL';
            ELSE
                h_lst_set := h_lst_set||', '||x_data_columns(h_i)||' = NULL';
            END IF;
        END IF;
    END LOOP;

    IF h_lst_set IS NOT NULL THEN
        h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
        l_bind_vars_values.delete ;
        IF h_yearly_flag = 1 THEN
            h_sql := 'UPDATE '||x_table_name||
                     ' SET '||h_lst_set||
                     ' WHERE YEAR > :1'||' AND TYPE = :2';
            l_bind_vars_values(1) := (x_period);
            l_bind_vars_values(2) := 0 ;
            l_num_bind_vars := 2 ;

            -- BSC-MV Note: Add condition on periodicity_id
            IF BSC_APPS.bsc_mv THEN
                h_sql := h_sql||' AND PERIODICITY_ID = :3';
                l_bind_vars_values(3) := x_periodicity;
                l_num_bind_vars := 3;
            END IF;
        ELSE
            h_sql := 'UPDATE '||x_table_name||
                     ' SET '||h_lst_set||
                     ' WHERE YEAR = :1'||' AND PERIOD > :2'||' AND TYPE = :3';
            l_bind_vars_values(1) := (x_current_fy);
            l_bind_vars_values(2) := (x_period) ;
            l_bind_vars_values(3) := 0 ;
            l_num_bind_vars := 3 ;

            -- BSC-MV Note: Add condition on periodicity_id
            IF BSC_APPS.bsc_mv THEN
                h_sql := h_sql||' AND PERIODICITY_ID = :4';
                l_bind_vars_values(4) := x_periodicity;
                l_num_bind_vars := 4;
            END IF;
        END IF;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Delete_Projection');
        RETURN FALSE;

END Delete_Projection;


/*===========================================================================+
| FUNCTION Delete_Projection_Base_Table
+============================================================================*/
FUNCTION Delete_Projection_Base_Table(
	x_table_name IN VARCHAR2,
	x_periodicity IN NUMBER,
	x_current_period IN NUMBER,
        x_new_current_period IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_proj_methods IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
        x_current_fy IN NUMBER,
        x_aw_flag IN BOOLEAN,
        x_change_vector_value IN NUMBER
	) RETURN BOOLEAN IS

    h_i NUMBER;
    h_sql VARCHAR2(32700);

    h_lst_set VARCHAR2(32700);
    h_lst_where VARCHAR2(32700);

    h_yearly_flag NUMBER;

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars  NUMBER;

BEGIN
    h_lst_set := NULL;
    h_lst_where := NULL;
    h_yearly_flag := 0;
    l_num_bind_vars := 0;

    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);

    --ENH_PROJECTION_4235711: Do this only if new current period > current period
    IF x_new_current_period > x_current_period THEN
        FOR h_i IN 1 .. x_num_data_columns LOOP
            -- Delete the projection from all the data columns
            IF h_lst_set IS NULL THEN
                h_lst_set := x_data_columns(h_i)||' = NULL';
                h_lst_where := x_data_columns(h_i)||' IS NOT NULL';
            ELSE
                h_lst_set := h_lst_set||', '||x_data_columns(h_i)||' = NULL';
                h_lst_where := h_lst_where||' OR '||x_data_columns(h_i)||' IS NOT NULL';
            END IF;
        END LOOP;

        IF h_lst_set IS NOT NULL THEN
            l_bind_vars_values.delete ;
            IF h_yearly_flag = 1 THEN
                -- There is no need to delete projection for yearly periodicity
                -- The condition will be  year > current_fy and year <= current_fy
                -- which always is false.
                NULL;
            ELSE
                -- AW_INTEGRATION: Need to set projection column to 'N' and change_vector to x_change_vector value
                IF BSC_APPS.bsc_mv AND x_aw_flag THEN
                    h_lst_set := h_lst_set||', projection = ''N'', change_vector = '||x_change_vector_value;
                END IF;

                h_sql := 'UPDATE '||x_table_name||
                         ' SET '||h_lst_set||
                         ' WHERE YEAR = :1 AND PERIOD > :2 AND PERIOD <= :3 AND TYPE = :4';
                l_bind_vars_values(1) := (x_current_fy);
                l_bind_vars_values(2) := (x_current_period) ;
                l_bind_vars_values(3) := (x_new_current_period) ;
                l_bind_vars_values(4) := 0 ;
                l_num_bind_vars := 4 ;

                -- BSC-MV Note: Add condition on periodicity_id
                -- AW_INTEGRATION: If the base table is for AW then there is no higher periodicities
                -- and there is no PERIODICITY_ID column.
                IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                    h_sql := h_sql||' AND PERIODICITY_ID = :5';
                    l_bind_vars_values(5) := x_periodicity;
                    l_num_bind_vars := 5;
                END IF;

                -- Fix bug#4653405 AW_INTEGRATION: in AW  we need update the rows no matter if the data
                -- columns are already null, since we have to update the projection flag to N
                IF NOT x_aw_flag THEN
                    h_sql := h_sql||' AND ('||h_lst_where||')';
                END IF;
                BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
            END IF;
        END IF;
    END IF;

    -- Now delete the projection for data columns with no projection method
    h_lst_set := NULL;
    h_lst_where := NULL;

    FOR h_i IN 1 .. x_num_data_columns LOOP
        IF x_data_proj_methods(h_i) = 0 THEN
            IF h_lst_set IS NULL THEN
                h_lst_set := x_data_columns(h_i)||' = NULL';
                h_lst_where := x_data_columns(h_i)||' IS NOT NULL';
            ELSE
                h_lst_set := h_lst_set||', '||x_data_columns(h_i)||' = NULL';
                h_lst_where := h_lst_where||' OR '||x_data_columns(h_i)||' IS NOT NULL';
            END IF;
        END IF;
    END LOOP;

    IF h_lst_set IS NOT NULL THEN
        -- AW_INTEGRATION: Need to set projection column to 'N' and change_vector to x_change_vector_value
        -- Fix bug#4653405: AW_INTEGRATION: we cannot set projection = 'N' here, it remains in Y
        IF BSC_APPS.bsc_mv AND x_aw_flag THEN
            h_lst_set := h_lst_set||', change_vector = '||x_change_vector_value;
        END IF;

        l_bind_vars_values.delete ;
        IF h_yearly_flag = 1 THEN
            h_sql := 'UPDATE '||x_table_name||
                     ' SET '||h_lst_set||
                     ' WHERE YEAR > :1'||' AND TYPE = :2';
            l_bind_vars_values(1) := (x_current_period);
            l_bind_vars_values(2) := 0 ;
            l_num_bind_vars := 2 ;

            -- BSC-MV Note: Add condition on periodicity_id
            -- AW_INTEGRATION: If the base table is for AW then there is not periodicity_id
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                h_sql := h_sql||' AND PERIODICITY_ID = :3';
                l_bind_vars_values(3) := x_periodicity;
                l_num_bind_vars := 3;
            END IF;
        ELSE
            h_sql := 'UPDATE '||x_table_name||
                     ' SET '||h_lst_set||
                     ' WHERE YEAR = :1'||' AND PERIOD > :2'||' AND TYPE = :3';
            l_bind_vars_values(1) := (x_current_fy);
            l_bind_vars_values(2) := (x_current_period) ;
            l_bind_vars_values(3) := 0 ;
            l_num_bind_vars := 3 ;

            -- BSC-MV Note: Add condition on periodicity_id
            -- AW_INTEGRATION: If the base table is for AW then there is not periodicity_id
            IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
                h_sql := h_sql||' AND PERIODICITY_ID = :4';
                l_bind_vars_values(4) := x_periodicity;
                l_num_bind_vars := 4;
            END IF;
        END IF;
        h_sql := h_sql||' AND ('||h_lst_where||')';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Delete_Projection_Base_Table');
        RETURN FALSE;

END Delete_Projection_Base_Table;


/*===========================================================================+
| FUNCTION Drop_Proj_Temps
+============================================================================*/
FUNCTION Drop_Proj_Temps RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);
    h_table_name VARCHAR2(30);

    e_unexpected_error EXCEPTION;

BEGIN
    -- Now we use generic temporary tables. We do not drop these tables.
    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Drop_Proj_Temps');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Drop_Proj_Temps');
        RETURN FALSE;

END Drop_Proj_Temps;


/*===========================================================================+
| FUNCTION Get_Zero_Code_Calc_Method
+============================================================================*/
FUNCTION Get_Zero_Code_Calc_Method(
	x_table_name IN VARCHAR2
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /* c_calculation_type t_cursor;
    c_calculation_type_sql VARCHAR2(2000) := 'SELECT calculation_type'||
                                             ' FROM bsc_db_calculations'||
                                             ' WHERE table_name = :1 AND'||
                                             ' (calculation_type = :2 OR calculation_type = :3)'; */
   cursor c_calculation_type ( pTableName varchar2, pCalcType number, pCalcType2 number ) is
   SELECT calculation_type
   FROM bsc_db_calculations
   WHERE table_name = pTableName
   AND (calculation_type = pCalcType OR calculation_type = pCalcType2) ;

    h_calculation_type NUMBER;

BEGIN
    -- OPEN c_calculation_type FOR c_calculation_type_sql USING x_table_name, 3, 4;
    OPEN c_calculation_type (x_table_name, 3, 4);
    FETCH c_calculation_type INTO h_calculation_type;
    IF c_calculation_type%NOTFOUND THEN
        h_calculation_type := 0;
    END IF;
    CLOSE c_calculation_type;

    IF h_calculation_type IS NULL THEN
        h_calculation_type := 0;
    END IF;

    RETURN h_calculation_type;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Get_Zero_Code_Calc_Method');
        RETURN NULL;

END Get_Zero_Code_Calc_Method;


/*===========================================================================+
| FUNCTION Merge_Data_From_Tables
+============================================================================*/
FUNCTION Merge_Data_From_Tables(
	x_table_name IN VARCHAR2,
        x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_key_columns IN NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /* c_source_tables t_cursor;
    c_source_tables_sql VARCHAR2(2000) := 'SELECT DISTINCT parameter1'||
                                          ' FROM bsc_db_calculations'||
                                          ' WHERE table_name = :1 AND'||
                                          ' calculation_type = :2'; */
    cursor c_source_tables(pTableName varchar2, pCalcType number) is
        SELECT DISTINCT parameter1
        FROM bsc_db_calculations
        WHERE table_name = pTableName
        AND calculation_type =  pCalcType ;

    h_source_table VARCHAR2(30);

    /* c_data_columns t_cursor;
    c_data_columns_sql VARCHAR2(2000) := 'SELECT parameter2'||
                                         ' FROM bsc_db_calculations'||
                                         ' WHERE table_name = :1 AND'||
                                         ' calculation_type = :2 AND'||
                                         ' parameter1 = :3';          */
    cursor c_data_columns(pTableName varchar2,pCalcType number, pParam1 varchar2) is
    SELECT parameter2
    FROM bsc_db_calculations
    WHERE table_name =  pTableName
    AND calculation_type = pCalcType
    AND parameter1 = pParam1 ;

    h_data_column VARCHAR2(30);

    h_sql VARCHAR2(32700);
    h_lst_data_columns VARCHAR2(32700);
    h_lst_key_columns VARCHAR2(32700);

BEGIN
    h_lst_data_columns := NULL;
    h_lst_key_columns := NULL;

    -- Get the list of key columns
    h_lst_key_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    IF h_lst_key_columns IS NOT NULL THEN
        h_lst_key_columns := h_lst_key_columns||', ';
    END IF;

    -- Loop within the source tables
    -- OPEN c_source_tables FOR c_source_tables_sql USING x_table_name, 5;
    OPEN c_source_tables (x_table_name, 5);
    FETCH c_source_tables INTO h_source_table;
    WHILE c_source_tables%FOUND LOOP
        -- Get list of data columns
        h_lst_data_columns := NULL;
        OPEN c_data_columns (x_table_name, 5, h_source_table);
        FETCH c_data_columns INTO h_data_column;
        WHILE c_data_columns%FOUND LOOP
            IF h_lst_data_columns IS NOT NULL THEN
                h_lst_data_columns := h_lst_data_columns||',';
            END IF;
            h_lst_data_columns := h_lst_data_columns||h_data_column;
            FETCH c_data_columns INTO h_data_column;
        END LOOP;
        CLOSE c_data_columns;

        -- Update rows existing in the target table
        h_sql := 'UPDATE '||x_table_name||' T'||
                 ' SET ('||h_lst_data_columns||') = ('||
                 '     SELECT '||h_lst_data_columns||
                 '     FROM '||h_source_table||' S'||
                 '     WHERE ';
        IF x_num_key_columns > 0 THEN
            h_sql := h_sql||
                     BSC_UPDATE_UTIL.Make_Lst_Cond_Join('T', x_key_columns,
                                                        'S', x_key_columns,
                                                        x_num_key_columns, 'AND')||
                     ' AND ';
        END IF;
        h_sql := h_sql||
                 '     T.YEAR = S.YEAR AND T.TYPE = S.TYPE AND T.PERIOD = S.PERIOD'||
                 '     )'||
                 ' WHERE ('||h_lst_key_columns||'YEAR, TYPE, PERIOD) IN ('||
                 '     SELECT '||h_lst_key_columns||'YEAR, TYPE, PERIOD'||
                 '     FROM '||h_source_table||
                 '     )';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        --Fix bug#4116490 need commit
        commit;

        -- Insert new rows
        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
         h_sql:=h_sql||'parallel ('||x_table_name||') ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO '||x_table_name||
                 ' ('||h_lst_key_columns||'YEAR, TYPE, PERIOD,'||h_lst_data_columns||')'||
                 ' SELECT ';
       if BSC_UPDATE_UTIL.is_parallel then
        h_sql:=h_sql||'/*+ parallel ('||h_source_table||')*/ ';
       end if;
       h_sql:=h_sql||h_lst_key_columns||'YEAR, TYPE, PERIOD,'||h_lst_data_columns||
                 ' FROM '||h_source_table||
                 ' WHERE ('||h_lst_key_columns||'YEAR, TYPE, PERIOD) NOT IN ('||
                 '     SELECT '||h_lst_key_columns||'YEAR, TYPE, PERIOD'||
                 '     FROM '||x_table_name||
                 '     )';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        commit;

        FETCH c_source_tables INTO h_source_table;
    END LOOP;
    CLOSE c_source_tables;


    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Merge_Data_From_Tables');
        RETURN FALSE;

END Merge_Data_From_Tables;


/*===========================================================================+
| FUNCTION Merge_Projection						     |
+============================================================================*/
FUNCTION Merge_Projection(
    x_table_name VARCHAR2,
    x_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_key_columns NUMBER,
    x_data_columns BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_data_columns NUMBER,
    x_is_base BOOLEAN,
    x_aw_flag BOOLEAN
) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);
    h_i NUMBER;

    h_key_columns_temp  BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_keys_temp VARCHAR2(32000);
    h_cond_join VARCHAR2(32000);
    h_lst_keys_a VARCHAR2(32000);
    h_lst_keys_b VARCHAR2(32000);
    h_lst_data_temp VARCHAR2(32000);
    h_lst_set_data VARCHAR2(32000);
    h_lst_data_a VARCHAR2(32000);
    h_lst_data_b VARCHAR2(32000);

BEGIN
    h_lst_keys_temp := NULL;
    h_cond_join := NULL;
    h_lst_keys_a := NULL;
    h_lst_keys_b := NULL;
    h_lst_data_temp := NULL;
    h_lst_set_data := NULL;
    h_lst_data_a := NULL;
    h_lst_data_b := NULL;

    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    h_lst_keys_temp := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_key_columns);
    h_cond_join := BSC_UPDATE_UTIL.Make_Lst_Cond_Join('A', x_key_columns,
                                                      'B', h_key_columns_temp,
                                                       x_num_key_columns, 'AND');
    h_lst_keys_a := BSC_UPDATE_UTIL.Make_Lst_Table_Column('A', x_key_columns, x_num_key_columns);
    h_lst_keys_b := BSC_UPDATE_UTIL.Make_Lst_Table_Column('B', h_key_columns_temp, x_num_key_columns);

    IF h_lst_keys_temp IS NOT NULL THEN
        h_lst_keys_temp := h_lst_keys_temp||', ';
        h_cond_join := h_cond_join||' AND ';
        h_lst_keys_a := h_lst_keys_a||', ';
        h_lst_keys_b := h_lst_keys_b||', ';
    END IF;

    IF BSC_APPS.bsc_mv AND (NOT x_aw_flag) THEN
        h_lst_keys_temp := h_lst_keys_temp||'PERIODICITY_ID, ';
        h_cond_join := h_cond_join||'A.PERIODICITY_ID = B.PERIODICITY_ID AND ';
        h_lst_keys_a := h_lst_keys_a||'A.PERIODICITY_ID, ';
        h_lst_keys_b := h_lst_keys_b||'B.PERIODICITY_ID, ';

        IF NOT x_is_base THEN
            h_lst_keys_temp := h_lst_keys_temp||'PERIOD_TYPE_ID, ';
            h_lst_keys_a := h_lst_keys_a||'A.PERIOD_TYPE_ID, ';
            h_lst_keys_b := h_lst_keys_b||'B.PERIOD_TYPE_ID, ';
        END IF;
    END IF;

    h_lst_keys_temp := h_lst_keys_temp||'YEAR, TYPE, PERIOD';
    h_cond_join := h_cond_join||'A.YEAR = B.YEAR AND A.TYPE = B.TYPE AND A.PERIOD = B.PERIOD';
    h_lst_keys_a := h_lst_keys_a||'A.YEAR, A.TYPE, A.PERIOD';
    h_lst_keys_b := h_lst_keys_b||'B.YEAR, B.TYPE, B.PERIOD';

    h_lst_data_temp := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('DATA', x_num_data_columns);

    FOR h_i IN 1..x_num_data_columns LOOP
        IF h_i = 1 THEN
            h_lst_set_data := 'A.'||x_data_columns(h_i)||' = B.DATA'||h_i;
            h_lst_data_a := 'A.'||x_data_columns(h_i);
            h_lst_data_b := 'B.DATA'||h_i;
        ELSE
            h_lst_set_data := h_lst_set_data||', A.'||x_data_columns(h_i)||' = B.DATA'||h_i;
            h_lst_data_a := h_lst_data_a||', A.'||x_data_columns(h_i);
            h_lst_data_b := h_lst_data_b||', B.DATA'||h_i;
        END IF;
    END LOOP;

    IF x_aw_flag THEN
        h_lst_data_temp := h_lst_data_temp||', PROJECTION, CHANGE_VECTOR';
        h_lst_set_data := h_lst_set_data||', A.PROJECTION = B.PROJECTION, A.CHANGE_VECTOR = B.CHANGE_VECTOR';
        h_lst_data_a := h_lst_data_a||', A.PROJECTION, A.CHANGE_VECTOR';
        h_lst_data_b := h_lst_data_b||', B.PROJECTION, B.CHANGE_VECTOR';
    END IF;

    h_sql := 'MERGE INTO '||x_table_name||' A'||
             ' USING (SELECT '||h_lst_keys_temp||', '||h_lst_data_temp||' FROM BSC_TMP_PROJ_CALC) B'||
             ' ON ('||h_cond_join||')'||
             ' WHEN MATCHED THEN UPDATE SET '||h_lst_set_data||
             ' WHEN NOT MATCHED THEN'||
             ' INSERT ('||h_lst_keys_a||', '||h_lst_data_a||')'||
             ' VALUES ('||h_lst_keys_b||', '||h_lst_data_b||')';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

	BSC_MESSAGE.Add(
		X_Message => SQLERRM,
		X_Source => 'BSC_UPDATE_CALC.Merge_Projection');
        RETURN FALSE;
END Merge_Projection;


/*===========================================================================+
| FUNCTION Refresh_EDW_Views
+============================================================================*/
FUNCTION Refresh_EDW_Views(
	x_table_name IN VARCHAR2,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2 ,
        x_num_key_columns IN NUMBER ,
        x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_data_columns IN NUMBER,
	x_current_fy IN NUMBER,
	x_periodicity IN NUMBER,
        x_current_period OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_edw_mv_name VARCHAR2(50);
    h_edw_uv_name VARCHAR2(50);

    h_lst_key_columns VARCHAR2(32700);
    h_lst_data_columns VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);

    h_yearly_flag NUMBER;

    h_num_of_years NUMBER;
    h_previous_years NUMBER;
    h_start_year NUMBER;
    h_end_year NUMBER;

BEGIN

    h_yearly_flag := 0;

    -- Refresh materialized view.
    -- Get the number of years and previous years of the table
    IF NOT BSC_UPDATE_UTIL.Get_Table_Range_Of_Years(x_table_name, h_num_of_years, h_previous_years) THEN
        RAISE e_unexpected_error;
    END IF;

    h_start_year := x_current_fy - h_previous_years;
    h_end_year := h_start_year + h_num_of_years - 1;

    BSC_INTEGRATION_MV_GEN.Refresh_MVs(x_table_name, TO_CHAR(h_start_year)||'-'||TO_CHAR(h_end_year));
    IF BSC_APPS.CheckError('BSC_INTEGRATION_MV_GEN.Refresh_MVs') THEN
        RAISE e_unexpected_error;
    END IF;

    -- Delete from x_table all rows existing in the materialized view
    h_edw_mv_name := BSC_UPDATE_UTIL.Get_EDW_Materialized_View_Name(x_table_name);

    h_lst_key_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_key_columns, x_num_key_columns);
    IF h_lst_key_columns IS NOT NULL THEN
        h_lst_key_columns := h_lst_key_columns||', ';
    END IF;

    h_sql := 'DELETE FROM '||x_table_name||
             ' WHERE ('||h_lst_key_columns||'YEAR, TYPE, PERIOD) IN ('||
             ' SELECT '||h_lst_key_columns||'YEAR, TYPE, PERIOD '||
             ' FROM '||h_edw_mv_name||')';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    -- Create union view
    h_edw_uv_name := BSC_UPDATE_UTIL.Get_EDW_Union_View_Name(x_table_name);
    h_lst_data_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(x_data_columns, x_num_data_columns);
    h_sql := 'CREATE OR REPLACE VIEW '||h_edw_uv_name||' AS ('||
             ' SELECT '||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||h_lst_data_columns||
             ' FROM '||x_table_name||
             ' UNION '||
             ' SELECT '||h_lst_key_columns||'YEAR, TYPE, PERIOD, '||h_lst_data_columns||
             ' FROM '||h_edw_mv_name||')';

    --AD_DDL has some issues creating the view. It could be because the materialized views
    --were not created using AD_DDL?
    --So, we create the view directly. This is not so bad because the views are created on APPS schema
    --BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_VIEW, h_edw_uv_name);
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    -- Get current period for the table.
    -- This is the maximun period reported in the materialized view
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity);
    IF h_yearly_flag = 1 THEN
        -- Annual periodicity --> current period is the current fiscal year
        x_current_period := x_current_fy;
    ELSE
        -- Get the maximum period reported in the materialized view
        h_sql := 'SELECT NVL(MAX(period),1) '||
                 ' FROM '||h_edw_mv_name||
                 ' WHERE year = :1'||
                 ' AND type = :2';

        OPEN h_cursor FOR h_sql USING x_current_fy, 0;
        FETCH h_cursor INTO x_current_period;
        IF h_cursor%NOTFOUND THEN
            x_current_period := 1;
        END IF;
        CLOSE h_cursor;

    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error  THEN
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_REFRESH_EDW_VIEWS_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Refresh_EDW_Views');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Refresh_EDW_Views');
        RETURN FALSE;

END Refresh_EDW_Views;


/*===========================================================================+
| FUNCTION Rollup_Projection
+============================================================================*/
FUNCTION Rollup_Projection(
	x_periodicity IN NUMBER,
        x_period IN NUMBER,
        x_base_periodicity IN NUMBER,
        x_base_period IN NUMBER,
	x_key_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN NUMBER,
	x_data_columns IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_formulas IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_data_measure_types IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN NUMBER,
	x_current_fy IN NUMBER,
        x_is_base IN BOOLEAN
        ) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);
    h_i NUMBER;
    h_j NUMBER;

    h_period_col_name VARCHAR2(30);
    h_origin_period_col_name VARCHAR2(30);

    h_lst_key_columns VARCHAR2(32700);

    h_lst_data_columns VARCHAR2(32700);
    h_lst_data_formulas VARCHAR2(32700);

    h_lst_from VARCHAR2(32700);
    h_lst_on VARCHAR2(32700);

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

    h_calendar_id NUMBER;

    -- Bind var fix for Posco
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    l_parallel_hint varchar2(20000);
    l_parallel_hint1 varchar2(20000);
    l_parallel_hint2 varchar2(20000);

    h_key_columns_temp BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_lst_key_columns_temp VARCHAR2(32000);

    h_lst_tot_data_columns_temp VARCHAR2(32000);
    h_lst_bal_data_columns_temp VARCHAR2(32000);
    h_lst_tot_data_columns_temp_t VARCHAR2(32000);
    h_lst_bal_data_columns_temp_b VARCHAR2(32000);

    h_lst_data_columns_temp VARCHAR2(32000);
    h_cond_data_values VARCHAR2(32000);

    h_lst_data_p VARCHAR2(32000);

    h_data_formula_temp VARCHAR2(32000);
    h_period_type_id NUMBER;

BEGIN

    h_sql := NULL;
    h_lst_key_columns := NULL;
    h_lst_data_columns := NULL;
    h_lst_data_formulas := NULL;
    h_lst_from := NULL;
    h_lst_on := NULL;
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
    l_num_bind_vars := 0;
    h_lst_key_columns_temp := NULL;
    h_lst_tot_data_columns_temp := NULL;
    h_lst_bal_data_columns_temp := NULL;
    h_lst_tot_data_columns_temp_t := NULL;
    h_lst_bal_data_columns_temp_b := NULL;
    h_lst_data_columns_temp := NULL;
    h_cond_data_values := NULL;
    h_lst_data_p := NULL;

    --ENH_PROJECTION_4235711: We are going to rollup the projection in BSC_TMP_PROJ_CALC.
    -- We need to take in account balance columns!
    -- We need to take in account formulas
    -- Also we know that the target periodicity is not yearly.
    -- This code is only used in MV Architecture.

    -- get period type id of the target periodicity
    select period_type_id
    into h_period_type_id
    from bsc_sys_periodicities
    where periodicity_id = x_periodicity;

    -- New array used with generic temporary tables
    FOR h_i IN 1..x_num_key_columns LOOP
        h_key_columns_temp(h_i) := 'KEY'||h_i;
    END LOOP;

    -- Some information about the periodicity
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity);

    -- Initialize some variables required for change of periodicity
    -- to handle balance and total data columns

    -- Calculate the number of balance and total data columns
    -- By the way initialize arrays for total and balance data columns
    FOR h_i IN 1..x_num_data_columns LOOP
        h_data_formula_temp := x_data_formulas(h_i);
        FOR h_j IN 1..x_num_data_columns LOOP
            h_data_formula_temp := replace(h_data_formula_temp, '('||x_data_columns(h_j)||')', '(DATA'||h_j||')');
        END LOOP;

        IF x_data_measure_types(h_i) = 1 THEN
            -- Total data column
            h_num_tot_data_columns := h_num_tot_data_columns + 1;

            IF h_num_tot_data_columns = 1 THEN
                h_lst_tot_data_columns := 'DATA'||h_i;
                h_lst_tot_data_columns_temp := 'DATA'||h_i;
                h_lst_tot_data_columns_temp_t := 'T.DATA'||h_i;
                h_lst_tot_data_formulas := h_data_formula_temp;
            ELSE
                h_lst_tot_data_columns := h_lst_tot_data_columns||', DATA'||h_i;
                h_lst_tot_data_columns_temp := h_lst_tot_data_columns_temp||', DATA'||h_i;
                h_lst_tot_data_columns_temp_t := h_lst_tot_data_columns_temp_t||', T.DATA'||h_i;
                h_lst_tot_data_formulas := h_lst_tot_data_formulas||', '||h_data_formula_temp;
            END IF;
        ELSE
            -- Balance data column
            h_num_bal_data_columns := h_num_bal_data_columns + 1;
            IF h_num_bal_data_columns = 1 THEN
                h_lst_bal_data_columns := 'DATA'||h_i;
                h_lst_bal_data_columns_temp := 'DATA'||h_i;
                h_lst_bal_data_columns_temp_b := 'B.DATA'||h_i;
                h_lst_bal_data_formulas := h_data_formula_temp;
            ELSE
                h_lst_bal_data_columns := h_lst_bal_data_columns||', DATA'||h_i;
                h_lst_bal_data_columns_temp := h_lst_bal_data_columns_temp||', DATA'||h_i;
                h_lst_bal_data_columns_temp_b := h_lst_bal_data_columns_temp_b||', B.DATA'||h_i;
                h_lst_bal_data_formulas := h_lst_bal_data_formulas||', '||h_data_formula_temp;
            END IF;
        END IF;
    END LOOP;

    -- Create a temporal table to make the change of periodicity
    h_period_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity);
    h_origin_period_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_base_periodicity);

    IF h_num_tot_data_columns > 0 THEN
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE');

        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'parallel (bsc_tmp_per_change) ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO bsc_tmp_per_change (year, src_per, trg_per)'||
               ' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'/*+ parallel (bsc_db_calendar)*/ ';
        end if;
        h_sql:=h_sql||
               'DISTINCT year, '||h_origin_period_col_name||' AS src_per, '||
               h_period_col_name||' AS trg_per'||
               ' FROM bsc_db_calendar'||
               ' WHERE calendar_id = :1 and year = :2';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := h_calendar_id;
        l_bind_vars_values(2) := x_current_fy;
        l_num_bind_vars := 2;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
        commit;
    END IF;

    IF h_num_bal_data_columns > 0 THEN
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE_BAL');

        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'parallel (bsc_tmp_per_change_bal) ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO bsc_tmp_per_change_bal (year, src_per, trg_per)'||
               ' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'/*+ parallel (bsc_db_calendar)*/ ';
        end if;
        h_sql:=h_sql||'year, MAX('||h_origin_period_col_name||') AS src_per, '||
               h_period_col_name||' AS trg_per'||
               ' FROM bsc_db_calendar'||
               ' WHERE calendar_id = :1 and year = :2'||
               ' GROUP BY year, '||h_period_col_name;
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := h_calendar_id;
        l_bind_vars_values(2) := x_current_fy;
        l_num_bind_vars := 2;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
        commit;
    END IF;

    -- Create temporal tables to calculate total data columns and balance data columns separately
    -- and then merge them into the target summary table
    -- If all data columns are total or balance we dont need those temporal tables
    IF (h_num_tot_data_columns > 0) AND (h_num_bal_data_columns > 0) THEN
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_DATA');
        h_target_table_tot := 'BSC_TMP_TOT_DATA';

        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BAL_DATA');
        h_target_table_bal := 'BSC_TMP_BAL_DATA';
    ELSE
        h_target_table_tot := 'BSC_TMP_PROJ_CALC';
        h_target_table_bal := 'BSC_TMP_PROJ_CALC';
    END IF;

    -- create the string for FROM sub-statement
    h_lst_from := 'BSC_TMP_PROJ_CALC';
    l_parallel_hint:=l_parallel_hint||' parallel (BSC_TMP_PROJ_CALC)';

    -- Initialize some lists that will be part of the query to generate the summary table
    h_lst_key_columns := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(h_key_columns_temp, x_num_key_columns);
    h_lst_key_columns_temp := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(h_key_columns_temp, x_num_key_columns);

    IF h_lst_key_columns IS NOT NULL THEN
        h_lst_key_columns := h_lst_key_columns||', ';
        h_lst_key_columns_temp := h_lst_key_columns_temp||', ';
    END IF;

    -- Create the string for the SELECT and FROM sub-statement
    FOR h_i IN 1..x_num_key_columns LOOP
        h_lst_select_disag := h_lst_select_disag||'BSC_TMP_PROJ_CALC.'||h_key_columns_temp(h_i)||', ';
    END LOOP;

    -- Create the string for the SELECT and FROM sub-statement for the periodicity change.
    -- Note: We suppose that the change of periodicity is allowed
    -- (see bsc_sys_periodicites)
    IF h_num_tot_data_columns > 0 THEN
        h_lst_from_tot := h_lst_from||', BSC_TMP_PER_CHANGE';
        l_parallel_hint1:=l_parallel_hint||' parallel (BSC_TMP_PER_CHANGE)';
        h_lst_on_tot := 'BSC_TMP_PROJ_CALC.YEAR = BSC_TMP_PER_CHANGE.YEAR'||
                        ' AND BSC_TMP_PROJ_CALC.PERIOD = BSC_TMP_PER_CHANGE.SRC_PER';
        h_lst_select_per :=  'BSC_TMP_PROJ_CALC.YEAR, BSC_TMP_PROJ_CALC.TYPE, BSC_TMP_PER_CHANGE.TRG_PER';

        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'parallel ('||h_target_table_tot||') ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO '||h_target_table_tot;
        h_sql:=h_sql||' ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, PERIODICITY_ID, ';
        IF NOT x_is_base THEN
            h_sql:=h_sql||'PERIOD_TYPE_ID, ';
        END IF;
        h_sql:=h_sql||h_lst_tot_data_columns_temp||')';
        h_sql:=h_sql||' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'/*+'||l_parallel_hint1||'*/ ';
        end if;
        h_sql:=h_sql||h_lst_select_disag||h_lst_select_per||', :1, ';
        IF NOT x_is_base THEN
            h_sql:=h_sql||':2, ';
        END IF;
        h_sql:=h_sql||h_lst_tot_data_formulas||
               ' FROM '||h_lst_from_tot||
               ' WHERE '||h_lst_on_tot||
               ' AND BSC_TMP_PROJ_CALC.PERIODICITY_ID = :3'||
               ' AND BSC_TMP_PER_CHANGE.TRG_PER > :4'||
               ' GROUP BY '||h_lst_select_disag||h_lst_select_per;
        l_bind_vars_values.delete;
        IF NOT x_is_base THEN
            l_bind_vars_values(1) := x_periodicity;
            l_bind_vars_values(2) := h_period_type_id;
            l_bind_vars_values(3) := x_base_periodicity;
            l_bind_vars_values(4) := x_period;
            l_num_bind_vars := 4;
        ELSE
            l_bind_vars_values(1) := x_periodicity;
            l_bind_vars_values(2) := x_base_periodicity;
            l_bind_vars_values(3) := x_period;
            l_num_bind_vars := 3;
        END IF;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
        commit;
    END IF;

    IF h_num_bal_data_columns > 0 THEN
        h_lst_from_bal := h_lst_from||', BSC_TMP_PER_CHANGE_BAL';
        l_parallel_hint2:=l_parallel_hint||' parallel (BSC_TMP_PER_CHANGE_BAL)';
        h_lst_on_bal := 'BSC_TMP_PROJ_CALC.YEAR = BSC_TMP_PER_CHANGE_BAL.YEAR'||
                        ' AND BSC_TMP_PROJ_CALC.PERIOD = BSC_TMP_PER_CHANGE_BAL.SRC_PER';
        h_lst_select_per := 'BSC_TMP_PROJ_CALC.YEAR, BSC_TMP_PROJ_CALC.TYPE, BSC_TMP_PER_CHANGE_BAL.TRG_PER';

        h_sql := 'INSERT /*+ append ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'parallel ('||h_target_table_bal||') ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO '||h_target_table_bal;
        h_sql:=h_sql||' ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, PERIODICITY_ID, ';
        IF NOT x_is_base THEN
            h_sql:=h_sql||'PERIOD_TYPE_ID, ';
        END IF;
        h_sql:=h_sql||h_lst_bal_data_columns_temp||')';
        h_sql := h_sql||' SELECT ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'/*+'||l_parallel_hint2||'*/ ';
        end if;
        h_sql:=h_sql||h_lst_select_disag||h_lst_select_per||', :1, ';
        IF NOT x_is_base THEN
            h_sql:=h_sql||':2, ';
        END IF;
        h_sql:=h_sql||h_lst_bal_data_formulas||
               ' FROM '||h_lst_from_bal||
               ' WHERE '||h_lst_on_bal||
               ' AND BSC_TMP_PROJ_CALC.PERIODICITY_ID = :3'||
               ' AND BSC_TMP_PER_CHANGE_BAL.TRG_PER > :4'||
               ' GROUP BY '||h_lst_select_disag||h_lst_select_per;
        l_bind_vars_values.delete;
        IF NOT x_is_base THEN
            l_bind_vars_values(1) := x_periodicity;
            l_bind_vars_values(2) := h_period_type_id;
            l_bind_vars_values(3) := x_base_periodicity;
            l_bind_vars_values(4) := x_period;
            l_num_bind_vars := 4;
        ELSE
            l_bind_vars_values(1) := x_periodicity;
            l_bind_vars_values(2) := x_base_periodicity;
            l_bind_vars_values(3) := x_period;
            l_num_bind_vars := 3;
        END IF;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, l_bind_vars_values, l_num_bind_vars);
        commit;
    END IF;

    IF (h_num_tot_data_columns > 0) AND (h_num_bal_data_columns > 0) THEN
        -- We need to merge BSC_TMP_TOT_DATA and BSC_TMP_BAL_DATA into BSC_TMP_PROJ_CALC
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
            h_sql:=h_sql||'parallel (BSC_TMP_PROJ_CALC) ';
        end if;
        h_sql:=h_sql||' */';
        h_sql:=h_sql||'INTO BSC_TMP_PROJ_CALC'||
               ' ('||h_lst_key_columns_temp||'YEAR, TYPE, PERIOD, PERIODICITY_ID, ';
        IF NOT x_is_base THEN
            h_sql:=h_sql||'PERIOD_TYPE_ID, ';
        END IF;
        h_sql:=h_sql||h_lst_tot_data_columns_temp||', '||h_lst_bal_data_columns_temp||')'||
               ' SELECT ';
        --Fix bug#3875046: Use hash hint
        h_sql:=h_sql||'/*+use_hash(T) use_hash(B)*/ ';
        if BSC_UPDATE_UTIL.is_parallel then
            h_sql:=h_sql||'/*+ parallel (T) parallel (B)*/ ';
        end if;
        h_sql:=h_sql||h_lst_select_disag||'T.YEAR, T.TYPE, T.PERIOD, T.PERIODICITY_ID, ';
        IF NOT x_is_base THEN
            h_sql:=h_sql||'T.PERIOD_TYPE_ID, ';
        END IF;
        h_sql:=h_sql||h_lst_tot_data_columns_temp_t||', '||h_lst_bal_data_columns_temp_b||
               ' FROM BSC_TMP_TOT_DATA T, BSC_TMP_BAL_DATA B'||
               ' WHERE '||h_lst_on;
        h_sql := h_sql||'T.YEAR = B.YEAR (+) AND T.TYPE = B.TYPE (+)'||
                 ' AND T.PERIOD = B.PERIOD (+) AND T.PERIODICITY_ID = B.PERIODICITY_ID (+)';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        commit;
    END IF;
    commit;

    -- Fix bug#4463132: Truncate temporary table after use
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_PER_CHANGE_BAL');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TOT_DATA');
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_BAL_DATA');
    commit;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        ROLLBACK;
        BSC_MESSAGE.Add(
                X_Message => BSC_UPDATE_UTIL.Get_Message('BSC_PROJ_FAILED'),
                X_Source => 'BSC_UPDATE_CALC.Rollup_Projection');
        RETURN FALSE;

    WHEN OTHERS THEN
        ROLLBACK;

        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Rollup_Projection');
        RETURN FALSE;

END Rollup_Projection;


/*===========================================================================+
| FUNCTION Table_Has_Profit_Calc
+============================================================================*/
FUNCTION Table_Has_Profit_Calc(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    cursor c_profit_calc (pTableName varchar2,pCalcType number) is
    SELECT calculation_type
    FROM bsc_db_calculations
    WHERE table_name = pTableName
    AND calculation_type =  pCalcType;

    h_profit_calc bsc_db_calculations.calculation_type%TYPE;
    h_ret BOOLEAN;

BEGIN
    -- OPEN c_profit_calc FOR c_profit_calc_sql USING x_table_name, 1;
    OPEN c_profit_calc (x_table_name, 1);
    FETCH c_profit_calc INTO h_profit_calc;
    IF c_profit_calc%NOTFOUND THEN
        h_ret := FALSE;
    ELSE
        h_ret := TRUE;
    END IF;
    CLOSE c_profit_calc;

    RETURN h_ret;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Table_Has_Profit_Calc');
        RETURN NULL;

END Table_Has_Profit_Calc;


/*===========================================================================+
| FUNCTION Table_Has_Proj_Calc
+============================================================================*/
FUNCTION Table_Has_Proj_Calc(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(4000);
    h_column_type_a VARCHAR2(1);
    h_table_name VARCHAR2(30);
    h_ret BOOLEAN;

   -- SUPPORT_BSC_BIS_MEASURES: Only BSC measures exists in bsc_db_measure_cols_vl and
   -- by design we assumed that BIS measures do not have projection.
   -- I have added the condition on source in bsc_db_tables_cols
   cursor h_cursor (pTableName varchar2,pProjFlag number,pColCnt number,
      pColType varchar2,pProjId number, pProjId2 number, pBSCSource varchar2,
      pBSCSource1 varchar2) is
   SELECT table_name
   FROM bsc_db_tables t
   WHERE table_name = pTableName AND project_flag = pProjFlag AND
   pColCnt <> (SELECT COUNT(tc.column_name)
               FROM bsc_db_tables_cols tc, bsc_db_measure_cols_vl m
               WHERE tc.table_name = t.table_name AND
               tc.column_type = pColType AND
               NVL(tc.source, pBSCSource) = pBSCSource1 AND
               tc.column_name = m.measure_col (+) AND
               NVL(m.projection_id, pProjId) <> pProjId2);

BEGIN
    h_column_type_a := 'A';
    h_table_name := NULL;

    -- There are two conditions:
    -- 1. The table has projection flag = 1 and
    -- 2. At least one data column has projection method <> 0

    OPEN h_cursor (x_table_name, 1, 0, h_column_type_a, 0, 0, 'BSC', 'BSC') ;
    FETCH h_cursor INTO h_table_name;
    IF h_cursor%NOTFOUND THEN
        h_ret := FALSE;
    ELSE
        h_ret := TRUE;
    END IF;
    CLOSE h_cursor;

    RETURN h_ret;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_CALC.Table_Has_Proj_Calc');
        RETURN NULL;

END Table_Has_Proj_Calc;


END BSC_UPDATE_CALC;

/
