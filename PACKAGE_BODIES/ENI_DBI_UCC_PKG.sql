--------------------------------------------------------
--  DDL for Package Body ENI_DBI_UCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_UCC_PKG" AS
/* $Header: ENIUCCPB.pls 120.0 2005/05/26 19:33:13 appldev noship $ */


-- Returns query for the Cost by Cost Element report
PROCEDURE get_sql ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                               , x_custom_sql OUT NOCOPY VARCHAR2
                               , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  -- SQL statement for report
  l_sql_stmt             VARCHAR2(32000);

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
  l_from_clause varchar2(1000);
  l_where_clause varchar2(1000);
  l_group_by_clause varchar2(1000);

  l_comp_where          VARCHAR2(100);
  l_view_by_column      VARCHAR2(30);
  l_item_where          VARCHAR2(100);

  l_status varchar2(40);
  l_priority varchar2(40);
  l_reason varchar2(40);
  l_lifecycle_phase varchar2(40);
  l_currency  varchar2(40);
  l_currency_rate VARCHAR2(30);
  l_bom_type varchar2(40);
  l_type varchar2(40);
  l_manager varchar2(40);
  l_lob varchar2(100);
  x varchar2(200);
  y varchar2(200);

  x_mtl_cost number;
  x_mo_cost number;
  x_res_cost number;
  x_osp_cost number;
  x_ovhd_cost number;
  x_unit_cost number;
  x_exists number;

  x_prev_mtl_cost number;
  x_prev_mo_cost number;
  x_prev_res_cost number;
  x_prev_osp_cost number;
  x_prev_ovhd_cost number;
  x_prev_unit_cost number;
  x_prev_exists number;
  l_total_pct_change number;


  l_org_where           VARCHAR2(1000);
  l_cat_where           VARCHAR2(1000);

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

  -- Set currency rate based on currency chosen by user

    l_currency_rate :=
      CASE l_currency
        WHEN ENI_DBI_UTIL_PKG.get_curr_sec
		THEN 'secondary_currency_rate'   -- secondary global currency
        ELSE 'primary_currency_rate'             -- primary global currency (default)
      END;

if ((l_org IS NULL OR l_org = '' OR l_org = 'All') or (l_item IS NULL OR l_item = '' OR l_item = 'All')) then
l_sql_stmt := 'select null VIEWBY,
          null ENI_MEASURE1, -- elemental_cost for table
          null ENI_MEASURE2, -- change for table
          null ENI_MEASURE3, -- pct_of_total for table and graph
          null ENI_MEASURE4,
          null ENI_MEASURE5,
          null ENI_MEASURE6
        from sys.dual' ;
