--------------------------------------------------------
--  DDL for Package POA_DBI_SUTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_SUTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbisutils.pls 120.7 2006/04/18 02:02:26 sdiwakar noship $ */
 OPER_UNIT_BMAP             CONSTANT INTEGER := 1;
 REASON_BMAP                CONSTANT INTEGER := 2;
 REC_ORG_BMAP               CONSTANT INTEGER := 4;
 BUYER_BMAP                 CONSTANT INTEGER := 8;
 CLERK_BMAP                 CONSTANT INTEGER := 8;
 COMMODITY_BMAP		    CONSTANT INTEGER := 16;
 CATEGORY_BMAP              CONSTANT INTEGER := 32;
 SUPPLIER_BMAP              CONSTANT INTEGER := 64;
 SUPPLIER_SITE_BMAP         CONSTANT INTEGER := 128;
 ITEM_BMAP                  CONSTANT INTEGER := 256;
 DOCTYPE_BMAP               CONSTANT INTEGER := 512;
 REQUESTER_BMAP		    CONSTANT INTEGER := 1024;
 COMPANY_BMAP		    CONSTANT INTEGER := 2048;
 COSTCTR_BMAP		    CONSTANT INTEGER := 4096;
 g_as_of_date                        date;
 g_previous_asof_date                date;
 g_page_period_type                  varchar2(100);

TYPE poa_dbi_mv_bmap_rec is RECORD(mv_name         VARCHAR2(32),
                                   mv_bmap         NUMBER);

TYPE poa_dbi_mv_bmap_tbl is TABLE of poa_dbi_mv_bmap_rec;

TYPE POA_DBI_AGG_LEVEL_REC is RECORD (
                                       agg_level NUMBER,
                                       agg_bmap NUMBER
                                       );
TYPE POA_DBI_AGG_LEVEL_TBL is TABLE OF POA_DBI_AGG_LEVEL_REC;
TYPE poa_dbi_filter_tbl is TABLE of VARCHAR2(100);
TYPE POA_DBI_SHOW_PARAM_REC IS RECORD (SHOW_FLAG VARCHAR2(1));
TYPE POA_DBI_SHOW_PARAM_TBL IS TABLE of POA_DBI_SHOW_PARAM_REC;

FUNCTION get_filter_where(p_cols in  POA_DBI_FILTER_TBL) return VARCHAR2;


PROCEDURE process_parameters(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_view_by out NOCOPY VARCHAR2,
			       p_view_by_col_name out NOCOPY VARCHAR2,
			       p_view_by_value out NOCOPY VARCHAR2,
                               p_comparison_type out NOCOPY VARCHAR2,
                               p_xtd out NOCOPY VARCHAR2,
                               p_as_of_date out NOCOPY DATE,
                               p_prev_as_of_date out NOCOPY DATE,
                               p_cur_suffix out NOCOPY VARCHAR2,
                               p_nested_pattern out NOCOPY NUMBER,
			       p_where_clause out NOCOPY VARCHAR2,
			       p_mv out NOCOPY VARCHAR2,
			       p_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl,
			       p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
			       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
			       p_trend IN VARCHAR2,
			       p_func_area IN VaRCHAR2,
			       p_version IN VARCHAR2,
			       p_role IN VARCHAR2,
			       p_mv_set IN VARCHAR2);

PROCEDURE drill_process_parameters(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                             p_cur_suffix out NOCOPY VARCHAR2,
                             p_where_clause out NOCOPY VARCHAR2,
                             p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
                             p_func_area IN VaRCHAR2,
                             p_version IN VARCHAR2,
                             p_role IN VARCHAR2,
                             p_mv_set IN VARCHAR2);

PROCEDURE bind_reqfact_date(
  p_custom_output IN OUT NOCOPY bis_query_attributes_tbl);

PROCEDURE init_dim_map(p_dim_map out NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map,
			p_func_area IN VARCHAR2,
			p_version IN VARCHAR2,
			p_role IN VARCHAR2,
			p_mv_set IN VARCHAR2);


FUNCTION get_mv(p_dim_bmap IN NUMBER,
		p_func_area in VARCHAR2,
		p_version in VARCHAR2,
		p_mv_set IN VARCHAR2) return VARCHAR2;

FUNCTION get_col_name(dim_name VARCHAR2, p_func_area in VARCHAR2, p_version in VARCHAR2, p_mv_set in VARCHAR2) return VARCHAR2;

FUNCTION get_security_where_clauses(p_dim_map poa_dbi_util_pkg.poa_dbi_dim_map,
	p_func_area in VARCHAR2,
	p_version in VARCHAR2,
	p_role in VARCHAR2,
	p_trend in VARCHAR2 := 'N') return VARCHAR2;

