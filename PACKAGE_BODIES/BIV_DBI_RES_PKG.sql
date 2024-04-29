--------------------------------------------------------
--  DDL for Package Body BIV_DBI_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_RES_PKG" 
/* $Header: bivsrvrresb.pls 120.0 2005/05/25 10:54:09 appldev noship $ */
as

  g_closure_rep_func         varchar2(50) := 'BIV_DBI_RES_TBL_REP';
  g_closure_dbn_rep_func     varchar2(50) := 'BIV_DBI_RES_DBN_TBL_REP';

  g_closed_detail_rep_func   varchar2(50) := 'BIV_DBI_RES_DTL_REP';

procedure get_tbl_sql
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

  l_bucket_rec       bis_bucket_pub.bis_bucket_rec_type;

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
  , p_report_type      => 'RESOLVED'
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
  ELSE
     l_to_date_type := 'RLX';
  END IF;


  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'resolution_count'
                             , p_alias_name => 'closed'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_time_to_resolution'
                             , p_alias_name => 'time_to_close'
                             , p_to_date_type => l_to_date_type
                             );

  biv_dbi_tmpl_util.add_bucket_inner_query
  ( p_short_name   => 'BIV_DBI_RESOLUTION_CYCLE_TIME'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'time_to_resolution'
  , p_alias_name   => 'close_bucket'
  , p_grand_total  => 'Y'
  , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
  , p_to_date_type => l_to_date_type
  , x_bucket_rec   => l_bucket_rec
  );

  l_stmt := 'select
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
/* Closed Prior */
, nvl(oset.p_closed,0) BIV_MEASURE1
/* Closed Current */
, nvl(oset.c_closed,0) BIV_MEASURE2
/* Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_closed','oset.p_closed','BIV_MEASURE4') ||
'
/* Average Time To Close Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.p_time_to_close','oset.p_closed','BIV_MEASURE5','N') ||
'
/* Average Time To Close Current */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.c_time_to_close','oset.c_closed','BIV_MEASURE6','N') ||
'
/* Average Time To Close Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('oset.c_time_to_close','oset.c_closed',null,'N')
                               ,biv_dbi_tmpl_util.rate_column('oset.p_time_to_close','oset.p_closed',null,'N')
                               ,'BIV_MEASURE8'
                               ,'N') ||
'
/* Time to Close Buckets */
' || biv_dbi_tmpl_util.get_bucket_outer_query
     ( p_bucket_rec       => l_bucket_rec
     , p_column_name_base => 'oset.c_close_bucket'
     , p_alias_base       => 'BIV_MEASURE10'
     , p_total_flag       => 'N'
     , p_backlog_col      => case
                               when p_distribution = 'Y' then 'oset.c_closed'
                             end
     ) ||
'
/* GT Closed Current */
, nvl(oset.c_closed_total,0) BIV_MEASURE11
/* GT Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('oset.c_closed_total','oset.p_closed_total','BIV_MEASURE12') ||
'
/* GT Average Time To Close Current */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.c_time_to_close_total','oset.c_closed_total','BIV_MEASURE13','N') ||
'
/* GT Average Time To Close Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('oset.c_time_to_close_total','oset.c_closed_total',null,'N')
                               ,biv_dbi_tmpl_util.rate_column('oset.p_time_to_close_total','oset.p_closed_total',null,'N')
                               ,'BIV_MEASURE14'
                               ,'N') ||
'
/* GT Time to Close Buckets*/
' || biv_dbi_tmpl_util.get_bucket_outer_query
     ( p_bucket_rec       => l_bucket_rec
     , p_column_name_base => 'oset.c_close_bucket'
     , p_alias_base       => 'BIV_MEASURE15'
     , p_total_flag       => 'Y'
     , p_backlog_col      => case
                               when p_distribution = 'Y' then 'oset.c_closed'
                             end
     ) ||
