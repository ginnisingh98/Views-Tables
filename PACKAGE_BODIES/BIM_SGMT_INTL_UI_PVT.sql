--------------------------------------------------------
--  DDL for Package Body BIM_SGMT_INTL_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_SGMT_INTL_UI_PVT" AS
/* $Header: bimsiuib.pls 120.31 2006/03/02 22:28:05 sbassi noship $ */


FUNCTION GLb( p_page_parameter_tbl    IN BIS_PMV_PAGE_PARAMETER_TBL , num in number)
	RETURN VARCHAR2	IS

	l_val		VARCHAR2(50);
	Label1       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('BOOK_C');
	Label2       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('OPPT_C');
	Label3       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('LEAD_C');
	Label4       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('RESP_C');
	Label5       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('ACT_C');
	Label6       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('BOOK_G');
	Label7       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('OPPT_G');
	Label8       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('LEAD_G');
	Label9       CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('RESP_G');
	Label10      CONSTANT  varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('ACT_G');
BEGIN

	IF (p_page_parameter_tbl.count > 0) THEN

		FOR i IN p_page_parameter_tbl.FIRST..p_page_parameter_tbl.LAST
		LOOP

			IF p_page_parameter_tbl(i).parameter_name ='BIM_PARAMETER1' THEN

				l_val := p_page_parameter_tbl(i).parameter_value;
				EXIT;

			END IF;

		END LOOP;

	END IF;

	IF num = 1 THEN

	---the fuction is called for column name

		CASE
			WHEN l_val = 'ACT' THEN
			RETURN Label5 ;
			WHEN l_val = 'RESP' THEN
			RETURN  Label4 ;
			WHEN l_val = 'LEAD' THEN
			RETURN   Label3 ;
			WHEN l_val = 'OPPT' THEN
			RETURN    Label2 ;
			WHEN l_val = 'BOOK' THEN
			RETURN   Label1 ;
		END CASE;

	ELSIF  num = 2 THEN

		---the fuction is called for Graph Title
		CASE
			WHEN l_val = 'ACT' THEN
			RETURN Label10 ;
			WHEN l_val = 'RESP' THEN
			RETURN  Label9 ;
			WHEN l_val = 'LEAD' THEN
			RETURN   Label8 ;
			WHEN l_val = 'OPPT' THEN
			RETURN    Label7 ;
			WHEN l_val = 'BOOK' THEN
			RETURN   Label6 ;
		END CASE;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
END GLb;



FUNCTION GET_RESOURCE_ID return NUMBER IS
l_resource_id NUMBER := NULL;
CURSOR c_rid IS
       SELECT resource_id
       FROM   JTF_RS_RESOURCE_EXTNS
       WHERE  user_id = FND_GLOBAL.user_id;
 BEGIN
 OPEN c_rid;
         FETCH c_rid INTO l_resource_id;
 CLOSE c_rid;
 if (l_resource_id=null) then
   l_resource_id := -1;
 end if;
 if (l_resource_id='') then
    l_resource_id := -1;
 end if;

return l_resource_id;
END GET_RESOURCE_ID;

FUNCTION GET_ADMIN_STATUS return VARCHAR2 IS
l_admin_count NUMBER := 0;
l_admin_flag varchar2(20) ;
 CURSOR c_rid IS
       SELECT count(*)
       FROM   JTF_RS_RESOURCE_EXTNS r, bim_i_admin_group a
       WHERE  user_id = FND_GLOBAL.user_id
       AND r.resource_id = a.resource_id;

BEGIN
If GET_RESOURCE_ID is null
then
l_admin_flag := 'Y';

else

 OPEN c_rid;
         FETCH c_rid INTO l_admin_count;
 CLOSE c_rid;
   if (l_admin_count<=0)
   then
      l_admin_flag := 'N';
   else
      l_admin_flag := 'Y';
   end if;
end if;
   return l_admin_flag;
END GET_ADMIN_STATUS;

PROCEDURE GET_SGMT_VALUE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_sqltext					VARCHAR2 (20000);
	l_as_of_date				DATE;
	l_period_type				VARCHAR2 (2000);
	l_record_type_id			NUMBER;
	l_cat_id					VARCHAR2 (50) ;
	l_sgmt_id					VARCHAR2 (50) ;
	l_curr						VARCHAR2(50);
	l_view_by					VARCHAR2 (4000);
	l_where						VARCHAR2 (2000);
	l_groupby					VARCHAR2 (200);
	l_custom_rec				BIS_QUERY_ATTRIBUTES;
	l_active_cust_col			VARCHAR2(30);
	l_start_date				VARCHAR2(30);
	l_curr_suffix				VARCHAR2(2);
	l_url_metric				VARCHAR2(10);
	l_url_viewby				VARCHAR2(100);
	l_url_viewbyid				VARCHAR2(100);
	l_view_by_id				VARCHAR2(50);
	l_url_str					VARCHAR2(1000);
	l_url_str_sgmt_jtf			VARCHAR2(1000);
	l_leaf_node_flag			VARCHAR2(1);
	l_from						VARCHAR2(200);
	l_col						VARCHAR2(200);

