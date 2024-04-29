--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PDA_PKG" AS
/*$Header: ENIPDAPB.pls 115.14 2004/02/23 00:02:35 pthambu noship $*/
PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_custom_rec		BIS_QUERY_ATTRIBUTES;
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
l_status		        VARCHAR2(100);
l_priority		VARCHAR2(100);
l_reason		        VARCHAR2(100);
l_lifecycle_phase	VARCHAR2(100);
l_currency		VARCHAR2(100);
l_bom_type		VARCHAR2(100);
l_type			VARCHAR2(100);
l_manager		VARCHAR2(100);
l_temp			VARCHAR2(1000);
l_lob			VARCHAR2(1000);
l_org_where 		VARCHAR2(400);
l_item_where		VARCHAR2(400);
l_priority_where	VARCHAR2(400);
l_reason_where	VARCHAR2(400);
l_type_where	VARCHAR2(400);
l_status_where	VARCHAR2(400);
l_join_col_name	VARCHAR2(100);
l_viewby_tbl		VARCHAR2(100);
l_open_url		VARCHAR2(400);
l_item_description VARCHAR2(100) := 'NULL';
l_item_desc_grp   VARCHAR2(100);

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

/* Bug Fix: 3380925
     Added ENI_MEASURE6,ENI_MEASURE7, ENI_MEASURE37,ENI_MEASURE38
     Reverted the calculation to (current_date - need_by_date)

*/

	l_open_url:='''pFunctionName=ENI_DBI_COL_PAST_R&pCustomView=ENI_DBI_COL_CV4&REPORTED=PAST'||
				'&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=VIEW_BY&pParamIds=Y''';


	IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
	THEN
		l_priority_where:= '';
	ELSE
		l_priority_where := ' and pdo.priority_code = :PRIORITY';
	END IF;


	IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
	THEN
		l_type_where := '';
	ELSE
		l_type_where := ' and pdo.change_order_type_id = :TYPE';
	END IF;


	IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
	THEN
		l_reason_where := '';
	ELSE
		l_reason_where := ' and pdo.reason_code  = :REASON';
	END IF;

	IF (l_status IS NULL OR l_status = '' OR l_status = 'All')
	THEN
		l_status_where := '';
	ELSE
		l_status_where := ' and pdo.status_type  = :STATUS';
	END IF;


	IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
	THEN
		l_org_where := '';
	ELSE
		l_org_where := ' AND pdo.organization_id = :ORG';
	END IF;


	l_item_desc_grp := '';

	CASE l_view_by
	WHEN 'ENI_CHANGE_MGMT_STATUS+ENI_CHANGE_MGMT_STATUS' THEN
		l_viewby_tbl := ' eni_chg_mgmt_status_v vby';
		l_join_col_name := ' and vby.id = pdo.status_type';
	WHEN 'ENI_CHANGE_MGMT_PRIORITY+ENI_CHANGE_MGMT_PRIORITY' THEN
		l_viewby_tbl := ' eni_chg_mgmt_priority_v vby';
		l_join_col_name := ' and vby.id = pdo.priority_code';
	WHEN 'ENI_CHANGE_MGMT_REASON+ENI_CHANGE_MGMT_REASON' THEN
		l_viewby_tbl := ' eni_chg_mgmt_reason_v vby';
		l_join_col_name := ' and vby.id = pdo.reason_code';
	WHEN 'ENI_CHANGE_MGMT_TYPE+ENI_CHANGE_MGMT_TYPE' THEN
		l_viewby_tbl := ' eni_chg_mgmt_type_v vby';
		l_join_col_name := ' and vby.id = pdo.change_order_type_id';
	ELSE
		l_item_description := ' vby.description';
		l_item_desc_grp := ', vby.description';
		l_viewby_tbl := ' eni_item_org_v  vby';
		l_join_col_name := ' and vby.inventory_item_id = pdo.item_id
				    and vby.organization_id = pdo.organization_id';
	END CASE;


	IF (l_item IS NULL OR l_item = '' OR l_item = 'All')
	THEN
		l_item_where := '';
		IF(l_view_by NOT like '%ITEM+%')
		THEN
			X_CUSTOM_SQL:='
				SELECT	NULL AS VIEWBY,
					NULL AS      ENI_MEASURE30,
					NULL AS	ENI_MEASURE1,
					NULL AS	ENI_MEASURE9,
					NULL AS	ENI_MEASURE3,
					NULL AS      ENI_MEASURE6,
					NULL AS      ENI_MEASURE7,
					NULL AS	ENI_MEASURE11,
					NULL AS	ENI_MEASURE31,
					NULL AS	ENI_MEASURE32,
					NULL AS	ENI_MEASURE33,
					NULL AS	ENI_MEASURE34,
					NULL AS       ENI_MEASURE20,
					NULL AS	ENI_MEASURE21,
					NULL AS	ENI_MEASURE22,
					NULL AS       ENI_MEASURE23,
					NULL AS	ENI_MEASURE25,
					NULL AS	ENI_MEASURE26,
					NULL AS	ENI_MEASURE27,
					NULL AS	ENI_MEASURE28,
					NULL AS      ENI_MEASURE36,
					NULL AS      ENI_MEASURE37,
					NULL AS      ENI_MEASURE38
				FROM	DUAL';
				RETURN;
		END IF;
	ELSE
		l_item_where := ' AND pdo.item_id = :ITEM';
	END IF;

