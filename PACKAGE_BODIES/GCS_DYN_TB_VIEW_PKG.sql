--------------------------------------------------------
--  DDL for Package Body GCS_DYN_TB_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DYN_TB_VIEW_PKG" AS
/* $Header: gcs_dyn_tb_vb.pls 120.2 2005/07/01 23:15:53 mikeward noship $ */

--
-- Private Exceptions
--
  GCS_DYN_TB_APPLSYS_NOT_FOUND	EXCEPTION;
  GCS_DYN_TB_V_BUILD_ERR	EXCEPTION;

--
-- Private Global Variables
--
  -- The API name
  g_api		CONSTANT VARCHAR2(40) := 'gcs.plsql.GCS_DYN_TB_VIEW_PKG';


  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter	CONSTANT VARCHAR2(2) := '>>';
  g_module_success	CONSTANT VARCHAR2(2) := '<<';
  g_module_failure	CONSTANT VARCHAR2(2) := '<x';

  -- Newline character
  g_nl CONSTANT VARCHAR2(1) := '
';

  --
  -- Procedure
  --   Module_Log_Write
  -- Purpose
  --   Write the procedure or function entered or exited, and the time that
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module		Name of the module
  --   p_action_type	Entered, Exited Successfully, or Exited with Failure
  -- Example
  --   GCS_DYN_TB_VIEW_PKG.Module_Log_Write
  -- Notes
  --
  PROCEDURE Module_Log_Write
    (p_module		VARCHAR2,
     p_action_type	VARCHAR2) IS
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE, g_api || '.' || p_module,
                     p_action_type || ' ' || p_module || '() ' ||
                     to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_action_type || ' ' || p_module ||
                      '() ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
  END Module_Log_Write;

  --
  -- Procedure
  --   Write_To_Log
  -- Purpose
  --   Write the text given to the log in 3500 character increments
  --   this happened. Write it to the log repository.
  -- Arguments
  --   p_module		Name of the module
  --   p_level		Logging level
  --   p_text		Text to write
  -- Example
  --   GCS_TRANSLATION_PKG.Write_To_Log
  -- Notes
  --
  PROCEDURE Write_To_Log
    (p_module	VARCHAR2,
     p_level	NUMBER,
     p_text	VARCHAR2)
  IS
    api_module_concat	VARCHAR2(200);
    text_with_date	VARCHAR2(32767);
    text_with_date_len	NUMBER;
    curr_index		NUMBER;
  BEGIN
    -- Only print if the log level is set at the appropriate level
    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN
      api_module_concat := g_api || '.' || p_module;
      text_with_date := to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||g_nl||p_text;
      text_with_date_len := length(text_with_date);
      curr_index := 1;
      WHILE curr_index <= text_with_date_len LOOP
        fnd_log.string(p_level, api_module_concat,
                       substr(text_with_date, curr_index, 1500));
        curr_index := curr_index + 1500;
      END LOOP;
    END IF;
  END Write_To_Log;

  --
  -- Procedure
  --   Build_Dimension_Row
  -- Purpose
  --   Build one row of the comma or join list in ad_ddl.
  -- Arguments
  --   p_item		The item to write if the dimension is used
  --   p_def_item	The item to write if the dimension is unused
  --   p_rownum		The row number to use for ad_ddl
  --   p_dim_req	Whether or not the dimension is required
  -- Example
  --   GCS_DYN_TB_VIEW_PKG.Build_Dimension_Row
  -- Notes
  --
  PROCEDURE Build_Dimension_Row(p_item		VARCHAR2,
				p_def_item	VARCHAR2,
				p_rownum	NUMBER,
				p_dim_req	VARCHAR2) IS
  BEGIN
    IF p_dim_req = 'Y' THEN
      ad_ddl.build_statement(p_item, p_rownum);
    ELSE
      ad_ddl.build_statement(p_def_item, p_rownum);
    END IF;
  END Build_Dimension_Row;

  --
  -- Procedure
  --   Optional_Row
  -- Purpose
  --   This will conditionally write a row to ad_ddl.
  -- Arguments
  --   p_text		The text to be written if the condition passes
  --   p_dim_req	The condition
  --   p_row_counter	The row number
  -- Example
  --   GCS_DYN_TB_VIEW_PKG.Optional_Row
  -- Notes
  --
  PROCEDURE Optional_Row(	p_text		VARCHAR2,
				p_dim_req	VARCHAR2,
				p_row_counter	IN OUT NOCOPY NUMBER) IS
  BEGIN
    IF p_dim_req = 'Y' THEN
      ad_ddl.build_statement(p_text, p_row_counter);
      p_row_counter := p_row_counter + 1;
    END IF;
  END Optional_Row;