BEGIN
	x_custom_output := bis_query_attributes_tbl ();
	l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
	bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
												l_as_of_date ,
												l_period_type,
												l_record_type_id,
												l_view_by,
												l_cat_id ,
												l_sgmt_id,
												l_curr,
												l_url_metric,
												l_url_viewby,
												l_url_viewbyid
											  ) ;

	IF l_sgmt_id is null THEN
		--i.e The value in Segment Lov is NULL , then show only Parent Segments

		l_from := ' , bim_i_sgmt_denorm dn ' ;
		l_where := ' AND dn.immediate_parent_id IS NULL AND a.segment_id=dn.segment_id ';
		l_groupby := ' , dn.leaf_node_flag ' ;
		l_col	:=  ' , dn.leaf_node_flag leaf_node_flag ' ;

	ELSE
		-- two cases here, if the segment is a parent segment , then show the children underneath
		-- else show that segment only
		BEGIN

			SELECT	leaf_node_flag
			INTO	l_leaf_node_flag
			FROM	bim_i_sgmt_denorm
			WHERE   segment_id = replace(l_sgmt_id,'''',null)
			AND     segment_id = parent_segment_id;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;

		IF l_leaf_node_flag = 'Y' THEN
			--Show the segment itself

			l_where := ' AND a.segment_id = :l_sgmt_id ';
			l_col	:=  ' , '''||l_leaf_node_flag||''' leaf_node_flag ' ;

		ELSE
			--Show only immediate Children

			l_from := ' , bim_i_sgmt_denorm dn ' ;
			l_where := ' AND dn.immediate_parent_id=:l_sgmt_id AND dn.immediate_parent_flag = ''Y''
						 AND a.segment_id=dn.segment_id ';

			l_groupby := ' , dn.leaf_node_flag ' ;
			l_col	:=  ' , dn.leaf_node_flag leaf_node_flag ' ;

		END IF;

	END IF;

	l_view_by_id:='VIEWBYID';

	IF (l_curr = '''FII_GLOBAL1''')	THEN
		l_curr_suffix := '';
	ELSIF (l_curr = '''FII_GLOBAL2''')	THEN
		l_curr_suffix := '_s';
	ELSE
		l_curr_suffix := '';
	END IF;

	CASE l_period_type
		WHEN 'FII_TIME_WEEK' THEN
			l_active_cust_col := 'cust_count_week';
			l_start_date:='week_start_date';
		WHEN 'FII_TIME_ENT_PERIOD' THEN
			l_active_cust_col := 'cust_count_month';
			l_start_date:='ent_period_start_date';
		WHEN 'FII_TIME_ENT_QTR' THEN
			l_active_cust_col := 'cust_count_qtr';
			l_start_date:='ent_qtr_start_date';
		WHEN 'FII_TIME_ENT_YEAR' THEN
			l_active_cust_col := 'cust_count_year';
			l_start_date:='ent_year_start_date';
		ELSE
			l_active_cust_col := 'cust_count_week';
			l_start_date:='week_start_date';
	END CASE;

	l_url_str  :='''pFunctionName=BIM_I_SGMT_VAL_R&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID''';

	--l_url_str_sgmt_jtf :='''pFunctionName=BIM_I_SGMT_DRILL&PAGE.OBJ.objType=CELL&PAGE.OBJ.objAttribute=HIER&PAGE.OBJ.ID_NAME0=treeSearchId&PAGE.OBJ.treeSearchFlag=Y&PAGE.OBJ.ID0=VIEWBYID&treeSearchId=VIEWBYID''';
	l_url_str_sgmt_jtf := 'NULL';

 l_sqltext:='
	SELECT
		VIEWBY,
		VIEWBYID,
		total_customers BIM_ATTRIBUTE2,
		CASE WHEN prev_total_customers = 0 THEN NULL ELSE
		((total_customers-prev_total_customers)/prev_total_customers)*100 end BIM_ATTRIBUTE3,
		active_customers BIM_ATTRIBUTE4,
		CASE WHEN prev_active_customers=0 THEN NULL ELSE ((active_customers-prev_active_customers)/prev_active_customers)*100 end BIM_ATTRIBUTE5,
		CASE WHEN total_customers = 0 THEN NULL ELSE
		((active_customers)/total_customers)*100 END BIM_ATTRIBUTE6,
		total_customers - active_customers  BIM_ATTRIBUTE7,
		revenue BIM_ATTRIBUTE8,
		CASE WHEN prev_revenue = 0 THEN NULL ELSE ((revenue-prev_revenue)/prev_revenue)*100 END BIM_ATTRIBUTE9,
		CASE WHEN active_customers = 0 THEN NULL ELSE  revenue/active_customers END BIM_ATTRIBUTE10,
		CASE WHEN booked_count = 0 THEN NULL ELSE booked_amt/booked_count END BIM_ATTRIBUTE11,
		CASE WHEN (prev_booked_count=0 OR prev_booked_amt=0 OR booked_count=0) THEN NULL ELSE (((booked_amt/booked_count)-(prev_booked_amt/prev_booked_count))/ (prev_booked_amt/prev_booked_count))*100
		end BIM_ATTRIBUTE12,
		segment_size BIM_ATTRIBUTE13,
		CASE WHEN prev_segment_size=0 THEN NULL ELSE ((segment_size-prev_segment_size)/prev_segment_size)*100 END BIM_ATTRIBUTE14,
		CASE WHEN prev_active_customers=0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_ACTIVE_CUST_T&pParamIds=Y&BIM_DIM11='||l_view_by_id||''' END BIM_URL1,
		CASE WHEN prev_revenue = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_REV_T&pParamIds=Y&BIM_DIM11='||l_view_by_id||''' END BIM_URL2,
		CASE WHEN (prev_booked_count=0 OR prev_booked_amt=0 OR booked_count=0) THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_AVG_TXN_VAL_T&pParamIds=Y&BIM_DIM11='||l_view_by_id||''' END BIM_URL3,
		CASE WHEN prev_segment_size = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_SIZE_T&pParamIds=Y&BIM_DIM11='||l_view_by_id||''' END BIM_URL4  ,
		decode( leaf_node_flag ,''Y'','||l_url_str_sgmt_jtf||', '||l_url_str||') BIM_URL5
	FROM
	(
   SELECT
    b.cell_name VIEWBY,
    VIEWBYID,
	a.leaf_node_flag  leaf_node_flag,
   SUM(revenue) revenue,
   SUM(prev_revenue)  prev_revenue,
   SUM(total_customers ) total_customers,
   SUM(prev_total_customers )  prev_total_customers,
   SUM(booked_amt)   booked_amt,
   SUM(prev_booked_amt)   prev_booked_amt,
   SUM(booked_count)   booked_count,
   SUM(prev_booked_count)  prev_booked_count,
   SUM(segment_size)  segment_size,
   SUM(prev_segment_size) prev_segment_size,
   SUM(active_customers) active_customers,
   SUM(prev_active_customers)   prev_active_customers
   FROM
   (
  SELECT
  a.segment_id viewbyid
  '||l_col||' ,
  SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.revenue'||l_curr_suffix||',0)) revenue ,
  SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.revenue'||l_curr_suffix||',0))   prev_revenue,
  SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
  SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt,
  SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_count,0)) booked_count,
  SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_count,0)) prev_booked_count,
  0 total_customers,
  0 prev_total_customers,
  0 segment_size,
  0 prev_segment_size,
  0 active_customers,
  0	prev_active_customers
  FROM bim_sgmt_val_f_mv a,fii_time_rpt_struct_v cal '||l_from||'
  WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND  cal.calendar_id= -1
 '||l_where
  ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
  GROUP BY a.segment_id '||l_groupby||'
  UNION ALL
  SELECT
  a.segment_id viewbyid
  '||l_col||' ,
  0  revenue  ,
  0  prev_revenue,
  0  booked_amt,
  0  prev_booked_amt,
  0  booked_count,
  0  prev_booked_count,
  SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.total_customers,0)) total_customers,
  SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.total_customers,0)) prev_total_customers,
  SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.segment_size,0)) segment_size,
  SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.segment_size,0)) prev_segment_size,
  0 active_customers,
  0	 prev_active_customers
  FROM bim_sgmt_val_f_mv a,fii_time_rpt_struct_v cal '||l_from||'
  WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
  AND  cal.calendar_id= -1
 '||l_where
  ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
  GROUP BY a.segment_id '||l_groupby||'
  UNION ALL
  SELECT
  a.segment_id viewbyid
  '||l_col||' ,
  0  revenue  ,
  0  prev_revenue,
  0  booked_amt,
  0  prev_booked_amt,
  0  booked_count,
  0  prev_booked_count,
  0  total_customers,
  0  prev_total_customers,
  0  segment_size,
  0  prev_segment_size,
  SUM('||l_active_cust_col||') active_customers,
  0	 prev_active_customers
  FROM bim_i_sgmt_facts a,fii_time_day cal '||l_from||'
  WHERE a.transaction_create_date between cal.'||l_start_date||' and &BIS_CURRENT_ASOF_DATE
 '||l_where
  ||' AND cal.report_date =&BIS_CURRENT_ASOF_DATE
  AND a.metric_type=''CUST''
  GROUP BY a.segment_id '||l_groupby||'
   UNION ALL
   --Select to capture Previous Active Customer
  SELECT
  a.segment_id viewbyid
  '||l_col||' ,
  0  revenue  ,
  0  prev_revenue,
  0  booked_amt,
  0  prev_booked_amt,
  0  booked_count,
  0  prev_booked_count,
  0  total_customers,
  0  prev_total_customers,
  0  segment_size,
  0  prev_segment_size,
  0  active_customers,
  SUM('||l_active_cust_col||') prev_active_customers
  FROM bim_i_sgmt_facts a,fii_time_day cal '||l_from||'
  WHERE a.transaction_create_date between cal.'||l_start_date||' and &BIS_PREVIOUS_ASOF_DATE
 '||l_where
  ||' AND cal.report_date = &BIS_PREVIOUS_ASOF_DATE
  AND a.metric_type=''CUST''
  GROUP BY a.segment_id '||l_groupby||' ) a,ams_cells_all_tl b
  WHERE a.viewbyid=b.cell_id
  and b.language=userenv(''LANG'')
  group by viewbyid,b.cell_name,a.leaf_node_flag )
  &ORDER_BY_CLAUSE';
   x_custom_sql := l_sqltext;

   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_sgmt_id';
   l_custom_rec.attribute_value := l_sgmt_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
END;


PROCEDURE  GET_SGMT_REVENUE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_cat_id                       VARCHAR2 (50) ;
   l_sgmt_id                      VARCHAR2 (50) ;
   l_curr		          VARCHAR2(50);
   l_view_by                      VARCHAR2 (4000);
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_custom_rec                   BIS_QUERY_ATTRIBUTES;
   l_object_type                  VARCHAR2(30);
   l_url_link                     VARCHAR2(200);
   l_url_camp1                    VARCHAR2(3000);
   l_url_camp2                    VARCHAR2(3000);
   l_start_date                   VARCHAR2(30);
   l_curr_suffix                  VARCHAR2(2);
   l_url_metric						VARCHAR2(10);
   l_url_viewby						VARCHAR2(100);
   l_url_viewbyid					VARCHAR2(100);
   l_from							VARCHAR2(100);

BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
   bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
						l_as_of_date ,
          			                l_period_type,
     		        	                l_record_type_id,
				                l_view_by,
				                l_cat_id ,
				                l_sgmt_id,
				                l_curr ,
								l_url_metric,
								l_url_viewby,
								l_url_viewbyid
				                ) ;
   	 IF l_sgmt_id is null THEN
       l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
	   l_from := l_from||' , bim_i_sgmt_denorm dn ';
	ELSE
      l_where := 'AND a.segment_id=:l_sgmt_id ';

	END IF;

   IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;

