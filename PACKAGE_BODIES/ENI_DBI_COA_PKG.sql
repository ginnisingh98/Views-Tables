--------------------------------------------------------
--  DDL for Package Body ENI_DBI_COA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_COA_PKG" AS
/*$Header: ENICOAPB.pls 115.23 2004/06/24 22:26:37 adhachol noship $*/
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
l_type_where		VARCHAR2(1000);
l_from_clause		VARCHAR2(1000);
l_where_clause		VARCHAR2(1000);
l_group_by_clause	VARCHAR2(1000);
l_priority_from		VARCHAR2(1000);
l_type_from		VARCHAR2(1000);
l_reason_from		VARCHAR2(1000);
l_item_from		VARCHAR2(1000);
l_common_part		VARCHAR2(32000);
l_inner_part		VARCHAR2(32000);
l_lookup_from		VARCHAR2(4000);
l_lookup_outer_where	VARCHAR2(4000);
l_status_from		VARCHAR2(4000);
l_status_where		VARCHAR2(4000);
l_open_url		VARCHAR2(4000);
l_description		VARCHAR2(4000);
l_inner_group_by	VARCHAR2(4000);

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

	IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
	THEN
		l_priority_from:='';
		l_priority_where:= '';
        ELSIF (l_priority = '-1')
        THEN
		l_priority_where := ' and edcd.priority_code = :PRIORITY ';
        ELSE
		l_priority_where := ' and edcd.priority_code = :PRIORITY ';
	END IF;

	IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
	THEN
		l_type_from:='';
		l_type_where := '';

	ELSE
		l_type_where := ' and edcd.change_order_type_id = :TYPE ';
	END IF;


	IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
	THEN
		l_reason_from:='';
		l_reason_where := '';
	ELSIF (l_reason = '-1')
        THEN
		l_reason_where := ' and edcd.reason_code  = :REASON ';
        ELSE
		l_reason_where := ' and edcd.reason_code  = :REASON ';
	END IF;

	IF (l_status IS NULL OR l_status = '' OR l_status = 'All')
	THEN
		l_status_from:='';
		l_status_where := '';

	ELSE
		l_status_where := ' and edcd.status_type  = :STATUS ';
	END IF;

	IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
	THEN
		l_org_where := '';

	ELSE
		l_org_where := ' AND edcd.organization_id = :ORG ';
	END IF;

	l_open_url:=   '''pFunctionName=ENI_DBI_COL_OPEN_R&pCustomView=ENI_DBI_COL_CV1&REPORTED=OPEN'||
	'&VIEW_BY=VIEW_BY&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

	IF (l_item IS NULL OR l_item = '' OR l_item = 'All')
	THEN
		l_item_where := '';
		IF(l_view_by NOT like '%ITEM+%')
		THEN
			X_CUSTOM_SQL:='
				SELECT	NULL AS VIEWBY,
					NULL AS ENI_MEASURE60,
					NULL AS	ENI_MEASURE1,
					NULL AS	ENI_MEASURE9,
					NULL AS	ENI_MEASURE3,
					NULL AS	ENI_MEASURE11,
					NULL AS	ENI_MEASURE31,
					NULL AS	ENI_MEASURE32,
					NULL AS	ENI_MEASURE33,
					NULL AS	ENI_MEASURE34,
					NULL AS ENI_MEASURE20,
					NULL AS	ENI_MEASURE21,
					NULL AS	ENI_MEASURE22,
					NULL AS ENI_MEASURE23,
					NULL AS	ENI_MEASURE25,
					NULL AS	ENI_MEASURE26,
					NULL AS	ENI_MEASURE27,
					NULL AS	ENI_MEASURE28,
					NULL AS	ENI_MEASURE35,
					NULL AS	ENI_MEASURE36,
					NULL AS	ENI_MEASURE37,
					NULL AS	ENI_MEASURE38,
					NULL AS ENI_MEASURE40
				FROM	DUAL';
				RETURN;
		END IF;
	ELSE
		l_item_where := ' AND edcd.item_id = :ITEM ';
	END IF;


/*
 Bug #3114681 :  Previously the condition in the CASE was without the equal sign and not taking the
		current_as_of_date into account .

*/

l_inner_part:='


	SUM(CASE WHEN ( edcd.creation_date
	      <= &BIS_CURRENT_ASOF_DATE ) AND
		(nvl(edcd.IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(edcd.CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END) as ENI_MEASURE1,

	SUM(CASE WHEN ( edcd.creation_date
	      <= &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1 ) > &BIS_PREVIOUS_ASOF_DATE )
		THEN edcd.cnt
		ELSE null END) as ENI_MEASURE9,

	SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN  ((&BIS_CURRENT_ASOF_DATE - edcd.CREATION_DATE)* edcd.cnt)
		ELSE 0 END)/
		(case when (SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END) = 0) then null else (SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END)) END)
			as ENI_MEASURE3,

	SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE )
		THEN  ((&BIS_PREVIOUS_ASOF_DATE - edcd.CREATION_DATE)* edcd.cnt)
		ELSE 0 END)/
		(case when (SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END) = 0) then null else (SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END)) END )
			as ENI_MEASURE11 ,

	SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) AND
		 ((&BIS_CURRENT_ASOF_DATE -edcd.creation_date) between  0
	     AND 1 ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN  edcd.cnt
		ELSE 0 END ) as ENI_MEASURE31 ,

	SUM(CASE WHEN ( edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) and
		 ((&BIS_CURRENT_ASOF_DATE -edcd.creation_date) between  2
	     AND 5 ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN  edcd.cnt
		ELSE 0 END ) as ENI_MEASURE32 ,

	SUM(CASE WHEN  (edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) and
		 ((&BIS_CURRENT_ASOF_DATE -edcd.creation_date) between  6
	     AND 10 ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN  edcd.cnt
		ELSE 0 END ) as ENI_MEASURE33 ,

	SUM(CASE WHEN  (edcd.creation_date
	     <= &BIS_CURRENT_ASOF_DATE ) and
		 ((&BIS_CURRENT_ASOF_DATE -edcd.creation_date) > 10
		  ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN  edcd.cnt
		ELSE 0 END ) as ENI_MEASURE34	,

	SUM(CASE WHEN ( edcd.creation_date
		<= &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN  ((&BIS_CURRENT_ASOF_DATE - edcd.CREATION_DATE)* edcd.cnt)
		ELSE 0 END) AS INNER11,

	SUM(CASE WHEN ( edcd.creation_date
		<= &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END) AS INNER12,


	SUM(CASE WHEN ( edcd.creation_date
		<= &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE )
		THEN  ((&BIS_PREVIOUS_ASOF_DATE - edcd.CREATION_DATE)* edcd.cnt)
		ELSE 0 END) AS INNER21,


	 SUM(CASE WHEN ( edcd.creation_date
		<= &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE )
		THEN edcd.cnt
		ELSE 0 END) AS INNER22

		FROM
 ';
-- Bug 3722506 : INNER21 was coming as 0 and hence the calculation of measure23 was giving a
-- Division by Zero error .

l_common_part:='

	ENI_MEASURE1,
	ENI_MEASURE9,
	ENI_MEASURE3,
	ENI_MEASURE11,
	ENI_MEASURE31,
	ENI_MEASURE32,
	ENI_MEASURE33,
	ENI_MEASURE34,
	SUM(ENI_MEASURE1) OVER() AS ENI_MEASURE20,
	((SUM(ENI_MEASURE1) OVER() - SUM(ENI_MEASURE9) OVER()))
	/
	(SUM(ENI_MEASURE9) OVER() )* 100  AS ENI_MEASURE21,

	(SUM(INNER11) OVER())/ DECODE ( SUM(INNER12) OVER(),0,NULL,SUM(INNER12) OVER()) AS ENI_MEASURE22,

	((((SUM(INNER11) OVER())/ DECODE ( SUM(INNER12) OVER(),0,NULL,SUM(INNER12) OVER()))
	-
	((SUM(INNER21) OVER())/ DECODE ( SUM(INNER22) OVER(),0,NULL,SUM(INNER22) OVER())))
	/
	decode (((SUM(INNER21) OVER())/ DECODE ( SUM(INNER22) OVER(),0,NULL,SUM(INNER22) OVER())),0,null,
  ((SUM(INNER21) OVER())/ DECODE ( SUM(INNER22) OVER(),0,NULL,SUM(INNER22) OVER())))
  )
	* 100
	AS ENI_MEASURE23 ,

	SUM(ENI_MEASURE31) OVER() AS ENI_MEASURE25,
	SUM(ENI_MEASURE32) OVER() AS ENI_MEASURE26,
	SUM(ENI_MEASURE33) OVER() AS ENI_MEASURE27,
	SUM(ENI_MEASURE34) OVER() AS ENI_MEASURE28,
	35 AS ENI_MEASURE35,
	36 AS ENI_MEASURE36,
	37 AS ENI_MEASURE37,
	38 AS ENI_MEASURE38,
	DECODE(ENI_MEASURE1,0,NULL,'||l_open_url || ') as ENI_MEASURE40';


	l_lookup_from:=' , eni_item_org_v eiv ';
	l_lookup_outer_where:=' and edcd.item_id = eiv.inventory_item_id
				and eiv.organization_id = edcd.organization_id ';
	l_description:=' eiv.description as ENI_MEASURE60 ';
	l_inner_group_by:=', eiv.description ';

	IF(l_view_by like '%ITEM+%')
	THEN
		l_lookup_from:=' , eni_item_org_v eiv ';
		l_lookup_outer_where:=' and edcd.item_id = eiv.inventory_item_id
					and eiv.organization_id = edcd.organization_id ';
		l_description:=' eiv.description as ENI_MEASURE60 ';
		l_inner_group_by:=', eiv.description ';

	ELSIF(l_view_by like '%TYPE%')
	THEN
		l_lookup_from:=' , eni_chg_mgmt_type_v eiv ';
		l_lookup_outer_where:=' and edcd.change_order_type_id = eiv.id ';
		l_description:=' null as ENI_MEASURE60 ';
		l_inner_group_by:='';


	ELSIF(l_view_by like '%PRIORITY%')
	THEN
		l_lookup_from:=' ,eni_chg_mgmt_priority_v eiv';
		l_lookup_outer_where:=' and edcd.priority_code = eiv.id(+) ';
		l_description:=' null as ENI_MEASURE60 ';
		l_inner_group_by:='';


	ELSIF(l_view_by like '%REASON%')
	THEN
		l_lookup_from:=',eni_chg_mgmt_reason_v eiv';
		l_lookup_outer_where:=' and edcd.reason_code = eiv.id(+) ';
		l_description:=' null as ENI_MEASURE60 ';
		l_inner_group_by:='';


	ELSIF(l_view_by like '%STATUS%')
	THEN
		l_lookup_from:=',eni_chg_mgmt_status_v eiv';
		l_lookup_outer_where:=' and edcd.status_type = eiv.id ';
		l_description:=' null as ENI_MEASURE60 ';
		l_inner_group_by:='';

	END IF;


	X_CUSTOM_SQL:=
		'
			select  value as VIEWBY,
				ID AS VIEWBYID,
				ENI_MEASURE60, '
				|| l_common_part ||'

			FROM  ( SELECT EIV.VALUE AS VALUE, eiv.id as id,
				'|| l_description ||',
				'|| l_inner_part ||'
		   		ENI_DBI_CO_DNUM_MV edcd
				' || l_lookup_from || '
			WHERE
				1=1
				AND
				((edcd.creation_date
      		<= &BIS_CURRENT_ASOF_DATE ) AND
		      ( nvl(IMPLEMENTATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE ) AND
		      ( nvl(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1) > &BIS_CURRENT_ASOF_DATE )
					OR
				(edcd.creation_date
		      <= &BIS_PREVIOUS_ASOF_DATE ) AND
		      ( nvl(IMPLEMENTATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE ) AND
      		( nvl(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE +1) > &BIS_PREVIOUS_ASOF_DATE))
				' || l_item_where ||'
				' || l_lookup_outer_where ||'
				' || l_org_where || '
				' || l_type_where || '
				' || l_priority_where || '
				' || l_reason_where|| '
				' || l_status_where || '

				GROUP BY
					 eiv.id,eiv.value'||l_inner_group_by||'
			) t
			WHERE
				ENI_MEASURE1 > 0 OR ENI_MEASURE9 > 0
			group by
				id,value,ENI_MEASURE1, ENI_MEASURE9, ENI_MEASURE3, ENI_MEASURE11,
				ENI_MEASURE31, ENI_MEASURE32, ENI_MEASURE33, ENI_MEASURE34,
				ENI_MEASURE60,INNER11,INNER12,INNER21,INNER22
			order by
				' || l_order_by ;


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


--l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
--l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;



END GET_SQL;
END ENI_DBI_COA_PKG;

/
