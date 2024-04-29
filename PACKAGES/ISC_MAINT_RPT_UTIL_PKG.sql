--------------------------------------------------------
--  DDL for Package ISC_MAINT_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_RPT_UTIL_PKG" 
/* $Header: iscmaintrptutils.pls 120.1 2005/09/13 05:37:43 nbhamidi noship $ */
AUTHID CURRENT_USER as

-- the following are constants that define the actual (or pseudo)
-- dimension levels used in reports.
-- these constants are used internally and should be use externally
-- rather than making direct reference to the dimension+dimension_level
G_ORGANIZATION      constant varchar2(50) := 'ORGANIZATION+ORGANIZATION';
G_CURRENCY          constant varchar2(50) := 'CURRENCY+FII_CURRENCIES';
G_DEPARTMENT        constant varchar2(50) := 'RESOURCE+ENI_RESOURCE_DEPARTMENT';
G_ASSET_GROUP       constant varchar2(50) := 'BIV_MAINT_ASSET+BIV_MAINT_ASSET_GROUP_LVL';
G_ASSET_NUMBER      constant varchar2(50) := 'BIV_MAINT_ASSET+BIV_MAINT_ASSET_NUMBER_LVL';
G_ACTIVITY          constant varchar2(50) := 'BIV_MAINT_ACTIVITY+BIV_MAINT_ACTIVITY_LVL';
G_COST_CATEGORY     constant varchar2(50) := 'BIV_MAINT_CST_CATEGORY+BIV_MAINT_CST_CATEGORY_LVL';
G_COST_ELEMENT      constant varchar2(50) := 'BIV_MAINT_CST_ELEMENT+BIV_MAINT_CST_ELEMENT_LVL';
G_WORK_ORDER_TYPE   constant varchar2(55) := 'BIV_MAINT_WK_ORDER_TYPE+BIV_MAINT_WK_ORDER_TYPE_LVL';
G_LATE_CMPL_AGING   constant varchar2(50) := 'BIV_MAINT_AGING+BIV_MAINT_LATE_COMP_AGING';
G_PAST_DUE_AGING    constant varchar2(50) := 'BIV_MAINT_AGING+BIV_MAINT_PAST_DUE_AGING';
G_ASSET_CATEGORY    constant varchar2(50) := 'BIV_MAINT_ASSET+BIV_MAINT_ASSET_CATEGORY_LVL';
G_ASSET_CRITICALITY constant varchar2(60) := 'BIV_MAINT_ASSET_CRITICALITY+BIV_MAINT_ASSET_CRITICAL_LVL';
G_REQUEST_TYPE      constant varchar2(50) := 'BIV_MAINT_REQUEST_TYPE+BIV_MAINT_REQUEST_TYPE_LVL';
G_REQ_CMPL_AGING    constant varchar2(50) := 'BIV_MAINT_AGING+BIV_MAINT_REQ_COMP_AGING';
G_WORK_ORDER_STATUS constant varchar2(60) := 'BIV_MAINT_WK_ORDER_STATUS+BIV_MAINT_WK_ORDER_STATUS_LVL';
G_RESOURCE          constant varchar2(50) := 'RESOURCE+ENI_RESOURCE';


-- these is not a real dimension level but exist for joins in detail reports
G_WIP_ENTITIES      constant varchar2(50) := 'ISC_MAINT_WIP_ENTITIES';
G_ESTIMATED         constant varchar2(50) := 'ISC_MAINT_ESTIMATED_COST_VALUE+LOOKUP';
G_REQUESTS          constant varchar2(50) := 'ISC_MAINT_REQUESTS';
G_REQUEST_SEVERITIES constant varchar2(50) := 'ISC_MAINT_REQUEST_SEVERITIES';

-- this record type is used to store all of the details for using a
-- dimension level, it contains the join to table, join conditions
-- for both dimension table and fact table as well as the columns
-- to be displayed in a viewby, including ID and also the fact
-- column to be used to filter for this dimension.
type t_dimension_rec is record
     ( dim_bmap number -- this is used to determine parameters/view by entered
     , dim_table_name varchar2(500) -- this is the dimension table to join to
     , dim_table_alias varchar2(200) -- this is the alias that this table will use
     , dim_outer_join varchar2(2) -- indicates if join is outer join
     , dim_col_name1 varchar2(200) -- this is the first join column in dim table
     , oset_col_name1 varchar2(200) -- this is the first join table in the "oset"
     , dim_col_name2 varchar2(200) -- this is the second join column in dim table
     , oset_col_name2 varchar2(200) -- this is the second join table in the "oset"
     , dim_col_name3 varchar2(200) -- this is the third join column in dim table
     , oset_col_name3 varchar2(200) -- this is the third join table in the "oset"
     , additional_where_clause varchar2(1000) -- any additional where clause needed
     , viewby_col_name varchar2(200) -- this is the dimension table column to be displayed
     , viewby_id_col_name varchar2(200) -- this is the dimension table ID column
     , viewby_id_unassigned varchar2(30) -- this is the default value for ID when outer joined
     , fact_filter_col_name varchar2(200) -- this is fact column to be used in where clause
     );

