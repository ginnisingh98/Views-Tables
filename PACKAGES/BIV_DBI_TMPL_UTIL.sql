--------------------------------------------------------
--  DDL for Package BIV_DBI_TMPL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_TMPL_UTIL" AUTHID CURRENT_USER as
/* $Header: bivsrvrutls.pls 120.0 2005/05/25 10:58:40 appldev noship $ */

  -- these are the codes for the dimension levels

  g_REQUEST_TYPE      varchar2(50) := 'BIV_REQUEST_TYPE+REQUESTTYPE';
  g_CATEGORY          varchar2(50) := 'ITEM+ENI_ITEM_VBH_CAT';
  g_PRODUCT           varchar2(50) := 'ITEM+ENI_ITEM';
  g_SEVERITY          varchar2(50) := 'SEVERITY+SEVERITY';
  g_STATUS            varchar2(50) := 'STATUS+STATUS';
  g_CHANNEL           varchar2(50) := 'BIV_CHANNEL+CHANNEL';
  g_RESOLUTION        varchar2(50) := 'RESOLUTION+RESOLUTION';
  g_CUSTOMER          varchar2(50) := 'CUSTOMER+PROSPECT';
  g_ASSIGNMENT        varchar2(50) := 'ORGANIZATION+JTF_ORG_SUPPORT_GROUP';
  g_AGING             varchar2(50) := 'BUCKET_AGING+SERVICE_DISTRIBUTION';
  g_BACKLOG_TYPE      varchar2(50) := 'BACKLOG_TYPE+BACKLOG_TYPE';
  g_RES_STATUS        varchar2(50) := 'BIV_RES_STATUS+RES_STATUS';

-- get_period_type function returns the value of the parameter value
-- for period_type as poa_dbi_util_pkg.get_parameter_values
-- does not understand rolling periods yet.
--
-- when poa_dbi_util_pkg.get_parameter_values is updated to handle
-- rolling periods this function will not be needed.
--
function get_period_type
( p_param in bis_pmv_page_parameter_tbl )
return varchar2;

-- this is biv specific and should remain in this package.
procedure process_parameters
( p_param            in bis_pmv_page_parameter_tbl
, p_report_type      in varchar2 -- 'ACTIVITY','CLOSED','BACKLOG','BACKLOG_AGE'
, p_trend            in varchar2
, x_view_by          out nocopy varchar2
, x_view_by_col_name out nocopy varchar2
, x_comparison_type  out nocopy varchar2
, x_xtd              out nocopy varchar2
, x_where_clause     out nocopy varchar2
, x_mv               out nocopy varchar2
, x_join_tbl         out nocopy poa_DBI_UTIL_PKG.poa_dbi_join_tbl
, x_as_of_date       out nocopy date
);

-- this is biv specific and should remain in this package.
function get_view_by_col_name
( p_dim_name in varchar2 )
return varchar2;

-- get_category_drill_down function returns the select statement
-- column needed to perform drill down on product category to either
-- the next level down in the hierarchy or to view by product.
-- if p_view_by is not product category then null is returned.
-- this is biv specific and should remain in this package.
function get_category_drill_down
( p_view_by_name  in varchar2
, p_function_name in varchar2
, p_column_alias  in varchar2 default 'BIV_ATTRIBUTE4' )
return varchar2;

-- get_backlog_type function returns the value of the parameter value
-- for backlog type as poa_dbi_util_pkg.get_parameter_values
-- only returns whether or not it is set and we don't want
-- the join/where logic from biv_dbi_template_pkg.status_sql
-- anyway.
-- this is biv specific and should remain in this package
function get_backlog_type
( p_param in bis_pmv_page_parameter_tbl )
return varchar2;

-- get_bucket_outer_query function returns the columns for the
-- outer select statement for the buckets based on the
-- bucket short name
-- if p_backlog_col is not null then the columns will be
-- returned as % of backlog (distribution)
-- this is biv specific and should remain in this package.
function get_bucket_outer_query
( p_bucket_rec       in bis_bucket_pub.bis_bucket_rec_type
, p_column_name_base in varchar2
, p_alias_base       in varchar2
, p_total_flag       in varchar2 default 'N'
, p_backlog_col      in varchar2 default null
)
return varchar2;

-- add_bucket_inner_query procedure adds the bucket columns to
-- the inner query for the buckets based on the bucket short name.
-- this is biv specific and should remain in this package.
procedure add_bucket_inner_query
( p_short_name   in varchar2
, p_col_tbl      in out nocopy poa_DBI_UTIL_PKG.poa_dbi_col_tbl
, p_col_name     in varchar2
, p_alias_name   in varchar2
, p_grand_total  in varchar2
, p_prior_code   in varchar2
, p_to_date_type in varchar2
, x_bucket_rec   out nocopy bis_bucket_pub.bis_bucket_rec_type
);