/* Bug: 3394222  Rolling Period Conversion. New requirements specific to 7.0
   Days open = currrent date - creation date
*/

 x_custom_sql := '
  select   value as VIEWBY
	   ,id as VIEWBYID
	   ,NULL  as ENI_MEASURE30
	   ,curr_open_cnt as ENI_MEASURE1
	   ,prev_open_cnt as ENI_MEASURE9
	   ,curr_open_days_cnt/DECODE(curr_open_cnt,0,NULL,curr_open_cnt) as ENI_MEASURE3
	   ,prev_open_days_cnt/DECODE(prev_open_cnt,0,NULL,prev_open_cnt) as ENI_MEASURE11
	   ,curr_past_open_days_cnt/DECODE(curr_open_cnt,0,NULL,curr_open_cnt) as ENI_MEASURE6
	   ,prev_past_open_days_cnt/DECODE(prev_open_cnt,0,NULL,prev_open_cnt) as ENI_MEASURE7
	   ,avg1_cnt as ENI_MEASURE31
	   ,avg2_cnt as ENI_MEASURE32
	   ,avg3_cnt as ENI_MEASURE33
	   ,avg4_cnt as ENI_MEASURE34
	   ,SUM(curr_open_cnt) OVER() as ENI_MEASURE20,
	  (
	 (SUM(curr_open_cnt) OVER() - SUM(prev_open_cnt) OVER())
	 /(DECODE(SUM(prev_open_cnt) OVER(),0,NULL,SUM(prev_open_cnt) OVER()))
	) * 100
	as ENI_MEASURE21,
	SUM(curr_open_days_cnt) OVER()/DECODE(SUM(curr_open_cnt) OVER(),0,NULL,SUM(curr_open_cnt)  OVER() ) as ENI_MEASURE22
        ,(
   	  (
		   SUM(curr_open_days_cnt) OVER()/DECODE(SUM(curr_open_cnt) OVER(),0,NULL,SUM(curr_open_cnt)  OVER() )
		 - SUM(prev_open_days_cnt) OVER()/DECODE(SUM(prev_open_cnt) OVER(),0,NULL,SUM(prev_open_cnt)  OVER() )
	  )
	  /DECODE(SUM(prev_open_days_cnt) OVER()/DECODE(SUM(prev_open_cnt) OVER(),0,NULL,SUM(prev_open_cnt)  OVER() )
	 		,0
			,NULL
			,SUM(prev_open_days_cnt) OVER()/DECODE(SUM(prev_open_cnt) OVER(),0,NULL,SUM(prev_open_cnt)  OVER() )
		   )
	) * 100 as ENI_MEASURE23
	,SUM( avg1_cnt ) OVER() as ENI_MEASURE25
	,SUM( avg2_cnt ) OVER() as ENI_MEASURE26
	,SUM( avg3_cnt ) OVER() as ENI_MEASURE27
	,SUM( avg4_cnt ) OVER() as ENI_MEASURE28
	,(CASE WHEN curr_open_cnt IS NULL OR curr_open_cnt = 0 THEN
			NULL
		      ELSE
			' || l_open_url || '
	  END ) as ENI_MEASURE36
	,SUM(curr_past_open_days_cnt) OVER()/DECODE(SUM(curr_open_cnt) OVER(),0,NULL,SUM(curr_open_cnt)  OVER() ) as ENI_MEASURE37
	,SUM(prev_past_open_days_cnt) OVER()/DECODE(SUM(prev_open_cnt) OVER(),0,NULL,SUM(prev_open_cnt)  OVER() ) as ENI_MEASURE38
