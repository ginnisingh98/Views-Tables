--------------------------------------------------------
--  DDL for Package POA_DBI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: poadbiutils.pls 120.2 2005/09/08 15:39:29 nnewadka noship $ */

NO_PRIORS             CONSTANT INTEGER := 1;
COL_PRIOR_ONLY        CONSTANT INTEGER := 2;
BOTH_PRIORS           CONSTANT INTEGER := 3;
PREV_PREV             CONSTANT INTEGER := 4;
OPENING_PRIOR_CURR    CONSTANT INTEGER := 5;

---Begin MOAC changes
g_org_id              NUMBER ;
g_sec_profile_id      NUMBER ;
---End MOAC changes

TYPE poa_dbi_join_rec is RECORD(column_name         VARCHAR2(200),
                                    /* column to join, e.g. id */
                                table_name          VARCHAR2(500),
                                    /* table to join e.g. poa_items_v */
                                table_alias         VARCHAR(200),
                                    /* alias of table, i.e. v */
                                fact_column         VARCHAR2(200),
                                    /* column selected from fact, e.g. item_id */
				fact_column2 	   VARCHAR2(200),
				  /* column selected from fact in second part of				    union all queries. If not populated,
				    then fact_column is used for both parts of
				    the union.  Not used in non-union
				    queries. */
				inner_alias 	   VARCHAR(200),
				    /* alias of table to select column
				    from in innermost select
				    (if left empty, the inner_alias
				    will be 'fact') */
                                dim_outer_join      VARCHAR2(2),
                                    /* whether it is an outer join or not */
                                additional_where_clause varchar2(1000));
                                    /* any additional conditions on the join (such as a tl condition) */

TYPE poa_dbi_join_tbl is TABLE of poa_dbi_join_rec;

TYPE poa_dbi_col_list is TABLE OF VARCHAR2(200);

TYPE poa_dbi_union_query_rec is RECORD(in_union_sel VARCHAR2(5000),
					template_sql  VARCHAR2(20000));

TYPE poa_dbi_union_query_tbl is TABLE OF poa_dbi_union_query_rec;


TYPE poa_dbi_col_calc_rec is RECORD(column_name VARCHAR2(300),
				alias_begin VARCHAR2(200),
				alias_end VARCHAR2(20),
				calc_begin VARCHAR2(50),
				calc_end  VARCHAR2(50),
				date_decode_begin VARCHAR2(200),
				date_decode_end	VARCHAR2(50));

TYPE poa_dbi_col_calc_tbl is TABLE of poa_dbi_col_calc_rec;

TYPE poa_dbi_in_join_rec is RECORD(table_name        VARCHAR2(400),
                                        /* table to join e.g. per_organization_list*/
                                   table_alias  VARCHAR(200),
                                   aggregated_flag varchar2(1));
                                   /* added specifically for company, cost_center and user defined dimensions*/

TYPE poa_dbi_in_join_tbl is TABLE of poa_dbi_in_join_rec;

TYPE poa_dbi_dim_rec IS RECORD(value          VARCHAR2(3) := 'All',
                               col_name       VARCHAR2(64),
                               bmap           NUMBER,
                               view_by_table  VARCHAR2(500),
                               generate_where_clause VARCHAR2(1) := 'Y');
                                   /* if generate_where_clause = 'Y' then the
                                      function get_where_clauses will add in a where clause
                                      for that dimension.  Set generate_where_clause to 'N'
                                      if you need to create a more complicate where for a
                                      dimension, or if you do not want a where at all. */

/* possible values for to_date_type:
XTD = period to date
XED = period to end of period (i.e. entire period)
YTD = year to date
ITD = inception to date
RLX = Rolling period
BAL = Balance
NA = for reports with no as-of date or period type.
*/
TYPE poa_dbi_col_rec is RECORD(column_name         VARCHAR2(100),
                               column_alias        VARCHAR2(64),
                               to_date_type        varchar2(3),
                               grand_total         VARCHAR2(1),
                               prior_code          VARCHAR2(2));

