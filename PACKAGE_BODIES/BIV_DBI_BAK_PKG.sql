--------------------------------------------------------
--  DDL for Package Body BIV_DBI_BAK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_BAK_PKG" 
/* $Header: bivsrvrbakb.pls 120.0 2005/05/25 10:58:32 appldev noship $ */
as

  g_backlog_rep_func         varchar2(50) := 'BIV_DBI_BAK_TBL_REP';
  g_backlog_dbn_rep_func     varchar2(50) := 'BIV_DBI_BAK_DBN_TBL_REP';
  g_backlog_age_rep_func     varchar2(50) := 'BIV_DBI_BAK_AGE_TBL_REP';
  g_backlog_age_dbn_rep_func varchar2(50) := 'BIV_DBI_BAK_AGE_DBN_TBL_REP';

function drill_across
( p_distribution    in varchar2
, p_backlog_type    in varchar2
, p_col_name        in varchar2
, p_alias           in varchar2
, p_view_by         in varchar2
)
return varchar2
is

begin

  if p_view_by = biv_dbi_tmpl_util.g_AGING then
    return 'null ' || p_alias;
  end if;

  return 'case when &BIS_CURRENT_ASOF_DATE >= &LAST_COLLECTION then ' ||
         '''pFunctionName=' || case p_distribution
                               when 'Y' then
                                 g_backlog_age_dbn_rep_func
                               else
                                 g_backlog_age_rep_func
                             end
                          || case p_backlog_type
                               when 'ESCALATED' then
                                 '&BACKLOG_TYPE=ESCALATED'
                               when 'UNOWNED' then
                                 '&BACKLOG_TYPE=UNOWNED'
                             end
                          || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY='
                          || case p_view_by
                               when biv_dbi_tmpl_util.g_SEVERITY then
                                 biv_dbi_tmpl_util.g_STATUS
                               else
                                 biv_dbi_tmpl_util.g_SEVERITY
                             end
                          || '&pParamIds=Y'' else null end '
                          || p_alias;
end drill_across;

function unr_drill_across
( p_distribution    in varchar2
, p_backlog_type    in varchar2
, p_col_name        in varchar2
, p_alias           in varchar2
, p_view_by         in varchar2
)
return varchar2
is

begin

  if p_view_by = biv_dbi_tmpl_util.g_AGING then
    return 'null ' || p_alias;
  end if;

  return 'case when &BIS_CURRENT_ASOF_DATE >= &LAST_COLLECTION then ' ||
         '''pFunctionName=' || case p_distribution
                               when 'Y' then
                                 g_backlog_age_dbn_rep_func
                               else
                                 g_backlog_age_rep_func
                             end
                          || case p_backlog_type
                               when 'ESCALATED' then
                                 '&BACKLOG_TYPE=ESCALATED'
                               when 'UNOWNED' then
                                 '&BACKLOG_TYPE=UNOWNED'
                             end
                          || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY='
                          || case p_view_by
                               when biv_dbi_tmpl_util.g_SEVERITY then
                                 biv_dbi_tmpl_util.g_STATUS
                               else
                                 biv_dbi_tmpl_util.g_SEVERITY
                             end
                          || '&BIV_RES_STATUS=N&pParamIds=Y'' else null end '
                          || p_alias;
end unr_drill_across;

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
--     set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;


  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'backlog_count'
                             , p_alias_name => 'backlog'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'escalated_count'
                             , p_alias_name => 'escalated'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'unowned_count'
                             , p_alias_name => 'unowned'
                             , p_to_date_type => l_to_date_type
                             );

  l_stmt := 'select
  ' ||
    biv_dbi_tmpl_util.get_view_by_col_name(l_view_by) || ' VIEWBY ' ||
    ', oset.' || l_view_by_col_name || ' VIEWBYID ' ||
'
' ||
    case
      when l_view_by = biv_dbi_tmpl_util.g_PRODUCT then
        ', v.description'
      else
        ', null'
    end
    || ' BIV_ATTRIBUTE5
