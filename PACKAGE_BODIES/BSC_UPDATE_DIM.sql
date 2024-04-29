--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_DIM" AS
/* $Header: BSCDDIMB.pls 120.16.12010000.2 2008/08/11 09:33:25 sirukull ship $ */

/*===========================================================================+
| FUNCTION Any_Item_Changed_Any_Relation
+============================================================================*/
FUNCTION Any_Item_Changed_Any_Relation(
	x_dimension_table IN VARCHAR2,
        x_temp_table IN VARCHAR2,
        x_relation_cols IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_relation_cols IN NUMBER
        ) RETURN BOOLEAN IS

    h_i NUMBER;
    h_res BOOLEAN;

    h_cond VARCHAR2(32700);
    h_sql VARCHAR2(32700);
    h_code NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

BEGIN

    h_res := FALSE;
    h_cond := NULL;

    FOR h_i IN 1..x_num_relation_cols LOOP
        IF h_cond IS NULL THEN
            h_cond := 'd.'||x_relation_cols(h_i)||' <> t.'||x_relation_cols(h_i);
        ELSE
            h_cond := h_cond||' OR d.'||x_relation_cols(h_i)||' <> t.'||x_relation_cols(h_i);
        END IF;
    END LOOP;

    h_sql := 'SELECT d.code'||
             ' FROM '||x_dimension_table||' d, '||x_temp_table||' t'||
             ' WHERE d.code = t.code AND ('||h_cond||')';

    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_code;
    IF h_cursor%FOUND THEN
        h_res := TRUE;
    END IF;
    CLOSE h_cursor;

    RETURN h_res;

END Any_Item_Changed_Any_Relation;


/*===========================================================================+
| FUNCTION Create_Dbi_Dim_Tables
+============================================================================*/
FUNCTION Create_Dbi_Dim_Tables(
	x_error_msg IN OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN IS

    l_sql VARCHAR2(32000);
    l_i NUMBER;
    l_count NUMBER;

    l_table_name VARCHAR2(50);
    l_index_name VARCHAR2(50);
    l_constraint_name VARCHAR2(50);
    l_short_name VARCHAR2(50);
    l_table_owner VARCHAR2(50);
    l_date_tracked_dim VARCHAR2(5);

    l_parent_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_src_parent_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_parent_columns NUMBER;

    l_lst_parent_cols VARCHAR2(8000);
    l_lst_cols_desc VARCHAR2(8000);
    l_col_already_indexed      EXCEPTION;
    PRAGMA EXCEPTION_INIT(l_col_already_indexed, -01408);

BEGIN
    --Fix bug#4600154: create tables/indexes in summary table/index tablespace instead of dimension table/index tablespace.

    IF g_dbi_dim_tables_set THEN
        RETURN TRUE;
    END IF;

    BSC_APPS.Init_Bsc_Apps;
    Init_Dbi_Dim_Data;

    l_table_owner := UPPER(BSC_APPS.bsc_apps_schema);

    FOR l_i IN 1..g_dbi_dim_data.COUNT LOOP
        l_table_name := g_dbi_dim_data(l_i).table_name;
        l_short_name := g_dbi_dim_data(l_i).short_name;
        l_date_tracked_dim := g_dbi_dim_data(l_i).date_tracked_dim;

        IF l_table_name IS NOT NULL THEN
            -- Get list of parents
            l_num_parent_columns := Get_Dbi_Dim_Parent_Columns(l_short_name,
                                                               l_parent_columns,
                                                               l_src_parent_columns);


            l_lst_cols_desc := 'USER_CODE VARCHAR2(400),CODE VARCHAR2(400)';
            IF l_num_parent_columns > 0 THEN
                l_lst_cols_desc := l_lst_cols_desc||', '||
                                   BSC_UPDATE_UTIL.Make_Lst_Description(l_parent_columns, l_num_parent_columns, 'VARCHAR2(400)');
            END IF;
            IF l_date_tracked_dim = 'YES' THEN
                l_lst_cols_desc := l_lst_cols_desc||', EFFECTIVE_START_DATE DATE, EFFECTIVE_END_DATE DATE';
            END IF;

            --remove
            --if not BSC_UPDATE_UTIL.Drop_Table(l_table_name) then
              --null;
            --end if;
            -- Create the table, if it does not exists
            IF NOT BSC_APPS.Table_Exists(l_table_name) THEN
                l_sql := 'CREATE TABLE '||l_table_name||' ('||l_lst_cols_desc||')'||
                         ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_table_tbs_type)||
                         ' '||BSC_APPS.bsc_storage_clause;
                if bsc_im_utils.g_debug then
                  write_to_log_file_n(l_sql);
                end if;
                BSC_APPS.Do_DDL(l_sql, AD_DDL.CREATE_TABLE, l_table_name);
            END IF;

            -- Create the mv log
            SELECT COUNT(1) INTO l_count
            FROM all_snapshot_logs
            WHERE master = l_table_name AND log_owner = l_table_owner;
            IF l_count = 0 THEN
                -- mv log does ot exists

                -- Create PK
                SELECT COUNT(1) INTO l_count
                FROM all_constraints
                WHERE owner = l_table_owner AND constraint_type = 'P' AND table_name = l_table_name;
                IF l_count = 0 THEN
                    -- PK does not exists
                    l_constraint_name := substr(l_table_name,1,29)||'P';
                    l_sql := 'ALTER TABLE '||l_table_name||
                             ' ADD CONSTRAINT '||l_constraint_name||' PRIMARY KEY(USER_CODE) RELY ENABLE NOVALIDATE';
                    if bsc_im_utils.g_debug then
                      write_to_log_file_n(l_sql);
                    end if;
                    BSC_APPS.Do_DDL(l_sql, AD_DDL.ALTER_TABLE, l_table_name);
                END IF;

                -- Create mv log
                l_sql := 'CREATE MATERIALIZED VIEW LOG ON '||l_table_owner||'.'||l_table_name||
                         ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_table_tbs_type)||
                         ' '||BSC_APPS.bsc_storage_clause||' WITH';
                IF BSC_IM_UTILS.get_db_version = '9i' THEN
                    l_sql := l_sql||' SEQUENCE,';
                END IF;
                l_sql := l_sql||' PRIMARY KEY, ROWID(CODE';
                IF l_num_parent_columns > 0 THEN
                    l_sql := l_sql||','||BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(l_parent_columns, l_num_parent_columns);
                END IF;
                l_sql := l_sql||')';
                l_sql := l_sql||' INCLUDING NEW VALUES';
                if bsc_im_utils.g_debug then
                  write_to_log_file_n(l_sql);
                end if;
                EXECUTE IMMEDIATE l_sql;
            END IF;
            -- Create the Unique Index
            l_index_name := substr(l_table_name,1,29)||'U';
            IF NOT BSC_APPS.Index_Exists(l_index_name) THEN
                l_sql := 'CREATE UNIQUE INDEX '||l_index_name||
                         ' ON '||l_table_name||' (USER_CODE)'||
                         ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_index_tbs_type)||
                         ' '||BSC_APPS.bsc_storage_clause;
                if bsc_im_utils.g_debug then
                  write_to_log_file_n(l_sql);
                end if;
                begin
                  BSC_APPS.Do_DDL(l_sql, AD_DDL.CREATE_INDEX, l_index_name);
                exception
                when l_col_already_indexed then
                  null;
                end;
            END IF;
        END IF;

        -- Create denorm table for recursive dimensions
        l_table_name := g_dbi_dim_data(l_i).denorm_table;
        IF (g_dbi_dim_data(l_i).recursive_dim = 'YES') AND (l_table_name IS NOT NULL) THEN
            l_lst_cols_desc := g_dbi_dim_data(l_i).parent_col||' VARCHAR2(400), '||
                               g_dbi_dim_data(l_i).child_col||' VARCHAR2(400), '||
                               g_dbi_dim_data(l_i).parent_level_col||' VARCHAR2(40)';
            IF  l_date_tracked_dim = 'YES' THEN
                l_lst_cols_desc := l_lst_cols_desc||', EFFECTIVE_START_DATE DATE, EFFECTIVE_END_DATE DATE';
            END IF;

            IF NOT BSC_APPS.Table_Exists(l_table_name) THEN
                l_sql := 'CREATE TABLE '||l_table_name||' ('||l_lst_cols_desc||')'||
                         ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_table_tbs_type)||
                         ' '||BSC_APPS.bsc_storage_clause;
                if bsc_im_utils.g_debug then
                  write_to_log_file_n(l_sql);
                end if;
                BSC_APPS.Do_DDL(l_sql, AD_DDL.CREATE_TABLE, l_table_name);
            END IF;
            -- Create the Index
            l_index_name := substr(l_table_name,1,29)||'N';
            IF NOT BSC_APPS.Index_Exists(l_index_name) THEN
                l_sql := 'CREATE INDEX '||l_index_name||
                         ' ON '||l_table_name||' ('||g_dbi_dim_data(l_i).parent_col||')'||
                         ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.summary_index_tbs_type)||
                         ' '||BSC_APPS.bsc_storage_clause;
                if bsc_im_utils.g_debug then
                  write_to_log_file_n(l_sql);
                end if;
                begin
                  BSC_APPS.Do_DDL(l_sql, AD_DDL.CREATE_INDEX, l_index_name);
                exception
                when l_col_already_indexed then
                  null;
                end;
            END IF;
        END IF;
    END LOOP;
    g_dbi_dim_tables_set:=true;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        x_error_msg := SQLERRM;
        RETURN FALSE;
END Create_Dbi_Dim_Tables;


--AW_INTEGRATION: new function
/*===========================================================================+
| FUNCTION Create_AW_Dim_Temp_Tables    				     |
+============================================================================*/
FUNCTION Create_AW_Dim_Temp_Tables RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_table_name VARCHAR2(30);
    h_table_columns BSC_UPDATE_UTIL.t_array_temp_table_cols;
    h_num_columns NUMBER;
    h_i NUMBER;
    h_tablespace VARCHAR2(80);
    h_idx_tablespace VARCHAR2(80);

BEGIN
    h_tablespace := BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type);
    h_idx_tablespace := BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type);

    -- BSC_AW_DIM_DELETE
    h_table_name := 'BSC_AW_DIM_DELETE';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DIM_LEVEL';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 300;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DELETE_VALUE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    -- Fix bug#5121276 this table needs to be created as a permanent table
    IF NOT BSC_UPDATE_UTIL.Create_Permanent_Table(h_table_name, h_table_columns, h_num_columns,
                                                  h_tablespace, h_idx_tablespace) THEN
        RAISE e_unexpected_error;
    END IF;


    -- BSC_AW_DIM_DATA
    h_table_name := 'BSC_AW_DIM_DATA';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DIM_LEVEL';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 300;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CODE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_AW_TMP_DENORM
    h_table_name := 'BSC_AW_TMP_DENORM';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CHILD_VALUE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PARENT_VALUE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_AW_REC_DIM_HIER_CHANGE
    h_table_name := 'BSC_AW_REC_DIM_HIER_CHANGE';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DIM_LEVEL';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 300;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CHILD_VALUE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PARENT_VALUE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'HIER_CHANGE_DATE';
    h_table_columns(h_num_columns).data_type := 'DATE';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR'),
                      x_source => 'BSC_UPDATE_DIM.Create_AW_Dim_Temp_Tables');
      RETURN FALSE;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_DIM.Create_AW_Dim_Temp_Tables');
      RETURN FALSE;
END Create_AW_Dim_Temp_Tables;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Create_AW_Dim_Temp_Tables_AT
+============================================================================*/
FUNCTION Create_AW_Dim_Temp_Tables_AT RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Create_AW_Dim_Temp_Tables;
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Create_AW_Dim_Temp_Tables_AT;


/*===========================================================================+
| FUNCTION Create_Dbi_Dim_Temp_Tables    				     |
+============================================================================*/
FUNCTION Create_Dbi_Dim_Temp_Tables RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_table_name VARCHAR2(30);
    h_table_columns BSC_UPDATE_UTIL.t_array_temp_table_cols;
    h_num_columns NUMBER;
    h_i NUMBER;
    h_tablespace VARCHAR2(80);
    h_idx_tablespace VARCHAR2(80);

BEGIN
    h_tablespace := BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type);
    h_idx_tablespace := BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type);

    -- BSC_TMP_DBI_DIM
    h_table_name := 'BSC_TMP_DBI_DIM';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'USER_CODE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CODE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    FOR h_i IN 1..10 LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'PARENT_CODE'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'N';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'EFFECTIVE_START_DATE';
    h_table_columns(h_num_columns).data_type := 'DATE';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'EFFECTIVE_END_DATE';
    h_table_columns(h_num_columns).data_type := 'DATE';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_DBI_DIM_ADD
    h_table_name := 'BSC_TMP_DBI_DIM_ADD';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'USER_CODE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_TMP_DBI_DIM_DEL (Note this table has the same strucutre of the previouos table)
    h_table_name := 'BSC_TMP_DBI_DIM_DEL';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC_OBJECT_REFRESH_LOG
    -- This is a permanent table used to store the last update date of the dbi dimension tables
    h_table_name := 'BSC_OBJECT_REFRESH_LOG';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'OBJECT_NAME';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 800;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'OBJECT_TYPE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 80;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'REFRESH_START_TIME';
    h_table_columns(h_num_columns).data_type := 'DATE';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'REFRESH_END_TIME';
    h_table_columns(h_num_columns).data_type := 'DATE';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Permanent_Table(h_table_name, h_table_columns, h_num_columns,
                                                  h_tablespace, h_idx_tablespace) THEN
        RAISE e_unexpected_error;
    END IF;

    -- RECURSIVE_DIMS: new temp table
    -- BSC_TMP_DNT
    h_table_name := 'BSC_TMP_DNT';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PARENT_CODE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CODE';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 400;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CHILD_LEVEL';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PARENT_LEVEL';
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
                      x_source => 'BSC_UPDATE_DIM.Create_Dbi_Dim_Temp_Tables');
      RETURN FALSE;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_DIM.Create_Dbi_Dim_Temp_Tables');
      RETURN FALSE;
END Create_Dbi_Dim_Temp_Tables;


/*===========================================================================+
| FUNCTION Delete_Codes_Cascade
+============================================================================*/
FUNCTION Delete_Codes_Cascade(
	x_dim_table IN VARCHAR2,
	x_deleted_codes IN BSC_UPDATE_UTIL.t_array_of_number,
	x_num_deleted_codes IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql 	VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    CURSOR c_dim_info (p_level_table_name VARCHAR2) IS
        SELECT dim_level_id, level_pk_col
        FROM bsc_sys_dim_levels_b
        WHERE level_table_name = p_level_table_name;

    h_dim_level_id 	bsc_sys_dim_levels_b.dim_level_id%TYPE;
    h_level_pk_col	bsc_sys_dim_levels_b.level_pk_col%TYPE;

    CURSOR c_child_mn (p_dim_level_id NUMBER, p_relation_type NUMBER)  IS
        SELECT r.relation_col, t.level_pk_col
        FROM bsc_sys_dim_level_rels r, bsc_sys_dim_levels_b t
        WHERE t.dim_level_id = r.parent_dim_level_id AND
              r.dim_level_id = p_dim_level_id AND r.relation_type = p_relation_type;

    h_mn_dim_table	bsc_sys_dim_level_rels.relation_col%TYPE;
    h_mn_level_pk_col	bsc_sys_dim_levels_b.level_pk_col%TYPE;

    CURSOR c_child (p_parent_id NUMBER, p_relation_type NUMBER) IS
        SELECT t.level_table_name
        FROM bsc_sys_dim_levels_b t, bsc_sys_dim_level_rels r
        WHERE t.dim_level_id = r.dim_level_id AND
              r.parent_dim_level_id = p_parent_id AND r.relation_type = p_relation_type;

    h_child_dim_table	bsc_sys_dim_levels_b.level_table_name%TYPE;

    h_condition VARCHAR2(32700);
    h_i NUMBER;

    h_deleted_codes 	BSC_UPDATE_UTIL.t_array_of_number;

    -- BSC-BIS-DIMENSIONS
    -- MN dimension can be created in BSC to store MN relations between BIS dimensions.
    -- To spport NUMBER or VARCHAR2 I will change the type of this arrays to varchar2.
    h_deleted_codes1 	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_deleted_codes2 	BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_deleted_codes NUMBER;

    h_code	NUMBER;
    h_code1	NUMBER;
    h_code2	NUMBER;

    -- AW_INTEGRATION: new varaibles
    h_dim_level_list dbms_sql.varchar2_table;

BEGIN
    h_num_deleted_codes := 0;

    -- Get info of the dimension table
    -- OPEN c_dim_info FOR c_dim_info_sql USING x_dim_table;
    OPEN c_dim_info(x_dim_table);
    FETCH c_dim_info INTO h_dim_level_id, h_level_pk_col;
    IF c_dim_info%NOTFOUND THEN
        RAISE e_unexpected_error;
    END IF;
    CLOSE c_dim_info;

    -- Delete from all system tables rows for deleted values
    -- BSC-MV Note: There is no need to delete data from summary tables
    -- because the affected indicators will be re-calculated later.
    -- It is necessary to delete only from base tables.
    -- This logic is valid for both architectures.

    h_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, h_level_pk_col);
    FOR h_i IN 1..x_num_deleted_codes LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_deleted_codes(h_i));
    END LOOP;

    IF NOT Delete_Key_Values_In_Tables(h_level_pk_col, h_condition) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Delete the items from the mn-child dimension tables
    --OPEN c_child_mn FOR c_child_mn_sql USING h_dim_level_id, 2;
    OPEN c_child_mn(h_dim_level_id, 2);
    FETCH c_child_mn INTO h_mn_dim_table, h_mn_level_pk_col;
    WHILE c_child_mn%FOUND LOOP
        h_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, h_level_pk_col);
        FOR h_i IN 1..x_num_deleted_codes LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, x_deleted_codes(h_i));
        END LOOP;

        h_sql := 'SELECT '||h_level_pk_col||', '||h_mn_level_pk_col||
                 ' FROM '||h_mn_dim_table||
                 ' WHERE '||h_condition;

        h_num_deleted_codes := 0;

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_code1, h_code2;
        WHILE h_cursor%FOUND LOOP
            h_num_deleted_codes := h_num_deleted_codes + 1;
            h_deleted_codes1(h_num_deleted_codes) := h_code1;
            h_deleted_codes2(h_num_deleted_codes) := h_code2;

            FETCH h_cursor INTO h_code1, h_code2;
        END LOOP;
        CLOSE h_cursor;

        IF h_num_deleted_codes > 0 THEN
            IF NOT Delete_Codes_CascadeMN(h_mn_dim_table,
                                          h_level_pk_col,
                                          h_mn_level_pk_col,
                                          h_deleted_codes1,
                                          h_deleted_codes2,
                                          h_num_deleted_codes) THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;

        FETCH c_child_mn INTO h_mn_dim_table, h_mn_level_pk_col;
    END LOOP;
    CLOSE c_child_mn;

    -- Delete the items from the child dimension tables
    --BSC-BIS-DIMENSIONS: A BSC dimension CANNOT be parent of a BIS dimension. So no need change here.

    --OPEN c_child FOR c_child_sql USING h_dim_level_id, 1;
    OPEN c_child(h_dim_level_id, 1);
    FETCH c_child INTO h_child_dim_table;
    WHILE c_child%FOUND LOOP
        h_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, h_level_pk_col);
        FOR h_i IN 1..x_num_deleted_codes LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, x_deleted_codes(h_i));
        END LOOP;

        h_sql := 'SELECT DISTINCT CODE FROM '||h_child_dim_table||
                 ' WHERE '||h_condition;

        h_num_deleted_codes := 0;

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_code;
        WHILE h_cursor%FOUND LOOP
            h_num_deleted_codes := h_num_deleted_codes + 1;
            h_deleted_codes(h_num_deleted_codes) := h_code;

            FETCH h_cursor INTO h_code;
        END LOOP;
        CLOSE h_cursor;

        IF h_num_deleted_codes > 0 THEN
            IF NOT Delete_Codes_Cascade(h_child_dim_table,
                                        h_deleted_codes,
                                        h_num_deleted_codes) THEN
                RAISE e_unexpected_error;
            END IF;
            -- AW_INTEGRATION: If the dimension is used by any AW indicator, we need to call the
            -- AW API to re-load child dimension into AW world.
            IF Dimension_Used_In_AW_Kpi(h_child_dim_table) THEN
                h_dim_level_list.delete;
                h_dim_level_list(1) := h_child_dim_table;
                bsc_aw_load.load_dim(
                    p_dim_level_list => h_dim_level_list,
                    p_options => 'DEBUG LOG'
                );
            END IF;
        END IF;

        FETCH c_child INTO h_child_dim_table;
    END LOOP;
    CLOSE c_child;

    -- Delete records from the dimension table
    h_condition := BSC_APPS.Get_New_Big_In_Cond_Number  (1, 'CODE');
    FOR h_i IN 1..x_num_deleted_codes LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_deleted_codes(h_i));

        -- AW_INTEGRATION: Need to insert the deleted codes into BSC_AW_DIM_DELETE table
        IF Dimension_Used_In_AW_Kpi(x_dim_table) THEN
            Insert_AW_Delete_Value(x_dim_table, x_deleted_codes(h_i));
        END IF;
    END LOOP;

    h_sql := 'DELETE FROM '||x_dim_table||
             ' WHERE '||h_condition;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DIMREC_DELETE_FAILED'),
                        x_source => 'BSC_UPDATE_BASE.Delete_Codes_Cascade');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Delete_Codes_Cascade');
        RETURN FALSE;

