--------------------------------------------------------
--  DDL for Package Body GCS_TRANS_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_TRANS_DYN_BUILD_PKG" AS
/* $Header: gcsxltdb.pls 120.7 2007/06/29 11:45:31 vkosuri noship $ */

--
-- Private Exceptions
--
  GCS_CCY_APPLSYS_NOT_FOUND	EXCEPTION;
  GCS_CCY_DYN_PKG_BUILD_ERR	EXCEPTION;

--
-- Private Global Variables
--
  -- The API name
  g_api		CONSTANT VARCHAR2(50) := 'gcs.plsql.GCS_TRANS_DYN_BUILD_PKG';


  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter	CONSTANT VARCHAR2(2) := '>>';
  g_module_success	CONSTANT VARCHAR2(2) := '<<';
  g_module_failure	CONSTANT VARCHAR2(2) := '<x';

  -- For holding error text
  g_error_text	VARCHAR2(32767);

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
  --   GCS_TRANS_DYN_BUILD_PKG.Module_Log_Write
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
                       substr(text_with_date, curr_index, 3500));
        curr_index := curr_index + 3500;
      END LOOP;
    END IF;
  END Write_To_Log;


  -- Bugfix 5707630: Added two extra argument to the procedure. Dimension is added
  -- only when its enabled for historical rates (for historical rate).
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
  --   p_hrate_dim_req  Whether or not the dimension is required for Historicla Rates
  --   p_key        The processing key type - 'H' - Historical rate, 'F' - FCH Processing key
  -- Example
  --   GCS_TRANS_DYN_BUILD_PKG.Build_Dimension_Row
  -- Notes
  --
  PROCEDURE Build_Dimension_Row(
                p_item          VARCHAR2,
                p_def_item      VARCHAR2,
                p_rownum        NUMBER,
                p_dim_req       VARCHAR2,
                p_hrate_dim_req VARCHAR2,
                p_key           VARCHAR2) IS
  BEGIN
    IF p_key = 'F' THEN
    IF p_dim_req = 'Y' THEN
      ad_ddl.build_statement(p_item, p_rownum);
    ELSE
      ad_ddl.build_statement(p_def_item, p_rownum);
    END IF;
    ELSE
      IF p_hrate_dim_req <> 'N' THEN
        ad_ddl.build_statement(p_item, p_rownum);
      ELSE
        ad_ddl.build_statement(p_def_item, p_rownum);
      END IF;
    END IF;
  END Build_Dimension_Row;


