--------------------------------------------------------
--  DDL for Package Body GCS_BUILD_EPB_DATA_TR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_BUILD_EPB_DATA_TR_PKG" AS
/* $Header: gcsepbtrdatab.pls 120.10 2007/12/13 11:56:54 cdesouza noship $ */
--
-- Package
--   build_epb_datatr_pkg
-- Purpose
--   Creates GCS_DYN_FEM_POSTING_PKG
-- History
--   12-MAR-04	R Goyal		Created
--
--

--
-- Public procedures
--
  PROCEDURE build_epb_datatr_pkg IS

    -- row number to be used in dynamically creating the package
    r		NUMBER := 1;
    body        VARCHAR2(10000);
    tempbuf        VARCHAR2(1000);
    from_clause    VARCHAR2(1000);
    where_clause   VARCHAR2(1000);
    groupby_clause VARCHAR2(1000);

    body_len    NUMBER;
    curr_pos    NUMBER;
    line_num    NUMBER := 1;
    err		VARCHAR2(2000);

    -- Store the data table
    l_data_table     VARCHAR2(30);

    -- Store whether a dimension is used by GCS
    l_cctr_req  VARCHAR2(1);
    l_interco_req VARCHAR2(1);
    l_interco_tab VARCHAR2(30);
    l_interco_col VARCHAR2(30);
    l_interco_id  VARCHAR2(30);
    l_felm_req  VARCHAR2(1);
    l_felm_tab  VARCHAr2(30);
    l_felm_col  VARCHAR2(30);
    l_felm_id VARCHAR2(30);
    l_prd_req   VARCHAR2(1);
    l_na_req    VARCHAR2(1);
    l_na_tab    VARCHAR2(30);
    l_na_col    VARCHAR2(30);
    l_na_id     VARCHAR2(30);
    l_chl_req   VARCHAR2(1);
    l_prj_req   VARCHAR2(1);
    l_cst_req   VARCHAR2(1);
    l_tsk_req   VARCHAR2(1);
    l_ud1_req   VARCHAR2(1);
    l_ud2_req   VARCHAR2(1);
    l_ud3_req   VARCHAR2(1);
    l_ud4_req   VARCHAR2(1);
    l_ud5_req   VARCHAR2(1);
    l_ud6_req   VARCHAR2(1);
    l_ud7_req   VARCHAR2(1);
    l_ud8_req   VARCHAR2(1);
    l_ud9_req   VARCHAR2(1);
    l_ud10_req  VARCHAR2(1);
    l_category_req  VARCHAR2(1);
    l_category_tab  VARCHAR2(30);
    l_category_col  VARCHAR2(30);
    l_category_id   VARCHAR2(30);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'GCS_BUILD_FEM_POSTING_PKG' || '.' || 'BUILD_EPB_DATATR_PKG',
                     GCS_UTILITY_PKG.g_module_enter || 'BUILD_EPB_DATATR_PKG' ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter || 'BUILD_EPB_DATATR_PKG' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));


     -- Set the epb table name
     SELECT epb_table_name
       INTO l_data_table
       FROM GCS_SYSTEM_OPTIONS;

     -- Set the required flags
     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10)
       INTO l_felm_req, l_felm_tab
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'FINANCIAL_ELEM_ID';
     exception
       when no_data_found then
         l_felm_req := 'N';
     end;

     --Bugfix 5308890: Comment out this portion of the code as no mapping is required for financial element
     -- Set the table names, column names and column id's to be used in the main sql
     /*
     IF substr(l_felm_tab,14) <> '0' THEN
        l_felm_tab := substr(l_felm_tab, 0, 13) || '_B';
        l_felm_col := substr(l_felm_tab, 5, 9) || '_DISPLAY_CODE';
        l_felm_id  := substr(l_felm_tab, 5, 9) || '_ID';
     ELSE
        l_felm_tab := l_felm_tab || '_B';
        l_felm_col := substr(l_felm_tab, 5, 10) || '_DISPLAY_CODE';
        l_felm_id := substr(l_felm_tab, 5, 10) || '_ID';
     END IF;
     */

     begin
     SELECT enabled_flag
       INTO l_cctr_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'COMPANY_COST_CENTER_ORG_ID';
     exception
       when no_data_found then
         l_cctr_req := 'N';
     end;

     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10)
       INTO l_interco_req, l_interco_tab
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'INTERCOMPANY_ID';
     exception
       when no_data_found then
         l_interco_req := 'N';
     end;

     --Bugfix 5308890: Comment out this portion of the code as no mapping is required for intercompany
     /*
      IF substr(l_interco_tab,14) <> '0' THEN
        l_interco_tab := substr(l_interco_tab, 0, 13) || '_B';
        l_interco_col := substr(l_interco_tab, 5, 9) || '_DISPLAY_CODE';
        l_interco_id  := substr(l_interco_tab, 5, 9) || '_ID';
      ELSE
        l_interco_tab := l_interco_tab || '_B';
        l_interco_col := substr(l_interco_tab, 5, 10) || '_DISPLAY_CODE';
        l_interco_id := substr(l_interco_tab, 5, 10) || '_ID';
      END IF;
     */

     begin
     SELECT enabled_flag
       INTO l_prd_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'PRODUCT_ID';
     exception
       when no_data_found then
         l_prd_req := 'N' ;
     end;

     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10)
       INTO l_na_req, l_na_tab
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'NATURAL_ACCOUNT_ID';
     exception
       when no_data_found then
         l_na_req := 'N' ;
     end;

     --Bugfix 5308890: Comment out this portion of the code as mapping is not required for natural account
     /*
      IF substr(l_na_tab,14) <> '0' THEN
        l_na_tab := substr(l_na_tab, 0, 13) || '_B';
        l_na_col := substr(l_na_tab, 5, 9) || '_DISPLAY_CODE';
        l_na_id  := substr(l_na_tab, 5, 9) || '_ID';
      ELSE
        l_na_tab := l_na_tab || '_B';
        l_na_col := substr(l_na_tab, 5, 10) || '_DISPLAY_CODE';
        l_na_id := substr(l_na_tab, 5, 10) || '_ID';
      END IF;
     */

     begin
     SELECT enabled_flag
       INTO l_chl_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'CHANNEL_ID';
     exception
       when no_data_found then
         l_chl_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_prj_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'PROJECT_ID';
     exception
       when no_data_found then
         l_prj_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_cst_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'CUSTOMER_ID';
     exception
       when no_data_found then
         l_cst_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_tsk_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'TASK_ID';
    exception
       when no_data_found then
         l_tsk_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud1_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM1_ID';
     exception
       when no_data_found then
         l_ud1_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud2_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM2_ID';
     exception
       when no_data_found then
         l_ud2_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud3_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM3_ID';
     exception
       when no_data_found then
         l_ud3_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud4_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM4_ID';
     exception
       when no_data_found then
         l_ud4_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud5_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM5_ID';
     exception
       when no_data_found then
         l_ud5_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud6_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM6_ID';
     exception
       when no_data_found then
         l_ud6_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud7_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM7_ID';
     exception
       when no_data_found then
         l_ud7_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud8_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM8_ID';
     exception
       when no_data_found then
         l_ud8_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud9_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM9_ID';
     exception
       when no_data_found then
         l_ud9_req := 'N' ;
     end;

     begin
     SELECT enabled_flag
       INTO l_ud10_req
       FROM GCS_EPB_DIM_MAPS
      WHERE gcs_column = 'USER_DIM10_ID';
     exception
       when no_data_found then
         l_ud10_req := 'N' ;
     end;

     begin
     SELECT enabled_flag, 'FEM_' || substr(epb_column,0, 10)
       INTO l_category_req, l_category_tab
       FROM GCS_EPB_DIM_MAPS
      --Bugfix 4291225: The column name is CREATED_BY_OBJECT_ID
      WHERE gcs_column = 'CREATED_BY_OBJECT_ID';
     exception
       when no_data_found then
         l_category_req := 'N' ;
     end;

     IF substr(l_category_tab,14) <> '0' THEN
        l_category_tab := substr(l_category_tab, 0, 13) || '_B';
        l_category_col := substr(l_category_tab, 5, 9) || '_DISPLAY_CODE';
        l_category_id  := substr(l_category_tab, 5, 9) || '_ID';
     ELSE
        l_category_tab := l_category_tab || '_B';
        l_category_col := substr(l_category_tab, 5, 10) || '_DISPLAY_CODE';
        l_category_id := substr(l_category_tab, 5, 10) || '_ID';
     END IF;



     -- Create the package body