type t_dimension_tbl is table of t_dimension_rec index by varchar2(200);

-- this record type is used to store the column defintions requiried for
-- producing detail reports.  it is populated by "add_detail_column".
type t_detail_column_rec is record
     ( dimension_level    varchar2(200)
     , dim_level_col_name varchar2(200)
     , fact_col_name      varchar2(200)
     , fact_col_total     varchar2(200)
     , column_key         varchar2(200)
     );

type t_detail_column_tbl is table of t_detail_column_rec index by varchar2(200);

-- this procedure allows the report to register the
-- dimension level parameters that it is interested in
-- the parameters G_ORGANIZATION and G_DEPARTMENT will automatically
-- be registers for all reports via process parameters, here you
-- specify report specific parameters.  Up to 10 parameters
-- can be registered at a time, this procedure can be called
-- as many times as needed, however once should be enough for
-- most reports.
-- p_dimensionN: the dimension level using it's logical name
-- p_filter_flagN: "Y" indicate if the dimension level is a
-- filtering parameter or "N" to indicate it is view by/detail only.
procedure register_dimension_levels
( x_dimension_tbl  in out nocopy t_dimension_tbl
, x_dim_filter_map in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
, p_dimension1     in varchar2
, p_filter_flag1   in varchar2
, p_dimension2     in varchar2 default null
, p_filter_flag2   in varchar2 default null
, p_dimension3     in varchar2 default null
, p_filter_flag3   in varchar2 default null
, p_dimension4     in varchar2 default null
, p_filter_flag4   in varchar2 default null
, p_dimension5     in varchar2 default null
, p_filter_flag5   in varchar2 default null
, p_dimension6     in varchar2 default null
, p_filter_flag6   in varchar2 default null
, p_dimension7     in varchar2 default null
, p_filter_flag7   in varchar2 default null
, p_dimension8     in varchar2 default null
, p_filter_flag8   in varchar2 default null
, p_dimension9     in varchar2 default null
, p_filter_flag9   in varchar2 default null
, p_dimension10    in varchar2 default null
, p_filter_flag10  in varchar2 default null
);

-- this procedure is a wrapper to poa_dbi_util_pkg.get_parameter_values
-- which processes the parameters. it also provides out variables
-- that can be used directly by your report or are needed to be
-- passed in to subsequent procedures/functions.
--
-- p_param: the parameter table passed into your report from PMV.
-- p_dimension_tbl: this is x_dimension_tbl returned from
--                  register_dimension_levels
-- p_dim_filter_map: this is x_dim_filter_map returned from
--                   register_dimension_levels
-- p_trend: "Y" for a trend report, "N" for a non-trend report and "D" for
--          detail report.  "K" for current only non-trend reports.
-- p_custom_output: this returns custom bind values that your report will
--                  need such as the &ISC_UNASSIGNED.
-- x_cur_suffix: returns "b", "g" or "sg" based on the currency parameter,
--               needed for curreny reports to determine base or global
--               currency column to use.
-- x_where_clause: returns the where clause to be passed into
--                 poa_dbi_template_pkg.status_sql,
--                 poa_dbi_template_pkg.trend_sql or detail_sql.
-- x_viewby_select: returns the select statement columns for a view by
--                  report, included the fully qualified VIEWBY and
--                  VIEWBY_ID columns.
-- x_join_tbl: returns the dimension join table to be passed into
--             poa_dbi_template_pkg.status_sql,
--             poa_dbi_template_pkg.trend_sql or detail_sql.
-- x_dim_bmap: returns a bitmap number of parameters entered and
--             view by selected, used for call to bind_group_id
-- x_comparison_type: returns the comparison type parameter value,
--                    needed so can be passed into
--                    poa_dbi_template_pkg.trend_sql
-- x_xtd: returns a short coded representation of the selected
--        period type, needed so can be passed into
--        poa_dbi_template_pkg.trend_sql
procedure process_parameters
( p_param            in bis_pmv_page_parameter_tbl
, p_dimension_tbl    in out nocopy t_dimension_tbl
, p_dim_filter_map   in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
, p_trend            in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
, x_cur_suffix       out nocopy varchar2
, x_where_clause     out nocopy varchar2
, x_viewby_select    out nocopy varchar2
, x_join_tbl         out nocopy poa_dbi_util_pkg.poa_dbi_join_tbl
, x_dim_bmap         out nocopy number
, x_comparison_type  out nocopy varchar2
, x_xtd              out nocopy varchar2
);