/* Backlog Prior */
, nvl(oset.p_backlog,0) BIV_MEASURE1
/* Backlog Current */
, nvl(oset.c_backlog,0) BIV_MEASURE2
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog'
                               ,'oset.p_backlog'
                               ,'BIV_MEASURE4') ||
'
/* Escalated Prior */
, nvl(oset.p_escalated,0) BIV_MEASURE9
/* Escalated Current */
, nvl(oset.c_escalated,0) BIV_MEASURE10
/* Escalated Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_escalated'
                               ,'oset.p_escalated'
                               ,'BIV_MEASURE12') ||
'
/* Unowned Prior */
, nvl(oset.p_unowned,0) BIV_MEASURE13
/* Unowned Current */
, nvl(oset.c_unowned,0) BIV_MEASURE14
/* Unowned Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_unowned'
                               ,'oset.p_unowned'
                               ,'BIV_MEASURE16') ||
'
/* GT Backlog Current */
, nvl(oset.c_backlog_total,0) BIV_MEASURE17
/* GT Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog_total'
                               ,'oset.p_backlog_total'
                               ,'BIV_MEASURE18') ||
'
/* GT Escalated Current */
, nvl(oset.c_escalated_total,0) BIV_MEASURE21
/* GT Escalated Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_escalated_total'
                               ,'oset.p_escalated_total'
                               ,'BIV_MEASURE22') ||
'
/* GT Unowned Current */
, nvl(oset.c_unowned_total,0) BIV_MEASURE23
/* GT Unowned Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_unowned_total'
                               ,'oset.p_unowned_total'
                               ,'BIV_MEASURE24') ||
'
, ' ||
biv_dbi_tmpl_util.get_category_drill_down( l_view_by, g_backlog_rep_func ) ||
'
, ' ||
drill_across('N','BACKLOG', 'oset.c_backlog', 'BIV_ATTRIBUTE6',l_view_by) ||
'
, ' ||
drill_across('N','ESCALATED', 'oset.c_escalated', 'BIV_ATTRIBUTE7',l_view_by) ||
'
, ' ||
drill_across('N','UNOWNED', 'oset.c_unowned', 'BIV_ATTRIBUTE8',l_view_by) ||
'
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 3
        , p_filter_where         => '(c_backlog > 0 or p_backlog > 0)'
        , p_generate_viewby      => 'Y'
        );

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
   l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);


  x_custom_sql      := l_stmt;
--  unset_last_collection;

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => biv_dbi_tmpl_util.get_balance_fact(l_mv)
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

  l_stmt := biv_dbi_tmpl_util.dump_binds(l_custom_output);

end get_tbl_sql;

procedure get_dbn_tbl_sql
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
--     set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'backlog_count'
                             , p_alias_name => 'backlog'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'escalated_count'
                             , p_alias_name => 'escalated'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'unowned_count'
                             , p_alias_name => 'unowned'
                             , p_to_date_type => l_to_date_type
                             );

  l_stmt := 'select
  ' ||
    biv_dbi_tmpl_util.get_view_by_col_name(l_view_by) || ' VIEWBY ' ||
    ', oset.' || l_view_by_col_name || ' VIEWBYID ' ||
'
' ||
    case
      when l_view_by = biv_dbi_tmpl_util.g_PRODUCT then
        ', v.description'
      else
        ', null'
    end
    || ' BIV_ATTRIBUTE5
/* Backlog Prior */
, nvl(oset.p_backlog,0) BIV_MEASURE1
/* Backlog Current */
, nvl(oset.c_backlog,0) BIV_MEASURE2
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog'
                               ,'oset.p_backlog'
                               ,'BIV_MEASURE4') ||