body:=
'CREATE OR REPLACE PACKAGE BODY GCS_DYN_EPB_DATATR_PKG AS


/* $Header: gcsepbtrdatab.pls 120.10 2007/12/13 11:56:54 cdesouza noship $ */
     -- Store the log level
     runtimeLogLevel     NUMBER := FND_LOG.g_current_runtime_level;
     statementLogLevel   CONSTANT NUMBER := FND_LOG.level_statement;
     procedureLogLevel   CONSTANT NUMBER := FND_LOG.level_procedure;
     exceptionLogLevel   CONSTANT NUMBER := FND_LOG.level_exception;
     errorLogLevel       CONSTANT NUMBER := FND_LOG.level_error;
     unexpectedLogLevel  CONSTANT NUMBER := FND_LOG.level_unexpected;

     g_src_sys_code NUMBER := GCS_UTILITY_PKG.g_gcs_source_system_code;
     -- bugfix 5569522: Added for FND logging.
     g_api	 VARCHAR2(200)  :=	''gcs.plsql.GCS_DYN_EPB_DATATR_PKG'';

   -- bugfix 5569522: Added p_analysis_cycle_id parameter for launching business
   -- process.
   PROCEDURE Gcs_Epb_Tr_Data (
		errbuf       OUT NOCOPY VARCHAR2,
		retcode      OUT NOCOPY VARCHAR2,
		p_hierarchy_id          NUMBER,
		p_balance_type_code     VARCHAR2,
		p_cal_period_id         NUMBER,
        p_analysis_cycle_id     NUMBER) IS

	l_dataset_code      NUMBER;
        l_target_dataset_code NUMBER := -1;
	l_ledger_id         NUMBER;
	l_object_id         NUMBER;
        l_object_def_id     NUMBER;
        l_ln_item_hier_id   NUMBER;
        l_ln_item_obj_id    NUMBER;
        l_top_curr          VARCHAR2(15);
        l_dataset_dsp_code  VARCHAR2(150);

        errcode NUMBER;
        msgnum  VARCHAR2(1000);
        return_status VARCHAR2(10);

        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(2000);
        l_return_status    VARCHAR2(1);
        l_exec_state       VARCHAr2(30);
        l_prev_req_id      NUMBER;
        l_ret_status       BOOLEAN;

        l_req_id   NUMBER := FND_GLOBAL.conc_request_id;
        l_login_id NUMBER := FND_GLOBAL.login_id;
        l_user_id  NUMBER := FND_GLOBAL.user_id;

        l_end_date_attribute_id	NUMBER	:=	gcs_utility_pkg.g_dimension_attr_info(''CAL_PERIOD_ID-CAL_PERIOD_END_DATE'').attribute_id;
        l_end_date_version_id	NUMBER	:=	gcs_utility_pkg.g_dimension_attr_info(''CAL_PERIOD_ID-CAL_PERIOD_END_DATE'').version_id;


	l_ext_acct_type_attr_id		NUMBER	:=	gcs_utility_pkg.g_dimension_attr_info(''LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE'').attribute_id;
	l_ext_acct_type_version_id	NUMBER	:=	gcs_utility_pkg.g_dimension_attr_info(''LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE'').version_id;
	l_basic_acct_type_attr_id	NUMBER	:=	gcs_utility_pkg.g_dimension_attr_info(''EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE'').attribute_id;
	l_basic_acct_type_version_id	NUMBER	:=	gcs_utility_pkg.g_dimension_attr_info(''EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE'').version_id;

        l_end_date	DATE;

	module	  VARCHAR2(30) := ''GCS_EPB_TR_DATA'';

        --Exception handlers: everything that can go wrong here
        NO_DATASET_CREATED    EXCEPTION;
        DIM_TRANSFER_FAILED   EXCEPTION;

        --Bugfix 5526501: Added row count variable to store number of rows transferred
        l_row_count NUMBER(15);

   BEGIN

     runtimeLogLevel := FND_LOG.g_current_runtime_level;

     IF (procedureloglevel >= runtimeloglevel ) THEN
    	 FND_LOG.STRING(procedureloglevel, ''gcs.plsql.gcs_epb_data_tr_pkg.gcs_epb_tr_data.begin'' || GCS_UTILITY_PKG.g_module_enter, to_char(sysdate, ''DD-MON-YYYY HH:MI:SS''));
     END IF;
     IF (statementloglevel >= runtimeloglevel ) THEN
         FND_LOG.STRING(statementloglevel, ''gcs.plsql.gcs_epb_data_tr_pkg.gcs_epb_tr_data'', ''p_hierarchy_id = '' || to_char(p_hierarchy_id));
         FND_LOG.STRING(statementloglevel, ''gcs.plsql.gcs_epb_data_tr_pkg.gcs_epb_tr_data'', ''p_balance_type_code = '' || p_balance_type_code);
         FND_LOG.STRING(statementloglevel, ''gcs.plsql.gcs_epb_data_tr_pkg.gcs_epb_tr_data'', ''p_cal_period_id = '' || to_char(p_cal_period_id));
         FND_LOG.STRING(statementloglevel, ''gcs.plsql.gcs_epb_data_tr_pkg.gcs_epb_tr_data'', ''p_analysis_cycle_id = '' || to_char(p_analysis_cycle_id));
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter || ''Gcs_Epb_Tr_Data'' || to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
     FND_FILE.PUT_LINE(FND_FILE.LOG, '' p_hierarchy_id = '' || to_char(p_hierarchy_id));
     FND_FILE.PUT_LINE(FND_FILE.LOG, '' p_balance_type = '' || p_balance_type_code );
     FND_FILE.PUT_LINE(FND_FILE.LOG, '' p_cal_period_id = '' || to_char(p_cal_period_id) );
     FND_FILE.PUT_LINE(FND_FILE.LOG, '' p_analysis_cycle_id = '' || to_char(p_analysis_cycle_id) );
