--------------------------------------------------------
--  DDL for Package Body ENI_DBI_UCO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_UCO_PKG" AS
/* $Header: ENIUCOPB.pls 120.0 2005/05/26 19:36:32 appldev noship $ */



-- Returns query for Unit Cost report/portlet
PROCEDURE get_sql( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                            , x_custom_sql OUT NOCOPY VARCHAR2
                            , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  -- SQL statement for the report
  l_sql_stmt             VARCHAR2(4000);

  l_period_type          VARCHAR2(40);
  l_period_bitand        NUMBER;
  l_view_by              VARCHAR2(200);
  l_as_of_date           DATE;
  l_prev_as_of_date      DATE;
  l_report_start         DATE;
  l_cur_period           NUMBER;
  l_days_into_period     NUMBER;
  l_comp_type            VARCHAR2(100);
  l_category             VARCHAR2(100);
  l_item                 VARCHAR2(100);
  l_org                  VARCHAR2(30);
  l_id_column            VARCHAR2(30);
  l_order_by             VARCHAR2(100);
  l_drill                VARCHAR2(30);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_err_msg              VARCHAR2(100);

  l_comp_where          VARCHAR2(100);
  l_view_by_column      VARCHAR2(30);
  l_item_where          VARCHAR2(1000);
  l_org_where           VARCHAR2(1000);
  l_cat_where           VARCHAR2(1000);

  l_status varchar2(40);
  l_priority varchar2(40);
  l_reason varchar2(40);
  l_lifecycle_phase varchar2(40);
  l_currency  varchar2(40);
  l_bom_type varchar2(40);
  l_type varchar2(40);
  l_manager varchar2(40);
  l_lob varchar2(100);
  l_from_clause varchar2(1000);
  l_where_clause varchar2(1000);
  l_group_by_clause varchar2(1000);
  l_currency_rate VARCHAR2(30);
BEGIN

	ENI_DBI_UTIL_PKG.get_parameters( p_page_parameter_tbl
                                 , l_period_type
                                 , l_period_bitand
                                 , l_view_by
                                 , l_as_of_date
                                 , l_prev_as_of_date
                                 , l_report_start
                                 , l_cur_period
                                 , l_days_into_period
                                 , l_comp_type
                                 , l_category
                                 , l_item
                                 , l_org
                                 , l_id_column
                                 , l_order_by
                                 , l_drill
                                 , l_status
                                 , l_priority
                                 , l_reason
                                 , l_lifecycle_phase
                                 , l_currency
                                 , l_bom_type
                                 , l_type
                                 , l_manager
                                 , l_lob
                                 );

	IF(l_order_by like '%DESC%')
	THEN
		l_order_by:=' report_period_start_date desc ';
	ELSE
		l_order_by:=' report_period_start_date asc ';
	END IF;

    l_period_type := '''' || l_period_type || '''';
    l_comp_type := '''' || l_comp_type || '''';

  -- Set currency rate based on currency chosen by user
    l_currency_rate :=
      CASE l_currency
        WHEN ENI_DBI_UTIL_PKG.get_curr_sec
                THEN 'secondary_currency_rate'   -- secondary global currency
        ELSE 'primary_currency_rate'             -- primary global currency (default)
      END;

 -- Eventually get this string from the util package

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

if ((l_org IS NULL OR l_org = '' OR l_org = 'All') or (l_item IS NULL OR l_item = '' OR l_item = 'All')) then
l_sql_stmt := 'select null VIEWBY,
          NULL VIEWBYID,
          null ENI_MEASURE1, -- curr mtl_cost for table
          null ENI_MEASURE3, -- curr mtl_ovhd_cost for table
          null ENI_MEASURE4, -- curr res_cost for table
          null ENI_MEASURE5, -- curr osp_cost for table
          null ENI_MEASURE6, -- curr ovhd_cost for table
	  NULL ENI_MEASURE10, -- curr unit_cost for table
	  null ENI_MEASURE9 -- pct_change for table
        from sys.dual' ;
else
 l_sql_stmt :=
  'select name VIEWBY,
          1 VIEWBYID,
          curr_mtl_cost ENI_MEASURE1,
          curr_mtl_ovhd_cost ENI_MEASURE3,
          curr_res_cost ENI_MEASURE4,
          curr_osp_cost ENI_MEASURE5,
          curr_ovhd_cost ENI_MEASURE6,
	  curr_item_cost ENI_MEASURE10,
          prev_item_cost ENI_MEASURE9
	  -- removed the calculation of change % for Bug# 3933564
    from  ( select name, report_period_start_date start_date,
                    sum(case when curr_or_prior_period = ''C''
                    then material_cost * ' || l_currency_rate || '
		              else null
		              end) curr_mtl_cost,
                   sum(case when curr_or_prior_period = ''C''
                       then material_overhead_cost * ' || l_currency_rate || '
 		       else null
		       end) curr_mtl_ovhd_cost,
                   sum(case when curr_or_prior_period = ''C''
                       then resource_cost * ' || l_currency_rate || '
		       else null
		       end) curr_res_cost,
                   sum(case when curr_or_prior_period = ''C''
                       then outside_processing_cost * ' || l_currency_rate || '
		       else null
		       end) curr_osp_cost,
                   sum(case when curr_or_prior_period = ''C''
                       then overhead_cost * ' || l_currency_rate || '
		       else null
		       end) curr_ovhd_cost,
              sum(case when curr_or_prior_period = ''C''
                       then item_cost * ' || l_currency_rate || '
                       else null
                       end) curr_item_cost,
                   sum(case when curr_or_prior_period = ''P''
                       then item_cost * ' || l_currency_rate || '
		       else null
                       end) prev_item_cost
    from
     (select t.*, cost.*,
       rank() over
	(partition by t.curr_or_prior_period, t.report_period_start_date
	 order by effective_date DESC) r
      from
        (select TO_CHAR(&' || 'BIS_CURRENT_ASOF_DATE + offset , ''dd-Mon-yyyy'') AS name,
		''C'' AS curr_or_prior_period,
		&' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
	       		AS report_period_start_date,
		&' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
	       AS period_start_date,
           &' || 'BIS_CURRENT_ASOF_DATE + offset AS period_end_date
     	from fii_time_rolling_offsets
     	where period_type = :l_period_type
            AND comparison_type = :l_comp_type
     	union all
     	select TO_CHAR(&' || 'BIS_CURRENT_ASOF_DATE + offset , ''dd-Mon-yyyy'') AS name,
		''P'' AS curr_or_prior_period,
		&' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
	       		AS report_period_start_date,
		&' || 'BIS_PREVIOUS_ASOF_DATE + offset + start_date_offset
	       		AS period_start_date,
                &' || 'BIS_PREVIOUS_ASOF_DATE  + offset AS period_end_date
     	from fii_time_rolling_offsets
     	where period_type = :l_period_type
            AND comparison_type = :l_comp_type)t,
	 eni_dbi_item_cost_f cost
         where cost.inventory_item_id (+) = :l_item
         and cost.organization_id (+) = :l_org
         and cost.effective_date (+) <= period_end_date) t
    WHERE r=1
    GROUP BY name, report_period_start_date
    ORDER BY ' || l_order_by || ' )';
    --removed the binding for Bug # 3930862

end if;

  x_custom_sql := l_sql_stmt;
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':l_item';
  l_custom_rec.attribute_value := replace(l_item,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(1) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':l_org';
  l_custom_rec.attribute_value := replace(l_org,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(2) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':l_period_type';
  l_custom_rec.attribute_value := replace(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(3) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':l_comp_type';
  l_custom_rec.attribute_value := replace(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(4) := l_custom_rec;

END get_sql;

END ENI_DBI_UCO_PKG;

/