l_sqltext:='
select
fii.name VIEWBY,
revenue bim_attribute2,
case when revenue_p =0 then null else ((revenue-revenue_p)/revenue_p)*100 end  bim_attribute3
FROM
( SELECT dates.start_date start_date,
sum(decode(dates.period, ''C'',a.revenue'||l_curr_suffix||',0)) revenue,
sum(decode(dates.period, ''P'',a.revenue'||l_curr_suffix||',0)) revenue_p
FROM
(
SELECT
   fii.start_date START_DATE,
   ''C'' PERIOD,
   least(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
   FROM '||l_period_type||'   fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
UNION ALL
 SELECT
   p2.start_date START_DATE,
   ''P'' PERIOD,
   p1.report_date REPORT_DATE
 FROM
   (
	SELECT report_date , rownum id
	FROM
		(
		SELECT
			least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
		FROM ' ||l_period_type||'   fii
		WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p1,
    (
	SELECT start_date , rownum id
	FROM
		(
		SELECT
			fii.start_date START_DATE
		FROM  ' ||l_period_type||'  fii
		WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p2
    WHERE p1.id(+) = p2.id) dates, bim_sgmt_val_f_mv a,fii_time_rpt_struct_v cal '||l_from||'
    WHERE cal.report_date	= dates.report_date
    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
	AND a.time_id = cal.time_id
	AND a.period_type_id = cal.period_type_id '||l_where||' group by dates.start_date )
    s,'|| l_period_type||' fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
         fii.start_date = s.start_date(+)
  order by fii.start_date ';



   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_sgmt_id';
   l_custom_rec.attribute_value := l_sgmt_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
END GET_SGMT_REVENUE_SQL;

PROCEDURE  GET_ACTIVE_CUST_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_cat_id                       VARCHAR2 (50) ;
   l_sgmt_id                      VARCHAR2 (50) ;
   l_curr		          VARCHAR2(50);
   l_view_by                      VARCHAR2 (4000);
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_custom_rec                   BIS_QUERY_ATTRIBUTES;
   l_object_type                  VARCHAR2(30);
   l_url_link                     VARCHAR2(200);
   l_url_camp1                    VARCHAR2(3000);
   l_url_camp2                    VARCHAR2(3000);
   l_active_cust_col              VARCHAR2(30);
   l_start_date                   VARCHAR2(30);
   l_curr_suffix                  VARCHAR2(2);
   l_url_metric			  VARCHAR2(10);
   l_url_viewby			  VARCHAR2(100);
   l_url_viewbyid		  VARCHAR2(100);
   l_from			  VARCHAR2(100);

BEGIN
	x_custom_output := bis_query_attributes_tbl ();
	l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
	bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
												l_as_of_date ,
												l_period_type,
												l_record_type_id,
												l_view_by,
												l_cat_id ,
												l_sgmt_id,
												l_curr ,
												l_url_metric,
												l_url_viewby,
												l_url_viewbyid
												) ;
	IF l_sgmt_id IS NULL THEN

		l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
		l_from := l_from||' , bim_i_sgmt_denorm dn ';
	ELSE

		l_where := 'AND a.segment_id=:l_sgmt_id';

	END IF;


CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN
		 l_active_cust_col := 'cust_count_week';
		 l_start_date:='week_start_date';
    WHEN 'FII_TIME_ENT_PERIOD' THEN
         l_active_cust_col := 'cust_count_month';
         l_start_date:='ent_period_start_date';
    WHEN 'FII_TIME_ENT_QTR' THEN
          l_active_cust_col := 'cust_count_qtr';
          l_start_date:='ent_qtr_start_date';
    WHEN 'FII_TIME_ENT_YEAR' THEN
          l_active_cust_col := 'cust_count_year';
          l_start_date:='ent_year_start_date';
    ELSE  l_active_cust_col := 'cust_count_week';
          l_start_date:='week_start_date';
  END CASE;

l_sqltext:='
select
fii.name VIEWBY,
active_customer bim_attribute2,
case when  active_customer_p =0 then null else (( active_customer- active_customer_p)/active_customer_p)*100 end  bim_attribute3
FROM
( SELECT dates.start_date start_date,
sum(decode(dates.period, ''C'','||l_active_cust_col||',0)) active_customer,
sum(decode(dates.period, ''P'','||l_active_cust_col||',0)) active_customer_p
FROM
(
SELECT
   fii.start_date START_DATE,
   ''C'' PERIOD,
   least(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
   FROM '||l_period_type||'   fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
UNION ALL
 SELECT
   p2.start_date START_DATE,
   ''P'' PERIOD,
   p1.report_date REPORT_DATE
 FROM
   (
	SELECT report_date, rownum id
	FROM
		(
		SELECT
			least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
		FROM ' ||l_period_type||'   fii
		WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p1,
    (
	SELECT start_date, rownum id
	FROM
		(
		SELECT
			fii.start_date START_DATE
		FROM  ' ||l_period_type||'  fii
		WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p2
    WHERE p1.id(+) = p2.id) dates, bim_i_sgmt_facts a,fii_time_day cal '||l_from||'
    WHERE cal.report_date	= dates.report_date
    AND a.transaction_create_date between cal.'||l_start_date||' and cal.report_date
    '||l_where||' group by dates.start_date )
    s,'|| l_period_type||' fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
         fii.start_date = s.start_date(+)
   order by fii.start_date ';
   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_sgmt_id';
   l_custom_rec.attribute_value := l_sgmt_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
END GET_ACTIVE_CUST_SQL;



PROCEDURE  GET_SGMT_SIZE_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_cat_id                       VARCHAR2 (50) ;
   l_sgmt_id                      VARCHAR2 (50) ;
   l_curr		          VARCHAR2(50);
   l_view_by                      VARCHAR2 (4000);
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_custom_rec                   BIS_QUERY_ATTRIBUTES;
   l_object_type                  VARCHAR2(30);
   l_url_link                     VARCHAR2(200);
   l_url_camp1                    VARCHAR2(3000);
   l_url_camp2                    VARCHAR2(3000);
   l_start_date                   VARCHAR2(30);
   l_curr_suffix                  VARCHAR2(2);
   l_url_metric						VARCHAR2(10);
   l_url_viewby						VARCHAR2(100);
   l_url_viewbyid					VARCHAR2(100);
   l_from							VARCHAR2(100);

BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
   bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
						l_as_of_date ,
          			                l_period_type,
     		        	                l_record_type_id,
				                l_view_by,
				                l_cat_id ,
				                l_sgmt_id,
				                l_curr ,
								l_url_metric,
								l_url_viewby,
								l_url_viewbyid
				                ) ;
   IF l_sgmt_id is null THEN
       l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
	   l_from := l_from||' , bim_i_sgmt_denorm dn ';
	ELSE
      l_where := 'AND a.segment_id=:l_sgmt_id';

	END IF;

l_sqltext:='
select
fii.name VIEWBY,
seg_size bim_attribute2,
case when seg_size_p =0 then null else ((seg_size-seg_size_p)/seg_size_p)*100 end  bim_attribute3
FROM
( SELECT dates.start_date start_date,
sum(decode(dates.period, ''C'',a.segment_size,0)) seg_size,
sum(decode(dates.period, ''P'',a.segment_size,0)) seg_size_p
FROM
(
SELECT
   fii.start_date START_DATE,
   ''C'' PERIOD,
   least(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
   FROM '||l_period_type||'   fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
UNION ALL
 SELECT
   p2.start_date START_DATE,
   ''P'' PERIOD,
   p1.report_date REPORT_DATE
 FROM
   (
	SELECT report_date , ROWNUM id
	FROM
		(
		SELECT
			least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
		FROM ' ||l_period_type||'   fii
		WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p1,
    (
	SELECT start_date , ROWNUM id
	FROM
		(
		SELECT fii.start_date START_DATE,
		rownum ID
		FROM  ' ||l_period_type||'  fii
		WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p2
    WHERE p1.id(+) = p2.id) dates, bim_sgmt_val_f_mv a,fii_time_rpt_struct_v cal '||l_from||'
    WHERE  cal.report_date	= dates.report_date
    AND bitand(cal.record_type_id,1143) = cal.record_type_id
	AND a.time_id = cal.time_id
	AND a.period_type_id = cal.period_type_id '||l_where||' group by dates.start_date )
    s,'|| l_period_type||' fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
         fii.start_date = s.start_date(+)
   order by fii.start_date ';
   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_sgmt_id';
   l_custom_rec.attribute_value := l_sgmt_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
END GET_SGMT_SIZE_SQL;

PROCEDURE GET_SGMT_AVG_TXN_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
				x_custom_sql  OUT NOCOPY VARCHAR2,
				x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_cat_id                       VARCHAR2 (50) ;
   l_sgmt_id                      VARCHAR2 (50) ;
   l_curr		          VARCHAR2(50);
   l_view_by                      VARCHAR2 (4000);
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_custom_rec                   BIS_QUERY_ATTRIBUTES;
   l_object_type                  VARCHAR2(30);
   l_url_link                     VARCHAR2(200);
   l_url_camp1                    VARCHAR2(3000);
   l_url_camp2                    VARCHAR2(3000);
   l_start_date                   VARCHAR2(30);
   l_curr_suffix                  VARCHAR2(2);
   l_url_metric						VARCHAR2(10);
   l_url_viewby						VARCHAR2(100);
   l_url_viewbyid					VARCHAR2(100);
   l_from						VARCHAR2(100);

BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
   bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
						l_as_of_date ,
          			                l_period_type,
     		        	                l_record_type_id,
				                l_view_by,
				                l_cat_id ,
				                l_sgmt_id,
				                l_curr ,
								l_url_metric,
								l_url_viewby,
								l_url_viewbyid
				                ) ;

  	 IF l_sgmt_id is null THEN
       l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
	   l_from := l_from||' , bim_i_sgmt_denorm dn ';
	ELSE
      l_where := 'AND a.segment_id=:l_sgmt_id';

	END IF;

   IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;

l_sqltext:='
select
fii.name VIEWBY,
case when booked_count =0 then null else (booked_amt/booked_count) end bim_attribute2,
case when (prev_booked_count=0 OR prev_booked_amt=0 OR booked_count=0) then null else (((booked_amt/booked_count)-(prev_booked_amt/prev_booked_count))/ (prev_booked_amt/prev_booked_count))*100
end bim_attribute3
FROM
( SELECT dates.start_date start_date,
SUM(decode(dates.period, ''C'',a.booked_amt'||l_curr_suffix||',0)) booked_amt,
SUM(decode(dates.period, ''P'',a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt,
SUM(decode(dates.period, ''C'',a.booked_count,0)) booked_count,
SUM(decode(dates.period, ''P'',a.booked_count,0)) prev_booked_count
FROM
(
SELECT
   fii.start_date START_DATE,
   ''C'' PERIOD,
   least(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
   FROM '||l_period_type||'   fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
UNION ALL
 SELECT
   p2.start_date START_DATE,
   ''P'' PERIOD,
   p1.report_date REPORT_DATE
 FROM
   (
	SELECT report_date , ROWNUM id
	FROM
		(
		SELECT
			least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
		FROM ' ||l_period_type||'   fii
		WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
		ORDER BY fii.start_date DESC
		)
	) p1,
    (
	SELECT start_date, ROWNUM id
	FROM
		(
			SELECT fii.start_date START_DATE
			FROM  ' ||l_period_type||'  fii
			WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
			ORDER BY fii.start_date DESC
		)
	) p2
    WHERE p1.id(+) = p2.id) dates, bim_sgmt_val_f_mv a,fii_time_rpt_struct_v cal '||l_from||'
    WHERE  cal.report_date	= dates.report_date
    AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
	AND a.time_id = cal.time_id
	AND a.period_type_id = cal.period_type_id '||l_where||' group by dates.start_date )
    s,'|| l_period_type||' fii
   WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE AND
         fii.start_date = s.start_date(+)
   order by fii.start_date ';




   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_sgmt_id';
   l_custom_rec.attribute_value := l_sgmt_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
END GET_SGMT_AVG_TXN_SQL;

PROCEDURE GET_CAMP_EFF_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_sqltext					VARCHAR2 (20000);
	l_as_of_date				DATE;
	l_period_type				VARCHAR2 (2000);
	l_record_type_id			NUMBER;
	l_cat_id					VARCHAR2 (50) ;
	l_sgmt_id					VARCHAR2 (50) ;
	l_curr						VARCHAR2(50);
	l_view_by					VARCHAR2 (4000);

	l_where						VARCHAR2 (20000);  -- static where clause
	l_groupby					VARCHAR2 (2000);  -- to build  group by clause
	l_pc_from					VARCHAR2 (20000);   -- from clause to handle product category
	l_pc_where					VARCHAR2 (20000);   --  where clause to handle product category
	l_custom_rec				BIS_QUERY_ATTRIBUTES;
	l_object_type				VARCHAR2(30);
	l_url_link					VARCHAR2(200);

	l_start_date				VARCHAR2(30);
	l_curr_suffix				VARCHAR2(2);
	l_bim_url2					VARCHAR2(50);
	l_bim_url3					VARCHAR2(50);
	l_bim_url4					VARCHAR2(50);
	l_bim_url5					VARCHAR2(50);
	l_bim_url6					VARCHAR2(50);
    l_view_by_id                VARCHAR2(50);
	l_url_metric						VARCHAR2(10);
   l_url_viewby						VARCHAR2(100);
   l_url_viewbyid					VARCHAR2(100);
	l_from						VARCHAR2(200);
	l_url_str					VARCHAR2(1000);
	l_url_str_sgmt_jtf			VARCHAR2(1000);
	l_setup_id					VARCHAR2(50);
	l_url_str_csch_jtf			VARCHAR2(1000);
	l_leaf_node_flag			VARCHAR2(1);
	l_col						VARCHAR2(200);



BEGIN
	x_custom_output := bis_query_attributes_tbl ();
	l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
	bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
												l_as_of_date ,
												l_period_type,
												l_record_type_id,
												l_view_by,
												l_cat_id ,
												l_sgmt_id,
												l_curr,
												l_url_metric,
												l_url_viewby,
												l_url_viewbyid
												) ;

	l_bim_url2 := 'ACT';
	l_bim_url3 := 'RESP';
	l_bim_url4 := 'LEAD';
	l_bim_url5 := 'OPPT';
	l_bim_url6 := 'BOOK';
    l_view_by_id:='VIEWBYID';


	IF (l_curr = '''FII_GLOBAL1''')	THEN

		l_curr_suffix := '';

	ELSIF (l_curr = '''FII_GLOBAL2''')	THEN

		l_curr_suffix := '_s';

	ELSE
		l_curr_suffix := '';

	END IF;


	IF  l_cat_id IS NOT NULL THEN

		l_pc_from   :=  ' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs';
		l_pc_where  :=  ' AND a.category_id = edh.child_id
						AND edh.object_type = ''CATEGORY_SET''
						AND edh.object_id = mdcs.category_set_id
						AND mdcs.functional_area_id = 11
						AND edh.dbi_flag = ''Y''
						AND edh.parent_id = :l_cat_id ';

	ELSE
		l_pc_where :=     ' AND a.category_id = -9 ';

	END IF;

	IF l_view_by = 'TARGET SEGMENT+TARGET SEGMENT' THEN

		l_url_link := '&BIM_DIM11='||l_view_by_id||'&ENI_ITEM_VBH_CAT='||replace(l_cat_id,'''',null)||'&BIM_PARAMETER2='||l_view_by_id||'&BIM_PARAMETER3='||l_view_by;

		l_url_str  :='''pFunctionName=BIM_I_SGMT_CAMP_EFF_R&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID''';

		--l_url_str_sgmt_jtf :='''pFunctionName=BIM_I_SGMT_DRILL&PAGE.OBJ.objType=CELL&PAGE.OBJ.objAttribute=HIER&PAGE.OBJ.ID_NAME0=treeSearchId&PAGE.OBJ.treeSearchFlag=Y&PAGE.OBJ.ID0=VIEWBYID&treeSearchId=VIEWBYID''';
		l_url_str_sgmt_jtf := 'NULL';

		IF l_sgmt_id is null THEN
			--i.e The value in Segment Lov is NULL , then show only Parent Segments

			l_from := ' , bim_i_sgmt_denorm dn ' ;
			l_where := ' AND dn.immediate_parent_id IS NULL AND a.segment_id=dn.segment_id ';
			l_groupby := ' , dn.leaf_node_flag ' ;
			l_col	:=  ' , dn.leaf_node_flag leaf_node_flag ' ;

		ELSE
			-- two cases here, if the segment is a parent segment , then show the children underneath
			-- else show that segment only
			BEGIN

				SELECT	leaf_node_flag
				INTO	l_leaf_node_flag
				FROM	bim_i_sgmt_denorm
				WHERE   segment_id = replace(l_sgmt_id,'''',null)
				AND		segment_id = parent_segment_id;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;

			IF l_leaf_node_flag = 'Y' THEN
				--Show the segment itself

				l_where := ' AND a.segment_id = :l_sgmt_id ';
				l_col	:=  ' , '''||l_leaf_node_flag||''' leaf_node_flag ' ;

			ELSE
				--Show only immediate Children

				l_from := ' , bim_i_sgmt_denorm dn ' ;
				l_where := ' AND dn.immediate_parent_id=:l_sgmt_id AND dn.immediate_parent_flag = ''Y''
							 AND a.segment_id=dn.segment_id ';

				l_groupby := ' , dn.leaf_node_flag ' ;
				l_col	:=  ' , dn.leaf_node_flag leaf_node_flag ' ;

			END IF;

		END IF;

		l_sqltext:='
		SELECT
			VIEWBY,
			VIEWBYID,
			activities BIM_ATTRIBUTE2,
			CASE WHEN prev_activities = 0 THEN NULL ELSE ((activities-prev_activities)/prev_activities)*100 end BIM_ATTRIBUTE3,
			responses BIM_ATTRIBUTE4,
			CASE WHEN prev_responses = 0 THEN NULL ELSE ((responses-prev_responses)/prev_responses)*100 end BIM_ATTRIBUTE5,
			leads BIM_ATTRIBUTE6,
			CASE WHEN prev_leads = 0 THEN NULL ELSE ((leads - prev_leads)/prev_leads)*100 end BIM_ATTRIBUTE7,
			new_opportunity_amt BIM_ATTRIBUTE8,
			CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100 end BIM_ATTRIBUTE9,
			booked_amt BIM_ATTRIBUTE10,
			CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ((booked_amt - prev_booked_amt)/prev_booked_amt)*100 end BIM_ATTRIBUTE11,
			CASE WHEN activities=0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_CAMP_ACT_R&pParamIds=Y'||l_url_link||''' END BIM_URL1,
			CASE WHEN prev_activities = 0 THEN null ELSE ''pFunctionName=BIM_I_SGMT_ACT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url2||l_url_link||''' END BIM_URL2,
			CASE WHEN prev_responses = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_RESP_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url3||l_url_link||''' END BIM_URL3,
			CASE WHEN prev_leads = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_LEAD_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url4||l_url_link||''' END BIM_URL4,
			CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_OPPT_AMT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url5||l_url_link||''' END BIM_URL5,
			CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_BOOK_ODR_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url6||l_url_link||''' END BIM_URL6,
			decode( leaf_node_flag ,''Y'','||l_url_str_sgmt_jtf||','||l_url_str||') BIM_URL7,
			NULL	BIM_URL8,
			NULL    BIM_URL9
		FROM
		(
			SELECT
				b.cell_name VIEWBY,
				VIEWBYID,
				a.leaf_node_flag leaf_node_flag,
				SUM(activities) activities,
				SUM(prev_activities)  prev_activities,
				SUM(responses) responses,
				SUM(prev_responses) prev_responses,
				SUM(leads) leads,
				SUM(prev_leads)  prev_leads,
				SUM(new_opportunity_amt) new_opportunity_amt,
				SUM(prev_new_opportunity_amt) prev_new_opportunity_amt,
				SUM(booked_amt) booked_amt,
				SUM(prev_booked_amt) prev_booked_amt
			FROM
			(
				SELECT
					a.segment_id viewbyid
					'||l_col||' ,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.activities_count,0)) activities ,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.activities_count,0))   prev_activities,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses,0)) responses,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.responses,0))   prev_responses,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads,0)) prev_leads,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt
				FROM bim_sgmt_act_mv a , fii_time_rpt_struct_v cal  ' ||l_from||l_pc_from||
				'  WHERE a.time_id = cal.time_id
				AND  a.period_type_id = cal.period_type_id
				AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
				AND  cal.calendar_id = -1
				'||l_where ||l_pc_where
				||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
				GROUP BY a.segment_id '||l_groupby||'
			)  a , ams_cells_all_tl b
		WHERE a.viewbyid=b.cell_id
		and b.language=userenv(''LANG'')
		group by viewbyid,b.cell_name , a.leaf_node_flag
		)
		WHERE activities > 0  OR prev_activities > 0  OR responses > 0 OR prev_responses > 0
	   OR leads > 0  OR prev_leads > 0  OR    new_opportunity_amt > 0  OR    prev_new_opportunity_amt > 0
	   OR    booked_amt > 0  OR    prev_booked_amt > 0
	   &ORDER_BY_CLAUSE';

	ELSIF l_view_by = 'MEDIA+MEDIA' THEN

		--i.e view by is marketing Channnel

		l_url_link := '&BIM_DIM11='||replace(l_sgmt_id,'''',null)||'&ENI_ITEM_VBH_CAT='||replace(l_cat_id,'''',null)||'&BIM_DIM9='||l_view_by_id||'&BIM_PARAMETER3='||l_view_by||'&BIM_PARAMETER4=VIEWBY'||'&BIM_PARAMETER2='||l_view_by_id;

		IF l_sgmt_id is null THEN

			l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
			l_from := l_from||' , bim_i_sgmt_denorm dn ';
		ELSE

			l_where := 'AND a.segment_id=:l_sgmt_id ';

		END IF;

		l_sqltext:='
		SELECT
			VIEWBY,
			VIEWBYID,
			activities BIM_ATTRIBUTE2,
			CASE WHEN prev_activities = 0 THEN NULL ELSE ((activities-prev_activities)/prev_activities)*100 end BIM_ATTRIBUTE3,
			SUM(activities) OVER() BIM_GRAND_TOTAL1,
			CASE WHEN SUM(prev_activities) OVER() = 0 THEN NULL ELSE (SUM(activities) OVER()- SUM(prev_activities) OVER() )  * 100  / SUM(prev_activities) OVER() END BIM_GRAND_TOTAL2,
			responses  BIM_ATTRIBUTE4,
			CASE WHEN prev_responses = 0 THEN NULL ELSE ((responses-prev_responses)/prev_responses)*100 end BIM_ATTRIBUTE5,
			SUM(responses) OVER() BIM_GRAND_TOTAL3,
			CASE WHEN SUM(prev_responses) OVER() = 0 THEN NULL ELSE (SUM(responses) OVER()- SUM(prev_responses) OVER() ) * 100  / SUM(prev_responses) OVER() END BIM_GRAND_TOTAL4,
			leads BIM_ATTRIBUTE6,
			CASE WHEN prev_leads = 0 THEN NULL ELSE ((leads - prev_leads)/prev_leads)*100 end BIM_ATTRIBUTE7,
			SUM(leads) OVER() BIM_GRAND_TOTAL5,
			CASE WHEN SUM(prev_leads) OVER() = 0 THEN NULL ELSE (SUM(leads) OVER()- SUM(prev_leads) OVER() ) * 100  / SUM(prev_leads) OVER() END BIM_GRAND_TOTAL6,
			new_opportunity_amt BIM_ATTRIBUTE8,
			CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100 end BIM_ATTRIBUTE9,
			SUM(new_opportunity_amt) OVER() BIM_GRAND_TOTAL7,
			CASE WHEN SUM(prev_new_opportunity_amt) OVER() = 0 THEN NULL ELSE (SUM(new_opportunity_amt) OVER()- SUM(prev_new_opportunity_amt) OVER() )  * 100 / SUM(prev_leads) OVER() END BIM_GRAND_TOTAL8,
			booked_amt BIM_ATTRIBUTE10,
			CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ((booked_amt - prev_booked_amt)/prev_booked_amt)*100 end BIM_ATTRIBUTE11,
			SUM(booked_amt) OVER() BIM_GRAND_TOTAL9,
			CASE WHEN SUM(prev_booked_amt) OVER() = 0 THEN NULL ELSE (SUM(booked_amt) OVER()- SUM(prev_booked_amt) OVER() )  * 100 / SUM(prev_booked_amt) OVER() END BIM_GRAND_TOTAL10,
			CASE WHEN activities=0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_CAMP_ACT_R&pParamIds=Y'||l_url_link||''' END BIM_URL1,
			CASE WHEN prev_activities = 0 THEN null ELSE ''pFunctionName=BIM_I_SGMT_ACT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url2||l_url_link||''' END BIM_URL2,
			CASE WHEN prev_responses = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_RESP_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url3||l_url_link||''' END BIM_URL3,
			CASE WHEN prev_leads = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_LEAD_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url4||l_url_link||''' END BIM_URL4,
			CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_OPPT_AMT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url5||l_url_link||''' END BIM_URL5,
			CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_BOOK_ODR_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url6||l_url_link||''' END BIM_URL6,
			NULL    BIM_URL7,
			NULL	BIM_URL8,
			NULL    BIM_URL9
		FROM
		(
			SELECT
				b.value VIEWBY,
				VIEWBYID,
				SUM(activities) activities,
				SUM(prev_activities)  prev_activities,
				SUM(responses) responses,
				SUM(prev_responses)  prev_responses,
				SUM(leads) leads,
				SUM(prev_leads)  prev_leads,
				SUM(new_opportunity_amt)  new_opportunity_amt,
				SUM(prev_new_opportunity_amt)    prev_new_opportunity_amt,
				SUM(booked_amt)  booked_amt,
				SUM(prev_booked_amt) prev_booked_amt
			FROM
			(
				SELECT
					a.activity_id viewbyid,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.activities_count,0)) activities ,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.activities_count,0))   prev_activities,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses,0)) responses,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.responses,0))   prev_responses,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads,0)) prev_leads,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt
				FROM bim_sgmt_act_ch_mv a , fii_time_rpt_struct_v cal ' ||l_pc_from||l_from||
				'  WHERE a.time_id = cal.time_id
				AND  a.period_type_id = cal.period_type_id
				AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
				AND  cal.calendar_id = -1
				'||l_where ||l_pc_where
				||'
				AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
				GROUP BY a.activity_id
			)  a , bim_dimv_media b
		WHERE a.viewbyid = b.id (+)
		group by viewbyid,b.value
		)
		WHERE activities > 0  OR prev_activities > 0  OR responses > 0 OR prev_responses > 0
	   OR leads > 0  OR prev_leads > 0  OR    new_opportunity_amt > 0  OR    prev_new_opportunity_amt > 0
	   OR    booked_amt > 0  OR    prev_booked_amt > 0
	   &ORDER_BY_CLAUSE';

	ELSIF l_view_by = 'CAMPAIGN+CAMPAIGN' THEN
		--i.e view by is Camapign Activity
		--l_url_link := '&BIM_DIM11=replace('||l_sgmt_id||','''',null)&ENI_ITEM_VBH_CAT=replace('||l_cat_id||','''',null)&BIM_PARAMETER2='||l_view_by_id||'&BIM_PARAMETER3='||l_view_by;
		l_url_link := '&BIM_DIM11='||replace(l_sgmt_id,'''',null)||'&ENI_ITEM_VBH_CAT='||replace(l_cat_id,'''',null)||'&BIM_PARAMETER5=VIEWBY'||'&BIM_PARAMETER2='||l_view_by_id||'&BIM_PARAMETER3='||l_view_by;
        l_setup_id := 'custom_setup_id';

		--l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID1=''||'||l_setup_id||'||
		--''&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

		l_url_str_csch_jtf :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';

		IF l_sgmt_id is null THEN

			l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
			l_from := l_from||' , bim_i_sgmt_denorm dn ';
		ELSE

			l_where := 'AND a.segment_id=:l_sgmt_id ';

		END IF;

		l_sqltext:='
			SELECT
			VIEWBY,
			VIEWBYID,
			activities BIM_ATTRIBUTE2,
			CASE WHEN prev_activities = 0 THEN NULL ELSE ((activities-prev_activities)/prev_activities)*100 end BIM_ATTRIBUTE3,
			SUM(activities) OVER() BIM_GRAND_TOTAL1,
			CASE WHEN SUM(prev_activities) OVER() = 0 THEN NULL ELSE (SUM(activities) OVER()- SUM(prev_activities) OVER() ) * 100  / SUM(prev_activities) OVER() END BIM_GRAND_TOTAL2,
			responses BIM_ATTRIBUTE4,
			CASE WHEN prev_responses = 0 THEN NULL ELSE ((responses-prev_responses)/prev_responses)*100 end BIM_ATTRIBUTE5,
			SUM(responses) OVER() BIM_GRAND_TOTAL3,
			CASE WHEN SUM(prev_responses) OVER() = 0 THEN NULL ELSE (SUM(responses) OVER()- SUM(prev_responses) OVER() ) * 100  / SUM(prev_responses) OVER() END BIM_GRAND_TOTAL4,
			leads BIM_ATTRIBUTE6,
			CASE WHEN prev_leads = 0 THEN NULL ELSE ((leads - prev_leads)/prev_leads)*100 end BIM_ATTRIBUTE7,
			SUM(leads) OVER() BIM_GRAND_TOTAL5,
			CASE WHEN SUM(prev_leads) OVER() = 0 THEN NULL ELSE (SUM(leads) OVER()- SUM(prev_leads) OVER() )  * 100 / SUM(prev_leads) OVER() END BIM_GRAND_TOTAL6,
			new_opportunity_amt BIM_ATTRIBUTE8,
			CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100 end BIM_ATTRIBUTE9,
			SUM(new_opportunity_amt) OVER() BIM_GRAND_TOTAL7,
			CASE WHEN SUM(prev_new_opportunity_amt) OVER() = 0 THEN NULL ELSE (SUM(new_opportunity_amt) OVER()- SUM(prev_new_opportunity_amt) OVER() ) * 100  / SUM(prev_new_opportunity_amt) OVER() END BIM_GRAND_TOTAL8,
			booked_amt BIM_ATTRIBUTE10,
			CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ((booked_amt - prev_booked_amt)/prev_booked_amt)*100 end BIM_ATTRIBUTE11,
			SUM(booked_amt) OVER() BIM_GRAND_TOTAL9,
			CASE WHEN SUM(prev_booked_amt) OVER() = 0 THEN NULL ELSE (SUM(booked_amt) OVER()- SUM(prev_booked_amt) OVER() ) * 100  / SUM(prev_booked_amt) OVER() END BIM_GRAND_TOTAL10,
			NULL BIM_URL1,
			CASE WHEN prev_activities = 0 THEN null ELSE ''pFunctionName=BIM_I_SGMT_ACT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url2||l_url_link||''' END BIM_URL2,
			CASE WHEN prev_responses = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_RESP_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url3||l_url_link||''' END BIM_URL3,
			CASE WHEN prev_leads = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_LEAD_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url4||l_url_link||''' END BIM_URL4,
			CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_OPPT_AMT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url5||l_url_link||''' END BIM_URL5,
			CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_BOOK_ODR_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url6||l_url_link||''' END BIM_URL6,
			NULL    BIM_URL7,
			NULL	BIM_URL8,
			'''||l_url_str_csch_jtf||'''||schedule_id  BIM_URL9
		FROM
		(
			SELECT
				b.name VIEWBY,
				VIEWBYID,
				sch.schedule_id schedule_id,
				sch.custom_setup_id,
				SUM(activities) activities,
				SUM(prev_activities)   prev_activities,
				SUM(responses) responses,
				SUM(prev_responses) prev_responses,
				SUM(leads) leads,
				SUM(prev_leads) prev_leads,
				SUM(new_opportunity_amt)  new_opportunity_amt,
				SUM(prev_new_opportunity_amt)  prev_new_opportunity_amt,
				SUM(booked_amt) booked_amt,
				SUM(prev_booked_amt) prev_booked_amt
			FROM
			(
				SELECT
					a.source_code_id viewbyid,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.activities_count,0)) activities ,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.activities_count,0))   prev_activities,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses,0)) responses,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.responses,0))   prev_responses,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads,0)) prev_leads,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
					SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
					SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt
				FROM bim_sgmt_act_sh_mv a , fii_time_rpt_struct_v cal ' ||l_pc_from|| l_from||
				'  WHERE a.time_id = cal.time_id
				AND  a.period_type_id = cal.period_type_id
				AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
				AND  cal.calendar_id = -1
				'||l_where ||l_pc_where
				||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
				GROUP BY a.source_code_id
			)  a , bim_i_obj_name_mv b , ams_campaign_schedules_b sch
		WHERE a.viewbyid = b.source_code_id (+)
		and   b.object_id = sch.schedule_id
		and b.language (+) =userenv(''LANG'')
		group by viewbyid,b.name,sch.schedule_id,sch.custom_setup_id
		)
		WHERE responses > 0 OR prev_responses > 0
	   OR leads > 0  OR prev_leads > 0  OR    new_opportunity_amt > 0  OR    prev_new_opportunity_amt > 0
	   OR    booked_amt > 0  OR    prev_booked_amt > 0
	   &ORDER_BY_CLAUSE';

	ELSIF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' THEN

		--i.e view by is Product Category
		--l_url_link := '&BIM_DIM11='||replace(l_sgmt_id,'''',null)||'&BIS_ENI_ITEM_VBH_CAT='||l_view_by_id||'&BIM_PARAMETER2='||l_view_by_id||'&BIM_PARAMETER3='||l_view_by;
		l_url_link := '&ENI_ITEM_VBH_CAT='||l_view_by_id||'&BIM_DIM11='||replace(l_sgmt_id,'''',null)||'&BIM_PARAMETER2='||l_view_by_id||'&BIM_PARAMETER3='||l_view_by;
		l_url_str  :='''pFunctionName=BIM_I_SGMT_CAMP_EFF_R&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID''';

		IF l_sgmt_id is null THEN

			l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
			l_from := l_from||' , bim_i_sgmt_denorm dn ';
		ELSE

			l_where := 'AND a.segment_id=:l_sgmt_id ';

		END IF;

		IF l_cat_id IS NULL THEN

			l_sqltext:='
			SELECT
				VIEWBY,
				VIEWBYID,
				activities BIM_ATTRIBUTE2,
				CASE WHEN prev_activities = 0 THEN NULL ELSE ((activities-prev_activities)/prev_activities)*100 end BIM_ATTRIBUTE3,
				SUM(activities) OVER() BIM_GRAND_TOTAL1,
				CASE WHEN SUM(prev_activities) OVER() = 0 THEN NULL ELSE (SUM(activities) OVER()- SUM(prev_activities) OVER() ) * 100  / SUM(prev_activities) OVER() END BIM_GRAND_TOTAL2,
				responses BIM_ATTRIBUTE4,
				CASE WHEN prev_responses = 0 THEN NULL ELSE ((responses-prev_responses)/prev_responses)*100 end BIM_ATTRIBUTE5,
				SUM(responses) OVER() BIM_GRAND_TOTAL3,
				CASE WHEN SUM(prev_responses) OVER() = 0 THEN NULL ELSE (SUM(responses) OVER()- SUM(prev_responses) OVER() ) * 100  / SUM(prev_responses) OVER() END BIM_GRAND_TOTAL4,
				leads BIM_ATTRIBUTE6,
				CASE WHEN prev_leads = 0 THEN NULL ELSE ((leads - prev_leads)/prev_leads)*100 end BIM_ATTRIBUTE7,
				SUM(leads) OVER() BIM_GRAND_TOTAL5,
				CASE WHEN SUM(prev_leads) OVER() = 0 THEN NULL ELSE (SUM(leads) OVER()- SUM(prev_leads) OVER() )  * 100 / SUM(prev_leads) OVER() END BIM_GRAND_TOTAL6,
				new_opportunity_amt BIM_ATTRIBUTE8,
				CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100 end BIM_ATTRIBUTE9,
				SUM(new_opportunity_amt) OVER() BIM_GRAND_TOTAL7,
				CASE WHEN SUM(prev_new_opportunity_amt) OVER() = 0 THEN NULL ELSE (SUM(new_opportunity_amt) OVER()- SUM(prev_new_opportunity_amt) OVER() )  * 100 / SUM(prev_new_opportunity_amt) OVER() END BIM_GRAND_TOTAL8,
				booked_amt BIM_ATTRIBUTE10,
				CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ((booked_amt - prev_booked_amt)/prev_booked_amt)*100 end BIM_ATTRIBUTE11,
				SUM(booked_amt) OVER() BIM_GRAND_TOTAL9,
				CASE WHEN SUM(prev_booked_amt) OVER() = 0 THEN NULL ELSE (SUM(booked_amt) OVER()- SUM(prev_booked_amt) OVER() ) * 100  / SUM(prev_booked_amt) OVER() END BIM_GRAND_TOTAL10,
			    CASE WHEN activities=0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_CAMP_ACT_R&pParamIds=Y'||l_url_link||''' END BIM_URL1,
				CASE WHEN prev_activities = 0 THEN null ELSE ''pFunctionName=BIM_I_SGMT_ACT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url2||l_url_link||''' END BIM_URL2,
				CASE WHEN prev_responses = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_RESP_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url3||l_url_link||''' END BIM_URL3,
				CASE WHEN prev_leads = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_LEAD_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url4||l_url_link||''' END BIM_URL4,
				CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_OPPT_AMT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url5||l_url_link||''' END BIM_URL5,
				CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_BOOK_ODR_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url6||l_url_link||''' END BIM_URL6,
				NULL  BIM_URL7,
				decode( leaf_node_flag ,''Y'', NULL, '||l_url_str||') BIM_URL8,
				NULL BIM_URL9
			FROM
			(
				SELECT
					value VIEWBY,
					VIEWBYID,
					leaf_node_flag,
					SUM(activities) activities,
					SUM(prev_activities) prev_activities,
					SUM(responses) responses,
					SUM(prev_responses) prev_responses,
					SUM(leads) leads,
					SUM(prev_leads) prev_leads,
					SUM(new_opportunity_amt) new_opportunity_amt,
					SUM(prev_new_opportunity_amt) prev_new_opportunity_amt,
					SUM(booked_amt) booked_amt,
					SUM(prev_booked_amt) prev_booked_amt
				FROM
				(
					SELECT
						p.value,
						p.parent_id viewbyid,
						p.leaf_node_flag  leaf_node_flag,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.activities_count,0)) activities ,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.activities_count,0))   prev_activities,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses,0)) responses,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.responses,0))   prev_responses,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads,0)) prev_leads,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt
					FROM bim_sgmt_act_mv a , fii_time_rpt_struct_v cal, eni_denorm_hierarchies edh,mtl_default_category_sets mdcs'||l_from||'
						 ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
							FROM eni_item_vbh_nodes_v e
							WHERE e.top_node_flag=''Y''
							AND e.child_id = e.parent_id) p
					WHERE a.time_id = cal.time_id
					AND  a.period_type_id = cal.period_type_id
					AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
					AND  cal.calendar_id = -1
					AND a.category_id = edh.child_id
					AND edh.object_type = ''CATEGORY_SET''
					AND edh.object_id = mdcs.category_set_id
					AND mdcs.functional_area_id = 11
					AND edh.dbi_flag = ''Y''
					AND edh.parent_id = p.parent_id
					AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
					'||l_where||'
					GROUP BY p.value ,p.parent_id , p.leaf_node_flag
				)
			group by viewbyid, value , leaf_node_flag
			)
			WHERE activities > 0  OR prev_activities > 0  OR responses > 0 OR prev_responses > 0
		   OR leads > 0  OR prev_leads > 0  OR    new_opportunity_amt > 0  OR    prev_new_opportunity_amt > 0
		   OR    booked_amt > 0  OR    prev_booked_amt > 0
		   &ORDER_BY_CLAUSE';

		ELSE
			-- i.e User has select a Product Category from LOV

			l_pc_where := ' AND a.category_id = :l_cat_id ';


			l_sqltext:='
			SELECT
				VIEWBY,
				VIEWBYID,
				activities BIM_ATTRIBUTE2,
				CASE WHEN prev_activities = 0 THEN NULL ELSE ((activities-prev_activities)/prev_activities)*100 end BIM_ATTRIBUTE3,
				SUM(activities) OVER() BIM_GRAND_TOTAL1,
				CASE WHEN SUM(prev_activities) OVER() = 0 THEN NULL ELSE (SUM(activities) OVER()- SUM(prev_activities) OVER() ) * 100  / SUM(prev_activities) OVER() END BIM_GRAND_TOTAL2,
				responses BIM_ATTRIBUTE4,
				CASE WHEN prev_responses = 0 THEN NULL ELSE ((responses-prev_responses)/prev_responses)*100 end BIM_ATTRIBUTE5,
				SUM(responses) OVER() BIM_GRAND_TOTAL3,
				CASE WHEN SUM(prev_responses) OVER() = 0 THEN NULL ELSE (SUM(responses) OVER()- SUM(prev_responses) OVER() ) * 100  / SUM(prev_responses) OVER() END BIM_GRAND_TOTAL4,
				leads BIM_ATTRIBUTE6,
				CASE WHEN prev_leads = 0 THEN NULL ELSE ((leads - prev_leads)/prev_leads)*100 end BIM_ATTRIBUTE7,
				SUM(leads) OVER() BIM_GRAND_TOTAL5,
				CASE WHEN SUM(prev_leads) OVER() = 0 THEN NULL ELSE (SUM(leads) OVER()- SUM(prev_leads) OVER() ) * 100  / SUM(prev_leads) OVER() END BIM_GRAND_TOTAL6,
				new_opportunity_amt BIM_ATTRIBUTE8,
				CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100 end BIM_ATTRIBUTE9,
				SUM(new_opportunity_amt) OVER() BIM_GRAND_TOTAL7,
				CASE WHEN SUM(prev_new_opportunity_amt) OVER() = 0 THEN NULL ELSE (SUM(new_opportunity_amt) OVER()- SUM(prev_new_opportunity_amt) OVER() )  * 100 / SUM(prev_new_opportunity_amt) OVER() END BIM_GRAND_TOTAL8,
				booked_amt BIM_ATTRIBUTE10,
				CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ((booked_amt - prev_booked_amt)/prev_booked_amt)*100 end BIM_ATTRIBUTE11,
				SUM(booked_amt) OVER() BIM_GRAND_TOTAL9,
				CASE WHEN SUM(prev_booked_amt) OVER() = 0 THEN NULL ELSE (SUM(booked_amt) OVER()- SUM(prev_booked_amt) OVER() ) * 100  / SUM(prev_booked_amt) OVER() END BIM_GRAND_TOTAL10,
				CASE WHEN activities=0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_CAMP_ACT_R&pParamIds=Y'||l_url_link||''' END BIM_URL1,
				CASE WHEN prev_activities = 0 THEN null ELSE ''pFunctionName=BIM_I_SGMT_ACT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url2||l_url_link||''' END BIM_URL2,
				CASE WHEN prev_responses = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_RESP_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url3||l_url_link||''' END BIM_URL3,
				CASE WHEN prev_leads = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_LEAD_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url4||l_url_link||''' END BIM_URL4,
				CASE WHEN prev_new_opportunity_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_OPPT_AMT_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url5||l_url_link||''' END BIM_URL5,
				CASE WHEN prev_booked_amt = 0 THEN NULL ELSE ''pFunctionName=BIM_I_SGMT_BOOK_ODR_T&pParamIds=Y&BIM_PARAMETER1='||l_bim_url6||l_url_link||''' END BIM_URL6,
				NULL  BIM_URL7,
				decode( leaf_node_flag ,''Y'', NULL, '||l_url_str||') BIM_URL8,
				NULL BIM_URL9
			FROM
			(
				SELECT
					value VIEWBY,
					VIEWBYID,
					leaf_node_flag,
					SUM(activities) activities,
					SUM(prev_activities) prev_activities,
					SUM(responses) responses,
					SUM(prev_responses) prev_responses,
					SUM(leads) leads,
					SUM(prev_leads) prev_leads,
					SUM(new_opportunity_amt) new_opportunity_amt,
					SUM(prev_new_opportunity_amt) prev_new_opportunity_amt,
					SUM(booked_amt) booked_amt,
					SUM(prev_booked_amt) prev_booked_amt
				FROM
				(
					SELECT
						p.value,
						p.id viewbyid,
						p.leaf_node_flag  leaf_node_flag,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.activities_count,0)) activities ,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.activities_count,0))   prev_activities,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses,0)) responses,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.responses,0))   prev_responses,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads,0)) prev_leads,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt
					FROM bim_sgmt_act_mv a , fii_time_rpt_struct_v cal , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs
						,(	SELECT e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
							FROM eni_item_vbh_nodes_v e
							WHERE e.parent_id =  :l_cat_id
							AND e.id = e.child_id
							AND ((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p '||l_from||'
					WHERE a.time_id = cal.time_id
					AND  a.period_type_id = cal.period_type_id
					AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
					AND  cal.calendar_id = -1
					AND a.category_id = edh.child_id
					AND edh.object_type = ''CATEGORY_SET''
					AND edh.object_id = mdcs.category_set_id
					AND mdcs.functional_area_id = 11
					AND edh.dbi_flag = ''Y''
					AND edh.parent_id = p.id
					AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
					 '||l_where||'
					GROUP BY p.value , p.id , p.leaf_node_flag
					UNION ALL
					SELECT
						bim_pmv_dbi_utl_pkg.get_lookup_value(''DASS'') value,
						p.id viewbyid,
						p.leaf_node_flag  leaf_node_flag,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.activities_count,0)) activities ,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.activities_count,0))   prev_activities,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses,0)) responses,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.responses,0))   prev_responses,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads,0)) prev_leads,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
						SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) booked_amt,
						SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.booked_amt'||l_curr_suffix||',0)) prev_booked_amt
					FROM bim_sgmt_act_mv a , fii_time_rpt_struct_v cal ,
						(	SELECT e.id id ,e.value value , leaf_node_flag
							FROM eni_item_vbh_nodes_v e
							WHERE e.parent_id =  :l_cat_id
							AND e.parent_id = e.child_id
							AND leaf_node_flag <> ''Y'') p '||l_from||'
					WHERE a.time_id = cal.time_id
					AND  a.period_type_id = cal.period_type_id
					AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
					AND  cal.calendar_id = -1
					AND a.category_id = p.id
					AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
					 '||l_where||'
					GROUP BY p.value , p.id , p.leaf_node_flag
				)
			group by viewbyid, value , leaf_node_flag
			)
			WHERE activities > 0  OR prev_activities > 0  OR responses > 0 OR prev_responses > 0
		   OR leads > 0  OR prev_leads > 0  OR    new_opportunity_amt > 0  OR    prev_new_opportunity_amt > 0
		   OR    booked_amt > 0  OR    prev_booked_amt > 0
		   &ORDER_BY_CLAUSE';

		END IF;
	END IF;

	x_custom_sql := l_sqltext;
	l_custom_rec.attribute_name := ':l_record_type';
	l_custom_rec.attribute_value := l_record_type_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (1) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_sgmt_id';
	l_custom_rec.attribute_value := l_sgmt_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (2) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_cat_id';
	l_custom_rec.attribute_value := l_cat_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (3) := l_custom_rec;


