--------------------------------------------------------
--  DDL for Package Body BIV_DBI_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_ACT_PKG" 
/* $Header: bivsrvractb.pls 120.0 2005/05/25 10:48:26 appldev noship $ */
as

  g_activity_rep_func          varchar2(50) := 'BIV_DBI_ACT_TBL_REP';
  g_activity_backlog_rep_func  varchar2(50) := 'BIV_DBI_ACT_BAK_TBL_REP';
  g_backlog_rep_func           varchar2(50) := 'BIV_DBI_BAK_TBL_REP';
/*
-- Last refresh date checks
procedure set_last_collection
is
begin
   poa_dbi_template_pkg.g_c_as_of_date :=  'least(&BIS_CURRENT_ASOF_DATE,&LAST_COLLECTION)';
   poa_dbi_template_pkg.g_p_as_of_date :=  'least(&BIS_PREVIOUS_ASOF_DATE,&LAST_COLLECTION)';
end set_last_collection;

-- Last refresh date checks
procedure unset_last_collection
is
begin
   poa_dbi_template_pkg.g_c_as_of_date :=  '&BIS_CURRENT_ASOF_DATE';
   poa_dbi_template_pkg.g_p_as_of_date :=  '&BIS_PREVIOUS_ASOF_DATE';
end unset_last_collection;
*/
procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_view_by          varchar2(200);
  l_view_by_col_name varchar2(200);
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_stmt             varchar2(32767);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;

begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'ACTIVITY'
  , p_trend            => 'N'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );


  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'XTD';
--     l_mv  := 'BIV_ACT_H_SUM_MV';
  ELSE
     l_to_date_type := 'RLX';
  END IF;


  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'first_opened_count'
                             , p_alias_name => 'first_opened'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'reopened_count'
                             , p_alias_name => 'reopened'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'closed_count'
                             , p_alias_name => 'closed'
                             , p_to_date_type => l_to_date_type
                             );

  l_stmt := 'select
  ' ||
    biv_dbi_tmpl_util.get_view_by_col_name(l_view_by) || ' VIEWBY ' || '
, oset.' || l_view_by_col_name || ' VIEWBYID ' ||
    case
      when l_view_by = biv_dbi_tmpl_util.g_PRODUCT then
        ', v.description'
      else
        ', null'
    end
    || ' BIV_ATTRIBUTE5
/* First Opened Prior */
, nvl(oset.p_first_opened,0) BIV_MEASURE1
/* First Opened Current */
, nvl(oset.c_first_opened,0) BIV_MEASURE2
/* First Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_first_opened'
                               ,'oset.p_first_opened'
                               ,'BIV_MEASURE4') ||
'
/* Reopened Prior */
, nvl(oset.p_reopened,0) BIV_MEASURE5
/* Reopened Current */
, nvl(oset.c_reopened,0) BIV_MEASURE6
/* Reopened Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_reopened'
                               ,'oset.p_reopened'
                               ,'BIV_MEASURE8') ||
'
/* Opened Prior */
, nvl(oset.p_first_opened,0)+nvl(oset.p_reopened,0) BIV_MEASURE9
/* Opened Current */
, nvl(oset.c_first_opened,0)+nvl(oset.c_reopened,0) BIV_MEASURE10
/* Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('(nvl(oset.c_first_opened,0)+nvl(oset.c_reopened,0))'
                               ,'(nvl(oset.p_first_opened,0)+nvl(oset.p_reopened,0))'
                               ,'BIV_MEASURE12') ||
'
/* Closed Prior */
, nvl(oset.p_closed,0) BIV_MEASURE13
/* Closed Current */
, nvl(oset.c_closed,0) BIV_MEASURE14
/* Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_closed'
                               ,'oset.p_closed'
                               ,'BIV_MEASURE16') ||
'
/* Open to Close Ratio Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('(nvl(oset.p_first_opened,0)+nvl(oset.p_reopened,0))'
                             ,'oset.p_closed','BIV_MEASURE17'
                             ,'N') ||
'
/* Open to Close Ratio Current */
, ' ||
biv_dbi_tmpl_util.rate_column('(nvl(oset.c_first_opened,0)+nvl(oset.c_reopened,0))'
                             ,'oset.c_closed'
                             ,'BIV_MEASURE18'
                             ,'N') ||
