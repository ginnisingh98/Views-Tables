--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_UTIL" AS
/* $Header: BSCDUTIB.pls 120.10 2007/03/15 09:46:11 ankgoel ship $ */


/*===========================================================================+
| PROCEDURE CloneBSCPeriodicitybyCalendar
+============================================================================*/
PROCEDURE CloneBSCPeriodicitybyCalendar (
    x_calendar_id IN NUMBER
    ) IS

    sql_stmt	VARCHAR2(2000); -- Sql statement string
    e_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;

    CURSOR c_base_per (p_calendar_id NUMBER, p_custom_code NUMBER) IS
        SELECT PERIODICITY_ID
        FROM BSC_SYS_PERIODICITIES
        WHERE CALENDAR_ID = p_calendar_id AND CUSTOM_CODE < p_custom_code
        ORDER BY PERIODICITY_ID;

    CURSOR c_new_per (p_calendar_id NUMBER) IS
        SELECT PERIODICITY_ID,SOURCE
        FROM BSC_SYS_PERIODICITIES
        WHERE CALENDAR_ID = p_calendar_id
        ORDER BY PERIODICITY_ID;

    h_periodicity_type NUMBER;

    CURSOR c_get_per (p_calendar_id NUMBER, p_periodicity_type NUMBER) IS
        SELECT PERIODICITY_ID
        FROM BSC_SYS_PERIODICITIES
        WHERE CALENDAR_ID = p_calendar_id AND PERIODICITY_TYPE = p_periodicity_type;

    h_periodicity_id NUMBER;
    h_source  VARCHAR2(200);
    h_tmp_array BSC_UPDATE_UTIL.t_array_of_number;
    h_count NUMBER;
    h_i NUMBER;
    h_new_per_id NUMBER;
    h_new_source  VARCHAR2(200);

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    -- Init BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    --Get all The Base periodicities
	--OPEN c_base_per FOR c_base_per_sql USING 1, 1;
        OPEN c_base_per(1, 1);
        FETCH c_base_per INTO h_periodicity_id;
	WHILE c_base_per%FOUND LOOP
		--Copy the periodicity with a new PERIODICITY_ID and CALENDAR_ID
		/*
                sql_stmt :=
		' INSERT INTO BSC_SYS_PERIODICITIES ' ||
		' (PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,PERIOD_COL_NAME, ' ||
		' SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID, ' ||
		' CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE) ' ||
		' SELECT BSC_SYS_PERIODICITY_ID_S.NEXTVAL PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS, '||
		' PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG, '||
		' :1 CALENDAR_ID,EDW_PERIODICITY_ID,CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE '||
		' FROM BSC_SYS_PERIODICITIES ' ||
		' WHERE PERIODICITY_ID = :2';

                h_bind_vars_values.delete;
                h_bind_vars_values(1) := x_calendar_id;
                h_bind_vars_values(2) := h_periodicity_id;
                h_num_bind_vars := 2;
	        BSC_UPDATE_UTIL.Execute_Immediate(sql_stmt, h_bind_vars_values, h_num_bind_vars);
                */
                INSERT INTO BSC_SYS_PERIODICITIES (
                PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,PERIOD_COL_NAME,
                SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,CALENDAR_ID,EDW_PERIODICITY_ID,
                CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE)
                SELECT BSC_SYS_PERIODICITY_ID_S.NEXTVAL PERIODICITY_ID,NUM_OF_PERIODS,SOURCE,NUM_OF_SUBPERIODS,
		PERIOD_COL_NAME,SUBPERIOD_COL_NAME,YEARLY_FLAG,EDW_FLAG,
		x_calendar_id CALENDAR_ID,EDW_PERIODICITY_ID,CUSTOM_CODE,DB_COLUMN_NAME,PERIODICITY_TYPE
		FROM BSC_SYS_PERIODICITIES
		WHERE PERIODICITY_ID = h_periodicity_id;

	        FETCH c_base_per INTO h_periodicity_id;
	END LOOP;
	CLOSE c_base_per;

	--- Update the SOURCE columns
	--OPEN c_new_per FOR c_new_per_sql USING x_calendar_id;
        OPEN c_new_per(x_calendar_id);
        FETCH c_new_per INTO h_periodicity_id,h_source;
	WHILE c_new_per%FOUND LOOP
		h_new_source := '';
		IF h_source IS NOT NULL THEN
			h_count := BSC_UPDATE_UTIL.Decompose_Numeric_List(h_source,h_tmp_array,',');
			FOR h_i IN 1.. h_count LOOP
				-- Get New Value
				h_periodicity_type := h_tmp_array(h_i);
				--OPEN c_get_per FOR c_get_per_sql USING x_calendar_id, h_periodicity_type;
                                OPEN c_get_per(x_calendar_id, h_periodicity_type);
				FETCH c_get_per INTO h_new_per_id;
				IF c_get_per%FOUND THEN
					IF h_new_source IS NOT NULL THEN
						h_new_source := h_new_source  || ',' || h_new_per_id;
					ELSE
						h_new_source :=h_new_per_id;
					END IF;
			        END IF;
			        CLOSE c_get_per;
			END LOOP;
			-- Update the source
                        /*
			sql_stmt := 'UPDATE BSC_SYS_PERIODICITIES SET SOURCE = :1 WHERE PERIODICITY_ID = :2';
                        EXECUTE IMMEDIATE sql_stmt USING  h_new_source, h_periodicity_id;
                        */
                        UPDATE BSC_SYS_PERIODICITIES
                        SET SOURCE = h_new_source
                        WHERE PERIODICITY_ID = h_periodicity_id;
		END IF;
	        FETCH c_new_per INTO h_periodicity_id,h_source;
	END LOOP;
	CLOSE c_new_per;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.CloneBSCPeriodicitybyCalendar',
                        x_mode => 'I');
        COMMIT;
END CloneBSCPeriodicitybyCalendar;


/*===========================================================================+
| FUNCTION Create_Unique_Index
+============================================================================*/
FUNCTION Create_Unique_Index(
	x_table_name IN VARCHAR2,
        x_index_name IN VARCHAR2,
        x_lst_columns IN VARCHAR2,
        x_tbs_type IN VARCHAR2
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;

    CURSOR c_index (p_index_name VARCHAR2) IS
        SELECT index_name
        FROM user_indexes
        WHERE index_name = p_index_name;

    CURSOR c_index_apps (p_index_name VARCHAR2, p_owner VARCHAR2) IS
        SELECT index_name
        FROM all_indexes
        WHERE index_name = p_index_name AND owner = p_owner;

    h_index VARCHAR2(30);
    h_do_it BOOLEAN;
    h_index_name VARCHAR2(50);

BEGIN
    h_do_it := FALSE;

    h_index_name := UPPER(x_index_name);

    IF NOT BSC_APPS.APPS_ENV THEN
        -- Personal
        --OPEN c_index FOR c_index_sql USING h_index_name;
        OPEN c_index(h_index_name);
        FETCH c_index INTO h_index;
        IF c_index%NOTFOUND THEN
            h_do_it := TRUE;
        END IF;
        CLOSE c_index;
    ELSE
        -- APPS
        --OPEN c_index_apps FOR c_index_apps_sql USING h_index_name, BSC_APPS.BSC_APPS_SCHEMA;
        OPEN c_index_apps(h_index_name, BSC_APPS.BSC_APPS_SCHEMA);
        FETCH c_index_apps INTO h_index;
        IF c_index_apps%NOTFOUND THEN
            h_do_it := TRUE;
        END IF;
        CLOSE c_index_apps;
    END IF;

    IF h_do_it THEN
        h_sql := 'CREATE UNIQUE INDEX '||x_index_name||
                 ' ON '||x_table_name||' ('||x_lst_columns||
                 ') TABLESPACE '||BSC_APPS.Get_Tablespace_Name(x_tbs_type)||
                 ' '||BSC_APPS.bsc_storage_clause;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_INDEX, x_index_name);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Create_Unique_Index');
        RETURN FALSE;

END Create_Unique_Index;


/*===========================================================================+
| FUNCTION getSmallerColumnList
| Added for Bug 4099338
+============================================================================*/
 function getSmallerColumnList(h_lst_cols_index in varchar2) return varchar2 is
 l_list varchar2(2000);
 l_index number;
 begin
    l_list:='';
    l_index:=INSTR(h_lst_cols_index, ',', -1, 1);
    l_list:=substr(h_lst_cols_index, 1, l_index-1);
    return l_list;
 end;


/*===========================================================================+
| FUNCTION Create_Global_Temp_Table
+============================================================================*/
FUNCTION Create_Global_Temp_Table(
        x_table_name IN VARCHAR2,
	x_table_columns IN BSC_UPDATE_UTIL.t_array_temp_table_cols,
        x_num_columns IN NUMBER
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    h_create_it BOOLEAN;
    h_drop_it BOOLEAN;

    CURSOR c_table_columns (p_table_name VARCHAR2, p_owner VARCHAR2) IS
        SELECT column_name, data_type, data_length, data_precision
        FROM all_tab_columns
        WHERE table_name = p_table_name AND owner = p_owner
        ORDER BY column_id;

    h_column_name VARCHAR2(30);
    h_data_type VARCHAR2(200);
    h_data_length NUMBER;
    h_data_precision NUMBER;

    h_lst_cols_desc VARCHAR2(32000);
    h_lst_cols_index VARCHAR2(32000);

    h_i NUMBER;
    h_count NUMBER;
    h_index_name VARCHAR2(30);
    h_need_index BOOLEAN;

BEGIN

    h_drop_it := FALSE;
    h_create_it := FALSE;

    -- If the table exists and the structure is the same then we do not
    -- re-create the temporal table

    SELECT COUNT(*)
    INTO h_count
    FROM all_tab_columns
    WHERE table_name = x_table_name AND owner = BSC_APPS.BSC_APPS_SCHEMA;

    IF h_count = 0 THEN
        -- table does not exists
        h_create_it := TRUE;
    ELSE
        IF h_count <> x_num_columns THEN
            -- structure is different or table does not exist
           h_drop_it := TRUE;
           h_create_it := TRUE;
        ELSE
            h_i := 1;
            OPEN c_table_columns(x_table_name, BSC_APPS.BSC_APPS_SCHEMA);
            LOOP
                FETCH c_table_columns INTO h_column_name, h_data_type, h_data_length, h_data_precision;
                EXIT WHEN c_table_columns%NOTFOUND;
                IF (UPPER(x_table_columns(h_i).column_name) <> h_column_name) OR
                   (x_table_columns(h_i).data_type <> h_data_type) OR
                   (h_data_type = 'VARCHAR2' AND (NVL(x_table_columns(h_i).data_size, 0) <> h_data_length)) OR
                   (h_data_type = 'NUMBER' AND (NVL(x_table_columns(h_i).data_size, 0) <> NVL(h_data_precision, 0))) THEN
                    -- structure is different
                    h_drop_it := TRUE;
                    h_create_it := TRUE;
                    EXIT;
                END IF;
                h_i := h_i + 1;
            END LOOP;
            CLOSE c_table_columns;
        END IF;
    END IF;

    IF h_drop_it THEN
        h_sql := 'DROP TABLE '||x_table_name;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, x_table_name);
    END IF;

    IF h_create_it THEN
       h_lst_cols_desc := NULL;
        h_lst_cols_index := NULL;

        FOR h_i IN 1..x_num_columns LOOP
            IF h_lst_cols_desc IS NOT NULL THEN
                h_lst_cols_desc := h_lst_cols_desc||', ';
            END IF;
            h_lst_cols_desc := h_lst_cols_desc||x_table_columns(h_i).column_name||
                               ' '||x_table_columns(h_i).data_type;
            IF x_table_columns(h_i).data_size IS NOT NULL THEN
                h_lst_cols_desc := h_lst_cols_desc||'('||x_table_columns(h_i).data_size||')';
            END IF;

            IF x_table_columns(h_i).add_to_index = 'Y' THEN
                IF h_lst_cols_index IS NOT NULL THEN
                    h_lst_cols_index := h_lst_cols_index||', ';
                END IF;
                h_lst_cols_index := h_lst_cols_index||x_table_columns(h_i).column_name;
            END IF;
        END LOOP;

        h_sql := 'CREATE GLOBAL TEMPORARY TABLE '||x_table_name||' ('||h_lst_cols_desc||
                 ') ON COMMIT PRESERVE ROWS';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_TABLE, x_table_name);

        -- Create index
        IF h_lst_cols_index IS NOT NULL THEN
            h_index_name := x_table_name||'_N1';
            loop	--modifed code for 4099338
            	begin
                    h_sql := 'CREATE INDEX '||h_index_name||
            	             ' ON '||x_table_name||' ('||h_lst_cols_index||')';
            	    BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_INDEX, h_index_name);
            	    exit;
            	exception
            	    when others then
            	        if h_lst_cols_index is null then
                            BSC_MESSAGE.Add(x_message => 'x_table_name='||x_table_name,
                                            x_source => 'BSC_UPDATE_UTIL.Create_Global_Temp_Table');
                            BSC_MESSAGE.Add(x_message => 'l_index_count=0.Unable to create Index on any Key columns',
                                            x_source => 'BSC_UPDATE_UTIL.Create_Global_Temp_Table');
                            RETURN FALSE;
                        end if;
                	h_lst_cols_index:=getSmallerColumnList(h_lst_cols_index);
            	end;
	    end loop;
        END IF;
    ELSE
        -- Bug#3875046
        -- there was no need to re-create the table, but may be the case
        -- we want to drop existing index since the index is not needed anymore
        h_need_index := FALSE;

        FOR h_i IN 1..x_num_columns LOOP
            IF x_table_columns(h_i).add_to_index = 'Y' THEN
                h_need_index := TRUE;
                EXIT;
            END IF;
        END LOOP;

        IF NOT h_need_index THEN
            h_index_name := x_table_name||'_N1';

            SELECT COUNT(*)
            INTO h_count
            FROM all_indexes
            WHERE index_name = h_index_name AND owner = BSC_APPS.BSC_APPS_SCHEMA;

            IF h_count > 0 THEN
                -- Index exist but it is not needed
                h_sql := 'DROP INDEX '||h_index_name;
                BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_INDEX, h_index_name);
            END IF;
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => 'x_table_name='||x_table_name,
                        x_source => 'BSC_UPDATE_UTIL.Create_Global_Temp_Table');
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Create_Global_Temp_Table');
        RETURN FALSE;

END Create_Global_Temp_Table;


/*===========================================================================+
| FUNCTION Create_Permanent_Table
+============================================================================*/
FUNCTION Create_Permanent_Table(
        x_table_name IN VARCHAR2,
	x_table_columns IN BSC_UPDATE_UTIL.t_array_temp_table_cols,
        x_num_columns IN NUMBER,
        x_tablespace IN VARCHAR2,
        x_idx_tablespace IN VARCHAR2
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    h_create_it BOOLEAN;
    h_drop_it BOOLEAN;

    CURSOR c_table_columns (p_table_name VARCHAR2, p_owner VARCHAR2) IS
        SELECT column_name, data_type, data_length, data_precision
        FROM all_tab_columns
        WHERE table_name = p_table_name AND owner = p_owner
        ORDER BY column_id;

    h_column_name VARCHAR2(30);
    h_data_type VARCHAR2(200);
    h_data_length NUMBER;
    h_data_precision NUMBER;

    h_lst_cols_desc VARCHAR2(32000);
    h_lst_cols_index VARCHAR2(32000);

    h_i NUMBER;
    h_count NUMBER;
    h_index_name VARCHAR2(30);

BEGIN

    h_drop_it := FALSE;
    h_create_it := FALSE;

    -- If the table exists and the structure is the same then we do not
    -- re-create the temporal table

    SELECT COUNT(*)
    INTO h_count
    FROM all_tab_columns
    WHERE table_name = x_table_name AND owner = BSC_APPS.BSC_APPS_SCHEMA;

    IF h_count = 0 THEN
        -- table does not exists
        h_create_it := TRUE;
    ELSE
        IF h_count <> x_num_columns THEN
            -- structure is different or table does not exist
           h_drop_it := TRUE;
           h_create_it := TRUE;
        ELSE
            h_i := 1;
            OPEN c_table_columns(x_table_name, BSC_APPS.BSC_APPS_SCHEMA);
            LOOP
                FETCH c_table_columns INTO h_column_name, h_data_type, h_data_length, h_data_precision;
                EXIT WHEN c_table_columns%NOTFOUND;
                IF (UPPER(x_table_columns(h_i).column_name) <> h_column_name) OR
                   (x_table_columns(h_i).data_type <> h_data_type) OR
                   (h_data_type = 'VARCHAR2' AND (NVL(x_table_columns(h_i).data_size, 0) <> h_data_length)) OR
                   (h_data_type = 'NUMBER' AND (NVL(x_table_columns(h_i).data_size, 0) <> NVL(h_data_precision, 0))) THEN
                    -- structure is different
                    h_drop_it := TRUE;
                    h_create_it := TRUE;
                    EXIT;
                END IF;
                h_i := h_i + 1;
            END LOOP;
            CLOSE c_table_columns;
        END IF;
    END IF;

    IF h_drop_it THEN
        h_sql := 'DROP TABLE '||x_table_name;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, x_table_name);
    END IF;

    IF h_create_it THEN
       h_lst_cols_desc := NULL;
        h_lst_cols_index := NULL;

        FOR h_i IN 1..x_num_columns LOOP
            IF h_lst_cols_desc IS NOT NULL THEN
                h_lst_cols_desc := h_lst_cols_desc||', ';
            END IF;
            h_lst_cols_desc := h_lst_cols_desc||x_table_columns(h_i).column_name||
                               ' '||x_table_columns(h_i).data_type;
            IF x_table_columns(h_i).data_size IS NOT NULL THEN
                h_lst_cols_desc := h_lst_cols_desc||'('||x_table_columns(h_i).data_size||')';
            END IF;

            IF x_table_columns(h_i).add_to_index = 'Y' THEN
                IF h_lst_cols_index IS NOT NULL THEN
                    h_lst_cols_index := h_lst_cols_index||', ';
                END IF;
                h_lst_cols_index := h_lst_cols_index||x_table_columns(h_i).column_name;
            END IF;
        END LOOP;

        h_sql := 'CREATE TABLE '||x_table_name||' ('||h_lst_cols_desc||')'||
                 ' TABLESPACE '||x_tablespace||
                 ' '||BSC_APPS.bsc_storage_clause;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_TABLE, x_table_name);

        -- Create index
        IF h_lst_cols_index IS NOT NULL THEN
            h_index_name := x_table_name||'_N1';
            h_sql := 'CREATE INDEX '||h_index_name||
                     ' ON '||x_table_name||' ('||h_lst_cols_index||')'||
                     ' TABLESPACE '||x_idx_tablespace||
                     ' '||BSC_APPS.bsc_storage_clause;
            BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_INDEX, h_index_name);
        END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => 'x_table_name='||x_table_name,
                        x_source => 'BSC_UPDATE_UTIL.Create_Permanent_Table');
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Create_Permanent_Table');
        RETURN FALSE;

END Create_Permanent_Table;


/*===========================================================================+
| FUNCTION Decompose_Numeric_List
+============================================================================*/
FUNCTION Decompose_Numeric_List(
	x_string IN VARCHAR2,
	x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
	) RETURN NUMBER IS

    h_num_items NUMBER;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN
    h_num_items := 0;

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1))));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(h_sub_string)));

    END IF;

    RETURN h_num_items;

END Decompose_Numeric_List;


/*===========================================================================+
| FUNCTION Decompose_Varchar2_List
+============================================================================*/
FUNCTION Decompose_Varchar2_List(
	x_string IN VARCHAR2,
	x_array IN OUT NOCOPY t_array_of_varchar2,
        x_separator IN VARCHAR2
	) RETURN NUMBER IS

    h_num_items NUMBER;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN
    h_num_items := 0;

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_array(h_num_items) := RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1)));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_array(h_num_items) := RTRIM(LTRIM(h_sub_string));

    END IF;

    RETURN h_num_items;

END Decompose_Varchar2_List;


/*===========================================================================+
| FUNCTION Drop_Index
+============================================================================*/
FUNCTION Drop_Index(
        x_index_name IN VARCHAR2
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(200);

    TYPE t_cursor IS REF CURSOR;

    /*
    c_index t_cursor; -- x_index_name
    c_index_sql VARCHAR2(2000) := 'SELECT index_name'||
                                  ' FROM user_indexes'||
                                  ' WHERE index_name = :1';
    */
    CURSOR c_index (p_index_name VARCHAR2) IS
        SELECT index_name
        FROM user_indexes
        WHERE index_name = p_index_name;

    /*
    c_index_apps t_cursor; -- x_index_name, BSC_APPS.BSC_APPS_SCHEMA
    c_index_apps_sql VARCHAR2(2000) := 'SELECT index_name'||
                                       ' FROM all_indexes'||
                                       ' WHERE index_name = :1 AND owner = :2';
    */
    CURSOR c_index_apps (p_index_name VARCHAR2, p_owner VARCHAR2) IS
        SELECT index_name
        FROM all_indexes
        WHERE index_name = p_index_name AND owner = p_owner;

    h_index VARCHAR2(30);
    h_do_it BOOLEAN;
    h_index_name VARCHAR2(50);
BEGIN
    h_do_it := FALSE;

    h_index_name := UPPER(x_index_name);

    IF NOT BSC_APPS.APPS_ENV THEN
        -- Personal
        --OPEN c_index FOR c_index_sql USING h_index_name;
        OPEN c_index(h_index_name);
        FETCH c_index INTO h_index;
        IF c_index%FOUND THEN
            h_do_it := TRUE;
        END IF;
        CLOSE c_index;
    ELSE
        -- Personal
        --OPEN c_index_apps FOR c_index_apps_sql USING h_index_name, BSC_APPS.BSC_APPS_SCHEMA;
        OPEN c_index_apps(h_index_name, BSC_APPS.BSC_APPS_SCHEMA);
        FETCH c_index_apps INTO h_index;
        IF c_index_apps%FOUND THEN
            h_do_it := TRUE;
        END IF;
        CLOSE c_index_apps;
    END IF;

    IF h_do_it THEN
        h_sql := 'DROP INDEX '||x_index_name;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_INDEX, x_index_name);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Drop_Index');
        RETURN FALSE;
END Drop_Index;


/*===========================================================================+
| FUNCTION Drop_Table
+============================================================================*/
FUNCTION Drop_Table(
        x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(200);

BEGIN
    -- Drop table if exits
    IF Table_Exists(x_table_name) THEN
        -- Truncate table to release space --> Bug: DROP TABLE don't release the space immediately
        Truncate_Table(x_table_name);

        h_sql := 'DROP TABLE '||x_table_name;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, x_table_name);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Drop_Table');
        RETURN FALSE;