from
(
	SELECT vby.value
	,vby.id
        ,'|| l_item_description || ' as ENI_MEASURE30
	,SUM(
 	   case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		     AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
	 	     AND (NVL(IMPLEMENTATION_DATE,
	    	           NVL(CANCELLATION_DATE,(&BIS_CURRENT_ASOF_DATE)+1))) > &BIS_CURRENT_ASOF_DATE
		Then pdo.cnt
		Else 0
		end
	   ) curr_open_cnt,
	SUM(
	  case
	 	When pdo.creation_date <= &BIS_PREVIOUS_ASOF_DATE
		  AND pdo.need_by_date < &BIS_PREVIOUS_ASOF_DATE
	   	 AND (NVL(IMPLEMENTATION_DATE,
  		       NVL(CANCELLATION_DATE,(&BIS_PREVIOUS_ASOF_DATE)+1))) > &BIS_PREVIOUS_ASOF_DATE
		Then pdo.cnt
		Else 0
		End
	   ) prev_open_cnt,
	SUM(
		case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		  AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
		 AND (NVL(IMPLEMENTATION_DATE,
			  NVL(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1))) > &BIS_CURRENT_ASOF_DATE
		Then ((&BIS_CURRENT_ASOF_DATE-pdo.creation_date)*pdo.cnt)
		Else 0
		end
	   ) curr_open_days_cnt,
	SUM(
		case
		When pdo.creation_date <= &BIS_PREVIOUS_ASOF_DATE
		  AND pdo.need_by_date < &BIS_PREVIOUS_ASOF_DATE
		  AND (NVL(IMPLEMENTATION_DATE,
		         NVL(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE + 1))) > &BIS_PREVIOUS_ASOF_DATE
		Then ((&BIS_PREVIOUS_ASOF_DATE-pdo.creation_date)*pdo.cnt)
		Else 0
		End
	   ) prev_open_days_cnt,
	SUM(
		case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		  AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
		 AND (NVL(IMPLEMENTATION_DATE,
			  NVL(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE +1))) > &BIS_CURRENT_ASOF_DATE
		Then ((&BIS_CURRENT_ASOF_DATE-pdo.need_by_date)*pdo.cnt)
		Else 0
		end
	   ) curr_past_open_days_cnt,
	SUM(
		case
		When pdo.creation_date <= &BIS_PREVIOUS_ASOF_DATE
		  AND pdo.need_by_date < &BIS_PREVIOUS_ASOF_DATE
		  AND (NVL(IMPLEMENTATION_DATE,
		         NVL(CANCELLATION_DATE,&BIS_PREVIOUS_ASOF_DATE + 1))) > &BIS_PREVIOUS_ASOF_DATE
		Then ((&BIS_PREVIOUS_ASOF_DATE-pdo.need_by_date)*pdo.cnt)
		Else 0
		End
	   ) prev_past_open_days_cnt,
       SUM(
 	   case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		     AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
	 	     AND (NVL(IMPLEMENTATION_DATE,
	    	           NVL(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE + 1))) > &BIS_CURRENT_ASOF_DATE
			 AND (&BIS_CURRENT_ASOF_DATE-pdo.need_by_date) between 0 and 1
		Then pdo.cnt
		Else 0
		end
	   ) avg1_cnt,
	SUM(
 	   case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		     AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
	 	     AND (NVL(IMPLEMENTATION_DATE,
	    	           NVL(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE + 1))) > &BIS_CURRENT_ASOF_DATE
			 AND (&BIS_CURRENT_ASOF_DATE-pdo.need_by_date) between 2 and 5
		Then pdo.cnt
		Else 0
		end
	   ) avg2_cnt,
	SUM(
 	   case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		     AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
	 	     AND (NVL(IMPLEMENTATION_DATE,
	    	           NVL(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE + 1))) > &BIS_CURRENT_ASOF_DATE
			 AND (&BIS_CURRENT_ASOF_DATE-pdo.need_by_date) between 6 and 10
		Then pdo.cnt
		Else 0
		end
	   ) avg3_cnt,
	SUM(
 	   case
		When pdo.creation_date <= &BIS_CURRENT_ASOF_DATE
		     AND pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
	 	     AND (NVL(IMPLEMENTATION_DATE,
	    	           NVL(CANCELLATION_DATE,&BIS_CURRENT_ASOF_DATE + 1))) > &BIS_CURRENT_ASOF_DATE
			 AND (&BIS_CURRENT_ASOF_DATE-pdo.need_by_date) > 10
		Then pdo.cnt
		Else 0
		end
	   ) avg4_cnt
	FROM
		eni_dbi_co_dnum_mv pdo,' ||
		l_viewby_tbl || '
	WHERE
		pdo.need_by_date is not null
		and pdo.need_by_date < &BIS_CURRENT_ASOF_DATE
		and nvl(pdo.implementation_date, &BIS_CURRENT_ASOF_DATE + 1) > pdo.need_by_date
		and nvl(pdo.cancellation_date, &BIS_CURRENT_ASOF_DATE + 1) > pdo.need_by_date ' ||
		    l_join_col_name ||
		    l_item_where ||
		    l_priority_where ||
		    l_type_where ||
		    l_reason_where ||
		    l_status_where ||
		    l_org_where || '
	GROUP BY
		vby.value,
		vby.id'
		|| l_item_desc_grp || '
)t
WHERE
	curr_open_cnt <> 0 or prev_open_cnt <> 0
GROUP BY
	   value,
	   id,
	   ENI_MEASURE30,
	   curr_open_cnt,
	   prev_open_cnt,
	   curr_open_days_cnt,
	   prev_open_days_cnt,
	   curr_past_open_days_cnt,
	   prev_past_open_days_cnt,
	   avg1_cnt,
	   avg2_cnt,
	   avg3_cnt,
	   avg4_cnt
ORDER BY
		' || l_order_by;

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
 l_custom_rec.attribute_value :=replace(l_org,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
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
 l_custom_rec.attribute_name := ':TYPE';
 l_custom_rec.attribute_value := replace(l_type,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(5) := l_custom_rec;


 x_custom_output.extend;
 l_custom_rec.attribute_name := ':STATUS';
 l_custom_rec.attribute_value := replace(l_status,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(6) := l_custom_rec;


EXCEPTION
	WHEN OTHERS THEN
		NULL;
END GET_SQL;
END ENI_DBI_PDA_PKG;

/