else

    l_period_type := '''' || l_period_type || '''';
    l_comp_type := '''' || l_comp_type || '''';

    l_sql_stmt := 'select cost_element VIEWBY,
   		decode(cost_element_id, 1, curr_mtl_cost,
		2, curr_mtl_ovhd_cost,
		3, curr_res_cost,
		4, curr_osp_cost,
		5, curr_ovhd_cost) ENI_MEASURE1,
	   	decode(cost_element_id, 1,
		100*(curr_mtl_cost-prev_mtl_cost)/abs(prev_mtl_cost),
		2, 100*(curr_mtl_ovhd_cost-prev_mtl_ovhd_cost)/abs(prev_mtl_ovhd_cost),
		3, 100*(curr_res_cost-prev_res_cost)/abs(prev_res_cost),
		4, 100*(curr_osp_cost-prev_osp_cost)/abs(prev_osp_cost),
		5, 100*(curr_ovhd_cost-prev_ovhd_cost)/abs(prev_ovhd_cost)) ENI_MEASURE2,
		decode(cost_element_id, 1, 100*(curr_mtl_cost/curr_item_cost_for_div),
		2, 100*(curr_mtl_ovhd_cost/curr_item_cost_for_div),
		3, 100*(curr_res_cost/curr_item_cost_for_div),
		4, 100*(curr_osp_cost/curr_item_cost_for_div),
		5, 100*(curr_ovhd_cost/curr_item_cost_for_div)) ENI_MEASURE3,
		curr_item_cost ENI_MEASURE4,
		Round(100*(curr_item_cost-prev_item_cost_for_div)/abs(prev_item_cost_for_div),2) ENI_MEASURE5,
		decode(curr_item_cost,null,null,0,null,100) ENI_MEASURE6
 		from (select report_period_start_date,
                    	sum(case when curr_or_prior_period = ''C''
                    	then material_cost * ' || l_currency_rate || '
                	else null
                	end) curr_mtl_cost,
                   	sum(case when curr_or_prior_period = ''P''
                       	then decode(material_cost,0,null,
                            material_cost * ' || l_currency_rate || ')
                       	else null
                       	end) prev_mtl_cost,
                   	sum(case when curr_or_prior_period = ''C''
                       	then material_overhead_cost * ' || l_currency_rate || '
          		else null
         		end) curr_mtl_ovhd_cost,
                	sum(case when curr_or_prior_period = ''P''
                       	then decode(material_overhead_cost,0,null,
                            material_overhead_cost * ' || l_currency_rate || ')
                       	else null
                       	end) prev_mtl_ovhd_cost,
                   	sum(case when curr_or_prior_period = ''C''
                       	then resource_cost * ' || l_currency_rate || '
         		else null
         		end) curr_res_cost,
                   	sum(case when curr_or_prior_period = ''P''
                       	then decode(resource_cost,0,null,
                            resource_cost * ' || l_currency_rate || ')
                       	else null
                       	end) prev_res_cost,
                   	sum(case when curr_or_prior_period = ''C''
                       	then outside_processing_cost * ' || l_currency_rate || '
         		else null
         		end) curr_osp_cost,
                   	sum(case when curr_or_prior_period = ''P''
                       	then decode(outside_processing_cost,0,null,
                            outside_processing_cost * ' || l_currency_rate || ')
                       	else null
                       	end) prev_osp_cost,
                   	sum(case when curr_or_prior_period = ''C''
                       	then overhead_cost * ' || l_currency_rate || '
         		else null
         		end) curr_ovhd_cost,
                   	sum(case when curr_or_prior_period = ''P''
                       	then decode(overhead_cost,0,null,
                            overhead_cost * ' || l_currency_rate || ')
                       	else null
                       	end) prev_ovhd_cost,
         		sum(case when curr_or_prior_period = ''C''
                       	then decode(item_cost,0,null,
                            item_cost * ' || l_currency_rate || ')
         		else null
         		end) curr_item_cost_for_div,
         		sum(case when curr_or_prior_period = ''C''
                       	then item_cost * ' || l_currency_rate || '
         		else null
         		end) curr_item_cost,
         		sum(case when curr_or_prior_period = ''P''
                       	then decode(item_cost,0,null,
                            item_cost * ' || l_currency_rate || ')
         		else null
         		end) prev_item_cost_for_div,
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
        	(select ''C'' AS curr_or_prior_period,
                 &' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
                        AS report_period_start_date,
                 &' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
               		AS period_start_date,
           	 &' || 'BIS_CURRENT_ASOF_DATE + offset AS period_end_date
        	from fii_time_rolling_offsets
        	where period_type = :l_period_type
            	AND comparison_type = :l_comp_type
        	and offset = 0
		union all
        	select ''P'' AS curr_or_prior_period,
                 &' || 'BIS_CURRENT_ASOF_DATE + offset + start_date_offset
                        AS report_period_start_date,
                 &' || 'BIS_PREVIOUS_ASOF_DATE + offset + start_date_offset
                        AS period_start_date,
                 &' || 'BIS_PREVIOUS_ASOF_DATE  + offset AS period_end_date
        	from fii_time_rolling_offsets
		where period_type = :l_period_type
                AND comparison_type = :l_comp_type
                and offset = 0) t,
		eni_dbi_item_cost_f cost
        	where  cost.inventory_item_id  = :l_item
         	  and   cost.organization_id  = :l_org
           	  and cost.effective_date  <= period_end_date) cost
		where r=1
		group by report_period_start_date),
     		cst_cost_elements cost_elements '
		|| '&' || 'ORDER_BY_CLAUSE';
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



END ENI_DBI_UCC_PKG;

/