'
/* Open to Close Ratio Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('(nvl(oset.c_first_opened,0)+nvl(oset.c_reopened,0))'
                                                             ,'oset.c_closed',null,'N')
                               ,biv_dbi_tmpl_util.rate_column('(nvl(oset.p_first_opened,0)+nvl(oset.p_reopened,0))'
                                                             ,'oset.p_closed',null,'N')
                               ,'BIV_MEASURE20'
                               ,'N') ||
'
/* GT First Opened Current */
, nvl(oset.c_first_opened_total,0) BIV_MEASURE21
/* GT First Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_first_opened_total'
                               ,'oset.p_first_opened_total'
                               ,'BIV_MEASURE22') ||
'
/* GT Repened Current */
, nvl(oset.c_reopened_total,0) BIV_MEASURE23
/* GT Repened Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_reopened_total'
                               ,'oset.p_reopened_total'
                               ,'BIV_MEASURE24') ||
'
/* GT Opened Current */
, nvl(oset.c_first_opened_total,0)+nvl(oset.c_reopened_total,0) BIV_MEASURE25
/* GT Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('(nvl(oset.c_first_opened_total,0)+nvl(oset.c_reopened_total,0))'
                               ,'(nvl(oset.p_first_opened_total,0)+nvl(oset.p_reopened_total,0))'
                               ,'BIV_MEASURE26') ||
'
/* GT Closed Current */
, nvl(oset.c_closed_total,0) BIV_MEASURE27
/* GT Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_closed_total'
                               ,'oset.p_closed_total'
                               ,'BIV_MEASURE28') ||
'
/* GT Open to Close Ratio Current */
, ' ||
biv_dbi_tmpl_util.rate_column('(nvl(oset.c_first_opened_total,0)+nvl(oset.c_reopened_total,0))'
                             ,'oset.c_closed_total'
                             ,'BIV_MEASURE29'
                             ,'N') ||
'
/* GT Open to Close Ratio Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('(nvl(oset.c_first_opened_total,0)+nvl(oset.c_reopened_total,0))'
                                                             ,'oset.c_closed_total',null,'N')
                               ,biv_dbi_tmpl_util.rate_column('(nvl(oset.p_first_opened_total,0)+nvl(oset.p_reopened_total,0))'
                                                             ,'oset.p_closed_total',null,'N')
                               ,'BIV_MEASURE30'
                               ,'N') ||
'
/* KPI GT Opened Prior */
, nvl(oset.p_first_opened_total,0)+nvl(oset.p_reopened_total,0) BIV_MEASURE31
/* KPI GT Closed Prior */
, nvl(oset.p_closed_total,0) BIV_MEASURE32
, ' ||
biv_dbi_tmpl_util.get_category_drill_down( l_view_by , g_activity_rep_func ) ||
'
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
        ( P_FACT_NAME            => l_mv
        , P_WHERE_CLAUSE         => l_where_clause
        , P_JOIN_TABLES          => l_join_tbl
        , P_USE_WINDOWING        => 'N'
        , P_COL_NAME             => l_col_tbl
        , P_USE_GRPID            => 'N'
        , P_PAREN_COUNT          => 3
        , P_FILTER_WHERE         => '(c_first_opened > 0 or p_first_opened > 0 or ' ||
                                     'c_reopened > 0 or p_reopened > 0 or ' ||
                                     'c_closed > 0 or p_closed > 0)'
        , P_GENERATE_VIEWBY      => 'Y'
        );

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

end get_tbl_sql;

procedure get_act_bak_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_view_by          varchar2(200);
  l_view_by_col_name varchar2(200);
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_backlog_stmt     varchar2(32767);
  l_activity_stmt    varchar2(32767);
  l_stmt             varchar2(32767);
  l_balance_fact     varchar2(200);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;

begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'BACKLOG'
  , p_trend            => 'N'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'YTD';
  --  set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'backlog_count'
                             , p_alias_name   => 'backlog'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total  => 'N'
                             , p_prior_code   => poa_dbi_util_pkg.OPENING_PRIOR_CURR
                             );

  l_backlog_stmt := 'select
  ' || l_view_by_col_name || '
