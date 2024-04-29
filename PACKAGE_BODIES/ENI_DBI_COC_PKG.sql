--------------------------------------------------------
--  DDL for Package Body ENI_DBI_COC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_COC_PKG" AS
/*$Header: ENICOCPB.pls 120.1 2006/03/16 06:22:24 pgopalar noship $*/
PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_custom_rec		BIS_QUERY_ATTRIBUTES;
l_err_msg		VARCHAR2(1000);
l_period_type		VARCHAR2(1000);
l_period_bitand		NUMBER;
l_view_by		VARCHAR2(1000);
l_as_of_date		DATE;
l_prev_as_of_date	DATE;
l_report_start		DATE;
l_cur_period		NUMBER;
l_days_into_period	NUMBER;
l_comp_type		VARCHAR2(100);
l_category		VARCHAR2(100);
l_item			VARCHAR2(100);
l_org			VARCHAR2(100);
l_id_column		VARCHAR2(100);
l_order_by		VARCHAR2(1000);
l_drill			VARCHAR2(100);
l_status		VARCHAR2(100);
l_priority		VARCHAR2(100);
l_reason		VARCHAR2(100);
l_lifecycle_phase	VARCHAR2(100);
l_currency		VARCHAR2(100);
l_bom_type		VARCHAR2(100);
l_type			VARCHAR2(100);
l_manager		VARCHAR2(100);
l_temp			VARCHAR2(1000);
l_lob			VARCHAR2(1000);
l_comp_where		VARCHAR2(1000);
l_org_where 		VARCHAR2(1000);
l_cat_where 		VARCHAR2(1000);
l_item_where		VARCHAR2(1000);
l_priority_where	VARCHAR2(1000);
l_reason_where		VARCHAR2(1000);
l_status_where		VARCHAR2(200);
l_type_where		VARCHAR2(1000);
l_from_clause		VARCHAR2(1000);
l_where_clause		VARCHAR2(1000);
l_group_by_clause	VARCHAR2(1000);
l_priority_from		VARCHAR2(1000);
l_type_from		VARCHAR2(1000);
l_reason_from		VARCHAR2(1000);
l_lookup_from		VARCHAR2(1000);
l_lookup_outer_where	VARCHAR2(1000);
l_reason_outer_where	VARCHAR2(1000);
l_priority_outer_where	VARCHAR2(1000);
l_type_outer_where	VARCHAR2(1000);
l_status_outer_where	VARCHAR2(200);
l_lookup_value		VARCHAR2(100);
l_impl_url		VARCHAR2(1000);
l_description		VARCHAR2(1000);
BEGIN

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