-- this is a utility function that returns the value for the first
-- occurance of a named parameter.
-- this is used internally and may also be used externally for
-- returning the value of any named parameter (e.g. 'ORDERBY')
function get_parameter_value
( p_param            in bis_pmv_page_parameter_tbl
, p_parameter_name   in varchar2
)
return varchar2;

-- this is a utility function that returns the ID for the first
-- occurance of a named parameter.
-- this is used internally and may also be used externally for
-- returning the value of any named parameter (e.g. G_COST_ELEMENT)
-- by default "All" will be replaced with null unless
-- p_no_replace_all = Y
function get_parameter_id
( p_param            in bis_pmv_page_parameter_tbl
, p_parameter_name   in varchar2
, p_no_replace_all   in varchar2 default null
)
return varchar2;

-- this procedure is used by detail reports to define a column that
-- they want to be displayed.  it is similar in concept to
-- poa_dbi_util_pkg.add_column which is used for adding measure columns
-- to a summary report.
-- this procedure can add both attribute (text) columns from a table
-- to be joined to, or an attribute (text) or measure column
-- from the fact table.
-- this procedure can be called for each item to be included in the
-- select list of the detail report (excludes say URLs)
--
-- to select a column from a dimension, provide a value for p_dimension_level
-- and optionally provide a value for p_dim_level_col_name (if not
-- provided, then the "viewby_col_name" from the dimension level will
-- be used).  by defining the dimension level here, all of the
-- necessary "from" and "where" clauses will be built by detail_sql.
--
-- to select a column from the fact, provide a value for p_fact_col_name
-- and optionally "Y" for p_fact_col_total.
--
-- for both dimension and fact columns you need to provide a value for
-- p_fact_col_total, this is the key that you will use to extract the
-- column in your select statement using get_detail_column.
-- note: if you set p_fact_col_total = "Y" their will automatically
-- be a key of p_column_key || '_total' also created for you.
procedure add_detail_column
( p_detail_col_tbl     in out nocopy t_detail_column_tbl
, p_dimension_tbl      in t_dimension_tbl
, p_dimension_level    in varchar2 default null
, p_dim_level_col_name in varchar2 default null
, p_fact_col_name      in varchar2 default null
, p_fact_col_total     in varchar2 default null
, p_column_key         in varchar2
);

-- this function is used by detail reports to return the fully
-- build column, including table alias and nvl() as necessary,
-- for you to use in your select statement.
-- the column is extracted based on the key value p_column_key
-- (or p_column_key || '_total') that you defined with add_detail_column.
-- you can optionally provide a value for p_alias and this will be
-- appended.
function get_detail_column
( p_detail_col_tbl in t_detail_column_tbl
, p_column_key     in varchar2
, p_alias          in varchar2 default null
)
return varchar2;

-- this function is used to build the "from" and "where" clauses
-- of a detail report that does require any aggregation.  for
-- aggregated detail reports you should be using poa_dbi_template_pkg
-- procedures.  it also includes the order by and optionally the
-- ranking logic for "window" reports.
--
-- p_detail_col_tbl: this is the detail column table that you
-- populated with calls to add_detail_column.
-- p_dimension_tbl: this is the dimension table that you populated
-- with get_dimension_tbl and used in add_detail_column.
-- p_mv_name: this is the MV name returned from process_parameters.
-- p_where_clause: this is the where clause returned from process_parameters.
-- p_rank_order: this is the ordering clause for the rank function,
-- only provide this parameter if you are using a "window" report.
-- p_filter_where: optionally add any restrictions to the inner most
-- where clause.
function detail_sql
( p_detail_col_tbl     in t_detail_column_tbl
, p_dimension_tbl      in t_dimension_tbl
, p_mv_name            in varchar2
, p_where_clause       in varchar2
, p_rank_order         in varchar2 default null
, p_filter_where       in varchar2 default null
, p_override_date_clause in varchar2 default null
)
return varchar2;

