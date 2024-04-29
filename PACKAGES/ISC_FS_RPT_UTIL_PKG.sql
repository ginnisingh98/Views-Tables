--------------------------------------------------------
--  DDL for Package ISC_FS_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_RPT_UTIL_PKG" 
/* $Header: iscfsrptutils.pls 120.2 2006/04/12 20:45:40 kreardon noship $ */
AUTHID CURRENT_USER as

-- the following are constants that define the actual (or pseudo)
-- dimension levels used in reports.
-- these constants are used internally and should be use externally
-- rather than making direct reference to the dimension+dimension_level

G_CURRENCY                constant varchar2(50) := 'CURRENCY+FII_CURRENCIES';
G_CATEGORY                constant varchar2(50) := 'ITEM+ENI_ITEM_VBH_CAT';
G_PRODUCT                 constant varchar2(50) := 'ITEM+ENI_ITEM';
G_CUSTOMER                constant varchar2(50) := 'CUSTOMER+PROSPECT';
G_DISTRICT                constant varchar2(50) := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
G_DISTANCE_UOM            constant varchar2(50) := 'BIV_FS_DISTANCE_UOM+BIV_FS_DISTANCE_UOM_LVL';
G_TASK_TYPE               constant varchar2(50) := 'BIV_FS_TASK_TYPE+BIV_FS_TASK_TYPE_LVL';
G_BACKLOG_AGING_DISTRIB   constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_BACKLOG_AGING';
G_TIME_TO_RES_DISTRIB     constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_TIME_TO_RES';
G_TRVL_DIST_DISTRIB       constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_TRVL_DIST';
G_TRVL_DIST_VAR_DISTRIB   constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_TRVL_DIST_VAR';
G_TRVL_TIME_DISTRIB       constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_TRVL_TIME';
G_TRVL_TIME_VAR_DISTRIB   constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_TRVL_TIME_VAR';
G_INV_CATEGORY            constant varchar2(50) := 'ITEM+ENI_ITEM_INV_CAT';
G_ITEM_ORG                constant varchar2(50) := 'ITEM+ENI_ITEM_ORG';
G_SEVERITY                constant varchar2(50) := 'SEVERITY+SEVERITY';

-- pseudo
G_ACTIVITY_EVENT          constant varchar2(50) := 'TASK_ACTIVITY_EVENT';
G_TASK_OWNER              constant varchar2(50) := 'TASK_OWNER';
G_BACKLOG_STATUS          constant varchar2(50) := 'BIV_FS_DISTRIB+BIV_FS_BACKLOG_STATUS';
G_TASK_STATUS             constant varchar2(50) := 'TASK_STATUS';
G_SR_STATUS               constant varchar2(50) := 'SR_STATUS';
G_SR_TYPE                 constant varchar2(50) := 'SR_TYPE';
G_SR_OWNER                constant varchar2(50) := 'SR_OWNER';
G_TASK_ASSIGNEE           constant varchar2(50) := 'TASK_ASSIGNEE';
G_TASK_ADDRESS            constant varchar2(50) := 'TASK_ADDRESS';

-- short form of G_DISTRICT
G_DISTRICT_SHORT          constant varchar2(50) := 'ISC_FS_DISTRICT';

G_CURRENCY_BMAP               constant number := 1;
G_CATEGORY_BMAP               constant number := 2;
G_PRODUCT_BMAP                constant number := 4;
G_CUSTOMER_BMAP               constant number := 8;
G_DISTRICT_BMAP               constant number := 16;
G_DISTANCE_UOM_BMAP           constant number := 32;
G_TASK_TYPE_BMAP              constant number := 64;
G_BACKLOG_AGING_DISTRIB_BMAP  constant number := 128;
G_TIME_TO_RES_DISTRIB_BMAP    constant number := 256;
G_TRVL_DIST_DISTRIB_BMAP      constant number := 512;
G_TRVL_DIST_VAR_DISTRIB_BMAP  constant number := 1024;
G_TRVL_TIME_DISTRIB_BMAP      constant number := 2048;
G_TRVL_TIME_VAR_DISTRIB_BMAP  constant number := 4096;
G_INV_CATEGORY_BMAP           constant number := 8192;
G_ITEM_ORG_BMAP               constant number := 16384;
G_SEVERITY_BMAP               constant number := 32768;

