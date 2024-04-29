--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_RPT_PKG" AS
/* $Header: OPIDRINVRB.pls 120.1 2005/08/10 04:00:54 srayadur noship $ */

/* PMV date mask */
s_pmv_date_mask VARCHAR2 (15) := '''DD-MM-RR'''; -- No more used bug 3580454

/* Local functions */

FUNCTION get_turns_sel_clause (p_view_by_col_name in VARCHAR2)
    RETURN VARCHAR2;

/* inner part of dynamic SQL for Inventory Turns table portlet */
FUNCTION turns_status_inner_sql(p_as_of_date in varchar2,
                                p_prev_as_of_date in varchar2,
                                p_xtd in varchar2,
                                p_curr in varchar2,
                                p_comparison_type in varchar2,
                                p_view_by_col_name in varchar2,
                                p_view_by_col_id in varchar2,
                                p_fact_name in varchar2,
                                p_where_clause in varchar2,
                                p_in_where_clause in varchar2,
                                p_kpi_group_by in varchar2,
                                p_kpi_in_group_by in varchar2,
                                p_view_by_dim in varchar2,
                                p_use_windowing in varchar2,
                                p_col_name in OPI_DBI_COL_TBL,
                                p_total_col_name in OPI_DBI_COL_TBL)
    RETURN VARCHAR2;


FUNCTION get_turns_trd_sel_clause RETURN VARCHAR2;

FUNCTION turns_trd_inner_sql (p_as_of_date in varchar2,
                                p_prev_as_of_date in varchar2,
                                p_curr in varchar2,
                                p_xtd in varchar2,
                                p_comparison_type in varchar2,
                                p_fact_name in varchar2,
                                p_where_clause in varchar2,
                                p_in_where_clause in varchar2,
                                p_col_name in OPI_DBI_COL_TBL,
                                p_total_col_name in OPI_DBI_COL_TBL)
    RETURN VARCHAR2;



Function get_view_by_table (dim_name varchar2) RETURN VARCHAR2;


PROCEDURE get_parameter_values(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_dim_in_tbl in OPI_DBI_DIM_TBL,
                               p_dim_out_tbl out NOCOPY OPI_DBI_DIM_TBL,
                               p_view_by out NOCOPY VARCHAR2,
                               p_comparison_type out NOCOPY VARCHAR2,
                               p_xtd out NOCOPY VARCHAR2,
                               p_as_of_date out NOCOPY DATE,
                               p_prev_as_of_date out NOCOPY DATE,
                               p_cur_suffix out NOCOPY VARCHAR2,
                               p_nested_pattern out NOCOPY NUMBER);


Function get_calendar_table(period_type varchar2) return varchar2;

Function get_nested_pattern(period_type varchar2) return number;

/****************************
Inventory Turns Report
*****************************/

PROCEDURE inv_turns_tbl_sql(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                            BIS_QUERY_ATTRIBUTES_TBL)
    IS
        l_query varchar2(8000);
        l_view_by varchar2(120);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_org varchar2(100);
        l_plant varchar2(100);
        l_category varchar2(2000);
        l_item varchar2(2000);
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_org_where varchar2(240);
        l_in_org_where varchar2(240);
        l_kpi_group_by varchar2(40) := '';
        l_kpi_in_group_by varchar2(40) := '';
        l_category_where varchar2(120);
        l_item_where varchar2(120);
        l_cur_suffix varchar2(5);
        l_rev_amount varchar2(25);
        l_cogs_amount varchar2(25);
        l_dim_in_tbl OPI_DBI_DIM_TBL;
        l_dim_out_tbl OPI_DBI_DIM_TBL;
        l_col_rec OPI_DBI_COL_REC;
        l_col_tbl OPI_DBI_COL_TBL;
        l_total_col_tbl OPI_DBI_COL_TBL;
        l_plant_where varchar2(240);
        l_in_plant_where varchar2(240);

    BEGIN

/* figure out what parameters we need for filtering and map them with available page paramters from PMV */
  l_dim_in_tbl := OPI_DBI_DIM_TBL('ORGANIZATION+ORGANIZATION');

  get_parameter_values(p_param, l_dim_in_tbl, l_dim_out_tbl, l_view_by, l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern);

  l_plant := l_dim_out_tbl(1);

  l_col_tbl := OPI_DBI_COL_TBL();
  l_total_col_tbl := OPI_DBI_COL_TBL();

