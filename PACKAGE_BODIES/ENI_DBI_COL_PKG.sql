--------------------------------------------------------
--  DDL for Package Body ENI_DBI_COL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_COL_PKG" AS
/*$Header: ENICOLPB.pls 120.0 2005/05/26 19:34:21 appldev noship $*/

PROCEDURE get_sql
(
  p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
        , x_custom_sql        OUT NOCOPY VARCHAR2
        , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
) IS

l_custom_rec				BIS_QUERY_ATTRIBUTES;
l_period_type				VARCHAR2(1000);
l_period_bitand				NUMBER;
l_view_by				VARCHAR2(1000);
l_as_of_date				DATE;
l_prev_as_of_date			DATE;
l_report_start				DATE;
l_cur_period				NUMBER;
l_days_into_period			NUMBER;
l_comp_type				VARCHAR2(100);
l_category				VARCHAR2(100);
l_item					VARCHAR2(100);
l_org					VARCHAR2(100);
l_id_column				VARCHAR2(100);
l_order_by				VARCHAR2(1000);
l_drill					VARCHAR2(100);
l_status				VARCHAR2(100);
l_priority				VARCHAR2(100);
l_reason				VARCHAR2(100);
l_lifecycle_phase			VARCHAR2(100);
l_currency				VARCHAR2(100);
l_bom_type				VARCHAR2(100);
l_type					VARCHAR2(100);
l_manager				VARCHAR2(100);
l_lob					VARCHAR2(1000);
l_org_where 				VARCHAR2(1000);
l_cat_where 				VARCHAR2(1000);
l_item_where				VARCHAR2(1000);
l_priority_where			VARCHAR2(1000);
l_reason_where				VARCHAR2(1000);
l_type_where				VARCHAR2(1000);
l_group_by_clause			VARCHAR2(1000);
l_priority_from				VARCHAR2(1000);
l_reason_from				VARCHAR2(1000);
l_status_where				VARCHAR2(1000);
l_report				VARCHAR2(1000);
l_start_date				DATE;
l_end_date				DATE;
l_impl_where				VARCHAR2(1000);
l_canc_where				VARCHAR2(1000);
l_past_where				VARCHAR2(1000);
l_open_where				VARCHAR2(1000);
l_final_where				VARCHAR2(1000);
l_new_where				VARCHAR2(1000);
l_priority_value			VARCHAR2(1000);
l_reason_value			VARCHAR2(1000);
l_oa_url				VARCHAR2(1000);
BEGIN

	l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
	x_custom_output := bis_query_attributes_tbl();

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

	get_col_parameters( p_page_parameter_tbl
				, l_report
				, l_start_date
				, l_end_date
		);

	if(l_start_date is null)
	then
		l_start_date:= l_as_of_date - l_days_into_period ;

	end if;
	if(l_end_date is null)
	then
		l_end_date:= l_as_of_date;
	end if;

	-- l_oa_url:='OA.jsp?OAFunc=ENG_CHANGE_DETAIL_PAGE&changeId=';
	-- Bug : 3560677.Modified the drill URL

        l_oa_url:='pFunctionName=ENG_CHANGE_SUMMARY_PAGE&OAPB=ENI_CHG_MGMT_PROD_BRNDNG_TEXT';

