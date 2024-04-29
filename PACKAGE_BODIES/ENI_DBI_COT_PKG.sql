--------------------------------------------------------
--  DDL for Package Body ENI_DBI_COT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_COT_PKG" AS
/*$Header: ENICOTPB.pls 120.4 2006/03/31 05:10:12 sdebroy noship $*/
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
l_priority_out_where	VARCHAR2(1000);
l_reason_where		VARCHAR2(1000);
l_type_where		VARCHAR2(1000);
l_from_clause		VARCHAR2(1000);
l_where_clause		VARCHAR2(1000);
l_group_by_clause	VARCHAR2(1000);
l_priority_from		VARCHAR2(1000);
l_type_from		VARCHAR2(1000);
l_reason_from		VARCHAR2(1000);
l_report		VARCHAR2(1000);
l_coltype		VARCHAR2(1000);
l_impl_url		VARCHAR2(1000);
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


			ENI_DBI_UTIL_PKG.get_time_clauses
            		(
                        	'I',
				                  'edcs',
        	                l_period_type,
                	        l_period_bitand,
                        	l_as_of_date,
	                        l_prev_as_of_date,
        	                l_report_start,
                	        l_cur_period,
                        	l_days_into_period,
	                        l_comp_type,
        	                l_id_column,
                	        l_from_clause,
                        	l_where_clause,
				l_group_by_clause,
				'ROLLING'
        		);


	IF(l_order_by like '%DESC%')
	THEN
		l_order_by:=' t.start_date desc ';
	ELSIF(l_order_by like '%ASC%')
	THEN
		l_order_by:=' t.start_date asc ';
	ELSE
		l_order_by:=' t.start_date asc ';
	END IF;


--  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

	IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
	THEN
		null;
		l_priority:='';

	ELSE
		l_priority_where := ' and edcs.priority_code= :PRIORITY ';
	END IF;

	IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
	THEN
		l_type_where := 'and edcs.change_order_type_id is null';

	ELSE
		l_type_where := ' and edcs.change_order_type_id= :TYPE ';
	END IF;


	IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
	THEN
		l_reason_where := 'and edcs.reason_code is null';

	ELSE
		l_reason_where := ' and edcs.reason_code = :REASON ';
	END IF;

	IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
	THEN
		l_org_where := '';

	ELSE
		l_org_where := ' AND edcs.organization_id = :ORG ';
	END IF;

-- Bug : 3465553
/*
l_impl_url:='''pFunctionName=ENI_DBI_COL_IMPL_R&pCustomView=ENI_DBI_COL_CV2&REPORTED=IMPL'||
'&start_date=''||to_char(t.start_date,''dd-mm-yyyy'')||''&end_date=''||to_char(t.c_end_date,''dd-mm-yyyy'')||''&''||''AS_OF_DATE=''||to_char(t.c_end_date,''dd-mm-yyyy'')';
*/
-- Bug : 3465553
l_impl_url :=null;

	IF (l_item IS NULL OR l_item = '' OR l_item = 'All')
	THEN
		l_item_where := '';
		x_custom_sql :='
				select	null as VIEWBY,
					null as ENI_MEASURE1,
					null as ENI_MEASURE10,
					null as ENI_MEASURE9,
					null as ENI_MEASURE3,
					null as ENI_MEASURE6,
					null as ENI_MEASURE7,
					null as ENI_MEASURE8,
					null as ENI_MEASURE16,
					null as ENI_MEASURE17,
					null as ENI_MEASURE18,
					null as ENI_MEASURE19,
					null as ENI_MEASURE11,
					null as ENI_MEASURE12,
					null as ENI_MEASURE13,
					null as ENI_MEASURE21,
					null as ENI_MEASURE22,
					null as ENI_MEASURE23,
					null as ENI_MEASURE25,
					null as ENI_MEASURE26,
					null as ENI_MEASURE27,
					null as ENI_MEASURE28,
					null as ENI_MEASURE40



				from	dual';
				return;
	ELSE
		l_item_where := ' AND edcs.item_id = :ITEM ';
	END IF;

