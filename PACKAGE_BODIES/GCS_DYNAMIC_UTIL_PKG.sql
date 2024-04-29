--------------------------------------------------------
--  DDL for Package Body GCS_DYNAMIC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DYNAMIC_UTIL_PKG" AS
/* $Header: gcsdynutilb.pls 120.1 2005/09/15 18:38:40 spala noship $ */

--
-- Private Exceptions
--
  GCS_CCY_APPLSYS_NOT_FOUND	EXCEPTION;

--
-- Private Global Variables
--

  -- Store whether a dimension is used by GCS
  g_felm_req  VARCHAR2(1);
  g_prd_req   VARCHAR2(1);
  g_na_req    VARCHAR2(1);
  g_chl_req   VARCHAR2(1);
  g_prj_req   VARCHAR2(1);
  g_cst_req   VARCHAR2(1);
  g_tsk_req   VARCHAR2(1);
  g_ud1_req   VARCHAR2(1);
  g_ud2_req   VARCHAR2(1);
  g_ud3_req   VARCHAR2(1);
  g_ud4_req   VARCHAR2(1);
  g_ud5_req   VARCHAR2(1);
  g_ud6_req   VARCHAR2(1);
  g_ud7_req   VARCHAR2(1);
  g_ud8_req   VARCHAR2(1);
  g_ud9_req   VARCHAR2(1);
  g_ud10_req  VARCHAR2(1);

  -- Store whether a dimension is used by FEM
  g_felm_fem_req  VARCHAR2(1);
  g_prd_fem_req   VARCHAR2(1);
  g_na_fem_req    VARCHAR2(1);
  g_chl_fem_req   VARCHAR2(1);
  g_prj_fem_req   VARCHAR2(1);
  g_cst_fem_req   VARCHAR2(1);
  g_tsk_fem_req   VARCHAR2(1);
  g_ud1_fem_req   VARCHAR2(1);
  g_ud2_fem_req   VARCHAR2(1);
  g_ud3_fem_req   VARCHAR2(1);
  g_ud4_fem_req   VARCHAR2(1);
  g_ud5_fem_req   VARCHAR2(1);
  g_ud6_fem_req   VARCHAR2(1);
  g_ud7_fem_req   VARCHAR2(1);
  g_ud8_fem_req   VARCHAR2(1);
  g_ud9_fem_req   VARCHAR2(1);
  g_ud10_fem_req  VARCHAR2(1);

  --
  -- Private Procedures
  --

  PROCEDURE init_dyn_pkg_info IS

    status	VARCHAR2(1);
    industry	VARCHAR2(1);