-- Bug : 3487387 changed the where clauses . Bug caused by the fix of 3472006.
	l_impl_where:=' and eco.implementation_date > :START_DATE and eco.implementation_date <= :END_DATE';
	l_canc_where:=' and eco.cancellation_date > :START_DATE and eco.cancellation_date <= :END_DATE';
	l_new_where:= ' and eco.CREATION_date > :START_DATE and eco.creation_date <=  :END_DATE ';
	l_open_where:=' and eco.creation_date <= :END_DATE
			and nvl(eco.implementation_date,:END_DATE +1)  > :END_DATE
			and nvl(eco.cancellation_date,:END_DATE +1)  >  :END_DATE ';
	l_past_where:=' and eco.need_by_date is not null
			and eco.need_by_date < :END_DATE
			AND NVL(IMPLEMENTATION_DATE, :END_DATE +1) > greatest(ECO.NEED_BY_DATE,:END_DATE)
			AND NVL(CANCELLATION_DATE,:END_DATE +1) > greatest(ECO.NEED_BY_DATE,:END_DATE)';

	IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
	THEN
		l_priority_from:=' ,eni_chg_mgmt_priority_v prio ';
		l_priority_value:=' prio.value ';
		l_priority_where:= ' and prio.id(+)=eco.priority_code ';
	ELSE
		l_priority_from:=' ,eni_chg_mgmt_priority_v prio ';
		l_priority_value:=' prio.value ';
		l_priority_where := ' and prio.id(+)=eco.priority_code and eco.priority_code = :PRIORITY_ID';
	END IF;

	IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
	THEN
		l_type_where := '';

	ELSE
		l_type_where := ' and eco.change_order_type_id = :TYPE_ID ';
	END IF;

--added for Bug 3435046

	IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
	THEN
		l_reason_from:=' ,eni_chg_mgmt_reason_v rea ';
		l_reason_value:=' rea.value ';
		l_reason_where:= ' and rea.id(+)=eco.reason_code ';
	ELSE
		l_reason_from:=' ,eni_chg_mgmt_reason_v rea ';
		l_reason_value:=' rea.value ';
		l_reason_where := ' and rea.id(+)=eco.reason_code and eco.reason_code = :REASON_ID';
	END IF;

--added for Bug 3435046

	IF (l_status IS NULL OR l_status = '' OR l_status = 'All')
	THEN
		l_status_where := '';

	ELSE
		l_status_where := ' and eco.status_type  = :STATUS_ID ';
	END IF;

	IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
	THEN
		l_org_where := '';

	ELSE
		l_org_where := ' AND eco.organization_id = :ORGANIZATION_ID ';
	END IF;

	if(l_item= 'All' or l_item ='' or l_item is null)
	then
		x_custom_sql :=
		      '
				SELECT
					NULL as ENI_MEASURE1,
					NULL as ENI_MEASURE2,
					NULL as ENI_MEASURE3,
					NULL as ENI_MEASURE4,
					NULL as ENI_MEASURE20,
					NULL as ENI_MEASURE5,
					NULL as ENI_MEASURE6,
					NULL as ENI_MEASURE7,
					NULL as ENI_MEASURE8,
					NULL as ENI_MEASURE9,
					NULL as ENI_MEASURE10,
					NULL as ENI_MEASURE11,
					NULL as ENI_MEASURE12,
					NULL as ENI_MEASURE13,
					NULL as ENI_MEASURE14,
					NULL as ENI_ATTRIBUTE2

				FROM
					DUAL
						';
				return;

	else
		l_item_where:=' and eco.item_id = :ITEM_ID';
		if(l_report='NEW')
		then
			l_final_where:=l_new_where;
		elsif(l_report='IMPL')
		then
			l_final_where:=l_impl_where;
		elsif(l_report='OPEN')
		then
			l_final_where:=l_open_where;
		elsif(l_report='PAST')
		then
			l_final_where:=l_past_where;
		elsif(l_report='CANC')
		then
			l_final_where:=l_canc_where;
		end if;
	end if;