-- pseudo
G_ACTIVITY_EVENT_BMAP         constant number := 65536;
G_TASK_OWNER_BMAP             constant number := 131072;
G_BACKLOG_STATUS_BMAP         constant number := 262144;
G_TASK_STATUS_BMAP            constant number := 524288;
G_SR_STATUS_BMAP              constant number := 1048576;
G_SR_TYPE_BMAP                constant number := 2097152;
G_SR_OWNER_BMAP               constant number := 4194304;
G_TASK_ASSIGNEE_BMAP          constant number := 8388608;
G_TASK_ADDRESS_BMAP           constant number := 16777216;

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
-- x_uom_suffix: returns "km" or "mi" based on the distance UOM parameter,
--               needed for travel reports to determine distance UOM
--               column to use.
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
, x_uom_suffix       out nocopy varchar2
);

-- this is an overload of process_parameters that does not return
-- x_uom_suffix.
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
, p_percent         in varchar2 default null -- treated as 'Y'
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
, p_percent         in varchar2 default null -- treated as 'Y'
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

-- this procedure is a noop
procedure check_district_filter
( p_param     in bis_pmv_page_parameter_tbl
, p_dim_map   in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
);

-- this function returns the portion of the inner query select stmt
-- that can be used by window queries.  It is based on the code used
-- in poa_dbi_template_pkg.get_group_and_sel_clause which is unfortunately
-- not public.
-- p_join_tables: this is x_join_tbl returned from process_parameters
function get_inner_select_col
( p_join_tables in poa_dbi_util_pkg.poa_dbi_join_tbl
)
return varchar2;

-- this function returns the drill down URL for product category
-- it returns NULL unless p_view_by is G_CATEGORY
-- p_view_by: pass the report view by
-- p_function_name: function name of the report to drill to
-- p_column_alias: optionally pass the column alias to be appended to
--                 return URL
function get_category_drill_down
( p_view_by       in varchar2
, p_function_name in varchar2
, p_column_alias  in varchar2 default null
)
return varchar2;

-- this function returns the drill down URL for district
-- it returns NULL unless p_view_by is G_DISTRICT
-- NULL will also be returned if the row value is for any value under
-- the Unassigned district, or the row value is for a group at the technician
-- level (occurs when owner/assignee is a group and not an individual).
-- p_view_by: pass the report view by, if the view by is G_DISTRICT
--            logic will be applied to check value of district_id_c
-- p_function_name: function name of the report to drill to
-- p_column_alias: optionally pass the column alias to be appended to
--                 return URL
function get_district_drill_down
( p_view_by       in varchar2
, p_function_name in varchar2
, p_column_alias  in varchar2 default null
)
return varchar2;

-- this function returns the drill to service request detail URL
-- p_sr_id_col: the column name/alias in the report query that contains
--              the incident_id value
function get_sr_detail_page_function
( p_sr_id_col in varchar2
)
return varchar2;

-- this procedures adds any custom bind variable value to p_custom_output
-- p_custom_output: this returns custom bind values, it will be initialized
--                  only if NULL
-- p_parameter_name: the name of the bind variable, this needs to match
--                   the string used in your report query.  you should include
--                   the prefix of "&" etc
-- p_parameter_data_type: this procedure does not validate this parameter,
--                        however it should be one of the following constants:
--                        BIS_PMV_PARAMETERS_PUB.INTEGER_BIND
--                        BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND
--                        BIS_PMV_PARAMETERS_PUB.DATE_BIND
--                        BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND
--                        BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND
--                        BIS_PMV_PARAMETERS_PUB.MESSAGE_BIND
-- p_parameter_value: this is the value to be used for the bind value, it needs
--                    to be compatible with p_parameter_data_type, for DATE_BIND
--                    pass date as DD/MM/YYYY
procedure add_custom_bind_parameter
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_parameter_name      in varchar2
, p_parameter_data_type in varchar2
, p_parameter_value     in varchar2
);

-- this procedure adds bind variable values to p_custom_output for
-- the low and high values for a bucket set
-- p_param: the parameter table passed into your report from PMV.
-- p_param_name: the parameter name that you need to check the value
--               of to get the low and high values
-- p_short_name: the bucket set short name
-- p_custom_output: this returns custom bind values, it will be initialized
--                  only if NULL
-- p_low_token: optionally provide the bind variable name to use for low
--              value, defaults to &ISC_FS_LOW
-- p_high_token: optionally provide the bind variable name to use for low
--               value, defaults to &ISC_FS_HIGH
procedure bind_low_high
( p_param         in bis_pmv_page_parameter_tbl
, p_param_name    in varchar2
, p_short_name    in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
, p_low_token     in varchar2 default null
, p_high_token    in varchar2 default null
);