'
/* Percent of Total Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.p_backlog'
                             ,'oset.p_backlog_total'
                             ,'BIV_MEASURE5') ||
'
/* Percent of Total Current */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.c_backlog'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE6') ||
'
/* Percent of Total Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('oset.c_backlog'
                                                             ,'oset.c_backlog_total'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('oset.p_backlog'
                                                              ,'oset.p_backlog_total'
                                                              ,null)
                               ,'BIV_MEASURE8'
                               ,'N') ||
'
/* Escalated Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated,0)'
                             ,'oset.p_backlog'
                             ,'BIV_MEASURE9') ||
'
/* Escalated Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated,0)'
                             ,'oset.c_backlog'
                             ,'BIV_MEASURE10') ||
'
/* Escalated Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated,0)'
                                                             ,'oset.c_backlog'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated,0)'
                                                             ,'oset.p_backlog'
                                                             ,null)
                               ,'BIV_MEASURE12'
                               ,'N') ||
'
/* Unowned Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned,0)'
                             ,'oset.p_backlog'
                             ,'BIV_MEASURE13') ||
'
/* Unowned Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned,0)'
                             ,'oset.c_backlog'
                             ,'BIV_MEASURE14') ||
'
/* Unowned Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned,0)'
                                                             ,'oset.c_backlog'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned,0)'
                                                             ,'oset.p_backlog'
                                                             ,null)
                               ,'BIV_MEASURE16'
                               ,'N') ||
'
/* GT Backlog Current */
, nvl(oset.c_backlog_total,0) BIV_MEASURE17
/* GT Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog_total'
                               ,'oset.p_backlog_total'
                               ,'BIV_MEASURE18') ||
'
/* GT Percent of Total Current */
, 100 BIV_MEASURE19
/* GT Escalated Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated_total,0)'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE21') ||
'
/* GT Escalated Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated_total,0)'
                                                             ,'oset.c_backlog_total'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated_total,0)'
                                                             ,'oset.p_backlog_total'
                                                             ,null)
                               ,'BIV_MEASURE22'
                               ,'N') ||
'
/* GT Unowned Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned_total,0)'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE23') ||
'
/* GT Unowned Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned_total,0)'
                                                             ,'oset.c_backlog_total'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned_total,0)'
                                                             ,'oset.p_backlog_total'
                                                             ,null)
                               ,'BIV_MEASURE24'
                               ,'N') ||
'
/* KPI GT Backlog Prior */
, nvl(oset.p_backlog_total,0) BIV_MEASURE31
/* KPI GT Escalated Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated_total,0)'
                             ,'oset.p_backlog_total'
                             ,'BIV_MEASURE32') ||
'
/* KPI GT Unowned Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned_total,0)'
                             ,'oset.p_backlog_total'
                             ,'BIV_MEASURE33') ||
'
, ' ||
biv_dbi_tmpl_util.get_category_drill_down( l_view_by, g_backlog_dbn_rep_func ) ||
'
, ' ||
drill_across('Y','BACKLOG', 'oset.c_backlog', 'BIV_ATTRIBUTE6',l_view_by) ||
'
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 3
        , p_filter_where         => '(c_backlog > 0 or p_backlog > 0)'
        , p_generate_viewby      => 'Y'
        );

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;
--  unset_last_collection;


  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => biv_dbi_tmpl_util.get_balance_fact(l_mv)
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

end get_dbn_tbl_sql;


procedure get_unr_dbn_tbl_sql
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

  l_where_clause := l_where_clause || 'and resolved_flag = ''N''';

  IF(l_xtd IN ('DAY','WTD','MTD','QTD','YTD') )
  THEN
     l_to_date_type := 'YTD';
--     set_last_collection;
  ELSE
     l_to_date_type := 'BAL';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'backlog_count'
                             , p_alias_name => 'backlog'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'escalated_count'
                             , p_alias_name => 'escalated'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'unowned_count'
                             , p_alias_name => 'unowned'
                             , p_to_date_type => l_to_date_type
                             );

  l_stmt := 'select
  ' ||
    biv_dbi_tmpl_util.get_view_by_col_name(l_view_by) || ' VIEWBY ' ||
    ', oset.' || l_view_by_col_name || ' VIEWBYID ' ||
'
' ||
    case
      when l_view_by = biv_dbi_tmpl_util.g_PRODUCT then
        ', v.description'
      else
        ', null'
    end
    || ' BIV_ATTRIBUTE5
/* Backlog Prior */
, nvl(oset.p_backlog,0) BIV_MEASURE1
/* Backlog Current */
, nvl(oset.c_backlog,0) BIV_MEASURE2
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog'
                               ,'oset.p_backlog'
                               ,'BIV_MEASURE4') ||