/* construct the list of measures to be appended to the select clause of the dynamic SQL */
  l_col_rec.column_name := 'total_inv_val_' || l_cur_suffix;
  l_col_rec.column_alias := 'total_inv_val';
  l_col_tbl.extend;
  l_col_tbl(l_col_tbl.count) := l_col_rec;

  l_col_rec.column_name := 'cogs_val_' || l_cur_suffix;
  l_col_rec.column_alias := 'cogs_value';
  l_col_tbl.extend;
  l_col_tbl(l_col_tbl.count) := l_col_rec;

  l_col_rec.column_name := 'total_inv_val_' || l_cur_suffix;
  l_col_rec.column_alias := 'total_inv_val_total';
  l_total_col_tbl.extend;
  l_total_col_tbl(l_total_col_tbl.count) := l_col_rec;

  l_col_rec.column_name := 'cogs_val_' || l_cur_suffix;
  l_col_rec.column_alias := 'cogs_val_total';
  l_total_col_tbl.extend;
  l_total_col_tbl(l_total_col_tbl.count) := l_col_rec;

/* construct where caluse of the dynamic SQL based on chosen page parameter values */
/*
  if(l_org is null or l_org = '') then
    l_org_where := ' and fact.operating_unit_id in (select organization_id from per_organization_list where security_profile_id= nvl(fnd_profile.value(''XLA_MO_SECURITY_PROFILE_LEVEL''), -1) ) ';
  else
    l_org_where := ' and fact.operating_unit_id = &ORGANIZATION+FII_OPERATING_UNITS ';
  end if;

  if(l_org is null or l_org = '') then
    l_in_org_where := ' and insv.operating_unit_id in (select organization_id from per_organization_list where security_profile_id= nvl(fnd_profile.value(''XLA_MO_SECURITY_PROFILE_LEVEL''), -1) ) ';
  else
    l_in_org_where := ' and insv.operating_unit_id = &ORGANIZATION+FII_OPERATING_UNITS ';
  end if;
*/

  if(l_plant is null or l_plant = '' or l_plant = 'All') then
    l_plant_where := '';
    l_in_plant_where := '';
  else
    l_plant_where := ' and fact.organization_id in (' || l_plant || ') ';
    l_in_plant_where := ' and insv.organization_id in (' || l_plant || ') ';
  end if;

     l_query :=
                get_turns_sel_clause('organization_id') || ' from
              ' || turns_status_inner_sql(l_as_of_date,
                                          l_prev_as_of_date,
                                          l_xtd,
                                          l_cur_suffix,
                                          l_comparison_type,
                                          'organization_id',
                                          'id',
                                          'opi_dbi_inv_turns_f',
                                          l_plant_where ,
                                          l_in_org_where ,
                                          l_kpi_group_by ,
                                          l_kpi_in_group_by ,
                                          'INV_ORG',
                                          'N',
                                          l_col_tbl,
                                          l_total_col_tbl);


    -- empty the output table because we have no bind values to pass back
    x_custom_output := bis_query_attributes_tbl();

    -- return the query
    x_custom_sql := l_query;

END inv_turns_tbl_sql;


/* Outer select clause of Inventory Turns table portlet query */

FUNCTION get_turns_sel_clause (p_view_by_col_name in VARCHAR2)
    RETURN VARCHAR2
IS

    l_sel_clause varchar2(7000);