';

         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

body:=
'    -- Call Dimension transfer program
     GCS_DYN_EPB_DIMTR_PKG.Gcs_Epb_Tr_Dim(errbuf, retcode);

     FND_FILE.PUT_LINE(FND_FILE.LOG, '' Call Dimension Transfer '');

     IF (statementloglevel >= runtimeloglevel ) THEN
         FND_LOG.STRING(statementloglevel, ''gcs.plsql.gcs_epb_data_tr_pkg.gcs_epb_tr_data'', ''Called Dimension Transfer '');
     END IF;

     IF retcode = ''0'' THEN
       RAISE DIM_TRANSFER_FAILED;
     END IF;

     --Bugfix 5111721: Removed code to get the dataset code

     -- get the top entity and currency
     SELECT currency_code
       INTO l_top_curr
       FROM gcs_hierarchies_b hier,
            gcs_entity_cons_attrs attr
       WHERE hier.hierarchy_id = p_hierarchy_id
         AND attr.hierarchy_id = hier.hierarchy_id
         AND attr.entity_id = hier.top_entity_id;

     --Bugfix 4655571: The top currency is no longer required since EPB should support reporting on currency as a dimension

     FND_FILE.PUT_LINE(FND_FILE.LOG, '' Top Currency = '' || l_top_curr );

     -- get line item hierarchy id
     SELECT ln_item_hierarchy_obj_id
       INTO l_ln_item_obj_id
       FROM GCS_SYSTEM_OPTIONS;


     --Bugfix 5111721: Removed the concatenation of PTD with dataset code
     --Also modified the select statement

     begin
      SELECT dataset_code
      INTO   l_dataset_code
      FROM   gcs_dataset_codes
      WHERE  hierarchy_id         = p_hierarchy_id
      AND    balance_type_code    = p_balance_type_code;

      SELECT dataset_code
      INTO   l_target_dataset_code
      FROM   gcs_dataset_codes
      WHERE  hierarchy_id         = p_hierarchy_id
      AND    balance_type_code    = ''ANALYZE_'' || p_balance_type_code;
    exception
     WHEN NO_DATA_FOUND THEN
	l_target_dataset_code := -1;
     end;

     /*
     -- If dataset for EPB does not exist, create a the target dataset
     IF (l_target_dataset_code = -1) THEN
       FEM_DIMENSION_UTIL_PKG.new_dataset(
         p_display_code => l_dataset_dsp_code,
         p_dataset_name => l_dataset_dsp_code,
         p_bal_type_cd => ''ACTUAL'',
         p_api_version => 1,
         P_INIT_MSG_LIST => ''F'',
         P_COMMIT => ''F'',
         P_ENCODED => ''F'',
         p_source_cd => g_src_sys_code,
         p_pft_w_flg => ''Y'',
         p_prod_flg => ''Y'',
         p_budget_id => NULL,
         p_enc_type_id => NULL,
         p_ver_name => ''Default'',
         p_ver_disp_cd => ''Default'',
         p_dataset_desc => l_dataset_dsp_code,
         x_msg_count => errcode,
         x_msg_data => msgnum,
         x_return_status => return_status);
      SELECT dataset_code
        INTO l_target_dataset_code
        FROM FEM_DATASETS_B
        WHERE DATASET_DISPLAY_CODE = l_dataset_dsp_code;
      END IF;
      */

      IF l_target_dataset_code = -1 THEN
        RAISE NO_DATASET_CREATED;
      END IF;

     -- get ledger_id
     SELECT fem_ledger_id
     INTO l_ledger_id
     FROM GCS_HIERARCHIES_B
     WHERE hierarchy_id = p_hierarchy_id;

     -- Get the end date of the period
     SELECT 	date_assign_value
     INTO	l_end_date
     FROM 	fem_cal_periods_attr
     WHERE	cal_period_id	= 	p_cal_period_id
     AND	attribute_id	=	l_end_date_attribute_id
     AND	version_id	=	l_end_date_version_id;

     -- Get the Line Item hierarchy id based on the object id
     -- Bugfix: 4655571: Commenting out selection of the hierarchy since EPBv2 supports Hierarchial Total
     --		SELECT object_definition_id
     --  	INTO l_ln_item_hier_id
     --  	FROM FEM_OBJECT_DEFINITION_B
     -- 	WHERE object_id = l_ln_item_obj_id
     --   	AND l_end_date BETWEEN effective_start_date and effective_end_date;

     FND_FILE.PUT_LINE(FND_FILE.LOG, '' cal_period_id = '' || to_char(p_cal_period_id));

      -- Get object_id
     SELECT associated_object_id
       INTO l_object_id
       FROM GCS_CATEGORIES_B
       WHERE category_code = ''AGGREGATION'';
