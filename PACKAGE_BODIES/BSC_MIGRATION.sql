--------------------------------------------------------
--  DDL for Package Body BSC_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MIGRATION" AS
/* $Header: BSCSMIGB.pls 120.58.12010000.2 2008/08/11 09:34:46 sirukull ship $ */

-- Global variables
g_metadata_tables   t_metadata_tables;
g_num_metadata_tables   NUMBER := 0;

g_src_resps t_array_of_number;  -- array with the source responsibility ids
g_num_src_resps NUMBER := 0;
g_trg_resps t_array_of_number;  -- array with the target responsibility ids
g_num_trg_resps NUMBER := 0;

g_tabs_filter   t_array_of_number;  -- array with the tabs in the filter
g_num_tabs_filter NUMBER := 0;
g_kpis_filter   t_array_of_number;  -- array with the KPIs in the filter
g_num_kpis_filter NUMBER := 0;

g_mig_tabs    t_array_of_number;  -- array with the tabs to be migrated
g_num_mig_tabs    NUMBER := 0;
g_mig_kpis    t_array_of_number;  -- array with the kpis to be migrated
g_num_mig_kpis    NUMBER := 0;
g_mig_tables    t_array_of_varchar2;  -- array with the tables to be migrated
g_num_mig_tables  NUMBER := 0;

g_src_apps_flag BOOLEAN;    -- True: source system is an apps system
g_src_bsc_schema VARCHAR2(30);  -- BSC schema name in source system
g_sysadmin_user_id NUMBER;    -- User id for SYSADMIN user in the target system

g_warnings BOOLEAN := FALSE;

/*===========================================================================+
  this flag will check that if migration failed after syncup, in that
  case we will not do the sync up again while exiting, else we will do sync up
  before exit.
+============================================================================*/
g_syncup_done BOOLEAN; -- bug fix 6004972
g_error_synch_bsc_pmf EXCEPTION;
g_invalid_pmf_measures    t_array_of_varchar2;  -- array with PMF measures that not exist in the target
g_num_invalid_pmf_measures  NUMBER := 0;
g_invalid_pmf_dimensions  t_array_of_varchar2;  -- array with PMF dimensions that not exist in the target
g_num_invalid_pmf_dimensions  NUMBER := 0;
g_invalid_pmf_dim_levels  t_array_of_varchar2;  -- array with PMF dimension levels that not exist in the target
g_num_invalid_pmf_dim_levels  NUMBER := 0;
g_invalid_kpis      t_array_of_number;  -- array with invalid kpis
g_num_invalid_kpis    NUMBER := 0;
g_no_mig_kpis                   t_array_of_number;  -- array of kpis that cannot be migrated
g_num_no_mig_kpis   NUMBER := 0;

-- Enh#4697749 new global variables
g_migrated_ak_regions     t_array_of_varchar2;
g_num_migrated_ak_regions       NUMBER := 0;
g_migrated_functions          t_array_of_varchar2;
g_num_migrated_functions        NUMBER := 0;

--BSC-MV Note: variable to store the summarization level from the source.
--This value is gotten from BSC_SYS_INIT in the source
-- g_adv_sum_level = NULL means current architecture.
-- g_adv_sum_level <> NULL means BSC-MV/V architecture
g_adv_sum_level NUMBER := NULL;

g_adv_mig_features VARCHAR2(100) := NULL;

-- Constants
--- commented for bug 5583119
---c_version    CONSTANT VARCHAR2(10) := '5.3.0';
c_fto_long_date_time  CONSTANT VARCHAR2(30) := 'Month DD, YYYY HH24:MI:SS';

c_comments_tbl CONSTANT VARCHAR2(30) := 'BSC_KPI_COMMENTS';
c_comments_bak CONSTANT VARCHAR2(30) := 'BSC_KPI_COMMENTS_BAK';

--bug 6004972 sync up api to be called in case of failures or exiting from migration
PROCEDURE sync_bis_bsc_metadata(h_error_msg OUT NOCOPY VARCHAR2) IS
BEGIN
  -- --------------------------------------------------------------------
  -- Synchronize Dimensions and Measures between BSC-PMF
  -- --------------------------------------------------------------------
  IF NOT BSC_UPGRADES.Synchronize_Dim_Objects(h_error_msg) THEN
     RAISE g_error_synch_bsc_pmf;
  END IF;

  IF NOT BSC_UPGRADES.Synchronize_Dimensions(h_error_msg) THEN
     RAISE g_error_synch_bsc_pmf;
  END IF;

  IF NOT BSC_UPGRADES.synchronize_measures(h_error_msg) THEN
     RAISE g_error_synch_bsc_pmf;
  END IF;
END sync_bis_bsc_metadata;

PROCEDURE syncup_dataset_id_in_target IS
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(2000);

    h_count NUMBER;
    h_short_name BIS_INDICATORS.SHORT_NAME%TYPE;
    h_dataset_id BIS_INDICATORS.DATASET_ID%TYPE;

BEGIN
    h_sql := 'SELECT DISTINCT si.short_name,si.dataset_id'||
             ' FROM bis_indicators@'||g_db_link||' si'||
             ', bsc_sys_datasets_b@'||g_db_link||' sd'||
             ' WHERE sd.dataset_id = si.dataset_id AND'||
             ' si.created_by NOT IN (:2, :3, :4, :5)';
    IF(h_cursor%ISOPEN) THEN
       CLOSE h_cursor;
    END IF;
    OPEN h_cursor FOR h_sql USING 1, 2,120,121;
    LOOP
      FETCH h_cursor INTO h_short_name,h_dataset_id;
      EXIT WHEN h_cursor%NOTFOUND;
      --EXECUTE IMMEDIATE h_upd_stmt USING h_dataset_id,h_short_name;
      UPDATE bis_indicators SET dataset_id = h_dataset_id WHERE short_name = h_short_name;
    END LOOP;
    CLOSE h_cursor;

    COMMIT;
EXCEPTION --ignore the exception if any
  WHEN OTHERS THEN
       ROLLBACK;
       BSC_MESSAGE.Add(x_message => 'Error in syncup dataset ids'||sqlerrm,
                        x_source => 'BSC_MIGRATION.Migrate_System');
       COMMIT;
       IF(h_cursor%ISOPEN) THEN
             CLOSE h_cursor;
       END IF;
END;

/*===========================================================================+
| FUNCTION Assign_Target_Responsibilities
+============================================================================*/
FUNCTION Assign_Target_Responsibilities RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    e_add_roles_scorecard EXCEPTION;

    h_error_msg VARCHAR2(2000);

    h_sql VARCHAR2(32000);
    h_condition VARCHAR2(32000);

    h_message VARCHAR2(4000);
    h_i NUMBER;
    h_j NUMBER;

    h_dist_trg_resps t_array_of_number;
    h_num_dist_trg_resps NUMBER := 0;

    h_decode_lst VARCHAR2(32000);
    h_tab_condition VARCHAR2(32000);
    h_kpi_condition VARCHAR2(32000);
    h_src_resps_condition VARCHAR2(32000);

    h_property_code VARCHAR2(50);


BEGIN
    h_message := BSC_APPS.Get_Message('BSC_MIG_ASG_KPIS_TO_RESPS');
    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

    -- Delete current assigments
    h_sql := 'DELETE FROM bsc_user_tab_access';
    BSC_APPS.Execute_Immediate(h_sql);

    h_sql := 'DELETE FROM bsc_user_list_access';
    BSC_APPS.Execute_Immediate(h_sql);

    h_sql := 'DELETE FROM bsc_user_kpi_access';
    BSC_APPS.Execute_Immediate(h_sql);

    -- Transfer source assigments to target
    -- Initialize the array of distinct target responsibilities
    h_num_dist_trg_resps := 0;
    FOR h_i IN 1..g_num_trg_resps LOOP
        IF NOT Item_Belong_To_Array_Number(g_trg_resps(h_i), h_dist_trg_resps, h_num_dist_trg_resps) THEN
            h_num_dist_trg_resps := h_num_dist_trg_resps + 1;
            h_dist_trg_resps(h_num_dist_trg_resps) := g_trg_resps(h_i);
        END IF;
    END LOOP;

    -- Assign each different target responsibility base on his source responsibilities
    h_tab_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'tab_id');
    FOR h_i IN 1 .. g_num_mig_tabs LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, g_mig_tabs(h_i));
    END LOOP;

    h_kpi_condition := BSC_APPS.Get_New_Big_In_Cond_Number(2, 'indicator');
    FOR h_i IN 1 .. g_num_mig_kpis LOOP
        BSC_APPS.Add_Value_Big_In_Cond(2, g_mig_kpis(h_i));
    END LOOP;

    FOR h_i IN 1..h_num_dist_trg_resps LOOP
        -- Get the componets for the queries
        h_decode_lst := NULL;

        h_src_resps_condition := BSC_APPS.Get_New_Big_In_Cond_Number(3, 'responsibility_id');
        FOR h_j IN 1..g_num_trg_resps LOOP
            IF g_trg_resps(h_j) = h_dist_trg_resps(h_i) THEN
                IF h_decode_lst IS NULL THEN
                    h_decode_lst := g_src_resps(h_j)||', '||h_dist_trg_resps(h_i);
                ELSE
                    h_decode_lst := h_decode_lst||', '||g_src_resps(h_j)||', '||h_dist_trg_resps(h_i);
                END IF;

                BSC_APPS.Add_Value_Big_In_Cond(3, g_src_resps(h_j));
            END IF;
        END LOOP;

        -- Transfer responsibilities for this target responsibility. All this logica is because
        -- one target responsibility can correspond to many source responsibilities.
        -- Also one source responsibility can correspond to many target responsibilities. We need
        -- to be careful with the unique constraints in the access tables.

        -- BSC_USER_TAB_ACCESS
        h_sql := 'INSERT INTO bsc_user_tab_access (responsibility_id, tab_id, creation_date,'||
                 ' created_by, last_update_date, last_updated_by, last_update_login, start_date,'||
                 ' end_date)'||
                 ' SELECT DECODE (responsibility_id, '||h_decode_lst||'), tab_id, MAX(creation_date),'||
                 ' MAX(created_by), MAX(last_update_date), MAX(last_updated_by), MAX(last_update_login),'||
                 ' MAX(start_date), MAX(end_date)'||
                 ' FROM bsc_user_tab_access@'||g_db_link||
                 ' WHERE ('||h_src_resps_condition||')';
        IF h_tab_condition IS NOT NULL THEN
            h_sql := h_sql||' AND ('||h_tab_condition||')';
        END IF;
        h_sql := h_sql||' GROUP BY DECODE(responsibility_id, '||h_decode_lst||'), tab_id';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_USER_LIST_ACCESS
        h_sql := 'INSERT INTO bsc_user_list_access (responsibility_id, tab_id, dim_level_index,'||
                 ' dim_level_value, creation_date, created_by, last_update_date, last_updated_by,'||
                 ' last_update_login)'||
                 ' SELECT DECODE (responsibility_id, '||h_decode_lst||'), tab_id, dim_level_index,'||
                 ' MIN(dim_level_value), MAX(creation_date), MAX(created_by), MAX(last_update_date),'||
                 ' MAX(last_updated_by), MAX(last_update_login)'||
                 ' FROM bsc_user_list_access@'||g_db_link||
                 ' WHERE ('||h_src_resps_condition||')';
        IF h_tab_condition IS NOT NULL THEN
            h_sql := h_sql||' AND ('||h_tab_condition||')';
        END IF;
        h_sql := h_sql||' GROUP BY DECODE(responsibility_id, '||h_decode_lst||'), tab_id, dim_level_index';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_USER_KPI_ACCESS
        h_sql := 'INSERT INTO bsc_user_kpi_access (responsibility_id, indicator, creation_date,'||
                 ' created_by, last_update_date, last_updated_by, last_update_login, start_date,'||
                 ' end_date)'||
                 ' SELECT DECODE (responsibility_id, '||h_decode_lst||'), indicator, MAX(creation_date),'||
                 ' MAX(created_by), MAX(last_update_date), MAX(last_updated_by), MAX(last_update_login),'||
                 ' MAX(start_date), MAX(end_date)'||
                 ' FROM bsc_user_kpi_access@'||g_db_link||
                 ' WHERE ('||h_src_resps_condition||')';
        IF h_kpi_condition IS NOT NULL THEN
            h_sql := h_sql||' AND ('||h_kpi_condition||')';
        END IF;
        h_sql := h_sql||' GROUP BY DECODE(responsibility_id, '||h_decode_lst||'), indicator';
        BSC_APPS.Execute_Immediate(h_sql);

    END LOOP;

    -- Assign custom links to the target responsibilities based on the accessibility of the source
    -- responsibilities
    IF BSC_APPS.APPS_ENV AND g_src_apps_flag THEN
        -- Source and target systems are in APPS
        FOR h_i IN 1..g_num_trg_resps LOOP
            IF NOT BSC_LAUNCH_PAD_PVT.Migrate_Custom_Links_Security(g_trg_resps(h_i), g_src_resps(h_i), g_db_link) THEN
               RAISE e_unexpected_error;
            END IF;
        END LOOP;
    END IF;

    -- Fix bug#3831534 It will grant Designer Role (update Acess) to all design user
    -- (user with BSC_Manager or BSC_DESIGNER)
    h_property_code := 'GRANT_ROLE_TAB';

    delete from bsc_sys_init
    where property_code = h_property_code;
    commit;

    IF NOT BSC_UPGRADES_GENERIC.upgrade_role_to_tabs(h_error_msg) THEN
        RAISE e_add_roles_scorecard;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_MIG_FAIL_EXEC'),
                         x_source => 'BSC_MIGRATION.Assign_Target_Responsibilities');
        RETURN FALSE;

    WHEN e_add_roles_scorecard THEN
        BSC_MESSAGE.Add (x_message => h_error_msg,
                         x_source => 'BSC_MIGRATION.Assign_Target_Responsibilities');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Assign_Target_Responsibilities');
        RETURN FALSE;

END Assign_Target_Responsibilities;


/*===========================================================================+
| FUNCTION Check_Languages_TL_Tables
+============================================================================*/
FUNCTION Check_Languages_TL_Tables RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_src_languages t_array_of_varchar2;
    h_num_src_languages NUMBER := 0;
    h_trg_languages t_array_of_varchar2;
    h_num_trg_languages NUMBER := 0;

    h_src_base_language VARCHAR2(4);

    h_lang_code VARCHAR2(4);
    h_installed_flag VARCHAR2(1);

    h_i NUMBER;
    h_j NUMBER;
    h_table_name VARCHAR2(30);
    h_sql VARCHAR2(32700);

    h_column_name VARCHAR2(30);
    h_lst_insert VARCHAR2(32700);
    h_lst_select VARCHAR2(32700);

    CURSOR c_columns IS
        SELECT column_name
        FROM user_tab_columns
        WHERE table_name = UPPER(h_table_name);

    CURSOR c_columns_apps IS
        SELECT column_name
        FROM all_tab_columns
        WHERE table_name = UPPER(h_table_name) AND
              owner = UPPER(BSC_APPS.BSC_APPS_SCHEMA);

BEGIN
    -- Get supported languages in source system
    h_sql := 'SELECT DISTINCT language_code, installed_flag'||
             ' FROM fnd_languages@'||g_db_link||
             ' WHERE installed_flag IN (:1, :2)';
    OPEN h_cursor FOR h_sql USING 'B', 'I';
    h_num_src_languages := 0;
    LOOP
        FETCH h_cursor INTO h_lang_code, h_installed_flag;
        EXIT WHEN h_cursor%NOTFOUND;

        h_num_src_languages := h_num_src_languages + 1;
        h_src_languages(h_num_src_languages) := h_lang_code;

        IF h_installed_flag = 'B' THEN
            h_src_base_language := h_lang_code;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- Get supported languages in target system
    h_sql := 'SELECT DISTINCT language_code'||
             ' FROM fnd_languages'||
             ' WHERE installed_flag IN (:1, :2)';
    OPEN h_cursor FOR h_sql USING 'B', 'I';
    h_num_trg_languages := 0;
    LOOP
        FETCH h_cursor INTO h_lang_code;
        EXIT WHEN h_cursor%NOTFOUND;

        h_num_trg_languages := h_num_trg_languages + 1;
        h_trg_languages(h_num_trg_languages) := h_lang_code;
    END LOOP;
    CLOSE h_cursor;


    -- Fix _TL tables according to supported languages in the target system
    FOR h_i IN 1..g_num_metadata_tables LOOP
        IF g_metadata_tables(h_i).lang_flag THEN
            h_table_name := g_metadata_tables(h_i).table_name;

            -- For each language in the target system:
            -- If language is not supported in the source system then
            -- we generate the records for the target language based
            -- on the base language of the source system
            FOR h_j IN 1..h_num_trg_languages LOOP
                IF NOT Item_Belong_To_Array_Varchar2(h_trg_languages(h_j),
                                                     h_src_languages,
                                                     h_num_src_languages) THEN
                    h_lst_insert := NULL;
                    h_lst_select := NULL;
                    IF NOT BSC_APPS.APPS_ENV THEN
                        -- Personal mode
                        OPEN c_columns;
                        FETCH c_columns INTO h_column_name;
                        WHILE c_columns%FOUND LOOP
                            IF h_lst_insert IS NOT NULL THEN
                                h_lst_insert := h_lst_insert||', ';
                                h_lst_select := h_lst_select||', ';
                            END IF;

                            h_lst_insert := h_lst_insert||h_column_name;

                            IF UPPER(h_column_name) = 'LANGUAGE' THEN
                                h_lst_select := h_lst_select||''''||h_trg_languages(h_j)||'''';
                            ELSE
                                h_lst_select := h_lst_select||h_column_name;
                            END IF;

                            FETCH c_columns INTO h_column_name;
                        END LOOP;
                        CLOSE c_columns;
                    ELSE
                        -- Apps mode
                        OPEN c_columns_apps;
                        FETCH c_columns_apps INTO h_column_name;
                        WHILE c_columns_apps%FOUND LOOP
                            IF h_lst_insert IS NOT NULL THEN
                                h_lst_insert := h_lst_insert||', ';
                                h_lst_select := h_lst_select||', ';
                            END IF;

                            h_lst_insert := h_lst_insert||h_column_name;

                            IF UPPER(h_column_name) = 'LANGUAGE' THEN
                                h_lst_select := h_lst_select||''''||h_trg_languages(h_j)||'''';
                            ELSE
                                h_lst_select := h_lst_select||h_column_name;
                            END IF;

                            FETCH c_columns_apps INTO h_column_name;
                        END LOOP;
                        CLOSE c_columns_apps;
                    END IF;

                    h_sql := 'INSERT INTO '||h_table_name||' ('||h_lst_insert||')'||
                             ' SELECT '||h_lst_select||
                             ' FROM '||h_table_name||
                             ' WHERE LANGUAGE = :1';
                             /* ' WHERE LANGUAGE = '''||h_src_base_language||'''';*/

                    EXECUTE IMMEDIATE h_sql USING h_src_base_language;

                   /* BSC_APPS.Execute_Immediate(h_sql);            */

                END IF;
            END LOOP;

            -- Delete records of source languages that dont exists in the
            -- target system
            FOR h_j IN 1..h_num_src_languages LOOP
                IF NOT Item_Belong_To_Array_Varchar2(h_src_languages(h_j),
                                                     h_trg_languages,
                                                     h_num_trg_languages) THEN
                    h_sql := 'DELETE FROM '||h_table_name||
                         ' WHERE LANGUAGE = :1';
                            /* ' WHERE LANGUAGE = '''||h_src_languages(h_j)||'''';*/
                              EXECUTE IMMEDIATE h_sql USING h_src_languages(h_j);

                   /*BSC_APPS.Execute_Immediate(h_sql);            */
                END IF;
            END LOOP;

            COMMIT;
        END IF;
    END LOOP;

    -- Fix dimension tables. They are TL tables too.
    h_sql :=  'SELECT level_table_name'||
              ' FROM bsc_sys_dim_levels_b'||
              ' WHERE nvl(source, ''BSC'') = ''BSC''';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table_name;
        EXIT WHEN h_cursor%NOTFOUND;

        -- For each language in the target system:
        -- If language is not supported in the source system then
        -- we generate the records for the target language based
        -- on the base language of the source system
        FOR h_j IN 1..h_num_trg_languages LOOP
            IF NOT Item_Belong_To_Array_Varchar2(h_trg_languages(h_j),
                                                 h_src_languages,
                                                 h_num_src_languages) THEN
                h_lst_insert := NULL;
                h_lst_select := NULL;
                IF NOT BSC_APPS.APPS_ENV THEN
                    -- Personal mode
                    OPEN c_columns;
                    FETCH c_columns INTO h_column_name;
                    WHILE c_columns%FOUND LOOP
                        IF h_lst_insert IS NOT NULL THEN
                            h_lst_insert := h_lst_insert||', ';
                            h_lst_select := h_lst_select||', ';
                        END IF;

                        h_lst_insert := h_lst_insert||h_column_name;

                        IF UPPER(h_column_name) = 'LANGUAGE' THEN
                            h_lst_select := h_lst_select||''''||h_trg_languages(h_j)||'''';
                        ELSE
                            h_lst_select := h_lst_select||h_column_name;
                        END IF;

                        FETCH c_columns INTO h_column_name;
                    END LOOP;
                    CLOSE c_columns;
                ELSE
                    -- Apps mode
                    OPEN c_columns_apps;
                    FETCH c_columns_apps INTO h_column_name;
                    WHILE c_columns_apps%FOUND LOOP
                        IF h_lst_insert IS NOT NULL THEN
                            h_lst_insert := h_lst_insert||', ';
                            h_lst_select := h_lst_select||', ';
                        END IF;

                        h_lst_insert := h_lst_insert||h_column_name;

                        IF UPPER(h_column_name) = 'LANGUAGE' THEN
                            h_lst_select := h_lst_select||''''||h_trg_languages(h_j)||'''';
                        ELSE
                            h_lst_select := h_lst_select||h_column_name;
                        END IF;

                        FETCH c_columns_apps INTO h_column_name;
                    END LOOP;
                    CLOSE c_columns_apps;
                END IF;

                h_sql := 'INSERT INTO '||h_table_name||' ('||h_lst_insert||')'||
                         ' SELECT '||h_lst_select||
                         ' FROM '||h_table_name||
                         ' WHERE LANGUAGE = :1';
                 EXECUTE IMMEDIATE h_sql USING h_src_base_language;
            END IF;
        END LOOP;

        -- Delete records of source languages that dont exists in the
        -- target system
        FOR h_j IN 1..h_num_src_languages LOOP
            IF NOT Item_Belong_To_Array_Varchar2(h_src_languages(h_j),
                                                 h_trg_languages,
                                                 h_num_trg_languages) THEN
                h_sql := 'DELETE FROM '||h_table_name||
                         ' WHERE LANGUAGE = :1';
                         EXECUTE IMMEDIATE h_sql USING h_src_languages(h_j);
            END IF;
        END LOOP;

        COMMIT;

    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Check_Languages_TL_Tables');
        RETURN FALSE;
END Check_Languages_TL_Tables;


/*===========================================================================+
| PROCEDURE Clean_Metadata_Invalid_PMF
+============================================================================*/
PROCEDURE Clean_Metadata_Invalid_PMF IS

    h_sql VARCHAR2(32000);
    h_condition VARCHAR2(32000);
    h_i NUMBER;

BEGIN
    -- Clean metadata from invalid measures

    IF g_num_invalid_pmf_measures > 0 THEN
        h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'short_name');
        FOR h_i IN 1 .. g_num_invalid_pmf_measures LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, g_invalid_pmf_measures(h_i));
        END LOOP;

        -- BSC_SYS_DATASET_CALC
        h_sql := 'DELETE FROM bsc_sys_dataset_calc'||
                 ' WHERE dataset_id IN ('||
                 '   SELECT dataset_id'||
                 '   FROM bsc_sys_datasets_b'||
                 '   WHERE measure_id1 IN ('||
                 '     SELECT measure_id'||
                 '     FROM bsc_sys_measures'||
                 '     WHERE '||h_condition||
                 '     )'||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DATASETS_TL
        h_sql := 'DELETE FROM bsc_sys_datasets_tl'||
                 ' WHERE dataset_id IN ('||
                 '   SELECT dataset_id'||
                 '   FROM bsc_sys_datasets_b'||
                 '   WHERE measure_id1 IN ('||
                 '     SELECT measure_id'||
                 '     FROM bsc_sys_measures'||
                 '     WHERE '||h_condition||
                 '     )'||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DATASETS_B
        h_sql := 'DELETE FROM bsc_sys_datasets_b'||
                 ' WHERE measure_id1 IN ('||
                 '   SELECT measure_id'||
                 '   FROM bsc_sys_measures'||
                 '   WHERE '||h_condition||
                 ' )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_DB_MEASURE_COLS_TL
        h_sql := 'DELETE FROM bsc_db_measure_cols_tl'||
                 ' WHERE measure_col IN ('||
                 '   SELECT measure_col'||
                 '   FROM bsc_sys_measures'||
                 '   WHERE '||h_condition||
                 ' )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_MEASURES
        h_sql := 'DELETE FROM bsc_sys_measures'||
                 ' WHERE '||h_condition;
        BSC_APPS.Execute_Immediate(h_sql);

    END IF;

    -- Clean metadata from invalid dimensions (dimension groups)

    IF g_num_invalid_pmf_dimensions > 0 THEN
        h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'short_name');
        FOR h_i IN 1 .. g_num_invalid_pmf_dimensions LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, g_invalid_pmf_dimensions(h_i));
        END LOOP;

        -- BSC_SYS_DIM_LEVELS_BY_GROUP
        h_sql := 'DELETE FROM bsc_sys_dim_levels_by_group'||
                 ' WHERE dim_group_id IN ('||
                 '   SELECT dim_group_id'||
                 '   FROM bsc_sys_dim_groups_tl'||
                 '   WHERE '||h_condition||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DIM_GROUPS_TL
        h_sql := 'DELETE FROM bsc_sys_dim_groups_tl'||
                 '   WHERE '||h_condition;
        BSC_APPS.Execute_Immediate(h_sql);

    END IF;

    -- Clean metadata from invalid dimension levels

    IF g_num_invalid_pmf_dim_levels > 0 THEN
        h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'short_name');
        FOR h_i IN 1 .. g_num_invalid_pmf_dim_levels LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, g_invalid_pmf_dim_levels(h_i));
        END LOOP;

        -- BSC_SYS_DIM_LEVELS_BY_GROUP
        h_sql := 'DELETE FROM bsc_sys_dim_levels_by_group'||
                 ' WHERE dim_level_id IN ('||
                 '   SELECT dim_level_id'||
                 '   FROM bsc_sys_dim_levels_b'||
                 '   WHERE '||h_condition||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DIM_LEVEL_COLS
        h_sql := 'DELETE FROM bsc_sys_dim_level_cols'||
                 ' WHERE dim_level_id IN ('||
                 '   SELECT dim_level_id'||
                 '   FROM bsc_sys_dim_levels_b'||
                 '   WHERE '||h_condition||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DIM_LEVEL_RELS (dim_level_id)
        h_sql := 'DELETE FROM bsc_sys_dim_level_rels'||
                 ' WHERE dim_level_id IN ('||
                 '   SELECT dim_level_id'||
                 '   FROM bsc_sys_dim_levels_b'||
                 '   WHERE '||h_condition||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DIM_LEVEL_RELS (parent_dim_level_id)
        h_sql := 'DELETE FROM bsc_sys_dim_level_rels'||
                 ' WHERE parent_dim_level_id IN ('||
                 '   SELECT dim_level_id'||
                 '   FROM bsc_sys_dim_levels_b'||
                 '   WHERE '||h_condition||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DIM_LEVELS_TL
        h_sql := 'DELETE FROM bsc_sys_dim_levels_tl'||
                 ' WHERE dim_level_id IN ('||
                 '   SELECT dim_level_id'||
                 '   FROM bsc_sys_dim_levels_b'||
                 '   WHERE '||h_condition||
                 '   )';
        BSC_APPS.Execute_Immediate(h_sql);

        -- BSC_SYS_DIM_LEVELS_B
        h_sql := 'DELETE FROM bsc_sys_dim_levels_b'||
                 ' WHERE '||h_condition;
        BSC_APPS.Execute_Immediate(h_sql);

    END IF;

    COMMIT;

END Clean_Metadata_Invalid_PMF;


-- ENH_B_TABLES_PERF: change to this function
/*===========================================================================+
| FUNCTION Create_Copy_Of_Table_Def
+============================================================================*/
FUNCTION Create_Copy_Of_Table_Def(
  x_table IN VARCHAR2,
        x_tbs_type IN VARCHAR2
  ) RETURN BOOLEAN IS
    h_b BOOLEAN;
BEGIN
    h_b := Create_Copy_Of_Table_Def(x_table, x_tbs_type, FALSE);
    RETURN h_b;
END Create_Copy_Of_Table_Def;


-- ENH_B_TABLES_PERF: change to this function
/*===========================================================================+
| FUNCTION Create_Copy_Of_Table_Def
+============================================================================*/
FUNCTION Create_Copy_Of_Table_Def(
  x_table IN VARCHAR2,
        x_tbs_type IN VARCHAR2,
        x_with_partitions IN BOOLEAN
) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_column_id   NUMBER;
    h_column_name   VARCHAR2(30);
    h_data_type   VARCHAR2(30);
    h_data_length NUMBER;
    h_data_precision  NUMBER;
    h_data_scale  NUMBER;
    h_nullable    VARCHAR2(1);

    h_lst_columns VARCHAR2(32700);

    h_storage VARCHAR2(2500);
    h_initial_extent  NUMBER;
    h_next_extent NUMBER;
    h_max_extents NUMBER;
    h_pct_increase  NUMBER;

    h_table   VARCHAR2(50);
    h_count NUMBER;

BEGIN

    h_table := UPPER(x_table);

    --Bug3329329 Drop the table if exists before trying to create it
    IF BSC_APPS.Table_Exists(h_table) THEN
        -- Fix perf bug#4583017: do not truncate, just drop.
        -- Truncate table to release space --> Bug: DROP TABLE don't release the space immediately
        --h_sql := 'TRUNCATE TABLE '||h_table;
        --BSC_APPS.Do_DDL(h_sql, AD_DDL.TRUNCATE_TABLE, h_table);

        h_sql := 'DROP TABLE '||h_table;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
    END IF;
    ---------

    IF NOT g_src_apps_flag THEN
        -- The source is Non-Enterprise version
        h_sql := 'SELECT column_id, column_name, data_type, data_length,'||
                 '       data_precision, data_scale, nullable'||
                 ' FROM user_tab_columns@'||g_db_link||
                 ' WHERE table_name = :1'||
                 ' ORDER BY column_id';
       OPEN h_cursor FOR h_sql USING h_table;
    ELSE
        -- The source system is Enterprice version (APPS)
        h_sql := 'SELECT column_id, column_name, data_type, data_length,'||
                 '       data_precision, data_scale, nullable'||
                 ' FROM all_tab_columns@'||g_db_link||
                 ' WHERE table_name = :1 AND'||
                 '       owner = :2'||
                 ' ORDER BY column_id';
       OPEN h_cursor FOR h_sql USING h_table, g_src_bsc_schema;
    END IF;

    h_lst_columns := NULL;

    LOOP
        FETCH h_cursor INTO h_column_id, h_column_name, h_data_type, h_data_length, h_data_precision, h_data_scale, h_nullable;
        EXIT WHEN h_cursor%NOTFOUND;

        IF h_lst_columns IS NOT NULL THEN
            h_lst_columns := h_lst_columns||', ';
        END IF;

        h_lst_columns := h_lst_columns||h_column_name;
        h_lst_columns := h_lst_columns||' '||h_data_type;

        IF h_data_type IN ('VARCHAR2', 'NVARCHAR2', 'RAW', 'CHAR', 'NCHAR') THEN
            h_lst_columns := h_lst_columns||'('||h_data_length||')';
        ELSIF h_data_type = 'FLOAT' THEN
            IF h_data_precision IS NOT NULL THEN
                h_lst_columns := h_lst_columns||'('||h_data_precision||')';
            END IF;
        ELSIF  h_data_type = 'NUMBER' THEN
            IF h_data_precision IS NOT NULL AND h_data_scale IS NOT NULL THEN
                h_lst_columns := h_lst_columns||'('||h_data_precision||','||h_data_scale||')';
            ELSIF h_data_precision IS NOT NULL THEN
                h_lst_columns := h_lst_columns||'('||h_data_precision||')';
            END IF;
        END IF;

        IF h_nullable = 'N' THEN
            h_lst_columns := h_lst_columns||' NOT NULL';
        END IF;

    END LOOP;
    CLOSE h_cursor;

    -- Get the storage specs. The table in the target system is created with the same
    -- storage specs from the source table.
    IF NOT g_src_apps_flag THEN
        -- The source is Non-Enterprise version
        h_sql := 'SELECT initial_extent, next_extent, max_extents, pct_increase'||
                 ' FROM user_tables@'||g_db_link||
                 ' WHERE table_name = :1';
       OPEN h_cursor FOR h_sql USING h_table;
    ELSE
        -- The source system is Enterprice version (APPS)
        IF x_with_partitions THEN
            -- See if the table has partitions in the source. In this case we need to read
            -- storage parameters from all_tab_partitions
            h_count := 0;
            h_sql := 'select count(*)'||
                     ' from all_tab_partitions@'||g_db_link||
                     ' where table_owner = :1 and table_name = :2';
            OPEN h_cursor FOR h_sql USING g_src_bsc_schema, h_table;
            FETCH h_cursor INTO h_count;
            CLOSE h_cursor;

            IF h_count > 0 THEN
                h_sql := 'select max(initial_extent), max(next_extent), max(max_extent), max(pct_increase)'||
                         ' from all_tab_partitions@'||g_db_link||
                         ' where table_owner = :1 and table_name = :2';
                OPEN h_cursor FOR h_sql USING g_src_bsc_schema, h_table;
            ELSE
                h_sql := 'SELECT initial_extent, next_extent, max_extents, pct_increase'||
                         ' FROM all_tables@'||g_db_link||
                         ' WHERE table_name = :1 AND'||
                         '       owner = :2';
                OPEN h_cursor FOR h_sql USING h_table, g_src_bsc_schema;
            END IF;
        ELSE
            h_sql := 'SELECT initial_extent, next_extent, max_extents, pct_increase'||
                     ' FROM all_tables@'||g_db_link||
                     ' WHERE table_name = :1 AND'||
                     '       owner = :2';
           OPEN h_cursor FOR h_sql USING h_table, g_src_bsc_schema;
        END IF;
    END IF;

    --Fix bug#4206404: storage parameters may be null
    FETCH h_cursor INTO h_initial_extent, h_next_extent, h_max_extents, h_pct_increase;
    IF h_cursor%NOTFOUND THEN
        h_storage :=  NULL;
    ELSE
        --Fix bug#4206404: storage parameters may be null
        h_storage := NULL;
        IF h_initial_extent IS NOT NULL THEN
            h_storage := h_storage||' INITIAL '||TO_CHAR(h_initial_extent);
        END IF;
        --Fix perf bug#4583017: hard-code NEXT 4M
        h_storage := h_storage||' NEXT 4M';
        --IF h_next_extent IS NOT NULL THEN
        --    h_storage := h_storage||' NEXT '||TO_CHAR(h_next_extent);
        --END IF;
        IF h_max_extents IS NOT NULL THEN
            h_storage := h_storage||' MAXEXTENTS '||TO_CHAR(h_max_extents);
        END IF;
        IF h_pct_increase IS NOT NULL THEN
            h_storage := h_storage||' PCTINCREASE '||TO_CHAR(h_pct_increase);
        END IF;
        IF h_storage IS NOT NULL THEN
            h_storage := 'STORAGE ('||h_storage||')';
        END IF;
    END IF;
    CLOSE h_cursor;

    -- Create table
    IF h_lst_columns IS NOT NULL THEN
        h_sql := 'CREATE TABLE '||x_table||' ('||
                 h_lst_columns||
                 ')';
        IF x_with_partitions THEN
            h_sql := h_sql||' '||bsc_dbgen_metadata_reader.get_partition_clause;
        END IF;
        h_sql := h_sql||' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(x_tbs_type)||' '||h_storage;

        BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_TABLE, x_table);
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Create_Copy_Of_Table_Def');
        RETURN FALSE;

END Create_Copy_Of_Table_Def;


/*===========================================================================+
| FUNCTION Create_Copy_Of_View_Def
+============================================================================*/
FUNCTION Create_Copy_Of_View_Def(
	x_view IN VARCHAR2,
	x_replace IN BOOLEAN := TRUE
  ) RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_text VARCHAR2(30000);

    h_column_id   NUMBER;
    h_column_name   VARCHAR2(30);
    h_lst_columns VARCHAR2(32000);
    h_view    VARCHAR2(50);

BEGIN
    h_view := UPPER(x_view);

    -- Get the columns of the view
    -- The columns of the view are in user_tab_columns.
    -- Because it is view, we know it should be in APPS scheme so qe can use
    -- user_tab_columns even when in Apps environment.
    h_sql := 'SELECT column_id, column_name'||
             ' FROM user_tab_columns@'||g_db_link||
             ' WHERE table_name = :1'||
             ' ORDER BY column_id';
    OPEN h_cursor FOR h_sql USING h_view;

    h_lst_columns := NULL;

    LOOP
        FETCH h_cursor INTO h_column_id, h_column_name;
        EXIT WHEN h_cursor%NOTFOUND;

        IF h_lst_columns IS NOT NULL THEN
            h_lst_columns := h_lst_columns||', ';
        END IF;

        h_lst_columns := h_lst_columns||h_column_name;

    END LOOP;
    CLOSE h_cursor;

    -- Get the sql of the view
    h_sql := 'SELECT text'||
             ' FROM user_views@'||g_db_link||
             ' WHERE view_name = :1';
    OPEN h_cursor FOR h_sql USING h_view;

    FETCH h_cursor INTO h_text;
    IF h_cursor%FOUND THEN
        BEGIN
            h_sql := 'CREATE';
            IF x_replace THEN
              h_sql := h_sql||' OR REPLACE';
            END IF;
            h_sql := h_sql||' FORCE VIEW '||x_view||' ('||h_lst_columns||') AS '||h_text;
            BSC_APPS.Execute_DDL(h_sql);
        EXCEPTION
            WHEN OTHERS THEN
                IF (SQLCODE = -24344) THEN
                    NULL; -- Ignore, success with compilation error
                ELSIF (SQLCODE = -00955) THEN
		    NULL; -- view already exists on the target do not oeverwrite
                ELSE
                   BSC_MESSAGE.Add (x_message => SQLERRM,
                                    x_source => 'BSC_MIGRATION.Create_Copy_Of_View_Def');
                   RETURN FALSE;
                END IF;
        END;

    END IF;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Create_Copy_Of_View_Def');
        RETURN FALSE;

END Create_Copy_Of_View_Def;


/*===========================================================================+
| FUNCTION Create_Dynamic_Objects
+============================================================================*/
FUNCTION Create_Dynamic_Objects RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_i NUMBER;

    h_table VARCHAR2(30);
    h_view VARCHAR2(30);
    h_source VARCHAR2(10);

    h_base_message VARCHAR2(4000);
    h_base_message_v VARCHAR2(4000);
    h_message VARCHAR2(4000);

    h_tbs_type VARCHAR2(100);

    -- ENH_B_TABLES_PERF: new variables
    h_rowid_table_name VARCHAR2(30);
    h_proj_table_name VARCHAR2(30);

    --bug#5943112
    h_max_partitions NUMBER;
    h_num_partitions NUMBER;
    h_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns NUMBER;
    h_key_columns_create BOOLEAN;
BEGIN

    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_CREATE_OBJS'), BSC_APPS.OUTPUT_FILE);

    h_base_message := BSC_APPS.Get_Message('BSC_CREATING_TABLE');
    h_base_message_v := BSC_APPS.Get_Message('BSC_CREATING_VIEW');

    -- Dimension tables
    h_sql :=  'SELECT level_table_name, level_view_name, nvl(source, ''BSC'')'||
              ' FROM bsc_sys_dim_levels_b';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table, h_view, h_source;
        EXIT WHEN h_cursor%NOTFOUND;

        -- If the dimension is for PMF the value stored for table and view
        -- is the same and corresponds to a view

        IF h_source = 'BSC' THEN
            -- create dimension table
            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            IF NOT Create_Copy_Of_Table_Def(h_table, BSC_APPS.dimension_table_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;

        -- Create vl view
        h_message := BSC_APPS.Replace_Token(h_base_message_v, 'VIEW', h_view);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT Create_Copy_Of_View_Def(h_view) THEN
            RAISE e_unexpected_error;
        END IF;

    END LOOP;
    CLOSE h_cursor;

    -- Input tables for dimensions
    h_sql :=  'SELECT table_name'||
              ' FROM bsc_db_tables'||
              ' WHERE table_type = 2';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        -- create dimension input table
        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT Create_Copy_Of_Table_Def(h_table, BSC_APPS.input_table_tbs_type) THEN
            RAISE e_unexpected_error;
        END IF;

    END LOOP;
    CLOSE h_cursor;


    -- MN Dimension tables
    h_sql :=  'SELECT DISTINCT relation_col'||
              ' FROM bsc_sys_dim_level_rels'||
              ' WHERE relation_type = 2';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT Create_Copy_Of_Table_Def(h_table, BSC_APPS.dimension_table_tbs_type) THEN
            RAISE e_unexpected_error;
        END IF;
    END LOOP;
    CLOSE h_cursor;


    -- Filter views
    h_base_message := BSC_APPS.Get_Message('BSC_CREATING_VIEW');

    h_sql := 'SELECT level_view_name'||
             ' FROM bsc_sys_filters_views';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_view;
        EXIT WHEN h_cursor%NOTFOUND;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'VIEW', h_view);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT Create_Copy_Of_View_Def(h_view) THEN
            RAISE e_unexpected_error;
        END IF;
    END LOOP;
    CLOSE h_cursor;
    --rkumar:bug#5943112
    h_max_partitions := bsc_dbgen_metadata_reader.get_max_partitions;

    -- Data tables
    h_base_message := BSC_APPS.Get_Message('BSC_CREATING_TABLE');

    FOR h_i IN 1..g_num_mig_tables LOOP
        h_table := g_mig_tables(h_i);
        h_num_key_columns := 0;
        h_key_columns_create:=false;
        IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(h_table,
                                                           h_key_columns,
                                                           h_key_dim_tables,
                                                           h_source_columns,
                                                           h_source_dim_tables,
                                                           h_num_key_columns) THEN
           RAISE e_unexpected_error;
        END IF;
        if ((h_num_key_columns > 0) AND (h_max_partitions > 1) ) then
          h_key_columns_create:=true;
        end if;
        --BSC-MV Note: Create only existing tables
        IF g_adv_sum_level IS NULL THEN
            -- BSC summary tables architecture. All summary tables exists
            IF Is_Input_Table(h_table) THEN
                h_tbs_type := BSC_APPS.input_table_tbs_type;

                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;

                -- ENH_B_TABLES_PERF: check if the input table has a rowid table
                h_rowid_table_name := Get_RowId_Table_Name(h_table);
                IF h_rowid_table_name IS NOT NULL THEN
                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_rowid_table_name);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                    IF NOT Create_Copy_Of_Table_Def(h_rowid_table_name, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;

            ELSIF Is_Base_Table(h_table) THEN
                h_tbs_type := BSC_APPS.base_table_tbs_type;

                -- ENH_B_TABLES_PERF: check if the base table has a projection table
                h_proj_table_name := Get_Proj_Table_Name(h_table);
                IF h_proj_table_name IS NULL THEN
                    -- create the base table in the standard way
                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                    IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;
                ELSE
                    -- new strategy: b table has a projection table and may be partitioned
                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                    IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type, h_key_columns_create) THEN
                        RAISE e_unexpected_error;
                    END IF;
                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_proj_table_name);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                    IF NOT Create_Copy_Of_Table_Def(h_proj_table_name, h_tbs_type, h_key_columns_create) THEN
                        RAISE e_unexpected_error;
                    END IF;

                END IF;
            ELSE
                h_tbs_type := BSC_APPS.summary_table_tbs_type;

                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;
            END IF;
        ELSE
            -- BSC-MV architecture. Generation type = -1 means the table does not exists
            IF BSC_UPDATE_UTIL.Get_Table_Generation_Type(h_table) <> -1 THEN
                IF Is_Input_Table(h_table) THEN
                    h_tbs_type := BSC_APPS.input_table_tbs_type;

                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                    IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- ENH_B_TABLES_PERF: check if the input table has a rowid table
                    h_rowid_table_name := Get_RowId_Table_Name(h_table);
                    IF h_rowid_table_name IS NOT NULL THEN
                        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_rowid_table_name);
                        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                        IF NOT Create_Copy_Of_Table_Def(h_rowid_table_name, h_tbs_type) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    END IF;

                ELSIF Is_Base_Table(h_table) THEN
                    h_tbs_type := BSC_APPS.base_table_tbs_type;

                    -- ENH_B_TABLES_PERF: check if the base table has a projection table in the source
                    h_proj_table_name := Get_Proj_Table_Name(h_table);
                    IF h_proj_table_name IS NULL THEN
                        -- create the base table in the standard way
                        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                        IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    ELSE
                        -- new strategy: b table has a projection table and may be partitioned
                        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                        IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type, h_key_columns_create) THEN
                            RAISE e_unexpected_error;
                        END IF;
                        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_proj_table_name);
                        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                        IF NOT Create_Copy_Of_Table_Def(h_proj_table_name, h_tbs_type, h_key_columns_create) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    END IF;

                ELSE
                    h_tbs_type := BSC_APPS.summary_table_tbs_type;

                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);
                    IF NOT Create_Copy_Of_Table_Def(h_table, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- BSC-MV Note: Create projection tables
    IF g_adv_sum_level IS NOT NULL THEN
        h_sql :=  'SELECT DISTINCT projection_data'||
                  ' FROM bsc_kpi_data_tables'||
                  ' WHERE projection_data IS NOT NULL';
        OPEN h_cursor FOR h_sql;
        LOOP
            FETCH h_cursor INTO h_table;
            EXIT WHEN h_cursor%NOTFOUND;

            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            IF NOT Create_Copy_Of_Table_Def(h_table, BSC_APPS.summary_table_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;
        CLOSE h_cursor;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_MIG_FAIL_CREATE_OBJS'),
                         x_source => 'BSC_MIGRATION.Create_Dynamic_Objects');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Create_Dynamic_Objects');
        RETURN FALSE;
END Create_Dynamic_Objects;


/*===========================================================================+
| FUNCTION Create_Indexes_Dynamic_Tables
+============================================================================*/
FUNCTION Create_Indexes_Dynamic_Tables RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_i NUMBER;

    h_table VARCHAR2(30);

    h_tbs_type VARCHAR2(100);

    h_rowid_table_name VARCHAR2(30);
    h_proj_table_name VARCHAR2(30);

BEGIN

    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_CREATE_INDEXES'), BSC_APPS.OUTPUT_FILE);

    -- Dimension tables
    h_sql :=  'SELECT level_table_name'||
              ' FROM bsc_sys_dim_levels_b';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;
        IF NOT Create_Table_Indexes(h_table, BSC_APPS.dimension_index_tbs_type) THEN
            RAISE e_unexpected_error;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- Dimension input tables
    h_sql :=  'SELECT table_name'||
              ' FROM bsc_db_tables'||
              ' WHERE table_type = 2';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Create_Table_Indexes(h_table, BSC_APPS.input_index_tbs_type) THEN
            RAISE e_unexpected_error;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- MN Dimension tables
    h_sql :=  'SELECT DISTINCT relation_col'||
              ' FROM bsc_sys_dim_level_rels'||
              ' WHERE relation_type = 2';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Create_Table_Indexes(h_table, BSC_APPS.dimension_index_tbs_type) THEN
            RAISE e_unexpected_error;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- Data tables
    FOR h_i IN 1..g_num_mig_tables LOOP
        h_table := g_mig_tables(h_i);

        --BSC-MV Note: Create index only for existing tables
        IF g_adv_sum_level IS NULL THEN
            -- BSC summary tables architecture. All summary tables exists

            IF Is_Input_Table(h_table) THEN
                h_tbs_type := BSC_APPS.input_index_tbs_type;

                IF NOT Create_Table_Indexes(h_table, h_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;

                -- ENH_B_TABLES_PERF: check if the input table has a rowid table
                h_rowid_table_name := Get_RowId_Table_Name(h_table);
                IF h_rowid_table_name IS NOT NULL THEN
                    IF NOT Create_Table_Indexes(h_rowid_table_name, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;

            ELSIF Is_Base_Table(h_table) THEN
                h_tbs_type := BSC_APPS.base_index_tbs_type;

                IF NOT Create_Table_Indexes(h_table, h_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;

                -- ENH_B_TABLES_PERF: check if the base table has a projection table
                h_proj_table_name := Get_Proj_Table_Name(h_table);
                IF h_proj_table_name IS NOT NULL THEN
                    IF NOT Create_Table_Indexes(h_proj_table_name, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;

            ELSE
                h_tbs_type := BSC_APPS.summary_index_tbs_type;

                IF NOT Create_Table_Indexes(h_table, h_tbs_type) THEN
                    RAISE e_unexpected_error;
                END IF;
            END IF;

        ELSE
            -- BSC-MV architecture. Generation type = -1 means the table does not exists
            IF BSC_UPDATE_UTIL.Get_Table_Generation_Type(h_table) <> -1 THEN
                IF Is_Input_Table(h_table) THEN
                    h_tbs_type := BSC_APPS.input_index_tbs_type;

                    IF NOT Create_Table_Indexes(h_table, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- ENH_B_TABLES_PERF: check if the input table has a rowid table
                    h_rowid_table_name := Get_RowId_Table_Name(h_table);
                    IF h_rowid_table_name IS NOT NULL THEN
                        IF NOT Create_Table_Indexes(h_rowid_table_name, h_tbs_type) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    END IF;

                ELSIF Is_Base_Table(h_table) THEN
                    h_tbs_type := BSC_APPS.base_index_tbs_type;

                    IF NOT Create_Table_Indexes(h_table, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;

                    -- ENH_B_TABLES_PERF: check if the base table has a projection table
                    h_proj_table_name := Get_Proj_Table_Name(h_table);
                    IF h_proj_table_name IS NOT NULL THEN
                        IF NOT Create_Table_Indexes(h_proj_table_name, h_tbs_type) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    END IF;

                ELSE
                    h_tbs_type := BSC_APPS.summary_index_tbs_type;

                    IF NOT Create_Table_Indexes(h_table, h_tbs_type) THEN
                        RAISE e_unexpected_error;
                    END IF;
                END IF;
            END IF;
        END IF;

    END LOOP;

    -- BSC-MV Note: Create index on projection tables
    IF g_adv_sum_level IS NOT NULL THEN
        h_sql :=  'SELECT DISTINCT projection_data'||
                  ' FROM bsc_kpi_data_tables'||
                  ' WHERE projection_data IS NOT NULL';
        OPEN h_cursor FOR h_sql;
        LOOP
            FETCH h_cursor INTO h_table;
            EXIT WHEN h_cursor%NOTFOUND;

            IF NOT Create_Table_Indexes(h_table, BSC_APPS.summary_index_tbs_type) THEN
                RAISE e_unexpected_error;
            END IF;
        END LOOP;
        CLOSE h_cursor;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_MIG_FAIL_CREATE_OBJS'),
                         x_source => 'BSC_MIGRATION.Create_Indexes_Dynamic_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Create_Indexes_Dynamic_Tables');
        RETURN FALSE;
END Create_Indexes_Dynamic_Tables;


/*===========================================================================+
| FUNCTION Analyze_Base_And_Dim_Tables
+============================================================================*/
FUNCTION Analyze_Base_And_Dim_Tables RETURN BOOLEAN IS

    h_sql VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_i NUMBER;

    h_table VARCHAR2(30);

BEGIN

    -- Dimension tables
    h_sql :=  'SELECT level_table_name'||
              ' FROM bsc_sys_dim_levels_b'||
              ' WHERE NVL(source, ''BSC'') = ''BSC''';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        BSC_BIA_WRAPPER.Analyze_Table(h_table);
        commit;
    END LOOP;
    CLOSE h_cursor;

    -- Base Tables
    FOR h_i IN 1..g_num_mig_tables LOOP
        h_table := g_mig_tables(h_i);

        IF Is_Base_Table(h_table) THEN
            BSC_BIA_WRAPPER.Analyze_Table(h_table);
        END IF;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Analyze_Base_And_Dim_Tables');
        RETURN FALSE;
END Analyze_Base_And_Dim_Tables;


/*===========================================================================+
| FUNCTION Create_Table_Indexes
+============================================================================*/
FUNCTION Create_Table_Indexes(
  x_table IN VARCHAR2,
        x_tbs_type IN VARCHAR2
  ) RETURN BOOLEAN IS

    h_storage VARCHAR2(250);
    h_initial_extent  NUMBER;
    h_next_extent NUMBER;
    h_max_extents NUMBER;
    h_pct_increase  NUMBER;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_cursor_i t_cursor;

    h_sql VARCHAR2(32700);

    h_index_name VARCHAR2(30);
    h_index_type VARCHAR2(50);
    h_partitioned VARCHAR2(10);
    h_uniqueness VARCHAR2(9);
    h_column_position NUMBER;
    h_column_name VARCHAR2(30);

    h_base_message VARCHAR2(4000);
    h_message VARCHAR2(4000);

    h_lst_columns VARCHAR2(32000);
    h_table VARCHAR2(50);
    h_count NUMBER;

BEGIN
    -- ENH_B_TABLES_PERF: need to enhance this function to take into account bitmap indexes too

    h_table := UPPER(x_table);

    h_base_message := BSC_APPS.Get_Message('BSC_CREATING_INDEX');

    IF NOT g_src_apps_flag THEN
        -- The source is Non-Enterprise version
        h_sql := 'SELECT index_name, index_type, uniqueness, initial_extent, next_extent, max_extents, pct_increase, partitioned'||
                 ' FROM user_indexes@'||g_db_link||
                 ' WHERE table_name = :1';
        OPEN h_cursor FOR h_sql USING h_table;
    ELSE
        -- The source system is Enterprice version (APPS)
        h_sql := 'SELECT index_name, index_type, uniqueness, initial_extent, next_extent, max_extents, pct_increase, partitioned'||
                 ' FROM all_indexes@'||g_db_link||
                 ' WHERE table_name = :1 AND'||
                 '       owner = :2';
        OPEN h_cursor FOR h_sql USING h_table, g_src_bsc_schema;
    END IF;

    LOOP
        FETCH h_cursor INTO h_index_name, h_index_type, h_uniqueness, h_initial_extent, h_next_extent,
                            h_max_extents, h_pct_increase, h_partitioned;
        EXIT WHEN h_cursor%NOTFOUND;

        --Fix bug#4206404: storage parameters may be null
        h_storage := NULL;
        IF h_initial_extent IS NOT NULL THEN
            h_storage := h_storage||' INITIAL '||TO_CHAR(h_initial_extent);
        END IF;
        --Fix perf bug#4583017: hard-code NEXT 4M
        h_storage := h_storage||' NEXT 4M';
        --IF h_next_extent IS NOT NULL THEN
        --    h_storage := h_storage||' NEXT '||TO_CHAR(h_next_extent);
        --END IF;
        IF h_max_extents IS NOT NULL THEN
            h_storage := h_storage||' MAXEXTENTS '||TO_CHAR(h_max_extents);
        END IF;
        IF h_pct_increase IS NOT NULL THEN
            h_storage := h_storage||' PCTINCREASE '||TO_CHAR(h_pct_increase);
        END IF;
        IF h_storage IS NOT NULL THEN
            h_storage := 'STORAGE ('||h_storage||')';
        END IF;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'INDEX', h_index_name);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT g_src_apps_flag THEN
            -- The source is Non-Enterprise version
            h_sql := 'SELECT column_position, column_name'||
                     ' FROM user_ind_columns@'||g_db_link||
                     ' WHERE index_name = :1'||
                     ' ORDER BY column_position';
            OPEN h_cursor_i FOR h_sql USING h_index_name;
        ELSE
            -- The source system is Enterprice version (APPS)
            h_sql := 'SELECT column_position, column_name'||
                     ' FROM all_ind_columns@'||g_db_link||
                     ' WHERE index_name = :1 AND'||
                     '       index_owner = :2'||
                     ' ORDER BY column_position';
            OPEN h_cursor_i FOR h_sql USING h_index_name, g_src_bsc_schema;
        END IF;

        h_lst_columns := NULL;

        LOOP
            FETCH h_cursor_i INTO h_column_position, h_column_name;
            EXIT WHEN h_cursor_i%NOTFOUND;

            IF h_lst_columns IS NULL THEN
                h_lst_columns := h_column_name;
            ELSE
                h_lst_columns := h_lst_columns||', '||h_column_name;
            END IF;

        END LOOP;
        CLOSE h_cursor_i;

        IF h_lst_columns IS NOT NULL THEN
            IF h_index_type = 'BITMAP' THEN
                h_sql := 'CREATE BITMAP INDEX';
            ELSE
                IF h_uniqueness = 'UNIQUE' THEN
                    h_sql := 'CREATE UNIQUE INDEX';
                ELSE
                    h_sql := 'CREATE INDEX';
                END IF;
            END IF;
            -- Fix performance bug#3860149: create index in parallel
            -- Fix perf bug#4583017: Use NOLOGGING COMPUTE STATISTICS option
            h_sql := h_sql||' '||h_index_name||
                     ' ON '||x_table||' ('||h_lst_columns||
                     ')';

            --Bug#4769877: need to use LOCAL if the table is partitioned
            IF h_index_type = 'BITMAP' THEN
                select count(partition_name)
                into h_count
                from all_tab_partitions
                where table_owner = g_src_bsc_schema and table_name = x_table;

                IF h_count > 0 THEN
                    h_sql := h_sql||' LOCAL';
                END IF;
            END IF;

            h_sql := h_sql||' PARALLEL NOLOGGING COMPUTE STATISTICS'||
                     ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(x_tbs_type)||' '||h_storage;
            BSC_APPS.Do_DDL(h_sql, AD_DDL.CREATE_INDEX, h_index_name);
            commit;

            -- Fix performance bug#3860149: do not leave the index in parallel
            -- Fix perf bug#4583017: Use NOLOGGING option
            h_sql := 'ALTER INDEX '||BSC_APPS.bsc_apps_schema||'.'||h_index_name||' NOPARALLEL LOGGING';
            BSC_APPS.Execute_Immediate(h_sql);
            commit;
        END IF;

    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Create_Table_Indexes');
        RETURN FALSE;

END Create_Table_Indexes;


/*===========================================================================+
| FUNCTION Decompose_Numeric_List
+============================================================================*/
FUNCTION Decompose_Numeric_List(
  x_string IN VARCHAR2,
  x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
  ) RETURN NUMBER IS

    e_invalid_format EXCEPTION;

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1))));

            IF x_number_array(h_num_items) IS NULL THEN
                RAISE e_invalid_format;
            END IF;

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(h_sub_string)));

        IF x_number_array(h_num_items) IS NULL THEN
            RAISE e_invalid_format;
        END IF;

    END IF;

    RETURN h_num_items;

EXCEPTION
    WHEN e_invalid_format THEN
        RETURN (-1);
    WHEN OTHERS THEN
        RETURN (-1);

END Decompose_Numeric_List;


/*===========================================================================+
| FUNCTION Delete_Metadata_Tables
+============================================================================*/
FUNCTION Delete_Metadata_Tables RETURN BOOLEAN IS

    h_i NUMBER;

    h_sql VARCHAR2(2000);

    h_message VARCHAR2(4000);
    h_base_message VARCHAR2(4000);

BEGIN
    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_DELETE_METADATA'), BSC_APPS.OUTPUT_FILE);

    h_base_message := BSC_APPS.Get_Message('BSC_DELETING_DATA');

    FOR h_i IN 1..g_num_metadata_tables LOOP
        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', g_metadata_tables(h_i).table_name);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        -- Fix bug#4430901: Use truncate instead of delete
        h_sql := 'TRUNCATE TABLE '||g_metadata_tables(h_i).table_name;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.TRUNCATE_TABLE, g_metadata_tables(h_i).table_name);
        COMMIT;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Delete_Metadata_Tables');
        RETURN FALSE;
END Delete_Metadata_Tables;


/*===========================================================================+
| FUNCTION Drop_Dynamic_Objects
+============================================================================*/
FUNCTION Drop_Dynamic_Objects RETURN BOOLEAN IS

    CURSOR c_data_tables IS
        SELECT table_name
        FROM bsc_db_tables;

    CURSOR c_dim_tables IS
        SELECT level_table_name, level_view_name, nvl(edw_flag,0)
        FROM bsc_sys_dim_levels_b;

    CURSOR c_mn_dim_tables IS
        SELECT DISTINCT relation_col
        FROM bsc_sys_dim_level_rels
        WHERE relation_type = 2;

    CURSOR c_filter_views IS
        SELECT level_view_name
        FROM bsc_sys_filters_views;

    -- ENH_B_TABLES_PERF: get rowid tables created for input tables
    CURSOR c_rowid_tables IS
        select bsc_migration.get_rowid_table_name(table_name)
        from bsc_db_tables
        where table_type = 0;

    -- ENH_B_TABLES_PERF: get rowid tables created for input tables
    CURSOR c_proj_tables IS
        select bsc_migration.get_proj_table_name(table_name)
        from bsc_db_tables
        where table_type = 1;

    h_table VARCHAR2(30);
    h_edw_flag NUMBER;
    h_view VARCHAR2(30);
    h_sql VARCHAR2(32700);
    h_base_message VARCHAR2(4000);
    h_base_message_v VARCHAR2(4000);
    h_message VARCHAR2(4000);
    h_mv VARCHAR2(50);
    h_uv VARCHAR2(50);

    e_unexpected_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_mv_name VARCHAR2(30);
    h_error_message_drop_mv VARCHAR2(2000);
    e_error_drop_mv EXCEPTION;

BEGIN

    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_DROP_OBJECTS'), BSC_APPS.OUTPUT_FILE);

    h_base_message := BSC_APPS.Get_Message('BSC_DROPPING_TABLE');
    h_base_message_v := BSC_APPS.Get_Message('BSC_DROPPING_VIEW');

    -- Drop dimension tables
    -- EDW Note: EDW Dimension tables are materialized views
    OPEN c_dim_tables;
    FETCH c_dim_tables INTO h_table, h_view, h_edw_flag;
    WHILE c_dim_tables%FOUND LOOP
        IF h_edw_flag = 0 THEN
            -- BSC dimension
            IF BSC_APPS.Table_Exists(h_table) THEN
                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                -- Fix perf bug#4583017: do not truncate, just drop.
                -- Truncate table to release space --> Bug: DROP TABLE don't release the space immediately
                --h_sql := 'TRUNCATE TABLE '||h_table;
                --BSC_APPS.Do_DDL(h_sql, AD_DDL.TRUNCATE_TABLE, h_table);

                h_sql := 'DROP TABLE '||h_table;
                BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
            END IF;

            -- Drop the Vl view
            IF BSC_APPS.View_Exists(h_view) THEN
                h_message := BSC_APPS.Replace_Token(h_base_message_v, 'VIEW', h_view);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                h_sql := 'DROP VIEW '||h_view;
                BSC_APPS.Execute_DDL(h_sql);
            END IF;

        ELSE
            -- EDW dimension
            IF BSC_APPS.Object_Exists(h_table) THEN
                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                BSC_INTEGRATION_MV_GEN.Drop_Materialized_View(h_table, 'Y');
                IF BSC_APPS.CheckError('BSC_INTEGRATION_MV_GEN.Drop_Materialized_View') THEN
              RAISE e_unexpected_error;
                END IF;

            END IF;

        END IF;

        FETCH c_dim_tables INTO h_table, h_view, h_edw_flag;
    END LOOP;
    CLOSE c_dim_tables;

    -- Drop mn dimension tables
    -- EDW Note: No mn dimensions are from EDW
    OPEN c_mn_dim_tables;
    FETCH c_mn_dim_tables INTO h_table;
    WHILE c_mn_dim_tables%FOUND LOOP
        IF BSC_APPS.Table_Exists(h_table) THEN
            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            -- Fix perf bug#4583017: do not truncate, just drop.
            -- Truncate table to release space --> Bug: DROP TABLE don't release the space immediately
            --h_sql := 'TRUNCATE TABLE '||h_table;
            --BSC_APPS.Do_DDL(h_sql, AD_DDL.TRUNCATE_TABLE, h_table);

            h_sql := 'DROP TABLE '||h_table;
            BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
        END IF;

        FETCH c_mn_dim_tables INTO h_table;
    END LOOP;
    CLOSE c_mn_dim_tables;

    -- Drop filter views
    h_base_message := BSC_APPS.Get_Message('BSC_DROPPING_VIEW');

    OPEN c_filter_views;
    FETCH c_filter_views INTO h_view;
    WHILE c_filter_views%FOUND LOOP
        IF BSC_APPS.View_Exists(h_view) THEN
            h_message := BSC_APPS.Replace_Token(h_base_message, 'VIEW', h_view);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            h_sql := 'DROP VIEW '||h_view;
            BSC_APPS.Execute_DDL(h_sql);
        END IF;

        FETCH c_filter_views INTO h_view;
    END LOOP;
    CLOSE c_filter_views;

    -- Drop data tables (input, base and system tables)
    h_base_message := BSC_APPS.Get_Message('BSC_DROPPING_TABLE');

    OPEN c_data_tables;
    FETCH c_data_tables INTO h_table;
    WHILE c_data_tables%FOUND LOOP
        IF BSC_APPS.Table_Exists(h_table) THEN
            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            -- Fix perf bug#4583017: do not truncate, just drop.
            -- Truncate table to release space --> Bug: DROP TABLE don't release the space immediately
            --h_sql := 'TRUNCATE TABLE '||h_table;
            --BSC_APPS.Do_DDL(h_sql, AD_DDL.TRUNCATE_TABLE, h_table);

            h_sql := 'DROP TABLE '||h_table;
            BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
        END IF;

        -- BSC-MV Note: I am commenting this code. EDW is not supported and
        -- this code affect the performance.
        -- -- EDW note: I dont know at this point, whether the table is a S, B or I table
        -- -- neither if the table is from EDW. So I check if there is a materialized
        -- -- view corresponding to this table. In that case I drop the materialize view.
        -- h_mv := h_table||'_MV_V';
        -- IF BSC_APPS.Object_Exists(h_mv) THEN
        --     BSC_INTEGRATION_MV_GEN.Drop_Materialized_View(h_table, 'N');
        --     IF BSC_APPS.CheckError('BSC_INTEGRATION_MV_GEN.Drop_Materialized_View') THEN
  --         RAISE e_unexpected_error;
        --     END IF;
        -- END IF;
        --
        -- -- Same for the union view.
        -- h_uv := h_table||'_V';
        -- IF BSC_APPS.View_Exists(h_uv) THEN
        --     h_sql := 'DROP VIEW '||h_uv;
        --     BSC_APPS.Execute_DDL(h_sql);
        -- END IF;

        FETCH c_data_tables INTO h_table;
    END LOOP;
    CLOSE c_data_tables;

    -- ENH_B_TABLES_PERF: Drop rowid tables created for input tables
    OPEN c_rowid_tables;
    FETCH c_rowid_tables INTO h_table;
    WHILE c_rowid_tables%FOUND LOOP
        IF h_table IS NOT NULL THEN
            IF BSC_APPS.Table_Exists(h_table) THEN
                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                h_sql := 'DROP TABLE '||h_table;
                BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
            END IF;
        END IF;
        FETCH c_rowid_tables INTO h_table;
    END LOOP;
    CLOSE c_rowid_tables;

    -- ENH_B_TABLES_PERF: Drop projection tables created for base tables
    OPEN c_proj_tables;
    FETCH c_proj_tables INTO h_table;
    WHILE c_proj_tables%FOUND LOOP
        IF h_table IS NOT NULL THEN
            IF BSC_APPS.Table_Exists(h_table) THEN
                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                h_sql := 'DROP TABLE '||h_table;
                BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
            END IF;
        END IF;
        FETCH c_proj_tables INTO h_table;
    END LOOP;
    CLOSE c_proj_tables;

    -- BSC-MV Note: Drop all MVs used by the Kpis
    h_base_message := BSC_APPS.Get_Message('BSC_DROPPING_VIEW');

    h_sql := 'SELECT DISTINCT MV_NAME'||
             ' FROM BSC_KPI_DATA_TABLES'||
             ' WHERE MV_NAME IS NOT NULL';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_mv_name;
        EXIT WHEN h_cursor%NOTFOUND;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'VIEW', h_mv_name);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT BSC_BIA_WRAPPER.Drop_Summary_MV(h_mv_name, h_error_message_drop_mv) THEN
            RAISE e_error_drop_mv;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- BSC-MV Note: Also Drop all MV used for targets
    h_sql := 'SELECT DISTINCT BSC_BIA_WRAPPER.Get_Sum_Table_MV_Name(SOURCE_TABLE_NAME) MV_NAME'||
             ' FROM BSC_DB_TABLES_RELS'||
             ' WHERE TABLE_NAME IN ('||
             '   SELECT TABLE_NAME'||
             '   FROM BSC_KPI_DATA_TABLES'||
             '   WHERE TABLE_NAME IS NOT NULL'||
             ' ) AND'||
             ' RELATION_TYPE = 1';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_mv_name;
        EXIT WHEN h_cursor%NOTFOUND;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'VIEW', h_mv_name);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        IF NOT BSC_BIA_WRAPPER.Drop_Summary_MV(h_mv_name, h_error_message_drop_mv) THEN
            RAISE e_error_drop_mv;
        END IF;

    END LOOP;
    CLOSE h_cursor;

    -- BSC-MV Note: Also drop all the projection tables
    h_base_message := BSC_APPS.Get_Message('BSC_DROPPING_TABLE');

    h_sql := 'SELECT DISTINCT PROJECTION_DATA'||
             ' FROM BSC_KPI_DATA_TABLES'||
             ' WHERE PROJECTION_DATA IS NOT NULL';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        IF BSC_APPS.Table_Exists(h_table) THEN
            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            -- Fix perf bug#4583017: do not truncate, just drop.
            -- Truncate table to release space --> Bug: DROP TABLE don't release the space immediately
            --h_sql := 'TRUNCATE TABLE '||h_table;
            --BSC_APPS.Do_DDL(h_sql, AD_DDL.TRUNCATE_TABLE, h_table);

            h_sql := 'DROP TABLE '||h_table;
            BSC_APPS.Do_DDL(h_sql, AD_DDL.DROP_TABLE, h_table);
        END IF;
    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_ERROR_DROPPING_OLD_DB_OBJ'),
                         x_source => 'BSC_MIGRATION.Drop_Dynamic_Objects');
        RETURN FALSE;

    WHEN e_error_drop_mv THEN
        BSC_MESSAGE.Add (x_message => 'BSC_BIA_WRAPPER.Drop_Summary_MV: '||h_mv_name||' '||h_error_message_drop_mv,
                         x_source => 'BSC_MIGRATION.Drop_Dynamic_Objects');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Drop_Dynamic_Objects');
        RETURN FALSE;

END Drop_Dynamic_Objects;


--LOCKING: new function
/*===========================================================================+
| FUNCTION Lock_Migration
+============================================================================*/
FUNCTION Lock_Migration (
    x_process_id IN NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    h_src_responsibilities VARCHAR2(32000) := NULL;
    h_trg_responsibilities VARCHAR2(32000) := NULL;
    h_tab_filter VARCHAR2(32000) := NULL;
    h_kpi_filter VARCHAR2(32000) := NULL;
    h_overwrite VARCHAR2(32000) := NULL;
    h_adv_mig_features VARCHAR2(32000) := NULL;

    h_tabs_filter   t_array_of_number;  -- array with the tabs in the filter
    h_num_tabs_filter NUMBER := 0;
    h_kpis_filter   t_array_of_number;  -- array with the KPIs in the filter
    h_num_kpis_filter NUMBER := 0;

    h_i NUMBER;
    h_sql VARCHAR2(32000);

    h_object_key varchar2(30);
    h_object_type varchar2(50);
    h_lock_type varchar2(1);
    h_query_time date;
    h_program_id number;
    h_user_id number;
    h_cascade_lock_level number;

    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);
    e_system_lock EXCEPTION;

BEGIN

    --Lock the entire target system
    BSC_APPS.Write_Line_Log('Locking Target System:', BSC_APPS.OUTPUT_FILE);
    BSC_APPS.Write_Line_Log('Locking the whole system', BSC_APPS.OUTPUT_FILE);
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -800,
        p_user_id => BSC_APPS.apps_user_id,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data =>  h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    --In the source, lock the indicators or scorecards or the whole system according to the filters
    -- Get parameters from BSC_DB_LOADER_CONTROL
    BSC_APPS.Write_Line_Log('Locking Source System:', BSC_APPS.OUTPUT_FILE);
    Get_Migration_Parameters(
        p_process_id => x_process_id,
        x_src_responsibilities => h_src_responsibilities,
        x_trg_responsibilities => h_trg_responsibilities,
        x_tab_filter => h_tab_filter,
        x_kpi_filter => h_kpi_filter,
        x_overwrite =>  h_overwrite,
        x_adv_mig_features => h_adv_mig_features,
        x_db_link => g_db_link
    );

    h_num_tabs_filter := Decompose_Numeric_List(h_tab_filter, h_tabs_filter, ',');
    h_num_kpis_filter := Decompose_Numeric_List(h_kpi_filter, h_kpis_filter, ',');

    h_sql := 'BEGIN FND_MSG_PUB.Initialize@'||g_db_link||'; END;';
    execute immediate h_sql;

    h_sql := 'BEGIN BSC_APPS.Init_Bsc_Apps@'||g_db_link||'; END;';
    execute immediate h_sql;

    h_lock_type := 'W';
    h_query_time := SYSDATE;
    h_program_id := -800;
    -- Fix bug#4873385 get user id for source system
    h_user_id := Get_Source_User_Id;
    h_cascade_lock_level := 0;

    --Lock the scorecards if the migration is by scorecards (it is in cascade mode)
    h_object_type := 'SCORECARD';
    FOR h_i IN 1..h_num_tabs_filter LOOP
        h_object_key := h_tabs_filter(h_i);

        BSC_APPS.Write_Line_Log('Locking SCORECARD '||h_object_key, BSC_APPS.OUTPUT_FILE);

        h_sql := 'BEGIN BSC_LOCKS_PUB.GET_SYSTEM_LOCK@'||g_db_link||' ('||
                 ' p_object_key => :1'||
                 ',p_object_type => :2'||
                 ',p_lock_type => :3'||
                 ',p_query_time => :4'||
                 ',p_program_id => :5'||
                 ',p_user_id => :6'||
                 ',p_cascade_lock_level => :7'||
                 ',x_return_status => :8'||
                 ',x_msg_count => :9'||
                 ',x_msg_data => :10); END;';
        execute immediate h_sql
        using h_object_key, h_object_type, h_lock_type, h_query_time, h_program_id,
              h_user_id, h_cascade_lock_level, OUT h_return_status, OUT h_msg_count, OUT h_msg_data;

        IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE e_system_lock;
        END IF;
    END LOOP;

    --Lock the kpis if the migration is by kpis (in cascade)
    h_object_type := 'OBJECTIVE';
    FOR h_i IN 1..h_num_kpis_filter LOOP
        h_object_key := h_kpis_filter(h_i);

        BSC_APPS.Write_Line_Log('Locking OBJECTIVE '||h_object_key, BSC_APPS.OUTPUT_FILE);

        h_sql := 'BEGIN BSC_LOCKS_PUB.GET_SYSTEM_LOCK@'||g_db_link||' ('||
                 ' p_object_key => :1'||
                 ',p_object_type => :2'||
                 ',p_lock_type => :3'||
                 ',p_query_time => :4'||
                 ',p_program_id => :5'||
                 ',p_user_id => :6'||
                 ',p_cascade_lock_level => :7'||
                 ',x_return_status => :8'||
                 ',x_msg_count => :9'||
                 ',x_msg_data => :10); END;';
        execute immediate h_sql
        using h_object_key, h_object_type, h_lock_type, h_query_time, h_program_id,
              h_user_id, h_cascade_lock_level, OUT h_return_status, OUT h_msg_count, OUT h_msg_data;

        IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE e_system_lock;
        END IF;
    END LOOP;

    --Lock the entire source system if there is no filters
    IF h_num_kpis_filter = 0 AND h_num_tabs_filter = 0 THEN

        BSC_APPS.Write_Line_Log('Locking the whole system', BSC_APPS.OUTPUT_FILE);

        h_sql := 'BEGIN BSC_LOCKS_PUB.GET_SYSTEM_LOCK@'||g_db_link||' ('||
                 'p_program_id => :1'||
                 ',p_user_id => :2'||
                 ',x_return_status => :3'||
                 ',x_msg_count => :4'||
                 ',x_msg_data => :5); END;';
        execute immediate h_sql
        using h_program_id, h_user_id, OUT h_return_status, OUT h_msg_count, OUT h_msg_data;

        IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE e_system_lock;
        END IF;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN e_system_lock THEN
        x_msg_data := h_msg_data;
        RETURN FALSE;
    WHEN OTHERS THEN
        x_msg_data := SQLERRM;
        RETURN FALSE;
END Lock_Migration;


/*===========================================================================+
| PROCEDURE Execute_Migration
+============================================================================*/
PROCEDURE Execute_Migration (
        ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_tab_filter IN VARCHAR2,
  x_kpi_filter IN VARCHAR2,
        x_overwrite IN VARCHAR2
  ) IS

    e_error EXCEPTION;
    e_warning EXCEPTION;
    h_count NUMBER;

    --LOCKING: new variables
    h_return_status VARCHAR2(10);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(4000);
    e_system_lock EXCEPTION;
    h_sql VARCHAR2(32000);
    h_null VARCHAR2(1);

    h_src_responsibilities VARCHAR2(32000) := NULL;
    h_trg_responsibilities VARCHAR2(32000) := NULL;
    h_tab_filter VARCHAR2(32000) := NULL;
    h_kpi_filter VARCHAR2(32000) := NULL;
    h_overwrite VARCHAR2(32000) := NULL;
    h_adv_mig_features VARCHAR2(32000) := NULL;

    h_source_user_id NUMBER;
    h_error_msg VARCHAR2(4000);

BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- LOCKING: call this api
    FND_MSG_PUB.Initialize;

    -- Initializes the error message stack
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    -- Alter session set global_names = false to disable the enforcement
    -- of database link name must be equals to remote database name.
    h_sql := 'ALTER SESSION SET GLOBAL_NAMES = FALSE';
    BSC_APPS.Execute_Immediate(h_sql);

    Get_Migration_Parameters(
        p_process_id => x_src_responsibilities,
        x_src_responsibilities => h_src_responsibilities,
        x_trg_responsibilities => h_trg_responsibilities,
        x_tab_filter => h_tab_filter,
        x_kpi_filter => h_kpi_filter,
        x_overwrite =>  h_overwrite,
        x_adv_mig_features => h_adv_mig_features,
        x_db_link => g_db_link
    );

    --LOCKING: Call this api for backward compatibility
    BSC_LOCKS_PUB.Get_System_Lock (
        p_program_id => -800,
        p_user_id => BSC_APPS.apps_user_id,
        p_icx_session_id => null,
        x_return_status => h_return_status,
        x_msg_count => h_msg_count,
        x_msg_data => h_msg_data
    );
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    --Fix bug#4873385 if the user BSC_APPS.apps_user_id does not exists in the source system
    -- then we lock the source system with the user ANONYMOUS
    h_source_user_id := Get_Source_User_Id;

    -- Fix bug#4480209 LOCKING: Need to call this api for backward compatibility
    h_sql := 'BEGIN FND_MSG_PUB.Initialize@'||g_db_link||'; END;';
    execute immediate h_sql;
    h_sql := 'BEGIN BSC_APPS.Init_Bsc_Apps@'||g_db_link||'; END;';
    execute immediate h_sql;
    h_null := NULL;
    h_sql := 'BEGIN BSC_LOCKS_PUB.Get_System_Lock@'||g_db_link||' ('||
             'p_program_id => :1,'||
             'p_user_id => :2,'||
             'p_icx_session_id => :3,'||
             'x_return_status => :4,'||
             'x_msg_count => :5,'||
             'x_msg_data => :6); END;';
    -- Fix bug#4648979: Migration should run with iViewer in the source system. Passign new program -802
    execute immediate h_sql
    using -802, h_source_user_id, h_null, OUT h_return_status, OUT h_msg_count, OUT h_msg_data;
    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_system_lock;
    END IF;

    --LOCKING: Lock the whole target system and the kpis to be migrated in the source
    -- note that x_src_responsibilities has the process_id
    IF NOT Lock_Migration(x_src_responsibilities, h_msg_data) THEN
        RAISE e_system_lock;
    END IF;

    --LOCKING: Call the autonomous transaction procedure
    Migrate_System_AT(x_src_responsibilities,
                      x_trg_responsibilities,
                      x_tab_filter,
                x_kpi_filter,
                      x_overwrite);


    --LOCKING: Commit to release locks
    COMMIT;

    SELECT count(*)
    INTO h_count
    FROM bsc_message_logs
    WHERE type = 0
    AND UPPER(source) = 'BSC_MIGRATION.MIGRATE_SYSTEM'
    AND last_update_login = USERENV('SESSIONID');

    IF h_count > 0 THEN
        IF NOT g_syncup_done THEN
	    sync_bis_bsc_metadata(h_error_msg);
        END IF;
        RAISE e_error;
    END IF;

    IF g_warnings THEN
        IF NOT g_syncup_done THEN
	    sync_bis_bsc_metadata(h_error_msg);
        END IF;
        RAISE e_warning;
    END IF;

    -- LOCKING
    BSC_LOCKS_PUB.Remove_System_Lock;

    -- Fix bug#4480209: need to call this in the source system too
    h_sql := 'BEGIN BSC_LOCKS_PUB.Remove_System_Lock@'||g_db_link||'; END;';
    execute immediate h_sql;

EXCEPTION
    WHEN e_error THEN
        ERRBUF := BSC_APPS.Get_Message('BSC_MIG_FAIL_EXEC');
        RETCODE := 2; -- Request completed with errors
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        -- Fix bug#4624462: need to call this in the source system too
        h_sql := 'BEGIN BSC_LOCKS_PUB.Remove_System_Lock@'||g_db_link||'; END;';
        execute immediate h_sql;

    --LOCKING
    WHEN e_system_lock THEN
        ERRBUF := h_msg_data;
        RETCODE := 2; -- Request completed with errors
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        -- Fix bug#4624462: need to call this in the source system too
        h_sql := 'BEGIN BSC_LOCKS_PUB.Remove_System_Lock@'||g_db_link||'; END;';
        execute immediate h_sql;

    WHEN e_warning THEN
        ERRBUF := '';
        RETCODE := 1; -- Request completed with warning
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        -- Fix bug#4624462: need to call this in the source system too
        h_sql := 'BEGIN BSC_LOCKS_PUB.Remove_System_Lock@'||g_db_link||'; END;';
        execute immediate h_sql;

    WHEN g_error_synch_bsc_pmf THEN
        ROLLBACK;
        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => h_error_msg,
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

        ERRBUF := BSC_APPS.Get_Message('BSC_MIG_FAIL_EXEC');
        RETCODE := 2; -- Request completed with errors
        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        h_sql := 'BEGIN BSC_LOCKS_PUB.Remove_System_Lock@'||g_db_link||'; END;';
        execute immediate h_sql;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_MIGRATION.Execute_Migration',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);


        ERRBUF := BSC_UPDATE_UTIL.Get_Message('BSC_UPDATE_PROC_FAILED');
        RETCODE := 2; -- Request completed with errors

        -- LOCKING
        BSC_LOCKS_PUB.Remove_System_Lock;
        -- Fix bug#4624462: need to call this in the source system too
        h_sql := 'BEGIN BSC_LOCKS_PUB.Remove_System_Lock@'||g_db_link||'; END;';
        execute immediate h_sql;

END Execute_Migration;


/*===========================================================================+
| FUNCTION Get_Lst_Table_Columns
+============================================================================*/
FUNCTION Get_Lst_Table_Columns(
  x_table IN VARCHAR2
  ) RETURN VARCHAR2 IS

    h_lst VARCHAR2(32700);
    h_column_name VARCHAR2(30);

    CURSOR c_columns IS
        SELECT column_name
        FROM user_tab_columns
        WHERE table_name = UPPER(x_table);

    CURSOR c_columns_apps IS
        SELECT column_name
        FROM all_tab_columns
        WHERE table_name = UPPER(x_table) AND
              owner = UPPER(BSC_APPS.BSC_APPS_SCHEMA);

BEGIN
    h_lst := NULL;
    IF NOT BSC_APPS.APPS_ENV THEN
        -- Personal mode
        OPEN c_columns;
        FETCH c_columns INTO h_column_name;
        WHILE c_columns%FOUND LOOP
            IF h_lst IS NOT NULL THEN
                h_lst := h_lst||', ';
            END IF;

            h_lst := h_lst||h_column_name;

            FETCH c_columns INTO h_column_name;
        END LOOP;
        CLOSE c_columns;
    ELSE
        -- Apps mode
        OPEN c_columns_apps;
        FETCH c_columns_apps INTO h_column_name;
        WHILE c_columns_apps%FOUND LOOP
            IF h_lst IS NOT NULL THEN
                h_lst := h_lst||', ';
            END IF;

            h_lst := h_lst||h_column_name;

            FETCH c_columns_apps INTO h_column_name;
        END LOOP;
        CLOSE c_columns_apps;
    END IF;

    RETURN h_lst;

END Get_Lst_Table_Columns;


/*===========================================================================+
| PROCEDURE Get_Migration_Parameters
+============================================================================*/
PROCEDURE Get_Migration_Parameters(
        p_process_id IN VARCHAR2,
        x_src_responsibilities IN OUT NOCOPY VARCHAR2,
        x_trg_responsibilities IN OUT NOCOPY VARCHAR2,
        x_tab_filter IN OUT NOCOPY VARCHAR2,
        x_kpi_filter IN OUT NOCOPY VARCHAR2,
        x_overwrite IN OUT NOCOPY VARCHAR2,
        x_adv_mig_features IN OUT NOCOPY VARCHAR2,
        x_db_link IN OUT NOCOPY VARCHAR2
      ) IS
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);
    h_parameter VARCHAR2(30);
    h_parameter_type VARCHAR2(30);
    h_parameter_value VARCHAR2(30);

BEGIN
    x_src_responsibilities := NULL;
    x_trg_responsibilities := NULL;
    x_tab_filter := NULL;
    x_kpi_filter := NULL;
    x_overwrite := NULL;
    x_adv_mig_features := NULL;

    -- need to sort to get source and target responsibilities in the proper order
    h_sql := 'SELECT input_table_name'||
             ' FROM bsc_db_loader_control'||
             ' WHERE process_id = :1'||
             ' ORDER BY input_table_name';

    OPEN h_cursor FOR h_sql USING p_process_id;
    LOOP
        FETCH h_cursor INTO h_parameter;
        EXIT WHEN h_cursor%NOTFOUND;

        h_parameter_type := SUBSTR(h_parameter, 1, 2);
        h_parameter_value := SUBSTR(h_parameter, INSTR(h_parameter, '_') + 1);

        IF h_parameter_type = 'SR' THEN
            -- source responsibility
            IF x_src_responsibilities IS NULL THEN
                x_src_responsibilities := h_parameter_value;
            ELSE
                x_src_responsibilities := x_src_responsibilities||','||h_parameter_value;
            END IF;
        ELSIF h_parameter_type = 'TR' THEN
            -- target responsibility
            IF x_trg_responsibilities IS NULL THEN
                x_trg_responsibilities := h_parameter_value;
            ELSE
                x_trg_responsibilities := x_trg_responsibilities||','||h_parameter_value;
            END IF;
        ELSIF h_parameter_type = 'TF' THEN
            -- tab filter
            IF x_tab_filter IS NULL THEN
                x_tab_filter := h_parameter_value;
            ELSE
                x_tab_filter := x_tab_filter||','||h_parameter_value;
            END IF;
        ELSIF h_parameter_type = 'KF' THEN
            -- kpi filter
            IF x_kpi_filter IS NULL THEN
                x_kpi_filter := h_parameter_value;
            ELSE
                x_kpi_filter := x_kpi_filter||','||h_parameter_value;
            END IF;
        ELSIF h_parameter_type = 'AF' THEN
            -- advanced features
            IF h_parameter_value = 'NULL' THEN
                x_adv_mig_features := null;
            ELSE
                x_adv_mig_features := h_parameter_value;
            END IF;
        ELSIF h_parameter_type = 'DB' THEN
            -- database link
            x_db_link := h_parameter_value;
        ELSE
      -- overwrite flag 'OF'
            -- It is expected only one record
            x_overwrite := h_parameter_value;
        END IF;
    END LOOP;
    CLOSE h_cursor;

END Get_Migration_Parameters;


/*===========================================================================+
| PROCEDURE Init_Invalid_PMF_Objects
+============================================================================*/
PROCEDURE Init_Invalid_PMF_Objects IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(20000);

    h_pmf VARCHAR2(3) := 'PMF';

    h_invalid_measure VARCHAR2(50);
    h_invalid_dimension VARCHAR2(50);
    h_invalid_dim_level VARCHAR2(50);
    h_invalid_kpi NUMBER;

    --Fix bug#4226188 : need these new variables
    h_bis_dimension_rec       BIS_DIMENSION_PUB.Dimension_Rec_Type;
    h_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
    h_return_status     VARCHAR2(1);
    h_dgrp_dim VARCHAR2(50);

BEGIN

    -- --------------------------------------------------------------------------
    -- Get the PMF dimensions (dimension groups) used in the source system that do no exist in
    -- the target system

    -- Enh#4697749
    -- First we are going to migrate all the non-pre-seeded existing source dimensions
    -- those are BSC/PMF dimensions created by the customer and not by product teams
    -- it will migrate also all the DGRP_% dimensions
    Migrate_Custom_PMF_Dimensions;

    -- Get all the invalid dimensions. PMF dimensions not existing in the target
    g_num_invalid_pmf_dimensions := 0;
    h_sql := 'SELECT DISTINCT bsc_d.short_name'||
             ' FROM bsc_sys_dim_levels_b@'||g_db_link||' bsc_do,'||
             ' bsc_sys_dim_groups_vl@'||g_db_link||' bsc_d,'||
             ' bsc_sys_dim_levels_by_group@'||g_db_link||' bsc_dlg,'||
             ' bis_dimensions pmf_d'||
             ' WHERE bsc_do.dim_level_id = bsc_dlg.dim_level_id AND'||
             ' bsc_dlg.dim_group_id = bsc_d.dim_group_id AND'||
             ' bsc_do.source = :1 AND'||
             ' bsc_d.short_name = pmf_d.short_name(+) AND'||
             ' pmf_d.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_dimension;
        EXIT WHEN h_cursor%NOTFOUND;

        g_num_invalid_pmf_dimensions := g_num_invalid_pmf_dimensions + 1;
        g_invalid_pmf_dimensions(g_num_invalid_pmf_dimensions) := h_invalid_dimension;
    END LOOP;
    CLOSE h_cursor;

    -- Get indicators using those invalid dimensions
    h_sql := 'SELECT DISTINCT k.indicator'||
             ' FROM bsc_kpi_dim_groups@'||g_db_link||' k,'||
             ' bsc_sys_dim_levels_b@'||g_db_link||' bsc_do,'||
             ' bsc_sys_dim_groups_vl@'||g_db_link||' bsc_d,'||
             ' bsc_sys_dim_levels_by_group@'||g_db_link||' bsc_dlg,'||
             ' bis_dimensions pmf_d'||
             ' WHERE k.dim_group_id = bsc_d.dim_group_id AND'||
             ' bsc_do.dim_level_id = bsc_dlg.dim_level_id AND'||
             ' bsc_dlg.dim_group_id = bsc_d.dim_group_id AND'||
             ' bsc_do.source = :1 AND'||
             ' bsc_d.short_name = pmf_d.short_name(+) AND'||
             ' pmf_d.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_kpi;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Item_Belong_To_Array_Number(h_invalid_kpi, g_invalid_kpis, g_num_invalid_kpis) THEN
            g_num_invalid_kpis := g_num_invalid_kpis + 1;
            g_invalid_kpis(g_num_invalid_kpis) := h_invalid_kpi;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- ---------------------------------------------------------------------
    -- Get the PMF dimension levels used in the source system that do no exist in
    -- the target system

    -- Enh#4697749
    -- First we are going to migrate all the non-pre-seeded existing source dimension levels
    -- those are BSC/PMF dimension levels created by the customer and not by product teams
    Migrate_Custom_PMF_Dim_Levels;

    -- Get all the invalid dimension levels. PMF dimension levels not existing in the target
    g_num_invalid_pmf_dim_levels := 0;
    h_sql := 'SELECT DISTINCT bsc_dl.short_name'||
             ' FROM bsc_sys_dim_levels_b@'||g_db_link||' bsc_dl, bis_levels pmf_dl'||
             ' WHERE bsc_dl.source = :1 AND'||
             ' bsc_dl.short_name = pmf_dl.short_name(+) AND'||
             ' pmf_dl.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_dim_level;
        EXIT WHEN h_cursor%NOTFOUND;

        g_num_invalid_pmf_dim_levels := g_num_invalid_pmf_dim_levels + 1;
        g_invalid_pmf_dim_levels(g_num_invalid_pmf_dim_levels) := h_invalid_dim_level;
    END LOOP;
    CLOSE h_cursor;

    -- Get indicators using those invalid dimension levels
    h_sql := 'SELECT DISTINCT k.indicator'||
             ' FROM bsc_kpi_dim_levels_b@'||g_db_link||' k,'||
             ' bsc_sys_dim_levels_b@'||g_db_link||' bsc_dl,'||
             ' bis_levels pmf_dl'||
             ' WHERE k.level_table_name = bsc_dl.level_table_name AND'||
             ' bsc_dl.source = :1 AND'||
             ' bsc_dl.short_name = pmf_dl.short_name(+) AND'||
             ' pmf_dl.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_kpi;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Item_Belong_To_Array_Number(h_invalid_kpi, g_invalid_kpis, g_num_invalid_kpis) THEN
            g_num_invalid_kpis := g_num_invalid_kpis + 1;
            g_invalid_kpis(g_num_invalid_kpis) := h_invalid_kpi;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- ---------------------------------------------------------------------
    -- Get the PMF measures used in the source system that do no exist in
    -- the target system

    -- Enh#4697749
    -- First we are going to migrate all the non-pre-seeded existing source measures
    -- those are BSC/PMF measures created by the customer and not by product teams
    Migrate_Custom_PMF_Measures;

    -- Get all the invalid measures. PMF measures not existing in the target
    g_num_invalid_pmf_measures := 0;
    h_sql := 'SELECT DISTINCT bsc_m.short_name'||
             ' FROM bsc_sys_measures@'||g_db_link||' bsc_m, bis_indicators pmf_m'||
             ' WHERE bsc_m.source = :1 AND'||
             ' bsc_m.short_name = pmf_m.short_name(+) AND'||
             ' pmf_m.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_measure;
        EXIT WHEN h_cursor%NOTFOUND;

        g_num_invalid_pmf_measures := g_num_invalid_pmf_measures + 1;
        g_invalid_pmf_measures(g_num_invalid_pmf_measures) := h_invalid_measure;
    END LOOP;
    CLOSE h_cursor;

    -- Get indicators using those invalid measures
    --Fix bug#4932663 remove this line
    --g_num_invalid_kpis := 0;

    h_sql := 'SELECT DISTINCT k.indicator'||
             ' FROM bsc_kpi_analysis_measures_b@'||g_db_link||' k,'||
             ' bsc_sys_datasets_b@'||g_db_link||' d,'||
             ' bsc_sys_measures@'||g_db_link||' m,'||
             ' bis_indicators i'||
             ' WHERE k.dataset_id = d.dataset_id AND'||
             ' d.measure_id1 = m.measure_id AND'||
             ' m.source = :1 AND'||
             ' m.short_name = i.short_name (+) AND'||
             ' i.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_kpi;
        EXIT WHEN h_cursor%NOTFOUND;

        g_num_invalid_kpis := g_num_invalid_kpis + 1;
        g_invalid_kpis(g_num_invalid_kpis) := h_invalid_kpi;
    END LOOP;
    CLOSE h_cursor;

    -- ---------------------------------------------------------------------------
    -- Fix bug#4226188: This is a new validation. We want to get the dimensions used by the measures
    -- that not exists in the target
    h_sql := 'SELECT DISTINCT d.short_name'||
             ' FROM bis_indicator_dimensions@'||g_db_link||' id,'||
             ' bis_indicators@'||g_db_link||' i,'||
             ' bis_dimensions@'||g_db_link||' d,'||
             ' bis_dimensions td'||
             ' WHERE i.indicator_id = id.indicator_id AND'||
             ' d.dimension_id = id.dimension_id AND'||
             ' td.short_name = d.short_name(+) AND '||
             ' td.short_name IS NULL';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_invalid_dimension;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Item_Belong_To_Array_Varchar2(h_invalid_dimension, g_invalid_pmf_dimensions, g_num_invalid_pmf_dimensions) THEN
            g_num_invalid_pmf_dimensions := g_num_invalid_pmf_dimensions + 1;
            g_invalid_pmf_dimensions(g_num_invalid_pmf_dimensions) := h_invalid_dimension;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    --Fix bug#4226188: Now get the indicators using PMF measures whose dimensions does not exists in the target
    h_sql := 'SELECT DISTINCT k.indicator'||
             ' FROM bsc_kpi_analysis_measures_b@'||g_db_link||' k,'||
             ' bsc_sys_datasets_b@'||g_db_link||' d,'||
             ' bsc_sys_measures@'||g_db_link||' m,'||
             ' bis_indicator_dimensions@'||g_db_link||' id,'||
             ' bis_indicators@'||g_db_link||' i,'||
             ' bis_dimensions@'||g_db_link||' sd,'||
             ' bis_dimensions td'||
             ' WHERE k.dataset_id = d.dataset_id AND'||
             ' d.measure_id1 = m.measure_id AND'||
             ' m.source = :1 AND'||
             ' m.short_name = i.short_name AND'||
             ' i.indicator_id = id.indicator_id AND'||
             ' sd.dimension_id = id.dimension_id AND'||
             ' td.short_name = sd.short_name(+) AND'||
             ' td.short_name IS NULL';
    OPEN h_cursor FOR h_sql USING h_pmf;
    LOOP
        FETCH h_cursor INTO h_invalid_kpi;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Item_Belong_To_Array_Number(h_invalid_kpi, g_invalid_kpis, g_num_invalid_kpis) THEN
            g_num_invalid_kpis := g_num_invalid_kpis + 1;
            g_invalid_kpis(g_num_invalid_kpis) := h_invalid_kpi;
        END IF;
    END LOOP;
    CLOSE h_cursor;

END Init_Invalid_PMF_Objects;


/*===========================================================================+
| PROCEDURE Init_Metadata_Tables_Array
+============================================================================*/
PROCEDURE Init_Metadata_Tables_Array IS
BEGIN
    g_num_metadata_tables := 0;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_BIS_MEASURES_DATA';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_CALCULATIONS';
    g_metadata_tables(g_num_metadata_tables).level := 3;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TABLE_NAME';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_CALENDAR';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_LOADER_CONTROL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_MEASURE_COLS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    -- Bug#2977516 We need to migrate all rows in BSC_DB_MEASURE_COLS_TL
    -- There are valid cases were a column is in BSC_DB_MEASURE_COLS_TL and not in BSC_SYS_MEASURES:
    -- 1. Internal columns
    -- 2. Measures renamed as formulas
    --g_metadata_tables(g_num_metadata_tables).level_condition := 'MEASURE_COL IN ('||
    --                                                            ' SELECT MEASURE_COL'||
    --                                                            ' FROM BSC_SYS_MEASURES@'||g_db_link||
    --                                                            ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_MEASURE_GROUPS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_PROCESS_CONTROL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_RESERVED_WORDS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    -- This table will copy data tables according to the kpis being migrated.
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_TABLES';
    g_metadata_tables(g_num_metadata_tables).level := 3;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TABLE_NAME';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    -- This is for input tables for dimensions which are system level objects
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_TABLES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition :=  'TABLE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_TABLES_COLS';
    g_metadata_tables(g_num_metadata_tables).level := 3;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TABLE_NAME';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    -- This table will copy relationships between DATA tables
    -- according to the kpis being migrated
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_TABLES_RELS';
    g_metadata_tables(g_num_metadata_tables).level := 3;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TABLE_NAME';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

     -- This is for relations between dimension tables and input tables which are system level objects
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_TABLES_RELS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'TABLE_NAME IN ('||
                                                                ' SELECT LEVEL_TABLE_NAME'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||')';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    -- Add for bug#2728248
    -- This is for relations between MN dimension tables and its input tables which are system level objects
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_TABLES_RELS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'TABLE_NAME IN ('||
                                                                ' SELECT RELATION_COL'||
                                                                ' FROM BSC_SYS_DIM_LEVEL_RELS@'||g_db_link||
                                                                ' WHERE RELATION_TYPE = 2)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_VALIDATION';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_DB_WEEK_MAPS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_CALENDARS_B';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'NVL(EDW_FLAG, 0) = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_CALENDARS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'CALENDAR_ID IN ('||
                                                                ' SELECT CALENDAR_ID'||
                                                                ' FROM BSC_SYS_CALENDARS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_EDW_CALENDAR_TYPE_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_EDW_PERIODS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPIS_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPIS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_ANALYSIS_GROUPS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_ANALYSIS_MEASURES_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_ANALYSIS_MEASURES_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_ANALYSIS_OPT_USER';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_ANALYSIS_OPTIONS_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_ANALYSIS_OPTIONS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_CALCULATIONS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_CALCULATIONS_USER';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_CAUSE_EFFECT_RELS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_COMMENTS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DATA_TABLES';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DEFAULTS_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DEFAULTS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DIM_GROUPS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DIM_LEVELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DIM_LEVELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DIM_LEVELS_USER';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DIM_LEVEL_PROPERTIES';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_DIM_SETS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_GRAPHS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_MM_CONTROLS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_PERIODICITIES';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_PERIODICITIES_USER';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_PROPERTIES';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_SERIES_COLORS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_SHELL_CMDS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_SHELL_CMDS_USER';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_SUBTITLES_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_TREE_NODES_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_TREE_NODES_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    --BSC-MV Note: This table is part of ODF, so we can migrate even in old architecture
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_REPORTING_CALENDAR';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    -- Fix bug#4873669: bsc_reporting_calendar is partitioned now. We are not going to
    -- copy the data from source. We are going to call populate_reporting_calendar
    -- later.
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE; --TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_BENCHMARKS_B';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_BENCHMARKS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_BM_GROUPS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_CALCULATIONS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_COM_DIM_LEVELS';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DATASETS_B';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'NVL(EDW_FLAG, 0) = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DATASETS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DATASET_ID IN ('||
                                                                ' SELECT DATASET_ID'||
                                                                ' FROM BSC_SYS_DATASETS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DATASET_CALC';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DATASET_ID IN ('||
                                                                ' SELECT DATASET_ID'||
                                                                ' FROM BSC_SYS_DATASETS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DIM_GROUPS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DIM_LEVELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition :=  'NVL(EDW_FLAG, 0) = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DIM_LEVELS_BY_GROUP';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DIM_LEVELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DIM_LEVEL_COLS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_DIM_LEVEL_RELS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILES';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILTERS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0 AND'||
                                                                ' DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILTERS';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1 AND'||
                                                                ' DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILTERS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILTERS_VIEWS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0 AND'||
                                                                ' DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILTERS_VIEWS';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1 AND'||
                                                                ' DIM_LEVEL_ID IN ('||
                                                                ' SELECT DIM_LEVEL_ID'||
                                                                ' FROM BSC_SYS_DIM_LEVELS_B@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG,0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FILTERS_VIEWS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_FORMATS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_IMAGES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;  --blob columns are handled by DMLs as others type of columns
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_IMAGES_MAP_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;
    --CONDITION CHANGE FOR ENH 5844382, PICK UP SOURCE_TYPE = 3 ALSO
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_IMAGES_MAP_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1 OR SOURCE_TYPE = 3';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE; -- Only 1 flag per table

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_IMAGES_MAP_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE; --Only 1 flag per table
    /*--bug fix 5680620m bsc_sys_init is a special case and will be
        handled separately
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_INIT';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'PROPERTY_CODE <> ''EDW_INSTALLED''';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;*/

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_KPI_COLORS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LABELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LABELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LABELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LABELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LABELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE; -- Only 1 flag per table

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LABELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE; --Only 1 flag per table

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LINES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LINES';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_LINES';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_MEASURES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'NVL(EDW_FLAG, 0) = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_MM_CONTROLS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_PERIODICITIES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'NVL(EDW_FLAG, 0) = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_PERIODICITIES_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'PERIODICITY_ID IN ('||
                                                                ' SELECT PERIODICITY_ID'||
                                                                ' FROM BSC_SYS_PERIODICITIES@'||g_db_link||
                                                                ' WHERE NVL(EDW_FLAG, 0) = 0)';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_PERIODS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_PERIODS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_SERIES_COLORS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_USER_OPTIONS';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 0';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_USER_OPTIONS';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 1';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_USER_OPTIONS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'SOURCE_CODE';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'SOURCE_TYPE = 2';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TABS_B';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TABS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_CSF_B';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_CSF_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_INDICATORS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_IND_GROUPS_B';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_IND_GROUPS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEW_KPI_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    -- bug 5990196 for tables bsc_tab_view_labels_b and bsc_tab_view_labels_tl
    -- added condition for objective based migration of data, as the tab_id is -99
    -- for simulation objectives

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEW_LABELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEW_LABELS_B';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_VIEW_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'TAB_ID = -999';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEW_LABELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEW_LABELS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_VIEW_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := 'TAB_ID = -999';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEWS_B';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_TAB_VIEWS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 1;
    g_metadata_tables(g_num_metadata_tables).level_column := 'TAB_ID';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_UI_COLOR_SCHEMES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_UI_COLOR_USER';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := FALSE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_COLORS_B';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_COLORS_TL';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := TRUE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_COLOR_TYPE_PROPS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    --5979829 bug fix, added right parenthesis.. in the condition
    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_COLOR_RANGES';
    g_metadata_tables(g_num_metadata_tables).level := 0;
    g_metadata_tables(g_num_metadata_tables).level_column := NULL;
    g_metadata_tables(g_num_metadata_tables).level_condition := ' COLOR_RANGE_ID IN ( ' ||
                                                                ' SELECT COLOR_RANGE_ID ' ||
                                                                ' FROM BSC_COLOR_TYPE_PROPS) ';
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_MEASURE_PROPS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_KPI_MEASURE_WEIGHTS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    g_num_metadata_tables := g_num_metadata_tables + 1;
    g_metadata_tables(g_num_metadata_tables).table_name := 'BSC_SYS_OBJECTIVE_COLORS';
    g_metadata_tables(g_num_metadata_tables).level := 2;
    g_metadata_tables(g_num_metadata_tables).level_column := 'INDICATOR';
    g_metadata_tables(g_num_metadata_tables).level_condition := NULL;
    g_metadata_tables(g_num_metadata_tables).copy_flag := TRUE;
    g_metadata_tables(g_num_metadata_tables).lang_flag := FALSE;

    -- Tables with information by customized by user
    -- These tables are not migrated but we need to delete records from target system
    --  BSC_KPI_ANALYSIS_OPT_USER
    --  BSC_KPI_CALCULATIONS_USER
    --  BSC_KPI_DIM_LEVELS_USER
    --  BSC_KPI_PERIODICITIES_USER
    --  BSC_KPI_SHELL_CMDS_USER
    --  BSC_UI_COLOR_USER
    --  BSC_KPI_GRAPHS (This table needs to be deleted in the target. Portlet wiil create
    --                  records here dynamically and we cannot leave as is becasue
    --                  this table make reference to images in BSC_SYS_IMAGES and
    --                  after migration the images could not correspond.
    --  BSC_BIS_MEASURES_DATA (This table needs to be deleted in the target. Viewer will create
    --                  records here dynamically by demand.

    -- Bug 2125440 (Solution approved by Patricia and Vinod)
    -- This tables are not deleted from the target and are not copied from source
    -- because they are used by portlets.
    --  BSC_USER_KPIGRAPH_PLUGS
    --  BSC_USER_KPILIST_PLUGS
    --  BSC_USER_KPILIST_KPIS
    --  BSC_USER_PARAMETERS_B
    --  BSC_USER_PARAMETERS_TL

    -- Security Level tables
    --  BSC_APPS_USERS
    --  BSC_RESPONSIBILITY
    --  BSC_RESPONSIBILITY_TL
    --  BSC_USERS
    --  BSC_USER_INFO
    --  BSC_USER_KPI_ACCESS
    --  BSC_USER_LIST_ACCESS
    --  BSC_USER_RESPONSIBILITY
    --  BSC_USER_TAB_ACCESS

    -- This table is not deleted from the target and is not copied from source
    -- because the migration program use this table.
    -- BSC_MESSAGE_LOGS

    -- Ignored tables.
    -- BSC_INSTALL_LOGS
    -- BSC_UPGRADE_TASK

END Init_Metadata_Tables_Array;


/*===========================================================================+
| FUNCTION Init_Migration_Objects_Arrays
+============================================================================*/
FUNCTION Init_Migration_Objects_Arrays RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32700);

    h_filter_condition VARCHAR2(32700);
    h_resp_cond VARCHAR2(32700);
    h_tab_cond VARCHAR2(32700);
    h_kpi_cond VARCHAR2(32700);

    h_message VARCHAR2(2000);

    h_i NUMBER;

    h_tab_id NUMBER;
    h_kpi_id NUMBER;

    h_table VARCHAR2(30);
    h_tables t_array_of_varchar2;
    h_num_tables NUMBER := 0;

BEGIN

    -- ------------------------------------------------------------------------------------
    -- Initialize the arrays of PMF measures, dimensions and dimension levels that do not
    -- exist in the target. Also init an array with the indicators using those PMF objects
    -- We cannot migrate those indicators.
    Init_Invalid_PMF_Objects;
    -- ------------------------------------------------------------------------------------

    h_resp_cond := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'r.responsibility_id');
    FOR h_i IN 1 .. g_num_src_resps LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, g_src_resps(h_i));
    END LOOP;

    h_tab_cond := BSC_APPS.Get_New_Big_In_Cond_Number(2, 'rt.tab_id');
    FOR h_i IN 1 .. g_num_tabs_filter LOOP
        BSC_APPS.Add_Value_Big_In_Cond(2, g_tabs_filter(h_i));
    END LOOP;

    h_kpi_cond := BSC_APPS.Get_New_Big_In_Cond_Number(3, 'rk.indicator');
    FOR h_i IN 1 .. g_num_kpis_filter LOOP
        BSC_APPS.Add_Value_Big_In_Cond(3, g_kpis_filter(h_i));
    END LOOP;

    h_filter_condition := '('||h_resp_cond||')';
    IF g_num_tabs_filter > 0 THEN
        h_filter_condition := h_filter_condition||' AND ('||h_tab_cond||')';
    END IF;
    IF g_num_kpis_filter > 0 THEN
        h_filter_condition := h_filter_condition||' AND ('||h_kpi_cond||')';
    END IF;

    -- Initialize migration objects arrays: g_mig_tabs, g_mig_kpis and g_mig_tables
    -- EDW Note: No EDW Kpis con be migratred
    h_sql := 'SELECT rt.tab_id, rk.indicator'||
             ' FROM bsc_responsibility_vl@'||g_db_link||' r,'||
             '      bsc_user_tab_access@'||g_db_link||' rt,'||
             '      bsc_user_kpi_access@'||g_db_link||' rk,'||
             '      bsc_tab_indicators@'||g_db_link||' tk,'||
             '      bsc_kpis_b@'||g_db_link||' k'||
             ' WHERE r.responsibility_id = rt.responsibility_id AND'||
             '       r.responsibility_id = rk.responsibility_id AND'||
             '       rt.tab_id = tk.tab_id AND'||
             '       rk.indicator = tk.indicator AND'||
             '       tk.indicator = k.indicator AND'||
             '       NVL(k.edw_flag, 0) = 0 AND '||h_filter_condition;
    OPEN h_cursor FOR h_sql;

    g_num_mig_tabs := 0;
    g_num_mig_kpis := 0;
    g_num_mig_tables := 0;
    g_num_no_mig_kpis := 0;

    LOOP
        FETCH h_cursor INTO h_tab_id, h_kpi_id;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Item_Belong_To_Array_Number(h_tab_id, g_mig_tabs, g_num_mig_tabs) THEN
            g_num_mig_tabs := g_num_mig_tabs + 1;
            g_mig_tabs(g_num_mig_tabs) := h_tab_id;
        END IF;

        IF NOT Item_Belong_To_Array_Number(h_kpi_id, g_mig_kpis, g_num_mig_kpis) THEN
            -- Verify that the indicator is not in the array of invalid Kpis
            -- Those Kpis are using PMF objects that do no exists in the target
            IF NOT Item_Belong_To_Array_Number(h_kpi_id, g_invalid_kpis, g_num_invalid_kpis) THEN
                g_num_mig_kpis := g_num_mig_kpis + 1;
                g_mig_kpis(g_num_mig_kpis) := h_kpi_id;
            ELSE
                -- This is the array of Kpis that cannot be migrated because are using PMF
                -- objects that do not exist in the target environment
                g_num_no_mig_kpis := g_num_no_mig_kpis + 1;
                g_no_mig_kpis(g_num_no_mig_kpis) := h_kpi_id;
            END IF;
        END IF;

    END LOOP;
    CLOSE h_cursor;

    -- Now we need to add the tabs that do not have kpis associated to them.
    -- This is done oly if the filter is not by indicator
    IF g_num_kpis_filter = 0 THEN
        -- The filter is not by indicator
        -- h_filter_condition already is set.

        h_sql := 'SELECT rt.tab_id'||
                 ' FROM bsc_responsibility_vl@'||g_db_link||' r,'||
                 '      bsc_user_tab_access@'||g_db_link||' rt'||
                 ' WHERE r.responsibility_id = rt.responsibility_id AND '||h_filter_condition;
        OPEN h_cursor FOR h_sql;

        LOOP
            FETCH h_cursor INTO h_tab_id;
            EXIT WHEN h_cursor%NOTFOUND;

            IF NOT Item_Belong_To_Array_Number(h_tab_id, g_mig_tabs, g_num_mig_tabs) THEN
                g_num_mig_tabs := g_num_mig_tabs + 1;
                g_mig_tabs(g_num_mig_tabs) := h_tab_id;
            END IF;
        END LOOP;
        CLOSE h_cursor;

    END IF;

    -- Initialize the array of tables that are used by those KPIs
    IF g_num_mig_kpis > 0 THEN
        h_kpi_cond := BSC_APPS.Get_New_Big_In_Cond_Number(4, 'indicator');
        FOR h_i IN 1 .. g_num_mig_kpis LOOP
            BSC_APPS.Add_Value_Big_In_Cond(4, g_mig_kpis(h_i));
        END LOOP;

        h_sql := 'SELECT DISTINCT table_name'||
                 ' FROM bsc_kpi_data_tables_v@'||g_db_link||
                 ' WHERE ('||h_kpi_cond||') AND'||
                 '       table_name IS NOT NULL';
        OPEN h_cursor FOR h_sql;
        LOOP
            FETCH h_cursor INTO h_table;
            EXIT WHEN h_cursor%NOTFOUND;

            g_num_mig_tables := g_num_mig_tables + 1;
            g_mig_tables(g_num_mig_tables) := h_table;

            h_num_tables := h_num_tables + 1;
            h_tables(h_num_tables) := h_table;

        END LOOP;
        CLOSE h_cursor;

        -- Add the parent tables until the input tables
        Insert_Origin_Tables(h_tables, h_num_tables);

    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Init_Migration_Objects_Arrays');
        RETURN FALSE;

END Init_Migration_Objects_Arrays;


/*===========================================================================+
| FUNCTION Is_Input_Table
+============================================================================*/
FUNCTION Is_Input_Table(
  x_table_name IN VARCHAR2
  ) RETURN BOOLEAN IS

    CURSOR c_table_type IS
        SELECT table_type
        FROM bsc_db_tables
        WHERE table_name = x_table_name;

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

END Is_Input_Table;


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
| PROCEDURE Insert_Origin_Tables
+============================================================================*/
PROCEDURE Insert_Origin_Tables(
  x_tables IN t_array_of_varchar2,
  x_num_tables IN NUMBER
  ) IS

    h_sql VARCHAR2(32700);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_table VARCHAR2(30);
    h_tables t_array_of_varchar2;
    h_num_tables NUMBER := 0;

    h_table_cond VARCHAR2(32700);

BEGIN
    IF x_num_tables > 0 THEN

        h_table_cond := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'table_name');
        FOR h_i IN 1 .. x_num_tables LOOP
            BSC_APPS.Add_Value_Big_In_Cond(1, x_tables(h_i));
        END LOOP;

        h_sql := 'SELECT DISTINCT source_table_name'||
                 ' FROM bsc_db_tables_rels@'||g_db_link||
                 ' WHERE '||h_table_cond;
        OPEN h_cursor FOR h_sql;

        LOOP
            FETCH h_cursor INTO h_table;
            EXIT WHEN h_cursor%NOTFOUND;

            IF NOT Item_Belong_To_Array_Varchar2(h_table, g_mig_tables, g_num_mig_tables) THEN
                g_num_mig_tables := g_num_mig_tables + 1;
                g_mig_tables(g_num_mig_tables) := h_table;
            END IF;

            h_num_tables := h_num_tables + 1;
            h_tables(h_num_tables) := h_table;

        END LOOP;
        CLOSE h_cursor;

        -- Add the parent tables until the input tables
        Insert_Origin_Tables(h_tables, h_num_tables);

    END IF;

END Insert_Origin_Tables;


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
    h_lst VARCHAR2(32700) := NULL;

BEGIN
    FOR h_i IN 1 .. x_num_values LOOP
        IF h_lst IS NULL THEN
            h_lst := x_column||' = '||x_values(h_i);
        ELSE
            h_lst := h_lst||' '||x_separator||' '||x_column||' = '||x_values(h_i);
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Cond_Number;


/*===========================================================================+
| FUNCTION Make_Lst_Cond_Varchar2
+============================================================================*/
FUNCTION Make_Lst_Cond_Varchar2(
  x_column IN VARCHAR2,
  x_values IN t_array_of_varchar2,
        x_num_values IN NUMBER,
        x_separator IN VARCHAR2
  ) RETURN VARCHAR2 IS

    h_i NUMBER;
    h_lst VARCHAR2(32700) := NULL;

BEGIN
    FOR h_i IN 1 .. x_num_values LOOP
        IF h_lst IS NULL THEN
            h_lst := 'UPPER('||x_column||') = '''||UPPER(x_values(h_i))||'''';
        ELSE
            h_lst := h_lst||' '||x_separator||' UPPER('||x_column||') = '''||UPPER(x_values(h_i))||'''';
        END IF;
    END LOOP;

    RETURN h_lst;

END Make_Lst_Cond_Varchar2;


/*===========================================================================+
| FUNCTION Migrate_Dynamic_Tables_Data
+============================================================================*/
FUNCTION Migrate_Dynamic_Tables_Data RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_table VARCHAR2(30);

    h_base_message VARCHAR2(4000);
    h_message VARCHAR2(4000);

    -- ENH_B_TABES_PERF: new variables
    h_proj_table_name VARCHAR2(30);

BEGIN

    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_TABLES_DATA'), BSC_APPS.OUTPUT_FILE);

    h_base_message := BSC_APPS.Get_Message('BSC_MIG_DATA');

    -- Dimension tables
    h_sql :=  'SELECT level_table_name'||
              ' FROM bsc_sys_dim_levels_b'||
              ' WHERE NVL(source, ''BSC'') = ''BSC''';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        -- Fix bug#4430901 add append hint
        -- Fix performance bug#3860149: use parallel hint
        h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                 ' SELECT /*+ parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
        BSC_APPS.Execute_Immediate(h_sql);

        COMMIT;
    END LOOP;
    CLOSE h_cursor;

    -- No need to copy input tables for dimensions.

    -- MN Dimension tables
    h_sql :=  'SELECT DISTINCT relation_col'||
              ' FROM bsc_sys_dim_level_rels'||
              ' WHERE relation_type = 2';
    OPEN h_cursor FOR h_sql;
    LOOP
        FETCH h_cursor INTO h_table;
        EXIT WHEN h_cursor%NOTFOUND;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        -- Fix bug#4430901 add append hint
        -- Fix performance bug#3860149: use parallel hint
        h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                 ' SELECT /* parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
        BSC_APPS.Execute_Immediate(h_sql);

        COMMIT;
    END LOOP;
    CLOSE h_cursor;

    -- Data tables
    FOR h_i IN 1..g_num_mig_tables LOOP
        h_table := g_mig_tables(h_i);

        --BSC-MV Note: Migrate only existing tables
        IF g_adv_sum_level IS NULL THEN
            -- BSC summary tables architecture. All summary tables exists

            -- ENH_B_TABLES_PERF: for base table we need to check if it has a projection table.
            -- in this case the base table is in the new architecture (partitions and projection table)
            -- We need to fix the batch column in th esame time we are inserting rows inthe target
            -- since the number of partititons may be different from the source.
            IF Is_Base_Table(h_table) THEN
                h_proj_table_name := Get_Proj_Table_Name(h_table);
                IF h_proj_table_name IS NOT NULL THEN
                    IF NOT Migrate_BTable_With_Partitions(h_table, h_proj_table_name) THEN
                        RAISE e_unexpected_error;
                    END IF;
                ELSE
                    -- This is a normal B table
                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                    -- Fix bug#4430901 add append hint
                    -- Fix performance bug#3860149: use parallel hint
                    h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                             ' SELECT /*+ parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
                    BSC_APPS.Execute_Immediate(h_sql);
                    commit;
                END IF;
            ELSE
                -- This is not a base table
                h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                -- Fix bug#4430901 add append hint
                -- Fix performance bug#3860149: use parallel hint
                h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                         ' SELECT /*+ parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
                BSC_APPS.Execute_Immediate(h_sql);
                commit;
            END IF;
        ELSE
            -- BSC-MV architecture. Generation type = -1 means the table does not exists
            IF BSC_UPDATE_UTIL.Get_Table_Generation_Type(h_table) <> -1 THEN
                -- ENH_B_TABLES_PERF: for base table we need to check if it has a projection table.
                -- in this case the base table is in the new architecture (partitions and projection table)
                -- We need to fix the batch column in th esame time we are inserting rows inthe target
                -- since the number of partititons may be different from the source.
                IF Is_Base_Table(h_table) THEN
                    h_proj_table_name := Get_Proj_Table_Name(h_table);
                    IF h_proj_table_name IS NOT NULL THEN
                        IF NOT Migrate_BTable_With_Partitions(h_table, h_proj_table_name) THEN
                            RAISE e_unexpected_error;
                        END IF;
                    ELSE
                        -- This is a normal B table
                        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                        -- Fix bug#4430901 add append hint
                        -- Fix performance bug#3860149: use parallel hint
                        h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                                 ' SELECT /*+ parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
                        BSC_APPS.Execute_Immediate(h_sql);
                        commit;
                    END IF;
                ELSE
                    -- This is not a base table
                    h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
                    BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

                    -- Fix bug#4430901 add append hint
                    -- Fix performance bug#3860149: use parallel hint
                    h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                             ' SELECT /*+ parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
                    BSC_APPS.Execute_Immediate(h_sql);
                    commit;
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- BSC-MV Note: Migrate data of projection tables
    IF g_adv_sum_level IS NOT NULL THEN
        h_sql :=  'SELECT DISTINCT projection_data'||
                  ' FROM bsc_kpi_data_tables'||
                  ' WHERE projection_data IS NOT NULL';
        OPEN h_cursor FOR h_sql;
        LOOP
            FETCH h_cursor INTO h_table;
            EXIT WHEN h_cursor%NOTFOUND;

            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            IF Exist_Table_In_Src(h_table) THEN
                -- Fix bug#4430901 add append hint
                -- Fix performance bug#3860149: use parallel hint
                h_sql := 'INSERT /*+ append parallel('||h_table||') */ INTO '||h_table||
                         ' SELECT /*+ parallel('||h_table||') */ * FROM '||h_table||'@'||g_db_link;
                BSC_APPS.Execute_Immediate(h_sql);
                commit;
            END IF;
        END LOOP;
        CLOSE h_cursor;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_UNEXPECTED_ERROR'),
                         x_source => 'BSC_MIGRATION.Migrate_Dynamic_Tables_Data');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Migrate_Dynamic_Tables_Data');
        RETURN FALSE;

END Migrate_Dynamic_Tables_Data;


/*===========================================================================+
| FUNCTION Migrate_Metadata
+============================================================================*/
FUNCTION Migrate_Metadata RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    h_i NUMBER;
    h_j NUMBER;
    h_mig_condition VARCHAR2(32700) := NULL;
    h_cause_cond VARCHAR2(32700) := NULL;
    h_effect_cond VARCHAR2(32700) := NULL;

    h_table_name VARCHAR2(30);
    h_level NUMBER;
    h_level_column VARCHAR2(30);
    h_level_condition VARCHAR2(200);

    h_base_message VARCHAR2(4000);
    h_message VARCHAR2(4000);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32700);

    h_lst_table_columns VARCHAR2(32700) := NULL;

    h_currval NUMBER;
    h_src_currval NUMBER;
    h_interval NUMBER;

BEGIN

    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_METADATA'), BSC_APPS.OUTPUT_FILE);

    h_base_message := BSC_APPS.Get_Message('BSC_MIG_DATA');

    FOR h_i IN 1..g_num_metadata_tables LOOP
        IF g_metadata_tables(h_i).copy_flag THEN
            h_table_name := g_metadata_tables(h_i).table_name;
            h_level := g_metadata_tables(h_i).level;
            h_level_column := g_metadata_tables(h_i).level_column;
            h_level_condition := g_metadata_tables(h_i).level_condition;

            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table_name);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            h_mig_condition := NULL;

            IF h_level = 0 THEN
                -- System Level
                h_mig_condition := NULL;

            ELSIF h_level = 1 THEN
                -- Tab level
                h_mig_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, h_level_column);
                FOR h_j IN 1 .. g_num_mig_tabs LOOP
                    BSC_APPS.Add_Value_Big_In_Cond(1, g_mig_tabs(h_j));
                END LOOP;

            ELSIF h_level = 2 THEN
                -- KPI Level
                h_mig_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, h_level_column);
                FOR h_j IN 1 .. g_num_mig_kpis LOOP
                    BSC_APPS.Add_Value_Big_In_Cond(1, g_mig_kpis(h_j));
                END LOOP;

            ELSIF h_level = 3 THEN
                -- Table level
                h_mig_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, h_level_column);
                FOR h_j IN 1 .. g_num_mig_tables LOOP
                    BSC_APPS.Add_Value_Big_In_Cond(1, g_mig_tables(h_j));
                END LOOP;

            END IF;

            IF h_level_condition IS NOT NULL THEN
                IF h_mig_condition IS NULL THEN
                    h_mig_condition := h_level_condition;
                ELSE
                    h_mig_condition := h_level_condition||' AND ('||h_mig_condition||')';
                END IF;
            END IF;

            h_lst_table_columns := Get_Lst_Table_Columns(g_metadata_tables(h_i).table_name);
            -- Fix bug#4430901: add append hint
            -- Fix performance bug#3860149: use parallel hint
            h_sql := 'INSERT  /*+ append parallel('||g_metadata_tables(h_i).table_name||') */'||
                     ' INTO '||g_metadata_tables(h_i).table_name||' ('||h_lst_table_columns||')'||
                     ' SELECT /*+ parallel('||g_metadata_tables(h_i).table_name||') */ '||h_lst_table_columns||
                     ' FROM '||g_metadata_tables(h_i).table_name||'@'||g_db_link;

            IF h_mig_condition IS NOT NULL THEN
                h_sql := h_sql||' WHERE '||h_mig_condition;
            END IF;
            BSC_APPS.Execute_Immediate(h_sql);

            COMMIT;
        END IF;
    END LOOP;

    -- Fix some problems
    -- 1. The table BSC_KPI_CAUSE_EFFECT_RELS only should have Kpis that are in g_mig_kpis
    --    in columns cause_indicator and effect_indicator
    h_cause_cond := BSC_APPS.Get_New_Big_In_Cond_Number(2, 'cause_indicator');

    FOR h_j in 1 .. g_num_mig_kpis LOOP
        BSC_APPS.Add_Value_Big_In_Cond(2, g_mig_kpis(h_j));
    END LOOP;

    h_effect_cond := BSC_APPS.Get_New_Big_In_Cond_Number(3, 'effect_indicator');
    FOR h_j in 1 .. g_num_mig_kpis LOOP
        BSC_APPS.Add_Value_Big_In_Cond(3, g_mig_kpis(h_j));
    END LOOP;

    h_sql := 'DELETE FROM bsc_kpi_cause_effect_rels'||
             ' WHERE NOT ('||h_cause_cond||') OR'||
             '       NOT ('||h_effect_cond||')';
    BSC_APPS.Execute_Immediate(h_sql);
    COMMIT;

    -- 2. Reset sequence BSC_SYS_IMAGE_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    -- Bug resetting sequences: We cannot drop the sequence to reset the start value because the packages
    -- using the sequence will become invalid.
    -- We will use alter sequence and NEXTVAL to reset the start value is the current value
    -- in the source system is greater than the current value in the target system.
    h_sql := 'SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_IMAGE_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_IMAGE_ID_S');

        SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_IMAGE_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_IMAGE_ID_S');
    END IF;

    -- 3. Reset sequence BSC_SYS_CALENDAR_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_SYS_CALENDAR_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_CALENDAR_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_CALENDAR_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_CALENDAR_ID_S');

        SELECT BSC_SYS_CALENDAR_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_CALENDAR_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_CALENDAR_ID_S');
    END IF;

    -- 4. Reset sequence BSC_SYS_PERIODICITY_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_SYS_PERIODICITY_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_PERIODICITY_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_PERIODICITY_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_PERIODICITY_ID_S');

        SELECT BSC_SYS_PERIODICITY_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_PERIODICITY_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_PERIODICITY_ID_S');
    END IF;

    -- 5. Migrate custom links
    IF BSC_APPS.APPS_ENV AND g_src_apps_flag THEN
        -- Source and target systems are in APPS
        IF NOT BSC_LAUNCH_PAD_PVT.Migrate_Custom_Links(g_db_link) THEN
            RAISE e_unexpected_error;
        END IF;
    ELSE
        -- Source or Target system is personal
        -- Update link_id to -1
        h_sql := 'UPDATE bsc_tab_view_labels_b
                  SET link_id = -1
                  WHERE label_type = 2';
        BSC_APPS.Execute_Immediate(h_sql);
    END IF;

    -- 6. Fix CREATED_BY and LAST_UPDATED_BY columns of BSC_KPI_COMMENTS
    --    according to users in the target system.
    --    Update those columns in the target system with the USER_ID from FND_USER
    --    whose USER_NAME is the same in the source system.
    --    If a USER_ID do not have a corresponding USER_ID in the target system,
    --    it will be set to the USER_ID of the SYSADMIN user.
    IF BSC_APPS.APPS_ENV THEN
        -- Target system is APPS
        IF g_src_apps_flag THEN
            -- Source system is APPS
            h_sql := 'UPDATE bsc_kpi_comments c
                      SET created_by = NVL((SELECT u.user_id
                                            FROM fnd_user u, fnd_user@'||g_db_link||' s
                                            WHERE u.user_name = s.user_name AND
                                                  c.created_by = s.user_id), :1),
                          last_updated_by = NVL((SELECT u.user_id
                                                 FROM fnd_user u, fnd_user@'||g_db_link||' s
                                                 WHERE u.user_name = s.user_name AND
                                                       c.last_updated_by = s.user_id), :2)';
            execute immediate h_sql using g_sysadmin_user_id, g_sysadmin_user_id;
        ELSE
            -- Source system is Personal
            h_sql := 'UPDATE bsc_kpi_comments c
                      SET created_by = :1,
                          last_updated_by = :2';
            execute immediate h_sql using g_sysadmin_user_id, g_sysadmin_user_id;
        END IF;
    END IF;

    -- 7. Reset sequence BSC_KPI_COMMENTS_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_KPI_COMMENTS_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_KPI_COMMENTS_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_KPI_COMMENTS_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_KPI_COMMENTS_ID_S');

        SELECT BSC_KPI_COMMENTS_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_KPI_COMMENTS_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_KPI_COMMENTS_ID_S');
    END IF;

    -- 8. Add TAB_ID -1 in BSC_TAB_IND_GROUPS_B and BSC_TAB_IND_GROUPS_TL
    INSERT INTO BSC_TAB_IND_GROUPS_TL (TAB_ID,CSF_ID,IND_GROUP_ID,LANGUAGE,SOURCE_LANG,NAME,HELP)
    SELECT -1,CSF_ID,IND_GROUP_ID,LANGUAGE,MIN(SOURCE_LANG),MIN(NAME),MIN(HELP)
    FROM BSC_TAB_IND_GROUPS_TL
    GROUP BY -1,CSF_ID,IND_GROUP_ID,LANGUAGE;

    INSERT INTO BSC_TAB_IND_GROUPS_B (TAB_ID,CSF_ID,IND_GROUP_ID,GROUP_TYPE,NAME_POSITION,
      NAME_JUSTIFICATION,LEFT_POSITION,TOP_POSITION,WIDTH,HEIGHT,SHORT_NAME)
    SELECT -1,CSF_ID,IND_GROUP_ID,MIN(GROUP_TYPE),MIN(NAME_POSITION),
      MIN(NAME_JUSTIFICATION),MIN(LEFT_POSITION),MIN(TOP_POSITION),MIN(WIDTH),MIN(HEIGHT),SHORT_NAME
    FROM BSC_TAB_IND_GROUPS_B
    GROUP BY -1,CSF_ID,IND_GROUP_ID,SHORT_NAME;

    -- 9. Fix OWNER_ID in BSC_TABS_B according to users in the target system.
    --    Update this column in the target system with the USER_ID from FND_USER
    --    whose USER_NAME is the same in the source system.
    --    If a USER_ID do not have a corresponding USER_ID in the target system,
    --    it will be set to the USER_ID of the SYSADMIN user.
    IF BSC_APPS.APPS_ENV THEN
        -- Target system is APPS
        IF g_src_apps_flag THEN
            -- Source system is APPS
            h_sql := 'UPDATE bsc_tabs_b c
                      SET owner_id = NVL((SELECT u.user_id
                                            FROM fnd_user u, fnd_user@'||g_db_link||' s
                                            WHERE u.user_name = s.user_name AND
                                                  c.owner_id = s.user_id), :1)';
            execute immediate h_sql using g_sysadmin_user_id;
        ELSE
            -- Source system is Personal
            h_sql := 'UPDATE bsc_tabs_b
                      SET owner_id = :1';
            execute immediate h_sql using g_sysadmin_user_id;
        END IF;
    END IF;

    -- 10. Set PARENT_TAB_ID to NULL in BSC_TABS_B for tabs whose parent was not migrated.
    UPDATE bsc_tabs_b
    SET parent_tab_id = NULL
    WHERE
        parent_tab_id NOT IN (
            SELECT tab_id
            FROM bsc_tabs_b
        );

    -- 11. Reset sequence BSC_INTERNAL_COLUMN_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_INTERNAL_COLUMN_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_INTERNAL_COLUMN_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_INTERNAL_COLUMN_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_INTERNAL_COLUMN_S');

        SELECT BSC_INTERNAL_COLUMN_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_INTERNAL_COLUMN_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_INTERNAL_COLUMN_S');
    END IF;

    -- 12. Reset sequence BSC_SYS_DIM_LEVEL_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_SYS_DIM_LEVEL_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_DIM_LEVEL_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_DIM_LEVEL_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_DIM_LEVEL_ID_S');

        SELECT BSC_SYS_DIM_LEVEL_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_DIM_LEVEL_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_DIM_LEVEL_ID_S');
    END IF;

    -- 13. Reset sequence BSC_SYS_DIM_GROUP_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_SYS_DIM_GROUP_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_DIM_GROUP_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_DIM_GROUP_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_DIM_GROUP_ID_S');

        SELECT BSC_SYS_DIM_GROUP_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_DIM_GROUP_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_DIM_GROUP_ID_S');
    END IF;

    -- 14. Reset sequence BSC_SYS_DATASET_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_SYS_DATASET_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_DATASET_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_DATASET_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_DATASET_ID_S');

        SELECT BSC_SYS_DATASET_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_DATASET_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_DATASET_ID_S');
    END IF;

    -- 15. Reset sequence BSC_SYS_MEASURE_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_SYS_MEASURE_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_SYS_MEASURE_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_SYS_MEASURE_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_MEASURE_ID_S');

        SELECT BSC_SYS_MEASURE_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_SYS_MEASURE_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_SYS_MEASURE_ID_S');
    END IF;

    -- 16. Reset sequence BSC_DB_MEASURE_GROUPS_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_DB_MEASURE_GROUPS_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_DB_MEASURE_GROUPS_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_DB_MEASURE_GROUPS_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_DB_MEASURE_GROUPS_S');

        SELECT BSC_DB_MEASURE_GROUPS_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_DB_MEASURE_GROUPS_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_DB_MEASURE_GROUPS_S');
    END IF;

    -- 17. Reset sequence BSC_INDICATOR_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_INDICATOR_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_INDICATOR_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_INDICATOR_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_INDICATOR_ID_S');

        SELECT BSC_INDICATOR_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_INDICATOR_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_INDICATOR_ID_S');
    END IF;

    -- 18. Reset sequence BSC_KPI_MEASURE_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_KPI_MEASURE_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_KPI_MEASURE_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_KPI_MEASURE_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_KPI_MEASURE_S');

        SELECT BSC_KPI_MEASURE_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_KPI_MEASURE_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_KPI_MEASURE_S');
    END IF;

    -- 18. Reset sequence BSC_COLOR_RANGE_ID_S to start with at least the same current value of the sequence
    -- in the source system.
    h_sql := 'SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL@'||g_db_link||' FROM DUAL';
    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_src_currval;
    CLOSE h_cursor;

    SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL INTO h_currval FROM DUAL;
    IF h_src_currval > h_currval THEN
        h_interval := h_src_currval - h_currval;

        h_sql := 'ALTER SEQUENCE BSC_COLOR_RANGE_ID_S INCREMENT BY '||h_interval;
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_COLOR_RANGE_ID_S');

        SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL INTO h_currval FROM DUAL;

        h_sql := 'ALTER SEQUENCE BSC_COLOR_RANGE_ID_S INCREMENT BY 1';
        BSC_APPS.Do_DDL(h_sql, AD_DDL.ALTER_SEQUENCE, 'BSC_COLOR_RANGE_ID_S');
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_MIG_FAIL_EXEC'),
                         x_source => 'BSC_MIGRATION.Migrate_Metadata');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Migrate_Metadata');
        RETURN FALSE;
END Migrate_Metadata;

/*===========================================================================+
| FUNCTION get_previous_migration_status
+============================================================================*/
FUNCTION get_previous_migration_status RETURN boolean IS
CURSOR cTable IS
SELECT property_value  FROM
bsc_sys_init WHERE property_code = 'TARGET_STATUS';

l_value VARCHAR2(400);
BEGIN
    OPEN cTable;
    FETCH cTable into l_value;
    CLOSE cTable;
    IF (l_value <> 'UNAPPLIED') THEN -- unapplied indicates error or process failure
        return true;
    ELSE
        return false;
    END IF;

END;


/*===========================================================================+
| FUNCTION table_exists
+============================================================================*/
FUNCTION table_exists(pTableName IN VARCHAR2, pSchema IN VARCHAR2) return boolean IS
CURSOR cTable IS
SELECT COUNT(1) FROM
ALL_TABLES WHERE TABLE_NAME = pTableName
AND OWNER = pSchema;
l_count NUMBER := 0;
BEGIN
    OPEN cTable;
    FETCH cTable into l_Count;
    CLOSE cTable;
    IF (l_count = 0) THEN
        return false;
    ELSE
        return true;
    END IF;

END;

PROCEDURE  create_comment_backup_table IS
l_stmt VARCHAR2(4000) := 'CREATE TABLE '||c_comments_bak||' AS
SELECT
 CMT.INDICATOR,
 CMT.YEAR,
 CMT.PERIODICITY_ID,
 CMT.PERIOD_ID,
 CMT.TREND_FLAG,
 CMT.COMMENT_TEXT,
 CMT.COMMENT_TYPE,
 CMT.CREATED_BY,
 CMT.CREATION_DATE,
 CMT.LAST_UPDATED_BY,
 CMT.LAST_UPDATE_DATE,
 CMT.LAST_UPDATE_LOGIN,
 CMT.COMMENT_SUBJECT,
 CMT.COMMENT_ID,
 ''N'' PRESERVE_FLAG,
  1000000 CONC_REQUEST_ID,
  sysdate MIGRATION_DATE
FROM
BSC_KPI_COMMENTS CMT,
BSC_KPIS_B TGT
WHERE
CMT.INDICATOR = TGT.INDICATOR';
    e_unexpected_error EXCEPTION;
BEGIN

    BSC_APPS.Do_DDL(l_stmt, AD_DDL.CREATE_TABLE, c_comments_bak);
    EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.create_comment_backup_table');
    RAISE e_unexpected_error;

END;

PROCEDURE  update_comment_backup_table IS
l_stmt VARCHAR2(4000) ;
    e_unexpected_error EXCEPTION;
BEGIN

    l_stmt := 'UPDATE '||c_comments_bak||' set preserve_flag = :1 where indicator in
        (SELECT TGT.INDICATOR FROM
            BSC_KPIS_B TGT,
            BSC_KPIS_B@'||g_db_link||' SRC
            WHERE
            TGT.INDICATOR = SRC.INDICATOR
            AND TGT.CREATION_DATE = SRC.CREATION_DATE)';
    execute immediate l_stmt using 'Y';

    -- new req. : need conc program id and migration_date
    -- note that this cannot be a part of the creation as the migration could have failed
    -- after table creation : the next migration will NOT create the backup table but will reuse it
    -- hence we need to update the conc_request_id to the current request id

    l_stmt := 'UPDATE '||c_comments_bak||' set CONC_REQUEST_ID = :1, migration_date = :2';
    execute immediate l_stmt USING fnd_global.CONC_REQUEST_ID, sysdate;

    EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.update_comment_backup_table');
    RAISE e_unexpected_error;

END;


/*===========================================================================+
| FUNCTION Backup_Comments
+============================================================================*/
FUNCTION Backup_Comments return boolean IS
    e_unexpected_error EXCEPTION;
BEGIN

    -- for testing comments APIs
    IF (BSC_APPS.bsc_apps_schema IS NULL) THEN
        BSC_APPS.Init_BSC_APPS;
    END IF;

    IF (get_previous_migration_status) THEN
        IF table_exists(c_comments_bak, BSC_APPS.bsc_apps_schema) THEN
            BSC_APPS.Do_DDL('DROP TABLE '||c_comments_bak, AD_DDL.DROP_TABLE, c_comments_bak);
        END IF;
        create_comment_backup_table;
    ELSE
        IF NOT table_exists(c_comments_bak, BSC_APPS.bsc_apps_schema) THEN
            create_comment_backup_table;
        END IF;
    END IF;

    update_comment_backup_table ;

    return true;
    EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Backup_Comments');
                         raise;
    RAISE e_unexpected_error;
END;

/*===========================================================================+
| FUNCTION Restore_Comments
+============================================================================*/
FUNCTION Restore_Comments return boolean IS
l_stmt VARCHAR2(4000);
l_preserve_flag VARCHAR2(10);
e_unexpected_error EXCEPTION;

BEGIN
    l_preserve_flag := g_adv_mig_features;

    IF (l_preserve_flag IS NULL) THEN
        -- User want to remove comments from the target after migration
        l_stmt := 'delete bsc_kpi_comments ';
        EXECUTE IMMEDIATE l_stmt;
        RETURN true;
    END IF;

    IF (l_preserve_flag = 'N') THEN
        --User wants to migrate comments from the source. bsc_kpi_comments was already migrated.
        RETURN true;
    END IF;

    -- User wants to preserve the comments already existing in the target

    --l_stmt := 'delete bsc_kpi_comments where indicator in
    --    (select distinct indicator from bsc_kpi_comments_bak where preserve_flag = :1)';
    --EXECUTE IMMEDIATE l_stmt USING 'Y';

    l_stmt := 'delete bsc_kpi_comments '; -- preserve target or source fully. no mix and match.
    EXECUTE IMMEDIATE l_stmt;


    l_stmt := 'INSERT INTO BSC_KPI_COMMENTS
            (INDICATOR,
             YEAR,
             PERIODICITY_ID,
             PERIOD_ID,
             TREND_FLAG,
             COMMENT_TEXT,
             COMMENT_TYPE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             COMMENT_SUBJECT,
             COMMENT_ID)
             SELECT
             CMT.INDICATOR,
             CMT.YEAR,
             CMT.PERIODICITY_ID,
             CMT.PERIOD_ID,
             CMT.TREND_FLAG,
             CMT.COMMENT_TEXT,
             CMT.COMMENT_TYPE,
             CMT.CREATED_BY,
             CMT.CREATION_DATE,
             CMT.LAST_UPDATED_BY,
             CMT.LAST_UPDATE_DATE,
             CMT.LAST_UPDATE_LOGIN,
             CMT.COMMENT_SUBJECT,
             CMT.COMMENT_ID
             FROM
             BSC_KPI_COMMENTS_BAK CMT,
             BSC_KPIS_B KPIS
             WHERE PRESERVE_FLAG = :1
             AND CMT.indicator = kpis.indicator';

    EXECUTE IMMEDIATE l_stmt USING 'Y';
    return true;

    EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Restore_Comments');
    RAISE e_unexpected_error;
    return false;
END;


/*===========================================================================+
| PROCEDURE Migrate_System
+============================================================================*/
PROCEDURE Migrate_System(
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_tab_filter IN VARCHAR2 := NULL,
  x_kpi_filter IN VARCHAR2 := NULL,
        x_overwrite IN VARCHAR2 := 'N'
  ) IS

    e_unexpected_error EXCEPTION;
    e_creating_dbi_dim_tables EXCEPTION;
    e_warning_raised EXCEPTION; --BUG FIX 6004972
    e_load_rpt_cal EXCEPTION;
    h_src_responsibilities VARCHAR2(32000) := NULL;
    h_trg_responsibilities VARCHAR2(32000) := NULL;
    h_tab_filter VARCHAR2(32000) := NULL;
    h_kpi_filter VARCHAR2(32000) := NULL;
    h_overwrite VARCHAR2(32000) := NULL;
    h_adv_mig_features VARCHAR2(32000) := NULL;

    h_log_file_name VARCHAR2(200);

    h_b BOOLEAN;
    h_error_msg VARCHAR2(4000);
    h_validation_error VARCHAR2(4000);

    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_object VARCHAR2(30);
    h_src_bsc_schema VARCHAR2(30);
    h_sysadmin_user_id NUMBER;

    h_application_name VARCHAR2(240);
    h_indicator NUMBER;
    h_name VARCHAR2(200);
    h_short_name VARCHAR2(200);

    h_i NUMBER;
    h_condition VARCHAR2(32000);

    --BSC-MV Note: New variables
    h_error_implement_mv VARCHAR2(2000) := NULL;
    e_error_implement_mv EXCEPTION;
    h_table VARCHAR2(30);
    h_base_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_base_tables NUMBER;
    h_base_message_v VARCHAR2(4000);
    h_message VARCHAR2(4000);

    CURSOR c_indic_sum_level (pIndicator NUMBER, pPropertyCode VARCHAR2) IS
        SELECT property_value
        FROM bsc_kpi_properties
        WHERE indicator = pIndicator
        AND property_code = pPropertyCode;

    h_sum_level_prop_code VARCHAR2(20) := 'ADV_SUM_LEVEL';
    h_kpi_sum_level NUMBER;
    h_prototype_flag NUMBER;

    h_dbi_table_name VARCHAR2(30);
    h_dbi_short_name VARCHAR2(30);

    --AW_INTEGRATION: new variables
    h_dim_level_list dbms_sql.varchar2_table;
    h_kpi_list dbms_sql.varchar2_table;
    h_calendar_id NUMBER;
    h_level_table_name VARCHAR2(50);
    h_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_dim_tables NUMBER;

    h_report_type VARCHAR2(2000);

    h_lst_columns VARCHAR2(32700);
BEGIN

-- Initializes global variables

    -- Init g_warnings
    g_warnings := FALSE;

    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    -- Initializes the error message stack
    BSC_MESSAGE.Init(g_debug_flag);

    -- Initialize the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    -- Initiliaze log file
    h_log_file_name := 'bscmig40.log';
    IF NOT BSC_APPS.Init_Log_File(h_log_file_name, h_error_msg) THEN
        BSC_MESSAGE.Add(x_message => h_error_msg,
                        x_source => 'BSC_MIGRATION.Migrate_System');
        RAISE e_unexpected_error;
    END IF;

    /*
    -- TRACE ----------------------------------------------------------------
    -- Set sql trace
    execute immediate 'alter session set MAX_DUMP_FILE_SIZE=UNLIMITED';
    execute immediate 'alter session set tracefile_identifier=''BSCMIG''';
    execute immediate 'alter session set sql_trace=true';
    --execute immediate 'alter session set events= ''10046 trace name context forever, level 8''';
    -- ----------------------------------------------------------------------------------
    */

    -- Fix performance bug#3860149
    h_sql := 'alter session set hash_area_size=50000000';
    BSC_APPS.Execute_Immediate(h_sql);
    h_sql := 'alter session set sort_area_size=50000000';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;
    h_sql := 'alter session enable parallel dml';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;


    -- Alter session set global_names = false to disable the enforcement
    -- of database link name must be equals to remote database name.
    h_sql := 'ALTER SESSION SET GLOBAL_NAMES = FALSE';
    BSC_APPS.Execute_Immediate(h_sql);


    -- Get parameters from BSC_DB_LOADER_CONTROL
    Get_Migration_Parameters(
        p_process_id => x_src_responsibilities,
        x_src_responsibilities => h_src_responsibilities,
        x_trg_responsibilities => h_trg_responsibilities,
        x_tab_filter => h_tab_filter,
        x_kpi_filter => h_kpi_filter,
        x_overwrite =>  h_overwrite,
        x_adv_mig_features => h_adv_mig_features,
        x_db_link => g_db_link
    );
    g_adv_mig_features := h_adv_mig_features;


    IF NOT (Backup_Comments) THEN
        RAISE e_unexpected_error;
    END IF;

    -- create temp table to hold CODE COLUMN TYPE
    --Bug 3919106
    --check if the temp table for col datatype has already been created
    --if false drop the table and create it again
    if(BSC_OLAP_MAIN.b_table_col_type_created=false)then
       BSC_OLAP_MAIN.drop_tmp_col_type_table;
       if(BSC_OLAP_MAIN.create_tmp_col_type_table(h_error_msg)) then
          BSC_OLAP_MAIN.b_table_col_type_created := true;
       else
         --Raise exception;
         BSC_MESSAGE.Add(x_message => h_error_msg,
                        x_source => 'BSC_MIGRATION.Migrate_System');
         RAISE e_unexpected_error;
       end if;
    end if;

    -- Validations

    -- Validate x_overwrite is 'Y'
    IF h_overwrite <> 'Y' THEN
        h_validation_error := BSC_APPS.Get_Message('BSC_MIG_CONFIRM_OVERW');
        BSC_APPS.Write_Line_Log(h_validation_error, BSC_APPS.OUTPUT_FILE);
        BSC_MESSAGE.Add(x_message => h_validation_error,
                        x_source => 'BSC_MIGRATION.Migrate_System');
        RAISE e_unexpected_error;
    END IF;

    -- Validate that the source and target system are same version
    IF NOT Validate_System_Versions(h_validation_error) THEN
        BSC_APPS.Write_Line_Log(h_validation_error, BSC_APPS.OUTPUT_FILE);
        BSC_MESSAGE.Add(x_message => h_validation_error,
                        x_source => 'BSC_MIGRATION.Migrate_System');
        RAISE e_unexpected_error;
    END IF;

    -- Validate the given source and target responsibilities
    -- By the way initialize the array g_src_resps and g_trg_resps
    IF NOT Validate_Responsibilities(h_src_responsibilities,
                                     h_trg_responsibilities,
                                     h_validation_error) THEN
        BSC_APPS.Write_Line_Log(h_validation_error, BSC_APPS.OUTPUT_FILE);
        BSC_MESSAGE.Add(x_message => h_validation_error,
                        x_source => 'BSC_MIGRATION.Migrate_System');
        RAISE e_unexpected_error;
    END IF;

    -- Validate the given tab and kpi filters
    -- By the way initialize the array g_tabs_filter and g_kpis_filter
    IF NOT Validate_Filters(h_tab_filter,
                            h_kpi_filter,
                            h_validation_error) THEN
        BSC_APPS.Write_Line_Log(h_validation_error, BSC_APPS.OUTPUT_FILE);
        BSC_MESSAGE.Add(x_message => h_validation_error,
                        x_source => 'BSC_MIGRATION.Migrate_System');
        RAISE e_unexpected_error;
    END IF;

    --BSC-MV Note: Moved this code here
    -- Know if the source system is in apps or not
    h_sql :=  'SELECT object_name FROM user_objects@'||g_db_link||
              ' WHERE object_name = :1';
    OPEN h_cursor FOR h_sql USING 'FND_USER';
    FETCH h_cursor INTO h_object;
    IF h_cursor%NOTFOUND THEN
        g_src_apps_flag := FALSE;
    ELSE
        g_src_apps_flag := TRUE;
    END IF;
    CLOSE h_cursor;

    --BSC-MV Note: Get the advanced summarization level of the source.
    --The profile in the target system will be overwritten with the value
    --in the source.
    IF g_src_apps_flag THEN
        -- Read sum level from bsc_sys_init
        h_sql := 'SELECT property_value'||
                 ' FROM bsc_sys_init@'||g_db_link||
                 ' WHERE property_code = :1';
        OPEN h_cursor FOR h_sql USING h_sum_level_prop_code;
        FETCH h_cursor INTO g_adv_sum_level;
        IF h_cursor%NOTFOUND THEN
            g_adv_sum_level := NULL;
        END IF;
        CLOSE h_cursor;
    ELSE
        g_adv_sum_level := NULL;
    END IF;

    -- Get BSC schema name in the source system
    IF g_src_apps_flag THEN
        h_sql := 'SELECT table_owner FROM user_synonyms@'||g_db_link||
                 ' WHERE table_name = :1';
        OPEN h_cursor FOR h_sql USING 'BSC_SYS_INIT';
        FETCH h_cursor INTO h_src_bsc_schema;
        IF h_cursor%NOTFOUND THEN
            g_src_bsc_schema := NULL;
        ELSE
            g_src_bsc_schema := h_src_bsc_schema;
        END IF;
        CLOSE h_cursor;
    END IF;

    --initialize g_sync flag bug fix 6004972
    g_syncup_done := FALSE;

    -- Enh#4697749 Need to remove custom non-pre-seeded measures (BSC and PMF) from pmf repository
    IF NOT Remove_Custom_Measures_In_PMF THEN
        RAISE e_unexpected_error;
    END IF;

    -- Enh#4697749 Need to remove custom non-pre-seeded dim objects (BSC and PMF) from pmf repository
    IF NOT Remove_Custom_Dim_Objs_In_PMF THEN
        RAISE e_unexpected_error;
    END IF;

    -- Enh#4697749 Need to remove custom non-pre-seeded dimensions (BSC and PMF) from pmf repository
    IF NOT Remove_Custom_Dims_In_PMF THEN
        RAISE e_unexpected_error;
    END IF;

    -- Init the arrays of tabs, kpis and tables that need to be considered
    -- in the source system to be migrated based on the source responsibilities
    -- and tab and kpi filters.
    IF NOT Init_Migration_Objects_Arrays THEN
        RAISE e_unexpected_error;
    END IF;

    IF g_num_mig_kpis = 0 THEN
        --Fix bug#4220506 Write invalid PMF objects into the log file
        Write_Log_Invalid_PMF_Objects;
        --Fix bug 6004972, if there is any objective that could not be migrated
        -- non custom PMF data
        -- then we should not be throwing error that there are no objectives according to
        -- filters, in this case migration should finish with warning.
        IF g_num_no_mig_kpis = 0 THEN
          h_validation_error := BSC_APPS.Get_Message('BSC_MIG_NO_INDICATORS');
          BSC_APPS.Write_Line_Log(h_validation_error, BSC_APPS.OUTPUT_FILE);
          BSC_MESSAGE.Add(x_message => h_validation_error,
                          x_source => 'BSC_MIGRATION.Migrate_System');
          RAISE e_unexpected_error;
        ELSE
          RAISE e_warning_raised;
        END IF;
    END IF;

    -- Init array of metadata tables
    Init_Metadata_Tables_Array;

    -- Bug#3854109: We are going to add a new validation to check that all the tables
    -- that are going to be migrated actually exists in the source system.
    -- If this happens we list in the log file those tables and the afferect kpis
    IF NOT Validate_Tables THEN
        -- log file already has the list of un-existing tavbles and affected indicators
        RAISE e_unexpected_error;
    END IF;

    -- At this point, the system is inconsistent until everything have been migrated
    -- So, we flag the system like if it is not in the latest version.
    UPDATE bsc_sys_init
      SET property_value = 'UNAPPLIED',
          last_updated_by = BSC_APPS.fnd_global_user_id,
          last_update_date = SYSDATE
      WHERE property_code = 'TARGET_STATUS';
    COMMIT;

    -- Drop all current dynamic tables in the target system (target system)
    IF Not Drop_Dynamic_Objects THEN
        RAISE e_unexpected_error;
    END IF;

    -- Delete all records from Metadata tables (target system)
    IF NOT Delete_Metadata_Tables THEN
        RAISE e_unexpected_error;
    END IF;

    -- Get the user_id of the SYSADMIN user in the target system
    IF BSC_APPS.APPS_ENV THEN
        -- The target system is APPS
        h_sql :=  'SELECT user_id FROM fnd_user WHERE user_name = ''SYSADMIN''';
        OPEN h_cursor FOR h_sql;
        FETCH h_cursor INTO h_sysadmin_user_id;
        IF h_cursor%NOTFOUND THEN
            g_sysadmin_user_id := 0;
        ELSE
            g_sysadmin_user_id := h_sysadmin_user_id;
        END IF;
        CLOSE h_cursor;
    ELSE
        g_sysadmin_user_id := 0;
    END IF;

    -- Migrate metadata
    IF NOT Migrate_Metadata THEN
        RAISE e_unexpected_error;
    END IF;

    -- Delete metadata for invalid PMF objects: Measures, dimensions and dimension levels
    -- that do not exist in the target.
    -- The following arrays already has this information: g_invalid_measures,
    -- g_invalid_dimenisions and g_invalid_dim_levels
    Clean_Metadata_Invalid_PMF;


    -- we need to sync up dataset_ids between bis_indicators and bsc_sys_datasets_b
    -- because there can be many datasets pointing to same measure as measure_id1
    -- sync up is not able to handle this issue.
    -- bug 5990096
    syncup_dataset_id_in_target;

    --for bug 5680620 handling of bsdc_sys_init table
    -- DELETE THE DATA FROM TABLE EXCEPT PATCH_NUMBER
    DELETE BSC_SYS_INIT where PROPERTY_CODE <> 'PATCH_NUMBER';
    --added commit for bug fix 6470015
    COMMIT;

    -- COPY ROWS FROM TARGET TO THIS TABLE.
    h_lst_columns := Get_Lst_Table_Columns('BSC_SYS_INIT');
    h_sql := 'INSERT /*+ append parallel(BSC_SYS_INIT)*/'||
             ' INTO BSC_SYS_INIT ('||h_lst_columns||')'||
             ' SELECT /*+ parallel(BSC_SYS_INIT)*/ '||h_lst_columns||
             ' FROM BSC_SYS_INIT'||'@'||g_db_link ||
             ' WHERE PROPERTY_CODE <> ''PATCH_NUMBER'' AND PROPERTY_CODE <>''EDW_INSTALLED'' ';
    BSC_APPS.Execute_Immediate(h_sql);
    COMMIT;

    -- At this point, the system is inconsistent until everything have been migrated
    -- So, we flag the system like if it is not in the latest version.
    -- I do it again because the records in BSC_SYS_INIT have been migrated from the source.
    UPDATE bsc_sys_init
      SET property_value = 'UNAPPLIED',
          last_updated_by = BSC_APPS.fnd_global_user_id,
          last_update_date = SYSDATE
      WHERE property_code = 'TARGET_STATUS';
    COMMIT;

    -- Enh#4697749: Migrate AK Metadata and Form Functions of the Reports
    FOR h_i IN 1..g_num_mig_kpis LOOP
        h_sql := 'SELECT short_name'||
                 ' FROM bsc_kpis_b'||
                 ' WHERE indicator = :1';
        OPEN h_cursor FOR h_sql USING g_mig_kpis(h_i);
        FETCH h_cursor INTO h_short_name;
        CLOSE h_cursor;
        IF h_short_name IS NOT NULL THEN
            -- By design there is a form function and ak region called as the short name
            BSC_APPS.Write_Line_Log('Migrating report '||h_short_name, BSC_APPS.OUTPUT_FILE);
            IF NOT Migrate_AK_Region(h_short_name, h_error_msg) THEN
                BSC_APPS.Write_Line_Log('Error migrating AK Region '||h_short_name||': '||h_error_msg,
                                        BSC_APPS.OUTPUT_FILE);
            END IF;
            IF NOT Migrate_Form_Function(h_short_name, h_error_msg) THEN
                BSC_APPS.Write_Line_Log('Error migrating Form Function '||h_short_name||': '||h_error_msg,
                                        BSC_APPS.OUTPUT_FILE);
            END IF;
        END IF;
    END LOOP;

    -- ----------------------------------------------------------------------------
    -- Create dynamic objects
    IF NOT Create_Dynamic_Objects THEN
        RAISE e_unexpected_error;
    END IF;

    -- Migrate dynamic tables
    IF NOT Migrate_Dynamic_Tables_Data THEN
        RAISE e_unexpected_error;
    END IF;

    -- Create indexes on dynamic tables
    -- Fix performance bug#3860149: indexes are going to be created in parallel
    -- for that reason we need the following commands
    commit;
    h_sql := 'alter session force parallel query';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;
    h_sql := 'alter session enable parallel dml';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;

    IF NOT Create_Indexes_Dynamic_Tables THEN
        RAISE e_unexpected_error;
    END IF;

    commit;
    h_sql := 'alter session disable parallel dml';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;
    h_sql := 'alter session disable parallel query';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;
    h_sql := 'alter session enable parallel dml';
    BSC_APPS.Execute_Immediate(h_sql);
    commit;

    -- Fix performance bug#3860149: analyze base and dimension tables
    IF NOT Analyze_Base_And_Dim_Tables THEN
        RAISE e_unexpected_error;
    END IF;

    -- ---------------------------------------------------------------------

    -- Fix _TL tables according to supported languages in target system
    IF NOT Check_Languages_TL_Tables THEN
        RAISE e_unexpected_error;
    END IF;

    -- Assign target responsibilities
    IF NOT Assign_Target_Responsibilities THEN
        RAISE e_unexpected_error;
    END IF;

    COMMIT;

    -- changes for bug fix 6004972
    -- --------------------------------------------------------------------
    -- Synchronize Dimensions and Measures between BSC-PMF
    -- --------------------------------------------------------------------
    sync_bis_bsc_metadata(h_error_msg);
    g_syncup_done := TRUE;
    -- ---------------------------------------------------------------------

    -- Bug#3138718 Description of the dimensions is not migrated
    -- Description is stored only in BIS_DIMENSIONS
    -- We need to update the description ONLY FOR BSC DIMENSIONS
    -- with the value from the source system
    IF NOT Update_BSC_Dimensions_In_PMF THEN
        RAISE e_unexpected_error;
    END IF;

    -- BSC-MV Note: Need to create MVs for migrated Kpis and refresh them.
    -- AW_INTEGRATION: Need to create cubes for migrated Kpis and refresh them.
    h_base_message_v := BSC_APPS.Get_Message('BSC_CREATING_VIEW');
    IF g_adv_sum_level IS NOT NULL THEN
        -- Create MVs for migrated Kpis that has prototype flag 0, 6 or 7
        FOR h_i IN 1..g_num_mig_kpis LOOP
            -- Get prototype flag and report type
            h_sql := 'SELECT prototype_flag, BSC_DBGEN_UTILS.get_Objective_Type(short_name)'||
                     ' FROM bsc_kpis_b@'||g_db_link||
                     ' WHERE indicator = :1';
            OPEN h_cursor FOR h_sql USING g_mig_kpis(h_i);
            FETCH h_cursor INTO h_prototype_flag, h_report_type;
            CLOSE h_cursor;

            -- We need to create MVs or AW Cubes only for indicators with report_type OBJECTIVE or BSCREPORT
            IF (h_prototype_flag = 0 OR h_prototype_flag = 6 OR h_prototype_flag = 7) AND
               (h_report_type = 'OBJECTIVE' OR h_report_type = 'BSCREPORT' OR h_report_type = 'SIMULATION') THEN
                -- Create the MV with the same summarization level they was created
                OPEN c_indic_sum_level (g_mig_kpis(h_i), h_sum_level_prop_code);
                FETCH c_indic_sum_level INTO h_kpi_sum_level;
                IF c_indic_sum_level%NOTFOUND THEN
                    h_kpi_sum_level := g_adv_sum_level;
                ELSE
                    IF h_kpi_sum_level IS NULL THEN
                        h_kpi_sum_level := g_adv_sum_level;
                    END IF;
                END IF;
                CLOSE c_indic_sum_level;

                --AW_INTEGRATION: see if the indicator is implemented in AW
                IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(g_mig_kpis(h_i)) = 2 THEN
                    --AW implementation
                    h_message := 'Creating AW cubes: '||g_mig_kpis(h_i);
                    BSC_APPS.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);
                    h_kpi_list.delete;
                    h_kpi_list(1) := g_mig_kpis(h_i);
                    bsc_aw_adapter.implement_kpi_aw(h_kpi_list,
                                                    'DEBUG LOG,RECREATE KPI,SUMMARIZATION LEVEL='||h_kpi_sum_level);
                ELSE
                    --MV implementation
                    h_message := BSC_APPS.Replace_Token(h_base_message_v, 'VIEW', TO_CHAR(g_mig_kpis(h_i)));
                    BSC_APPS.Write_Line_Log(h_message, BSC_UPDATE_LOG.OUTPUT);

                    IF NOT BSC_BIA_WRAPPER.Implement_Bsc_MV(g_mig_kpis(h_i),
                                                            h_kpi_sum_level,
                                                            FALSE,
                                                            h_error_implement_mv) THEN
                        RAISE e_error_implement_mv;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        -- Refresh BIS Dimension tables. The BIS dimension tables that are materialized in BSC
        -- will be refreshed.
        -- AW_INTEGRATION: The BIS dimensions used in AW indicators will be loaded to AW
        IF NOT BSC_UPDATE_DIM.Create_Dbi_Dim_Temp_Tables THEN
            RAISE e_unexpected_error;
        END IF;
        -- AW_INTEGRATION: Create temporary tables needed for AW dimension processing
        IF NOT BSC_UPDATE_DIM.Create_AW_Dim_Temp_Tables THEN
            RAISE e_unexpected_error;
        END IF;
        -- Fix bug#4457823: Need to create the DBI dimension tables where we materialize
        IF NOT BSC_UPDATE_DIM.Create_Dbi_Dim_Tables(h_error_msg) THEN
            RAISE e_creating_dbi_dim_tables;
        END IF;

        h_sql := 'select distinct short_name'||
                 ' from bsc_sys_dim_levels_b'||
                 ' where source = :1';
        OPEN h_cursor FOR h_sql USING 'PMF';
        LOOP
            FETCH h_cursor INTO h_dbi_short_name;
            EXIT WHEN h_cursor%NOTFOUND;
            IF NOT BSC_UPDATE_DIM.Refresh_Dbi_Dimension_Table(h_dbi_short_name) THEN
                -- fix bug#4682494: if for any reason the dbi dimension cannot be refreshed
                -- then we write this to the log file an continue
                g_warnings := TRUE;
                BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_WARNING')||' '||
                                        BSC_APPS.Get_Message('BSC_RETR_DIMTABLE_FAILED')||' '||h_dbi_short_name,
                                        BSC_UPDATE_LOG.OUTPUT);
            END IF;
        END LOOP;
        CLOSE h_cursor;


        --AW_INTEGRATION: Load TYPE dimension into AW
        IF BSC_UPDATE_UTIL.Exists_AW_Kpi THEN
            h_dim_level_list.delete;
            h_dim_level_list(1) := 'TYPE';
            bsc_aw_load.load_dim(
                p_dim_level_list => h_dim_level_list,
                p_options => 'DEBUG_LOG'
            );
        END IF;

        --AW_INTEGRATION: Load all the BSC dimensions used in AW indicators into AW
        h_sql := 'select distinct level_table_name'||
                 ' from bsc_kpi_dim_levels_vl kd, bsc_kpi_properties kp, bsc_kpis_b k'||
                 ' where kd.indicator = kp.indicator and'||
                 ' kd.indicator = k.indicator and'||
                 ' k.prototype_flag IN (0,6,7) and'||
                 ' kp.property_code = :1 and kp.property_value = :2 and'||
                 ' kd.status = :3 and kd.level_source = :4';
        h_num_dim_tables := 0;
        OPEN h_cursor FOR h_sql USING 'IMPLEMENTATION_TYPE', 2, 2, 'BSC';
        LOOP
            FETCH h_cursor INTO h_level_table_name;
            EXIT WHEN h_cursor%NOTFOUND;

            h_num_dim_tables := h_num_dim_tables + 1;
            h_dim_tables(h_num_dim_tables) := h_level_table_name;
        END LOOP;
        CLOSE h_cursor;
        IF NOT BSC_UPDATE.Load_Dims_Into_AW(h_dim_tables, h_num_dim_tables) THEN
            RAISE e_unexpected_error;
        END IF;

        --Fix bug#4873669: Populate bsc_reporting_calendar fro all the calendars
        h_sql := 'select calendar_id'||
                 ' from bsc_sys_calendars_b';
        OPEN h_cursor FOR h_sql;
        LOOP
            FETCH h_cursor INTO h_calendar_id;
            EXIT WHEN h_cursor%NOTFOUND;

            IF NOT BSC_BIA_WRAPPER.Load_Reporting_Calendar(h_calendar_id, h_error_msg) THEN
                RAISE e_load_rpt_cal;
            END IF;
        END LOOP;
        CLOSE h_cursor;

        --AW_INTEGRATION: Load calendars used by AW indicators into AW
        h_sql := 'select distinct calendar_id'||
                 ' from bsc_kpis_b k, bsc_kpi_properties kp'||
                 ' where k.indicator = kp.indicator and'||
                 ' k.prototype_flag IN (0,6,7) and'||
                 ' kp.property_code = :1 and kp.property_value = :2';
        OPEN h_cursor FOR h_sql USING 'IMPLEMENTATION_TYPE', 2;
        LOOP
            FETCH h_cursor INTO h_calendar_id;
            EXIT WHEN h_cursor%NOTFOUND;

             bsc_aw_calendar.create_calendar(
                p_calendar => h_calendar_id,
                p_options => 'DEBUG LOG, RECREATE'
             );
             bsc_aw_calendar.load_calendar(
                p_calendar => h_calendar_id,
                p_options => 'DEBUG LOG'
             );
        END LOOP;
        CLOSE h_cursor;

        -- Refresh all MV in the system
        -- Get all the base tables
        --AW_INTEGRATION: We need to get only the base tables used by MV indicators
        h_num_base_tables := 0;
        h_sql := 'SELECT table_name FROM bsc_db_tables_rels'||
                 ' WHERE source_table_name IN ('||
                 ' SELECT table_name FROM bsc_db_tables'||
                 ' WHERE table_type = :1)';
        OPEN h_cursor FOR h_sql USING 0;
        LOOP
            FETCH h_cursor INTO h_table;
            EXIT WHEN h_cursor%NOTFOUND;

            IF NOT BSC_UPDATE_UTIL.Is_Table_For_AW_Kpi(h_table) THEN
                -- The base table is for a MV indicator
                h_num_base_tables := h_num_base_tables + 1;
                h_base_tables(h_num_base_tables) := h_table;
            END IF;
        END LOOP;
        CLOSE h_cursor;

        -- Refresh all MVs in the system affected by base tables
        IF NOT BSC_UPDATE.Refresh_System_MVs_Mig(h_base_tables, h_num_base_tables) THEN
            RAISE e_unexpected_error;
        END IF;

        --AW_INTEGRATION: Now refresh the AW indicators
        h_sql := 'select k.indicator'||
                 ' from bsc_kpis_b k, bsc_kpi_properties kp'||
                 ' where k.indicator = kp.indicator and'||
                 ' k.prototype_flag IN (0,6,7) and'||
                 ' kp.property_code = :1 and kp.property_value = :2';
        OPEN h_cursor FOR h_sql USING 'IMPLEMENTATION_TYPE', 2;
        LOOP
            FETCH h_cursor INTO h_indicator;
            EXIT WHEN h_cursor%NOTFOUND;

            h_kpi_list.delete;
            h_kpi_list(1) := h_indicator;
            bsc_aw_load.load_kpi(
                p_kpi_list => h_kpi_list,
                p_options => 'DEBUG LOG'
            );
        END LOOP;
        CLOSE h_cursor;
    END IF;

    COMMIT;

    --BSC-MV Note: Overwrite profile BSC_ADVANCED_SUMMARIZATION_LEVEL with the value from source
    IF BSC_APPS.APPS_ENV THEN
        IF NOT FND_PROFILE.SAVE('BSC_ADVANCED_SUMMARIZATION_LEVEL', TO_CHAR(g_adv_sum_level), 'SITE') THEN
            RAISE e_unexpected_error;
        END IF;

        COMMIT;
    END IF;

       -- Restore the comments on the target...
    IF NOT (Restore_Comments) THEN
        RAISE e_unexpected_error;
    END IF;

    -- At this point, the system is consistent
    UPDATE bsc_sys_init
      SET property_value = 'APPLIED',
          last_updated_by = BSC_APPS.fnd_global_user_id,
          last_update_date = SYSDATE
      WHERE property_code = 'TARGET_STATUS';
    COMMIT;

    -- Write Program completed to log file
    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                            BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                            ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

    -- Write in the log file the PMF objects that are not valid
    --Fix bug#4220506
    Write_Log_Invalid_PMF_Objects;

    -- Delete records in the temporal table used for big 'in' conditions
    BSC_APPS.Init_Big_In_Cond_Table;

    --Bug 3919106
    if(BSC_OLAP_MAIN.b_table_col_type_created) then
          BSC_OLAP_MAIN.drop_tmp_col_type_table;
    end if;

EXCEPTION
    WHEN e_load_rpt_cal THEN
        -- error message is in h_error_msg
        ROLLBACK;

        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => 'Error in BSC_BIA_WRAPPER.Load_Reporting_Calendar: '||h_calendar_id||' '||h_error_msg,
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

    WHEN e_creating_dbi_dim_tables THEN
        -- error message is in h_error_msg
        ROLLBACK;

        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => 'Error in BSC_UPDATE_DIM.Create_Dbi_Dim_Tables: '||h_error_msg,
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

    WHEN g_error_synch_bsc_pmf THEN
        -- error message is in h_error_msg
        ROLLBACK;

        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => h_error_msg,
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

    WHEN e_error_implement_mv THEN
        ROLLBACK;

        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => 'BSC_BIA_WRAPPER.Implement_Bsc_MV '||g_mig_kpis(h_i)||' '||h_error_implement_mv,
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

    WHEN e_unexpected_error THEN
        ROLLBACK;

        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => BSC_APPS.Get_Message('BSC_MIG_FAIL_EXEC'),
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

    WHEN e_warning_raised THEN
        ROLLBACK;
        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;

        COMMIT ;

    WHEN OTHERS THEN
        ROLLBACK;

        -- Delete records in the temporal table used for big 'in' conditions
        BSC_APPS.Init_Big_In_Cond_Table;

        BSC_MESSAGE.flush;
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_MIGRATION.Migrate_System',
                        x_mode => 'I');
        COMMIT;

        BSC_APPS.Write_Errors_To_Log;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TIME')||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'SYMBOL_COLON')||
                                ' '||TO_CHAR(SYSDATE, c_fto_long_date_time), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_PROGRAM_COMPLETED'), BSC_APPS.OUTPUT_FILE);

END Migrate_System;


--LOCKING: new procedure
/*===========================================================================+
| PROCEDURE Migrate_System_AT
+============================================================================*/
PROCEDURE Migrate_System_AT(
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_tab_filter IN VARCHAR2 := NULL,
  x_kpi_filter IN VARCHAR2 := NULL,
        x_overwrite IN VARCHAR2 := 'N'
  ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    Migrate_System(x_src_responsibilities,
                   x_trg_responsibilities,
                   x_tab_filter,
             x_kpi_filter,
                   x_overwrite);
    commit; -- all autonomous transaction needs to commit
END Migrate_System_AT;


-- Enh#4697749
/*===========================================================================+
| FUNCTION Remove_Custom_Dim_Objs_In_PMF
+============================================================================*/
FUNCTION Remove_Custom_Dim_Objs_In_PMF RETURN BOOLEAN IS
     --bug 5099776
    CURSOR c_dim_objects (p1 NUMBER, p2 NUMBER, p3 NUMBER, p4 NUMBER) IS
        SELECT DISTINCT spmf_dl.level_id
        FROM bsc_sys_dim_levels_b sbsc_dl,
             bis_levels spmf_dl
        WHERE sbsc_dl.short_name = spmf_dl.short_name AND
              spmf_dl.created_by NOT IN (p1, p2,p3,p4);

    h_level_id      NUMBER;
    h_bis_dim_level_rec       BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    h_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
    h_return_status     VARCHAR2(1);
    h_msg_count     NUMBER;
    h_msg_data      VARCHAR2(2000);

    h_arr_ids     t_array_of_number;
    h_num_ids     NUMBER :=0;
    i       NUMBER;

BEGIN

    -- Delete custom dim objects from PMF repository.

    OPEN c_dim_objects(1,2,120,121);
    LOOP
        FETCH c_dim_objects INTO h_level_id;
        EXIT WHEN c_dim_objects%NOTFOUND;

        h_num_ids := h_num_ids + 1;
        h_arr_ids(h_num_ids) := h_level_id;
    END LOOP;
    CLOSE c_dim_objects;

    FOR i IN 1..h_num_ids LOOP
        h_bis_dim_level_rec.dimension_level_id := h_arr_ids(i);

        BIS_DIMENSION_LEVEL_PUB.Delete_Dimension_Level (
            p_commit                =>  FND_API.G_FALSE
           ,p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
           ,p_Dimension_Level_Rec   =>  h_bis_dim_level_rec
           ,x_return_status         =>  h_return_status
           ,x_error_Tbl             =>  h_error_tbl
        );
    END LOOP;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        FND_MSG_PUB.Count_And_Get(p_count => h_msg_count
                                  ,p_data => h_msg_data);
        IF (h_msg_data is null) THEN
            h_msg_data := SQLERRM;
        END IF;

        BSC_MESSAGE.Add(x_message => h_msg_data,
                        x_source => 'BSC_MIGRATION.Remove_Custom_Dim_Objs_In_PMF');
        RETURN FALSE;

END Remove_Custom_Dim_Objs_In_PMF;


-- Enh#4697749
/*===========================================================================+
| FUNCTION Remove_Custom_Dims_In_PMF
+============================================================================*/
FUNCTION Remove_Custom_Dims_In_PMF RETURN BOOLEAN IS
    --bug 5099776
    CURSOR c_dimensions (p1 NUMBER, p2 NUMBER,p3 NUMBER,p4 NUMBER) IS
        SELECT DISTINCT spmf_d.dimension_id
        FROM bsc_sys_dim_groups_vl sbsc_d,
             bis_dimensions spmf_d
        WHERE sbsc_d.short_name = spmf_d.short_name AND
              spmf_d.created_by NOT IN (p1, p2,p3,p4);

    h_dimension_id    NUMBER;
    h_bis_dimension_rec       BIS_DIMENSION_PUB.Dimension_Rec_Type;
    h_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
    h_return_status     VARCHAR2(1);
    h_msg_count     NUMBER;
    h_msg_data      VARCHAR2(2000);

    h_arr_ids     t_array_of_number;
    h_num_ids     NUMBER :=0;
    i       NUMBER;

BEGIN

    -- Delete custom dimensions (dimension groups) from PMF repository.

    OPEN c_dimensions(1 ,2,120,121);
    LOOP
        FETCH c_dimensions INTO h_dimension_id;
        EXIT WHEN c_dimensions%NOTFOUND;

        h_num_ids := h_num_ids + 1;
        h_arr_ids(h_num_ids) := h_dimension_id;
    END LOOP;
    CLOSE c_dimensions;

    FOR i IN 1..h_num_ids LOOP
        h_bis_dimension_rec.dimension_id := h_arr_ids(i);

        BIS_DIMENSION_PUB.Delete_Dimension(
            p_commit                =>  FND_API.G_FALSE
           ,p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
           ,p_Dimension_Rec         =>  h_bis_dimension_rec
           ,x_return_status         =>  h_return_status
           ,x_error_Tbl             =>  h_error_tbl
        );
    END LOOP;

    COMMIT;

    -- Update DIM_GRP_ID to NULL in BIS_DIMENSIONS so the new dimension group id can be populated
    -- during synchronization
    UPDATE bis_dimensions
    SET dim_grp_id = NULL;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        FND_MSG_PUB.Count_And_Get(p_count => h_msg_count
                                  ,p_data => h_msg_data);
        IF (h_msg_data is null) THEN
            h_msg_data := SQLERRM;
        END IF;

        BSC_MESSAGE.Add(x_message => h_msg_data,
                        x_source => 'BSC_MIGRATION.Remove_Custom_Dims_In_PMF');
        RETURN FALSE;

END Remove_Custom_Dims_In_PMF;


-- Enh#4697749
/*===========================================================================+
| FUNCTION Remove_Custom_Measures_In_PMF
+============================================================================*/
FUNCTION Remove_Custom_Measures_In_PMF RETURN BOOLEAN IS
  -- bug 5099776 modified cursor correct join is with dataset_ids
    CURSOR c_measures (p1 NUMBER, p2 NUMBER, p3 NUMBER, p4 NUMBER) IS
        SELECT DISTINCT si.indicator_id
        FROM bis_indicators si,
       bsc_sys_datasets_b sd
  WHERE sd.dataset_id = si.dataset_id AND
        si.created_by NOT IN (p1, p2, p3,p4);

    h_indicator_id    NUMBER;
    h_measure_rec   BIS_MEASURE_PUB.Measure_Rec_Type;
    h_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
    h_return_status     VARCHAR2(1);
    h_msg_count     NUMBER;
    h_msg_data      VARCHAR2(2000);

    h_arr_ids     t_array_of_number;
    h_num_ids     NUMBER :=0;
    i       NUMBER;

BEGIN

    -- Delete custom measures from PMF repository.

    OPEN c_measures(1, 2,120,121);
    LOOP
        FETCH c_measures INTO h_indicator_id;
        EXIT WHEN c_measures%NOTFOUND;

        h_num_ids := h_num_ids + 1;
        h_arr_ids(h_num_ids) := h_indicator_id;
    END LOOP;
    CLOSE c_measures;

    FOR i IN 1..h_num_ids LOOP
        h_measure_rec.measure_id := h_arr_ids(i);

        BIS_MEASURE_PUB.Delete_Measure(
            p_api_version => 1.0
           ,p_commit => FND_API.G_FALSE
           ,p_Measure_Rec => h_measure_rec
           ,x_return_status => h_return_status
           ,x_error_Tbl => h_error_tbl);
    END LOOP;

    -- Update dataset_id to NULL in BIS_INDICATORS so the new dataset id can be populated
    -- during synchronization
    UPDATE bis_indicators
    SET dataset_id = NULL;

    COMMIT;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        FND_MSG_PUB.Count_And_Get(p_count => h_msg_count
                                  ,p_data => h_msg_data);
        IF (h_msg_data is null) THEN
            h_msg_data := SQLERRM;
        END IF;

        BSC_MESSAGE.Add(x_message => h_msg_data,
                        x_source => 'BSC_MIGRATION.Remove_Custom_Measures_In_PMF');
        RETURN FALSE;

END Remove_Custom_Measures_In_PMF;


/*===========================================================================+
| FUNCTION Update_BSC_Dimensions_In_PMF
+============================================================================*/
FUNCTION Update_BSC_Dimensions_In_PMF RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_base_language VARCHAR2(4);
    h_lang_code VARCHAR2(4);

    h_sql VARCHAR2(32000);
    h_source_bsc VARCHAR2(3) := 'BSC';
    h_i NUMBER;

BEGIN

    -- Update description of the BSC dimensions in BIS_DIMENSIONS_TL with the value
    -- from the source system
    h_sql := 'UPDATE bis_dimensions_tl tdtl'||
             ' SET description = ('||
             '   SELECT sdtl.description'||
             '   FROM bis_dimensions@'||g_db_link||' sd,'||
             '   bis_dimensions_tl@'||g_db_link||' sdtl,'||
             '   bis_dimensions td'||
             '   WHERE tdtl.dimension_id = td.dimension_id AND'||
             '   td.short_name = sd.short_name AND'||
             '   sd.dimension_id = sdtl.dimension_id AND'||
             '   tdtl.language = sdtl.language'||
             '   )'||
             ' WHERE tdtl.dimension_id IN ('||
             '   SELECT DISTINCT pmf_d.dimension_id'||
             '   FROM bis_levels pmf_do, bsc_sys_dim_levels_vl bsc_do,'||
             '   bis_dimensions pmf_d, bsc_sys_dim_groups_tl bsc_d,'||
             '   bsc_sys_dim_levels_by_group bsc_dlg'||
             '   WHERE pmf_do.short_name = bsc_do.short_name AND'||
             '   bsc_do.source = :1 AND bsc_do.dim_level_id = bsc_dlg.dim_level_id AND'||
             '   bsc_dlg.dim_group_id = bsc_d.dim_group_id AND'||
             '   bsc_d.short_name = pmf_d.short_name'||
             '  )';
    EXECUTE IMMEDIATE h_sql USING h_source_bsc;

    -- The previous query updates to null the description for the languages existing in the target
    -- but not in the source. The following logic will update the description for those languages
    -- with the description of the base language of the target system.

    -- Get the base language of the target system
    SELECT language_code INTO h_base_language
    FROM fnd_languages
    WHERE installed_flag = 'B';

    -- Get supported languages in target that are not supported in source
    h_sql := 'SELECT DISTINCT language_code'||
             ' FROM fnd_languages'||
             ' WHERE installed_flag IN (:1, :2) AND'||
             ' language_code NOT IN ('||
             ' SELECT language_code'||
             ' FROM fnd_languages@'||g_db_link||
             ' WHERE installed_flag IN (:3, :4)'||
             ' )';
    OPEN h_cursor FOR h_sql USING 'B', 'I', 'B', 'I';
    LOOP
        FETCH h_cursor INTO h_lang_code;
        EXIT WHEN h_cursor%NOTFOUND;

        IF h_lang_code <> h_base_language THEN
            h_sql := 'UPDATE bis_dimensions_tl d1'||
                     ' SET description = ('||
                     '   SELECT description'||
                     '   FROM bis_dimensions_tl d2'||
                     '   WHERE d2.dimension_id = d1.dimension_id AND'||
                     '   d2.language = :1'||
                     ' ),'||
                     ' source_lang = :2'||
                     ' WHERE d1.language = :3 AND'||
                     ' d1.dimension_id IN ('||
                     '   SELECT DISTINCT pmf_d.dimension_id'||
                     '   FROM bis_levels pmf_do, bsc_sys_dim_levels_vl bsc_do,'||
                     '   bis_dimensions pmf_d, bsc_sys_dim_groups_tl bsc_d,'||
                     '   bsc_sys_dim_levels_by_group bsc_dlg'||
                     '   WHERE pmf_do.short_name = bsc_do.short_name AND'||
                     '   bsc_do.source = :4 AND bsc_do.dim_level_id = bsc_dlg.dim_level_id AND'||
                     '   bsc_dlg.dim_group_id = bsc_d.dim_group_id AND'||
                     '   bsc_d.short_name = pmf_d.short_name'||
                     ' )';
            EXECUTE IMMEDIATE h_sql USING h_base_language, h_base_language, h_lang_code, h_source_bsc;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_MIGRATION.Update_BSC_Dimensions_In_PMF');
        RETURN FALSE;

END Update_BSC_Dimensions_In_PMF;


/*===========================================================================+
| PROCEDURE Validate_Filters
+============================================================================*/
FUNCTION Validate_Filters(
  x_tab_filter IN VARCHAR2,
        x_kpi_filter IN VARCHAR2,
  x_validation_error OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS

    e_invalid_tab_filter EXCEPTION;
    e_invalid_kpi_filter EXCEPTION;

    e_no_tab_access EXCEPTION;
    e_no_kpi_access EXCEPTION;

    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_i NUMBER;

    h_access_item NUMBER;

    h_condition VARCHAR2(32700);

BEGIN
    -- Validate x_tab_filter
    g_num_tabs_filter := Decompose_Numeric_List(x_tab_filter, g_tabs_filter, ',');
    IF g_num_tabs_filter = -1 THEN
        RAISE e_invalid_tab_filter;
    END IF;

    -- Validate x_kpi_filter
    g_num_kpis_filter := Decompose_Numeric_List(x_kpi_filter, g_kpis_filter, ',');
    IF g_num_kpis_filter = -1 THEN
        RAISE e_invalid_kpi_filter;
    END IF;

    -- All the provided tabs must be accessible by any of the source responsibilities.
    h_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'responsibility_id');
    FOR h_i IN 1..g_num_src_resps LOOP
        BSC_APPS.Add_Value_Big_In_Cond(1, g_src_resps(h_i));
    END LOOP;

    FOR h_i IN 1..g_num_tabs_filter LOOP
        h_sql := 'SELECT tab_id'||
                 ' FROM bsc_user_tab_access@'||g_db_link||
                 ' WHERE tab_id = :1 AND ('||h_condition||')';
        OPEN h_cursor FOR h_sql USING g_tabs_filter(h_i);
        FETCH h_cursor INTO h_access_item;
        IF h_cursor%NOTFOUND THEN
            CLOSE h_cursor;
            h_access_item := g_tabs_filter(h_i);
            RAISE e_no_tab_access;
        END IF;
        CLOSE h_cursor;
    END LOOP;

    -- All the provided kpis must be accessible by any of the source responsibilities.
    FOR h_i IN 1..g_num_kpis_filter LOOP
        h_sql := 'SELECT indicator'||
                 ' FROM bsc_user_kpi_access@'||g_db_link||
                 ' WHERE indicator = :1 AND ('||h_condition||')';
        OPEN h_cursor FOR h_sql USING g_kpis_filter(h_i);
        FETCH h_cursor INTO h_access_item;
        IF h_cursor%NOTFOUND THEN
            CLOSE h_cursor;
            h_access_item := g_kpis_filter(h_i);
            RAISE e_no_kpi_access;
        END IF;
        CLOSE h_cursor;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN e_invalid_tab_filter THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_INV_TAB_FILTER');
        RETURN FALSE;

    WHEN e_invalid_kpi_filter THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_INV_KPI_FILTER');
        RETURN FALSE;

    WHEN e_no_tab_access THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_NO_TAB_ACCESS');
        x_validation_error := BSC_APPS.Replace_Token(x_validation_error, 'TAB_ID', TO_CHAR(h_access_item));
        RETURN FALSE;

    WHEN e_no_kpi_access THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_NO_KPI_ACCESS');
        x_validation_error := BSC_APPS.Replace_Token(x_validation_error, 'INDICATOR', TO_CHAR(h_access_item));
        RETURN FALSE;

    WHEN OTHERS THEN
        x_validation_error := SQLERRM;
        RETURN FALSE;

END Validate_Filters;


/*===========================================================================+
| PROCEDURE Validate_Responsibilities
+============================================================================*/
FUNCTION Validate_Responsibilities(
  x_src_responsibilities IN VARCHAR2,
        x_trg_responsibilities IN VARCHAR2,
  x_validation_error OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS

    e_invalid_src_resps EXCEPTION;
    e_invalid_trg_resps EXCEPTION;

    e_null_src_resps EXCEPTION;
    e_null_trg_resps EXCEPTION;
    e_no_match_resps EXCEPTION;

    e_no_src_resp EXCEPTION;
    e_no_trg_resp EXCEPTION;

    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_resp NUMBER;

    h_i NUMBER;

BEGIN
    -- Validate x_src_responsibilities
    g_num_src_resps := Decompose_Numeric_List(x_src_responsibilities, g_src_resps, ',');
    IF g_num_src_resps = -1 THEN
        RAISE e_invalid_src_resps;
    END IF;

    -- Validate x_trg_responsibilities
    g_num_trg_resps := Decompose_Numeric_List(x_trg_responsibilities, g_trg_resps, ',');
    IF g_num_trg_resps = -1 THEN
        RAISE e_invalid_trg_resps;
    END IF;

    -- The user must to provide at least one source responsibility
    IF g_num_src_resps = 0 THEN
        RAISE e_null_src_resps;
    END IF;

    -- The user must to provide at least one target responsibility
    IF g_num_trg_resps = 0 THEN
        RAISE e_null_trg_resps;
    END IF;

    -- The user must provide the same number of source and target responsibilities
    IF g_num_src_resps <> g_num_trg_resps THEN
        RAISE e_no_match_resps;
    END IF;

    -- All the provided source responsibilities must exists in the source system.
    FOR h_i IN 1..g_num_src_resps LOOP
        h_sql := 'SELECT responsibility_id'||
                 ' FROM bsc_responsibility_vl@'||g_db_link||
                 ' WHERE responsibility_id = :1';
        OPEN h_cursor FOR h_sql USING g_src_resps(h_i);
        FETCH h_cursor INTO h_resp;
        IF h_cursor%NOTFOUND THEN
            CLOSE h_cursor;
            h_resp := g_src_resps(h_i);
            RAISE e_no_src_resp;
        END IF;
        CLOSE h_cursor;
    END LOOP;

    -- All the provided target responsibilities must exists in the target system.
    FOR h_i IN 1..g_num_trg_resps LOOP
        h_sql := 'SELECT responsibility_id'||
                 ' FROM bsc_responsibility_vl'||
                 ' WHERE responsibility_id = :1';
        OPEN h_cursor FOR h_sql USING g_trg_resps(h_i);
        FETCH h_cursor INTO h_resp;
        IF h_cursor%NOTFOUND THEN
            CLOSE h_cursor;
            h_resp := g_trg_resps(h_i);
            RAISE e_no_trg_resp;
        END IF;
        CLOSE h_cursor;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN e_invalid_src_resps THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_INV_SRC_RESPS');
        RETURN FALSE;

    WHEN e_invalid_trg_resps THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_INV_TRG_RESPS');
        RETURN FALSE;

    WHEN e_null_src_resps THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_SRC_RESPS_EMPTY');
        RETURN FALSE;

    WHEN e_null_trg_resps THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_TRG_RESPS_EMPTY');
        RETURN FALSE;

    WHEN e_no_match_resps THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_NOMATCH_RESPS');
        RETURN FALSE;

    WHEN e_no_src_resp THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_SRC_RESP_NOEXIST');
        x_validation_error := BSC_APPS.Replace_Token(x_validation_error, 'RESP_ID', TO_CHAR(h_resp));
        RETURN FALSE;

    WHEN e_no_trg_resp THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_TRG_RESP_NOEXIST');
        x_validation_error := BSC_APPS.Replace_Token(x_validation_error, 'RESP_ID', TO_CHAR(h_resp));
        RETURN FALSE;

    WHEN OTHERS THEN
        x_validation_error := SQLERRM;
        RETURN FALSE;

END Validate_Responsibilities;


/*===========================================================================+
| PROCEDURE Validate_System_Versions
+============================================================================*/
FUNCTION Validate_System_Versions(
  x_validation_error OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS

    e_src_invalid_version EXCEPTION;
    e_trg_invalid_version EXCEPTION;

    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_src_version VARCHAR2(30);
    h_trg_version VARCHAR2(30);
    h_status VARCHAR2(30);

BEGIN
    --- for bug 5583119
    -- we will compare version of both source and target against each other
    -- rather than comparing against a constant hard coded value
    -- if both source and target are on same version than migration can proceed

    -- We will get the target system's version first,
    -- so as to use it later for log messages

    -- get the version of the target system
    h_sql := 'SELECT property_value'||
             ' FROM bsc_sys_init'||
             ' WHERE UPPER(property_code) = :1';
    OPEN h_cursor FOR h_sql USING 'PATCH_NUMBER';
    FETCH h_cursor INTO h_trg_version;
    IF h_cursor%NOTFOUND THEN
       CLOSE h_cursor;
       RAISE e_trg_invalid_version;
    END IF;
    CLOSE h_cursor;

    -- get the version of the source system
    h_sql := 'SELECT property_value'||
             ' FROM bsc_sys_init@'||g_db_link||
             ' WHERE UPPER(property_code) = :1';
    OPEN h_cursor FOR h_sql USING 'PATCH_NUMBER';
    FETCH h_cursor INTO h_src_version;
    IF h_cursor%NOTFOUND THEN
       CLOSE h_cursor;
       RAISE e_src_invalid_version;
    ELSE --compare source and target system BSC versions
       IF h_trg_version <> h_src_version THEN
          CLOSE h_cursor;
          RAISE e_src_invalid_version;
       END IF;
    END IF;
    CLOSE h_cursor;

    h_sql := 'SELECT property_value'||
             ' FROM bsc_sys_init@'||g_db_link||
             ' WHERE UPPER(property_code) = :1';
    OPEN h_cursor FOR h_sql USING 'PATCH_STATUS';
    FETCH h_cursor INTO h_status;
    IF h_cursor%NOTFOUND THEN
        CLOSE h_cursor;
        RAISE e_src_invalid_version;
    END IF;
    CLOSE h_cursor;

    IF h_status <> 'APPLIED' THEN
        RAISE e_src_invalid_version;
    END IF;

    h_sql := 'SELECT property_value'||
             ' FROM bsc_sys_init'||
             ' WHERE UPPER(property_code) = :1';
    OPEN h_cursor FOR h_sql USING 'PATCH_STATUS';
    FETCH h_cursor INTO h_status;
    IF h_cursor%FOUND THEN
        IF h_status <> 'APPLIED' THEN
            CLOSE h_cursor;
            RAISE e_trg_invalid_version;
        END IF;
    END IF;
    CLOSE h_cursor;

    RETURN TRUE;
EXCEPTION
    WHEN e_src_invalid_version THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_INV_SRC_VERSION');
        x_validation_error := BSC_APPS.Replace_Token(x_validation_error, 'VERSION_NUMBER', h_trg_version);
        RETURN FALSE;

    WHEN e_trg_invalid_version THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_INV_TRG_VERSION');
        x_validation_error := BSC_APPS.Replace_Token(x_validation_error, 'VERSION_NUMBER', h_trg_version);
        RETURN FALSE;

    WHEN OTHERS THEN
        x_validation_error := BSC_APPS.Get_Message('BSC_MIG_NO_SOURCE_SYSTEM');
        RETURN FALSE;

END Validate_System_Versions;


/*===========================================================================+
| PROCEDURE Validate_Tables
+============================================================================*/
FUNCTION Validate_Tables RETURN BOOLEAN IS
    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_table VARCHAR2(30);
    h_i NUMBER;

    h_invalid_tables t_array_of_varchar2;
    h_num_invalid_tables NUMBER;

    h_invalid_dim_tables t_array_of_varchar2;
    h_num_invalid_dim_tables NUMBER;

    h_invalid_dim_objs t_array_of_varchar2;
    h_num_invalid_dim_objs NUMBER;

    h_invalid_kpis_code t_array_of_number;
    h_invalid_kpis_name t_array_of_varchar2;
    h_num_invalid_kpis NUMBER;

    h_kpi_code NUMBER;
    h_kpi_name VARCHAR2(200);
    h_dim_table VARCHAR2(30);
    h_dim_obj VARCHAR2(300);
    h_dim_obj1 VARCHAR2(300);

BEGIN

    -- Get invalid dimension tables
    h_num_invalid_dim_tables := 0;
    h_num_invalid_dim_objs := 0;

    --Fix bug#4206368: Fix bug#4206368 the dimension table name may be in lowercase!
    h_sql := 'SELECT level_table_name, name'||
             ' FROM bsc_sys_dim_levels_vl@'||g_db_link||
             ' WHERE NVL(source, ''BSC'') = ''BSC'' AND '||
             ' UPPER(level_table_name) NOT IN ('||
             ' SELECT table_name'||
             ' FROM all_tables@'||g_db_link||
             ' WHERE owner = :1)';
    OPEN h_cursor FOR h_sql USING g_src_bsc_schema;
    LOOP
        FETCH h_cursor INTO h_dim_table, h_dim_obj;
        EXIT WHEN h_cursor%NOTFOUND;

        h_num_invalid_dim_tables := h_num_invalid_dim_tables + 1;
        h_invalid_dim_tables(h_num_invalid_dim_tables) := h_dim_table;

        h_num_invalid_dim_objs := h_num_invalid_dim_objs + 1;
        h_invalid_dim_objs(h_num_invalid_dim_objs) := h_dim_obj;
    END LOOP;
    CLOSE h_cursor;

    -- Get invalid mn dimension tables
    --Fix bug#4206368: Fix bug#4206368 the dimension table name may be in lowercase!
    h_sql := 'SELECT DISTINCT r.relation_col, c.name, p.name'||
             ' FROM bsc_sys_dim_level_rels@'||g_db_link||' r,'||
             ' bsc_sys_dim_levels_vl@'||g_db_link||' c, '||
             ' bsc_sys_dim_levels_vl@'||g_db_link||' p'||
             ' WHERE r.relation_type = 2 AND r.dim_level_id = c.dim_level_id (+)'||
             ' AND r.parent_dim_level_id = p.dim_level_id (+)'||
             ' AND UPPER(r.relation_col) NOT IN ('||
             ' SELECT table_name'||
             ' FROM all_tables@'||g_db_link||
             ' WHERE owner = :1)';
    OPEN h_cursor FOR h_sql USING g_src_bsc_schema;
    LOOP
        FETCH h_cursor INTO h_dim_table, h_dim_obj, h_dim_obj1;
        EXIT WHEN h_cursor%NOTFOUND;

        IF NOT Item_Belong_To_Array_Varchar2(h_dim_table, h_invalid_dim_tables, h_num_invalid_dim_tables) THEN
            h_num_invalid_dim_tables := h_num_invalid_dim_tables + 1;
            h_invalid_dim_tables(h_num_invalid_dim_tables) := h_dim_table;
        END IF;

        IF h_dim_obj IS NOT NULL THEN
            IF NOT Item_Belong_To_Array_Varchar2(h_dim_obj, h_invalid_dim_objs, h_num_invalid_dim_objs) THEN
                h_num_invalid_dim_objs := h_num_invalid_dim_objs + 1;
                h_invalid_dim_objs(h_num_invalid_dim_objs) := h_dim_obj;
            END IF;
        END IF;

        IF h_dim_obj1 IS NOT NULL THEN
            IF NOT Item_Belong_To_Array_Varchar2(h_dim_obj1, h_invalid_dim_objs, h_num_invalid_dim_objs) THEN
                h_num_invalid_dim_objs := h_num_invalid_dim_objs + 1;
                h_invalid_dim_objs(h_num_invalid_dim_objs) := h_dim_obj1;
            END IF;
        END IF;
    END LOOP;
    CLOSE h_cursor;

    -- Get invalid summary, base and input tables
    h_num_invalid_tables := 0;

    FOR h_i IN 1..g_num_mig_tables LOOP
        h_table := g_mig_tables(h_i);

        IF g_adv_sum_level IS NULL THEN
            -- BSC summary tables architecture. All summary tables should exists
            IF NOT Exist_Table_In_Src(h_table) THEN
                h_num_invalid_tables := h_num_invalid_tables + 1;
                h_invalid_tables(h_num_invalid_tables) := h_table;
            END IF;
        ELSE
            -- BSC-MV architecture. Generation type = -1 means the table does not exists
            IF Get_Table_Generation_Type_Src(h_table) <> -1 THEN
                IF NOT Exist_Table_In_Src(h_table) THEN
                    h_num_invalid_tables := h_num_invalid_tables + 1;
                    h_invalid_tables(h_num_invalid_tables) := h_table;
                END IF;
            END IF;
        END IF;
    END LOOP;

    IF (h_num_invalid_tables = 0) AND (h_num_invalid_dim_tables = 0) THEN
        RETURN TRUE;
    END IF;

    -- Write to the log file the invalid tables and kpis
    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_FOUND_INVALID_TABLES'), BSC_APPS.OUTPUT_FILE);
    BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
    BSC_APPS.Write_Line_Log(RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TABLE'),32)||
                            BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TYPE'),
                            BSC_APPS.OUTPUT_FILE);
    BSC_APPS.Write_Line_Log(RPAD('-', 30, '-')||'  '||RPAD('-', 30, '-'), BSC_APPS.OUTPUT_FILE);

    h_num_invalid_kpis := 0;
    FOR h_i IN 1..h_num_invalid_tables LOOP
        BSC_APPS.Write_Line_Log(RPAD(h_invalid_tables(h_i),32)||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_FACT_TABLE'),
                                BSC_APPS.OUTPUT_FILE);

        -- Add to the array of invalid kpis the affected indicators
        h_sql := 'select distinct k.indicator, k.name'||
                 ' from bsc_kpi_data_tables@'||g_db_link||' t, bsc_kpis_vl@'||g_db_link||' k'||
                 ' where t.indicator = k.indicator and'||
                 ' (t.table_name = :1 or'||
                 ' t.table_name in ('||
                 ' select distinct table_name'||
                 ' from bsc_db_tables_rels@'||g_db_link||
                 ' start with source_table_name = :2'||
                 ' connect by source_table_name = prior table_name))';
        OPEN h_cursor FOR h_sql USING h_invalid_tables(h_i), h_invalid_tables(h_i);
        LOOP
            FETCH h_cursor INTO h_kpi_code, h_kpi_name;
            EXIT WHEN h_cursor%NOTFOUND;

            IF NOT Item_Belong_To_Array_Number(h_kpi_code, h_invalid_kpis_code, h_num_invalid_kpis) THEN
                h_num_invalid_kpis := h_num_invalid_kpis + 1;
                h_invalid_kpis_code(h_num_invalid_kpis) := h_kpi_code;
                h_invalid_kpis_name(h_num_invalid_kpis) := h_kpi_name;
            END IF;
        END LOOP;
        CLOSE h_cursor;
    END LOOP;
    FOR h_i IN 1..h_num_invalid_dim_tables LOOP
        BSC_APPS.Write_Line_Log(RPAD(h_invalid_dim_tables(h_i),32)||
                                BSC_APPS.Get_Lookup_Value('BSC_UI_BUILDER', 'DIMENTION_TABLE'),
                                BSC_APPS.OUTPUT_FILE);
    END LOOP;
    BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);

    -- Now write the affected indicators
    IF h_num_invalid_kpis > 0 THEN
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'RELATED_OBJECTIVES'), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(RPAD('-', 50, '-'), BSC_APPS.OUTPUT_FILE);
        FOR h_i IN 1..h_num_invalid_kpis LOOP
            BSC_APPS.Write_Line_Log(RPAD(h_invalid_kpis_code(h_i), 12)||h_invalid_kpis_name(h_i), BSC_APPS.OUTPUT_FILE);
        END LOOP;
        BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
    END IF;

    -- Now write invalid dimension objects
    IF h_num_invalid_dim_objs > 0 THEN
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECTS'), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(RPAD('-', 50, '-'), BSC_APPS.OUTPUT_FILE);
        FOR h_i IN 1..h_num_invalid_dim_objs LOOP
            BSC_APPS.Write_Line_Log(h_invalid_dim_objs(h_i), BSC_APPS.OUTPUT_FILE);
        END LOOP;
        BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
    END IF;

    BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_ACTION_INVALID_TABLES'), BSC_APPS.OUTPUT_FILE);
    BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
    IF h_num_invalid_tables > 0 THEN
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_ACTION1_INVALID_TABLES'), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
    END IF;
    IF h_num_invalid_dim_tables > 0 THEN
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_ACTION2_INVALID_TABLES'), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
    END IF;

    RETURN FALSE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Validate_Tables');
        RETURN FALSE;
END Validate_Tables;


/*===========================================================================+
| FUNCTION Exist_Table_In_Src
+============================================================================*/
FUNCTION Exist_Table_In_Src(
    x_table_name IN VARCHAR2
) RETURN BOOLEAN IS
    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_count NUMBER;

BEGIN
    h_sql := 'select count(*)'||
             ' from all_tables@'||g_db_link||
             ' where owner = :1 and table_name = :2';
    OPEN h_cursor FOR h_sql USING g_src_bsc_schema, x_table_name;
    FETCH h_cursor INTO h_count;
    CLOSE h_cursor;

    IF h_count > 0 THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
END Exist_Table_In_Src;


/*===========================================================================+
| FUNCTION Get_Table_Generation_Type_Src
+============================================================================*/
FUNCTION Get_Table_Generation_Type_Src(
  x_table_name IN VARCHAR2
  ) RETURN NUMBER IS

    h_table_generation_type NUMBER;
    h_sql VARCHAR2(32700);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

BEGIN
    h_table_generation_type := NULL;

    h_sql := 'SELECT generation_type'||
             ' FROM bsc_db_tables@'||g_db_link||
             ' WHERE table_name = :1';
    OPEN h_cursor FOR h_sql USING x_table_name;
    FETCH h_cursor INTO h_table_generation_type;
    IF h_cursor%NOTFOUND THEN
        h_table_generation_type := NULL;
    END IF;
    CLOSE h_cursor;

    RETURN h_table_generation_type;

END Get_Table_Generation_Type_Src;


--Fix bug#4220506
/*===========================================================================+
| PROCEDURE Write_Log_Invalid_PMF_Objects
+============================================================================*/
PROCEDURE Write_Log_Invalid_PMF_Objects IS

    h_i NUMBER;
    h_condition VARCHAR2(32000);
    h_sql VARCHAR2(32000);
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_application_name VARCHAR2(240);
    h_indicator NUMBER;
    h_name VARCHAR2(200);
    h_short_name VARCHAR2(200);

BEGIN
    IF (g_num_invalid_pmf_measures > 0) OR (g_num_invalid_pmf_dimensions > 0) OR
       (g_num_invalid_pmf_dim_levels > 0) OR (g_num_no_mig_kpis > 0) THEN

        g_warnings := TRUE;

        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_UPG_PMF_ERROR'), BSC_APPS.OUTPUT_FILE);
        BSC_APPS.Write_Line_Log(BSC_APPS.Get_Message('BSC_MIG_INSTALL_PROD_PATCH'), BSC_APPS.OUTPUT_FILE);

        IF g_num_no_mig_kpis > 0 THEN
            BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
            BSC_APPS.Write_Line_Log(RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_BACKEND', 'KPI_CODE'), 15)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_NAME'), 50),
                                    BSC_UPDATE_LOG.OUTPUT);

            h_condition := BSC_APPS.Get_New_Big_In_Cond_Number(1, 'indicator');
            FOR h_i IN 1 .. g_num_no_mig_kpis LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, g_no_mig_kpis(h_i));
            END LOOP;

            h_sql := 'SELECT indicator, name'||
                     ' FROM bsc_kpis_vl@'||g_db_link||
                     ' WHERE '||h_condition;
            OPEN h_cursor FOR h_sql;
            LOOP
                FETCH h_cursor INTO h_indicator, h_name;
                EXIT WHEN h_cursor%NOTFOUND;

                BSC_APPS.Write_Line_Log(RPAD(h_indicator, 15)||h_name,
                                             BSC_UPDATE_LOG.OUTPUT);

            END LOOP;
            CLOSE h_cursor;
        END IF;

        IF g_num_invalid_pmf_measures > 0 THEN
            BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
            BSC_APPS.Write_Line_Log(RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_MEASURE'), 40)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'SHORT_NAME'), 35)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'APPLICATION_NAME'), 40),
                                    BSC_UPDATE_LOG.OUTPUT);

            h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'i.short_name');
            FOR h_i IN 1 .. g_num_invalid_pmf_measures LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, g_invalid_pmf_measures(h_i));
            END LOOP;

            -- perf bug#4583017: remove distinct
            h_sql := 'SELECT itl.name, i.short_name, f.application_name'||
                     ' FROM bis_indicators@'||g_db_link||' i,'||
                     ' bis_indicators_tl@'||g_db_link||' itl,'||
                     ' bis_application_measures@'||g_db_link||' am,'||
                     ' fnd_application_vl@'||g_db_link||' f'||
                     ' WHERE i.indicator_id = itl.indicator_id AND'||
                     ' itl.language = USERENV(''LANG'') AND'||
                     ' i.indicator_id = am.indicator_id AND'||
                     ' am.application_id = f.application_id(+) AND '||h_condition;
            OPEN h_cursor FOR h_sql;
            LOOP
                FETCH h_cursor INTO h_name, h_short_name, h_application_name;
                EXIT WHEN h_cursor%NOTFOUND;

                BSC_APPS.Write_Line_Log(RPAD(h_name, 40)||
                                        RPAD(h_short_name, 35)||
                                        h_application_name,
                                        BSC_UPDATE_LOG.OUTPUT);
            END LOOP;
            CLOSE h_cursor;
        END IF;

        IF g_num_invalid_pmf_dimensions > 0 THEN
            BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
            BSC_APPS.Write_Line_Log(RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), 40)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'SHORT_NAME'), 35)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'APPLICATION_NAME'), 40),
                                    BSC_UPDATE_LOG.OUTPUT);

            h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'd.short_name');
            FOR h_i IN 1 .. g_num_invalid_pmf_dimensions LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, g_invalid_pmf_dimensions(h_i));
            END LOOP;

            h_sql := 'SELECT DISTINCT dtl.name, d.short_name, f.application_name'||
                     ' FROM bis_dimensions@'||g_db_link||' d,'||
                     ' bis_dimensions_tl@'||g_db_link||' dtl,'||
                     ' fnd_application_vl@'||g_db_link||' f'||
                     ' WHERE d.dimension_id = dtl.dimension_id AND'||
                     ' dtl.language =  USERENV(''LANG'') AND'||
                     ' d.application_id = f.application_id (+) AND '||h_condition;
            OPEN h_cursor FOR h_sql;
            LOOP
                FETCH h_cursor INTO h_name, h_short_name, h_application_name;
                EXIT WHEN h_cursor%NOTFOUND;

                BSC_APPS.Write_Line_Log(RPAD(h_name, 40)||
                                        RPAD(h_short_name, 35)||
                                        h_application_name,
                                        BSC_UPDATE_LOG.OUTPUT);
            END LOOP;
            CLOSE h_cursor;
        END IF;

        IF g_num_invalid_pmf_dim_levels > 0 THEN
            BSC_APPS.Write_Line_Log(' ', BSC_APPS.OUTPUT_FILE);
            BSC_APPS.Write_Line_Log(RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), 40)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'SHORT_NAME'), 35)||
                                    RPAD(BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'APPLICATION_NAME'), 40),
                                    BSC_UPDATE_LOG.OUTPUT);

            h_condition := BSC_APPS.Get_New_Big_In_Cond_Varchar2(1, 'l.short_name');
            FOR h_i IN 1 .. g_num_invalid_pmf_dim_levels LOOP
                BSC_APPS.Add_Value_Big_In_Cond(1, g_invalid_pmf_dim_levels(h_i));
            END LOOP;

            h_sql := 'SELECT DISTINCT ltl.name, l.short_name, f.application_name'||
                     ' FROM bis_levels@'||g_db_link||' l,'||
                     ' bis_levels_tl@'||g_db_link||' ltl,'||
                     ' fnd_application_vl@'||g_db_link||' f'||
                     ' WHERE l.level_id = ltl.level_id AND'||
                     ' ltl.language = USERENV(''LANG'') AND'||
                     ' l.application_id = f.application_id (+) AND '||h_condition;
            OPEN h_cursor FOR h_sql;
            LOOP
                FETCH h_cursor INTO h_name, h_short_name, h_application_name;
                EXIT WHEN h_cursor%NOTFOUND;

                BSC_APPS.Write_Line_Log(RPAD(h_name, 40)||
                                        RPAD(h_short_name, 35)||
                                        h_application_name,
                                        BSC_UPDATE_LOG.OUTPUT);
            END LOOP;
            CLOSE h_cursor;
        END IF;
    END IF;
END Write_Log_Invalid_PMF_Objects;


/*===========================================================================+
| PROCEDURE Migrate_Custom_PMF_Dimensions
+============================================================================*/
PROCEDURE Migrate_Custom_PMF_Dimensions IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(20000);

    h_pmf VARCHAR2(3) := 'PMF';
    h_count NUMBER;

    h_dimension_rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
    h_dimension_short_name VARCHAR2(2000);
    h_dimension_name VARCHAR2(2000);
    h_description VARCHAR2(2000);
    h_hide        VARCHAR2(10);
    h_application_id NUMBER;
    h_return_status VARCHAR2(2000);
    h_error_msg VARCHAR2(2000);
    h_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;


BEGIN
    -- Enh#4697749
    --Query to get non-pre-seeded BSC/PMF dimensions from the source
    --We will need to create/update those dimensions in the target
    -- seed data owner r12 bug 5099776
    h_sql := 'SELECT DISTINCT sbsc_d.short_name'||
             ' FROM bsc_sys_dim_groups_vl@'||g_db_link||' sbsc_d,'||
             ' bis_dimensions@'||g_db_link||' spmf_d'||
             ' WHERE sbsc_d.short_name = spmf_d.short_name AND'||
             ' spmf_d.created_by NOT IN (:1, :2, :3, :4)';
    OPEN h_cursor FOR h_sql USING 1, 2,120,121;
    LOOP
        FETCH h_cursor INTO h_dimension_short_name;
        EXIT WHEN h_cursor%NOTFOUND;

        -- Retrieve the dimension from the source system
        BSC_APPS.Write_Line_Log('Migrating existing source dimension '||h_dimension_short_name, BSC_APPS.OUTPUT_FILE);

        h_sql := 'BEGIN BSC_MIGRATION.Retrieve_Dimension@'||g_db_link||'('||
                 ' p_dimension_short_name => :1'||
                 ', x_dimension_name => :2'||
                 ', x_description => :3'||
                 ', x_application_id => :4'||
                 ', x_return_status => :5'||
                 ', x_error_msg => :6'||
                 ', x_hide => :7'||
                 '); END;';
        execute immediate h_sql
        using h_dimension_short_name, OUT h_dimension_name,
              OUT h_description, OUT h_application_id,
              OUT h_return_status, OUT h_error_msg, OUT h_hide;

        IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            BSC_APPS.Write_Line_Log('Error retrieving dimension: '||h_error_msg, BSC_APPS.OUTPUT_FILE);
        ELSE
            h_dimension_rec.Dimension_Short_Name := h_dimension_short_name;
            h_dimension_rec.Dimension_Name := h_dimension_name;
            h_dimension_rec.Description := h_description;
            h_dimension_rec.Application_ID := h_application_id;
            h_dimension_rec.Hide := h_hide;

            --check if the dimension exists in the target
            h_count := 0;
            select count(short_name)
            into h_count
            from bis_dimensions
            where short_name = h_dimension_short_name;

            IF h_count = 0 THEN
                -- Dimension does not exists, create it
                BIS_DIMENSION_PUB.Create_Dimension(
                     p_api_version       =>  1.0
                   , p_commit            =>  FND_API.G_FALSE
                   , p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL
                   , p_Dimension_Rec     =>  h_dimension_rec
                   , x_return_status     =>  h_return_status
                   , x_error_Tbl         =>  h_error_tbl
                );
                commit;

                IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    BSC_APPS.Write_Line_Log('Error creating dimension: '||h_error_tbl(1).Error_Description, BSC_APPS.OUTPUT_FILE);
                END IF;
            ELSE
                -- Dimension exists, update it
                BIS_DIMENSION_PUB.Update_Dimension(
                     p_api_version       =>  1.0
                   , p_commit            =>  FND_API.G_FALSE
                   , p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL
                   , p_Dimension_Rec     =>  h_dimension_rec
                   , x_return_status     =>  h_return_status
                   , x_error_Tbl         =>  h_error_tbl
                );
                commit;

                IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    BSC_APPS.Write_Line_Log('Error updating dimension: '||h_error_tbl(1).Error_Description, BSC_APPS.OUTPUT_FILE);
                END IF;
            END IF;
        END IF;
    END LOOP;
    CLOSE h_cursor;

END Migrate_Custom_PMF_Dimensions;


/*===========================================================================+
| PROCEDURE Migrate_Custom_PMF_Dim_Levels
+============================================================================*/
PROCEDURE Migrate_Custom_PMF_Dim_Levels IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_cursor2 t_cursor;
    h_sql VARCHAR2(20000);

    h_pmf VARCHAR2(3) := 'PMF';
    h_count NUMBER;

    h_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;

    h_dimension_level_short_name VARCHAR2(2000);
    h_dimension_short_name VARCHAR2(2000);
    h_dimension_name VARCHAR2(2000);
    h_dimension_level_name VARCHAR2(2000);
    h_description VARCHAR2(2000);
    h_hide          VARCHAR2(10);
    h_level_values_view_name VARCHAR2(2000);
    h_where_clause VARCHAR2(2000);
    h_source VARCHAR2(2000);
    h_comparison_label_code VARCHAR2(2000);
    h_attribute_code VARCHAR2(2000);
    h_application_id NUMBER;
    h_default_search VARCHAR2(2000);
    h_long_lov VARCHAR2(2000);
    h_master_level VARCHAR2(2000);
    h_view_object_name VARCHAR2(2000);
    h_default_values_api VARCHAR2(2000);
    h_enabled VARCHAR2(2000);
    h_drill_to_form_function VARCHAR2(2000);
    h_primary_dim VARCHAR2(2000);

    h_return_status VARCHAR2(2000);
    h_error_msg VARCHAR2(2000);
    h_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

    h_level_source VARCHAR2(2000);
    h_create_level BOOLEAN;

BEGIN
    -- Enh#4697749
    --Query to get non-pre-seeded BSC/PMF dimension levels from the source
    --We will need to create/update those dimension levels in the target
    -- bug 5099776
    h_sql := 'SELECT DISTINCT sbsc_dl.short_name, sbsc_dl.source'||
             ' FROM bsc_sys_dim_levels_b@'||g_db_link||' sbsc_dl,'||
             ' bis_levels@'||g_db_link||' spmf_dl'||
             ' WHERE sbsc_dl.short_name = spmf_dl.short_name AND'||
             ' spmf_dl.created_by NOT IN (:1, :2, :3, :4)';
    OPEN h_cursor FOR h_sql USING 1, 2,120,121;
    LOOP
        FETCH h_cursor INTO h_dimension_level_short_name, h_level_source;
        EXIT WHEN h_cursor%NOTFOUND;

        -- Retrieve the dimension level from the source system
        BSC_APPS.Write_Line_Log('Migrating existing source dimension object '||h_dimension_level_short_name, BSC_APPS.OUTPUT_FILE);

        h_sql := 'BEGIN BSC_MIGRATION.Retrieve_Dimension_Level@'||g_db_link||'('||
                 '  p_dimension_level_short_name => :1'||
                 ', x_dimension_short_name => :2'||
                 ', x_dimension_name => :3'||
                 ', x_dimension_level_name => :4'||
                 ', x_description => :5'||
                 ', x_level_values_view_name => :6'||
                 ', x_where_clause => :7'||
                 ', x_source => :8'||
                 ', x_comparison_label_code => :9'||
                 ', x_attribute_code => :10'||
                 ', x_application_id => :11'||
                 ', x_default_search => :12'||
                 ', x_long_lov => :13'||
                 ', x_master_level => :14'||
                 ', x_view_object_name => :15'||
                 ', x_default_values_api => :16'||
                 ', x_enabled => :17'||
                 ', x_drill_to_form_function => :18'||
                 ', x_primary_dim => :19'||
                 ', x_return_status => :20'||
                 ', x_error_msg => :21'||
                 ', x_hide => :22'||
                 '); END;';
        execute immediate h_sql
        using h_dimension_level_short_name, OUT h_dimension_short_name,
              OUT h_dimension_name, OUT h_dimension_level_name, OUT h_description,
              OUT h_level_values_view_name, OUT h_where_clause, OUT h_source,
              OUT h_comparison_label_code, OUT h_attribute_code, OUT h_application_id,
              OUT h_default_search, OUT h_long_lov, OUT h_master_level,
              OUT h_view_object_name, OUT h_default_values_api, OUT h_enabled,
              OUT h_drill_to_form_function, OUT h_primary_dim,
              OUT h_return_status, OUT h_error_msg, OUT h_hide;

        IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            BSC_APPS.Write_Line_Log('Error retrieving dimension object: '||h_error_msg, BSC_APPS.OUTPUT_FILE);
        ELSE
            h_dimension_level_rec.dimension_level_short_name := h_dimension_level_short_name;
            h_dimension_level_rec.dimension_short_name := h_dimension_short_name;
            h_dimension_level_rec.dimension_name := h_dimension_name;
            h_dimension_level_rec.dimension_level_name := h_dimension_level_name;
            h_dimension_level_rec.description := h_description;
            h_dimension_level_rec.level_values_view_name := h_level_values_view_name;
            h_dimension_level_rec.where_clause := h_where_clause;
            h_dimension_level_rec.source := h_source;
            h_dimension_level_rec.comparison_label_code := h_comparison_label_code;
            h_dimension_level_rec.attribute_code := h_attribute_code;
            h_dimension_level_rec.application_id := h_application_id;
            h_dimension_level_rec.default_search := h_default_search;
            h_dimension_level_rec.long_lov := h_long_lov;
            h_dimension_level_rec.master_level := h_master_level;
            h_dimension_level_rec.view_object_name := h_view_object_name;
            h_dimension_level_rec.default_values_api := h_default_values_api;
            h_dimension_level_rec.enabled := h_enabled;
            h_dimension_level_rec.drill_to_form_function := h_drill_to_form_function;
            h_dimension_level_rec.primary_dim := h_primary_dim;
            h_dimension_level_rec.hide        := h_hide;

            -- Fix bug#4932663: Migrate the level values view for PMF existing source dimensions levels
            -- Then check if the view has errors in the target system. If the view has errors
            -- then we do not migrate that dimension level
            h_create_level := TRUE;
            IF h_level_source = 'PMF' AND (h_level_values_view_name IS NOT NULL) THEN
                IF NOT Create_Copy_Of_View_Def(h_level_values_view_name,FALSE) THEN --bug 6004972 No Overwrite version
                    BSC_APPS.Write_Line_Log('Could not migrate the level values view: '||h_level_values_view_name,
                                            BSC_APPS.OUTPUT_FILE);
                    h_create_level := FALSE;
                ELSE
                    -- Check if the view has not errors
                    h_sql := 'select count(*) from '||h_level_values_view_name||' where rownum < :1';
                    BEGIN
                        OPEN h_cursor2 FOR h_sql USING 2;
                        FETCH h_cursor2 INTO h_count;
                        CLOSE h_cursor2;
                    EXCEPTION
                        WHEN OTHERS THEN
                            CLOSE h_cursor2;
                            BSC_APPS.Write_Line_Log('Level values view has errors: '||h_level_values_view_name,
                                                    BSC_APPS.OUTPUT_FILE);
                            h_create_level := FALSE;
                    END;
                END IF;
            END IF;

            IF h_create_level THEN
                --check if the dimension level exists in the target
                h_count := 0;
                select count(short_name)
                into h_count
                from bis_levels
                where short_name = h_dimension_level_short_name;

                IF h_count = 0 THEN
                    -- Dimension level does not exists, create it
                    BIS_DIMENSION_LEVEL_PUB.Create_Dimension_Level(
                         p_api_version         => 1.0
                           , p_commit              => FND_API.G_FALSE
                           , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                           , p_Dimension_Level_Rec => h_dimension_level_rec
                           , x_return_status       => h_return_status
                           , x_error_Tbl           => h_error_tbl
                    );
                    commit;

                    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        BSC_APPS.Write_Line_Log('Error creating dimension object: '||h_error_tbl(1).Error_Description,
                                                 BSC_APPS.OUTPUT_FILE);
                    END IF;
                ELSE
                    -- Dimension level exists, update it
                    BIS_DIMENSION_LEVEL_PUB.Update_Dimension_Level(
                         p_api_version         => 1.0
                           , p_commit              => FND_API.G_FALSE
                           , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                           , p_Dimension_Level_Rec => h_dimension_level_rec
                           , x_return_status       => h_return_status
                           , x_error_Tbl           => h_error_tbl
                    );
                    commit;

                    IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        BSC_APPS.Write_Line_Log('Error updating dimension level: '||h_error_tbl(1).Error_Description,
                                                BSC_APPS.OUTPUT_FILE);
                    END IF;
                END IF;
            END IF;
        END IF;
    END LOOP;
    CLOSE h_cursor;

END Migrate_Custom_PMF_Dim_Levels;


/*===========================================================================+
| PROCEDURE Migrate_Custom_PMF_Measures
+============================================================================*/
PROCEDURE Migrate_Custom_PMF_Measures IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(20000);

    h_pmf VARCHAR2(3) := 'PMF';
    h_count NUMBER;

    h_measure_rec BIS_MEASURE_PUB.Measure_Rec_Type;

    h_measure_short_name VARCHAR2(2000);
    h_measure_name VARCHAR2(2000);
    h_description VARCHAR2(2000);
    h_region_app_id NUMBER;
    h_source_column_app_id NUMBER;
    h_compare_column_app_id NUMBER;
    h_actual_data_source_type VARCHAR2(2000);
    h_actual_data_source VARCHAR2(2000);
    h_function_name VARCHAR2(2000);
    h_comparison_source VARCHAR2(2000);
    h_increase_in_measure VARCHAR2(2000);
    h_enable_link VARCHAR2(2000);
    h_enabled VARCHAR2(2000);
    h_obsolete VARCHAR2(2000);
    h_measure_type VARCHAR2(2000);
    h_dimension1_short_name VARCHAR2(2000);
    h_dimension1_name VARCHAR2(2000);
    h_dimension2_short_name VARCHAR2(2000);
    h_dimension2_name VARCHAR2(2000);
    h_dimension3_short_name VARCHAR2(2000);
    h_dimension3_name VARCHAR2(2000);
    h_dimension4_short_name VARCHAR2(2000);
    h_dimension4_name VARCHAR2(2000);
    h_dimension5_short_name VARCHAR2(2000);
    h_dimension5_name VARCHAR2(2000);
    h_dimension6_short_name VARCHAR2(2000);
    h_dimension6_name VARCHAR2(2000);
    h_dimension7_short_name VARCHAR2(2000);
    h_dimension7_name VARCHAR2(2000);
    h_unit_of_measure_class VARCHAR2(2000);
    h_application_id NUMBER;
    h_is_validate VARCHAR2(2000);
    h_func_area_short_name VARCHAR2(2000);

    h_return_status VARCHAR2(2000);
    h_error_msg VARCHAR2(2000);
    h_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

    -- Enh#4697749 new variables
    h_region_code VARCHAR2(200);


BEGIN
    -- Following join changed to use dataset_id because there can be
    -- many datasets pointing to same measure. Bug 5990096
    -- be taken care by sync up apis
    -- Enh#4697749
    --Query to get non-pre-seeded BSC/PMF measures from the source
    --We will need to create/update those measures in the target
    -- bug 5099776
    h_sql := 'SELECT DISTINCT si.short_name'||
             ' FROM bis_indicators@'||g_db_link||' si,'||
       ' bsc_sys_datasets_b@'||g_db_link||' sd'||
       ' WHERE sd.dataset_id= si.dataset_id AND'||
       ' si.created_by NOT IN (:2, :3, :4, :5)';
    OPEN h_cursor FOR h_sql USING 1, 2,120,121;
    LOOP
        FETCH h_cursor INTO h_measure_short_name;
        EXIT WHEN h_cursor%NOTFOUND;

        -- Retrieve the measure from the source system
        BSC_APPS.Write_Line_Log('Migrating existing source measure '||h_measure_short_name, BSC_APPS.OUTPUT_FILE);

        h_sql := 'BEGIN BSC_MIGRATION.Retrieve_Measure@'||g_db_link||'('||
                 '  p_measure_short_name => :1'||
                 ', x_measure_name => :2'||
                 ', x_description => :3'||
                 ', x_region_app_id => :4'||
                 ', x_source_column_app_id => :5'||
                 ', x_compare_column_app_id => :6'||
                 ', x_actual_data_source_type => :7'||
                 ', x_actual_data_source => :8'||
                 ', x_function_name => :9'||
                 ', x_comparison_source => :10'||
                 ', x_increase_in_measure => :11'||
                 ', x_enable_link => :12'||
                 ', x_enabled => :13'||
                 ', x_obsolete => :14'||
                 ', x_measure_type => :15'||
                 ', x_dimension1_short_name => :16'||
                 ', x_dimension1_name => :17'||
                 ', x_dimension2_short_name => :18'||
                 ', x_dimension2_name => :19'||
                 ', x_dimension3_short_name => :20'||
                 ', x_dimension3_name => :21'||
                 ', x_dimension4_short_name => :22'||
                 ', x_dimension4_name => :23'||
                 ', x_dimension5_short_name => :24'||
                 ', x_dimension5_name => :25'||
                 ', x_dimension6_short_name => :26'||
                 ', x_dimension6_name => :27'||
                 ', x_dimension7_short_name => :28'||
                 ', x_dimension7_name => :29'||
                 ', x_unit_of_measure_class => :30'||
                 ', x_application_id => :31'||
                 ', x_is_validate => :32'||
                 ', x_func_area_short_name => :33'||
                 ', x_return_status => :34'||
                 ', x_error_msg => :35'||
                 '); END;';
        execute immediate h_sql
        using h_measure_short_name, OUT h_measure_name, OUT h_description, OUT h_region_app_id,
              OUT h_source_column_app_id, OUT h_compare_column_app_id, OUT h_actual_data_source_type,
              OUT h_actual_data_source, OUT h_function_name, OUT h_comparison_source,
              OUT h_increase_in_measure, OUT h_enable_link, OUT h_enabled, OUT h_obsolete,
              OUT h_measure_type, OUT h_dimension1_short_name, OUT h_dimension1_name,
              OUT h_dimension2_short_name, OUT h_dimension2_name, OUT h_dimension3_short_name,
              OUT h_dimension3_name, OUT h_dimension4_short_name, OUT h_dimension4_name,
              OUT h_dimension5_short_name, OUT h_dimension5_name, OUT h_dimension6_short_name,
              OUT h_dimension6_name, OUT h_dimension7_short_name, OUT h_dimension7_name,
              OUT h_unit_of_measure_class, OUT h_application_id, OUT h_is_validate,
              OUT h_func_area_short_name, OUT h_return_status, OUT h_error_msg;

        IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            BSC_APPS.Write_Line_Log('Error retrieving measure: '||h_error_msg, BSC_APPS.OUTPUT_FILE);
        ELSE
            h_measure_rec.measure_short_name := h_measure_short_name;
            h_measure_rec.measure_name := h_measure_name;
            h_measure_rec.description := h_description;
            h_measure_rec.region_app_id := h_region_app_id;
            h_measure_rec.source_column_app_id := h_source_column_app_id;
            h_measure_rec.compare_column_app_id := h_compare_column_app_id;
            h_measure_rec.actual_data_source_type := h_actual_data_source_type;
            h_measure_rec.actual_data_source := h_actual_data_source;
            h_measure_rec.function_name := h_function_name;
            h_measure_rec.comparison_source := h_comparison_source;
            h_measure_rec.increase_in_measure := h_increase_in_measure;
            h_measure_rec.enable_link := h_enable_link;
            h_measure_rec.enabled := h_enabled;
            h_measure_rec.obsolete := h_obsolete;
            h_measure_rec.measure_type := h_measure_type;
            h_measure_rec.dimension1_short_name := h_dimension1_short_name;
            h_measure_rec.dimension1_name := h_dimension1_name;
            h_measure_rec.dimension2_short_name := h_dimension2_short_name;
            h_measure_rec.dimension2_name := h_dimension2_name;
            h_measure_rec.dimension3_short_name := h_dimension3_short_name;
            h_measure_rec.dimension3_name := h_dimension3_name;
            h_measure_rec.dimension4_short_name := h_dimension4_short_name;
            h_measure_rec.dimension4_name := h_dimension4_name;
            h_measure_rec.dimension5_short_name := h_dimension5_short_name;
            h_measure_rec.dimension5_name := h_dimension5_name;
            h_measure_rec.dimension6_short_name := h_dimension6_short_name;
            h_measure_rec.dimension6_name := h_dimension6_name;
            h_measure_rec.dimension7_short_name := h_dimension7_short_name;
            h_measure_rec.dimension7_name := h_dimension7_name;
            h_measure_rec.unit_of_measure_class := h_unit_of_measure_class;
            h_measure_rec.application_id := h_application_id;
            h_measure_rec.is_validate := h_is_validate;
            h_measure_rec.func_area_short_name := h_func_area_short_name;

            -- Enh#4697749 Migrate AK Region of the measure
            IF h_actual_data_source_type = 'AK' THEN
                h_region_code := SUBSTR(h_actual_data_source, 1, INSTR(h_actual_data_source, '.') - 1);
                IF h_region_code IS NOT NULL THEN
                    IF NOT Migrate_AK_Region(h_region_code, h_error_msg) THEN
                        BSC_APPS.Write_Line_Log('Error migrating AK Region '||h_region_code||': '||h_error_msg,
                                                BSC_APPS.OUTPUT_FILE);
                    END IF;
                END IF;
                h_region_code := SUBSTR(h_comparison_source, 1, INSTR(h_comparison_source, '.') - 1);
                IF h_region_code IS NOT NULL THEN
                    IF NOT Migrate_AK_Region(h_region_code, h_error_msg) THEN
                        BSC_APPS.Write_Line_Log('Error migrating AK Region '||h_region_code||': '||h_error_msg,
                                                BSC_APPS.OUTPUT_FILE);
                    END IF;
                END IF;
            END IF;

            -- Enh#4697749 Migrate Form Function of the measure
            IF h_function_name IS NOT NULL THEN
                IF NOT Migrate_Form_Function(h_function_name, h_error_msg) THEN
                    BSC_APPS.Write_Line_Log('Error migrating Form Function '||h_function_name||': '||h_error_msg,
                                            BSC_APPS.OUTPUT_FILE);
                END IF;
            END IF;

            --check if the dimension level exists in the target
            h_count := 0;
            select count(short_name)
            into h_count
            from bis_indicators
            where short_name = h_measure_short_name;

            IF h_count = 0 THEN
                -- Measure does not exists, create it
                BIS_MEASURE_PUB.Create_Measure(
                     p_api_version   => 1.0
                   , p_commit        => FND_API.G_FALSE
                   , p_Measure_Rec   => h_measure_rec
                   , p_owner         => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
                   , x_return_status => h_return_status
                   , x_error_Tbl     => h_error_tbl
                );
                commit;

                IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    BSC_APPS.Write_Line_Log('Error creating measure: '||h_error_tbl(1).Error_Description,
                                            BSC_APPS.OUTPUT_FILE);
                END IF;
            ELSE
                -- Measure exists, update it
                BIS_MEASURE_PUB.Update_Measure(
                     p_api_version   => 1.0
                   , p_commit        => FND_API.G_FALSE
                   , p_Measure_Rec   => h_measure_rec
                   , p_owner         => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
                   , x_return_status => h_return_status
                   , x_error_Tbl     => h_error_tbl
                );
                commit;

                IF h_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    BSC_APPS.Write_Line_Log('Error updating measure: '||h_error_tbl(1).Error_Description,
                                            BSC_APPS.OUTPUT_FILE);
                END IF;
            END IF;
        END IF;
    END LOOP;
    CLOSE h_cursor;

END Migrate_Custom_PMF_Measures;


/*===========================================================================+
| PROCEDURE Retrieve_Dimension
+============================================================================*/
PROCEDURE Retrieve_Dimension
( p_dimension_short_name IN VARCHAR2
, x_dimension_name OUT NOCOPY VARCHAR2
, x_description OUT NOCOPY VARCHAR2
, x_hide        OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_msg OUT NOCOPY VARCHAR2
) IS
    e_error EXCEPTION;
    h_api_version NUMBER;
    h_dimension_rec_in BIS_DIMENSION_PUB.Dimension_Rec_Type;
    h_dimension_rec_out BIS_DIMENSION_PUB.Dimension_Rec_Type;
    h_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

    h_dimension_rec_in.dimension_short_name := p_dimension_short_name;
    h_api_version := 1.0;

    BIS_DIMENSION_PUB.Retrieve_Dimension(
    p_api_version       => h_api_version
   ,p_Dimension_Rec     => h_dimension_rec_in
   ,x_Dimension_Rec     => h_dimension_rec_out
   ,x_return_status     => x_return_status
   ,x_error_Tbl         => h_error_tbl
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_error;
    END IF;

    x_dimension_name := h_dimension_rec_out.dimension_name;
    x_description := h_dimension_rec_out.description;
    x_application_id := h_dimension_rec_out.application_id;
    x_hide        := h_dimension_rec_out.hide;

EXCEPTION
    WHEN e_error THEN
        x_error_msg := h_error_tbl(1).Error_Description;
    WHEN others THEN
        x_error_msg := SQLERRM;
        x_return_status := FND_API.G_RET_STS_ERROR;
END Retrieve_Dimension;


/*===========================================================================+
| PROCEDURE Retrieve_Dimension_Level
+============================================================================*/
PROCEDURE Retrieve_Dimension_Level
( p_dimension_level_short_name IN VARCHAR2
, x_dimension_short_name OUT NOCOPY VARCHAR2
, x_dimension_name OUT NOCOPY VARCHAR2
, x_dimension_level_name OUT NOCOPY VARCHAR2
, x_description OUT NOCOPY VARCHAR2
, x_hide        OUT NOCOPY VARCHAR2
, x_level_values_view_name OUT NOCOPY VARCHAR2
, x_where_clause OUT NOCOPY VARCHAR2
, x_source OUT NOCOPY VARCHAR2
, x_comparison_label_code OUT NOCOPY VARCHAR2
, x_attribute_code OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_default_search OUT NOCOPY VARCHAR2
, x_long_lov OUT NOCOPY VARCHAR2
, x_master_level OUT NOCOPY VARCHAR2
, x_view_object_name OUT NOCOPY VARCHAR2
, x_default_values_api OUT NOCOPY VARCHAR2
, x_enabled OUT NOCOPY VARCHAR2
, x_drill_to_form_function OUT NOCOPY VARCHAR2
, x_primary_dim OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_msg OUT NOCOPY VARCHAR2
) IS
    e_error EXCEPTION;
    h_api_version NUMBER;
    h_dimension_level_rec_in BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    h_dimension_level_rec_out BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    h_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

    h_dimension_level_rec_in.dimension_level_short_name := p_dimension_level_short_name;
    h_api_version := 1.0;

    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level(
      p_api_version          => h_api_version
     ,p_Dimension_Level_Rec  => h_dimension_level_rec_in
     ,x_Dimension_Level_Rec  => h_dimension_level_rec_out
     ,x_return_status        => x_return_status
     ,x_error_Tbl            => h_error_tbl
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_error;
    END IF;

    x_dimension_short_name := h_dimension_level_rec_out.dimension_short_name;
    x_dimension_name := h_dimension_level_rec_out.dimension_name;
    x_dimension_level_name := h_dimension_level_rec_out.dimension_level_name;
    x_description := h_dimension_level_rec_out.description;
    x_hide        := h_dimension_level_rec_out.hide;
    x_level_values_view_name := h_dimension_level_rec_out.level_values_view_name;
    x_where_clause := h_dimension_level_rec_out.where_clause;
    x_source := h_dimension_level_rec_out.source;
    x_comparison_label_code := h_dimension_level_rec_out.comparison_label_code;
    x_attribute_code := h_dimension_level_rec_out.attribute_code;
    x_application_id := h_dimension_level_rec_out.application_id;
    x_default_search := h_dimension_level_rec_out.default_search;
    x_long_lov := h_dimension_level_rec_out.long_lov;
    x_master_level := h_dimension_level_rec_out.master_level;
    x_view_object_name := h_dimension_level_rec_out.view_object_name;
    x_default_values_api := h_dimension_level_rec_out.default_values_api;
    x_enabled := h_dimension_level_rec_out.enabled;
    x_drill_to_form_function := h_dimension_level_rec_out.drill_to_form_function;
    x_primary_dim := h_dimension_level_rec_out.primary_dim;

EXCEPTION
    WHEN e_error THEN
        x_error_msg := h_error_tbl(1).Error_Description;
    WHEN others THEN
        x_error_msg := SQLERRM;
        x_return_status := FND_API.G_RET_STS_ERROR;
END Retrieve_Dimension_Level;


/*===========================================================================+
| PROCEDURE Retrieve_Measure
+============================================================================*/
PROCEDURE Retrieve_Measure
( p_measure_short_name IN VARCHAR2
, x_measure_name OUT NOCOPY VARCHAR2
, x_description OUT NOCOPY VARCHAR2
, x_region_app_id OUT NOCOPY NUMBER
, x_source_column_app_id OUT NOCOPY NUMBER
, x_compare_column_app_id OUT NOCOPY NUMBER
, x_actual_data_source_type OUT NOCOPY VARCHAR2
, x_actual_data_source OUT NOCOPY VARCHAR2
, x_function_name OUT NOCOPY VARCHAR2
, x_comparison_source OUT NOCOPY VARCHAR2
, x_increase_in_measure OUT NOCOPY VARCHAR2
, x_enable_link OUT NOCOPY VARCHAR2
, x_enabled OUT NOCOPY VARCHAR2
, x_obsolete OUT NOCOPY VARCHAR2
, x_measure_type OUT NOCOPY VARCHAR2
, x_dimension1_short_name OUT NOCOPY VARCHAR2
, x_dimension1_name OUT NOCOPY VARCHAR2
, x_dimension2_short_name OUT NOCOPY VARCHAR2
, x_dimension2_name OUT NOCOPY VARCHAR2
, x_dimension3_short_name OUT NOCOPY VARCHAR2
, x_dimension3_name OUT NOCOPY VARCHAR2
, x_dimension4_short_name OUT NOCOPY VARCHAR2
, x_dimension4_name OUT NOCOPY VARCHAR2
, x_dimension5_short_name OUT NOCOPY VARCHAR2
, x_dimension5_name OUT NOCOPY VARCHAR2
, x_dimension6_short_name OUT NOCOPY VARCHAR2
, x_dimension6_name OUT NOCOPY VARCHAR2
, x_dimension7_short_name OUT NOCOPY VARCHAR2
, x_dimension7_name OUT NOCOPY VARCHAR2
, x_unit_of_measure_class OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_is_validate OUT NOCOPY VARCHAR2
, x_func_area_short_name OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_msg OUT NOCOPY VARCHAR2
) IS
    e_error EXCEPTION;
    h_api_version NUMBER;
    h_all_info VARCHAR2(80);
    h_measure_rec_in BIS_MEASURE_PUB.Measure_Rec_Type;
    h_measure_rec_out BIS_MEASURE_PUB.Measure_Rec_Type;
    h_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

    h_measure_rec_in.measure_short_name := p_measure_short_name;
    h_api_version := 1.0;
    h_all_info := FND_API.G_TRUE;

    BIS_MEASURE_PUB.Retrieve_Measure(
              p_api_version => h_api_version
             , p_Measure_Rec => h_measure_rec_in
             , p_all_info => h_all_info
             , x_Measure_Rec => h_measure_rec_out
             , x_return_status => x_return_status
             , x_error_Tbl => h_error_tbl
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE e_error;
    END IF;

    x_measure_name := h_measure_rec_out.measure_name;
    x_description := h_measure_rec_out.description;
    x_region_app_id := h_measure_rec_out.region_app_id;
    x_source_column_app_id := h_measure_rec_out.source_column_app_id;
    x_compare_column_app_id := h_measure_rec_out.compare_column_app_id;
    x_actual_data_source_type := h_measure_rec_out.actual_data_source_type;
    x_actual_data_source := h_measure_rec_out.actual_data_source;
    x_function_name := h_measure_rec_out.function_name;
    x_comparison_source := h_measure_rec_out.comparison_source;
    x_increase_in_measure := h_measure_rec_out.increase_in_measure;
    x_enable_link := h_measure_rec_out.enable_link;
    x_enabled := h_measure_rec_out.enabled;
    x_obsolete := h_measure_rec_out.obsolete;
    x_measure_type := h_measure_rec_out.measure_type;
    x_dimension1_short_name := h_measure_rec_out.dimension1_short_name;
    x_dimension1_name := h_measure_rec_out.dimension1_name;
    x_dimension2_short_name := h_measure_rec_out.dimension2_short_name;
    x_dimension2_name := h_measure_rec_out.dimension2_name;
    x_dimension3_short_name := h_measure_rec_out.dimension3_short_name;
    x_dimension3_name := h_measure_rec_out.dimension3_name;
    x_dimension4_short_name := h_measure_rec_out.dimension4_short_name;
    x_dimension4_name := h_measure_rec_out.dimension4_name;
    x_dimension5_short_name := h_measure_rec_out.dimension5_short_name;
    x_dimension5_name := h_measure_rec_out.dimension5_name;
    x_dimension6_short_name := h_measure_rec_out.dimension6_short_name;
    x_dimension6_name := h_measure_rec_out.dimension6_name;
    x_dimension7_short_name := h_measure_rec_out.dimension7_short_name;
    x_dimension7_name := h_measure_rec_out.dimension7_name;
    x_unit_of_measure_class := h_measure_rec_out.unit_of_measure_class;
    x_application_id := h_measure_rec_out.application_id;
    x_is_validate := h_measure_rec_out.is_validate;
    x_func_area_short_name := h_measure_rec_out.func_area_short_name;

EXCEPTION
    WHEN e_error THEN
        x_error_msg := h_error_tbl(1).Error_Description;
    WHEN others THEN
        x_error_msg := SQLERRM;
        x_return_status := FND_API.G_RET_STS_ERROR;
END Retrieve_Measure;


-- ENH_B_TABLES_PERF: new function
/*===========================================================================+
| FUNCTION Get_RowId_Table_Name
+============================================================================*/
FUNCTION Get_RowId_Table_Name (
    x_table_name IN VARCHAR2
) RETURN VARCHAR2 IS
    h_list dbms_sql.varchar2_table;
    h_values dbms_sql.varchar2_table;
BEGIN
    h_list.delete;
    h_list(1) := BSC_DBGEN_STD_METADATA.BSC_I_ROWID_TABLE;
    h_values := BSC_DBGEN_METADATA_READER.Get_Table_Properties(x_table_name, h_list);
    RETURN h_values(1);
END Get_RowId_Table_Name;


-- ENH_B_TABLES_PERF: new function
/*===========================================================================+
| FUNCTION Get_Proj_Table_Name
+============================================================================*/
FUNCTION Get_Proj_Table_Name (
    x_table_name IN VARCHAR2
) RETURN VARCHAR2 IS
    h_list dbms_sql.varchar2_table;
    h_values dbms_sql.varchar2_table;
BEGIN
    h_list.delete;
    h_list(1) := BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE;
    h_values := BSC_DBGEN_METADATA_READER.Get_Table_Properties(x_table_name, h_list);
    RETURN h_values(1);
END Get_Proj_Table_Name;


-- ENH_B_TABLES_PERF: new function
/*===========================================================================+
| FUNCTION Get_Num_Partitions
+============================================================================*/
FUNCTION Get_Num_Partitions (
    x_table_name IN VARCHAR2
) RETURN NUMBER IS
    h_list dbms_sql.varchar2_table;
    h_values dbms_sql.varchar2_table;
BEGIN
    h_list.delete;
    h_list(1) := BSC_DBGEN_STD_METADATA.BSC_PARTITION;
    h_values := BSC_DBGEN_METADATA_READER.Get_Table_Properties(x_table_name, h_list);
    RETURN TO_NUMBER(h_values(1));
END Get_Num_Partitions;


-- ENH_B_TABLES_PERF: new function
/*===========================================================================+
| FUNCTION Migrate_BTable_With_Partitions
+============================================================================*/
FUNCTION Migrate_BTable_With_Partitions (
    x_base_table IN VARCHAR2,
    x_proj_table IN VARCHAR2
) RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    h_base_message VARCHAR2(4000);
    h_message VARCHAR2(4000);
    h_sql VARCHAR2(32000);

    h_table VARCHAR2(30);
    h_num_partitions NUMBER;
    h_max_partitions NUMBER;

    h_key_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_source_dim_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_key_columns NUMBER;

    h_i NUMBER;
    h_j NUMBER;
    h_level_table_name VARCHAR2(100);
    h_level_short_name VARCHAR2(300);
    h_level_source VARCHAR2(100);
    h_dbi_dim_data BSC_UPDATE_DIM.t_dbi_dim_data;

    CURSOR c_columns(p_table varchar2) IS
        SELECT column_name
        FROM all_tab_columns
        WHERE table_name = UPPER(p_table) AND
              owner = UPPER(BSC_APPS.BSC_APPS_SCHEMA);

    h_column VARCHAR2(50);
    h_batch_column VARCHAR2(50);
    h_lst_select VARCHAR2(32000);
    h_lst_insert VARCHAR2(32000);
    h_where_cond VARCHAR2(32000);

BEGIN

    h_base_message := BSC_APPS.Get_Message('BSC_MIG_DATA');

    h_max_partitions := bsc_dbgen_metadata_reader.get_max_partitions;
    h_num_partitions := Get_Num_Partitions(x_base_table);
    h_batch_column := UPPER(BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME);

    IF h_num_partitions <> h_max_partitions THEN
        h_num_key_columns := 0;
        IF NOT BSC_UPDATE_UTIL.Get_Information_Key_Columns(x_base_table,
                                                           h_key_columns,
                                                           h_key_dim_tables,
                                                           h_source_columns,
                                                           h_source_dim_tables,
                                                           h_num_key_columns) THEN
            RAISE e_unexpected_error;
        END IF;

        FOR h_i IN 1..h_num_key_columns LOOP
            -- Bug4769877
            -- BSC-BIS-DIMENSIONS: If the dimension is a BIS dimension we do not need to join
            -- to the dimension table because the code and user_code is the same. We
            -- do not need to translate code into user_code
            SELECT source
            INTO h_level_source
            FROM bsc_sys_dim_levels_b
            WHERE level_view_name = h_key_dim_tables(h_i);
            IF h_level_source = 'PMF' THEN
                h_key_dim_tables(h_i) := null;
            END IF;
        END LOOP;

        FOR h_i IN 1..2 LOOP
            IF h_i = 1 THEN
                h_table := x_base_table;
            ELSE
                h_table := x_proj_table;
            END IF;

            -- Bug4769877: review from here
            h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', h_table);
            BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

            h_lst_insert := null;
            h_lst_select := null;

            OPEN c_columns(h_table);
            LOOP
                FETCH c_columns INTO h_column;
                EXIT WHEN c_columns%NOTFOUND;

                IF h_lst_insert IS NOT NULL THEN
                    h_lst_insert := h_lst_insert||', ';
                    h_lst_select := h_lst_select||', ';
                END IF;
                h_lst_insert := h_lst_insert||h_column;

                IF h_column = h_batch_column THEN
                    IF h_num_key_columns > 0 AND h_max_partitions > 1 THEN
                        h_lst_select := h_lst_select||'dbms_utility.get_hash_value(';
                        FOR h_j IN 1..h_num_key_columns LOOP
                            IF h_j > 1 THEN
                                h_lst_select := h_lst_select||'||''.''||';
                            END IF;
                            IF h_key_dim_tables(h_j) IS NULL THEN
                                h_lst_select := h_lst_select||'b.'||h_key_columns(h_j);
                            ELSE
                                h_lst_select := h_lst_select||h_key_dim_tables(h_j)||'.USER_CODE';
                            END IF;
                        END LOOP;
                        h_lst_select := h_lst_select||', 0, '||h_max_partitions||')';
                    ELSE
                        h_lst_select := h_lst_select||'0';
                    END IF;
                ELSE
                    h_lst_select := h_lst_select||'b.'||h_column;
                END IF;
            END LOOP;
            CLOSE c_columns;

            h_sql := 'insert /*+ append parallel('||h_table||') */ into '||h_table||
                     ' ('||h_lst_insert||')'||
                     ' select /*+ parallel(b)';
            FOR h_j IN 1..h_num_key_columns LOOP
                IF h_key_dim_tables(h_j) IS NOT NULL THEN
                    h_sql := h_sql||' parallel('||h_key_dim_tables(h_j)||')';
                END IF;
            END LOOP;
            h_sql := h_sql||' */ '||h_lst_select||
                     ' from '||h_table||'@'||g_db_link||' b';
            FOR h_j IN 1..h_num_key_columns LOOP
                IF h_key_dim_tables(h_j) IS NOT NULL THEN
                    h_sql := h_sql||', '||h_key_dim_tables(h_j)||'@'||g_db_link;
                END IF;
            END LOOP;
            h_where_cond := null;
            FOR h_j IN 1..h_num_key_columns LOOP
               IF h_key_dim_tables(h_j) IS NOT NULL THEN
                   IF h_where_cond IS NULL THEN
                       h_where_cond := 'where ';
                   ELSE
                       h_where_cond := h_where_cond||' and ';
                   END IF;
                   h_where_cond := h_where_cond||'b.'||h_key_columns(h_j)||' = '||h_key_dim_tables(h_j)||'.CODE';
               END IF;
            END LOOP;
            IF h_where_cond IS NOT NULL THEN
                h_sql := h_sql||' '||h_where_cond;
            END IF;
            execute immediate h_sql;
            commit;
        END LOOP;

        -- Update the property PARTITIONS in BSC_DB_TABLES for this base table
        IF h_num_key_columns > 0 THEN
            bsc_dbgen_metadata_reader.set_table_property(x_base_table, BSC_DBGEN_STD_METADATA.BSC_PARTITION, h_max_partitions);
            commit;
        END IF;
    ELSE
        -- No difference in the number of partitions. So we can just insert from select, no need to fix batch column
        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', x_base_table);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        h_sql := 'INSERT /*+ append parallel('||x_base_table||') */ INTO '||x_base_table||
                 ' SELECT /*+ parallel('||x_base_table||') */ * FROM '||x_base_table||'@'||g_db_link;
        BSC_APPS.Execute_Immediate(h_sql);
        commit;

        h_message := BSC_APPS.Replace_Token(h_base_message, 'TABLE', x_proj_table);
        BSC_APPS.Write_Line_Log(h_message, BSC_APPS.OUTPUT_FILE);

        h_sql := 'INSERT /*+ append parallel('||x_proj_table||') */ INTO '||x_proj_table||
                 ' SELECT /*+ parallel('||x_proj_table||') */ * FROM '||x_proj_table||'@'||g_db_link;
        BSC_APPS.Execute_Immediate(h_sql);
        commit;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add (x_message => BSC_APPS.Get_Message('BSC_UNEXPECTED_ERROR'),
                         x_source => 'BSC_MIGRATION.Migrate_BTable_With_Partitions');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add (x_message => SQLERRM,
                         x_source => 'BSC_MIGRATION.Migrate_BTable_With_Partitions');
        RETURN FALSE;
END Migrate_BTable_With_Partitions;


-- Enh#4697749 New procedure
/*===========================================================================+
| FUNCTION Migrate_AK_Region
+============================================================================*/
FUNCTION Migrate_AK_Region(
    p_region_code IN VARCHAR2,
    x_error_msg OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    e_delete_ak_region_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_cursor1 t_cursor;
    h_sql VARCHAR2(32000);
    h_count NUMBER;
    h_return_status VARCHAR2(200);
    h_msg_count NUMBER;
    h_msg_data VARCHAR2(2000);

    h_rowid VARCHAR2(2000);
    h_region_application_id NUMBER;
    h_database_object_name VARCHAR2(30);
    h_name VARCHAR2(80);
    h_description VARCHAR2(2000);
    h_num_rows_display NUMBER;
    h_region_style VARCHAR2(30);
    h_region_object_type VARCHAR2(240);
    h_isform_flag VARCHAR2(1);
    h_attribute_category VARCHAR2(30);
    h_attribute1 VARCHAR2(150);
    h_attribute2 VARCHAR2(150);
    h_attribute3 VARCHAR2(150);
    h_attribute4 VARCHAR2(150);
    h_attribute5 VARCHAR2(150);
    h_attribute6 VARCHAR2(150);
    h_attribute7 VARCHAR2(150);
    h_attribute8 VARCHAR2(150);
    h_attribute9 VARCHAR2(150);
    h_attribute10 VARCHAR2(150);
    h_attribute11 VARCHAR2(150);
    h_attribute12 VARCHAR2(150);
    h_attribute13 VARCHAR2(150);
    h_attribute14 VARCHAR2(150);
    h_attribute15 VARCHAR2(150);
    h_attribute16 VARCHAR2(150);
    h_attribute17 VARCHAR2(150);
    h_attribute18 VARCHAR2(150);
    h_attribute19 VARCHAR2(150);
    h_attribute20 VARCHAR2(150);
    h_attribute21 VARCHAR2(150);
    h_attribute22 VARCHAR2(150);
    h_attribute23 VARCHAR2(150);
    h_attribute24 VARCHAR2(150);
    h_attribute25 VARCHAR2(150);
    h_attribute26 VARCHAR2(150);
    h_attribute27 VARCHAR2(150);
    h_attribute28 VARCHAR2(150);
    h_attribute29 VARCHAR2(150);
    h_attribute30 VARCHAR2(150);
    h_attribute31 VARCHAR2(150);
    h_attribute32 VARCHAR2(150);
    h_attribute33 VARCHAR2(150);
    h_attribute34 VARCHAR2(150);
    h_attribute35 VARCHAR2(150);
    h_attribute36 VARCHAR2(150);
    h_attribute37 VARCHAR2(150);
    h_attribute38 VARCHAR2(150);
    h_attribute39 VARCHAR2(150);
    h_attribute40 VARCHAR2(150);
    h_created_by NUMBER;

    h_attribute_application_id NUMBER;
    h_attribute_code VARCHAR2(30);
    h_display_sequence NUMBER;
    h_node_display_flag VARCHAR2(1);
    h_node_query_flag VARCHAR2(1);
    h_attribute_label_long VARCHAR2(80);
    h_attribute_label_length NUMBER;
    h_display_value_length NUMBER;
    h_item_style VARCHAR2(30);
    h_required_flag VARCHAR2(1);
    h_nested_region_code VARCHAR2(30);
    h_nested_region_application_id NUMBER;
    h_url VARCHAR2(2000);
    h_order_sequence NUMBER;
    h_order_direction VARCHAR2(30);

BEGIN
    IF Item_Belong_To_Array_Varchar2(p_region_code, g_migrated_ak_regions, g_num_migrated_ak_regions) THEN
        -- This ak region was migrated before during htis process. No need to migrate it again
        RETURN TRUE;
    END IF;

    h_sql := 'SELECT region_application_id, database_object_name, name,'||
             ' description, num_rows_display, region_style, region_object_type,'||
             ' isform_flag, attribute_category, attribute1, attribute2, attribute3,'||
             ' attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,'||
             ' attribute10, attribute11, attribute12, attribute13, attribute14,'||
             ' attribute15, created_by'||
             ' FROM ak_regions_vl@'||g_db_link||
             ' WHERE region_code = :1';
    OPEN h_cursor FOR h_sql USING p_region_code;
    FETCH h_cursor INTO h_region_application_id, h_database_object_name, h_name,
             h_description, h_num_rows_display, h_region_style, h_region_object_type,
             h_isform_flag, h_attribute_category, h_attribute1, h_attribute2, h_attribute3,
             h_attribute4, h_attribute5, h_attribute6, h_attribute7, h_attribute8, h_attribute9,
             h_attribute10, h_attribute11, h_attribute12, h_attribute13, h_attribute14,
             h_attribute15, h_created_by;
    IF h_cursor%NOTFOUND THEN
        -- The ak region does not exists in the source system
        CLOSE h_cursor;
        g_num_migrated_ak_regions := g_num_migrated_ak_regions + 1;
        g_migrated_ak_regions(g_num_migrated_ak_regions) := p_region_code;
        RETURN TRUE;
    END IF;
    CLOSE h_cursor;

    --bug 5099776
    IF (h_created_by = 1) OR (h_created_by = 2) or (h_created_by = 120) or (h_created_by = 121)THEN
        -- The ak region is pre-seeded. We cannot create a pre-seeded ak region in the target
        g_num_migrated_ak_regions := g_num_migrated_ak_regions + 1;
        g_migrated_ak_regions(g_num_migrated_ak_regions) := p_region_code;
        RETURN TRUE;
    END IF;

    -- Check if the ak region exists on the target
    h_count := 0;
    select count(region_code) into h_count
    from ak_regions
    where region_application_id = h_region_application_id and
          region_code = p_region_code;

    IF h_count > 0 THEN
        -- Delete ak region from target.
        BIS_AK_REGION_PUB.DELETE_REGION_AND_REGION_ITEMS(
             p_REGION_CODE => p_region_code
            ,p_REGION_APPLICATION_ID => h_region_application_id
            ,x_return_status => h_return_status
            ,x_msg_count => h_msg_count
            ,x_msg_data => h_msg_data
        );

        IF (h_return_status IS NOT NULL) AND (h_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE e_delete_ak_region_error;
        END IF;
    END IF;

    -- Create the ak region in the target
    BIS_AK_REGION_PUB.INSERT_REGION_ROW (
        X_ROWID => h_rowid,
        X_USER_ID => fnd_global.user_id,
        X_REGION_APPLICATION_ID => h_region_application_id,
        X_REGION_CODE => p_region_code,
        X_DATABASE_OBJECT_NAME => h_database_object_name,
        X_NAME => h_name,
        X_DESCRIPTION => h_description,
        X_NUM_ROWS_DISPLAY => h_num_rows_display,
        X_REGION_STYLE => h_region_style,
        X_REGION_OBJECT_TYPE => h_region_object_type,
        X_ISFORM_FLAG => h_isform_flag,
        X_ATTRIBUTE_CATEGORY => h_attribute_category,
        X_ATTRIBUTE1 => h_attribute1,
        X_ATTRIBUTE2 => h_attribute2,
        X_ATTRIBUTE3 => h_attribute3,
        X_ATTRIBUTE4 => h_attribute4,
        X_ATTRIBUTE5 => h_attribute5,
        X_ATTRIBUTE6 => h_attribute6,
        X_ATTRIBUTE7 => h_attribute7,
        X_ATTRIBUTE8 => h_attribute8,
        X_ATTRIBUTE9 => h_attribute9,
        X_ATTRIBUTE10 => h_attribute10,
        X_ATTRIBUTE11 => h_attribute11,
        X_ATTRIBUTE12 => h_attribute12,
        X_ATTRIBUTE13 => h_attribute13,
        X_ATTRIBUTE14 => h_attribute14,
        X_ATTRIBUTE15 => h_attribute15
    );

    -- Create ak region extension
    h_sql := 'select attribute16, attribute17, attribute18, attribute19, attribute20, attribute21,'||
             ' attribute22, attribute23, attribute24, attribute25, attribute26, attribute27,'||
             ' attribute28, attribute29, attribute30, attribute31, attribute32, attribute33,'||
             ' attribute34, attribute35, attribute36, attribute37, attribute38, attribute39,'||
             ' attribute40'||
             ' from bis_ak_region_extension@'||g_db_link||
             ' where region_code = :1 and region_application_id = :2';
    OPEN h_cursor FOR h_sql USING p_region_code, h_region_application_id;
    FETCH h_cursor INTO h_attribute16, h_attribute17, h_attribute18, h_attribute19, h_attribute20, h_attribute21,
             h_attribute22, h_attribute23, h_attribute24, h_attribute25, h_attribute26, h_attribute27,
             h_attribute28, h_attribute29, h_attribute30, h_attribute31, h_attribute32, h_attribute33,
             h_attribute34, h_attribute35, h_attribute36, h_attribute37, h_attribute38, h_attribute39,
             h_attribute40;
    IF h_cursor%FOUND THEN
        BIS_REGION_EXTENSION_PVT.CREATE_REGION_EXTN_RECORD(
            p_commit => FND_API.G_FALSE
           ,pRegionCode => p_region_code
           ,pRegionAppId => h_region_application_id
           ,pAttribute16 => h_attribute16
           ,pAttribute17 => h_attribute17
           ,pAttribute18 => h_attribute18
           ,pAttribute19 => h_attribute19
           ,pAttribute20 => h_attribute20
           ,pAttribute21 => h_attribute21
           ,pAttribute22 => h_attribute22
           ,pAttribute23 => h_attribute23
           ,pAttribute24 => h_attribute24
           ,pAttribute25 => h_attribute25
           ,pAttribute26 => h_attribute26
           ,pAttribute27 => h_attribute27
           ,pAttribute28 => h_attribute28
           ,pAttribute29 => h_attribute29
           ,pAttribute30 => h_attribute30
           ,pAttribute31 => h_attribute31
           ,pAttribute32 => h_attribute32
           ,pAttribute33 => h_attribute33
           ,pAttribute34 => h_attribute34
           ,pAttribute35 => h_attribute35
           ,pAttribute36 => h_attribute36
           ,pAttribute37 => h_attribute37
           ,pAttribute38 => h_attribute38
           ,pAttribute39 => h_attribute39
           ,pAttribute40 => h_attribute40
        );
    END IF;
    CLOSE h_cursor;

    -- Migrate ak region items
    h_sql := 'select attribute_application_id, attribute_code, display_sequence, node_display_flag,'||
             ' node_query_flag, attribute_label_long, attribute_label_length, display_value_length,'||
             ' item_style, required_flag, nested_region_code, nested_region_application_id,'||
             ' attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5,'||
             ' attribute6, attribute7, attribute8, attribute9, attribute10, attribute11, attribute12,'||
             ' attribute13, attribute14, attribute15, url, order_sequence, order_direction'||
             ' from ak_region_items_vl@'||g_db_link||
             ' where region_code = :1 and region_application_id = :2';
    OPEN h_cursor FOR h_sql USING p_region_code, h_region_application_id;
    LOOP
        FETCH h_cursor INTO h_attribute_application_id, h_attribute_code, h_display_sequence, h_node_display_flag,
             h_node_query_flag, h_attribute_label_long, h_attribute_label_length, h_display_value_length,
             h_item_style, h_required_flag, h_nested_region_code, h_nested_region_application_id,
             h_attribute_category, h_attribute1, h_attribute2, h_attribute3, h_attribute4, h_attribute5,
             h_attribute6, h_attribute7, h_attribute8, h_attribute9, h_attribute10, h_attribute11, h_attribute12,
             h_attribute13, h_attribute14, h_attribute15, h_url, h_order_sequence, h_order_direction;

        EXIT WHEN h_cursor%NOTFOUND;

        BIS_AK_REGION_PUB.INSERT_REGION_ITEM_ROW (
            X_ROWID => h_rowid,
            X_USER_ID => fnd_global.user_id,
            X_REGION_APPLICATION_ID => h_region_application_id,
            X_REGION_CODE => p_region_code,
            X_ATTRIBUTE_APPLICATION_ID => h_attribute_application_id,
            X_ATTRIBUTE_CODE => h_attribute_code,
            X_DISPLAY_SEQUENCE => h_display_sequence,
            X_NODE_DISPLAY_FLAG => h_node_display_flag,
            X_NODE_QUERY_FLAG => h_node_query_flag,
            X_ATTRIBUTE_LABEL_LONG => h_attribute_label_long,
            X_ATTRIBUTE_LABEL_LENGTH => h_attribute_label_length,
            X_DISPLAY_VALUE_LENGTH => h_display_value_length,
            X_ITEM_STYLE => h_item_style,
            X_REQUIRED_FLAG => h_required_flag,
            X_NESTED_REGION_CODE => h_nested_region_code,
            X_NESTED_REGION_APPL_ID => h_nested_region_application_id,
            X_ATTRIBUTE_CATEGORY => h_attribute_category,
            X_ATTRIBUTE1 => h_attribute1,
            X_ATTRIBUTE2 => h_attribute2,
            X_ATTRIBUTE3 => h_attribute3,
            X_ATTRIBUTE4 => h_attribute4,
            X_ATTRIBUTE5 => h_attribute5,
            X_ATTRIBUTE6 => h_attribute6,
            X_ATTRIBUTE7 => h_attribute7,
            X_ATTRIBUTE8 => h_attribute8,
            X_ATTRIBUTE9 => h_attribute9,
            X_ATTRIBUTE10 => h_attribute10,
            X_ATTRIBUTE11 => h_attribute11,
            X_ATTRIBUTE12 => h_attribute12,
            X_ATTRIBUTE13 => h_attribute13,
            X_ATTRIBUTE14 => h_attribute14,
            X_ATTRIBUTE15 => h_attribute15,
            X_URL => h_url,
            X_ORDER_SEQUENCE => h_order_sequence,
            X_ORDER_DIRECTION => h_order_direction
        );

        -- migrate region items extensions
        h_sql := 'SELECT attribute16, attribute17, attribute18, attribute19, attribute20, attribute21,'||
                 ' attribute22, attribute23, attribute24, attribute25, attribute26, attribute27,'||
                 ' attribute28, attribute29, attribute30, attribute31, attribute32, attribute33,'||
                 ' attribute34, attribute35, attribute36, attribute37, attribute38, attribute39,'||
                 ' attribute40'||
                 ' from bis_ak_region_item_extension@'||g_db_link||
                 ' where region_code = :1 and region_application_id = :2 and'||
                 ' attribute_code = :3 and attribute_application_id = :4';
        OPEN h_cursor1 FOR h_sql USING p_region_code, h_region_application_id, h_attribute_code, h_attribute_application_id;
        FETCH h_cursor1 INTO h_attribute16, h_attribute17, h_attribute18, h_attribute19, h_attribute20, h_attribute21,
             h_attribute22, h_attribute23, h_attribute24, h_attribute25, h_attribute26, h_attribute27,
             h_attribute28, h_attribute29, h_attribute30, h_attribute31, h_attribute32, h_attribute33,
             h_attribute34, h_attribute35, h_attribute36, h_attribute37, h_attribute38, h_attribute39,
             h_attribute40;
        IF h_cursor1%FOUND THEN
            BIS_REGION_ITEM_EXTENSION_PVT.CREATE_REGION_ITEM_RECORD(
                pRegionCode => p_region_code
               ,pRegionAppId => h_region_application_id
               ,pAttributeCode => h_attribute_code
               ,pAttributeAppId => h_attribute_application_id
               ,pAttribute16 => h_attribute16
               ,pAttribute17 => h_attribute17
               ,pAttribute18 => h_attribute18
               ,pAttribute19 => h_attribute19
               ,pAttribute20 => h_attribute20
               ,pAttribute21 => h_attribute21
               ,pAttribute22 => h_attribute22
               ,pAttribute23 => h_attribute23
               ,pAttribute24 => h_attribute24
               ,pAttribute25 => h_attribute25
               ,pAttribute26 => h_attribute26
               ,pAttribute27 => h_attribute27
               ,pAttribute28 => h_attribute28
               ,pAttribute29 => h_attribute29
               ,pAttribute30 => h_attribute30
               ,pAttribute31 => h_attribute31
               ,pAttribute32 => h_attribute32
               ,pAttribute33 => h_attribute33
               ,pAttribute34 => h_attribute34
               ,pAttribute35 => h_attribute35
               ,pAttribute36 => h_attribute36
               ,pAttribute37 => h_attribute37
               ,pAttribute38 => h_attribute38
               ,pAttribute39 => h_attribute39
               ,pAttribute40 => h_attribute40
               ,pCommit => 'N'
            );
        END IF;
        CLOSE h_cursor1;
    END LOOP;
    CLOSE h_cursor;

    g_num_migrated_ak_regions := g_num_migrated_ak_regions + 1;
    g_migrated_ak_regions(g_num_migrated_ak_regions) := p_region_code;

    commit;
    RETURN TRUE;

EXCEPTION
    WHEN e_delete_ak_region_error THEN
        rollback;
        x_error_msg :=  h_msg_data;
        RETURN FALSE;
    WHEN OTHERS THEN
        rollback;
        x_error_msg := SQLERRM;
        RETURN FALSE;
END Migrate_AK_Region;


-- Enh#4697749 New procedure
/*===========================================================================+
| FUNCTION Migrate_Form_Function
+============================================================================*/
FUNCTION Migrate_Form_Function(
    p_function_name IN VARCHAR2,
    x_error_msg OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_sql VARCHAR2(32000);
    h_count NUMBER;

    CURSOR c_function_id IS
        SELECT function_id
        FROM fnd_form_functions
        WHERE function_name = p_function_name;

    h_rowid VARCHAR2(2000);
    h_function_id NUMBER;
    h_web_host_name VARCHAR2(80);
    h_web_agent_name VARCHAR2(80);
    h_web_html_call VARCHAR2(240);
    h_web_encrypt_parameters VARCHAR2(1);
    h_web_secured VARCHAR2(1);
    h_web_icon VARCHAR2(30);
    h_object_id NUMBER;
    h_region_application_id NUMBER;
    h_region_code VARCHAR2(30);
    h_application_id NUMBER;
    h_form_id NUMBER;
    h_parameters VARCHAR2(2000);
    h_type VARCHAR2(30);
    h_user_function_name VARCHAR2(80);
    h_description VARCHAR2(240);
    h_maintenance_mode_support VARCHAR2(8);
    h_context_dependence VARCHAR2(8);
    h_jrad_ref_path VARCHAR2(1000);
    h_created_by NUMBER;

BEGIN
    IF Item_Belong_To_Array_Varchar2(p_function_name, g_migrated_functions, g_num_migrated_functions) THEN
        -- This form function was migrated before during this process. No need to migrate it again
        RETURN TRUE;
    END IF;

    h_sql := 'SELECT web_host_name, web_agent_name, web_html_call, web_encrypt_parameters,'||
             ' web_secured, web_icon, object_id, region_application_id, region_code,'||
             ' application_id, form_id, parameters, type, user_function_name,'||
             ' description, maintenance_mode_support, context_dependence, jrad_ref_path,'||
             ' created_by'||
             ' FROM fnd_form_functions_vl@'||g_db_link||
             ' WHERE function_name = :1';
    OPEN h_cursor FOR h_sql USING p_function_name;
    FETCH h_cursor INTO h_web_host_name, h_web_agent_name, h_web_html_call, h_web_encrypt_parameters,
             h_web_secured, h_web_icon, h_object_id, h_region_application_id, h_region_code,
             h_application_id, h_form_id, h_parameters, h_type, h_user_function_name,
             h_description, h_maintenance_mode_support, h_context_dependence, h_jrad_ref_path,
             h_created_by;
    IF h_cursor%NOTFOUND THEN
        -- The form function does not exists in the source system
        CLOSE h_cursor;
        g_num_migrated_functions := g_num_migrated_functions + 1;
        g_migrated_functions(g_num_migrated_functions) := p_function_name;
        RETURN TRUE;
    END IF;
    CLOSE h_cursor;
    -- bug 5099776
    IF (h_created_by = 1) OR (h_created_by = 2) or (h_created_by = 120) or (h_created_by = 121) THEN
        -- The form function is pre-seeded. We cannot create a pre-seeded form function in the target
        g_num_migrated_functions := g_num_migrated_functions + 1;
        g_migrated_functions(g_num_migrated_functions) := p_function_name;
        RETURN TRUE;
    END IF;

    -- Check if the form function exists on the target
    OPEN c_function_id;
    FETCH c_function_id INTO h_function_id;
    IF c_function_id%FOUND THEN
        -- Delete the form function from the target
        FND_FORM_FUNCTIONS_PKG.DELETE_ROW(X_FUNCTION_ID => h_function_id);
    END IF;
    CLOSE c_function_id;

    -- Create the form function in the target
    SELECT fnd_form_functions_s.nextval INTO h_function_id FROM DUAL;

    FND_FORM_FUNCTIONS_PKG.INSERT_ROW (
        X_ROWID => h_rowid,
        X_FUNCTION_ID => h_function_id,
        X_WEB_HOST_NAME => h_web_host_name,
        X_WEB_AGENT_NAME => h_web_agent_name,
        X_WEB_HTML_CALL => h_web_html_call,
        X_WEB_ENCRYPT_PARAMETERS => h_web_encrypt_parameters,
        X_WEB_SECURED => h_web_secured,
        X_WEB_ICON => h_web_icon,
        X_OBJECT_ID => h_object_id,
        X_REGION_APPLICATION_ID => h_region_application_id,
        X_REGION_CODE => h_region_code,
        X_FUNCTION_NAME => p_function_name,
        X_APPLICATION_ID => h_application_id,
        X_FORM_ID => h_form_id,
        X_PARAMETERS => h_parameters,
        X_TYPE => h_type,
        X_USER_FUNCTION_NAME => h_user_function_name,
        X_DESCRIPTION => h_description,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_MAINTENANCE_MODE_SUPPORT => h_maintenance_mode_support,
        X_CONTEXT_DEPENDENCE => h_context_dependence,
        X_JRAD_REF_PATH => h_jrad_ref_path
    );

    g_num_migrated_functions := g_num_migrated_functions + 1;
    g_migrated_functions(g_num_migrated_functions) := p_function_name;

    commit;
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        x_error_msg := SQLERRM;
        RETURN FALSE;
END Migrate_Form_Function;


-- Fix bug#4873385
/*===========================================================================+
| FUNCTION Get_Source_User_Id
+============================================================================*/
FUNCTION Get_Source_User_Id RETURN NUMBER IS
    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    h_sql VARCHAR2(32000);
    h_source_user_id NUMBER;
    h_def_user VARCHAR2(200);
BEGIN
    --Fix bug#4873385 if the user BSC_APPS.apps_user_id does not exists in the source system
    -- then we lock the source system with the user ANONYMOUS
    h_def_user := 'ANONYMOUS';

    h_sql := 'select s.user_id'||
             ' from fnd_user@'||g_db_link||' s, fnd_user t'||
             ' where t.user_name = s.user_name and t.user_id = :1';
    OPEN h_cursor FOR h_sql USING BSC_APPS.apps_user_id;
    FETCH h_cursor INTO h_source_user_id;
    IF h_cursor%NOTFOUND THEN
        h_source_user_id := NULL;
    END IF;
    CLOSE h_cursor;

    IF h_source_user_id IS NULL THEN
        h_sql := 'select user_id'||
                 ' from fnd_user@'||g_db_link||
                 ' where user_name = :1';
        OPEN h_cursor FOR h_sql USING h_def_user;
        FETCH h_cursor INTO h_source_user_id;
        IF h_cursor%NOTFOUND THEN
            h_source_user_id := 0;
        END IF;
        CLOSE h_cursor;
    END IF;

    RETURN h_source_user_id;

END Get_Source_User_Id;

/************************************************************************************
--	API name 	: Update_AK_Item_Props
--	Type		: Private
--	Function	:
************************************************************************************/

PROCEDURE Update_AK_Item_Props (
   p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
  ,p_region_code              IN    VARCHAR2
  ,p_region_application_id    IN    NUMBER
  ,p_Attribute_Code           IN    AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
  ,p_Attribute_Application_Id IN    AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
  ,p_Attribute2               IN    AK_REGION_ITEMS.ATTRIBUTE2%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS

 l_Ak_Region_Item_Rec BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscUpdAKItemProps;
  BIS_AK_REGION_PUB.Get_Region_Item_Rec (
    p_region_code              =>  p_region_code
   ,p_region_application_id    =>  p_region_application_id
   ,p_Attribute_Code           =>  p_Attribute_Code
   ,p_Attribute_Application_Id =>  p_Attribute_Application_Id
   ,x_Region_Item_Rec          =>  l_Ak_Region_Item_Rec
   ,x_return_status            =>  x_return_status
   ,x_msg_count                =>  x_msg_count
   ,x_msg_data                 =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_Ak_Region_Item_Rec.Measure_Level := p_Attribute2;

  BIS_AK_REGION_PUB.Update_Region_Item_Row (
    p_region_code              =>  p_region_code
   ,p_region_application_id    =>  p_region_application_id
   ,p_Region_Item_Rec          =>  l_Ak_Region_Item_Rec
   ,x_return_status            =>  x_return_status
   ,x_msg_count                =>  x_msg_count
   ,x_msg_data                 =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO BscUpdAKItemProps;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO BscUpdAKItemProps;
      FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
     ROLLBACK TO BscUpdAKItemProps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Update_AK_Item_Props';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Update_AK_Item_Props ';
     END IF;
  WHEN OTHERS THEN
     ROLLBACK TO BscUpdAKItemProps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Update_AK_Item_Props ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Update_AK_Item_Props ';
     END IF;
END Update_AK_Item_Props;

/************************************************************************************
--	API name 	: Synchronize_AK_BSC_Metadata
--	Type		: Private
--	Function	:
--      1. Synchronizes attribute2, attribute_label_long of measures
--      2. Synchronizes attribute2, attribute_label_long of dimension objects
--      3. Synchronizes attribute2, attribute_label_long of periodicities
************************************************************************************/


PROCEDURE Synchronize_AK_BSC_Metadata (
   p_commit             IN    VARCHAR2 := FND_API.G_FALSE
  ,p_Trg_indicator      IN    BSC_KPIS_B.indicator%TYPE
  ,p_Src_indicator      IN    BSC_KPIS_B.indicator%TYPE
  ,p_short_name         IN    BSC_KPIS_B.short_name%TYPE
  ,p_Old_Dim_Levels     IN    FND_TABLE_OF_NUMBER
  ,p_New_Dim_Levels     IN    FND_TABLE_OF_NUMBER
  ,p_Old_Dim_Groups     IN    FND_TABLE_OF_NUMBER
  ,p_New_Dim_Groups     IN    FND_TABLE_OF_NUMBER
  ,p_Old_DataSet_Map    IN    FND_TABLE_OF_NUMBER
  ,p_New_DataSet_Map    IN    FND_TABLE_OF_NUMBER
  ,p_Target_Calendar    IN    NUMBER
  ,p_Old_Periodicities  IN    FND_TABLE_OF_NUMBER
  ,p_New_Periodicities  IN    FND_TABLE_OF_NUMBER
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS
  l_Id NUMBER;

  l_Calendar_Sht_Name bsc_sys_calendars_b.short_name%TYPE;
  l_Dim_Group_Id      bsc_sys_dim_groups_vl.dim_group_Id%TYPE;
  l_Dim_Lev_Sht_Name  bsc_sys_dim_levels_vl.short_name%TYPE;
  l_Dim_Short_Name    bsc_sys_dim_groups_vl.short_name%TYPE;
  l_Old_Default_Node  bsc_kpi_properties.property_value%TYPE ;

  l_Attribute2        ak_region_items.attribute2%TYPE;
  l_Item_Att_App_Id   ak_region_items.attribute_application_id%TYPE;
  l_Item_Att_Code     ak_region_items.attribute_code%TYPE;
  l_New_Attribute2    ak_region_items.attribute2%TYPE;
  l_Region_Att_Id     ak_region_items.region_application_id%TYPE;
  l_Attribute_Code_Tbl    BISVIEWER.t_char ;
  l_Attribute_App_Id_Tbl  BISVIEWER.t_num ;
  l_Region_Code       ak_region_items.region_code%TYPE;
  l_Retain_Dim_Att2   BIS_STRING_ARRAY;
  l_Actual_Data_Source bis_indicators.actual_data_source%TYPE;
  l_sql               VARCHAR2(32000);
  l_Periodicity_Sht_Name bsc_sys_periodicities.short_name%TYPE;
  l_Comparison_Source bis_indicators.comparison_source%TYPE;
  l_Enable_Link bis_indicators.enable_link%TYPE;
  TYPE c_cur_type IS REF CURSOR;
  c_cursor c_cur_type;

  CURSOR c_Default_Node IS
  SELECT
    property_value
  FROM
    bsc_kpi_properties
  WHERE
    indicator = p_Trg_indicator AND
    property_code = 'S_NODE_ID';

BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscSyncAKBscMetadata;
  -- DataSet Sync Up
  l_sql := 'SELECT ak_item.region_code,ak_item.region_application_id,ak_item.attribute_code,ak_item.attribute_application_id, i.comparison_source,i.enable_link, ';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('ak_item.attribute2,i.dataset_id from ak_region_items');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('ak_item, bis_indicators');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('i,bsc_kpis_b');
  l_sql := l_sql || ' k  WHERE ak_item.region_code = k.short_name and ak_item.attribute1 = :1 and i.short_name = ak_item.attribute2';
  l_sql := l_sql || ' AND k.indicator = :2';

  OPEN c_Default_Node;
  FETCH c_Default_Node INTO l_Old_Default_Node;
  CLOSE c_Default_Node;

  OPEN c_cursor FOR l_sql USING 'MEASURE_NOTARGET',p_Src_indicator;
  LOOP
    FETCH c_cursor INTO l_Region_Code,l_Region_Att_Id,l_Item_Att_Code,l_Item_Att_App_Id, l_Comparison_Source,l_Enable_Link,l_Attribute2,l_Id;
    EXIT WHEN c_cursor%NOTFOUND;
    FOR i IN 1..p_Old_DataSet_Map.COUNT LOOP
      IF p_Old_DataSet_Map(i) = l_Id THEN

        SELECT
          short_name,actual_data_source
        INTO
          l_New_Attribute2,l_Actual_Data_Source
        FROM
          bis_indicators
        WHERE
          dataset_id = p_New_DataSet_Map(i);

        IF l_Actual_Data_Source IS NULL THEN
          UPDATE
            bis_indicators
          SET
            actual_data_source = p_short_name || '.' || l_Item_Att_Code,
            function_name = p_short_name,
            actual_data_source_type = 'AK',
            comparison_source = DECODE(l_Comparison_Source,NULL,NULL,p_short_name || '.' || l_Item_Att_Code || '_B'),
            enable_link = l_Enable_Link
          WHERE
            short_name = l_New_Attribute2;
        END IF;

        IF l_New_Attribute2 <> l_Attribute2 OR p_New_DataSet_Map(i) <> p_Old_DataSet_Map(i) THEN
          Update_AK_Item_Props (
             p_commit                => FND_API.G_FALSE
	    ,p_region_code           => p_short_name
	    ,p_region_application_id => l_Region_Att_Id
	    ,p_Attribute_Code        => l_Item_Att_Code
	    ,p_Attribute_Application_Id => l_Item_Att_App_Id
	    ,p_Attribute2            => l_New_Attribute2
	    ,x_return_status         => x_return_status
	    ,x_msg_count             => x_msg_count
	    ,x_msg_data              => x_msg_data
	  );
	  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  UPDATE
	    ak_region_items_tl ak_item
	  SET
	    attribute_label_long = (SELECT
	                              d.name
	                            FROM
	                              bsc_sys_datasets_tl d
	                            WHERE
	                              d.dataset_id = p_New_DataSet_Map(i) AND
	                              d.language = ak_item.language)
	  WHERE
	    ak_item.region_code = p_short_name AND
	    ak_item.region_application_id = l_Region_Att_Id AND
	    ak_item.attribute_code = l_Item_Att_Code AND
	    ak_item.attribute_application_id = l_Item_Att_App_Id;

	  UPDATE
	    bsc_kpi_tree_nodes_b
	  SET
	    node_id = p_New_DataSet_Map(i)
	  WHERE
	    indicator = p_Trg_indicator AND
	    node_id = p_Old_DataSet_Map(i);

	  UPDATE
	    bsc_kpi_tree_nodes_tl tr
	  SET
	    node_id = p_New_DataSet_Map(i),
            name = (SELECT
	                d.name
	            FROM
	              bsc_sys_datasets_tl d
	            WHERE
	              d.dataset_id = p_New_DataSet_Map(i) AND
	              (d.language = tr.language OR
		      d.language = tr.language)),
            help = (SELECT
	                d.help
	            FROM
	              bsc_sys_datasets_tl d
	            WHERE
	              d.dataset_id = p_New_DataSet_Map(i) AND
	              (d.language = tr.language OR
		      d.language = tr.language))
	  WHERE
	    indicator = p_Trg_indicator AND
	    node_id = p_Old_DataSet_Map(i);

	  UPDATE
	    bsc_tab_view_labels_b
	  SET
	    link_id = p_New_DataSet_Map(i)
	  WHERE
	    tab_view_id = p_Trg_indicator AND
	    tab_id = -999 AND
	    link_id = p_Old_DataSet_Map(i);

	  IF l_Old_Default_Node IS NOT NULL AND l_Old_Default_Node = p_Old_DataSet_Map(i) THEN
	    UPDATE
	      bsc_kpi_properties
	    SET
	      property_value = p_New_DataSet_Map(i)
	    WHERE
	      indicator = p_Trg_indicator AND
	      property_code = 'S_NODE_ID';
	  END IF;

        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  CLOSE c_cursor;

  --Periods Sync Up
  l_sql := 'SELECT ak_item.region_code,ak_item.region_application_id,ak_item.attribute_code,ak_item.attribute_application_id,ak_item.attribute2,';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' p.periodicity_id FROM ak_region_items');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' ak_item,bsc_kpis_b');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' k,bsc_sys_periodicities');
  l_sql := l_sql || ' p WHERE ak_item.region_code = k.short_name and ak_item.attribute1 = :1 and ak_item.attribute2 LIKE :2';
  l_sql := l_sql || ' AND ak_item.attribute2 NOT LIKE :3 AND SUBSTR(ak_item.attribute2,INSTR(ak_item.attribute2,''+'') +1) = p.short_name';
  l_sql := l_sql || ' AND k.indicator = :4';

  SELECT
    short_name
  INTO
    l_Calendar_Sht_Name
  FROM
    bsc_sys_calendars_b
  WHERE
    calendar_id = p_Target_Calendar;

  l_Retain_Dim_Att2 := BIS_STRING_ARRAY();
  OPEN c_cursor FOR l_sql USING 'DIMENSION LEVEL','%+%','TIME_COMPARISON_TYPE+BUDGET',p_Src_indicator;
  LOOP
    FETCH c_cursor INTO l_Region_Code,l_Region_Att_Id,l_Item_Att_Code,l_Item_Att_App_Id,l_Attribute2,l_Id;
    EXIT WHEN c_cursor%NOTFOUND;
    FOR i IN 1..p_Old_Periodicities.COUNT LOOP
      IF p_Old_Periodicities(i) = l_Id THEN
        SELECT
          short_name
        INTO
          l_Periodicity_Sht_Name
        FROM
          bsc_sys_periodicities
        WHERE
          periodicity_id = p_New_Periodicities(i);

        l_New_Attribute2 := l_Calendar_Sht_Name || '+' || l_Periodicity_Sht_Name;
          Update_AK_Item_Props (
             p_commit                => FND_API.G_FALSE
	    ,p_region_code           => p_short_name
	    ,p_region_application_id => l_Region_Att_Id
	    ,p_Attribute_Code        => l_Item_Att_Code
	    ,p_Attribute_Application_Id => l_Item_Att_App_Id
	    ,p_Attribute2            => l_New_Attribute2
	    ,x_return_status         => x_return_status
	    ,x_msg_count             => x_msg_count
	    ,x_msg_data              => x_msg_data
	  );
	  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  l_Retain_Dim_Att2.EXTEND(1);
          l_Retain_Dim_Att2(l_Retain_Dim_Att2.LAST) := l_Item_Att_Code;

	  UPDATE
	    ak_region_items_tl ak_item
	  SET
	    attribute_label_long = (SELECT
	                              tl.name
	                            FROM
	                              bsc_sys_periodicities_tl tl,
	                              bsc_sys_periodicities b
	                            WHERE
	                              b.short_name = l_Periodicity_Sht_Name AND
	                              b.periodicity_id = tl.periodicity_id AND
	                              tl.language = ak_item.language)
	  WHERE
	    ak_item.region_code = p_short_name AND
	    ak_item.region_application_id = l_Region_Att_Id AND
	    ak_item.attribute_code = l_Item_Att_Code AND
	    ak_item.attribute_application_id = l_Item_Att_App_Id;

        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  CLOSE c_cursor;

  --Dim Object Sync Up
  l_sql := 'SELECT ak_item.region_code,ak_item.region_application_id,ak_item.attribute_code,ak_item.attribute_application_id,';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' ak_item.attribute2, d.dim_level_id,g.dim_group_id FROM ak_region_items');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' ak_item,bsc_kpis_b');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' k , bsc_sys_dim_levels_b');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' d , bsc_sys_dim_groups_vl');
  l_sql := l_sql || ' g WHERE ak_item.region_code = k.short_name  AND ak_item.node_query_flag = ''Y'' AND ak_item.attribute2 LIKE ''%+%''';
  l_sql := l_sql || ' AND SUBSTR(ak_item.attribute2,INSTR(ak_item.attribute2,''+'') +1) = d.short_name AND';
  l_sql := l_sql || ' SUBSTR(ak_item.attribute2,0,INSTR(ak_item.attribute2,''+'') - 1) = g.short_name AND k.indicator = :1 MINUS';
  l_sql := l_sql || ' SELECT ak_item.region_code,ak_item.region_application_id,ak_item.attribute_code,ak_item.attribute_application_id,';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('ak_item.attribute2, d.dim_level_id,g.dim_group_id FROM ak_region_items');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' ak_item,bsc_kpis_b');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' k , bsc_sys_periodicities');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' p,bsc_sys_dim_levels_b');
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(' d,bsc_sys_dim_groups_vl');
  l_sql := l_sql || 'g WHERE ak_item.region_code = k.short_name  AND ak_item.node_query_flag = ''Y'' AND ak_item.attribute2 LIKE ''%+%''';
  l_sql := l_sql || ' AND SUBSTR(ak_item.attribute2,INSTR(ak_item.attribute2,''+'') +1) = p.short_name AND d.short_name = p.short_name';
  l_sql := l_sql || ' AND SUBSTR(ak_item.attribute2,0,INSTR(ak_item.attribute2,''+'') - 1) = g.short_name';
  l_sql := l_sql || ' AND k.indicator = :2';

  OPEN c_cursor FOR l_sql USING p_Src_indicator,p_Src_indicator;
  LOOP
    FETCH c_cursor INTO l_Region_Code,l_Region_Att_Id,l_Item_Att_Code,l_Item_Att_App_Id,l_Attribute2,l_Id,l_Dim_Group_Id;
    EXIT WHEN c_cursor%NOTFOUND;
    l_Dim_Short_Name := NULL;
    FOR i IN 1..p_Old_Dim_Groups.COUNT LOOP
      IF p_Old_Dim_Groups(i) = l_Dim_Group_Id THEN
        SELECT
          short_name
        INTO
          l_Dim_Short_Name
        FROM
          bsc_sys_dim_groups_vl
        WHERE
          dim_group_id = p_New_Dim_Groups(i);
        EXIT;
      END IF;
    END LOOP;

    IF l_Dim_Short_Name IS NOT NULL THEN
      l_Dim_Lev_Sht_Name := NULL;
      FOR i IN 1..p_Old_Dim_Levels.COUNT LOOP
        IF p_Old_Dim_Levels(i) = l_Id THEN
          SELECT
	    short_name
	  INTO
	    l_Dim_Lev_Sht_Name
	  FROM
	    bsc_sys_dim_levels_vl
	  WHERE
	    dim_level_id = p_New_Dim_Levels(i);
          EXIT;
        END IF;
      END LOOP;

      IF l_Dim_Lev_Sht_Name IS NOT NULL THEN
        l_New_Attribute2 := l_Dim_Short_Name||'+'||l_Dim_Lev_Sht_Name;
          Update_AK_Item_Props (
             p_commit                => FND_API.G_FALSE
	    ,p_region_code           => p_short_name
	    ,p_region_application_id => l_Region_Att_Id
	    ,p_Attribute_Code        => l_Item_Att_Code
	    ,p_Attribute_Application_Id => l_Item_Att_App_Id
	    ,p_Attribute2            => l_New_Attribute2
	    ,x_return_status         => x_return_status
	    ,x_msg_count             => x_msg_count
	    ,x_msg_data              => x_msg_data
	  );
	  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
	     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  l_Retain_Dim_Att2.EXTEND(1);
          l_Retain_Dim_Att2(l_Retain_Dim_Att2.LAST) := l_Item_Att_Code;

	  UPDATE
	    ak_region_items_tl ak_item
	  SET
	    attribute_label_long = (SELECT
	                              tl.name
	                            FROM
	                              bsc_sys_dim_levels_tl tl,
	                              bsc_sys_dim_levels_b b
	                            WHERE
	                              b.short_name = l_Dim_Lev_Sht_Name AND
	                              b.dim_level_id = tl.dim_level_id AND
	                              tl.language = ak_item.language)
	  WHERE
	    ak_item.region_code = p_short_name AND
	    ak_item.region_application_id = l_Region_Att_Id AND
	    ak_item.attribute_code = l_Item_Att_Code AND
	    ak_item.attribute_application_id = l_Item_Att_App_Id;

      END IF;
    END IF;

  END LOOP;
  CLOSE c_cursor;

  IF l_Retain_Dim_Att2 IS NOT NULL THEN
    SELECT
      attribute_code,attribute_application_id
    BULK COLLECT INTO
      l_Attribute_Code_Tbl,l_Attribute_App_Id_Tbl
    FROM
      ak_region_items
    WHERE
      region_code = p_short_name AND
      attribute_code in (SELECT
                           attribute_code
                         FROM
                           ak_region_items
                         WHERE
                           region_code = p_short_name AND
                           node_query_flag = 'Y' AND
                           attribute2 like '%+%' AND
                           attribute2 not like 'TIME_COMPARISON_TYPE+BUDGET'
                         MINUS
                         SELECT
                           column_value attribute_code
                         FROM
                           TABLE(CAST(l_Retain_Dim_Att2 AS BIS_STRING_ARRAY)));
    SELECT
      region_application_id
    INTO
      l_Region_Att_Id
    FROM
      ak_regions
    WHERE
      region_code = p_short_name;

    BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS (
      p_commit                 => p_commit
     ,p_region_code            => p_short_name
     ,p_region_application_id  => l_Region_Att_Id
     ,p_Attribute_Code_Tbl     => l_Attribute_Code_Tbl
     ,p_Attribute_Appl_Id_Tbl  => l_Attribute_App_Id_Tbl
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO BscSyncAKBscMetadata;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO BscSyncAKBscMetadata;
      FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
     ROLLBACK TO BscSyncAKBscMetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Synchronize_AK_BSC_Metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Synchronize_AK_BSC_Metadata ';
     END IF;
  WHEN OTHERS THEN
     ROLLBACK TO BscSyncAKBscMetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Synchronize_AK_BSC_Metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Synchronize_AK_BSC_Metadata ';
     END IF;
END Synchronize_AK_BSC_Metadata;


/************************************************************************************
--	API name 	: Copy_AK_Attributes_Metadata
--	Type		: Private
--	Function	:
--      1. Synchronizes properties in ak_attributes and ak_attributes_tl
************************************************************************************/


PROCEDURE Copy_AK_Attributes_Metadata (
   p_commit             IN    VARCHAR2 := FND_API.G_FALSE
  ,p_short_name         IN    BSC_KPIS_B.short_name%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS
  l_Attribute_Code ak_region_items.attribute_code%TYPE;
  l_Attribute_Application_Id ak_region_items.attribute_application_id%TYPE;
  l_Item_Style ak_region_items.item_style%TYPE;
  l_Attribute_Category  ak_region_items.attribute_category%TYPE;
  l_sql   VARCHAR2(32000);
  l_attribute_rowid           varchar2(50);
  l_count NUMBER := 0;
  TYPE c_cur_type IS REF CURSOR;
  c_cursor c_cur_type;

BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscCopyAKAttrMetadata;
  -- DataSet Sync Up
  l_sql := 'SELECT attribute_code,attribute_application_id,item_style,attribute_category ';
  l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String('from ak_region_items');
  l_sql := l_sql || ' WHERE region_code = :1';


  OPEN c_cursor FOR l_sql USING p_short_name;
  LOOP
    FETCH c_cursor INTO l_Attribute_Code,l_Attribute_Application_Id,l_Item_Style,l_Attribute_Category;
    EXIT WHEN c_cursor%NOTFOUND;

    l_Count := 0;
    SELECT COUNT(1)
    INTO  l_Count
    FROM AK_ATTRIBUTES
    WHERE attribute_code = l_Attribute_Code AND
    attribute_application_id = l_Attribute_Application_Id;
    IF l_Count = 0 THEN
      AK_ATTRIBUTES_PKG.INSERT_ROW (
       X_ROWID => l_attribute_rowid,
       X_ATTRIBUTE_APPLICATION_ID => l_Attribute_Application_Id,
       X_ATTRIBUTE_CODE => l_Attribute_Code,
       X_ATTRIBUTE_LABEL_LENGTH => BIS_AK_REGION_PUB.c_ATTR_LABEL_LENGTH,
       X_ATTRIBUTE_VALUE_LENGTH  => BIS_AK_REGION_PUB.c_ATTR_VALUE_LENGTH,
       X_BOLD => BIS_AK_REGION_PUB.c_BOLD ,
       X_ITALIC => BIS_AK_REGION_PUB.c_ITALIC,
       X_UPPER_CASE_FLAG => BIS_AK_REGION_PUB.c_UPPER_CASE_FLAG,
       X_VERTICAL_ALIGNMENT => BIS_AK_REGION_PUB.c_VERTICAL_ALIGNMENT,
       X_HORIZONTAL_ALIGNMENT => BIS_AK_REGION_PUB.c_HORIZONTAL_ALIGNMENT,
       X_DEFAULT_VALUE_VARCHAR2 => null,
       X_DEFAULT_VALUE_NUMBER => null,
       X_DEFAULT_VALUE_DATE => null,
       X_LOV_REGION_CODE => null,
       X_LOV_REGION_APPLICATION_ID => null,
       X_DATA_TYPE => BIS_AK_REGION_PUB.c_ATTR_DATATYPE,
       X_DISPLAY_HEIGHT => null,
       X_ITEM_STYLE => l_Item_Style,
       X_CSS_CLASS_NAME => null,
       X_CSS_LABEL_CLASS_NAME => null,
       X_PRECISION => null,
       X_EXPANSION  => null,
       X_ALS_MAX_LENGTH => null,
       X_POPLIST_VIEWOBJECT => null,
       X_POPLIST_DISPLAY_ATTRIBUTE => null,
       X_POPLIST_VALUE_ATTRIBUTE => null,
       X_ATTRIBUTE_CATEGORY => l_Attribute_Category,
       X_ATTRIBUTE1 => null,
       X_ATTRIBUTE2 => null,
       X_ATTRIBUTE3 => null,
       X_ATTRIBUTE4 => null,
       X_ATTRIBUTE5 => null,
       X_ATTRIBUTE6 => null,
       X_ATTRIBUTE7 => null,
       X_ATTRIBUTE8 => null,
       X_ATTRIBUTE9 => null,
       X_ATTRIBUTE10 => null,
       X_ATTRIBUTE11 => null,
       X_ATTRIBUTE12 => null,
       X_ATTRIBUTE13 => null,
       X_ATTRIBUTE14 => null,
       X_ATTRIBUTE15 => null,
       X_NAME => l_Attribute_Code,
       X_ATTRIBUTE_LABEL_LONG => null,
       X_ATTRIBUTE_LABEL_SHORT => null,
       X_DESCRIPTION => null,
       X_CREATION_DATE => sysdate,
       X_CREATED_BY => fnd_global.user_id,
       X_LAST_UPDATE_DATE => sysdate,
       X_LAST_UPDATED_BY => fnd_global.user_id,
       X_LAST_UPDATE_LOGIN => fnd_global.user_id);
    END IF;
  END LOOP;
  CLOSE c_cursor;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO BscCopyAKAttrMetadata;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO BscCopyAKAttrMetadata;
      FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
     ROLLBACK TO BscCopyAKAttrMetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Copy_AK_Attributes_Metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Copy_AK_Attributes_Metadata ';
     END IF;
  WHEN OTHERS THEN
     ROLLBACK TO BscCopyAKAttrMetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Copy_AK_Attributes_Metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Copy_AK_Attributes_Metadata ';
     END IF;
END Copy_AK_Attributes_Metadata;

/************************************************************************************
--	API name 	: Migrate_Sim_Data
--	Type		: Public
--	Function	:
--      1. Copies simulation data of BSC tables
--      2. Copies AK Metadata
--      3. Copies Form Function data
--      4. Synchronizes AK Metadata with BSC Metadata
************************************************************************************/

PROCEDURE Migrate_Sim_Data
(
   p_commit             IN    VARCHAR2 := FND_API.G_FALSE
  ,p_Trg_indicator      IN    BSC_KPIS_B.indicator%TYPE
  ,p_Src_indicator      IN    BSC_KPIS_B.indicator%TYPE
  ,p_Region_Code        IN    VARCHAR2
  ,p_Old_Region_Code    IN    BSC_KPIS_B.short_name%TYPE
  ,p_Old_Dim_Levels     IN    FND_TABLE_OF_NUMBER
  ,p_New_Dim_Levels     IN    FND_TABLE_OF_NUMBER
  ,p_Old_Dim_Groups     IN    FND_TABLE_OF_NUMBER
  ,p_New_Dim_Groups     IN    FND_TABLE_OF_NUMBER
  ,p_Old_DataSet_Map    IN    FND_TABLE_OF_NUMBER
  ,p_New_DataSet_Map    IN    FND_TABLE_OF_NUMBER
  ,p_Target_Calendar    IN    NUMBER
  ,p_Old_Periodicities  IN    FND_TABLE_OF_NUMBER
  ,p_New_Periodicities  IN    FND_TABLE_OF_NUMBER
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
)IS
  l_count               NUMBER;
  l_Bsc_Kpi_Entity_Rec  BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Table_Number        NUMBER;
  l_kpi_metadata_tables BSC_DESIGNER_PVT.t_kpi_metadata_tables;
  l_sql                 VARCHAR2(32700);
  l_table_name          all_tables.table_name%TYPE;
  l_arr_columns         BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_num_columns         NUMBER;
  l_colum               VARCHAR2(100);
  l_key_name            VARCHAR2(30);
  l_error_msg           VARCHAR2(4000);
  l_column_name         all_tab_columns.column_name%TYPE;
  l_Tl_Table_Column     all_tab_columns.column_name%TYPE;
  l_condition           VARCHAR2(4000);
  l_image_id            BSC_SYS_IMAGES_MAP_TL.image_id%TYPE;
  l_next_image_id       BSC_SYS_IMAGES_MAP_TL.image_id%TYPE;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  h_sql                 VARCHAR2(3200);
  l_New_Function_Id     fnd_form_functions.function_id%TYPE;
  l_Target_Value_char   fnd_form_functions.function_name%TYPE;
  l_Target_Value        fnd_form_functions.function_id%TYPE;
  l_Source_Value_char   fnd_form_functions.function_name%TYPE;
  l_Source_Value        fnd_form_functions.function_id%TYPE;
  l_Old_Function_Id     fnd_form_functions.function_id%TYPE;
  CURSOR c_column IS
  SELECT column_name
  FROM   all_tab_columns
  WHERE  table_name = UPPER(l_table_name)
  AND OWNER = UPPER(BSC_APPS.BSC_APPS_SCHEMA);



BEGIN
   --new tables for simulatio tree objective are
    --BSC_SYS_IMAGES
    --BSC_SYS_IMAGES_MAP_TL
    --BSC_TAB_VIEW_LABELS_B/TL
    --BSC_KPI_TREE_NODES_B/TL

    --For existing migration we don't need to handle any thing

    --First we will check if the region_code exists on the target system
    -- if yes then we cannot migrate and log it
    -- if the short_name is not there
    FND_MSG_PUB.INITIALIZE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT BscMigSimDataPub;
    g_db_link := BSC_DESIGNER_PVT.g_DbLink_Name;
    SELECT COUNT(0)
    INTO   l_count
    FROM   ak_regions
    WHERE  region_code = p_Old_Region_Code
    AND    region_application_id =BSC_MIGRATION.C_BSC_APP_ID;

    IF g_db_link IS NULL THEN
      --here we will call only the tables which are specific to simulation tree
      -- and also call the migration of ak region api
      l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Trg_indicator;
      BSC_KPI_PUB.Delete_Sim_Tree_Data
      (
          p_commit                => FND_API.G_FALSE
        , p_Bsc_Kpi_Entity_Rec    => l_Bsc_Kpi_Entity_Rec
        , x_return_status         => x_return_status
        , x_msg_count             => x_msg_count
        , x_msg_data              => x_msg_data
      );
      IF (x_return_status IS NOT NULL AND x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        BSC_APPS.Write_Line_Log('Error Deleting SimTree Data ', BSC_APPS.OUTPUT_FILE);
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    BSC_SIMULATION_VIEW_PVT.Init_Sim_Tables_Array
    (
       p_copy_Ak_Tables          =>  FND_API.G_TRUE
      ,x_Table_Number            =>  l_Table_Number
      ,x_kpi_metadata_tables     =>  l_kpi_metadata_tables
    );

    BSC_APPS.Write_Line_Log('Migrating Sim Data  [p_Trg_indicator =' ||p_Trg_indicator||']' , BSC_APPS.OUTPUT_FILE);

    FOR h_i IN 1..l_Table_Number LOOP
      IF l_kpi_metadata_tables(h_i).table_type <> BSC_SIMULATION_VIEW_PVT.C_AK_TABLE AND
        l_kpi_metadata_tables(h_i).table_type <>  BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE THEN
        l_table_name := l_kpi_metadata_tables(h_i).table_name;
        l_column_name:= l_kpi_metadata_tables(h_i).table_column;

        l_key_name := 'TAB_VIEW_ID';
        IF( l_column_name = BSC_SIMULATION_VIEW_PVT.C_SOURCE_CODE )THEN
          l_key_name := 'SOURCE_CODE';
        ELSIF (l_column_name = BSC_SIMULATION_VIEW_PVT.C_INDICATOR) THEN
          l_key_name := 'INDICATOR';
        END IF;


        l_num_columns :=0;
        OPEN c_column;
        FETCH c_column INTO l_colum;
        WHILE c_column%FOUND LOOP
          l_num_columns := l_num_columns + 1;
          l_arr_columns(l_num_columns) := l_colum;
          FETCH c_column INTO l_colum;
        END LOOP;
        CLOSE c_column;

        IF l_num_columns > 0 THEN

           IF(l_key_name = 'SOURCE_CODE') THEN
             l_condition := 'SOURCE_TYPE = 2 AND ' || l_key_name || '=' || p_Src_indicator;
           ELSIF(l_key_name = 'INDICATOR') THEN
             l_condition := 'INDICATOR =' || p_Src_indicator;
           ELSE
             l_condition := 'TAB_ID =-999 AND '|| l_column_name ||' = ' || p_Src_indicator;
           END IF;


           l_sql:= 'INSERT INTO ( SELECT ';
           FOR i IN 1..l_num_columns LOOP
              IF i <> 1 THEN
                  l_sql:= l_sql || ',';
              END IF;
                  l_sql:= l_sql || l_arr_columns(i);
           END LOOP;
           l_sql:= l_sql || ' FROM  ' || l_table_name;
           l_sql:= l_sql || ' )';
           l_sql:= l_sql || ' SELECT ';
           FOR i IN 1..l_num_columns LOOP
              IF i <> 1 THEN
                  l_sql:= l_sql || ',';
              END IF;

              IF(l_table_name='BSC_SYS_IMAGES_MAP_TL' AND UPPER(l_arr_columns(i)) = 'IMAGE_ID') THEN

                SELECT bsc_sys_image_id_s.nextval
                INTO l_next_image_id
                FROM dual;

                l_sql:= l_sql || l_next_image_id || ' AS ' || l_arr_columns(i);
              ELSIF(l_table_name='BSC_SYS_IMAGES' AND UPPER(l_arr_columns(i)) = 'IMAGE_ID' )THEN

                h_sql := ' SELECT DISTINCT image_id '||
                         ' FROM   BSC_SYS_IMAGES_MAP_TL '||'@'||g_db_link ||
                         ' WHERE SOURCE_TYPE =2 AND SOURCE_CODE = '|| p_Src_indicator;

                IF(l_cursor%ISOPEN)THEN
                  CLOSE l_cursor;
                END IF;

                OPEN l_cursor FOR h_sql;
                FETCH l_cursor INTO l_image_id;
                CLOSE l_cursor;

                l_condition := l_column_name ||' = ' || l_image_id;

                SELECT distinct image_id
                INTO   l_image_id
                FROM   BSC_SYS_IMAGES_MAP_TL
                WHERE SOURCE_TYPE =2
                AND   SOURCE_CODE =p_Trg_indicator;

                l_sql:= l_sql || l_image_id || ' AS ' || l_arr_columns(i);

                ELSIF UPPER(l_arr_columns(i)) = l_key_name THEN
                    l_sql:= l_sql || p_Trg_indicator || ' AS ' || l_arr_columns(i);
                ELSE
                    l_sql:= l_sql || l_arr_columns(i) || ' AS ' || l_arr_columns(i);
                END IF;
           END LOOP;
           l_sql:= l_sql || ' FROM  ' || l_table_name||'@'||g_db_link;
           l_sql:= l_sql || ' WHERE ' || l_condition;
           BSC_UPDATE_UTIL.Execute_Immediate(l_sql);
        END IF;

        IF l_kpi_metadata_tables(h_i).mls_table IS NOT NULL AND
           l_kpi_metadata_tables(h_i).mls_table = bsc_utility.YES THEN
           BSC_DESIGNER_PVT.Process_TL_Table(
             p_commit                => FND_API.G_FALSE
            ,p_DbLink_Name           => g_db_link
            ,p_Table_Name            => l_table_name
            ,p_Table_column          => l_key_name
            ,p_Target_Value          => p_Trg_indicator
            ,p_Target_Value_Char     => NULL
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
           );
           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

      END IF;
    END LOOP;

    SELECT
      FND_FORM_FUNCTIONS_S.NEXTVAL
    INTO
     l_New_Function_Id
    FROM dual;

    FOR h_i IN 1..l_Table_Number LOOP
      IF(l_kpi_metadata_tables(h_i).duplicate_data = bsc_utility.YES AND
          l_kpi_metadata_tables(h_i).table_type=BSC_SIMULATION_VIEW_PVT.C_AK_TABLE) THEN
         BSC_SIMULATION_VIEW_PVT.Copy_Ak_Record_Table (
           p_table_name       =>  l_kpi_metadata_tables(h_i).table_name
          ,p_table_type       =>  l_kpi_metadata_tables(h_i).table_type
          ,p_table_column     =>  l_kpi_metadata_tables(h_i).table_column
          ,p_Src_kpi          =>  p_Src_indicator
          ,p_Trg_kpi          =>  p_Trg_indicator
          ,p_new_region_code  =>  p_Region_Code
          ,p_new_form_function=>  NULL
          ,p_DbLink_Name      =>  g_db_link
         );
         IF l_kpi_metadata_tables(h_i).mls_table IS NOT NULL AND
           l_kpi_metadata_tables(h_i).mls_table = bsc_utility.YES THEN
           BSC_DESIGNER_PVT.Process_TL_Table(
             p_commit                => FND_API.G_FALSE
            ,p_DbLink_Name           => g_db_link
            ,p_Table_Name            => l_kpi_metadata_tables(h_i).table_name
            ,p_Table_column          => l_kpi_metadata_tables(h_i).table_column
            ,p_Target_Value          => NULL
            ,p_Target_Value_Char     => p_Region_Code
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
           );
           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
      ELSIF(l_kpi_metadata_tables(h_i).duplicate_data = bsc_utility.YES AND
           l_kpi_metadata_tables(h_i).table_type=BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE)THEN
         BSC_SIMULATION_VIEW_PVT.Copy_Ak_Record_Table (
           p_table_name       =>  l_kpi_metadata_tables(h_i).table_name
          ,p_table_type       =>  l_kpi_metadata_tables(h_i).table_type
          ,p_table_column     =>  l_kpi_metadata_tables(h_i).table_column
          ,p_Src_kpi          =>  p_Src_indicator
          ,p_Trg_kpi          =>  p_Trg_indicator
          ,p_new_region_code  =>  p_Region_Code
          ,p_new_form_function=>  l_new_function_id
          ,p_DbLink_Name      =>  g_db_link
         );
         IF l_kpi_metadata_tables(h_i).mls_table IS NOT NULL AND
           l_kpi_metadata_tables(h_i).mls_table = bsc_utility.YES THEN
           BSC_DESIGNER_PVT.Process_TL_Table(
             p_commit                => FND_API.G_FALSE
            ,p_DbLink_Name           => g_db_link
            ,p_Table_Name            => l_kpi_metadata_tables(h_i).table_name
            ,p_Table_column          => 'FUNCTION_ID'
            ,p_Target_Value          => l_new_function_id
            ,p_Target_Value_Char     => NULL
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
           );
           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

         END IF;
      END IF;
    END LOOP;

    IF p_Region_Code <> p_Old_Region_Code THEN
      UPDATE
        bsc_kpis_b
      SET
        short_name = p_Region_Code
      WHERE
        indicator = p_Trg_indicator;

      UPDATE
        bsc_kpi_analysis_options_b
      SET
        short_name = p_Region_Code
      WHERE
        indicator = p_Trg_indicator;

      UPDATE fnd_form_functions_tl tl
      SET user_function_name = (SELECT name FROM bsc_kpis_tl k, bsc_kpis_b b
          WHERE b.indicator = k.indicator AND
          b.short_name = p_Region_Code AND k.language = tl.language)
      WHERE
        function_id = l_new_function_id;

    END IF;

    --Now we will migrate the AK stuff here
    IF p_Region_Code IS NOT NULL THEN
         -- By design there is a form function and ak region called as the short name
         BSC_APPS.Write_Line_Log('Migrating report '||p_Old_Region_Code, BSC_APPS.OUTPUT_FILE);
         Synchronize_AK_BSC_Metadata (
            p_commit            =>  FND_API.G_FALSE
           ,p_Src_indicator     =>  p_Src_indicator
           ,p_Trg_indicator     =>  p_Trg_indicator
           ,p_short_name        =>  p_Region_Code
           ,p_Old_Dim_Levels    =>  p_Old_Dim_Levels
           ,p_New_Dim_Levels    =>  p_New_Dim_Levels
           ,p_Old_Dim_Groups    =>  p_Old_Dim_Groups
           ,p_New_Dim_Groups    =>  p_New_Dim_Groups
           ,p_Old_DataSet_Map   =>  p_Old_DataSet_Map
           ,p_New_DataSet_Map   =>  p_New_DataSet_Map
           ,p_Target_Calendar   =>  p_Target_Calendar
           ,p_Old_Periodicities =>  p_Old_Periodicities
           ,p_New_Periodicities =>  p_New_Periodicities
           ,x_return_status     =>  x_return_status
           ,x_msg_count         =>  x_msg_count
           ,x_msg_data          =>  x_msg_data
         );
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         UPDATE
           ak_regions
         SET
           attribute12 = p_Region_Code
         WHERE
           region_code = p_Region_Code;
         Copy_AK_Attributes_Metadata (
            p_commit            =>  FND_API.G_FALSE
           ,p_short_name        =>  p_Old_Region_Code
           ,x_return_status     =>  x_return_status
           ,x_msg_count         =>  x_msg_count
           ,x_msg_data          =>  x_msg_data
         );
     END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO BscMigSimDataPub;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO BscMigSimDataPub;
      FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
     ROLLBACK TO BscMigSimDataPub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Migrate_Sim_Data ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Migrate_Sim_Data ';
     END IF;
  WHEN OTHERS THEN
     ROLLBACK TO BscMigSimDataPub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_MIGRATION.Migrate_Sim_Data ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_MIGRATION.Migrate_Sim_Data ';
     END IF;
END Migrate_Sim_Data;



END BSC_MIGRATION;

/
