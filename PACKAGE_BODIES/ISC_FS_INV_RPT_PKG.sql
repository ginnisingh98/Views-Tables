--------------------------------------------------------
--  DDL for Package Body ISC_FS_INV_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_INV_RPT_PKG" AS
/*$Header: iscfsinvrptb.pls 120.3 2006/05/08 14:42:36 kreardon noship $ */
function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
)
return varchar2
is
  l_comparison_type  varchar2(20);
  l_period_type    varchar2(20);
begin

  l_comparison_type:=isc_fs_rpt_util_pkg.get_parameter_value(p_param, 'TIME_COMPARISON_TYPE' ); /* YEARLY or SEQUENTIAL' */
  l_period_type:=isc_fs_rpt_util_pkg.get_parameter_value(p_param, 'PERIOD_TYPE');

  if p_report_type = 'INV_VALUE_1' then

      isc_fs_rpt_util_pkg.bind_group_id
        ( p_dim_bmap
         , p_custom_output
         , isc_fs_rpt_util_pkg.G_INV_CATEGORY
         , isc_fs_rpt_util_pkg.G_ITEM_ORG
        );

        return '(
      select f.record_type,f.parent_district_id
       ,decode(f.record_type, ''GROUP'', f.district_id, f.resource_id ) district_id
       ,district_id_c,f.inv_category_id,f.item_org_id,f.time_id,f.period_type_id,f.onhand_value_g  Inv_usg_g,f.onhand_value_sg Inv_usg_sg
      from isc_fs_015_mv f where f.grp_id = &ISC_GRP_ID)';

  elsif p_report_type = 'INV_VALUE_2' then

      isc_fs_rpt_util_pkg.bind_group_id
        ( p_dim_bmap
         , p_custom_output
         , isc_fs_rpt_util_pkg.G_INV_CATEGORY
         , isc_fs_rpt_util_pkg.G_ITEM_ORG
        );


      return '(
      select
        f.record_type,f.parent_district_id
       ,decode(f.record_type, ''GROUP'', f.district_id, f.resource_id ) district_id
       ,district_id_c
       ,f.inv_category_id,f.item_org_id,f.time_id,f.period_type_id,f.uonhand_value_g
       ,f.uonhand_value_sg,f.donhand_value_g,f.donhand_value_sg,nvl(f.uonhand_value_g,0) + nvl(f.donhand_value_g,0) totalonhand_value_g
       ,nvl(f.uonhand_value_sg,0) + nvl(f.donhand_value_sg,0) totalonhand_value_sg
      from isc_fs_016_mv f where f.grp_id = &ISC_GRP_ID)';

  elsif p_report_type = 'FS_CALENDAR'
    and l_comparison_type = 'YEARLY'
   and l_period_type in ('FII_TIME_ENT_YEAR','FII_TIME_ENT_QTR','FII_TIME_ENT_PERIOD','FII_TIME_WEEK') /* Only used in XTD */
   then

      return '(select decode(grouping_id(c.ent_year_id,c.ent_qtr_id,c.ent_period_id,c.week_id,c.report_date_julian),0,c.report_date_julian,1,c.week_id,3,c.ent_period_id,7,c.ent_qtr_id,15,c.ent_year_id) time_id
      ,decode(grouping_id(c.ent_year_id,c.ent_qtr_id,c.ent_period_id,c.week_id,c.report_date_julian),0,1,1,16,3,32,7,64,15,128) period_type_id
      ,sum(CASE WHEN (t.start_date <= &ISC_TO_DATE and t.end_date >= &ISC_TO_DATE) and t.flag = ''C'' THEN &ISC_TO_DATE - t.start_date + 1
             WHEN (t.start_date <= &BIS_PREVIOUS_ASOF_DATE and t.end_date >= &BIS_PREVIOUS_ASOF_DATE) and t.flag=''C'' THEN &BIS_PREVIOUS_ASOF_DATE-t.start_date+1
            WHEN (t.flag=''P'') THEN t.end_date-&BIS_PREVIOUS_ASOF_DATE ' || /* Do not need +1 because start date row "C" already has it */
             'ELSE t.end_date-t.start_date+1 END) period_days' ||
      ' from fii_time_day c
      ,(select ' || /* need this row to complete current number of days of the period before current period in the trend */
       'tt.end_date start_date, tt.end_date end_date, ''P'' flag
       from PERIOD_TABLE tt
       where tt.start_date <= &BIS_PREVIOUS_ASOF_DATE and tt.end_date >= &BIS_PREVIOUS_ASOF_DATE
       union all
       select start_date,end_date,''C'' flag from PERIOD_TABLE ttt) t
      where  c.report_date = t.start_date and t.start_date <= &ISC_TO_DATE group by t.start_date,c.ent_year_id,rollup(c.ent_qtr_id,c.ent_period_id,c.week_id,c.report_date_julian))';

  elsif p_report_type = 'FS_CALENDAR' /* When comparison is Sequential, the partial current period is compared to the complete prior period (Because of the line graph). */
    and l_comparison_type = 'SEQUENTIAL'
   and l_period_type in ('FII_TIME_ENT_YEAR','FII_TIME_ENT_QTR','FII_TIME_ENT_PERIOD','FII_TIME_WEEK') /* Only used in XTD */
   then

      return '(
      select
       decode(grouping_id(c.ent_year_id, c.ent_qtr_id, c.ent_period_id, c.week_id, c.report_date_julian), 0, c.report_date_julian, 1, c.week_id, 3, c.ent_period_id, 7, c.ent_qtr_id, 15, c.ent_year_id) time_id
      ,decode(grouping_id(c.ent_year_id, c.ent_qtr_id , c.ent_period_id, c.week_id, c.report_date_julian), 0, 1, 1, 16, 3, 32, 7, 64, 15, 128) period_type_id
      ,sum(CASE
             WHEN (t.start_date <= &ISC_TO_DATE and t.end_date >= &ISC_TO_DATE) THEN
               &ISC_TO_DATE - t.start_date + 1
             ELSE t.end_date - t.start_date + 1
           END) period_days
      from
        fii_time_day c
        ,PERIOD_TABLE t
      where
        c.report_date = t.start_date and t.start_date <= &ISC_TO_DATE
      group by
       t.start_date
      , c.ent_year_id
      ,rollup(c.ent_qtr_id, c.ent_period_id, c.week_id, c.report_date_julian))';

  else -- should not happen!!!
    return '';

  end if;

