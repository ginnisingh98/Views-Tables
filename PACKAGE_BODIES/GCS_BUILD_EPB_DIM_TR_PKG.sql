--------------------------------------------------------
--  DDL for Package Body GCS_BUILD_EPB_DIM_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_BUILD_EPB_DIM_TR_PKG" AS
/* $Header: gcsdimtrb.pls 120.2 2006/06/09 17:48:36 skamdar noship $ */
--
-- Package
--   build_epb_dimtr_pkg
-- Purpose
--   Creates GCS_DYN_EPB_DIMTR_PKG
-- History
--   12-MAR-04	R Goyal		Created
--
--
--
-- Public procedures
--
  PROCEDURE build_epb_dimtr_pkg IS

    -- row number to be used in dynamically creating the package
    r		NUMBER := 1;
    body        VARCHAR2(10000);

    body_len    NUMBER;
    curr_pos    NUMBER;
    line_num    NUMBER := 1;
    err		VARCHAR2(2000);
    l_global_vs_id  NUMBER;

    felm_obj_def_id  NUMBER;
    interco_obj_def_id NUMBER;
    cat_obj_def_id NUMBER;
    na_obj_def_id NUMBER;

    l_felm_value_set     VARCHAR2(150);
    l_felm_value_set_id  NUMBER;
    l_interco_value_set  VARCHAR2(150);
    l_interco_value_set_id  NUMBER;
    l_na_value_set  VARCHAR2(150);
    l_na_value_set_id  NUMBER;
    l_cat_value_set      VARCHAR2(150);

    -- Store whether a dimension is used by GCS and the respective table info
    --Bugfix 5308890: Hardcode mapping for Intercopmany to 'N'
    l_interco_req VARCHAR2(1) := 'N';
    l_interco_tab VARCHAR2(30);
    l_interco_b VARCHAR2(30);
    l_interco_btab VARCHAR2(30);
    l_interco_tltab VARCHAR2(30);
    l_interco_attrtab VARCHAR2(30);
    l_interco_col VARCHAR2(30);
    l_interco_name VARCHAR2(30);
    l_interco_column  VARCHAR2(30);

    --Bugfix 5308890: Hardcode mapping for Financial Element to 'N'
    l_felm_req  VARCHAR2(1) := 'N';
    l_felm_tab  VARCHAR2(30);
    l_felm_btab  VARCHAR2(30);
    l_felm_b     VARCHAR2(30);
    l_felm_tltab  VARCHAR2(30);
    l_felm_attrtab VARCHAR2(30);
    l_felm_col  VARCHAR2(30);
    l_felm_name VARCHAR2(30);
    l_felm_column  VARCHAR2(30);

    --Bugfix 5308890: Hardcode mapping for Natural Account to 'N'
    l_na_req    VARCHAR2(1) := 'N';
    l_na_tab    VARCHAR2(30);
    l_na_b      VARCHAR2(30);
    l_na_btab    VARCHAR2(30);
    l_na_tltab    VARCHAR2(30);
    l_na_attrtab  VARCHAR2(30);
    l_na_col    VARCHAR2(30);
    l_na_name   VARCHAR2(30);
    l_na_column    VARCHAR2(30);

    l_category_req  VARCHAR2(1);
    l_category_tab  VARCHAR2(30);
    l_category_b    VARCHAR2(30);
    l_category_btab  VARCHAR2(30);
    l_category_tltab  VARCHAR2(30);
    l_cat_attrtab     VARCHAR2(30);
    l_category_col  VARCHAR2(30);
    l_category_name VARCHAR2(30);
    l_cat_column       VARCHAR2(30);

    l_fe_value_setid       NUMBER;
    l_interco_value_setid  NUMBER;
    l_na_value_setid       NUMBER;
    l_cat_value_setid      NUMBER;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'GCS_BUILD_EPB_DIM_TR_PKG' || '.' || 'BUILD_EPB_DIMTR_PKG',
                     GCS_UTILITY_PKG.g_module_enter || 'BUILD_EPB_DIM_TR_PKG' ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter || 'BUILD_EPB_DIMTR_PKG' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));


    --Bugfix 5308890: Comment out the check for intercompany, natural account, and financial element as they are now supported in EPB
    /*
    -- Set the value sets
    begin
      l_felm_value_set_id := gcs_utility_pkg.g_gcs_dimension_info ('FINANCIAL_ELEM_ID').associated_value_set_id;
    exception
      when no_data_found then
        l_felm_value_set_id := -1;
    end;

    begin
     l_interco_value_set_id := gcs_utility_pkg.g_gcs_dimension_info ('INTERCOMPANY_ID').associated_value_set_id;
    exception
      when no_data_found then
        l_interco_value_set_id := -1;
    end;

    begin
     l_na_value_set_id := gcs_utility_pkg.g_gcs_dimension_info ('NATURAL_ACCOUNT_ID').associated_value_set_id;
    exception
      when no_data_found then
        l_na_value_set_id := -1;
    end;
    */

     --Bugfix 5308890: Comment out check for Financial Element, Intercompany and Natural Account well
     /*
     -- Set the required flags
     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10), epb_column
       INTO l_felm_req, l_felm_tab, l_felm_column
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'FINANCIAL_ELEM_ID';
     exception
       when no_data_found then
         l_felm_req := 'N';
     end;

     -- Get the GVS
     SELECT fch_global_vs_combo_id
       INTO l_global_vs_id
       FROM gcs_system_options;

     -- get the value set name
     begin
       SELECT value_set_display_code, value_set_id
         INTO l_felm_value_set, l_fe_value_setid
         FROM fem_value_sets_b
        WHERE value_set_id = ( SELECT gvs.value_set_id
                                 FROM FEM_GLOBAL_VS_COMBO_DEFS gvs, FEM_TAB_COLUMNS_B dim
                                 WHERE gvs.global_vs_combo_id = l_global_vs_id
                                   AND dim.fem_data_type_code = 'DIMENSION'
                                   AND gvs.dimension_id = dim.dimension_id
                                   AND dim.table_name = 'FEM_BALANCES'
                                   AND dim.column_name = l_felm_column) ;
     exception
       when no_data_found then
         l_felm_value_set := '-1';
     end;

     -- Set the table names, column names and column id's to be used in the main sql
     IF substr(l_felm_tab,14) <> '0' THEN
        l_felm_b := substr(l_felm_tab, 0, 13) || '_B';
        l_felm_btab := substr(l_felm_tab, 0, 13) || '_B_T';
        l_felm_tltab := substr(l_felm_tab, 0, 13) || '_TL_T';
        l_felm_attrtab := substr(l_felm_tab, 0, 13) || '_ATTR_T';
        l_felm_col := substr(l_felm_tab, 5, 9) || '_DISPLAY_CODE';
        l_felm_name := substr(l_felm_tab, 5, 9) || '_NAME';
        felm_obj_def_id := get_obj_def_id(substr(l_felm_tab, 13, 1));
     ELSE
        l_felm_b := l_felm_tab || '_B';
        l_felm_btab := l_felm_tab || '_B_T';
        l_felm_tltab := l_felm_tab || '_TL_T';
        l_felm_attrtab := l_felm_tab || '_ATTR_T';
        l_felm_col := substr(l_felm_tab, 5, 10) || '_DISPLAY_CODE';
        l_felm_name := substr(l_felm_tab, 5, 10) || '_NAME';
        -- felm_obj_def_id := 1220;
        felm_obj_def_id := 28;
     END IF;

     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10), epb_column
       INTO l_interco_req, l_interco_tab, l_interco_column
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'INTERCOMPANY_ID';
     exception
       when no_data_found then
         l_interco_req := 'N';
     end;

     -- get the value set name
     begin
       SELECT value_set_display_code, value_set_id
         INTO l_interco_value_set, l_interco_value_setid
         FROM fem_value_sets_b
        WHERE value_set_id = ( SELECT gvs.value_set_id
                                 FROM FEM_GLOBAL_VS_COMBO_DEFS gvs, FEM_TAB_COLUMNS_B dim
                                 WHERE gvs.global_vs_combo_id = l_global_vs_id
                                   AND dim.fem_data_type_code = 'DIMENSION'
                                   AND gvs.dimension_id = dim.dimension_id
                                   AND dim.table_name = 'FEM_BALANCES'
                                   AND dim.column_name = l_interco_column) ;
     exception
       when no_data_found then
         l_interco_value_set := '-1';
     end;

      IF substr(l_interco_tab,14) <> '0' THEN
        l_interco_b := substr(l_interco_tab, 0, 13) || '_B';
        l_interco_btab := substr(l_interco_tab, 0, 13) || '_B_T';
        l_interco_tltab := substr(l_interco_tab, 0, 13) || '_TL_T';
        l_interco_attrtab := substr(l_interco_tab, 0, 13) || '_ATTR_T';
        l_interco_col := substr(l_interco_tab, 5, 9) || '_DISPLAY_CODE';
        l_interco_name := substr(l_interco_tab, 5, 9) || '_NAME';
        interco_obj_def_id := get_obj_def_id(substr(l_interco_tab, 13, 1));
      ELSE
        l_interco_b := l_interco_tab || '_B';
        l_interco_btab := l_interco_tab || '_B_T';
        l_interco_tltab := l_interco_tab || '_TL_T';
        l_interco_attrtab := l_interco_tab || '_ATTR_T';
        l_interco_col := substr(l_interco_tab, 5, 10) || '_DISPLAY_CODE';
        l_interco_name := substr(l_interco_tab, 5, 10) || '_NAME';
        interco_obj_def_id := 28;
        -- interco_obj_def_id := 1220;
      END IF;

     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10), epb_column
       INTO l_na_req, l_na_tab, l_na_column
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'NATURAL_ACCOUNT_ID';
     exception
       when no_data_found then
         l_na_req := 'N' ;
     end;

     -- get the value set name
     begin
       SELECT value_set_display_code, value_set_id
         INTO l_na_value_set, l_na_value_setid
         FROM fem_value_sets_b
        WHERE value_set_id = ( SELECT gvs.value_set_id
                                 FROM FEM_GLOBAL_VS_COMBO_DEFS gvs, FEM_TAB_COLUMNS_B dim
                                 WHERE gvs.global_vs_combo_id = l_global_vs_id
                                   AND dim.fem_data_type_code = 'DIMENSION'
                                   AND dim.table_name = 'FEM_BALANCES'
                                   AND gvs.dimension_id = dim.dimension_id
                                   AND dim.column_name = l_na_column) ;
     exception
       when no_data_found then
         l_na_value_set := '-1';
     end;

      IF substr(l_na_tab,14) <> '0' THEN
        l_na_b := substr(l_na_tab, 0, 13) || '_B';
        l_na_btab := substr(l_na_tab, 0, 13) || '_B_T';
        l_na_tltab := substr(l_na_tab, 0, 13) || '_TL_T';
        l_na_attrtab := substr(l_na_tab, 0, 13) || '_ATTR_T';
        l_na_col := substr(l_na_tab, 5, 9) || '_DISPLAY_CODE';
        l_na_name := substr(l_na_tab, 5, 9) || '_NAME';
        na_obj_def_id := get_obj_def_id(substr(l_na_tab, 13, 1));
      ELSE
        l_na_b := l_na_tab || '_B';
        l_na_btab := l_na_tab || '_B_T';
        l_na_tltab := l_na_tab || '_TL_T';
        l_na_attrtab := l_na_tab || '_ATTR_T';
        l_na_col := substr(l_na_tab, 5, 10) || '_DISPLAY_CODE';
        l_na_name := substr(l_na_tab, 5, 10) || '_NAME';
        -- na_obj_def_id := 1220;
        na_obj_def_id := 28;
      END IF;

     */

     -- Get the GVS
     SELECT fch_global_vs_combo_id
       INTO l_global_vs_id
       FROM gcs_system_options;

     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10), epb_column
       INTO l_category_req, l_category_tab, l_cat_column
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'CREATED_BY_OBJECT_ID';
     exception
       when no_data_found then
         l_category_req := 'N' ;
     end;

     -- get the value set name
     begin
        SELECT value_set_display_code, value_set_id
         INTO l_cat_value_set, l_cat_value_setid
         FROM fem_value_sets_b
        WHERE value_set_id = ( SELECT gvs.value_set_id
                                 FROM FEM_GLOBAL_VS_COMBO_DEFS gvs, FEM_TAB_COLUMNS_B dim
                                 WHERE gvs.global_vs_combo_id = l_global_vs_id
                                   AND dim.fem_data_type_code = 'DIMENSION'
                                   AND gvs.dimension_id = dim.dimension_id
                                   AND dim.table_name = 'FEM_BALANCES'
                                   AND dim.column_name = l_cat_column) ;
     exception
       when no_data_found then
         l_cat_value_set := '-1';
     end;

     IF substr(l_category_tab,14) <> '0' THEN
        l_category_b := substr(l_category_tab, 0, 13) || '_B';
        l_category_btab := substr(l_category_tab, 0, 13) || '_B_T';
        l_category_tltab := substr(l_category_tab, 0, 13) || '_TL_T';
        l_cat_attrtab := substr(l_category_tab, 0, 13) || '_ATTR_T';
        l_category_col := substr(l_category_tab, 5, 9) || '_DISPLAY_CODE';
        l_category_name := substr(l_category_tab, 5, 9) || '_NAME';
        cat_obj_def_id := get_obj_def_id(substr(l_category_tab, 13, 1));
     ELSE
        l_category_b := l_category_tab || '_B';
        l_category_btab := l_category_tab || '_B_T';
        l_category_tltab := l_category_tab || '_TL_T';
        l_cat_attrtab := l_category_tab || '_ATTR_T';
        l_category_col := substr(l_category_tab, 5, 10) || '_DISPLAY_CODE';
        l_category_name := substr(l_category_tab, 5, 10) || '_NAME';
        -- cat_obj_def_id := 1220;
        cat_obj_def_id := 28;
     END IF;



     -- Create the package body