, nvl(o_backlog,0) o_backlog
, 0 c_opened
, 0 p_opened
, 0 c_closed
, 0 p_closed
, nvl(c_backlog,0) c_backlog
, nvl(p_backlog,0) p_backlog
from
( ( ' ||
                    poa_dbi_template_pkg.status_sql
                    ( p_fact_name            => l_mv
                    , p_where_clause         => l_where_clause
                    , p_join_tables          => l_join_tbl
                    , p_use_windowing        => 'N'
                    , p_col_name             => l_col_tbl
                    , p_use_grpid            => 'N'
                    , p_paren_count          => 3
                    , p_filter_where         => null
                    , p_generate_viewby      => 'N'
                    );
--  unset_last_collection;


  IF (l_to_date_type <> 'BAL')
  THEN
     /* This was added to avoid descripency between rolling and xtd model query generated for OPENING_PRIOR_CURR measures */
     l_backlog_stmt := replace(l_backlog_stmt,'fact.report_date','cal.report_date');
  END IF;


  l_balance_fact := biv_dbi_tmpl_util.get_balance_fact(l_mv);

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'ACTIVITY'
  , p_trend            => 'N'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'XTD';
--     l_mv  := 'BIV_ACT_H_SUM_MV';
  ELSE
     l_to_date_type := 'RLX';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'first_opened_count'
                             , p_alias_name => 'first_opened'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'reopened_count'
                             , p_alias_name => 'reopened'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'closed_count'
                             , p_alias_name => 'closed'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  l_activity_stmt := '
union all
select
  ' || l_view_by_col_name || '
, 0 o_backlog
, nvl(c_first_opened,0)+nvl(c_reopened,0) c_opened
, nvl(p_first_opened,0)+nvl(p_reopened,0) p_opened
, nvl(c_closed,0) c_closed
, nvl(p_closed,0) p_closed
, 0 c_backlog
, 0 p_backlog
from
 ( ' ||
                     poa_dbi_template_pkg.status_sql
                     ( p_fact_name            => l_mv
                     , p_where_clause         => l_where_clause
                     , p_join_tables          => l_join_tbl
                     , p_use_windowing        => 'N'
                     , p_col_name             => l_col_tbl
                     , p_use_grpid            => 'N'
                     , p_paren_count          => 3
                     , p_filter_where         => null
                     , p_generate_viewby      => 'N'
                     );

  l_stmt := '
select
  ' ||
    biv_dbi_tmpl_util.get_view_by_col_name(l_view_by) || ' VIEWBY ' ||
    ', oset.' || l_view_by_col_name || ' VIEWBYID ' ||
    case
      when l_view_by = biv_dbi_tmpl_util.g_PRODUCT then
        ', v.description'
      else
        ', null'
    end
    || ' BIV_ATTRIBUTE5
/* Beginning Backlog */
, oset.o_backlog BIV_MEASURE1
/* Opened Prior */
, oset.p_opened BIV_MEASURE2
/* Opened Current */
, oset.c_opened BIV_MEASURE3
/* Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_opened'
                               ,'oset.p_opened'
                               ,'BIV_MEASURE5') ||
'
/* Closed Prior */
, oset.p_closed BIV_MEASURE6
/* Closed Current */
, oset.c_closed BIV_MEASURE7
/* Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_closed'
                               ,'oset.p_closed'
                               ,'BIV_MEASURE9') ||
'
/* Transfer Current */
, c_backlog-(o_backlog+c_opened-c_closed) BIV_MEASURE10
/* Backlog Prior */
, oset.p_backlog BIV_MEASURE11
/* Backlog Current */
, oset.c_backlog BIV_MEASURE12
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog'
                               ,'oset.p_backlog'
                               ,'BIV_MEASURE14') ||
'
/* GT Beginning Backlog */
, oset.o_backlog_total BIV_MEASURE15
/* GT Opened Current */
, oset.c_opened_total BIV_MEASURE16
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_opened_total'
                               ,'oset.p_opened_total'
                               ,'BIV_MEASURE17') ||
'
/* GT Closed Current */
, oset.c_closed_total BIV_MEASURE18
/* GT Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_closed_total'
                               ,'oset.p_closed_total'
                               ,'BIV_MEASURE19') ||
'
/* GT Transfer Current */
, c_backlog_total-(o_backlog_total+c_opened_total-c_closed_total) BIV_MEASURE20
/* GT Backlog Current */
, oset.c_backlog_total BIV_MEASURE21
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog_total'
                               ,'oset.p_backlog_total'
                               ,'BIV_MEASURE22') ||