end get_fact_mv_name;


procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_dimension_tbl    isc_fs_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(400); -- needed to be increased from 200
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_col_tbl1         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl2         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_mv               VARCHAR2 (10000);
  l_mv_tbl          poa_dbi_util_pkg.poa_dbi_mv_tbl;
  l_view_by          varchar2(200);
  l_stmt             varchar2(32700);
  l_stmt1            varchar2(5000);
  l_stmt2            varchar2(5000);
  l_to_date        varchar2(20);
  l_to_date_type     varchar2(20);
  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  /* Specifying the report parameters, The Y means it is a filter besides a view by. */
  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_INV_CATEGORY, 'Y'
  , isc_fs_rpt_util_pkg.G_ITEM_ORG, 'Y'
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  );

  isc_fs_rpt_util_pkg.check_district_filter
  ( p_param
  , l_dim_filter_map
  );

  isc_fs_rpt_util_pkg.process_parameters
  ( p_param            => p_param
  , p_dimension_tbl    => l_dimension_tbl
  , p_dim_filter_map   => l_dim_filter_map
  , p_trend            => 'N'
  , p_custom_output    => l_custom_output
  , x_cur_suffix       => l_curr_suffix
  , x_where_clause     => l_where_clause
  , x_viewby_select    => l_viewby_select
  , x_join_tbl         => l_join_tbl
  , x_dim_bmap         => l_dim_bmap
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  );

  l_view_by := isc_fs_rpt_util_pkg.get_parameter_value
               ( p_param
               , 'VIEW_BY'
               );

  /* To support Day and rolling */
  if l_xtd in ('DAY','WTD','MTD','QTD','YTD') then
    l_to_date_type := 'XTD';
  else
    l_to_date_type := 'RLX';
  end if;

  /* The to date is the least between the as of date and last collection date */
  if fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('ISC_FS_016_MV')) <
  to_date(isc_fs_rpt_util_pkg.get_parameter_value( p_param, 'AS_OF_DATE'),'DD-MM-YYYY') then
    l_to_date := to_char(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('ISC_FS_016_MV')),'DD/MM/YYYY');
  else
    l_to_date := to_char(to_date(isc_fs_rpt_util_pkg.get_parameter_value( p_param, 'AS_OF_DATE'),'DD-MM-YYYY') ,'DD/MM/YYYY');
  end if;

  l_col_tbl1 := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl2 := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

  poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1
                       , p_col_name     => 'Inv_usg_' || l_curr_suffix
                       , p_alias_name   => 'Inv_usg'
                       , p_grand_total  => 'Y'
                       , p_prior_code   => poa_dbi_util_pkg.both_priors
                       , p_to_date_type => l_to_date_type
                       );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl2
                             , p_col_name     => 'uonhand_value_' || l_curr_suffix
                             , p_alias_name   => 'uonhand_value'
                             , p_grand_total  => 'Y'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => 'XTD'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl2
                             , p_col_name     => 'donhand_value_' || l_curr_suffix
                             , p_alias_name   => 'donhand_value'
                             , p_grand_total  => 'Y'
                             , p_prior_code   => poa_dbi_util_pkg.no_priors
                             , p_to_date_type => 'XTD'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl2
                             , p_col_name     => 'totalonhand_value_' || l_curr_suffix
                             , p_alias_name   => 'totalonhand_value'
                             , p_grand_total  => 'Y'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => 'XTD'
                             );

  l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := 'MV_PLACEHOLDER1';
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';

  l_mv_tbl.extend;
  l_mv_tbl(2).mv_name := 'MV_PLACEHOLDER2';
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := l_where_clause;
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';

  l_stmt := poa_dbi_template_pkg.union_all_status_sql
                   (p_mv       => l_mv_tbl
                   ,p_join_tables     => l_join_tbl
                   ,p_use_windowing   => 'Y'
                   ,p_paren_count     => 3
                   ,p_filter_where    => '(ISC_MEASURE_1<> 0 or ISC_MEASURE_3<> 0 or ISC_MEASURE_5<> 0 or
                   ISC_MEASURE_6<> 0 or ISC_MEASURE_7<> 0 or ISC_MEASURE_9<> 0 or ISC_MEASURE_11<> 0
                   or ISC_MEASURE_12<> 0 or ISC_MEASURE_13<> 0 or ISC_MEASURE_26<> 0
                   or ISC_MEASURE_27<> 0) ) iset'
                   ,p_generate_viewby => 'Y'
                   );

  l_mv := get_fact_mv_name
          ( 'INV_VALUE_1'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER1', l_mv );

  l_mv := get_fact_mv_name
          ( 'INV_VALUE_2'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER2', l_mv );

  l_stmt1 := SUBSTR (l_stmt,1,INSTR(l_stmt,'UNION')-1);
  l_stmt2 := SUBSTR (l_stmt,INSTR(l_stmt,'UNION'),LENGTH(l_stmt));

  /* Replacing second part of the UNION all's NESTED PATTERN bind variable for the hard coded ITD patttern: 1143 */
  l_stmt2 := replace( l_stmt2, '&BIS_NESTED_PATTERN', 1143 );

  l_stmt := l_stmt1 || l_stmt2;

  l_stmt := 'select
  ' || l_viewby_select || '
, ' ||
   case l_view_by
      when isc_fs_rpt_util_pkg.G_ITEM_ORG
      then 'v12.description'
      else 'null'
   end ||'
 ISC_ATTRIBUTE_5
, ISC_MEASURE_1
, ISC_MEASURE_26 ISC_MEASURE_2
, ISC_MEASURE_7
, ISC_MEASURE_27 ISC_MEASURE_8
, ISC_MEASURE_11
, ISC_MEASURE_30
, ISC_MEASURE_31
, ISC_MEASURE_26
, ISC_MEASURE_3
, ISC_MEASURE_5
, ISC_MEASURE_6
, ISC_MEASURE_27
, ISC_MEASURE_9
, ISC_MEASURE_12
, ISC_MEASURE_13
, ISC_MEASURE_15
, ISC_MEASURE_16
, ISC_MEASURE_17
, ISC_MEASURE_18
, ISC_MEASURE_19
, ISC_MEASURE_20
, ISC_MEASURE_21
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24
, ISC_MEASURE_25
, ISC_MEASURE_16 ISC_MEASURE_39
, ISC_MEASURE_21 ISC_MEASURE_40
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , 'ISC_FS_INV_DOH_TBL_REP'
       , 'ISC_ATTRIBUTE_4' ) || '
from (
select
  row_number() over(&ORDER_BY_CLAUSE nulls last, '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
, iset.*
from ( select * from (
select ' || isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || '
, nvl(p_Inv_usg,0)  ISC_MEASURE_1
, nvl(c_Inv_usg,0) ISC_MEASURE_26
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_Inv_usg'
       , 'p_Inv_usg'
       , 'ISC_MEASURE_3' ) || '
, nvl(c_uonhand_value,0)  ISC_MEASURE_5
, nvl(c_donhand_value,0) ISC_MEASURE_6
, nvl(p_totalonhand_value,0) ISC_MEASURE_7
, nvl(c_totalonhand_value,0) ISC_MEASURE_27
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_totalonhand_value'
       , 'p_totalonhand_value'
       , 'ISC_MEASURE_9' ) || '
, p_uonhand_value/(decode(p_Inv_usg, 0, null, decode(&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1,0,null,p_Inv_usg/(&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1)))) ISC_MEASURE_11
, case when &BIS_PREVIOUS_ASOF_DATE <= &ISC_TO_DATE then (case when (&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) end)
else (case when (&ISC_TO_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) end) end ISC_MEASURE_30
, case when (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) < 0 then 0
  else &ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1 end ISC_MEASURE_31
, c_uonhand_value*(case when (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) end)/(decode(c_Inv_usg, 0, null, c_Inv_usg)) ISC_MEASURE_12
, c_uonhand_value*(case when (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) end)/(decode(c_Inv_usg, 0, null, c_Inv_usg)) -
p_uonhand_value*(&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1)/(decode(p_Inv_usg, 0, null, p_Inv_usg)) ISC_MEASURE_13
, nvl(p_Inv_usg_total,0) ISC_MEASURE_15
, nvl(c_Inv_usg_total,0) ISC_MEASURE_16
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_Inv_usg_total'
       , 'p_Inv_usg_total'
       , 'ISC_MEASURE_17' ) || '
, nvl(c_uonhand_value_total, 0) ISC_MEASURE_18
, nvl(c_donhand_value_total, 0) ISC_MEASURE_19
, nvl(p_totalonhand_value_total, 0) ISC_MEASURE_20
, nvl(c_totalonhand_value_total, 0) ISC_MEASURE_21
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_totalonhand_value_total'
       , 'p_totalonhand_value_total'
       , 'ISC_MEASURE_22' ) || '
, p_uonhand_value_total*(case when &BIS_PREVIOUS_ASOF_DATE <= &ISC_TO_DATE then (case when (&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&BIS_PREVIOUS_ASOF_DATE -
&BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) end) else (case when (&ISC_TO_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) end)
end)/(decode(p_Inv_usg_total, 0, null, p_Inv_usg_total)) ISC_MEASURE_23
, c_uonhand_value_total*(case when (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) end)/(decode(c_Inv_usg_total, 0, null,c_Inv_usg_total)) ISC_MEASURE_24
, c_uonhand_value_total*(case when (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) end)/(decode(c_Inv_usg_total,
0, null,c_Inv_usg_total)) - p_uonhand_value_total*(case when &BIS_PREVIOUS_ASOF_DATE <= &ISC_TO_DATE then (case when (&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) < 0 then 0
else (&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) end)
else (case when (&ISC_TO_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) < 0 then 0 else (&ISC_TO_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) end) end)/(decode(p_Inv_usg_total, 0, null, p_Inv_usg_total)) ISC_MEASURE_25
from (' || l_stmt;


  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

  l_custom_rec.attribute_name := '&ISC_TO_DATE';
  l_custom_rec.attribute_value := l_to_date;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;

  x_custom_output.extend;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'N'
  );

  x_custom_sql      := l_stmt;

end get_tbl_sql;


function get_period_days(l_period_type varchar2, l_curr_prior varchar2) return varchar2
is
begin

  if l_curr_prior = 'P' and l_period_type like '%TD' then
     return 'p_period_days';
  elsif l_curr_prior = 'C' and l_period_type like '%TD' then
     return 'c_period_days';
  elsif (l_period_type like 'RL%' or l_period_type = 'DAY') and l_curr_prior = 'P' then

   /*  We do not support queries in the future (after the end date of the period where last collection date
   falls into): If the query returns periods above the end date of the period where
  the last collection date falls into, it will return 0 days. */
     if(l_period_type = 'RLY') then
      return '(CASE WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 365
                 END)';
     elsif(l_period_type = 'RLQ') then
      return '(CASE WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 90
                 END)';
     elsif(l_period_type = 'RLM') then
      return '(CASE WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 30
                 END)';
     elsif(l_period_type = 'RLW') then
      return '(CASE WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 7
                 END)';
     elsif(l_period_type = 'DAY') then
      return '1';
     end if;

  elsif (l_period_type like 'RL%' or l_period_type = 'DAY') and l_curr_prior = 'C' then
  /* In the case that the user queries the report on days after the last collection date:
  We need to substract the days after the last collection date to the end date of the period where
  the last collection date falls into. If the query returns periods above the end date of the period where
  the last collection date falls into, it should return 0 days.
  Note: ISC_TO_DATE is the least between last collection date and as of date */
     if(l_period_type = 'RLY') then
      return '(CASE WHEN &ISC_TO_DATE BETWEEN cal_start_date AND cal_end_date
                      THEN 365 - (cal_end_date - &ISC_TO_DATE)
                   WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 365
                 END)';
     elsif(l_period_type = 'RLQ') then
      return '(CASE WHEN &ISC_TO_DATE BETWEEN cal_start_date AND cal_end_date
                      THEN 90 - (cal_end_date - &ISC_TO_DATE)
                   WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 90
                 END)';
     elsif(l_period_type = 'RLM') then
      return '(CASE WHEN &ISC_TO_DATE BETWEEN cal_start_date AND cal_end_date
                      THEN 30 - (cal_end_date - &ISC_TO_DATE)
                   WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 30
                 END)';
     elsif(l_period_type = 'RLW') then
      return '(CASE WHEN &ISC_TO_DATE BETWEEN cal_start_date AND cal_end_date
                      THEN 7 - (cal_end_date - &ISC_TO_DATE)
                   WHEN cal_start_date > &ISC_TO_DATE THEN 0
                   ELSE 7
                 END)';
     elsif(l_period_type = 'DAY') then
      return '1';
     end if;

  end if;