TYPE poa_dbi_col_tbl is TABLE of poa_dbi_col_rec;

TYPE poa_dbi_dim_tbl is TABLE of varchar2(100);

TYPE poa_dbi_dim_map IS TABLE OF poa_dbi_dim_rec
      INDEX BY VARCHAR2(75);
TYPE poa_dbi_filter_tbl is TABLE of VARCHAR2(100);

TYPE poa_dbi_flex_filter_rec IS RECORD (measure_name    VARCHAR2(100),
                                        modifier        VARCHAR2(100));
TYPE poa_dbi_flex_filter_tbl IS TABLE OF poa_dbi_flex_filter_rec;

TYPE poa_dbi_mv_bmap_rec is RECORD(mv_name         VARCHAR2(32),
                                   mv_bmap         NUMBER);

TYPE poa_dbi_mv_bmap_tbl is TABLE of poa_dbi_mv_bmap_rec;

TYPE poa_dbi_mv_rec is RECORD(	mv_name		VARCHAR2(300),
				mv_col		poa_dbi_util_pkg.poa_dbi_col_tbl ,
				mv_where	VARCHAR2(4000),
				in_join_tbls	poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL,
				mv_hint		VARCHAR2(1000) /* used only by union all trend sql*/,
				use_grp_id	VARCHAR2(10),
				mv_xtd		VARCHAR2(50) /* used only by union all trend sql */);
TYPE poa_dbi_mv_tbl is TABLE of poa_dbi_mv_rec;


FUNCTION get_calendar_table
( period_type        in varchar2
, p_include_prior    in varchar2 := 'Y'
, p_include_opening  in varchar2 := 'N'
, p_called_by_union  in varchar2 := 'N'
)
return varchar2;

FUNCTION get_nested_pattern(period_type IN varchar2) return number;

FUNCTION get_nested_period_type_id(period_type IN varchar2) return number;

FUNCTION get_sec_profile return number;

FUNCTION get_fnd_user_profile RETURN NUMBER;

FUNCTION get_fnd_employee_profile RETURN NUMBER;

FUNCTION bitor(x in number,y in number) return number;

PROCEDURE refresh (p_mv_name  IN  VARCHAR2);

FUNCTION get_filter_where(p_cols in  POA_DBI_FILTER_TBL)
	return VARCHAR2;

FUNCTION get_filter_where(p_cols in  POA_DBI_FLEX_FILTER_TBL)
    return VARCHAR2;

PROCEDURE get_parameter_values(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_dim_map in out NOCOPY poa_dbi_dim_map,
                               p_view_by out NOCOPY VARCHAR2,
                               p_comparison_type out NOCOPY VARCHAR2,
                               p_xtd out NOCOPY VARCHAR2,
                               p_as_of_date out NOCOPY DATE,
                               p_prev_as_of_date out NOCOPY DATE,
                               p_cur_suffix out NOCOPY VARCHAR2,
                               p_nested_pattern out NOCOPY NUMBER,
                               p_dim_bmap in out NOCOPY NUMBER);

PROCEDURE get_drill_param_values(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                                 p_dim_map in out nocopy poa_dbi_dim_map,
                                 p_cur_suffix out NOCOPY VARCHAR2);

FUNCTION get_where_clauses(p_dim_map poa_dbi_dim_map, p_trend in VARCHAR2) RETURN VARCHAR2;

PROCEDURE add_column(p_col_tbl      IN OUT NOCOPY poa_dbi_col_tbl,
                     p_col_name     IN VARCHAR2,
                     p_alias_name   IN VARCHAR2,
                     p_grand_total  IN VARCHAR2 := 'Y',
                     p_prior_code   IN NUMBER := BOTH_PRIORS,
                     p_to_date_type IN VARCHAR2 := 'XTD');

