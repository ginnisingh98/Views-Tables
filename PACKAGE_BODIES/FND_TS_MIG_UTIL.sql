--------------------------------------------------------
--  DDL for Package Body FND_TS_MIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TS_MIG_UTIL" AS
/* $Header: fndptmub.pls 120.2 2005/11/15 16:28:16 mnovakov noship $ */
 G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;
 G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


 FUNCTION get_db_version
  RETURN NUMBER
 IS
   CURSOR ver_csr IS
     SELECT TO_NUMBER(SUBSTR(version, 1, 3))
       FROM product_component_version
      WHERE product like 'Oracle%Enterprise Edition%';
   l_version           NUMBER;
 BEGIN
   OPEN ver_csr;
   FETCH ver_csr INTO l_version;
   CLOSE ver_csr;
   RETURN l_version;
 END get_db_version;

 -- Set the TABLESPACE_NAME in gl_storage_parameters to INTERFACE.
 PROCEDURE upd_gl_storage_param (p_tablespace_type VARCHAR2)
 IS
   CURSOR tsp_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = p_tablespace_type;
   l_tablespace_name        FND_TABLESPACES.TABLESPACE%TYPE;
 BEGIN
   OPEN tsp_csr;
   FETCH tsp_csr INTO l_tablespace_name;
   if tsp_csr%NOTFOUND then
     raise_application_error(-20001, 'Tablespace of type '||p_tablespace_type||' is not present in FND_TABLESPACES table.');
   end if;
   CLOSE tsp_csr;

   UPDATE gl_storage_parameters
      SET tablespace_name = l_tablespace_name;

 END upd_gl_storage_param;

 -- Migrate Dictionary managed tablespaces to locally managed
 PROCEDURE migrate_tsp_to_local
 IS
   CURSOR tsp_csr IS
     SELECT distinct dt.tablespace_name
       FROM dba_tablespaces dt,
            fnd_product_installations fpi
      WHERE dt.extent_management = 'DICTIONARY'
        AND (dt.tablespace_name = fpi.tablespace
             OR dt.tablespace_name = fpi.index_tablespace);
   l_tablespace_name          DBA_TABLESPACES.TABLESPACE_NAME%TYPE;
 BEGIN
   OPEN tsp_csr;
   LOOP
     FETCH tsp_csr INTO l_tablespace_name;
     EXIT WHEN tsp_csr%NOTFOUND;
     DBMS_SPACE_ADMIN.TABLESPACE_MIGRATE_TO_LOCAL(l_tablespace_name);
   END LOOP;
   CLOSE tsp_csr;
 END migrate_tsp_to_local;


 FUNCTION get_tablespace_name (p_tablespace_type IN VARCHAR2)
  RETURN VARCHAR2
 IS
   CURSOR tbs_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = p_tablespace_type;
   l_tablespace_name          FND_TABLESPACES.TABLESPACE%TYPE;
 BEGIN
    OPEN tbs_csr;
    FETCH tbs_csr INTO l_tablespace_name;
    if tbs_csr%NOTFOUND then
      raise_application_error(-20001, 'Tablespace Type '||p_tablespace_type||' does n
ot exist.');
    end if;
    CLOSE tbs_csr;
    RETURN l_tablespace_name;
 END get_tablespace_name;

 FUNCTION get_tablespace_ues (p_tablespace_name IN VARCHAR2)
  RETURN NUMBER
 IS
   CURSOR tbs_ues_csr IS
     SELECT initial_extent,
            allocation_type
       FROM dba_tablespaces
      WHERE tablespace_name = p_tablespace_name;
   l_ues                NUMBER;
   l_allocation_type    DBA_TABLESPACES.ALLOCATION_TYPE%TYPE;
 BEGIN
    OPEN tbs_ues_csr;
    FETCH tbs_ues_csr INTO l_ues, l_allocation_type;
    if tbs_ues_csr%NOTFOUND then
      raise_application_error(-20001, 'Tablespace '||p_tablespace_name||' does n
ot exist.');
    end if;
    CLOSE tbs_ues_csr;

    if l_allocation_type = 'SYSTEM' then
      l_ues := NULL;
    end if;

    RETURN l_ues;
 END get_tablespace_ues;

 PROCEDURE chk_new_tablespaces
 IS
   CURSOR tsp_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace NOT IN (select tablespace_name
                                 from dba_tablespaces)
        AND tablespace_type IN ('TRANSACTION_TABLES', 'TRANSACTION_INDEXES', 'REFERENCE', 'ARCHIVE' ,'SUMMARY', 'INTERFACE', 'MEDIA', 'AQ', 'NOLOGGING', 'TOOLS');
   l_tablespace_name          VARCHAR2(30);
 BEGIN
   OPEN tsp_csr;
   FETCH tsp_csr INTO l_tablespace_name;
   if tsp_csr%FOUND then
     raise_application_error(-20001, 'All the tablespaces required for the new tablespace design are not created.');
   end if;
   CLOSE tsp_csr;

 END chk_new_tablespaces;

 PROCEDURE chk_new_tables
 IS
   l_cnt                NUMBER;
 BEGIN
     SELECT COUNT(1)
       INTO l_cnt
       FROM fnd_object_tablespaces;
     if l_cnt = 0 then
       raise_application_error(-20001, 'Object classification does not exist in FND_OBJECT_TABLESPACES.');
     end if;

     SELECT COUNT(1)
       INTO l_cnt
       FROM fnd_tablespaces;
     if l_cnt < 6 then
       raise_application_error(-20001, 'New Tablespaces definition does not exist in FND_TABLESPACES.');
     end if;

 END chk_new_tables;

 PROCEDURE chk_product_defaults
 IS
   CURSOR usr_def_csr IS
     SELECT '1'
       FROM dba_users
      WHERE username in (select oracle_username
                           from fnd_oracle_userid
                          where read_only_flag in ('E','A','U','K','M'))
        AND default_tablespace <> (select tablespace
                                     from fnd_tablespaces
                                    where tablespace_type = l_def_tab_tsp);

   CURSOR prd_inst_csr IS
     SELECT '1'
       FROM fnd_product_installations
      WHERE oracle_id in (select oracle_id
                            from fnd_oracle_userid
                           where read_only_flag in ('E','A','U','K','M'))
        AND (index_tablespace <> (select tablespace
                                from fnd_tablespaces
                               where tablespace_type = l_def_ind_tsp)
            OR
             tablespace <> (select tablespace
                              from fnd_tablespaces
                             where tablespace_type = l_def_tab_tsp));
   l_dummy              VARCHAR2(1);

   CURSOR prd_grps_csr IS
     SELECT is_new_ts_mode
       FROM fnd_product_groups;
   l_new_ts_mode        FND_PRODUCT_GROUPS.IS_NEW_TS_MODE%TYPE;
 BEGIN
   OPEN usr_def_csr;
   FETCH usr_def_csr INTO l_dummy;
   if usr_def_csr%FOUND then
     raise_application_error(-20001, 'The Default Tablespace of Oracle Users is not changed for the new tablesapce design.');
   end if;
   CLOSE usr_def_csr;

   OPEN prd_inst_csr;
   FETCH prd_inst_csr INTO l_dummy;
   if prd_inst_csr%FOUND then
     raise_application_error(-20001, 'The Tablespace and Index Tablespace for Oracle products in FND_PRODUCT_INSTALLATIONS is not changed for the new tablesapce design.');
   end if;
   CLOSE prd_inst_csr;

 -- check if the new tablespace design flag is set in FND_PRODUCT_GROUPS.
   OPEN prd_grps_csr;
   FETCH prd_grps_csr INTO l_new_ts_mode;
   CLOSE prd_grps_csr;
   if l_new_ts_mode <> 'Y' then
     raise_application_error(-20001, 'The New Tablespace Mode flag for the new tablesapce design is not set in FND_PRODUCT_GROUPS.');
   end if;

 END chk_product_defaults;


 PROCEDURE crt_storage_pref (p_tablespace_type IN VARCHAR2,
                             l_pref_name IN VARCHAR2)
 IS
   CURSOR get_tsp_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = p_tablespace_type;
   l_tablespace_name     VARCHAR2(30);
   l_ues                 NUMBER;
   l_string              VARCHAR2(4000);
   l_storage_str         VARCHAR2(4000);
 BEGIN
   OPEN get_tsp_csr;
   FETCH get_tsp_csr INTO l_tablespace_name;
   if get_tsp_csr%NOTFOUND then
      raise_application_error(-20001, 'Tablespace Type '||p_tablespace_type||' does not exist in FND_TABLESPACES.');
   end if;
   CLOSE get_tsp_csr;

   l_ues := get_tablespace_ues(l_tablespace_name);
   if l_ues IS NOT NULL then
     l_storage_str := 'STORAGE (INITIAL '||l_ues||')';
   end if;

   l_string := 'BEGIN
     ctx_ddl.create_preference('''||l_pref_name||''', ''BASIC_STORAGE'');
     ctx_ddl.set_attribute('''||l_pref_name||''', ''I_TABLE_CLAUSE'', ''tablespace '||l_tablespace_name||' '||l_storage_str||''');
     ctx_ddl.set_attribute('''||l_pref_name||''', ''K_TABLE_CLAUSE'', ''tablespace '||l_tablespace_name||' '||l_storage_str||''');
     ctx_ddl.set_attribute('''||l_pref_name||''', ''R_TABLE_CLAUSE'', ''tablespace '||l_tablespace_name||' '||l_storage_str||' lob (data) store as (cache)'');
     ctx_ddl.set_attribute('''||l_pref_name||''', ''N_TABLE_CLAUSE'', ''tablespace '||l_tablespace_name||' '||l_storage_str||''');
     ctx_ddl.set_attribute('''||l_pref_name||''', ''I_INDEX_CLAUSE'', ''tablespace '||l_tablespace_name||' '||l_storage_str||' compress 2'');
       END;';

   EXECUTE IMMEDIATE l_string;

 END crt_storage_pref;

 PROCEDURE upd_fot_username IS
 BEGIN
   UPDATE fnd_object_tablespaces fot
      SET oracle_username = (select fou.oracle_username
                               from fnd_product_installations fpi,
                                    fnd_oracle_userid fou
                              where fpi.oracle_id = fou.oracle_id
                                and fpi.application_id = fot.application_id)
    WHERE oracle_username IS NULL;

 END upd_fot_username;

 PROCEDURE process_gl_storage_param(p_apps_schema_name IN VARCHAR2) IS
   CURSOR gl_csr IS
     SELECT gsp.object_name,
            gsp.tablespace_name,
            ft.tablespace_type
       FROM gl_storage_parameters gsp,
            fnd_tablespaces ft
      WHERE gsp.tablespace_name = ft.tablespace
        AND object_type = 'T';

   CURSOR gl_tab_csr(l_table_name VARCHAR2) IS
     SELECT dt.owner,
            dt.table_name,
            fot.object_source,
            fot.tablespace_type,
            fot.custom_tablespace_type,
            fot.custom_flag
       FROM dba_tables dt,
            fnd_object_tablespaces fot
      WHERE dt.table_name like l_table_name||'%'
        AND fot.oracle_username(+) = dt.owner
        AND fot.object_name(+) = dt.table_name
--        AND NVL(dt.iot_type, 'X') NOT IN ('IOT', 'IOT_OVERFLOW')
        AND NVL(dt.temporary, 'N') = 'N'
        AND NOT EXISTS ( select ds.table_name
                           from dba_snapshots ds
                          where ds.owner = dt.owner
                            and ds.table_name = dt.table_name)
        AND NOT EXISTS ( select dsl.log_table
                           from dba_snapshot_logs dsl
                          where dsl.log_owner = dt.owner
                            and dsl.log_table = dt.table_name)
        AND NOT EXISTS ( select dqt.queue_table
                           from dba_queue_tables dqt
                          where dqt.owner = dt.owner
                            and dqt.queue_table = dt.table_name)
        AND dt.table_name not like 'AQ$%'
        AND dt.table_name not like 'DR$'
        AND dt.table_name NOT LIKE 'RUPD$%'
       ORDER BY dt.owner;
   l_owner            DBA_TABLES.OWNER%TYPE;
   l_last_owner       DBA_TABLES.OWNER%TYPE;
   l_table_name       DBA_TABLES.TABLE_NAME%TYPE;
   l_tablespace_type  FND_OBJECT_TABLESPACES.TABLESPACE_TYPE%TYPE;
   l_custom_tsp_type  FND_OBJECT_TABLESPACES.TABLESPACE_TYPE%TYPE;
   l_custom_flag      FND_OBJECT_TABLESPACES.CUSTOM_FLAG%TYPE;
   l_object_source    FND_OBJECT_TABLESPACES.OBJECT_SOURCE%TYPE;
   l_rowid            ROWID;

   CURSOR app_csr(l_oracle_username VARCHAR2) IS
     SELECT fpi.application_id
       FROM fnd_product_installations fpi,
            fnd_oracle_userid fou
      WHERE fpi.oracle_id = fou.oracle_id
        AND fou.oracle_username = l_oracle_username
      ORDER BY fpi.application_id;
   l_app_id           FND_PRODUCT_INSTALLATIONS.APPLICATION_ID%TYPE;
 BEGIN

   FOR gl_rec IN gl_csr
   LOOP

     OPEN gl_tab_csr(gl_rec.object_name);
     LOOP
       FETCH gl_tab_csr INTO l_owner, l_table_name, l_object_source, l_tablespace_type, l_custom_tsp_type, l_custom_flag;
       EXIT WHEN gl_tab_csr%NOTFOUND;

--dbms_output.put_line('table name '||l_table_name);

       if l_owner <> NVL(l_last_owner, 'X') then
         -- Get the APP ID only if the owner changes
         if l_owner = p_apps_schema_name then
           l_app_id := -999;
         else
           OPEN app_csr(l_owner);
           FETCH app_csr INTO l_app_id;
           if app_csr%NOTFOUND then
             raise_application_error(-20001, 'Application Id not found for '||l_owner||' in FND_PRODUCT_INSTALLATIONS.');
           end if;
           CLOSE app_csr;
         end if;
       end if;

       if l_tablespace_type IS NULL then
         FND_OBJECT_TABLESPACES_PKG.INSERT_ROW
           (l_rowid,
            l_app_id,
            l_table_name,
            'TABLE',
            gl_rec.tablespace_type,
            NULL,
            'RULES',
            l_owner,
            NULL,
            SYSDATE,
            g_user_id,
            SYSDATE,
            g_user_id,
            g_login_id);
       elsif NVL(l_object_source, 'X') = 'RULES' and l_tablespace_type <> gl_rec.tablespace_type then
         FND_OBJECT_TABLESPACES_PKG.UPDATE_ROW
           (l_app_id,
            l_table_name,
            'TABLE',
            gl_rec.tablespace_type,
            l_custom_tsp_type,
            'RULES',
            l_owner,
            l_custom_flag,
            SYSDATE,
            g_user_id,
            g_login_id);
       end if;
       l_last_owner := l_owner;
     END LOOP;
     CLOSE gl_tab_csr;
   END LOOP;
 END process_gl_storage_param;

 PROCEDURE process_rules(p_apps_schema_name IN VARCHAR2) IS
   CURSOR rules_csr IS
     SELECT rule_id,
            rule_query,
            tablespace_type
       FROM fnd_ts_mig_rules
      ORDER BY rule_id;
   query              VARCHAR2(4000);
   TYPE rules_tab_csr_type IS REF CURSOR;
   rules_tab_csr      rules_tab_csr_type;
   l_owner            DBA_TABLES.OWNER%TYPE;
   l_last_owner       DBA_TABLES.OWNER%TYPE;
   l_table_name       DBA_TABLES.TABLE_NAME%TYPE;
   l_tablespace_type  FND_OBJECT_TABLESPACES.TABLESPACE_TYPE%TYPE;
   l_custom_tsp_type  FND_OBJECT_TABLESPACES.TABLESPACE_TYPE%TYPE;
   l_custom_flag      FND_OBJECT_TABLESPACES.CUSTOM_FLAG%TYPE;
   l_object_source    FND_OBJECT_TABLESPACES.OBJECT_SOURCE%TYPE;
   l_rowid            ROWID;
   CURSOR app_csr(l_oracle_username VARCHAR2) IS
     SELECT fpi.application_id
       FROM fnd_product_installations fpi,
            fnd_oracle_userid fou
      WHERE fpi.oracle_id = fou.oracle_id
        AND fou.oracle_username = l_oracle_username
      ORDER BY fpi.application_id;
   l_app_id           FND_PRODUCT_INSTALLATIONS.APPLICATION_ID%TYPE;
 BEGIN

   upd_fot_username;

   FOR rules_rec IN rules_csr
   LOOP
     query := 'SELECT dt.owner, dt.table_name, fot.object_source,
                      fot.tablespace_type, fot.custom_tablespace_type,
                      fot.custom_flag
                 FROM dba_tables dt, fnd_object_tablespaces fot
                '||rules_rec.rule_query||'
                AND fot.oracle_username(+) = dt.owner
                AND fot.object_name(+) = dt.table_name
                AND NVL(dt.iot_type, ''X'') NOT IN (''IOT'', ''IOT_OVERFLOW'')
                AND NVL(dt.temporary, ''N'') = ''N''
                AND dt.owner IN (select oracle_username
                                   from fnd_oracle_userid
                                  where read_only_flag IN (''E'',''A'',''U'',''K'',''M''))
                AND NOT EXISTS ( select ds.table_name
                                   from dba_snapshots ds
                                  where ds.owner = dt.owner
                                    and ds.table_name = dt.table_name)
                AND NOT EXISTS ( select dsl.log_table
                                   from dba_snapshot_logs dsl
                                  where dsl.log_owner = dt.owner
                                    and dsl.log_table = dt.table_name)
                AND NOT EXISTS ( select dqt.queue_table
                                   from dba_queue_tables dqt
                                  where dqt.owner = dt.owner
                                    and dqt.queue_table = dt.table_name)
                AND dt.table_name not like ''AQ$%''
                AND dt.table_name not like ''DR$''
                AND dt.table_name NOT LIKE ''RUPD$%''
               ORDER BY dt.owner';
--AND fot.object_type(+) = ''TABLE''
--dbms_output.put_line(substr(query,1,240));

     OPEN rules_tab_csr FOR query;
     LOOP
       FETCH rules_tab_csr INTO l_owner, l_table_name, l_object_source, l_tablespace_type, l_custom_tsp_type, l_custom_flag;
       EXIT WHEN rules_tab_csr%NOTFOUND;

--dbms_output.put_line('table name '||l_table_name);

       if l_owner <> NVL(l_last_owner, 'X') then
         -- Get the APP ID only if the owner changes
         if l_owner = p_apps_schema_name then
           l_app_id := -999;
         else
           OPEN app_csr(l_owner);
           FETCH app_csr INTO l_app_id;
           if app_csr%NOTFOUND then
             raise_application_error(-20001, 'Application Id not found for '||l_owner||' in FND_PRODUCT_INSTALLATIONS.');
           end if;
           CLOSE app_csr;
         end if;
       end if;

       if l_tablespace_type IS NULL then
         FND_OBJECT_TABLESPACES_PKG.INSERT_ROW
           (l_rowid,
            l_app_id,
            l_table_name,
            'TABLE',
            rules_rec.tablespace_type,
            NULL,
            'RULES',
            l_owner,
            NULL,
            SYSDATE,
            g_user_id,
            SYSDATE,
            g_user_id,
            g_login_id);
       elsif NVL(l_object_source, 'X') = 'RULES' and l_tablespace_type <> rules_rec.tablespace_type then
         FND_OBJECT_TABLESPACES_PKG.UPDATE_ROW
           (l_app_id,
            l_table_name,
            'TABLE',
            rules_rec.tablespace_type,
            l_custom_tsp_type,
            'RULES',
            l_owner,
            l_custom_flag,
            SYSDATE,
            g_user_id,
            g_login_id);
       end if;
       l_last_owner := l_owner;
     END LOOP;
     CLOSE rules_tab_csr;
   END LOOP;

   process_gl_storage_param(p_apps_schema_name);

 END process_rules;

 PROCEDURE set_defaults
 IS
   CURSOR usr_csr IS
     SELECT oracle_id,
            oracle_username
       FROM fnd_oracle_userid
      WHERE read_only_flag in ('E', 'A', 'U', 'K', 'M')
      ORDER by oracle_username;

   CURSOR usr_quota_csr(p_username VARCHAR2) IS
     SELECT dtq.tablespace_name
       FROM dba_ts_quotas dtq
      WHERE dtq.username = p_username
        AND EXISTS (select dt.tablespace_name
                      from dba_tablespaces dt
                     where dt.tablespace_name = dtq.tablespace_name)
      ORDER by dtq.tablespace_name;

   CURSOR txn_tsp_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = l_def_tab_tsp;

   CURSOR txn_ind_tsp_csr IS
     SELECT tablespace
       FROM fnd_tablespaces
      WHERE tablespace_type = l_def_ind_tsp;

   CURSOR tsp_csr IS
     SELECT ft.tablespace
       FROM fnd_tablespaces ft;

   l_string                 VARCHAR2(4000);
   l_txn_tablespace         VARCHAR2(30);
   l_txn_ind_tablespace     VARCHAR2(30);

 BEGIN

   OPEN txn_tsp_csr;
   FETCH txn_tsp_csr INTO l_txn_tablespace;
   if txn_tsp_csr%NOTFOUND then
     raise_application_error(-20001, 'Tablespace of type '||l_def_tab_tsp||' is not present in FND_TABLESPACES table.');
   end if;
   CLOSE txn_tsp_csr;

   OPEN txn_ind_tsp_csr;
   FETCH txn_ind_tsp_csr INTO l_txn_ind_tablespace;
   if txn_ind_tsp_csr%NOTFOUND then
     raise_application_error(-20001, 'Tablespace of type '||l_def_ind_tsp||' is not present in FND_TABLESPACES table.');
   end if;
   CLOSE txn_ind_tsp_csr;

   FOR usr_rec IN usr_csr
   LOOP

/* Revoke only after all schemas are migrated
     -- Revoke quota on all tablespaces
     FOR usr_quota_rec IN usr_quota_csr(usr_rec.oracle_username)
     LOOP
       l_string := 'ALTER USER '||usr_rec.oracle_username||' QUOTA 0 ON '||usr_quota_rec.tablespace_name;
       EXECUTE IMMEDIATE l_string;
     END LOOP;
*/

     -- Change the default tablespace for the user as TRANSACTION_TABLES
     l_string := 'ALTER USER '||usr_rec.oracle_username||' DEFAULT TABLESPACE '||l_txn_tablespace;
     EXECUTE IMMEDIATE l_string;

     -- Grant unlimited quota to the user for the new tablespaces.
     FOR tsp_rec IN tsp_csr
     LOOP
       l_string := 'ALTER USER '||usr_rec.oracle_username||' QUOTA UNLIMITED ON '||tsp_rec.tablespace;
       EXECUTE IMMEDIATE l_string;
     END LOOP;

     -- Set the data tablespace and index tablespace as TRANSACTION_TABLES in fnd_product_installations.
     UPDATE fnd_product_installations
        SET tablespace = l_txn_tablespace,
            index_tablespace = l_txn_ind_tablespace
      WHERE oracle_id = usr_rec.oracle_id;
   END LOOP;

   -- Set the TABLESPACE_NAME in gl_storage_parameters to INTERFACE.
   fnd_ts_mig_util.upd_gl_storage_param('INTERFACE');

   -- Set the new tablespace design flag to Y in fnd_product_groups.
   UPDATE fnd_product_groups
     SET is_new_ts_mode = 'Y';
END set_defaults;

 PROCEDURE crt_txn_ind_pref
 IS
   CURSOR pref_csr IS
     SELECT pre_name
       FROM CTX_USER_PREFERENCES
      WHERE PRE_NAME = 'TXN_IND_STORAGE_PREF';
   l_pref_name        CTX_USER_PREFERENCES.PRE_NAME%TYPE;
 BEGIN
   -- Drop storage preference if it exists.
   OPEN pref_csr;
   FETCH pref_csr INTO l_pref_name;
   if pref_csr%FOUND then
     ctx_ddl.drop_preference('TXN_IND_STORAGE_PREF');
   end if;
   CLOSE pref_csr;
   -- Create storage preference for TRANSACTION_INDEXES tablespace for DOMAIN indexes.
   crt_storage_pref(l_def_ind_tsp, 'txn_ind_storage_pref');
 END crt_txn_ind_pref;

END fnd_ts_mig_util;

/