BEGIN

  l_sel_clause :=
  'select v.value VIEWBY, v.value OPI_ATTRIBUTE1, oset.OPI_MEASURE1 OPI_MEASURE1,
            oset.OPI_MEASURE2 OPI_MEASURE2, oset.OPI_MEASURE3 OPI_MEASURE3,
            oset.OPI_MEASURE4 OPI_MEASURE4, oset.OPI_MEASURE5 OPI_MEASURE5,
            oset.OPI_MEASURE6 OPI_MEASURE6, oset.OPI_MEASURE7 OPI_MEASURE7,
            oset.OPI_MEASURE8 OPI_MEASURE8, oset.OPI_MEASURE9 OPI_MEASURE9,
            oset.OPI_MEASURE10 OPI_MEASURE10, oset.OPI_MEASURE11 OPI_MEASURE11,
            oset.OPI_MEASURE12 OPI_MEASURE12, oset.OPI_MEASURE13 OPI_MEASURE13
            from
     (select (rank() over
                (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col_name || ')) - 1 rnk,'
        || p_view_by_col_name || ',
           OPI_MEASURE1, OPI_MEASURE2, OPI_MEASURE3, OPI_MEASURE4,
           OPI_MEASURE5, OPI_MEASURE6, OPI_MEASURE7, OPI_MEASURE8,
           OPI_MEASURE9, OPI_MEASURE10, OPI_MEASURE11, OPI_MEASURE12, OPI_MEASURE13
      from
     (select ' || p_view_by_col_name || ', ' || p_view_by_col_name || ' VIEW_BY,
           c_total_inv_val OPI_MEASURE1, c_cogs_val OPI_MEASURE2,
           round(decode(sign(p_total_inv_val), 0, NULL, -1, NULL, p_cogs_val/p_total_inv_val),5) OPI_MEASURE3,
           round(decode(sign(c_total_inv_val), 0, NULL, -1, NULL, c_cogs_val/c_total_inv_val),5) OPI_MEASURE4,
           round((decode(sign(c_total_inv_val), 0, NULL, -1, NULL, c_cogs_val/c_total_inv_val) - decode(p_total_inv_val, 0, NULL, p_cogs_val/p_total_inv_val)),5) OPI_MEASURE5,
           c_total_inv_val_total OPI_MEASURE6, c_cogs_val_total OPI_MEASURE7,
           decode(sign(c_total_inv_val_total), 0, NULL,-1,NULL,
           (c_cogs_val_total / c_total_inv_val_total)) OPI_MEASURE8,
           decode(sign(c_total_inv_val_total), 0, NULL, -1, NULL,
           decode(sign(p_total_inv_val_total), 0, NULL, -1, NULL,
           ((c_cogs_val_total / c_total_inv_val_total) -
           (p_cogs_val_total / p_total_inv_val_total)))) OPI_MEASURE9,
           round(decode(sign(c_total_inv_val), 0, NULL, -1, NULL, c_cogs_val/c_total_inv_val),5) OPI_MEASURE10,
           round(decode(sign(p_total_inv_val), 0, NULL, -1, NULL, p_cogs_val/p_total_inv_val),5) OPI_MEASURE11,
           decode(sign(c_total_inv_val_total), 0, NULL,-1,NULL,
           (c_cogs_val_total / c_total_inv_val_total)) OPI_MEASURE12,
           decode(sign(p_total_inv_val_total), 0, NULL,-1,NULL,
           (p_cogs_val_total / p_total_inv_val_total)) OPI_MEASURE13 from
           (select c.' || p_view_by_col_name || ' ,
            c.total_inv_val c_total_inv_val , c.cogs_val c_cogs_val ,
            p.total_inv_val p_total_inv_val , p.cogs_val p_cogs_val ,
            sum(c.total_inv_val) over () c_total_inv_val_total,
            sum(c.cogs_val) over () c_cogs_val_total,
            sum(p.total_inv_val) over () p_total_inv_val_total,
            sum(p.cogs_val) over () p_cogs_val_total';

  return l_sel_clause;

END get_turns_sel_clause;


/* inner part of dynamic SQL for Inventory Turns table portlet */
FUNCTION turns_status_inner_sql(p_as_of_date in varchar2,
                                p_prev_as_of_date in varchar2,
                                p_xtd in varchar2,
                                p_curr in varchar2,
                                p_comparison_type in varchar2,
                                p_view_by_col_name in varchar2,
                                p_view_by_col_id in varchar2,
                                p_fact_name in varchar2,
                                p_where_clause in varchar2,
                                p_in_where_clause in varchar2,
                                p_kpi_group_by in varchar2,
                                p_kpi_in_group_by in varchar2,
                                p_view_by_dim in varchar2,
                                p_use_windowing in varchar2,
                                p_col_name in OPI_DBI_COL_TBL,
                                p_total_col_name in OPI_DBI_COL_TBL)
    RETURN VARCHAR2
IS
        l_query varchar2(5000);
        l_col_names varchar2(4000);
        l_partial_weight varchar2(1000);
        l_prev_partial_weight varchar2(1000);
        l_total_col_names varchar2(4000);
        l_view_by varchar2(120);
        l_view_by_table varchar2(300);
BEGIN

  FOR i IN 1 .. p_col_name.COUNT
  LOOP
      l_col_names := l_col_names || ',
                     sum(' || p_col_name(i).column_name || ') '  || p_col_name(i).column_alias;
  END LOOP;

  FOR i IN 1 .. p_total_col_name.COUNT
  LOOP
      l_total_col_names := l_total_col_names || ',
                           sum(sum(' || p_total_col_name(i).column_name || ')) over ()
' || p_total_col_name(i).column_alias;
  END LOOP;

  l_view_by_table := get_view_by_table(p_view_by_dim);

  l_partial_weight := ' (&BIS_CURRENT_ASOF_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) ';

  l_prev_partial_weight := ' ( &BIS_PREVIOUS_ASOF_DATE  -  &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) ';


  l_query := '(select ' || p_view_by_col_name ||', start_date_'|| p_xtd || ',
        sum(cogs_val_'|| p_curr || ') * 365 / ' || l_partial_weight || ' cogs_val,
        (sum(weight * inv_balance_' || p_curr || ') -
           (select distinct
             last_value(weight * inv_balance_' || p_curr || ')
            over (partition by organization_id, start_date_'|| p_xtd || '
            order by transaction_date asc
                range between unbounded preceding and unbounded following) -
             last_value(inv_balance_' || p_curr || ' * ( &BIS_CURRENT_ASOF_DATE  - transaction_date + 1))
            over (partition by organization_id, start_date_'|| p_xtd || '
            order by transaction_date asc
                range between unbounded preceding and unbounded following )
                    from ' || p_fact_name || ' insv
                    where
            fact.start_date_'|| p_xtd || ' = insv.start_date_'|| p_xtd || '
            and insv.organization_id = fact.organization_id
                ' || p_in_where_clause || '
                    and insv.transaction_date <= &BIS_CURRENT_ASOF_DATE))
            / ' || l_partial_weight || '  total_inv_val
                from ' || p_fact_name || ' fact
            where
(exists
(SELECT 1
FROM ORG_ACCESS o
WHERE o.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
AND o.RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID
and o.organization_id = fact.organization_id)
or exists
(SELECT 1
FROM mtl_parameters org
where org.organization_id = fact.organization_id
and NOT EXISTS
(select 1
from org_access ora
where org.organization_id = ora.organization_id)))
             and    transaction_date >= &BIS_CURRENT_EFFECTIVE_START_DATE
             and    transaction_date <= &BIS_CURRENT_ASOF_DATE
        ' || p_where_clause || '
                group by fact.' || p_view_by_col_name || ', start_date_'|| p_xtd || p_kpi_in_group_by || '
--          having sum(weight * inv_balance_' || p_curr || ') <> 0 and sum(cogs_val_'|| p_curr || ') is not null
                      ) c,
        (select ' || p_view_by_col_name ||', start_date_'|| p_xtd || ',
                     sum(cogs_val_'|| p_curr || ') * 365 / ' || l_prev_partial_weight || '  cogs_val,
                     (sum(weight * inv_balance_' || p_curr || ') -
                     (select distinct
                     last_value(weight * inv_balance_' || p_curr || ')
                        over (partition by organization_id, start_date_'|| p_xtd || '
                        order by transaction_date asc
                        range between unbounded preceding and unbounded following) -
                     last_value(inv_balance_' || p_curr || ' * (&BIS_PREVIOUS_ASOF_DATE - transaction_date + 1))
                        over (partition by organization_id, start_date_'|| p_xtd || '
                        order by transaction_date asc
                        range between unbounded preceding and unbounded following )
                    from ' || p_fact_name || ' insv
                    where
                        fact.start_date_'|| p_xtd || ' = insv.start_date_'|| p_xtd || '
                        and insv.organization_id = fact.organization_id
                        ' || p_in_where_clause || '
                        and insv.transaction_date <= &BIS_PREVIOUS_ASOF_DATE))/ ' || l_prev_partial_weight || '  total_inv_val
                from ' || p_fact_name || ' fact
                where
(exists
(SELECT 1
FROM ORG_ACCESS o
WHERE o.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
AND o.RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID
and o.organization_id = fact.organization_id)
or exists
(SELECT 1
FROM mtl_parameters org
where org.organization_id = fact.organization_id
and NOT EXISTS
(select 1
from org_access ora
where org.organization_id = ora.organization_id)))
                 and    transaction_date >= &BIS_PREVIOUS_EFFECTIVE_START_DATE
                 and    transaction_date <= &BIS_PREVIOUS_ASOF_DATE
                ' || p_where_clause || '
                group by fact.' || p_view_by_col_name || ', start_date_'|| p_xtd || p_kpi_in_group_by || '
--                having sum(weight * inv_balance_' || p_curr || ') <> 0 and sum(cogs_val_'|| p_curr || ') is not null
                      ) p
            where c.' || p_view_by_col_name || ' = p.' || p_view_by_col_name || ' (+) )' || p_kpi_group_by || ')) oset,
         ' || l_view_by_table || ' v
            where oset.' || p_view_by_col_name || ' = v.' || p_view_by_col_id;

  if(p_use_windowing = 'Y') then l_query := l_query || '
            and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)';
  end if;

  l_query := l_query || '
             &ORDER_BY_CLAUSE nulls last';

  return l_query;