l_impl_url:='''pFunctionName=ENI_DBI_COL_IMPL_R&pCustomView=ENI_DBI_COL_CV2&REPORTED=IMPL&VIEW_BY=VIEW_BY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

	IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
	THEN
		l_priority_where := ' and edcs.priority_code is null ';
		l_priority_outer_where := '';
	ELSE
		l_priority_where := ' and edcs.priority_code= :PRIORITY';
		l_priority_outer_where := ' and edcs.priority_code = :PRIORITY';
	END IF;

	IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
	THEN
		l_type_where := ' and edcs.change_order_type_id is null ';
		l_type_outer_where := '';
	ELSE
		l_type_where := ' and edcs.change_order_type_id= :TYPE';
		l_type_outer_where := ' and edcs.change_order_type_id= :TYPE';
	END IF;


	IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
	THEN
		l_reason_where := ' and edcs.reason_code is null ';
		l_reason_outer_where := '';
	ELSE
		l_reason_where := ' and edcs.reason_code = :REASON';
		l_reason_outer_where := ' and edcs.reason_code = :REASON';
	END IF;

	IF (l_item IS NULL OR l_item = '' OR l_item = 'All')
	THEN

		l_item_where := '';

	ELSE
		l_item_where := ' and edcs.item_id = :ITEM';
	END IF;

	IF (l_status IS NULL OR l_status = '' OR l_status = 'All')
	THEN
		l_status_where := ' and edcs.status_type is null ';
		l_status_outer_where := '';
	ELSE
		l_status_where := ' and edcs.status_type = :STATUS';
		l_status_outer_where := ' and edcs.status_type = :STATUS';
	END IF;


	IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
	THEN
		l_org_where := '';
	ELSE
		l_org_where := ' AND edcs.organization_id = :ORG';
	END IF;

	l_lookup_from:=' ,eni_chg_mgmt_priority_v eiv';
	l_lookup_outer_where:=' and edcs.priority_code is not null
				and edcs.priority_code = eiv.id(+)
				' || l_priority_outer_where || '
				' || l_type_where || '
				' || l_status_where || '
				' || l_reason_where;
	l_lookup_value := 'priority_code';
	l_description :=' null as ENI_MEASURE50 ';

	IF (l_view_by like '%TYPE%')
	THEN
		l_lookup_from:=' , eni_chg_mgmt_type_v eiv ';
		l_lookup_outer_where:=' and edcs.change_order_type_id is not null
					and edcs.change_order_type_id = eiv.id
					' || l_type_outer_where || '
					' || l_priority_where || '
					' || l_status_where || '
					' || l_reason_where;
		l_lookup_value := 'change_order_type_id';
		l_description :=' null as ENI_MEASURE50 ';

	ELSIF (l_view_by like '%REASON%')
	THEN
		l_lookup_from:=',eni_chg_mgmt_reason_v eiv';
		l_lookup_outer_where:=' and edcs.reason_code is not null
					and edcs.reason_code = eiv.id(+)
					' || l_reason_outer_where || '
					' || l_priority_where || '
					' || l_status_where || '
					' || l_type_where;
		l_lookup_value := 'reason_code';
		l_description :=' null as ENI_MEASURE50 ';

	ELSIF (l_view_by like '%STATUS%')
	THEN
		l_lookup_from:=',eni_chg_mgmt_status_v eiv';
		l_lookup_outer_where:=' and edcs.status_type is not null
					and edcs.status_type = eiv.id
					' || l_status_outer_where || '
					' || l_priority_where || '
					' || l_reason_where || '
					' || l_type_where;
		l_lookup_value := 'status_type';
		l_description :=' null as ENI_MEASURE50 ';

	ELSIF (l_view_by like 'ITEM+ENI_ITEM_ORG')
	THEN
			l_lookup_from:=',eni_item_org_v eiv';
			l_lookup_outer_where:=' and edcs.item_id = eiv.inventory_item_id
						and edcs.organization_id = eiv.organization_id
					' || l_reason_where || '
					' || l_priority_where || '
					' || l_status_where || '
					' || l_type_where;
			l_description :=' eiv.description as ENI_MEASURE50 ';

	END IF;


	IF (l_view_by not like '%ITEM%') AND (l_item IS NULL OR l_item = '' OR l_item = 'All')
	THEN
			x_custom_sql :=
				'SELECT
					NULL AS VIEWBY,
					NULL AS ENI_MEASURE50,
					NULL AS ENI_MEASURE1,
					NULL AS ENI_MEASURE9,
					NULL AS ENI_MEASURE3,
					NULL AS ENI_MEASURE6,
					NULL AS ENI_MEASURE7,
					NULL AS ENI_MEASURE8,
					NULL AS ENI_MEASURE16,
					NULL AS ENI_MEASURE17,
					NULL AS ENI_MEASURE18,
					NULL AS ENI_MEASURE19,
					NULL AS ENI_MEASURE51,
					NULL AS ENI_MEASURE52,
					NULL AS ENI_MEASURE53,
					NULL AS ENI_MEASURE54,
					NULL AS ENI_MEASURE55,
					NULL AS ENI_MEASURE56,
					NULL AS ENI_MEASURE57,
					NULL AS ENI_MEASURE58,
					NULL AS ENI_MEASURE59,
					NULL AS ENI_MEASURE60,
					NULL AS ENI_MEASURE62
				FROM
					DUAL';
					RETURN;

	ELSIF (l_item IS NOT NULL AND l_item <> '' AND l_item <> 'All') THEN
		l_item_where := ' AND edcs.item_id =  :ITEM'; --Bug 5083894
	END IF;

	x_custom_sql :=  '
		SELECT
			 t.VALUE as VIEWBY
			,ENI_MEASURE50
			,t.id as VIEWBYID
			,ENI_MEASURE1
			,ENI_MEASURE9
			,ENI_MEASURE93/DECODE(ENI_MEASURE89,0,NULL,ENI_MEASURE89) as ENI_MEASURE3
			,ENI_MEASURE96/DECODE(ENI_MEASURE88,0,NULL,ENI_MEASURE88) as ENI_MEASURE6
			,ENI_MEASURE97/DECODE(ENI_MEASURE1,0,NULL,ENI_MEASURE1) as ENI_MEASURE7
			,ENI_MEASURE98/DECODE(ENI_MEASURE9,0,NULL,ENI_MEASURE9) as ENI_MEASURE8
			,ENI_MEASURE16
			,ENI_MEASURE17
			,ENI_MEASURE18
			,ENI_MEASURE19';

-- No need to compute Grand Total if view by is on "Item"  #Purushothaman

	IF l_view_by not like 'ENI_ITEM_ORG%' THEN

		x_custom_sql := x_custom_sql ||
			',SUM(ENI_MEASURE1) OVER() as ENI_MEASURE51
			,((SUM(ENI_MEASURE1) OVER() - SUM(ENI_MEASURE9) OVER())
				/DECODE(SUM(ENI_MEASURE9) OVER(),0,NULL,SUM(ENI_MEASURE9) OVER()))*100
			 as ENI_MEASURE52
			,(SUM(ENI_MEASURE93) OVER())
				/DECODE(SUM(ENI_MEASURE89) OVER(),0,NULL,SUM(ENI_MEASURE89) OVER())
			 as ENI_MEASURE53
			,(SUM(ENI_MEASURE96) OVER())
			   /DECODE(SUM(ENI_MEASURE88) OVER(),0,NULL,SUM(ENI_MEASURE88) OVER())
			 as ENI_MEASURE54
			,(SUM(ENI_MEASURE97) OVER())
				/DECODE(SUM(ENI_MEASURE1) OVER(),0,NULL,SUM(ENI_MEASURE1) OVER())
			 as ENI_MEASURE55
			,((
				(
				  (SUM(ENI_MEASURE97) OVER())
				  /DECODE(SUM(ENI_MEASURE1) OVER(),0,NULL,SUM(ENI_MEASURE1) OVER())
				 )
			  -
				(
				  (SUM(ENI_MEASURE98) OVER())
				  /DECODE(SUM(ENI_MEASURE9) OVER(),0,NULL,SUM(ENI_MEASURE9) OVER())
				 )
			  )
			  /DECODE(
						(
						  (SUM(ENI_MEASURE98) OVER())
						  /DECODE(SUM(ENI_MEASURE9) OVER(),0,NULL,SUM(ENI_MEASURE9) OVER())
						)
						,0
						,NULL
						,(
						  (SUM(ENI_MEASURE98) OVER())
						  /DECODE(SUM(ENI_MEASURE9) OVER(),0,NULL,SUM(ENI_MEASURE9) OVER())
						)
					 )
			 ) * 100
			 as ENI_MEASURE56
			,SUM(ENI_MEASURE16) OVER() as ENI_MEASURE57
			,SUM(ENI_MEASURE17) OVER() as ENI_MEASURE58
			,SUM(ENI_MEASURE18) OVER() as ENI_MEASURE59
			,SUM(ENI_MEASURE19) OVER() as ENI_MEASURE60';
		ELSE
		x_custom_sql := x_custom_sql ||
		   ',NULL as ENI_MEASURE51
			,NULL as ENI_MEASURE52
			,NULL as ENI_MEASURE53
			,NULL as ENI_MEASURE54
			,NULL as ENI_MEASURE55
			,NULL as ENI_MEASURE56
			,NULL as ENI_MEASURE57
			,NULL as ENI_MEASURE58
			,NULL as ENI_MEASURE59
			,NULL as ENI_MEASURE60';
		END IF;

	x_custom_sql := x_custom_sql ||
		',(CASE WHEN ENI_MEASURE1 IS NULL OR ENI_MEASURE1=0
				   THEN NULL
				   ELSE  '||l_impl_url||'
			   END
			  )  as ENI_MEASURE62
		FROM
		(
			SELECT
			edcs.VALUE as VALUE
			,edcs.ID as ID
			,ENI_MEASURE50
			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	edcs.IMPLEMENTED_SUM
			ELSE	null
			END)	as ENI_MEASURE1

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
			THEN	edcs.IMPLEMENTED_SUM
			ELSE	null
			END)	as ENI_MEASURE9

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	NVL(edcs.CREATE_TO_APPROVE_SUM,0)
			ELSE	null
			END)	as ENI_MEASURE93

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	NVL(edcs.CREATE_TO_APPROVE_CNT,0)
			ELSE	null
			END)	as ENI_MEASURE89

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	NVL(edcs.APPROVE_TO_IMPL_SUM,0)
			ELSE	null
			END)	as ENI_MEASURE96

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	NVL(edcs.APPROVE_TO_IMPL_CNT,0)
			ELSE	null
			END)	as ENI_MEASURE88

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	NVL(edcs.CYCLE_TIME_SUM,0)
			ELSE	null
			END)	as ENI_MEASURE97

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
			THEN	NVL(edcs.CYCLE_TIME_SUM,0)
			ELSE	null
			END)	as ENI_MEASURE98

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	edcs.BUCKET1_SUM
			ELSE	null
			END)	as ENI_MEASURE16

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	edcs.BUCKET2_SUM
			ELSE	null
			END)	as ENI_MEASURE17

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	edcs.BUCKET3_SUM
			ELSE	null
			END)	as ENI_MEASURE18

			,SUM(CASE WHEN
				ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
			THEN	edcs.BUCKET4_SUM
			ELSE	null
			END)	as ENI_MEASURE19
			FROM
			(SELECT edcs.IMPLEMENTED_SUM
					,edcs.TIME_ID
					,edcs.PERIOD_TYPE_ID
					,edcs.CREATE_TO_APPROVE_SUM
					,edcs.CREATE_TO_APPROVE_CNT
					,edcs.APPROVE_TO_IMPL_SUM
					,edcs.APPROVE_TO_IMPL_CNT
					,edcs.CYCLE_TIME_SUM
					,edcs.BUCKET1_SUM
					,edcs.BUCKET2_SUM
					,edcs.BUCKET3_SUM
					,edcs.BUCKET4_SUM
					,eiv.value
					,eiv.id
					,'||l_description || '
						from ENI_DBI_CO_SUM_MV edcs
						' || l_lookup_from || '
					where 1=1
						' || l_item_where ||'
						' || l_org_where || '
						' || l_cat_where || '
						' || l_lookup_outer_where || '
				) edcs
				, fii_time_structures ftrs
				WHERE 1=1
					AND
					(
						ftrs.report_date = '|| '&' ||'BIS_CURRENT_ASOF_DATE
						OR
						ftrs.report_date  = '|| '&' ||'BIS_PREVIOUS_ASOF_DATE
					 )
					AND edcs.implemented_sum is not null
					AND edcs.time_id  = ftrs.time_id
					AND edcs.period_type_id  = ftrs.period_type_id
					AND BITAND(ftrs.record_type_id, :PERIOD ) =  :PERIOD
					GROUP BY
					edcs.value, edcs.id,ENI_MEASURE50
		) t
		GROUP BY
			t.VALUE,t.id,ENI_MEASURE1,ENI_MEASURE9,
			ENI_MEASURE89,ENI_MEASURE88,
			ENI_MEASURE16,ENI_MEASURE17,ENI_MEASURE18,ENI_MEASURE19,
			ENI_MEASURE93,ENI_MEASURE96,ENI_MEASURE97,ENI_MEASURE98,
			ENI_MEASURE50
		ORDER BY
			' ||l_order_by ;



 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
 x_custom_output := bis_query_attributes_tbl();



 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ITEM';
 l_custom_rec.attribute_value := l_item;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(1) := l_custom_rec;


 x_custom_output.extend;
 l_custom_rec.attribute_name := ':ORG';
 l_custom_rec.attribute_value := replace(l_org,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
 x_custom_output(2) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':REASON';
 l_custom_rec.attribute_value := l_reason;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(3) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':PRIORITY';
 l_custom_rec.attribute_value := l_priority;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
 x_custom_output(4) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':STATUS';
 l_custom_rec.attribute_value := replace(l_status,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(5) := l_custom_rec;

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':TYPE';
 l_custom_rec.attribute_value := replace(l_type,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(6) := l_custom_rec;

--Bug 5083894 - Start Code

 x_custom_output.extend;
 l_custom_rec.attribute_name := ':PERIOD';
 l_custom_rec.attribute_value := replace(l_period_bitand,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(7) := l_custom_rec;

--Bug 5083894 - End Code

--l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
--l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;



END GET_SQL;
END ENI_DBI_COC_PKG;

/