/*	Bug : 3221341 :  Modified the select clause to calculate the Days Open only for Non-Implementated
			and Non-Cancelled Change Orders */

	x_custom_sql :=
		'
			SELECT
				change_notice as ENI_MEASURE1,
				eco.description as ENI_MEASURE2,
				stat.value as ENI_MEASURE3,
				'||l_priority_value||' as ENI_MEASURE4,
				'||l_reason_value||' as ENI_MEASURE20,
				typ.value as ENI_MEASURE5,
				eco.creation_date as ENI_MEASURE6,
				need_by_date as ENI_MEASURE7,
				(case when :END_DATE < eco.implementation_date
					then null else eco.implementation_date end )as ENI_MEASURE8,
				( case when :END_DATE < eco.implementation_date
					then null
					else (eco.implementation_date  - eco.creation_date +1) end ) as ENI_MEASURE9,
				( case when nvl(nvl(cancellation_date,implementation_date),:NVL_DATE) > :END_DATE
					then (:END_DATE - eco.creation_date)
					else null end ) as ENI_MEASURE10,
					nvl(ass.party_name,'' '') as ENI_MEASURE11,
				:END_DATE - eco.need_by_date  as ENI_MEASURE12,
				(case when :END_DATE  < eco.cancellation_date
					then null else eco.cancellation_date end )as ENI_MEASURE13,
				:OA_URL||''&retainAM=N&changeId=''|| TO_CHAR(ECO.CHANGE_ID) AS ENI_MEASURE14 ,
				ECO.CHANGE_ID as ENI_ATTRIBUTE2
			FROM
				eni_dbi_co_num_mv eco,
				hz_parties ass,
				eni_chg_mgmt_type_v typ,
				eni_chg_mgmt_status_v stat
				'||l_priority_from||'
				'||l_reason_from||'
			WHERE
				ass.party_id(+) = eco.assignee_id
				and eco.change_order_type_id = typ.id
				and eco.status_type = stat.id
				'|| l_final_where||'
				'|| l_reason_where ||'
				'|| l_type_where   ||'
				'|| l_priority_where ||'
				'|| l_status_where ||'
				'|| l_item_where ||'
				'|| l_org_where||'
			ORDER BY
					'||l_order_by;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':STATUS_ID';
		  l_custom_rec.attribute_value := replace(l_status,'''');
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
		  x_custom_output(1) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':PRIORITY_ID';
		  l_custom_rec.attribute_value := l_priority;
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
		  x_custom_output(2) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':TYPE_ID';
		  l_custom_rec.attribute_value := REPLACE(l_type,'''');
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
		  x_custom_output(3) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':REASON_ID';
		  l_custom_rec.attribute_value := l_reason;
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
		  x_custom_output(4) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':ORGANIZATION_ID';
		  l_custom_rec.attribute_value := REPLACE(l_org,'''');
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
		  x_custom_output(5) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':ITEM_ID';
		  l_custom_rec.attribute_value := l_item;
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
		  x_custom_output(6) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':NVL_DATE';
		  l_custom_rec.attribute_value := '31/12/3000';
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
		  x_custom_output(7) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':OA_URL';
		  l_custom_rec.attribute_value := l_oa_url;
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
		  x_custom_output(8) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':START_DATE';
		  l_custom_rec.attribute_value := to_char(l_start_date,'DD/MM/YYYY');
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
		  x_custom_output(9) := l_custom_rec;

		  x_custom_output.extend;
		  l_custom_rec.attribute_name := ':END_DATE';
		  l_custom_rec.attribute_value := to_char(l_end_date,'DD/MM/YYYY');
		  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
		  x_custom_output(10) := l_custom_rec;
END GET_SQL;

PROCEDURE GET_COL_PARAMETERS (
                         p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                          p_report  		 OUT NOCOPY VARCHAR2,
                          p_start_date           OUT NOCOPY DATE,
                          p_end_date             OUT NOCOPY DATE
			  ) IS

BEGIN

  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'start_date' THEN
	     p_start_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
       ELSIF p_page_parameter_tbl(i).parameter_name = 'end_date' THEN
	     p_end_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
       ELSIF p_page_parameter_tbl(i).parameter_name = 'REPORTED' THEN
	     p_report := p_page_parameter_tbl(i).parameter_value;
       END IF;
    END LOOP;
  END IF;
END GET_COL_PARAMETERS;

END ENI_DBI_COL_PKG;

/