--
-- Public procedures
--
  PROCEDURE Create_View(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2) IS
    -- row number to be used in dynamically creating the view
    r		NUMBER;

    status	VARCHAR2(1);
    industry	VARCHAR2(1);
    appl	VARCHAR2(30);

    -- Store whether a dimension is used by GCS
    l_fe_req    VARCHAR2(1);
    l_pd_req   VARCHAR2(1);
    l_na_req    VARCHAR2(1);
    l_ch_req   VARCHAR2(1);
    l_pj_req   VARCHAR2(1);
    l_cu_req   VARCHAR2(1);
    l_ta_req   VARCHAR2(1);
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

    l_error_text	VARCHAR2(2000);

    module	VARCHAR2(30);
  BEGIN
    module := 'CREATE_VIEW';
    module_log_write(module, g_module_enter);

    -- Set the global variables determining which dimensions are used
    l_fe_req   := gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID');
    l_pd_req  := gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID');
    l_na_req   := gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID');
    l_ch_req  := gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID');
    l_pj_req  := gcs_utility_pkg.get_fem_dim_required('PROJECT_ID');
    l_cu_req  := gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID');
    l_ta_req  := gcs_utility_pkg.get_fem_dim_required('TASK_ID');
    l_ud1_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID');
    l_ud2_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID');
    l_ud3_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID');
    l_ud4_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID');
    l_ud5_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID');
    l_ud6_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID');
    l_ud7_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID');
    l_ud8_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID');
    l_ud9_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID');
    l_ud10_req := gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID');

    -- Get APPLSYS information. Needed for ad_ddl
    IF NOT fnd_installation.get_app_info('FND', status, industry, appl) THEN
      raise gcs_dyn_tb_applsys_not_found;
    END IF;

    r := 1;

    -- Create the package body
    ad_ddl.build_statement('CREATE OR REPLACE VIEW GCS_DYN_TB_V AS ', r); r:=r+1;
    ad_ddl.build_statement('SELECT ', r); r:=r+1;
    ad_ddl.build_statement(' fb.dataset_code, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.cal_period_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.entity_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.ledger_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.currency_code, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.currency_type_code, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.source_system_code, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.company_cost_center_org_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.intercompany_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.line_item_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.financial_elem_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.product_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.natural_account_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.channel_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.project_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.customer_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.task_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim1_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim2_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim3_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim4_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim5_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim6_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim7_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim8_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim9_id, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.user_dim10_id, ', r); r:=r+1;
    ad_ddl.build_statement(' cotl.company_cost_center_org_name, ', r); r:=r+1;
    ad_ddl.build_statement(' ictl.company_cost_center_org_name intercompany_name, ', r); r:=r+1;
    ad_ddl.build_statement(' litl.line_item_name, ', r); r:=r+1;
    build_dimension_row(' fetl.financial_elem_name, ', ' null financial_elem_name, ', r, l_fe_req); r:=r+1;
    build_dimension_row(' pdtl.product_name, ', ' null product_name, ', r, l_pd_req); r:=r+1;
    build_dimension_row(' natl.natural_account_name, ', ' null natural_account_name, ', r, l_na_req); r:=r+1;
    build_dimension_row(' chtl.channel_name, ', ' null channel_name, ', r, l_ch_req); r:=r+1;
    build_dimension_row(' pjtl.project_name, ', ' null project_name, ', r, l_pj_req); r:=r+1;
    build_dimension_row(' cutl.customer_name, ', ' null customer_name, ', r, l_cu_req); r:=r+1;
    build_dimension_row(' tatl.task_name, ', ' null task_name, ', r, l_ta_req); r:=r+1;
    build_dimension_row(' ud1tl.user_dim1_name, ', ' null user_dim1_name, ', r, l_ud1_req); r:=r+1;
    build_dimension_row(' ud2tl.user_dim2_name, ', ' null user_dim2_name, ', r, l_ud2_req); r:=r+1;
    build_dimension_row(' ud3tl.user_dim3_name, ', ' null user_dim3_name, ', r, l_ud3_req); r:=r+1;
    build_dimension_row(' ud4tl.user_dim4_name, ', ' null user_dim4_name, ', r, l_ud4_req); r:=r+1;
    build_dimension_row(' ud5tl.user_dim5_name, ', ' null user_dim5_name, ', r, l_ud5_req); r:=r+1;
    build_dimension_row(' ud6tl.user_dim6_name, ', ' null user_dim6_name, ', r, l_ud6_req); r:=r+1;
    build_dimension_row(' ud7tl.user_dim7_name, ', ' null user_dim7_name, ', r, l_ud7_req); r:=r+1;
    build_dimension_row(' ud8tl.user_dim8_name, ', ' null user_dim8_name, ', r, l_ud8_req); r:=r+1;
    build_dimension_row(' ud9tl.user_dim9_name, ', ' null user_dim9_name, ', r, l_ud9_req); r:=r+1;
    build_dimension_row(' ud10tl.user_dim10_name, ', ' null user_dim10_name, ', r, l_ud10_req); r:=r+1;
    ad_ddl.build_statement(' cotl.description company_cost_center_org_desc, ', r); r:=r+1;
    ad_ddl.build_statement(' ictl.description intercompany_desc, ', r); r:=r+1;
    ad_ddl.build_statement(' litl.description line_item_desc, ', r); r:=r+1;
    build_dimension_row(' fetl.description financial_elem_desc, ', ' null financial_elem_desc, ', r, l_fe_req); r:=r+1;
    build_dimension_row(' pdtl.description product_desc, ', ' null product_desc, ', r, l_pd_req); r:=r+1;
    build_dimension_row(' natl.description natural_account_desc, ', ' null natural_account_desc, ', r, l_na_req); r:=r+1;
    build_dimension_row(' chtl.description channel_desc, ', ' null channel_desc, ', r, l_ch_req); r:=r+1;
    build_dimension_row(' pjtl.description project_desc, ', ' null project_desc, ', r, l_pj_req); r:=r+1;
    build_dimension_row(' cutl.description customer_desc, ', ' null customer_desc, ', r, l_cu_req); r:=r+1;
    build_dimension_row(' tatl.description task_desc, ', ' null task_desc, ', r, l_ta_req); r:=r+1;
    build_dimension_row(' ud1tl.description user_dim1_desc, ', ' null user_dim1_desc, ', r, l_ud1_req); r:=r+1;
    build_dimension_row(' ud2tl.description user_dim2_desc, ', ' null user_dim2_desc, ', r, l_ud2_req); r:=r+1;
    build_dimension_row(' ud3tl.description user_dim3_desc, ', ' null user_dim3_desc, ', r, l_ud3_req); r:=r+1;
    build_dimension_row(' ud4tl.description user_dim4_desc, ', ' null user_dim4_desc, ', r, l_ud4_req); r:=r+1;
    build_dimension_row(' ud5tl.description user_dim5_desc, ', ' null user_dim5_desc, ', r, l_ud5_req); r:=r+1;
    build_dimension_row(' ud6tl.description user_dim6_desc, ', ' null user_dim6_desc, ', r, l_ud6_req); r:=r+1;
    build_dimension_row(' ud7tl.description user_dim7_desc, ', ' null user_dim7_desc, ', r, l_ud7_req); r:=r+1;
    build_dimension_row(' ud8tl.description user_dim8_desc, ', ' null user_dim8_desc, ', r, l_ud8_req); r:=r+1;
    build_dimension_row(' ud9tl.description user_dim9_desc, ', ' null user_dim9_desc, ', r, l_ud9_req); r:=r+1;
    build_dimension_row(' ud10tl.description user_dim10_desc, ', ' null user_dim10_desc, ', r, l_ud10_req); r:=r+1;
    ad_ddl.build_statement(' fb.xtd_balance_e, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.xtd_balance_f, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.ytd_balance_e, ', r); r:=r+1;
    ad_ddl.build_statement(' fb.ytd_balance_f ', r); r:=r+1;
    ad_ddl.build_statement('FROM ', r); r:=r+1;
    ad_ddl.build_statement(' FEM_BALANCES fb, ', r); r:=r+1;
    ad_ddl.build_statement(' FEM_CCTR_ORGS_TL cotl, ', r); r:=r+1;
    ad_ddl.build_statement(' FEM_CCTR_ORGS_TL ictl, ', r); r:=r+1;
    optional_row(' FEM_FIN_ELEMS_TL fetl, ', l_fe_req, r);
    optional_row(' FEM_PRODUCTS_TL pdtl, ', l_pd_req, r);
    optional_row(' FEM_NAT_ACCTS_TL natl, ', l_na_req, r);
    optional_row(' FEM_CHANNELS_TL chtl, ', l_ch_req, r);
    optional_row(' FEM_PROJECTS_TL pjtl, ', l_pj_req, r);
    optional_row(' FEM_CUSTOMERS_TL cutl, ', l_cu_req, r);
    optional_row(' FEM_TASKS_TL tatl, ', l_ta_req, r);
    optional_row(' FEM_USER_DIM1_TL ud1tl, ', l_ud1_req, r);
    optional_row(' FEM_USER_DIM2_TL ud2tl, ', l_ud2_req, r);
    optional_row(' FEM_USER_DIM3_TL ud3tl, ', l_ud3_req, r);
    optional_row(' FEM_USER_DIM4_TL ud4tl, ', l_ud4_req, r);
    optional_row(' FEM_USER_DIM5_TL ud5tl, ', l_ud5_req, r);
    optional_row(' FEM_USER_DIM6_TL ud6tl, ', l_ud6_req, r);
    optional_row(' FEM_USER_DIM7_TL ud7tl, ', l_ud7_req, r);
    optional_row(' FEM_USER_DIM8_TL ud8tl, ', l_ud8_req, r);
    optional_row(' FEM_USER_DIM9_TL ud9tl, ', l_ud9_req, r);
    optional_row(' FEM_USER_DIM10_TL ud10tl, ', l_ud10_req, r);
    ad_ddl.build_statement(' FEM_LN_ITEMS_TL litl ', r); r:=r+1;
    ad_ddl.build_statement('WHERE cotl.company_cost_center_org_id = fb.company_cost_center_org_id ', r); r:=r+1;
    ad_ddl.build_statement('AND   cotl.language = userenv(''LANG'') ', r); r:=r+1;
    ad_ddl.build_statement('AND   ictl.company_cost_center_org_id = fb.intercompany_id ', r); r:=r+1;
    ad_ddl.build_statement('AND   ictl.language = userenv(''LANG'') ', r); r:=r+1;
    optional_row('AND   fetl.financial_elem_id = fb.financial_elem_id ', l_fe_req, r);
    optional_row('AND   fetl.language = userenv(''LANG'') ', l_fe_req, r);
    optional_row('AND   pdtl.product_id = fb.product_id ', l_pd_req, r);
    optional_row('AND   pdtl.language = userenv(''LANG'') ', l_pd_req, r);
    optional_row('AND   natl.natural_account_id = fb.natural_account_id ', l_na_req, r);
    optional_row('AND   natl.language = userenv(''LANG'') ', l_na_req, r);
    optional_row('AND   chtl.channel_id = fb.channel_id ', l_ch_req, r);
    optional_row('AND   chtl.language = userenv(''LANG'') ', l_ch_req, r);
    optional_row('AND   pjtl.project_id = fb.project_id ', l_pj_req, r);
    optional_row('AND   pjtl.language = userenv(''LANG'') ', l_pj_req, r);
    optional_row('AND   cutl.customer_id = fb.customer_id ', l_cu_req, r);
    optional_row('AND   cutl.language = userenv(''LANG'') ', l_cu_req, r);
    optional_row('AND   tatl.task_id = fb.task_id ', l_ta_req, r);
    optional_row('AND   tatl.language = userenv(''LANG'') ', l_ta_req, r);
    optional_row('AND   ud1tl.user_dim1_id = fb.user_dim1_id ', l_ud1_req, r);
    optional_row('AND   ud1tl.language = userenv(''LANG'') ', l_ud1_req, r);
    optional_row('AND   ud2tl.user_dim2_id = fb.user_dim2_id ', l_ud2_req, r);
    optional_row('AND   ud2tl.language = userenv(''LANG'') ', l_ud2_req, r);
    optional_row('AND   ud3tl.user_dim3_id = fb.user_dim3_id ', l_ud3_req, r);
    optional_row('AND   ud3tl.language = userenv(''LANG'') ', l_ud3_req, r);
    optional_row('AND   ud4tl.user_dim4_id = fb.user_dim4_id ', l_ud4_req, r);
    optional_row('AND   ud4tl.language = userenv(''LANG'') ', l_ud4_req, r);
    optional_row('AND   ud5tl.user_dim5_id = fb.user_dim5_id ', l_ud5_req, r);
    optional_row('AND   ud5tl.language = userenv(''LANG'') ', l_ud5_req, r);
    optional_row('AND   ud6tl.user_dim6_id = fb.user_dim6_id ', l_ud6_req, r);
    optional_row('AND   ud6tl.language = userenv(''LANG'') ', l_ud6_req, r);
    optional_row('AND   ud7tl.user_dim7_id = fb.user_dim7_id ', l_ud7_req, r);
    optional_row('AND   ud7tl.language = userenv(''LANG'') ', l_ud7_req, r);
    optional_row('AND   ud8tl.user_dim8_id = fb.user_dim8_id ', l_ud8_req, r);
    optional_row('AND   ud8tl.language = userenv(''LANG'') ', l_ud8_req, r);
    optional_row('AND   ud9tl.user_dim9_id = fb.user_dim9_id ', l_ud9_req, r);
    optional_row('AND   ud9tl.language = userenv(''LANG'') ', l_ud9_req, r);
    optional_row('AND   ud10tl.user_dim10_id = fb.user_dim10_id ', l_ud10_req, r);
    optional_row('AND   ud10tl.language = userenv(''LANG'') ', l_ud10_req, r);
    ad_ddl.build_statement('AND   litl.line_item_id = fb.line_item_id ', r); r:=r+1;
    ad_ddl.build_statement('AND   litl.language = userenv(''LANG'') ', r); r:=r+1;
    ad_ddl.build_statement('AND   fb.currency_type_code IN (''ENTERED'', ''TRANSLATED'') ', r);

    ad_ddl.do_array_ddl(appl, 'APPS', ad_ddl.create_view, 1, r, 'GCS_DYN_TB_V');

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_DYN_TB_APPLSYS_NOT_FOUND THEN
      FND_MESSAGE.SET_NAME('GCS', 'GCS_APPLSYS_NOT_FOUND');
      l_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, l_error_text);
      x_errbuf := l_error_text;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
    WHEN OTHERS THEN
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      x_errbuf := SQLERRM;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
  END Create_View;

END GCS_DYN_TB_VIEW_PKG;

/