END GET_CAMP_EFF_SQL;

PROCEDURE GET_CAMP_ACT_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_sqltext					VARCHAR2 (20000);
	iflag						NUMBER;
	l_period_type_hc			NUMBER;
	l_as_of_date				DATE;
	l_period_type				VARCHAR2 (2000);
	l_record_type_id			NUMBER;
	l_cat_id					VARCHAR2 (50) ;
	l_sgmt_id					VARCHAR2 (50) ;
	l_curr						VARCHAR2(50);
	l_view_by					VARCHAR2 (4000);
	l_select_filter				VARCHAR2 (20000); -- to build  select filter part
	l_where						VARCHAR2 (20000);  -- static where clause
	l_groupby					VARCHAR2 (2000);  -- to build  group by clause
	l_pc_from					VARCHAR2 (20000);   -- from clause to handle product category
	l_pc_where					VARCHAR2 (20000);   --  where clause to handle product category
	l_custom_rec				BIS_QUERY_ATTRIBUTES;
	l_object_type				VARCHAR2(30);
	l_url_link					VARCHAR2(200);
	l_url_camp1					VARCHAR2(3000);
	l_url_camp2					VARCHAR2(3000);

	l_start_date				VARCHAR2(30);
	l_curr_suffix				VARCHAR2(2);
	l_bim_url2					VARCHAR2(50);
	l_bim_url3					VARCHAR2(50);
	l_bim_url4					VARCHAR2(50);
	l_bim_url5					VARCHAR2(50);
	l_bim_url6					VARCHAR2(50);
    l_view_by_id                VARCHAR2(50);
	l_url_metric				VARCHAR2(10);
	l_url_viewby				VARCHAR2(100);
	l_url_viewbyid				VARCHAR2(100);
	l_from						VARCHAR2(100);
	l_resource_id				NUMBER;
	l_setup_id					VARCHAR2(50);
	l_url_str_csch_jtf			VARCHAR2(1000);
	l_from_outer				VARCHAR2(200);
	l_where_outer				VARCHAR2(500);