-- this is a wrapper to poa_dbi_util_pkg.change_clause.
-- this is biv specific and should remain in this package.
function change_column
( p_current_column  in varchar2
, p_prior_column    in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2;

-- this is a wrapper to poa_dbi_util_pkg.rate_clause.
-- this is biv specific and should remain in this package.
function rate_column
( p_numerator       in varchar2
, p_denominator     in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2;

-- dump_parameters function returns as a comment block the
-- contents of the parameters provided by PMV
-- note: it should only be called in debugging situations.
-- this is biv specific and should remain in this package.
function dump_parameters
( p_param in bis_pmv_page_parameter_tbl )
return varchar2;

-- dump_binds function returns as a comment block the
-- contents of the bind variables provided by PMV and  product team
-- note: it should only be called in debugging situations.
-- this is biv specific and should remain in this package.
function dump_binds
( p_custom_output in bis_query_attributes_tbl)
return varchar2;

-- override_order_by procedure replaces the default order by
-- clause with one based on importance level when view by
-- severity and order by severity or when bucket id when view by
-- aging and order by aging.
-- this is biv specific and should remain in this package.
procedure override_order_by
( p_view_by in varchar2
, p_param   in bis_pmv_page_parameter_tbl
, p_stmt    in out nocopy varchar2
);

-- get_balance_fact function returns the MV name to check the
-- last refresh details for based on the text of the mv used by
-- the backlog query
function get_balance_fact
( p_mv              in varchar2
)
return varchar2;

-- get_trace_file_name function returns as a comment the trace
-- file name that will contain the report query.
-- this is biv specific and should remain in this package.
function get_trace_file_name
return varchar2;

-- drill_detail function returns the drill to detail url for
-- either a backlog or closed column.
function drill_detail
( p_function_name in varchar2
, p_bucket_number in number
, p_bucket_name   in varchar2
, p_base_alias    in varchar2
) return varchar2;


-- bucket_detail_drill function returns the drill to detail urls for
-- either a backlog or closed distribution columns using drill_detail.
function bucket_detail_drill
( p_function_name in varchar2
, p_bucket_rec    in bis_bucket_pub.bis_bucket_rec_type
, p_base_alias    in varchar2
) return varchar2;

-- get_detail_page_function procedure returns the name of function
-- to display the details and the name of the parameter for the SR ID.
procedure get_detail_page_function
( x_function_name   out nocopy varchar2
, x_sr_id_parameter out nocopy varchar2
);

-- bind_yes_no procedure returns the translated values for Y and N
-- as bind variable values
procedure bind_yes_no
( p_yes           in varchar2
, p_no            in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
);

-- bind_low_high procedure returns the low and high values for bucket
-- as bind variable values
procedure bind_low_high
( p_param         in bis_pmv_page_parameter_tbl
, p_short_name    in varchar2
, p_low           in varchar2
, p_high          in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
);

-- process_parameters procedure is a wrapper to the other
-- process_parameters specifically for detail report queries
procedure process_parameters
( p_param            in bis_pmv_page_parameter_tbl
, p_report_type      in varchar2 -- 'BACKLOG_DETAIL', 'CLOSED_DETAIL'
, x_where_clause     out nocopy varchar2
, x_xtd              out nocopy varchar2
, x_mv               out nocopy varchar2
, x_join_from        out nocopy varchar2
, x_join_where       out nocopy varchar2
, x_join_tbl         out nocopy poa_DBI_UTIL_PKG.poa_dbi_join_tbl
, x_as_of_date       out nocopy date
);

-- get_order_by function returns the order by parameter
function get_order_by
( p_param in bis_pmv_page_parameter_tbl )
return varchar2;

-- bind_age_dates procedure returns the current and prior date
-- values as bind variables for backlog aging
procedure bind_age_dates
( p_param            in bis_pmv_page_parameter_tbl
, p_current_name     in varchar2
, p_prior_name       in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
);

-- get_grp_id function returns the decoded grouping set grp_id
-- to be used.  assumes:
-- 6 = Resolution, 5 = Channel, 4 = Status, 3 = Assignment Grp,
-- 2 = Customer, 1 = Product, any combination = 0
function get_grp_id
( p_bmap in number )
return number;


end biv_dbi_tmpl_util;

 

/