END Drop_Table;


/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN VARCHAR2
	) IS

BEGIN
--BIS_IM_UTILS.write_to_log_file_n(x_sql);
--BSC_UPDATE_LOG.Write_Line_Log(x_sql, BSC_UPDATE_LOG.LOG);

    EXECUTE IMMEDIATE x_sql;

END Execute_Immediate;


-- ENH_B_TABLES_PERF: new procedure
/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN clob
	) IS

    type t_array_of_varchar2 IS TABLE OF VARCHAR2(20000) INDEX BY BINARY_INTEGER;
    h_sql_tbl t_array_of_varchar2;
    h_i number;
    h_j number;
    h_offset number;
    h_clob_length number;
    h_str_length number;

BEGIN
    h_str_length := 16000;
    h_clob_length := dbms_lob.getlength(x_sql);
    h_sql_tbl.delete;
    h_i := 0;
    h_offset := 1;
    loop
        h_i := h_i + 1;
        h_sql_tbl(h_i) := dbms_lob.substr(x_sql, h_str_length, h_offset);
        h_offset := h_offset + h_str_length;
        exit when h_offset > h_clob_length;
    end loop;

    for h_j in (h_i + 1)..20 loop
        h_sql_tbl(h_j) := null;
    end loop;

    EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
    h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
    h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
    h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20);

END Execute_Immediate;


--Fix bug#3875046
/*===========================================================================+
| FUCTION Execute_Immediate
+============================================================================*/
FUNCTION Execute_Immediate(
	x_sql IN VARCHAR2
	) RETURN NUMBER IS

BEGIN
--BIS_IM_UTILS.write_to_log_file_n(x_sql);
--BSC_UPDATE_LOG.Write_Line_Log(x_sql, BSC_UPDATE_LOG.LOG);

    EXECUTE IMMEDIATE x_sql;
    RETURN SQL%ROWCOUNT;

END Execute_Immediate;


/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars IN NUMBER
) IS

    l_sql VARCHAR2(32700);
    l_sql_quote VARCHAR2(32700);