'
, ' ||
biv_dbi_tmpl_util.get_category_drill_down( l_view_by , g_activity_backlog_rep_func ) ||
'
, ''pFunctionName=' || g_backlog_rep_func || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY='
                          || case l_view_by
                               when biv_dbi_tmpl_util.g_SEVERITY then
                                 biv_dbi_tmpl_util.g_STATUS
                               else
                                 biv_dbi_tmpl_util.g_SEVERITY
                             end
                          || '&pParamIds=Y'' BIV_ATTRIBUTE6
from (
select
  ' || l_view_by_col_name || '
, sum(o_backlog) o_backlog
, sum(sum(o_backlog)) over () o_backlog_total
, sum(c_opened) c_opened
, sum(sum(c_opened)) over () c_opened_total
, sum(p_opened) p_opened
, sum(sum(p_opened)) over () p_opened_total
, sum(c_closed) c_closed
, sum(sum(c_closed)) over () c_closed_total
, sum(p_closed) p_closed
, sum(sum(p_closed)) over () p_closed_total
, sum(c_backlog) c_backlog
, sum(sum(c_backlog)) over () c_backlog_total
, sum(p_backlog) p_backlog
, sum(sum(p_backlog)) over () p_backlog_total
from (
' ||
l_backlog_stmt || l_activity_stmt ||
'
group by ' || l_view_by_col_name || '
) oset
, ' || l_join_tbl(1).table_name || ' ' || l_join_tbl(1).table_alias || '
where oset.' || l_join_tbl(1).fact_column || '=' ||
      l_join_tbl(1).table_alias || '.' || l_join_tbl(1).column_name ||
      case when l_join_tbl(1).dim_outer_join = 'Y' then '(+)' end ||
      ' ' ||
      case when l_join_tbl(1).additional_where_clause is not null then
             'and ' || l_join_tbl(1).additional_where_clause
      end ||
      ' and (oset.o_backlog > 0 or ' ||
            'oset.c_opened > 0 or oset.p_opened > 0 or ' ||
            'oset.c_closed > 0 or oset.p_closed > 0 or ' ||
            'oset.c_backlog > 0 or oset.p_backlog > 0)' || '
&ORDER_BY_CLAUSE nulls last';

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => l_balance_fact
  , p_xtd           => l_xtd
  );

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

end get_act_bak_tbl_sql;

procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_view_by          varchar2(200);
  l_view_by_col_name varchar2(200);
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_stmt             varchar2(32767);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;


begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'ACTIVITY'
  , p_trend            => 'Y'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'XTD';
--     l_mv  := 'BIV_ACT_H_SUM_MV';
  ELSE
     l_to_date_type := 'RLX';
  END IF;


  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'first_opened_count'
                             , p_alias_name => 'first_opened'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'reopened_count'
                             , p_alias_name => 'reopened'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'closed_count'
                             , p_alias_name => 'closed'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  l_stmt := 'select
  cal.name VIEWBY