BEGIN
	x_custom_output := bis_query_attributes_tbl ();
	l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
	bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
												l_as_of_date ,
												l_period_type,
												l_record_type_id,
												l_view_by,
												l_cat_id ,
												l_sgmt_id,
												l_curr,
												l_url_metric,
												l_url_viewby,
												l_url_viewbyid
												) ;


	IF l_url_viewby = 'MEDIA+MEDIA' THEN


		l_where := ' AND a.activity_id = '||l_url_viewbyid;


	END IF;

	IF (l_curr = '''FII_GLOBAL1''')	THEN

		l_curr_suffix := '';

	ELSIF (l_curr = '''FII_GLOBAL2''')	THEN

		l_curr_suffix := '_s';

	ELSE

		l_curr_suffix := '';

	END IF;

	IF  l_cat_id IS NOT NULL THEN

		l_pc_from   :=  ' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs';
		l_pc_where  :=  ' AND a.category_id = edh.child_id
						AND edh.object_type = ''CATEGORY_SET''
						AND edh.object_id = mdcs.category_set_id
						AND mdcs.functional_area_id = 11
						AND edh.dbi_flag = ''Y''
						AND edh.parent_id = :l_cat_id ';

	END IF;

	IF l_sgmt_id IS NOT NULL THEN

		l_where := l_where||' AND a.segment_id=:l_sgmt_id';
        ELSE
	l_from := l_from||',bim_i_sgmt_denorm dn';
	l_where := l_where||' and dn.immediate_parent_id is null
	and a.segment_id=dn.segment_id';

	END IF;


	l_setup_id := 'custom_setup_id';

	l_url_str_csch_jtf :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';

	IF get_admin_status = 'N' THEN

		l_from_outer := ' , ams_act_access_denorm ac ' ;
		l_where_outer := ' AND c.object_id  = ac.object_id
						   AND c.object_type  = ac.object_type
						   AND ac.resource_id = :l_resource_id ';

		l_resource_id := GET_RESOURCE_ID ;

	END IF;

	l_sqltext:='
	SELECT
		VIEWBY,
		VIEWBYID,
		VIEWBY BIM_ATTRIBUTE1,
		meaning BIM_ATTRIBUTE2,
		responses BIM_ATTRIBUTE3,
		NULL  BIM_ATTRIBUTE4,
		booked_amt BIM_ATTRIBUTE5,
		NULL  BIM_ATTRIBUTE6
		,'''||l_url_str_csch_jtf||'''||object_id  BIM_URL1
	FROM
	(
		SELECT
			c.name VIEWBY,
			VIEWBYID,
			l.meaning meaning,
			c.object_id object_id,
			SUM(responses)  responses ,
			SUM(prev_responses) prev_responses,
			SUM(booked_amt) booked_amt,
			SUM(prev_booked_amt) prev_booked_amt
		FROM
		(
			SELECT
				a.source_code_id viewbyid,
				a.schedule_purpose,
				SUM(a.responses) responses,
				0   prev_responses,
				SUM(a.booked_amt'||l_curr_suffix||') booked_amt,
				0 prev_booked_amt
			FROM  bim_sgmt_act_h_mv facts, bim_sgmt_act_b_mv a '||l_pc_from|| l_from||
			'  WHERE ( facts.schedule_start_date  BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE AND &BIS_CURRENT_ASOF_DATE )
			 AND facts.source_code_id=a.source_code_id AND facts.segment_id=a.segment_id
			'||l_where ||l_pc_where
			||'
			GROUP BY a.source_code_id , a.schedule_purpose
			UNION ALL
			SELECT
				a.source_code_id viewbyid,
				a.schedule_purpose,
				0 responses,
				SUM(a.responses)   prev_responses,
				0 booked_amt,
				SUM(a.booked_amt'||l_curr_suffix||') prev_booked_amt
			FROM  bim_sgmt_act_h_mv facts, bim_sgmt_act_b_mv a '||l_pc_from|| l_from||
			'  WHERE ( facts.schedule_start_date  BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE AND &BIS_PREVIOUS_ASOF_DATE )
			 AND facts.source_code_id=a.source_code_id AND facts.segment_id=a.segment_id
			'||l_where ||l_pc_where
			||'
			GROUP BY a.source_code_id , a.schedule_purpose
		)  a , ams_lookups l,bim_i_obj_name_mv c '||l_from_outer||'
	WHERE l.lookup_type(+) =''AMS_ACTIVITY_PURPOSES'' and l.lookup_code(+) =  a.schedule_purpose
	and  a.viewbyid = c.source_code_id
	and c.language=userenv(''LANG'') '||l_where_outer||'
	group by viewbyid,c.name , l.meaning , c.object_id
	)
   ';


	x_custom_sql := l_sqltext;
	l_custom_rec.attribute_name := ':l_record_type';
	l_custom_rec.attribute_value := l_record_type_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (1) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_sgmt_id';
	l_custom_rec.attribute_value := l_sgmt_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (2) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_cat_id';
	l_custom_rec.attribute_value := l_cat_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (3) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_resource_id';
	l_custom_rec.attribute_value := l_resource_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (4) := l_custom_rec;