';
        curr_pos := 1;
        body_len := LENGTH(body);
        WHILE curr_pos <= body_len LOOP
        ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
        curr_pos := curr_pos + g_line_size;
        r := r + 1;
        END LOOP;

body:=
'-- Get object definition id
     SELECT object_definition_id
      INTO l_object_def_id
      FROM fem_object_definition_b
     WHERE object_id = l_object_id;

     -- Delete data from FEM_DATA11 before inserting
     -- Bugfix 4286024 : Added table name dynamically
     DELETE FROM ' || l_data_table  ||  '
     WHERE dataset_code = l_target_dataset_code
       AND cal_period_id = p_cal_period_id;
';
        curr_pos := 1;
        body_len := LENGTH(body);
        WHILE curr_pos <= body_len LOOP
        ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
        curr_pos := curr_pos + g_line_size;
        r := r + 1;
        END LOOP;

body:='
INSERT INTO ' || l_data_table;

tempbuf :=
'  (
         DATASET_CODE,
         CAL_PERIOD_ID,
         SOURCE_SYSTEM_CODE,
         LEDGER_ID,
         CURRENCY_CODE,
         LINE_ITEM_ID,
         ENTITY_ID,
         CREATED_BY_OBJECT_ID,
';

body := body || tempbuf;

         IF (l_felm_req = 'Y') THEN
           --Bugfix 5308890: Removing the variable assignment and hard-coding FINANCIAL_ELEM_ID
           body := body || 'FINANCIAL_ELEM_ID ,' ;
         END IF;
         IF (l_prd_req = 'Y') THEN
           body := body || 'PRODUCT_ID, ';
         END IF;
         IF (l_cctr_req = 'Y') THEN
           body := body || 'COMPANY_COST_CENTER_ORG_ID, ';
          END IF;
         IF (l_interco_req = 'Y') THEN
           --Bugfix 5308890: Removing the variable assignment and hard-coding INTERCOMPANY_ID
           body := body || 'INTERCOMPANY_ID ,' ;
          END IF;
         IF (l_na_req = 'Y') THEN
           --Bugfix 5308890: Removing the variable assignment and hard-coding NATURAL_ACCOUNT_ID
           body := body ||  'NATURAL_ACCOUNT_ID ,' ;
         END IF;
         IF (l_chl_req = 'Y') THEN
           body := body ||  'CHANNEL_ID, ';
         END IF;
         IF (l_prj_req = 'Y') THEN
            body := body || 'PROJECT_ID, ';
         END IF;
         IF (l_cst_req = 'Y') THEN
           body := body ||  'CUSTOMER_ID, ';
         END IF;
         IF (l_tsk_req = 'Y') THEN
            body := body || 'TASK_ID, ';
         END IF;
         IF (l_ud1_req = 'Y') THEN
            body := body || 'USER_DIM1_ID, ';
         END IF;
         IF (l_ud2_req = 'Y') THEN
            body := body || 'USER_DIM2_ID, ';
         END IF;
         IF (l_ud3_req = 'Y') THEN
             body := body || 'USER_DIM3_ID, ';
         END IF;
         IF (l_ud4_req = 'Y') THEN
            body := body || 'USER_DIM4_ID, ';
         END IF;
         IF (l_ud5_req = 'Y') THEN
             body := body || 'USER_DIM5_ID, ';
         END IF;
         IF (l_ud6_req = 'Y') THEN
             body := body || 'USER_DIM6_ID, ';
         END IF;
         IF (l_ud7_req = 'Y') THEN
             body := body || 'USER_DIM7_ID, ';
          END IF;
         IF (l_ud8_req = 'Y') THEN
             body := body || 'USER_DIM8_ID, ';
         END IF;
         IF (l_ud9_req = 'Y') THEN
              body := body || 'USER_DIM9_ID, ';
         END IF;
         IF (l_ud10_req = 'Y') THEN
              body := body || 'USER_DIM10_ID, ';
         END IF;
         IF (l_category_req = 'Y') THEN
              body := body || l_category_id || ',' ;
         END IF;

tempbuf :=
'
         CREATED_BY_REQUEST_ID ,
         LAST_UPDATED_BY_REQUEST_ID,
         LAST_UPDATED_BY_OBJECT_ID,
         NUMERIC_MEASURE)
       SELECT
         l_target_dataset_code,
         p_cal_period_id,
         g_src_sys_code,
         LEDGER_ID,
         CURRENCY_CODE,
         LINE_ITEM_ID,
         ENTITY_ID,