body:=
'CREATE OR REPLACE PACKAGE BODY GCS_DYN_EPB_DIMTR_PKG AS


/* $Header: gcsdimtrb.pls 120.2 2006/06/09 17:48:36 skamdar noship $ */
     -- Store the log level
     runtimeLogLevel     NUMBER := FND_LOG.g_current_runtime_level;
     statementLogLevel   CONSTANT NUMBER := FND_LOG.level_statement;
     procedureLogLevel   CONSTANT NUMBER := FND_LOG.level_procedure;
     exceptionLogLevel   CONSTANT NUMBER := FND_LOG.level_exception;
     errorLogLevel       CONSTANT NUMBER := FND_LOG.level_error;
     unexpectedLogLevel  CONSTANT NUMBER := FND_LOG.level_unexpected;

     g_src_sys_code NUMBER := GCS_UTILITY_PKG.g_gcs_source_system_code;

     DIM_LOAD_ERROR     EXCEPTION;


   PROCEDURE Gcs_Epb_Tr_Dim (
		errbuf       OUT NOCOPY VARCHAR2,
		retcode      OUT NOCOPY VARCHAR2 ) IS

        l_execution_mode   VARCHAR2(1) := ''S'' ;
        l_felm_req_id           NUMBER;
        l_int_req_id            NUMBER;
        l_na_req_id             NUMBER;
        l_cat_req_id            NUMBER;

 	module	  VARCHAR2(30) := ''GCS_EPB_TR_DIM'';

   BEGIN

     runtimeLogLevel := FND_LOG.g_current_runtime_level;

     IF (procedureloglevel >= runtimeloglevel ) THEN
    	 FND_LOG.STRING(procedureloglevel, ''gcs.plsql.gcs_epb_dim_tr_pkg.gcs_epb_tr_dim.begin'' || GCS_UTILITY_PKG.g_module_enter, to_char(sysdate, ''DD-MON-YYYY HH:MI:SS''));
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter || ''Gcs_Epb_Tr_Dim'' || to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));