END GET_CAMP_ACT_SQL;

PROCEDURE  GET_CAMP_TREND_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_sqltext					VARCHAR2 (20000);
	l_as_of_date				DATE;
	l_period_type				VARCHAR2 (2000);
	l_record_type_id			NUMBER;
	l_cat_id					VARCHAR2 (50) ;
	l_sgmt_id					VARCHAR2 (50) ;
	l_curr						VARCHAR2(50);
	l_view_by					VARCHAR2 (4000);
	l_select_filter				VARCHAR2 (20000); -- to build  select filter part
	l_where						VARCHAR2 (20000);  -- static where clause
	l_groupby					VARCHAR2 (2000);  -- to build  group by clause
	l_from						VARCHAR2 (20000);   -- from clause
	l_custom_rec				BIS_QUERY_ATTRIBUTES;
	l_object_type				VARCHAR2(30);

	l_start_date				VARCHAR2(30);
	l_curr_suffix				VARCHAR2(2);
	l_url_metric				VARCHAR2(10);
	l_url_viewby				VARCHAR2(100);
	l_url_viewbyid				VARCHAR2(100);
	l_col_name					VARCHAR2(30);
	l_pc_from					VARCHAR2(200);
	l_pc_where					VARCHAR2(2000);
	l_col_where					VARCHAR2(500);