END turns_status_inner_sql;



/****************************
Inventory Turns Trend Report
*****************************/

PROCEDURE inv_turns_trd_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                              x_custom_sql    OUT NOCOPY  VARCHAR2,
                              x_custom_output OUT NOCOPY
                              BIS_QUERY_ATTRIBUTES_TBL)
IS
        l_query varchar2(12000);
        l_view_by varchar2(120);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_plant varchar2(100);
        l_category varchar2(2000);
        l_item varchar2(2000);
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_plant_where varchar2(240);
        l_in_plant_where varchar2(240);
        l_cur_suffix varchar2(5);
        l_custom_rec BIS_MAP_REC := BIS_MAP_REC(null, null);
        l_dim_in_tbl OPI_DBI_DIM_TBL;
        l_dim_out_tbl OPI_DBI_DIM_TBL;
        l_col_rec OPI_DBI_COL_REC;
        l_col_tbl OPI_DBI_COL_TBL;
        l_total_col_tbl OPI_DBI_COL_TBL;


        l_custom_attr_rec           BIS_QUERY_ATTRIBUTES;
        l_period_type       VARCHAR2(30);

BEGIN


/* figure out what parameters we need for filtering and map them with available page paramters from PMV */
  l_dim_in_tbl := OPI_DBI_DIM_TBL('ORGANIZATION+ORGANIZATION');
  get_parameter_values(p_param, l_dim_in_tbl, l_dim_out_tbl, l_view_by, l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern);

  l_plant := l_dim_out_tbl(1);

  l_col_tbl := OPI_DBI_COL_TBL();
  l_total_col_tbl := OPI_DBI_COL_TBL();