'
/* Percent of Total Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.p_backlog'
                             ,'oset.p_backlog_total'
                             ,'BIV_MEASURE5') ||
'
/* Percent of Total Current */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.c_backlog'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE6') ||
'
/* Percent of Total Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('oset.c_backlog'
                                                             ,'oset.c_backlog_total'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('oset.p_backlog'
                                                              ,'oset.p_backlog_total'
                                                              ,null)
                               ,'BIV_MEASURE8'
                               ,'N') ||
'
/* Escalated Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated,0)'
                             ,'oset.p_backlog'
                             ,'BIV_MEASURE9') ||
'
/* Escalated Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated,0)'
                             ,'oset.c_backlog'
                             ,'BIV_MEASURE10') ||
'
/* Escalated Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated,0)'
                                                             ,'oset.c_backlog'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated,0)'
                                                             ,'oset.p_backlog'
                                                             ,null)
                               ,'BIV_MEASURE12'
                               ,'N') ||
'
/* Unowned Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned,0)'
                             ,'oset.p_backlog'
                             ,'BIV_MEASURE13') ||
'
/* Unowned Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned,0)'
                             ,'oset.c_backlog'
                             ,'BIV_MEASURE14') ||
'
/* Unowned Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned,0)'
                                                             ,'oset.c_backlog'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned,0)'
                                                             ,'oset.p_backlog'
                                                             ,null)
                               ,'BIV_MEASURE16'
                               ,'N') ||
'
/* GT Backlog Current */
, nvl(oset.c_backlog_total,0) BIV_MEASURE17
/* GT Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_backlog_total'
                               ,'oset.p_backlog_total'
                               ,'BIV_MEASURE18') ||
'
/* GT Percent of Total Current */
, 100 BIV_MEASURE19
/* GT Escalated Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated_total,0)'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE21') ||
'
/* GT Escalated Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_escalated_total,0)'
                                                             ,'oset.c_backlog_total'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated_total,0)'
                                                             ,'oset.p_backlog_total'
                                                             ,null)
                               ,'BIV_MEASURE22'
                               ,'N') ||
'
/* GT Unowned Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned_total,0)'
                             ,'oset.c_backlog_total'
                             ,'BIV_MEASURE23') ||
'
/* GT Unowned Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(oset.c_unowned_total,0)'
                                                             ,'oset.c_backlog_total'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned_total,0)'
                                                             ,'oset.p_backlog_total'
                                                             ,null)
                               ,'BIV_MEASURE24'
                               ,'N') ||
'
/* KPI GT Backlog Prior */
, nvl(oset.p_backlog_total,0) BIV_MEASURE31
/* KPI GT Escalated Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_escalated_total,0)'
                             ,'oset.p_backlog_total'
                             ,'BIV_MEASURE32') ||
'
/* KPI GT Unowned Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(oset.p_unowned_total,0)'
                             ,'oset.p_backlog_total'
                             ,'BIV_MEASURE33') ||
'
, ' ||
biv_dbi_tmpl_util.get_category_drill_down( l_view_by, g_backlog_dbn_rep_func||'@BIV_RES_STATUS=N' ) ||
'
, ' ||
unr_drill_across('Y','BACKLOG', 'oset.c_backlog', 'BIV_ATTRIBUTE6',l_view_by) ||
'
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 3
        , p_filter_where         => '(c_backlog > 0 or p_backlog > 0)'
        , p_generate_viewby      => 'Y'
        );

  biv_dbi_tmpl_util.override_order_by(l_view_by, p_param, l_stmt);

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.dump_parameters(p_param);

  x_custom_sql      := l_stmt;
--  unset_last_collection;


  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => biv_dbi_tmpl_util.get_balance_fact(l_mv)
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

end get_unr_dbn_tbl_sql;

procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
, p_distribution    in varchar2 := 'N'
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


  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'backlog_count'
                             , p_alias_name => 'backlog'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'escalated_count'
                             , p_alias_name => 'escalated'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'unowned_count'
                             , p_alias_name => 'unowned'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  l_stmt := 'select
  cal.name VIEWBY
/* End date of the period */
, cal.end_date VIEWBYID
/* Backlog Prior */
, nvl(iset.p_backlog,0) BIV_MEASURE1
/* Backlog Current */
, nvl(iset.c_backlog,0) BIV_MEASURE2
/* Backlog Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_backlog'
                                   ,'iset.p_backlog'
                                   ,'BIV_MEASURE4') ||
   case
     when p_distribution = 'N' then
'
/* Escalated Prior */
, nvl(iset.p_escalated,0) BIV_MEASURE9
/* Escalated Current */
, nvl(iset.c_escalated,0) BIV_MEASURE10
/* Escalated Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_escalated'
                               ,'iset.p_escalated'
                               ,'BIV_MEASURE12') ||
'
/* Unowned Prior */
, nvl(iset.p_unowned,0) BIV_MEASURE13
/* Unowned Current */
, nvl(iset.c_unowned,0) BIV_MEASURE14
/* Unowned Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_unowned'
                               ,'iset.p_unowned'
                               ,'BIV_MEASURE16')
     else
'
/* Escalated Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(iset.p_escalated,0)'
                             ,'iset.p_backlog'
                             ,'BIV_MEASURE9') ||
'
/* Escalated Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(iset.c_escalated,0)'
                             ,'iset.c_backlog'
                             ,'BIV_MEASURE10') ||
'
/* Escalated Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(iset.c_escalated,0)'
                                                             ,'iset.c_backlog'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(iset.p_escalated,0)'
                                                             ,'iset.p_backlog'
                                                             ,null)
                               ,'BIV_MEASURE12'
                               ,'N') ||
'
/* Unowned Percent Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(iset.p_unowned,0)'
                             ,'iset.p_backlog'
                             ,'BIV_MEASURE13') ||
'
/* Unowned Percent Current */
, ' ||
biv_dbi_tmpl_util.rate_column('nvl(iset.c_unowned,0)'
                             ,'iset.c_backlog'
                             ,'BIV_MEASURE14') ||