';

body := body || tempbuf;

         IF ( l_category_req = 'Y') THEN
           body := body ||  'CREATED_BY_OBJECT_ID, ';
         ELSE
           body := body ||  'max(CREATED_BY_OBJECT_ID), ';
         END IF;
         IF (l_felm_req = 'Y') THEN
           --Bugfix 5308890: Removing variable assignment and hard-coding column name
           body := body || 'FINANCIAL_ELEM_ID ,' ;
         END IF;
         IF (l_prd_req = 'Y') THEN
           body := body ||  'PRODUCT_ID, ';
         END IF;
         IF (l_cctr_req = 'Y') THEN
           body := body || 'FB.COMPANY_COST_CENTER_ORG_ID, ';
         END IF;
         IF (l_interco_req = 'Y') THEN
           --Bugfix 5308890: Removing variable assignment and hard-coding column name
           body := body || 'INTERCOMPANY_ID , ' ;
         END IF;
         IF (l_na_req = 'Y') THEN
           --Bugfix 5308890: Removing variable assignment and hard-coding column_name
           body := body || 'NATURAL_ACCOUNT_ID, ' ;
         END IF;
         IF (l_chl_req = 'Y') THEN
           body := body || 'CHANNEL_ID, ';
         END IF;
         IF (l_prj_req = 'Y') THEN
           body := body || 'PROJECT_ID, ';
         END IF;
         IF (l_cst_req = 'Y') THEN
           body := body || 'CUSTOMER_ID, ';
         END IF;
         IF (l_tsk_req = 'Y') THEN
           body := body || 'TASK_ID, ';
         END IF;
         IF (l_ud1_req = 'Y') THEN
           body := body || 'USER_DIM1_ID, ';
         END IF;
         IF (l_ud2_req = 'Y') THEN
           body := body || 'USER_DIM2_ID, ';
         END IF;
         IF (l_ud3_req = 'Y') THEN
           body := body || 'USER_DIM3_ID, ';
         END IF;
         IF (l_ud4_req = 'Y') THEN
           body := body || 'USER_DIM4_ID, ';
         END IF;
         IF (l_ud5_req = 'Y') THEN
           body := body || 'USER_DIM5_ID, ';
         END IF;
         IF (l_ud6_req = 'Y') THEN
            body := body || 'USER_DIM6_ID, ';
         END IF;
         IF (l_ud7_req = 'Y') THEN
            body := body || 'USER_DIM7_ID, ';
         END IF;
         IF (l_ud8_req = 'Y') THEN
            body := body || 'USER_DIM8_ID, ';
         END IF;
         IF (l_ud9_req = 'Y') THEN
            body := body || 'USER_DIM9_ID, ';
         END IF;
         IF (l_ud10_req = 'Y') THEN
            body := body || 'USER_DIM10_ID, ';
         END IF;
         IF (l_category_req = 'Y') THEN
            body := body || 'CATDIM.' || l_category_id || ',' ;
         END IF;

tempbuf:=
'
         max(CREATED_BY_REQUEST_ID) ,
         max(LAST_UPDATED_BY_REQUEST_ID),
         max(LAST_UPDATED_BY_OBJECT_ID),
         sum(xtd_balance_e)
     FROM FEM_BALANCES FB ';

body := body || tempbuf;

where_clause := '
-- Bugfix 4655571: Modifying the where clause to remove the currency code condition since EPBv2 should support multiple currencies
WHERE /* FB.currency_code = l_top_curr AND */ FB.source_system_code = g_src_sys_code AND ';

       IF ( l_category_req = 'Y') THEN
          from_clause := from_clause || ',' || l_category_tab || ' CATDIM, GCS_CATEGORIES_B CATB';
          where_clause := where_clause || 'CATDIM.' || l_category_col || '= CATB.category_code AND FB.created_by_object_id = CATB.associated_object_id AND ';
       END IF;

       --Bugfix 5308890: The next three where clauses are no longer required since EPB supports those dimensions natively now
       /*
       IF ( l_interco_req = 'Y') THEN
          from_clause := from_clause || ',' || l_interco_tab || ' INTERCODIM, FEM_CCTR_ORGS_B ORG';
          where_clause := where_clause || 'INTERCODIM.' || l_interco_col || '= ORG.cctr_org_display_code AND FB.intercompany_id = ORG.company_cost_center_org_id AND ';
       END IF;

       IF ( l_felm_req = 'Y') THEN
          from_clause := from_clause || ',' || l_felm_tab || ' FELMDIM, FEM_FIN_ELEMS_B FE';
          where_clause := where_clause || 'FELMDIM.' || l_felm_col || '= FE.financial_elem_display_code AND FB.financial_elem_id = FE.financial_elem_id AND ';
       END IF;

       IF ( l_na_req = 'Y') THEN
          from_clause := from_clause || ',' || l_na_tab || ' NADIM, FEM_NAT_ACCTS_B ACCT';
          where_clause := where_clause || 'NADIM.' || l_na_col || '= ACCT.natural_account_display_code AND FB.natural_account_id = ACCT.natural_account_id AND ';
       END IF;
       */

       where_clause := where_clause || 'FB.dataset_code = l_dataset_code AND FB.cal_period_id = p_cal_period_id ';

       body := body || from_clause;

       body := body || where_clause;

       groupby_clause := '