/* End date of the period */
, cal.end_date VIEWBYID
/* First Opened Prior */
, nvl(iset.p_first_opened,0) BIV_MEASURE1
/* First Opened Current */
, nvl(iset.c_first_opened,0) BIV_MEASURE2
/* First Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_first_opened'
                               ,'iset.p_first_opened'
                               ,'BIV_MEASURE3') ||
'
/* Reopened Prior */
, nvl(iset.p_reopened,0) BIV_MEASURE4
/* Reopened Current */
, nvl(iset.c_reopened,0) BIV_MEASURE5
/* Reopened Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_reopened'
                               ,'iset.p_reopened'
                               ,'BIV_MEASURE6') ||
'
/* Opened Prior */
, nvl(iset.p_first_opened,0)+nvl(iset.p_reopened,0) BIV_MEASURE7
/* Opened Current */
, nvl(iset.c_first_opened,0)+nvl(iset.c_reopened,0) BIV_MEASURE8
/* Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('(nvl(iset.c_first_opened,0)+nvl(iset.c_reopened,0))'
                               ,'(nvl(iset.p_first_opened,0)+nvl(iset.p_reopened,0))'
                               ,'BIV_MEASURE10') ||
'
/* Closed Prior */
, nvl(iset.p_closed,0) BIV_MEASURE11
/* Closed Current */
, nvl(iset.c_closed,0) BIV_MEASURE12
/* Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_closed'
                               ,'iset.p_closed'
                               ,'BIV_MEASURE14') ||
'
/* Open to Close Ratio Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('(nvl(iset.p_first_opened,0)+nvl(iset.p_reopened,0))'
                             ,'iset.p_closed','BIV_MEASURE15'
                             ,'N') ||
'
/* Open to Close Ratio Current */
, ' ||
biv_dbi_tmpl_util.rate_column('(nvl(iset.c_first_opened,0)+nvl(iset.c_reopened,0))'
                             ,'iset.c_closed'
                             ,'BIV_MEASURE16'
                             ,'N') ||
'
/* Open to Close Ratio Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('(nvl(iset.c_first_opened,0)+nvl(iset.c_reopened,0))'
                                                             ,'iset.c_closed',null,'N')
                               ,biv_dbi_tmpl_util.rate_column('(nvl(iset.p_first_opened,0)+nvl(iset.p_reopened,0))'
                                                             ,'iset.p_closed',null,'N')
                               ,'BIV_MEASURE18'
                               ,'N');

IF (l_xtd = 'WTD')
  THEN
  l_stmt := l_stmt ||','||'''AS_OF_DATE=''||to_char(cal.end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_ACT_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL1' || ',NULL BIV_DYNAMIC_URL2';
ELSIF (l_xtd = 'RLW') THEN
  l_stmt := l_stmt ||',NULL BIV_DYNAMIC_URL1 ,'||'''AS_OF_DATE=''||to_char(cal.end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_ACT_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL2';
  ELSE
  l_stmt:= l_stmt || ', NULL BIV_DYNAMIC_URL1, NULL BIV_DYNAMIC_URL2';
  END IF;

l_stmt := l_stmt ||'
from
  ' || poa_dbi_template_pkg.trend_sql
        ( p_xtd                  => l_xtd
        , p_comparison_type      => l_comparison_type
        , p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  );

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  IF(l_xtd = 'DAY')
  THEN
    poa_dbi_util_pkg.get_custom_day_binds(p_custom_output     => l_custom_output,
                                           p_as_of_date        => l_as_of_date,
                                           p_comparison_type   => l_comparison_type);
    null;
  END IF;


  x_custom_output := l_custom_output;

end get_trd_sql;

procedure get_act_bak_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_view_by          varchar2(200);
  l_view_by_col_name varchar2(200);
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_backlog_stmt     varchar2(32767);
  l_activity_stmt    varchar2(32767);
  l_stmt             varchar2(32767);
  l_balance_fact     varchar2(200);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output bis_query_attributes_tbl;

  l_to_date_type      VARCHAR2 (3)  ;
  l_as_of_date        date;

begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'BACKLOG'
  , p_trend            => 'Y'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'YTD';
--     set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;


  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'backlog_count'
                             , p_alias_name   => 'backlog'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total  => 'N'
                             , p_prior_code   => poa_dbi_util_pkg.OPENING_PRIOR_CURR
                             );

  l_backlog_stmt := 'select
  cal.name
, cal.start_date
, cal.end_date
, nvl(iset.o_backlog,0) o_backlog
, 0 c_opened
, 0 p_opened
, 0 c_closed
, 0 p_closed
, nvl(iset.c_backlog,0) c_backlog
, nvl(iset.p_backlog,0) p_backlog
from
  ' || poa_dbi_template_pkg.trend_sql
        ( p_xtd                  => l_xtd
        , p_comparison_type      => l_comparison_type
        , p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        );
--  unset_last_collection;

  l_balance_fact := biv_dbi_tmpl_util.get_balance_fact(l_mv);


  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'ACTIVITY'
  , p_trend            => 'Y'
  , x_view_by          => l_view_by
  , x_view_by_col_name => l_view_by_col_name
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'XTD';
--     l_mv  := 'BIV_ACT_H_SUM_MV';
  ELSE
     l_to_date_type := 'RLX';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'first_opened_count'
                             , p_alias_name => 'first_opened'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'reopened_count'
                             , p_alias_name => 'reopened'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'closed_count'
                             , p_alias_name => 'closed'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  l_activity_stmt := '
union all
select
  cal.name
, cal.start_date
, cal.end_date
, 0 o_backlog
, nvl(iset.c_first_opened,0)+nvl(c_reopened,0) c_opened
, nvl(iset.p_first_opened,0)+nvl(p_reopened,0) p_opened
, nvl(iset.c_closed,0) c_closed
, nvl(iset.p_closed,0) p_closed
, 0 c_backlog
, 0 p_backlog

from
  ' || poa_dbi_template_pkg.trend_sql
        ( p_xtd                  => l_xtd
        , p_comparison_type      => l_comparison_type
        , p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        );

  l_stmt := 'select
  uset.name VIEWBY
/* End date of the period */
, uset.end_date VIEWBYID
/* Beginning Backlog */
, uset.o_backlog BIV_MEASURE1
/* Opened Prior */
, uset.p_opened BIV_MEASURE2
/* Opened Current */
, uset.c_opened BIV_MEASURE3
/* Opened Change */
, ' ||
biv_dbi_tmpl_util.change_column('uset.c_opened'
                               ,'uset.p_opened'
                               ,'BIV_MEASURE4') ||