-- this function is a wrapper to poa_dbi_util_pkg.change_clause
-- p_current_column: the current measure column
-- p_prior_column: the prior period measure column
-- p_column_alias: optional provide the alias that you
-- want to have appended.
-- p_percent: set this to "Y" for percent change or "N" for absolute
-- change, the default is percent change
function change_column
( p_current_column  in varchar2
, p_prior_column    in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2;

-- this function is a wrapper to poa_dbi_util_pkg.rate_clause
-- p_current_column: the numerator measure column
-- p_prior_column: the denominator measure column
-- p_column_alias: optional provide the alias that you
-- want to have appended.
-- p_percent: set this to "Y" for percent or "N" for ratio,
-- the default is percent
function rate_column
( p_numerator       in varchar2
, p_denominator     in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2;

-- this procedure calculates the grp_id value for an MV
-- that implements grouping sets and adds the value as a bind variable.
-- p_dim_bmap: the dimension level bitmap based on entered parameters
--             and selected view by returned from process_parameters
-- p_custom_output: this returns custom bind values that your report will
--                  need such as the &ISC_GRP_ID.
-- p_columnN: up to 8 column names can be passed in, use the logical
--            name for the dimension level.  the order of these columns
--            is important and must match the grouping_id clause in the
--            corresponding MV defintion.
procedure bind_group_id
( p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
, p_column1       in varchar2 default null
, p_column2       in varchar2 default null
, p_column3       in varchar2 default null
, p_column4       in varchar2 default null
, p_column5       in varchar2 default null
, p_column6       in varchar2 default null
, p_column7       in varchar2 default null
, p_column8       in varchar2 default null
);

-- this function returns a snippet of where clause code that can be included
-- in your MV inline view text
-- p_fact_alias: the alias you have assigned to your fact table/MV, typically
--               the will be "fact"
-- p_org_id: the value of the user selected org id.  the actual value is not
--           important.  if the user has selected an value (other than All)
--           then this function will return null as the main query will
--           filter on organization_id anyway.
function get_sec_where_clause
( p_fact_alias  in varchar2
, p_org_id      in varchar2
)
return varchar2;

-- this function returns a comments (/* */) dump of the
-- contents of p_param, showing parameter name, value, id,
-- dimension etc.
-- this can be used during development to validate that the
-- parameters PMV is passing are as you would expect.
-- note: the function should not be included in any code
-- released as it will cause a unique sql statement to be
-- generated each time, it is for development testing only.
function dump_parameters
( p_param in bis_pmv_page_parameter_tbl )
return varchar2;

-- this function allows you to create a second (or Nth) view by
-- in a report, for example asset downtime view by asset plus
-- criticality and returns the select list column for you to use.
-- p_view_by: the dimension level using it's logical name
-- p_dimension_tbl: this is x_dimension_tbl returned from
--                  register_dimension_levels
-- p_join_tbl: this is x_join_tbl returned from process_parameters
function add_view_by
( p_view_by          in varchar2
, p_dimension_tbl    in t_dimension_tbl
, p_join_tbl         in out nocopy poa_dbi_util_pkg.poa_dbi_join_tbl
)
return varchar2;

-- this function returns the select list element for rendering the
-- drill to detail URL for work order read only.
-- by default it assumes that:
--   organization_id will be available as oset.organization_id and
--   wip_entity_id will be available as oset.work_order_id
-- you need to pass a value for p_org_id_column and p_wo_id_column
-- if you have something different.
function get_drill_detail
( p_column_alias     in varchar2
, p_org_id_column    in varchar2 default null
, p_wo_id_column     in varchar2 default null
)
return varchar2;


-- this function returns the portion of the inner query select stmt
-- that can be used by window queries.  It is based on the code used
-- in poa_dbi_template_pkg.get_group_and_sel_clause which is
-- not public.
function get_inner_select_col
(p_join_tables in poa_dbi_util_pkg.poa_dbi_join_tbl
) return varchar2;


--This function is to return the
--asset group curresponding to the
--asset number
-- input parameters are the p_view_by (asset_number)
-- and the dimension table to locate the asset_number dimension parameters
function add_asset_group_column
( p_view_by in varchar2
, p_dimension_tbl in t_dimension_tbl
)
return varchar2;


end isc_maint_rpt_util_pkg;

 

/