FUNCTION get_in_security_where_clauses(p_dim_map poa_dbi_util_pkg.poa_dbi_dim_map,
        p_context_code in VARCHAR2,
	p_func_area in VARCHAR2,
	p_version in VARCHAR2,
	p_role in VARCHAR2,
	p_trend in VARCHAR2 := 'N') return VARCHAR2;

PROCEDURE get_join_info(p_view_by IN varchar2,
		p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map,
		x_join_tbl OUT NOCOPY poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
		p_func_area IN varchar2,
		p_version IN varchar2);

PROCEDURE populate_in_join_tbl(p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
        p_param in BIS_PMV_PAGE_PARAMETER_TBL,
        p_dim_map in POA_DBI_UTIL_PKG.POA_DBI_DIM_MAP,
        p_context_code in VARCHAR2,
        p_version in VARCHAR2,
        p_mv_set in varchar2,
        p_where_clause in out nocopy varchar2);

FUNCTION get_table(dim_name VARCHAR2, p_func_area in VARCHAR2, p_version in VARCHAR2)
	return VARCHAR2;

FUNCTION get_viewby_select_clause(p_viewby IN VARCHAR2, p_func_area IN VARCHAR2,
	p_version IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_fact_hint(p_mv IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE populate_agg_level(
                              p_agg_lvl_tbl OUT NOCOPY 	POA_DBI_AGG_LEVEL_TBL,
                              p_mv_set IN VARCHAR2
                             ) ;

FUNCTION get_agg_level(p_dim_bmap IN NUMBER,
                       p_mv_set IN VARCHAR2) RETURN NUMBER;

FUNCTION get_display_category(p_category_code                IN VARCHAR2,
                              p_selected_commodity      IN VARCHAR2,
                              p_context_code in varchar2,
			      p_restrict_lov in varchar2 := 'Y'
                             ) RETURN VARCHAR2;

procedure get_company_sql (p_viewby in varchar2,
  p_company_id in varchar2,
  p_region_code in varchar2,
  p_company_sql out nocopy varchar2,
  p_agg_flag out nocopy varchar2);

procedure get_cost_ctr_sql (p_viewby in varchar2,
  p_cost_center_id in varchar2,
  p_region_code in varchar2,
  p_cost_ctr_sql out nocopy varchar2,
  p_agg_flag out nocopy varchar2);

FUNCTION get_display_supplier(p_supplier_id IN VARCHAR2,
                              p_context_code IN VARCHAR2
			     ) RETURN VARCHAR2;
FUNCTION get_display_supplier_site(p_supplier_site_id IN VARCHAR2,
                              p_context_code IN VARCHAR2
			     ) RETURN VARCHAR2;
FUNCTION get_display_commodity(p_commodity_id IN VARCHAR2,
                              p_context_code IN VARCHAR2
			     ) RETURN VARCHAR2;
FUNCTION get_display_ou(p_ou_id IN VARCHAR2,
                        p_context_code IN VARCHAR2
		       ) RETURN VARCHAR2;
FUNCTION get_display_com(p_id IN VARCHAR2,
                         p_parent_id IN VARCHAR2,
                         p_selected_company IN VARCHAR2
                        ) RETURN VARCHAR2;
FUNCTION get_display_cc(p_id IN VARCHAR2,
                        p_parent_id IN VARCHAR2,
                        p_selected_cc IN VARCHAR2
                       ) RETURN VARCHAR2;

PROCEDURE hide_parameter(p_param IN BIS_PMV_PAGE_PARAMETER_TBL, hideParameter OUT NOCOPY VARCHAR2);
PROCEDURE hide_parameter2(p_param IN BIS_PMV_PAGE_PARAMETER_TBL, hideParameter OUT NOCOPY VARCHAR2);
PROCEDURE hide_parameter3(p_param IN BIS_PMV_PAGE_PARAMETER_TBL, hideParameter OUT NOCOPY VARCHAR2);
PROCEDURE hide_commodity(p_param IN BIS_PMV_PAGE_PARAMETER_TBL, hideParameter OUT NOCOPY VARCHAR2);

function get_sec_context(p_param in bis_pmv_page_parameter_tbl) return varchar2;
function get_bis_calling_parameter(p_param in bis_pmv_page_parameter_tbl) return varchar2;
function get_supplier_id_ou return varchar2;
function get_supplier_id_sup return varchar2;
procedure get_parameters (p_page_parameter_tbl in bis_pmv_page_parameter_tbl);
function get_pri_label return varchar2;
function get_curr_label return varchar2;
procedure bind_com_cc_values( x_custom_output in out nocopy bis_query_attributes_tbl,
                              p_param in bis_pmv_page_parameter_tbl);
END POA_DBI_SUTIL_PKG;

 

/