BEGIN
	x_custom_output := bis_query_attributes_tbl ();
	l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
	bim_pmv_dbi_utl_pkg.get_bim_page_sgmt_params(p_page_parameter_tbl,
												l_as_of_date ,
												l_period_type,
												l_record_type_id,
												l_view_by,
												l_cat_id ,
												l_sgmt_id,
												l_curr ,
												l_url_metric,
												l_url_viewby,
												l_url_viewbyid
												) ;

	IF (l_curr = '''FII_GLOBAL1''')	THEN
		l_curr_suffix := '';

	ELSIF (l_curr = '''FII_GLOBAL2''')	THEN
		l_curr_suffix := '_s';

	ELSE
		l_curr_suffix := '';
	END IF;




	CASE l_url_metric
		WHEN 'ACT'  THEN	l_col_name := 'ACTIVITIES_COUNT';
		WHEN 'RESP' THEN	l_col_name := 'RESPONSES';
		WHEN 'LEAD' THEN	l_col_name := 'LEADS';
		WHEN 'OPPT' THEN	l_col_name := 'NEW_OPPORTUNITY_AMT'||l_curr_suffix ;
		WHEN 'BOOK' THEN	l_col_name := 'BOOKED_AMT'||l_curr_suffix;
	END CASE;

	CASE l_url_viewby

		WHEN  'TARGET SEGMENT+TARGET SEGMENT' THEN

			l_from := 'bim_sgmt_act_mv a ';

		WHEN 'MEDIA+MEDIA' THEN

			l_from := 'bim_sgmt_act_ch_mv a ';
			l_col_where := ' AND activity_id = '||l_url_viewbyid;

		WHEN 'CAMPAIGN+CAMPAIGN' THEN

			l_from := 'bim_sgmt_act_sh_mv a ';
			l_col_where := ' AND source_code_id = '||l_url_viewbyid;

		WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN

			l_from := 'bim_sgmt_act_mv a ';

	END CASE;

	 IF l_sgmt_id is null THEN
       l_where := 'AND dn.immediate_parent_id is null AND dn.segment_id = a.segment_id';
	   l_from := l_from||' , bim_i_sgmt_denorm dn ';
	ELSE
      l_where := 'AND a.segment_id=:l_sgmt_id';

	END IF;

	IF  l_cat_id IS NOT NULL THEN

		l_pc_from   :=  ' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs';
		l_pc_where  :=  ' AND a.category_id = edh.child_id
						AND edh.object_type = ''CATEGORY_SET''
						AND edh.object_id = mdcs.category_set_id
						AND mdcs.functional_area_id = 11
						AND edh.dbi_flag = ''Y''
						AND edh.parent_id = :l_cat_id ';

	ELSE
		l_pc_where :=     ' AND a.category_id = -9 ';

	END IF;

	l_sqltext:='
		SELECT
		VIEWBY,
		 bim_attribute2,
        	  bim_attribute3
		  FROM
		  ( SELECT
			fii.name VIEWBY,
			'||l_col_name||' bim_attribute2,
			CASE WHEN '||l_col_name||'_p =0 THEN NULL ELSE (('||l_col_name||'-'||l_col_name||'_p)/'||l_col_name||'_p)*100 END  bim_attribute3,
			fii.start_date startdate
		FROM
			(
			SELECT
			        dates.start_date start_date,
				SUM(DECODE(dates.period, ''C'','||l_col_name||',0)) '||l_col_name||',
				SUM(DECODE(dates.period, ''P'','||l_col_name||',0)) '||l_col_name||'_p
			FROM
				(
				SELECT
					fii.start_date START_DATE,
					''C'' PERIOD,
					LEAST(fii.end_date, &BIS_CURRENT_ASOF_DATE) REPORT_DATE
				FROM '||l_period_type||'   fii
				WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
				UNION ALL
				SELECT
					p2.start_date START_DATE,
					''P'' PERIOD,
					p1.report_date REPORT_DATE
				FROM
					(
					SELECT report_date, rownum id
					FROM
						(
							SELECT
							LEAST(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
							FROM ' ||l_period_type||'   fii
							WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE
							ORDER BY fii.start_date DESC
						)

					) p1
					,
					(
					 SELECT start_date,rownum id
					 FROM
						(
							SELECT
							fii.start_date START_DATE
							FROM  ' ||l_period_type||'  fii
							WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
							ORDER BY fii.start_date DESC
						)
					) p2
				WHERE p1.id(+) = p2.id
				) dates
				,'||l_from||l_pc_from||' ,fii_time_rpt_struct_v cal
			WHERE  cal.report_date	= dates.report_date
			AND bitand(cal.record_type_id,:l_record_type) = cal.record_type_id
			AND a.time_id = cal.time_id
			AND a.period_type_id = cal.period_type_id '
			||l_where||l_pc_where||l_col_where||' group by dates.start_date
			)s,'|| l_period_type||' fii
		WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
		AND  fii.start_date = s.start_date(+) ) a Order By a.startdate
		';

	x_custom_sql := l_sqltext;
	l_custom_rec.attribute_name := ':l_record_type';
	l_custom_rec.attribute_value := l_record_type_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (1) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_sgmt_id';
	l_custom_rec.attribute_value := l_sgmt_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (2) := l_custom_rec;
	l_custom_rec.attribute_name := ':l_cat_id';
	l_custom_rec.attribute_value := l_cat_id;
	l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
	l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
	x_custom_output.EXTEND;
	x_custom_output (3) := l_custom_rec;



END GET_CAMP_TREND_SQL;

END BIM_SGMT_INTL_UI_PVT;

/