END Delete_Codes_Cascade;


/*===========================================================================+
| FUNCTION Delete_Codes_CascadeMN
+============================================================================*/
FUNCTION Delete_Codes_CascadeMN(
	x_dim_table IN VARCHAR2,
	x_key_column1 IN VARCHAR2,
	x_key_column2 IN VARCHAR2,
	x_deleted_codes1 IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_deleted_codes2 IN BSC_UPDATE_UTIL.t_array_of_varchar2,
	x_num_deleted_codes IN NUMBER
	) RETURN BOOLEAN IS

    h_condition VARCHAR2(32700);
    h_i NUMBER;

    TYPE t_cursor IS REF CURSOR;

    -- BSC-MV Note: Change query to get only base tables. This logic is valid for both architectures
    CURSOR c_system_tables (p_col_name1 VARCHAR2, p_col_name2 VARCHAR2,
                            p_col_type VARCHAR2, p_table_type NUMBER, p_count NUMBER) IS
        SELECT DISTINCT bt.table_name
        FROM (SELECT DISTINCT table_name
              FROM bsc_db_tables_rels
              WHERE source_table_name IN (
                    SELECT table_name
                    FROM bsc_db_tables
                    WHERE table_type = p_table_type)
             ) bt,
             bsc_db_tables_cols c
        WHERE bt.table_name = c.table_name AND
              (c.column_name = p_col_name1 OR
              c.column_name = p_col_name2) AND
              c.column_type = p_col_type
        GROUP BY bt.table_name
        HAVING COUNT(*) = p_count;

    h_column_type_p VARCHAR2(1);

    h_system_table VARCHAR2(30);
    h_sql VARCHAR2(32700);

    -- ENH_B_TABLES_PERF: new variable
    h_proj_tbl_name VARCHAR2(30);

BEGIN

    h_column_type_p := 'P';

    h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, x_key_column1||'||''-''||'||x_key_column2);

    FOR h_i IN 1..x_num_deleted_codes LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_deleted_codes1(h_i)||'-'||x_deleted_codes2(h_i));
    END LOOP;

    -- Delete from system tables
    -- BSC-MV Note: There is no need to delete data from summary tables
    -- because the affected indicators will be re-calculated later.
    -- It is necessary to delete only from base tables.
    -- This logic is valid for both architectures.
    OPEN c_system_tables(x_key_column1, x_key_column2, h_column_type_p, 0, 2);
    FETCH c_system_tables INTO h_system_table;
    WHILE c_system_tables%FOUND LOOP
        h_sql := 'DELETE FROM '||h_system_table||
                 ' WHERE '||h_condition;
        --Fix bug#5060236 B table may not exists, GDB may have fail in the middle
        -- We can ignore error if the table does not exists
        BEGIN BSC_UPDATE_UTIL.Execute_Immediate(h_sql); EXCEPTION WHEN OTHERS THEN NULL; END;

        -- ENH_B_TABLES_PERF: with the new strategy the B table may have a projection table.
        -- We need to delete rows from the projection table too.
        h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_system_table);
        IF h_proj_tbl_name IS NOT NULL THEN
            h_sql := 'DELETE FROM '||h_proj_tbl_name||
                     ' WHERE '||h_condition;
            --Fix bug#5060236 B table may not exists, GDB may have fail in the middle
            -- We can ignore error if the table does not exists
            BEGIN BSC_UPDATE_UTIL.Execute_Immediate(h_sql); EXCEPTION WHEN OTHERS THEN NULL; END;
        END IF;

        FETCH c_system_tables INTO h_system_table;
    END LOOP;
    CLOSE c_system_tables;

    -- Delete from dimension table
    h_sql := 'DELETE FROM '||x_dim_table||
             ' WHERE '||h_condition;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Delete_Codes_CascadeMN');
        RETURN FALSE;

END Delete_Codes_CascadeMN;


/*===========================================================================+
| FUNCTION Delete_Key_Values_In_Tables
+============================================================================*/
FUNCTION Delete_Key_Values_In_Tables(
	x_level_pk_col IN VARCHAR2,
        x_condition IN VARCHAR2
	) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;

    -- BSC-MV Note: Change query to get only base tables. This logic is valid for both architectures
    CURSOR c_affected_tables (p_col_name VARCHAR2, p_col_type VARCHAR2, p_table_type NUMBER) IS
        SELECT DISTINCT bt.table_name
        FROM (SELECT DISTINCT table_name
              FROM bsc_db_tables_rels
              WHERE source_table_name IN (
                       SELECT table_name
                       FROM bsc_db_tables
                       WHERE table_type = p_table_type)
             ) bt,
             bsc_db_tables_cols c
        WHERE bt.table_name = c.table_name AND
              c.column_name = p_col_name AND
              c.column_type = p_col_type;

    h_column_type_p VARCHAR2(1);
    h_table_name VARCHAR2(30);

    -- ENH_B_TABLES_PERF: new variable
    h_proj_tbl_name VARCHAR2(30);

BEGIN

    h_column_type_p := 'P';

    OPEN c_affected_tables(x_level_pk_col, h_column_type_p, 0);
    FETCH c_affected_tables INTO h_table_name;
    WHILE c_affected_tables%FOUND LOOP
        h_sql := 'DELETE FROM '||h_table_name||
                 ' WHERE '||x_condition;
        --Fix bug#5060236 B table may not exists, GDB may have fail in the middle
        -- We can ignore error if the table does not exists
        BEGIN BSC_UPDATE_UTIL.Execute_Immediate(h_sql); EXCEPTION WHEN OTHERS THEN NULL; END;

        -- ENH_B_TABLES_PERF: with the new strategy the B table may have a projection table.
        -- We need to delete rows from the projection table too
        h_proj_tbl_name := BSC_UPDATE_BASE_V2.Get_Base_Proj_Tbl_Name(h_table_name);
        IF h_proj_tbl_name IS NOT NULL THEN
            h_sql := 'DELETE FROM '||h_proj_tbl_name||
                     ' WHERE '||x_condition;
            --Fix bug#5060236 B table may not exists, GDB may have fail in the middle
            -- We can ignore error if the table does not exists
            BEGIN BSC_UPDATE_UTIL.Execute_Immediate(h_sql); EXCEPTION WHEN OTHERS THEN NULL; END;
        END IF;

        FETCH c_affected_tables INTO h_table_name;
    END LOOP;
    CLOSE c_affected_tables;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Delete_Key_Values_In_Tables');
        RETURN FALSE;

END Delete_Key_Values_In_Tables;


/*===========================================================================+
| FUNCTION Denorm_Eni_Item_Vbh_Cat
+============================================================================*/
FUNCTION Denorm_Eni_Item_Vbh_Cat RETURN BOOLEAN IS

    l_sql VARCHAR2(32000);
    l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;
    l_yes VARCHAR2(3);

    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;

    l_num_ids_this_level NUMBER;
    l_current_level NUMBER;
    l_id NUMBER;
    l_where_level VARCHAR2(32000);

    l_dim_obj_type VARCHAR2(80);

    -- AW_INTEGRATION: new varaibles
    l_level_table_name VARCHAR2(30);
    l_dim_for_aw_kpi BOOLEAN;
    l_dim_short_name VARCHAR2(100);

BEGIN

    l_dim_obj_type := 'DIM';
    l_yes := 'Y';
    l_dim_short_name := 'ENI_ITEM_VBH_CAT';

    Get_Dbi_Dim_Data(l_dim_short_name, l_dbi_dim_data);

    -- AW_INTEGRATION: We need to know the level_table_name given the short name
    SELECT level_table_name
    INTO l_level_table_name
    FROM bsc_sys_dim_levels_b
    WHERE short_name = l_dim_short_name;

    -- AW_INTEGRATION: We need to knowif the dimension is used by an AW indicator
    l_dim_for_aw_kpi := Dimension_Used_In_AW_Kpi(l_level_table_name);

    IF l_dbi_dim_data.denorm_table IS NULL THEN
        -- there is no denorm table
        RETURN TRUE;
    END IF;

    IF (l_dbi_dim_data.top_n_levels IS NULL) OR (l_dbi_dim_data.top_n_levels = 0) THEN
        -- we do not need to denormalize this table
        RETURN TRUE;
    END IF;

    -- We are going to compare the last update date of the source object with
    -- the refresh_end_time of the dimension table to know if it is necessary to
    -- refresh it or not.
    IF NOT Need_Refresh_Dbi_Table(l_dbi_dim_data.denorm_table, l_dbi_dim_data.denorm_source_to_check) THEN
        -- NO need to refresh
        RETURN TRUE;
    END IF;

    -- Udpate REFRESH_START_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_start_time = SYSDATE, refresh_end_time = NULL'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    IF SQL%NOTFOUND THEN
        l_sql := 'INSERT INTO bsc_object_refresh_log'||
                 ' (object_name, object_type, refresh_start_time, refresh_end_time)'||
                 ' VALUES (:1, :2, SYSDATE, NULL)';
        EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    END IF;
    COMMIT;

    -- AW_INTEGRATION: We need to save the current denorm table data int temp table BSC_AW_TMP_DENORM
    IF l_dim_for_aw_kpi THEN
        BSC_UPDATE_UTIL.Execute_Immediate('DELETE BSC_AW_TMP_DENORM');
        l_sql := 'INSERT INTO BSC_AW_TMP_DENORM (CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql;
        COMMIT;
    END IF;

    BSC_UPDATE_UTIL.Truncate_Table(l_dbi_dim_data.denorm_table);

    FOR l_current_level IN 1..l_dbi_dim_data.top_n_levels LOOP
        l_num_ids_this_level := 0;

        IF l_current_level = 1 THEN
            -- First level (top_level)
            l_sql := 'SELECT DISTINCT '||l_dbi_dim_data.parent_col_src||
                     ' FROM '||l_dbi_dim_data.denorm_src_object||
                     ' WHERE top_node_flag = :1';
            OPEN l_cursor FOR l_sql USING l_yes;
        ELSE
            l_sql := 'SELECT DISTINCT imm_child_id'||
                     ' FROM '||l_dbi_dim_data.denorm_src_object||
                     ' WHERE '||l_dbi_dim_data.parent_col_src||' <> imm_child_id'||
                     ' AND ('||l_where_level||')';
            OPEN l_cursor FOR l_sql;
        END IF;

        l_where_level := BSC_APPS.Get_New_Big_In_Cond_Number(l_current_level, l_dbi_dim_data.parent_col_src);

        LOOP
            FETCH l_cursor INTO l_id;
            EXIT WHEN l_cursor%NOTFOUND;
            BSC_APPS.Add_Value_Big_In_Cond(l_current_level, l_id);
            l_num_ids_this_level := l_num_ids_this_level + 1;
        END LOOP;
        CLOSE l_cursor;

        IF l_num_ids_this_level = 0 THEN
            -- There is not items for this level, then no reason to continue...
            EXIT;
        END IF;

        l_sql := 'INSERT INTO '||l_dbi_dim_data.denorm_table||' ('||
                 l_dbi_dim_data.parent_col||', '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_level_col||')'||
                 ' SELECT '||l_dbi_dim_data.parent_col_src||', '||l_dbi_dim_data.child_col_src||', :1'||
                 ' FROM '||l_dbi_dim_data.denorm_src_object||
                 ' WHERE '||l_where_level;
        EXECUTE IMMEDIATE l_sql USING l_current_level;
    END LOOP;

    -- AW_INTEGRATION: Need to insert BSC_AW_TMP_DENORM MINUS l_dbi_dim_data.denorm_table
    -- into BSC_AW_REC_DIM_HIER_CHANGE
    IF l_dim_for_aw_kpi THEN
        l_sql := 'INSERT INTO BSC_AW_REC_DIM_HIER_CHANGE (DIM_LEVEL, CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT :1, CHILD_VALUE, PARENT_VALUE FROM BSC_AW_TMP_DENORM'||
                 ' MINUS '||
                 ' SELECT :2, '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql USING l_level_table_name, l_level_table_name;
    END IF;

    COMMIT;

    -- Udpate REFRESH_END_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_end_time = SYSDATE'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Denorm_Eni_Item_Vbh_Cat');
        RETURN FALSE;
END Denorm_Eni_Item_Vbh_Cat;


/*===========================================================================+
| FUNCTION Denorm_Eni_Item_Itm_Cat
+============================================================================*/
FUNCTION Denorm_Eni_Item_Itm_Cat RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    l_sql VARCHAR2(32000);
    l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;

    l_ids_this_level BSC_UPDATE_UTIL.t_array_of_number;
    l_num_ids_this_level NUMBER;
    l_ids BSC_UPDATE_UTIL.t_array_of_number;
    l_num_ids NUMBER;
    l_current_level NUMBER;
    l_id NUMBER;
    l_where_level VARCHAR2(32000);
    l_i NUMBER;
    l_short_name VARCHAR2(100);
    l_src_condition VARCHAR2(20000);

    l_dim_obj_type VARCHAR2(80);

    -- AW_INTEGRATION: new varaibles
    l_level_table_name VARCHAR2(30);
    l_dim_for_aw_kpi BOOLEAN;

BEGIN

    l_dim_obj_type := 'DIM';
    l_short_name := 'ENI_ITEM_ITM_CAT';

    Get_Dbi_Dim_Data(l_short_name, l_dbi_dim_data);

    -- AW_INTEGRATION: We need to know the level_table_name given the short name
    SELECT level_table_name
    INTO l_level_table_name
    FROM bsc_sys_dim_levels_b
    WHERE short_name = l_short_name;

    -- AW_INTEGRATION: We need to knowif the dimension is used by an AW indicator
    l_dim_for_aw_kpi := Dimension_Used_In_AW_Kpi(l_level_table_name);

    IF l_dbi_dim_data.denorm_table IS NULL THEN
        -- there is no denorm table
        RETURN TRUE;
    END IF;


    IF (l_dbi_dim_data.top_n_levels IS NULL) OR (l_dbi_dim_data.top_n_levels = 0) THEN
        -- we do not need to denormalize this table
        RETURN TRUE;
    END IF;

    -- We are going to compare the last update date of the source object with
    -- the refresh_end_time of the dimension table to know if it is necessary to
    -- refresh it or not.
    IF NOT Need_Refresh_Dbi_Table(l_dbi_dim_data.denorm_table, l_dbi_dim_data.denorm_source_to_check) THEN
        -- NO need to refresh
        RETURN TRUE;
    END IF;

    -- Udpate REFRESH_START_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_start_time = SYSDATE, refresh_end_time = NULL'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    IF SQL%NOTFOUND THEN
        l_sql := 'INSERT INTO bsc_object_refresh_log'||
                 ' (object_name, object_type, refresh_start_time, refresh_end_time)'||
                 ' VALUES (:1, :2, SYSDATE, NULL)';
        EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    END IF;
    COMMIT;

    -- AW_INTEGRATION: We need to save the current denorm table data int temp table BSC_AW_TMP_DENORM
    IF l_dim_for_aw_kpi THEN
        BSC_UPDATE_UTIL.Execute_Immediate('DELETE BSC_AW_TMP_DENORM');
        l_sql := 'INSERT INTO BSC_AW_TMP_DENORM (CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql;
        COMMIT;
    END IF;

    BSC_UPDATE_UTIL.Truncate_Table(l_dbi_dim_data.denorm_table);

    l_src_condition := 'NVL(node, '||l_dbi_dim_data.child_col_src||') = '||l_dbi_dim_data.child_col_src;

    FOR l_current_level IN 1..l_dbi_dim_data.top_n_levels LOOP
        l_num_ids_this_level := 0;
        l_ids_this_level.delete;

        IF l_current_level = 1 THEN
            -- First level (top_level)
            l_sql := 'SELECT DISTINCT '||l_dbi_dim_data.child_col_src||
                     ' FROM '||l_dbi_dim_data.denorm_src_object||
                     ' WHERE '||l_src_condition||
                     ' AND '||l_dbi_dim_data.parent_col_src||' IS NULL';
        ELSE
            l_sql := 'SELECT DISTINCT '||l_dbi_dim_data.child_col_src||
                     ' FROM '||l_dbi_dim_data.denorm_src_object||
                     ' WHERE '||l_src_condition||
                     ' AND '||l_where_level;
        END IF;
        OPEN l_cursor FOR l_sql;
        l_where_level := BSC_APPS.Get_New_Big_In_Cond_Number(l_current_level, l_dbi_dim_data.parent_col_src);
        LOOP
            FETCH l_cursor INTO l_id;
            EXIT WHEN l_cursor%NOTFOUND;
            BSC_APPS.Add_Value_Big_In_Cond(l_current_level, l_id);
            l_num_ids_this_level := l_num_ids_this_level + 1;
            l_ids_this_level(l_num_ids_this_level) := l_id;
        END LOOP;
        CLOSE l_cursor;

        IF l_num_ids_this_level = 0 THEN
            -- There is not items for this level, then no reason to continue...
            EXIT;
        END IF;

        FOR l_i IN 1..l_num_ids_this_level LOOP
            -- Insert row for itself
            l_sql := 'INSERT INTO '||l_dbi_dim_data.denorm_table||' ('||
                     l_dbi_dim_data.parent_col||', '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_level_col||
                     ') VALUES (:1, :2, :3)';
            EXECUTE IMMEDIATE l_sql USING l_ids_this_level(l_i), l_ids_this_level(l_i), l_current_level;

            -- Insert children, grand children, etc of this id
            l_ids(1) := l_ids_this_level(l_i);
            l_num_ids := 1;
            IF NOT Insert_Children_Denorm_Table(x_parent_id => l_ids_this_level(l_i),
                                                x_ids => l_ids,
                                                x_num_ids => l_num_ids,
                                                x_level => l_current_level,
                                                x_denorm_table => l_dbi_dim_data.denorm_table,
                                                x_child_col => l_dbi_dim_data.child_col,
                                                x_parent_col => l_dbi_dim_data.parent_col,
                                                x_parent_level_col => l_dbi_dim_data.parent_level_col,
                                                x_denorm_src_object => l_dbi_dim_data.denorm_src_object,
                                                x_child_col_src => l_dbi_dim_data.child_col_src,
                                                x_parent_col_src => l_dbi_dim_data.parent_col_src,
                                                x_src_condition => l_src_condition) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;
    END LOOP;

    -- AW_INTEGRATION: Need to insert BSC_AW_TMP_DENORM MINUS l_dbi_dim_data.denorm_table
    -- into BSC_AW_REC_DIM_HIER_CHANGE
    IF l_dim_for_aw_kpi THEN
        l_sql := 'INSERT INTO BSC_AW_REC_DIM_HIER_CHANGE (DIM_LEVEL, CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT :1, CHILD_VALUE, PARENT_VALUE FROM BSC_AW_TMP_DENORM'||
                 ' MINUS '||
                 ' SELECT :2, '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql USING l_level_table_name, l_level_table_name;
    END IF;

    COMMIT;

    -- Udpate REFRESH_END_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_end_time = SYSDATE'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR'),
                        x_source => 'BSC_UPDATE_DIM.Denorm_Eni_Item_Itm_Cat');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Denorm_Eni_Item_Itm_Cat');
        RETURN FALSE;
END Denorm_Eni_Item_Itm_Cat;


/*===========================================================================+
| FUNCTION Denorm_Hri_Per_Usrdr_H
+============================================================================*/
FUNCTION Denorm_Hri_Per_Usrdr_H RETURN BOOLEAN IS

    l_sql VARCHAR2(32000);
    l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;
    l_lst_cols VARCHAR2(32000);
    l_lst_src_cols VARCHAR2(32000);

    l_dim_obj_type VARCHAR2(80);

    -- AW_INTEGRATION: new varaibles
    l_level_table_name VARCHAR2(30);
    l_dim_for_aw_kpi BOOLEAN;
    l_dim_short_name VARCHAR2(100);

