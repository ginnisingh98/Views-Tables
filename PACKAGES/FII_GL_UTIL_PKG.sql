--------------------------------------------------------
--  DDL for Package FII_GL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLC5S.pls 120.6 2006/03/15 15:09:18 hpoddar noship $ */
g_viewby_type              VARCHAR2(50);
g_period_type              NUMBER;
g_where_period_type        NUMBER;
g_act_where_period_type    NUMBER;
g_ent_period_type          NUMBER;
g_actual_period_type       NUMBER;
g_budget_period_type       NUMBER;
g_forecast_period_type     NUMBER;
g_global_curr_view         VARCHAR2(1);
g_view		           VARCHAR2(100);
g_view_by                  VARCHAR2(30);
g_lob_id                   VARCHAR2(30);
g_previous_asof_date       DATE;
g_as_of_date 	           DATE;
g_curr_start		   DATE;
g_curr_end		   DATE;
g_temp			   DATE;
g_prior_start		   DATE;
g_prior_end		   DATE;
g_mgr_id	           NUMBER;
g_mgr_mgr_id               NUMBER;
g_fin_id	           NUMBER;
g_py_sper_end	           DATE;
g_curr_per_sequence        NUMBER;
g_p_period_end 	           DATE;
g_p_p_period_end           DATE;
g_ccc_id	           NUMBER;
g_time_comp	           VARCHAR2(30);
g_currency	           VARCHAR2(50);
g_gid		           VARCHAR2(30);
g_lob_from_clause          VARCHAR2(500);
g_mgr_from_clause          VARCHAR2(500);
g_cat_from_clause          VARCHAR2(500);
g_ccc_from_clause          VARCHAR2(500);
g_non_ag_cat_from_clause   VARCHAR2(500);
g_lob_join	           VARCHAR2(200);
g_cat_join	           VARCHAR2(32000);
g_mgr_join	           VARCHAR2(200);
g_ccc_join	           VARCHAR2(500);
g_non_ag_cat_join	   VARCHAR2(32000);
g_lob_viewby_from_clause   VARCHAR2(500);
g_mgr_viewby_from_clause   VARCHAR2(500);
g_cat_viewby_from_clause   VARCHAR2(500);
g_ccc_viewby_from_clause   VARCHAR2(500);
g_viewby_from_clause       VARCHAR2(500);
g_lob_viewby_join	   VARCHAR2(200);
g_cat_viewby_join	   VARCHAR2(200);
g_mgr_viewby_join	   VARCHAR2(200);
g_ccc_viewby_join	   VARCHAR2(500);
g_viewby_join              VARCHAR2(500);
g_lob_viewby_value         VARCHAR2(30);
g_cat_viewby_value         VARCHAR2(30);
g_ccc_viewby_value         VARCHAR2(30);
g_mgr_viewby_value         VARCHAR2(30);
g_viewby_value             VARCHAR2(200);
g_lob_viewby_id	           VARCHAR2(30);
g_cat_viewby_id            VARCHAR2(30);
g_mgr_viewby_id            VARCHAR2(30);
g_ccc_viewby_id	           VARCHAR2(30);
g_viewby_id	           VARCHAR2(30);
g_parent_fin_id            NUMBER;
g_fin_type	           VARCHAR2(200);
g_month_id	           VARCHAR2(100);
g_page_period_type         VARCHAR2(100);
g_cy_period_end	           DATE;
g_ent_pyr_start	           DATE;
g_ent_pyr_end	           DATE;
g_ent_cyr_start	           DATE;
g_ent_cyr_end	           DATE;
g_total_hc                 NUMBER;
g_py_sday                  DATE;
g_five_yr_back             DATE;
g_begin_date               DATE;
g_rpt_begin_date           DATE;
g_rev_msg		   VARCHAR2(240);
g_exp_msg		   VARCHAR2(240);
g_cog_msg		   VARCHAR2(240);
g_dir_msg		   VARCHAR2(240);
g_prod_id		   NUMBER;
g_cat_join2		   VARCHAR2(32000);
g_lob_is_top_node          VARCHAR2(1);
g_cc_owner                 NUMBER;
g_ccc_mgr_join             VARCHAR2(200);
g_ppy_sday                 DATE;
g_new_date		   DATE;
g_new_date2		   DATE;
g_detail_start		   DATE;
g_detail_end		   DATE;
g_top_spend_start	   DATE;
g_top_spend_end		   DATE;
g_exp_asof_date            DATE;
g_exp_begin_date           DATE;
g_exp_start                DATE;
g_mgr_is_leaf		   VARCHAR2(1);
g_lob_is_leaf		   VARCHAR2(1);
g_fincat_is_leaf	   VARCHAR2(1);
g_sd_lyr		   DATE;
  --added for bug fix 5002238
  --by vkazhipu
  --changing l_id and l_dim_flag to bind variables
g_l_id			   NUMBER;
g_dim_flag		   VARCHAR2(1);
g_bitmask		   NUMBER;
--added for bug fix 4969910
--added by hpoddar
--changing l_start,l_end,l_slice_type_flag,l_prev_mgr_id and l_emp_id to bind variables

g_start_id		   NUMBER;
g_end_id		   NUMBER;
g_slice_type_flag	   VARCHAR2(1);
g_prev_mgr_id		   NUMBER;
g_emp_id		   NUMBER;

--added for bug fix 5002564
--added by hpoddar
-- g_curr_start_id and g_curr_end_id store the month-id of the start date and end date of the period chosen
-- g_curr%day_id are used to store day-ids for start date and end date of current and prior periods

g_curr_start_period_id     NUMBER;
g_curr_end_period_id	   NUMBER;
g_curr_start_day_id        NUMBER;
g_curr_end_day_id	   NUMBER;
g_prior_start_day_id       NUMBER;
g_prior_end_day_id	   NUMBER;


--   This package will provide central utilities for all GL DBI PMV content

PROCEDURE reset_globals;

PROCEDURE get_viewby_sql;

PROCEDURE get_non_ag_cat_pmv_sql;

PROCEDURE get_lob_pmv_sql;

PROCEDURE get_ccc_pmv_sql;

PROCEDURE get_cat_pmv_sql;

PROCEDURE get_parameters (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL);

PROCEDURE Bind_Variable (p_sqlstmt IN Varchar2,
                         p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_sql_output OUT NOCOPY Varchar2,
                         p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_bitmasks;
PROCEDURE get_mgr_pmv_sql;
PROCEDURE get_supervisor (l_mgr_mgr_id OUT NOCOPY NUMBER);

PROCEDURE get_lob;

FUNCTION ccc_within_mgr_lob( g_ccc_id IN NUMBER,
                             g_lob_id IN VARCHAR2,
                             g_mgr_id IN NUMBER) return varchar2;

PROCEDURE get_fin_item ( l_fin_id IN NUMBER,
                         l_p_fin_id OUT NOCOPY NUMBER);

FUNCTION get_first_string(l_id IN VARCHAR2) return VARCHAR2;

END fii_gl_util_pkg;


 

/
