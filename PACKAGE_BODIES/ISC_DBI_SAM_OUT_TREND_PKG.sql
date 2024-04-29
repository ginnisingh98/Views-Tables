--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SAM_OUT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SAM_OUT_TREND_PKG" as
/* $Header: ISCRGCEB.pls 120.1 2006/04/19 17:32:54 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl) is

  l_period_type          varchar2(32000);
  l_comparison_type      varchar2(32000);
  l_sgid                 varchar2(32000);
  l_agree                varchar2(32000);
  l_class                varchar2(32000);
  l_cust                 varchar2(32000);
  l_curr                 varchar2(32000);
  l_curr_suffix          varchar2(32000);
  l_period_str           varchar2(32000);
  l_lag                  number;
  l_sg_sg                number;
  l_sg_res               number;
  l_sg_where             varchar2(32000);
  l_agree_where          varchar2(32000);
  l_class_where          varchar2(32000);
  l_cust_where           varchar2(32000);
  l_agree_needed         boolean;
  l_class_needed         boolean;
  l_cust_needed          boolean;
  l_agg_level            number;
  l_query                varchar2(32000);
  l_custom_rec           bis_query_attributes;


begin

  -- Get all necessary parameters from PMV
  for i in 1..p_param.count loop

    if (p_param(i).parameter_name = 'PERIOD_TYPE') then
      l_period_type := p_param(i).parameter_value;
    end if;

    if (p_param(i).parameter_name = 'TIME_COMPARISON_TYPE') then
      l_comparison_type := p_param(i).parameter_value;
    end if;

    if (p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
      l_sgid :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE') then
      l_agree :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
      l_class :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') then
      l_cust :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
      l_curr := p_param(i).parameter_id;
    end if;

  end loop;

  if (l_curr = '''FII_GLOBAL1''') then
    l_curr_suffix := 'g';
  else -- (l_curr = '''FII_GLOBAL2''')
    l_curr_suffix := 'g1';
  end if;

  if (l_period_type = 'FII_TIME_ENT_YEAR') then
    l_period_str := 'yr';
  elsif (l_period_type = 'FII_TIME_ENT_QTR') then
    l_period_str := 'qr';
  elsif (l_period_type = 'FII_TIME_ENT_PERIOD') then
    l_period_str := 'pd';
  else -- (l_period_type = 'FII_TIME_WEEK')
    l_period_str := 'wk';
  end if;

  case
    when (l_period_type = 'FII_TIME_WEEK'       and l_comparison_type = 'SEQUENTIAL') then l_lag := 1;
    when (l_period_type = 'FII_TIME_WEEK'       and l_comparison_type = 'YEARLY')     then l_lag := 13;
    when (l_period_type = 'FII_TIME_ENT_PERIOD' and l_comparison_type = 'SEQUENTIAL') then l_lag := 1;
    when (l_period_type = 'FII_TIME_ENT_PERIOD' and l_comparison_type = 'YEARLY')     then l_lag := 12;
    when (l_period_type = 'FII_TIME_ENT_QTR'    and l_comparison_type = 'SEQUENTIAL') then l_lag := 1;
    when (l_period_type = 'FII_TIME_ENT_QTR'    and l_comparison_type = 'YEARLY')     then l_lag := 4;
    when (l_period_type = 'FII_TIME_ENT_YEAR'   and l_comparison_type = 'SEQUENTIAL') then l_lag := 1;
    when (l_period_type = 'FII_TIME_ENT_YEAR'   and l_comparison_type = 'YEARLY')     then l_lag := 1;
  end case;

  -- Figure out where clauses
  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

  if (l_sg_res is null) then -- when a sales group is chosen
    l_sg_where := ' and f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.resource_id is null';
  else -- when the LOV parameter is a Salesrep (no need to go through the SG hierarchy)
    l_sg_where := ' and f.sales_grp_id = :ISC_SG and f.resource_id = :ISC_RES';
  end if;

  if (l_agree is null) then
    l_agree_where := '';
  else
    l_agree_where := ' and f.agreement_type_id in (&ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE)';
  end if;

  if (l_class is null) then
    l_class_where := '';
  else
    l_class_where := ' and f.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  end if;

  if (l_cust is null) then
    l_cust_where := '';
  else
    l_cust_where := ' and f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  end if;

  -- Figure out agg_level flag value
  l_agree_needed := false;
  l_class_needed := false;
  l_cust_needed := false;

  if (l_agree is not null) then
    l_agree_needed := true;
  end if;

  if (l_class is not null) then
    l_class_needed := true;
  end if;

  if (l_cust is not null) then
    l_cust_needed := true;
  end if;

  case
    when (    l_agree_needed and     l_class_needed and     l_cust_needed) then l_agg_level := 0;
    when (    l_agree_needed and     l_class_needed and not l_cust_needed) then l_agg_level := 2;
    when (    l_agree_needed and not l_class_needed and     l_cust_needed) then l_agg_level := 0;
    when (not l_agree_needed and     l_class_needed and     l_cust_needed) then l_agg_level := 1;
    when (    l_agree_needed and not l_class_needed and not l_cust_needed) then l_agg_level := 4;
    when (not l_agree_needed and     l_class_needed and not l_cust_needed) then l_agg_level := 3;
    when (not l_agree_needed and not l_class_needed and     l_cust_needed) then l_agg_level := 1;
    when (not l_agree_needed and not l_class_needed and not l_cust_needed) then l_agg_level := 5;
  end case;

  l_query := '
select
cal_name VIEWBY,
nvl(c_out,0) ISC_MEASURE_3,
(c_out-p_out)/decode(p_out,0,null,abs(p_out))*100 ISC_MEASURE_4,
nvl(c_act,0) ISC_MEASURE_5,
(c_act-p_act)/decode(p_act,0,null,abs(p_act))*100 ISC_MEASURE_6,
nvl(c_out,0) ISC_MEASURE_7,
nvl(c_act,0) ISC_MEASURE_8
from
(select
cal_name, cal_start_date,
sum(c_act)+sum(c_out) c_out,
sum(p_act)+sum(p_out) p_out,
sum(c_act) c_act,
sum(p_act) p_act
from
(
select
cal.name cal_name,
cal.start_date cal_start_date,
0 c_out,
0 p_out,
c_act,
p_act
from
(select
n.start_date,
sum(case when (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_CURRENT_ASOF_DATE))
then act_amt else null end) c_act,
lag(sum(case when (n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_PREVIOUS_ASOF_DATE))
then act_amt else null end), :ISC_LAG) over (order by n.start_date) p_act
from
(
select n.start_date,
n.report_date ,
sum(f.commit_amt_'||l_curr_suffix||') act_amt
from isc_sam_003_mv f, -- active balance
(select /*+ NO_MERGE */ n.ent_year_id,
n.report_date,
cal.start_date,
cal.end_date
from '||l_period_type||' cal,
fii_time_day n
where cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE), &BIS_PREVIOUS_ASOF_DATE)
and n.report_date between cal.start_date and cal.end_date) n
where f.ent_year_id = n.ent_year_id
and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
group by n.start_date, n.report_date) i, '||l_period_type||' n
where i.start_date (+) = n.start_date
and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date) iset, '||l_period_type||' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)
union all
select
cal.name cal_name,
cal.start_date cal_start_date,
0 c_out,
0 p_out,
c_act,
p_act
from
(select
n.start_date,
sum(case when (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_CURRENT_ASOF_DATE))
then act_amt else null end) c_act,
lag(sum(case when (n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_PREVIOUS_ASOF_DATE))
then act_amt else null end), :ISC_LAG) over (order by n.start_date) p_act
from
(
select n.start_date,
n.report_date ,
sum(f.commit_amt_'||l_curr_suffix||') act_amt
from isc_sam_001_mv f, -- activation
(select /*+ NO_MERGE */ n.time_id,
n.record_type_id,
n.period_type_id,
n.report_date,
cal.start_date,
cal.end_date
from '||l_period_type||' cal,
fii_time_rpt_struct_v n
where cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE), &BIS_PREVIOUS_ASOF_DATE)
and n.report_date between cal.start_date and cal.end_date
and bitand(n.record_type_id, 119) = n.record_type_id) n
where f.time_id = n.time_id
and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
group by n.start_date, n.report_date) i, '||l_period_type||' n
where i.start_date (+) = n.start_date
and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date) iset, '||l_period_type||' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)
union all
select
cal.name cal_name,
cal.start_date cal_start_date,
0 c_out,
0 p_out,
-c_act,
-p_act
from
(select
n.start_date,
sum(case when (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_CURRENT_ASOF_DATE))
then act_amt else null end) c_act,
lag(sum(case when (n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_PREVIOUS_ASOF_DATE))
then act_amt else null end), :ISC_LAG) over (order by n.start_date) p_act
from
(
select n.start_date,
n.report_date ,
sum(f.commit_amt_'||l_curr_suffix||') act_amt
from isc_sam_004_mv f, -- effective end
(select /*+ NO_MERGE */ n.time_id,
n.record_type_id,
n.period_type_id,
n.report_date,
cal.start_date,
cal.end_date
from '||l_period_type||' cal,
fii_time_rpt_struct_v n
where cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE), &BIS_PREVIOUS_ASOF_DATE)
and n.report_date between cal.start_date and cal.end_date
and bitand(n.record_type_id, 119) = n.record_type_id) n
where f.time_id = n.time_id
and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
group by n.start_date, n.report_date) i, '||l_period_type||' n
where i.start_date (+) = n.start_date
and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date) iset, '||l_period_type||' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)
union all
select
cal.name cal_name,
cal.start_date cal_start_date,
-c_out,
-p_out,
0 c_act,
0 p_act
from
(select
n.start_date,
sum(case when (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_CURRENT_ASOF_DATE))
then out_amt else null end) c_out,
lag(sum(case when (n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_PREVIOUS_ASOF_DATE))
then out_amt else null end), :ISC_LAG) over (order by n.start_date) p_out
from
(
select n.start_date,
n.report_date ,
sum(f.fulfill_out_f_ee_amt_'||l_curr_suffix||') out_amt
from isc_sam_005_mv f, -- fulfilled
(select /*+ NO_MERGE */ n.time_id,
n.record_type_id,
n.period_type_id,
n.report_date,
cal.start_date,
cal.end_date
from '||l_period_type||' cal,
fii_time_rpt_struct_v n
where cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE), &BIS_PREVIOUS_ASOF_DATE)
and n.report_date between cal.start_date and cal.end_date
and bitand(n.record_type_id, 1143) = n.record_type_id) n
where f.time_id = n.time_id
and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
group by n.start_date, n.report_date) i, '||l_period_type||' n
where i.start_date (+) = n.start_date
and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date) iset, '||l_period_type||' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)
union all
select
cal.name cal_name,
cal.start_date cal_start_date,
c_out,
p_out,
0 c_act,
0 p_act
from
(select
n.start_date,
sum(case when (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_CURRENT_ASOF_DATE))
then out_amt else null end) c_out,
lag(sum(case when (n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
and i.report_date = least(n.end_date, &BIS_PREVIOUS_ASOF_DATE))
then out_amt else null end), :ISC_LAG) over (order by n.start_date) p_out
from
(
select n.start_date,
n.report_date ,
sum(f.fulfill_out_f_ee_amt_'||l_curr_suffix||') out_amt
from isc_sam_004_mv f, -- effective end
(select /*+ NO_MERGE */ n.time_id,
n.record_type_id,
n.period_type_id,
n.report_date,
cal.start_date,
cal.end_date
from '||l_period_type||' cal,
fii_time_rpt_struct_v n
where cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE), &BIS_PREVIOUS_ASOF_DATE)
and n.report_date between cal.start_date and cal.end_date
and bitand(n.record_type_id, 1143) = n.record_type_id) n
where f.time_id = n.time_id
and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
group by n.start_date, n.report_date) i, '||l_period_type||' n
where i.start_date (+) = n.start_date
and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
group by n.start_date) iset, '||l_period_type||' cal
where cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)
)
group by cal_name, cal_start_date) uset
order by cal_start_date
';

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
  x_custom_output := bis_query_attributes_tbl();

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := l_agg_level;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LAG';
  l_custom_rec.attribute_value := l_lag;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_SG';
  l_custom_rec.attribute_value := to_char(l_sg_sg);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES';
  l_custom_rec.attribute_value := to_char(l_sg_res);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  x_custom_sql := l_query;

end get_sql;

end isc_dbi_sam_out_trend_pkg;

/