'
/* KPI GT Average Time To Close Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('oset.p_time_to_close_total','oset.p_closed_total','BIV_MEASURE16','N') ||
'
, ' ||
biv_dbi_tmpl_util.get_category_drill_down( l_view_by
                                         , case
                                             when p_distribution = 'Y' then g_closure_dbn_rep_func
                                             else g_closure_rep_func
                                           end ) ||
  biv_dbi_tmpl_util.drill_detail( g_closed_detail_rep_func
                                , 0
                                , null
                                , 'BIV_ATTRIBUTE6') ||
  case
    when p_distribution = 'N' then
      biv_dbi_tmpl_util.bucket_detail_drill( g_closed_detail_rep_func
                                           , l_bucket_rec
                                           , 'BIV_ATTRIBUTE7' )
    else
      null
    end ||
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
        , P_FILTER_WHERE         => '(c_closed > 0 or p_closed > 0)'
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

procedure get_dbn_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is
begin
  get_tbl_sql
  ( p_param         => p_param
  , x_custom_sql    => x_custom_sql
  , x_custom_output => x_custom_output
  , p_distribution  => 'Y'
  );
end get_dbn_tbl_sql;


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

  l_bucket_rec       bis_bucket_pub.bis_bucket_rec_type;

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
  , p_report_type      => 'RESOLVED'
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
  ELSE
     l_to_date_type := 'RLX';
  END IF;

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'resolution_count'
                             , p_alias_name => 'closed'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_time_to_resolution'
                             , p_alias_name => 'time_to_close'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  biv_dbi_tmpl_util.add_bucket_inner_query
  ( p_short_name   => 'BIV_DBI_RESOLUTION_CYCLE_TIME'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'time_to_resolution'
  , p_alias_name   => 'close_bucket'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
  , p_to_date_type => l_to_date_type
  , x_bucket_rec   => l_bucket_rec
  );

  l_stmt := 'select
  cal.name VIEWBY
/* End date of the period */
, cal.end_date VIEWBYID
/* Closed Prior */
, nvl(iset.p_closed,0) BIV_MEASURE1
/* Closed Current */
, nvl(iset.c_closed,0) BIV_MEASURE2
/* Closed Change */
, ' ||
biv_dbi_tmpl_util.change_column('iset.c_closed','iset.p_closed','BIV_MEASURE4') ||
'
/* Average Time To Close Prior */
, ' ||
biv_dbi_tmpl_util.rate_column('iset.p_time_to_close','iset.p_closed','BIV_MEASURE5','N') ||
'
/* Average Time To Close Current */
, ' ||
biv_dbi_tmpl_util.rate_column('iset.c_time_to_close','iset.c_closed','BIV_MEASURE6','N') ||
'
/* Average Time To Close Change */
, ' ||
biv_dbi_tmpl_util.change_column(biv_dbi_tmpl_util.rate_column('iset.c_time_to_close','iset.c_closed',null,'N')
                               ,biv_dbi_tmpl_util.rate_column('iset.p_time_to_close','iset.p_closed',null,'N')
                               ,'BIV_MEASURE8'
                               ,'N') ||
'
/* Time to Close Buckets */
' || biv_dbi_tmpl_util.get_bucket_outer_query
     ( p_bucket_rec       => l_bucket_rec
     , p_column_name_base => 'iset.c_close_bucket'
     , p_alias_base       => 'BIV_MEASURE10'
     , p_total_flag       => 'N'
     , p_backlog_col      => case
                               when p_distribution = 'Y' then 'iset.c_closed'
                             end
     );

IF (l_xtd = 'WTD')
  THEN
  l_stmt := l_stmt ||','||'''AS_OF_DATE=''||to_char(cal.end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_RES_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL1' || ',NULL BIV_DYNAMIC_URL2';
ELSIF (l_xtd = 'RLW') THEN
  l_stmt := l_stmt ||',NULL BIV_DYNAMIC_URL1 ,'||'''AS_OF_DATE=''||to_char(cal.end_date,''dd/mm/yyyy'')||''&pFunctionName=BIV_DBI_RES_TRD_REP&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' BIV_DYNAMIC_URL2';
  ELSE
  l_stmt:= l_stmt || ', NULL BIV_DYNAMIC_URL1, NULL BIV_DYNAMIC_URL2';
  END IF;