BEGIN

    l_dim_obj_type := 'DIM';
    l_dim_short_name := 'HRI_PER_USRDR_H';

    Get_Dbi_Dim_Data(l_dim_short_name, l_dbi_dim_data);

    -- AW_INTEGRATION: We need to know the level_table_name given the short name
    SELECT level_table_name
    INTO l_level_table_name
    FROM bsc_sys_dim_levels_b
    WHERE short_name = l_dim_short_name;

    -- AW_INTEGRATION: We need to knowif the dimension is used by an AW indicator
    l_dim_for_aw_kpi := Dimension_Used_In_AW_Kpi(l_level_table_name);

    IF l_dbi_dim_data.denorm_table IS NULL THEN
        -- there is no denorm table
        RETURN TRUE;
    END IF;

    IF (l_dbi_dim_data.top_n_levels IS NULL) OR (l_dbi_dim_data.top_n_levels = 0) THEN
        -- we do not need to denormalize this table
        RETURN TRUE;
    END IF;

    -- We are going to compare the last update date of the source object with
    -- the refresh_end_time of the dimension table to know if it is necessary to
    -- refresh it or not.
    IF NOT Need_Refresh_Dbi_Table(l_dbi_dim_data.denorm_table, l_dbi_dim_data.denorm_source_to_check) THEN
        -- NO need to refresh
        RETURN TRUE;
    END IF;

    -- Udpate REFRESH_START_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_start_time = SYSDATE, refresh_end_time = NULL'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    IF SQL%NOTFOUND THEN
        l_sql := 'INSERT INTO bsc_object_refresh_log'||
                 ' (object_name, object_type, refresh_start_time, refresh_end_time)'||
                 ' VALUES (:1, :2, SYSDATE, NULL)';
        EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    END IF;
    COMMIT;

    -- AW_INTEGRATION: We need to save the current denorm table data int temp table BSC_AW_TMP_DENORM
    IF l_dim_for_aw_kpi THEN
        BSC_UPDATE_UTIL.Execute_Immediate('DELETE BSC_AW_TMP_DENORM');
        l_sql := 'INSERT INTO BSC_AW_TMP_DENORM (CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql;
        COMMIT;
    END IF;

    BSC_UPDATE_UTIL.Truncate_Table(l_dbi_dim_data.denorm_table);

    l_lst_cols := l_dbi_dim_data.parent_col||', '||l_dbi_dim_data.child_col||
                  ', '||l_dbi_dim_data.parent_level_col;

    l_lst_src_cols := l_dbi_dim_data.parent_col_src||', '||l_dbi_dim_data.child_col_src||
                      ', '||l_dbi_dim_data.parent_level_src_col;

    IF l_dbi_dim_data.date_tracked_dim = 'YES' THEN
        l_lst_cols := l_lst_cols||', EFFECTIVE_START_DATE, EFFECTIVE_END_DATE';
        l_lst_src_cols := l_lst_src_cols||', EFFECTIVE_START_DATE, EFFECTIVE_END_DATE';
    END IF;

    l_sql := 'INSERT INTO '||l_dbi_dim_data.denorm_table||' ('||l_lst_cols||')'||
             ' SELECT '||l_lst_src_cols||
             ' FROM '||l_dbi_dim_data.denorm_src_object||
             ' WHERE '||l_dbi_dim_data.parent_level_src_col||' <= :1';

    IF l_dbi_dim_data.date_tracked_dim = 'YES' THEN
        l_sql := l_sql||' AND (SYSDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)';
    END IF;
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.top_n_levels;

    -- AW_INTEGRATION: Need to insert BSC_AW_TMP_DENORM MINUS l_dbi_dim_data.denorm_table
    -- into BSC_AW_REC_DIM_HIER_CHANGE
    IF l_dim_for_aw_kpi THEN
        l_sql := 'INSERT INTO BSC_AW_REC_DIM_HIER_CHANGE (DIM_LEVEL, CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT :1, CHILD_VALUE, PARENT_VALUE FROM BSC_AW_TMP_DENORM'||
                 ' MINUS '||
                 ' SELECT :2, '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql USING l_level_table_name, l_level_table_name;
    END IF;

    COMMIT;

    -- Udpate REFRESH_END_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_end_time = SYSDATE'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Denorm_Hri_Per_Usrdr_H');
        RETURN FALSE;
END Denorm_Hri_Per_Usrdr_H;


/*===========================================================================+
| FUNCTION Denorm_Pji_Organizations
+============================================================================*/
FUNCTION Denorm_Pji_Organizations RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    l_sql VARCHAR2(32000);
    l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;

    l_ids_this_level BSC_UPDATE_UTIL.t_array_of_number;
    l_num_ids_this_level NUMBER;
    l_ids BSC_UPDATE_UTIL.t_array_of_number;
    l_num_ids NUMBER;
    l_current_level NUMBER;
    l_id NUMBER;
    l_where_level VARCHAR2(32000);
    l_i NUMBER;
    l_short_name VARCHAR2(100);

    l_dim_obj_type VARCHAR2(80);

    -- AW_INTEGRATION: new varaibles
    l_level_table_name VARCHAR2(30);
    l_dim_for_aw_kpi BOOLEAN;

BEGIN

    l_dim_obj_type := 'DIM';
    l_short_name := 'PJI_ORGANIZATIONS';

    Get_Dbi_Dim_Data(l_short_name, l_dbi_dim_data);

    -- AW_INTEGRATION: We need to know the level_table_name given the short name
    SELECT level_table_name
    INTO l_level_table_name
    FROM bsc_sys_dim_levels_b
    WHERE short_name = l_short_name;

    -- AW_INTEGRATION: We need to knowif the dimension is used by an AW indicator
    l_dim_for_aw_kpi := Dimension_Used_In_AW_Kpi(l_level_table_name);

    IF l_dbi_dim_data.denorm_table IS NULL THEN
        -- there is no denorm table
        RETURN TRUE;
    END IF;

    IF (l_dbi_dim_data.top_n_levels IS NULL) OR (l_dbi_dim_data.top_n_levels = 0) THEN
        -- we do not need to denormalize this table
        RETURN TRUE;
    END IF;

    -- We are going to compare the last update date of the source object with
    -- the refresh_end_time of the dimension table to know if it is necessary to
    -- refresh it or not.
    IF NOT Need_Refresh_Dbi_Table(l_dbi_dim_data.denorm_table, l_dbi_dim_data.denorm_source_to_check) THEN
        -- NO need to refresh
        RETURN TRUE;
    END IF;

    -- Udpate REFRESH_START_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_start_time = SYSDATE, refresh_end_time = NULL'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    IF SQL%NOTFOUND THEN
        l_sql := 'INSERT INTO bsc_object_refresh_log'||
                 ' (object_name, object_type, refresh_start_time, refresh_end_time)'||
                 ' VALUES (:1, :2, SYSDATE, NULL)';
        EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    END IF;
    COMMIT;

    -- AW_INTEGRATION: We need to save the current denorm table data int temp table BSC_AW_TMP_DENORM
    IF l_dim_for_aw_kpi THEN
        BSC_UPDATE_UTIL.Execute_Immediate('DELETE BSC_AW_TMP_DENORM');
        l_sql := 'INSERT INTO BSC_AW_TMP_DENORM (CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql;
        COMMIT;
    END IF;

    BSC_UPDATE_UTIL.Truncate_Table(l_dbi_dim_data.denorm_table);

    FOR l_current_level IN 1..l_dbi_dim_data.top_n_levels LOOP
        l_num_ids_this_level := 0;
        l_ids_this_level.delete;

        IF l_current_level = 1 THEN
            -- First level (top_level)
            l_sql := 'SELECT DISTINCT '||l_dbi_dim_data.child_col_src||
                     ' FROM '||l_dbi_dim_data.denorm_src_object||
                     ' WHERE '||l_dbi_dim_data.parent_col_src||' IS NULL';
        ELSE
            l_sql := 'SELECT DISTINCT '||l_dbi_dim_data.child_col_src||
                     ' FROM '||l_dbi_dim_data.denorm_src_object||
                     ' WHERE '||l_where_level;
        END IF;
        OPEN l_cursor FOR l_sql;
        l_where_level := BSC_APPS.Get_New_Big_In_Cond_Number(l_current_level, l_dbi_dim_data.parent_col_src);
        LOOP
            FETCH l_cursor INTO l_id;
            EXIT WHEN l_cursor%NOTFOUND;
            BSC_APPS.Add_Value_Big_In_Cond(l_current_level, l_id);
            l_num_ids_this_level := l_num_ids_this_level + 1;
            l_ids_this_level(l_num_ids_this_level) := l_id;
        END LOOP;
        CLOSE l_cursor;

        IF l_num_ids_this_level = 0 THEN
            -- There is not items for this level, then no reason to continue...
            EXIT;
        END IF;

        FOR l_i IN 1..l_num_ids_this_level LOOP
            -- Insert row for itself
            l_sql := 'INSERT INTO '||l_dbi_dim_data.denorm_table||' ('||
                     l_dbi_dim_data.parent_col||', '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_level_col||
                     ') VALUES (:1, :2, :3)';
            EXECUTE IMMEDIATE l_sql USING l_ids_this_level(l_i), l_ids_this_level(l_i), l_current_level;

            -- Insert children, grand children, etc of this id
            l_ids(1) := l_ids_this_level(l_i);
            l_num_ids := 1;

            IF NOT Insert_Children_Denorm_Table(x_parent_id => l_ids_this_level(l_i),
                                                x_ids => l_ids,
                                                x_num_ids => l_num_ids,
                                                x_level => l_current_level,
                                                x_denorm_table => l_dbi_dim_data.denorm_table,
                                                x_child_col => l_dbi_dim_data.child_col,
                                                x_parent_col => l_dbi_dim_data.parent_col,
                                                x_parent_level_col => l_dbi_dim_data.parent_level_col,
                                                x_denorm_src_object => l_dbi_dim_data.denorm_src_object,
                                                x_child_col_src => l_dbi_dim_data.child_col_src,
                                                x_parent_col_src => l_dbi_dim_data.parent_col_src,
                                                x_src_condition => NULL) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;
    END LOOP;

    -- AW_INTEGRATION: Need to insert BSC_AW_TMP_DENORM MINUS l_dbi_dim_data.denorm_table
    -- into BSC_AW_REC_DIM_HIER_CHANGE
    IF l_dim_for_aw_kpi THEN
        l_sql := 'INSERT INTO BSC_AW_REC_DIM_HIER_CHANGE (DIM_LEVEL, CHILD_VALUE, PARENT_VALUE)'||
                 ' SELECT :1, CHILD_VALUE, PARENT_VALUE FROM BSC_AW_TMP_DENORM'||
                 ' MINUS '||
                 ' SELECT :2, '||l_dbi_dim_data.child_col||', '||l_dbi_dim_data.parent_col||
                 ' FROM '||l_dbi_dim_data.denorm_table;
        EXECUTE IMMEDIATE l_sql USING l_level_table_name, l_level_table_name;
    END IF;

    COMMIT;

    -- Udpate REFRESH_END_TIME in BSC_OBJECT_REFRESH_LOG for this table
    l_sql := 'UPDATE bsc_object_refresh_log'||
             ' SET refresh_end_time = SYSDATE'||
             ' WHERE object_name = :1 AND object_type = :2';
    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.denorm_table, l_dim_obj_type;
    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR'),
                        x_source => 'BSC_UPDATE_DIM.Denorm_Pji_Organizations');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Denorm_Pji_Organizations');
        RETURN FALSE;
END Denorm_Pji_Organizations;


--AW_INTEGRATION: New function
/*===========================================================================+
| FUNCTION Dimension_Used_In_AW_Kpi
+============================================================================*/
FUNCTION Dimension_Used_In_AW_Kpi(
	x_dim_table IN VARCHAR2
	) RETURN BOOLEAN IS
    h_count NUMBER;
    h_aw_impl_type NUMBER;
    h_aw_impl_type_name VARCHAR2(100);
BEGIN
    h_count := 0;
    h_aw_impl_type_name := 'IMPLEMENTATION_TYPE';
    h_aw_impl_type := 2;

    select count(level_table_name)
    into h_count
    from bsc_kpi_dim_levels_b
    where indicator in (
        select p.indicator
        from bsc_kpi_properties p, bsc_kpis_b k
        where p.indicator = k.indicator and
              p.property_code = h_aw_impl_type_name and
              p.property_value = h_aw_impl_type and
              k.prototype_flag in (0,6,7)
    ) and level_table_name = x_dim_table;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Dimension_Used_In_AW_Kpi;


--RECURSIVE_DIMS: New function
/*===========================================================================+
| FUNCTION Dimension_Used_In_MV_Kpi
+============================================================================*/
FUNCTION Dimension_Used_In_MV_Kpi(
	x_dim_table IN VARCHAR2
	) RETURN BOOLEAN IS
    h_count NUMBER;
    h_mv_impl_type NUMBER;
    h_mv_impl_type_name VARCHAR2(100);
BEGIN
    h_count := 0;
    h_mv_impl_type_name := 'IMPLEMENTATION_TYPE';
    h_mv_impl_type := 1;

    select count(level_table_name)
    into h_count
    from bsc_kpi_dim_levels_b
    where indicator in (
        select k.indicator
        from bsc_kpi_properties p, bsc_kpis_b k
        where p.indicator (+) = k.indicator and
              p.property_code (+) = h_mv_impl_type_name and
              (p.property_value is null or p.property_value = h_mv_impl_type) and
              k.prototype_flag in (0,6,7)
    ) and level_table_name = x_dim_table;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Dimension_Used_In_MV_Kpi;


/*===========================================================================+
| PROCEDURE Get_All_Dbi_Dim_Data
+============================================================================*/
PROCEDURE Get_All_Dbi_Dim_Data(
    x_dbi_dim_data OUT NOCOPY BSC_UPDATE_DIM.t_array_dbi_dim_data
) IS
    l_i NUMBER;
BEGIN

    IF g_dbi_dim_data_set is null or g_dbi_dim_data_set = FALSE THEN
        Init_Dbi_Dim_Data;
    END IF;

    FOR l_i IN 1..g_dbi_dim_data.COUNT LOOP
        x_dbi_dim_data(l_i) := g_dbi_dim_data(l_i);
    END LOOP;

END Get_All_Dbi_Dim_Data;


/*===========================================================================+
| FUNCTION Get_Aux_Fields_Dim_Table
+============================================================================*/
FUNCTION Get_Aux_Fields_Dim_Table(
	x_dim_table IN VARCHAR2,
        x_aux_fields IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_aux_fields t_cursor; -- x_dim_table, h_column_type_a
    c_aux_fields_sql VARCHAR2(2000) := 'SELECT c.column_name'||
                                       ' FROM bsc_sys_dim_level_cols c, bsc_sys_dim_levels_b d'||
                                       ' WHERE d.dim_level_id = c.dim_level_id AND'||
                                       ' d.level_table_name = :1 AND'||
                                       ' column_type = :2';
    */
    CURSOR c_aux_fields (p_level_table_name VARCHAR2, p_column_type VARCHAR2) IS
        SELECT c.column_name
        FROM bsc_sys_dim_level_cols c, bsc_sys_dim_levels_b d
        WHERE d.dim_level_id = c.dim_level_id AND
              d.level_table_name = p_level_table_name AND
              column_type = p_column_type;

    h_column_type_a VARCHAR2(1);

    h_aux_field bsc_sys_dim_level_cols.column_name%TYPE;
    h_num_aux_fields NUMBER;

BEGIN
    h_column_type_a := 'A';
    h_num_aux_fields := 0;

    --OPEN c_aux_fields FOR c_aux_fields_sql USING x_dim_table, h_column_type_a;
    OPEN c_aux_fields (x_dim_table, h_column_type_a);
    FETCH c_aux_fields INTO h_aux_field;
    WHILE c_aux_fields%FOUND LOOP
        h_num_aux_fields := h_num_aux_fields + 1;
        x_aux_fields(h_num_aux_fields) := h_aux_field;

        FETCH c_aux_fields INTO h_aux_field;
    END LOOP;
    CLOSE c_aux_fields;

    RETURN h_num_aux_fields;

END Get_Aux_Fields_Dim_Table;


/*===========================================================================+
| FUNCTION Get_Child_Dimensions
+============================================================================*/
FUNCTION Get_Child_Dimensions(
	x_dimension_table IN VARCHAR2,
        x_child_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER IS

    h_num_child_dimensions NUMBER;

    h_table_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    /*
    c_child_dimensions t_cursor; -- h_table_id, 1
    c_child_dimensions_sql VARCHAR2(2000) := 'SELECT t.level_table_name'||
                                             ' FROM bsc_sys_dim_levels_b t, bsc_sys_dim_level_rels r'||
                                             ' WHERE t.dim_level_id = r.dim_level_id AND'||
                                             ' r.parent_dim_level_id = :1 AND r.relation_type = :2';
    */
    CURSOR c_child_dimensions (p_parent_id NUMBER, p_relation_type NUMBER) IS
        SELECT t.level_table_name
        FROM bsc_sys_dim_levels_b t, bsc_sys_dim_level_rels r
        WHERE t.dim_level_id = r.dim_level_id AND
              r.parent_dim_level_id = p_parent_id AND r.relation_type = p_relation_type;

    h_child_dimension VARCHAR2(30);

BEGIN

    h_num_child_dimensions := 0;

    -- Get dimension id
    /*
    h_sql := 'SELECT dim_level_id'||
             ' FROM bsc_sys_dim_levels_b'||
             ' WHERE level_table_name = :1';
    OPEN h_cursor FOR h_sql USING x_dimension_table;
    FETCH h_cursor INTO h_table_id;
    CLOSE h_cursor;
    */
    SELECT dim_level_id
    INTO h_table_id
    FROM bsc_sys_dim_levels_b
    WHERE level_table_name = x_dimension_table;

    -- Get child dimensions
    --OPEN c_child_dimensions FOR c_child_dimensions_sql USING h_table_id, 1;
    OPEN c_child_dimensions(h_table_id, 1);
    FETCH c_child_dimensions INTO h_child_dimension;
    WHILE c_child_dimensions%FOUND LOOP
        h_num_child_dimensions := h_num_child_dimensions + 1;
        x_child_dimensions(h_num_child_dimensions) := h_child_dimension;

        FETCH c_child_dimensions INTO h_child_dimension;
    END LOOP;
    CLOSE c_child_dimensions;

    RETURN h_num_child_dimensions;

END Get_Child_Dimensions;


/*===========================================================================+
| FUNCTION Get_Dbi_Dim_Parent_Columns
+============================================================================*/
FUNCTION Get_Dbi_Dim_Parent_Columns(
        x_dim_short_name IN VARCHAR2,
        x_parent_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_src_parent_columns IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
        ) RETURN NUMBER IS

    CURSOR c_parent_cols IS
        SELECT p.level_pk_col
        FROM bsc_sys_dim_levels_b c, bsc_sys_dim_level_rels r, bsc_sys_dim_levels_b p
        WHERE c.dim_level_id = r.dim_level_id AND
              r.parent_dim_level_id = p.dim_level_id AND
              r.relation_type = 1 AND
              r.dim_level_id <> r.parent_dim_level_id AND
              c.short_name = x_dim_short_name
        ORDER BY p.level_pk_col;

    l_num_parent_columns NUMBER;
    l_parent_column VARCHAR2(50);
    l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

BEGIN
    l_num_parent_columns := 0;

    Get_Dbi_Dim_Data(x_dim_short_name, l_dbi_dim_data);
    x_src_parent_columns(1) := l_dbi_dim_data.parent1_col;
    x_src_parent_columns(2) := l_dbi_dim_data.parent2_col;
    x_src_parent_columns(3) := l_dbi_dim_data.parent3_col;
    x_src_parent_columns(4) := l_dbi_dim_data.parent4_col;
    x_src_parent_columns(5) := l_dbi_dim_data.parent5_col;

    OPEN c_parent_cols;
    LOOP
        FETCH c_parent_cols INTO l_parent_column;
        EXIT WHEN c_parent_cols%NOTFOUND;

        l_num_parent_columns := l_num_parent_columns + 1;
        x_parent_columns(l_num_parent_columns) := l_parent_column;

        IF x_src_parent_columns(l_num_parent_columns) IS NULL THEN
            x_src_parent_columns(l_num_parent_columns) := l_parent_column;
        END IF;
    END LOOP;
    CLOSE c_parent_cols;

    RETURN l_num_parent_columns;

END Get_Dbi_Dim_Parent_Columns;


/*===========================================================================+
| FUNCTION Get_Dbi_Dim_View_Name
+============================================================================*/
FUNCTION Get_Dbi_Dim_View_Name(
    x_dim_short_name IN VARCHAR2
) RETURN VARCHAR2 IS

    l_view_name VARCHAR2(30);

BEGIN
    SELECT level_view_name
    INTO l_view_name
    FROM bsc_sys_dim_levels_b
    WHERE short_name = x_dim_short_name;

    RETURN l_view_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END Get_Dbi_Dim_View_Name;


/*===========================================================================+
| PROCEDURE Get_Dbi_Dim_Data
+============================================================================*/
PROCEDURE Get_Dbi_Dim_Data(
        x_dim_short_name IN VARCHAR2,
        x_dbi_dim_data OUT NOCOPY BSC_UPDATE_DIM.t_dbi_dim_data
        ) IS

    l_i NUMBER;

BEGIN
    IF g_dbi_dim_data_set is null or g_dbi_dim_data_set = FALSE THEN
        Init_Dbi_Dim_Data;
    END IF;

    FOR l_i IN 1..g_dbi_dim_data.COUNT LOOP
        IF UPPER(g_dbi_dim_data(l_i).short_name) = UPPER(x_dim_short_name) THEN
            x_dbi_dim_data := g_dbi_dim_data(l_i);
            EXIT;
        END IF;
    END LOOP;

END Get_Dbi_Dim_Data;


/*===========================================================================+
| FUNCTION Get_Dbi_Dims_Kpis
+============================================================================*/
FUNCTION Get_Dbi_Dims_Kpis(
	x_indicators IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_indicators IN NUMBER,
        x_dbi_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_dbi_dimensions IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    h_where_indics VARCHAR2(32000);
    h_i NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32700);

    h_short_name VARCHAR2(50);
    h_source VARCHAR2(10);
    h_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

BEGIN
    h_where_indics := NULL;
    h_sql := NULL;
    h_source := 'PMF';
    x_num_dbi_dimensions := 0;

    h_where_indics := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
    FOR h_i IN 1 .. x_num_indicators LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, x_indicators(h_i));
    END LOOP;

    h_sql := 'SELECT DISTINCT level_shortname'||
             ' FROM bsc_kpi_dim_levels_vl'||
             ' WHERE ('||h_where_indics||') AND level_source = :1';

    OPEN h_cursor FOR h_sql USING h_source;
    FETCH h_cursor INTO h_short_name;
    WHILE h_cursor%FOUND LOOP
        -- AW_INTEGRATION: Since we need to bring all the BIS dimensions used by AW indicators into AW world
        -- I need to change the next function to return all the BIS dimensions and not only the
        -- ones that are materialized in BSC
        x_num_dbi_dimensions := x_num_dbi_dimensions + 1;
        x_dbi_dimensions(x_num_dbi_dimensions) := h_short_name;

        FETCH h_cursor INTO h_short_name;
    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Get_Dbi_Dims_Kpis');
        RETURN FALSE;

END Get_Dbi_Dims_Kpis;


/*===========================================================================+
| FUNCTION Get_Deleted_Records
+============================================================================*/
FUNCTION Get_Deleted_Records(
        x_dimension_table IN VARCHAR2,
        x_temp_table IN VARCHAR2,
        x_deleted_records IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
        ) RETURN NUMBER IS

    h_num_deleted_records NUMBER;
    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_code NUMBER;

BEGIN
    h_num_deleted_records := 0;

    h_sql := 'SELECT T.CODE'||
             ' FROM '||x_temp_table||' T, '||x_dimension_table||' D'||
             ' WHERE T.CODE = D.CODE (+)'||
             ' AND D.CODE IS NULL';

    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_code;
    WHILE h_cursor%FOUND LOOP
        h_num_deleted_records := h_num_deleted_records + 1;
        x_deleted_records(h_num_deleted_records) := h_code;

        FETCH h_cursor INTO h_code;
    END LOOP;
    CLOSE h_cursor;

    RETURN h_num_deleted_records;

END Get_Deleted_Records;


/*===========================================================================+
| FUNCTION Get_Dim_Table_of_Input_Table
+============================================================================*/
FUNCTION Get_Dim_Table_of_Input_Table(
	x_input_table IN VARCHAR2
	) RETURN VARCHAR2 IS

    h_table_name VARCHAR2(30);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    /*
    h_sql := 'SELECT table_name'||
             ' FROM bsc_db_tables_rels'||
             ' WHERE source_table_name = :1';
    OPEN h_cursor FOR h_sql USING x_input_table;
    FETCH h_cursor INTO h_table_name;
    CLOSE h_cursor;
    */
    SELECT table_name
    INTO h_table_name
    FROM bsc_db_tables_rels
    WHERE source_table_name = x_input_table;

    RETURN h_table_name;

END Get_Dim_Table_of_Input_Table;


/*===========================================================================+
| FUNCTION Get_Dim_Table_Type
+============================================================================*/
FUNCTION Get_Dim_Table_Type(
	x_dim_table IN VARCHAR2
	) RETURN NUMBER IS

    h_count NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    h_count := 0;

    -- See if the dimension table is 1N
    /*
    h_sql := 'SELECT COUNT(*)'||
             ' FROM bsc_sys_dim_levels_b'||
             ' WHERE level_table_name = :1';
    OPEN h_cursor FOR h_sql USING x_dim_table;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;
    */
    SELECT COUNT(*)
    INTO h_count
    FROM bsc_sys_dim_levels_b
    WHERE level_table_name = x_dim_table;

    IF h_count > 0 THEN
        RETURN DIM_TABLE_TYPE_1N;
    END IF;

    -- See if the dimension table is MN
    /*
    h_sql := 'SELECT COUNT(*)'||
             ' FROM bsc_sys_dim_level_rels'||
             ' WHERE relation_col = :1';
    OPEN h_cursor FOR h_sql USING x_dim_table;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;
    */
    SELECT COUNT(*)
    INTO h_count
    FROM bsc_sys_dim_level_rels
    WHERE relation_col = x_dim_table;

    IF h_count > 0 THEN
        RETURN DIM_TABLE_TYPE_MN;
    END IF;

    RETURN DIM_TABLE_TYPE_UNKNOWN;

END Get_Dim_Table_Type;


/*===========================================================================+
| FUNCTION Get_Info_Parents_Dimensions
+============================================================================*/
FUNCTION Get_Info_Parents_Dimensions(
	x_dim_table IN VARCHAR2,
        x_parent_tables IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_parent_keys IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_parents t_cursor; -- x_dim_table
    c_parents_sql VARCHAR2(2000) := 'SELECT dp.level_table_name, dp.level_pk_col'||
                                    ' FROM bsc_sys_dim_levels_b d, bsc_sys_dim_levels_b dp,'||
                                    ' bsc_sys_dim_level_rels r'||
                                    ' WHERE d.dim_level_id = r.dim_level_id AND'||
                                    ' r.parent_dim_level_id = dp.dim_level_id AND'||
                                    ' DECODE(r.relation_type, 2, r.relation_col,'||
                                    ' d.level_table_name) = :1';
    */
    CURSOR c_parents (p_dim_table VARCHAR2) IS
        SELECT dp.level_table_name, dp.level_pk_col
        FROM bsc_sys_dim_levels_b d, bsc_sys_dim_levels_b dp, bsc_sys_dim_level_rels r
        WHERE d.dim_level_id = r.dim_level_id AND
              r.parent_dim_level_id = dp.dim_level_id AND
              DECODE(r.relation_type, 2, r.relation_col, d.level_table_name) = p_dim_table;

    h_parent_table  bsc_sys_dim_levels_b.level_table_name%TYPE;
    h_parent_key  bsc_sys_dim_levels_b.level_pk_col%TYPE;

    h_num_parents NUMBER;

BEGIN
    h_num_parents := 0;

    --OPEN c_parents FOR c_parents_sql USING x_dim_table;
    OPEN c_parents(x_dim_table);
    FETCH c_parents INTO h_parent_table, h_parent_key;
    WHILE c_parents%FOUND LOOP
        h_num_parents := h_num_parents + 1;
        x_parent_tables(h_num_parents) := h_parent_table;
        x_parent_keys(h_num_parents) := h_parent_key;

        FETCH c_parents INTO h_parent_table, h_parent_key;
    END LOOP;
    CLOSE c_parents;

    RETURN h_num_parents;

END Get_Info_Parents_Dimensions;


/*===========================================================================+
| FUNCTION Get_Level_PK_Col
+============================================================================*/
FUNCTION Get_Level_PK_Col(
        x_dimension_table IN VARCHAR2
        ) RETURN VARCHAR2 IS

    h_level_pk_col VARCHAR2(30);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

BEGIN
    /*
    h_sql := 'SELECT level_pk_col'||
             ' FROM bsc_sys_dim_levels_b'||
             ' WHERE level_table_name = :1';
    OPEN h_cursor FOR h_sql USING x_dimension_table;
    FETCH h_cursor INTO h_level_pk_col;
    CLOSE h_cursor;
    */
    SELECT level_pk_col
    INTO h_level_pk_col
    FROM bsc_sys_dim_levels_b
    WHERE level_table_name = x_dimension_table;

    RETURN h_level_pk_col;

END Get_Level_PK_Col;


/*===========================================================================+
| FUNCTION Get_New_Code
+============================================================================*/
FUNCTION Get_New_Code(
	x_dim_table IN VARCHAR2
	) RETURN NUMBER IS

    h_new_code NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);

BEGIN
    h_sql := 'SELECT NVL(MAX(CODE) + 1, 1) FROM '||x_dim_table;

    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_new_code;
    IF h_cursor%NOTFOUND THEN
        h_new_code := -1;
    END IF;
    CLOSE h_cursor;

    RETURN h_new_code;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_BASE.Get_New_Code');
        RETURN -1;

END Get_New_Code;


/*===========================================================================+
| FUNCTION Get_Parent_Dimensions
+============================================================================*/
FUNCTION Get_Parent_Dimensions(
	x_dimension_table IN VARCHAR2,
        x_parent_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
	) RETURN NUMBER IS

    h_num_parent_dimensions NUMBER;

    h_table_id NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);

    /*
    c_parent_dimensions t_cursor; -- h_table_id, 1
    c_parent_dimensions_sql VARCHAR2(2000) := 'SELECT t.level_table_name'||
                                              ' FROM bsc_sys_dim_levels_b t, bsc_sys_dim_level_rels r'||
                                              ' WHERE t.dim_level_id = r.parent_dim_level_id AND'||
                                              ' r.dim_level_id = :1 AND r.relation_type = :2';
    */
    CURSOR c_parent_dimensions (p_dim_level_id NUMBER, p_relation_type NUMBER) IS
        SELECT t.level_table_name
        FROM bsc_sys_dim_levels_b t, bsc_sys_dim_level_rels r
        WHERE t.dim_level_id = r.parent_dim_level_id AND
              r.dim_level_id = p_dim_level_id AND r.relation_type = p_relation_type;

    h_parent_dimension VARCHAR2(30);