';

         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

--Bugfix 5308890: This code will never be generated since l_felm_req has been hardcoded to 'N'
IF l_felm_req = 'Y' THEN
  body:= '       INSERT INTO ' ||  l_felm_btab || ' (' || l_felm_col || ', value_set_display_code, status)';
  body := body || '
          SELECT ';
  body := body || 'financial_elem_display_code, ''' || l_felm_value_set || ''' , ''LOAD''
          FROM fem_fin_elems_b
          WHERE value_set_id = ' || l_felm_value_set_id || '
          AND financial_elem_display_code NOT IN
               ( SELECT ' || l_felm_col || '
                  FROM ' || l_felm_b || '
                  WHERE value_set_id = ' || l_fe_value_setid  || ' );' ;

  body := body || '
';

  body := body || '
        INSERT INTO ' || l_felm_tltab || ' (' || l_felm_col || ', value_set_display_code, status, language, description, ';
  body := body || l_felm_name || ') ';
  body := body || '
          SELECT financial_elem_display_code, ''' || l_felm_value_set ;
  body := body || ''', ''LOAD'', userenv(''LANG''), description, financial_elem_name ';
  body := body || '
          FROM fem_fin_elems_vl
          WHERE value_set_id = ' || l_felm_value_set_id || '
          AND financial_elem_display_code NOT IN
               ( SELECT ' || l_felm_col || '
                  FROM ' || l_felm_b || '
                  WHERE value_set_id = ' || l_fe_value_setid  || ' );' ;

        curr_pos := 1;
        body_len := LENGTH(body);
        WHILE curr_pos <= body_len LOOP
        ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
        curr_pos := curr_pos + g_line_size;
        r := r + 1;
        END LOOP;

  body := '
';
  body := body || '
        INSERT INTO ' || l_felm_attrtab || ' (' || l_felm_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
        SELECT ';
  body := body || 'financial_elem_display_code, ''' || l_felm_value_set ;
  body := body || ''', ''SOURCE_SYSTEM_CODE'', ''GCS'', ''LOAD'', ''Default''
        FROM fem_fin_elems_b
        WHERE value_set_id = ' || l_felm_value_set_id || '
          AND financial_elem_display_code NOT IN
               ( SELECT ' || l_felm_col || '
                  FROM ' || l_felm_b || '
                  WHERE value_set_id = ' || l_fe_value_setid  || ' );' ;

  body := body || '
';
  body := body || '
        INSERT INTO ' || l_felm_attrtab || ' (' || l_felm_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
        SELECT ';
  body := body || 'financial_elem_display_code, ''' || l_felm_value_set ;
  body := body || ''', ''RECON_LEAF_NODE_FLAG'', ''Y'', ''LOAD'', ''Default''
        FROM fem_fin_elems_b
        WHERE value_set_id = ' || l_felm_value_set_id ||  '
          AND financial_elem_display_code NOT IN
               ( SELECT ' || l_felm_col || '
                  FROM ' || l_felm_b || '
                  WHERE value_set_id = ' || l_fe_value_setid  || ' );' ;

  body := body || '
';
  body := body || '
    IF (SQL%ROWCOUNT <> 0) THEN
      FEM_DIM_MEMBER_LOADER_PKG.Main(
         errbuf => errbuf,
         retcode => retcode,
         p_execution_mode => ''S'',
         p_dimension_id => ' || felm_obj_def_id || ');';

   body := body || '
   dbms_output.put_line(''FE dim load status = ''|| retcode ); ';

  body := body || '
';

  body := body || '
         IF retcode = ''2'' THEN
           RAISE DIM_LOAD_ERROR;
         END IF;
     END IF ;
';

         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

END IF;  -- if felm_req is Y


--Bugfix 5308890: This code will never be executed as l_na_req has been hard-coded to 'N'
IF l_na_req = 'Y' THEN
  body:= 'INSERT INTO ' ||  l_na_btab || ' (' || l_na_col || ', value_set_display_code, status)
          SELECT ';
  body := body || 'natural_account_display_code, ''' || l_na_value_set || ''', ''LOAD''
          FROM fem_nat_accts_b
          WHERE value_set_id = ' || l_na_value_set_id || '
          AND natural_account_display_code NOT IN
               ( SELECT ' || l_na_col || '
                  FROM ' || l_na_b || '
                  WHERE value_set_id = ' || l_na_value_setid  || ' );' ;

  body := body || '
          INSERT INTO ' || l_na_tltab || ' (' || l_na_col || ', value_set_display_code, status, language, description, ';
  body := body || l_na_name || ')
          SELECT natural_account_display_code, ''' || l_na_value_set ;
  body := body || ''', ''LOAD'', userenv(''LANG''), description, natural_account_name
          FROM fem_nat_accts_vl
          WHERE value_set_id = ' || l_na_value_set_id || '
          AND natural_account_display_code NOT IN
               ( SELECT ' || l_na_col || '
                  FROM ' || l_na_b || '
                  WHERE value_set_id = ' || l_na_value_setid  || ' );' ;

        curr_pos := 1;
        body_len := LENGTH(body);
        WHILE curr_pos <= body_len LOOP
        ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
        curr_pos := curr_pos + g_line_size;
        r := r + 1;
        END LOOP;

  body := body || '
';

  body := 'INSERT INTO ' || l_na_attrtab || ' (' || l_na_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
           SELECT ';
  body := body || 'natural_account_display_code, ''' || l_na_value_set ;
  body := body || ''', ''SOURCE_SYSTEM_CODE'', ''GCS'', ''LOAD'', ''Default''
           FROM fem_nat_accts_b
           WHERE value_set_id = ' || l_na_value_set_id || '
          AND natural_account_display_code NOT IN
               ( SELECT ' || l_na_col || '
                  FROM ' || l_na_b || '
                  WHERE value_set_id = ' || l_na_value_setid  || ' );' ;
  body := body || '
';

  body := body || '
    INSERT INTO ' || l_na_attrtab || ' (' || l_na_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
    SELECT ';
  body := body || 'natural_account_display_code, ''' || l_na_value_set ;
  body := body || ''', ''RECON_LEAF_NODE_FLAG'', ''Y'', ''LOAD'', ''Default''
    FROM fem_nat_accts_b
    WHERE value_set_id = ' || l_na_value_set_id || '
          AND natural_account_display_code NOT IN
               ( SELECT ' || l_na_col || '
                  FROM ' || l_na_b || '
                  WHERE value_set_id = ' || l_na_value_setid  || ' );' ;

  body := body || '
';
  body := body || '
   IF (SQL%ROWCOUNT <> 0) THEN
     FEM_DIM_MEMBER_LOADER_PKG.Main(
         errbuf => errbuf,
         retcode => retcode,
         p_execution_mode => ''S'',
         p_dimension_id => ' || na_obj_def_id || ';' ;

  body := body || '
';
   body := body || '
   dbms_output.put_line(''NA dim load status = ''|| retcode ); ';

  body := body || '
';

  body := body || '
         IF retcode = ''2'' THEN
           RAISE DIM_LOAD_ERROR;
         END IF;
       END IF ;
';


         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

END IF;  -- if na_req is Y


IF l_category_req = 'Y' THEN
  body:= 'INSERT INTO ' ||  l_category_btab || ' (' || l_category_col || ', value_set_display_code, status)
          SELECT ';
  body := body || 'category_code, ''' || l_cat_value_set || ''', ''LOAD''
          FROM gcs_categories_b
          WHERE category_code NOT IN
               ( SELECT ' || l_category_col || '
                  FROM ' || l_category_b || '
                  WHERE value_set_id = ' || l_cat_value_setid  || ' );' ;

  body := body || '
          INSERT INTO ' || l_category_tltab || ' (' || l_category_col || ', value_set_display_code, status, language, description, ';
  body := body || l_category_name || ')
          SELECT category_code, ''' || l_cat_value_set ;
  body := body || ''', ''LOAD'', userenv(''LANG''), description, category_name
          FROM gcs_categories_tl
          WHERE language = userenv(''LANG'')
           AND  category_code NOT IN
                ( SELECT ' || l_category_col || '
                  FROM ' || l_category_b || '
                  WHERE value_set_id = ' || l_cat_value_setid  || ' );' ;

        curr_pos := 1;
        body_len := LENGTH(body);
        WHILE curr_pos <= body_len LOOP
        ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
        curr_pos := curr_pos + g_line_size;
        r := r + 1;
        END LOOP;

  body := '
';
  body := body || 'INSERT INTO ' || l_cat_attrtab || ' (' || l_category_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
                   SELECT ';
  body := body || 'category_code, ''' || l_cat_value_set ;
  body := body || ''', ''SOURCE_SYSTEM_CODE'', ''GCS'', ''LOAD'', ''Default''
                   FROM gcs_categories_b
                   WHERE category_code NOT IN
                      ( SELECT ' || l_category_col || '
                        FROM ' || l_category_b || '
                        WHERE value_set_id = ' || l_cat_value_setid  || ' );' ;

  body := body || '
    INSERT INTO ' || l_cat_attrtab || ' (' || l_category_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
    SELECT ';
  body := body || 'category_code, ''' || l_cat_value_set ;
  body := body || ''', ''RECON_LEAF_NODE_FLAG'', ''Y'', ''LOAD'', ''Default''
    FROM gcs_categories_b
    WHERE category_code NOT IN
                      ( SELECT ' || l_category_col || '
                        FROM ' || l_category_b || '
                        WHERE value_set_id = ' || l_cat_value_setid  || ' );' ;

  body := body || '
';
  body := body || '
    IF (SQL%ROWCOUNT <> 0) THEN
      FEM_DIM_MEMBER_LOADER_PKG.Main(
         errbuf => errbuf,
         retcode => retcode,
         p_execution_mode => ''S'',
         p_dimension_id => ' || cat_obj_def_id || '); ' ;

 body := body || '
   dbms_output.put_line(''Category dim load status = ''|| retcode ); ';

  body := body || '
';

  body := body || '
         IF retcode = ''2'' THEN
           RAISE DIM_LOAD_ERROR;
         END IF;
       END IF;
';


  body := body || '
';


         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

END IF;  -- if category_req is Y


--Bugfix 5308890: This code will never be executed since l_interco_req has been hardcoded to 'N'
IF l_interco_req = 'Y' THEN
  body:= 'INSERT INTO ' ||  l_interco_btab || ' (' || l_interco_col || ', value_set_display_code, status)
          SELECT ';
  body := body || 'cctr_org_display_code, ''' || l_interco_value_set || ''', ''LOAD''
          FROM fem_cctr_orgs_b
          WHERE value_set_id = ' || l_interco_value_set_id || '
          AND cctr_org_display_code NOT IN
               ( SELECT ' || l_interco_col || '
                  FROM ' || l_interco_b || '
                  WHERE value_set_id = ' || l_interco_value_setid  || ' );' ;

  body := body || '
';

  body := body || '
          INSERT INTO ' || l_interco_tltab || ' (' || l_interco_col || ', value_set_display_code, status, language, description, ';
  body := body || l_interco_name || ')
          SELECT cctr_org_display_code, ''' || l_interco_value_set ;
  body := body || ''', ''LOAD'', userenv(''LANG''), description, company_cost_center_org_name
          FROM fem_cctr_orgs_vl
          WHERE value_set_id = ' || l_interco_value_set_id || '
          AND cctr_org_display_code NOT IN
               ( SELECT ' || l_interco_col || '
                  FROM ' || l_interco_b || '
                  WHERE value_set_id = ' || l_interco_value_setid  || ' );' ;

        curr_pos := 1;
        body_len := LENGTH(body);
        WHILE curr_pos <= body_len LOOP
        ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
        curr_pos := curr_pos + g_line_size;
        r := r + 1;
        END LOOP;

  body := body || '
';


  body := 'INSERT INTO ' || l_interco_attrtab || ' (' || l_interco_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
           SELECT ';
  body := body || 'cctr_org_display_code, ''' || l_interco_value_set ;
  body := body || ''', ''SOURCE_SYSTEM_CODE'', ''GCS'', ''LOAD'', ''Default''
           FROM fem_cctr_orgs_b
           WHERE value_set_id = ' || l_interco_value_set_id || '
          AND cctr_org_display_code NOT IN
               ( SELECT ' || l_interco_col || '
                  FROM ' || l_interco_b || '
                  WHERE value_set_id = ' || l_interco_value_setid  || ' );' ;

  body := body || '
';

  body := body || '
    INSERT INTO ' || l_interco_attrtab || ' (' || l_interco_col ;
  body := body || ', value_set_display_code, attribute_varchar_label, attribute_assign_value, status, version_display_code)
    SELECT ';
  body := body || 'cctr_org_display_code, ''' || l_interco_value_set ;
  body := body || ''', ''RECON_LEAF_NODE_FLAG'', ''Y'', ''LOAD'', ''Default''
    FROM fem_cctr_orgs_b
    WHERE value_set_id = ' || l_interco_value_set_id || '
          AND cctr_org_display_code NOT IN
               ( SELECT ' || l_interco_col || '
                  FROM ' || l_interco_b || '
                  WHERE value_set_id = ' || l_interco_value_setid  || ' );' ;

  body := body || '
';
  body := body || '
    IF (SQL%ROWCOUNT <> 0) THEN
      FEM_DIM_MEMBER_LOADER_PKG.Main(
         errbuf => errbuf,
         retcode => retcode,
         p_execution_mode => ''S'',
         p_dimension_id => ' || interco_obj_def_id || '); ' ;

   body := body || '
   dbms_output.put_line(''Intercompany dim load status = ''|| retcode ); ';

  body := body || '
';

  body := body || '
         IF retcode = ''2'' THEN
           RAISE DIM_LOAD_ERROR;
         END IF;
       END IF;
';

  body := body || '
';


         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

END IF;  -- if interco_req is Y

body:=
'
     EXCEPTION

       WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DIM_TR_PKG.GCS_EPB_TR_DIM'', ''GCS_NO_DATA_FOUND'');
         END IF;
         retcode := ''0'';
         errbuf := ''GCS_NO_DATA_FOUND'';
         RAISE NO_DATA_FOUND;

       WHEN DIM_LOAD_ERROR THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DIM_TR_PKG.GCS_EPB_TR_DIM'', ''GCS_DIM_LOAD_ERROR'');
         END IF;
         retcode := ''0'';
         FND_FILE.PUT_LINE(FND_FILE.LOG, '' Dimension Load Error - '' || errbuf );
         RAISE;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DIM_TR_PKG.GCS_EPB_TR_DIM'', errbuf);
         END IF;
         retcode := ''0'';
         RAISE;


  END Gcs_Epb_Tr_Dim;

END GCS_DYN_EPB_DIMTR_PKG;
';
       curr_pos := 1;
       body_len := LENGTH(body);
       WHILE curr_pos <= body_len LOOP
       ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
       curr_pos := curr_pos + g_line_size;
       r := r + 1;
       END LOOP;

    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', 'GCS_DYN_EPB_DIMTR_PKG',1, r - 1, 'FALSE', err);

    -- dbms_output.put_line('Error' || AD_DDL.error_buf);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'GCS_BUILD_EPB_DIMTR_PKG' || '.' || 'BUILD_EPB_DIMTR_PKG',
                     GCS_UTILITY_PKG.g_module_success || 'BUILD_EPB_DIMTR_PKG' ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success || 'BUILD_EPB_DIMTR_PKG' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'GCS_BUILD_EPB_DIM_TR_PKG' || '.' || 'BUILD_EPB_DIMTR_PKG',
                       SUBSTR(SQLERRM, 1, 255));
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'GCS_BUILD_EPB_DIM_TR_PKG' || '.' || 'BUILD_EPB_DIMTR_PKG',
                       GCS_UTILITY_PKG.g_module_failure || 'BUILD_EPB_DIMTR_PKG' ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
                        'BUILD_EPB_DIMTR_PKG' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  END build_epb_dimtr_pkg;

  FUNCTION get_obj_def_id ( num  VARCHAR2) RETURN NUMBER IS

    obj_def_id NUMBER;
  BEGIN

   IF (num = '1') THEN
     obj_def_id := 19;
     -- obj_def_id :=  1211;
   ELSIF (num = '2') THEN
    obj_def_id := 20;
     -- obj_def_id :=  1212;
   ELSIF (num = '3') THEN
     obj_def_id := 21;
     -- obj_def_id := 1213;
   ELSIF (num = '4') THEN
    obj_def_id := 22;
    -- obj_def_id := 1214;
   ELSIF (num = '5') THEN
    obj_def_id := 23;
    -- obj_def_id := 1215;
   ELSIF (num = '6') THEN
    obj_def_id := 24;
    -- obj_def_id := 1216;
   ELSIF (num = '7') THEN
    obj_def_id := 25;
    -- obj_def_id := 1217;
   ELSIF (num = '8') THEN
    obj_def_id := 26;
    -- obj_def_id := 1218;
   ELSIF (num = '9') THEN
    obj_def_id := 27;
    -- obj_def_id := 1219;
   END IF;

   RETURN obj_def_id;
  END get_obj_def_id;

END GCS_BUILD_EPB_DIM_TR_PKG;

/