/* construct the list of measures to be appended to the select clause of the dynamic SQL */
  l_col_rec.column_name := 'cogs_val_' || l_cur_suffix;
  l_col_rec.column_alias := 'cogs_val';
  l_col_tbl.extend;
  l_col_tbl(l_col_tbl.count) := l_col_rec;

  l_col_rec.column_name := 'inv_balance_' || l_cur_suffix;
  l_col_rec.column_alias := 'inv_balance';
  l_col_tbl.extend;
  l_col_tbl(l_col_tbl.count) := l_col_rec;

  l_col_rec.column_name := 'cogs_val_' || l_cur_suffix;
  l_col_rec.column_alias := 'cogs_val_total';
  l_total_col_tbl.extend;
  l_total_col_tbl(l_total_col_tbl.count) := l_col_rec;

  l_col_rec.column_name := 'inv_balance_' || l_cur_suffix;
  l_col_rec.column_alias := 'inv_balance_total';
  l_total_col_tbl.extend;
  l_total_col_tbl(l_total_col_tbl.count) := l_col_rec;

/* construct where caluse of the dynamic SQL based on chosen page parameter values */
/*
  if(l_org is null or l_org = '') then
    l_org_where := ' and (fact.operating_unit_id is null or fact.operating_unit_id in (select organization_id
from per_organization_list where security_profile_id = nvl(fnd_profile.value(''XLA_MO_SECURITY_PROFILE_LEVEL''), -1) )) ';
  else
    l_org_where := ' and fact.operating_unit_id (+) = &ORGANIZATION+FII_OPERATING_UNITS ' ;
  end if;

  if(l_org is null or l_org = '') then
    l_in_org_where := ' and insv.operating_unit_id in (select organization_id from per_organization_list where
 security_profile_id = nvl(fnd_profile.value(''XLA_MO_SECURITY_PROFILE_LEVEL''), -1) ) ' ;
  else
    l_in_org_where := ' and insv.operating_unit_id = &ORGANIZATION+FII_OPERATING_UNITS ';
  end if;
*/

  if(l_plant is null or l_plant = '' or l_plant = 'All') then
    l_plant_where := '';
    l_in_plant_where := '';
  else
    l_plant_where := ' and fact.organization_id in (' || l_plant || ') ';
    l_in_plant_where := ' and insv.organization_id in (' || l_plant || ') ';
  end if;

  l_query := get_turns_trd_sel_clause || ' from
             '|| turns_trd_inner_sql(l_as_of_date,
                                       l_prev_as_of_date,
                                       l_cur_suffix,
                                       l_xtd,
                                       l_comparison_type,
                                       'opi_dbi_inv_turns_f',
                                       l_plant_where,
                                       l_in_plant_where,
                                       l_col_tbl,
                                       l_total_col_tbl);
  x_custom_sql := l_query;

  if(l_xtd = 'YTD') then
    l_period_type := 'FII_TIME_ENT_YEAR';
  elsif(l_xtd = 'QTD') then
    l_period_type := 'FII_TIME_ENT_QTR';
  elsif(l_xtd = 'MTD') then
    l_period_type := 'FII_TIME_ENT_PERIOD';
  else
    l_period_type := 'FII_TIME_WEEK';
  end if;

  l_custom_attr_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  l_custom_attr_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.View_By_Value;
  l_custom_attr_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_attr_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_attr_rec;

END inv_turns_trd_sql;


/* Outer select clause of Inventory Turns Trend portlet query */
FUNCTION get_turns_trd_sel_clause
    RETURN VARCHAR2
IS

    l_sel_clause varchar2(4000);

BEGIN

    l_sel_clause :=
    'select cal.name VIEWBY,
      cal.name OPI_ATTRIBUTE1,
          c.avg_daily_inv OPI_MEASURE1,
          c.annualized_cogs OPI_MEASURE2,
      decode(p.avg_daily_inv, 0, NULL, p.annualized_cogs/p.avg_daily_inv) OPI_MEASURE3,
      decode(c.avg_daily_inv, 0, NULL, c.annualized_cogs/c.avg_daily_inv) OPI_MEASURE4,
      (decode(c.avg_daily_inv, 0, NULL, c.annualized_cogs/c.avg_daily_inv)
      - decode(p.avg_daily_inv, 0, NULL, p.annualized_cogs/p.avg_daily_inv)) OPI_MEASURE5 ';

  RETURN l_sel_clause;

END get_turns_trd_sel_clause;