BEGIN
    h_num_parent_dimensions := 0;

    -- Get dimension id
    /*
    h_sql := 'SELECT dim_level_id'||
             ' FROM bsc_sys_dim_levels_b'||
             ' WHERE level_table_name = :1';
    OPEN h_cursor FOR h_sql USING x_dimension_table;
    FETCH h_cursor INTO h_table_id;
    CLOSE h_cursor;
    */
    SELECT dim_level_id
    INTO h_table_id
    FROM bsc_sys_dim_levels_b
    WHERE level_table_name = x_dimension_table;

    -- Get parent dimensions
    --OPEN c_parent_dimensions FOR c_parent_dimensions_sql USING h_table_id, 1;
    OPEN c_parent_dimensions (h_table_id, 1);
    FETCH c_parent_dimensions INTO h_parent_dimension;
    WHILE c_parent_dimensions%FOUND LOOP
        h_num_parent_dimensions := h_num_parent_dimensions + 1;
        x_parent_dimensions(h_num_parent_dimensions) := h_parent_dimension;

        FETCH c_parent_dimensions INTO h_parent_dimension;
    END LOOP;
    CLOSE c_parent_dimensions;

    RETURN h_num_parent_dimensions;

END Get_Parent_Dimensions;


/*===========================================================================+
| FUNCTION Get_Relation_Cols
+============================================================================*/
FUNCTION Get_Relation_Cols(
        x_dimension_table IN VARCHAR2,
        x_relation_cols IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2
        ) RETURN NUMBER IS

    TYPE t_cursor IS REF CURSOR;

    /*
    c_relation_cols t_cursor; -- x_dimension_table, 1
    c_relation_cols_sql VARCHAR2(2000) := 'SELECT r.relation_col'||
                                          ' FROM bsc_sys_dim_levels_b d, bsc_sys_dim_level_rels r'||
                                          ' WHERE d.dim_level_id = r.dim_level_id AND'||
                                          ' d.level_table_name = :1 AND r.relation_type = :2';
    */
    CURSOR c_relation_cols (p_level_table_name VARCHAR2, p_relation_type NUMBER) IS
        SELECT r.relation_col
        FROM bsc_sys_dim_levels_b d, bsc_sys_dim_level_rels r
        WHERE d.dim_level_id = r.dim_level_id AND
              d.level_table_name = p_level_table_name AND r.relation_type = p_relation_type;

    h_num_relation_cols NUMBER;
    h_relation_col VARCHAR2(50);

BEGIN
    h_num_relation_cols := 0;

    --OPEN c_relation_cols FOR c_relation_cols_sql USING x_dimension_table, 1;
    OPEN c_relation_cols(x_dimension_table, 1);
    FETCH c_relation_cols INTO h_relation_col;
    WHILE c_relation_cols%FOUND LOOP
        h_num_relation_cols := h_num_relation_cols + 1;
        x_relation_cols(h_num_relation_cols) := h_relation_col;

        FETCH c_relation_cols INTO h_relation_col;
    END LOOP;
    CLOSE c_relation_cols;

    RETURN h_num_relation_cols;

END Get_Relation_Cols;


