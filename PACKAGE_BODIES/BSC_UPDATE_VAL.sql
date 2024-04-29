--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_VAL" AS
/* $Header: BSCDVALB.pls 120.4 2006/01/31 13:37:14 meastmon noship $ */


/*===========================================================================+
| FUNCTION Delete_Invalid_Zero_Codes
+============================================================================*/
FUNCTION Delete_Invalid_Zero_Codes(
	x_error_msg OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS

    CURSOR c_base_tables (p_db_transform VARCHAR2) IS
        SELECT DISTINCT table_name
        FROM bsc_db_tables_rels
        WHERE source_table_name IN (
          SELECT table_name
          FROM bsc_db_tables
          WHERE table_type = 0
        )
        START WITH table_name IN (
          SELECT table_name
          FROM bsc_kpi_data_tables t, bsc_kpi_properties p
          WHERE t.indicator = p.indicator (+) AND
                t.table_name is not null AND
                p.property_code (+) = p_db_transform AND
                nvl(p.property_value,1) <> 0
        )
        CONNECT BY table_name = PRIOR source_table_name;

    CURSOR c_key_columns (p_table VARCHAR2, p_column_type VARCHAR2) IS
        SELECT column_name
        FROM bsc_db_tables_cols
        WHERE table_name = p_table AND column_type = p_column_type;


    h_db_transform VARCHAR2(20);
    h_base_table VARCHAR2(30);
    h_p VARCHAR2(1);
    h_sql VARCHAR2(32000);
    h_key_column VARCHAR2(100);
    h_where_cond VARCHAR2(32000);

BEGIN
    h_db_transform := 'DB_TRANSFORM';
    h_p := 'P';

    -- This cusror return all the base tables for indicators that are not precalculated.
    OPEN c_base_tables(h_db_transform);
    LOOP
        FETCH c_base_tables INTO h_base_table;
        EXIT WHEN c_base_tables%NOTFOUND;

        h_where_cond := NULL;
        OPEN c_key_columns(h_base_table, h_p);
        LOOP
            FETCH c_key_columns INTO h_key_column;
            EXIT WHEN c_key_columns%NOTFOUND;

            IF h_where_cond IS NOT NULL THEN
                h_where_cond := h_where_cond||' OR ';
            END IF;
            h_where_cond := h_where_cond||h_key_column||'=''0''';
        END LOOP;
        CLOSE c_key_columns;

        IF h_where_cond IS NOT NULL THEN
            h_sql := 'DELETE FROM '||h_base_table||
                     ' WHERE '||h_where_cond;
            EXECUTE IMMEDIATE h_sql;
           commit;
        END IF;
    END LOOP;
    CLOSE c_base_tables;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        x_error_msg := SQLERRM;
        RETURN FALSE;
END Delete_Invalid_Zero_Codes;


/*===========================================================================+
| FUNCTION Is_Table_For_PreCalc_Kpi
+============================================================================*/
FUNCTION Is_Table_For_PreCalc_Kpi(
	x_table IN VARCHAR2
	) RETURN BOOLEAN IS

    h_count NUMBER;
    h_db_transform VARCHAR2(20);

BEGIN
    h_db_transform := 'DB_TRANSFORM';

    SELECT count(*)
    INTO h_count
    FROM (
        SELECT source_table_name
        FROM bsc_db_tables_rels
        START WITH table_name IN (
            SELECT table_name
            FROM bsc_kpi_data_tables t, bsc_kpi_properties p
            WHERE t.indicator = p.indicator AND
                  t.table_name is not null AND
                  p.property_code = h_db_transform AND
                  p.property_value = 0
        )
        CONNECT BY table_name = PRIOR source_table_name
    )
    WHERE source_table_name = x_table;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Is_Table_For_PreCalc_Kpi;


/*===========================================================================+
| FUNCTION Validate_Codes
+============================================================================*/
FUNCTION Validate_Codes(
	x_input_table IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;

    /* c_dim_cols t_cursor; -- x_input_table, h_column_type_p
    c_dim_cols_sql VARCHAR2(2000) := 'SELECT t.column_name, d.level_view_name'||
                                     ' FROM bsc_db_tables_cols t, bsc_sys_dim_levels_b d'||
                                     ' WHERE t.table_name = :1 AND t.column_type = :2 AND'||
                                     ' t.column_name = d.level_pk_col'; */

    cursor c_dim_cols( pTableName varchar2, pColTYpe varchar) is
    SELECT t.column_name, d.level_view_name, d.short_name, d.source
    FROM bsc_db_tables_cols t, bsc_sys_dim_levels_b d
    WHERE t.table_name = pTableName
    AND t.column_type = pColType
    AND t.column_name = d.level_pk_col ;

    h_column_type_p VARCHAR2(1);

    h_column_name bsc_db_tables_cols.column_name%TYPE;
    h_level_table_name bsc_sys_dim_levels_b.level_view_name%TYPE;
    h_level_short_name bsc_sys_dim_levels_b.short_name%TYPE;
    h_level_source bsc_sys_dim_levels_b.short_name%TYPE;
    h_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

    h_sql VARCHAR2(2000);

    h_periodicity NUMBER;
    h_period_col_name VARCHAR2(15);
    h_subperiod_col_name VARCHAR2(15);

    h_db_calendar_col_name VARCHAR2(30);
    h_invalid BOOLEAN;

    h_edw_flag NUMBER;
    h_target_flag NUMBER;
    h_current_fy NUMBER;
    h_calendar_id NUMBER;
    h_yearly_flag NUMBER;
    h_num_of_years NUMBER;
    h_previous_years NUMBER;
    h_start_year NUMBER;
    h_end_year NUMBER;

    h_periodicity_type NUMBER;

    /* c_mn_rels t_cursor; -- 2, x_input_table, h_column_type_p, x_input_table, h_column_type_p
    c_mn_rels_sql VARCHAR2(2000) := 'SELECT d1.level_view_name as p1_table, d1.level_pk_col as p1_pk_col,'||
                                    ' d2.level_view_name as p2_table, d2.level_pk_col as p2_pk_col,'||
                                    ' r.relation_col as rel_table'||
                                    ' FROM bsc_sys_dim_level_rels r, bsc_sys_dim_levels_b d1,'||
                                    ' bsc_sys_dim_levels_b d2'||
                                    ' WHERE r.relation_type = :1 AND r.dim_level_id = ('||
                                    ' SELECT min(r2.dim_level_id)'||
                                    ' FROM bsc_sys_dim_level_rels r2'||
                                    ' WHERE r.relation_col = r2.relation_col) AND'||
                                    ' r.dim_level_id = d1.dim_level_id AND'||
                                    ' r.parent_dim_level_id = d2.dim_level_id AND'||
                                    ' d1.level_pk_col in ('||
                                    ' SELECT column_name'||
                                    ' FROM bsc_db_tables_cols'||
                                    ' WHERE table_name = :2 AND column_type = :3) AND'||
                                    ' d2.level_pk_col in ('||
                                    ' SELECT column_name'||
                                    ' FROM bsc_db_tables_cols'||
                                    ' WHERE table_name = :4 AND column_type = :5)'; */

    cursor c_mn_rels(pRelnType number,pTableName varchar2, pColType varchar2,pTableName2 varchar2, pColType2 varchar2) is
       SELECT d1.level_view_name as p1_table, d1.level_pk_col as p1_pk_col,
              d2.level_view_name as p2_table, d2.level_pk_col as p2_pk_col,
              r.relation_col as rel_table
              FROM bsc_sys_dim_level_rels r, bsc_sys_dim_levels_b d1,
                   bsc_sys_dim_levels_b d2
              WHERE r.relation_type = pRelnType
              AND r.dim_level_id = (SELECT min(r2.dim_level_id)
                                    FROM bsc_sys_dim_level_rels r2
                                    WHERE r.relation_col = r2.relation_col)
              AND r.dim_level_id = d1.dim_level_id
              AND r.parent_dim_level_id = d2.dim_level_id
              AND d1.level_pk_col in ( SELECT column_name
                                     FROM bsc_db_tables_cols
                                     WHERE table_name = pTableName
                                     AND column_type = pColType) AND
                                    d2.level_pk_col in (
                                    SELECT column_name
                                    FROM bsc_db_tables_cols
                                    WHERE table_name = pTableName2 AND column_type = pColType2);


    h_p1_table bsc_sys_dim_levels_b.level_table_name%TYPE;
    h_p1_pk_col bsc_db_tables_cols.column_name%TYPE;
    h_p2_table bsc_sys_dim_levels_b.level_table_name%TYPE;
    h_p2_pk_col bsc_db_tables_cols.column_name%TYPE;
    h_rel_table bsc_sys_dim_levels_b.level_table_name%TYPE;


    --  Bind Var. fix for POSCO
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    l_num_bind_vars NUMBER;

    h_num_rows NUMBER;

    h_calendar_source VARCHAR2(20);

    h_table_for_precalc_kpi BOOLEAN;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_bind_vars NUMBER;

BEGIN

    h_column_type_p := 'P';
    l_num_bind_vars := 0;
    h_calendar_source := NULL;
    h_table_for_precalc_kpi := Is_Table_For_PreCalc_Kpi(x_input_table);

    -- Get Target_Flag of the table
    h_target_flag := BSC_UPDATE_UTIL.Get_Table_Target_Flag(x_input_table);

    -- Delete the current invalid codes of input table
    DELETE FROM bsc_db_validation
    WHERE input_table_name = x_input_table;

    -- Validate codes for each key column
    -- OPEN c_dim_cols FOR c_dim_cols_sql USING x_input_table, h_column_type_p;

    OPEN c_dim_cols (x_input_table, h_column_type_p) ;
    FETCH c_dim_cols INTO h_column_name, h_level_table_name, h_level_short_name, h_level_source;
    WHILE c_dim_cols%FOUND LOOP

        -- BSC-BIS-DIMENSIONS: If the dimension is a DBI dimension and it is materialized and
        -- the table exists then we validate against the table created in BSC to materialize
        -- the DBI dimension. It has USER_CODE column. Note that is only in MV Architecture.

        IF BSC_APPS.bsc_mv THEN
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

        -- Insert the invalid codes for the key column h_coumn_name
        -- into bsc_db_validation table
        h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                 'SELECT DISTINCT '||
                 ':1, :2, t.'||h_column_name||' '||
                 'FROM '||x_input_table||' t, '||h_level_table_name||' d '||
                 'WHERE t.'||h_column_name||' = d.user_code (+) AND d.user_code IS NULL';
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := x_input_table;
        h_bind_vars_values(2) := h_column_name;
        h_num_bind_vars := 2;
        -- Validate for zero codes: If the input table is for non-precalculated indicator
        -- and the corresponding code is '0' then it is an invalid code.
        IF NOT h_table_for_precalc_kpi THEN
            h_sql := h_sql||' UNION '||
                     'SELECT DISTINCT '||
                     ':3, :4, t.'||h_column_name||' '||
                     'FROM '||x_input_table||' t, '||h_level_table_name||' d '||
                     'WHERE t.'||h_column_name||' = d.user_code AND d.code = :5';
            h_bind_vars_values(3) := x_input_table;
            h_bind_vars_values(4) := h_column_name;
            h_bind_vars_values(5) := '0';
            h_num_bind_vars := 5;
        END IF;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,h_num_bind_vars);
        commit;

        FETCH c_dim_cols INTO h_column_name, h_level_table_name, h_level_short_name, h_level_source;
    END LOOP;
    CLOSE c_dim_cols;

    -- Validate mn relations
    -- OPEN c_mn_rels FOR c_mn_rels_sql USING 2, x_input_table, h_column_type_p, x_input_table, h_column_type_p;
    OPEN c_mn_rels (2, x_input_table, h_column_type_p, x_input_table, h_column_type_p);
    FETCH c_mn_rels INTO h_p1_table, h_p1_pk_col, h_p2_table, h_p2_pk_col, h_rel_table;
    WHILE c_mn_rels%FOUND LOOP
        h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                 ' SELECT DISTINCT :1, :2, '||
                 ' t.'||h_p1_pk_col||'||'', ''||t.'||h_p2_pk_col||' '||
                 ' FROM '||x_input_table||' t '||
                 ' WHERE ('||h_p1_pk_col||', '||h_p2_pk_col||') NOT IN ( '||
                 ' SELECT p1.user_code, p2.user_code '||
                 ' FROM '||h_p1_table||' p1, '||h_p2_table||' p2, '||h_rel_table||' r '||
                 ' WHERE r.'||h_p1_pk_col||' = p1.code AND r.'||h_p2_pk_col||' = p2.code)';
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := x_input_table;
        h_bind_vars_values(2) := h_p1_pk_col||', '||h_p2_pk_col;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,2);

        FETCH c_mn_rels INTO h_p1_table, h_p1_pk_col, h_p2_table, h_p2_pk_col, h_rel_table;
    END LOOP;
    CLOSE c_mn_rels;

    -- Validate periods

    -- BSC-BIS-DIMENSIONS: If the periodicity of the input table is from BIS, then the
    -- input table has a column called TIME_FK instead of YEAR+PERIOD.

    -- Get table periodicity
    h_periodicity := BSC_UPDATE_UTIL.Get_Table_Periodicity(x_input_table);
    IF h_periodicity IS NULL THEN
        RAISE e_unexpected_error;
    END IF;

    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(h_periodicity);
    h_calendar_source := BSC_UPDATE_UTIL.Get_Calendar_Source(h_calendar_id);
    h_periodicity_type := BSC_UPDATE_UTIL.Get_Periodicity_Type(h_periodicity);

    IF h_calendar_source = 'BSC' THEN
        -- Get period column name and subperiod column name for that periodicity
        IF NOT BSC_UPDATE_UTIL.Get_Period_Cols_Names(h_periodicity, h_period_col_name, h_subperiod_col_name) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Annually
        IF h_periodicity_type = 1 THEN
            l_bind_vars_values.delete;
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                     'SELECT DISTINCT :1, :2, '||
                     't.year||'', ''||t.'||h_period_col_name||' '||
                     'FROM '||x_input_table||' t, bsc_db_calendar d '||
                     'WHERE d.calendar_id (+) = :3'||' AND t.year = d.year (+) '||
                     ' AND (d.year IS NULL OR d.calendar_id IS NULL) '||
                     'UNION '||
                     'SELECT DISTINCT :4, :5, '||
                     't.year||'', ''||t.'||h_period_col_name||' '||
                     'FROM '||x_input_table||' t '||
                     'WHERE t.'||h_period_col_name||' <> :6';
            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_input_table;
            h_bind_vars_values(2) := 'YEAR, '||h_period_col_name;
            h_bind_vars_values(3) := h_calendar_id;
            h_bind_vars_values(4) := x_input_table;
            h_bind_vars_values(5) := 'YEAR, '||h_period_col_name;
            h_bind_vars_values(6) := 0;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,6);

        -- Month Week
        ELSIF h_periodicity_type = 11 THEN
            l_bind_vars_values.delete;
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                     'SELECT DISTINCT :1, :2, '||
                     't.year||'', ''||t.'||h_period_col_name||'||'', ''||t.'||h_subperiod_col_name||' '||
                     'FROM '||x_input_table||' t, bsc_db_week_maps d '||
                     'WHERE d.calendar_id (+) = :3'||' AND t.year = d.year (+) '||
                     'AND t.'||h_period_col_name||' = d.month (+) '||
                     'AND t.'||h_subperiod_col_name||' = d.week (+) '||
                     'AND (d.calendar_id IS NULL OR d.year IS NULL OR d.month IS NULL OR d.week IS NULL)';
            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_input_table;
            h_bind_vars_values(2) := 'YEAR, '||h_period_col_name||', '||h_subperiod_col_name;
            h_bind_vars_values(3) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,3);

        -- Month Day
        ELSIF h_periodicity_type = 12 THEN
            l_bind_vars_values.delete;
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                     'SELECT DISTINCT :1, :2, '||
                     't.year||'', ''||t.'||h_period_col_name||'||'', ''||t.'||h_subperiod_col_name||' '||
                     'FROM '||x_input_table||' t, bsc_db_calendar d '||
                     'WHERE d.calendar_id (+) = :3'|| ' AND t.year = d.year (+) '||
                     'AND t.'||h_period_col_name||' = d.month (+) '||
                     'AND t.'||h_subperiod_col_name||' = d.day30 (+) '||
                     'AND (d.calendar_id IS NULL OR d.year IS NULL OR d.month IS NULL OR d.day30 IS NULL)';
            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_input_table;
            h_bind_vars_values(2) := 'YEAR, '||h_period_col_name||', '||h_subperiod_col_name;
            h_bind_vars_values(3) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,3);

        -- Other periodicities: Monthly, Quarterly, Custom periodicities, etc
        ELSE
            l_bind_vars_values.delete;
            h_db_calendar_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(h_periodicity);
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                     'SELECT DISTINCT :1, :2, '||
                     't.year||'', ''||t.'||h_period_col_name||' '||
                     'FROM '||x_input_table||' t, bsc_db_calendar d '||
                     'WHERE d.calendar_id (+) = :3'||' AND t.year = d.year (+) '||
                     'AND t.'||h_period_col_name||' = d.'||h_db_calendar_col_name||' (+) '||
                     'AND (d.calendar_id IS NULL OR d.year IS NULL OR d.'||h_db_calendar_col_name||' IS NULL)';
            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_input_table;
            h_bind_vars_values(2) := 'YEAR, '||h_period_col_name;
            h_bind_vars_values(3) := h_calendar_id;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,3);
        END IF;
    ELSE
        -- BIS Calendar
        -- The input table has a column called TIME_FK. We need to validate against BSC_SYS_PERIODS.TIME_FK

        IF h_periodicity_type = 9 THEN
            -- If the periodicity is Daily the TIME_FK column is of type DATE.
            -- The format in BSC_SYS_PERIODS.TIME_FK is always MM/DD/YYYY
            l_bind_vars_values.delete;
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                     'SELECT DISTINCT :1, :2, TO_CHAR(time_fk) '||
                     'FROM '||x_input_table||' '||
                     'WHERE TRUNC(time_fk) NOT IN ( '||
                     ' SELECT TRUNC(TO_DATE(time_fk,:3)) '||
                     ' FROM bsc_sys_periods '||
                     ' WHERE periodicity_id = :4 '||
                     ')';
            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_input_table;
            h_bind_vars_values(2) := 'TIME_FK';
            h_bind_vars_values(3) := 'MM/DD/YYYY';
            h_bind_vars_values(4) := h_periodicity;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,4);
        ELSE
            -- Other periodicity, TIME_FK is VARCHAR2
            l_bind_vars_values.delete;
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                     'SELECT DISTINCT :1, :2, i.time_fk '||
                     'FROM '||x_input_table||' i, bsc_sys_periods p '||
                     'WHERE p.periodicity_id (+) = :3 AND i.time_fk = p.time_fk (+) '||
                     'AND (p.periodicity_id IS NULL OR p.time_fk IS NULL)';
            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_input_table;
            h_bind_vars_values(2) := 'TIME_FK';
            h_bind_vars_values(3) := h_periodicity;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,3);
        END IF;
    END IF;

    -- Validate type.
    -- Type should be registered in BSC_SYS_BENCHMARKS_B.DATA_TYPE
    -- Fix bug#4293829: Type 90 is used for user projection. We should allow this value
    h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
             'SELECT DISTINCT :1, :2, TO_CHAR(TYPE) '||
             'FROM '||x_input_table||' i, bsc_sys_benchmarks_b b '||
             'WHERE i.type = b.data_type (+) and i.type <> :3 and b.data_type is null';
    h_bind_vars_values.delete;
    h_bind_vars_values(1) := x_input_table;
    h_bind_vars_values(2) := 'TYPE';
    h_bind_vars_values(3) := 90;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,3);

    -- User should not enter actuals in target only tables
    IF h_target_flag = 1 THEN
        l_bind_vars_values.delete;
        h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code) '||
                 'SELECT DISTINCT :1, :2, TO_CHAR(TYPE) '||
                 'FROM '||x_input_table||' '||
                 'WHERE TYPE = :3';
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := x_input_table;
        h_bind_vars_values(2) := 'TYPE';
        h_bind_vars_values(3) := 0;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,h_bind_vars_values,3);
    END IF;

    COMMIT;

    -- Check if there were invalid codes
    SELECT COUNT(*)
    INTO h_num_rows
    FROM BSC_DB_VALIDATION
    WHERE ROWNUM < 2 AND INPUT_TABLE_NAME = x_input_table;

    IF h_num_rows > 0 THEN
        h_invalid := TRUE;
    ELSE
        h_invalid := FALSE;
    END IF;

    RETURN NOT h_invalid;

EXCEPTION
    WHEN e_unexpected_error THEN
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_ITABLE_VALID_FAILED'),
                      x_source => 'BSC_UPDATE_VAL.Validate_Codes');
      RETURN NULL;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_VAL.Validate_Codes');
      RETURN NULL;
END Validate_Codes;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Validate_Codes_AT
+============================================================================*/
FUNCTION Validate_Codes_AT(
	x_input_table IN VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Validate_Codes(x_input_table);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Validate_Codes_AT;


END BSC_UPDATE_VAL;

/