PROCEDURE add_bucket_columns(p_short_name   in varchar2
, p_col_tbl      in out nocopy poa_dbi_util_pkg.poa_dbi_col_tbl
, p_col_name     in varchar2
, p_alias_name   in varchar2
, x_bucket_rec   out nocopy bis_bucket_pub.bis_bucket_rec_type
, p_grand_total  in varchar2 := 'Y'
, p_prior_code   in varchar2 := BOTH_PRIORS
, p_to_date_type in varchar2 := 'XTD'
);

function get_bucket_outer_query
( p_bucket_rec       in bis_bucket_pub.bis_bucket_rec_type
, p_col_name	     in varchar2
, p_alias_name       in varchar2
, p_prefix	     in varchar2
, p_suffix	     in varchar2
, p_total_flag       in varchar2 default 'N'
)return varchar2;

function get_bucket_drill_url
( p_bucket_rec       in bis_bucket_pub.bis_bucket_rec_type
, p_alias_name       in varchar2
, p_prefix	     in varchar2
, p_suffix	     in varchar2
, p_add_bucket_num   in varchar2
)
return varchar2;


/* NP  -> non-percentage.  otherwise returns percent change formula */
FUNCTION change_clause(cur_col IN VARCHAR2, prior_col IN VARCHAR2, change_type IN VARCHAR2 := 'NP')
RETURN VARCHAR2;

FUNCTION rate_clause(numerator IN VARCHAR2, denominator IN VARCHAR2, rate_type IN VARCHAR2 := 'P') RETURN VARCHAR2;

FUNCTION get_commodity_sec_where(p_commodity_value VARCHAR2, p_trend IN VARCHAR2 :='N') return VARCHAR2;

FUNCTION get_in_commodity_sec_where(p_commodity_value VARCHAR2, p_trend IN VARCHAR2 :='N') return VARCHAR2;

FUNCTION get_ou_sec_where(p_ou_value VARCHAR2, p_ou_fact_col VARCHAR2, p_trend IN VARCHAR2 :='N') return VARCHAR2;

FUNCTION get_in_ou_sec_where(p_ou_value VARCHAR2, p_ou_fact_col VARCHAR2, p_use_bind IN VARCHAR2 :='Y') return VARCHAR2;

PROCEDURE get_custom_trend_binds
( p_xtd             in varchar2
, p_comparison_type in varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_opening_balance in varchar2 := 'N'
);

PROCEDURE get_custom_status_binds(x_custom_output IN OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

FUNCTION get_trend_lag(p_xtd IN varchar2,  p_comparison_type IN varchar2) return number;

-- get_report_start_date function returns the BIS bind variable
-- substituton text for use by status_sql and trend_sql for rolling periods
FUNCTION get_report_start_date
( p_period_type      varchar2
, p_prior            varchar2 := 'N'
)
return varchar2;

-- get_custom_balance_binds procedure updates the bis_query_attributes_tbl
-- with the bind variables/values needed for balance reports
PROCEDURE get_custom_balance_binds
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_balance_fact  in varchar2
, p_xtd           in varchar2 := null
);

-- get_custom_rolling_binds procedure updates the bis_query_attributes_tbl
-- with the bind variables/values needed for rolling period reports
-- will be unnecessary when fii/bis provide this functionality.
PROCEDURE get_custom_rolling_binds
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_xtd           in varchar2
);

procedure bind_low_high
( p_param         in bis_pmv_page_parameter_tbl
, p_short_name    in varchar2
, p_dim_level	  in varchar2
, p_low           in varchar2
, p_high          in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
);

-- Procedure to seed Bind variables for day level reporting
PROCEDURE get_custom_day_binds(p_custom_output IN OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
                               p_as_of_date    IN DATE,
                               p_comparison_type IN VARCHAR2);

FUNCTION get_in_supplier_sec_where(p_supplier_value IN VARCHAR2) RETURN VARCHAR2;
---Begin MOAC changes
 FUNCTION get_ou_org_id RETURN NUMBER;
---End  MOAC changes

--Begin changes for spend trend graph
 FUNCTION get_rolling_inline_view
 RETURN VARCHAR2 ;
--End changes for spend trend graph
END poa_dbi_util_pkg;

 

/