--    appl	VARCHAR2(30);

  BEGIN
    -- Initialize the dimension information.
    GCS_UTILITY_PKG.init_dimension_info;

    -- Set the global variables determining which dimensions are used by GCS
    g_felm_req := gcs_utility_pkg.get_dimension_required('FINANCIAL_ELEM_ID');
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

    -- Set the global variables determining which dimensions are used by FEM
    g_felm_fem_req := gcs_utility_pkg.get_fem_dim_required('FINANCIAL_ELEM_ID');
    g_prd_fem_req  := gcs_utility_pkg.get_fem_dim_required('PRODUCT_ID');
    g_na_fem_req   := gcs_utility_pkg.get_fem_dim_required('NATURAL_ACCOUNT_ID');
    g_chl_fem_req  := gcs_utility_pkg.get_fem_dim_required('CHANNEL_ID');
    g_prj_fem_req  := gcs_utility_pkg.get_fem_dim_required('PROJECT_ID');
    g_cst_fem_req  := gcs_utility_pkg.get_fem_dim_required('CUSTOMER_ID');
    g_tsk_fem_req  := gcs_utility_pkg.get_fem_dim_required('TASK_ID');
    g_ud1_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM1_ID');
    g_ud2_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM2_ID');
    g_ud3_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM3_ID');
    g_ud4_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM4_ID');
    g_ud5_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM5_ID');
    g_ud6_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM6_ID');
    g_ud7_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM7_ID');
    g_ud8_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM8_ID');
    g_ud9_fem_req  := gcs_utility_pkg.get_fem_dim_required('USER_DIM9_ID');
    g_ud10_fem_req := gcs_utility_pkg.get_fem_dim_required('USER_DIM10_ID');

    -- Get APPLSYS information. Needed for ad_ddl
    IF NOT fnd_installation.get_app_info('FND', status, industry,
					 g_applsys_username) THEN
      raise gcs_ccy_applsys_not_found;
    END IF;

  END init_dyn_pkg_info;

  --
  -- Procedure
  --   Build_Dimension_Row
  -- Purpose
  --   Build one row of the comma or join list in ad_ddl.
  --
  -- Arguments
  --   p_item		The item to write if the dimension is used
  --   p_def_item	The item to write if the dimension is unused
  --   p_rownum		The row number to use for ad_ddl
  --   p_dim_req	Whether or not the dimension is required
  -- Example
  --
  -- Notes
  --   Returns the line number for the next row.
  --
  FUNCTION Build_Dimension_Row( p_item		VARCHAR2,
				p_def_item	VARCHAR2,
				p_rownum	NUMBER,
				p_dim_req	VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_dim_req = 'Y' THEN
      ad_ddl.build_statement(p_item, p_rownum);
    ELSE
      ad_ddl.build_statement(p_def_item, p_rownum);
    END IF;
    RETURN (p_rownum + 1);
  END Build_Dimension_Row;

  --
  -- Procedure
  --   Build_Fem_Dimension_Row
  -- Purpose
  --   Build one row of the comma or join list in ad_ddl.
  --
  -- Arguments
  --   p_item		The item to write if the dimension is used
  --   p_def_item	The item to write if the dimension is unused
  --   p_rownum		The row number to use for ad_ddl
  --   p_dim_req	Whether or not the dimension is required
  -- Example
  --
  -- Notes
  --   Returns the line number for the next row.
  --
  FUNCTION Build_Fem_Dimension_Row( p_item		VARCHAR2,
				p_def_item	VARCHAR2,
				p_rownum	NUMBER,
				p_dim_req	VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_dim_req = 'Y' THEN
      ad_ddl.build_statement('''' || p_item || '''' || ',', p_rownum);
    ELSE
      ad_ddl.build_statement(p_def_item, p_rownum);
    END IF;
    RETURN (p_rownum + 1);
  END Build_Fem_Dimension_Row;


  --
  -- Public Procedures
  --

  FUNCTION Build_Comma_List(p_prefix		VARCHAR2,
			    p_suffix		VARCHAR2,
			    p_default_text	VARCHAR2,
			    p_first_rownum	NUMBER) RETURN NUMBER IS
    the_rownum  NUMBER := p_first_rownum;
  BEGIN
    -- Go through each of the optional dimensions, and fill out accordingly

    the_rownum := build_dimension_row(p_prefix||'FINANCIAL_ELEM_ID,'||p_suffix,
			p_default_text, the_rownum, g_felm_req);
    the_rownum := build_dimension_row(p_prefix||'PRODUCT_ID,'||p_suffix,
			p_default_text, the_rownum, g_prd_req);
    the_rownum := build_dimension_row(p_prefix||'NATURAL_ACCOUNT_ID,'||p_suffix,
			p_default_text, the_rownum, g_na_req);
    the_rownum := build_dimension_row(p_prefix||'CHANNEL_ID,'||p_suffix,
			p_default_text, the_rownum, g_chl_req);
    the_rownum := build_dimension_row(p_prefix||'PROJECT_ID,'||p_suffix,
			p_default_text, the_rownum, g_prj_req);
    the_rownum := build_dimension_row(p_prefix||'CUSTOMER_ID,'||p_suffix,
			p_default_text, the_rownum,g_cst_req);
    the_rownum := build_dimension_row(p_prefix||'TASK_ID,'||p_suffix,
			p_default_text, the_rownum, g_tsk_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM1_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud1_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM2_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud2_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM3_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud3_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM4_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud4_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM5_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud5_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM6_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud6_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM7_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud7_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM8_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud8_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM9_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud9_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM10_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud10_req);

    RETURN the_rownum;
  END Build_Comma_List;


  FUNCTION Build_Join_List(p_left		VARCHAR2,
			   p_middle		VARCHAR2,
			   p_right		VARCHAR2,
			   p_first_rownum	NUMBER) RETURN NUMBER IS
    the_rownum NUMBER := p_first_rownum;
  BEGIN
    -- Go through each of the optional dimensions, and fill out accordingly

    the_rownum := build_dimension_row(p_left||'FINANCIAL_ELEM_ID'||
				p_middle||'FINANCIAL_ELEM_ID'||p_right,
				'', the_rownum, g_felm_req);
    the_rownum := build_dimension_row(p_left||'PRODUCT_ID'||
				p_middle||'PRODUCT_ID'||p_right,
				'', the_rownum, g_prd_req);
    the_rownum := build_dimension_row(p_left||'NATURAL_ACCOUNT_ID'||
				p_middle||'NATURAL_ACCOUNT_ID'||p_right,
				'', the_rownum, g_na_req);
    the_rownum := build_dimension_row(p_left||'CHANNEL_ID'||
				p_middle||'CHANNEL_ID'||p_right,
				'', the_rownum, g_chl_req);
    the_rownum := build_dimension_row(p_left||'PROJECT_ID'||
				p_middle||'PROJECT_ID'||p_right,
				'', the_rownum, g_prj_req);
    the_rownum := build_dimension_row(p_left||'CUSTOMER_ID'||
				p_middle||'CUSTOMER_ID'||p_right,
				'', the_rownum, g_cst_req);
    the_rownum := build_dimension_row(p_left||'TASK_ID'||
				p_middle||'TASK_ID'||p_right,
				'', the_rownum, g_tsk_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM1_ID'||
				p_middle||'USER_DIM1_ID'||p_right,
				'', the_rownum, g_ud1_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM2_ID'||
				p_middle||'USER_DIM2_ID'||p_right,
				'', the_rownum, g_ud2_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM3_ID'||
				p_middle||'USER_DIM3_ID'||p_right,
				'', the_rownum, g_ud3_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM4_ID'||
				p_middle||'USER_DIM4_ID'||p_right,
				'', the_rownum, g_ud4_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM5_ID'||
				p_middle||'USER_DIM5_ID'||p_right,
				'', the_rownum, g_ud5_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM6_ID'||
				p_middle||'USER_DIM6_ID'||p_right,
				'', the_rownum, g_ud6_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM7_ID'||
				p_middle||'USER_DIM7_ID'||p_right,
				'', the_rownum, g_ud7_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM8_ID'||
				p_middle||'USER_DIM8_ID'||p_right,
				'', the_rownum, g_ud8_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM9_ID'||
				p_middle||'USER_DIM9_ID'||p_right,
				'', the_rownum, g_ud9_req);
    the_rownum := build_dimension_row(p_left||'USER_DIM10_ID'||
				p_middle||'USER_DIM10_ID'||p_right,
				'', the_rownum, g_ud10_req);

    RETURN the_rownum;
  END Build_Join_List;


  --
  -- Public Procedures
  --

  FUNCTION Build_Fem_Comma_List(p_prefix		VARCHAR2,
			    p_suffix		VARCHAR2,
			    p_default_text	VARCHAR2,
			    p_first_rownum	NUMBER,
                            p_value_req         VARCHAR2) RETURN NUMBER IS
    the_rownum  NUMBER := p_first_rownum;
    default_val NUMBER;
  BEGIN
    -- Go through each of the optional dimensions, and fill out accordingly

    IF (p_value_req = 'Y' AND g_felm_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('FINANCIAL_ELEM_ID');
        the_rownum := build_fem_dimension_row( to_char(default_val), p_default_text, the_rownum, g_felm_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'FINANCIAL_ELEM_ID,'||p_suffix,p_default_text, the_rownum, g_felm_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_prd_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('PRODUCT_ID');
        the_rownum := build_fem_dimension_row( to_char(default_val), p_default_text, the_rownum, g_prd_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'PRODUCT_ID,'||p_suffix,p_default_text, the_rownum, g_prd_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_na_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('NATURAL_ACCOUNT_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_na_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'NATURAL_ACCOUNT_ID,'||p_suffix,p_default_text, the_rownum, g_na_fem_req);
    END IF;


    IF (p_value_req = 'Y' AND g_chl_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('CHANNEL_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_chl_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'CHANNEL_ID,'||p_suffix,
			p_default_text, the_rownum, g_chl_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_prj_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('PROJECT_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_prj_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'PROJECT_ID,'||p_suffix,
			p_default_text, the_rownum, g_prj_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_cst_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('CUSTOMER_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_cst_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'CUSTOMER_ID,'||p_suffix,
			p_default_text, the_rownum,g_cst_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_tsk_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('TASK_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_tsk_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'TASK_ID,'||p_suffix,
			p_default_text, the_rownum, g_tsk_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud1_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM1_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud1_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM1_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud1_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud2_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM2_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud2_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM2_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud2_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud3_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM3_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud3_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM3_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud3_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud4_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM4_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud4_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM4_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud4_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud5_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM5_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud5_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM5_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud5_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud6_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM6_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud6_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM6_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud6_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud7_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM7_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud7_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM7_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud7_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud8_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM8_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud8_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM8_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud8_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud9_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM9_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud9_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM9_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud9_fem_req);
    END IF;

    IF (p_value_req = 'Y' AND g_ud10_req = 'N') THEN
        default_val := GCS_UTILITY_PKG.get_default_value('USER_DIM10_ID');
        the_rownum := build_fem_dimension_row(to_char(default_val), p_default_text, the_rownum, g_ud10_fem_req);
    ELSE
        the_rownum := build_dimension_row(p_prefix||'USER_DIM10_ID,'||p_suffix,
			p_default_text, the_rownum, g_ud10_fem_req);
    END IF;

    RETURN the_rownum;
  END Build_Fem_Comma_List;

  --
  -- Public Procedures
  --

  FUNCTION Build_interco_Comma_List(p_pre_prefix		VARCHAR2,
                            p_prefix	VARCHAR2,
                            P_post_prefix       VARCHAR2,
                            p_pre_suffix        VARCHAR2,
			    p_suffix		VARCHAR2,
                            p_post_suffix       VARCHAR2,
			    p_default_text	VARCHAR2,
			    p_first_rownum	NUMBER) RETURN NUMBER IS
    the_rownum  NUMBER := p_first_rownum;
  BEGIN
    -- Go through each of the optional dimensions, and fill out accordingly
/*   the_rownum := build_dimension_row(p_prefix||'FINANCIAL_ELEM_ID,'
  ||p_post_prefix||'''FINANCIAL_ELEM_ID'','
  ||p_pre_suffix||'FINANCIAL_ELEM_ID'||p_suffix
  ||p_post_suffix, p_default_text, the_rownum, g_felm_req);   */
  the_rownum := build_dimension_row(
                 p_pre_prefix||'FINANCIAL_ELEM_ID,'||p_post_suffix,
			p_default_text, the_rownum, g_felm_req);
   the_rownum := build_dimension_row(
                        p_pre_prefix||'PRODUCT_ID,'||p_post_suffix,
			p_default_text, the_rownum, g_prd_req);
   the_rownum := build_dimension_row(
                       p_pre_prefix||'NATURAL_ACCOUNT_ID,'||p_post_suffix,
			 p_default_text, the_rownum, g_na_req);
   the_rownum := build_dimension_row(
                       p_pre_prefix||'CHANNEL_ID,'||p_post_suffix,
			  p_default_text, the_rownum, g_chl_req);
   the_rownum := build_dimension_row(
                      p_pre_prefix||'PROJECT_ID,'||p_post_suffix,
			p_default_text, the_rownum, g_prj_req);
   the_rownum := build_dimension_row(
                         p_pre_prefix||'CUSTOMER_ID,'||p_post_suffix,
			p_default_text, the_rownum,g_cst_req);
   the_rownum := build_dimension_row(p_pre_prefix||'TASK_ID,'||p_post_suffix,
			p_default_text, the_rownum, g_tsk_req);
    the_rownum := build_dimension_row(p_prefix||'USER_DIM1_ID,'
                      ||p_post_prefix||'''USER_DIM1_ID'','
                      ||p_pre_suffix||'USER_DIM1_ID'||p_suffix
                      ||p_post_suffix, p_default_text, the_rownum, g_ud1_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM2_ID,'
                      ||p_post_prefix||'''USER_DIM2_ID'','
                      ||p_pre_suffix||'USER_DIM2_ID'||p_suffix
                      ||p_post_suffix, p_default_text, the_rownum, g_ud2_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM3_ID,'
                       ||p_post_prefix||'''USER_DIM3_ID'','
                       ||p_pre_suffix||'USER_DIM3_ID'||p_suffix
		       ||p_post_suffix, p_default_text,the_rownum, g_ud3_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM4_ID,'
                        ||p_post_prefix||'''USER_DIM4_ID'','
                        ||p_pre_suffix||'USER_DIM4_ID'||p_suffix
			||p_post_suffix,p_default_text, the_rownum, g_ud4_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM5_ID,'
                        ||p_post_prefix||'''USER_DIM5_ID'','
                        ||p_pre_suffix||'USER_DIM5_ID'||p_suffix
			||p_post_suffix,p_default_text, the_rownum, g_ud5_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM6_ID,'
                        ||p_post_prefix||'''USER_DIM6_ID'','
                        ||p_pre_suffix||'USER_DIM6_ID'||p_suffix
			||p_post_suffix,p_default_text, the_rownum, g_ud6_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM7_ID,'
                        ||p_post_prefix||'''USER_DIM7_ID'','
                        ||p_pre_suffix||'USER_DIM7_ID'||p_suffix
			||p_post_suffix,p_default_text, the_rownum, g_ud7_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM8_ID,'
                        ||p_post_prefix||'''USER_DIM8_ID'','
                        ||p_pre_suffix||'USER_DIM8_ID'||p_suffix
			||p_post_suffix,p_default_text, the_rownum, g_ud8_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM9_ID,'
                        ||p_post_prefix||'''USER_DIM9_ID'','
                        ||p_pre_suffix||'USER_DIM9_ID'||p_suffix
			||p_post_suffix,p_default_text, the_rownum, g_ud9_req);

    the_rownum := build_dimension_row(p_prefix||'USER_DIM10_ID,'
                        ||p_post_prefix||'''USER_DIM10_ID'','
                        ||p_pre_suffix||'USER_DIM10_ID'||p_suffix
			||p_post_suffix,p_default_text,the_rownum, g_ud10_req);

    RETURN the_rownum;
  END Build_Interco_Comma_List;


  FUNCTION index_col_list ( collist OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
  BEGIN

    IF g_felm_req = 'Y' THEN
      collist := 'FINANCIAL_ELEM_ID, ';
    END IF;
    IF g_prd_req = 'Y' THEN
      collist := collist || 'PRODUCT_ID, ';
    END IF;
    IF g_na_req = 'Y' THEN
      collist := collist || 'NATURAL_ACCOUNT_ID, ';
    END IF;
    IF g_chl_req = 'Y' THEN
      collist := collist || 'CHANNEL_ID, ';
    END IF;
    IF g_prj_req = 'Y' THEN
      collist := collist || 'PROJECT_ID, ';
    END IF;
    IF g_cst_req = 'Y' THEN
      collist := collist || 'CUSTOMER_ID, ';
    END IF;
    IF g_tsk_req = 'Y' THEN
      collist := collist || 'TASK_ID, ';
    END IF;
    IF g_ud1_req = 'Y' THEN
      collist := collist || 'USER_DIM1_ID, ';
    END IF;
    IF g_ud2_req = 'Y' THEN
      collist := collist || 'USER_DIM2_ID, ';
    END IF;
    IF g_ud3_req = 'Y' THEN
      collist := collist || 'USER_DIM3_ID, ';
    END IF;
    IF g_ud4_req = 'Y' THEN
      collist := collist || 'USER_DIM4_ID, ';
    END IF;
    IF g_ud5_req = 'Y' THEN
      collist := collist || 'USER_DIM5_ID, ';
    END IF;
    IF g_ud6_req = 'Y' THEN
      collist := collist || 'USER_DIM6_ID, ';
    END IF;
    IF g_ud7_req = 'Y' THEN
      collist := collist || 'USER_DIM7_ID, ';
    END IF;
    IF g_ud8_req = 'Y' THEN
      collist := collist || 'USER_DIM8_ID, ';
    END IF;
    IF g_ud9_req = 'Y' THEN
      collist := collist || 'USER_DIM9_ID, ';
    END IF;
    IF g_ud10_req = 'Y' THEN
      collist := collist || 'USER_DIM10_ID, ';
    END IF;

    RETURN collist;
  END index_col_list;


BEGIN

  init_dyn_pkg_info();

  EXCEPTION
    WHEN GCS_CCY_APPLSYS_NOT_FOUND THEN
      FND_MESSAGE.SET_NAME('GCS', 'GCS_APPLSYS_NOT_FOUND');
      IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED THEN
        FND_LOG.message(FND_LOG.LEVEL_UNEXPECTED, 'GCS_DYNAMIC_UTIL_PKG');
      END IF;
    WHEN OTHERS THEN
      FND_MESSAGE.set_name('GCS', 'GCS_DYNAMIC_UTIL_PKG_ERR');
      IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED THEN
        FND_LOG.message(FND_LOG.LEVEL_UNEXPECTED, 'GCS_DYNAMIC_UTIL_PKG');
      END IF;
END GCS_DYNAMIC_UTIL_PKG;

/