l_stmt := l_stmt || '

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

procedure get_detail_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)as

  l_where_clause varchar2(10000);
  l_mv           varchar2(10000);
  l_join_from    varchar2(10000);
  l_join_where   varchar2(10000);
  l_order_by     varchar2(100);
  l_drill_url    varchar2(500);
  l_sr_id        varchar2(100);

  l_join_tbl      poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_custom_output bis_query_attributes_tbl;
  l_as_of_date        date;

  l_xtd              varchar2(200);

begin

  biv_dbi_tmpl_util.get_detail_page_function( l_drill_url, l_sr_id );

  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  biv_dbi_tmpl_util.process_parameters
  ( p_param            => p_param
  , p_report_type      => 'RESOLVED_DETAIL'
  , x_where_clause     => l_where_clause
  , x_mv               => l_mv
  , x_xtd              => l_xtd
  , x_join_from        => l_join_from
  , x_join_where       => l_join_where
  , x_join_tbl         => l_join_tbl
  , x_as_of_date       => l_as_of_date
  );

  if l_where_clause like '%<replace this>%' then
    l_where_clause := replace(l_where_clause,'fact.<replace this> in (&'||biv_dbi_tmpl_util.g_AGING||')'
                                            ,'(&RANGE_LOW is null or fact.age >= &RANGE_LOW) and (&RANGE_HIGH is null or fact.age < &RANGE_HIGH)');

    biv_dbi_tmpl_util.bind_low_high
    ( p_param
    , 'BIV_DBI_RESOLUTION_CYCLE_TIME'
    , '&RANGE_LOW'
    , '&RANGE_HIGH'
    , l_custom_output );

  end if;

  l_order_by := biv_dbi_tmpl_util.get_order_by(p_param);
  if l_order_by like '% DESC%' then
    if l_order_by like '%BIV_MEASURE11%' then
      l_order_by := 'fact.resolved_date desc, fact.incident_id desc';
    else
      l_order_by := 'fact.age desc, fact.incident_id desc';
    end if;
  else
    if l_order_by like '%BIV_MEASURE11%' then
      l_order_by := 'fact.resolved_date asc, fact.incident_id asc';
    else
      l_order_by := 'fact.age asc, fact.incident_id asc';
    end if;
  end if;

x_custom_sql := '
select
  i.incident_number biv_measure1
, rt.value biv_measure2 -- request_type
, pr.value biv_measure3 -- product
, pr.description biv_measure4
, cu.value biv_measure5 -- customer
, sv.value biv_measure6 -- severity
, ag.value biv_measure7 -- assignment_group
, re.value biv_measure8 -- resolution
, ch.value biv_measure9 -- channel
, fact.age biv_measure10
, fnd_date.date_to_displaydate(fact.resolved_date) biv_measure11 ' ||
  case
    when l_drill_url is not null then
'
, ''pFunctionName=' || l_drill_url || '&' || l_sr_id || '=''||fact.incident_id biv_attribute1'
    else
'
, null biv_attribute1'
  end ||
'
from
  ( select
      fact.*
    , rank() over(order by ' || l_order_by || ') -1 rnk
    from
      ' || l_mv || ' fact
    where
        fact.resolved_date between &BIS_CURRENT_EFFECTIVE_START_DATE and (&BIS_CURRENT_EFFECTIVE_END_DATE + 0.99999)
' || l_where_clause || '
  ) fact
' || l_join_from || '
, cs_incidents_all_b i
where
    1=1
and fact.incident_id = i.incident_id' || l_join_where || '
and (fact.rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
&ORDER_BY_CLAUSE
'
--|| biv_dbi_tmpl_util.dump_parameters(p_param)
;

  if l_custom_output is null then
    l_custom_output := bis_query_attributes_tbl();
  end if;

  x_custom_output := l_custom_output;

end get_detail_sql;

end biv_dbi_res_pkg;

/