-- this function returns the URL to enable drill on view by date for trend
-- reports.  it returns to columns for inclusion in the select list, first
-- for WTD and second for RLW.  One, other or both can be returned as NULL.
-- p_xtd: period type code (WTD,RLW are the important ones)
-- p_function_name: function name of the report to drill to
-- p_alias_wtd: column alias to be used for WTD function URL
-- p_alias_rlw: column alias to be used for RLW function URL
-- p_override_end_date: optionally provide the column in the query that
--                      contains the date to be passed, default cal.end_date
function get_trend_drill
( p_xtd in varchar2
, p_function_name in varchar2
, p_alias_wtd in varchar2
, p_alias_rlw in varchar2
, p_override_end_date in varchar2 default null
)
return varchar2;

-- this function returns the default parameter values for a
-- web portlet provider (dashboard region)
-- p_region_code: default parameter values are based on region code
function default_params
( p_region_code   in varchar2
)
return varchar2;

-- this procedure modifies the POA template generated
-- join between fact table and inline view using fii_time_rpt_struct_v
-- it also removes the extra table (inline view) added to the report query
-- to allows distict_id_c to be included in the group by clause
-- p_query: the query string generated by the POA template
-- p_trend: Y or N to indicate if the query is for a trend report or not
procedure enhance_time_join
( p_query in out nocopy varchar2
, p_trend in varchar2
);

-- this function returns the drill to task detail URL
-- p_task_id_col: the column name/alias in the report query that contains
--                the task_id value
function get_task_detail_page_function
( p_task_id_col in varchar2
)
return varchar2;

-- this function returns the drill to detail URL string for
-- a measure column.
-- p_view_by: pass the report view by, if the view by is G_DISTRICT
--            logic will be applied to check value of district_id_c
--            before return URL
-- p_check_column_name: pass the base column name that will to have
--                      it's value checked
-- p_function_name: pass the function name to be used in the URL
-- p_column_alias: optionally pass the column alias to be appended to
--                 return URL
-- p_extra_params: optionally pass any extra parameters you need to
--                 be appended to the return URL
-- p_check_column: optionally pass "Y" to have base column name checked
--                 (NULL/0), if NULL then assumed to be "N".  This may
--                 toogle to assumed "Y" if ER 4532901 is approved.
-- p_check_resource: optionally pass "Y" to have have drill enabled only
--                   for resource level rows when view by G_DISTRICT
function get_detail_drill_down
( p_view_by           in varchar2
, p_check_column_name in varchar2
, p_function_name     in varchar2
, p_column_alias      in varchar2 default null
, p_extra_params      in varchar2 default null
, p_check_column      in varchar2 default null
, p_check_resource    in varchar2 default null
)
return varchar2;

-- this function returns a drill to detail URL string for
-- all of the valid bucket measure columns.  it internally
-- calls get_detail_drill_down for each column appending the
-- bucket number to p_extra_params
-- p_function_name: pass the function name to be used in the URL
-- p_check_column_name: pass the base column name that will to have
--                      it's value checked
-- p_column_alias: pass the base column alias to be appended to
--                 return URL, the bucket number will be appended
-- p_extra_params: pass any extra parameters you need to
--                 be appended to the return URL, the bucket number will be
--                 appended
-- p_check_column: optionally pass "Y" to have base column name checked
--                 (NULL/0), if NULL then assumed to be "N".  This may
--                 toogle to assumed "Y" if ER 4532901 is approved.
-- p_check_resource: optionally pass "Y" to have have drill enabled only
--                   for resource level rows when view by G_DISTRICT
function get_bucket_drill_down
( p_bucket_rec        in bis_bucket_pub.bis_bucket_rec_type
, p_view_by           in varchar2
, p_check_column_name in varchar2
, p_function_name     in varchar2
, p_column_alias      in varchar2
, p_extra_params      in varchar2
, p_check_column      in varchar2 default null
, p_check_resource    in varchar2 default null
)
return varchar2;

-- this function returns Y or N to indicate whether the current district
-- parameter (id) is a leaf node (or resource) or non-leaf node.
-- It returns Y if the district is a leaf node district or a resource,
-- otherwise returns N.
-- p_param: the parameter table passed into your report from PMV.
function is_district_leaf_node
( p_param            in bis_pmv_page_parameter_tbl
)
return varchar2;

end isc_fs_rpt_util_pkg;

 

/