/* inner part of dynamic SQL for Inventory Turns Trend portlet */
FUNCTION turns_trd_inner_sql (p_as_of_date in varchar2,
                                p_prev_as_of_date in varchar2,
                                p_curr in varchar2,
                                p_xtd in varchar2,
                                p_comparison_type in varchar2,
                                p_fact_name in varchar2,
                                p_where_clause in varchar2,
                                p_in_where_clause in varchar2,
                                p_col_name in OPI_DBI_COL_TBL,
                                p_total_col_name in OPI_DBI_COL_TBL)
    RETURN VARCHAR2
  IS
        l_query varchar2(12000);
        l_col_names varchar2(4000);
        l_total_col_names varchar2(4000);
        l_view_by varchar2(120);
        l_partial_weight varchar2(1000);
        l_prev_partial_weight varchar2(1000);
        l_global_start_date date;
        l_span number;

  BEGIN

  FOR i IN p_col_name.FIRST .. p_col_name.LAST
  LOOP
      l_col_names := l_col_names || ',
                     ' || p_col_name(i).column_name || ' '  || p_col_name(i).column_alias;
  END LOOP;

  FOR i IN p_total_col_name.FIRST .. p_total_col_name.LAST
  LOOP
      l_total_col_names := l_total_col_names || ',
                           sum(sum(' || p_total_col_name(i).column_name || ')) over () ' || p_total_col_name(i).column_alias;
  END LOOP;

  l_span := (CASE p_xtd WHEN 'YTD' THEN 365 WHEN 'QTD' THEN 90 WHEN 'MTD' THEN 30 ELSE 7 END);
  l_global_start_date := bis_common_parameters.get_global_start_date;

  l_partial_weight := ' (&BIS_CURRENT_ASOF_DATE - &BIS_CURRENT_EFFECTIVE_START_DATE + 1) ';

  l_prev_partial_weight := ' (&BIS_PREVIOUS_ASOF_DATE - &BIS_PREVIOUS_EFFECTIVE_START_DATE + 1) ';

  l_query :=