/*===========================================================================+
| FUNCTION Import_Dbi_Plans
+============================================================================*/
FUNCTION Import_Dbi_Plans(
    x_error_msg IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    l_sql VARCHAR2(32000);

    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;

    l_id NUMBER;
    l_value VARCHAR2(400);

    l_ids BSC_UPDATE_UTIL.t_array_of_number;
    l_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_ids NUMBER;
    l_i NUMBER;
    l_bm_id NUMBER;

    l_dbi_plans_view VARCHAR2(30);
    l_count NUMBER;

BEGIN
    -- fix bug#4046594: Validate that isc_plan_snapshot_v exists
    l_dbi_plans_view := 'ISC_PLAN_SNAPSHOT_V';
    select count(view_name) into l_count
    from user_views
    where view_name = l_dbi_plans_view;
    IF l_count = 0 THEN
        -- isc_plan_snapshot_v does not exists so we cannot import dbi plans
        RETURN TRUE;
    END IF;

    -- Delete from BSC_SYS_BENCHMARKS_B and BSC_SYS_BENCHMARKS_TL the
    -- DBI plans that are no longer valid.
    l_sql := 'DELETE FROM bsc_sys_benchmarks_b'||
             ' WHERE source_type = :1'||
             ' AND data_type NOT IN ('||
             ' SELECT id FROM isc_plan_snapshot_v'||
             ')';
    EXECUTE IMMEDIATE l_sql USING 2;

    DELETE FROM bsc_sys_benchmarks_tl
    WHERE bm_id NOT IN (SELECT bm_id FROM bsc_sys_benchmarks_b);

    -- Insert new dbi plans into BSC_SYS_BENCHMARKS and BSC_SYS_BENCHMARKS_TL
    -- Added s.id < 1000 for bug#6713924
    l_num_ids := 0;
    l_sql := 'SELECT s.id, s.value'||
             ' FROM isc_plan_snapshot_v s, bsc_sys_benchmarks_b b'||
             ' WHERE s.id = b.data_type (+) AND b.source_type (+) = :1 AND b.data_type IS NULL AND s.id < 1000';
    OPEN l_cursor FOR l_sql USING 2;
    LOOP
        FETCH l_cursor INTO l_id, l_value;
        EXIT WHEN l_cursor%NOTFOUND;

        l_num_ids := l_num_ids + 1;
        l_ids(l_num_ids) := l_id;
        l_values(l_num_ids) := l_value;
    END LOOP;
    CLOSE l_cursor;

    FOR l_i IN 1..l_num_ids LOOP
        SELECT NVL(MAX(bm_id)+1,1) INTO l_bm_id
        FROM bsc_sys_benchmarks_b;

        -- This inserts the record in bs_sys_benchmarks_b and tl for existing languages
        BSC_SYS_BENCHMARKS_PKG.Insert_Row(x_bm_id => l_bm_id,
                                          x_color => 0,
                                          x_data_type => l_ids(l_i),
                                          x_source_type => 2,
                                          x_periodicity_id => 0,
                                          x_no_display_flag => 0,
                                          x_name => l_values(l_i));
    END LOOP;

    COMMIT;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        x_error_msg := SQLERRM;
        RETURN FALSE;
END Import_Dbi_Plans;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Import_Dbi_Plans_AT
+============================================================================*/
FUNCTION Import_Dbi_Plans_AT(
    x_error_msg IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Import_Dbi_Plans(x_error_msg);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Import_Dbi_Plans_AT;


/*===========================================================================+
| PROCEDURE Init_Dbi_Dim_Data
+============================================================================*/
PROCEDURE Init_Dbi_Dim_Data IS
    l_i NUMBER;
    l_owner varchar2(100);
BEGIN
    l_i := 0;
    g_dbi_dim_data.delete;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'JTF_ORG_SALES_GROUP';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_JTF_ORG_SALES_GROUP_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+parallel (drg)*/ to_char(drg.id) USER_CODE,to_char(drg.id) CODE '||
    'FROM jtf_rs_dbi_denorm_res_groups drg
    UNION ALL SELECT TO_CHAR(-1111) USER_CODE,TO_CHAR(-1111) CODE FROM dual
    UNION ALL SELECT /*+parallel (drg)*/ to_char(drg.id_for_grp_mem) USER_CODE,to_char(drg.id_for_grp_mem) CODE FROM '||
    'jtf_rs_dbi_denorm_res_groups drg
    UNION ALL SELECT /*+parallel (d1)*/ to_char(d1.group_id) USER_CODE,to_char(d1.group_id) CODE '||
    'FROM jtf_rs_groups_denorm d1) JTF_ORG_SALES_GROUP';
    g_dbi_dim_data(l_i).source_object_alias:='JTF_ORG_SALES_GROUP';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'FII_CURRENCIES';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_FII_CURRENCIES_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    l_owner:=bsc_im_utils.get_table_owner('ENI_DENORM_HIERARCHIES');
    g_dbi_dim_data(l_i).short_name := 'ENI_ITEM_VBH_CAT';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_ENI_ITEM_VBH_CAT_T';
    g_dbi_dim_data(l_i).from_clause := l_owner||'.eni_denorm_hierarchies';
    g_dbi_dim_data(l_i).where_clause := ' where imm_child_id=child_id and imm_child_id=parent_id ';
    g_dbi_dim_data(l_i).recursive_dim := 'YES';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='NO';
    g_dbi_dim_data(l_i).user_code_col := 'parent_id';
    g_dbi_dim_data(l_i).code_col := 'parent_id';
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;
    --  for rec dim
    g_dbi_dim_data(l_i).child_col:='child';
    g_dbi_dim_data(l_i).parent_col:='parent';
    g_dbi_dim_data(l_i).parent_level_col:='parent_level';
    g_dbi_dim_data(l_i).denorm_table:='BSC_D_ENI_ITEM_VBH_CAT_DT';
    g_dbi_dim_data(l_i).child_col_src:='CHILD_ID';
    g_dbi_dim_data(l_i).parent_col_src:='PARENT_ID';
    g_dbi_dim_data(l_i).parent_level_src_col:=null;
    g_dbi_dim_data(l_i).denorm_src_object:='ENI_DENORM_HIERARCHIES';
    --g_dbi_dim_data(l_i).top_n_levels:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    g_dbi_dim_data(l_i).top_n_levels:=100000;--denorm all levels
    g_dbi_dim_data(l_i).top_n_levels_in_mv:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    -----
    g_dbi_dim_data(l_i).source_to_check := NULL;
    g_dbi_dim_data(l_i).denorm_source_to_check := 'ENI_DENORM_HIERARCHIES';

    --3636879
    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'ENI_ITEM_ITM_CAT';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_ENI_ITEM_ITM_CAT_T';
    g_dbi_dim_data(l_i).from_clause := null;
    g_dbi_dim_data(l_i).where_clause := null;
    g_dbi_dim_data(l_i).recursive_dim := 'YES';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := null;
    g_dbi_dim_data(l_i).code_col := null;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;
    --  for rec dim
    g_dbi_dim_data(l_i).child_col:='child';
    g_dbi_dim_data(l_i).parent_col:='parent';
    g_dbi_dim_data(l_i).parent_level_col:='parent_level';
    g_dbi_dim_data(l_i).denorm_table:='BSC_D_ENI_ITEM_ITM_CAT_DT';
    g_dbi_dim_data(l_i).child_col_src:='ID';
    g_dbi_dim_data(l_i).parent_col_src:='PARENT_ID';
    g_dbi_dim_data(l_i).parent_level_src_col:=null;
    g_dbi_dim_data(l_i).denorm_src_object:='ENI_ITEM_ITM_CAT_V';
    --g_dbi_dim_data(l_i).top_n_levels:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    g_dbi_dim_data(l_i).top_n_levels:=100000;--denorm all levels
    g_dbi_dim_data(l_i).top_n_levels_in_mv:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    ---

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'REQUESTTYPE';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_REQUESTTYPE_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'CAMPAIGN';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_CAMPAIGN_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'COUNTRY';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_COUNTRY_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_PER_USRDR_H';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_PER_USRDR_H_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'YES';
    g_dbi_dim_data(l_i).date_tracked_dim := 'YES';
    g_dbi_dim_data(l_i).source_object := 'HRI_CS_SUPH';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := 'sub_person_id';
    g_dbi_dim_data(l_i).code_col := 'sub_person_id';
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;
    --  for rec dim
    g_dbi_dim_data(l_i).child_col:='child';
    g_dbi_dim_data(l_i).parent_col:='parent';
    g_dbi_dim_data(l_i).parent_level_col:='parent_level';
    g_dbi_dim_data(l_i).denorm_table:='BSC_D_HRI_PER_USRDR_H_DT';
    g_dbi_dim_data(l_i).child_col_src:='SUB_PERSON_ID';
    g_dbi_dim_data(l_i).parent_col_src:='SUP_PERSON_ID';
    g_dbi_dim_data(l_i).parent_level_src_col:='SUP_LEVEL';
    g_dbi_dim_data(l_i).denorm_src_object:='HRI_CS_SUPH';
    --g_dbi_dim_data(l_i).top_n_levels:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    g_dbi_dim_data(l_i).top_n_levels:=100000;--denorm all levels
    g_dbi_dim_data(l_i).top_n_levels_in_mv:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    ---
    g_dbi_dim_data(l_i).source_to_check := 'HRI_CS_SUPH';
    g_dbi_dim_data(l_i).denorm_source_to_check := 'HRI_CS_SUPH';

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'ORGANIZATION';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_ORGANIZATION_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'BIX_CALL_CLASSIFICATION';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_BIX_CALL_CLASSIFICATIO_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'BIX_CALL_CENTER';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_BIX_CALL_CENTER_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'BIX_DNIS';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_BIX_DNIS_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'EMAIL ACCOUNT';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_EMAIL_ACCOUNT_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'EMAIL CLASSIFICATION';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_EMAIL_CLASSIFICATION_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    l_owner:=bsc_im_utils.get_table_owner('ENI_OLTP_ITEM_STAR');
    g_dbi_dim_data(l_i).short_name := 'ENI_ITEM_ORG';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_ENI_ITEM_ORG_T';
    g_dbi_dim_data(l_i).from_clause := l_owner||'.ENI_OLTP_ITEM_STAR';
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='NO';
    g_dbi_dim_data(l_i).user_code_col := 'ID';
    g_dbi_dim_data(l_i).code_col := 'ID';
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'FII_OPERATING_UNITS';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_FII_OPERATING_UNITS_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'STORE';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_STORE_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'PLAN_SNAPSHOT';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_PLAN_SNAPSHOT_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'PJI_ORGANIZATIONS';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_PJI_ORGANIZATIONS_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'YES';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := NULL;
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;
    --  for rec dim
    g_dbi_dim_data(l_i).child_col:='child';
    g_dbi_dim_data(l_i).parent_col:='parent';
    g_dbi_dim_data(l_i).parent_level_col:='parent_level';
    g_dbi_dim_data(l_i).denorm_table:='BSC_D_PJI_ORGANIZATIONS_DT';
    g_dbi_dim_data(l_i).child_col_src:='ID';
    g_dbi_dim_data(l_i).parent_col_src:='PARENT_ID';
    g_dbi_dim_data(l_i).parent_level_src_col:=null;
    g_dbi_dim_data(l_i).denorm_src_object:='PJI_ORGANIZATIONS_V';
    --g_dbi_dim_data(l_i).top_n_levels:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    g_dbi_dim_data(l_i).top_n_levels:=100000;--denorm all levels
    g_dbi_dim_data(l_i).top_n_levels_in_mv:=fnd_profile.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');--read adv sum profile
    ---

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'POA_COMMODITIES';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_POA_COMMODITIES_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := 'PO_commodities_B';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := 'commodity_id';
    g_dbi_dim_data(l_i).code_col := 'commodity_id';
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;


    -- Enh#4316042 New dbi dimensions
    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_CL_RQNVAC_VACNCY';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_CL_RQNVAC_VACNCY_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.vacancy_id) USER_CODE,'||
                                         ' to_char(s.vacancy_id) CODE'||
                                         ' FROM per_all_vacancies s'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE'||
                                         ' FROM dual) PER_ALL_VACANCIES_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_ALL_VACANCIES_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_GRADE_BX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_GRADE_BX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.grade_id) USER_CODE,'||
                                         ' to_char(s.grade_id) CODE'||
                                         ' FROM per_grades s'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE'||
                                         ' FROM dual) PER_GRADES_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_GRADES_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_JOB_BX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_JOB_BX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.job_id) USER_CODE,'||
                                         ' to_char(s.job_id) CODE'||
                                         ' FROM per_jobs s'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE'||
                                         ' FROM dual) PER_JOBS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_JOBS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_ORG_HRCYVRSN_BX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_ORG_HRCYVRSN_BX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.org_structure_version_id) USER_CODE,'||
                                         ' to_char(s.org_structure_version_id) CODE'||
                                         ' FROM per_org_structure_versions s) PER_ORG_STRUCTURE_VERSIONS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_ORG_STRUCTURE_VERSIONS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_ORG_HRCY_BX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_ORG_HRCY_BX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.organization_structure_id) USER_CODE,'||
                                         ' to_char(s.organization_structure_id) CODE'||
                                         ' FROM per_organization_structures s) PER_ORGANIZATION_STRUCTURES_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_ORGANIZATION_STRUCTURES_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_ORG_HR_H';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_ORG_HR_H_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) parallel (s1) */ TO_CHAR(s.organization_id) USER_CODE,'||
                                         ' to_char(s.organization_id) CODE'||
                                         ' FROM hr_all_organization_units s, hr_organization_information s1'||
                                         ' WHERE s.organization_id = s1.organization_id AND'||
                                         ' s1.org_information1 = ''HR_ORG'''||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE'||
                                         ' FROM dual) HR_ALL_ORGANIZATION_UNITS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'HR_ALL_ORGANIZATION_UNITS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_ORG_HR_HX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_ORG_HR_HX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) parallel (s1) */ TO_CHAR(s.organization_id) USER_CODE,'||
                                         ' to_char(s.organization_id) CODE'||
                                         ' FROM hr_all_organization_units s, hr_organization_information s1'||
                                         ' WHERE s.organization_id = s1.organization_id AND'||
                                         ' s1.org_information1 = ''HR_ORG'''||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE'||
                                         ' FROM dual) HR_ALL_ORGANIZATION_UNITS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'HR_ALL_ORGANIZATION_UNITS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_ORG_INHV_H';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_ORG_INHV_H_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) parallel (s1) */ DISTINCT'||
                                         ' TO_CHAR(s.organization_id) USER_CODE, to_char(s.organization_id) CODE'||
                                         ' FROM hr_all_organization_units s, hri_org_hrchy_summary s1'||
                                         ' WHERE s.organization_id = s1.organization_id AND s1.sub_org_relative_level = 0'||
                                         ') HR_ALL_ORGANIZATION_UNITS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'HR_ALL_ORGANIZATION_UNITS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_PER_EMP_HX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_PER_EMP_HX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'YES';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.person_id) USER_CODE,'||
                                         ' to_char(s.person_id) CODE,s.effective_start_date, s.effective_end_date'||
                                         ' FROM per_all_people_f s'||
                                         ' WHERE current_employee_flag = ''Y'' AND'||
                                         ' trunc(sysdate) BETWEEN effective_start_date AND effective_end_date'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE,'||
                                         ' hr_general.start_of_time effective_start_date,'||
                                         ' hr_general.end_of_time effective_end_date'||
                                         ' FROM dual) PER_ALL_PEOPLE_F_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_ALL_PEOPLE_F_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_PER_HX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_PER_HX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'YES';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.person_id) USER_CODE,'||
                                         ' to_char(s.person_id) CODE,s.effective_start_date, s.effective_end_date'||
                                         ' FROM per_all_people_f s'||
                                         ' WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date'||
                                         ' ) PER_ALL_PEOPLE_F_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_ALL_PEOPLE_F_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_PER_SUP_HX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_PER_SUP_HX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'YES';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.person_id) USER_CODE,'||
                                         ' to_char(s.person_id) CODE,s.effective_start_date, s.effective_end_date'||
                                         ' FROM per_all_people_f s'||
                                         ' WHERE (current_employee_flag = ''Y'' OR current_npw_flag = ''Y'') AND'||
                                         ' trunc(sysdate) BETWEEN effective_start_date AND effective_end_date AND'||
                                         ' EXISTS (SELECT -1 FROM per_assignments_f asg, per_people_f peo2'||
                                         ' WHERE s.person_id = asg.supervisor_id AND asg.person_id = peo2.person_id AND'||
                                         ' trunc(sysdate) BETWEEN peo2.effective_start_date AND peo2.effective_end_date AND'||
                                         ' trunc(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date AND'||
                                         ' (peo2.current_employee_flag = ''Y'' OR peo2.current_npw_flag = ''Y''))'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE,'||
                                         ' hr_general.start_of_time effective_start_date,'||
                                         ' hr_general.end_of_time effective_end_date'||
                                         ' FROM dual) PER_ALL_PEOPLE_F_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_ALL_PEOPLE_F_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_POSITION';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_POSITION_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'YES';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.position_id) USER_CODE,'||
                                         ' to_char(s.position_id) CODE,s.date_effective effective_start_date,'||
                                         ' NVL(s.date_end, hr_general.end_of_time) effective_end_date'||
                                         ' FROM per_positions s'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE,'||
                                         ' hr_general.start_of_time effective_start_date,'||
                                         ' hr_general.end_of_time effective_end_date'||
                                         ' FROM dual) PER_POSITIONS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_POSITIONS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'HRI_POSITION_HX';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_HRI_POSITION_HX_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'YES';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.position_id) USER_CODE,'||
                                         ' to_char(s.position_id) CODE,s.date_effective effective_start_date,'||
                                         ' NVL(s.date_end, hr_general.end_of_time) effective_end_date'||
                                         ' FROM per_positions s'||
                                         ' WHERE TRUNC(sysdate) <= NVL(s.date_end, hr_general.end_of_time)'||
                                         ' UNION ALL SELECT TO_CHAR(-1) USER_CODE, TO_CHAR(-1) CODE,'||
                                         ' hr_general.start_of_time effective_start_date,'||
                                         ' hr_general.end_of_time effective_end_date'||
                                         ' FROM dual) PER_POSITIONS_S';
    g_dbi_dim_data(l_i).source_object_alias := 'PER_POSITIONS_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'LEGAL ENTITY';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_LEGAL_ENTITY_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (o) parallel (o2) parallel (o3) */'||
                                         ' TO_CHAR(o.organization_id) USER_CODE, to_char(o.organization_id) CODE'||
                                         ' FROM hr_all_organization_units o, hr_organization_information o2,'||
                                         ' hr_organization_information o3'||
                                         ' WHERE o.organization_id = o2.organization_id AND'||
                                         ' o.organization_id = o3.organization_id (+) AND'||
                                         ' o2.org_information_context = ''CLASS'' AND'||
                                         ' o3.org_information_context (+) = ''Legal Entity Accounting'' AND'||
                                         ' o2.org_information1 = ''HR_LEGAL'' AND'||
                                         ' o2.org_information2 = ''Y'') HR_ALL_ORGANIZATION_UNITS_O';
    g_dbi_dim_data(l_i).source_object_alias := 'HR_ALL_ORGANIZATION_UNITS_O';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'OPM COMPANY';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_OPM_COMPANY_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.co_code) USER_CODE, to_char(s.co_code) CODE'||
                                         ' FROM sy_orgn_mst s'||
                                         ' WHERE s.orgn_code = s.co_code) SY_ORGN_MST_S';
    g_dbi_dim_data(l_i).source_object_alias := 'SY_ORGN_MST_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'OPM ORGANIZATION';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_OPM_ORGANIZATION_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ TO_CHAR(s.orgn_code) USER_CODE, to_char(s.orgn_code) CODE'||
                                         ' FROM sy_orgn_mst s) SY_ORGN_MST_S';
    g_dbi_dim_data(l_i).source_object_alias := 'SY_ORGN_MST_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'OPM WAREHOUSE';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_OPM_WAREHOUSE_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ s.whse_code USER_CODE, s.whse_code CODE'||
                                         ' FROM ic_whse_mst s) IC_WHSE_MST_S';
    g_dbi_dim_data(l_i).source_object_alias := 'IC_WHSE_MST_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'JTF_ORG_INTERACTION_CENTER_GRP';
    g_dbi_dim_data(l_i).table_name := 'BSC_D_JTF_ORG_INTERACTION_CE_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := ' (SELECT DISTINCT USER_CODE, CODE FROM '||
                                         ' (SELECT /*+ parallel (s) */ TO_CHAR(s.id) USER_CODE, to_char(s.id) CODE'||
                                         ' FROM jtf_rs_dbi_denorm_res_groups s WHERE s.id IS NOT NULL'||
                                         ' UNION ALL  SELECT TO_CHAR(-1111) USER_CODE, TO_CHAR(-1111) CODE FROM dual'||
                                         ' UNION ALL  SELECT /*+ parallel (s) */ TO_CHAR(s.id_for_grp_mem) USER_CODE,'||
                                         ' to_char(s.id_for_grp_mem) CODE'||
                                         ' FROM jtf_rs_dbi_denorm_res_groups s WHERE s.id_for_grp_mem IS NOT NULL'||
                                         ' UNION ALL SELECT /*+ parallel (s) */ TO_CHAR(s.group_id) USER_CODE,'||
                                         ' to_char(s.group_id) CODE FROM jtf_rs_groups_denorm s WHERE s.group_id IS NOT NULL)'||
                                         ' ) JTF_ORG_INTERACTION_CENTER_S';
    g_dbi_dim_data(l_i).source_object_alias := 'JTF_ORG_INTERACTION_CENTER_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    l_i := l_i + 1;
    g_dbi_dim_data(l_i).short_name := 'ENI_ITEM';
    g_dbi_dim_data(l_i).table_name := 'ENI_D_ENI_ITEM_T';
    g_dbi_dim_data(l_i).from_clause := NULL;
    g_dbi_dim_data(l_i).where_clause := NULL;
    g_dbi_dim_data(l_i).recursive_dim := 'NO';
    g_dbi_dim_data(l_i).date_tracked_dim := 'NO';
    g_dbi_dim_data(l_i).source_object := '(SELECT /*+ parallel (s) */ s.id USER_CODE, s.id CODE'||
                                         ' FROM eni_oltp_item_star s'||
                                         ' WHERE s.master_id is null) ENI_ITEM_S';
    g_dbi_dim_data(l_i).source_object_alias := 'ENI_ITEM_S';
    g_dbi_dim_data(l_i).materialized :='YES';
    g_dbi_dim_data(l_i).user_code_col := NULL;
    g_dbi_dim_data(l_i).code_col := NULL;
    g_dbi_dim_data(l_i).parent1_col := NULL;
    g_dbi_dim_data(l_i).parent2_col := NULL;
    g_dbi_dim_data(l_i).parent3_col := NULL;
    g_dbi_dim_data(l_i).parent4_col := NULL;
    g_dbi_dim_data(l_i).parent5_col := NULL;

    g_dbi_dim_data_set := TRUE;

END Init_Dbi_Dim_Data;


/*===========================================================================+
| FUNCTION Insert_Children_Denorm_Table
+============================================================================*/
FUNCTION Insert_Children_Denorm_Table(
    x_parent_id IN number,
    x_ids IN BSC_UPDATE_UTIL.t_array_of_number,
    x_num_ids IN NUMBER,
    x_level IN NUMBER,
    x_denorm_table IN VARCHAR2,
    x_child_col IN VARCHAR2,
    x_parent_col IN VARCHAR2,
    x_parent_level_col IN VARCHAR2,
    x_denorm_src_object IN VARCHAR2,
    x_child_col_src IN VARCHAR2,
    x_parent_col_src IN VARCHAR2,
    x_src_condition IN VARCHAR2
) RETURN BOOLEAN IS

    l_sql VARCHAR2(32000);
    l_where_cond VARCHAR2(32000);
    l_i NUMBER;
    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;

    l_num_child_ids NUMBER;
    l_child_ids BSC_UPDATE_UTIL.t_array_of_number;
    l_child_id NUMBER;

BEGIN

    IF x_num_ids = 0 THEN
        RETURN TRUE;
    END IF;

    l_where_cond := BSC_APPS.Get_New_Big_In_Cond_Number(-999999, x_parent_col_src);
    FOR l_i IN 1..x_num_ids LOOP
        BSC_APPS.Add_Value_Big_In_Cond(-999999, x_ids(l_i));
    END LOOP;

    l_num_child_ids := 0;
    l_sql := 'SELECT DISTINCT '||x_child_col_src||
             ' FROM '||x_denorm_src_object||
             ' WHERE ';
    IF x_src_condition IS NOT NULL THEN
        l_sql := l_sql||x_src_condition||' AND ';
    END IF;
    l_sql := l_sql||l_where_cond;
    OPEN l_cursor FOR l_sql;
    LOOP
        FETCH l_cursor INTO l_child_id;
        EXIT WHEN l_cursor%NOTFOUND;
        l_num_child_ids := l_num_child_ids + 1;
        l_child_ids(l_num_child_ids) := l_child_id;

        l_sql := 'INSERT INTO '||x_denorm_table||' ('||
                 x_parent_col||', '||x_child_col||', '||x_parent_level_col||
                 ') VALUES (:1, :2, :3)';
        EXECUTE IMMEDIATE l_sql USING x_parent_id, l_child_id, x_level;
    END LOOP;
    -- Fix bug#3899842: Close cursor
    CLOSE l_cursor;

    IF NOT Insert_Children_Denorm_Table(x_parent_id => x_parent_id,
                                        x_ids => l_child_ids,
                                        x_num_ids => l_num_child_ids,
                                        x_level => x_level,
                                        x_denorm_table => x_denorm_table,
                                        x_child_col => x_child_col,
                                        x_parent_col => x_parent_col,
                                        x_parent_level_col => x_parent_level_col,
                                        x_denorm_src_object => x_denorm_src_object,
                                        x_child_col_src => x_child_col_src,
                                        x_parent_col_src => x_parent_col_src,
                                        x_src_condition => x_src_condition) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => l_sql,
                        x_source => 'BSC_UPDATE_DIM.Insert_Children_Denorm_Table');
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Insert_Children_Denorm_Table');
        RETURN FALSE;

END Insert_Children_Denorm_Table;


--RECURSIVE_DIMS: New function
/*===========================================================================+
| FUNCTION Is_Recursive_Dim
+============================================================================*/
FUNCTION Is_Recursive_Dim(
	x_dim_table IN VARCHAR2
	) RETURN BOOLEAN IS
    h_count NUMBER;
BEGIN
    h_count := 0;

    select count(d.dim_level_id)
    into h_count
    from bsc_sys_dim_levels_b d, bsc_sys_dim_level_rels r
    where d.dim_level_id = r.dim_level_id and
          d.level_table_name = x_dim_table and
          r.parent_dim_level_id = r.dim_level_id;

    IF h_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Is_Recursive_Dim;


--AW_INTEGRATION: New procedure
/*===========================================================================+
| FUNCTION Insert_AW_Delete_Value
+============================================================================*/
PROCEDURE Insert_AW_Delete_Value(
    x_dim_table IN VARCHAR2,
    x_delete_value IN VARCHAR2
) IS

    h_sql VARCHAR2(32000);
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_bind_vars NUMBER;

BEGIN

  h_sql := 'INSERT INTO BSC_AW_DIM_DELETE (DIM_LEVEL, DELETE_VALUE)'||
           ' VALUES (:1,:2)';
  l_bind_vars_values.delete;
  l_bind_vars_values(1) := x_dim_table;
  l_bind_vars_values(2) := x_delete_value;
  BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);

END Insert_AW_Delete_Value;