x_custom_sql :=  '
	SELECT
	t.name as VIEWBY,

	SUM(CASE WHEN
			ftrs.report_date = t.c_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	null
		END)	as ENI_MEASURE1,

	nvl(SUM(CASE WHEN
			ftrs.report_date = t.c_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	0
		END),0)	as ENI_MEASURE10,

	SUM(CASE WHEN
			ftrs.report_date =t.p_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	null
		END)	as ENI_MEASURE9,

	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	NVL(ftrs.CREATE_TO_APPROVE_SUM,0)
		ELSE	null
		END)
	/
	decode(SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.CREATE_TO_APPROVE_CNT
		ELSE	null
		END),0,1,SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.CREATE_TO_APPROVE_CNT
		ELSE	null
		END))	 as ENI_MEASURE3,



	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	NVL(ftrs.APPROVE_TO_IMPL_SUM,0)
		ELSE	null
		END)
	/
	decode(SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.APPROVE_TO_IMPL_CNT
		ELSE	null
		END),0,1,SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.APPROVE_TO_IMPL_CNT
		ELSE	null
		END))	as ENI_MEASURE6,

	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.CYCLE_TIME_SUM
		ELSE	null
		END)
	/
	decode(SUM(CASE WHEN
			ftrs.report_date = t.c_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	null
		END),0,1,SUM(CASE WHEN
			ftrs.report_date = t.c_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	null
		END)) as ENI_MEASURE7,

	SUM(CASE WHEN
			ftrs.report_date =t.p_end_date
		THEN	NVL(ftrs.CYCLE_TIME_SUM,0)
		ELSE	null
		END)
	/
	decode(SUM(CASE WHEN
			ftrs.report_date =t.p_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	null
		END),0,1,SUM(CASE WHEN
			ftrs.report_date =t.p_end_date
		THEN	ftrs.IMPLEMENTED_SUM
		ELSE	null
		END)) as ENI_MEASURE8,

	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.BUCKET1_SUM
		ELSE	null
		END)	as ENI_MEASURE16 ,

	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.BUCKET2_SUM
		ELSE	null
		END)	as ENI_MEASURE17 ,

	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.BUCKET3_SUM
		ELSE	null
		END)	as ENI_MEASURE18 ,

	SUM(CASE WHEN
			ftrs.report_date =t.c_end_date
		THEN	ftrs.BUCKET4_SUM
		ELSE	null
		END)	as ENI_MEASURE19,

	SUM(CASE WHEN	ftrs.report_date = t.c_end_date
					and ftrs.priority_level=0
				THEN	ftrs.CYCLE_TIME_SUM
				else 0 end)
					/
			decode(sum( case when ftrs.report_date=t.c_end_date
					and ftrs.priority_level=0
					then ftrs.implemented_sum
					else 0 end ),0,1,sum( case when ftrs.report_date=t.c_end_date
					and ftrs.priority_level=0
					then ftrs.implemented_sum
					else 0 end ))
					as ENI_MEASURE11,

	SUM(CASE WHEN	ftrs.report_date = t.c_end_date
					and ftrs.priority_level=1
				THEN	ftrs.CYCLE_TIME_SUM
				else 0 end)
					/
			decode(sum( case when ftrs.report_date=t.c_end_date
					and ftrs.priority_level=1
					then ftrs.implemented_sum
					else 0 end ),0,1,sum( case when ftrs.report_date=t.c_end_date
					and ftrs.priority_level=1
					then ftrs.implemented_sum
					else 0 end ))
					as ENI_MEASURE12,

	SUM(CASE WHEN	ftrs.report_date = t.c_end_date
					and nvl(ftrs.priority_level,2) <> 0 and nvl(ftrs.priority_level,2) <> 1
				THEN	ftrs.CYCLE_TIME_SUM
				else 0 end)
					/
			decode(sum( case when ftrs.report_date=t.c_end_date
					and nvl(ftrs.priority_level,2) <> 0 and nvl(ftrs.priority_level,2) <> 1
					then ftrs.implemented_sum
					else 0 end ),0,1,sum( case when ftrs.report_date=t.c_end_date
					and  nvl(ftrs.priority_level,2) <> 0 and nvl(ftrs.priority_level,2) <> 1
					then ftrs.implemented_sum
					else 0 end ))
					as ENI_MEASURE13,
			10 as ENI_MEASURE21,
			11 as ENI_MEASURE22,
			12 as ENI_MEASURE23,
			13 as ENI_MEASURE25,
			14 as ENI_MEASURE26,
			15 as ENI_MEASURE27,
			16 as ENI_MEASURE28,
			NULL as ENI_MEASURE40

FROM
	(	SELECT edcs.*,t.c_end_date,t.p_end_date,prio.*,ftrs.report_date
		FROM ENI_DBI_CO_SUM_MV edcs,eni_chg_mgmt_priority_v prio, fii_time_structures ftrs,'||l_from_clause||'
		WHERE
		edcs.status_type is null
		' || l_item_where ||'
		' || l_org_where || '
		' || l_type_where || '
		' || l_priority_where || '
		' || l_reason_where|| '
		' || l_cat_where || '
		and edcs.priority_code is not null
		and prio.id(+)=edcs.priority_code
		and (ftrs.report_date=t.c_end_date  OR ftrs.report_date=t.p_end_date )
	  and edcs.time_id (+) = ftrs.time_id
	  and edcs.period_type_id (+) = ftrs.period_type_id
	  and bitand(ftrs.record_type_id,:PERIODAND) = :PERIODAND --Bug 5083882
	) ftrs,'||l_from_clause||'
	WHERE ftrs.c_end_date(+) = t.c_end_date
GROUP BY
	t.name,t.start_date,t.c_end_date
ORDER BY
	'||l_order_by;

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

 --Bug 5083882 - Start Code
 x_custom_output.extend;
 l_custom_rec.attribute_name := ':PERIODAND'; --Bug 5083652
 l_custom_rec.attribute_value := replace(l_period_bitand,'''');
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
 l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
 x_custom_output(7) := l_custom_rec;
--Bug 5083882 - End Code

--Bug 5083652 --	Start Code
  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(8) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(9) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(10) := l_custom_rec;
--Bug 5083652 --	End Code


END GET_SQL;
END ENI_DBI_COT_PKG;

/