'(select start_date_' || p_xtd || ' period_name, sum(cogs_val) annualized_cogs, sum(total_inv_val) avg_daily_inv, id from
    (select organization_id, start_date_' || p_xtd || ' ,
                sum(cogs_val_' || p_curr || ') * 365 / sum(weight) cogs_val,
                sum(weight * inv_balance_' || p_curr || ') / sum(weight) total_inv_val,
        decode (fact.start_date_' || p_xtd || ', ''' || l_global_start_date || ''',
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ') + 1,
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ')) id
                from ' || p_fact_name || ' fact
                where
(exists
(SELECT 1
FROM ORG_ACCESS o
WHERE o.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
AND o.RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID
and o.organization_id = fact.organization_id)
or exists
(SELECT 1
FROM mtl_parameters org
where org.organization_id = fact.organization_id
and NOT EXISTS
(select 1
from org_access ora
where org.organization_id = ora.organization_id)))
                and     transaction_date >= &BIS_CURRENT_REPORT_START_DATE
                and     transaction_date < &BIS_CURRENT_EFFECTIVE_START_DATE
                ' || p_where_clause || '
                group by fact.organization_id, start_date_'|| p_xtd || ',
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ')
--                having sum(weight * inv_balance_' || p_curr || ') <> 0 and sum(cogs_val_'|| p_curr || ') is not null
    union all
    select organization_id, start_date_'|| p_xtd || ',
                sum(cogs_val_'|| p_curr || ') * 365 /
        ' || l_partial_weight || ' cogs_val,
                (sum(weight * inv_balance_' || p_curr || ') -
                   (select distinct
                     last_value(weight * inv_balance_' || p_curr || ')
                        over (partition by organization_id, start_date_'|| p_xtd || '
                        order by transaction_date asc
                        range between unbounded preceding and unbounded following) -
                     last_value(inv_balance_' || p_curr || ' * (&BIS_CURRENT_ASOF_DATE - transaction_date + 1))
                        over (partition by organization_id, start_date_'|| p_xtd || '
                        order by transaction_date asc
                        range between unbounded preceding and unbounded following )
                    from ' || p_fact_name || ' insv
                    where
                        fact.start_date_'|| p_xtd || ' = insv.start_date_'|| p_xtd || '
                        and insv.organization_id = fact.organization_id
                        ' || p_in_where_clause || '
                        and insv.transaction_date <= &BIS_CURRENT_ASOF_DATE)) /
        ' || l_partial_weight || ' total_inv_val,
        decode (fact.start_date_' || p_xtd || ', ''' || l_global_start_date || ''',
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ') + 1,
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ')) id
                from ' || p_fact_name || ' fact
                where
(exists
(SELECT 1
FROM ORG_ACCESS o
WHERE o.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
AND o.RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID
and o.organization_id = fact.organization_id)
or exists
(SELECT 1
FROM mtl_parameters org
where org.organization_id = fact.organization_id
and NOT EXISTS
(select 1
from org_access ora
where org.organization_id = ora.organization_id)))
                 and    transaction_date >= &BIS_CURRENT_EFFECTIVE_START_DATE
                 and    transaction_date <= &BIS_CURRENT_ASOF_DATE
                ' || p_where_clause || '
                group by fact.organization_id, start_date_'|| p_xtd || ',
        decode (fact.start_date_' || p_xtd || ', ''' || l_global_start_date || ''',
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ') + 1,
        round((&BIS_CURRENT_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || '))
--                having sum(weight * inv_balance_' || p_curr || ') <> 0 and sum(cogs_val_'|| p_curr || ') is not null
                     )
    group by start_date_' ||  p_xtd || ', id order by id asc) c,
(select start_date_' || p_xtd || ' period_name, sum(cogs_val) annualized_cogs, sum(total_inv_val) avg_daily_inv, id from
        (select organization_id, start_date_' || p_xtd || ',
                sum(cogs_val_' || p_curr || ') * 365 / sum(weight) cogs_val,
                sum(weight * inv_balance_' || p_curr || ') / sum(weight) total_inv_val,
        decode (fact.start_date_' || p_xtd || ', ''' || l_global_start_date || ''',
        round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ') + 1,
        round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ')) id
                from ' || p_fact_name || ' fact
                where
(exists
(SELECT 1
FROM ORG_ACCESS o
WHERE o.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
AND o.RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID
and o.organization_id = fact.organization_id)
or exists
(SELECT 1
FROM mtl_parameters org
where org.organization_id = fact.organization_id
and NOT EXISTS
(select 1
from org_access ora
where org.organization_id = ora.organization_id)))
                and     transaction_date >= &BIS_PREVIOUS_REPORT_START_DATE
                and     transaction_date < &BIS_PREVIOUS_EFFECTIVE_START_DATE
                ' || p_where_clause || '
                group by fact.organization_id, start_date_'|| p_xtd || ',
                round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ')
--                having sum(weight * inv_balance_' || p_curr || ') <> 0 and sum(cogs_val_'|| p_curr || ') is not null
        union all
        select organization_id, start_date_'|| p_xtd || ',
                sum(cogs_val_'|| p_curr || ') * 365 /
        ' || l_prev_partial_weight || ' cogs_val,
                (sum(weight * inv_balance_' || p_curr || ') -
                   (select distinct
                     last_value(weight * inv_balance_' || p_curr || ')
                        over (partition by organization_id, start_date_'|| p_xtd || '
                        order by transaction_date asc
                        range between unbounded preceding and unbounded following) -
                     last_value(inv_balance_' || p_curr || ' * (&BIS_PREVIOUS_ASOF_DATE - transaction_date + 1))
                        over (partition by organization_id, start_date_'|| p_xtd || '
                        order by transaction_date asc
                        range between unbounded preceding and unbounded following )
                    from ' || p_fact_name || ' insv
                    where
                        fact.start_date_'|| p_xtd || ' = insv.start_date_'|| p_xtd || '
                        and insv.organization_id = fact.organization_id
                        ' || p_in_where_clause || '
                        and insv.transaction_date <= &BIS_PREVIOUS_ASOF_DATE)) /
        ' || l_prev_partial_weight || ' total_inv_val,
        decode (fact.start_date_' || p_xtd || ', ''' || l_global_start_date || ''',
        round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ') + 1,
        round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ')) id
                from ' || p_fact_name || ' fact
                where
(exists
(SELECT 1
FROM ORG_ACCESS o
WHERE o.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
AND o.RESP_APPLICATION_ID = FND_GLOBAL.RESP_APPL_ID
and o.organization_id = fact.organization_id)
or exists
(SELECT 1
FROM mtl_parameters org
where org.organization_id = fact.organization_id
and NOT EXISTS
(select 1
from org_access ora
where org.organization_id = ora.organization_id)))
                 and    transaction_date >= &BIS_PREVIOUS_EFFECTIVE_START_DATE
                 and    transaction_date <= &BIS_PREVIOUS_ASOF_DATE
                ' || p_where_clause || '
                group by fact.organization_id, start_date_'|| p_xtd || ',
        decode (fact.start_date_' || p_xtd || ', ''' || l_global_start_date || ''',
        round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || ') + 1,
        round((&BIS_PREVIOUS_EFFECTIVE_START_DATE - fact.start_date_' || p_xtd || ')/' || l_span || '))
--                having sum(weight * inv_balance_' || p_curr || ') <> 0 and sum(cogs_val_'|| p_curr || ') is not null
                     )
        group by start_date_' ||  p_xtd || ', id order by id asc) p,
 ' || get_calendar_table(p_xtd) || ' cal
     where
      c.id = p.id(+)
      and cal.start_date = c.period_name
     order by c.id desc';

  return l_query;

END turns_trd_inner_sql;


/****************************
Utilities
*****************************/

/*
    Get the view by based on the dimension level
*/
Function get_view_by_table (dim_name varchar2)
         RETURN VARCHAR2

IS

l_table varchar2(300);

begin

  l_table :=  (CASE dim_name
  WHEN 'OPER_UNIT' THEN 'fii_operating_units_v'
  WHEN 'INV_ORG' THEN '(select organization_id id, name value from hr_all_organization_units_tl where language = userenv(''LANG'')) '
  WHEN 'PROD_CAT' THEN 'eni_item_vbh_nodes_v'
  WHEN 'INV_CAT' THEN 'eni_item_inv_cat_v'
  WHEN 'ITEM' THEN 'eni_item_org_v '
  ELSE ''
  END);

  return l_table;

end get_view_by_table;


/*
    Get parameter values for the inventory turns reports
*/

PROCEDURE get_parameter_values(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_dim_in_tbl in OPI_DBI_DIM_TBL,
                               p_dim_out_tbl out NOCOPY OPI_DBI_DIM_TBL,
                               p_view_by out NOCOPY VARCHAR2,
                               p_comparison_type out NOCOPY VARCHAR2,
                               p_xtd out NOCOPY VARCHAR2,
                               p_as_of_date out NOCOPY DATE,
                               p_prev_as_of_date out NOCOPY DATE,
                               p_cur_suffix out NOCOPY VARCHAR2,
                               p_nested_pattern out NOCOPY NUMBER)
  IS

  l_currency varchar2(30);
  l_period_type varchar2(30);

  BEGIN

  p_dim_out_tbl := OPI_DBI_DIM_TBL();
  p_dim_out_tbl.extend(p_dim_in_tbl.count);

  for i in 1..p_param.COUNT LOOP

  if( p_param(i).parameter_name= 'VIEW_BY') then
     p_view_by := p_param(i).parameter_value;
  end if;
  if(p_param(i).parameter_name = 'PERIOD_TYPE') then
     l_period_type := p_param(i).parameter_value;
  end if;
  if(p_param(i).parameter_name = 'TIME_COMPARISON_TYPE') then
     if(p_param(i).parameter_value = 'YEARLY') then
       p_comparison_type := 'Y';
     else
       p_comparison_type := 'S';
     end if;
  end if;
  if(p_param(i).parameter_name = 'AS_OF_DATE') then
     p_as_of_date := to_date(p_param(i).parameter_value, 'DD-MM-RR');
  end if;
  if(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
     l_currency := p_param(i).parameter_id;
  end if;

  FOR j IN 1 .. p_dim_in_tbl.COUNT
  LOOP
     if(p_param(i).parameter_name = p_dim_in_tbl(j)) then
        p_dim_out_tbl(j) := p_param(i).parameter_id;
     end if;
  END LOOP;

  END LOOP;

  if(l_period_type = 'FII_TIME_ENT_YEAR') then p_xtd := 'YTD';
  elsif (l_period_type = 'FII_TIME_ENT_QTR') then p_xtd := 'QTD';
  elsif (l_period_type = 'FII_TIME_ENT_PERIOD') then p_xtd := 'MTD';
  else p_xtd := 'WTD';
  end if;

  if(p_as_of_date is null) then p_as_of_date := sysdate; end if;
  p_prev_as_of_date := opi_dbi_calendar_pkg.previous_period_asof_date(p_as_of_date, p_xtd, p_comparison_type);
  p_nested_pattern := get_nested_pattern(p_xtd);

  if(p_comparison_type is null) then p_comparison_type := 'Y'; end if;

  /*Mohit - 08/23/2004
  1. removed the else clause as it was causing currency suffix to default to 'B'
  2. Replace else with elsif statement (same as in util package)
  */
  if(l_currency = '''FII_GLOBAL1''') then
    p_cur_suffix := 'g';
  elsif(l_currency = '''FII_GLOBAL2''') then
    p_cur_suffix := 'sg';
  elsif(l_currency is not null) then
--  else
    p_cur_suffix := 'b';
  end if;

  if(p_cur_suffix is null) then p_cur_suffix := 'g'; end if;

END get_parameter_values;


Function get_calendar_table(period_type varchar2)
         return varchar2 is

 l_table_name varchar2(25);
begin

 if(period_type = 'YTD') then
   l_table_name := 'fii_time_ent_year';
 elsif(period_type = 'QTD') then
   l_table_name := 'fii_time_ent_qtr';
 elsif(period_type = 'MTD') then
   l_table_name := 'fii_time_ent_period';
 elsif(period_type = 'WTD') then
   l_table_name := 'fii_time_week';
 end if;

 return l_table_name;

end get_calendar_table;

Function get_nested_pattern(period_type varchar2)
         return number is

  l_pattern number;
begin

  if(period_type = 'YTD') then
    l_pattern := 119;
  elsif(period_type = 'QTD') then
    l_pattern := 55;
  elsif(period_type = 'MTD') then
    l_pattern := 23;
  elsif(period_type = 'WTD') then
    l_pattern := 11;
  end if;

  return l_pattern;

end get_nested_pattern;


END OPI_DBI_INV_RPT_PKG;

/