'
/* Unowned Percent Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('nvl(iset.c_unowned,0)'
                                                             ,'iset.c_backlog'
                                                             ,null)
                               ,biv_dbi_tmpl_util.rate_column('nvl(iset.p_unowned,0)'
                                                             ,'iset.p_backlog'
                                                             ,null)
                               ,'BIV_MEASURE16'
                               ,'N')
   end;

IF (l_xtd = 'WTD')
  THEN
  l_stmt := l_stmt ||','||'''AS_OF_DATE=''||to_char(cal.end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_BAK_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL1' || ',NULL BIV_DYNAMIC_URL2';
ELSIF (l_xtd = 'RLW') THEN
  l_stmt := l_stmt ||',NULL BIV_DYNAMIC_URL1 ,'||'''AS_OF_DATE=''||to_char(cal.end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_BAK_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL2';
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
  -- l_stmt := l_stmt || biv_dbi_tmpl_util.get_trace_file_name;

  x_custom_sql      := l_stmt;
--  unset_last_collection;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  );

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => biv_dbi_tmpl_util.get_balance_fact(l_mv)
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

  l_stmt := biv_dbi_tmpl_util.dump_binds(l_custom_output);

end get_trd_sql;

procedure get_dbn_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is
begin
  get_trd_sql
  ( p_param         => p_param
  , x_custom_sql    => x_custom_sql
  , x_custom_output => x_custom_output
  , p_distribution  => 'Y'
  );
end get_dbn_trd_sql;

end biv_dbi_bak_pkg;

/