--
-- Public procedures/functions
--
  -- Bugfix 5707630: Added a new argument
  -- The procedure is now a function as it will return the line number to the
  -- GCS_DYN_HRATES_BUILD_PKG and GCS_DYN_RE_BUILD_PKG.
  -- The enabled for historical rates flag and the hrate type is also passed to build_dimension_row.
  -- Added cttr and ic dimensions as well.
  --
  -- Procedure
  --   Build_Comma_List
  -- Purpose
  --   Build a list of the dimensions, delimited by commas. Use null if
  --   the dimension is not used.
  -- Arguments
  --   p_prefix		The prefix to put on the dimensions
  --   p_suffix		The suffix to put on the dimensions
  --   p_null_text	The text to be inserted for the null case
  --   p_first_rownum	The first row number to use for ad_ddl
  --   p_key           Whether Historical rates keys or FCH processing keys.
  -- Example
  --   GCS_TRANS_DYN_BUILD_PKG.Build_Comma_List
  -- Notes
  --
  FUNCTION Build_Comma_List( p_prefix        VARCHAR2,
                             p_suffix        VARCHAR2,
                             p_null_text     VARCHAR2,
                             p_first_rownum  NUMBER,
                             p_key           VARCHAR2) RETURN NUMBER IS
  BEGIN
    -- Go through each of the optional dimensions, and fill out accordingly
    build_dimension_row(p_prefix||'COMPANY_COST_CENTER_ORG_ID,'||p_suffix, p_null_text, p_first_rownum,    g_cctr_req, g_cctr_hrate_req, p_key);
    build_dimension_row(p_prefix||'INTERCOMPANY_ID,'||p_suffix,            p_null_text, p_first_rownum+1,  g_ic_req,   g_ic_hrate_req,   p_key);
    build_dimension_row(p_prefix||'FINANCIAL_ELEM_ID,'||p_suffix,          p_null_text, p_first_rownum+2,  g_fe_req,   g_fe_hrate_req,   p_key);
    build_dimension_row(p_prefix||'PRODUCT_ID,'||p_suffix,                 p_null_text, p_first_rownum+3,  g_prd_req,  g_prd_hrate_req,  p_key);
    build_dimension_row(p_prefix||'NATURAL_ACCOUNT_ID,'||p_suffix,         p_null_text, p_first_rownum+4,  g_na_req,   g_na_hrate_req,   p_key);
    build_dimension_row(p_prefix||'CHANNEL_ID,'||p_suffix,                 p_null_text, p_first_rownum+5,  g_chl_req,  g_chl_hrate_req,  p_key);
    build_dimension_row(p_prefix||'PROJECT_ID,'||p_suffix,                 p_null_text, p_first_rownum+6,  g_prj_req,  g_prj_hrate_req,  p_key);
    build_dimension_row(p_prefix||'CUSTOMER_ID,'||p_suffix,                p_null_text, p_first_rownum+7,  g_cst_req,  g_cst_hrate_req,  p_key);
    build_dimension_row(p_prefix||'TASK_ID,'||p_suffix,                    p_null_text, p_first_rownum+8,  g_tsk_req,  g_tsk_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM1_ID,'||p_suffix,               p_null_text, p_first_rownum+9,  g_ud1_req,  g_ud1_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM2_ID,'||p_suffix,               p_null_text, p_first_rownum+10, g_ud2_req,  g_ud2_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM3_ID,'||p_suffix,               p_null_text, p_first_rownum+11, g_ud3_req,  g_ud3_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM4_ID,'||p_suffix,               p_null_text, p_first_rownum+12, g_ud4_req,  g_ud4_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM5_ID,'||p_suffix,               p_null_text, p_first_rownum+13, g_ud5_req,  g_ud5_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM6_ID,'||p_suffix,               p_null_text, p_first_rownum+14, g_ud6_req,  g_ud6_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM7_ID,'||p_suffix,               p_null_text, p_first_rownum+15, g_ud7_req,  g_ud7_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM8_ID,'||p_suffix,               p_null_text, p_first_rownum+16, g_ud8_req,  g_ud8_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM9_ID,'||p_suffix,               p_null_text, p_first_rownum+17, g_ud9_req,  g_ud9_hrate_req,  p_key);
    build_dimension_row(p_prefix||'USER_DIM10_ID,'||p_suffix,              p_null_text, p_first_rownum+18, g_ud10_req, g_ud10_hrate_req, p_key);

    return p_first_rownum + 19;
  END Build_Comma_List;


  -- Bugfix 5707630: Added a new argument.
  -- The procedure is now a function as it will return the line number to the
  -- GCS_DYN_HRATES_BUILD_PKG and GCS_DYN_RE_BUILD_PKG. The enabled for historical
  -- rates flag and the hrate type is also passed to build_dimension_row.
  -- Added cttr, ic and line item.
  --
  -- Procedure
  --   Build_Join_List
  -- Purpose
  --   Build a list of the dimensions, delimited by commas. Use null if
  --   the dimension is not used.
  -- Arguments
  --   p_left		The text to put before the left dimension
  --   p_middle		The text to put between the two dimensions
  --   p_right		The text to put after the right dimension
  --   p_first_rownum	The first row number to use for ad_ddl
  --   p_key           Whether Historical rates keys or FCH processing keys.
  -- Example
  --   GCS_TRANS_DYN_BUILD_PKG.Build_Join_List
  -- Notes
  --
  FUNCTION  Build_Join_List(p_left          VARCHAR2,
                            p_middle        VARCHAR2,
                            p_right         VARCHAR2,
                            p_first_rownum  NUMBER,
                            p_key           VARCHAR2) RETURN NUMBER IS
  BEGIN
    -- Go through each of the optional dimensions, and fill out accordingly
    build_dimension_row(p_left||'COMPANY_COST_CENTER_ORG_ID'||p_middle||'COMPANY_COST_CENTER_ORG_ID'||p_right, '', p_first_rownum,    g_cctr_req, g_cctr_hrate_req, p_key);
    build_dimension_row(p_left||'INTERCOMPANY_ID'||p_middle||'INTERCOMPANY_ID'||p_right,                       '', p_first_rownum+1,  g_ic_req,   g_ic_hrate_req,   p_key);
    build_dimension_row(p_left||'FINANCIAL_ELEM_ID'||p_middle||'FINANCIAL_ELEM_ID'||p_right,                   '', p_first_rownum+2,  g_fe_req,   g_fe_hrate_req,   p_key);
    build_dimension_row(p_left||'PRODUCT_ID'||p_middle||'PRODUCT_ID'||p_right,                                 '', p_first_rownum+3,  g_prd_req,  g_prd_hrate_req,  p_key);
    build_dimension_row(p_left||'NATURAL_ACCOUNT_ID'||p_middle||'NATURAL_ACCOUNT_ID'||p_right,                 '', p_first_rownum+4,  g_na_req,   g_na_hrate_req,   p_key);
    build_dimension_row(p_left||'CHANNEL_ID'||p_middle||'CHANNEL_ID'||p_right,                                 '', p_first_rownum+5,  g_chl_req,  g_chl_hrate_req,  p_key);
    build_dimension_row(p_left||'PROJECT_ID'||p_middle||'PROJECT_ID'||p_right,                                 '', p_first_rownum+6,  g_prj_req,  g_prj_hrate_req,  p_key);
    build_dimension_row(p_left||'CUSTOMER_ID'||p_middle||'CUSTOMER_ID'||p_right,                               '', p_first_rownum+7,  g_cst_req,  g_cst_hrate_req,  p_key);
    build_dimension_row(p_left||'TASK_ID'||p_middle||'TASK_ID'||p_right,                                       '', p_first_rownum+8,  g_tsk_req,  g_tsk_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM1_ID'||p_middle||'USER_DIM1_ID'||p_right,                             '', p_first_rownum+9,  g_ud1_req,  g_ud1_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM2_ID'||p_middle||'USER_DIM2_ID'||p_right,                             '', p_first_rownum+10, g_ud2_req,  g_ud2_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM3_ID'||p_middle||'USER_DIM3_ID'||p_right,                             '', p_first_rownum+11, g_ud3_req,  g_ud3_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM4_ID'||p_middle||'USER_DIM4_ID'||p_right,                             '', p_first_rownum+12, g_ud4_req,  g_ud4_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM5_ID'||p_middle||'USER_DIM5_ID'||p_right,                             '', p_first_rownum+13, g_ud5_req,  g_ud5_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM6_ID'||p_middle||'USER_DIM6_ID'||p_right,                             '', p_first_rownum+14, g_ud6_req,  g_ud6_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM7_ID'||p_middle||'USER_DIM7_ID'||p_right,                             '', p_first_rownum+15, g_ud7_req,  g_ud7_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM8_ID'||p_middle||'USER_DIM8_ID'||p_right,                             '', p_first_rownum+16, g_ud8_req,  g_ud8_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM9_ID'||p_middle||'USER_DIM9_ID'||p_right,                             '', p_first_rownum+17, g_ud9_req,  g_ud9_hrate_req,  p_key);
    build_dimension_row(p_left||'USER_DIM10_ID'||p_middle||'USER_DIM10_ID'||p_right,                           '', p_first_rownum+18, g_ud10_req, g_ud10_hrate_req, p_key);

    return p_first_rownum + 19;
  END Build_Join_List;


  -- Bugfix 5725759: Added the initilization procedure that will initialize
  -- the historical rates and fem dimension required variables.
  PROCEDURE Initialize_Dimensions IS

  BEGIN

    gcs_utility_pkg.init_dimension_info;

    -- Set the global variables determining which dimensions are used
    -- Bugfix 5707630: Set values for company_cost_center_org_id and intercompany_id.
    g_cctr_req  := gcs_utility_pkg.get_dimension_required('COMPANY_COST_CENTER_ORG_ID');
    g_ic_req    := gcs_utility_pkg.get_dimension_required('INTERCOMPANY_ID');
    g_fe_req   := gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID');
    g_prd_req  := gcs_utility_pkg.get_dimension_required('PRODUCT_ID');
    g_na_req   := gcs_utility_pkg.get_dimension_required('NATURAL_ACCOUNT_ID');
    g_chl_req  := gcs_utility_pkg.get_dimension_required('CHANNEL_ID');
    g_prj_req  := gcs_utility_pkg.get_dimension_required('PROJECT_ID');
    g_cst_req  := gcs_utility_pkg.get_dimension_required('CUSTOMER_ID');
    g_tsk_req  := gcs_utility_pkg.get_dimension_required('TASK_ID');
    g_ud1_req  := gcs_utility_pkg.get_dimension_required('USER_DIM1_ID');
    g_ud2_req  := gcs_utility_pkg.get_dimension_required('USER_DIM2_ID');
    g_ud3_req  := gcs_utility_pkg.get_dimension_required('USER_DIM3_ID');
    g_ud4_req  := gcs_utility_pkg.get_dimension_required('USER_DIM4_ID');
    g_ud5_req  := gcs_utility_pkg.get_dimension_required('USER_DIM5_ID');
    g_ud6_req  := gcs_utility_pkg.get_dimension_required('USER_DIM6_ID');
    g_ud7_req  := gcs_utility_pkg.get_dimension_required('USER_DIM7_ID');
    g_ud8_req  := gcs_utility_pkg.get_dimension_required('USER_DIM8_ID');
    g_ud9_req  := gcs_utility_pkg.get_dimension_required('USER_DIM9_ID');
    g_ud10_req := gcs_utility_pkg.get_dimension_required('USER_DIM10_ID');

    -- Bugfix 5707630: For each dimension, set the historical enabled flag value.
    g_cctr_hrate_req  := gcs_utility_pkg.get_hrate_dim_required('COMPANY_COST_CENTER_ORG_ID');
    g_ic_hrate_req    := gcs_utility_pkg.get_hrate_dim_required('INTERCOMPANY_ID');
    g_fe_hrate_req    := gcs_utility_pkg.get_hrate_dim_required('FINANCIAL_ELEM_ID');
    g_prd_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('PRODUCT_ID');
    g_na_hrate_req    := gcs_utility_pkg.get_hrate_dim_required('NATURAL_ACCOUNT_ID');
    g_chl_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('CHANNEL_ID');
    g_prj_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('PROJECT_ID');
    g_cst_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('CUSTOMER_ID');
    g_tsk_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('TASK_ID');
    g_ud1_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM1_ID');
    g_ud2_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM2_ID');
    g_ud3_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM3_ID');
    g_ud4_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM4_ID');
    g_ud5_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM5_ID');
    g_ud6_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM6_ID');
    g_ud7_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM7_ID');
    g_ud8_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM8_ID');
    g_ud9_hrate_req   := gcs_utility_pkg.get_hrate_dim_required('USER_DIM9_ID');
    g_ud10_hrate_req  := gcs_utility_pkg.get_hrate_dim_required('USER_DIM10_ID');

  END Initialize_Dimensions;


  -- Bugfix 5707630: The main logic will no longer be present in this package now.
  -- The logic has been split into two packages, one will contains procedures for
  -- translation of historical rates and the other will contain the translation
  -- for retained earnings. This package will create the dynamic generic package
  -- that will have code to call procedures in the historical rates and the
  -- retained earnings packages.
  PROCEDURE Create_Package(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2) IS
    -- row number to be used in dynamically creating the package
    r		NUMBER := 1;

    err		VARCHAR2(2000);

    status	VARCHAR2(1);
    industry	VARCHAR2(1);
    appl	VARCHAR2(30);

    module	VARCHAR2(30);
  BEGIN
    module := 'CREATE_PACKAGE';
    module_log_write(module, g_module_enter);
    Initialize_Dimensions;

    -- Get APPLSYS information. Needed for ad_ddl
    IF NOT fnd_installation.get_app_info('FND', status, industry, appl) THEN
      raise gcs_ccy_applsys_not_found;
    END IF;

    -- Create the package body
    -- Bugfix 5725759: Added function Get_RE_Data_Exists and Initialize_Data_Load_Status procedure
    ad_ddl.build_statement('CREATE OR REPLACE PACKAGE BODY GCS_TRANS_DYNAMIC_PKG AS', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  -- The API name', r); r:=r+1;
    ad_ddl.build_statement('  g_api             VARCHAR2(50) := ''gcs.plsql.GCS_TRANS_DYNAMIC_PKG'';', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  -- Action types for writing module information to the log file. Used for', r); r:=r+1;
    ad_ddl.build_statement('  -- the procedure log_file_module_write.', r); r:=r+1;
    ad_ddl.build_statement('  g_module_enter    VARCHAR2(2) := ''>>'';', r); r:=r+1;
    ad_ddl.build_statement('  g_module_success  VARCHAR2(2) := ''<<'';', r); r:=r+1;
    ad_ddl.build_statement('  g_module_failure  VARCHAR2(2) := ''<x'';', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  -- A newline character. Included for convenience when writing long strings.', r); r:=r+1;
    ad_ddl.build_statement('  g_nl              VARCHAR2(1) := ''', r); r:=r+1;
    ad_ddl.build_statement(''';', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('-- PRIVATE EXCEPTIONS', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('  GCS_CCY_NO_DATA               EXCEPTION;', r); r:=r+1;
    ad_ddl.build_statement('  GCS_CCY_ENTRY_CREATE_FAILED   EXCEPTION;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('-- PRIVATE PROCEDURES/FUNCTIONS', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  --', r); r:=r+1;
    ad_ddl.build_statement('  -- Procedure', r); r:=r+1;
    ad_ddl.build_statement('  --   Module_Log_Write', r); r:=r+1;
    ad_ddl.build_statement('  -- Purpose', r); r:=r+1;
    ad_ddl.build_statement('  --   Write the procedure or function entered or exited, and the time that', r); r:=r+1;
    ad_ddl.build_statement('  --   this happened. Write it to the log repository.', r); r:=r+1;
    ad_ddl.build_statement('  -- Arguments', r); r:=r+1;
    ad_ddl.build_statement('  --   p_module       Name of the module', r); r:=r+1;
    ad_ddl.build_statement('  --   p_action_type  Entered, Exited Successfully, or Exited with Failure', r); r:=r+1;
    ad_ddl.build_statement('  -- Example', r); r:=r+1;
    ad_ddl.build_statement('  --   GCS_TRANSLATION_PKG.Module_Log_Write', r); r:=r+1;
    ad_ddl.build_statement('  -- Notes', r); r:=r+1;
    ad_ddl.build_statement('  --', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE Module_Log_Write', r); r:=r+1;
    ad_ddl.build_statement('    (p_module       VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_action_type  VARCHAR2) IS', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    -- Only print if the log level is set at the appropriate level', r); r:=r+1;
    ad_ddl.build_statement('    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN', r); r:=r+1;
    ad_ddl.build_statement('      fnd_log.string(FND_LOG.LEVEL_PROCEDURE, g_api || ''.'' || p_module,', r); r:=r+1;
    ad_ddl.build_statement('                     p_action_type || '' '' || p_module || ''() '' ||', r); r:=r+1;
    ad_ddl.build_statement('                     to_char(sysdate, ''DD-MON-YYYY HH:MI:SS''));', r); r:=r+1;
    ad_ddl.build_statement('    END IF;', r); r:=r+1;
    ad_ddl.build_statement('    FND_FILE.PUT_LINE(FND_FILE.LOG, p_action_type || '' '' || p_module ||', r); r:=r+1;
    ad_ddl.build_statement('                      ''() '' || to_char(sysdate, ''DD-MON-YYYY HH:MI:SS''));', r); r:=r+1;
    ad_ddl.build_statement('  END Module_Log_Write;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  --', r); r:=r+1;
    ad_ddl.build_statement('  -- Procedure', r); r:=r+1;
    ad_ddl.build_statement('  --   Write_To_Log', r); r:=r+1;
    ad_ddl.build_statement('  -- Purpose', r); r:=r+1;
    ad_ddl.build_statement('  --   Write the text given to the log in 3500 character increments', r); r:=r+1;
    ad_ddl.build_statement('  --   this happened. Write it to the log repository.', r); r:=r+1;
    ad_ddl.build_statement('  -- Arguments', r); r:=r+1;
    ad_ddl.build_statement('  --   p_module		Name of the module', r); r:=r+1;
    ad_ddl.build_statement('  --   p_level		Logging level', r); r:=r+1;
    ad_ddl.build_statement('  --   p_text		Text to write', r); r:=r+1;
    ad_ddl.build_statement('  -- Example', r); r:=r+1;
    ad_ddl.build_statement('  --   GCS_TRANSLATION_PKG.Write_To_Log', r); r:=r+1;
    ad_ddl.build_statement('  -- Notes', r); r:=r+1;
    ad_ddl.build_statement('  --', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE Write_To_Log', r); r:=r+1;
    ad_ddl.build_statement('    (p_module	VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_level	NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_text	VARCHAR2)', r); r:=r+1;
    ad_ddl.build_statement('  IS', r); r:=r+1;
    ad_ddl.build_statement('    api_module_concat	VARCHAR2(200);', r); r:=r+1;
    ad_ddl.build_statement('    text_with_date	VARCHAR2(32767);', r); r:=r+1;
    ad_ddl.build_statement('    text_with_date_len	NUMBER;', r); r:=r+1;
    ad_ddl.build_statement('    curr_index		NUMBER;', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    -- Only print if the log level is set at the appropriate level', r); r:=r+1;
    ad_ddl.build_statement('    IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN', r); r:=r+1;
    ad_ddl.build_statement('      api_module_concat := g_api || ''.'' || p_module;', r); r:=r+1;
    ad_ddl.build_statement('      text_with_date := to_char(sysdate,''DD-MON-YYYY HH:MI:SS'')||g_nl||p_text;', r); r:=r+1;
    ad_ddl.build_statement('      text_with_date_len := length(text_with_date);', r); r:=r+1;
    ad_ddl.build_statement('      curr_index := 1;', r); r:=r+1;
    ad_ddl.build_statement('      WHILE curr_index <= text_with_date_len LOOP', r); r:=r+1;
    ad_ddl.build_statement('        fnd_log.string(p_level, api_module_concat,', r); r:=r+1;
    ad_ddl.build_statement('                       substr(text_with_date, curr_index, 3500));', r); r:=r+1;
    ad_ddl.build_statement('        curr_index := curr_index + 3500;', r); r:=r+1;
    ad_ddl.build_statement('      END LOOP;', r); r:=r+1;
    ad_ddl.build_statement('    END IF;', r); r:=r+1;
    ad_ddl.build_statement('  END Write_To_Log;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  --', r); r:=r+1;
    ad_ddl.build_statement('  -- Function', r); r:=r+1;
    ad_ddl.build_statement('  --   Get_RE_Data_Exists', r); r:=r+1;
    ad_ddl.build_statement('  -- Purpose', r); r:=r+1;
    ad_ddl.build_statement('  --   Determines whether the data was loaded for the given combination or not.', r); r:=r+1;
    ad_ddl.build_statement('  -- Arguments', r); r:=r+1;
    ad_ddl.build_statement('  --   p_hier_dataset_code   The dataset code in FEM_BALANCES.', r); r:=r+1;
    ad_ddl.build_statement('  --   p_cal_period_id       The current period''s cal_period_id.', r); r:=r+1;
    ad_ddl.build_statement('  --   p_source_system_code  GCS source system code.', r); r:=r+1;
    ad_ddl.build_statement('  --   p_from_ccy            From currency code.', r); r:=r+1;
    ad_ddl.build_statement('  --   p_ledger_id           The ledger in FEM_BALANCES.', r); r:=r+1;
    ad_ddl.build_statement('  --   p_entity_id           Entity on which the translation is being performed.', r); r:=r+1;
    ad_ddl.build_statement('  --   p_line_item_id        Line Item Id of retained earnings selected for the hierarchy.', r); r:=r+1;
    ad_ddl.build_statement('  -- Example', r); r:=r+1;
    ad_ddl.build_statement('  --   GCS_TRANSLATION_PKG.Get_RE_Data_Exists', r); r:=r+1;
    ad_ddl.build_statement('  -- Notes', r); r:=r+1;
    ad_ddl.build_statement('  --', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  FUNCTION Get_RE_Data_Exists(', r); r:=r+1;
    ad_ddl.build_statement('                     p_hier_dataset_code  NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_cal_period_id      NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_source_system_code NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_from_ccy           VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('                     p_ledger_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_entity_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_line_item_id       NUMBER) RETURN VARCHAR2 IS', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    l_re_data_flag VARCHAR2(10);', r); r:=r+1;
    ad_ddl.build_statement('    CURSOR re_data_cur (', r); r:=r+1;
    ad_ddl.build_statement('                     p_hier_dataset_code  NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_cal_period_id      NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_source_system_code NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_from_ccy           VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('                     p_ledger_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_entity_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                     p_line_item_id       NUMBER) IS', r); r:=r+1;
    ad_ddl.build_statement('    SELECT ''X''', r); r:=r+1;
    ad_ddl.build_statement('      FROM FEM_BALANCES fb', r); r:=r+1;
    ad_ddl.build_statement('     WHERE fb.dataset_code       =  p_hier_dataset_code', r); r:=r+1;
    ad_ddl.build_statement('       AND fb.cal_period_id      =  p_cal_period_id', r); r:=r+1;
    ad_ddl.build_statement('       AND fb.source_system_code =  p_source_system_code', r); r:=r+1;
    ad_ddl.build_statement('       AND fb.currency_code      =  p_from_ccy', r); r:=r+1;
    ad_ddl.build_statement('       AND fb.ledger_id          =  p_ledger_id', r); r:=r+1;
    ad_ddl.build_statement('       AND fb.entity_id          =  p_entity_id', r); r:=r+1;
    ad_ddl.build_statement('       AND fb.line_item_id       =  p_line_item_id;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    OPEN re_data_cur (', r); r:=r+1;
    ad_ddl.build_statement('                     p_hier_dataset_code,', r); r:=r+1;
    ad_ddl.build_statement('                     p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('                     p_source_system_code,', r); r:=r+1;
    ad_ddl.build_statement('                     p_from_ccy,', r); r:=r+1;
    ad_ddl.build_statement('                     p_ledger_id,', r); r:=r+1;
    ad_ddl.build_statement('                     p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('                     p_line_item_id);', r); r:=r+1;
    ad_ddl.build_statement('    FETCH re_data_cur INTO l_re_data_flag;', r); r:=r+1;
    ad_ddl.build_statement('    CLOSE re_data_cur;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    IF l_re_data_flag IS NOT NULL THEN', r); r:=r+1;
    ad_ddl.build_statement('      l_re_data_flag := ''Y'';', r); r:=r+1;
    ad_ddl.build_statement('    ELSE', r); r:=r+1;
    ad_ddl.build_statement('      l_re_data_flag := ''N'';', r); r:=r+1;
    ad_ddl.build_statement('    END IF;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    RETURN l_re_data_flag;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  END Get_RE_Data_Exists;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('-- Public procedures', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('   PROCEDURE Initialize_Data_Load_Status (', r); r:=r+1;
    ad_ddl.build_statement('                   p_hier_dataset_code  NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                   p_cal_period_id      NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                   p_source_system_code NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                   p_from_ccy           VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('                   p_ledger_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                   p_entity_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('                   p_line_item_id       NUMBER) IS', r); r:=r+1;
    ad_ddl.build_statement('   BEGIN', r); r:=r+1;
    ad_ddl.build_statement('     re_data_loaded_flag :=', r); r:=r+1;
    ad_ddl.build_statement('              Get_RE_Data_Exists (', r); r:=r+1;
    ad_ddl.build_statement('                       p_hier_dataset_code,', r); r:=r+1;
    ad_ddl.build_statement('                       p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('                       p_source_system_code,', r); r:=r+1;
    ad_ddl.build_statement('                       p_from_ccy,', r); r:=r+1;
    ad_ddl.build_statement('                       p_ledger_id,', r); r:=r+1;
    ad_ddl.build_statement('                       p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('                       p_line_item_id);', r); r:=r+1;
    ad_ddl.build_statement('   END;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('-- Start bugfix 5707630: Added public procedure for Roll_Forward_Rates, ', r); r:=r+1;
    ad_ddl.build_statement('-- Translate_First_Ever_Period, Translate_Subsequent_Period and ', r); r:=r+1;
    ad_ddl.build_statement('-- Create_New_Entry procedures.This public procedures will call theier respective', r); r:=r+1;
    ad_ddl.build_statement('-- private procedures (one for historical rates and the other for retained earnings).', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE Roll_Forward_Rates', r); r:=r+1;
    ad_ddl.build_statement('    (p_hier_dataset_code  NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_source_system_code NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_ledger_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_cal_period_id      NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_prev_period_id     NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_entity_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_hierarchy_id       NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_from_ccy           VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_to_ccy             VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_eq_xlate_mode      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_hier_li_id         NUMBER) IS', r); r:=r+1;
    ad_ddl.build_statement('    module    VARCHAR2(30) := ''ROLL_FORWARD_RATES:PUBLIC'';', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    GCS_TRANS_HRATES_DYNAMIC_PKG.Roll_Forward_Historical_Rates', r); r:=r+1;
    ad_ddl.build_statement('      (p_hier_dataset_code, ', r); r:=r+1;
    ad_ddl.build_statement('       p_source_system_code, ', r); r:=r+1;
    ad_ddl.build_statement('       p_ledger_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_cal_period_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_prev_period_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_entity_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_hierarchy_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_from_ccy, ', r); r:=r+1;
    ad_ddl.build_statement('       p_to_ccy, ', r); r:=r+1;
    ad_ddl.build_statement('       p_eq_xlate_mode, ', r); r:=r+1;
    ad_ddl.build_statement('       p_hier_li_id);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    GCS_TRANS_RE_DYNAMIC_PKG.Roll_Forward_Retained_Earnings', r); r:=r+1;
    ad_ddl.build_statement('      (p_hier_dataset_code, ', r); r:=r+1;
    ad_ddl.build_statement('       p_source_system_code, ', r); r:=r+1;
    ad_ddl.build_statement('       p_ledger_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_cal_period_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_prev_period_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_entity_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_hierarchy_id, ', r); r:=r+1;
    ad_ddl.build_statement('       p_from_ccy, ', r); r:=r+1;
    ad_ddl.build_statement('       p_to_ccy, ', r); r:=r+1;
    ad_ddl.build_statement('       p_eq_xlate_mode, ', r); r:=r+1;
    ad_ddl.build_statement('       p_hier_li_id);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);', r); r:=r+1;
    ad_ddl.build_statement('  END Roll_Forward_Rates;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE Translate_First_Ever_Period', r); r:=r+1;
    ad_ddl.build_statement('    (p_hier_dataset_code  NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_source_system_code NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_ledger_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_cal_period_id      NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_entity_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_hierarchy_id       NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_from_ccy           VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_to_ccy             VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_eq_xlate_mode      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_is_xlate_mode      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_avg_rate           NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_end_rate           NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_group_by_flag      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_round_factor       NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_hier_li_id         NUMBER) IS', r); r:=r+1;
    ad_ddl.build_statement('    module    VARCHAR2(50) := ''TRANSLATE_FIRST_EVER_PERIOD:PUBLIC'';', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    GCS_TRANS_HRATES_DYNAMIC_PKG.Trans_HRates_First_Per', r); r:=r+1;
    ad_ddl.build_statement('      (p_hier_dataset_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_source_system_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_ledger_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_hierarchy_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_from_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_to_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_eq_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_is_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_avg_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_end_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_group_by_flag,', r); r:=r+1;
    ad_ddl.build_statement('        p_round_factor,', r); r:=r+1;
    ad_ddl.build_statement('       p_hier_li_id);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    IF re_data_loaded_flag = ''Y'' THEN', r); r:=r+1;
    ad_ddl.build_statement('    GCS_TRANS_RE_DYNAMIC_PKG.Trans_RE_First_Per', r); r:=r+1;
    ad_ddl.build_statement('      (p_hier_dataset_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_source_system_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_ledger_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_hierarchy_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_from_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_to_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_eq_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_is_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_avg_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_end_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_group_by_flag,', r); r:=r+1;
    ad_ddl.build_statement('       p_round_factor,', r); r:=r+1;
    ad_ddl.build_statement('       p_hier_li_id);', r); r:=r+1;
    ad_ddl.build_statement('    END IF;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);', r); r:=r+1;
    ad_ddl.build_statement('  END Translate_First_Ever_Period;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE Translate_Subsequent_Period', r); r:=r+1;
    ad_ddl.build_statement('    (p_hier_dataset_code       NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_cal_period_id      NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_prev_period_id     NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_entity_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_hierarchy_id       NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_ledger_id          NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_from_ccy           VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_to_ccy             VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_eq_xlate_mode      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_is_xlate_mode      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_avg_rate           NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_end_rate           NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_group_by_flag      VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_round_factor       NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_source_system_code NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_hier_li_id         NUMBER) IS', r); r:=r+1;
    ad_ddl.build_statement('    module    VARCHAR2(50) := ''TRANSLATE_SUBSEQUENT_PERIOD:PUBLIC'';', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    GCS_TRANS_HRATES_DYNAMIC_PKG.Trans_HRates_Subseq_Per', r); r:=r+1;
    ad_ddl.build_statement('      (p_hier_dataset_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_prev_period_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_hierarchy_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_ledger_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_from_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_to_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_eq_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_is_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_avg_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_end_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_group_by_flag,', r); r:=r+1;
    ad_ddl.build_statement('          p_round_factor,', r); r:=r+1;
    ad_ddl.build_statement('       p_source_system_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_hier_li_id);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    IF re_data_loaded_flag = ''Y'' THEN', r); r:=r+1;
    ad_ddl.build_statement('    GCS_TRANS_RE_DYNAMIC_PKG.Trans_RE_Subseq_Per', r); r:=r+1;
    ad_ddl.build_statement('      (p_hier_dataset_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_prev_period_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_hierarchy_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_ledger_id,', r); r:=r+1;
    ad_ddl.build_statement('       p_from_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_to_ccy,', r); r:=r+1;
    ad_ddl.build_statement('       p_eq_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_is_xlate_mode,', r); r:=r+1;
    ad_ddl.build_statement('       p_avg_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_end_rate,', r); r:=r+1;
    ad_ddl.build_statement('       p_group_by_flag,', r); r:=r+1;
    ad_ddl.build_statement('       p_round_factor,', r); r:=r+1;
    ad_ddl.build_statement('       p_source_system_code,', r); r:=r+1;
    ad_ddl.build_statement('       p_hier_li_id);', r); r:=r+1;
    ad_ddl.build_statement('    END IF;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);', r); r:=r+1;
    ad_ddl.build_statement('  END Translate_Subsequent_Period;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('-- Create_New_Entry will not split as it does not use gcs_historical_rates table.', r); r:=r+1;
    ad_ddl.build_statement('--', r); r:=r+1;
    ad_ddl.build_statement('  PROCEDURE Create_New_Entry', r); r:=r+1;
    ad_ddl.build_statement('    (p_new_entry_id			NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_hierarchy_id			NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_entity_id			NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_cal_period_id		NUMBER,', r); r:=r+1;
    ad_ddl.build_statement('     p_balance_type_code		VARCHAR2,', r); r:=r+1;
    ad_ddl.build_statement('     p_to_ccy			VARCHAR2) IS', r); r:=r+1;
    ad_ddl.build_statement('    module    VARCHAR2(50) := ''CREATE_NEW_ENTRY:PUBLIC'';', r); r:=r+1;
    ad_ddl.build_statement('    -- Used to keep information for gcs_entry_pkg.create_entry_header.', r); r:=r+1;
    ad_ddl.build_statement('    errbuf        VARCHAR2(2000);', r); r:=r+1;
    ad_ddl.build_statement('    retcode       VARCHAR2(2000);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    -- Used because we need an IN OUT parameter', r); r:=r+1;
    ad_ddl.build_statement('    new_entry_id  NUMBER := p_new_entry_id;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('  BEGIN', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('     -- Create the entry', r); r:=r+1;
    ad_ddl.build_statement('     GCS_ENTRY_PKG.create_entry_header(', r); r:=r+1;
    ad_ddl.build_statement('              x_errbuf                 => errbuf,', r); r:=r+1;
    ad_ddl.build_statement('              x_retcode                => retcode,', r); r:=r+1;
    ad_ddl.build_statement('              p_entry_id               => new_entry_id,', r); r:=r+1;
    ad_ddl.build_statement('              p_hierarchy_id           => p_hierarchy_id,', r); r:=r+1;
    ad_ddl.build_statement('              p_entity_id              => p_entity_id,', r); r:=r+1;
    ad_ddl.build_statement('              p_start_cal_period_id    => p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('              p_end_cal_period_id      => p_cal_period_id,', r); r:=r+1;
    ad_ddl.build_statement('              p_entry_type_code        => ''AUTOMATIC'',', r); r:=r+1;
    ad_ddl.build_statement('              p_balance_type_code      => p_balance_type_code,', r); r:=r+1;
    ad_ddl.build_statement('              p_currency_code          => p_to_ccy,', r); r:=r+1;
    ad_ddl.build_statement('              p_process_code           => ''SINGLE_RUN_FOR_PERIOD'',', r); r:=r+1;
    ad_ddl.build_statement('              p_category_code          => ''TRANSLATION'',', r); r:=r+1;
    ad_ddl.build_statement('              p_xlate_flag             => ''Y'',', r); r:=r+1;
    ad_ddl.build_statement('              p_period_init_entry_flag => ''N'');', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('     IF retcode IN (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) THEN', r); r:=r+1;
    ad_ddl.build_statement('       raise GCS_CCY_ENTRY_CREATE_FAILED;', r); r:=r+1;
    ad_ddl.build_statement('     END IF;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('        write_to_log(module, FND_LOG.LEVEL_STATEMENT,', r); r:=r+1;
    ad_ddl.build_statement('    ''INSERT /*+ parallel (gcs_entry_lines) */ INTO gcs_entry_lines(entry_id, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''line_item_id, company_cost_center_org_id, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''intercompany_id, financial_elem_id, product_id, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''natural_account_id, channel_id, project_id, customer_id, task_id, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id, user_dim10_id, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''xtd_balance_e, ytd_balance_e, ptd_debit_balance_e, ptd_credit_balance_e, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''ytd_debit_balance_e, ytd_credit_balance_e, creation_date, created_by, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''last_update_date, last_updated_by, last_update_login)'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''SELECT '' || p_new_entry_id || '', '' ||', r); r:=r+1;
    ad_ddl.build_statement('    ''tgt.line_item_id, '' ||', r); r:=r+1;
    r := build_comma_list('''tgt.', ' '' ||', '''NULL, '' ||', r, 'F');
    ad_ddl.build_statement('    g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''fxata.number_assign_value *'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''decode(tgt.account_type_code,'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''       ''''REVENUE'''', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''       ''''EXPENSE'''', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''            tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''fxata.number_assign_value * (tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''tgt.xlate_ptd_dr, tgt.xlate_ptd_cr, tgt.xlate_ytd_dr, tgt.xlate_ytd_cr, sysdate, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    gcs_translation_pkg.g_fnd_user_id || '', sysdate, '' ||', r); r:=r+1;
    ad_ddl.build_statement('    gcs_translation_pkg.g_fnd_user_id || '', '' ||', r); r:=r+1;
    ad_ddl.build_statement('    gcs_translation_pkg.g_fnd_login_id || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''FROM   gcs_translation_gt, tgt,'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''       fem_ln_items_attr li,'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''       fem_ext_acct_types_attr fxata'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''WHERE  li.line_item_id = tgt.line_item_id'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''AND    li.attribute_id = '' || gcs_translation_pkg.g_li_acct_type_attr_id || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''AND    li.version_id = '' || gcs_translation_pkg.g_li_acct_type_v_id || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''AND    fxata.ext_account_type_code = li.dim_attribute_varchar_label'' || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''AND    fxata.attribute_id = '' || gcs_translation_pkg.g_xat_sign_attr_id || g_nl ||', r); r:=r+1;
    ad_ddl.build_statement('    ''AND    fxata.version_id = '' || gcs_translation_pkg.g_xat_sign_v_id);', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('        INSERT /*+ parallel (gcs_entry_lines) */ INTO gcs_entry_lines(', r); r:=r+1;
    ad_ddl.build_statement('          entry_id, line_item_id, company_cost_center_org_id,', r); r:=r+1;
    ad_ddl.build_statement('          intercompany_id, financial_elem_id,', r); r:=r+1;
    ad_ddl.build_statement('          product_id, natural_account_id, channel_id, project_id, customer_id,', r); r:=r+1;
    ad_ddl.build_statement('          task_id, user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id,', r); r:=r+1;
    ad_ddl.build_statement('          user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id,', r); r:=r+1;
    ad_ddl.build_statement('          user_dim10_id, xtd_balance_e, ytd_balance_e, ptd_debit_balance_e,', r); r:=r+1;
    ad_ddl.build_statement('          ptd_credit_balance_e, ytd_debit_balance_e, ytd_credit_balance_e,', r); r:=r+1;
    ad_ddl.build_statement('          creation_date, created_by, last_update_date, last_updated_by,', r); r:=r+1;
    ad_ddl.build_statement('          last_update_login)', r); r:=r+1;
    ad_ddl.build_statement('        SELECT', r); r:=r+1;
    ad_ddl.build_statement('          p_new_entry_id,', r); r:=r+1;
    ad_ddl.build_statement('          tgt.line_item_id,', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    r := build_comma_list('      tgt.', '', '      NULL,', r, 'F');
    ad_ddl.build_statement('         fxata.number_assign_value *', r); r:=r+1;
    ad_ddl.build_statement('          decode(tgt.account_type_code,', r); r:=r+1;
    ad_ddl.build_statement('                 ''REVENUE'', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,', r); r:=r+1;
    ad_ddl.build_statement('                 ''EXPENSE'', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,', r); r:=r+1;
    ad_ddl.build_statement('                      tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),', r); r:=r+1;
    ad_ddl.build_statement('          fxata.number_assign_value * (tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),', r); r:=r+1;
    ad_ddl.build_statement('          tgt.xlate_ptd_dr, tgt.xlate_ptd_cr, tgt.xlate_ytd_dr, tgt.xlate_ytd_cr,', r); r:=r+1;
    ad_ddl.build_statement('          sysdate, gcs_translation_pkg.g_fnd_user_id, sysdate,', r); r:=r+1;
    ad_ddl.build_statement('    gcs_translation_pkg.g_fnd_user_id, gcs_translation_pkg.g_fnd_login_id', r); r:=r+1;
    ad_ddl.build_statement('        FROM   gcs_translation_gt tgt,', r); r:=r+1;
    ad_ddl.build_statement('               fem_ln_items_attr li,', r); r:=r+1;
    ad_ddl.build_statement('               fem_ext_acct_types_attr fxata', r); r:=r+1;
    ad_ddl.build_statement('        WHERE  li.line_item_id = tgt.line_item_id', r); r:=r+1;
    ad_ddl.build_statement('        AND    li.attribute_id = gcs_translation_pkg.g_li_acct_type_attr_id', r); r:=r+1;
    ad_ddl.build_statement('        AND    li.version_id = gcs_translation_pkg.g_li_acct_type_v_id', r); r:=r+1;
    ad_ddl.build_statement('        AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member', r); r:=r+1;
    ad_ddl.build_statement('        AND    fxata.attribute_id = gcs_translation_pkg.g_xat_sign_attr_id', r); r:=r+1;
    ad_ddl.build_statement('        AND    fxata.version_id = gcs_translation_pkg.g_xat_sign_v_id;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);', r); r:=r+1;
    ad_ddl.build_statement('      EXCEPTION', r); r:=r+1;
    ad_ddl.build_statement('        WHEN GCS_CCY_ENTRY_CREATE_FAILED THEN', r); r:=r+1;
    ad_ddl.build_statement('          module_log_write(module, g_module_failure);', r); r:=r+1;
    ad_ddl.build_statement('          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;', r); r:=r+1;
    ad_ddl.build_statement('        WHEN OTHERS THEN', r); r:=r+1;
    ad_ddl.build_statement('          FND_MESSAGE.set_name(''GCS'', ''GCS_CCY_NEW_ENTRY_UNEXP_ERR'');', r); r:=r+1;
    ad_ddl.build_statement('          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;', r); r:=r+1;
    ad_ddl.build_statement('          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);', r); r:=r+1;
    ad_ddl.build_statement('          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);', r); r:=r+1;
    ad_ddl.build_statement('          module_log_write(module, g_module_failure);', r); r:=r+1;
    ad_ddl.build_statement('          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);', r); r:=r+1;
    ad_ddl.build_statement('  END Create_New_Entry;', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement(' ', r); r:=r+1;
    ad_ddl.build_statement('END GCS_TRANS_DYNAMIC_PKG;', r);

    ad_ddl.create_plsql_object(appl, 'APPS', 'GCS_TRANS_DYNAMIC_PKG', 1, r, 'TRUE', err);

    IF err = 'TRUE' THEN
      raise GCS_CCY_DYN_PKG_BUILD_ERR;
    END IF;

    module_log_write(module, g_module_success);
  EXCEPTION
    WHEN GCS_CCY_APPLSYS_NOT_FOUND THEN
      FND_MESSAGE.SET_NAME('GCS', 'GCS_APPLSYS_NOT_FOUND');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      x_errbuf := g_error_text;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
    WHEN GCS_CCY_DYN_PKG_BUILD_ERR THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_DYN_PKG_BUILD_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      x_errbuf := g_error_text;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_CCY_DYN_PKG_ERR');
      g_error_text := FND_MESSAGE.get;
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, g_error_text);
      write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
      x_errbuf := g_error_text;
      x_retcode := '2';
      module_log_write(module, g_module_failure);
  END Create_Package;

END GCS_TRANS_DYN_BUILD_PKG;

/