'
/* Closed Prior */
, uset.p_closed BIV_MEASURE5
/* Closed Current */
, uset.c_closed BIV_MEASURE6
/* Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('uset.c_closed'
                               ,'uset.p_closed'
                               ,'BIV_MEASURE7') ||
'
/* Transfer Current */
, uset.c_backlog-(uset.o_backlog+uset.c_opened-uset.c_closed) BIV_MEASURE8
/* Backlog Prior */
, uset.p_backlog BIV_MEASURE9
/* Backlog Current */
, uset.c_backlog BIV_MEASURE10
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('uset.c_backlog'
                               ,'uset.p_backlog'
                               ,'BIV_MEASURE12');
IF (l_xtd = 'WTD')
  THEN
  l_stmt := l_stmt ||','||'''AS_OF_DATE=''||to_char(end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_ACT_BAK_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL1' || ',NULL BIV_DYNAMIC_URL2';
ELSIF (l_xtd = 'RLW') THEN
  l_stmt := l_stmt ||',NULL BIV_DYNAMIC_URL1 ,'||'''AS_OF_DATE=''||to_char(end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_ACT_BAK_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL2';
  ELSE
  l_stmt:= l_stmt || ', NULL BIV_DYNAMIC_URL1, NULL BIV_DYNAMIC_URL2';
  END IF;

l_stmt := l_stmt || '

from (
select
  name
, start_date
, end_date
, sum(o_backlog) o_backlog
, sum(c_opened) c_opened
, sum(p_opened) p_opened
, sum(c_closed) c_closed
, sum(p_closed) p_closed
, sum(c_backlog) c_backlog
, sum(p_backlog) p_backlog

from (
' ||
replace(l_backlog_stmt,'order by cal.start_date','') ||
replace(l_activity_stmt,'order by cal.start_date','') ||
' )
group by name, start_date, end_date
) uset
order by start_date';

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  -- only need to make lag offset adjustment for Week
  , p_opening_balance   => case when l_xtd = 'RLW' then 'Y' else 'N' end
  );

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => l_balance_fact
  , p_xtd           => l_xtd
  );

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  IF(l_xtd = 'DAY')
  THEN
    poa_dbi_util_pkg.get_custom_day_binds(p_custom_output     => l_custom_output,
                                           p_as_of_date        => l_as_of_date,
                                           p_comparison_type   => l_comparison_type);
    null;
  END IF;


  x_custom_output := l_custom_output;

end get_act_bak_trd_sql;

end biv_dbi_act_pkg;

/