--LOCKING: new procedure
/*===========================================================================+
| PROCEDURE Load_Dim_Into_AW_AT
+============================================================================*/
PROCEDURE Load_Dim_Into_AW_AT (
    x_dim_table IN VARCHAR2
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_dim_level_list dbms_sql.varchar2_table;
BEGIN
    h_dim_level_list.delete;
    h_dim_level_list(1) := x_dim_table;
    bsc_aw_load.load_dim(
        p_dim_level_list => h_dim_level_list,
        p_options => 'DEBUG LOG'
    );
    commit;
END Load_Dim_Into_AW_AT;


/*===========================================================================+
| FUNCTION Load_Dim_Table
+============================================================================*/
FUNCTION Load_Dim_Table(
	x_dim_table IN VARCHAR2,
        x_input_table IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_loading_mode NUMBER;
    h_dim_table_type NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);
    h_i NUMBER;
    h_do_it_flag BOOLEAN;

    h_code NUMBER;
    h_code1 NUMBER;
    h_code2 NUMBER;
    h_user_code VARCHAR2(1000);

    h_deleted_codes BSC_UPDATE_UTIL.t_array_of_number;

    -- BSC-BIS-DIMENSIONS
    -- MN dimension can be created in BSC to store MN relations between BIS dimensions.
    -- To spport NUMBER or VARCHAR2 I will change the type of this arrays to varchar2.
    h_deleted_codes1 BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_deleted_codes2 BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_deleted_codes NUMBER;

    h_table_was_modified BOOLEAN;

    h_parent_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_parent_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_parents NUMBER;

    h_aux_fields BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_aux_fields NUMBER;

    h_installed_languages BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_installed_languages NUMBER;

    h_p_insert VARCHAR2(32700);
    h_p_select VARCHAR2(32700);
    h_p_from VARCHAR2(32700);
    h_p_where VARCHAR2(32700);

    h_aux_insert VARCHAR2(32700);
    h_aux_select VARCHAR2(32700);

    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_bind_vars NUMBER;

    h_safe_user_code VARCHAR2(1000);

    --AW_INTEGRATION: new variables
    h_dim_level_list dbms_sql.varchar2_table;

    h_userenv_lang VARCHAR2(10);

BEGIN
    h_num_deleted_codes := 0;
    h_table_was_modified := FALSE;
    l_num_bind_vars := 0;

    -- Get loading mode
    SELECT generation_type
    INTO h_loading_mode
    FROM bsc_db_tables
    WHERE table_name = x_input_table;

    -- Get dimension table type (1n or MN)
    h_dim_table_type := Get_Dim_Table_Type(x_dim_table);
    IF h_dim_table_type = DIM_TABLE_TYPE_UNKNOWN THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get info of parents
    h_num_parents := Get_Info_Parents_Dimensions(x_dim_table, h_parent_tables, h_parent_keys);

    -- Delete records existing in the dimension table but not in the input table.
    IF h_loading_mode = 1 THEN
        -- Overwrite
        -- Data in the input table represent the complete dimension table
        -- So, we need to delete records existing in the dimension table
        -- but not in the input table.

        IF h_dim_table_type = DIM_TABLE_TYPE_1N THEN
            -- Normal dimension

            -- BSC-BIS-DIMENSIONS: No change here to support NUMBER/VARCHAR2. We only can load
            -- BSC dimensions. Also the array h_deleted_codes can continue to be NUMBER

            h_sql := 'SELECT DISTINCT code FROM '||x_dim_table||
                     ' WHERE code > :1 AND user_code NOT IN ('||
                     ' SELECT user_code FROM '||x_input_table||')';

            OPEN h_cursor FOR h_sql USING 0;
            FETCH h_cursor INTO h_code;
            WHILE h_cursor%FOUND LOOP
                h_num_deleted_codes := h_num_deleted_codes + 1;
                h_deleted_codes(h_num_deleted_codes) := h_code;

                FETCH h_cursor INTO h_code;
            END LOOP;
            CLOSE h_cursor;

            IF h_num_deleted_codes > 0 THEN
                IF NOT Delete_Codes_Cascade(x_dim_table, h_deleted_codes, h_num_deleted_codes) THEN
                    RAISE e_unexpected_error;
                END IF;

                h_table_was_modified := TRUE;
            END IF;
        ELSE
            -- MN dimension
            h_sql := 'SELECT DISTINCT '||h_parent_keys(1)||', '||h_parent_keys(2)||
                     ' FROM '||x_dim_table||
                     ' WHERE ('||h_parent_keys(1)||', '||h_parent_keys(2)||') NOT IN ('||
                     ' SELECT d1.code, d2.code'||
                     ' FROM '||x_input_table||' i, '||h_parent_tables(1)||' d1, '||h_parent_tables(2)||' d2'||
                     ' WHERE i.'||h_parent_keys(1)||'_usr = d1.user_code'||
                     ' AND i.'||h_parent_keys(2)||'_usr = d2.user_code)';

            OPEN h_cursor FOR h_sql;
            FETCH h_cursor INTO h_code1, h_code2;
            WHILE h_cursor%FOUND LOOP
                h_num_deleted_codes := h_num_deleted_codes + 1;
                h_deleted_codes1(h_num_deleted_codes) := h_code1;
                h_deleted_codes2(h_num_deleted_codes) := h_code2;

                FETCH h_cursor INTO h_code1, h_code2;
            END LOOP;
            CLOSE h_cursor;

            IF h_num_deleted_codes > 0 THEN
                IF NOT Delete_Codes_CascadeMN(x_dim_table,
                                              h_parent_keys(1),
                                              h_parent_keys(2),
                                              h_deleted_codes1,
                                              h_deleted_codes2,
                                              h_num_deleted_codes) THEN
                    RAISE e_unexpected_error;
                END IF;

                h_table_was_modified := TRUE;
            END IF;
        END IF;
    END IF;


    -- Update existing records and insert new records

    IF h_dim_table_type = DIM_TABLE_TYPE_1N THEN
        -- 1N dimesion

        -- Get aux fields
        h_num_aux_fields := Get_Aux_Fields_Dim_Table(x_dim_table, h_aux_fields);

        -- Update existing records
        -- Records in the dimension table that are in the input table

        -- Check if there are existing records
        h_sql := 'SELECT DISTINCT code FROM '||x_dim_table||
                 ' WHERE user_code IN ('||
                 ' SELECT user_code FROM '||x_input_table||')';

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_code;
        IF h_cursor%FOUND THEN
            h_do_it_flag := TRUE;
        ELSE
            h_do_it_flag := FALSE;
        END IF;
        CLOSE h_cursor;

        IF h_do_it_flag THEN
            -- There are existing records to update

            -- Udpate the NAME column (MLS)
            h_sql := 'UPDATE '||x_dim_table||' d'||
                     ' SET name = ('||
                     '   SELECT name'||
                     '   FROM '||x_input_table||' i'||
                     '   WHERE i.user_code = d.user_code),'||
                     ' source_lang = :1'||
                     ' WHERE user_code IN (SELECT user_code FROM '||x_input_table||')'||
                     ' AND (language = :2 OR source_lang = :3)';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := userenv('LANG');
            l_bind_vars_values(2) := userenv('LANG');
            l_bind_vars_values(3) := userenv('LANG');
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,3);

            -- Udpate parent key columns
            FOR h_i IN 1 .. h_num_parents LOOP
                -- Check if there is at least one change of parent to mark this dimension as modified (to recalc kpi totals)
                h_sql := 'SELECT user_code FROM '||x_input_table||' i'||
                         ' WHERE '||h_parent_keys(h_i)||'_usr <> ('||
                         ' SELECT DISTINCT '||h_parent_keys(h_i)||'_usr'||
                         ' FROM '||x_dim_table||' d'||
                         ' WHERE d.user_code = i.user_code)';

                OPEN h_cursor FOR h_sql;
                FETCH h_cursor INTO h_user_code;
                IF h_cursor%FOUND THEN
                    h_table_was_modified := TRUE;
                END IF;
                CLOSE h_cursor;

                h_sql := 'UPDATE '||x_dim_table||' d'||
                         ' SET ('||h_parent_keys(h_i)||', '||h_parent_keys(h_i)||'_usr) = ('||
                         '   SELECT DISTINCT p.code, i.'||h_parent_keys(h_i)||'_usr'||
                         '   FROM '||x_input_table||' i, '||h_parent_tables(h_i)||' p'||
                         '   WHERE d.user_code = i.user_code'||
                         '   AND i.'||h_parent_keys(h_i)||'_usr = p.user_code)'||
                         ' WHERE d.user_code IN (SELECT user_code FROM '||x_input_table||')';
                BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
            END LOOP;

            -- Udpate auxiliary fileds
            FOR h_i IN 1 .. h_num_aux_fields LOOP
                h_sql := 'UPDATE '||x_dim_table||' d'||
                         ' SET '||h_aux_fields(h_i)||' = ('||
                         '   SELECT i.'||h_aux_fields(h_i)||
                         '   FROM '||x_input_table||' i'||
                         '   WHERE d.user_code = i.user_code)'||
                         ' WHERE d.user_code IN (SELECT user_code FROM '||x_input_table||')';
                BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
            END LOOP;

            -- Delete existing records from the input table
            h_sql := 'DELETE FROM '||x_input_table||
                     ' WHERE user_code IN (SELECT user_code FROM '||x_dim_table||')';
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

        END IF;

        -- Insert new records from the input table to the dimension table
        -- Get installed languages
        h_num_installed_languages := BSC_UPDATE_UTIL.Get_Installed_Languages(h_installed_languages);
        IF h_num_installed_languages = -1 THEN
            RAISE e_unexpected_error;
        END IF;

        -- Get portion of the sql statement corresponding to the parents
        h_p_insert := NULL;
        h_p_select := NULL;
        h_p_from := NULL;
        h_p_where := NULL;

        FOR h_i IN 1 .. h_num_parents LOOP
            h_p_insert := h_p_insert||', '||h_parent_keys(h_i)||', '||h_parent_keys(h_i)||'_USR';
            h_p_select := h_p_select||', p'||h_i||'.code, i.'||h_parent_keys(h_i)||'_USR';
            h_p_from := h_p_from||', '||h_parent_tables(h_i)||' p'||h_i;
            h_p_where := h_p_where||' AND i.'||h_parent_keys(h_i)||'_USR = p'||h_i||'.user_code'||
                                    ' AND p'||h_i||'.language = USERENV(''LANG'')';
        END LOOP;

        -- Get portion of the sql statement corresponding to aux fields
        h_aux_insert := NULL;
        h_aux_select := NULL;

        FOR h_i IN 1 .. h_num_aux_fields LOOP
            h_aux_insert := h_aux_insert||', '||h_aux_fields(h_i);
            h_aux_select := h_aux_select||', i.'||h_aux_fields(h_i);
        END LOOP;

        -- Insert record by record (we need to get new code for each one)
        h_sql := 'SELECT DISTINCT user_code FROM '||x_input_table;

        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_user_code;
        WHILE h_cursor%FOUND LOOP
            -- Get a new code for this record
            h_code := Get_New_Code(x_dim_table);
            IF h_code = -1 THEN
                RAISE e_unexpected_error;
            END IF;

            -- Insert one record for each installed language
            FOR h_i IN 1 .. h_num_installed_languages LOOP
                h_sql := 'INSERT INTO '||x_dim_table||' ('||
                         ' code, user_code, name'||h_p_insert||h_aux_insert||', language, source_lang)'||
                         ' SELECT :1, i.user_code, i.name'||h_p_select||h_aux_select||
                         ', :2, :3'||
                         ' FROM '||x_input_table||' i'||h_p_from||
                         ' WHERE i.user_code = :4 '||h_p_where;
                --h_p_where looks fine. we may not need binding
                --Venu : because there is a mix of number and varchar variables, executing it here
                --Bug 3092316: no need the replace!!
                --execute immediate h_sql using h_code,h_installed_languages(h_i),REPLACE(h_user_code,'''', '''''');
                h_userenv_lang := USERENV('LANG');
                execute immediate h_sql using h_code,h_installed_languages(h_i),h_userenv_lang,h_user_code;
            END LOOP;

            FETCH h_cursor INTO h_user_code;
        END LOOP;
        CLOSE h_cursor;

    ELSE
        -- MN dimension
        -- Delete existing records from the input table
        h_sql := 'DELETE FROM '||x_input_table||
                 ' WHERE ('||h_parent_keys(1)||'_usr, '||h_parent_keys(2)||'_usr) IN ('||
                 ' SELECT d1.user_code, d2.user_code'||
                 ' FROM '||x_dim_table||' d, '||h_parent_tables(1)||' d1, '||h_parent_tables(2)||' d2'||
                 ' WHERE d.'||h_parent_keys(1)||' = d1.code'||
                 ' AND d.'||h_parent_keys(2)||' = d2.code)';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

        -- Insert new records from the input table to the dimension table
        h_sql := 'INSERT INTO '||x_dim_table||' ('||h_parent_keys(1)||', '||h_parent_keys(2)||')'||
                 ' SELECT p1.code, p2.code'||
                 ' FROM '||x_input_table||' i, '||h_parent_tables(1)||' p1, '||h_parent_tables(2)||' p2'||
                 ' WHERE i.'||h_parent_keys(1)||'_USR = p1.user_code AND p1.language = :1 AND'||
                 ' i.'||h_parent_keys(2)||'_USR = p2.user_code AND p2.language = :2';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := userenv('LANG');
        l_bind_vars_values(2) := userenv('LANG');
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);

    END IF;

    -- Delete data from input table
    BSC_UPDATE_UTIL.Truncate_Table(x_input_table);

    --AW_INTEGRATION: We need to load the dimension into AW even that the dimension
    -- input table is empty
    h_dim_table_type := Get_Dim_Table_Type(x_dim_table);
    IF h_dim_table_type = BSC_UPDATE_DIM.DIM_TABLE_TYPE_1N THEN
        IF Dimension_Used_In_AW_Kpi(x_dim_table) THEN
            h_dim_level_list.delete;
            h_dim_level_list(1) := x_dim_table;
            bsc_aw_load.load_dim(
                p_dim_level_list => h_dim_level_list,
                p_options => 'DEBUG LOG'
            );
        END IF;
    END IF;

    -- Synchronize sec assigments
    IF NOT Sync_Sec_Assigments THEN
        RAISE e_unexpected_error;
    END IF;

    -- Mark indicators using this dimension to be recalculated.
    -- Only if the table was modified.
    IF h_table_was_modified THEN
        UPDATE BSC_KPIS_B K
        SET PROTOTYPE_FLAG = 6,
            LAST_UPDATED_BY = BSC_APPS.fnd_global_user_id,
            LAST_UPDATE_DATE = SYSDATE
        WHERE INDICATOR IN (SELECT D.INDICATOR
                            FROM BSC_KPI_DIM_LEVELS_B D
                            WHERE K.INDICATOR = D.INDICATOR AND
                                  (D.LEVEL_TABLE_NAME = x_dim_table OR
                                   D.TABLE_RELATION = x_dim_table)) AND
              PROTOTYPE_FLAG in (0, 6, 7);

        -- Color By KPI: Mark KPIs for color re-calculation
        UPDATE bsc_kpi_analysis_measures_b k
          SET prototype_flag = BSC_DESIGNER_PVT.C_COLOR_CHANGE -- 7
          WHERE indicator IN (SELECT d.indicator
                              FROM bsc_kpi_dim_levels_b d
                              WHERE k.indicator = d.indicator
                              AND   (d.level_table_name = x_dim_table
                                     OR d.table_relation = x_dim_table));

    END IF;

    COMMIT;

    -- Analyze the dimension table
    BSC_BIA_WRAPPER.Analyze_Table(x_dim_table);

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DIMTABLE_UPDATE_FAILED'),
                      x_source => 'BSC_UPDATE_BASE.Load_Dim_Table');
      RETURN FALSE;

    WHEN OTHERS THEN
      ROLLBACK;
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_BASE.Load_Dim_Table');
      RETURN FALSE;

END Load_Dim_Table;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Load_Dim_Table_AT
+============================================================================*/
FUNCTION Load_Dim_Table_AT(
	x_dim_table IN VARCHAR2,
        x_input_table IN VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Load_Dim_Table(x_dim_table, x_input_table);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Load_Dim_Table_AT;


--LOCKING: new procedure
/*===========================================================================+
| PROCEDURE Load_Type_Into_AW_AT
+============================================================================*/
PROCEDURE Load_Type_Into_AW_AT IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_dim_level_list dbms_sql.varchar2_table;
BEGIN
    h_dim_level_list.delete;
    h_dim_level_list(1) := 'TYPE';
    bsc_aw_load.load_dim(
        p_dim_level_list => h_dim_level_list,
        p_options => 'DEBUG LOG'
    );
    commit;
END Load_Type_Into_AW_AT;


/*===========================================================================+
| FUNCTION Need_Refresh_Dbi_Table
+============================================================================*/
FUNCTION Need_Refresh_Dbi_Table(
    x_table_name IN VARCHAR2,
    x_source_to_check IN VARCHAR2
) RETURN BOOLEAN IS

    l_obj_type VARCHAR2(80);

    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;
    l_sql VARCHAR2(32000);
    l_objs_to_check BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_objs_to_check NUMBER;

    l_max_lud_source DATE;
    l_max_lud DATE;
    l_lud_table DATE;
    l_i NUMBER;

BEGIN
    l_obj_type := 'DIM';

    IF x_source_to_check IS NULL THEN
        -- There is no source objects to compare last update dat with.
        RETURN TRUE;
    END IF;

    -- get last update date of the table from bsc_object_refresh_log
    l_sql := 'SELECT refresh_end_time'||
             ' FROM bsc_object_refresh_log'||
             ' WHERE object_name = :1 AND object_type = :2';
    OPEN l_cursor FOR l_sql USING x_table_name, l_obj_type;
    FETCH l_cursor INTO l_lud_table;
    IF l_cursor%NOTFOUND THEN
        l_lud_table := NULL;
    END IF;
    CLOSE l_cursor;

    IF l_lud_table IS NULL THEN
        -- No info about last update date of the table. So this table need to be refreshed
        RETURN TRUE;
    END IF;


    -- get the max last update date between the source objects
    l_num_objs_to_check := BSC_UPDATE_UTIL.Decompose_Varchar2_List(x_source_to_check, l_objs_to_check, ',');
    l_max_lud_source := NULL;
    FOR l_i IN 1..l_num_objs_to_check LOOP
        l_sql := 'SELECT MAX(last_update_date)'||
                 ' FROM '||l_objs_to_check(l_i);
        OPEN l_cursor FOR l_sql;
        FETCH l_cursor INTO l_max_lud;
        IF l_cursor%NOTFOUND THEN
            l_max_lud := NULL;
        END IF;
        CLOSE l_cursor;
        IF l_max_lud IS NOT NULL THEN
            IF l_max_lud_source IS NULL THEN
                l_max_lud_source := l_max_lud;
            ELSE
                IF l_max_lud > l_max_lud_source THEN
                    l_max_lud_source := l_max_lud;
                END IF;
            END IF;
        END IF;
    END LOOP;

    IF l_max_lud_source IS NULL THEN
        -- NO innfo about last update date of the source. So this table need to be refreshed
        RETURN TRUE;
    END IF;

    IF l_max_lud_source > l_lud_table THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Need_Refresh_Dbi_Table;


/*===========================================================================+
| FUNCTION Refresh_Dbi_Dimension_Table
+============================================================================*/
FUNCTION Refresh_Dbi_Dimension_Table(
        x_dim_short_name IN VARCHAR2
) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    l_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;
    l_sql VARCHAR2(32000);
    l_i NUMBER;
    l_lst_select VARCHAR2(8000);
    l_lst_select_src VARCHAR2(8000);
    l_lst_select_tmp VARCHAR2(8000);
    l_lst_select_tmp_t VARCHAR2(8000);
    l_lst_set VARCHAR2(8000);
    l_lst_set_tmp VARCHAR2(8000);
    l_cond_parents VARCHAR2(8000);
    l_cond_eff_date VARCHAR2(8000);

    l_parent_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_src_parent_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_parent_columns NUMBER;

    l_source_object VARCHAR2(20000);
    l_code varchar2(100);
    l_user_code varchar2(100);
    l_source_object_alias varchar2(100);

    l_dim_obj_type VARCHAR2(80);

    -- AW_INTEGRATION: new variables
    l_level_table_name VARCHAR2(30);
    l_dim_level_list dbms_sql.varchar2_table;
    l_dim_for_aw_kpi BOOLEAN;

    -- RECURSIVE_DIMS: new variables
    l_dim_for_mv_kpi BOOLEAN;
    l_denorm_table_name VARCHAR2(30);

BEGIN
    l_dim_obj_type := 'DIM';

    Get_Dbi_Dim_Data(x_dim_short_name, l_dbi_dim_data);

    -- AW_INTEGRATION: We need to know the level_table_name given the short name
    SELECT level_table_name
    INTO l_level_table_name
    FROM bsc_sys_dim_levels_b
    WHERE short_name = x_dim_short_name;

    -- AW_INTEGRATION: We need to know if the dimension is used by an AW indicator
    l_dim_for_aw_kpi := Dimension_Used_In_AW_Kpi(l_level_table_name);
    l_dim_for_mv_kpi := Dimension_Used_In_MV_Kpi(l_level_table_name);

    IF (l_dbi_dim_data.table_name IS NOT NULL) AND (l_dbi_dim_data.materialized='YES') THEN
        --Fix bug#3780702: If the table does not exist we do not do anything.
        IF BSC_APPS.Table_Exists(l_dbi_dim_data.table_name) THEN
            IF l_dbi_dim_data.source_object IS NULL THEN
                l_source_object := Get_Dbi_Dim_View_Name(x_dim_short_name);
            ELSE
                l_source_object := l_dbi_dim_data.source_object;
            END IF;

            IF l_source_object IS NOT NULL THEN
                -- NOTE: The generic temporary tables needed in this process MUST exist.

                -- We are going to compare the last update date of the source object with
                -- the refresh_end_time of the dimension table to know if it is necessary to
                -- refresh it or not.
                IF Need_Refresh_Dbi_Table(l_dbi_dim_data.table_name, l_dbi_dim_data.source_to_check) THEN

                    -- Udpate REFRESH_START_TIME in BSC_OBJECT_REFRESH_LOG for this table
                    l_sql := 'UPDATE bsc_object_refresh_log'||
                             ' SET refresh_start_time = SYSDATE, refresh_end_time = NULL'||
                             ' WHERE object_name = :1 AND object_type = :2';
                    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.table_name, l_dim_obj_type;
                    IF SQL%NOTFOUND THEN
                        l_sql := 'INSERT INTO bsc_object_refresh_log'||
                                 ' (object_name, object_type, refresh_start_time, refresh_end_time)'||
                                 ' VALUES (:1, :2, SYSDATE, NULL)';
                       EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.table_name, l_dim_obj_type;
                    END IF;
                    COMMIT;

                    -- Get the parent key columns in  an array. It does not include self-relations.
                    l_num_parent_columns := Get_Dbi_Dim_Parent_Columns(x_dim_short_name, l_parent_columns, l_src_parent_columns);

                    l_code:='CODE';
                    IF l_dbi_dim_data.code_col IS NOT NULL THEN
                        l_code := l_dbi_dim_data.code_col;
                    END IF;
                    l_user_code:='USER_CODE';
                    IF l_dbi_dim_data.user_code_col IS NOT NULL THEN
                        l_user_code := l_dbi_dim_data.user_code_col;
                    END IF;
                    l_lst_select := 'USER_CODE,CODE';
                    if l_dbi_dim_data.source_object is null then
                        --for all except hri and po commodities
                        l_lst_select_src := l_user_code||','||l_code;
                    else
                        --for HRI and po commodities
                        l_lst_select_src := l_user_code||',decode(to_char('||l_user_code||'),''0'',''-99999999'','||
                                            'to_char('||l_user_code||')) '||l_code;
                    end if;
                    l_lst_select_tmp := 'USER_CODE,CODE';
                    l_lst_select_tmp_t := 'T.USER_CODE,T.CODE';
                    l_lst_set := NULL;
                    l_lst_set_tmp := NULL;
                    l_cond_parents := NULL;
                    l_cond_eff_date := NULL;

                    IF l_num_parent_columns > 0 THEN
                        FOR l_i IN 1..l_num_parent_columns LOOP
                            l_lst_select := l_lst_select||', '||l_parent_columns(l_i);
                            l_lst_select_src := l_lst_select_src||', '||l_src_parent_columns(l_i);
                            l_lst_select_tmp := l_lst_select_tmp||', PARENT_CODE'||l_i;
                            l_lst_select_tmp_t := l_lst_select_tmp_t||', T.PARENT_CODE'||l_i;

                            IF l_i > 1 THEN
                                l_lst_set := l_lst_set||', ';
                                l_lst_set_tmp := l_lst_set_tmp||', ';
                                l_cond_parents := l_cond_parents||' OR ';
                            END IF;
                            l_lst_set := l_lst_set||l_parent_columns(l_i);
                            l_lst_set_tmp := l_lst_set_tmp||'T.PARENT_CODE'||l_i;
                            l_cond_parents := l_cond_parents||'T.PARENT_CODE'||l_i||' <> B.'||l_parent_columns(l_i);
                        END LOOP;

                        IF l_dbi_dim_data.date_tracked_dim = 'YES' THEN
                            l_lst_select := l_lst_select||', EFFECTIVE_START_DATE, EFFECTIVE_END_DATE';
                            l_lst_select_src := l_lst_select_src||', EFFECTIVE_START_DATE, EFFECTIVE_END_DATE';
                            l_lst_select_tmp := l_lst_select_tmp||', EFFECTIVE_START_DATE, EFFECTIVE_END_DATE';
                            l_lst_select_tmp_t := l_lst_select_tmp_t||', T.EFFECTIVE_START_DATE, T.EFFECTIVE_END_DATE';

                            l_cond_eff_date := 'T.EFFECTIVE_START_DATE = B.EFFECTIVE_START_DATE AND'||
                                               ' T.EFFECTIVE_END_DATE = B.EFFECTIVE_END_DATE';
                        END IF;
                    END IF;

                    --delete the temp tables
                    BSC_UPDATE_UTIL.Execute_Immediate('delete BSC_TMP_DBI_DIM');
                    BSC_UPDATE_UTIL.Execute_Immediate('delete BSC_TMP_DBI_DIM_ADD');
                    BSC_UPDATE_UTIL.Execute_Immediate('delete BSC_TMP_DBI_DIM_DEL');
                    commit;

                    if l_dbi_dim_data.source_object_alias is not null then
                        l_source_object_alias:=l_dbi_dim_data.source_object_alias;
                    else
                        l_source_object_alias:=l_source_object;
                    end if;

                    -- Insert into BSC_TMP_DBI_DIM all items from the view or source object.
                    l_sql := 'INSERT /*+ parallel(BSC_TMP_DBI_DIM) */'||
                             ' INTO BSC_TMP_DBI_DIM ('||l_lst_select_tmp||')'||
                             ' SELECT /*+ parallel('||l_source_object_alias||') */ DISTINCT '||l_lst_select_src||
                             ' FROM '||l_source_object;
                    if bsc_im_utils.g_debug then
                        write_to_log_file_n(l_sql);
                    end if;
                    BSC_UPDATE_UTIL.Execute_Immediate(l_sql);
                    COMMIT;

                    -- Insert BSC_TMP_DBI_DIM.CODE minus DIM_TABLE.CODE (new records) into BSC_TMP_DBI_DIM_ADD
                    l_sql := 'INSERT /*+ parallel(BSC_TMP_DBI_DIM_ADD) */'||
                             ' INTO BSC_TMP_DBI_DIM_ADD (USER_CODE)'||
                             ' SELECT USER_CODE'||
                             ' FROM BSC_TMP_DBI_DIM MINUS select USER_CODE from '||l_dbi_dim_data.table_name;
                    if bsc_im_utils.g_debug then
                        write_to_log_file_n(l_sql);
                    end if;
                    BSC_UPDATE_UTIL.Execute_Immediate(l_sql);
                    COMMIT;

                    -- Insert DIM_TABLE.CODE minus BSC_TMP_DBI_DIM.CODE (records to delete) into BSC_TMP_DBI_DIM_DEL
                    l_sql := 'INSERT /*+ parallel(BSC_TMP_DBI_DIM_DEL) */'||
                             ' INTO BSC_TMP_DBI_DIM_DEL (USER_CODE)'||
                             ' SELECT USER_CODE'||
                             ' FROM '||l_dbi_dim_data.table_name||' MINUS select USER_CODE from BSC_TMP_DBI_DIM';
                    if bsc_im_utils.g_debug then
                        write_to_log_file_n(l_sql);
                    end if;
                    BSC_UPDATE_UTIL.Execute_Immediate(l_sql);
                    COMMIT;

                    -- AW_INTEGRATION: We need to insert the deleted rows into BSC_AW_DIM_DELETE table
                    -- Here we need to inser CODEs not USER_CODEs
                    IF l_dim_for_aw_kpi THEN
                        l_sql := 'INSERT /*+ parallel(BSC_AW_DIM_DELETE) */'||
                                 ' INTO BSC_AW_DIM_DELETE (DIM_LEVEL, DELETE_VALUE)'||
                                 ' SELECT :1, CODE'||
                                 ' FROM '||l_dbi_dim_data.table_name||' MINUS SELECT :2, CODE FROM BSC_TMP_DBI_DIM';
                        if bsc_im_utils.g_debug then
                            write_to_log_file_n(l_sql);
                        end if;
                        EXECUTE IMMEDIATE l_sql USING l_level_table_name, l_level_table_name;
                        COMMIT;
                    END IF;

                    -- Udpate DIM_TABLE
                    IF l_num_parent_columns > 0 THEN
                        l_sql := 'UPDATE '||l_dbi_dim_data.table_name||' B'||
                                 ' SET ('||l_lst_set||') = ('||
                                 ' SELECT '||l_lst_set_tmp||
                                 ' FROM BSC_TMP_DBI_DIM T'||
                                 ' WHERE T.USER_CODE = B.USER_CODE'||
                                 ' )'||
                                 ' WHERE EXISTS ('||
                                 ' SELECT T.USER_CODE'||
                                 ' FROM BSC_TMP_DBI_DIM T'||
                                 ' WHERE T.USER_CODE = B.USER_CODE AND ('||l_cond_parents||')';
                        IF l_cond_eff_date IS NOT NULL THEN
                            l_sql := l_sql||' AND '||l_cond_eff_date;
                        END IF;
                        l_sql := l_sql||' )';
                        if bsc_im_utils.g_debug then
                            write_to_log_file_n(l_sql);
                        end if;
                        BSC_UPDATE_UTIL.Execute_Immediate(l_sql);
                    END IF;

                    -- Insert new rows into DIM_TABLE
                    l_sql := 'INSERT /*+ parallel('||l_dbi_dim_data.table_name||') */'||
                             ' INTO '||l_dbi_dim_data.table_name||' ('||l_lst_select||')'||
                             ' SELECT '||l_lst_select_tmp_t||
                             ' FROM BSC_TMP_DBI_DIM T, BSC_TMP_DBI_DIM_ADD N'||
                             ' WHERE T.USER_CODE = N.USER_CODE';
                    if bsc_im_utils.g_debug then
                        write_to_log_file_n(l_sql);
                    end if;
                    BSC_UPDATE_UTIL.Execute_Immediate(l_sql);

                    -- Delete from DIM_TABLE
                    l_sql :=  'DELETE FROM '||l_dbi_dim_data.table_name||
                              ' WHERE USER_CODE IN (SELECT USER_CODE FROM BSC_TMP_DBI_DIM_DEL)';
                    if bsc_im_utils.g_debug then
                        write_to_log_file_n(l_sql);
                    end if;
                    BSC_UPDATE_UTIL.Execute_Immediate(l_sql);

                    COMMIT;

                    -- Udpate REFRESH_END_TIME in BSC_OBJECT_REFRESH_LOG for this table
                    l_sql := 'UPDATE bsc_object_refresh_log'||
                             ' SET refresh_end_time = SYSDATE'||
                             ' WHERE object_name = :1 AND object_type = :2';
                    EXECUTE IMMEDIATE l_sql USING l_dbi_dim_data.table_name, l_dim_obj_type;
                    COMMIT;
                END IF;
            END IF;
        END IF;
    ELSE
        --AW_INTEGRATION: This is a BIS dimension that is not materialized in BSC
        -- We need to insert the deleted codes into BSC_AW_DIM_DELETE table
        IF l_dim_for_aw_kpi THEN
            -- This procedure will insert into BSC_AW_DIM_DATA all the records
            -- existing in AW for the dimension
            l_dim_level_list.delete;
            l_dim_level_list(1) := l_level_table_name;
            bsc_aw_load.dmp_dim_level_into_table(
                p_dim_level_list => l_dim_level_list,
                p_options => 'DEBUG LOG'
            );

            -- Now we can compare and insert the deleted rows into BSC_AW_DIM_DELETE
            l_sql := 'INSERT /*+ parallel(BSC_AW_DIM_DELETE) */'||
                     ' INTO BSC_AW_DIM_DELETE (DIM_LEVEL, DELETE_VALUE)'||
                     ' SELECT DIM_LEVEL, CODE'||
                     ' FROM BSC_AW_DIM_DATA'||
                     ' WHERE DIM_LEVEL = :1'||
                     ' MINUS '||
                     ' SELECT :2, TO_CHAR(CODE) FROM '||l_level_table_name;
            if bsc_im_utils.g_debug then
                write_to_log_file_n(l_sql);
            end if;
            EXECUTE IMMEDIATE l_sql USING l_level_table_name, l_level_table_name;
            COMMIT;
        END IF;

        -- RECURSIVE_DIMS: Refresh the denorm table. We do this only in MV architecture and
        -- if the dimension is used by a MV indicator
        IF BSC_APPS.bsc_mv AND l_dim_for_mv_kpi THEN
            IF Is_Recursive_Dim(l_level_table_name) THEN
                l_denorm_table_name := BSC_DBGEN_METADATA_READER.get_denorm_dimension_table(x_dim_short_name);
                IF l_denorm_table_name IS NOT NULL THEN
                    IF NOT Refresh_Denorm_Table(l_level_table_name, l_denorm_table_name) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;
            END IF;
        END IF;

    END IF;

    -- Refresh denormalized table for recursive dimensions for materialized DBI dimensions
    IF l_dbi_dim_data.recursive_dim = 'YES' THEN
        IF x_dim_short_name = 'ENI_ITEM_VBH_CAT' THEN
            IF NOT Denorm_Eni_Item_Vbh_Cat THEN
                RAISE e_unexpected_error;
            END IF;
        ELSIF x_dim_short_name = 'ENI_ITEM_ITM_CAT' THEN
            IF NOT Denorm_Eni_Item_Itm_Cat THEN
                RAISE e_unexpected_error;
            END IF;
        ELSIF x_dim_short_name = 'HRI_PER_USRDR_H' THEN
            IF NOT Denorm_Hri_Per_Usrdr_H THEN
                RAISE e_unexpected_error;
            END IF;
        ELSIF x_dim_short_name = 'PJI_ORGANIZATIONS' THEN
            IF NOT Denorm_Pji_Organizations THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;
    END IF;

    -- AW_INTEGRATION: We need to bring the bis dimension into AW world
    IF l_dim_for_aw_kpi THEN
        -- Fix bug#4646856: delete the zero code from bsc_aw_dim_delete table.
        -- we cannot delete the zero code from aw
        l_sql := 'delete from bsc_aw_dim_delete'||
                 ' where dim_level = :1 and delete_value = :2';
        execute immediate l_sql using l_level_table_name, '0';
        commit;
        l_dim_level_list.delete;
        l_dim_level_list(1) := l_level_table_name;
        bsc_aw_load.load_dim(
            p_dim_level_list => l_dim_level_list,
            p_options => 'DEBUG LOG'
        );
    END IF;

    commit;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR'),
                        x_source => 'BSC_UPDATE_DIM.Refresh_Dbi_Dimension_Table');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Refresh_Dbi_Dimension_Table');
        RETURN FALSE;

END Refresh_Dbi_Dimension_Table;

--LOCKING: new function
/*===========================================================================+
| FUNCTION Refresh_Dbi_Dimension_Table_AT
+============================================================================*/
FUNCTION Refresh_Dbi_Dimension_Table_AT(
        x_dim_short_name IN VARCHAR2
) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Refresh_Dbi_Dimension_Table(x_dim_short_name);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Refresh_Dbi_Dimension_Table_AT;


/*===========================================================================+
| PROCEDURE Refresh_DBI_Dimension
+============================================================================*/
PROCEDURE Refresh_Dbi_Dimension(
    ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    x_dim_short_name IN VARCHAR2
) IS

    e_unexpected_error EXCEPTION;
    --LOCKING
    e_could_not_get_lock EXCEPTION;

BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Initialize the error message stack
    BSC_MESSAGE.Init('NO');

    --LOCKING: Lock the dimension
    IF NOT BSC_UPDATE_LOCK.Lock_DBI_Dimension(x_dim_short_name) THEN
        RAISE e_could_not_get_lock;
    END IF;

    -- Refresh the dbi dimension table
    --LOCKING: call the autonomous transaction function
    IF NOT Refresh_Dbi_Dimension_Table_AT(x_dim_short_name) THEN
        RAISE e_unexpected_error;
    END IF;

    --LOCKING: commit to release locks
    COMMIT;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.flush;
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR');
        RETCODE := 2; -- Request completed with errors

    --LOCKING
    WHEN e_could_not_get_lock THEN
        BSC_MESSAGE.flush;
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        ERRBUF := 'Loader could not get the required locks to continue.';
        RETCODE := 2; -- Request completed with errors

    WHEN OTHERS THEN
        ROLLBACK;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Refresh_Dbi_Dimension',
                        x_mode => 'I');
        COMMIT;

        BSC_UPDATE_LOG.Write_Errors_To_Log;

        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UNEXPECTED_ERROR');
        RETCODE := 2; -- Request completed with errors

END Refresh_Dbi_Dimension;


-- RECURSIVE_DIMS: new function
/*===========================================================================+
| FUNCTION Refresh_Denorm_Table
+============================================================================*/
FUNCTION Refresh_Denorm_Table(
    x_level_table_name IN VARCHAR2,
    x_denorm_table_name IN VARCHAR2
) RETURN BOOLEAN IS

    l_sql VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    l_cursor t_cursor;

    l_level_view_name VARCHAR2(30);
    l_level_pk_col VARCHAR2(30);

    norm_child dbms_sql.varchar2_table;
    norm_parent dbms_sql.varchar2_table;
    levels dbms_sql.number_table;
    parents dbms_sql.varchar2_table;
    --
    denorm_child dbms_sql.varchar2_table;
    denorm_parent dbms_sql.varchar2_table;
    dp_level dbms_sql.number_table;
    dc_level dbms_sql.number_table;
    --
    prev_p dbms_sql.varchar2_table;
    prev_p_level dbms_sql.number_table;
    last_p varchar2(400);
    last_level number;
    child_level number;


BEGIN

    IF NOT BSC_APPS.Table_Exists(x_denorm_table_name) THEN
        -- Denorm table does not exists
        RETURN TRUE;
    END IF;

    -- Fix bug#5079365, use level_pk_col instead of relation_col
    --select d.level_view_name, r.relation_col
    --into l_level_view_name, l_level_pk_col
    --from bsc_sys_dim_levels_b d, bsc_sys_dim_level_rels r
    --where d.dim_level_id = r.dim_level_id and
    --      d.level_table_name = x_level_table_name and
    --      r.dim_level_id = r.parent_dim_level_id;
    select level_view_name, level_pk_col
    into l_level_view_name, l_level_pk_col
    from bsc_sys_dim_levels_b
    where level_table_name = x_level_table_name;

    l_sql := 'select distinct code'||
             ' from '||l_level_view_name||
             ' where '||l_level_pk_col||' is null';
    open l_cursor for l_sql;
    loop
        fetch l_cursor bulk collect into parents;
        exit when l_cursor%notfound;
    end loop;
    close l_cursor;
    --
    denorm_child.delete;
    denorm_parent.delete;
    dc_level.delete;
    dp_level.delete;
    --
    for i in 1..parents.count loop
        norm_child.delete;
        norm_parent.delete;
        l_sql := 'select '||l_level_pk_col||', code, level'||
                 ' from '||l_level_view_name||
                 ' start with '||l_level_pk_col||' = :1'||
                 ' connect by prior code = '||l_level_pk_col;
        open l_cursor for l_sql using parents(i);
        loop
            fetch l_cursor bulk collect into norm_parent, norm_child, levels;
            exit when l_cursor%notfound;
        end loop;
        close l_cursor;
        --
        prev_p.delete;
        last_level := null;
        last_p := null;
        child_level := null;
        --
        --add the root node first
        denorm_parent(denorm_parent.count+1):=parents(i);
        denorm_child(denorm_parent.count):=parents(i);
        dp_level(denorm_parent.count):=1;
        dc_level(denorm_parent.count):=1;
        --
        for j in 1..norm_parent.count loop
            --delete prev_p if needed. if we come up again, only then we delete from prev_p
            if last_level>levels(j) then
                for k in reverse 1..prev_p.count loop
                    if prev_p(k)=norm_parent(j) then
                        for m in k..prev_p.count loop
                            prev_p.delete(m);
                            prev_p_level.delete(m);
                        end loop;
                        exit;
                    end if;
                end loop;
            end if;
            --now insert
            child_level:=levels(j)+1;
            denorm_parent(denorm_parent.count+1):=norm_parent(j);
            denorm_child(denorm_parent.count):=norm_child(j);
            dp_level(denorm_parent.count):=levels(j);
            dc_level(denorm_parent.count):=child_level;
            --now, add elements to prev_p
            if last_level<levels(j) then
                prev_p(prev_p.count+1):=last_p;
                prev_p_level(prev_p.count):=last_level;
            end if;
            --now, add denorm records
            for k in 1..prev_p.count loop
                denorm_parent(denorm_parent.count+1):=prev_p(k);
                denorm_child(denorm_parent.count):=norm_child(j);
                dp_level(denorm_parent.count):=prev_p_level(k);
                dc_level(denorm_parent.count):=child_level;
            end loop;
            --add self level for child
            denorm_parent(denorm_parent.count+1):=norm_child(j);
            denorm_child(denorm_parent.count):=norm_child(j);
            dp_level(denorm_parent.count):=child_level;
            dc_level(denorm_parent.count):=child_level;
            --now, populate the state variables
            last_level:=levels(j);
            last_p:=norm_parent(j);
            --
        end loop;
    end loop;

    -- update the denorm table
    IF BSC_UPDATE_UTIL.Table_Has_Any_Row(x_denorm_table_name) THEN
        -- Incremental load
        BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_DNT');

        forall i in 1..denorm_parent.count
            execute immediate 'insert into bsc_tmp_dnt (parent_code, code, child_level, parent_level)'||
                              ' values (:1, :2, :3, :4)'
            using denorm_parent(i), denorm_child(i), dc_level(i), dp_level(i);
        commit;

        l_sql := 'delete from '||x_denorm_table_name||
                 ' where (parent_code, code, child_level, parent_level) in ('||
                 ' select parent_code, code, child_level, parent_level'||
                 ' from '||x_denorm_table_name||
                 ' minus'||
                 ' select parent_code, code, child_level, parent_level'||
                 ' from bsc_tmp_dnt'||
                 ' )';
        execute immediate l_sql;

        l_sql := 'insert into '||x_denorm_table_name||' (parent_code, code, child_level, parent_level)'||
                 ' select parent_code, code, child_level, parent_level'||
                 ' from bsc_tmp_dnt'||
                 ' minus'||
                 ' select parent_code, code, child_level, parent_level'||
                 ' from '||x_denorm_table_name;
        execute immediate l_sql;
        commit;
    ELSE
        -- Initial Load
        forall i in 1..denorm_parent.count
            execute immediate 'insert into '||x_denorm_table_name||
                              ' (parent_code, code, child_level, parent_level)'||
                              ' values (:1, :2, :3, :4)'
            using denorm_parent(i), denorm_child(i), dc_level(i), dp_level(i);
        commit;
    END IF;

    commit;
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Refresh_Denorm_Table');
        RETURN FALSE;
END Refresh_Denorm_Table;


/*===========================================================================+
| FUNCTION Refresh_EDW_Dimension
+============================================================================*/
FUNCTION Refresh_EDW_Dimension(
        x_dimension_table IN VARCHAR2,
	x_mod_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_mod_dimensions IN OUT NOCOPY NUMBER,
	x_checked_dimensions IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_checked_dimensions IN OUT NOCOPY NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);

    h_relation_cols BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_relation_cols NUMBER;
    h_lst_relation_cols_desc VARCHAR2(32700);
    h_lst_relation_cols VARCHAR2(32700);

    h_level_pk_col VARCHAR2(30);

    h_deleted_records BSC_UPDATE_UTIL.t_array_of_number;
    h_num_deleted_records NUMBER;

    h_condition VARCHAR2(32700);

    h_i NUMBER;

    h_child_dimensions BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_child_dimensions NUMBER;
    h_parent_dimensions BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_parent_dimensions NUMBER;


BEGIN
    h_num_relation_cols := 0;
    h_num_deleted_records := 0;
    h_num_child_dimensions := 0;
    h_num_parent_dimensions := 0;

    -- It is possible to try to refresh a dimension which was previously refreshed
    -- because of the cascade logical. To prevent this, we insert the dimension into the array
    -- x_checked dimensions.
    IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(x_dimension_table,
                                                         x_checked_dimensions,
                                                         x_num_checked_dimensions) THEN

        BSC_UPDATE_LOG.Write_Line_Log(x_dimension_table, BSC_UPDATE_LOG.OUTPUT);

        -- Add the dimension to the array x_checked dimensions
        x_num_checked_dimensions := x_num_checked_dimensions + 1;
        x_checked_dimensions(x_num_checked_dimensions) := x_dimension_table;

        -- Get some information about this dimension table
            -- Get level pk column name
            h_level_pk_col := Get_Level_PK_Col(x_dimension_table);
            -- Get relation cols
            h_num_relation_cols := Get_Relation_Cols(x_dimension_table, h_relation_cols);

        -- Create a temporal table with the current data
        -- Only we are interested in CODE and relation columns.
        -- Remember that in EDW all relations are 1-n
            -- Drop table if exits
            IF NOT BSC_UPDATE_UTIL.Drop_Table('BSC_TMP_DIMENSION') THEN
                RAISE e_unexpected_error;
            END IF;

            -- Create the table
            h_lst_relation_cols := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(h_relation_cols, h_num_relation_cols);
            h_lst_relation_cols_desc := BSC_UPDATE_UTIL.Make_Lst_Description(h_relation_cols, h_num_relation_cols, 'NUMBER');
            IF h_lst_relation_cols IS NOT NULL THEN
                h_lst_relation_cols := ', '||h_lst_relation_cols;
                h_lst_relation_cols_desc := ', '||h_lst_relation_cols_desc;
            END IF;

            h_sql := 'CREATE TABLE BSC_TMP_DIMENSION ('||
                     'CODE NUMBER'||h_lst_relation_cols_desc||
                     ') TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.other_table_tbs_type)||
                     ' '||BSC_APPS.bsc_storage_clause;
            BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_TABLE, 'BSC_TMP_DIMENSION');

            -- Insert records
            h_sql := 'INSERT INTO BSC_TMP_DIMENSION (CODE'||h_lst_relation_cols||')'||
                     ' SELECT CODE'||h_lst_relation_cols||
                     ' FROM '||x_dimension_table;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

            -- Create unique index
            IF NOT BSC_UPDATE_UTIL.Create_Unique_Index('BSC_TMP_DIMENSION',
                                                       'BSC_TMP_DIMENSION_U1',
                                                       'CODE',
                                                       BSC_APPS.other_index_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;

        -- Refresh dimension table (materialized view)
        DBMS_MVIEW.REFRESH(BSC_APPS.BSC_APPS_SCHEMA||'.'||x_dimension_table, 'AF', NULL, FALSE, FALSE, 0, 0, 0, TRUE);

        -- Get deleted records (records in BSC_TMP_DIMENSION that are not in x_dimension_table)
        h_num_deleted_records := Get_Deleted_Records(x_dimension_table, 'BSC_TMP_DIMENSION', h_deleted_records);

        IF h_num_deleted_records > 0 THEN
            -- Delete from all system tables rows for deleted values

            -- h_condition := BSC_UPDATE_UTIL.Make_Lst_Cond_Number(h_level_pk_col, h_deleted_records, h_num_deleted_records, 'OR');
            h_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, h_level_pk_col);
            FOR h_i IN 1..h_num_deleted_records LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, h_deleted_records(h_i));
            END LOOP;

            IF NOT Delete_Key_Values_In_Tables(h_level_pk_col, h_condition) THEN
                RAISE e_unexpected_error;
            END IF;

            -- Add the dimension table to the array of modified dimensions
            IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(x_dimension_table,
                                                                 x_mod_dimensions,
                                                                 x_num_mod_dimensions) THEN
                -- Add the dimension to the array x_checked dimensions
                x_num_mod_dimensions := x_num_mod_dimensions + 1;
                x_mod_dimensions(x_num_mod_dimensions) := x_dimension_table;
            END IF;
        END IF;

        IF h_num_relation_cols > 0 THEN
            -- Check if any dimension item changed any relation
            IF Any_Item_Changed_Any_Relation(x_dimension_table, 'BSC_TMP_DIMENSION', h_relation_cols, h_num_relation_cols) THEN
                -- Add the dimension table to the array of modified dimensions
                IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(x_dimension_table,
                                                                     x_mod_dimensions,
                                                                     x_num_mod_dimensions) THEN
                    -- Add the dimension to the array x_checked dimensions
                    x_num_mod_dimensions := x_num_mod_dimensions + 1;
                    x_mod_dimensions(x_num_mod_dimensions) := x_dimension_table;
                END IF;
            END IF;
        END IF;

        -- Drop the temporal table
        IF NOT BSC_UPDATE_UTIL.Drop_Table('BSC_TMP_DIMENSION') THEN
           RAISE e_unexpected_error;
        END IF;

        -- Refresh child dimensions
        h_num_child_dimensions := Get_Child_Dimensions(x_dimension_table, h_child_dimensions);
        FOR h_i IN 1..h_num_child_dimensions LOOP
            IF NOT Refresh_EDW_Dimension(h_child_dimensions(h_i),
                                         x_mod_dimensions,
                                         x_num_mod_dimensions,
                                         x_checked_dimensions,
                                         x_num_checked_dimensions) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;


        -- Refresh parent dimensions
        h_num_parent_dimensions := Get_Parent_Dimensions(x_dimension_table, h_parent_dimensions);
        FOR h_i IN 1..h_num_parent_dimensions LOOP
            IF NOT Refresh_EDW_Dimension(h_parent_dimensions(h_i),
                                         x_mod_dimensions,
                                         x_num_mod_dimensions,
                                         x_checked_dimensions,
                                         x_num_checked_dimensions) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;

    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_REFRESH_EDW_DIM_FAILED'),
                        x_source => 'BSC_UPDATE_DIM.Refresh_EDW_Dimension');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Refresh_EDW_Dimension');
        RETURN FALSE;
END Refresh_EDW_Dimension;



/*===========================================================================+
| FUNCTION Refresh_EDW_Dimensions
+============================================================================*/
FUNCTION Refresh_EDW_Dimensions(
	x_dimension_tables IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_dimension_tables IN NUMBER
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_mod_dimensions BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_mod_dimensions NUMBER;
    h_checked_dimensions BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_checked_dimensions NUMBER;
    h_i NUMBER;

BEGIN
    h_num_mod_dimensions := 0;
    h_num_checked_dimensions := 0;

    -- Refresh each dimension. It will be adding modified dimension in the array
    -- Also, it will delete from B, S tables the deleted dimension values
    BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_REFRESHING_EDW_DIM'), BSC_UPDATE_LOG.OUTPUT);
    FOR h_i IN 1 .. x_num_dimension_tables LOOP
        IF NOT Refresh_EDW_Dimension(x_dimension_tables(h_i),
                                     h_mod_dimensions,
                                     h_num_mod_dimensions,
                                     h_checked_dimensions,
                                     h_num_checked_dimensions) THEN
            RAISE e_unexpected_error;
        END IF;
    END LOOP;

    -- Changing a dimension table may affect the totals of the KPIs using
    -- that dimension.
    -- This procedure mark the affected KPIs with prototype 6 (Recalc data).
    -- Once the kpis are marked, Incremental changes will re calculate the data.
    IF h_num_mod_dimensions > 0 THEN
        BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_RECALC_KPI_DIMTABLES'), BSC_UPDATE_LOG.OUTPUT);
        FOR h_i IN 1..h_num_mod_dimensions LOOP

            UPDATE BSC_KPIS_B K
            SET PROTOTYPE_FLAG = 6,
                LAST_UPDATED_BY = BSC_APPS.fnd_global_user_id,
                LAST_UPDATE_DATE = SYSDATE
                WHERE INDICATOR IN (SELECT D.INDICATOR
                                    FROM BSC_KPI_DIM_LEVELS_B D
                                    WHERE K.INDICATOR = D.INDICATOR AND
                                          D.LEVEL_TABLE_NAME = h_mod_dimensions(h_i)) AND
                      PROTOTYPE_FLAG in (0, 6, 7);

            -- Color By KPI: Mark KPIs for color re-calculation
            UPDATE bsc_kpi_analysis_measures_b k
	      SET prototype_flag = BSC_DESIGNER_PVT.C_COLOR_CHANGE -- 7
              WHERE indicator IN (SELECT d.indicator
                                  FROM bsc_kpi_dim_levels_b d
                                  WHERE k.indicator = d.indicator
                                  AND   d.level_table_name = h_mod_dimensions(h_i));

            COMMIT;
        END LOOP;
    END IF;

    -- Synchronize sec assigments
    IF NOT Sync_Sec_Assigments THEN
        RAISE e_unexpected_error;
    END IF;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_REFRESH_EDW_DIM_FAILED'),
                        x_source => 'BSC_UPDATE_DIM.Refresh_EDW_Dimensions');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Refresh_EDW_Dimensions');
        RETURN FALSE;

END Refresh_EDW_Dimensions;


/*===========================================================================+
| FUNCTION Sync_Sec_Assigments
+============================================================================*/
FUNCTION Sync_Sec_Assigments RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_dim_level_id NUMBER;
    h_level_table_name VARCHAR2(30);
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_bind_vars NUMBER;

    CURSOR c_list IS
        SELECT DISTINCT L.DIM_LEVEL_ID, D.LEVEL_TABLE_NAME
        FROM BSC_SYS_COM_DIM_LEVELS L, BSC_SYS_DIM_LEVELS_B D
        WHERE L.DIM_LEVEL_ID = D.DIM_LEVEL_ID;

BEGIN
    l_num_bind_vars := 0;

    -- Get the dimension id and dimension table name for the dimension involved
    -- in any list of any tab
    /*
    h_sql := 'SELECT DISTINCT L.DIM_LEVEL_ID, D.LEVEL_TABLE_NAME'||
             ' FROM BSC_SYS_COM_DIM_LEVELS L, BSC_SYS_DIM_LEVELS_B D'||
             ' WHERE L.DIM_LEVEL_ID = D.DIM_LEVEL_ID';
    */
    --OPEN h_cursor FOR h_sql;
    OPEN c_list;
    FETCH c_list INTO h_dim_level_id, h_level_table_name;
    WHILE c_list%FOUND LOOP
        -- Delete from BSC_USER_LIST_ACCESS the records which dimension value
        -- doest not exist in the dimension table. It deletes all the list assigment
        -- for the responsibility in the tab. So if a list in a tab
        -- have more that one dimension, if one of them becomes invalid because the
        -- dimension value doest not belong to the dimension table, all dimensions
        -- for that tab and for that responsibility will be deleted.

        -- BSC-BIS-DIMENSIONS: The table column DIM_LEVEL_VALUE in BSC_USER_LIST_ACCESS
        -- it is now VARCHAR2 to support BIS/BSC dimensions. So changing condition to use '0'

        h_sql := 'DELETE FROM BSC_USER_LIST_ACCESS'||
                 ' WHERE (RESPONSIBILITY_ID, TAB_ID) IN ('||
                 ' SELECT LA.RESPONSIBILITY_ID, LA.TAB_ID'||
                 ' FROM BSC_SYS_COM_DIM_LEVELS L, BSC_USER_LIST_ACCESS LA'||
                 ' WHERE L.TAB_ID = LA.TAB_ID'||
                 ' AND L.DIM_LEVEL_INDEX = LA.DIM_LEVEL_INDEX'||
                 ' AND L.DIM_LEVEL_ID = :1'||
                 ' AND LA.DIM_LEVEL_VALUE <> ''0'''||
                 ' AND LA.DIM_LEVEL_VALUE NOT IN ('||
                 ' SELECT CODE FROM '||h_level_table_name||'))';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := TO_CHAR(h_dim_level_id);
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);

        FETCH c_list INTO h_dim_level_id, h_level_table_name;
    END LOOP;
    CLOSE c_list;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_DIM.Sync_Sec_Assigments');
       RETURN FALSE;