BEGIN
--BIS_IM_UTILS.write_to_log_file_n(x_sql);
--BSC_UPDATE_LOG.Write_Line_Log(x_sql, BSC_UPDATE_LOG.LOG);

    IF x_num_bind_vars = 0 THEN
        EXECUTE IMMEDIATE x_sql;
    ELSIF x_num_bind_vars = 1 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1);
    ELSIF x_num_bind_vars = 2 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2);
    ELSIF x_num_bind_vars = 3 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3);
    ELSIF x_num_bind_vars = 4 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4);
    ELSIF x_num_bind_vars = 5 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5);
    ELSIF x_num_bind_vars = 6 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6);
    ELSIF x_num_bind_vars = 7 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7);
    ELSIF x_num_bind_vars = 8 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8);
    ELSIF x_num_bind_vars = 9 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9);
    ELSIF x_num_bind_vars = 10 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10);
    ELSIF x_num_bind_vars = 11 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11);
    ELSIF x_num_bind_vars = 12 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12);
    ELSIF x_num_bind_vars = 13 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13);
    ELSIF x_num_bind_vars = 14 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14);
    ELSIF x_num_bind_vars = 15 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14)
        , x_bind_vars_values(15);
    ELSIF x_num_bind_vars = 16 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16);
    ELSIF x_num_bind_vars = 17 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17);
    ELSIF x_num_bind_vars = 18 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18);
    ELSIF x_num_bind_vars = 19 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19);
    ELSIF x_num_bind_vars = 20 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19), x_bind_vars_values(20);
    ELSE
        l_sql_quote := REPLACE(x_sql, '''', '''''');
        l_sql := 'BEGIN EXECUTE IMMEDIATE '''||l_sql_quote||''' USING';
        FOR h_i IN 1..x_num_bind_vars LOOP
            IF h_i > 1 THEN
                l_sql := l_sql||',';
            END IF;
            l_sql := l_sql||' '''||x_bind_vars_values(h_i)||'''';
        END LOOP;
        l_sql := l_sql||'; END;';
        EXECUTE IMMEDIATE l_sql;
    END IF;

END Execute_Immediate;


-- ENH_B_TABLES_PERF: new procedure
/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN clob,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars IN NUMBER
) IS

    l_sql VARCHAR2(32700);
    l_sql_quote VARCHAR2(32700);

    type t_array_of_varchar2 IS TABLE OF VARCHAR2(20000) INDEX BY BINARY_INTEGER;
    h_sql_tbl t_array_of_varchar2;
    h_i number;
    h_j number;
    h_offset number;
    h_clob_length number;
    h_str_length number;

BEGIN

    h_str_length := 16000;
    h_clob_length := dbms_lob.getlength(x_sql);
    h_sql_tbl.delete;
    h_i := 0;
    h_offset := 1;
    loop
        h_i := h_i + 1;
        h_sql_tbl(h_i) := dbms_lob.substr(x_sql, h_str_length, h_offset);
        h_offset := h_offset + h_str_length;
        exit when h_offset > h_clob_length;
    end loop;

    for h_j in (h_i + 1)..20 loop
        h_sql_tbl(h_j) := null;
    end loop;

    IF x_num_bind_vars = 0 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20);
    ELSIF x_num_bind_vars = 1 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1);
    ELSIF x_num_bind_vars = 2 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2);
    ELSIF x_num_bind_vars = 3 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3);
    ELSIF x_num_bind_vars = 4 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4);
    ELSIF x_num_bind_vars = 5 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5);
    ELSIF x_num_bind_vars = 6 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6);
    ELSIF x_num_bind_vars = 7 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7);
    ELSIF x_num_bind_vars = 8 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8);
    ELSIF x_num_bind_vars = 9 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9);
    ELSIF x_num_bind_vars = 10 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10);
    ELSIF x_num_bind_vars = 11 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11);
    ELSIF x_num_bind_vars = 12 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12);
    ELSIF x_num_bind_vars = 13 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13);
    ELSIF x_num_bind_vars = 14 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14);
    ELSIF x_num_bind_vars = 15 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14)
        , x_bind_vars_values(15);
    ELSIF x_num_bind_vars = 16 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16);
    ELSIF x_num_bind_vars = 17 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17);
    ELSIF x_num_bind_vars = 18 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18);
    ELSIF x_num_bind_vars = 19 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19);
    ELSIF x_num_bind_vars = 20 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19), x_bind_vars_values(20);
    END IF;

END Execute_Immediate;


--Fix bug#3875046
/*===========================================================================+
| FUNCTION Execute_Immediate
+============================================================================*/
FUNCTION Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars IN NUMBER
) RETURN NUMBER IS

    l_sql VARCHAR2(32700);
    l_sql_quote VARCHAR2(32700);

BEGIN
--BIS_IM_UTILS.write_to_log_file_n(x_sql);
--BSC_UPDATE_LOG.Write_Line_Log(x_sql, BSC_UPDATE_LOG.LOG);

    IF x_num_bind_vars = 0 THEN
        EXECUTE IMMEDIATE x_sql;
    ELSIF x_num_bind_vars = 1 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1);
    ELSIF x_num_bind_vars = 2 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2);
    ELSIF x_num_bind_vars = 3 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3);
    ELSIF x_num_bind_vars = 4 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4);
    ELSIF x_num_bind_vars = 5 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5);
    ELSIF x_num_bind_vars = 6 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6);
    ELSIF x_num_bind_vars = 7 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7);
    ELSIF x_num_bind_vars = 8 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8);
    ELSIF x_num_bind_vars = 9 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9);
    ELSIF x_num_bind_vars = 10 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10);
    ELSIF x_num_bind_vars = 11 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11);
    ELSIF x_num_bind_vars = 12 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12);
    ELSIF x_num_bind_vars = 13 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13);
    ELSIF x_num_bind_vars = 14 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14);
    ELSIF x_num_bind_vars = 15 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14)
        , x_bind_vars_values(15);
    ELSIF x_num_bind_vars = 16 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16);
    ELSIF x_num_bind_vars = 17 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17);
    ELSIF x_num_bind_vars = 18 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18);
    ELSIF x_num_bind_vars = 19 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19);
    ELSIF x_num_bind_vars = 20 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19), x_bind_vars_values(20);
    ELSE
        l_sql_quote := REPLACE(x_sql, '''', '''''');
        l_sql := 'BEGIN EXECUTE IMMEDIATE '''||l_sql_quote||''' USING';
        FOR h_i IN 1..x_num_bind_vars LOOP
            IF h_i > 1 THEN
                l_sql := l_sql||',';
            END IF;
            l_sql := l_sql||' '''||x_bind_vars_values(h_i)||'''';
        END LOOP;
        l_sql := l_sql||'; END;';
        EXECUTE IMMEDIATE l_sql;
    END IF;

    RETURN SQL%ROWCOUNT;

END Execute_Immediate;


/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_bind_vars IN NUMBER
) IS

    l_sql VARCHAR2(32700);
    l_sql_quote VARCHAR2(32700);

BEGIN
--BIS_IM_UTILS.write_to_log_file_n(x_sql);
--BSC_UPDATE_LOG.Write_Line_Log(x_sql, BSC_UPDATE_LOG.LOG);

    IF x_num_bind_vars = 0 THEN
        EXECUTE IMMEDIATE x_sql;
    ELSIF x_num_bind_vars = 1 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1);
    ELSIF x_num_bind_vars = 2 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2);
    ELSIF x_num_bind_vars = 3 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3);
    ELSIF x_num_bind_vars = 4 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4);
    ELSIF x_num_bind_vars = 5 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5);
    ELSIF x_num_bind_vars = 6 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6);
    ELSIF x_num_bind_vars = 7 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7);
    ELSIF x_num_bind_vars = 8 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8);
    ELSIF x_num_bind_vars = 9 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9);
    ELSIF x_num_bind_vars = 10 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10);
    ELSIF x_num_bind_vars = 11 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11);
    ELSIF x_num_bind_vars = 12 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12);
    ELSIF x_num_bind_vars = 13 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13);
    ELSIF x_num_bind_vars = 14 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14);
    ELSIF x_num_bind_vars = 15 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15);
    ELSIF x_num_bind_vars = 16 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16);
    ELSIF x_num_bind_vars = 17 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17);
    ELSIF x_num_bind_vars = 18 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18);
    ELSIF x_num_bind_vars = 19 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19);
    ELSIF x_num_bind_vars = 20 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19), x_bind_vars_values(20);
    ELSE
        l_sql_quote := REPLACE(x_sql, '''', '''''');
        l_sql := 'BEGIN EXECUTE IMMEDIATE '''||l_sql_quote||''' USING';
        FOR h_i IN 1..x_num_bind_vars LOOP
            IF h_i > 1 THEN
                l_sql := l_sql||',';
            END IF;
            l_sql := l_sql||' '||x_bind_vars_values(h_i);
        END LOOP;
        l_sql := l_sql||'; END;';
        EXECUTE IMMEDIATE l_sql;
    END IF;

END Execute_Immediate;


-- ENH_B_TABLES_PERF: new procedure
/*===========================================================================+
| PROCEDURE Execute_Immediate
+============================================================================*/
PROCEDURE Execute_Immediate(
	x_sql IN clob,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_bind_vars IN NUMBER
) IS

    l_sql VARCHAR2(32700);
    l_sql_quote VARCHAR2(32700);

    type t_array_of_varchar2 IS TABLE OF VARCHAR2(20000) INDEX BY BINARY_INTEGER;
    h_sql_tbl t_array_of_varchar2;
    h_i number;
    h_j number;
    h_offset number;
    h_clob_length number;
    h_str_length number;

BEGIN

    h_str_length := 16000;
    h_clob_length := dbms_lob.getlength(x_sql);
    h_sql_tbl.delete;
    h_i := 0;
    h_offset := 1;
    loop
        h_i := h_i + 1;
        h_sql_tbl(h_i) := dbms_lob.substr(x_sql, h_str_length, h_offset);
        h_offset := h_offset + h_str_length;
        exit when h_offset > h_clob_length;
    end loop;

    for h_j in (h_i + 1)..20 loop
        h_sql_tbl(h_j) := null;
    end loop;

    IF x_num_bind_vars = 0 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20);
    ELSIF x_num_bind_vars = 1 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1);
    ELSIF x_num_bind_vars = 2 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2);
    ELSIF x_num_bind_vars = 3 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3);
    ELSIF x_num_bind_vars = 4 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4);
    ELSIF x_num_bind_vars = 5 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5);
    ELSIF x_num_bind_vars = 6 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6);
    ELSIF x_num_bind_vars = 7 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7);
    ELSIF x_num_bind_vars = 8 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8);
    ELSIF x_num_bind_vars = 9 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9);
    ELSIF x_num_bind_vars = 10 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10);
    ELSIF x_num_bind_vars = 11 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11);
    ELSIF x_num_bind_vars = 12 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12);
    ELSIF x_num_bind_vars = 13 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13);
    ELSIF x_num_bind_vars = 14 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14);
    ELSIF x_num_bind_vars = 15 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14)
        , x_bind_vars_values(15);
    ELSIF x_num_bind_vars = 16 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16);
    ELSIF x_num_bind_vars = 17 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17);
    ELSIF x_num_bind_vars = 18 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18);
    ELSIF x_num_bind_vars = 19 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19);
    ELSIF x_num_bind_vars = 20 THEN
        EXECUTE IMMEDIATE h_sql_tbl(1)||h_sql_tbl(2)||h_sql_tbl(3)||h_sql_tbl(4)||h_sql_tbl(5)||
        h_sql_tbl(6)||h_sql_tbl(7)||h_sql_tbl(8)||h_sql_tbl(9)||h_sql_tbl(10)||
        h_sql_tbl(11)||h_sql_tbl(12)||h_sql_tbl(13)||h_sql_tbl(14)||h_sql_tbl(15)||
        h_sql_tbl(16)||h_sql_tbl(17)||h_sql_tbl(18)||h_sql_tbl(19)||h_sql_tbl(20)
        USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19), x_bind_vars_values(20);
    END IF;

END Execute_Immediate;


--Fix bug#3875046
/*===========================================================================+
| FUNCTION Execute_Immediate
+============================================================================*/
FUNCTION Execute_Immediate(
	x_sql IN VARCHAR2,
        x_bind_vars_values IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_bind_vars IN NUMBER
) RETURN NUMBER IS

    l_sql VARCHAR2(32700);
    l_sql_quote VARCHAR2(32700);

BEGIN
--BIS_IM_UTILS.write_to_log_file_n(x_sql);
--BSC_UPDATE_LOG.Write_Line_Log(x_sql, BSC_UPDATE_LOG.LOG);

    IF x_num_bind_vars = 0 THEN
        EXECUTE IMMEDIATE x_sql;
    ELSIF x_num_bind_vars = 1 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1);
    ELSIF x_num_bind_vars = 2 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2);
    ELSIF x_num_bind_vars = 3 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3);
    ELSIF x_num_bind_vars = 4 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4);
    ELSIF x_num_bind_vars = 5 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5);
    ELSIF x_num_bind_vars = 6 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6);
    ELSIF x_num_bind_vars = 7 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7);
    ELSIF x_num_bind_vars = 8 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8);
    ELSIF x_num_bind_vars = 9 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9);
    ELSIF x_num_bind_vars = 10 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10);
    ELSIF x_num_bind_vars = 11 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11);
    ELSIF x_num_bind_vars = 12 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12);
    ELSIF x_num_bind_vars = 13 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13);
    ELSIF x_num_bind_vars = 14 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14);
    ELSIF x_num_bind_vars = 15 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15);
    ELSIF x_num_bind_vars = 16 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16);
    ELSIF x_num_bind_vars = 17 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17);
    ELSIF x_num_bind_vars = 18 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18);
    ELSIF x_num_bind_vars = 19 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19);
    ELSIF x_num_bind_vars = 20 THEN
        EXECUTE IMMEDIATE x_sql USING x_bind_vars_values(1), x_bind_vars_values(2),
        x_bind_vars_values(3), x_bind_vars_values(4), x_bind_vars_values(5),
        x_bind_vars_values(6), x_bind_vars_values(7), x_bind_vars_values(8),
        x_bind_vars_values(9), x_bind_vars_values(10), x_bind_vars_values(11),
        x_bind_vars_values(12), x_bind_vars_values(13), x_bind_vars_values(14),
        x_bind_vars_values(15), x_bind_vars_values(16), x_bind_vars_values(17),
        x_bind_vars_values(18), x_bind_vars_values(19), x_bind_vars_values(20);
    ELSE
        l_sql_quote := REPLACE(x_sql, '''', '''''');
        l_sql := 'BEGIN EXECUTE IMMEDIATE '''||l_sql_quote||''' USING';
        FOR h_i IN 1..x_num_bind_vars LOOP
            IF h_i > 1 THEN
                l_sql := l_sql||',';
            END IF;
            l_sql := l_sql||' '||x_bind_vars_values(h_i);
        END LOOP;
        l_sql := l_sql||'; END;';
        EXECUTE IMMEDIATE l_sql;
    END IF;

    RETURN SQL%ROWCOUNT;

END Execute_Immediate;


/*===========================================================================+
| FUNCTION Exist_Periodicity_Rel
+============================================================================*/
FUNCTION Exist_Periodicity_Rel(
    x_periodicity_id IN NUMBER,
    x_source_periodicity_id IN NUMBER
    ) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN

    FOR h_i IN 1..g_array_periodicity_rels.COUNT LOOP
        IF g_array_periodicity_rels(h_i).periodicity_id = x_periodicity_id AND
           g_array_periodicity_rels(h_i).source_periodicity_id = x_source_periodicity_id THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Exist_Periodicity_Rel;


/*===========================================================================+
| FUNCTION Get_Calendar_EDW_Flag
+============================================================================*/
FUNCTION Get_Calendar_EDW_Flag(
	x_calendar_id IN NUMBER
	) RETURN NUMBER IS

    h_edw_flag NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN

    IF g_array_calendars.exists(x_calendar_id) THEN
        IF g_array_calendars(x_calendar_id).edw_flag IS NOT NULL THEN
            RETURN g_array_calendars(x_calendar_id).edw_flag;
        END IF;
    END IF;

    /* h_sql := 'SELECT edw_flag'||
             ' FROM bsc_sys_calendars_b'||
             ' WHERE calendar_id = :1';
    OPEN h_cursor FOR h_sql USING x_calendar_id;
    FETCH h_cursor INTO h_edw_flag;
    CLOSE h_cursor; */
    begin
      SELECT edw_flag
      into h_edw_flag
      FROM bsc_sys_calendars_b
      where calendar_id = x_calendar_id;
    exception when no_data_found then h_edw_flag := null;
    end;

    g_array_calendars(x_calendar_id).edw_flag := h_edw_flag;

    RETURN h_edw_flag;

END Get_Calendar_EDW_Flag;


/*===========================================================================+
| FUNCTION Get_Calendar_Source
+============================================================================*/
FUNCTION Get_Calendar_Source(
	x_calendar_id IN NUMBER
	) RETURN VARCHAR2 IS

    h_calendar_source VARCHAR2(20);

    h_sql VARCHAR2(32000);

BEGIN

    IF g_array_calendars.exists(x_calendar_id) THEN
        IF g_array_calendars(x_calendar_id).source IS NOT NULL THEN
            RETURN g_array_calendars(x_calendar_id).source;
        END IF;
    END IF;

    begin
      SELECT decode(nvl(edw_calendar_type_id, 0), 1, 'PMF', 'BSC')
      INTO h_calendar_source
      FROM bsc_sys_calendars_b
      where calendar_id = x_calendar_id;
    exception when no_data_found then h_calendar_source := null;
    end;

    g_array_calendars(x_calendar_id).source := h_calendar_source;

    RETURN h_calendar_source;

END Get_Calendar_Source;


/*===========================================================================+
| FUNCTION Get_Calendar_Fiscal_Year
+============================================================================*/
FUNCTION Get_Calendar_Fiscal_Year(
	x_calendar_id IN NUMBER
	) RETURN NUMBER IS

    h_fiscal_year NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    h_fiscal_year := 0;

    IF g_array_calendars.exists(x_calendar_id) THEN
        IF g_array_calendars(x_calendar_id).fiscal_year IS NOT NULL THEN
            RETURN g_array_calendars(x_calendar_id).fiscal_year;
        END IF;
    END IF;

    /*
    h_sql := 'SELECT fiscal_year'||
             ' FROM bsc_sys_calendars_b'||
             ' WHERE calendar_id = :1';
    OPEN h_cursor FOR h_sql USING x_calendar_id;
    FETCH h_cursor INTO h_fiscal_year;
    CLOSE h_cursor;
    */
    SELECT fiscal_year
    INTO h_fiscal_year
    FROM bsc_sys_calendars_b
    WHERE calendar_id = x_calendar_id;

    g_array_calendars(x_calendar_id).fiscal_year := h_fiscal_year;

    RETURN h_fiscal_year;

END Get_Calendar_Fiscal_Year;


/*===========================================================================+
| FUNCTION Get_Calendar_Id
+============================================================================*/
FUNCTION Get_Calendar_Id(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER IS

    h_calendar_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN

   IF g_array_periodicities.exists(x_periodicity_id) THEN
       IF g_array_periodicities(x_periodicity_id).calendar_id IS NOT NULL THEN
           RETURN g_array_periodicities(x_periodicity_id).calendar_id;
       END IF;
   END IF;

   /*
   h_sql := 'SELECT calendar_id'||
            ' FROM bsc_sys_periodicities'||
            ' WHERE periodicity_id = :1';
   OPEN h_cursor FOR h_sql USING x_periodicity_id;
   FETCH h_cursor INTO h_calendar_id;
   CLOSE h_cursor;
   */
   SELECT calendar_id
   INTO h_calendar_id
   FROM bsc_sys_periodicities
   WHERE periodicity_id = x_periodicity_id;

   g_array_periodicities(x_periodicity_id).calendar_id := h_calendar_id;

   RETURN h_calendar_id;

END Get_Calendar_Id;


/*===========================================================================+
| FUNCTION Get_Calendar_Name
+============================================================================*/
FUNCTION Get_Calendar_Name(
	x_calendar_id IN NUMBER
	) RETURN VARCHAR2 IS

    h_calendar_name VARCHAR2(400);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    /*
    h_sql := 'SELECT DECODE(C.EDW_FLAG, 0, C.NAME, C.NAME||'' (''||T.NAME||'')'')'||
             ' FROM BSC_SYS_CALENDARS_VL C, BSC_EDW_CALENDAR_TYPE_VL T'||
             ' WHERE C.CALENDAR_ID = :1 AND C.EDW_CALENDAR_TYPE_ID = T.EDW_CALENDAR_TYPE_ID (+)';
    OPEN h_cursor FOR h_sql USING x_calendar_id;
    FETCH h_cursor INTO h_calendar_name;
    CLOSE h_cursor;
    */
    SELECT DECODE(C.EDW_FLAG, 0, C.NAME, C.NAME||' ('||T.NAME||')')
    INTO h_calendar_name
    FROM BSC_SYS_CALENDARS_VL C, BSC_EDW_CALENDAR_TYPE_VL T
    WHERE C.CALENDAR_ID = x_calendar_id AND C.EDW_CALENDAR_TYPE_ID = T.EDW_CALENDAR_TYPE_ID (+);

    RETURN h_calendar_name;

END Get_Calendar_Name;


/*===========================================================================+
| FUNCTION Get_Calendar_Start_Date
+============================================================================*/
FUNCTION Get_Calendar_Start_Date(
	x_calendar_id IN NUMBER,
	x_current_fy IN NUMBER,
	x_start_year OUT NOCOPY NUMBER,
	x_start_month OUT NOCOPY NUMBER,
	x_start_day OUT NOCOPY NUMBER
      ) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    IF g_array_calendars.exists(x_calendar_id) THEN
        IF g_array_calendars(x_calendar_id).start_year IS NOT NULL THEN
            x_start_year := g_array_calendars(x_calendar_id).start_year;
            x_start_month := g_array_calendars(x_calendar_id).start_month;
	    x_start_day := g_array_calendars(x_calendar_id).start_day;
            RETURN TRUE;
        END IF;
    END IF;

    /*
    h_sql := 'SELECT current_year, start_month, start_day'||
             ' FROM bsc_sys_calendars_b'||
             ' WHERE calendar_id = :1';
    OPEN h_cursor FOR h_sql USING x_calendar_id;
    FETCH h_cursor INTO x_start_year, x_start_month, x_start_day;
    CLOSE h_cursor;
    */
    SELECT current_year, start_month, start_day
    INTO x_start_year, x_start_month, x_start_day
    FROM bsc_sys_calendars_b
    WHERE calendar_id = x_calendar_id;

    -- Fix the start year
    IF x_start_month = 1 THEN
        x_start_year := x_current_fy;
    ELSE
        x_start_year := x_current_fy - 1;
    END IF;

    UPDATE bsc_sys_calendars_b
    SET current_year = x_start_year
    WHERE calendar_id = x_calendar_id;

    g_array_calendars(x_calendar_id).start_year := x_start_year;
    g_array_calendars(x_calendar_id).start_month := x_start_month;
    g_array_calendars(x_calendar_id).start_day := x_start_day;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Calendar_Start_Date');
        RETURN FALSE;
END Get_Calendar_Start_Date;


/*===========================================================================+
| FUNCTION Get_Calendar_Table_Col_Name
+============================================================================*/
FUNCTION Get_Calendar_Table_Col_Name(
	x_periodicity_id IN NUMBER
	) RETURN VARCHAR2 IS

    h_db_column_name VARCHAR2(50);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN

    IF g_array_periodicities.exists(x_periodicity_id) THEN
        IF g_array_periodicities(x_periodicity_id).db_column_name IS NOT NULL THEN
            RETURN g_array_periodicities(x_periodicity_id).db_column_name;
        END IF;
    END IF;

    /*
    h_sql := 'SELECT db_column_name'||
             ' FROM bsc_sys_periodicities'||
             ' WHERE periodicity_id = :1';
    OPEN h_cursor FOR h_sql USING x_periodicity_id;
    FETCH h_cursor INTO h_db_column_name;
    CLOSE h_cursor;
    */
    SELECT db_column_name
    INTO h_db_column_name
    FROM bsc_sys_periodicities
    WHERE periodicity_id = x_periodicity_id;

    g_array_periodicities(x_periodicity_id).db_column_name := h_db_column_name;

    RETURN h_db_column_name;

END Get_Calendar_Table_Col_Name;


--AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Get_Dim_Level_Table_Name
+============================================================================*/
FUNCTION Get_Dim_Level_Table_Name(
	x_level_pk_col IN VARCHAR2
) RETURN VARCHAR2 IS

    h_level_table_name VARCHAR2(50);

BEGIN
    h_level_table_name := NULL;

    SELECT level_table_name
    INTO h_level_table_name
    FROM bsc_sys_dim_levels_b
    WHERE level_pk_col = x_level_pk_col;

    RETURN h_level_table_name;

END Get_Dim_Level_Table_Name;


--AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Get_Dim_Level_View_Name
+============================================================================*/
FUNCTION Get_Dim_Level_View_Name(
	x_level_pk_col IN VARCHAR2
) RETURN VARCHAR2 IS

    h_level_view_name VARCHAR2(50);

BEGIN
    h_level_view_name := NULL;

    SELECT level_view_name
    INTO h_level_view_name
    FROM bsc_sys_dim_levels_b
    WHERE level_pk_col = x_level_pk_col;

    RETURN h_level_view_name;

END Get_Dim_Level_View_Name;


/*===========================================================================+
| FUNCTION Get_EDW_Materialized_View_Name
+============================================================================*/
FUNCTION Get_EDW_Materialized_View_Name(
	x_table_name IN VARCHAR2
	) RETURN VARCHAR2 IS
BEGIN
    RETURN (x_table_name||'_MV_V');
END Get_EDW_Materialized_View_Name;


/*===========================================================================+
| FUNCTION Get_EDW_Union_View_Name
+============================================================================*/
FUNCTION Get_EDW_Union_View_Name(
	x_table_name IN VARCHAR2
	) RETURN VARCHAR2 IS
BEGIN
    RETURN (x_table_name||'_V');
END Get_EDW_Union_View_Name;


/*===========================================================================+
| FUNCTION Get_Free_Div_Zero_Expression
+============================================================================*/
FUNCTION Get_Free_Div_Zero_Expression(
	x_expression IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_expression VARCHAR2(32700);

    h_pos NUMBER;
    h_pos1 NUMBER;
    h_aux VARCHAR2(32700);
    h_field VARCHAR2(32700);
    h_fieldE VARCHAR2(26);
    h_decodeF VARCHAR2(7);
    h_group_counter NUMBER;
    h_groups BOOLEAN;

BEGIN
    h_fieldE := 'DECODE(FIELD,0,NULL,FIELD)';
    h_decodeF := 'DECODE(';

    h_expression := x_expression;
    h_pos1 := INSTR(h_expression, '/', 1);

    IF h_pos1 > 0 THEN
        LOOP
            IF h_pos1 > 0 THEN
                h_pos := h_pos1 + 1;
                h_field := NULL;
                h_group_counter := 0;
                h_groups := FALSE;

                WHILE h_pos <= LENGTH(h_expression) LOOP
                    h_aux := SUBSTR(h_expression, h_pos, 1);
                    IF h_aux IN ('+', '-', '*', '/', '(', ')', ',') THEN
                        IF h_aux = '(' THEN
                            IF h_groups = FALSE THEN
                                h_groups := TRUE;
                                h_group_counter := 0;
                            END IF;
                        END IF;

                        IF h_groups = FALSE THEN
                            EXIT;
                        ELSE
                            IF h_aux = '(' THEN
                                h_group_counter := h_group_counter + 1;
                            ELSIF h_aux = ')' THEN
                                h_group_counter := h_group_counter - 1;
                                IF h_group_counter = 0 THEN
                                    h_groups := FALSE;
                                END IF;
                            END IF;
                            h_field := h_field||h_aux;
                            h_pos := h_pos + 1;
                        END IF;
                    ELSE
                        h_field := h_field||h_aux;
                        h_pos := h_pos + 1;
                    END IF;
                END LOOP;

                IF h_field IS NOT NULL THEN
                    h_aux := REPLACE(h_FieldE, 'FIELD', h_field);
                    h_expression := SUBSTR(h_expression, 1, h_pos1)||h_aux||SUBSTR(h_expression, h_pos);
                END IF;
                h_pos := h_pos1 + LENGTH(h_decodeF);
            ELSE
                EXIT;
            END IF;
            h_pos1 := INSTR(h_expression, '/', h_pos);
        END LOOP;
    END IF;

    RETURN h_expression;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Free_Div_Zero_Expression;


/*===========================================================================+
| FUNCTION Get_Indic_Range_Of_Years
+============================================================================*/
FUNCTION Get_Indic_Range_Of_Years(
	x_indicator IN NUMBER,
        x_periodicity IN NUMBER,
        x_num_of_years OUT NOCOPY NUMBER,
	x_previous_years OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_indic t_cursor; -- x_indicator, x_periodicity
    c_indic_sql VARCHAR2(2000) := 'SELECT num_of_years, previous_years'||
                                  ' FROM bsc_kpi_periodicities'||
                                  ' WHERE indicator = :1 AND periodicity_id = :2';
    */

BEGIN
    /*
    OPEN c_indic FOR c_indic_sql USING x_indicator, x_periodicity;
    FETCH c_indic INTO x_num_of_years, x_previous_years;
    IF c_indic%NOTFOUND THEN
        x_num_of_years := 2;
        x_previous_years := 1;
    ELSE
        IF NVL(x_num_of_years, 0) = 0 THEN
            x_num_of_years := 2;
        END IF;

        IF NVL(x_previous_years, 0) = 0 THEN
            x_previous_years := 1;
        END IF;
    END IF;
    CLOSE c_indic;
    */
    BEGIN
        SELECT num_of_years, previous_years
        INTO x_num_of_years, x_previous_years
        FROM bsc_kpi_periodicities
        WHERE indicator = x_indicator AND periodicity_id = x_periodicity;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_num_of_years := 2;
            x_previous_years := 1;
    END;
    IF NVL(x_num_of_years, 0) = 0 THEN
        x_num_of_years := 2;
    END IF;

    IF NVL(x_previous_years, 0) = 0 THEN
        x_previous_years := 1;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Indic_Range_Of_Years');
        RETURN FALSE;

END Get_Indic_Range_Of_Years;


/*===========================================================================+
| FUNCTION Get_Information_Data_Columns
+============================================================================*/
FUNCTION Get_Information_Data_Columns(
	x_table IN VARCHAR2,
	x_data_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_formulas IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_data_proj_methods IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
        x_data_measure_types IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number,
	x_num_data_columns IN OUT NOCOPY NUMBER) RETURN BOOLEAN IS

    -- BSC-BIS-DIMENSIONS Note: From thsi implemetation we can run loader when
    -- there are indicators in prototype. This open a case where a measure is
    -- configured in BSC_DB_TABLES_COLS but it does not exists in BSC_DB_MEASURES_COLS_VL
    -- because the user could delete the measure. I am changing the query to return
    -- default values in case the measure does not exists in BSC_DB_MEASURES_COLS_VL

    -- SUPPORT_BSC_BIS_MEASURES: Only BSC measures exists in bsc_db_measure_cols_vl.
    -- For BIS measures by design we assumed that projection method is 0 (no projection)
    -- and measure type is 1 (Total)
    CURSOR c_data_columns (p_table_name VARCHAR2, p_column_type VARCHAR2) IS
        SELECT c.column_name, c.source_formula,
               DECODE(NVL(c.source,'BSC'),'BSC',NVL(m.projection_id, 0),0),
               DECODE(NVL(c.source,'BSC'),'BSC',NVL(m.measure_type, 1),1)
        FROM bsc_db_tables_cols c, bsc_db_measure_cols_vl m
        WHERE c.column_name = m.measure_col (+) AND
              c.table_name = p_table_name AND c.column_type = p_column_type;

    h_column_type_a 	VARCHAR2(1);

    h_column_name 	bsc_db_tables_cols.column_name%TYPE;
    h_source_formula 	bsc_db_tables_cols.source_formula%TYPE;
    h_projection_id 	bsc_db_tables_cols.projection_id%TYPE;
    h_measure_type	bsc_db_measure_cols_vl.measure_type%TYPE;

BEGIN
    h_column_type_a := 'A';

    --OPEN c_data_columns FOR c_data_columns_sql USING x_table, h_column_type_a;
    OPEN c_data_columns(x_table, h_column_type_a);
    FETCH c_data_columns INTO h_column_name, h_source_formula, h_projection_id, h_measure_type;
    WHILE c_data_columns%FOUND LOOP
        x_num_data_columns := x_num_data_columns + 1;
        x_data_columns(x_num_data_columns) := h_column_name;
        x_data_formulas(x_num_data_columns) := h_source_formula;

        IF h_measure_type IS NULL THEN
            h_measure_type := 1; -- Total
        END IF;

        x_data_measure_types(x_num_data_columns) := h_measure_type;

        IF h_projection_id IS NULL THEN
            h_projection_id := 0;
        END IF;

        x_data_proj_methods(x_num_data_columns) := h_projection_id;

        FETCH c_data_columns INTO h_column_name, h_source_formula, h_projection_id, h_measure_type;
    END LOOP;
    CLOSE c_data_columns;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Information_Data_Columns');
        RETURN FALSE;

END Get_Information_Data_Columns;


/*===========================================================================+
| FUNCTION Get_Information_Key_Columns
+============================================================================*/
FUNCTION Get_Information_Key_Columns(
	x_table IN VARCHAR2,
	x_key_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_key_dim_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_source_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_source_dim_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_key_columns IN OUT NOCOPY NUMBER) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_key_columns t_cursor; -- x_table, h_column_type_p
    c_key_columns_sql VARCHAR2(2000) := 'SELECT t.column_name, d.level_view_name, t.source_column, d1.level_view_name'||
                                        ' FROM bsc_db_tables_cols t, bsc_sys_dim_levels_b d, bsc_sys_dim_levels_b d1'||
                                        ' WHERE t.table_name = :1 AND t.column_type = :2 AND'||
                                        ' t.column_name = d.level_pk_col AND'||
                                        ' t.source_column = d1.level_pk_col';
    */
    CURSOR c_key_columns (p_table_name VARCHAR2, p_column_type VARCHAR2) IS
        SELECT t.column_name, d.level_view_name, t.source_column, d1.level_view_name
        FROM bsc_db_tables_cols t, bsc_sys_dim_levels_b d, bsc_sys_dim_levels_b d1
        WHERE t.table_name = p_table_name AND t.column_type = p_column_type AND
              t.column_name = d.level_pk_col AND
              t.source_column = d1.level_pk_col
        ORDER BY d.dim_level_id;

    h_column_type_p	VARCHAR2(1);

    h_key_column	bsc_db_tables_cols.column_name%TYPE;
    h_key_dim_table 	bsc_sys_dim_levels_b.level_view_name%TYPE;
    h_source_column 	bsc_db_tables_cols.source_column%TYPE;
    h_source_dim_table 	bsc_sys_dim_levels_b.level_view_name%TYPE;

BEGIN
    h_column_type_p := 'P';

    --OPEN c_key_columns FOR c_key_columns_sql USING x_table, h_column_type_p;
    OPEN c_key_columns(x_table, h_column_type_p);
    FETCH c_key_columns INTO h_key_column, h_key_dim_table, h_source_column, h_source_dim_table;

    WHILE c_key_columns%FOUND LOOP
        x_num_key_columns := x_num_key_columns + 1;

        x_key_columns(x_num_key_columns) := h_key_column;
        x_key_dim_tables(x_num_key_columns) := h_key_dim_table;
        x_source_columns(x_num_key_columns) := h_source_column;
        x_source_dim_tables(x_num_key_columns) := h_source_dim_table;

        FETCH c_key_columns INTO h_key_column, h_key_dim_table, h_source_column, h_source_dim_table;

    END LOOP;
    CLOSE c_key_columns;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Information_Key_Columns');
        RETURN FALSE;

END Get_Information_Key_Columns;


/*===========================================================================+
| FUNCTION Get_Init_Variable_Value
+============================================================================*/
FUNCTION Get_Init_Variable_Value(
	x_variable_name IN VARCHAR2,
        x_variable_value OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_init t_cursor; -- x_variable_name
    c_init_sql VARCHAR2(2000) := 'SELECT property_value'||
                                 ' FROM bsc_sys_init'||
                                 ' WHERE property_code = :1';
    */

    h_message VARCHAR2(4000);

BEGIN
    /*
    OPEN c_init FOR c_init_sql USING x_variable_name;
    FETCH c_init INTO x_variable_value;
    IF c_init%NOTFOUND THEN
        h_message := BSC_UPDATE_UTIL.Get_Message('BSC_VAR_NOT_FOUND');
        h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'VARIABLE', x_variable_name);
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_WARNING')||' '||h_message,
                        x_source => 'BSC_UPDATE_UTIL.Get_Init_Variable_Value');
        x_variable_value := NULL;
    END IF;
    CLOSE c_init;
    */
    BEGIN
        SELECT property_value
        INTO x_variable_value
        FROM bsc_sys_init
        WHERE property_code = x_variable_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_VAR_NOT_FOUND');
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'VARIABLE', x_variable_name);
            BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_WARNING')||' '||h_message,
                            x_source => 'BSC_UPDATE_UTIL.Get_Init_Variable_Value');
            x_variable_value := NULL;
    END;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Init_Variable_Value');
        RETURN FALSE;

END Get_Init_Variable_Value;


/*===========================================================================+
| FUNCTION Get_Input_Table_Source
+============================================================================*/
FUNCTION Get_Input_Table_Source(
	x_input_table IN VARCHAR2,
	x_source_type OUT NOCOPY NUMBER,
	x_source_name OUT NOCOPY VARCHAR2
      ) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    /* h_sql := 'SELECT source_data_type, source_file_name'||
             ' FROM bsc_db_tables'||
             ' WHERE table_name = :1';
    OPEN h_cursor FOR h_sql USING x_input_table;
    FETCH h_cursor INTO x_source_type, x_source_name;
    CLOSE h_cursor; */
    SELECT source_data_type, TRIM(source_file_name)
    INTO x_source_type, x_source_name
    FROM bsc_db_tables
    WHERE table_name = x_input_table ;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Input_Table_Source');
        RETURN FALSE;
END Get_Input_Table_Source;


/*===========================================================================+
| FUNCTION Get_Installed_Languages
+============================================================================*/
FUNCTION Get_Installed_Languages(
	x_languages IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_languages t_cursor; -- h_inst_lang, h_base_lang
    c_languages_sql VARCHAR2(2000) := 'SELECT DISTINCT LANGUAGE_CODE'||
                                      ' FROM FND_LANGUAGES'||
                                      ' WHERE INSTALLED_FLAG IN (:1, :2)';
    */
    CURSOR c_languages (p_param1 VARCHAR2, p_param2 VARCHAR2) IS
        SELECT DISTINCT LANGUAGE_CODE
        FROM FND_LANGUAGES
        WHERE INSTALLED_FLAG IN (p_param1, p_param2);

    h_inst_lang VARCHAR2(1);
    h_base_lang VARCHAR2(1);

    h_num_languages NUMBER;
    h_language VARCHAR2(10);

BEGIN
    h_inst_lang := 'I';
    h_base_lang := 'B';
    h_num_languages := 0;

    --OPEN c_languages FOR c_languages_sql USING h_inst_lang, h_base_lang;
    OPEN c_languages(h_inst_lang, h_base_lang);
    FETCH c_languages INTO h_language;
    WHILE c_languages%FOUND LOOP
        h_num_languages := h_num_languages + 1;
        x_languages(h_num_languages) := h_language;

        FETCH c_languages INTO h_language;
    END LOOP;
    CLOSE c_languages;

    RETURN h_num_languages;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Installed_Languages');
        RETURN -1;

END Get_Installed_Languages;


/*===========================================================================+
| FUNCTION Get_Lookup_Value
+============================================================================*/
FUNCTION Get_Lookup_Value(
	x_lookup_type IN VARCHAR2,
        x_lookup_code IN VARCHAR2
	) RETURN VARCHAR2 IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_lookup_value t_cursor; -- x_lookup_type, x_lookup_code
    c_lookup_value_sql VARCHAR2(2000) := 'SELECT meaning'||
                                         ' FROM bsc_lookups'||
                                         ' WHERE lookup_type = :1 AND lookup_code = :2';
    */

    h_lookup_value VARCHAR2(4000);

    h_message VARCHAR2(4000);

BEGIN
    /*
    OPEN c_lookup_value FOR c_lookup_value_sql USING x_lookup_type, x_lookup_code;
    FETCH c_lookup_value INTO h_lookup_value;
    IF c_lookup_value%NOTFOUND THEN
        h_message := BSC_UPDATE_UTIL.Get_Message('BSC_MISSING_LOOKUP_VALUES');
        h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'LOOKUP_TYPE', x_lookup_type);
        h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'LOOKUP_CODE', x_lookup_code);
        BSC_MESSAGE.Add(x_message => h_message,
                        x_source => 'BSC_UPDATE_UTIL.Get_Lookup_Value');
        h_lookup_value := NULL;
    END IF;
    CLOSE c_lookup_value;
    */
    BEGIN
        SELECT meaning
        INTO h_lookup_value
        FROM bsc_lookups
        WHERE lookup_type = x_lookup_type AND lookup_code = x_lookup_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_message := BSC_UPDATE_UTIL.Get_Message('BSC_MISSING_LOOKUP_VALUES');
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'LOOKUP_TYPE', x_lookup_type);
            h_message := BSC_UPDATE_UTIL.Replace_Token(h_message, 'LOOKUP_CODE', x_lookup_code);
            BSC_MESSAGE.Add(x_message => h_message,
                            x_source => 'BSC_UPDATE_UTIL.Get_Lookup_Value');
            h_lookup_value := NULL;
    END;

    RETURN h_lookup_value;

END Get_Lookup_Value;


/*===========================================================================+
| FUNCTION Get_Message
+============================================================================*/
FUNCTION Get_Message(
	x_message_name IN VARCHAR2
	) RETURN VARCHAR2 IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_message t_cursor; -- x_message_name
    c_message_sql VARCHAR2(2000) := 'SELECT message_text'||
                                    ' FROM bsc_messages'||
                                    ' WHERE message_name = :1';
    */

    h_message VARCHAR2(4000);

BEGIN
    /*
    OPEN c_message FOR c_message_sql USING x_message_name;
    FETCH c_message INTO h_message;
    IF c_message%NOTFOUND THEN
        h_message := NULL;
    END IF;
    CLOSE c_message;
    */
    BEGIN
        SELECT message_text
        INTO h_message
        FROM bsc_messages
        WHERE message_name = x_message_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_message := NULL;
    END;

    RETURN h_message;

END Get_Message;


/*===========================================================================+
| FUNCTION Get_Num_Periods_Periodicity
+============================================================================*/
FUNCTION Get_Num_Periods_Periodicity(
	x_periodicity IN NUMBER,
	x_current_fy IN NUMBER
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(2000);

    h_calendar_col_name VARCHAR2(30);
    h_num_periods NUMBER;

    h_edw_flag NUMBER;
    h_calendar_id NUMBER;

BEGIN
    h_edw_flag := 0;

    h_edw_flag := Get_Periodicity_EDW_Flag(x_periodicity);
    h_calendar_id := Get_Calendar_Id(x_periodicity);

    IF h_edw_flag = 0 THEN
        -- BSC periodicity
        h_calendar_col_name := Get_Calendar_Table_Col_Name(x_periodicity);

        h_sql := 'SELECT MAX('||h_calendar_col_name||')'||
                 ' FROM bsc_db_calendar'||
                 ' WHERE year = :1 AND calendar_id = :2';

        OPEN h_cursor FOR h_sql USING x_current_fy, h_calendar_id;
        FETCH h_cursor INTO h_num_periods;
        IF h_cursor%NOTFOUND THEN
            h_num_periods := NULL;
        END IF;
        CLOSE h_cursor;

    ELSE
        -- EDW periodicity
        h_num_periods := BSC_INTEGRATION_APIS.Get_Number_Of_Periods(x_current_fy, x_periodicity, h_calendar_id);
        IF BSC_APPS.CheckError('BSC_INTEGRATION_APIS.Get_Number_Of_Periods') THEN
            -- Error
            RETURN NULL;
        END IF;

    END IF;

    RETURN h_num_periods;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Num_Periods_Periodicity');
        RETURN NULL;

END Get_Num_Periods_Periodicity;


/*===========================================================================+
| FUNCTION Get_Period_Cols_Names
+============================================================================*/
FUNCTION Get_Period_Cols_Names(
	x_periodicity_cod IN NUMBER,
        x_period_col_name OUT NOCOPY VARCHAR2,
        x_subperiod_col_name OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_period_names t_cursor; -- x_periodicity_cod
    c_period_names_sql VARCHAR2(2000) := 'SELECT NVL(period_col_name, ''PERIOD''), subperiod_col_name'||
                                         ' FROM bsc_sys_periodicities'||
                                         ' WHERE periodicity_id = :1';
    */
BEGIN
    IF g_array_periodicities.exists(x_periodicity_cod) THEN
        IF g_array_periodicities(x_periodicity_cod).period_col_name IS NOT NULL THEN
            x_period_col_name := g_array_periodicities(x_periodicity_cod).period_col_name;
            x_subperiod_col_name := g_array_periodicities(x_periodicity_cod).sub_period_col_name;
            RETURN TRUE;
        END IF;
    END IF;

    /*
    OPEN c_period_names FOR c_period_names_sql USING x_periodicity_cod;
    FETCH c_period_names INTO x_period_col_name, x_subperiod_col_name;
    IF c_period_names%NOTFOUND THEN
        x_period_col_name := NULL;
        x_subperiod_col_name := NULL;
    END IF;
    CLOSE c_period_names;
    */
    BEGIN
        SELECT NVL(period_col_name, 'PERIOD'), subperiod_col_name
        INTO x_period_col_name, x_subperiod_col_name
        FROM bsc_sys_periodicities
        WHERE periodicity_id = x_periodicity_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_period_col_name := NULL;
            x_subperiod_col_name := NULL;
    END;

    g_array_periodicities(x_periodicity_cod).period_col_name := x_period_col_name;
    g_array_periodicities(x_periodicity_cod).sub_period_col_name := x_subperiod_col_name;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Period_Cols_Names');
        RETURN FALSE;

END Get_Period_Cols_Names;


/*===========================================================================+
| FUNCTION Get_Period_Other_Periodicity
+============================================================================*/
FUNCTION Get_Period_Other_Periodicity(
	p_periodicity_id IN NUMBER,
        p_calendar_id IN NUMBER,
        p_yearly_flag IN NUMBER,
        p_current_fy IN NUMBER,
        p_source_periodicity_id IN NUMBER,
        p_source_period IN NUMBER
        ) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_period NUMBER;
    h_source_col_name VARCHAR2(30);
    h_col_name VARCHAR2(30);

    h_sql VARCHAR2(32000);

BEGIN
    h_period := 0;

    IF p_yearly_flag = 1 THEN
        h_period := p_current_fy;
    ELSE
        h_source_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(p_source_periodicity_id);
        h_col_name := BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(p_periodicity_id);

        h_sql := 'SELECT DISTINCT '||h_col_name||
                 ' FROM bsc_db_calendar'||
                 ' WHERE calendar_id = :1 AND year = :2'||
                 ' AND '||h_source_col_name||' = :3';
        OPEN h_cursor FOR h_sql USING p_calendar_id, p_current_fy, p_source_period;
        FETCH h_cursor INTO h_period;
        CLOSE h_cursor;
    END IF;

    RETURN h_period;

END Get_Period_Other_Periodicity;


/*===========================================================================+
| FUNCTION Get_Periodicity_EDW_Flag
+============================================================================*/
FUNCTION Get_Periodicity_EDW_Flag(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER IS

    h_edw_flag NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(2000);

BEGIN

    IF g_array_periodicities.exists(x_periodicity_id) THEN
        IF g_array_periodicities(x_periodicity_id).edw_flag IS NOT NULL THEN
            RETURN g_array_periodicities(x_periodicity_id).edw_flag;
        END IF;
    END IF;

    /*
    h_sql := 'SELECT edw_flag'||
             ' FROM bsc_sys_periodicities'||
             ' WHERE periodicity_id = :1';
    OPEN h_cursor FOR h_sql USING x_periodicity_id;
    FETCH h_cursor INTO h_edw_flag;
    CLOSE h_cursor;
    */
    SELECT edw_flag
    INTO h_edw_flag
    FROM bsc_sys_periodicities
    WHERE periodicity_id = x_periodicity_id;

    g_array_periodicities(x_periodicity_id).edw_flag := h_edw_flag;

    RETURN h_edw_flag;

END Get_Periodicity_EDW_Flag;


/*===========================================================================+
| FUNCTION Get_Periodicity_Type
+============================================================================*/
FUNCTION Get_Periodicity_Type(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER IS

    h_periodicity_type NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(2000);

BEGIN

    IF g_array_periodicities.exists(x_periodicity_id) THEN
        IF g_array_periodicities(x_periodicity_id).periodicity_type IS NOT NULL THEN
            RETURN g_array_periodicities(x_periodicity_id).periodicity_type;
        END IF;
    END IF;

    /*
    h_sql := 'SELECT periodicity_type'||
             ' FROM bsc_sys_periodicities'||
             ' WHERE periodicity_id = :1';
    OPEN h_cursor FOR h_sql USING x_periodicity_id;
    FETCH h_cursor INTO h_periodicity_type;
    CLOSE h_cursor;
    */
    SELECT periodicity_type
    INTO h_periodicity_type
    FROM bsc_sys_periodicities
    WHERE periodicity_id = x_periodicity_id;

    g_array_periodicities(x_periodicity_id).periodicity_type := h_periodicity_type;

    RETURN h_periodicity_type;

END Get_Periodicity_Type;


/*===========================================================================+
| FUNCTION Get_Periodicity_Yearly_Flag
+============================================================================*/
FUNCTION Get_Periodicity_Yearly_Flag(
	x_periodicity_id IN NUMBER
	) RETURN NUMBER IS

    h_yearly_flag NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(2000);

BEGIN

    IF g_array_periodicities.exists(x_periodicity_id) THEN
        IF g_array_periodicities(x_periodicity_id).yearly_flag IS NOT NULL THEN
            RETURN g_array_periodicities(x_periodicity_id).yearly_flag;
        END IF;
    END IF;

    /*
    h_sql := 'SELECT yearly_flag'||
             ' FROM bsc_sys_periodicities'||
             ' WHERE periodicity_id = :1';
    OPEN h_cursor FOR h_sql USING x_periodicity_id;
    FETCH h_cursor INTO h_yearly_flag;
    CLOSE h_cursor;
    */
    SELECT yearly_flag
    INTO h_yearly_flag
    FROM bsc_sys_periodicities
    WHERE periodicity_id = x_periodicity_id;

    g_array_periodicities(x_periodicity_id).yearly_flag := h_yearly_flag;

    RETURN h_yearly_flag;

END Get_Periodicity_Yearly_Flag;


/*===========================================================================+
| FUNCTION Get_Source_Periodicities
+============================================================================*/
FUNCTION Get_Source_Periodicities(
    x_periodicity_id IN NUMBER,
    x_source_periodicities IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
    ) RETURN NUMBER IS

    h_num_source_periodicities NUMBER;
    h_i NUMBER;

BEGIN
    h_num_source_periodicities := 0;

    FOR h_i IN 1..g_array_periodicity_rels.COUNT LOOP
        IF g_array_periodicity_rels(h_i).periodicity_id = x_periodicity_id THEN
            h_num_source_periodicities := h_num_source_periodicities + 1;
            x_source_periodicities(h_num_source_periodicities) := g_array_periodicity_rels(h_i).source_periodicity_id;
        END IF;
    END LOOP;

    RETURN h_num_source_periodicities;

END Get_Source_Periodicities;


/*===========================================================================+
| FUNCTION Get_Table_EDW_Flag
+============================================================================*/
FUNCTION Get_Table_EDW_Flag(
	x_table_name IN VARCHAR2
	) RETURN NUMBER IS

    h_edw_flag NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(2000);

BEGIN
    h_edw_flag := 0;

    /* h_sql := 'SELECT NVL(edw_flag, 0)'||
             ' FROM bsc_db_tables'||
             ' WHERE table_name = :1';
    OPEN h_cursor FOR h_sql USING x_table_name;
    FETCH h_cursor INTO h_edw_flag;
    CLOSE h_cursor; */
    begin
      SELECT NVL(edw_flag, 0)
      INTO h_edw_flag
      FROM bsc_db_tables
      WHERE table_name = x_table_name;
    exception
      when no_data_found then h_edw_flag := null;
    end;

    RETURN h_edw_flag;

END Get_Table_EDW_Flag;


/*===========================================================================+
| FUNCTION Get_Table_Generation_Type
+============================================================================*/
FUNCTION Get_Table_Generation_Type(
	x_table_name IN VARCHAR2
	) RETURN NUMBER IS

    h_table_generation_type bsc_db_tables.generation_type%TYPE;

BEGIN
    h_table_generation_type := NULL;

    SELECT generation_type
    INTO h_table_generation_type
    FROM bsc_db_tables
    WHERE table_name = x_table_name;

    RETURN h_table_generation_type;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Table_Generation_Type');
        RETURN NULL;

END Get_Table_Generation_Type;


/*===========================================================================+
| FUNCTION Get_Table_Type
+============================================================================*/
FUNCTION Get_Table_Type(
	x_table_name IN VARCHAR2
	) RETURN NUMBER IS

    h_table_type bsc_db_tables.table_type%TYPE;

BEGIN
    h_table_type := NULL;

    SELECT table_type
    INTO h_table_type
    FROM bsc_db_tables
    WHERE table_name = x_table_name;

    RETURN h_table_type;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Table_Type');
        RETURN NULL;

END Get_Table_Type;


/*===========================================================================+
| FUNCTION Get_Table_Periodicity
+============================================================================*/
FUNCTION Get_Table_Periodicity(
	x_table_name IN VARCHAR2
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_table_periodicity t_cursor; -- x_table_name
    c_table_periodicity_sql VARCHAR2(2000) := 'SELECT periodicity_id'||
                                              ' FROM bsc_db_tables'||
                                              ' WHERE table_name = :1';
    */

    h_table_periodicity bsc_db_tables.periodicity_id%TYPE;

BEGIN
    h_table_periodicity := NULL;

    /*
    OPEN c_table_periodicity FOR c_table_periodicity_sql USING x_table_name;
    FETCH c_table_periodicity INTO h_table_periodicity;
    IF c_table_periodicity%NOTFOUND THEN
        h_table_periodicity := NULL;
    END IF;
    CLOSE c_table_periodicity;
    */
    BEGIN
       SELECT periodicity_id
       INTO h_table_periodicity
       FROM bsc_db_tables
       WHERE table_name = x_table_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            h_table_periodicity := NULL;
    END;

    RETURN h_table_periodicity;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Table_Periodicity');
        RETURN NULL;

END Get_Table_Periodicity;


/*===========================================================================+
| FUNCTION Get_Table_Range_Of_Years
+============================================================================*/
FUNCTION Get_Table_Range_Of_Years(
	x_table_name IN VARCHAR2,
        x_num_of_years OUT NOCOPY NUMBER,
	x_previous_years OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

BEGIN
    BEGIN
       SELECT num_of_years, previous_years
       INTO x_num_of_years, x_previous_years
       FROM bsc_db_tables
       WHERE table_name = x_table_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_num_of_years := 2;
            x_previous_years := 1;
    END;

    IF x_num_of_years IS NULL THEN
        x_num_of_years := 2;
    END IF;

    IF x_previous_years IS NULL THEN
        x_previous_years := 1;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Get_Table_Range_Of_Years');
        RETURN FALSE;

END Get_Table_Range_Of_Years;


/*===========================================================================+
| FUNCTION Get_Kpis_Using_Table
+============================================================================*/
FUNCTION Get_Kpis_Using_Table(
    x_table_name IN VARCHAR2,
    x_kpis IN OUT NOCOPY t_array_kpis
) RETURN NUMBER IS

    CURSOR c_kpis IS
        SELECT DISTINCT k.indicator, k.prototype_flag
        FROM bsc_kpi_data_tables t, bsc_db_tables_rels r, bsc_kpis_b k
        WHERE t.table_name = r.table_name AND
              t.indicator = k.indicator AND
              (t.table_name = x_table_name OR
              (r.source_table_name = x_table_name AND r.relation_type = 1));

    h_num_kpis NUMBER;
    h_kpi NUMBER;
    h_prototype_flag NUMBER;

BEGIN
    h_num_kpis := 0;

    OPEN c_kpis;
    LOOP
        FETCH c_kpis INTO h_kpi, h_prototype_flag;
        EXIT WHEN c_kpis%NOTFOUND;
        h_num_kpis := h_num_kpis + 1;
        x_kpis(h_num_kpis).indicator := h_kpi;
        x_kpis(h_num_kpis).prototype_flag := h_prototype_flag;
    END LOOP;
    --Fix bug#3899842: Close cursor;
    CLOSE c_kpis;
    RETURN h_num_kpis;

END Get_Kpis_Using_Table;


/*===========================================================================+
| FUNCTION Is_Kpi_In_Production
+============================================================================*/
FUNCTION Is_Kpi_In_Production(
    x_kpi IN NUMBER
) RETURN BOOLEAN IS

    h_num_rows NUMBER;

BEGIN
    SELECT COUNT(indicator)
    INTO h_num_rows
    FROM bsc_kpis_b
    WHERE indicator = x_kpi
    AND prototype_flag IN (0,6,7);

    IF h_num_rows > 0 THEN
         RETURN TRUE;
    ELSE
         RETURN FALSE;
    END IF;

END Is_Kpi_In_Production;


/*FUNCTION Is_Kpi_Measure_In_Production (
  p_objective_id   IN NUMBER
, p_kpi_measure_id IN NUMBER
)
RETURN BOOLEAN IS

    h_num_rows NUMBER;

BEGIN
    SELECT COUNT(indicator)
    INTO h_num_rows
    FROM bsc_kpi_analysis_measures_b
    WHERE kpi_measure_id = p_kpi_measure_id
    AND prototype_flag = 7;

    IF h_num_rows > 0 THEN
         RETURN TRUE;
    ELSE
         RETURN FALSE;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END Is_Kpi_Measure_In_Production;*/


/*===========================================================================+
| FUNCTION Get_Table_Target_Flag
+============================================================================*/
FUNCTION Get_Table_Target_Flag(
	x_table_name IN VARCHAR2
	) RETURN NUMBER IS

    h_target_flag NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    h_target_flag := 0;

    /*
    h_sql := 'SELECT NVL(target_flag, 0)'||
             ' FROM bsc_db_tables'||
             ' WHERE table_name = :1';
    OPEN h_cursor FOR h_sql USING x_table_name;
    FETCH h_cursor INTO h_target_flag;
    CLOSE h_cursor;
    */
    SELECT NVL(target_flag, 0)
    INTO h_target_flag
    FROM bsc_db_tables
    WHERE table_name = x_table_name;

    RETURN h_target_flag;

END Get_Table_Target_Flag;


/*===========================================================================+
| FUNCTION Init_Calendar_Tables
+============================================================================*/
FUNCTION Init_Calendar_Tables (
    x_calendar_id IN NUMBER,
    x_action IN NUMBER
    ) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_current_fy NUMBER;
    h_start_year NUMBER;
    h_start_month NUMBER;
    h_start_day NUMBER;
    h_min_year NUMBER;

    TYPE t_cursor IS REF CURSOR;

    --Fix bug#4063282, add source periodicity to this cursor
    CURSOR c_custom_pers (p_calendar_id NUMBER) IS
        SELECT periodicity_id, custom_code, DECODE(INSTR(source, ','), 0, source, SUBSTR(source, 1, INSTR(source, ',') - 1))
        FROM bsc_sys_periodicities
        WHERE calendar_id = p_calendar_id;

    h_periodicity_id NUMBER;
    h_custom_code NUMBER;
    h_source_periodicity NUMBER;

    h_calculated_pers BSC_UPDATE_UTIL.t_array_of_number;
    h_num_calculated_pers NUMBER;

    TYPE t_custom_per IS RECORD (
        periodicity_id NUMBER,
        custom_code NUMBER,
        source_periodicity NUMBER
    );

    TYPE t_custom_pers IS TABLE OF t_custom_per
        INDEX BY BINARY_INTEGER;

    h_custom_pers t_custom_pers;
    h_num_custom_pers NUMBER;
    h_num_periodicities NUMBER;

    h_i NUMBER;

    h_count NUMBER;

BEGIN
    -- x_action = 1 || x_action = NULL
    -- Drop Indexes from calendar tables: BSC_DB_CALENDAR, BSC_DB_WEEK_MAPS,
    -- BSC_SYS_PERIODS_TL to improve performance
    -- Note: Indexes on BSC_DB_CALENDAR and BSC_DB_WEEK_MAPS tables were removed.

    --LOCKING: We are not going to drop indexes anymore. If we remove indexes
    -- we cannot load different calendars at the same time
    --IF NVL(x_action, 1) = 1 THEN
    --    IF NOT Drop_Index('BSC_SYS_PERIODS_TL_U1') THEN
    --        RAISE e_unexpected_error;
    --    END IF;
    --END IF;


    -- Fix bug#4536286: validate source and db_column_name in bsc_sys_periodicities
    -- cannot be null for custom periodicities
    select count(periodicity_id)
    into h_count
    from bsc_sys_periodicities
    where calendar_id = x_calendar_id and nvl(custom_code, -1) <> 0 and
            (source is null or db_column_name is null);
    IF h_count > 0 THEN
        RAISE e_unexpected_error;
    END IF;

    -- x_action = 2 ||x_action = NULL
    -- Populate calendar tables
    IF NVL(x_action, 2) = 2 THEN
        -- Get the current fiscal year
        h_current_fy := Get_Calendar_Fiscal_Year(x_calendar_id);

        -- Get the start date of fiscal year
        IF NOT Get_Calendar_Start_Date(x_calendar_id,
                                       h_current_fy,
                                       h_start_year,
                                       h_start_month,
                                       h_start_day) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Populate BSC_DB_CALENDAR
        -- It insert row for predefined periodicities
        IF NOT Populate_Bsc_Db_Calendar(x_calendar_id,
                                        h_current_fy,
                                        h_start_year,
                                        h_start_month,
                                        h_start_day) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Verify custom periodicities
        -- It check that there are records for all fiscal years
        -- in BSC_SYS_PERIODS. In case a fiscal year dont have
        -- records, it generate them automatically taking the
        -- parameters of the current fiscal year.
        -- If there are no records in BSC_SYS_PERIODS for current
        -- fiscal year (i.e in year change process)
        -- then it look for the latest year which have records in
        -- BSC_SYS_PERIODS.
        -- After that it updates the corresponding column
        -- in BSC_DB_CALENDAR table

        -- Fix bug#4063282: Need to process custom periodicities in order.
        -- First the source, then the target periodicity

        h_num_calculated_pers := 0;
        h_num_custom_pers := 0;
        h_num_periodicities := 0;

        OPEN c_custom_pers(x_calendar_id);
        FETCH c_custom_pers INTO h_periodicity_id, h_custom_code, h_source_periodicity;
        WHILE c_custom_pers%FOUND LOOP
            IF h_custom_code = 0 THEN
                -- This is a pre-defined periodicity
                h_num_calculated_pers := h_num_calculated_pers + 1;
                h_calculated_pers(h_num_calculated_pers) := h_periodicity_id;
            ELSE
                -- This is a custom periodicity
                h_num_custom_pers := h_num_custom_pers + 1;
                h_custom_pers(h_num_custom_pers).periodicity_id := h_periodicity_id;
                h_custom_pers(h_num_custom_pers).custom_code := h_custom_code;
                h_custom_pers(h_num_custom_pers).source_periodicity := h_source_periodicity;
            END IF;
            h_num_periodicities := h_num_periodicities + 1;
            FETCH c_custom_pers INTO h_periodicity_id, h_custom_code, h_source_periodicity;
        END LOOP;
        CLOSE c_custom_pers;

        WHILE h_num_calculated_pers <> h_num_periodicities LOOP
            FOR h_i IN 1..h_num_custom_pers LOOP
                IF NOT Item_Belong_To_Array_Number(h_custom_pers(h_i).periodicity_id,
                                                   h_calculated_pers,
                                                   h_num_calculated_pers) THEN
                    -- This custom periodicity has not been processed yet
                    IF Item_Belong_To_Array_Number(h_custom_pers(h_i).source_periodicity,
                                                   h_calculated_pers,
                                                   h_num_calculated_pers) THEN
                       -- Source periodicity already was processed, so we can process this periodicity now
                       IF NOT Verify_Custom_Periodicity(x_calendar_id,
                                                        h_custom_pers(h_i).periodicity_id,
                                                        h_custom_pers(h_i).custom_code) THEN
                            RAISE e_unexpected_error;
                        END IF;

                        h_num_calculated_pers := h_num_calculated_pers + 1;
                        h_calculated_pers(h_num_calculated_pers) := h_custom_pers(h_i).periodicity_id;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;

        -- Populate BSC_DB_WEEK_MAPS
        IF NOT Populate_Bsc_Db_Week_Maps(x_calendar_id) THEN
            RAISE e_unexpected_error;
        END IF;

        -- Populate BSC_SYS_PERIODS_TL
        IF NOT Populate_Bsc_Sys_Periods_Tl(x_calendar_id) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    -- x_action = 3 || x_action = NULL
    -- Enable indexes
    --LOCKING: We are not going to drop indexes anymore. If we remove indexes
    -- we cannot load different calendars at the same time
    --IF NVL(x_action, 3) = 3 THEN
    --    IF NOT Create_Unique_Index('BSC_SYS_PERIODS_TL',
    --                               'BSC_SYS_PERIODS_TL_U1',
    --                               'YEAR, PERIODICITY_ID, PERIOD_ID, MONTH, LANGUAGE',
    --                               BSC_APPS.other_index_tbs_type) THEN
    --        RAISE e_unexpected_error;
    --    END IF;
    --     COMMIT;
    --END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_CALTABLES_INIT_FAILED'),
                        x_source => 'BSC_UPDATE_UTIL.Init_Calendar_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Init_Calendar_Tables');
        RETURN FALSE;

END Init_Calendar_Tables;


/*===========================================================================+
| FUNCTION Init_Calendar_Tables
+============================================================================*/
FUNCTION Init_Calendar_Tables (
    x_calendar_id IN NUMBER
    ) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

BEGIN
    IF NOT Init_Calendar_Tables(x_calendar_id, NULL) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_CALTABLES_INIT_FAILED'),
                        x_source => 'BSC_UPDATE_UTIL.Init_Calendar_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Init_Calendar_Tables');
        RETURN FALSE;

END Init_Calendar_Tables;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Init_Calendar_Tables_AT
+============================================================================*/
FUNCTION Init_Calendar_Tables_AT(
    x_calendar_id IN NUMBER
    ) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Init_Calendar_Tables(x_calendar_id);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Init_Calendar_Tables_AT;


-- ENH_B_TABLES_PERF: new function
/*===========================================================================+
| FUNCTION Is_Base_Table
+============================================================================*/
FUNCTION Is_Base_Table(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    CURSOR c_table_type IS
        SELECT t.table_type
        FROM bsc_db_tables t, bsc_db_tables_rels r
        WHERE t.table_name = r.source_table_name and
              r.table_name = x_table_name;

    h_table_type NUMBER;

BEGIN

    OPEN c_table_type;
    FETCH c_table_type INTO h_table_type;
    IF c_table_type%NOTFOUND THEN
        h_table_type := 1;
    END IF;
    CLOSE c_table_type;

    IF h_table_type = 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Is_Base_Table;


/*===========================================================================+
| FUNCTION Is_EDW_Kpi_Table
+============================================================================*/
FUNCTION Is_EDW_Kpi_Table(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    h_b BOOLEAN;

    /* TYPE t_cursor IS REF CURSOR;

    c_indicator t_cursor; -- x_table_name, 1
    c_indicator_sql VARCHAR2(2000) := 'SELECT t.indicator'||
                                      ' FROM bsc_kpi_data_tables t, bsc_kpis_b k'||
                                      ' WHERE t.indicator = k.indicator AND'||
                                      ' table_name = :1 AND NVL(k.edw_flag, 0) = :2';
    */
    cursor c_indicator (pTableName varchar2, pEDWFlag number ) is
       SELECT t.indicator
       FROM bsc_kpi_data_tables t, bsc_kpis_b k
       WHERE t.indicator = k.indicator AND
       table_name = pTableName AND NVL(k.edw_flag, 0) = pEDWFlag;

    h_indicator NUMBER;

BEGIN
    h_b := FALSE;

    --OPEN c_indicator FOR c_indicator_sql USING x_table_name, 1;
    OPEN c_indicator(x_table_name, 1);
    FETCH c_indicator INTO h_indicator;
    IF c_indicator%FOUND THEN
        h_b := TRUE;
    END IF;
    CLOSE c_indicator;

    RETURN h_b;

END Is_EDW_Kpi_Table;


/*===========================================================================+
| FUNCTION Item_Belong_To_Array_Number
+============================================================================*/
FUNCTION Item_Belong_To_Array_Number(
	x_item IN NUMBER,
	x_array IN t_array_of_number,
	x_num_items IN NUMBER
	) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1 .. x_num_items LOOP
        IF x_array(h_i) = x_item THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Item_Belong_To_Array_Number;


/*===========================================================================+
| FUNCTION Item_Belong_To_Array_Varchar2
+============================================================================*/
FUNCTION Item_Belong_To_Array_Varchar2(
	x_item IN VARCHAR2,
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER
	) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1 .. x_num_items LOOP
        IF UPPER(x_array(h_i)) = UPPER(x_item) THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Item_Belong_To_Array_Varchar2;


--LOCKING: New procedure
/*===========================================================================+
| PROCEDURE Load_Calendar_Into_AW_AT
+============================================================================*/
PROCEDURE Load_Calendar_Into_AW_AT(
    x_calendar_id IN NUMBER
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    --Fix bug#4360037: load calendar into aw only if there are aw indicators
    IF Calendar_Used_In_AW_Kpi(x_calendar_id) THEN
        bsc_aw_calendar.create_calendar(
            p_calendar => x_calendar_id,
            p_options => 'DEBUG LOG, RECREATE'
        );
        bsc_aw_calendar.load_calendar(
            p_calendar => x_calendar_id,
            p_options => 'DEBUG LOG'
        );
    END IF;
    commit; -- all autonomous transaction needs to commit
END Load_Calendar_Into_AW_AT;


/*===========================================================================+
| FUNCTION Load_Periodicity_Rels
+============================================================================*/
FUNCTION Load_Periodicity_Rels RETURN BOOLEAN IS

    h_sql VARCHAR2(32000);

    CURSOR c_per_rels IS
        SELECT PERIODICITY_ID, SOURCE
        FROM BSC_SYS_PERIODICITIES
        ORDER BY PERIODICITY_ID;

    h_periodicity_id NUMBER;
    h_source VARCHAR2(500);

    h_index NUMBER;

    h_sources BSC_UPDATE_UTIL.t_array_of_number;
    h_num_sources NUMBER;
    h_i NUMBER;
    h_j NUMBER;
    h_source_periodicity_id NUMBER;

    h_arr_new_periodicity_rels BSC_UPDATE_UTIL.t_array_periodicity_rels;
    h_num_new_periodicity_rels NUMBER;

BEGIN
    h_sql := NULL;
    h_index := 0;

    IF g_array_periodicity_rels.COUNT > 0 THEN
        -- array already initialized
        RETURN TRUE;
    END IF;

    OPEN c_per_rels;
    LOOP
        FETCH c_per_rels INTO h_periodicity_id, h_source;
        EXIT WHEN c_per_rels%NOTFOUND;

        h_num_sources := Decompose_Numeric_List(h_source, h_sources, ',');

        FOR h_i IN 1..h_num_sources LOOP
            h_index := h_index + 1;
            g_array_periodicity_rels(h_index).periodicity_id := h_periodicity_id;
            g_array_periodicity_rels(h_index).source_periodicity_id := h_sources(h_i);
        END LOOP;

    END LOOP;
    CLOSE c_per_rels;

    -- Completes the source of periodicities. For example
    -- if periodicity A can be calculated from B and B can be calculated from C then
    -- A also can be calculated from C
    LOOP
        h_num_new_periodicity_rels := 0;
        h_arr_new_periodicity_rels.delete;

        FOR h_i IN 1..g_array_periodicity_rels.COUNT LOOP
            h_periodicity_id := g_array_periodicity_rels(h_i).periodicity_id;
            h_source_periodicity_id := g_array_periodicity_rels(h_i).source_periodicity_id;

            h_num_sources := Get_Source_Periodicities(h_source_periodicity_id, h_sources);

            FOR h_j IN 1..h_num_sources LOOP
                IF NOT Exist_Periodicity_Rel(h_periodicity_id, h_sources(h_j)) THEN
                    h_num_new_periodicity_rels := h_num_new_periodicity_rels + 1;
                    h_arr_new_periodicity_rels(h_num_new_periodicity_rels).periodicity_id := h_periodicity_id;
                    h_arr_new_periodicity_rels(h_num_new_periodicity_rels).source_periodicity_id := h_sources(h_j);
                END IF;
            END LOOP;
        END LOOP;

        FOR h_j IN 1..h_num_new_periodicity_rels LOOP
            h_index := h_index + 1;
            g_array_periodicity_rels(h_index).periodicity_id := h_arr_new_periodicity_rels(h_j).periodicity_id;
            g_array_periodicity_rels(h_index).source_periodicity_id := h_arr_new_periodicity_rels(h_j).source_periodicity_id;
        END LOOP;

        EXIT WHEN (h_num_new_periodicity_rels = 0);
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Load_Periodicity_Rels');
        RETURN FALSE;

END Load_Periodicity_Rels;


/*===========================================================================+
| FUNCTION Make_Lst_Cond_Join
+============================================================================*/
FUNCTION Make_Lst_Cond_Join(
	x_table_1 IN VARCHAR2,
	x_key_columns_1 IN t_array_of_varchar2,
        x_table_2 IN VARCHAR2,
        x_key_columns_2 IN t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_key_columns LOOP
        IF h_lst IS NULL THEN
            h_lst := x_table_1||'.'||x_key_columns_1(h_i)||' = '||
                     x_table_2||'.'||x_key_columns_2(h_i);
        ELSE
            h_lst := h_lst||' '||x_separator||' '||
                     x_table_1||'.'||x_key_columns_1(h_i)||' = '||
                     x_table_2||'.'||x_key_columns_2(h_i);
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Cond_Join;


/*===========================================================================+
| FUNCTION Make_Lst_Cond_Left_Join
+============================================================================*/
FUNCTION Make_Lst_Cond_Left_Join(
	x_table_1 IN VARCHAR2,
	x_key_columns_1 IN t_array_of_varchar2,
        x_table_2 IN VARCHAR2,
        x_key_columns_2 IN t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_key_columns LOOP
        IF h_lst IS NULL THEN
            h_lst := x_table_1||'.'||x_key_columns_1(h_i)||' = '||
                     x_table_2||'.'||x_key_columns_2(h_i)||' (+)';
        ELSE
            h_lst := h_lst||' '||x_separator||' '||
                     x_table_1||'.'||x_key_columns_1(h_i)||' = '||
                     x_table_2||'.'||x_key_columns_2(h_i)||' (+)';
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Cond_Left_Join;


/*===========================================================================+
| FUNCTION Make_Lst_Cond_Null
+============================================================================*/
FUNCTION Make_Lst_Cond_Null(
	x_table IN VARCHAR2,
	x_key_columns IN t_array_of_varchar2,
        x_num_key_columns IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_key_columns LOOP
        IF h_lst IS NULL THEN
            h_lst := x_table||'.'||x_key_columns(h_i)||' IS NULL';
        ELSE
            h_lst := h_lst||' '||x_separator||' '||
                     x_table||'.'||x_key_columns(h_i)||' IS NULL';
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Cond_Null;


/*===========================================================================+
| FUNCTION Make_Lst_Cond_Number
+============================================================================*/
FUNCTION Make_Lst_Cond_Number(
	x_column IN VARCHAR2,
        x_values IN t_array_of_number,
        x_num_values IN NUMBER,
        x_separator IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_values LOOP
        IF h_lst IS NULL THEN
            h_lst := x_column||'='||x_values(h_i);
        ELSE
            h_lst := h_lst||' '||x_separator||' '||
                     x_column||'='||x_values(h_i);
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Cond_Number;


/*===========================================================================+
| FUNCTION Make_Lst_Description
+============================================================================*/
FUNCTION Make_Lst_Description(
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER,
        x_data_type IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_items LOOP
        IF h_lst IS NULL THEN
            h_lst := x_array(h_i)||' '||x_data_type;
        ELSE
            h_lst := h_lst||', '||x_array(h_i)||' '||x_data_type;
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Description;


/*===========================================================================+
| FUNCTION Make_Lst_From_Array_Varchar2
+============================================================================*/
FUNCTION Make_Lst_From_Array_Varchar2(
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_items LOOP
        IF h_lst IS NULL THEN
            h_lst := x_array(h_i);
        ELSE
            h_lst := h_lst||', '||x_array(h_i);
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_From_Array_Varchar2;


/*===========================================================================+
| FUNCTION Make_Lst_Fixed_Column
+============================================================================*/
FUNCTION Make_Lst_Fixed_Column(
        x_fixed_column_name IN VARCHAR2,
	x_num_items IN NUMBER
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_items LOOP
        IF h_lst IS NULL THEN
            h_lst := x_fixed_column_name||h_i;
        ELSE
            h_lst := h_lst||', '||x_fixed_column_name||h_i;
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Fixed_Column;


/*===========================================================================+
| FUNCTION Make_Lst_Table_Column
+============================================================================*/
FUNCTION Make_Lst_Table_Column(
        x_table_name IN VARCHAR2,
	x_columns IN t_array_of_varchar2,
	x_num_columns IN NUMBER
	) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700);

BEGIN
    h_lst := NULL;

    FOR h_i IN 1 .. x_num_columns LOOP
        IF h_lst IS NULL THEN
            h_lst := x_table_name||'.'||x_columns(h_i);
        ELSE
            h_lst := h_lst||', '||x_table_name||'.'||x_columns(h_i);
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Table_Column;


/*===========================================================================+
| FUNCTION Populate_Bsc_Db_Calendar
+============================================================================*/
FUNCTION Populate_Bsc_Db_Calendar(
        x_calendar_id           NUMBER,
        X_Current_Fiscal_Yr     NUMBER,
        X_Fy_Start_Yr           NUMBER,
        X_Fy_Start_Mth          NUMBER,
        X_Fy_Start_Day          NUMBER
        ) RETURN BOOLEAN IS

	sql_stmt	VARCHAR2(2000); -- Sql statement string

        num_foryears    NUMBER; -- Number of forward years
                                -- (number_of_years - number_of_backyears)
	num_backyears	NUMBER; -- Number of back years(number_of_backyears)

        h_first_year	NUMBER;
	h_year_save	NUMBER;
	h_last_year	NUMBER;

        h_fy_start_date	DATE;
	h_fy_end_date	DATE;

        h_current_date	DATE;
	h_monthly	NUMBER;
	h_semester	NUMBER;
	h_quarterly	NUMBER;
	h_bimonthly	NUMBER;
	h_weekly52	NUMBER;
	h_weekly4	NUMBER;
	h_daily365	NUMBER;
	h_daily30	NUMBER;
	h_year		NUMBER;
	h_month		NUMBER;
	h_day		NUMBER;

        h_pername_list VARCHAR2(300);
        y 		NUMBER;

        TYPE t_cursor IS REF CURSOR;

        -- Only look at tables using bsc calendar
        /*
        get_range_yr t_cursor; -- 2, 0, x_calendar_id
        get_range_yr_sql VARCHAR2(2000) := 'SELECT nvl(max(num_of_years - previous_years), 1),'||
                                           ' nvl(max(previous_years), 1)'||
                                           ' FROM bsc_db_tables'||
                                           ' WHERE table_type <> :1 AND nvl(num_of_years, 0) > :2 AND'||
                                           ' periodicity_id IN (SELECT periodicity_id'||
                                           ' FROM bsc_sys_periodicities'||
                                           ' WHERE calendar_id = :3)';
        */
        CURSOR get_range_yr (p_table_type NUMBER, p_num_of_years NUMBER, p_calendar_id NUMBER) IS
            SELECT nvl(max(num_of_years - previous_years), 1), nvl(max(previous_years), 1)
            FROM bsc_db_tables
            WHERE table_type <> p_table_type AND nvl(num_of_years, 0) > p_num_of_years AND
                  periodicity_id IN (
                    SELECT periodicity_id
                    FROM bsc_sys_periodicities
                    WHERE calendar_id = p_calendar_id);


        h_message VARCHAR2(4000);

        h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
        h_num_bind_vars NUMBER;

BEGIN
    /* Get the range of years the system tables need. */
    --OPEN get_range_yr FOR get_range_yr_sql USING 2, 0, x_calendar_id;
    OPEN get_range_yr(2, 0, x_calendar_id);
    FETCH get_range_yr INTO num_foryears, num_backyears;
    IF get_range_yr%NOTFOUND THEN
	num_foryears := 1;
	num_backyears := 1;
    END IF;
    CLOSE get_range_yr;

    h_first_year := X_Fy_Start_Yr - num_backyears;
    h_year_save := X_Current_Fiscal_Yr - num_backyears;
    h_last_year := h_first_year + (num_backyears + num_foryears) - 1;

    -- Delete all rows from bsc_db_calendar
    /*
    sql_stmt := 'DELETE FROM bsc_db_calendar WHERE calendar_id = :1';
    EXECUTE IMMEDIATE sql_stmt USING x_calendar_id;
    */
    DELETE FROM bsc_db_calendar WHERE calendar_id = x_calendar_id;

    h_pername_list := 'year, semester, quarter, bimester, month, week52, '||
                      'week4, day365, day30';

    FOR y in h_first_year .. h_last_year LOOP
	-- Get the calendar dates for a fiscal year start and end.
    	h_fy_start_date := to_date(to_char(X_Fy_Start_Day) || '-' ||
		  	      	   to_char(X_Fy_Start_Mth) || '-' ||
			      	   to_char(y), 'DD-MM-YYYY');
	h_fy_end_date := Add_Months(h_fy_start_date, 12) - 1;

	h_monthly := 1;
	h_semester := 1;
	h_quarterly := 1;
	h_bimonthly := 1;
	h_weekly52 := 1;
	h_weekly4 := 1;
	h_daily365 := 1;
	h_daily30 := 1;

	h_current_date := h_fy_start_date;

	WHILE (h_current_date <= h_fy_end_date) LOOP
	    h_day := to_number(to_char(h_current_date, 'DD'));
	    h_month := to_number(to_char(h_current_date, 'MM'));
	    h_year := to_number(to_char(h_current_date, 'YYYY'));

            /*
	    sql_stmt :=
              'INSERT INTO bsc_db_calendar (calendar_id, calendar_year, calendar_month,'||
              ' calendar_day, ' || h_pername_list ||
	        ') VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13)';

            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_calendar_id;
            h_bind_vars_values(2) := h_year;
            h_bind_vars_values(3) := h_month;
            h_bind_vars_values(4) := h_day;
            h_bind_vars_values(5) := h_year_save;
            h_bind_vars_values(6) := h_semester;
            h_bind_vars_values(7) := h_quarterly;
            h_bind_vars_values(8) := h_bimonthly;
            h_bind_vars_values(9) := h_monthly;
            h_bind_vars_values(10) := h_weekly52;
            h_bind_vars_values(11) := h_weekly4;
            h_bind_vars_values(12) := h_daily365;
            h_bind_vars_values(13) := h_daily30;
            h_num_bind_vars := 13;
            BSC_UPDATE_UTIL.Execute_Immediate(sql_stmt, h_bind_vars_values, h_num_bind_vars);
            */

            INSERT INTO bsc_db_calendar (calendar_id, calendar_year, calendar_month, calendar_day,
             year, semester, quarter, bimester, month, week52, week4, day365, day30)
            VALUES (x_calendar_id, h_year, h_month, h_day, h_year_save, h_semester, h_quarterly,
             h_bimonthly, h_monthly, h_weekly52, h_weekly4, h_daily365, h_daily30);

	    -- Increment current date by one day.
	    h_current_date := h_current_date + 1;

	    IF (to_char(h_current_date, 'MM') <>
		to_char(h_current_date - 1, 'MM')) THEN
	    -- In a different month.
		h_monthly := h_monthly + 1;
		h_semester := floor((h_monthly - 1) / 6 + 1);
		h_quarterly := floor((h_monthly - 1) / 3 + 1);
		h_bimonthly := floor((h_monthly - 1) / 2 + 1);
		h_daily30 := 1;
	    ELSE
	    -- In the same month.
		h_daily30 := h_daily30 + 1;
	    END IF;

            h_daily365 := h_daily365 + 1;

	    IF (to_char(h_current_date, 'DY') =
		to_char(h_fy_start_date, 'DY')) THEN
	    -- Current date is on the same day of the week as the fiscal
	    -- year start date.  Increment week values by 1.
		IF (to_char(h_current_date, 'MM') <>
		    to_char(h_current_date - 7, 'MM')) THEN
		-- In a different month.
		    h_weekly4 := 1;
		ELSE
		-- In the same month.
		    h_weekly4 := h_weekly4 + 1;
		END IF;

		h_weekly52 := h_weekly52 + 1;
	    END IF;
	END LOOP; /* WHILE (h_current_date <= h_fy_end_date) LOOP */

	h_year_save := h_year_save + 1;

    END LOOP; /* FOR y in h_first_year .. h_last_year LOOP */

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_UTIL.Populate_Bsc_Db_Calendar');
        RETURN FALSE;

END Populate_Bsc_Db_Calendar;


/*===========================================================================+
| FUNCTION Populate_Bsc_Db_Week_Maps
+============================================================================*/
FUNCTION Populate_Bsc_Db_Week_Maps (
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN IS

    sql_stmt VARCHAR2(2000);
    h_message VARCHAR2(4000);

BEGIN
    -- Delete all rows from bsc_db_week_maps
    /* sql_stmt := 'DELETE FROM BSC_DB_WEEK_MAPS'||
                ' WHERE CALENDAR_ID = :1';
    EXECUTE IMMEDIATE sql_stmt USING x_calendar_id; */

    DELETE FROM BSC_DB_WEEK_MAPS
     WHERE CALENDAR_ID = x_calendar_id;

    -- Insert the records
    /* sql_stmt := 'INSERT INTO bsc_db_week_maps (year, month, week, week52, calendar_id)'||
                ' SELECT year, min(month), week4, week52, calendar_id'||
                ' FROM bsc_db_calendar'||
                ' WHERE calendar_id = :1'||
                ' GROUP BY year, week4, week52, calendar_id';
    EXECUTE IMMEDIATE sql_stmt USING x_calendar_id; */
    INSERT INTO bsc_db_week_maps (year, month, week, week52,  calendar_id)
    SELECT year, min(month), week4, week52, calendar_id
    FROM bsc_db_calendar
    WHERE calendar_id = x_calendar_id
    GROUP BY year, week4, week52, calendar_id;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                x_message => SQLERRM,
                x_source => 'BSC_UPDATE_UTIL.Populate_Bsc_Db_Week_Maps');
        RETURN FALSE;

END Populate_Bsc_Db_Week_Maps;


/*===========================================================================+
| FUNCTION Populate_Bsc_Sys_Periods_Tl
+============================================================================*/
FUNCTION Populate_Bsc_Sys_Periods_Tl(
	x_calendar_id IN NUMBER
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);
    h_message VARCHAR2(4000);

    TYPE t_cursor IS REF CURSOR;

    CURSOR c_custom_pers (p_calendar_id NUMBER, p_custom_code NUMBER) IS
        SELECT periodicity_id, db_column_name
        FROM bsc_sys_periodicities
        WHERE calendar_id = p_calendar_id AND custom_code <> p_custom_code;

    h_periodicity_id NUMBER;
    h_db_column_name VARCHAR2(50);

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    -- Delete all rows from bsc_sys_periods_tl
    DELETE FROM BSC_SYS_PERIODS_TL
    WHERE PERIODICITY_ID IN (
      SELECT PERIODICITY_ID
      FROM BSC_SYS_PERIODICITIES
      WHERE CALENDAR_ID = x_calendar_id);


-- A. LABELS FOR PREDEFINED PERIODICITIES
    -- Insert the records
    INSERT INTO BSC_SYS_PERIODS_TL (YEAR, PERIODICITY_ID, PERIOD_ID, MONTH,
    LANGUAGE, SOURCE_LANG, NAME, SHORT_NAME)
     SELECT
       CA.YEAR,
       CA.PERIODICITY_ID,
       CA.PERIOD_ID,
       1 AS MONTH,
       L.LANGUAGE_CODE AS LANGUAGE,
       L.LANGUAGE_CODE AS SOURCE_LANG,
       CA.NAME,
       NULL AS SHORT_NAME
       FROM
       ( SELECT
           C.YEAR AS YEAR,
           P.PERIODICITY_ID AS PERIODICITY_ID,
           C.SEMESTER AS PERIOD_ID,
           C.CALENDAR_MONTH||';'||C2.CALENDAR_MONTH AS NAME
         FROM
           BSC_DB_CALENDAR C,
           BSC_DB_CALENDAR C2,
           BSC_SYS_PERIODICITIES P
         WHERE
           P.CALENDAR_ID = x_calendar_id AND
           P.PERIODICITY_TYPE = 2 AND
           C.YEAR = C2.YEAR AND
           C.CALENDAR_ID = C2.CALENDAR_ID AND
           C.CALENDAR_ID = P.CALENDAR_ID AND
           C.SEMESTER = C2.SEMESTER AND
           TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
            FROM BSC_DB_CALENDAR C1
            WHERE C1.YEAR = C.YEAR AND C1.SEMESTER = C.SEMESTER AND C1.CALENDAR_ID = C.CALENDAR_ID
           ) AND
           TO_DATE(C2.CALENDAR_YEAR||'-'||C2.CALENDAR_MONTH||'-'||C2.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
            FROM BSC_DB_CALENDAR C1
            WHERE C1.YEAR = C2.YEAR AND C1.SEMESTER = C2.SEMESTER AND C1.CALENDAR_ID = C2.CALENDAR_ID
           )
           UNION
         SELECT
           C.YEAR AS YEAR,
           P.PERIODICITY_ID AS PERIODICITY_ID,
           C.QUARTER AS PERIOD_ID,
           C.CALENDAR_MONTH||';'||C2.CALENDAR_MONTH AS NAME
         FROM
           BSC_DB_CALENDAR C,
           BSC_DB_CALENDAR C2,
           BSC_SYS_PERIODICITIES P
         WHERE
           P.CALENDAR_ID = x_calendar_id AND
           P.PERIODICITY_TYPE = 3 AND
           C.YEAR = C2.YEAR AND
           C.CALENDAR_ID = C2.CALENDAR_ID AND
           C.CALENDAR_ID = P.CALENDAR_ID AND
           C.QUARTER = C2.QUARTER AND
           TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
            FROM BSC_DB_CALENDAR C1
            WHERE C1.YEAR = C.YEAR AND C1.QUARTER = C.QUARTER AND C1.CALENDAR_ID = C.CALENDAR_ID
           ) AND
           TO_DATE(C2.CALENDAR_YEAR||'-'||C2.CALENDAR_MONTH||'-'||C2.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
            FROM BSC_DB_CALENDAR C1
            WHERE C1.YEAR = C2.YEAR AND C1.QUARTER = C2.QUARTER AND C1.CALENDAR_ID = C2.CALENDAR_ID
           )
           UNION
         SELECT
           C.YEAR AS YEAR,
           P.PERIODICITY_ID AS PERIODICITY_ID,
           C.BIMESTER AS PERIOD_ID,
           C.CALENDAR_MONTH||';'||C2.CALENDAR_MONTH AS NAME
         FROM
           BSC_DB_CALENDAR C,
           BSC_DB_CALENDAR C2,
           BSC_SYS_PERIODICITIES P
         WHERE
           P.CALENDAR_ID = x_calendar_id AND
           P.PERIODICITY_TYPE = 4 AND
           C.YEAR = C2.YEAR AND
           C.CALENDAR_ID = C2.CALENDAR_ID AND
           C.CALENDAR_ID = P.CALENDAR_ID AND
           C.BIMESTER = C2.BIMESTER AND
           TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MIN(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
            FROM BSC_DB_CALENDAR C1
            WHERE C1.YEAR = C.YEAR AND C1.BIMESTER = C.BIMESTER AND C1.CALENDAR_ID = C.CALENDAR_ID
           ) AND
           TO_DATE(C2.CALENDAR_YEAR||'-'||C2.CALENDAR_MONTH||'-'||C2.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
            FROM BSC_DB_CALENDAR C1
            WHERE C1.YEAR = C2.YEAR AND C1.BIMESTER = C2.BIMESTER AND C1.CALENDAR_ID = C2.CALENDAR_ID
           )
         UNION
         SELECT
           C.YEAR AS YEAR,
           P.PERIODICITY_ID AS PERIODICITY_ID,
           C.MONTH AS PERIOD_ID,
           TO_CHAR(C.CALENDAR_MONTH) AS NAME
         FROM
           BSC_DB_CALENDAR C,
           BSC_SYS_PERIODICITIES P
         WHERE
           P.CALENDAR_ID = x_calendar_id AND
           P.PERIODICITY_TYPE = 5 AND
           C.CALENDAR_ID = P.CALENDAR_ID
         GROUP BY C.YEAR, C.MONTH, C.CALENDAR_MONTH, P.PERIODICITY_ID
         UNION
         SELECT
           C.YEAR AS YEAR,
           P.PERIODICITY_ID AS PERIODICITY_ID,
           C.WEEK52 AS PERIOD_ID,
           C.CALENDAR_MONTH||';'||C.CALENDAR_DAY AS NAME
         FROM
           BSC_DB_CALENDAR C,
           BSC_SYS_PERIODICITIES P
         WHERE
           P.CALENDAR_ID = x_calendar_id AND
           C.CALENDAR_ID = P.CALENDAR_ID AND
           P.PERIODICITY_TYPE = 7 AND
           TO_DATE(C.CALENDAR_YEAR||'-'||C.CALENDAR_MONTH||'-'||C.CALENDAR_DAY,'YYYY-MM-DD') =
           (SELECT MAX(TO_DATE(C1.CALENDAR_YEAR||'-'||C1.CALENDAR_MONTH||'-'||C1.CALENDAR_DAY,'YYYY-MM-DD'))
           FROM BSC_DB_CALENDAR C1
           WHERE C1.YEAR = C.YEAR AND C1.WEEK52 = C.WEEK52 AND C1.CALENDAR_ID = C.CALENDAR_ID
           )
         UNION
         SELECT
           C.YEAR AS YEAR,
           P.PERIODICITY_ID AS PERIODICITY_ID,
           C.DAY365 AS PERIOD_ID,
           C.CALENDAR_MONTH||';'||C.CALENDAR_DAY AS NAME
         FROM
           BSC_DB_CALENDAR C,
           BSC_SYS_PERIODICITIES P
         WHERE
           P.CALENDAR_ID = x_calendar_id AND
           P.PERIODICITY_TYPE = 9 AND
         C.CALENDAR_ID = P.CALENDAR_ID) CA, FND_LANGUAGES L  WHERE L.INSTALLED_FLAG <> 'D';


-- B. LABELS FOR CUSTOM PERIODICITIES
    --OPEN c_custom_pers FOR c_custom_pers_sql USING x_calendar_id, 0;
    OPEN c_custom_pers(x_calendar_id, 0);
    FETCH c_custom_pers INTO h_periodicity_id, h_db_column_name;
    WHILE c_custom_pers%FOUND LOOP
        h_sql :=  'INSERT INTO BSC_SYS_PERIODS_TL (
                      YEAR,
                      PERIODICITY_ID,
                      PERIOD_ID,
                      MONTH,
                      LANGUAGE,
                      SOURCE_LANG,
                      NAME,
                      SHORT_NAME)
                   SELECT
                      C.YEAR AS YEAR,
                      :1 AS PERIODICITY_ID,
                      C.'||h_db_column_name||' AS PERIOD_ID,
                      1 AS MONTH,
                      L.LANGUAGE_CODE AS LANGUAGE,
                      L.LANGUAGE_CODE AS SOURCE_LANG,
                      C.CALENDAR_MONTH||'';''||C.CALENDAR_DAY AS NAME,
                      NULL AS SHORT_NAME
                   FROM
                      BSC_DB_CALENDAR C,
                      FND_LANGUAGES L
                   WHERE
                      L.INSTALLED_FLAG <> ''D'' AND
                      C.CALENDAR_ID = :2 AND
                      TO_DATE(C.CALENDAR_YEAR||''-''||C.CALENDAR_MONTH||''-''||C.CALENDAR_DAY,''YYYY-MM-DD'') =
                         (SELECT
                              MAX(TO_DATE(C1.CALENDAR_YEAR||''-''||C1.CALENDAR_MONTH||''-''||C1.CALENDAR_DAY,''YYYY-MM-DD''))
	                    FROM
                              BSC_DB_CALENDAR C1
                          WHERE
	                        C1.YEAR = C.YEAR AND
	                        C1.'||h_db_column_name||' = C.'||h_db_column_name||' AND
                              C1.CALENDAR_ID = C.CALENDAR_ID
                         )';

        h_bind_vars_values.delete;
        h_bind_vars_values(1) := h_periodicity_id;
        h_bind_vars_values(2) := x_calendar_id;
        h_num_bind_vars := 2;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

        FETCH c_custom_pers INTO h_periodicity_id, h_db_column_name;
    END LOOP;
    CLOSE c_custom_pers;


    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                x_message => SQLERRM,
                x_source => 'BSC_UPDATE_UTIL.Populate_Bsc_Sys_Periods_Tl');
        RETURN FALSE;

END Populate_Bsc_Sys_Periods_Tl;


/*===========================================================================+
| PROCEDURE Populate_Calendar_Tables
+============================================================================*/
PROCEDURE Populate_Calendar_Tables (
    x_calendar_id IN NUMBER,
    x_action IN NUMBER
    ) IS

    e_error EXCEPTION;
    e_error_load_rpt_cal EXCEPTION;
    h_error_message VARCHAR2(2000);

BEGIN
    -- Init BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Init calendar tables
    IF NOT BSC_UPDATE_UTIL.Init_Calendar_Tables(x_calendar_id, x_action) THEN
        RAISE e_error;
    END IF;

    -- BSC_MV Note: Populate reporting calendar
    --Fix bug#3847656: We only need to call Load_Reporting_Calendar when x_action=2
    IF x_action = 2 THEN
        IF BSC_APPS.bsc_mv THEN
            --Fix bug#4027813: call reporting calendar onlyto process this calendar
            IF NOT BSC_BIA_WRAPPER.Load_Reporting_Calendar(x_calendar_id, h_error_message) THEN
                RAISE e_error_load_rpt_cal;
            END IF;

            -- AW_INTEGRATION: Call aw api to import calendar into aw world
            --Fix bug#4360037: load calendar into aw only if there are aw indicators
            IF Calendar_Used_In_Aw_Kpi(x_calendar_id) THEN
                bsc_aw_calendar.create_calendar(
                    p_calendar => x_calendar_id,
                    p_options => 'DEBUG LOG, RECREATE'
                );
                bsc_aw_calendar.load_calendar(
                    p_calendar => x_calendar_id,
                    p_options => 'DEBUG LOG'
                );
            END IF;
        END IF;
    END IF;

EXCEPTION
    WHEN e_error THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_CALTABLES_POP_FAILED'),
                        x_source => 'BSC_UPDATE_UTIL.Populate_Calendar_Tables',
                        x_mode => 'I');
        COMMIT;

    WHEN e_error_load_rpt_cal THEN
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => 'BSC_BIA_WRAPPER.Load_Reporting_Calendar: '||h_error_message,
                        x_source => 'BSC_UPDATE_UTIL.Populate_Calendar_Tables',
                        x_mode => 'I');
        COMMIT;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Populate_Calendar_Tables',
                        x_mode => 'I');
        COMMIT;
END Populate_Calendar_Tables;


/*===========================================================================+
| PROCEDURE Populate_Calendar_Tables
+============================================================================*/
PROCEDURE Populate_Calendar_Tables (
    x_calendar_id IN NUMBER
    ) IS

BEGIN
    Populate_Calendar_Tables(x_calendar_id, NULL);

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Populate_Calendar_Tables',
                        x_mode => 'I');
        COMMIT;
END Populate_Calendar_Tables;


--Fix bug#4508980 : this api is provided to be called from OAF Calendar UI
-- Note that from now on, load reporting calendar and load calendar into aw will be done in GDB
/*===========================================================================+
| PROCEDURE Populate_Calendar_Tables
+============================================================================*/
PROCEDURE Populate_Calendar_Tables (
    p_commit         VARCHAR2,
    p_calendar_id    NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2,
    x_msg_count      OUT NOCOPY  NUMBER,
    x_msg_data       OUT NOCOPY  VARCHAR2
) IS

    e_error EXCEPTION;
    l_api_name CONSTANT VARCHAR2(30) := 'Populate_Calendar_Tables';

BEGIN
    SAVEPOINT BscUpdateUtilPopCalTables;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Init BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Init calendar tables
    IF NOT BSC_UPDATE_UTIL.Init_Calendar_Tables(p_calendar_id) THEN
        RAISE e_error;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN e_error THEN
        ROLLBACK TO BscUpdateUtilPopCalTables;
        FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
            l_api_name,
            BSC_UPDATE_UTIL.Get_Message('BSC_CALTABLES_POP_FAILED')
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BscUpdateUtilPopCalTables;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscUpdateUtilPopCalTables;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => 'F'
           ,p_count => x_msg_count
           ,p_data => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO BscUpdateUtilPopCalTables;
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
END Populate_Calendar_Tables;


/*===========================================================================+
| FUNCTON Replace_Token
+============================================================================*/
FUNCTION Replace_Token(
	x_message IN VARCHAR2,
	x_token_name IN VARCHAR2,
	x_token_value IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_message VARCHAR2(4000);

BEGIN
    h_message := REPLACE(x_message, '&'||x_token_name, x_token_value);
    RETURN h_message;
END Replace_Token;


/*===========================================================================+
| FUNTION Set_Calendar_Fiscal_Year
+============================================================================*/
FUNCTION Set_Calendar_Fiscal_Year(
	x_calendar_id IN NUMBER,
        x_fiscal_year IN NUMBER
	) RETURN BOOLEAN IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

BEGIN
    h_sessionid := USERENV('SESSIONID');

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    /*
    h_sql := 'UPDATE bsc_sys_calendars_b'||
             ' SET fiscal_year = :1, last_updated_by = :2, last_update_date = SYSDATE'||
             ' WHERE calendar_id = :3';
    EXECUTE IMMEDIATE h_sql USING x_fiscal_year, h_user_id, x_calendar_id;
    */
    UPDATE bsc_sys_calendars_b
    SET fiscal_year = x_fiscal_year, last_updated_by = h_user_id, last_update_date = SYSDATE
    WHERE calendar_id = x_calendar_id;

    -- Fix bug#3636273 No need this commit here
    --COMMIT;

    --Fix Bug in year change process.
    g_array_calendars(x_calendar_id).fiscal_year := x_fiscal_year;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_UTIL.Set_Calendar_Fiscal_Year');
        RETURN FALSE;

END Set_Calendar_Fiscal_Year;


/*===========================================================================+
| FUNCTION Table_Exists                                                      |
+============================================================================*/
FUNCTION Table_Exists(
	X_Table			VARCHAR2
	)	RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;

    /*
    get_table t_cursor; -- X_Table
    get_table_sql VARCHAR2(2000) := 'SELECT table_name'||
                                    ' FROM USER_TABLES'||
                                    ' WHERE table_name = :1';
    */
    CURSOR get_table (p_table_name VARCHAR2) IS
        SELECT table_name
        FROM USER_TABLES
        WHERE table_name = p_table_name;

    /*
    get_table_apps t_cursor; -- X_Table, BSC_APPS.BSC_APPS_SCHEMA
    get_table_apps_sql VARCHAR2(2000) := 'SELECT table_name'||
                                         ' FROM ALL_TABLES'||
                                         ' WHERE table_name = :1'||
                                         ' AND owner = :2';
    */
    CURSOR get_table_apps (p_table_name VARCHAR2, p_owner VARCHAR2) IS
        SELECT table_name
        FROM ALL_TABLES
        WHERE table_name = p_table_name AND owner = p_owner;

    h_tbl VARCHAR2(30);
    h_table VARCHAR2(30);
BEGIN
    h_table := UPPER(X_Table);

    IF NOT BSC_APPS.APPS_ENV THEN
        -- Personal
        --OPEN get_table FOR get_table_sql USING h_table;
        OPEN get_table(h_table);
        FETCH get_table INTO h_tbl;
        IF get_table%NOTFOUND THEN
	    CLOSE get_table;
	    RETURN (FALSE);
        END IF;
        CLOSE get_table;
    ELSE
        -- APPS
        --OPEN get_table_apps FOR get_table_apps_sql USING h_table, BSC_APPS.BSC_APPS_SCHEMA;
        OPEN get_table_apps(h_table, BSC_APPS.BSC_APPS_SCHEMA);
        FETCH get_table_apps INTO h_tbl;
        IF get_table_apps%NOTFOUND THEN
	    CLOSE get_table_apps;
	    RETURN (FALSE);
        END IF;
        CLOSE get_table_apps;
    END IF;

    RETURN (TRUE);
END Table_Exists;


/*===========================================================================+
| FUNCTION Table_Has_Any_Row
+============================================================================*/
FUNCTION Table_Has_Any_Row(
	x_table_name IN VARCHAR2,
        x_condition IN VARCHAR2
	) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(2000);

    h_num_rows NUMBER;
    h_res BOOLEAN;

BEGIN
    h_sql := 'SELECT COUNT(*) FROM '||x_table_name||' WHERE ROWNUM < :1';
    IF x_condition IS NOT NULL THEN
        h_sql := h_sql||' AND '||x_condition;
    END IF;

    OPEN h_cursor FOR h_sql USING 2;
    FETCH h_cursor INTO h_num_rows;
    IF h_num_rows > 0 THEN
        h_res := TRUE;
    ELSE
        h_res := FALSE;
    END IF;
    CLOSE h_cursor;

    RETURN h_res;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_UTIL.Table_Has_Any_Row');
        RETURN NULL;

END Table_Has_Any_Row;


/*===========================================================================+
| FUNCTION Table_Has_Any_Row
+============================================================================*/
FUNCTION Table_Has_Any_Row(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS

    h_res BOOLEAN;

BEGIN
    h_res := Table_Has_Any_Row(x_table_name, NULL);
    RETURN h_res;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_UTIL.Table_Has_Any_Row');
        RETURN NULL;

END Table_Has_Any_Row;


/*===========================================================================+
| PROCEDURE Truncate_Table
+============================================================================*/
PROCEDURE Truncate_Table(
        x_table_name IN VARCHAR2
	) IS

    h_sql VARCHAR2(200);
    h_bsc_schema VARCHAR2(30);

BEGIN

    h_bsc_schema := BSC_APPS.bsc_apps_schema;
    IF h_bsc_schema IS NOT NULL THEN
        h_bsc_schema := h_bsc_schema||'.';
    END IF;

    h_sql := 'TRUNCATE TABLE '||h_bsc_schema||x_table_name;
    Execute_Immediate(h_sql);
END Truncate_Table;


--LOCKING: new procedure
/*===========================================================================+
| PROCEDURE Truncate_Table_AT
+============================================================================*/
PROCEDURE Truncate_Table_AT(
        x_table_name IN VARCHAR2
	) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    Truncate_Table(x_table_name);
END Truncate_Table_AT;


/*===========================================================================+
| PROCEDURE Update_AnualPeriodicity_Src
+============================================================================*/
PROCEDURE Update_AnualPeriodicity_Src (
    x_calendar_id IN NUMBER,
    x_periodicity_id IN NUMBER,
    x_action IN NUMBER
    ) IS

    e_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;

    /*
    c_new_per t_cursor; -- x_calendar_id, 1
    c_new_per_sql VARCHAR2(2000) := 'SELECT SOURCE'||
                                    ' FROM BSC_SYS_PERIODICITIES'||
                                    ' WHERE CALENDAR_ID = :1 AND PERIODICITY_TYPE = :2'||
                                    ' ORDER BY PERIODICITY_ID';
    */
    CURSOR c_new_per (p_calendar_id NUMBER, p_periodicity_type NUMBER) IS
        SELECT SOURCE
        FROM BSC_SYS_PERIODICITIES
        WHERE CALENDAR_ID = p_calendar_id AND PERIODICITY_TYPE = p_periodicity_type
        ORDER BY PERIODICITY_ID;

    h_source  VARCHAR2(200);
    h_tmp_array BSC_UPDATE_UTIL.t_array_of_number;
    h_count NUMBER;
    h_i NUMBER;
    h_new_per_id NUMBER;
    h_new_source  VARCHAR2(200);
    x_exist BOOLEAN;

    h_sql VARCHAR2(32000);

BEGIN
    -- Init BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;
     --- Update the SOURCE columns
	--OPEN c_new_per FOR c_new_per_sql USING x_calendar_id, 1;
        OPEN c_new_per(x_calendar_id, 1);
        FETCH c_new_per INTO h_source;
	IF  c_new_per%FOUND THEN
		h_new_source := '';
		x_exist := FALSE;
		IF h_source IS NOT NULL THEN
			h_count := BSC_UPDATE_UTIL.Decompose_Numeric_List(h_source,h_tmp_array,',');
			FOR h_i IN 1.. h_count LOOP
				-- Get New Value
				h_new_per_id := h_tmp_array(h_i);
				--Delete
				IF x_action  =  2 THEN
				    IF h_new_per_id <> x_periodicity_id THEN
					IF h_new_source IS NOT NULL THEN
						h_new_source := h_new_source  || ',' || h_new_per_id;
					ELSE
						h_new_source := h_new_per_id;
					END IF;
				    END IF;
				ELSE
				--Update/add
				    IF h_new_per_id = x_periodicity_id THEN
					x_exist := TRUE;
				    END IF;
				    IF h_new_source IS NOT NULL THEN
				    	 h_new_source := h_new_source  || ',' || h_new_per_id;
				    ELSE
					h_new_source := h_new_per_id;
     				    END IF;
				END IF;
			END LOOP;
			IF x_action  =  1 AND x_exist = FALSE THEN
				h_new_source := h_new_source  || ',' || x_periodicity_id ;
			END IF;

			-- Update the source
                        /*
			h_sql := 'UPDATE BSC_SYS_PERIODICITIES SET SOURCE = :1'||
                                 ' WHERE CALENDAR_ID = :2 AND PERIODICITY_TYPE = :3';
                        EXECUTE IMMEDIATE h_sql USING h_new_source, x_calendar_id, 1;
                        */
                        UPDATE BSC_SYS_PERIODICITIES SET SOURCE = h_new_source
                        WHERE CALENDAR_ID = x_calendar_id AND PERIODICITY_TYPE = 1;

		ELSE
			IF x_action  =  1  THEN
				h_new_source := x_periodicity_id ;
				-- Update the source
                                /*
				h_sql := 'UPDATE BSC_SYS_PERIODICITIES SET SOURCE = :1'||
                                         ' WHERE CALENDAR_ID = :2 AND PERIODICITY_TYPE = :3';
                                EXECUTE IMMEDIATE h_sql USING h_new_source, x_calendar_id, 1;
                                */
                                UPDATE BSC_SYS_PERIODICITIES SET SOURCE = h_new_source
                                WHERE CALENDAR_ID = x_calendar_id AND PERIODICITY_TYPE = 1;
			END IF;
		END IF;
	END IF;
	CLOSE c_new_per;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.UpdAnualPeriodicitySrc',
                        x_mode => 'I');
        COMMIT;
END Update_AnualPeriodicity_Src;


/*===========================================================================+
| PROCEDURE Update_Kpi_Period_Name
+============================================================================*/
FUNCTION Update_Kpi_Period_Name(
	x_indicator IN NUMBER
	) RETURN BOOLEAN IS

    h_edw_flag NUMBER;
    h_current_fy NUMBER;
    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    -- Get Kpi EDW Flag
    /* h_sql := 'SELECT NVL(edw_flag, 0)'||
             ' FROM bsc_kpis_b'||
             ' WHERE indicator = :1';
    OPEN h_cursor FOR h_sql USING x_indicator;
    FETCH h_cursor INTO h_edw_flag;
    CLOSE h_cursor; */
    SELECT NVL(edw_flag, 0)
    INTO h_edw_flag
    FROM bsc_kpis_b
    WHERE indicator = x_indicator;

    IF h_edw_flag = 0 THEN
        -- BSC Kpi => BSC Periodicity
        -- Labels are in BSC_SYS_PERIODS_TL

        h_sql := ' UPDATE
                    BSC_KPI_DEFAULTS_TL D
                  SET
                    PERIOD_NAME = (
                      SELECT
                        DECODE(P.YEARLY_FLAG,
                               1, K.PERIODICITY_ID||''-''||C.FISCAL_YEAR,
                               (SELECT
                                  K.PERIODICITY_ID||''-''||L.NAME
                                FROM
                                  BSC_KPI_PERIODICITIES KP,
                                  BSC_SYS_PERIODS_TL L
                                WHERE
                                  K.INDICATOR = KP.INDICATOR AND
                                  K.PERIODICITY_ID = KP.PERIODICITY_ID AND
                                  C.FISCAL_YEAR = L.YEAR AND
                                  KP.PERIODICITY_ID = L.PERIODICITY_ID AND
                                  KP.CURRENT_PERIOD = L.PERIOD_ID AND
                                  D.LANGUAGE = L.LANGUAGE
                               ))
                      FROM
                        BSC_DB_COLOR_KPI_V K,
                        BSC_SYS_PERIODICITIES P,
                        BSC_SYS_CALENDARS_B C
                      WHERE
                        K.TAB_ID = D.TAB_ID AND
                        K.INDICATOR = D.INDICATOR AND
                        K.PERIODICITY_ID = P.PERIODICITY_ID AND
                        P.CALENDAR_ID = C.CALENDAR_ID
                    )
                  WHERE
                    INDICATOR = :1';

        h_bind_vars_values.delete;
        h_bind_vars_values(1) := x_indicator;
        h_num_bind_vars := 1;
        Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

    ELSE
        -- EDW Kpi => EDW Periodicity
        -- Labels are in BSC_EDW_PERIODS_TL
        h_sql := 'UPDATE
                    BSC_KPI_DEFAULTS_TL D
                  SET
                    PERIOD_NAME = (
                      SELECT
                        DECODE(P.YEARLY_FLAG,
                               1, ''EDW-''||C.FISCAL_YEAR,
                               (SELECT
                                  ''EDW-''||L.NAME
                                FROM
                                  BSC_KPI_PERIODICITIES KP,
                                  BSC_EDW_PERIODS_TL L
                                WHERE
                                  K.INDICATOR = KP.INDICATOR AND
                                  K.PERIODICITY_ID = KP.PERIODICITY_ID AND
                                  C.FISCAL_YEAR = L.YEAR AND
                                  KP.PERIODICITY_ID = L.PERIODICITY_ID AND
                                  KP.CURRENT_PERIOD = L.PERIOD_ID AND
                                  D.LANGUAGE = L.LANGUAGE
                               ))
                      FROM
                        BSC_DB_COLOR_KPI_V K,
                        BSC_SYS_PERIODICITIES P,
                        BSC_SYS_CALENDARS_B C
                      WHERE
                        K.TAB_ID = D.TAB_ID AND
                        K.INDICATOR = D.INDICATOR AND
                        K.PERIODICITY_ID = P.PERIODICITY_ID AND
                        P.CALENDAR_ID = C.CALENDAR_ID
                     )
                  WHERE
                    INDICATOR = x_indicator' ;

        h_bind_vars_values.delete;
        h_bind_vars_values(1) := x_indicator;
        h_num_bind_vars := 1;
        Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(
                X_Message => SQLERRM,
                X_Source => 'BSC_UPDATE_UTIL.Update_Kpi_Period_Name');
        RETURN FALSE;

END Update_Kpi_Period_Name;


/*===========================================================================+
| PROCEDURE Update_Kpi_Time_Stamp
+============================================================================*/
PROCEDURE Update_Kpi_Time_Stamp(
	x_indicator IN NUMBER
	) IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    /*
    h_sql := 'UPDATE bsc_kpis_b'||
             ' SET last_updated_by = :1,'||
             '     last_update_date = SYSDATE'||
             ' WHERE indicator = :2';

    h_bind_vars_values.delete;
    h_bind_vars_values(1) := h_user_id;
    h_bind_vars_values(2) := x_indicator;
    h_num_bind_vars := 2;
    Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
    */
    UPDATE bsc_kpis_b
    SET last_updated_by = h_user_id,
        last_update_date = SYSDATE
    WHERE indicator = x_indicator;

    --LOCKING: remove this commit
    --COMMIT;

END Update_Kpi_Time_Stamp;


/*===========================================================================+
| PROCEDURE Update_Kpi_Time_Stamp
+============================================================================*/
PROCEDURE Update_Kpi_Time_Stamp(
	x_condition IN VARCHAR2
	) IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    h_sessionid := USERENV('SESSIONID');

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    h_sql := 'UPDATE bsc_kpis_b'||
             ' SET last_updated_by = :1, last_update_date = SYSDATE'||
             ' WHERE '||x_condition;

    h_bind_vars_values.delete;
    h_bind_vars_values(1) := h_user_id;
    h_num_bind_vars := 1;
    Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

    --LOCKING: remove this commit
    --COMMIT;

END Update_Kpi_Time_Stamp;


/*===========================================================================+
| PROCEDURE Update_Kpi_Tab_Time_Stamp
+============================================================================*/
PROCEDURE Update_Kpi_Tab_Time_Stamp(
	x_indicator IN NUMBER
	) IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    h_sessionid := USERENV('SESSIONID');

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    /*
    h_sql := 'UPDATE bsc_tabs_b'||
             ' SET last_updated_by = :1,'||
             '     last_update_date = SYSDATE'||
             ' WHERE tab_id IN ('||
             '   SELECT tab_id'||
             '   FROM bsc_tab_indicators'||
             '   WHERE indicator = :2)';

    h_bind_vars_values.delete;
    h_bind_vars_values(1) := h_user_id;
    h_bind_vars_values(2) := x_indicator;
    h_num_bind_vars := 2;
    Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
    */
    UPDATE bsc_tabs_b
    SET last_updated_by = h_user_id,
        last_update_date = SYSDATE
    WHERE tab_id IN (
      SELECT tab_id
      FROM bsc_tab_indicators
      WHERE indicator = x_indicator);

    --LOCKING: remove this commit
    --COMMIT;

END Update_Kpi_Tab_Time_Stamp;


/*===========================================================================+
| PROCEDURE Update_Kpi_Tab_Time_Stamp
+============================================================================*/
PROCEDURE Update_Kpi_Tab_Time_Stamp(
	x_condition IN VARCHAR2
	) IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    h_sessionid := USERENV('SESSIONID');

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    h_sql := 'UPDATE bsc_tabs_b'||
             ' SET last_updated_by = :1, last_update_date = SYSDATE'||
             ' WHERE tab_id IN ('||
             ' SELECT tab_id'||
             ' FROM bsc_tab_indicators'||
             ' WHERE '||x_condition||')';

    h_bind_vars_values.delete;
    h_bind_vars_values(1) := h_user_id;
    h_num_bind_vars := 1;
    Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

    --LOCKING: remove this commit
    --COMMIT;

END Update_Kpi_Tab_Time_Stamp;


/*===========================================================================+
| PROCEDURE Update_Kpi_Table_Time_Stamp
+============================================================================*/
PROCEDURE Update_Kpi_Table_Time_Stamp(
	x_table_name IN VARCHAR2
	) IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

BEGIN
    h_sessionid := USERENV('SESSIONID');

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    /*
    h_sql := 'UPDATE bsc_kpis_b'||
             ' SET last_updated_by = :1,'||
             '     last_update_date = SYSDATE'||
             ' WHERE indicator IN ('||
             '   SELECT indicator'||
             '   FROM bsc_kpi_data_tables'||
             '   WHERE table_name = :2)';
    EXECUTE IMMEDIATE h_sql USING h_user_id, x_table_name;
    */

    UPDATE bsc_kpis_b
    SET last_updated_by = h_user_id,
        last_update_date = SYSDATE
    WHERE indicator IN (
      SELECT indicator
      FROM bsc_kpi_data_tables
      WHERE table_name = x_table_name);

    --LOCKING: remove this commit
    --COMMIT;

END Update_Kpi_Table_Time_Stamp;


/*===========================================================================+
| PROCEDURE Update_System_Time_Stamp
+============================================================================*/
PROCEDURE Update_System_Time_Stamp IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

    h_lock_property_code VARCHAR2(30);
BEGIN

    h_sessionid := USERENV('SESSIONID');
    h_lock_property_code := 'LOCK_SYSTEM';


    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    /*
    h_sql := 'UPDATE bsc_sys_init'||
             ' SET last_updated_by = :1,'||
             '     last_update_date = SYSDATE'||
             ' WHERE property_code = :2';
    EXECUTE IMMEDIATE h_sql USING h_user_id, h_lock_property_code;
    */
    UPDATE bsc_sys_init
    SET last_updated_by = h_user_id,
        last_update_date = SYSDATE
    WHERE property_code = h_lock_property_code;

    --LOCKING: remove this commit
    --COMMIT;

END Update_System_Time_Stamp;


/*===========================================================================+
| FUNCTION Verify_Custom_Periodicity
+============================================================================*/
FUNCTION Verify_Custom_Periodicity(
	x_calendar_id IN NUMBER,
	x_periodicity_id IN NUMBER,
	x_custom_code IN NUMBER
	)  RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    CURSOR c_missing_years (p_calendar_id NUMBER, p_periodicity_id NUMBER) IS
        SELECT DISTINCT c.year
        FROM bsc_db_calendar c, bsc_sys_periods p
        WHERE c.calendar_id = p_calendar_id AND p_periodicity_id = p.periodicity_id (+) AND
              c.year = p.year (+) AND p.year IS NULL;

    h_year NUMBER;

    CURSOR c_check_fy (p_periodicity_id NUMBER, p_calendar_id NUMBER) IS
        SELECT DISTINCT year
        FROM bsc_sys_periods
        WHERE periodicity_id = p_periodicity_id AND
              year = (SELECT fiscal_year
                      FROM bsc_sys_calendars_b
                      WHERE calendar_id = p_calendar_id);

    h_model_year NUMBER;

    CURSOR c_source_periodicity (p_periodicity_id NUMBER) IS
        SELECT DECODE(INSTR(source, ','), 0, source, SUBSTR(source, 1, INSTR(source, ',') - 1))
        FROM bsc_sys_periodicities
        WHERE periodicity_id = p_periodicity_id;

    h_source_periodicity NUMBER;

    h_db_column_name VARCHAR2(50);
    h_db_source_column_name VARCHAR2(50);

    h_sql VARCHAR2(32000);

    CURSOR c_feb_issue (p_periodicity_id NUMBER, p_year NUMBER, p_in1 NUMBER, p_in2 NUMBER) IS
         select p2.period_id, p2.start_date - p1.end_date as issue_type
         from bsc_sys_periods p1, bsc_sys_periods p2
         where p1.periodicity_id = p2.periodicity_id and
               p1.year = p2.year and p1.period_id = p2.period_id - 1 and
               p1.periodicity_id = p_periodicity_id and p1.year =  p_year and
               p2.start_date - p1.end_date IN (p_in1, p_in2);

    h_issue_type NUMBER;
    h_bad_period NUMBER;

    CURSOR c_fix_overlap_period (p_num1 NUMBER, p_periodicity_id NUMBER, p_year NUMBER, p_num2 NUMBER, p_num3 NUMBER) IS
        select period_id, abs(p_num1 - period_id) as distance
        from bsc_sys_periods
        where periodicity_id = p_periodicity_id and year = p_year and
              end_date - start_date > p_num2
        order by abs(p_num3 - period_id), period_id;

    h_fix_overlap_period NUMBER;
    h_distance NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    -- Check whether the current fical year exists in BSC_SYS_PERIODS
    -- If it exists, then it will be used as the model year.
    --OPEN c_check_fy FOR c_check_fy_sql USING x_periodicity_id, x_calendar_id;
    OPEN c_check_fy(x_periodicity_id, x_calendar_id);
    FETCH c_check_fy INTO h_model_year;
    IF c_check_fy%NOTFOUND THEN
        h_model_year := 0;
    END IF;
    CLOSE c_check_fy;

    -- Generate automatically information for missing years
    -- based on the information for the current fiscal year
    -- Note: the information for the current fiscal year
    --       MUST exist.
    --OPEN c_missing_years FOR c_missing_years_sql USING x_calendar_id, x_periodicity_id;
    OPEN c_missing_years(x_calendar_id, x_periodicity_id);
    FETCH c_missing_years INTO h_year;
    WHILE c_missing_years%FOUND LOOP
        -- Get the year to take as a model.
        -- Use the current fiscal year if it exists in BSC_SYS_PERIODS
        -- Otherwise, use the latest year for which there are records in BSC_SYS_PERIODS
        IF h_model_year = 0 THEN
            -- The current fiscal year does not exists in BSC_SYS_PERIODS, then
            -- we get the latest year.
            /*
            h_sql := 'SELECT MAX(year)'||
                     ' FROM bsc_sys_periods'||
                     ' WHERE periodicity_id = :1';
            OPEN h_cursor FOR h_sql USING x_periodicity_id;
            FETCH h_cursor INTO h_model_year;
            CLOSE h_cursor;
            */
            SELECT MAX(year)
            INTO h_model_year
            FROM bsc_sys_periods
            WHERE periodicity_id = x_periodicity_id;
        END IF;

        IF x_custom_code = 1 THEN
            -- Based on range of dates --> Use start_date and end_date
            /*
            h_sql := 'INSERT INTO bsc_sys_periods (
                          periodicity_id,
                          year,
                          period_id,
                          start_date,
                          end_date,
                          start_period,
                          end_period,
                          created_by,
                          creation_date,
                          last_updated_by,
                          last_update_date,
                          last_update_login)
                      SELECT
                          p.periodicity_id,
                          :1,
                          p.period_id,
                          add_months(p.start_date, 12*(:2 - :3)),
                          add_months(p.end_date, 12*(:4 - :5)),
                          p.start_period,
                          p.end_period,
                          p.created_by,
                          sysdate,
                          p.last_updated_by,
                          sysdate,
                          p.last_update_login
                      FROM
                          bsc_sys_periods p
                      WHERE
                          periodicity_id = :6 AND
                          year = :7';

            h_bind_vars_values.delete;
            h_bind_vars_values(1) := h_year;
            h_bind_vars_values(2) := h_year;
            h_bind_vars_values(3) := h_model_year;
            h_bind_vars_values(4) := h_year;
            h_bind_vars_values(5) := h_model_year;
            h_bind_vars_values(6) := x_periodicity_id;
            h_bind_vars_values(7) := h_model_year;
            h_num_bind_vars := 7;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
            */
            INSERT INTO bsc_sys_periods (
              periodicity_id,
              year,
              period_id,
              start_date,
              end_date,
              start_period,
              end_period,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login)
            SELECT
              p.periodicity_id,
              h_year,
              p.period_id,
              add_months(p.start_date, 12*(h_year - h_model_year)),
              add_months(p.end_date, 12*(h_year - h_model_year)),
              p.start_period,
              p.end_period,
              p.created_by,
              sysdate,
              p.last_updated_by,
              sysdate,
              p.last_update_login
            FROM
              bsc_sys_periods p
            WHERE
              periodicity_id = x_periodicity_id AND
              year = h_model_year;


            -- Fix the issue with FEB-28 AND FEB-29
            -- This issue coul happen because the function add_months in the previous query
            -- can automatically convert FEB-28 in FEB-29 or FEB-29 in FEB-28
            -- This can generate (rare cases but they could happen) two kind of issues:
            -- Example1:
            --     Base year 1998:
            --     START_DATE  END_DATE
            --     01-FEB-1998 27-FEB-1998
            --     28-FEB-1998 28-FEB-1998
            --     Records for 1999 resulting in:
            --     START_DATE  END_DATE
            --     01-FEB-1999 27-FEB-1999
            --     29-FEB-1999 29-FEB-1999  (Wrong!! There is a hole)
            -- Example2:
            --     Base year 1999:
            --     START_DATE  END_DATE
            --     01-FEB-1999 28-FEB-1999
            --     29-FEB-1999 29-FEB-1999
            --     Records for 1998 resulting in:
            --     START_DATE  END_DATE
            --     01-FEB-1998 28-FEB-1998
            --     28-FEB-1998 28-FEB-1998  (Wrong!! There is a overlap)
            -- Note: I have identified that the issue could happen (not always) when in
            --       the base year appears FEB-28 or FEB-29 as START_DATE.
            --       There is no issue when FEB-28 or FEB-29 are use as END_DATE: Let's see:
            --       One case: Look no 28 or 29 as START_DATE
            --       26 26          26 26
            --       27 28   ---->  27 29   Works!!
            --       01 01          01 01
            --       The other case: Look no 28 or 29 as START_DATE
            --       26 26          26 26
            --       27 29   ---->  27 28   Works!!
            --       01 01          01 01

            --Find the issue:
            --  We know that only is possible to find ONE issue:
            --  Overlaping: Type issue = 0
            --  Hole: Type issue = 2
            --OPEN c_feb_issue FOR c_feb_issue_sql USING x_periodicity_id, h_year, 0, 2;
            OPEN c_feb_issue(x_periodicity_id, h_year, 0, 2);
            FETCH c_feb_issue INTO h_bad_period, h_issue_type;
            IF c_feb_issue%FOUND THEN
                IF h_issue_type = 0 THEN
                    -- Overlap

                    -- Find the closest period to the period where the issue was found
                    -- to define the range of affected periods to fix the problem.
                    --OPEN c_fix_overlap_period FOR c_fix_overlap_period_sql
                    --USING h_bad_period, x_periodicity_id, h_year, 0, h_bad_period;
                    OPEN c_fix_overlap_period(h_bad_period, x_periodicity_id, h_year, 0, h_bad_period);
                    FETCH c_fix_overlap_period INTO h_fix_overlap_period, h_distance;
                    IF c_fix_overlap_period%FOUND THEN
                        IF h_fix_overlap_period < h_bad_period THEN
                            /*
                            h_sql := 'update bsc_sys_periods'||
                                     ' set'||
                                     '   start_date = DECODE(period_id, :1, start_date, start_date-1),'||
                                     '   end_date = end_date-1'||
                                     ' where'||
                                     '   periodicity_id = :2 and'||
                                     '   year = :3 and'||
                                     '   period_id < :4 and'||
                                     '   period_id >= :5';

                            h_bind_vars_values.delete;
                            h_bind_vars_values(1) := h_fix_overlap_period;
                            h_bind_vars_values(2) := x_periodicity_id;
                            h_bind_vars_values(3) := h_year;
                            h_bind_vars_values(4) := h_bad_period;
                            h_bind_vars_values(5) := h_fix_overlap_period;
                            h_num_bind_vars := 5;
                            Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                            */
                            update bsc_sys_periods
                            set start_date = DECODE(period_id, h_fix_overlap_period, start_date, start_date-1),
                                end_date = end_date-1
                            where periodicity_id = x_periodicity_id and
                                  year = h_year and
                                  period_id < h_bad_period and
                                  period_id >= h_fix_overlap_period;

                        ELSE
                            /*
                            h_sql := 'update bsc_sys_periods'||
                                     ' set'||
                                     '   start_date = start_date+1,'||
                                     '   end_date = DECODE(period_id, :1, end_date, end_date+1)'||
                                     ' where'||
                                     '   periodicity_id = :2 and'||
                                     '   year = :3 and'||
                                     '   period_id <= :4 and'||
                                     '   period_id >= :5';

                            h_bind_vars_values.delete;
                            h_bind_vars_values(1) := h_fix_overlap_period;
                            h_bind_vars_values(2) := x_periodicity_id;
                            h_bind_vars_values(3) := h_year;
                            h_bind_vars_values(4) := h_fix_overlap_period;
                            h_bind_vars_values(5) := h_bad_period;
                            h_num_bind_vars := 5;
                            Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                            */
                            update bsc_sys_periods
                            set start_date = start_date+1,
                                end_date = DECODE(period_id, h_fix_overlap_period, end_date, end_date+1)
                            where periodicity_id = x_periodicity_id and
                                  year = h_year and
                                  period_id <= h_fix_overlap_period and
                                  period_id >= h_bad_period;

                        END IF;
                    END IF;
                    CLOSE c_fix_overlap_period;
                END IF;

                IF h_issue_type = 2 THEN
                    --Hole
                    /*
                    h_sql := 'update bsc_sys_periods'||
                             ' set start_date = start_date - 1'||
                             ' where periodicity_id = :1 and'||
                             '       year = :2 and period_id = :3';

                    h_bind_vars_values.delete;
                    h_bind_vars_values(1) := x_periodicity_id;
                    h_bind_vars_values(2) := h_year;
                    h_bind_vars_values(3) := h_bad_period;
                    h_num_bind_vars := 3;
                    Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                    */
                    update bsc_sys_periods
                    set start_date = start_date - 1
                    where periodicity_id = x_periodicity_id and
                          year = h_year and
                          period_id = h_bad_period;
                END IF;
            END IF;
            CLOSE c_feb_issue;

        ELSE
            -- Based on other periodicity --> Use start_period and end_period
            /*
            h_sql := 'INSERT INTO bsc_sys_periods (
                          periodicity_id,
                          year,
                          period_id,
                          start_date,
                          end_date,
                          start_period,
                          end_period,
                          created_by,
                          creation_date,
                          last_updated_by,
                          last_update_date,
                          last_update_login)
                      SELECT
                          p.periodicity_id,
                          :1,
                          p.period_id,
                          p.start_date,
                          p.end_date,
                          p.start_period,
                          p.end_period,
                          p.created_by,
                          sysdate,
                          p.last_updated_by,
                          sysdate,
                          p.last_update_login
                      FROM
                          bsc_sys_periods p
                      WHERE
                          periodicity_id = :2 AND
                          year = :3';

            h_bind_vars_values.delete;
            h_bind_vars_values(1) := h_year;
            h_bind_vars_values(2) := x_periodicity_id;
            h_bind_vars_values(3) := h_model_year;
            h_num_bind_vars := 3;
            Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
            */
            INSERT INTO bsc_sys_periods (
              periodicity_id,
              year,
              period_id,
              start_date,
              end_date,
              start_period,
              end_period,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login)
            SELECT
              p.periodicity_id,
              h_year,
              p.period_id,
              p.start_date,
              p.end_date,
              p.start_period,
              p.end_period,
              p.created_by,
              sysdate,
              p.last_updated_by,
              sysdate,
              p.last_update_login
            FROM
              bsc_sys_periods p
            WHERE
              periodicity_id = x_periodicity_id AND
              year = h_model_year;

        END IF;
        FETCH c_missing_years INTO h_year;
    END LOOP;
    CLOSE c_missing_years;

    -- Update the corresponding column in BSC_DB_CALENDAR for this periodicity
    h_db_column_name := Get_Calendar_Table_Col_Name(x_periodicity_id);

    IF x_custom_code = 1 THEN
        -- Based on range of dates --> Use start_date and end_date
        h_sql := 'UPDATE
                      bsc_db_calendar d
                  SET '||h_db_column_name||' = (
                      SELECT
                          p.period_id
                      FROM
                          bsc_sys_periods p
                      WHERE
                          p.periodicity_id = :1 AND
                          p.year = d.year AND
                          TO_DATE(d.calendar_year||''-''||d.calendar_month||''-''||d.calendar_day, ''YYYY-MM-DD'')
                          BETWEEN p.start_date AND p.end_date
                    )
                  WHERE
                      d.calendar_id = :2';

        h_bind_vars_values.delete;
        h_bind_vars_values(1) := x_periodicity_id;
        h_bind_vars_values(2) := x_calendar_id;
        h_num_bind_vars := 2;
        Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

    ELSE
        -- Based on other periodicity --> Use start_period and end_period
        --OPEN c_source_periodicity FOR c_source_periodicity_sql USING x_periodicity_id;
        OPEN c_source_periodicity(x_periodicity_id);
        FETCH c_source_periodicity INTO h_source_periodicity;
        CLOSE c_source_periodicity;

        IF h_source_periodicity IS NOT NULL THEN
            h_db_source_column_name := Get_Calendar_Table_Col_Name(h_source_periodicity);

            h_sql := 'UPDATE
                          bsc_db_calendar d
                      SET '||h_db_column_name||' = (
                          SELECT
                              p.period_id
                          FROM
                              bsc_sys_periods p
                          WHERE
                              p.periodicity_id = :1 AND
                              p.year = d.year AND
                              d.'||h_db_source_column_name||' BETWEEN p.start_period AND p.end_period
                        )
                      WHERE
                          d.calendar_id = :2';

            h_bind_vars_values.delete;
            h_bind_vars_values(1) := x_periodicity_id;
            h_bind_vars_values(2) := x_calendar_id;
            h_num_bind_vars := 2;
            Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);

       END IF;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Verify_Custom_Periodicity');
        RETURN FALSE;
END Verify_Custom_Periodicity;


/*===========================================================================+
| FUNCTION Write_Init_Variable_Value
+============================================================================*/
FUNCTION Write_Init_Variable_Value(
	x_variable_name IN VARCHAR2,
	x_variable_value IN VARCHAR2
	) RETURN BOOLEAN IS

    h_user_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    h_sessionid NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN
    h_sessionid := USERENV('SESSIONID');

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    h_user_id := BSC_APPS.fnd_global_user_id;

    /*
    h_sql := 'UPDATE bsc_sys_init'||
             ' SET property_value = :1,'||
             '     last_updated_by = :2,'||
             '     last_update_date = SYSDATE'||
             ' WHERE property_code = :3';
    EXECUTE IMMEDIATE h_sql USING x_variable_value, h_user_id, x_variable_name;
    */
    UPDATE bsc_sys_init
    SET property_value = x_variable_value,
        last_updated_by = h_user_id,
        last_update_date = SYSDATE
    WHERE property_code = x_variable_name;

    IF SQL%NOTFOUND THEN
        /*
        h_sql := 'INSERT INTO bsc_sys_init (property_code, property_value,'||
                 ' created_by, creation_date, last_updated_by, last_update_date)'||
                 ' VALUES (:1, :2, :3, SYSDATE, :4 , SYSDATE)';
        EXECUTE IMMEDIATE h_sql USING x_variable_name, x_variable_value, h_user_id, h_user_id;
        */
        INSERT INTO bsc_sys_init (property_code, property_value,
          created_by, creation_date, last_updated_by, last_update_date)
        VALUES (x_variable_name, x_variable_value, h_user_id, SYSDATE, h_user_id , SYSDATE);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.Write_Init_Variable_Value');
        RETURN FALSE;

END Write_Init_Variable_Value;

function is_parallel return boolean is
Begin
  --Enable parallel
  if g_parallel is null then
    g_parallel:=true;
  end if;
   g_parallel:=true;
  return g_parallel;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_UTIL.is_parallel');
        RETURN FALSE;
END is_parallel;


/*******************************************************************************
********************************************************************************/
FUNCTION get_Product_Version
(
    p_Product           IN          VARCHAR2
) RETURN VARCHAR2
IS
    l_variable     BSC_SYS_INIT.Property_Code%TYPE;
    l_version      BSC_SYS_INIT.Property_Value%TYPE;
BEGIN
    l_variable :=  NULL;
    l_version  :=  NULL;

    IF (p_Product = BSC_UPDATE_UTIL.G_BIA) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_BIA_PATCH;
    ELSIF (p_Product = BSC_UPDATE_UTIL.G_PMF) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_PMF_PATCH;
    ELSIF (p_Product = BSC_UPDATE_UTIL.G_PMV) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_PMV_PATCH;
    ELSIF (p_Product = BSC_UPDATE_UTIL.G_BSC) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_BSC_PATCH;
    END IF;
    IF (BSC_UPDATE_UTIL.Get_Init_Variable_Value(
            x_variable_name   =>  l_variable
         ,  x_variable_value  =>  l_version)) THEN
        RETURN l_version;
    ELSE
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add
        (  x_message => SQLERRM
         , x_source  => 'BSC_UPDATE_UTIL.get_Product_Version'
        );
        RETURN NULL;
END get_Product_Version;

/*******************************************************************************
********************************************************************************/
FUNCTION set_Product_Version
(
        p_Product           IN          VARCHAR2
    ,   p_Version           IN          VARCHAR2
) RETURN BOOLEAN
IS
    l_variable     BSC_SYS_INIT.Property_Code%TYPE;
BEGIN
    l_variable := NULL;

    IF (p_Product = BSC_UPDATE_UTIL.G_BIA) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_BIA_PATCH;
    ELSIF (p_Product = BSC_UPDATE_UTIL.G_PMF) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_PMF_PATCH;
    ELSIF (p_Product = BSC_UPDATE_UTIL.G_PMV) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_PMV_PATCH;
    ELSIF (p_Product = BSC_UPDATE_UTIL.G_BSC) THEN
        l_variable  :=  BSC_UPDATE_UTIL.G_BSC_PATCH;
    END IF;
    IF(l_variable IS NOT NULL) THEN
        RETURN BSC_UPDATE_UTIL.Write_Init_Variable_Value
               (    x_variable_name     =>  l_variable
                  , x_variable_value    =>  p_Version
               );
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add
        (  x_message => SQLERRM
         , x_source  => 'BSC_UPDATE_UTIL.set_Product_Version'
        );
        RETURN FALSE;
END set_Product_Version;


-- AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Is_Table_For_AW_Kpi
+============================================================================*/
FUNCTION Is_Table_For_AW_Kpi(
	x_table_name IN VARCHAR2
	) RETURN BOOLEAN IS
    h_count NUMBER;
    h_aw_kpi_type NUMBER;
    h_aw_impl_type_name VARCHAR2(100);
BEGIN
    h_count := 0;
    h_aw_impl_type_name := 'IMPLEMENTATION_TYPE';
    h_aw_kpi_type := 2;

    select count(table_name)
    into h_count
    from (
        select distinct table_name
        from bsc_db_tables_rels
        start with table_name in (
            select distinct kd.table_name
            from bsc_kpi_data_tables kd, bsc_kpi_properties k
            where k.indicator = kd.indicator and
                  k.property_code = h_aw_impl_type_name and
                  k.property_value = h_aw_kpi_type and
                  kd.table_name is not null
        )
        connect by table_name = prior source_table_name
    )
    where table_name = x_table_name;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_Table_For_AW_Kpi;


-- AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Get_Kpi_Impl_Type
+============================================================================*/
FUNCTION Get_Kpi_Impl_Type(
    x_kpi IN NUMBER
) RETURN NUMBER IS

    CURSOR c_impl_type (p_kpi NUMBER, p_prop_code VARCHAR2) IS
        select property_value
        from bsc_kpi_properties
        where indicator = p_kpi and property_code = p_prop_code;

    h_impl_type NUMBER;
    h_impl_type_name VARCHAR2(100);

BEGIN
    h_impl_type_name := 'IMPLEMENTATION_TYPE';

    OPEN c_impl_type(x_kpi, h_impl_type_name);
    FETCH c_impl_type INTO h_impl_type;
    IF c_impl_type%NOTFOUND THEN
        h_impl_type := 1;
    END IF;
    CLOSE c_impl_type;

    RETURN h_impl_type;

END Get_Kpi_Impl_Type;


-- AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Exists_AW_Kpi
+============================================================================*/
FUNCTION Exists_AW_Kpi RETURN BOOLEAN IS
    h_count NUMBER;
    h_aw_kpi_type NUMBER;
    h_aw_impl_type_name VARCHAR2(100);
BEGIN
    h_count := 0;
    h_aw_impl_type_name := 'IMPLEMENTATION_TYPE';
    h_aw_kpi_type := 2;

    select count(k.indicator)
    into h_count
    from bsc_kpis_b k, bsc_kpi_properties p
    where k.indicator = p.indicator and
          k.prototype_flag in (0,6,7) and
          p.property_code = h_aw_impl_type_name and
          p.property_value = h_aw_kpi_type;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Exists_AW_Kpi;


-- AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Calendar_Used_In_AW_Kpi
+============================================================================*/
FUNCTION Calendar_Used_In_AW_Kpi(
	x_calendar_id IN VARCHAR2
	) RETURN BOOLEAN IS
    h_count NUMBER;
    h_aw_impl_type NUMBER;
    h_aw_impl_type_name VARCHAR2(100);
BEGIN
    h_count := 0;
    h_aw_impl_type_name := 'IMPLEMENTATION_TYPE';
    h_aw_impl_type := 2;

    select count(k.calendar_id)
    into h_count
    from bsc_kpis_vl k, bsc_kpi_properties p
    where k.indicator = p.indicator and
    k.calendar_id = x_calendar_id and
    k.prototype_flag in (0,6,7) and
    p.property_code = h_aw_impl_type_name and
    p.property_value = h_aw_impl_type;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Calendar_Used_In_AW_Kpi;


PROCEDURE Get_Kpi_Dim_Props (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER
, x_dim_props_rec   OUT NOCOPY BSC_UPDATE_UTIL.t_kpi_dim_props_rec
)
IS
  CURSOR c_dim_props(p_indicator NUMBER, p_kpi_measure_id NUMBER) IS
    SELECT ds.dim_set_id dim_set_id,
           kpi_dim.level_pk_col comp_level_pk_col
      FROM bsc_db_dataset_dim_sets_v ds,
           bsc_kpi_dim_levels_vl kpi_dim
      WHERE ds.indicator = kpi_dim.indicator(+)
      AND   ds.dim_set_id = kpi_dim.dim_set_id(+)
      AND   kpi_dim.default_value(+) = 'C'
      AND   ds.kpi_measure_id = p_kpi_measure_id
      AND   ds.indicator = p_indicator;
  l_dim_props  c_dim_props%ROWTYPE;

BEGIN

  IF c_dim_props%ISOPEN THEN
    CLOSE c_dim_props;
  END IF;
  OPEN c_dim_props (p_objective_id, p_kpi_measure_id);
  FETCH c_dim_props INTO l_dim_props;
  IF c_dim_props%FOUND THEN

    x_dim_props_rec.dim_set_id        := l_dim_props.dim_set_id;
    x_dim_props_rec.comp_level_pk_col := l_dim_props.comp_level_pk_col;

  END IF;
  CLOSE c_dim_props;

EXCEPTION
  WHEN OTHERS THEN
    IF c_dim_props%ISOPEN THEN
      CLOSE c_dim_props;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.Get_Kpi_Dim_Props');
    RAISE;
END Get_Kpi_Dim_Props;


FUNCTION get_kpi_measure_formula (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER
)
RETURN VARCHAR2 IS
  CURSOR c_measure_formula(p_indicator NUMBER, p_kpi_measure_id NUMBER) IS
    SELECT m1.operation || '(' ||
           NVL(BSC_APPS.Get_Property_Value(m1.s_color_formula, 'pFormulaSource'), m1.measure_col) || ')' ||
           ds.operation ||
           DECODE(ds.measure_id2,
                  NULL, NULL,
                  m2.operation || '(' || NVL(BSC_APPS.Get_Property_Value(m2.s_color_formula, 'pFormulaSource'), m2.measure_col) || ')' ) measure_formula
      FROM bsc_tab_indicators tab_ind,
           bsc_kpi_analysis_measures_b anal_meas,
           bsc_sys_datasets_b ds,
           bsc_sys_measures m1,
           bsc_sys_measures m2,
           bsc_kpis_b obj
      WHERE anal_meas.dataset_id = ds.dataset_id
      AND   ds.measure_id1 = m1.measure_id
      AND   NVL(ds.measure_id2, ds.measure_id1) = m2.measure_id
      AND   obj.indicator = anal_meas.indicator
      AND   tab_ind.indicator = obj.indicator
      AND   anal_meas.kpi_measure_id = p_kpi_measure_id
      AND   obj.indicator = p_indicator;

  l_measure_formula  VARCHAR2(4000);

BEGIN

  IF c_measure_formula%ISOPEN THEN
    CLOSE c_measure_formula;
  END IF;
  OPEN c_measure_formula (p_objective_id, p_kpi_measure_id);
  FETCH c_measure_formula INTO l_measure_formula;
  IF c_measure_formula%NOTFOUND THEN
    RETURN NULL;
  END IF;
  CLOSE c_measure_formula;

  RETURN l_measure_formula;

EXCEPTION
  WHEN OTHERS THEN
    IF c_measure_formula%ISOPEN THEN
      CLOSE c_measure_formula;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.get_kpi_measure_formula');
    RETURN NULL;
END get_kpi_measure_formula;


FUNCTION Get_SimObj_Color_Formula
( p_objective_id    IN  NUMBER
, p_kpi_measure_id  IN  NUMBER
)
RETURN VARCHAR2
IS
  CURSOR c_kpi_source(p_indicator NUMBER, p_kpi_measure NUMBER) IS
    SELECT ind.measure_type source,
           dts.dataset_id
      FROM bsc_sys_datasets_b dts,
           bis_indicators ind,
           bsc_kpi_analysis_measures_b am
      WHERE dts.dataset_id = am.dataset_id
      AND   dts.dataset_id = ind.dataset_id
      AND   am.indicator = p_indicator
      AND   am.kpi_measure_id = p_kpi_measure;
  l_kpi_source_rec  c_kpi_source%ROWTYPE;

  l_source                   bsc_sys_datasets_b.source%TYPE;
  l_default_node_dataset_id  bsc_sys_datasets_b.dataset_id%TYPE;
  l_measure_formula          VARCHAR2(4000);

BEGIN

  l_measure_formula := NULL;

  FOR l_kpi_source_rec IN c_kpi_source(p_objective_id, p_kpi_measure_id) LOOP
      -- Ideally only 1 row must be returned since duplicate datasets are not allowed in Simulation Objective
      l_source := l_kpi_source_rec.source;
      l_default_node_dataset_id := l_kpi_source_rec.dataset_id;
  END LOOP;

  IF l_source = BSC_SIMULATION_VIEW_PUB.c_CALCULATED_KPI THEN

     l_measure_formula := BSC_SIMULATION_VIEW_PUB.Get_Kpi_MeasureCol(l_default_node_dataset_id);

     l_measure_formula := BSC_SIMULATION_VIEW_PUB.Get_Formula_Base_Columns ( p_indicator  => p_objective_id
                                                                           , p_dataset_id => l_default_node_dataset_id
                                                                           , p_meas_col   => l_measure_formula
                                                                           );

  ELSE
    l_measure_formula := get_kpi_measure_formula ( p_objective_id   => p_objective_id
                                                 , p_kpi_measure_id => p_kpi_measure_id
                                                 );
  END IF;

  RETURN l_measure_formula;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.Get_SimObj_Color_Formula');
    RETURN NULL;
END Get_SimObj_Color_Formula;


FUNCTION Get_Measure_Formula (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER  := NULL
, p_sim_objective   IN BOOLEAN := FALSE
)
RETURN VARCHAR2 IS
  l_measure_formula  VARCHAR2(4000);
BEGIN

  IF NOT p_sim_objective THEN

    l_measure_formula :=  get_kpi_measure_formula ( p_objective_id   => p_objective_id
                                                  , p_kpi_measure_id => p_kpi_measure_id
                                                  );

  ELSE

    l_measure_formula :=  Get_SimObj_Color_Formula ( p_objective_id   => p_objective_id
                                                   , p_kpi_measure_id => p_kpi_measure_id
                                                   );

  END IF;

  RETURN l_measure_formula;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.Get_Measure_Formula');
    RETURN NULL;
END Get_Measure_Formula;


FUNCTION Get_Color_By_Total (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER  := NULL
)
RETURN NUMBER IS

  CURSOR c_color_by_total(p_indicator NUMBER, p_kpi_measure_id NUMBER) IS
    SELECT color_by_total
      FROM bsc_kpi_measure_props
      WHERE indicator = p_indicator
      AND kpi_measure_id = p_kpi_measure_id;

  l_color_by_total  bsc_kpi_measure_props.color_by_total%TYPE;

BEGIN

  l_color_by_total := 1;

  IF c_color_by_total%ISOPEN THEN
    CLOSE c_color_by_total;
  END IF;
  OPEN c_color_by_total (p_objective_id, p_kpi_measure_id);
  FETCH c_color_by_total INTO l_color_by_total;
  IF c_color_by_total%NOTFOUND THEN
    l_color_by_total := 1;
  END IF;
  CLOSE c_color_by_total;

  RETURN l_color_by_total;

EXCEPTION
  WHEN OTHERS THEN
    IF c_color_by_total%ISOPEN THEN
      CLOSE c_color_by_total;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.Get_Color_By_Total');
    RETURN NULL;
END Get_Color_By_Total;


FUNCTION get_ytd_flag (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER
)
RETURN NUMBER IS

  CURSOR c_ytd_flag(p_indicator  NUMBER, p_kpi_measure NUMBER) IS
    SELECT COUNT(default_calculation) ytd_flag
    FROM bsc_kpi_measure_props
    WHERE default_calculation = 2
    AND   kpi_measure_id = p_kpi_measure
    AND   indicator = p_indicator;

  l_ytd_flag                NUMBER;

BEGIN

  l_ytd_flag := 0;

  IF c_ytd_flag%ISOPEN THEN
    CLOSE c_ytd_flag;
  END IF;
  OPEN c_ytd_flag(p_objective_id, p_kpi_measure_id);
  FETCH c_ytd_flag INTO l_ytd_flag;
  IF c_ytd_flag%NOTFOUND THEN
    l_ytd_flag := 0;
  END IF;
  CLOSE c_ytd_flag;

  RETURN l_ytd_flag;

EXCEPTION
  WHEN OTHERS THEN
    IF c_ytd_flag%ISOPEN THEN
      CLOSE c_ytd_flag;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.get_ytd_flag');
    RETURN l_ytd_flag;
END get_ytd_flag;


FUNCTION Get_Apply_Color_Flag (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER  := NULL
)
RETURN NUMBER IS

  CURSOR c_apply_color_flag(p_indicator NUMBER, p_kpi_measure_id NUMBER) IS
    SELECT apply_color_flag
      FROM bsc_kpi_measure_props
      WHERE indicator = p_indicator
      AND kpi_measure_id = p_kpi_measure_id;

  l_apply_color_flag  bsc_kpi_measure_props.apply_color_flag%TYPE;

BEGIN

  l_apply_color_flag := 0;

  IF c_apply_color_flag%ISOPEN THEN
    CLOSE c_apply_color_flag;
  END IF;
  OPEN c_apply_color_flag (p_objective_id, p_kpi_measure_id);
  FETCH c_apply_color_flag INTO l_apply_color_flag;
  IF c_apply_color_flag%NOTFOUND THEN
    l_apply_color_flag := 0;
  END IF;
  CLOSE c_apply_color_flag;

  RETURN l_apply_color_flag;

EXCEPTION
  WHEN OTHERS THEN
    IF c_apply_color_flag%ISOPEN THEN
      CLOSE c_apply_color_flag;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_UTIL.Get_Apply_Color_Flag');
    RETURN NULL;
END Get_Apply_Color_Flag;


END BSC_UPDATE_UTIL;

/