GROUP BY FB.currency_code, FB.entity_id, FB.line_item_id, FB.ledger_id ';

       --Bugfix 5308890: Remove variable assignment and hard-code column name
       IF (l_felm_req = 'Y') THEN
         groupby_clause := groupby_clause || ', FINANCIAL_ELEM_ID' ;
       END IF;
       IF (l_category_req = 'Y') THEN
         groupby_clause := groupby_clause || ', FB.created_by_object_id' ;
       END IF;
       IF (l_prd_req = 'Y') THEN
         groupby_clause := groupby_clause || ', PRODUCT_ID' ;
       END IF;
       IF (l_cctr_req = 'Y') THEN
         groupby_clause := groupby_clause || ', FB.COMPANY_COST_CENTER_ORG_ID' ;
       END IF;
       --Bugfix 5308890: Remove variable assignment and hard-code column name
       IF (l_interco_req = 'Y') THEN
         groupby_clause := groupby_clause || ', INTERCOMPANY_ID' ;
       END IF;
       --Bugfix 5308890: Remove variable assignment and hard-code column name
       IF (l_na_req = 'Y') THEN
         groupby_clause := groupby_clause || ', NATURAL_ACCOUNT_ID' ;
       END IF;
       IF (l_chl_req = 'Y') THEN
          groupby_clause := groupby_clause || ', CHANNEL_ID ' ;
       END IF;
       IF (l_prj_req = 'Y') THEN
          groupby_clause := groupby_clause || ', PROJECT_ID ';
       END IF;
       IF (l_cst_req = 'Y') THEN
          groupby_clause := groupby_clause || ', CUSTOMER_ID ';
       END IF;
       IF (l_tsk_req = 'Y') THEN
          groupby_clause := groupby_clause || ', TASK_ID ';
       END IF;
       IF (l_ud1_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM1_ID ';
       END IF;
       IF (l_ud2_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM2_ID ';
       END IF;
       IF (l_ud3_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM3_ID ';
       END IF;
       IF (l_ud4_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM4_ID ';
       END IF;
       IF (l_ud5_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM5_ID ';
       END IF;
       IF (l_ud6_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM6_ID ';
       END IF;
       IF (l_ud7_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM7_ID ';
       END IF;
       IF (l_ud8_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM8_ID ';
       END IF;
       IF (l_ud9_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM9_ID ';
       END IF;
       IF (l_ud10_req = 'Y') THEN
          groupby_clause := groupby_clause || ', USER_DIM10_ID ';
       END IF;
       IF (l_category_req = 'Y') THEN
           groupby_clause := groupby_clause || ', CATDIM.' || l_category_id ;
       END IF;


   body := body || groupby_clause || ';' ;


         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

body:=
'
     l_row_count := SQL%ROWCOUNT;

     FND_FILE.PUT_LINE(FND_FILE.LOG, '' Rows inserted into data table = '' || l_row_count);


     IF (l_row_count <> 0) THEN
       -- Write to FEM_DATA_LOCATIONS
       FEM_DIMENSION_UTIL_PKG.Register_Data_Location
                 (P_REQUEST_ID  => -1,
                  P_OBJECT_ID   => l_object_id,
                  --Bugfix 4286024: Fixed hardcoding of FEM_DATA11
                  P_TABLE_NAME  => ''' || l_data_table || ''',
                  P_LEDGER_ID   => l_ledger_id,
                  P_CAL_PER_ID  => p_cal_period_id,
                  P_DATASET_CD  => l_target_dataset_code,
                  P_SOURCE_CD   => g_src_sys_code,
                  P_LOAD_STATUS => ''COMPLETE'');

       --Bugfix 5526501: Removing all commented code for table registration
       --Putting update statement within if..then statement
';

         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;

body := '--Bugfix 4655571: Removing code block to aggregate up a hierarchy since it is no longer useful with EPBv2';

         curr_pos := 1;
         body_len := LENGTH(body);
         WHILE curr_pos <= body_len LOOP
         ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
         curr_pos := curr_pos + g_line_size;
         r := r + 1;
         END LOOP;


body:=
'
        UPDATE	' || l_data_table || ' data_table
        SET	data_table.numeric_measure		=	numeric_measure * -1
	WHERE 	data_table.dataset_code			=	l_target_dataset_code
	AND	data_table.cal_period_id		=	p_cal_period_id
	AND	EXISTS		(			SELECT 	''X''
							FROM  	fem_ln_items_attr 		flia,
								fem_ext_acct_types_attr		feata
							WHERE	data_table.line_item_id		=	flia.line_item_id
							AND	flia.attribute_id		=	l_ext_acct_type_attr_id
							AND	flia.version_id			=	l_ext_acct_type_version_id
							AND	feata.attribute_id		=	l_basic_acct_type_attr_id
							AND	feata.version_id		=	l_basic_acct_type_version_id
							AND	feata.ext_account_type_code	=	flia.dim_attribute_varchar_member
							AND	feata.dim_attribute_varchar_member IN (''LIABILITY'', ''EQUITY'', ''REVENUE''));
     ELSE
       --Bugfix 5526501: Zero rows are inserted so we should set the completion status to warning
       fnd_file.put_line(fnd_file.log, ''<<<<<<<<<<<<<<<<<<<<<Beginning of Warning>>>>>>>>>>>>>>>>>>>>>>>>>>'');
       fnd_file.put_line(fnd_file.log, ''No data was transferred to the data table'');
       fnd_file.put_line(fnd_file.log, ''Please ensure the analytical report step in foundation was completed, and the consolidation process generated results.'');
       fnd_file.put_line(fnd_file.log, ''<<<<<<<<<<<<<<<<<<<<<<End of Warning>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'');
       l_ret_status         :=      fnd_concurrent.set_completion_status(
                                              status  =>      ''WARNING'',
                                              message =>      NULL);
     END IF;


      -- Bugfix 5569522: If the user had selected a business process, call the
      -- submit_business_process procedure to launch the business process.

      IF (p_analysis_cycle_id <> -1) THEN
        submit_business_process
        (
          errbuf               => errbuf,
          retcode              => retcode,
          p_analysis_cycle_id  => p_analysis_cycle_id,
          p_cal_period_id      => p_cal_period_id
        );
      END IF;



     EXCEPTION
       WHEN NO_DATASET_CREATED THEN
         --An error msg is placed on the stack at the exception raise point
         --A logString call is made at the exception raise point
         FND_MESSAGE.set_name( ''GCS'', ''GCS_EPB_NO_DATASET'' );
         errbuf    := FND_MESSAGE.get;
         retcode   := ''0'';
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DATA_TR_PKG.GCS_EPB_TR_DATA'', ''NO_DATASET_CREATED'');
         END IF;
         fnd_file.put_line(fnd_file.log, ''Fatal Error Occurred : '' || SQLERRM);
         l_ret_status         :=      fnd_concurrent.set_completion_status(
                                                status  =>      ''ERROR'',
                                                message =>      NULL);
         RAISE;

       WHEN DIM_TRANSFER_FAILED THEN
         --An error msg is placed on the stack at the exception raise point
         --A logString call is made at the exception raise point
         FND_MESSAGE.set_name( ''GCS'', ''GCS_EPB_FAIL_DIM_TRANSFER'' );
         errbuf    := FND_MESSAGE.get;
         retcode   := ''0'';
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DATA_TR_PKG.GCS_EPB_TR_DATA'', ''DIM_TRANSFER_FAILED'');
         END IF;
         fnd_file.put_line(fnd_file.log, ''Fatal Error Occurred : '' || SQLERRM);
         l_ret_status         :=      fnd_concurrent.set_completion_status(
                                                status  =>      ''ERROR'',
                                                message =>      NULL);
         RAISE;

       WHEN NO_DATA_FOUND THEN
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DATA_TR_PKG.GCS_EPB_TR_DATA'', ''GCS_NO_DATA_FOUND'');
         END IF;
         retcode := ''0'';
         errbuf := ''GCS_NO_DATA_FOUND'';
         fnd_file.put_line(fnd_file.log, ''Fatal Error Occurred : '' || SQLERRM);
         l_ret_status         :=      fnd_concurrent.set_completion_status(
                                                status  =>      ''ERROR'',
                                                message =>      NULL);
         RAISE NO_DATA_FOUND;

       WHEN OTHERS THEN
         errbuf := substr( SQLERRM, 1, 2000);
         IF (unexpectedloglevel >= runtimeloglevel ) THEN
    	   FND_LOG.STRING(unexpectedloglevel, ''gcs.plsql.GCS_EPB_DATA_TR_PKG.GCS_EPB_TR_DATA'', errbuf);
         END IF;
         retcode := ''0'';
         fnd_file.put_line(fnd_file.log, ''Fatal Error Occurred : '' || SQLERRM);
         l_ret_status         :=      fnd_concurrent.set_completion_status(
                                                status  =>      ''ERROR'',
                                                message =>      NULL);
         RAISE;


  END Gcs_Epb_Tr_Data;';

  -- bugfix 5646254: Since the text exceeded the max size of varchar2, the code was running
  -- into errors. Splitted the big String into two.

  curr_pos := 1;
  body_len := LENGTH(body);
  WHILE curr_pos <= body_len LOOP
  ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
  curr_pos := curr_pos + g_line_size;
  r := r + 1;
  END LOOP;


body:=
'
  -- bugfix 5569522: If the user has selected to run the business process
  -- and has access to it, the business process is launched and then the
  --  Workflow Background Process is launched.
  PROCEDURE	submit_business_process	(
                         errbuf    OUT NOCOPY VARCHAR2,
                    	 retcode   OUT NOCOPY VARCHAR2,
                         p_analysis_cycle_id  IN NUMBER,
  						 p_cal_period_id      IN VARCHAR2)
  IS
    l_business_area_name VARCHAR2(60);
    l_business_process_name VARCHAR(300);
    l_horizon_start DATE;
	l_horizon_end DATE;
    l_business_process_access VARCHAR2(100) := ''N'';
    l_bp_user_id NUMBER;
    l_start VARCHAR2(1000);
    l_end VARCHAR2(1000);
    l_key VARCHAR2(1000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_return_status VARCHAR2(10);
    l_end_date_attribute_id	NUMBER   :=
					gcs_utility_pkg.g_dimension_attr_info(''CAL_PERIOD_ID-CAL_PERIOD_END_DATE'').attribute_id;
    l_end_date_version_id NUMBER   :=
					gcs_utility_pkg.g_dimension_attr_info(''CAL_PERIOD_ID-CAL_PERIOD_END_DATE'').version_id;
    l_start_date_attribute_id NUMBER   :=
					gcs_utility_pkg.g_dimension_attr_info(''CAL_PERIOD_ID-CAL_PERIOD_START_DATE'').attribute_id;
    l_start_date_version_id	NUMBER   :=
					gcs_utility_pkg.g_dimension_attr_info(''CAL_PERIOD_ID-CAL_PERIOD_START_DATE'').version_id;
    l_request_id NUMBER;
    l_conc_req_status BOOLEAN;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.SUBMIT_BUSINESS_PROCESS.begin'', ''<<Enter>>'');
    END IF;

    fnd_file.put_line(fnd_file.log, ''<<Submit business process Parameter Listings>>'');
    fnd_file.put_line(fnd_file.log, ''Calendar Period		:	'' || p_cal_period_id);
    fnd_file.put_line(fnd_file.log, ''Analysis Cycle Id	:	'' || p_analysis_cycle_id);
    fnd_file.put_line(fnd_file.log, ''<<End of Parameter Listings>>'');

    -- bugfix 5569522: If the user had selected a business process, check whether
    -- the user has the access to launch the business process.
    SELECT value
    INTO   l_business_process_access
    FROM   zpb_ac_param_values
    WHERE  analysis_cycle_id = p_analysis_cycle_id
    AND    param_id = (SELECT tag
                       FROM   fnd_lookup_values_vl
                       WHERE  LOOKUP_TYPE = ''ZPB_PARAMS''
                       AND    lookup_code = ''OVERRIDE_EXTERNAL_USER_CHECK'');


    IF (l_business_process_access = ''N'') THEN
      SELECT user_id
      INTO   l_bp_user_id
      FROM   zpb_bp_external_users
      WHERE  analysis_cycle_id = p_analysis_cycle_id;

      IF l_bp_user_id IS NOT NULL THEN
        l_business_process_access := ''Y'';
      END IF;
    END IF;
    fnd_file.put_line(fnd_file.log, ''SUBMIT_BUSINESS_PROCESS:Business Process access:'' || l_business_process_access);


    IF (l_business_process_access = ''N'') THEN
      fnd_file.put_line(fnd_file.log, ''SUBMIT_BUSINESS_PROCESS: The Business Process cannot be kicked off because the user does not have access to submit the Business Process'');
      l_conc_req_status := FND_CONCURRENT.set_completion_status(''WARNING'', ''The Business Process cannot be kicked off because the user does not have access to submit the Business Process'');
    ELSE
      fnd_file.put_line(fnd_file.log, ''SUBMIT_BUSINESS_PROCESS: The user has access to submit the Business Process'');
    END IF;


    -- bugfix 5569522: if the user has access, launch the business process. If the
    -- business process was successful then log a success message and launch the
    -- workflow background process.
    IF (l_business_process_access = ''Y'') THEN
      SELECT zac.name, zbav.name
      INTO   l_business_process_name, l_business_area_name
      FROM   zpb_business_areas_vl zbav, zpb_analysis_cycles zac
      WHERE  zbav.business_area_id = zac.business_area_id
      AND    zac.analysis_cycle_id = p_analysis_cycle_id;


      SELECT start_fcpa.date_assign_value
      INTO   l_horizon_start
      FROM   fem_cal_periods_attr start_fcpa
      WHERE  start_fcpa.cal_period_id = p_cal_period_id
      AND    start_fcpa.attribute_id = l_start_date_attribute_id
      AND    start_fcpa.version_id = l_start_date_version_id;


      SELECT end_fcpa.date_assign_value
      INTO   l_horizon_end
      FROM   fem_cal_periods_attr end_fcpa
      WHERE  end_fcpa.cal_period_id = p_cal_period_id
      AND    end_fcpa.attribute_id = l_end_date_attribute_id
      AND    end_fcpa.version_id = l_end_date_version_id;

      fnd_file.put_line(fnd_file.log, ''Business process name: '' || l_business_process_name);
      fnd_file.put_line(fnd_file.log, ''Business Area name   : '' || l_business_area_name);
      fnd_file.put_line(fnd_file.log, ''Horizon start date	 : '' || l_horizon_start);
      fnd_file.put_line(fnd_file.log, ''Horizon end date     : '' || l_horizon_end);


      ZPB_EXTERNAL_BP_PUBLISH.START_BUSINESS_PROCESS
      (
         P_api_version      => 1,
         P_init_msg_list    => ''Y'',
         P_validation_level => 1,
         P_bp_name          => l_business_process_name,
         P_ba_name          => l_business_area_name,
         P_horizon_start    => l_horizon_start,
         P_horizon_end      => l_horizon_end,
         P_send_date        => NULL,
         x_start_member     => l_start,
         x_end_member       => l_end,
         X_item_key         => l_key,
         X_msg_count        => l_msg_count,
         X_msg_data         => l_msg_data,
         X_return_status    => l_return_status
      );

      fnd_file.put_line(fnd_file.log, '' l_start= '' || l_start);
      fnd_file.put_line(fnd_file.log, '' l_end= '' || l_end);
      fnd_file.put_line(fnd_file.log, '' l_key= '' || l_key);
      fnd_file.put_line(fnd_file.log, '' l_msg_count= '' || l_msg_count);
      fnd_file.put_line(fnd_file.log, '' l_msg_data = '' || l_msg_data );
      fnd_file.put_line(fnd_file.log, '' l_return_status = '' || l_return_status );

      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        fnd_file.put_line(fnd_file.log, ''SUBMIT_BUSINESS_PROCESS: The Business Process has been launched successfully'');

        -- run the workflow background concurrent program.
        l_request_id := fnd_request.submit_request(
      		    		application => ''FND'',
       		       		program 	=> ''FNDWFBG'',
       		       		sub_request => FALSE,
       		       		argument1 	=> null,
       	        		argument2 	=> null,
       	    			argument3 	=> null,
       	    			argument4	=> ''Y'',
       	    			argument5	=> ''Y'',
       	    			argument6	=> ''Y'');

      END IF;

    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.SUBMIT_BUSINESS_PROCESS.end'', ''<<Exit>>'');
    END IF;
  END;



END GCS_DYN_EPB_DATATR_PKG;
';
       curr_pos := 1;
       body_len := LENGTH(body);
       WHILE curr_pos <= body_len LOOP
       ad_ddl.build_statement(SUBSTR(body, curr_pos, g_line_size),r);
       curr_pos := curr_pos + g_line_size;
       r := r + 1;
       END LOOP;

    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username, 'GCS', 'GCS_DYN_EPB_DATATR_PKG',1, r - 1, 'FALSE', err);

    -- dbms_output.put_line('Error' || AD_DDL.error_buf);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'GCS_BUILD_EPB_DATATR_PKG' || '.' || 'BUILD_EPB_DATATR_PKG',
                     GCS_UTILITY_PKG.g_module_success || 'BUILD_EPB_DATATR_PKG' ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success || 'BUILD_EPB_DATATR_PKG' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'GCS_BUILD_EPB_DATA_TR_PKG' || '.' || 'BUILD_EPB_DATATR_PKG',
                       SUBSTR(SQLERRM, 1, 255));
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       'GCS_BUILD_EPB_DATA_TR_PKG' || '.' || 'BUILD_EPB_DATATR_PKG',
                       GCS_UTILITY_PKG.g_module_failure || 'BUILD_EPB_DATATR_PKG' ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
                        'BUILD_EPB_DATATR_PKG' || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
  END build_epb_datatr_pkg;

END GCS_BUILD_EPB_DATA_TR_PKG;

/
