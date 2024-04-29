--------------------------------------------------------
--  DDL for Package FII_AR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIARUTILS.pls 120.15.12000000.1 2007/02/23 02:29:37 applrt ship $ */

g_as_of_date 	           DATE;
g_page_period_type         VARCHAR2(100);
g_currency                 VARCHAR2(50);
g_view_by                  VARCHAR2(100);
g_time_comp                VARCHAR2(30);
g_region_code		   VARCHAR2(100);
g_session_id           NUMBER;
g_party_id 	           VARCHAR2(500) := 'All';
g_parent_party_id          VARCHAR2(30) := 'All';
g_cust_account_id          VARCHAR2(30) := 'All';
g_org_id		   VARCHAR2(30) := 'All';
g_collector_id		   VARCHAR2(30) := 'All';
g_industry_id		   VARCHAR2(30) := 'All';
g_curr_suffix               VARCHAR2(4);
g_cust_suffix               VARCHAR2(6);
g_cust_view_by		   VARCHAR2(15);
g_curr_per_start           DATE;
g_curr_per_end             DATE;
g_prior_per_start          DATE;
g_prior_per_end            DATE;
g_curr_month_start         DATE;
g_bitand            	   NUMBER;
g_dso_bitand               NUMBER;
g_bitand_inc_todate	   NUMBER;
g_bitand_rolling_30_days   NUMBER;
g_self_msg		   VARCHAR2(240);
g_previous_asof_date       DATE;
g_is_hierarchical_flag	   VARCHAR2(1);
g_count_parent_party_id	   NUMBER;
g_dso_period		   NUMBER;
g_industry_class_type	   VARCHAR2(100);
g_security_profile_id 	   NUMBER;
g_security_org_id	   NUMBER;
g_operating_unit	   VARCHAR2(240);
g_functional_currency_code	VARCHAR2(3);
g_prim_global_currency_code 	VARCHAR2(15);
g_sec_global_currency_code  	VARCHAR2(15);
g_common_functional_currency 	VARCHAR2(3);
g_det_ou_lov		  NUMBER;
g_business_group_id 	  NUMBER;
g_all_operating_unit 	  VARCHAR2(240);
g_order_by 	  VARCHAR2(500);
g_sd_prior			DATE;
g_sd_prior_prior		DATE;
g_sd_curr_sdate		DATE;
g_function_name          VARCHAR2(100);
g_col_curr_suffix        VARCHAR2(10);
g_cash_receipt_id	NUMBER;
g_cust_trx_id		VARCHAR2(30);
g_tran_num		VARCHAR2(30);
g_tran_class		VARCHAR2(30);
g_cust_account		VARCHAR2(30);
g_account_num		VARCHAR2(30);
g_app_cust_trx_id	NUMBER;
g_bucket_num		NUMBER;
g_page_refresh_date DATE;

TYPE dso_setup is RECORD (dso_type VARCHAR2(15), dso_value VARCHAR2(15));
TYPE dso_setup_tbl is table of dso_setup index by binary_integer;
g_dso_table dso_setup_tbl;

--   This package will provide central utilities for Receivables PMV content

-- -----------------------------------------------------------------------
-- Name: reset_globals
-- Desc: This procedure is used to reset all the global variables to null.
-- Output: N/A.
-- -----------------------------------------------------------------------

PROCEDURE reset_globals;

-- -----------------------------------------------------------------------
-- Name: get_parameters
-- Desc: This procedure is consumed by all the reports to set the global
--       variables.
-- Output: N/A.
-- -----------------------------------------------------------------------
PROCEDURE get_parameters (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL);

-- -----------------------------------------------------------------------
-- Name: get_viewby_id
-- Desc: This procedure is used to obtain the viewby columns for aggregated
--       and nonaggregated nodes.
-- -----------------------------------------------------------------------
--PROCEDURE get_viewby_id (p_viewby_id OUT NOCOPY VARCHAR2);

-- -----------------------------------------------------------------------
-- Name: get_viewby
-- Desc: This procedure is used to obtain the label of the first column
--       in trend reports
-- -----------------------------------------------------------------------
FUNCTION get_trend_viewby return VARCHAR2;

-- -----------------------------------------------------------------------
-- Name: bind_variable
-- Desc: This procedure is used to bind all the bind variables, no literal
--       shall be used in any report
-- Output: N/A.
-- -----------------------------------------------------------------------

PROCEDURE bind_variable (p_sqlstmt IN Varchar2,
                         p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_sql_output OUT NOCOPY Varchar2,
                         p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- -----------------------------------------------------------------------
-- Name: populate_summary_gt_tables
-- Desc: This procedure is used to populate the global tables
-- -----------------------------------------------------------------------
PROCEDURE populate_summary_gt_tables;

PROCEDURE insert_into_debug_table;

PROCEDURE populate_party_id;

FUNCTION get_sec_profile RETURN NUMBER;

FUNCTION get_dso_period_profile RETURN NUMBER;

FUNCTION get_curr RETURN VARCHAR2;

FUNCTION get_dso_setup_value(p_category IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE get_dso_table_values;

FUNCTION get_prim_global_currency_code RETURN VARCHAR2;

FUNCTION get_sec_global_currency_code RETURN VARCHAR2;

FUNCTION determine_OU_LOV RETURN NUMBER;

FUNCTION get_business_group RETURN NUMBER;

FUNCTION get_display_currency(p_selected_operating_unit  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_from_statement RETURN VARCHAR2;

FUNCTION get_where_statement RETURN VARCHAR2;

FUNCTION get_mv_where_statement RETURN VARCHAR2;

FUNCTION get_rct_mv_where_statement RETURN VARCHAR2;

PROCEDURE get_page_refresh_date;

END fii_ar_util_pkg;

 

/