END Sync_Sec_Assigments;


/*===========================================================================+
| FUNCTION Validate_Input_Table
+============================================================================*/
FUNCTION Validate_Input_Table(
	x_input_table IN VARCHAR2,
        x_dim_table IN VARCHAR2
	) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    h_dim_table_type NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);

    h_parent_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_parent_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_parents NUMBER;

    h_aux_fields BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_aux_fields NUMBER;

    h_i NUMBER;

    h_invalid BOOLEAN;

    h_null VARCHAR2(250);

    h_loading_mode NUMBER;
    l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    l_num_bind_vars NUMBER;

    h_num_rows NUMBER;

BEGIN

    l_num_bind_vars := 0;

    -- Delete the current invalid codes of input table
    /*
    h_sql := 'DELETE FROM bsc_db_validation'||
             ' WHERE input_table_name = :1';
    EXECUTE IMMEDIATE h_sql USING x_input_table;
    */
    DELETE FROM bsc_db_validation
    WHERE input_table_name = x_input_table;

    -- Get type of dimension table
    h_dim_table_type := Get_Dim_Table_Type(x_dim_table);
    IF h_dim_table_type = DIM_TABLE_TYPE_UNKNOWN THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get loading mode
    /*
    h_sql := 'SELECT generation_type'||
             ' FROM bsc_db_tables'||
             ' WHERE table_name = :1';
    OPEN h_cursor FOR h_sql USING x_input_table;
    FETCH h_cursor INTO h_loading_mode;
    CLOSE h_cursor;
    */
    SELECT generation_type
    INTO h_loading_mode
    FROM bsc_db_tables
    WHERE table_name = x_input_table;

    h_null := BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'NULL');
    --Fix bug#2562867 The lookup can contain single quotes
    h_null := REPLACE(h_null,'''', '''''');

    IF h_dim_table_type = DIM_TABLE_TYPE_1N THEN
        -- Validate USER_CODE
        -- Must be not null and diffent from '0' --> USER_CODE '0' correspondi by design to CODE = 0
        -- and we dong allow to import this value.

        -- BSC-BIS-DIMENSIONS: No need to change here. We only support to load input tables
        -- for BSC dimensions. They always have VARCHAR2 in USER_CODE.

        h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code)
                  SELECT DISTINCT :1, ''USER_CODE'',
                  NVL(USER_CODE,:2)
                  FROM '||x_input_table||'
                  WHERE NVL(USER_CODE, ''0'') = ''0''';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := x_input_table;
        l_bind_vars_values(2) := h_null;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);

        -- Validate NAME
        -- Must be not null
        h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code)
                  SELECT DISTINCT :1, ''NAME'', :2
                  FROM '||x_input_table||'
                  WHERE NAME IS NULL';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := x_input_table;
        l_bind_vars_values(2) := h_null;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,2);

        -- NAME should not be duplicated
        IF h_loading_mode = 1 THEN
            -- Overwrite
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code)
                  SELECT DISTINCT :1, ''NAME'', name
                  FROM '||x_input_table||'
                  WHERE name IS NOT NULL
                  GROUP BY name
                  HAVING count(*) > 1';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := x_input_table;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,1);
        ELSE
            -- Add/Update
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code)
                  SELECT DISTINCT :1, :2, name
                  FROM (SELECT user_code, name
                        FROM '||x_input_table||'
                        UNION
                        SELECT d.user_code, d.name
                        FROM '||x_dim_table||' d, '||x_input_table||' i
                        WHERE d.user_code = i.user_code (+) AND i.user_code IS NULL AND
                              d.language = :3 AND d.source_lang = :4)
                  WHERE name IS NOT NULL
                  GROUP BY name
                  HAVING count(*) > 1';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := x_input_table;
            l_bind_vars_values(2) := 'NAME';
            l_bind_vars_values(3) := userenv('LANG');
            l_bind_vars_values(4) := userenv('LANG');
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,4);
        END IF;
    END IF;

    -- Validate parents
    h_num_parents := Get_Info_Parents_Dimensions(x_dim_table, h_parent_tables, h_parent_keys);
    FOR h_i IN 1 .. h_num_parents LOOP
        -- Value must exist in the parent table (nulls will be catched here) and
        -- cannot be '0' becasue no item can be child of total.

        -- BSC-BIS-DIMENSIONS Note: A BSC dimension could have a BIS dimension as parent.
        -- So the parent key can be NUMBER/VARCHAR2. The following query will support both cases.

        h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code)
                  SELECT DISTINCT :1, :2,
                  NVL(TO_CHAR('||h_parent_keys(h_i)||'_USR), :3)
                  FROM '||x_input_table||'
                  WHERE NVL(TO_CHAR('||h_parent_keys(h_i)||'_USR), ''0'') NOT IN (
                  SELECT TO_CHAR(USER_CODE) FROM '||h_parent_tables(h_i)||' WHERE TO_CHAR(USER_CODE) <> ''0'')';
        l_bind_vars_values.delete;
        l_bind_vars_values(1) := x_input_table;
        l_bind_vars_values(2) := h_parent_keys(h_i)||'_USR';
        l_bind_vars_values(3) := h_null;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,3);
    END LOOP;

    -- Validate auxiliar fields
    IF h_dim_table_type = DIM_TABLE_TYPE_1N THEN
        h_num_aux_fields := Get_Aux_Fields_Dim_Table(x_dim_table, h_aux_fields);
        FOR h_i IN 1 .. h_num_aux_fields LOOP
            -- Must be not null
            h_sql := 'INSERT INTO bsc_db_validation (input_table_name, column_name, invalid_code)
                      SELECT DISTINCT :1, :2, :3
                      FROM '||x_input_table||'
                      WHERE '||h_aux_fields(h_i)||' IS NULL';
            l_bind_vars_values.delete;
            l_bind_vars_values(1) := x_input_table;
            l_bind_vars_values(2) := h_aux_fields(h_i);
            l_bind_vars_values(3) := h_null;
            BSC_UPDATE_UTIL.Execute_Immediate(h_sql,l_bind_vars_values,3);
        END LOOP;
    END IF;

    -- Check if there were invalid codes
    /*
    h_sql := 'SELECT COUNT(*) FROM BSC_DB_VALIDATION'||
             ' WHERE ROWNUM < :1 AND INPUT_TABLE_NAME = :2';
    OPEN h_cursor FOR h_sql USING 2, x_input_table;
    FETCH h_cursor INTO h_num_rows;
    CLOSE h_cursor;
    */
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
                      x_source => 'BSC_UPDATE_DIM.Validate_Input_Table');
      RETURN NULL;

    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_DIM.Validate_Input_Table');
      RETURN NULL;