end get_period_days;


procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_dimension_tbl    isc_fs_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(400); -- needed to be increased from 200
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_mv_tbl          poa_dbi_util_pkg.poa_dbi_mv_tbl;
  l_col_tbl1         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl2         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl3         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_stmt1            varchar2(15000);
  l_stmt2            varchar2(15000);
  l_to_date        varchar2(20);
  l_to_date_type     varchar2(20);
  l_rxtd        varchar2(3);
  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  /* Specifying the report parameters, The Y means it is a filter besides a view by. */
  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_INV_CATEGORY, 'Y'
  , isc_fs_rpt_util_pkg.G_ITEM_ORG, 'Y'
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  );

  isc_fs_rpt_util_pkg.check_district_filter
  ( p_param
  , l_dim_filter_map
  );

  isc_fs_rpt_util_pkg.process_parameters
  ( p_param            => p_param
  , p_dimension_tbl    => l_dimension_tbl
  , p_dim_filter_map   => l_dim_filter_map
  , p_trend            => 'Y'
  , p_custom_output    => l_custom_output
  , x_cur_suffix       => l_curr_suffix
  , x_where_clause     => l_where_clause
  , x_viewby_select    => l_viewby_select
  , x_join_tbl         => l_join_tbl
  , x_dim_bmap         => l_dim_bmap
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  );

  /* To support Day and rolling */
  if l_xtd in ('DAY','WTD','MTD','QTD','YTD') then
    l_to_date_type := 'XTD';
  else
    l_to_date_type := 'RLX';
  end if;

  /* The to date is the least between the as of date and last collection date */
  if trunc(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('ISC_FS_016_MV'))) <
  to_date(isc_fs_rpt_util_pkg.get_parameter_value( p_param, 'AS_OF_DATE'),'DD-MM-YYYY') then
    l_to_date := to_char(trunc(fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period('ISC_FS_016_MV'))),'DD/MM/YYYY');
  else
    l_to_date := to_char(to_date(isc_fs_rpt_util_pkg.get_parameter_value( p_param, 'AS_OF_DATE'),'DD-MM-YYYY') ,'DD/MM/YYYY');
  end if;

  l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

  if l_xtd like '%TD' then /* Do not need the first leg of the union alls if rolling or day */

     l_col_tbl1 := poa_dbi_util_pkg.poa_dbi_col_tbl();

     poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1
                          , p_col_name     => 'Period_days'
                          , p_alias_name   => 'Period_days'
                          , p_grand_total  => 'N'
                          , p_prior_code   => poa_dbi_util_pkg.both_priors
                          , p_to_date_type => l_to_date_type
                          );

     l_mv_tbl.extend;
     l_mv_tbl(l_mv_tbl.count).mv_name := 'MV_PLACEHOLDER1';
     l_mv_tbl(l_mv_tbl.count).mv_col := l_col_tbl1;
     l_mv_tbl(l_mv_tbl.count).mv_where := null;
     l_mv_tbl(l_mv_tbl.count).in_join_tbls := NULL;
     l_mv_tbl(l_mv_tbl.count).use_grp_id := 'N';
     l_mv_tbl(l_mv_tbl.count).mv_xtd := l_xtd;

     l_mv := get_fact_mv_name
             ( 'FS_CALENDAR'
             , p_param
             , l_dim_bmap
             , l_custom_output
             );

     l_mv := replace( l_mv, 'PERIOD_TABLE', poa_dbi_util_pkg.get_calendar_table(l_xtd));

  end if;

  l_col_tbl2 := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl3 := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl2
                       , p_col_name     => 'Inv_usg_' || l_curr_suffix
                       , p_alias_name   => 'Inv_usg'
                       , p_grand_total  => 'N'
                       , p_prior_code   => poa_dbi_util_pkg.both_priors
                       , p_to_date_type => l_to_date_type
                       );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl3
                             , p_col_name     => 'uonhand_value_' || l_curr_suffix
                             , p_alias_name   => 'uonhand_value'
                             , p_grand_total  => 'N'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type /* This affects only the select list of columns structure for getting current and prior values */
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl3
                             , p_col_name     => 'totalonhand_value_' || l_curr_suffix
                             , p_alias_name   => 'totalonhand_value'
                             , p_grand_total  => 'N'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type /* This affects only the select list of columns structure for getting current and prior values */
                             );

  l_mv_tbl.extend;
  l_mv_tbl(l_mv_tbl.count).mv_name := 'MV_PLACEHOLDER2';
  l_mv_tbl(l_mv_tbl.count).mv_col := l_col_tbl2;
  l_mv_tbl(l_mv_tbl.count).mv_where := l_where_clause;
  l_mv_tbl(l_mv_tbl.count).in_join_tbls := NULL;
  l_mv_tbl(l_mv_tbl.count).use_grp_id := 'N';
  l_mv_tbl(l_mv_tbl.count).mv_xtd := l_xtd;

  l_mv_tbl.extend;
  l_mv_tbl(l_mv_tbl.count).mv_name := 'MV_PLACEHOLDER3';
  l_mv_tbl(l_mv_tbl.count).mv_col := l_col_tbl3;
  l_mv_tbl(l_mv_tbl.count).mv_where := l_where_clause;
  l_mv_tbl(l_mv_tbl.count).in_join_tbls := NULL;
  l_mv_tbl(l_mv_tbl.count).use_grp_id := 'N';
  l_mv_tbl(l_mv_tbl.count).mv_xtd := l_xtd; /* This determines what calendar tables to use and what FII struct table to use. For XTD is the FII_TIME_ENT tables and
  fii_time_rpt_struct_v. If rolling, it will use the Rolling calendars inline views for week, month, quarter, year and fii_time_structures */

  l_stmt := poa_dbi_template_pkg.union_all_trend_sql(
               p_mv         => l_mv_tbl,
               p_comparison_type   => l_comparison_type,
               p_filter_where     => NULL
               );

  if l_xtd like '%TD' then /* The query does not have the first leg of the union alls if rolling or day */
    l_stmt := replace( l_stmt, 'MV_PLACEHOLDER1', l_mv );
  end if;

  l_mv := get_fact_mv_name
          ( 'INV_VALUE_1'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER2', l_mv );

  l_mv := get_fact_mv_name
          ( 'INV_VALUE_2'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER3', l_mv );

  if l_xtd like '%TD' then
     l_stmt1 := SUBSTR (l_stmt, 1, INSTR(l_stmt,'UNION',1,2) - 1); /* if XTD there are 2 unions */
     l_stmt2 := SUBSTR (l_stmt, INSTR(l_stmt,'UNION',1,2), LENGTH(l_stmt));

     /* Replacing third part of the UNION all's NESTED PATTERN bind variable for the hard coded ITD patttern for fii_time_rpt_struct_v: 1143 */
     l_stmt2 := replace( l_stmt2, '&BIS_NESTED_PATTERN', '1143');
  elsif l_xtd like 'RL%'  /* If rolling */ then
     l_stmt1 := SUBSTR (l_stmt, 1, INSTR(l_stmt,'UNION',1,1) - 1); /* if rolling there is only 1 union */
     l_stmt2 := SUBSTR (l_stmt, INSTR(l_stmt,'UNION',1,1), LENGTH(l_stmt));

     /* Replacing second part of the UNION all's NESTED PATTERN bind variable for the hard coded ITD patttern for fii_time_structures: 512 */
     l_stmt2 := replace( l_stmt2, '&RLX_NESTED_PATTERN', '512');
  else /* DAY */
     l_stmt1 := SUBSTR (l_stmt, 1, INSTR(l_stmt,'UNION',1,1) - 1); /* if DAY there is only 1 union */
     l_stmt2 := SUBSTR (l_stmt, INSTR(l_stmt,'UNION',1,1), LENGTH(l_stmt));

     /* Replacing second part of the UNION all's NESTED PATTERN bind variable for the hard coded ITD patttern for fii_time_rpt_struct_v: 1143 */
     l_stmt2 := replace( l_stmt2, '&BIS_NESTED_PATTERN', '1143');
  end if;

  l_stmt := l_stmt1 || l_stmt2;

  l_stmt := 'select
  cal_name VIEWBY
, nvl(p_totalonhand_value,0) ISC_MEASURE_1
, nvl(p_Inv_usg,0)  ISC_MEASURE_7
, (p_uonhand_value*' || get_period_days(l_xtd ,'P') ||')/decode(p_Inv_usg,0,null,p_Inv_usg) ISC_MEASURE_11
, ' || get_period_days(l_xtd ,'P')  || ' ISC_MEASURE_30
, ' || get_period_days(l_xtd ,'C')  || ' ISC_MEASURE_31
, nvl(c_totalonhand_value,0) ISC_MEASURE_2
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_totalonhand_value'
       , 'p_totalonhand_value'
       , 'ISC_MEASURE_3' ) || '
, nvl(c_Inv_usg,0) ISC_MEASURE_8
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_Inv_usg'
       , 'p_Inv_usg'
       , 'ISC_MEASURE_9' ) || '
