--------------------------------------------------------
--  DDL for Package GCS_TRANS_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TRANS_DYN_BUILD_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsxltds.pls 120.4 2007/06/28 12:30:06 vkosuri noship $ */

--
-- Package
--   gcs_trans_dyn_build_pkg
-- Purpose
--   Dynamically created package procedures for the Translation Program
-- History
--   07-JAN-03	M Ward		Created
--


  -- Bugfix 5725759: Made the req variables as global variables.
  -- Store whether a dimension is used by GCS
  -- Bugfix 5707630: Add global variables for company_cost_center_org_id and
  -- intercompany_id as they can also be disabled now.
  g_cctr_req  VARCHAR2(1);
  g_ic_req    VARCHAR2(1);
  g_fe_req    VARCHAR2(1);
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

  -- Bugfix 5707630: Store variables for all dimensions that determine whether it
  -- is enabled or disbaled for historical rates.
  g_cctr_hrate_req  VARCHAR2(1);
  g_ic_hrate_req    VARCHAR2(1);
  g_fe_hrate_req    VARCHAR2(1);
  g_prd_hrate_req   VARCHAR2(1);
  g_na_hrate_req    VARCHAR2(1);
  g_chl_hrate_req   VARCHAR2(1);
  g_prj_hrate_req   VARCHAR2(1);
  g_cst_hrate_req   VARCHAR2(1);
  g_tsk_hrate_req   VARCHAR2(1);
  g_ud1_hrate_req   VARCHAR2(1);
  g_ud2_hrate_req   VARCHAR2(1);
  g_ud3_hrate_req   VARCHAR2(1);
  g_ud4_hrate_req   VARCHAR2(1);
  g_ud5_hrate_req   VARCHAR2(1);
  g_ud6_hrate_req   VARCHAR2(1);
  g_ud7_hrate_req   VARCHAR2(1);
  g_ud8_hrate_req   VARCHAR2(1);
  g_ud9_hrate_req   VARCHAR2(1);
  g_ud10_hrate_req  VARCHAR2(1);


  -- Bugfix 5707630: Made this procedure public as it will be invoked from the
  -- GCS_TRANS_HRATES_DYN_BUILD_PKG and GCS_TRANS_RE_DYN_BUILD_PKG
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
  FUNCTION Build_Comma_List(	p_prefix	VARCHAR2,
		                		p_suffix	VARCHAR2,
                 				p_null_text	VARCHAR2,
                				p_first_rownum	NUMBER,
                                p_key           VARCHAR2) RETURN NUMBER;



  -- Bugfix 5707630: Made this procedure public as it will be invoked from the
  -- GCS_TRANS_HRATES_DYN_BUILD_PKG and GCS_TRANS_RE_DYN_BUILD_PKG
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
  FUNCTION Build_Join_List(	p_left		VARCHAR2,
		            		p_middle	VARCHAR2,
            				p_right		VARCHAR2,
            				p_first_rownum	NUMBER,
                            p_key           VARCHAR2) RETURN NUMBER;


  --
  -- Procedure
  --   Create_Package
  -- Purpose
  --   Create the dynamic portion of the translation program
  -- Example
  --   GCS_TRANS_DYN_BUILD_PKG.Create_Package
  -- Notes
  --
  PROCEDURE Create_Package(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2);


  -- Bugfix : 5725759
  -- Procedure
  --   Initialize_Dimensions
  -- Purpose
  --   Initializes the historical rates and fem dimension required variables.
  -- Example
  --   GCS_TRANS_DYN_BUILD_PKG.Initialize_Dimensions
  -- Notes
  --
  PROCEDURE Initialize_Dimensions;


END GCS_TRANS_DYN_BUILD_PKG;

/