END Validate_Input_Table;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Validate_Input_Table_AT
+============================================================================*/
FUNCTION Validate_Input_Table_AT(
	x_input_table IN VARCHAR2,
        x_dim_table IN VARCHAR2
	) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Validate_Input_Table(x_input_table, x_dim_table);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Validate_Input_Table_AT;


/*===========================================================================+
| FUNCTION WriteRemovedKeyItems
+============================================================================*/
FUNCTION WriteRemovedKeyItems RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    /*
    c_indicators t_cursor;
    c_indicators_sql VARCHAR2(2000) := 'SELECT d.indicator, d.level_table_name, d.default_key_value'||
                                       ' FROM bsc_kpi_dim_levels_b d, bsc_kpis_b k'||
                                       ' WHERE d.indicator = k.indicator AND'||
                                       ' d.default_key_value IS NOT NULL';
    */
    CURSOR c_indicators IS
        SELECT d.indicator, d.level_table_name, d.default_key_value
        FROM bsc_kpi_dim_levels_b d, bsc_kpis_b k
        WHERE d.indicator = k.indicator AND
              d.default_key_value IS NOT NULL;

    h_indicator 	NUMBER;
    h_level_table_name  bsc_kpi_dim_levels_b.level_table_name%TYPE;
    h_default_key_value bsc_kpi_dim_levels_b.default_key_value%TYPE;

    h_sql		VARCHAR2(32700);

    h_code		NUMBER;

    h_header		BOOLEAN;

    C_INDICATOR_W 	CONSTANT NUMBER := 15;
    C_DIMENSION_TABLE_W CONSTANT NUMBER := 35;
    C_DEFAULT_VALUE_W 	CONSTANT NUMBER := 15;

BEGIN
    h_header := FALSE;

    --OPEN c_indicators FOR c_indicators_sql;
    OPEN c_indicators;
    FETCH c_indicators INTO h_indicator, h_level_table_name, h_default_key_value;
    WHILE c_indicators%FOUND LOOP

        h_sql := 'SELECT code FROM '||h_level_table_name||
                 ' WHERE code = :1';

        OPEN h_cursor FOR h_sql USING h_default_key_value;
        FETCH h_cursor INTO h_code;
        IF h_cursor%NOTFOUND THEN
            -- The default value wa deleted
            IF NOT h_header THEN
                BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);
                BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                              BSC_UPDATE_LOG.OUTPUT);
                BSC_UPDATE_LOG.Write_Line_Log(BSC_UPDATE_UTIL.Get_Message('BSC_DFT_DIMVALUE_MISSING'), BSC_UPDATE_LOG.OUTPUT);
                BSC_UPDATE_LOG.Write_Line_Log('+---------------------------------------------------------------------------+',
                                              BSC_UPDATE_LOG.OUTPUT);
                BSC_UPDATE_LOG.Write_Line_Log(RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_BACKEND', 'KPI_CODE'), C_INDICATOR_W)||
                           RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_TABLE_NAME'), C_DIMENSION_TABLE_W)||
                           RPAD(BSC_UPDATE_UTIL.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'DEFAULT_VALUE'), C_DEFAULT_VALUE_W),
                           BSC_UPDATE_LOG.OUTPUT);
                h_header := TRUE;
            END IF;

            --Fix bug#4080680 do not use TO_CHAR(h_defualt_key_value)
            BSC_UPDATE_LOG.Write_Line_Log(RPAD(TO_CHAR(h_indicator), C_INDICATOR_W)||
                           RPAD(h_level_table_name, C_DIMENSION_TABLE_W)||
                           RPAD(h_default_key_value, C_DEFAULT_VALUE_W),
                           BSC_UPDATE_LOG.OUTPUT);
        END IF;
        CLOSE h_cursor;

        FETCH c_indicators INTO h_indicator, h_level_table_name, h_default_key_value;
    END LOOP;
    CLOSE c_indicators;

    BSC_UPDATE_LOG.Write_Line_Log('', BSC_UPDATE_LOG.OUTPUT);

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      BSC_MESSAGE.Add(x_message => SQLERRM,
                      x_source => 'BSC_UPDATE_DIM.WriteRemovedKeyItems');
      RETURN FALSE;

END WriteRemovedKeyItems;

procedure write_to_log_file(p_message varchar2) is
Begin
  BSC_IM_UTILS.write_to_log_file(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
end;


END BSC_UPDATE_DIM;

/