, (c_uonhand_value*' || get_period_days(l_xtd ,'C') ||')/decode(c_Inv_usg,0,null,c_Inv_usg) ISC_MEASURE_12
, (c_uonhand_value*' || get_period_days(l_xtd ,'C') ||')/decode(c_Inv_usg,0,null,c_Inv_usg) - (p_uonhand_value*' || get_period_days(l_xtd ,'P') ||')/decode(p_Inv_usg,0,null,p_Inv_usg) ISC_MEASURE_13
' ||
  isc_fs_rpt_util_pkg.get_trend_drill
  ( l_xtd
  , 'ISC_FS_INV_TRD_REP'
  , 'ISC_ATTRIBUTE_4'
  , 'ISC_ATTRIBUTE_5'
  , p_override_end_date =>  'cal_end_date'
  ) || '
from
  ' || l_stmt;

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  );

  if l_custom_output is not null then
    for i in 1..l_custom_output.count loop
      x_custom_output.extend;
      x_custom_output(x_custom_output.count) := l_custom_output(i);
    end loop;
  end if;

  l_custom_rec.attribute_name := '&ISC_TO_DATE';
  l_custom_rec.attribute_value := l_to_date;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;

  x_custom_output.extend;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  /* The poa template does not bring up the cal_end_date needed for the Day drills and current period days in rolling, so we do it */
  l_stmt := replace( l_stmt, ', cal.start_date cal_start_date', ', cal.start_date cal_start_date, cal.end_date cal_end_date');
  l_stmt := replace( l_stmt, ', cal_start_date', ', cal_start_date, cal_end_date');

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'Y'
  );

  x_custom_sql      := l_stmt;

end get_trd_sql;


END ISC_FS_INV_RPT_PKG;

/
